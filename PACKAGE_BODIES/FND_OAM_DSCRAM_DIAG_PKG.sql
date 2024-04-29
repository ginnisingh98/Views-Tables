--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_DIAG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_DIAG_PKG" as
/* $Header: AFOAMDSDIAGB.pls 120.10 2006/01/17 13:57 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_DIAG_PKG.';
   INIT_FAILED                  EXCEPTION;
   SYNC_FAILED                  EXCEPTION;
   VALIDATE_FAILED              EXCEPTION;

   -- # of seconds to wait when trying to sync the workers of a run on completion.
   B_MAX_WAIT                           CONSTANT NUMBER := 600;

   --run name prefix
   B_DIAG_RUN_NAME_PREFIX               CONSTANT VARCHAR2(20) := 'Diagnostic Test: ';

   --test table default params
   B_TEST_TABLE_OWNER           CONSTANT VARCHAR2(30) := 'APPS';
   B_TEST_TABLE_TABLESPACE      CONSTANT VARCHAR2(30) := 'APPS_TS_TX_DATA';
   B_TEST_TABLE_NAME_PREFIX     CONSTANT VARCHAR2(20) := 'FND_OAM_DSCRAM_TT_';
   --table serving as the master for test data so we don't re-create it each time
   B_TEST_TABLE_MASTER_NAME     CONSTANT VARCHAR2(30) := B_TEST_TABLE_NAME_PREFIX||'MASTER';

   ----------------------------------------
   -- Public Functions/Procedures
   ----------------------------------------

   --helper to drop table
   FUNCTION DROP_TEST_TABLE_INDICIES(p_table_name       IN VARCHAR2,
                                     p_owner            IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DROP_TEST_TABLE_INDICIES';

      l_stmt            VARCHAR2(2000);
      index_missing     EXCEPTION;
      PRAGMA EXCEPTION_INIT(index_missing, -1418);
   BEGIN
      fnd_oam_debug.log(1, l_ctxt, 'Dropping test table indicies');
      l_stmt := 'DROP INDEX '||p_table_name||'_N1';
      EXECUTE IMMEDIATE l_stmt;
      l_stmt := 'DROP INDEX '||p_table_name||'_N2';
      EXECUTE IMMEDIATE l_stmt;
      RETURN TRUE;
   EXCEPTION
      WHEN index_missing THEN
         RETURN TRUE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         RETURN FALSE;
   END;

   --Private, helper to MAKE_TEST_TABLE to drop it if it already exists
   FUNCTION DROP_TEST_TABLE(p_table_name        IN VARCHAR2,
                            p_owner             IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'DROP_TEST_TABLE';

      l_stmt            VARCHAR2(2000);
   BEGIN
      IF NOT DROP_TEST_TABLE_INDICIES(p_table_name,
                                      p_owner) THEN
         RETURN FALSE;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Dropping table');
      l_stmt := 'DROP TABLE '||p_owner||'.'||p_table_name;
      EXECUTE IMMEDIATE l_stmt;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         RETURN FALSE;
   END;

   --helper to make_test_table
   FUNCTION MAKE_TEST_TABLE_INDICIES(p_table_name       IN VARCHAR2,
                                     p_owner            IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_TEST_TABLE_INDICIES';

      l_stmt    VARCHAR2(2000);
   BEGIN
      fnd_oam_debug.log(1, l_ctxt, 'Creating Test Table Indicies');
      l_stmt := 'CREATE UNIQUE INDEX '||p_table_name||'_U1 ON '||p_table_name||' (C1)';
      EXECUTE IMMEDIATE l_stmt;
      l_stmt := 'CREATE INDEX '||p_table_name||'_N1 ON '||p_table_name||' (C3)';
      EXECUTE IMMEDIATE l_stmt;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         RETURN FALSE;
   END;

   --Private helper to make_test_table to create the data
   FUNCTION MAKE_TEST_TABLE_DATA(p_table_name   IN VARCHAR2,
                                 p_num_rows     IN NUMBER,
                                 p_owner        IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_TEST_TABLE_DATA';

      l_stmt    VARCHAR2(2000);
      k         NUMBER;
      v2        NUMBER          := 1;
      v3        VARCHAR2(30)    := 'ROWNAME';
      v4        DATE            := FND_DATE.CANONICAL_TO_DATE('2005/08/30 11:22:33');
      v5        VARCHAR2(2000)  := 'ROWDESC';
      v5_len    NUMBER          := 993;
      v5_tmp    VARCHAR2(2000);

      v1_vals   DBMS_SQL.NUMBER_TABLE;
      v2_vals   DBMS_SQL.NUMBER_TABLE;
      v3_vals   DBMS_SQL.VARCHAR2_TABLE;
      v4_vals   DBMS_SQL.DATE_TABLE;
      v5_vals   DBMS_SQL.VARCHAR2_TABLE;
   BEGIN
      fnd_oam_debug.log(1, l_ctxt, 'Creating Test Table Data');
      l_stmt := 'INSERT INTO '||p_owner||'.'||p_table_name||' (C1, C2, C3, C4, C5) VALUES (:1, :2, :3, :4, :5)';

      --if below some threshold, prepare in memory and insert
      --DBMS_RANDOM.initialize(100);
      IF p_num_rows <= 1000000 THEN
         fnd_oam_debug.log(1, l_ctxt, 'Using Buffer and Bulk Bind method.');
         k := 1;
         WHILE k <= p_num_rows LOOP
            v1_vals(k) := k;
            v2_vals(k) := v2;
            v3_vals(k) := v3||to_char(round((k/20),0));
            --v4_vals(k) := SYSDATE;
            v4_vals(k) := v4;
            --v5_vals(k) := v5||DBMS_RANDOM.STRING('U', v5_len);
            v5_vals(k) := v5||k;
            k := k + 1;
         END LOOP;
         FORALL k IN 1..p_num_rows
            EXECUTE IMMEDIATE l_stmt USING v1_vals(k), v2_vals(k), v3_vals(k), v4_vals(k), v5_vals(k);
      ELSE
         fnd_oam_debug.log(1, l_ctxt, 'Using Serial Insert method...');
         --populate the table
         k := 0;
         WHILE k < p_num_rows LOOP
            --v4 := SYSDATE;
            --v5_tmp := v5||DBMS_RANDOM.STRING('U', v5_len);
            v5_tmp := v5||k;
            EXECUTE IMMEDIATE l_stmt USING k, v2, v3||round(to_char(k/20),0), v4, v5_tmp;
            k := k + 1;
            IF MOD(k, 1000) = 0 THEN
               COMMIT;
            END IF;
         END LOOP;
      END IF;
      --DBMS_RANDOM.terminate;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         RETURN FALSE;
   END;

   -- Private, helper to the EXECUTE_* procedures to create a test table for ensuring diagnostic-style
   -- tests don't manipulate data before executing diagnostic tests on real tables.
   FUNCTION MAKE_TEST_TABLE(p_table_name        IN VARCHAR2 DEFAULT B_TEST_TABLE_MASTER_NAME,
                            p_num_rows          IN NUMBER   DEFAULT 1000,
                            p_owner             IN VARCHAR2 DEFAULT B_TEST_TABLE_OWNER,
                            p_tablespace        IN VARCHAR2 DEFAULT B_TEST_TABLE_TABLESPACE)
      RETURN BOOLEAN
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_TEST_TABLE';

      table_exists              EXCEPTION;
      tablespace_missing        EXCEPTION;
      PRAGMA EXCEPTION_INIT(table_exists, -955);
      PRAGMA EXCEPTION_INIT(tablespace_missing, -959);

      l_table_def       VARCHAR2(2000);
      l_tablespace_def  VARCHAR2(1000);
      l_nologging       VARCHAR2(100) := 'NOLOGGING';
   BEGIN
      fnd_oam_debug.log(1, l_ctxt, 'Creating table: '||p_owner||'.'||p_table_name||'('||p_tablespace||')');
      l_table_def := 'CREATE TABLE '||p_table_name||' (C1 NUMBER NOT NULL,
                                                       C2 NUMBER,
                                                       C3 VARCHAR2(30),
                                                       C4 DATE,
                                                       C5 VARCHAR2(2000))';
      l_tablespace_def := 'TABLESPACE '||p_tablespace;

      BEGIN
         EXECUTE IMMEDIATE l_table_def||' '||l_tablespace_def||' '||l_nologging;
      EXCEPTION
         WHEN table_exists THEN
            fnd_oam_debug.log(1, l_ctxt, 'Table already exists - dropping first.');
            IF NOT DROP_TEST_TABLE(p_table_name,
                                   p_owner) THEN
               RETURN FALSE;
            END IF;
            --otherwise, try to create the table again
            EXECUTE IMMEDIATE l_table_def||' '||l_tablespace_def||' '||l_nologging;
         WHEN tablespace_missing THEN
            fnd_oam_debug.log(1, l_ctxt, 'Tablespace missing, using default tablespace.');
            BEGIN
               EXECUTE IMMEDIATE l_table_def||' '||l_nologging;
            EXCEPTION
               WHEN table_exists THEN
                  fnd_oam_debug.log(1, l_ctxt, 'Table already exists - dropping first.');
                  IF NOT DROP_TEST_TABLE(p_table_name,
                                         p_owner) THEN
                     RETURN FALSE;
                  END IF;
                  --otherwise, try to create the table again
                  EXECUTE IMMEDIATE l_table_def||' '||l_nologging;
               WHEN OTHERS THEN
                  fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
                  RETURN FALSE;
            END;
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
            RETURN FALSE;
      END;
      COMMIT;

      -- make the table's data
      IF MAKE_TEST_TABLE_DATA(p_table_name,
                              p_num_rows,
                              p_owner) THEN
         COMMIT;
      ELSE
         ROLLBACK;
         RETURN FALSE;
      END IF;

      -- make the table's data
      IF MAKE_TEST_TABLE_INDICIES(p_table_name,
                                  p_owner) THEN
         COMMIT;
      ELSE
         ROLLBACK;
         RETURN FALSE;
      END IF;

      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         ROLLBACK;
         RETURN FALSE;
   END;

   -- Private, helper to the EXECUTE_* procedures to duplicate a test table.  Faster than create.
   FUNCTION DUPLICATE_TEST_TABLE(p_dest_table_name      IN VARCHAR2,
                                 p_src_table_name       IN VARCHAR2 DEFAULT B_TEST_TABLE_MASTER_NAME,
                                 p_dest_owner           IN VARCHAR2 DEFAULT B_TEST_TABLE_OWNER,
                                 p_src_owner            IN VARCHAR2 DEFAULT B_TEST_TABLE_OWNER,
                                 p_dest_tablespace      IN VARCHAR2 DEFAULT B_TEST_TABLE_TABLESPACE)
      RETURN BOOLEAN
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt    VARCHAR2(60) := PKG_NAME||'DUPLICATE_TEST_TABLE';

      table_exists      EXCEPTION;
      PRAGMA EXCEPTION_INIT(table_exists, -955);

      l_stmt    VARCHAR2(2000);
   BEGIN
      fnd_oam_debug.log(1, l_ctxt, 'Creating table: '||p_dest_owner||'.'||p_dest_table_name||' from table '||p_src_owner||'.'||p_src_table_name);
      l_stmt := 'CREATE TABLE '||p_dest_table_name||' (C1 NOT NULL,
                                                       C2,
                                                       C3,
                                                       C4,
                                                       C5) TABLESPACE '||p_dest_tablespace|| 'NOLOGGING
                                                       AS SELECT * FROM '||p_src_owner||'.'||p_src_table_name;
      BEGIN
         EXECUTE IMMEDIATE l_stmt;
      EXCEPTION
         WHEN table_exists THEN
            fnd_oam_debug.log(1, l_ctxt, 'Table already exists - dropping first.');
            IF NOT DROP_TEST_TABLE(p_dest_table_name,
                                   p_dest_owner) THEN
               RETURN FALSE;
            END IF;
            --otherwise, try to create the table again
            EXECUTE IMMEDIATE l_stmt;
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
            RETURN FALSE;
      END;

      COMMIT;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         ROLLBACK;
         RETURN FALSE;
   END;

   -- Private, helper to the VALIDATE_* procedures to make sure diagnostic tests didn't modify the contents of
   -- the test table.
   FUNCTION VALIDATE_TEST_TABLE_UNCHANGED(p_table_name          IN VARCHAR2 DEFAULT B_TEST_TABLE_MASTER_NAME,
                                          p_num_rows            IN NUMBER   DEFAULT 1000,
                                          p_owner               IN VARCHAR2 DEFAULT B_TEST_TABLE_OWNER,
                                          p_tablespace          IN VARCHAR2 DEFAULT B_TEST_TABLE_TABLESPACE)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'VALIDATE_TEST_TABLE_UNCHANGED';

      l_stmt            VARCHAR2(2000);
      l_row_count       NUMBER;
      l_c2_sum          NUMBER;
      l_c3_bad_count    NUMBER;
      l_c4              DATE := FND_DATE.CANONICAL_TO_DATE('2005/08/30 11:22:33');
      l_c4_bad_count    NUMBER;
   BEGIN
      fnd_oam_debug.log(1, l_ctxt, 'Validating table: '||p_owner||'.'||p_table_name||'('||p_tablespace||')');

      --check the row count
      l_stmt := 'SELECT COUNT(ROWID) FROM '||p_owner||'.'||p_table_name;
      BEGIN
         EXECUTE IMMEDIATE l_stmt INTO l_row_count;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(1, l_ctxt, 'Error selecting row count: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
            RETURN FALSE;
      END;
      IF l_row_count IS NULL OR l_row_count <> p_num_rows THEN
         fnd_oam_debug.log(6, l_ctxt, 'Queried row count('||l_row_count||') unequal to expected row count('||p_num_rows||')');
         RETURN FALSE;
      END IF;

      --check that the sum of C2 is the row count
      l_stmt := 'SELECT SUM(C2) FROM '||p_owner||'.'||p_table_name;
      BEGIN
         EXECUTE IMMEDIATE l_stmt INTO l_c2_sum;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(1, l_ctxt, 'Error selecting C2 sum: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
            RETURN FALSE;
      END;
      IF l_c2_sum IS NULL OR l_c2_sum <> p_num_rows THEN
         fnd_oam_debug.log(6, l_ctxt, 'Column C2 has sum('||l_c2_sum||'), should be equal to the row count('||p_num_rows||')');
         RETURN FALSE;
      END IF;

      --check that C3 has the proper setup
      l_stmt := 'SELECT COUNT(ROWID) FROM '||p_owner||'.'||p_table_name||' WHERE C3 <> CONCAT(''ROWNAME'',to_char(round((C1/20),0)))';
      BEGIN
         EXECUTE IMMEDIATE l_stmt INTO l_c3_bad_count;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(1, l_ctxt, 'Error selecting C3 bad count: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
            RETURN FALSE;
      END;
      IF l_c3_bad_count IS NULL OR l_c3_bad_count <> 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Found ('||l_c3_bad_count||') rows with invalid C3 values.');
         RETURN FALSE;
      END IF;

      --check that C4 has the proper setup
      l_stmt := 'SELECT COUNT(ROWID) FROM '||p_owner||'.'||p_table_name||' WHERE C4 <> :1';
      BEGIN
         EXECUTE IMMEDIATE l_stmt INTO l_c4_bad_count USING l_c4;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(1, l_ctxt, 'Error selecting C4 bad count: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
            RETURN FALSE;
      END;
      IF l_c4_bad_count IS NULL OR l_c4_bad_count <> 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Found ('||l_c3_bad_count||') rows with invalid C4 values.');
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         RETURN FALSE;
   END;

   -- Private, helper to the VALIDATE_* procedures to make sure diagnostic tests didn't modify the contents of
   -- the test table.
   FUNCTION VALIDATE_TEST_TABLE_ARG_VALUES(p_using_splitting    IN BOOLEAN,
                                           p_c2_arg_id          IN NUMBER,
                                           p_c2_target_sum      IN NUMBER,
                                           p_table_name         IN VARCHAR2 DEFAULT B_TEST_TABLE_MASTER_NAME,
                                           p_num_rows           IN NUMBER   DEFAULT 1000,
                                           p_c3_arg_id          IN NUMBER   DEFAULT NULL,
                                           p_c4_arg_id          IN NUMBER   DEFAULT NULL,
                                           p_owner              IN VARCHAR2 DEFAULT B_TEST_TABLE_OWNER,
                                           p_tablespace         IN VARCHAR2 DEFAULT B_TEST_TABLE_TABLESPACE)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'VALIDATE_TEST_TABLE_ARG_VALUES';

      l_valid_value_flag VARCHAR2(3);
      l_canonical_value  VARCHAR2(4000);
      l_stmt             VARCHAR2(2000);
      l_c2_sum           NUMBER;
      l_c3_bad_count     NUMBER;
      l_c4               DATE := FND_DATE.CANONICAL_TO_DATE('2005/08/30 11:22:33');
      l_c4_bad_count     NUMBER;
   BEGIN
      fnd_oam_debug.log(1, l_ctxt, 'Validating Arg Values for table: '||p_owner||'.'||p_table_name||'('||p_tablespace||')');

      --check the c2 value
      BEGIN
         IF p_using_splitting THEN
            SELECT SUM(to_number(canonical_value))
               INTO l_c2_sum
               FROM fnd_oam_dscram_arg_values
               WHERE arg_id = p_c2_arg_id
               AND valid_value_flag = FND_API.G_TRUE;
         ELSE
            SELECT valid_value_flag, canonical_value
               INTO l_valid_value_flag, l_canonical_value
               FROM fnd_oam_dscram_args_b
               WHERE arg_id = p_c2_arg_id;
            IF l_valid_value_flag IS NULL OR l_valid_value_flag <> FND_API.G_TRUE THEN
               fnd_oam_debug.log(6, l_ctxt, 'Valid value flag of C2 Sum is incorrect: '||l_valid_value_flag);
               RETURN FALSE;
            END IF;
            l_c2_sum := FND_NUMBER.CANONICAL_TO_NUMBER(l_canonical_value);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to query arg value for C2 sum: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
            RETURN FALSE;
      END;
      IF l_c2_sum IS NULL OR l_c2_sum <> p_c2_target_sum THEN
         fnd_oam_debug.log(6, l_ctxt, 'C2 Sum('||l_c2_sum||') not equal to target value('||p_c2_target_sum||')');
         RETURN FALSE;
      END IF;

      --check the c3 val
      IF p_c3_arg_id IS NOT NULL THEN
         BEGIN
            IF p_using_splitting THEN
               SELECT SUM(to_number(canonical_value))
                  INTO l_c3_bad_count
                  FROM fnd_oam_dscram_arg_values
                  WHERE arg_id = p_c3_arg_id
                  AND valid_value_flag = FND_API.G_TRUE;
            ELSE
               SELECT valid_value_flag, canonical_value
                  INTO l_valid_value_flag, l_canonical_value
                  FROM fnd_oam_dscram_args_b
                  WHERE arg_id = p_c3_arg_id;
               IF l_valid_value_flag IS NULL OR l_valid_value_flag <> FND_API.G_TRUE THEN
                  fnd_oam_debug.log(6, l_ctxt, 'Valid value flag of C3 Bad Count is incorrect: '||l_valid_value_flag);
                  RETURN FALSE;
               END IF;
               l_c2_sum := FND_NUMBER.CANONICAL_TO_NUMBER(l_canonical_value);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to query arg value for C3 bad count: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
               RETURN FALSE;
         END;
         IF l_c3_bad_count IS NULL OR l_c3_bad_count <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'C3 Bad Count('||l_c3_bad_count||') not equal to zero.');
            RETURN FALSE;
         END IF;
      END IF;

      --check the c4 val
      IF p_c4_arg_id IS NOT NULL THEN
         BEGIN
            IF p_using_splitting THEN
               SELECT SUM(to_number(canonical_value))
                  INTO l_c4_bad_count
                  FROM fnd_oam_dscram_arg_values
                  WHERE arg_id = p_c4_arg_id
                  AND valid_value_flag = FND_API.G_TRUE;
            ELSE
               SELECT valid_value_flag, canonical_value
                  INTO l_valid_value_flag, l_canonical_value
                  FROM fnd_oam_dscram_args_b
                  WHERE arg_id = p_c4_arg_id;
               IF l_valid_value_flag IS NULL OR l_valid_value_flag <> FND_API.G_TRUE THEN
                  fnd_oam_debug.log(6, l_ctxt, 'Valid value flag of C4 Bad Count is incorrect: '||l_valid_value_flag);
                  RETURN FALSE;
               END IF;
               l_c2_sum := FND_NUMBER.CANONICAL_TO_NUMBER(l_canonical_value);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to query arg value for C4 bad count: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
               RETURN FALSE;
         END;
         IF l_c4_bad_count IS NULL OR l_c4_bad_count <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'C4 Bad Count('||l_c4_bad_count||') not equal to zero.');
            RETURN FALSE;
         END IF;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled exception: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         RETURN FALSE;
   END;

   --used by the SYNC functions to coordinate on a name for the finish message pipe
   FUNCTION MAKE_RUN_PIPE_NAME(p_run_id         IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN FND_OAM_DSCRAM_UTILS_PKG.G_DSCRAM_GLOBAL_PREFIX||'PIPE_'||to_char(p_run_id);
   END;

   --used by the SYNC functions to coordinate on a name for the ack pipe used by the
   --initializing worker to tell other workers when they can proceed and what the final
   --status was for the previous test.
   FUNCTION MAKE_RUN_ACK_PIPE_NAME(p_run_id             IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN FND_OAM_DSCRAM_UTILS_PKG.G_DSCRAM_GLOBAL_PREFIX||'ACKPIPE_'||to_char(p_run_id);
   END;

   --used in delete_all_diagnostic runs to clear out the pipes we use for sychronizing runs
   FUNCTION CLEAR_PIPES(p_run_id IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'CLEAR_PIPES';

      l_run_pipe        VARCHAR2(60) := MAKE_RUN_PIPE_NAME(p_run_id);
      l_run_ack_pipe    VARCHAR2(60) := MAKE_RUN_ACK_PIPE_NAME(p_run_id);
      l_retval  INTEGER;
   BEGIN
      --could also use DBMS_PIPE.PURGE(<pipe_name>) if we didn't want to know how many stale messages there were
      WHILE TRUE LOOP
         l_retval := DBMS_PIPE.RECEIVE_MESSAGE(l_run_pipe,
                                               0);
         IF l_retval = 0 THEN
            fnd_oam_debug.log(1, l_ctxt, 'Removed message from run pipe.');
         ELSE
            EXIT;
         END IF;
      END LOOP;
      WHILE TRUE LOOP
         l_retval := DBMS_PIPE.RECEIVE_MESSAGE(l_run_ack_pipe,
                                               0);
         IF l_retval = 0 THEN
            fnd_oam_debug.log(1, l_ctxt, 'Removed message from run ack pipe.');
         ELSE
            EXIT;
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Error while cleaning pipes: Error Code('||SQLCODE||'), Message: "'||SQLERRM||'"');
         RETURN FALSE;
   END;

   --Public
   PROCEDURE DELETE_ALL_DIAGNOSTIC_RUNS(x_verdict OUT NOCOPY VARCHAR2)
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'DELETE_ALL_DIAGNOSTIC_RUNS';

      l_ids     DBMS_SQL.NUMBER_TABLE;
      k         NUMBER;
      l_retbool BOOLEAN;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out all runs in the diagnostic space
      SELECT run_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_runs_b
         WHERE run_id between 0 and 999;

      IF SQL%NOTFOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_TRUE;
         RETURN;
      END IF;

      --loop over ids found, nuking
      k := l_ids.FIRST;
      l_retbool := TRUE;
      WHILE k IS NOT NULL LOOP
         IF NOT FND_OAM_DSCRAM_UTILS_PKG.DELETE_RUN(l_ids(k)) THEN
            l_retbool := FALSE;
         END IF;

         IF NOT CLEAR_PIPES(l_ids(k)) THEN
            l_retbool := FALSE;
         END IF;
         k := l_ids.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
         RETURN;
   END;

   -- helper to remove a list of global arguments since these would affect later tests
   FUNCTION DELETE_GLOBAL_ARGS(p_global_arg_names       IN DBMS_SQL.VARCHAR2_TABLE)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'DELETE_GLOBAL_ARGS';
      k         NUMBER;
      l_arg_id  NUMBER;
      l_arg_name        VARCHAR2(60);
   BEGIN
      k := p_global_arg_names.FIRST;
      WHILE k IS NOT NULL LOOP
         l_arg_name := p_global_arg_names(k);
         fnd_oam_debug.log(1, l_ctxt, 'Deleting Global Arg: '||l_arg_name);
         DELETE FROM fnd_oam_dscram_args_b
            WHERE parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_GLOBAL
            AND arg_name = l_arg_name
            RETURNING arg_id INTO l_arg_id;
         DELETE FROM fnd_oam_dscram_args_tl
            WHERE arg_id = l_arg_id;
         DELETE FROM fnd_oam_dscram_arg_values
            WHERE arg_id = l_arg_id;
         k := p_global_arg_names.NEXT(k);
      END LOOP;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   --after a run is finished, validate that the dml entity completed as expected.
   FUNCTION VALIDATE_DML_SUCCESS(p_run_id               IN NUMBER,
                                 p_dml_id               IN NUMBER,
                                 p_target_status        IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS,
                                 p_target_rows          IN NUMBER DEFAULT -1)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_DML_SUCCESS';

      l_status                  VARCHAR2(30);
      l_rows_processed          NUMBER;

      k                         NUMBER;
      l_retbool                 BOOLEAN;
   BEGIN
      --fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out the run's final status
      SELECT finished_ret_sts, rows_processed
         INTO l_status, l_rows_processed
         FROM fnd_oam_dscram_dmls
         WHERE dml_id = p_dml_id;

      --status check
      IF l_status IS NULL OR l_status <> p_target_status THEN
         fnd_oam_debug.log(6, l_ctxt, 'Status incorrect: Current('||l_status||'), Target('||p_target_status||')');
         RETURN FALSE;
      END IF;

      --check that we processed all the rows
      IF p_target_rows >= 0 AND (l_rows_processed IS NULL OR l_rows_processed <> p_target_rows) THEN
         fnd_oam_debug.log(6, l_ctxt, 'DML ID('||p_dml_id||'), processed '||l_rows_processed||' rows, should have been '||p_target_rows);
         RETURN FALSE;
      END IF;

      --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(6, l_ctxt, 'DML with DML ID ('||p_dml_id||') not found.');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --after a run is finished, validate that the dml entity completed as expected.
   FUNCTION VALIDATE_PLSQL_SUCCESS(p_run_id             IN NUMBER,
                                   p_plsql_id           IN NUMBER,
                                   p_target_status      IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_PLSQL_SUCCESS';

      l_status                  VARCHAR2(30);

      k                         NUMBER;
      l_retbool                 BOOLEAN;
   BEGIN
      --fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out the run's final status
      SELECT finished_ret_sts
         INTO l_status
         FROM fnd_oam_dscram_plsqls
         WHERE plsql_id = p_plsql_id;

      --status check
      IF l_status IS NULL OR l_status <> p_target_status THEN
         fnd_oam_debug.log(6, l_ctxt, 'Status incorrect: Current('||l_status||'), Target('||p_target_status||')');
         RETURN FALSE;
      END IF;

      --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(6, l_ctxt, 'PLSQL with PLSQL ID ('||p_plsql_id||') not found.');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --after a run is finished, validate that the unit entity completed as expected.
   FUNCTION VALIDATE_UNIT_SUCCESS(p_run_id              IN NUMBER,
                                  p_unit_id             IN NUMBER,
                                  p_target_status       IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_UNIT_SUCCESS';

      l_status                  VARCHAR2(30);
      l_workers_assigned        NUMBER;
      k                         NUMBER;
      l_retbool                 BOOLEAN;
   BEGIN
      --fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out the run's final status
      SELECT unit_status, workers_assigned
         INTO l_status, l_workers_assigned
         FROM fnd_oam_dscram_units
         WHERE unit_id = p_unit_id;

      --status check
      IF (l_status IS NULL AND p_target_status IS NOT NULL) OR
         (l_status IS NOT NULL AND p_target_status IS NULL) OR
         l_status <> p_target_status THEN

         fnd_oam_debug.log(6, l_ctxt, 'Status incorrect: Current('||l_status||'), Target('||p_target_status||')');
         RETURN FALSE;
      END IF;

      --worker check
      IF l_workers_assigned IS NULL OR l_workers_assigned > 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Still has workers: '||l_workers_assigned);
         RETURN FALSE;
      END IF;

      --check the status row
      --skip for now

      --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unit with Unit ID ('||p_unit_id||') not found.');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --after a run is finished, validate that the task entity completed as expected.
   FUNCTION VALIDATE_TASK_SUCCESS(p_run_id              IN NUMBER,
                                  p_task_id             IN NUMBER,
                                  p_target_status       IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_TASK_SUCCESS';

      l_status                  VARCHAR2(30);
      l_workers_assigned        NUMBER;
      k                         NUMBER;
      l_retbool                 BOOLEAN;
   BEGIN
      --fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out the run's final status
      SELECT task_status, workers_assigned
         INTO l_status, l_workers_assigned
         FROM fnd_oam_dscram_tasks
         WHERE task_id = p_task_id;

      --status check
      IF l_status IS NULL OR l_status <> p_target_status THEN
         fnd_oam_debug.log(6, l_ctxt, 'Status incorrect: Current('||l_status||'), Target('||p_target_status||')');
         RETURN FALSE;
      END IF;

      --worker check
      IF l_workers_assigned IS NULL OR l_workers_assigned > 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Still has workers: '||l_workers_assigned);
         RETURN FALSE;
      END IF;

      --check the status row
      --skip for now

      --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(6, l_ctxt, 'Task with Task ID ('||p_task_id||') not found.');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --after a run is finished, validate that the bundle entity completed as expected.
   FUNCTION VALIDATE_BUNDLE_SUCCESS(p_run_id            IN NUMBER,
                                    p_bundle_id         IN NUMBER,
                                    p_target_status     IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_BUNDLE_SUCCESS';

      l_status          VARCHAR2(30);
      l_workers_assigned        NUMBER;
      k                 NUMBER;
      l_retbool         BOOLEAN;
   BEGIN
      --fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out the run's final status
      SELECT bundle_status, workers_assigned
         INTO l_status, l_workers_assigned
         FROM fnd_oam_dscram_bundles
         WHERE run_id = p_run_id
         AND bundle_id = p_bundle_id;

      --status check
      IF l_status IS NULL OR l_status <> p_target_status THEN
         fnd_oam_debug.log(6, l_ctxt, 'Status incorrect: Current('||l_status||'), Target('||p_target_status||')');
         RETURN FALSE;
      END IF;

      --worker check
      IF l_workers_assigned IS NULL OR l_workers_assigned > 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Still has workers: '||l_workers_assigned);
         RETURN FALSE;
      END IF;

      --check the status row
      --skip for now

      --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(6, l_ctxt, 'Bundle with Run ID ('||p_run_id||') and Bundle ID ('||p_bundle_id||') not found.');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --after a run is finished, validate that the run entity completed as expected.  In this case
   --we check for processing instead of processed since processed would have been set by the Java controller
   FUNCTION VALIDATE_RUN_SUCCESS(p_run_id               IN NUMBER,
                                 p_target_status        IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
                                 x_run_stat_id          OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_RUN_SUCCESS';

      l_status          VARCHAR2(30);
      l_run_stat_id     NUMBER;
      k                 NUMBER;
      l_retbool         BOOLEAN;
   BEGIN
      --fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out the run's final status
      SELECT run_status, last_run_stat_id
         INTO l_status, l_run_stat_id
         FROM fnd_oam_dscram_runs_vl
         WHERE run_id = p_run_id;

      --status check
      IF l_status IS NULL OR l_status <> p_target_status THEN
         fnd_oam_debug.log(6, l_ctxt, 'Status incorrect: Current('||l_status||'), Target('||p_target_status||')');
         RETURN FALSE;
      END IF;

      --check the status row
      --skip for now

      --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_run_stat_id := l_run_stat_id;
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(6, l_ctxt, 'Run ID ('||p_run_id||') not found.');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- Helper function to validate a single run, bundle, task.
   -- Covers the simple test cases.
   FUNCTION VALIDATE_UNIT_RECURSIVE(p_run_id            IN NUMBER,
                                    p_run_stat_id       IN NUMBER   DEFAULT NULL,
                                    p_unit_id           IN NUMBER,
                                    p_num_workers       IN NUMBER   DEFAULT 1,
                                    p_num_dmls          IN NUMBER   DEFAULT -1,
                                    p_num_dml_rows      IN NUMBER   DEFAULT -1,
                                    p_num_plsqls        IN NUMBER   DEFAULT -1,
                                    p_unit_status       IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                    p_dml_status        IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS,
                                    p_plsql_status      IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_UNIT_RECURSIVE';
      l_run_stat_id     NUMBER;
      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_id              NUMBER;
      k                 NUMBER;
      l_count           NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      fnd_oam_debug.log(1, l_ctxt, 'Unit ID: '||p_unit_id);

      --first validate the bundle
      IF NOT VALIDATE_UNIT_SUCCESS(p_run_id,
                                   p_unit_id,
                                   p_unit_status) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --doesn't handle the case where this unit is a concurrent group unit

      IF p_num_dmls >= 0 THEN
         --now query child dmls
         SELECT dml_id
            BULK COLLECT INTO l_ids
            FROM fnd_oam_dscram_dmls
            WHERE unit_id = p_unit_id;

         l_count := 0;
         k := l_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            fnd_oam_debug.log(1, l_ctxt, 'Dml ID: '||l_ids(k));
            IF NOT VALIDATE_DML_SUCCESS(p_run_id,
                                        l_ids(k),
                                        p_dml_status,
                                        p_num_dml_rows) THEN
               RAISE VALIDATE_FAILED;
            END IF;

            k := l_ids.NEXT(k);
            l_count := l_count + 1;
         END LOOP;
         IF (l_count IS NULL OR l_count <> p_num_dmls) THEN
            fnd_oam_debug.log(6, l_ctxt, 'Number of dmls found ('||l_count||') did not match the number expected ('||p_num_dmls||')');
            RAISE VALIDATE_FAILED;
         END IF;
      END IF;

      IF p_num_plsqls >= 0 THEN
         --now query child dmls
         SELECT plsql_id
            BULK COLLECT INTO l_ids
            FROM fnd_oam_dscram_plsqls
            WHERE unit_id = p_unit_id;

         l_count := 0;
         k := l_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            fnd_oam_debug.log(1, l_ctxt, 'Plsql ID: '||l_ids(k));
            IF NOT VALIDATE_PLSQL_SUCCESS(p_run_id,
                                          l_ids(k),
                                          p_plsql_status) THEN
               RAISE VALIDATE_FAILED;
            END IF;

            k := l_ids.NEXT(k);
            l_count := l_count + 1;
         END LOOP;
         IF (l_count IS NULL OR l_count <> p_num_plsqls) THEN
            fnd_oam_debug.log(6, l_ctxt, 'Number of dmls found ('||l_count||') did not match the number expected ('||p_num_plsqls||')');
            RAISE VALIDATE_FAILED;
         END IF;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Helper function to validate a single run, bundle, task.
   -- Covers the simple test cases.
   FUNCTION VALIDATE_TASK_RECURSIVE(p_run_id            IN NUMBER,
                                    p_run_stat_id       IN NUMBER   DEFAULT NULL,
                                    p_task_id           IN NUMBER,
                                    p_num_workers       IN NUMBER   DEFAULT 1,
                                    p_num_units         IN NUMBER   DEFAULT -1,
                                    p_num_dmls          IN NUMBER   DEFAULT -1,
                                    p_num_dml_rows      IN NUMBER   DEFAULT -1,
                                    p_num_plsqls        IN NUMBER   DEFAULT -1,
                                    p_task_status       IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                    p_unit_status       IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                    p_dml_status        IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS,
                                    p_plsql_status      IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS)

      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_TASK_RECURSIVE';
      l_run_stat_id     NUMBER;
      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_id              NUMBER;
      k                 NUMBER;
      l_count_units     NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      fnd_oam_debug.log(1, l_ctxt, 'Task ID: '||p_task_id);

      --first validate the bundle
      IF NOT VALIDATE_TASK_SUCCESS(p_run_id,
                                   p_task_id,
                                   p_task_status) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      IF p_num_units >= 0 THEN
         --now query the units and validate those
         SELECT unit_id
            BULK COLLECT INTO l_ids
            FROM fnd_oam_dscram_units
            WHERE task_id = p_task_id
            AND concurrent_group_unit_id IS NULL;

         l_count_units := 0;
         k := l_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            IF NOT VALIDATE_UNIT_RECURSIVE(p_run_id,
                                           l_run_stat_id,
                                           l_ids(k),
                                           p_num_workers,
                                           p_num_dmls,
                                           p_num_dml_rows,
                                           p_num_plsqls,
                                           p_unit_status,
                                           p_dml_status,
                                           p_plsql_status) THEN
               RAISE VALIDATE_FAILED;
            END IF;

            k := l_ids.NEXT(k);
            l_count_units := l_count_units + 1;
         END LOOP;
         IF p_num_units >= 0 AND (l_count_units IS NULL OR l_count_units <> p_num_units) THEN
            fnd_oam_debug.log(6, l_ctxt, 'Task ID('||p_task_id||'), Number of units found ('||l_count_units||') did not match the number expected ('||p_num_units||')');
            RAISE VALIDATE_FAILED;
         END IF;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Helper function to validate a single run, bundle, task.
   -- Covers the simple test cases.
   FUNCTION VALIDATE_BUNDLE_RECURSIVE(p_run_id          IN NUMBER,
                                      p_run_stat_id     IN NUMBER   DEFAULT NULL,
                                      p_bundle_id       IN NUMBER,
                                      p_num_workers     IN NUMBER   DEFAULT 1,
                                      p_num_tasks       IN NUMBER   DEFAULT -1,
                                      p_num_units       IN NUMBER   DEFAULT -1,
                                      p_num_dmls        IN NUMBER   DEFAULT -1,
                                      p_num_dml_rows    IN NUMBER   DEFAULT -1,
                                      p_num_plsqls      IN NUMBER   DEFAULT -1,
                                      p_bundle_status   IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                      p_task_status     IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                      p_unit_status     IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                      p_dml_status      IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS,
                                      p_plsql_status    IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS)

      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_BUNDLE_RECURSIVE';
      l_run_stat_id     NUMBER;
      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_id              NUMBER;
      k                 NUMBER;
      l_count_tasks     NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      fnd_oam_debug.log(1, l_ctxt, 'Bundle ID: '||p_bundle_id);

      --first validate the bundle
      IF NOT VALIDATE_BUNDLE_SUCCESS(p_run_id,
                                     p_bundle_id,
                                     p_bundle_status) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      IF p_num_tasks >= 0 THEN
         --now query the tasks and validate those
         SELECT task_id
            BULK COLLECT INTO l_ids
            FROM fnd_oam_dscram_tasks
            WHERE bundle_id = p_bundle_id;

         l_count_tasks := 0;
         k := l_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            IF NOT VALIDATE_TASK_RECURSIVE(p_run_id,
                                           l_run_stat_id,
                                           l_ids(k),
                                           p_num_workers,
                                           p_num_units,
                                           p_num_dmls,
                                           p_num_dml_rows,
                                           p_num_plsqls,
                                           p_task_status,
                                           p_unit_status,
                                           p_dml_status,
                                           p_plsql_status) THEN
               RAISE VALIDATE_FAILED;
            END IF;

            k := l_ids.NEXT(k);
            l_count_tasks := l_count_tasks + 1;
         END LOOP;
         IF p_num_tasks >= 0 AND (l_count_tasks IS NULL OR l_count_tasks <> p_num_tasks) THEN
            fnd_oam_debug.log(6, l_ctxt, 'Bundle ID('||p_bundle_id||'), Number of tasks found ('||l_count_tasks||') did not match the number expected ('||p_num_tasks||')');
            RAISE VALIDATE_FAILED;
         END IF;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Helper function to validate a single run, bundle, task.
   -- Covers the simple test cases.
   FUNCTION VALIDATE_RUN_RECURSIVE(p_run_id             IN NUMBER,
                                   p_num_workers        IN NUMBER   DEFAULT 1,
                                   p_num_bundles        IN NUMBER   DEFAULT -1,
                                   p_num_tasks          IN NUMBER   DEFAULT -1,
                                   p_num_units          IN NUMBER   DEFAULT -1,
                                   p_num_dmls           IN NUMBER   DEFAULT -1,
                                   p_num_dml_rows       IN NUMBER   DEFAULT -1,
                                   p_num_plsqls         IN NUMBER   DEFAULT -1,
                                   p_run_status         IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
                                   p_bundle_status      IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                   p_task_status        IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                   p_unit_status        IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                   p_dml_status         IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS,
                                   p_plsql_status       IN VARCHAR2 DEFAULT FND_API.G_RET_STS_SUCCESS)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_RUN_RECURSIVE';
      l_run_stat_id     NUMBER;
      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_id              NUMBER;
      k                 NUMBER;
      l_count_bundles           NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      fnd_oam_debug.log(1, l_ctxt, 'Run ID: '||p_run_id);

      --before doing any work, rollback the current transaction in case some state didn't get comitted.
      ROLLBACK;

      --first validate the run
      IF NOT VALIDATE_RUN_SUCCESS(p_run_id,
                                  p_run_status,
                                  x_run_stat_id => l_run_stat_id) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      IF p_num_bundles >= 0 THEN
         --now query the bundles and validate those
         SELECT bundle_id
            BULK COLLECT INTO l_ids
            FROM fnd_oam_dscram_bundles
            WHERE run_id = p_run_id;

         l_count_bundles := 0;
         k := l_ids.FIRST;
         WHILE k IS NOT NULL LOOP
            IF NOT VALIDATE_BUNDLE_RECURSIVE(p_run_id,
                                             l_run_stat_id,
                                             l_ids(k),
                                             p_num_workers,
                                             p_num_tasks,
                                             p_num_units,
                                             p_num_dmls,
                                             p_num_dml_rows,
                                             p_num_plsqls,
                                             p_bundle_status,
                                             p_task_status,
                                             p_unit_status,
                                             p_dml_status,
                                             p_plsql_status) THEN
               RAISE VALIDATE_FAILED;
            END IF;

            k := l_ids.NEXT(k);
            l_count_bundles := l_count_bundles + 1;
         END LOOP;
         IF p_num_bundles >= 0 AND (l_count_bundles IS NULL OR l_count_bundles <> p_num_bundles) THEN
            fnd_oam_debug.log(6, l_ctxt, 'Run ID('||p_run_id||'), Number of bundles found ('||l_count_bundles||') did not match the number expected ('||p_num_bundles||')');
            RAISE VALIDATE_FAILED;
         END IF;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- create an argument entry, typically attached to a run or dml
   FUNCTION MAKE_ARG(p_arg_name          IN VARCHAR2,
                     p_parent_type       IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RUN,
                     p_parent_id         IN NUMBER   DEFAULT NULL,
                     p_init_success_flag IN VARCHAR2 DEFAULT NULL,
                     p_allow_override_source     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                     p_binding_enabled_flag      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                     p_permissions       IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ,
                     p_write_policy      IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                     p_datatype          IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                     p_valid_value_flag  IN VARCHAR2 DEFAULT NULL,
                     p_canon_value       IN VARCHAR2 DEFAULT NULL,
                     p_src_type          IN VARCHAR2 DEFAULT NULL,
                     p_src_text          IN VARCHAR2 DEFAULT NULL,
                     p_src_where_clause  IN VARCHAR2 DEFAULT NULL,
                     x_arg_id            OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_ARG';
      l_retval  NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INSERT INTO FND_OAM_DSCRAM_ARGS_B (ARG_ID,
                                         ARG_NAME,
                                         PARENT_TYPE,
                                         PARENT_ID,
                                         ENABLED_FLAG,
                                         INITIALIZED_SUCCESS_FLAG,
                                         ALLOW_OVERRIDE_SOURCE_FLAG,
                                         BINDING_ENABLED_FLAG,
                                         PERMISSIONS,
                                         WRITE_POLICY,
                                         DATATYPE,
                                         VALID_VALUE_FLAG,
                                         CANONICAL_VALUE,
                                         SOURCE_TYPE,
                                         SOURCE_TEXT,
                                         SOURCE_WHERE_CLAUSE,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN)
         VALUES
            (fnd_oam_dscram_args_s.nextval,
             p_arg_name,
             p_parent_type,
             p_parent_id,
             FND_API.G_TRUE,
             p_init_success_flag,
             p_allow_override_source,
             p_binding_enabled_flag,
             p_permissions,
             p_write_policy,
             p_datatype,
             p_valid_value_flag,
             p_canon_value,
             p_src_type,
             p_src_text,
             p_src_where_clause,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING ARG_ID INTO l_retval;

      INSERT INTO FND_OAM_DSCRAM_ARGS_TL (ARG_ID,
                                          DISPLAY_NAME,
                                          DESCRIPTION,
                                          LANGUAGE,
                                          SOURCE_LANG,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN
                                          )
         VALUES
            (l_retval,
             'ARG'||l_retval,
             'DESC'||l_retval,
             FND_GLOBAL.CURRENT_LANGUAGE,
             FND_GLOBAL.CURRENT_LANGUAGE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_arg_id := l_retval;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_arg_id := NULL;
         RETURN FALSE;
   END;

   -- create a dml entry for a given unit
   FUNCTION MAKE_DML(p_unit_id                  IN NUMBER,
                     p_priority                 IN NUMBER DEFAULT NULL,
                     p_weight                   IN NUMBER DEFAULT NULL,
                     p_dml_stmt                 IN VARCHAR2,
                     p_where_clause             IN VARCHAR2 DEFAULT NULL,
                     x_dml_id                   OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_DML';
      l_retval  NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INSERT INTO FND_OAM_DSCRAM_DMLS (DML_ID,
                                       UNIT_ID,
                                       PRIORITY,
                                       WEIGHT,
                                       DML_STMT,
                                       DML_WHERE_CLAUSE,
                                       CREATED_BY,
                                       CREATION_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATE_LOGIN
                                       )
         VALUES
            (fnd_oam_dscram_dmls_s.nextval,
             p_unit_id,
             p_priority,
             p_weight,
             p_dml_stmt,
             p_where_clause,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING DML_ID INTO l_retval;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_dml_id := l_retval;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_dml_id := NULL;
         RETURN FALSE;
   END;

   -- create a plsql entry for a given unit
   FUNCTION MAKE_PLSQL(p_unit_id                IN NUMBER,
                       p_priority               IN NUMBER DEFAULT NULL,
                       p_weight                 IN NUMBER DEFAULT NULL,
                       p_plsql_text             IN VARCHAR2,
                       x_plsql_id               OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_PLSQL';
      l_retval  NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INSERT INTO FND_OAM_DSCRAM_PLSQLS (PLSQL_ID,
                                         UNIT_ID,
                                         PRIORITY,
                                         WEIGHT,
                                         PLSQL_TEXT,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN
                                       )
         VALUES
            (fnd_oam_dscram_plsqls_s.nextval,
             p_unit_id,
             p_priority,
             p_weight,
             p_plsql_text,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING PLSQL_ID INTO l_retval;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_plsql_id := l_retval;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_plsql_id := NULL;
         RETURN FALSE;
   END;

   -- create a task entry for a given bundle
   FUNCTION MAKE_UNIT(p_task_id                 IN NUMBER,
                      p_conc_unit_id            IN NUMBER DEFAULT NULL,
                      p_unit_type               IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET,
                      p_status                  IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
                      p_phase                   IN NUMBER DEFAULT NULL,
                      p_priority                IN NUMBER DEFAULT NULL,
                      p_weight                  IN NUMBER DEFAULT NULL,
                      p_sug_workers_allowed     IN NUMBER DEFAULT NULL,
                      p_act_workers_allowed     IN NUMBER DEFAULT NULL,
                      p_unit_obj_owner          IN VARCHAR2 DEFAULT NULL,
                      p_unit_obj_name           IN VARCHAR2 DEFAULT NULL,
                      p_batch_size              IN NUMBER DEFAULT NULL,
                      p_fatality_level          IN VARCHAR2 DEFAULT NULL,
                      p_sug_disable_splitting   IN VARCHAR2 DEFAULT NULL,
                      p_act_disable_splitting   IN VARCHAR2 DEFAULT NULL,
                      x_unit_id         OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_UNIT';
      l_retval  NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INSERT INTO FND_OAM_DSCRAM_UNITS (UNIT_ID,
                                        TASK_ID,
                                        CONCURRENT_GROUP_UNIT_ID,
                                        UNIT_TYPE,
                                        UNIT_STATUS,
                                        PHASE,
                                        PRIORITY,
                                        WEIGHT,
                                        SUGGEST_WORKERS_ALLOWED,
                                        ACTUAL_WORKERS_ALLOWED,
                                        WORKERS_ASSIGNED,
                                        UNIT_OBJECT_OWNER,
                                        UNIT_OBJECT_NAME,
                                        BATCH_SIZE,
                                        ERROR_FATALITY_LEVEL,
                                        SUGGEST_DISABLE_SPLITTING,
                                        ACTUAL_DISABLE_SPLITTING,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATE_LOGIN
                                        )
         VALUES
            (fnd_oam_dscram_units_s.nextval,
             p_task_id,
             p_conc_unit_id,
             p_unit_type,
             p_status,
             p_phase,
             p_priority,
             p_weight,
             p_sug_workers_allowed,
             p_act_workers_allowed,
             0,
             p_unit_obj_owner,
             p_unit_obj_name,
             p_batch_size,
             p_fatality_level,
             p_sug_disable_splitting,
             p_act_disable_splitting,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING UNIT_ID INTO l_retval;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_unit_id := l_retval;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_unit_id := NULL;
         RETURN FALSE;
   END;

   -- create a task entry for a given bundle
   FUNCTION MAKE_TASK(p_bundle_id       IN NUMBER,
                      p_status          IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
                      p_priority        IN NUMBER DEFAULT NULL,
                      p_weight          IN NUMBER DEFAULT NULL,
                      p_dom_owner       IN VARCHAR2 DEFAULT NULL,
                      p_dom_name        IN VARCHAR2 DEFAULT NULL,
                      x_task_id         OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'MAKE_TASK';
      l_retval  NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INSERT INTO FND_OAM_DSCRAM_TASKS (TASK_ID,
                                        BUNDLE_ID,
                                        TASK_STATUS,
                                        PRIORITY,
                                        WEIGHT,
                                        WORKERS_ASSIGNED,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATE_LOGIN
                                        )
         VALUES
            (fnd_oam_dscram_tasks_s.nextval,
             p_bundle_id,
             p_status,
             p_priority,
             p_weight,
             0,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING TASK_ID INTO l_retval;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_task_id := l_retval;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_task_id := NULL;
         RETURN FALSE;
   END;

   -- create a bundle entry for a given run
   FUNCTION MAKE_BUNDLE(p_run_id          IN NUMBER,
                        p_bundle_id       IN NUMBER,
                        p_status          IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
                        p_weight          IN NUMBER DEFAULT NULL,
                        p_workers_allowed IN NUMBER DEFAULT 1,
                        p_batch_size      IN NUMBER DEFAULT 1000,
                        p_min_par_weight  IN NUMBER DEFAULT NULL)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'MAKE_BUNDLE';
      l_batch_size      NUMBER := p_batch_size;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --if batch size was given as null, default it
      IF p_batch_size IS NULL THEN
         l_batch_size := 1000;
      END IF;

      INSERT INTO FND_OAM_DSCRAM_BUNDLES (BUNDLE_ID,
                                          RUN_ID,
                                          BUNDLE_STATUS,
                                          WEIGHT,
                                          WORKERS_ALLOWED,
                                          WORKERS_ASSIGNED,
                                          BATCH_SIZE,
                                          MIN_PARALLEL_UNIT_WEIGHT,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN
                                          )
         VALUES
            (p_bundle_id,
             p_run_id,
             p_status,
             p_weight,
             p_workers_allowed,
             0,
             l_batch_size,
             p_min_par_weight,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --creates a RUN
   FUNCTION MAKE_RUN(p_run_id           IN NUMBER,
                     p_mode             IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_MODE_DIAGNOSTIC,
                     p_status           IN VARCHAR2 DEFAULT FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
                     p_weight           IN NUMBER DEFAULT NULL,
                     p_check_interval   IN NUMBER DEFAULT 300,
                     p_name             IN VARCHAR2 DEFAULT NULL,
                     p_desc             IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'MAKE_RUN';
      l_dbname          VARCHAR2(30);
      l_run_stat_id     NUMBER;
      l_run_name        VARCHAR2(30) := p_name;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --default the run name if not provided
      IF p_name IS NULL THEN
         l_run_name := 'Diagnostic Test '||to_char(SYSDATE, 'MI_SS');
      END IF;

      --query the current db
      SELECT name
         INTO l_dbname
         FROM v$database
         WHERE rownum < 2;

      INSERT INTO FND_OAM_DSCRAM_RUNS_B (RUN_ID,
                                         RUN_STATUS,
                                         RUN_MODE,
                                         TARGET_DBNAME,
                                         WEIGHT,
                                         VALID_CHECK_INTERVAL,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN
                                         )
         VALUES
            (p_run_id,
             p_status,
             p_mode,
             l_dbname,
             p_weight,
             p_check_interval,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID);

      INSERT INTO FND_OAM_DSCRAM_RUNS_TL (RUN_ID,
                                          DISPLAY_NAME,
                                          DESCRIPTION,
                                          LANGUAGE,
                                          SOURCE_LANG,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN
                                          )
         VALUES
            (p_run_id,
             l_run_name,
             p_desc,
             FND_GLOBAL.CURRENT_LANGUAGE,
             FND_GLOBAL.CURRENT_LANGUAGE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID);

      --also create the run stats entry
      FND_OAM_DSCRAM_STATS_PKG.CREATE_ENTRY_FOR_RUN(p_run_id            => p_run_id,
                                                    p_start_time        => SYSDATE,
                                                    p_prestart_status   => 'UNPROCESSED',
                                                    x_run_stat_id       => l_run_stat_id,
                                                    x_return_status     => l_return_status,
                                                    x_return_msg        => l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Failed to create run stat entry: '||l_return_msg);
         RETURN FALSE;
      END IF;

      --update the run with this run stat id
      UPDATE fnd_oam_dscram_runs_b
         SET last_run_stat_id = l_run_stat_id
         WHERE run_id = p_run_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- Helper init function to make a single run, bundle, task.
   -- Covers the simple test cases.
   FUNCTION INIT_SINGLE_TASK(p_run_id           IN NUMBER,
                             p_bundle_id        IN NUMBER,
                             p_testnum          IN VARCHAR2,
                             p_num_workers      IN NUMBER DEFAULT 1,
                             p_batch_size       IN NUMBER DEFAULT NULL,
                             x_task_id          OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INIT_SINGLE_TASK';
      l_task_id         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --do the meat of creating a run, bundle, and task
      IF NOT MAKE_RUN(p_run_id,
                      p_name => B_DIAG_RUN_NAME_PREFIX||p_testnum) THEN
         RAISE INIT_FAILED;
      END IF;

      IF NOT MAKE_BUNDLE(p_run_id,
                         p_bundle_id,
                         p_workers_allowed      => p_num_workers,
                         p_batch_size           => p_batch_size) THEN
         RAISE INIT_FAILED;
      END IF;

      IF NOT MAKE_TASK(p_bundle_id,
                       x_task_id => l_task_id) THEN
         RAISE INIT_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_task_id := l_task_id;
      RETURN TRUE;
   EXCEPTION
      WHEN INIT_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_task_id := NULL;
         RETURN TRUE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_task_id := NULL;
         RETURN FALSE;
   END;

   -- Helper init function to make a single run, bundle, task.
   -- Covers the simple test cases.
   FUNCTION INIT_SINGLE_DML_UNIT(p_run_id               IN NUMBER,
                                 p_bundle_id            IN NUMBER,
                                 p_testnum              IN VARCHAR2,
                                 p_num_workers          IN NUMBER DEFAULT 1,
                                 p_batch_size           IN NUMBER DEFAULT 1000,
                                 x_task_id              OUT NOCOPY NUMBER,
                                 x_unit_id              OUT NOCOPY NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INIT_SINGLE_DML_UNIT';
      l_task_id         NUMBER;
      l_unit_id         NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --make the run,bundle,task
      IF NOT INIT_SINGLE_TASK(p_run_id,
                              p_bundle_id,
                              p_testnum,
                              p_num_workers,
                              p_batch_size,
                              l_task_id) THEN
         RAISE INIT_FAILED;
      END IF;

      --make the unit
      IF NOT MAKE_UNIT(l_task_id,
                       x_unit_id => l_unit_id) THEN
         RAISE INIT_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_task_id := l_task_id;
      x_unit_id := l_unit_id;
      RETURN TRUE;
   EXCEPTION
      WHEN INIT_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_task_id := NULL;
         x_unit_id := NULL;
         RETURN TRUE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_task_id := NULL;
         x_unit_id := NULL;
         RETURN FALSE;
   END;

   --helper to the EXECUTE_TEST# functions to detect when a run is finished, replaced by the SYNC_ON_FINISH
   --which uses DBMS_PIPE based IPC to detect when the run is finished.  This function is kept in case
   --we need a more manual check.
   FUNCTION RUN_IS_FINISHED(p_run_id    IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'RUN_IS_FINISHED';
      l_temp            NUMBER;
   BEGIN
      --Can't use the status of the run so see if any bundles exist in a non-finished status or have
      --workers
      SELECT 1
         INTO l_temp
         FROM DUAL
         WHERE EXISTS (SELECT 1
                       FROM fnd_oam_dscram_bundles
                       WHERE run_id = p_run_id
                       AND (workers_assigned > 0 OR bundle_status NOT IN (FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED,
                                                                          FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_STOPPED,
                                                                          FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_SKIPPED,
                                                                          FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_FATAL,
                                                                          FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN)));
      RETURN FALSE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN TRUE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --called by EXECUTE_TEST to sync the workers at the end of each run so that
   --things like cleanup can be called.
   --throws SYNC_FAILED if the timeout is hit
   FUNCTION SYNC_ON_FINISH(p_run_id             IN NUMBER,
                           p_test_success       IN BOOLEAN DEFAULT FALSE,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           p_did_init           IN BOOLEAN DEFAULT FALSE)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'SYNC_ON_FINISH';
      l_retval          NUMBER;
      l_msg             VARCHAR2(30);
      l_pipename        VARCHAR2(30) := MAKE_RUN_PIPE_NAME(p_run_id);
      l_ack_pipename    VARCHAR2(30);
      l_msg_count       NUMBER;
      l_target_msg_count NUMBER;
      l_retbool         BOOLEAN;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      l_retbool := TRUE;
      --different behavior depending on whether we're the initializing worker or not
      IF p_did_init THEN
         --we need to recieve done messages from the other n-1 messages
         l_msg_count := 0;
         l_target_msg_count := p_num_workers - 1;
         WHILE l_msg_count < l_target_msg_count LOOP
            l_retval := DBMS_PIPE.RECEIVE_MESSAGE(l_pipename,
                                                  B_MAX_WAIT);
            IF l_retval <> 0 THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to receive message: '||l_retval);
               RAISE SYNC_FAILED;
            END IF;

            --get the message, update the overall status if a worker failed
            DBMS_PIPE.UNPACK_MESSAGE(l_msg);
            IF l_msg <> FND_API.G_TRUE THEN
               l_retbool := FALSE;
            END IF;

            --increment the message received count
            l_msg_count := l_msg_count + 1;
         END LOOP;

         --all other workers have finished, return our status
         l_retbool := l_retbool AND p_test_success;
      ELSE
         --if we didn't do the init, send our status on the pipe
         IF p_test_success THEN
            DBMS_PIPE.PACK_MESSAGE(FND_API.G_TRUE);
         ELSE
            DBMS_PIPE.PACK_MESSAGE(FND_API.G_FALSE);
         END IF;
         l_retval := DBMS_PIPE.SEND_MESSAGE(l_pipename,
                                            B_MAX_WAIT);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to send message: '||l_retval);
            RAISE SYNC_FAILED;
         END IF;

         --now block waiting for an ack with the final status of the test
         l_ack_pipename := MAKE_RUN_ACK_PIPE_NAME(p_run_id);
         l_retval := DBMS_PIPE.RECEIVE_MESSAGE(l_ack_pipename,
                                               B_MAX_WAIT);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to receive ACK: '||l_retval);
            RAISE SYNC_FAILED;
         END IF;
         DBMS_PIPE.UNPACK_MESSAGE(l_msg);
         l_retbool := (l_msg = FND_API.G_TRUE);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_retbool;
   EXCEPTION
      WHEN SYNC_FAILED THEN
         RAISE SYNC_FAILED;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --used by the initializing worker to send acks to the other workers with the final status
   PROCEDURE SEND_ACKS(p_run_id                 IN NUMBER,
                       p_final_test_success     IN BOOLEAN,
                       p_num_workers            IN NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'SEND_ACKS';
      l_retval          NUMBER;
      l_msg             VARCHAR2(30);
      l_ack_pipename    VARCHAR2(30) := MAKE_RUN_ACK_PIPE_NAME(p_run_id);
      k                 NUMBER := 0;
      l_num_msgs        NUMBER := p_num_workers - 1;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --prep the ack message
      IF p_final_test_success THEN
         l_msg := FND_API.G_TRUE;
      ELSE
         l_msg := FND_API.G_FALSE;
      END IF;

      --send the messages
      WHILE k < l_num_msgs LOOP
         DBMS_PIPE.PACK_MESSAGE(l_msg);
         l_retval := DBMS_PIPE.SEND_MESSAGE(l_ack_pipename,
                                            B_MAX_WAIT);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to send ack message: '||l_retval);
            RAISE SYNC_FAILED;
         END IF;
         k := k + 1;
      END LOOP;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN SYNC_FAILED THEN
         RAISE SYNC_FAILED;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   --Helper to EXECUTE_TEST# functions to see if the run's been initialized yet, if it hasn't then it
   --keeps the lock and returns to EXECUTE_ to do the init and release the lock.
   FUNCTION RUN_NEEDS_INIT(p_run_id             IN NUMBER,
                           x_lock_handle        OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'RUN_NEEDS_INIT';
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_lock_handle := NULL;

      --lock the run
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.LOCK_RUN(p_run_id,
                                               l_lock_handle) THEN
         fnd_oam_debug.log(1, l_ctxt, 'Failed to lock run.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      --after getting the lock, see if the run's there
      BEGIN
         SELECT 1
            INTO l_retval
            FROM fnd_oam_dscram_runs_b
            WHERE run_id = p_run_id;

         --select suceeded, release and return
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_lock_handle := l_lock_handle;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN TRUE;
      END;

      --shouldn't get here
      fnd_oam_debug.log(1, l_ctxt, 'Bad spot?');
      l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
      IF l_retval <> 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
      END IF;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN FALSE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --try to release the lock
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --helper to the EXECUTE_TEST# functions
   FUNCTION EXECUTE_BUNDLE_WRAPPER(p_ctxt               IN VARCHAR2,
                                   p_run_id             IN NUMBER,
                                   p_bundle_id          IN NUMBER,
                                   px_worker_id         IN OUT NOCOPY NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_return_msg         OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_start   NUMBER;
      l_end     NUMBER;
   BEGIN
      l_start := DBMS_UTILITY.GET_TIME;
      FND_OAM_DSCRAM_BUNDLES_PKG.EXECUTE_BUNDLE(p_run_id                => p_run_id,
                                                p_bundle_id             => p_bundle_id,
                                                px_worker_id            => px_worker_id,
                                                x_return_status         => x_return_status,
                                                x_return_msg            => x_return_msg);
      l_end := DBMS_UTILITY.GET_TIME;
      fnd_oam_debug.log(1, p_ctxt, 'Execute Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
      fnd_oam_debug.log(1, p_ctxt, 'Return Status: '||x_return_status);
      fnd_oam_debug.log(1, p_ctxt, 'Return Msg: "'||x_return_msg||'"');

      --figure out if we should return a success or failure
      --allowable outputs, SUCCESS/PROCESSED
      RETURN x_return_status IN (FND_API.G_RET_STS_SUCCESS,
                                 FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED);
   END;

   --helper to EXECUTE_TEST* to print some state on entry
   PROCEDURE PRINT_TEST_ENTRY_STATE(p_ctxt              IN VARCHAR2,
                                    p_run_id            IN NUMBER,
                                    p_bundle_id         IN NUMBER,
                                    p_num_bundles       IN NUMBER,
                                    p_num_workers       IN NUMBER)
   IS
   BEGIN
      fnd_oam_debug.log(1, p_ctxt, 'Run ID: '||p_run_id);
      fnd_oam_debug.log(1, p_ctxt, 'Bundle ID: '||p_bundle_id);
      fnd_oam_debug.log(1, p_ctxt, 'Bundles: '||p_num_bundles);
      fnd_oam_debug.log(1, p_ctxt, 'Workers: '||p_num_workers);
   END;

   --Public
   PROCEDURE EXECUTE_TEST1(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST1';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;

      l_worker_id       NUMBER;
      l_task_id         NUMBER;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      -- make sure the run is initialized
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         IF NOT INIT_SINGLE_TASK(p_run_id,
                                 p_bundle_id,
                                 l_testnum,
                                 p_num_workers,
                                 x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --sync the finish
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_RUN_RECURSIVE(p_run_id,
                                   p_num_workers,
                                   p_num_bundles => 1,
                                   p_num_tasks => 1,
                                   p_num_units => 0);
         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         --send a msg with our status and wait for a msg with the final status
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   --Public
   PROCEDURE EXECUTE_TEST2(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST2';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_worker_id       NUMBER;
      l_task_id         NUMBER;
      l_unit_id         NUMBER;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a single run/bundle/task
         IF NOT INIT_SINGLE_DML_UNIT(p_run_id,
                                     p_bundle_id,
                                     l_testnum,
                                     p_num_workers,
                                     x_task_id => l_task_id,
                                     x_unit_id => l_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --sync the finish
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_RUN_RECURSIVE(p_run_id,
                                   p_num_workers,
                                   p_num_bundles => 1,
                                   p_num_tasks => 1,
                                   p_num_units => 1);
         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         --send a msg with our status and wait for a msg with the final status
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   --Helper to execute_test3 to remove any state that will negatively impact future tests
   FUNCTION CLEANUP_TEST3(p_run_id              IN NUMBER,
                          p_bundle_id           IN NUMBER,
                          p_global_arg_names    IN DBMS_SQL.VARCHAR2_TABLE)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CLEANUP_TEST3';
      l_retbool         BOOLEAN;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      fnd_oam_debug.log(1, l_ctxt, 'Run ID: '||p_run_id);
      fnd_oam_debug.log(1, l_ctxt, 'Bundle ID: '||p_bundle_id);

      l_retbool := DELETE_GLOBAL_ARGS(p_global_arg_names);

      COMMIT;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_retbool;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   --Public
   PROCEDURE EXECUTE_TEST3(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST3';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_unit_id                 NUMBER;
      l_arg_name                VARCHAR2(60);
      l_global_arg_names        DBMS_SQL.VARCHAR2_TABLE;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a single run/bundle/task
         IF NOT INIT_SINGLE_TASK(p_run_id,
                                 p_bundle_id,
                                 l_testnum,
                                 p_num_workers,
                                 x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a global arg
         l_arg_name := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_GLOBAL_ARG1';
         IF NOT MAKE_ARG(p_arg_name             => l_arg_name,
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_GLOBAL,
                         p_init_success_flag    => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_valid_value_flag     => FND_API.G_TRUE,
                         p_canon_value          => 'Value1',
                         x_arg_id               => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;
         l_global_arg_names(1) := l_arg_name;

         --create a run arg
         IF NOT MAKE_ARG(p_arg_name             => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_ARG1',
                         p_parent_id            => p_run_id,
                         p_init_success_flag    => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_valid_value_flag     => FND_API.G_TRUE,
                         p_canon_value          => '123.45',
                         x_arg_id               => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing a constant
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG1',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_CONSTANT,
                         p_src_text     => '3.141592653',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing a constant
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG1.5',
                         p_parent_id    => p_run_id,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_CONSTANT,
                         p_src_text     => '2005/08/30 11:26:45',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the date as a date
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG2',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT SYSDATE FROM DUAL',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the timestamp as a string, no write so each call gets a different value
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG3',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT to_char(SYSTIMESTAMP, ''HH24:MI:SS.FF'') FROM DUAL',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the timestamp as a string, writeable so each worker should get the same value
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG4',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT to_char(SYSTIMESTAMP, ''HH24:MI:SS.FF'') FROM DUAL',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the timestamp but writing one per worker
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG5',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT to_char(SYSTIMESTAMP, ''HH24:MI:SS.FF'') FROM DUAL',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the timestamp and writing always
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG6',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ALWAYS,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT to_char(SYSTIMESTAMP, ''HH24:MI:SS.FF'') FROM DUAL',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the timestamp and writing per range
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG7',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT to_char(SYSTIMESTAMP, ''HH24:MI:SS.FF'') FROM DUAL',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the rowid from dual, no write
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG8',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT ROWID FROM DUAL',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the runid from state
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG9',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text     => 'RUN_ID',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a dynamic run arg, sourcing the runid from state
         IF NOT MAKE_ARG(p_arg_name     => FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_RUN_DYNARG10',
                         p_parent_id    => p_run_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text     => 'WORKER_ID',
                         x_arg_id       => l_retval) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_RUN_RECURSIVE(p_run_id,
                                   p_num_workers,
                                   p_num_bundles => 1,
                                   p_num_tasks => 1,
                                   p_num_units => 0);

         --cleanup the test's side effects
         l_retbool_final := CLEANUP_TEST3(p_run_id,
                                     p_bundle_id,
                                     l_global_arg_names) AND l_retbool_final;

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         l_retbool := CLEANUP_TEST3(p_run_id,
                                    p_bundle_id,
                                    l_global_arg_names);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         l_retbool := CLEANUP_TEST3(p_run_id,
                                    p_bundle_id,
                                    l_global_arg_names);
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         l_retbool := CLEANUP_TEST3(p_run_id,
                                    p_bundle_id,
                                    l_global_arg_names);
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   --helper to EXECUTE_TEST4 to validate the test succeeded
   FUNCTION VALIDATE_TEST4(p_run_id             IN NUMBER,
                           p_bundle_id          IN NUMBER,
                           p_num_workers        IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_TEST4';

      l_run_stat_id     NUMBER;
      l_task_id         NUMBER;
      l_unit_id         NUMBER;

      l_retbool         BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      k                 NUMBER;
      j                 NUMBER;
      l_count           NUMBER;
      l_ids             DBMS_SQL.NUMBER_TABLE;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first validate the run
      IF NOT VALIDATE_RUN_SUCCESS(p_run_id,
                                  x_run_stat_id => l_run_stat_id) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --now the bundle
      IF NOT VALIDATE_BUNDLE_SUCCESS(p_run_id,
                                     p_bundle_id) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --now query out the task ids to validate each
      SELECT task_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_tasks
         WHERE bundle_id = p_bundle_id
         ORDER BY task_id ASC;

      l_count := 0;
      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         IF NOT VALIDATE_TASK_RECURSIVE(p_run_id,
                                        p_task_id => l_ids(k),
                                        p_num_workers => p_num_workers,
                                        p_num_units => l_count) THEN
            RAISE VALIDATE_FAILED;
         END IF;

         k := l_ids.NEXT(k);
         l_count := l_count + 1;
      END LOOP;
      IF l_count IS NULL OR l_count <> 5 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Number of tasks found ('||l_count||') did not match the number expected (5)');
         RAISE VALIDATE_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   --Public
   PROCEDURE EXECUTE_TEST4(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST4';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_unit_id                 NUMBER;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a single run/bundle
         IF NOT MAKE_RUN(p_run_id,
                         p_name => B_DIAG_RUN_NAME_PREFIX||l_testnum) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_BUNDLE(p_run_id,
                            p_bundle_id,
                            p_workers_allowed => p_num_workers) THEN
            RAISE INIT_FAILED;
         END IF;

         --create 5 tasks, each with a number of tasks equivalent to the value of the iterator
         k := 0;
         WHILE k < 5 LOOP
            --create task
            IF NOT MAKE_TASK(p_bundle_id,
                             x_task_id => l_task_id) THEN
               RAISE INIT_FAILED;
            END IF;

            --create k units
            j := 0;
            WHILE j < k LOOP
               --make unit
               IF NOT MAKE_UNIT(l_task_id,
                                p_sug_workers_allowed => (MOD(j, 2) + 1),
                                x_unit_id => l_unit_id) THEN
                  RAISE INIT_FAILED;
               END IF;
               j := j + 1;
            END LOOP;

            k := k + 1;
         END LOOP;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_TEST4(p_run_id,
                           p_bundle_id,
                           p_num_workers);

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   --helper to EXECUTE_TEST5 to validate the test succeeded
   FUNCTION VALIDATE_TEST5(p_run_id             IN NUMBER,
                           p_bundle_id          IN NUMBER,
                           p_num_workers        IN NUMBER,
                           p_dml_id             IN NUMBER,
                           p_test_tab_name      IN VARCHAR2,
                           p_test_tab_num_rows  IN NUMBER,
                           p_c2_arg_id          IN NUMBER)
      RETURN BOOLEAN
   IS
      l_testnum         VARCHAR2(20) := 'TEST5';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_'||l_testnum;

      l_c2_target_sum   NUMBER := p_test_tab_num_rows*2;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first validate the run/bundle/task/unit
      IF NOT VALIDATE_RUN_RECURSIVE(p_run_id,
                                    p_num_workers,
                                    p_num_bundles => 1,
                                    p_num_tasks => 1,
                                    p_num_units => 1,
                                    p_num_dmls => 1,
                                    p_num_dml_rows => p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check that the test table has the correct number of rows
      IF NOT VALIDATE_TEST_TABLE_UNCHANGED(p_test_tab_name,
                                           p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check that the c2 sum stored in the arg is correct
      IF NOT VALIDATE_TEST_TABLE_ARG_VALUES(FALSE,
                                            p_c2_arg_id,
                                            l_c2_target_sum,
                                            p_test_tab_name,
                                            p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   --Public
   PROCEDURE EXECUTE_TEST5(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST5';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_test_table_name         VARCHAR2(30) := B_TEST_TABLE_NAME_PREFIX||'5_TAB1';
      l_test_table_num_rows     NUMBER := 500;
      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_unit_id                 NUMBER;
      l_dml_id                  NUMBER;
      l_arg_name                VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_SUM';
      l_arg_id                  NUMBER;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a test table to work on
         IF NOT MAKE_TEST_TABLE(l_test_table_name,
                                l_test_table_num_rows) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a single run/bundle
         IF NOT MAKE_RUN(p_run_id,
                         p_weight => 100,
                         p_name => B_DIAG_RUN_NAME_PREFIX||l_testnum) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the task execute serially by one worker
         IF NOT MAKE_BUNDLE(p_run_id,
                            p_bundle_id,
                            p_weight => 100,
                            p_min_par_weight => 5000,
                            p_workers_allowed => p_num_workers) THEN
            RAISE INIT_FAILED;
         END IF;
         --create task
         IF NOT MAKE_TASK(p_bundle_id,
                          p_weight => 100,
                          x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make unit
         IF NOT MAKE_UNIT(l_task_id,
                          p_weight => 100,
                          x_unit_id => l_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make a simple dml
         IF NOT MAKE_DML(l_unit_id,
                         p_weight => 100,
                         p_dml_stmt => 'UPDATE '||l_test_table_name||' SET C2 = C2 + 1',
                         p_where_clause => NULL,
                         x_dml_id => l_dml_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an output arg for the dml to fetch C2's new sum
         IF NOT MAKE_ARG(p_arg_name     => l_arg_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id       => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_TEST5(p_run_id,
                           p_bundle_id,
                           p_num_workers,
                           l_dml_id,
                           l_test_table_name,
                           l_test_table_num_rows,
                           l_arg_id);

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   -- Public
   FUNCTION VALIDATE_TEST6(p_run_id             IN NUMBER,
                           p_bundle_id          IN NUMBER,
                           p_num_workers        IN NUMBER,
                           p_test_tab_name      IN VARCHAR2,
                           p_test_tab_num_rows  IN NUMBER,
                           p_c2_arg_id          IN NUMBER,
                           p_c2_final_arg_id    IN NUMBER,
                           p_c2_run_arg_id      IN NUMBER)
      RETURN BOOLEAN
   IS
      l_testnum         VARCHAR2(20) := 'TEST6';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_'||l_testnum;

      l_c2_target_sum   NUMBER := p_test_tab_num_rows*2;
      l_c2_final_sum    NUMBER;
      l_c2_run_sum      NUMBER;
      l_valid_value_flag        VARCHAR2(3);
      l_canonical_value VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first validate the run/bundle/task/unit
      IF NOT VALIDATE_RUN_RECURSIVE(p_run_id,
                                    p_num_workers,
                                    p_num_bundles => 1,
                                    p_num_tasks => 1,
                                    p_num_units => 1,
                                    p_num_dmls => 1,
                                    p_num_dml_rows => p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check that the test table has the correct number of rows
      IF NOT VALIDATE_TEST_TABLE_UNCHANGED(p_test_tab_name,
                                           p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check that the c2 sum stored in the arg is correct
      IF NOT VALIDATE_TEST_TABLE_ARG_VALUES(TRUE,
                                            p_c2_arg_id,
                                            l_c2_target_sum,
                                            p_test_tab_name,
                                            p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --make sure that the final c2 sum was run on the unchanged test table only and sums to the # of rows
      --check the row count
      BEGIN
         SELECT valid_value_flag, canonical_value
            INTO l_valid_value_flag, l_canonical_value
            FROM fnd_oam_dscram_args_b
            WHERE arg_id = p_c2_final_arg_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to query arg value for final C2 sum: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
            RAISE VALIDATE_FAILED;
      END;
      IF l_valid_value_flag IS NULL OR l_valid_value_flag <> FND_API.G_TRUE THEN
         fnd_oam_debug.log(6, l_ctxt, 'Valid value flag of final C2 Sum for dml is incorrect: '||l_valid_value_flag);
         RAISE VALIDATE_FAILED;
      END IF;
      l_c2_final_sum := FND_NUMBER.CANONICAL_TO_NUMBER(l_canonical_value);
      IF l_c2_final_sum IS NULL OR l_c2_final_sum <> p_test_tab_num_rows THEN
         fnd_oam_debug.log(6, l_ctxt, 'Final C2 Sum('||l_c2_final_sum||') not equal to target value('||p_test_tab_num_rows||')');
         RAISE VALIDATE_FAILED;
      END IF;

      --make sure that the run c2 sum also equals the # of rows.
      BEGIN
         SELECT SUM(to_number(canonical_value))
            INTO l_c2_run_sum
            FROM fnd_oam_dscram_arg_values
            WHERE arg_id = p_c2_run_arg_id
            AND valid_value_flag = FND_API.G_TRUE
            AND rownum < 2;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to query arg value for run C2 sum: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
            RAISE VALIDATE_FAILED;
      END;
      IF l_c2_run_sum IS NULL OR l_c2_run_sum <> p_test_tab_num_rows THEN
         fnd_oam_debug.log(6, l_ctxt, 'Run C2 Sum('||l_c2_run_sum||') not equal to target value('||p_test_tab_num_rows||')');
         RAISE VALIDATE_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   --Public
   PROCEDURE EXECUTE_TEST6(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST6';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_test_table_name         VARCHAR2(30) := B_TEST_TABLE_NAME_PREFIX||'6_TAB1';
      l_test_table_num_rows     NUMBER := 5000;
      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_unit_id                 NUMBER;
      l_dml_id                  NUMBER;
      l_c2_arg_name             VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_SUM';
      l_c2_final_arg_name       VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_FINAL_SUM';
      l_c2_arg_id               NUMBER;
      l_c2_final_arg_id         NUMBER;
      l_c2_run_arg_id           NUMBER;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a test table to work on
         IF NOT MAKE_TEST_TABLE(l_test_table_name,
                                l_test_table_num_rows) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a single run
         IF NOT MAKE_RUN(p_run_id,
                         p_weight => 200,
                         p_name => B_DIAG_RUN_NAME_PREFIX||l_testnum) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a context arg to receive the final c2 sum
         IF NOT MAKE_ARG(p_arg_name             => l_c2_final_arg_name,
                         p_parent_id            => p_run_id,
                         p_allow_override_source => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_CONSTANT,
                         p_src_text             => '99',
                         x_arg_id               => l_c2_run_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --solo bundle
         IF NOT MAKE_BUNDLE(p_run_id,
                            p_bundle_id,
                            p_weight => 200,
                            p_min_par_weight => 5,
                            p_workers_allowed => p_num_workers) THEN
            RAISE INIT_FAILED;
         END IF;
         --create task
         IF NOT MAKE_TASK(p_bundle_id,
                          p_weight => 200,
                          x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make unit
         IF NOT MAKE_UNIT(l_task_id,
                          p_weight => 200,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          p_batch_size => 100,
                          p_sug_disable_splitting => FND_API.G_FALSE,
                          x_unit_id => l_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make a simple dml
         IF NOT MAKE_DML(l_unit_id,
                         p_weight => 200,
                         p_dml_stmt => 'UPDATE '||l_test_table_name||' SET C2 = C2 + 1',
                         p_where_clause => NULL,
                         x_dml_id => l_dml_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an output arg for the dml to fetch C2's new sum
         IF NOT MAKE_ARG(p_arg_name     => l_c2_arg_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id       => l_c2_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an output arg to run at the end of the splitting to get the final c2 sum on all rows
         IF NOT MAKE_ARG(p_arg_name     => l_c2_final_arg_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id       => l_c2_final_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_TEST6(p_run_id,
                           p_bundle_id,
                           p_num_workers,
                           l_test_table_name,
                           l_test_table_num_rows,
                           l_c2_arg_id,
                           l_c2_final_arg_id,
                           l_c2_run_arg_id);

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   -- Public
   FUNCTION VALIDATE_TEST7(p_run_id             IN NUMBER,
                           p_bundle_id          IN NUMBER,
                           p_num_workers        IN NUMBER,
                           p_test_tab_name      IN VARCHAR2,
                           p_test_tab_num_rows  IN NUMBER,
                           p_del_dml_id         IN NUMBER,
                           p_upd_dml_id         IN NUMBER,
                           p_c2_arg_id          IN NUMBER,
                           p_c3_arg_id          IN NUMBER,
                           p_c4_arg_id          IN NUMBER)
      RETURN BOOLEAN
   IS
      l_testnum         VARCHAR2(20) := 'TEST7';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_'||l_testnum;

      l_c2_target_sum   NUMBER := ((p_test_tab_num_rows/2)*((p_test_tab_num_rows/2)+2))/4 + (2*(p_test_tab_num_rows/2));

      l_valid_value_flag        VARCHAR2(3);
      l_canonical_value         VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first validate the run/bundle/task/unit
      IF NOT VALIDATE_RUN_RECURSIVE(p_run_id,
                                    p_num_workers,
                                    p_num_bundles => 1,
                                    p_num_tasks => 1,
                                    p_num_units => 1) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --validate each of the DMLs
      IF NOT VALIDATE_DML_SUCCESS(p_run_id,
                                  p_del_dml_id,
                                  p_target_rows => p_test_tab_num_rows*3/4) THEN
         RAISE VALIDATE_FAILED;
      END IF;
      --update should have only been run on half the rows
      IF NOT VALIDATE_DML_SUCCESS(p_run_id,
                                  p_upd_dml_id,
                                  p_target_rows => p_test_tab_num_rows*1/4) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check that the test table has the correct number of rows
      IF NOT VALIDATE_TEST_TABLE_UNCHANGED(p_test_tab_name,
                                           p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check that the c2 sum stored in the arg is correct
      IF NOT VALIDATE_TEST_TABLE_ARG_VALUES(TRUE,
                                            p_c2_arg_id,
                                            l_c2_target_sum,
                                            p_test_tab_name,
                                            p_test_tab_num_rows,
                                            p_c3_arg_id,
                                            p_c4_arg_id) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   --Public
   PROCEDURE EXECUTE_TEST7(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST7';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_test_table_name         VARCHAR2(30) := B_TEST_TABLE_NAME_PREFIX||'7_TAB1';
      l_test_table_num_rows     NUMBER := 10000;
      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_unit_id                 NUMBER;
      l_del_dml_id              NUMBER;
      l_upd_dml_id              NUMBER;
      l_c2_arg_in_name          VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_IN';
      l_c3_arg_in_name          VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C3_IN';
      l_c4_arg_in_name          VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C4_IN';
      l_c2_arg_out_name         VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_OUT';
      l_c3_arg_out_name         VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C3_OUT';
      l_c4_arg_out_name         VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C4_OUT';
      l_c2_arg_in_id            NUMBER;
      l_c3_arg_in_id            NUMBER;
      l_c4_run_in_id            NUMBER;
      l_c4_arg_in_id            NUMBER;
      l_c2_arg_out_id           NUMBER;
      l_c3_arg_out_id           NUMBER;
      l_c4_arg_out_id           NUMBER;
      l_c2_val                  VARCHAR2(30) := '3';
      l_c3_val                  VARCHAR2(30) := l_testnum||'_TESTVAL';
      l_c4_val                  VARCHAR2(30) := '2005/08/31 11:22:33';

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a test table to work on
         IF NOT MAKE_TEST_TABLE(l_test_table_name,
                                l_test_table_num_rows) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a single run
         IF NOT MAKE_RUN(p_run_id,
                         p_weight => 400,
                         p_name => B_DIAG_RUN_NAME_PREFIX||l_testnum) THEN
            RAISE INIT_FAILED;
         END IF;
         --create a context arg to do the actually sourcing of the v4 value
         IF NOT MAKE_ARG(p_arg_name             => l_c4_arg_in_name,
                         p_parent_id            => p_run_id,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text             => 'SELECT FND_DATE.CANONICAL_TO_DATE('''||l_c4_val||''') FROM dual',
                         p_src_where_clause     => NULL,
                         x_arg_id               => l_c4_run_in_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --solo bundle
         IF NOT MAKE_BUNDLE(p_run_id,
                            p_bundle_id,
                            p_weight => 400,
                            p_min_par_weight => 50,
                            p_workers_allowed => p_num_workers) THEN
            RAISE INIT_FAILED;
         END IF;
         --create task
         IF NOT MAKE_TASK(p_bundle_id,
                          p_weight => 400,
                          x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make unit
         IF NOT MAKE_UNIT(l_task_id,
                          p_weight => 400,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          p_batch_size => 100,
                          p_sug_disable_splitting => FND_API.G_FALSE,
                          x_unit_id => l_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the update dml first, but put priority such that it executes second
         IF NOT MAKE_DML(l_unit_id,
                         p_priority => 2,
                         p_weight => 133,
                         p_dml_stmt => 'UPDATE '||l_test_table_name||' SET C2 = C2 + C1 + :DS__TEST7_C2_IN, C3 = :DS__TEST7_C3_IN, C4 = :DS__TEST7_C4_IN',
                         p_where_clause => NULL,
                         x_dml_id => l_upd_dml_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an input arg for the C2 arg
         IF NOT MAKE_ARG(p_arg_name     => l_c2_arg_in_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_upd_dml_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_CONSTANT,
                         p_src_text     => l_c2_val,
                         x_arg_id       => l_c2_arg_in_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an output arg for the C2 arg
         IF NOT MAKE_ARG(p_arg_name     => l_c2_arg_out_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_upd_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id       => l_c2_arg_out_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an input arg for C3
         IF NOT MAKE_ARG(p_arg_name     => l_c3_arg_in_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_upd_dml_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT '''||l_c3_val||''' FROM DUAL',
                         x_arg_id       => l_c3_arg_in_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an output arg for the C3 arg
         IF NOT MAKE_ARG(p_arg_name     => l_c3_arg_out_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_upd_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT COUNT(ROWID) FROM '||l_test_table_name,
                         p_src_where_clause => 'C3 IS NOT NULL AND C3 <> '''||l_c3_val||'''',
                         x_arg_id       => l_c3_arg_out_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an input arg for C4
         IF NOT MAKE_ARG(p_arg_name             => l_c4_arg_in_name,
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id            => l_upd_dml_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ALWAYS,
                         p_src_type             => NULL,
                         x_arg_id               => l_c4_arg_in_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an output arg for C4
         IF NOT MAKE_ARG(p_arg_name     => l_c4_arg_out_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_upd_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT COUNT(ROWID) FROM '||l_test_table_name,
                         p_src_where_clause => 'C4 IS NOT NULL AND C4 <> FND_DATE.CANONICAL_TO_DATE('''||l_c4_val||''')',
                         x_arg_id       => l_c4_arg_out_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --finally, make another dml for the delete that preceeds the update and removes all odd rows
         IF NOT MAKE_DML(l_unit_id,
                         p_priority => 1,
                         p_weight => 266,
                         p_dml_stmt => 'DELETE FROM '||l_test_table_name,
                         p_where_clause => '(MOD(C1, 2) = 1 OR C1 > '||l_test_table_num_rows/2||')',
                         x_dml_id => l_del_dml_id) THEN
            RAISE INIT_FAILED;
         END IF;


         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_TEST7(p_run_id,
                           p_bundle_id,
                           p_num_workers,
                           l_test_table_name,
                           l_test_table_num_rows,
                           l_del_dml_id,
                           l_upd_dml_id,
                           l_c2_arg_out_id,
                           l_c3_arg_out_id,
                           l_c4_arg_out_id);

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   -- Public
   FUNCTION VALIDATE_TEST8(p_run_id             IN NUMBER,
                           p_bundle_id          IN NUMBER,
                           p_num_workers        IN NUMBER,
                           p_verdict_arg_id     IN NUMBER)
      RETURN BOOLEAN
   IS
      l_testnum         VARCHAR2(20) := 'TEST8';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_'||l_testnum;

      l_valid_value_flag        VARCHAR2(3);
      l_canonical_value         VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first validate the run/bundle/task/unit/plsql
      IF NOT VALIDATE_RUN_RECURSIVE(p_run_id,
                                    p_num_workers,
                                    p_num_bundles => 1,
                                    p_num_tasks => 1,
                                    p_num_units => 1,
                                    p_num_plsqls => 1) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --get the value of the verdict output arg
      BEGIN
         SELECT valid_value_flag, canonical_value
            INTO l_valid_value_flag, l_canonical_value
            FROM fnd_oam_dscram_arg_values
            WHERE arg_id = p_verdict_arg_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to query arg value for verdict: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
            RAISE VALIDATE_FAILED;
      END;
      IF l_valid_value_flag IS NULL OR l_valid_value_flag <> FND_API.G_TRUE THEN
         fnd_oam_debug.log(6, l_ctxt, 'Valid value flag of verdict arg is incorrect: '||l_valid_value_flag);
         RAISE VALIDATE_FAILED;
      END IF;
      IF l_canonical_value IS NULL OR l_canonical_value <> FND_API.G_TRUE THEN
         fnd_oam_debug.log(6, l_ctxt, 'Verdict('||l_canonical_value||') not equal to target value('||FND_API.G_TRUE||')');
         RAISE VALIDATE_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Public
   PROCEDURE TEST8_PROC1(p_run_id               IN NUMBER,
                         p_run_mode             IN VARCHAR2,
                         p_bundle_id            IN NUMBER,
                         p_bundle_workers_allowed       IN NUMBER,
                         p_bundle_batch_size    IN NUMBER,
                         p_worker_id            IN NUMBER,
                         p_task_id              IN NUMBER,
                         p_unit_id              IN NUMBER,
                         p_using_splitting      IN VARCHAR2,
                         p_rowid_lbound         IN ROWID,
                         p_rowid_ubound         IN ROWID,
                         p_unit_object_owner    IN VARCHAR2,
                         p_unit_object_name     IN VARCHAR2,
                         p_unit_workers_allowed IN NUMBER,
                         p_unit_batch_size      IN NUMBER,
                         p_plsql_id             IN NUMBER,
                         p_arg_id               IN NUMBER,
                         p_workers_allowed      IN NUMBER,
                         p_batch_size           IN NUMBER,
                         x_verdict              OUT NOCOPY VARCHAR2,
                         x_return_msg           OUT NOCOPY VARCHAR2)
   IS

      l_id                      NUMBER;
      l_run_mode                VARCHAR2(30);
      l_batch_size              NUMBER;
      l_workers_allowed         NUMBER;
      l_worker_id               NUMBER;
      l_disable_splitting       VARCHAR2(3);
      l_unit_object_owner       VARCHAR2(30);
      l_unit_object_name        VARCHAR2(30);
   BEGIN
      --default to the failed status
      x_verdict := FND_API.G_FALSE;
      x_return_msg := '';

      --query out the run with this run_id, also validate run_mode
      BEGIN
         SELECT run_mode
            INTO l_run_mode
            FROM fnd_oam_dscram_runs_b
            WHERE run_id = p_run_id;
      EXCEPTION
         WHEN no_data_found THEN
            x_return_msg := 'Failed to query run for run_id: '||p_run_id;
            RETURN;
      END;

      IF l_run_mode IS NULL OR p_run_mode IS NULL OR l_run_mode <> p_run_mode THEN
         x_return_msg := 'Expected run_mode('||p_run_mode||'), found run_mode('||l_run_mode||')';
         RETURN;
      END IF;

      --check bundle_id/batch size
      BEGIN
         SELECT batch_size, workers_allowed
            INTO l_batch_size, l_workers_allowed
            FROM fnd_oam_dscram_bundles
            WHERE run_id = p_run_id
            AND bundle_id = p_bundle_id;
      EXCEPTION
         WHEN no_data_found THEN
            x_return_msg := 'Failed to query bundle for run_id: '||p_run_id||', bundle_id: '||p_bundle_id;
            RETURN;
      END;

      IF l_batch_size IS NULL OR p_bundle_batch_size IS NULL OR l_batch_size <> p_bundle_batch_size THEN
         x_return_msg := 'Expected bundle batch_size('||p_bundle_batch_size||'), found batch_size('||l_batch_size||')';
         RETURN;
      END IF;
      IF l_batch_size IS NULL OR p_batch_size IS NULL OR l_batch_size <> p_batch_size THEN
         x_return_msg := 'Expected general batch_size('||p_batch_size||'), found batch_size('||l_batch_size||')';
         RETURN;
      END IF;
      IF l_workers_allowed IS NULL OR p_bundle_workers_allowed IS NULL OR l_workers_allowed <> p_bundle_workers_allowed THEN
         x_return_msg := 'Expected bundle workers_allowed('||p_bundle_workers_allowed||'), found workers_allowed('||l_workers_allowed||')';
         RETURN;
      END IF;
      --check the worker_id matches the state
      l_worker_id := FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKER_ID;
      IF p_worker_id IS NULL OR p_worker_id <> l_worker_id THEN
         x_return_msg := 'Worker ID('||p_worker_id||') not the same as the one provided by dscram_bundles('||l_worker_id||')';
         RETURN;
      END IF;

      --check task_id
      BEGIN
         SELECT task_id
            INTO l_id
            FROM fnd_oam_dscram_tasks
            WHERE bundle_id = p_bundle_id
            AND task_id = p_task_id;
      EXCEPTION
         WHEN no_data_found THEN
            x_return_msg := 'Failed to query task for bundle_id: '||p_bundle_id||', task_id: '||p_task_id;
            RETURN;
      END;

      --check the unit
      BEGIN
         SELECT actual_disable_splitting, actual_workers_allowed, unit_object_owner, unit_object_name, batch_size
            INTO l_disable_splitting, l_workers_allowed, l_unit_object_owner, l_unit_object_name, l_batch_size
            FROM fnd_oam_dscram_units
            WHERE task_id = p_task_id
            AND unit_id = p_unit_id;
      EXCEPTION
         WHEN no_data_found THEN
            x_return_msg := 'Failed to query unit for task_id: '||p_task_id||', unit_id: '||p_unit_id;
            RETURN;
      END;

      IF l_disable_splitting IS NULL OR l_disable_splitting <> FND_API.G_TRUE THEN
         x_return_msg := 'Expected disable_splitting('||FND_API.G_TRUE||'), found disable_splitting('||l_disable_splitting||')';
         RETURN;
      END IF;
      IF p_using_splitting IS NULL OR p_using_splitting <> FND_API.G_FALSE THEN
         x_return_msg := 'Expected using_splitting('||FND_API.G_TRUE||'), found using_splitting('||p_using_splitting||')';
         RETURN;
      END IF;
      IF l_workers_allowed IS NULL OR l_workers_allowed <> 1 THEN
         x_return_msg := 'Expected database unit workers_allowed(1), found unit workers_allowed('||l_workers_allowed||')';
         RETURN;
      END IF;
      IF p_unit_workers_allowed IS NULL OR p_unit_workers_allowed <> 1 THEN
         x_return_msg := 'Expected unit workers_allowed(1), found unit workers_allowed('||p_unit_workers_allowed||')';
         RETURN;
      END IF;
      IF p_workers_allowed IS NULL OR p_workers_allowed <> 1 THEN
         x_return_msg := 'Expected general workers_allowed(1), found unit workers_allowed('||p_workers_allowed||')';
         RETURN;
      END IF;
      IF p_unit_batch_size IS NOT NULL THEN
         x_return_msg := 'Expected unit batch_size(NULL), found unit batch_size('||p_unit_batch_size||')';
         RETURN;
      END IF;
      IF l_unit_object_owner IS NULL OR p_unit_object_owner IS NULL OR l_unit_object_owner <> p_unit_object_owner THEN
         x_return_msg := 'Expected unit_object_owner('||p_unit_object_owner||'), found unit_object_owner('||l_unit_object_owner||')';
         RETURN;
      END IF;
      IF l_unit_object_name IS NULL OR p_unit_object_name IS NULL OR l_unit_object_name <> p_unit_object_name THEN
         x_return_msg := 'Expected unit_object_name('||p_unit_object_name||'), found unit_object_name('||l_unit_object_name||')';
         RETURN;
      END IF;

      --make sure the rowids are null
      IF p_rowid_lbound IS NOT NULL THEN
         x_return_msg := 'Expected rowid_lbound to be NULL, found: '||p_rowid_lbound;
         RETURN;
      END IF;
      IF p_rowid_ubound IS NOT NULL THEN
         x_return_msg := 'Expected rowid_ubound to be NULL, found: '||p_rowid_ubound;
         RETURN;
      END IF;

      --check the plsql id
      BEGIN
         SELECT plsql_id
            INTO l_id
            FROM fnd_oam_dscram_plsqls
            WHERE unit_id = p_unit_id
            AND plsql_id = p_plsql_id;
      EXCEPTION
         WHEN no_data_found THEN
            x_return_msg := 'Failed to query plsql for unit_id: '||p_unit_id||', plsql_id: '||p_plsql_id;
            RETURN;
      END;

      --check the arg id
      BEGIN
         SELECT arg_id
            INTO l_id
            FROM fnd_oam_dscram_args_b
            WHERE arg_id = p_arg_id
            AND parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL
            AND parent_id = p_plsql_id;
      EXCEPTION
         WHEN no_data_found THEN
            x_return_msg := 'Failed to query arg for arg_id: '||p_arg_id||', plsql_id: '||p_plsql_id;
            RETURN;
      END;

      --success
      x_verdict := FND_API.G_TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         x_verdict := FND_API.G_FALSE;
         x_return_msg := SUBSTR('Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))', 1, 4000);
   END;

   --Public
   PROCEDURE EXECUTE_TEST8(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST8';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_unit_id                 NUMBER;
      l_plsql_id                NUMBER;
      l_arg_id                  NUMBER;
      l_verdict_arg_id          NUMBER;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a single run
         IF NOT MAKE_RUN(p_run_id,
                         p_weight => 25,
                         p_name => B_DIAG_RUN_NAME_PREFIX||l_testnum) THEN
            RAISE INIT_FAILED;
         END IF;
         --solo bundle
         IF NOT MAKE_BUNDLE(p_run_id,
                            p_bundle_id,
                            p_weight => 25,
                            p_min_par_weight => 26,
                            p_batch_size => 123,
                            p_workers_allowed => p_num_workers) THEN
            RAISE INIT_FAILED;
         END IF;
         --solo task
         IF NOT MAKE_TASK(p_bundle_id,
                          p_weight => 25,
                          x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make unit
         IF NOT MAKE_UNIT(l_task_id,
                          p_unit_type => FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET,
                          p_weight => 25,
                          p_unit_obj_owner => 'DUMMY_OBJ_OWNER',
                          p_unit_obj_name => 'DUMMY_OBJ_NAME',
                          x_unit_id => l_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the update dml first, but put priority such that it executes second
         IF NOT MAKE_PLSQL(l_unit_id,
                           p_priority => 1,
                           p_weight => 25,
                           p_plsql_text => 'FND_OAM_DSCRAM_DIAG_PKG.TEST8_PROC1(:p_run_id,
                                                                                :p_run_mode,
                                                                                :p_bundle_id,
                                                                                :p_bundle_workers_allowed,
                                                                                :p_bundle_batch_size,
                                                                                :p_worker_id,
                                                                                :p_task_id,
                                                                                :p_unit_id,
                                                                                :p_using_splitting,
                                                                                :p_rowid_lbound,
                                                                                :p_rowid_ubound,
                                                                                :p_unit_object_owner,
                                                                                :p_unit_object_name,
                                                                                :p_unit_workers_allowed,
                                                                                :p_unit_batch_size,
                                                                                :p_plsql_id,
                                                                                :p_arg_id,
                                                                                :p_workers_allowed,
                                                                                :p_batch_size,
                                                                                :x_verdict,
                                                                                :x_return_msg)',
                           x_plsql_id => l_plsql_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make args for all the state variables
         IF NOT MAKE_ARG(p_arg_name             => 'p_run_id',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_RUN_ID,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_run_mode',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_RUN_MODE,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_bundle_id',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BUNDLE_ID,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_bundle_workers_allowed',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BUNDLE_WORKERS_ALLOWED,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_bundle_batch_size',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BUNDLE_BATCH_SIZE,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_worker_id',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_WORKER_ID,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_task_id',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_TASK_ID,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_id',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_ID,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_using_splitting',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_USING_SPLITTING,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_lbound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_ubound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_owner',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_OWNER,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_name',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_NAME,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_workers_allowed',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_WORKERS_ALLOWED,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_batch_size',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_BATCH_SIZE,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_plsql_id',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_PLSQL_ID,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_arg_id',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ARGUMENT_ID,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_workers_allowed',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_WORKERS_ALLOWED,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_batch_size',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BATCH_SIZE,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make the return message var
         IF NOT MAKE_ARG(p_arg_name             => 'x_return_msg',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE, --outputs must be bound also
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_EXECUTION_CURSOR,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the verdict output arg
         IF NOT MAKE_ARG(p_arg_name             => 'x_verdict',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE, --outputs must be bound also
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_EXECUTION_CURSOR,
                         x_arg_id               => l_verdict_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_TEST8(p_run_id,
                           p_bundle_id,
                           p_num_workers,
                           l_verdict_arg_id);

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   -- Public
   FUNCTION VALIDATE_TEST9(p_run_id                     IN NUMBER,
                           p_bundle_id                  IN NUMBER,
                           p_num_workers                IN NUMBER,
                           p_plsql_unit_id              IN NUMBER,
                           p_dml_unit_id                IN NUMBER,
                           p_test_tab_name              IN VARCHAR2,
                           p_test_tab_num_rows          IN NUMBER,
                           p_c2_run_arg_id              IN NUMBER,
                           p_c2_plsql_range_arg_id      IN NUMBER,
                           p_c2_dml_range_arg_id        IN NUMBER,
                           p_verdict_arg_id             IN NUMBER)
      RETURN BOOLEAN
   IS
      l_testnum         VARCHAR2(20) := 'TEST9';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_'||l_testnum;

      l_count                   NUMBER;
      l_valid_value_flag        VARCHAR2(3);
      l_canonical_value         VARCHAR2(4000);
      l_c2_sum                  NUMBER;
      l_c2_plsql_target_sum     NUMBER := 2*p_test_tab_num_rows;
      l_c2_dml_target_sum       NUMBER := p_test_tab_num_rows*p_test_tab_num_rows + p_test_tab_num_rows;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first validate the run/bundle/task/unit/plsql
      IF NOT VALIDATE_RUN_RECURSIVE(p_run_id,
                                    p_num_workers,
                                    p_num_bundles => 1,
                                    p_num_tasks => 1,
                                    p_num_units => 2) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --validate the plsql unit
      IF NOT VALIDATE_UNIT_RECURSIVE(p_run_id,
                                     NULL,
                                     p_plsql_unit_id,
                                     p_num_workers,
                                     p_num_dmls         => 0,
                                     p_num_dml_rows     => 0,
                                     p_num_plsqls       => 1) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --validate the dml unit
      IF NOT VALIDATE_UNIT_RECURSIVE(p_run_id,
                                     NULL,
                                     p_dml_unit_id,
                                     p_num_workers,
                                     p_num_dmls         => 1,
                                     p_num_dml_rows     => p_test_tab_num_rows,
                                     p_num_plsqls       => 0) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --make sure the plsql's verdict came out ok
      BEGIN
         SELECT COUNT(ROWID)
            INTO l_count
            FROM fnd_oam_dscram_arg_values
            WHERE arg_id = p_verdict_arg_id
            AND (valid_value_flag IS NULL OR valid_value_flag <> FND_API.G_TRUE)
            AND (canonical_value IS NULL OR canonical_value <> FND_API.G_TRUE);
      EXCEPTION
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to query count of invalid verdicts: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
            RAISE VALIDATE_FAILED;
      END;
      IF l_count IS NULL OR l_count <> 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Arg ID('||p_verdict_arg_id||'), found ('||l_count||') invalid verdicts');
         RAISE VALIDATE_FAILED;
      END IF;

      --check the run arg's value
      fnd_oam_debug.log(1, l_ctxt, 'Checking intermediate run C2 arg value...');
      BEGIN
         SELECT valid_value_flag, canonical_value
            INTO l_valid_value_flag, l_canonical_value
            FROM fnd_oam_dscram_args_b
            WHERE arg_id = p_c2_run_arg_id;
         IF l_valid_value_flag IS NULL OR l_valid_value_flag <> FND_API.G_TRUE THEN
            fnd_oam_debug.log(6, l_ctxt, 'Valid value flag of run C2 intermediate sum is incorrect: '||l_valid_value_flag);
            RAISE VALIDATE_FAILED;
         END IF;
         l_c2_sum := FND_NUMBER.CANONICAL_TO_NUMBER(l_canonical_value);
      EXCEPTION
         WHEN VALIDATE_FAILED THEN
            RAISE;
         WHEN OTHERS THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to query arg value for run C2 intermediate sum: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
            RAISE VALIDATE_FAILED;
      END;
      IF l_c2_sum IS NULL OR l_c2_sum <> p_test_tab_num_rows THEN
         fnd_oam_debug.log(6, l_ctxt, 'Run intermediate C2 Sum('||l_c2_sum||') not equal to target value('||p_test_tab_num_rows||')');
         RAISE VALIDATE_FAILED;
      END IF;

      --check the plsql ranged c2 sum
      fnd_oam_debug.log(1, l_ctxt, 'Checking plsql ranged c2 sum...');
      IF NOT VALIDATE_TEST_TABLE_ARG_VALUES(TRUE,
                                            p_c2_plsql_range_arg_id,
                                            l_c2_plsql_target_sum,
                                            p_test_tab_name,
                                            p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check the dml ranged c2 sum
      fnd_oam_debug.log(1, l_ctxt, 'Checking dml ranged c2 sum...');
      IF NOT VALIDATE_TEST_TABLE_ARG_VALUES(TRUE,
                                            p_c2_dml_range_arg_id,
                                            l_c2_dml_target_sum,
                                            p_test_tab_name,
                                            p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Public
   PROCEDURE TEST9_PROC1(p_using_splitting      IN VARCHAR2,
                         p_rowid_lbound         IN ROWID,
                         p_rowid_ubound         IN ROWID,
                         p_unit_object_owner    IN VARCHAR2,
                         p_unit_object_name     IN VARCHAR2,
                         x_verdict              OUT NOCOPY VARCHAR2,
                         x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_stmt    VARCHAR2(4000);
   BEGIN
      --default to the failed status
      x_verdict := FND_API.G_FALSE;
      x_return_msg := '';

      --make sure we're splitting
      IF p_using_splitting IS NULL or p_using_splitting <> FND_API.G_TRUE THEN
         x_return_msg := 'Procedure expects splitting to be enabled, has value: '||p_using_splitting;
         RETURN;
      END IF;

      -- set up the simple update statement
      l_stmt := 'UPDATE '||p_unit_object_owner||'.'||p_unit_object_name||' SET C2 = C2 + 1 WHERE ROWID BETWEEN :1 AND :2';
      BEGIN
         EXECUTE IMMEDIATE l_stmt USING p_rowid_lbound, p_rowid_ubound;
      EXCEPTION
         WHEN OTHERS THEN
            x_return_msg := 'Exception during execute immediate: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
            RETURN;
      END;

      --success
      x_verdict := FND_API.G_TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         x_verdict := FND_API.G_FALSE;
         x_return_msg := SUBSTR('Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))',1,4000);
   END;

   --Public
   PROCEDURE EXECUTE_TEST9(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST9';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_test_table_name         VARCHAR2(30) := B_TEST_TABLE_NAME_PREFIX||'9_TAB1';
      l_test_table_num_rows     NUMBER       := 8000; --make this small so we force the dependency issue for larger # of workers
      l_c2_range_arg_name       VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_RANGE_SUM';
      l_c2_inter_arg_name       VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_INTER_SUM';
      l_c2_run_arg_id           NUMBER;
      l_c2_plsql_range_arg_id   NUMBER;
      l_c2_plsql_inter_arg_id   NUMBER;
      l_c2_dml_range_arg_id     NUMBER;
      l_c2_dml_inter_arg_id     NUMBER;
      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_plsql_unit_id           NUMBER;
      l_plsql_id                NUMBER;
      l_dml_unit_id             NUMBER;
      l_dml_id                  NUMBER;
      l_arg_id                  NUMBER;
      l_verdict_arg_id          NUMBER;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a test table to work on
         IF NOT MAKE_TEST_TABLE(l_test_table_name,
                                l_test_table_num_rows) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a single run
         IF NOT MAKE_RUN(p_run_id,
                         p_weight => 30,
                         p_name => B_DIAG_RUN_NAME_PREFIX||l_testnum) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a context arg to receive the final c2 sum
         IF NOT MAKE_ARG(p_arg_name              => l_c2_inter_arg_name,
                         p_parent_id             => p_run_id,
                         p_allow_override_source => FND_API.G_TRUE,
                         p_datatype              => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions           => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy          => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE, --can't be always, otherwise it won't use unit1's cached val
                         p_src_type              => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE, --shouldn't be used beyond print_context
                         p_src_text              => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_RUN_ID,
                         x_arg_id                => l_c2_run_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --solo bundle
         IF NOT MAKE_BUNDLE(p_run_id,
                            p_bundle_id,
                            p_weight => 30,
                            p_min_par_weight => 15,
                            p_batch_size => 1,
                            p_workers_allowed => p_num_workers) THEN
            RAISE INIT_FAILED;
         END IF;
         --solo task
         IF NOT MAKE_TASK(p_bundle_id,
                          p_weight => 30,
                          x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make a plsql set unit
         IF NOT MAKE_UNIT(l_task_id,
                          p_unit_type => FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET,
                          p_phase => 1,
                          p_weight => 15,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          x_unit_id => l_plsql_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the plsql
         IF NOT MAKE_PLSQL(l_plsql_unit_id,
                           p_priority => 1,
                           p_weight => 25,
                           p_plsql_text => 'FND_OAM_DSCRAM_DIAG_PKG.TEST9_PROC1(:p_using_splitting,
                                                                                :p_rowid_lbound,
                                                                                :p_rowid_ubound,
                                                                                :p_unit_object_owner,
                                                                                :p_unit_object_name,
                                                                                :x_verdict,
                                                                                :x_return_msg)',
                           x_plsql_id => l_plsql_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_using_splitting',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_USING_SPLITTING,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_lbound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_ubound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_owner',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_OWNER,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_name',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_NAME,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make the return message var
         IF NOT MAKE_ARG(p_arg_name             => 'x_return_msg',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE, --outputs must be bound also
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_EXECUTION_CURSOR,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the verdict output arg
         IF NOT MAKE_ARG(p_arg_name             => 'x_verdict',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE, --outputs must be bound also
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_EXECUTION_CURSOR,
                         x_arg_id               => l_verdict_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make an output arg for the plsql to run at the end of each range to get the c2 sum
         IF NOT MAKE_ARG(p_arg_name             => l_c2_range_arg_name,
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text             => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id               => l_c2_plsql_range_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make an output arg for the plsql to run at the end of the splitting to get the final c2 sum on all rows
         IF NOT MAKE_ARG(p_arg_name     => l_c2_inter_arg_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id    => l_plsql_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL,
                         p_src_text     => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id       => l_c2_plsql_inter_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make the dml unit
         IF NOT MAKE_UNIT(l_task_id,
                          p_unit_type => FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET,
                          p_phase => NULL,
                          p_weight => 15,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          x_unit_id => l_dml_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make a simple dml
         IF NOT MAKE_DML(l_dml_unit_id,
                         p_weight => 15,
                         p_dml_stmt => 'UPDATE '||l_test_table_name||' SET C2 = C2 + :'|| l_c2_inter_arg_name,
                         p_where_clause => NULL,
                         x_dml_id => l_dml_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make an input arg for the dml to fetch the sum from the first unit
         IF NOT MAKE_ARG(p_arg_name              => l_c2_inter_arg_name,
                         p_parent_type           => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id             => l_dml_id,
                         p_binding_enabled_flag  => FND_API.G_TRUE,
                         p_allow_override_source => FND_API.G_TRUE,
                         p_datatype              => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions           => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy          => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type              => NULL,
                         x_arg_id                => l_c2_dml_inter_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make a ranged final arg_id
         IF NOT MAKE_ARG(p_arg_name     => l_c2_range_arg_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id       => l_c2_dml_range_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_TEST9(p_run_id,
                           p_bundle_id,
                           p_num_workers,
                           l_plsql_unit_id,
                           l_dml_unit_id,
                           l_test_table_name,
                           l_test_table_num_rows,
                           l_c2_run_arg_id,
                           l_c2_plsql_range_arg_id,
                           l_c2_dml_range_arg_id,
                           l_verdict_arg_id);

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   -- Public
   FUNCTION VALIDATE_TEST10(p_run_id                    IN NUMBER,
                            p_bundle_id                 IN NUMBER,
                            p_num_workers               IN NUMBER,
                            p_child1_unit_id            IN NUMBER,
                            p_child2_unit_id            IN NUMBER,
                            p_child3_unit_id            IN NUMBER,
                            p_test_tab_name             IN VARCHAR2,
                            p_test_tab_num_rows         IN NUMBER,
                            p_c2_final_arg_id           IN NUMBER)
      RETURN BOOLEAN
   IS
      l_testnum         VARCHAR2(20) := 'TEST10';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_'||l_testnum;

      l_count                   NUMBER;
      l_valid_value_flag        VARCHAR2(3);
      l_canonical_value         VARCHAR2(4000);
      l_c2_sum                  NUMBER;
      l_c2_target_sum           NUMBER := 51208*p_test_tab_num_rows;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --first validate the run/bundle/task/unit/plsql
      IF NOT VALIDATE_RUN_RECURSIVE(p_run_id,
                                    p_num_workers,
                                    p_num_bundles => 1,
                                    p_num_tasks => 1,
                                    p_num_units => 1) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --validate the child1 unit
      IF NOT VALIDATE_UNIT_RECURSIVE(p_run_id,
                                     NULL,
                                     p_child1_unit_id,
                                     p_num_workers,
                                     p_num_dmls         => 0,
                                     p_num_dml_rows     => 0,
                                     p_num_plsqls       => 2,
                                     p_unit_status      => FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_NO_STATUS) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --validate the child2 unit
      IF NOT VALIDATE_UNIT_RECURSIVE(p_run_id,
                                     NULL,
                                     p_child2_unit_id,
                                     p_num_workers,
                                     p_num_dmls         => 2,
                                     p_num_dml_rows     => p_test_tab_num_rows,
                                     p_num_plsqls       => 0,
                                     p_unit_status      => FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_NO_STATUS) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --validate the child3 unit
      IF NOT VALIDATE_UNIT_RECURSIVE(p_run_id,
                                     NULL,
                                     p_child3_unit_id,
                                     p_num_workers,
                                     p_num_dmls         => 0,
                                     p_num_dml_rows     => 0,
                                     p_num_plsqls       => 2,
                                     p_unit_status      => FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_NO_STATUS) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      --check the plsql ranged c2 sum
      fnd_oam_debug.log(1, l_ctxt, 'Checking final ranged c2 sum...');
      IF NOT VALIDATE_TEST_TABLE_ARG_VALUES(TRUE,
                                            p_c2_final_arg_id,
                                            l_c2_target_sum,
                                            p_test_tab_name,
                                            p_test_tab_num_rows) THEN
         RAISE VALIDATE_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN VALIDATE_FAILED THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Public
   PROCEDURE TEST10_PROC1_1(p_using_splitting   IN VARCHAR2,
                            p_rowid_lbound      IN ROWID,
                            p_rowid_ubound      IN ROWID,
                            p_unit_object_owner IN VARCHAR2,
                            p_unit_object_name  IN VARCHAR2)
   IS
      l_stmt    VARCHAR2(4000);
   BEGIN
      --make sure we're splitting
      IF p_using_splitting IS NULL or p_using_splitting <> FND_API.G_TRUE THEN
         RAISE VALUE_ERROR;
      END IF;

      -- set up the simple update statement
      l_stmt := 'UPDATE '||p_unit_object_owner||'.'||p_unit_object_name||' SET C2 = 7*C2 + 1 WHERE ROWID BETWEEN :1 AND :2';
      EXECUTE IMMEDIATE l_stmt USING p_rowid_lbound, p_rowid_ubound;
   END;

   -- Public
   PROCEDURE TEST10_PROC1_2(p_using_splitting   IN VARCHAR2,
                            p_rowid_lbound      IN ROWID,
                            p_rowid_ubound      IN ROWID,
                            p_unit_object_owner IN VARCHAR2,
                            p_unit_object_name  IN VARCHAR2)
   IS
      l_stmt    VARCHAR2(4000);
   BEGIN
      --make sure we're splitting
      IF p_using_splitting IS NULL or p_using_splitting <> FND_API.G_TRUE THEN
         RAISE VALUE_ERROR;
      END IF;

      -- set up the simple update statement
      l_stmt := 'UPDATE '||p_unit_object_owner||'.'||p_unit_object_name||' SET C2 = 11*C2 + 1 WHERE ROWID BETWEEN :1 AND :2';
      EXECUTE IMMEDIATE l_stmt USING p_rowid_lbound, p_rowid_ubound;
   END;

   -- Public
   FUNCTION TEST10_FUNC2_2(p_using_splitting    IN VARCHAR2,
                           p_rowid_lbound       IN ROWID,
                           p_rowid_ubound       IN ROWID,
                           p_unit_object_owner  IN VARCHAR2,
                           p_unit_object_name   IN VARCHAR2)
      RETURN NUMBER
   IS
      l_stmt    VARCHAR2(4000);
      l_count   NUMBER;
   BEGIN
      --make sure we're splitting
      IF p_using_splitting IS NULL or p_using_splitting <> FND_API.G_TRUE THEN
         RAISE VALUE_ERROR;
      END IF;

      -- set up the simple update statement
      l_stmt := 'SELECT COUNT(ROWID) FROM '||p_unit_object_owner||'.'||p_unit_object_name||' WHERE ROWID BETWEEN :1 AND :2';
      EXECUTE IMMEDIATE l_stmt INTO l_count USING p_rowid_lbound, p_rowid_ubound;
      RETURN l_count;
   END;

   -- Public
   PROCEDURE TEST10_PROC3_1(p_using_splitting   IN VARCHAR2,
                            p_rowid_lbound      IN ROWID,
                            p_rowid_ubound      IN ROWID,
                            p_unit_object_owner IN VARCHAR2,
                            p_unit_object_name  IN VARCHAR2)
   IS
      l_stmt    VARCHAR2(4000);
   BEGIN
      --make sure we're splitting
      IF p_using_splitting IS NULL or p_using_splitting <> FND_API.G_TRUE THEN
         RAISE VALUE_ERROR;
      END IF;

      -- set up the simple update statement
      l_stmt := 'UPDATE '||p_unit_object_owner||'.'||p_unit_object_name||' SET C2 = 3*C2 + 1 + :1 WHERE ROWID BETWEEN :2 AND :3';
      EXECUTE IMMEDIATE l_stmt USING TEST10_FUNC2_2(p_using_splitting, p_rowid_lbound, p_rowid_ubound, p_unit_object_owner, p_unit_object_name), p_rowid_lbound, p_rowid_ubound;
   END;

   -- Public
   PROCEDURE TEST10_PROC3_2(p_using_splitting   IN VARCHAR2,
                            p_rowid_lbound      IN ROWID,
                            p_rowid_ubound      IN ROWID,
                            p_unit_object_owner IN VARCHAR2,
                            p_unit_object_name  IN VARCHAR2)
   IS
      l_stmt    VARCHAR2(4000);
   BEGIN
      --make sure we're splitting
      IF p_using_splitting IS NULL or p_using_splitting <> FND_API.G_TRUE THEN
         RAISE VALUE_ERROR;
      END IF;

      -- set up the simple update statement
      l_stmt := 'UPDATE '||p_unit_object_owner||'.'||p_unit_object_name||' SET C2 = 2*C2 + 1 WHERE ROWID BETWEEN :1 AND :2';
      EXECUTE IMMEDIATE l_stmt USING p_rowid_lbound, p_rowid_ubound;
   END;

   --Public
   PROCEDURE EXECUTE_TEST10(p_run_id            IN NUMBER DEFAULT 1,
                            p_bundle_id         IN NUMBER DEFAULT 1,
                            p_num_bundles       IN NUMBER DEFAULT 1,
                            p_num_workers       IN NUMBER DEFAULT 1,
                            x_verdict           OUT NOCOPY VARCHAR2)
   IS
      l_testnum         VARCHAR2(20) := 'TEST10';
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_'||l_testnum;

      l_test_table_name         VARCHAR2(30) := B_TEST_TABLE_NAME_PREFIX||'10_TAB1';
      l_test_table_num_rows     NUMBER       := 4800; --make this small since we have many operations
      l_c2_final_arg_name       VARCHAR2(60) := FND_OAM_DSCRAM_UTILS_PKG.G_ARG_INTERNAL_PREFIX||l_testnum||'_C2_FINAL_SUM';
      l_worker_id               NUMBER;
      l_task_id                 NUMBER;
      l_parent_unit_id          NUMBER;
      l_child1_unit_id          NUMBER;
      l_child2_unit_id          NUMBER;
      l_child3_unit_id          NUMBER;
      l_plsql_id                NUMBER;
      l_dml_id                  NUMBER;
      l_c2_final_arg_id         NUMBER;
      l_arg_id                  NUMBER;

      l_did_init        BOOLEAN := FALSE;
      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_retbool         BOOLEAN;
      l_retbool_final   BOOLEAN;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_start           NUMBER;
      l_end             NUMBER;
      k                 NUMBER;
      j                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      PRINT_TEST_ENTRY_STATE(l_ctxt, p_run_id, p_bundle_id, p_num_bundles, p_num_workers);

      ROLLBACK;
      IF RUN_NEEDS_INIT(p_run_id,
                        l_lock_handle) THEN

         fnd_oam_debug.log(1, l_ctxt, 'Initializing Test...');
         l_start := DBMS_UTILITY.GET_TIME;

         --create a test table to work on
         IF NOT MAKE_TEST_TABLE(l_test_table_name,
                                l_test_table_num_rows) THEN
            RAISE INIT_FAILED;
         END IF;

         --create a single run
         IF NOT MAKE_RUN(p_run_id,
                         p_weight => NULL,
                         p_name => B_DIAG_RUN_NAME_PREFIX||l_testnum) THEN
            RAISE INIT_FAILED;
         END IF;
         --solo bundle
         IF NOT MAKE_BUNDLE(p_run_id,
                            p_bundle_id,
                            p_weight => NULL,
                            p_min_par_weight => 456,
                            p_batch_size => 1,
                            p_workers_allowed => p_num_workers) THEN
            RAISE INIT_FAILED;
         END IF;
         --solo task
         IF NOT MAKE_TASK(p_bundle_id,
                          p_weight => NULL,
                          x_task_id => l_task_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make a concurrent group meta-unit
         IF NOT MAKE_UNIT(l_task_id,
                          p_unit_type => FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_CONC_GROUP,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          x_unit_id => l_parent_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make child unit 1
         IF NOT MAKE_UNIT(l_task_id,
                          p_unit_type => FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET,
                          p_conc_unit_id => l_parent_unit_id,
                          p_status => FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_NO_STATUS,
                          p_priority => NULL,
                          p_weight => 1000,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          x_unit_id => l_child1_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the 1.1 plsql
         IF NOT MAKE_PLSQL(l_child1_unit_id,
                           p_priority => 2,
                           p_weight => 11,
                           p_plsql_text => 'FND_OAM_DSCRAM_DIAG_PKG.TEST10_PROC1_1(:p_using_splitting,
                                                                                   :p_rowid_lbound,
                                                                                   :p_rowid_ubound,
                                                                                   :p_unit_object_owner,
                                                                                   :p_unit_object_name)',
                           x_plsql_id => l_plsql_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_using_splitting',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_USING_SPLITTING,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_lbound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_ubound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_owner',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_OWNER,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_name',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_NAME,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the 1.2 plsql
         IF NOT MAKE_PLSQL(l_child1_unit_id,
                           p_priority => NULL,
                           p_weight => 112,
                           p_plsql_text => 'FND_OAM_DSCRAM_DIAG_PKG.TEST10_PROC1_2(:p_using_splitting,
                                                                                   :p_rowid_lbound,
                                                                                   :p_rowid_ubound,
                                                                                   :p_unit_object_owner,
                                                                                   :p_unit_object_name)',
                           x_plsql_id => l_plsql_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_using_splitting',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_USING_SPLITTING,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_lbound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_ubound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_owner',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_OWNER,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_name',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_NAME,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make child unit 2
         IF NOT MAKE_UNIT(l_task_id,
                          p_unit_type => FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET,
                          p_conc_unit_id => l_parent_unit_id,
                          p_status => FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_NO_STATUS,
                          p_priority => NULL,
                          p_weight => 200,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          x_unit_id => l_child2_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make dml 2.1
         IF NOT MAKE_DML(l_child2_unit_id,
                         p_weight => 21,
                         p_dml_stmt => 'UPDATE '||l_test_table_name||' SET C2 = 13*C2 + 1',
                         p_where_clause => NULL,
                         x_dml_id => l_dml_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --dml 2.1 will be scheduled last, affix a range sum to check our sequence of updates
         IF NOT MAKE_ARG(p_arg_name     => l_c2_final_arg_name,
                         p_parent_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id    => l_dml_id,
                         p_datatype     => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER,
                         p_permissions  => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                         p_write_policy => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type     => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE,
                         p_src_text     => 'SELECT SUM(C2) FROM '||l_test_table_name,
                         x_arg_id       => l_c2_final_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make dml 2.2
         --can't use function TEST10_FUNC2_2 in the math because it throws the error: Code(-4091),
         --Message("ORA-04091: table APPS.FND_OAM_DSCRAM_TT_10_TAB1 is mutating, trigger/function may not see it"))"
         IF NOT MAKE_DML(l_child2_unit_id,
                         p_priority => 1,
                         p_weight => 22,
                         p_dml_stmt => 'UPDATE '||l_test_table_name||' SET C2 = 5*(C2 - (SELECT COUNT(ROWID) FROM '||l_test_table_name||' WHERE ROWID BETWEEN  :p_rowid_lbound AND :p_rowid_ubound)) + 1',
                         p_where_clause => NULL,
                         x_dml_id => l_dml_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_lbound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id            => l_dml_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_ubound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                         p_parent_id            => l_dml_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         --make child unit 3
         IF NOT MAKE_UNIT(l_task_id,
                          p_unit_type => FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET,
                          p_conc_unit_id => l_parent_unit_id,
                          p_status => FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_NO_STATUS,
                          p_priority => 1,
                          p_weight => 300,
                          p_unit_obj_owner => B_TEST_TABLE_OWNER,
                          p_unit_obj_name => l_test_table_name,
                          x_unit_id => l_child3_unit_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the 3.1 plsql
         IF NOT MAKE_PLSQL(l_child3_unit_id,
                           p_priority => NULL,
                           p_weight => 31,
                           p_plsql_text => 'FND_OAM_DSCRAM_DIAG_PKG.TEST10_PROC3_1(:p_using_splitting,
                                                                                   :p_rowid_lbound,
                                                                                   :p_rowid_ubound,
                                                                                   :p_unit_object_owner,
                                                                                   :p_unit_object_name)',
                           x_plsql_id => l_plsql_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_using_splitting',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_USING_SPLITTING,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_lbound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_ubound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_owner',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_OWNER,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_name',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_NAME,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         --make the 3.2 plsql
         IF NOT MAKE_PLSQL(l_child3_unit_id,
                           p_priority => 1,
                           p_weight => 32,
                           p_plsql_text => 'FND_OAM_DSCRAM_DIAG_PKG.TEST10_PROC3_2(:p_using_splitting,
                                                                                   :p_rowid_lbound,
                                                                                   :p_rowid_ubound,
                                                                                   :p_unit_object_owner,
                                                                                   :p_unit_object_name)',
                           x_plsql_id => l_plsql_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_using_splitting',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_USING_SPLITTING,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_lbound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_rowid_ubound',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_owner',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_OWNER,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;
         IF NOT MAKE_ARG(p_arg_name             => 'p_unit_object_name',
                         p_parent_type          => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                         p_parent_id            => l_plsql_id,
                         p_binding_enabled_flag => FND_API.G_TRUE,
                         p_datatype             => FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2,
                         p_permissions          => FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE,
                         p_write_policy         => FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                         p_src_type             => FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE,
                         p_src_text             => FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_NAME,
                         x_arg_id               => l_arg_id) THEN
            RAISE INIT_FAILED;
         END IF;

         COMMIT;
         l_end := DBMS_UTILITY.GET_TIME;
         fnd_oam_debug.log(1, l_ctxt, 'Init Done - Duration: '||(l_end - l_start)/100|| ' seconds.');
         l_did_init := TRUE;
      END IF;

      --do work
      l_retbool := EXECUTE_BUNDLE_WRAPPER(l_ctxt,
                                          p_run_id,
                                          p_bundle_id,
                                          l_worker_id,
                                          l_return_status,
                                          l_return_msg);

      --make the guy who did init manage the sync, do cleanup and verify
      IF l_did_init THEN
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                           l_retbool,
                                           p_num_workers,
                                           l_did_init);
         --validate the results
         l_retbool_final := l_retbool_final AND
            VALIDATE_TEST10(p_run_id,
                            p_bundle_id,
                            p_num_workers,
                            l_child1_unit_id,
                            l_child2_unit_id,
                            l_child3_unit_id,
                            l_test_table_name,
                            l_test_table_num_rows,
                            l_c2_final_arg_id);

         --send acks to the other workers with the final status
         SEND_ACKS(p_run_id,
                   l_retbool_final,
                   p_num_workers);
      ELSE
         l_retbool_final := SYNC_ON_FINISH(p_run_id,
                                      l_retbool);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      IF l_retbool_final THEN
         x_verdict := FND_API.G_TRUE;
      ELSE
         x_verdict := FND_API.G_FALSE;
      END IF;
   EXCEPTION
      WHEN INIT_FAILED THEN
         --release the run lock on failure just in case
         l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         IF l_retval <> 0 THEN
            fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         END IF;
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN SYNC_FAILED THEN
         fnd_oam_debug.log(6, l_ctxt, 'Sync Failed');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

   --Public
   PROCEDURE EXECUTE_ALL_TESTS(p_run_id                         IN NUMBER,
                               p_bundle_id                      IN NUMBER,
                               p_num_bundles                    IN NUMBER,
                               p_num_workers                    IN NUMBER,
                               p_fail_fast                      IN VARCHAR2,
                               p_execute_real_table_tests       IN VARCHAR2,
                               x_verdict                        OUT NOCOPY VARCHAR2)
   IS
      l_ctxt                            VARCHAR2(60) := PKG_NAME||'EXECUTE_ALL_TESTS';
      l_fail_fast                       BOOLEAN := FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_fail_fast);
      l_execute_real_table_tests        BOOLEAN := FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_execute_real_table_tests);

      l_run_id          NUMBER := p_run_id;
      l_bundle_id       NUMBER := p_bundle_id;

      l_retval          BOOLEAN := TRUE;
      l_start           NUMBER;
      l_end             NUMBER;
      l_verdict         VARCHAR2(6);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      l_start := DBMS_UTILITY.GET_TIME;

      EXECUTE_TEST1(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST2(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST3(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST4(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST5(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST6(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST7(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST8(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST9(l_run_id,
                    l_bundle_id,
                    p_num_bundles,
                    p_num_workers,
                    l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_run_id := l_run_id + 1;
      l_bundle_id := l_bundle_id + p_num_bundles;

      EXECUTE_TEST10(l_run_id,
                     l_bundle_id,
                     p_num_bundles,
                     p_num_workers,
                     l_verdict);
      IF l_verdict <> FND_API.G_TRUE THEN
         IF l_fail_fast THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            x_verdict := l_verdict;
            RETURN;
         END IF;
      END IF;

      l_end := DBMS_UTILITY.GET_TIME;
      fnd_oam_debug.log(1, l_ctxt, 'Done - Duration: '||(l_end - l_start)/100|| ' seconds.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_verdict := l_verdict;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_verdict := FND_API.G_FALSE;
   END;

END FND_OAM_DSCRAM_DIAG_PKG;

/
