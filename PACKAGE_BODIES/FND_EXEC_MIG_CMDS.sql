--------------------------------------------------------
--  DDL for Package Body FND_EXEC_MIG_CMDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EXEC_MIG_CMDS" AS
/* $Header: fndpemcb.pls 120.1 2005/07/02 03:34:07 appldev noship $ */

  PROCEDURE execute_cmd (p_lineno IN NUMBER,
                         p_mig_cmd IN VARCHAR2,
                         x_err_code OUT NOCOPY NUMBER,
                         x_status OUT NOCOPY VARCHAR2)
  IS
    l_err                    VARCHAR2(4000);
    l_err_code               NUMBER;
  BEGIN
    x_status := 'SUCCESS';
    x_err_code := 0;

    BEGIN
      UPDATE fnd_ts_mig_cmds
         SET start_date = sysdate,
             last_update_date = sysdate,
             end_date = null
       WHERE lineno = p_lineno;

      EXECUTE IMMEDIATE p_mig_cmd;

      UPDATE fnd_ts_mig_cmds
         SET migration_status = 'SUCCESS',
             end_date = sysdate,
             last_update_date = sysdate,
             error_text = NULL
       WHERE lineno = p_lineno;

    EXCEPTION
     WHEN OTHERS THEN
       l_err_code := sqlcode;
       x_err_code := sqlcode;
       l_err := sqlerrm(sqlcode);
       x_status := 'ERROR';
       UPDATE fnd_ts_mig_cmds
          SET migration_status = 'ERROR',
              end_date = sysdate,
              error_text = l_err,
              last_update_date = sysdate
        WHERE lineno = p_lineno;
       if l_err_code IN (-1658, -1659) then
         raise_application_error(-20101, l_err);
       end if;
    END;
    COMMIT;
  END execute_cmd;


  PROCEDURE process_line_child_cmds (p_lineno IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_status                 VARCHAR2(30) := 'SUCCESS';
    l_err_code               NUMBER := 0;
    l_message_data           SYSTEM.tbl_mig_type;
    l_enqopt                 DBMS_AQ.enqueue_options_t;
    l_msgprop                DBMS_AQ.message_properties_t;
    l_deqopt                 DBMS_AQ.dequeue_options_t;
    l_enq_msgid              RAW(16);
    l_deq_msgid              RAW(16);
    l_queue_name             VARCHAR2(100);

    CURSOR child_lineno_cur(l_lineno NUMBER) IS
    SELECT lineno,
           owner,
           object_name,
           migration_cmd,
           partitioned,
           parent_owner,
           parent_object_name,
           execution_mode
      FROM fnd_ts_mig_cmds
     WHERE parent_lineno = l_lineno;
  BEGIN
    l_enqopt.visibility  := DBMS_AQ.IMMEDIATE;

    FOR child_lineno_rec IN child_lineno_cur(p_lineno)
    LOOP
      if child_lineno_rec.execution_mode = 'P' then
        l_queue_name := 'tblmig_messageque';
      elsif child_lineno_rec.execution_mode = 'S' then
        l_queue_name := 'tblmig_seq_messageque';
      end if;

      l_message_data := SYSTEM.tbl_mig_type
                            (child_lineno_rec.migration_cmd,
                             child_lineno_rec.lineno,
                             child_lineno_rec.owner,
                             child_lineno_rec.object_name,
                             child_lineno_rec.partitioned,
                             child_lineno_rec.parent_owner,
                             child_lineno_rec.parent_object_name);
      DBMS_AQ.enqueue (l_queue_name, l_enqopt, l_msgprop,
                       l_message_data, l_enq_msgid);
    END LOOP;
  END process_line_child_cmds;


  PROCEDURE migrate_objects (
    p_owner                IN   VARCHAR2,
    p_aqStat               IN   VARCHAR2,
    p_exec_mode            IN   VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2
  ) IS

    l_status                 VARCHAR2(30) := 'SUCCESS';
    l_err_code               NUMBER := 0;
    l_retVal                 NUMBER;
    l_lineno                 NUMBER;
    l_aqretVal               NUMBER;
    l_mig_cmd                VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
    l_message_data           SYSTEM.tbl_mig_type;
    l_outmessage_data        SYSTEM.tbl_mig_type;
    l_enqopt                 DBMS_AQ.enqueue_options_t;
    l_msgprop                DBMS_AQ.message_properties_t;
    l_deqopt                 DBMS_AQ.dequeue_options_t;
    l_enq_msgid              RAW(16);
    l_deq_msgid              RAW(16);

    l_parent_owner           FND_TS_MIG_CMDS.PARENT_OWNER%TYPE;
    l_parent_object_name     FND_TS_MIG_CMDS.PARENT_OBJECT_NAME%TYPE;
    l_owner                  FND_TS_MIG_CMDS.OWNER%TYPE;
    l_object_name            FND_TS_MIG_CMDS.OBJECT_NAME%TYPE;
    l_mig_status             FND_TS_MIG_CMDS.MIGRATION_STATUS%TYPE := 'SUCCESS';
    l_partitioned            FND_TS_MIG_CMDS.PARTITIONED%TYPE;
    l_queue_name             VARCHAR2(100);
    l_cnt                    NUMBER;
    l_string                 VARCHAR2(4000);
    TYPE mig_cmd_cur_type IS REF CURSOR;
    mig_cmd_cur              mig_cmd_cur_type;

    TYPE NumTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE CharTabType IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE BigCharTabType IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

    TYPE RecTabType IS RECORD
      (lineno   NumTabType,
       owner CharTabType,
       object_name CharTabType,
       migration_cmd BigCharTabType,
       partitioned CharTabType,
       parent_owner CharTabType,
       parent_object_name CharTabType);
    cmdtab RecTabType;

    cursor all_cmd_cur(l_exec_mode VARCHAR2) is
    select lineno,
           owner,
           object_name,
           migration_cmd,
           partitioned,
           parent_owner,
           parent_object_name
      from fnd_ts_mig_cmds
     --where object_type IN ('TABLE', 'INDEX', 'MVIEW', 'MV_LOG', 'LONG_INDEX','LONG_MVLOG')
     where object_type IN ('TABLE', 'INDEX', 'MVIEW', 'MV_LOG')
       and migration_status in ('ERROR', 'GENERATED')
       and object_name not like 'FND_TS_MIG_CMDS%'
       and object_name not like 'FND_TS_SIZING%'
       and object_name not like 'FND_TS_PROD_INSTS%'
       AND execution_mode = l_exec_mode
       AND ( (migration_status = 'ERROR' -- for restart
             OR
             (migration_status = 'GENERATED'
              AND start_date IS NOT NULL)) -- for restart of Abort cases
           OR
           (parent_lineno IS NULL)    -- for first time enqueueing
           OR
(migration_status = 'GENERATED' and parent_lineno in (select lineno from fnd_ts_mig_cmds where migration_status='SUCCESS'))  -- for bug 4332349
         )
     order by total_blocks desc;

    l_schema_list            VARCHAR2(4000);
    l_old_index              NUMBER := 0;
    l_new_index              NUMBER := 0;
    l_enqueue                VARCHAR2(1) := NVL(p_aqStat, 'N');

  BEGIN
    update fnd_ts_mig_status set num_threads=num_threads+1 where item='EXE_MIG_CMDS';
    commit;

    if p_owner <> '%' then
    LOOP
      l_new_index := INSTR(p_owner, ',', l_old_index+1);
      if l_schema_list IS NULL AND l_new_index = 0 then
        l_schema_list := '('''||SUBSTR(p_owner, l_old_index+1)||''')';
      elsif l_schema_list IS NULL AND l_new_index <> 0 then
        l_schema_list := '('''||SUBSTR(p_owner, l_old_index+1, l_new_index-l_old_index-1)||'''';
      elsif l_new_index = 0 then
        l_schema_list := l_schema_list||','''||SUBSTR(p_owner, l_old_index+1)||''')';
      else
        l_schema_list := l_schema_list||','''||SUBSTR(p_owner, l_old_index+1, l_new_index-l_old_index-1)||'''';
      end if;
      EXIT WHEN l_new_index = 0;
      l_old_index := l_new_index;
    END LOOP;
    end if;
--dbms_output.put_line('schema list = '||l_schema_list);

    l_string := 'select lineno,
                 owner,
                 object_name,
                 migration_cmd,
                 partitioned,
                 parent_owner,
                 parent_object_name
            from fnd_ts_mig_cmds
           where owner IN '||l_schema_list||'
             and object_type IN (''TABLE'', ''INDEX'', ''MVIEW'', ''MV_LOG'', ''LONG_INDEX'',''LONG_MVLOG'')
             and migration_status in (''ERROR'', ''GENERATED'')
             and object_name not like ''FND_TS_MIG_CMDS%''
             and object_name not like ''FND_TS_SIZING%''
             and object_name not like ''FND_TS_PROD_INSTS%''
             AND execution_mode = '''||p_exec_mode||'''
             AND ( (migration_status = ''ERROR''
                   OR
                   (migration_status = ''GENERATED''
                    AND start_date IS NOT NULL))
                 OR
                 (parent_lineno IS NULL))
           order by total_blocks desc';
--dbms_output.put_line(substr(l_string,1,250));
--dbms_output.put_line(substr(l_string,251,250));
--dbms_output.put_line(substr(l_string,501,250));
--dbms_output.put_line(substr(l_string,751,250));

   if p_exec_mode = 'P' then
     -- Set the module name for parallel process
     DBMS_APPLICATION_INFO.SET_MODULE('TS_MIGRATE_PARALLEL_OBJECTS', NULL);
     l_queue_name := 'tblmig_messageque';
   elsif p_exec_mode = 'S' then
/*
     -- Initial Enqueue only if no Sequential process is running.
     SELECT COUNT(1)
       INTO l_cnt
       FROM v$session
      WHERE module = 'TS_MIGRATE_SEQUENTIAL_OBJECTS'
        AND status <> 'KILLED';
     if l_cnt > 0 then
       l_enqueue := 'N';
     end if;
*/
     -- Set the module name for sequential process
     DBMS_APPLICATION_INFO.SET_MODULE('TS_MIGRATE_SEQUENTIAL_OBJECTS', NULL);
     l_queue_name := 'tblmig_seq_messageque';
   end if;

   if l_enqueue = 'Y' then
      l_enqopt.visibility  := DBMS_AQ.IMMEDIATE;
      if p_owner = '%' then
        OPEN all_cmd_cur(p_exec_mode);
        LOOP
          cmdtab.lineno.DELETE;
          FETCH all_cmd_cur BULK COLLECT INTO
            cmdtab.lineno, cmdtab.owner, cmdtab.object_name,
            cmdtab.migration_cmd, cmdtab.partitioned,
            cmdtab.parent_owner, cmdtab.parent_object_name LIMIT 1000;
          EXIT WHEN cmdtab.lineno.COUNT = 0;
          FOR i IN cmdtab.lineno.FIRST..cmdtab.lineno.LAST
          LOOP
            l_message_data := SYSTEM.tbl_mig_type
                                     (cmdtab.migration_cmd(i),
                                      cmdtab.lineno(i),
                                      cmdtab.owner(i),
                                      cmdtab.object_name(i),
                                      cmdtab.partitioned(i),
                                      cmdtab.parent_owner(i),
                                      cmdtab.parent_object_name(i));
            DBMS_AQ.enqueue (l_queue_name, l_enqopt, l_msgprop,
                             l_message_data, l_enq_msgid);
--DBMS_OUTPUT.PUT_LINE('Parent Message Enqueued, lineno = '||to_char(cmdtab.lineno(i)));
          END LOOP;
        END LOOP;
        CLOSE all_cmd_cur;
      else -- for a list of schemas
        OPEN mig_cmd_cur FOR l_string;
        LOOP
          cmdtab.lineno.DELETE;
          FETCH mig_cmd_cur BULK COLLECT INTO
            cmdtab.lineno, cmdtab.owner, cmdtab.object_name,
            cmdtab.migration_cmd, cmdtab.partitioned,
            cmdtab.parent_owner, cmdtab.parent_object_name LIMIT 1000;
          EXIT WHEN cmdtab.lineno.COUNT = 0;
          FOR i IN cmdtab.lineno.FIRST..cmdtab.lineno.LAST
          LOOP
            l_message_data := SYSTEM.tbl_mig_type
                                     (cmdtab.migration_cmd(i),
                                      cmdtab.lineno(i),
                                      cmdtab.owner(i),
                                      cmdtab.object_name(i),
                                      cmdtab.partitioned(i),
                                      cmdtab.parent_owner(i),
                                      cmdtab.parent_object_name(i));
            DBMS_AQ.enqueue (l_queue_name, l_enqopt, l_msgprop,
                             l_message_data, l_enq_msgid);
--DBMS_OUTPUT.PUT_LINE('Parent Message Enqueued, lineno = '||to_char(cmdtab.lineno(i)));
          END LOOP;
        END LOOP;
        CLOSE mig_cmd_cur;
      end if;
   end if;  -- for p_aqStat = 'Y'

    BEGIN
       l_deqopt.navigation := DBMS_AQ.FIRST_MESSAGE;
       l_deqopt.visibility := DBMS_AQ.IMMEDIATE;
       l_deqopt.wait       := 1;
    END;

    l_retVal := 0;
    while ( l_retVal = 0 )
    LOOP
        BEGIN
          DBMS_AQ.dequeue (
            queue_name =>          l_queue_name,
            dequeue_options =>     l_deqopt,
            message_properties =>  l_msgprop,
            payload =>             l_outmessage_data,
            msgid =>               l_deq_msgid
          );
          l_lineno             := l_outmessage_data.lineno;
          l_owner              := l_outmessage_data.owner;
          l_object_name        := l_outmessage_data.object_name;
          l_parent_owner       := l_outmessage_data.parent_owner;
          l_parent_object_name := l_outmessage_data.parent_object_name;
          l_partitioned        := l_outmessage_data.partitioned;
          l_mig_cmd            := l_outmessage_data.query;

          execute_cmd (l_lineno,
                       l_mig_cmd,
                       l_err_code,
                       l_status);
          if l_err_code = -54 then
            -- Re-try
            execute_cmd (l_lineno,
                         l_mig_cmd,
                         l_err_code,
                         l_status);
          end if;

          if l_status = 'SUCCESS' then
            -- Enqueue the childs i.e. all the objects with
            -- parent_lineno = lineno of the moved object
            process_line_child_cmds(l_lineno,
                                    l_status);
          end if;
          if l_status = 'ERROR' then
            x_return_status := 'ERROR';
          end if;

        EXCEPTION
          WHEN OTHERS THEN
           if p_exec_mode = 'P' then
            SELECT COUNT(1)
              INTO l_cnt
              FROM v$session
             WHERE module = 'TS_MIGRATE_SEQUENTIAL_OBJECTS'
               AND status <> 'KILLED';
            if l_cnt = 0 then
              if sqlcode = -25228 then
                update fnd_ts_mig_status set num_threads=num_threads-1, status=decode(num_threads,1,'SUCCESS',status),detail_message=decode(num_threads,1,'',detail_message) where item='EXE_MIG_CMDS';
                commit;
              end if;
              l_retVal := 1;
              EXIT;
            end if;
            DBMS_LOCK.SLEEP(300);
           else
             if sqlcode = -25228 then
                update fnd_ts_mig_status set num_threads=num_threads-1, status=decode(num_threads,1,'SUCCESS',status),detail_message=decode(num_threads,1,'',detail_message) where item='EXE_MIG_CMDS';
                commit;
             end if;
             l_retVal := 1;
             EXIT;
           end if;
        END;
    END LOOP;  -- end of while loop

  END migrate_objects;


  PROCEDURE disable_cons (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT  NOCOPY  VARCHAR2)
  IS
    cursor disable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'DISABLE_CONSTRAINT'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR disable_rec IN disable_cur
    LOOP
      query := disable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = disable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = disable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = disable_rec.lineno;
      END;
    END LOOP;
  END disable_cons;

  PROCEDURE disable_trigger (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2)
  IS
    cursor disable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'DISABLE_TRIGGER'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR disable_rec IN disable_cur
    LOOP
      query := disable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = disable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = disable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = disable_rec.lineno;
      END;
    END LOOP;
  END disable_trigger;

  PROCEDURE stop_queues (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2)
  IS
    cursor disable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'STOP_QUEUE'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR disable_rec IN disable_cur
    LOOP
      query := disable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = disable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = disable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = disable_rec.lineno;
      END;
    END LOOP;
  END stop_queues;

  PROCEDURE disable_policies (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT  NOCOPY  VARCHAR2)
  IS
    cursor disable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'DISABLE_POLICY'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR disable_rec IN disable_cur
    LOOP
      query := disable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = disable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = disable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = disable_rec.lineno;
      END;
    END LOOP;
  END disable_policies;

  PROCEDURE disable (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT  NOCOPY  VARCHAR2)
  IS
    cursor disable_all_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where object_type IN ('DISABLE_TRIGGER', 'DISABLE_CONSTRAINT', 'STOP_QUEUE', 'DISABLE_POLICY');

    TYPE disable_cur_type IS REF CURSOR;
    disable_cur              disable_cur_type;
    l_string                 VARCHAR2(4000);
    l_list                   VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
    l_lineno                 FND_TS_MIG_CMDS.LINENO%TYPE;
    l_migration_cmd          FND_TS_MIG_CMDS.MIGRATION_CMD%TYPE;
    query                    VARCHAR2(4000);

    l_schema_list            VARCHAR2(4000);
    l_old_index              NUMBER := 0;
    l_new_index              NUMBER := 0;

  BEGIN
    x_return_status := 'SUCCESS';

    if p_owner <> '%' then
    LOOP
      l_new_index := INSTR(p_owner, ',', l_old_index+1);
      if l_schema_list IS NULL AND l_new_index = 0 then
        l_schema_list := '('''||SUBSTR(p_owner, l_old_index+1)||''')';
      elsif l_schema_list IS NULL AND l_new_index <> 0 then
        l_schema_list := '('''||SUBSTR(p_owner, l_old_index+1, l_new_index-l_old_index-1)||'''';
      elsif l_new_index = 0 then
        l_schema_list := l_schema_list||','''||SUBSTR(p_owner, l_old_index+1)||''')';
      else
        l_schema_list := l_schema_list||','''||SUBSTR(p_owner, l_old_index+1, l_new_index-l_old_index-1)||'''';
      end if;
      EXIT WHEN l_new_index = 0;
      l_old_index := l_new_index;
    END LOOP;
    end if;
--dbms_output.put_line('schema list = '||l_schema_list);

   if p_owner = '%' then
    FOR disable_rec IN disable_all_cur
    LOOP
      query := disable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = disable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = disable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = disable_rec.lineno;
      END;
    END LOOP;
   else -- for a list of schemas
    l_string := 'select lineno, migration_cmd from fnd_ts_mig_cmds
                  where owner IN '||l_schema_list||'
                    and object_type IN (''DISABLE_TRIGGER'', ''DISABLE_CONSTRAINT'', ''STOP_QUEUE'', ''DISABLE_POLICY'')';
--dbms_output.put_line(l_string);
    OPEN disable_cur FOR l_string;
    LOOP
      FETCH disable_cur INTO l_lineno, l_migration_cmd;
      EXIT WHEN disable_cur%NOTFOUND;
      query := l_migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = l_lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = l_lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = l_lineno;
      END;
    END LOOP;
    CLOSE disable_cur;
   end if;
  END disable;

  PROCEDURE enable_cons (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2)
  IS
    cursor enable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'ENABLE_CONSTRAINT'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR enable_rec IN enable_cur
    LOOP
      query := enable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = enable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = enable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = enable_rec.lineno;
      END;
    END LOOP;
  END enable_cons;

  PROCEDURE enable_trigger (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2)
  IS
    cursor enable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'ENABLE_TRIGGER'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR enable_rec IN enable_cur
    LOOP
      query := enable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = enable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = enable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = enable_rec.lineno;
      END;
    END LOOP;
  END enable_trigger;

  PROCEDURE start_queues (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2)
  IS
    cursor enable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'START_QUEUE'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR enable_rec IN enable_cur
    LOOP
      query := enable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = enable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = enable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = enable_rec.lineno;
      END;
    END LOOP;
  END start_queues;

  PROCEDURE enable_policies (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2)
  IS
    cursor enable_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where owner = p_owner
       and object_type = 'ENABLE_POLICY'
     order by lineno asc;
    query                    VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
  BEGIN
    x_return_status := 'SUCCESS';

    FOR enable_rec IN enable_cur
    LOOP
      query := enable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = enable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = enable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = enable_rec.lineno;
      END;
    END LOOP;
  END enable_policies;

  PROCEDURE enable (
    p_owner                IN   VARCHAR2,
    x_return_status        OUT  NOCOPY  VARCHAR2)
  IS
    cursor enable_all_cur is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where object_type IN ('ENABLE_TRIGGER', 'ENABLE_CONSTRAINT', 'START_QUEUE', 'ENABLE_POLICY');

    cursor proc_csr IS
      select 1
      from   v$session
/*     where module in ('TS_MIGRATE_SEQUENTIAL_OBJECTS', 'TS_MIGRATE_PARALLEL_OBJECTS') */
      where  module in
     ('TS_MIGRATE_SEQUENTIAL_OBJECTS',
      'TS_MIGRATE_PARALLEL_OBJECTS',
      'TS_SET_DEFAULTS',
      'TS_DISABLE_CMDS',
      'TS_GENERATE_STATEMENTS',
      'TS_POSTMIGRATION_STEPS')
       and status <> 'KILLED';

    l_dummy                  INTEGER;

    cursor postmig_csr is
    select lineno,
           migration_cmd
      from fnd_ts_mig_cmds
     where object_type = 'POSTMIG';

    TYPE enable_cur_type IS REF CURSOR;
    enable_cur               enable_cur_type;
    l_string                 VARCHAR2(4000);
    l_list                   VARCHAR2(4000);
    l_err                    VARCHAR2(4000);
    l_lineno                 FND_TS_MIG_CMDS.LINENO%TYPE;
    l_migration_cmd          FND_TS_MIG_CMDS.MIGRATION_CMD%TYPE;
    query                    VARCHAR2(4000);
    l_schema_list            VARCHAR2(4000);
    l_old_index              NUMBER := 0;
    l_new_index              NUMBER := 0;

  BEGIN
   DBMS_APPLICATION_INFO.SET_MODULE('TS_POSTMIGRATION_STEPS', NULL);

   x_return_status := 'SUCCESS';

    if p_owner <> '%' then
    LOOP
      l_new_index := INSTR(p_owner, ',', l_old_index+1);
      if l_schema_list IS NULL AND l_new_index = 0 then
        l_schema_list := '('''||SUBSTR(p_owner, l_old_index+1)||''')';
      elsif l_schema_list IS NULL AND l_new_index <> 0 then
        l_schema_list := '('''||SUBSTR(p_owner, l_old_index+1, l_new_index-l_old_index-1)||'''';
      elsif l_new_index = 0 then
        l_schema_list := l_schema_list||','''||SUBSTR(p_owner, l_old_index+1)||''')';
      else
        l_schema_list := l_schema_list||','''||SUBSTR(p_owner, l_old_index+1, l_new_index-l_old_index-1)||'''';
      end if;
      EXIT WHEN l_new_index = 0;
      l_old_index := l_new_index;
    END LOOP;
    end if;
--dbms_output.put_line('schema list = '||l_schema_list);

   if p_owner = '%' then
    FOR enable_rec IN enable_all_cur
    LOOP
      query := enable_rec.migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = enable_rec.lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = enable_rec.lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = enable_rec.lineno;
      END;
    END LOOP;
   else -- for a list of schemas
    l_string := 'select lineno, migration_cmd from fnd_ts_mig_cmds
                  where owner IN '||l_schema_list||'
                    and object_type IN (''ENABLE_TRIGGER'', ''ENABLE_CONSTRAINT'', ''START_QUEUE'', ''ENABLE_POLICY'', ''POSTMIG'')';
    OPEN enable_cur FOR l_string;
    LOOP
      FETCH enable_cur INTO l_lineno, l_migration_cmd;
      EXIT WHEN enable_cur%NOTFOUND;
      query := l_migration_cmd;
      BEGIN
        UPDATE fnd_ts_mig_cmds
           SET start_date = sysdate,
               end_date = null
         WHERE lineno = l_lineno;

        EXECUTE IMMEDIATE query;

        UPDATE fnd_ts_mig_cmds
           SET migration_status = 'SUCCESS',
               end_date = sysdate,
               last_update_date = sysdate,
               error_text = NULL
         WHERE lineno = l_lineno;
      EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = l_lineno;
      END;
    END LOOP;
    CLOSE enable_cur;
   end if;

   OPEN proc_csr;
   FETCH proc_csr INTO l_dummy;
   if proc_csr%NOTFOUND then
     FOR postmig_rec IN  postmig_csr
     LOOP
       BEGIN
         UPDATE fnd_ts_mig_cmds
            SET start_date = sysdate,
                end_date = null
          WHERE lineno = postmig_rec.lineno;

         EXECUTE IMMEDIATE postmig_rec.migration_cmd;

         UPDATE fnd_ts_mig_cmds
            SET migration_status = 'SUCCESS',
                end_date = sysdate,
                last_update_date = sysdate,
                error_text = NULL
          WHERE lineno = postmig_rec.lineno;
       EXCEPTION
        WHEN OTHERS THEN
          l_err := sqlerrm(sqlcode);
          x_return_status := 'ERROR';
          UPDATE fnd_ts_mig_cmds
             SET migration_status = 'ERROR',
                 end_date = sysdate,
                 error_text = l_err,
                 last_update_date = sysdate
           WHERE lineno = postmig_rec.lineno;
       END;
     END LOOP;
   end if;
   CLOSE proc_csr;
  END enable;

PROCEDURE migtsobj IS
  CURSOR c1 IS
    select   *
    from     fnd_ts_mig_cmds
    where    migration_status <> 'SUCCESS'
    and      (object_name like 'FND_TS_MIG_CMDS%'
    or       object_name like 'FND_TS_PROD_INST%'
    or       object_name like 'FND_TS_SIZING%')
    order by lineno;
  TYPE cmd_tab_type IS TABLE OF FND_TS_MIG_CMDS%ROWTYPE;
  cmd_tab    cmd_tab_type;
  i          INTEGER := 0;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO cmd_tab(i);
    EXIT WHEN c1%NOTFOUND;
    i := i + 1;
  END LOOP;
  CLOSE c1;

  FOR j IN cmd_tab.FIRST..cmd_tab.LAST
  LOOP
    BEGIN
      cmd_tab(j).start_date := sysdate;
      EXECUTE IMMEDIATE cmd_tab(j).migration_cmd;
      cmd_tab(j).migration_status := 'SUCCESS';
      cmd_tab(j).end_date := sysdate;
      cmd_tab(j).last_update_date := sysdate;
      cmd_tab(j).error_text := null;
    EXCEPTION WHEN OTHERS THEN
      cmd_tab(j).migration_status := 'ERROR';
      cmd_tab(j).end_date := sysdate;
      cmd_tab(j).last_update_date := sysdate;
      cmd_tab(j).error_text := sqlerrm(sqlcode);
    END;
  END LOOP;

  FOR j IN cmd_tab.FIRST..cmd_tab.LAST
  LOOP
      UPDATE fnd_ts_mig_cmds
         SET migration_status = cmd_tab(j).migration_status,
             start_date = cmd_tab(j).start_date,
             end_date = cmd_tab(j).end_date,
             last_update_date = cmd_tab(j).last_update_date,
             error_text = cmd_tab(j).error_text
       WHERE lineno = cmd_tab(i).lineno;
  END LOOP;
END migtsobj;

END FND_EXEC_MIG_CMDS;

/
