--------------------------------------------------------
--  DDL for Package Body IBC_DEBUG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_DEBUG_PVT" AS
  /* $Header: ibcdbugb.pls 115.3 2003/08/14 18:35:38 enunez ship $ */

  TYPE t_table_vc100 IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  g_stack_level       NUMBER := 0;
  g_stack_processes   t_table_vc100;
  g_debug_type        VARCHAR2(30);
  g_debug_output_dir  VARCHAR2(80);
  g_output_file_ptr   utl_file.file_type;

  PROCEDURE put_message(p_message IN VARCHAR2)
  IS
  BEGIN
    IF g_debug_type = 'PIPE' THEN
      DBMS_PIPE.pack_message(p_message);
    ELSIF g_debug_type = 'FILE' THEN
      utl_file.put_line(g_output_file_ptr, p_message);
    END IF;
  END put_message;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Init_Debug
  -- DESCRIPTION: Initialize debugging mode depending upon profile
  --              settings.
  -- --------------------------------------------------------------------
  PROCEDURE Init_Debug IS
  BEGIN
    g_stack_level := 0;
    g_stack_processes.delete;
    FND_PROFILE.get('IBC_DEBUG_TYPE',g_debug_type);
    FND_PROFILE.get('IBC_DEBUG_OUTPUT_DIR',g_debug_output_dir);
    IF g_debug_type = 'FILE' THEN
      g_output_file_ptr := utl_file.fopen(g_debug_output_dir, 'IBC_' || FND_GLOBAL.USER_NAME || '.log', 'a');
      put_message('');
      put_message('<DEBUG  TIMESTAMP="' || TO_CHAR(SYSDATE, 'YYYYMMDD HH:MI:SS') || '">');
    END IF;
  END Init_Debug;

  -- --------------------------------------------------------------------
  -- FUNCTION: Debug_Enabled
  -- DESCRIPTION: Returns TRUE if debug is enabled for current user
  --              based upon profile values, FALSE otherwise.
  -- --------------------------------------------------------------------
  FUNCTION Debug_Enabled
  RETURN BOOLEAN
  IS
    l_debug_option   VARCHAR2(10);
  BEGIN
    FND_PROFILE.get('IBC_DEBUG', l_debug_option);
    RETURN l_debug_option = 'Y';
  END Debug_Enabled;

  PROCEDURE debug_flush IS
    l_pipe_result NUMBER;
  BEGIN
    IF g_debug_type = 'PIPE' THEN
      l_pipe_result := DBMS_PIPE.send_message(pipename    => 'IBC_DEBUG:' || FND_GLOBAL.user_name,
                                              maxpipesize => 8192);
    ELSIF g_debug_type = 'FILE' THEN
      utl_file.fflush(g_output_file_ptr);
    END IF;
  END debug_flush;

  PROCEDURE debug_close IS
  BEGIN
    IF g_debug_type = 'FILE' THEN
      put_message('</DEBUG>');
      put_message('');
      utl_file.fclose(g_output_file_ptr);
    END IF;
  END debug_close;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Start_Process
  -- DESCRIPTION: Marks the begin point of a procedure/function,
  --              This is used to keep a stack of calls.
  --              This procedure should be called at the begining of a
  --              procedure or function.
  -- --------------------------------------------------------------------
  PROCEDURE Start_Process(p_proc_type IN VARCHAR2,
                          p_proc_name IN VARCHAR2,
                          p_parms     IN VARCHAR2)
  IS
    l_pipe_result NUMBER;
    l_parms       VARCHAR2(32767);
    l_pos_lf      NUMBER;
    l_count       NUMBER;
  BEGIN

    IF Debug_Enabled THEN
      IF g_stack_level = 0 THEN
        Init_Debug;
      END IF;
      g_stack_level := g_stack_level + 1;
      g_stack_processes(g_stack_level) := p_proc_name;

      put_message(LPAD(' ', g_stack_level * 3, ' ') ||
                       '<CALL TYPE="' || p_proc_type || '" NAME="' || p_proc_name ||
                       '" TIMESTAMP="' ||
                       TO_CHAR(SYSDATE, 'YYYYMMDD HH:MI:SS') ||
                       '">' );
      IF p_parms IS NOT NULL THEN
        l_parms := p_parms;
        l_count := 0;
        LOOP
          l_pos_lf := INSTR(l_parms, FND_GLOBAL.local_chr(13));
          IF l_pos_lf > 0 THEN
            IF l_count = 0 THEN
              put_message(LPAD(' ', (g_stack_level + 1) * 3, ' ') ||
                          SUBSTR(l_parms, 1, l_pos_lf - 1));
            ELSE
              put_message(LPAD(' ', (g_stack_level + 2) * 3, ' ') ||
                          SUBSTR(l_parms, 1, l_pos_lf - 1));
            END IF;
            l_parms := SUBSTR(l_parms, l_pos_lf + 1);
          ELSE
            put_message(LPAD(' ', (g_stack_level + 1) * 3, ' ') || l_parms);
          END IF;
          EXIT WHEN l_pos_lf = 0;
          l_count := l_count + 1;
        END LOOP;
      END IF;
      debug_flush;
    END IF;

  END;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Debug_Message
  -- DESCRIPTION: Outputs p_message in case debug is enabled.
  -- --------------------------------------------------------------------
  PROCEDURE Debug_Message(p_message IN VARCHAR2) IS
    l_pipe_result     NUMBER;
  BEGIN
    IF Debug_Enabled THEN
      put_message(LPAD(' ', (g_stack_level + 1) * 3, ' ') ||
                  p_message);
      debug_flush;
    END IF;
  END Debug_Message;

  -- --------------------------------------------------------------------
  -- FUNCTION: Make_List
  -- DESCRIPTION: Makes a list of values (enclosed in [] and separated
  --              commas) from a JTF table being passed.
  --              Useful when debugging the content of JTF tables being
  --              passed as parameters.
  --              Returns the list.
  -- --------------------------------------------------------------------
  FUNCTION Make_List(p_values IN JTF_NUMBER_TABLE)
  RETURN VARCHAR2
  IS
    l_result VARCHAR2(32767);
  BEGIN
    l_result := NULL;
    IF p_values IS NOT NULL THEN
      FOR I IN 1..p_values.COUNT LOOP
        IF l_result IS NULL THEN
          l_result := '[' || p_values(I) || ']';
        ELSE
          l_result := l_result || ',[' || p_values(I) || ']';
        END IF;
      END LOOP;
    END IF;
    RETURN l_result;
  END Make_List;

  -- Overloaded
  FUNCTION Make_List(p_values IN JTF_VARCHAR2_TABLE_100)
  RETURN VARCHAR2
  IS
    l_result VARCHAR2(32767);
  BEGIN
    l_result := NULL;
    IF p_values IS NOT NULL THEN
      FOR I IN 1..p_values.COUNT LOOP
        IF l_result IS NULL THEN
          l_result := '[' || p_values(I) || ']';
        ELSE
          l_result := l_result || ',[' || p_values(I) || ']';
        END IF;
      END LOOP;
    END IF;
    RETURN l_result;
  END Make_List;

  -- Overloaded
  FUNCTION Make_List(p_values IN JTF_VARCHAR2_TABLE_300)
  RETURN VARCHAR2
  IS
    l_result VARCHAR2(32767);
  BEGIN
    l_result := NULL;
    IF p_values IS NOT NULL THEN
      FOR I IN 1..p_values.COUNT LOOP
        IF l_result IS NULL THEN
          l_result := '[' || p_values(I) || ']';
        ELSE
          l_result := l_result || ',[' || p_values(I) || ']';
        END IF;
      END LOOP;
    END IF;
    RETURN l_result;
  END Make_List;

  -- Overloaded
  FUNCTION Make_List(p_values IN JTF_VARCHAR2_TABLE_4000)
  RETURN VARCHAR2
  IS
    l_result VARCHAR2(32767);
  BEGIN
    l_result := NULL;
    IF p_values IS NOT NULL THEN
      FOR I IN 1..p_values.COUNT LOOP
        IF l_result IS NULL THEN
          l_result := '[' || p_values(I) || ']';
        ELSE
          l_result := l_result || ',[' || p_values(I) || ']';
        END IF;
      END LOOP;
    END IF;
    RETURN l_result;
  END Make_List;

  -- for JTF_VARCHAR2_TABLE_32767
  FUNCTION Make_List_VC32767(p_values IN JTF_VARCHAR2_TABLE_32767)
  RETURN VARCHAR2
  IS
    l_result VARCHAR2(32767);
  BEGIN
    l_result := NULL;
    IF p_values IS NOT NULL THEN
      FOR I IN 1..p_values.COUNT LOOP
        IF LENGTH(p_values(I)) > 4000 THEN
          IF l_result IS NULL THEN
            l_result := '[' || SUBSTR(p_values(I), 1, 25) || '...' || ']';
          ELSE
            l_result := l_result || ',[' || SUBSTR(p_values(I), 1, 25) || '...' || ']';
          END IF;
        ELSE
          IF l_result IS NULL THEN
            l_result := '[' || p_values(I) || ']';
          ELSE
            l_result := l_result || ',[' || p_values(I) || ']';
          END IF;
        END IF;

      END LOOP;
    END IF;
    RETURN l_result;
  END Make_List_VC32767;

  -- --------------------------------------------------------------------
  -- FUNCTION: Make_Parameter_List
  -- DESCRIPTION: Creates a parameter list (with tags for each parameter)
  --              Useful when calling Start_PRocess for "parms" parameter
  -- --------------------------------------------------------------------
  FUNCTION Make_Parameter_List(p_tag IN VARCHAR2,
                               p_parms IN JTF_VARCHAR2_TABLE_4000)
  RETURN VARCHAR2
  IS
    l_result     VARCHAR2(32000);
  BEGIN
    IF Debug_Enabled THEN
      IF p_parms IS NOT NULL THEN
        l_result := '<' || p_tag || '>';
        FOR I IN 1..p_parms.COUNT LOOP
          IF I MOD 2 <> 0 THEN
            l_result := l_result || FND_GLOBAL.local_chr(13) ||
                        '<' || p_parms(I) || '>';
          ELSE
            l_result := l_result || p_parms(I) ||
                        '</' || p_parms(I-1) || '>';
          END IF;
        END LOOP;
        l_result := l_result || FND_GLOBAL.local_chr(13) || '</' || p_tag || '>';
      END IF;
    END IF;
    RETURN l_result;
  END;

  FUNCTION Make_Parameter_List(p_tag IN VARCHAR2,
                               p_parms IN JTF_VARCHAR2_TABLE_32767)
  RETURN VARCHAR2
  IS
    l_result     VARCHAR2(32767);
  BEGIN
    IF Debug_Enabled THEN
      IF p_parms IS NOT NULL THEN
        l_result := '<' || p_tag || '>';
        FOR I IN 1..p_parms.COUNT LOOP
          IF I MOD 2 <> 0 THEN
            l_result := l_result || FND_GLOBAL.local_chr(13) ||
                        '<' || p_parms(I) || '>';
          ELSE
            l_result := l_result || p_parms(I) ||
                        '</' || p_parms(I-1) || '>';
          END IF;
        END LOOP;
        l_result := l_result || FND_GLOBAL.local_chr(13) || '</' || p_tag || '>';
      END IF;
    END IF;
    RETURN l_result;
  END;

  -- --------------------------------------------------------------------
  -- PROCEDURE: End_Process
  -- DESCRIPTION: Signals the end of a process (PROCEDURE or FUNCTION)
  --              This procedure should be called at the end of a
  --              procedure or function.
  -- --------------------------------------------------------------------
  PROCEDURE End_Process(p_output_list  IN VARCHAR2 := NULL)
  IS
    l_current_level    NUMBER;
    l_output_list      VARCHAR2(20000);
    l_pos_lf           NUMBER;
    l_count            NUMBER;
  BEGIN
    IF Debug_Enabled AND g_stack_level > 0 THEN
      l_current_level := g_stack_processes.COUNT;

      IF p_output_list IS NOT NULL THEN
        l_output_list := p_output_list;
        l_count := 0;
        LOOP
          l_pos_lf := INSTR(l_output_list, FND_GLOBAL.local_chr(13));
          IF l_pos_lf > 0 THEN
            IF l_count = 0 THEN
              put_message(LPAD(' ', (g_stack_level + 1) * 3, ' ') ||
                          SUBSTR(l_output_list, 1, l_pos_lf - 1));
            ELSE
              put_message(LPAD(' ', (g_stack_level + 2) * 3, ' ') ||
                          SUBSTR(l_output_list, 1, l_pos_lf - 1));
            END IF;
            l_output_list := SUBSTR(l_output_list, l_pos_lf + 1);
          ELSE
            put_message(LPAD(' ', (g_stack_level + 1) * 3, ' ') ||l_output_list);
          END IF;
          EXIT WHEN l_pos_lf = 0;
          l_count := l_count + 1;
        END LOOP;
      END IF;

      put_message(LPAD(' ', (g_stack_level + 1) * 3, ' ') ||
                  '<END TIMESTAMP="' ||
                  TO_CHAR(SYSDATE, 'YYYYMMDD HH:MI:SS') ||
                  '"/>');
      put_message(LPAD(' ', g_stack_level * 3, ' ') ||
                  '</CALL>');
      debug_flush;
      g_stack_processes.delete(l_current_level);
      g_stack_level := g_stack_level - 1;
      IF g_stack_level = 0 THEN
        debug_close;
      END IF;
    END IF;
  END;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Terminate_Stack
  -- DESCRIPTION: Flushes all Processes in the stack
  --              Useful when catching exceptions, and finishing the
  --              debugging.
  -- --------------------------------------------------------------------
  PROCEDURE Terminate_Stack
  IS
    l_current_level NUMBER;
  BEGIN
    IF Debug_Enabled THEN
      l_current_level := g_stack_processes.COUNT;
      FOR I IN REVERSE l_current_level..1 LOOP
        put_message('<STATUS>TERMINATED</STATUS>');
        put_message('</' || g_stack_processes(I) || '>');
        g_stack_processes.delete(I);
        g_stack_level := g_stack_level - 1;
      END LOOP;
      debug_flush;
      debug_close;
    END IF;
  END Terminate_Stack;

END IBC_DEBUG_PVT;

/
