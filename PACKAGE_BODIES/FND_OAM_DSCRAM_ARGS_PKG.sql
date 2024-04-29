--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_ARGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_ARGS_PKG" as
/* $Header: AFOAMDSARGB.pls 120.7 2006/01/17 13:55 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants/Types
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_ARGS_PKG.';

   -- exceptions used by INITIALZE_ARG/GET_CANONICAL_ARG_VALUE to facilitate common
   -- cleanup actions
   INIT_FAILED                  EXCEPTION;
   GET_FAILED                   EXCEPTION;

   --local name for common exception when dealing with binding
   BIND_DOES_NOT_EXIST  EXCEPTION;
   PRAGMA EXCEPTION_INIT(BIND_DOES_NOT_EXIST, -1006);

   --type used for bulk selects of the canonical value field
   TYPE long_varchar2_table IS TABLE OF VARCHAR2(4000);

   ----------------------------------------
   -- Public/Private Body Methods
   ----------------------------------------

   -- Public
   FUNCTION IS_READABLE(p_arg   IN arg)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_arg.permissions IN (FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ,
                                   FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE);
   END;

   -- Public
   FUNCTION IS_WRITABLE(p_arg   IN arg)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_arg.permissions IN (FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_WRITE,
                                   FND_OAM_DSCRAM_UTILS_PKG.G_PERMISSION_READ_WRITE);
   END;

   -- Private helper to make sure a canonical value is proper for an arg,
   -- validation failures are returned as exceptions
   PROCEDURE VALIDATE_CANONICAL_VALUE(p_arg             IN arg,
                                      p_canonical_value IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_CANONICAL_VALUE';

      l_num             NUMBER;
      l_date            DATE;
      l_rowid           ROWID;
   BEGIN
      CASE p_arg.datatype
         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2 THEN
            null; --no validation
         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER THEN
            l_num := FND_NUMBER.CANONICAL_TO_NUMBER(p_canonical_value);
         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE THEN
            l_date := FND_DATE.CANONICAL_TO_DATE(p_canonical_value);
         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID THEN
            --for some reason, this is refusing to throw an exception on invalid values
            l_rowid := CHARTOROWID(p_canonical_value);
         ELSE
            --unknown datatype
            fnd_oam_debug.log(6, l_ctxt, 'ARG ID('||p_arg.arg_id||'), unknown datatype: '||p_arg.datatype);
            RAISE NO_DATA_FOUND;
      END CASE;
   END;

   -- Private helper to set the canonical value and update related state.
   -- Errors are returned as exceptions.
   PROCEDURE SET_STATE_ARG_VALUE(p_arg                  IN OUT NOCOPY arg,
                                 p_canonical_value      IN VARCHAR2,
                                 p_rowid_lbound         IN ROWID DEFAULT NULL,
                                 p_rowid_ubound         IN ROWID DEFAULT NULL)
   IS
   BEGIN
      VALIDATE_CANONICAL_VALUE(p_arg,
                               p_canonical_value);
      p_arg.canonical_value := p_canonical_value;
      p_arg.rowid_lbound := p_rowid_lbound;
      p_arg.rowid_ubound := p_rowid_ubound;
      p_arg.valid_value_flag := FND_API.G_TRUE;
   END;

   -- Private constructor helper for add_arg_to_context and add_arg_to_list to make a new physical arg entity
   FUNCTION INTERNAL_CREATE_ARG(p_arg_id                        IN NUMBER,
                                p_arg_name                      IN VARCHAR2,
                                p_initialized_success_flag      IN VARCHAR2,
                                p_allow_override_source_flag    IN VARCHAR2,
                                p_binding_enabled_flag          IN VARCHAR2,
                                p_permissions                   IN VARCHAR2,
                                p_write_policy                  IN VARCHAR2,
                                p_datatype                      IN VARCHAR2,
                                p_valid_value_flag              IN VARCHAR2,
                                p_canonical_value               IN VARCHAR2)
      RETURN arg
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_CREATE_ARG';

      l_initialized             BOOLEAN := FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_initialized_success_flag);
      l_allow_override_source   BOOLEAN := FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_allow_override_source_flag);
      l_binding_enabled         BOOLEAN := FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_binding_enabled_flag);
      l_valid_value             BOOLEAN := FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_valid_value_flag);

      l_arg             arg;
      l_ignore          VARCHAR2(2048);
   BEGIN
      --init the new entry
      l_arg.arg_id                      := p_arg_id;
      l_arg.arg_name                    := p_arg_name;
      l_arg.init_locally                := FALSE;
      l_arg.initialized_success_flag    := p_initialized_success_flag;
      l_arg.allow_override_source       := l_allow_override_source;
      l_arg.binding_enabled             := l_binding_enabled;
      l_arg.permissions                 := p_permissions;
      l_arg.write_policy                := p_write_policy;
      l_arg.datatype                    := p_datatype;
      l_arg.is_constant                 := FALSE; --default here, set for real in init
      l_arg.source_cursor_id            := NULL;
      l_arg.source_sql_bind_rowids      := FALSE; --default here, set for real in init
      l_arg.source_state_key            := NULL;
      l_arg.source_use_exec_cursor      := FALSE; --default here, set in init

      --use separate setter for the value
      l_arg.valid_value_flag := p_valid_value_flag;
      IF l_initialized AND l_valid_value THEN
         SET_STATE_ARG_VALUE(l_arg,
                             p_canonical_value);
      END IF;

      --return the completed arg
      RETURN l_arg;

      --let exceptions pass to parent
   END;

   -- Helper to FETCH_CONTEXT-like procedures to create an arg based on its attributes and
   -- add it to a supplied arg context.
   FUNCTION ADD_ARG_TO_CONTEXT(px_arg_ctxt                      IN OUT NOCOPY arg_context,
                               p_arg_id                         IN NUMBER,
                               p_arg_name                       IN VARCHAR2,
                               p_initialized_success_flag       IN VARCHAR2,
                               p_allow_override_source_flag     IN VARCHAR2,
                               p_binding_enabled_flag           IN VARCHAR2,
                               p_permissions                    IN VARCHAR2,
                               p_write_policy                   IN VARCHAR2,
                               p_datatype                       IN VARCHAR2,
                               p_valid_value_flag               IN VARCHAR2,
                               p_canonical_value                IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_ARG_TO_CONTEXT';

      l_arg             arg;
   BEGIN
      l_arg := INTERNAL_CREATE_ARG(p_arg_id,
                                   p_arg_name,
                                   p_initialized_success_flag,
                                   p_allow_override_source_flag,
                                   p_binding_enabled_flag,
                                   p_permissions,
                                   p_write_policy,
                                   p_datatype,
                                   p_valid_value_flag,
                                   p_canonical_value);

      --add the arg to the context
      px_arg_ctxt(p_arg_name) := l_arg;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Argument ID: ('||p_arg_id||'), Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Private: similar to other add_arg_to_list but in this case we've already created an arg object
   -- and just want it appended.
   FUNCTION ADD_ARG_TO_LIST(px_arg_list         IN OUT NOCOPY arg_list,
                            p_arg               IN arg)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_ARG_TO_LIST';
   BEGIN
      --add the arg to the list
      px_arg_list.EXTEND;
      px_arg_list(px_arg_list.COUNT) := p_arg;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Argument ID: ('||p_arg.arg_id||'), Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Private helper to get_canonical_value to fetch the value for a given state key
   PROCEDURE GET_CANONICAL_VALUE_FOR_KEY(px_arg                 IN OUT NOCOPY arg,
                                         p_state_key            IN VARCHAR2,
                                         p_using_splitting      IN BOOLEAN,
                                         p_rowid_lbound         IN ROWID,
                                         p_rowid_ubound         IN ROWID,
                                         x_canonical_value      OUT NOCOPY VARCHAR2,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_CANONICAL_VALUE_FOR_KEY';

      l_canonical_value VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --do a big case statement on the state key to fetch the value
      CASE p_state_key
         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_RUN_ID THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_ID);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_RUN_MODE THEN
            l_canonical_value := FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_MODE;

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BUNDLE_ID THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_BUNDLES_PKG.GET_BUNDLE_ID);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BUNDLE_WORKERS_ALLOWED THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKERS_ALLOWED);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BUNDLE_BATCH_SIZE THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_BUNDLES_PKG.GET_BATCH_SIZE);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_WORKER_ID THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKER_ID);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_TASK_ID THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_TASKS_PKG.GET_TASK_ID);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_ID THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_UNITS_PKG.GET_UNIT_ID);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_USING_SPLITTING THEN
            l_canonical_value := FND_OAM_DSCRAM_UTILS_PKG.BOOLEAN_TO_FLAG(p_using_splitting);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_LBOUND THEN
            l_canonical_value := ROWIDTOCHAR(p_rowid_lbound);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ROWID_UBOUND THEN
            l_canonical_value := ROWIDTOCHAR(p_rowid_ubound);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_OWNER THEN
            l_canonical_value := FND_OAM_DSCRAM_UNITS_PKG.GET_UNIT_OBJECT_OWNER;

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_OBJECT_NAME THEN
            l_canonical_value := FND_OAM_DSCRAM_UNITS_PKG.GET_UNIT_OBJECT_NAME;

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_WORKERS_ALLOWED THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_UNITS_PKG.GET_WORKERS_ALLOWED);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_UNIT_BATCH_SIZE THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(FND_OAM_DSCRAM_UNITS_PKG.GET_BATCH_SIZE);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_DML_ID THEN
            l_canonical_value := FND_OAM_DSCRAM_DMLS_PKG.GET_CURRENT_DML_ID;

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_PLSQL_ID THEN
            l_canonical_value := FND_OAM_DSCRAM_PLSQLS_PKG.GET_CURRENT_PLSQL_ID;

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_ARGUMENT_ID THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(px_arg.arg_id);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_WORKERS_ALLOWED THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(NVL(FND_OAM_DSCRAM_UNITS_PKG.GET_WORKERS_ALLOWED,
                                                                    FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKERS_ALLOWED));

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_KEY_BATCH_SIZE THEN
            l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(NVL(FND_OAM_DSCRAM_UNITS_PKG.GET_BATCH_SIZE,
                                                                    FND_OAM_DSCRAM_BUNDLES_PKG.GET_BATCH_SIZE));
         ELSE
            x_return_msg := 'ARG ID('||px_arg.arg_id||'), invalid state key: '||p_state_key;
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END CASE;

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_canonical_value := l_canonical_value;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- since we involve no sql, this should only happen when there's missing state
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_MISSING_STATE;
         fnd_oam_debug.log(1, l_ctxt, 'Arg ID('||px_arg.arg_id||'), threw missing state.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Arg ID('||px_arg.arg_id||') Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
   END;

   -- Private helper to get_canonical_value to fetch the value from the execution cursor.  Since binds
   -- use the arg's name field, we implicitly use this name to fetch the value.
   PROCEDURE GET_CANONICAL_VALUE_FROM_CUR(px_arg                        IN OUT NOCOPY arg,
                                          p_execution_cursor_id         IN INTEGER,
                                          x_canonical_value             OUT NOCOPY VARCHAR2,
                                          x_return_status               OUT NOCOPY VARCHAR2,
                                          x_return_msg                  OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_CANONICAL_VALUE_FROM_CUR';

      l_canonical_value VARCHAR2(4000);

      l_bindvar_name            VARCHAR2(120)   := ':'||px_arg.arg_name;

      l_number                  NUMBER          := NULL;
      l_date                    DATE            := NULL;
      l_bool                    BOOLEAN         := NULL;
      l_rowid                   ROWID           := NULL;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --fetch the value into the properly typed local variable then then
      --convert it into the canonical
      CASE px_arg.datatype
         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2 THEN
            DBMS_SQL.VARIABLE_VALUE(p_execution_cursor_id,
                                    l_bindvar_name,
                                    x_canonical_value);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER THEN
            DBMS_SQL.VARIABLE_VALUE(p_execution_cursor_id,
                                    l_bindvar_name,
                                    l_number);
            x_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(l_number);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE THEN
            DBMS_SQL.VARIABLE_VALUE(p_execution_cursor_id,
                                    l_bindvar_name,
                                    l_date);
            x_canonical_value := FND_DATE.DATE_TO_CANONICAL(l_date);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID THEN
            DBMS_SQL.VARIABLE_VALUE_ROWID(p_execution_cursor_id,
                                          l_bindvar_name,
                                          l_rowid);
            x_canonical_value := ROWIDTOCHAR(l_rowid);
         ELSE
            x_return_msg := 'Arg ('||px_arg.arg_id||') has unknown datatype:'||px_arg.datatype;
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END CASE;

      fnd_oam_debug.log(1, l_ctxt, 'Found canonical value: '||x_canonical_value);

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN BIND_DOES_NOT_EXIST THEN
         --catch a common error and provide better feedback.
         fnd_oam_debug.log(6, l_ctxt, 'Arg ID('||px_arg.arg_id||'), Bindvar('||l_bindvar_name||') does not exist');
         x_return_msg := 'Variable Value failure: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Arg ID('||px_arg.arg_id||') Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
   END;

   --Private, utility procedure for GET_CANONICAL_ARG_VALUE to execute a source sql using dynamic sql or the source_cursor and return the value as
   --its canonical string representation.  Must occur after the derived state/rowids are set by INITIALIZE_ARG.
   PROCEDURE GET_CANONICAL_VALUE_FOR_SQL(px_arg                 IN OUT NOCOPY arg,
                                         p_final_sql_stmt       IN VARCHAR2 DEFAULT NULL,
                                         p_rowid_lbound         IN ROWID,
                                         p_rowid_ubound         IN ROWID,
                                         x_canonical_value      OUT NOCOPY VARCHAR2,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_CANONICAL_VALUE_FOR_SQL';

      l_rows_fetched    NUMBER;
      l_canonical_value VARCHAR2(4000);

      missing_binds     EXCEPTION;
      PRAGMA EXCEPTION_INIT(missing_binds, -1008);

      l_number          NUMBER;
      l_date            DATE;
      l_rowid           ROWID;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --fetch the canonical value differently based on what SQL is available to us
      IF p_final_sql_stmt IS NOT NULL THEN

         --we don't support binding the rowids when using a manual sql stmt since it won't bind properly
         --with user specified binds.  Statements using binds should use the source_cursor.
         IF px_arg.source_sql_bind_rowids THEN
            x_return_msg := 'Cannot have a non-null final sql stmt when binding rowids.  This should not happen.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;

         --different statements depending on datatype
         CASE px_arg.datatype
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2 THEN
               EXECUTE IMMEDIATE p_final_sql_stmt INTO l_canonical_value;
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER THEN
               EXECUTE IMMEDIATE p_final_sql_stmt INTO l_number;
               l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(l_number);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE THEN
               EXECUTE IMMEDIATE p_final_sql_stmt INTO l_date;
               l_canonical_value := FND_DATE.DATE_TO_CANONICAL(l_date);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID THEN
               EXECUTE IMMEDIATE p_final_sql_stmt INTO l_rowid;
               l_canonical_value := ROWIDTOCHAR(l_rowid);
            ELSE
               x_return_msg := 'Arg ID('||px_arg.arg_id||'), invalid datatype: '||px_arg.datatype;
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
         END CASE;
      ELSIF px_arg.source_cursor_id IS NOT NULL THEN
         IF NOT DBMS_SQL.IS_OPEN(px_arg.source_cursor_id) THEN
            x_return_msg := 'Arg ID ('||px_arg.arg_id||'), source cursor is already closed. This should not happen.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;

         --bind if we have to
         IF px_arg.source_sql_bind_rowids THEN
            fnd_oam_debug.log(1, l_ctxt, 'Binding Rowids');
            DBMS_SQL.BIND_VARIABLE(px_arg.source_cursor_id,
                                   FND_OAM_DSCRAM_UTILS_PKG.G_ARG_ROWID_LBOUND_NAME,
                                   p_rowid_lbound);
            DBMS_SQL.BIND_VARIABLE(px_arg.source_cursor_id,
                                   FND_OAM_DSCRAM_UTILS_PKG.G_ARG_ROWID_UBOUND_NAME,
                                   p_rowid_ubound);
         END IF;

         --now execute and fetch
         fnd_oam_debug.log(1, l_ctxt, 'Executing cursor...');
         l_rows_fetched := DBMS_SQL.EXECUTE_AND_FETCH(px_arg.source_cursor_id);
         fnd_oam_debug.log(1, l_ctxt, '...Done');

         IF l_rows_fetched <> 1 THEN
            x_return_msg := 'Fetched '||l_rows_fetched||' rows.  Args must return 1 row.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;

         --now depending on the datatype, set our local canonical value
         CASE px_arg.datatype
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2 THEN
               DBMS_SQL.COLUMN_VALUE(px_arg.source_cursor_id,
                                     1,
                                     l_canonical_value);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER THEN
               DBMS_SQL.COLUMN_VALUE(px_arg.source_cursor_id,
                                     1,
                                     l_number);
               l_canonical_value := FND_NUMBER.NUMBER_TO_CANONICAL(l_number);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE THEN
               DBMS_SQL.COLUMN_VALUE(px_arg.source_cursor_id,
                                     1,
                                     l_date);
               l_canonical_value := FND_DATE.DATE_TO_CANONICAL(l_date);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID THEN
               DBMS_SQL.COLUMN_VALUE_ROWID(px_arg.source_cursor_id,
                                           1,
                                           l_rowid);
               l_canonical_value := ROWIDTOCHAR(l_rowid);
            ELSE
               x_return_msg := 'Arg ID('||px_arg.arg_id||'), invalid datatype: '||px_arg.datatype;
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
         END CASE;
      ELSE
         x_return_msg := 'Source Cursor is NULL and Source Final SQL Stmt is NULL, no SQL to fetch.';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_canonical_value := l_canonical_value;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN missing_binds THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_MISSING_BINDS;
         fnd_oam_debug.log(1, l_ctxt, 'Arg ID('||px_arg.arg_id||'), threw missing binds.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Arg ID('||px_arg.arg_id||') Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
   END;

   --Private, helper to INITIALIZE_ARG to sync up the arg's state with values INIT found.  Primary responsibilities
   --include the derived arg state and the source_cursor-related fields.
   PROCEDURE UPDATE_STATE_USING_INIT_VALUES(px_arg                      IN OUT NOCOPY arg,
                                            p_use_splitting             IN BOOLEAN,
                                            p_initialized_success_flag  IN VARCHAR2,
                                            p_valid_value_flag          IN VARCHAR2,
                                            p_canonical_value           IN VARCHAR2,
                                            p_source_type               IN VARCHAR2,
                                            p_source_text               IN VARCHAR2,
                                            p_source_final_text         IN VARCHAR2,
                                            x_return_status             OUT NOCOPY VARCHAR2,
                                            x_return_msg                OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'UPDATE_STATE_USING_INIT_VALUES';

      l_canonical_value VARCHAR2(4000);
      l_number          NUMBER;
      l_date            DATE;
      l_rowid           ROWID;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --SET DERIVED ATTRIBUTES

      --update the bind_rowids flag based on the source type and whether we're using splitting
      IF (p_source_type = FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE) THEN
         px_arg.source_sql_bind_rowids := p_use_splitting;
      END IF;

      --set the is_constant indicator boolean based on the source_type
      IF p_source_type = FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_CONSTANT THEN
         px_arg.is_constant := TRUE;
      END IF;

      --if initialized was already determined, set our value-related state based on inputs
      IF p_initialized_success_flag IS NOT NULL THEN
         px_arg.initialized_success_flag := p_initialized_success_flag;
         IF FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_initialized_success_flag) THEN
            px_arg.valid_value_flag := p_valid_value_flag;
            IF FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_valid_value_flag) THEN
               BEGIN
                  SET_STATE_ARG_VALUE(px_arg,
                                      p_canonical_value);
               EXCEPTION
                  WHEN OTHERS THEN
                     fnd_oam_debug.log(1, l_ctxt, 'ARG ID ('||px_arg.arg_id||'), failed to set the canonical value: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
                     --if it didn't set properly, store that after the init to keep other threads from doing it
                     px_arg.valid_value_flag := FND_API.G_FALSE;
               END;
            ELSIF px_arg.is_constant AND px_arg.valid_value_flag IS NULL THEN
               -- For constants, write the canonical value when the value flag is null because we never set it to TRUE until the get.
               -- Invalid p_source_text values would have been caught by the first init where valid_value_flag would be set to FALSE.
               px_arg.canonical_value := p_source_text;
            ELSE
               px_arg.canonical_value := NULL;
            END IF;
         END IF;
      END IF;

      --Before doing further init, if we've already failed the init then return because we've updated enough state
      IF px_arg.initialized_success_flag = FND_API.G_FALSE THEN
         px_arg.init_locally := TRUE;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(1, l_ctxt, 'Found initialized_success_flag was false after sync but before any sql actions.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --Since constants are rather common and they dont change, go ahead and validate the value and
      --store it in the canonical value for quick retrieval later.  We don't set the valid_value_flag because
      --we want get_canonical_value to be able to detect the first time a constant is referenced so it can write it
      --in the appropriate location.
      IF p_source_type = FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_CONSTANT THEN

         BEGIN
            VALIDATE_CANONICAL_VALUE(px_arg,
                                     p_source_text);
            --set to NULL instead of TRUE to allow constants to be overridden in the get_* logic by context values
            px_arg.valid_value_flag := NULL;
            px_arg.canonical_value := p_source_text;
         EXCEPTION
            WHEN OTHERS THEN
               px_arg.valid_value_flag := FND_API.G_FALSE;
         END;

         --always set init to true since a failed value gets caught with the valid_value_flag
         px_arg.initialized_success_flag := FND_API.G_TRUE;

      -- The following situations benefit from a source cursor:
      --  1) SQL source with write policies of per_range or always
      -- However, to keep from querying the source_final_text in get_value later, all SQL-based sources use a cursor.
      ELSIF FND_OAM_DSCRAM_UTILS_PKG.SOURCE_TYPE_USES_SQL(p_source_type) THEN

         --close the last cursor, shouldn't happen but it's safe
         IF px_arg.source_cursor_id IS NOT NULL AND DBMS_SQL.IS_OPEN(px_arg.source_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(px_arg.source_cursor_id);
         END IF;

         --create a new cursor and parse the source_final_text into it
         px_arg.source_cursor_id := DBMS_SQL.OPEN_CURSOR;
         BEGIN
            DBMS_SQL.PARSE(px_arg.source_cursor_id,
                           p_source_final_text,
                           DBMS_SQL.NATIVE);
         EXCEPTION
            WHEN OTHERS THEN
               x_return_msg := 'ARG_ID ('||px_arg.arg_id||'), failed to parse source final text: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               px_arg.init_locally := TRUE;
               fnd_oam_debug.log(1, l_ctxt, 'Source Final Text: "'||p_source_final_text||'"');
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
         END;

         --finally, define a column with the correct output type
         CASE px_arg.datatype
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2 THEN
               DBMS_SQL.DEFINE_COLUMN(px_arg.source_cursor_id,
                                      1,
                                      l_canonical_value,
                                      4000);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER THEN
               DBMS_SQL.DEFINE_COLUMN(px_arg.source_cursor_id,
                                      1,
                                      l_number);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE THEN
               DBMS_SQL.DEFINE_COLUMN(px_arg.source_cursor_id,
                                      1,
                                      l_date);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID THEN
               DBMS_SQL.DEFINE_COLUMN_ROWID(px_arg.source_cursor_id,
                                            1,
                                            l_rowid);
            ELSE
               x_return_msg := 'Unknown Arg Dataype: '||px_arg.datatype;
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               px_arg.init_locally := TRUE;
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
         END CASE;

         --set these sorts of args to be initialized
         px_arg.initialized_success_flag := FND_API.G_TRUE;
      ELSIF p_source_type = FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_STATE THEN
         --set the source state key using the first 30 chars of the source_text
         px_arg.source_state_key := SUBSTR(p_source_text, 1, 30);
         px_arg.initialized_success_flag := FND_API.G_TRUE;
      ELSIF p_source_type = FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_EXECUTION_CURSOR THEN
         --set the use_exec_cursor indicator variable for the arg
         px_arg.source_use_exec_cursor := TRUE;
         px_arg.initialized_success_flag := FND_API.G_TRUE;
      ELSIF p_source_type IS NULL THEN
         --if there's no source, we're done initializing.
         px_arg.initialized_success_flag := FND_API.G_TRUE;
      END IF;

      --return success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      px_arg.init_locally := TRUE;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Arg ID('||px_arg.arg_id||') Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         px_arg.init_locally := TRUE;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private: used to set up the arg state and perform any pre-GET operations to make sure that all GETS
   -- proceed in the same way.  Only messes with the value fields in the case of constants so we don't have to select out
   -- the source text again later.
   PROCEDURE INITIALIZE_ARG(px_arg              IN OUT NOCOPY arg,
                            p_arg_context       IN arg_context,
                            p_using_splitting   IN BOOLEAN,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'INITIALIZE_ARG';

      l_initialized_success_flag        VARCHAR2(3);
      l_valid_value_flag                VARCHAR2(3);
      l_canonical_value                 VARCHAR2(4000);
      l_source_type                     VARCHAR2(30);
      l_source_text                     VARCHAR2(4000);
      l_source_where_clause             VARCHAR2(4000);
      l_source_final_text               VARCHAR2(4000);
      l_append_rowid_clause             BOOLEAN;

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(1, l_ctxt, 'Argument(Splitting?): '||px_arg.arg_name||'('||FND_OAM_DSCRAM_UTILS_PKG.BOOLEAN_TO_FLAG(p_using_splitting)||')');

      --check if we've already done the local init
      IF px_arg.init_locally THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(1, l_ctxt, 'Already locally initialized');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --before locking the arg, select to see if its initialized already by another thread
      SELECT initialized_success_flag, valid_value_flag, canonical_value, source_type, source_text, source_final_text
         INTO l_initialized_success_flag, l_valid_value_flag, l_canonical_value, l_source_type, l_source_text, l_source_final_text
         FROM fnd_oam_dscram_args_b
         WHERE arg_id = px_arg.arg_id;

      -- if init success already determined, update our local state variables and return
      IF l_initialized_success_flag IS NOT NULL THEN
         UPDATE_STATE_USING_INIT_VALUES(px_arg,
                                        p_using_splitting,
                                        l_initialized_success_flag,
                                        l_valid_value_flag,
                                        l_canonical_value,
                                        l_source_type,
                                        l_source_text,
                                        l_source_final_text,
                                        x_return_status,
                                        x_return_msg);
         fnd_oam_debug.log(1, l_ctxt, 'Pre-Lock select found already initialized.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      -- if we got here, we'll probably be updating the arg so lock it and make sure we still need to update it
      SELECT initialized_success_flag, valid_value_flag, canonical_value, source_type, source_text, source_where_clause, source_final_text
         INTO l_initialized_success_flag, l_valid_value_flag, l_canonical_value, l_source_type, l_source_text, l_source_where_clause, l_source_final_text
         FROM fnd_oam_dscram_args_b
         WHERE arg_id = px_arg.arg_id
         FOR UPDATE;

      --check again after the locking select to see if somebody else has already done the init
      IF l_initialized_success_flag IS NOT NULL THEN
         UPDATE_STATE_USING_INIT_VALUES(px_arg,
                                        p_using_splitting,
                                        l_initialized_success_flag,
                                        l_valid_value_flag,
                                        l_canonical_value,
                                        l_source_type,
                                        l_source_text,
                                        l_source_final_text,
                                        x_return_status,
                                        x_return_msg);
         fnd_oam_debug.log(1, l_ctxt, 'Locking select found already initialized.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
         RETURN;
      END IF;

      --at this point it's up to this function to do the init, reset the valid value flag to unknown
      l_valid_value_flag := NULL;

      --for sqls, compose our final source statement from its component parts
      IF FND_OAM_DSCRAM_UTILS_PKG.SOURCE_TYPE_USES_SQL(l_source_type) THEN

         --see whether we'll be appending the rowid clause or not
         l_append_rowid_clause := FALSE;
         IF l_source_type = FND_OAM_DSCRAM_UTILS_PKG.G_SOURCE_SQL_RESTRICTABLE THEN
            l_append_rowid_clause := p_using_splitting;
         END IF;

         --prepare the final text from the source_text/where clause
         FND_OAM_DSCRAM_UTILS_PKG.MAKE_FINAL_SQL_STMT(p_arg_context,
                                                      l_source_text,
                                                      l_source_where_clause,
                                                      l_append_rowid_clause,
                                                      l_source_final_text,
                                                      l_return_status,
                                                      l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            fnd_oam_debug.log(6, l_ctxt, 'ARG ID('||px_arg.arg_id||'), failed to create final sql stmt: '||l_return_msg);
            px_arg.initialized_success_flag := FND_API.G_FALSE;
         END IF;
      END IF;

      --After initializing stuff into our local values, try to roll these local values into our state
      UPDATE_STATE_USING_INIT_VALUES(px_arg,
                                     p_using_splitting,
                                     l_initialized_success_flag,
                                     l_valid_value_flag,
                                     l_canonical_value,
                                     l_source_type,
                                     l_source_text,
                                     l_source_final_text,
                                     l_return_status,
                                     l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         RAISE INIT_FAILED;
      END IF;

      --Finally, if we ended up initializing the arg, write out that new state
      IF px_arg.initialized_success_flag IS NOT NULL THEN
         UPDATE fnd_oam_dscram_args_b
            SET initialized_success_flag = px_arg.initialized_success_flag,
            source_final_text = l_source_final_text,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE arg_id = px_arg.arg_id;

         --if the arg is writable and we determined if it has a valid value or not, write out the canonical value and valid_value_flag
         --For constants, we bend the rules and write them even if it's not writable because otherwise get must incur the cost of messing
         --with the source_text.
         IF (px_arg.valid_value_flag IS NOT NULL AND IS_WRITABLE(px_arg)) THEN
            fnd_oam_debug.log(1, l_ctxt, 'Pre-emptively writing the arg value');
            UPDATE fnd_oam_dscram_args_b
               SET valid_value_flag = px_arg.valid_value_flag,
                   canonical_value = px_arg.canonical_value
               WHERE arg_id = px_arg.arg_id;
         END IF;

         COMMIT;

         --return success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
         x_return_msg := 'ARG ID('||px_arg.arg_id||'), got to the end but arg was not initialized.  This should not happen.';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         RAISE INIT_FAILED;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN INIT_FAILED THEN
         --x_return_* already set, only raised after locking select
         BEGIN
            UPDATE fnd_oam_dscram_args_b
               SET initialized_success_flag = FND_API.G_FALSE,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.user_id,
               last_update_date = SYSDATE
               WHERE arg_id = px_arg.arg_id;
            COMMIT;
            px_arg.initialized_success_flag := FND_API.G_FALSE;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         EXCEPTION
            WHEN OTHERS THEN
               x_return_msg := 'Unexpected Error while processing init_failed: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               ROLLBACK;
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         END;
      WHEN OTHERS THEN
         --here we can't assume we have a lock so leave out update of DB but do update our local state
         px_arg.initialized_success_flag := FND_API.G_FALSE;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Arg ID('||px_arg.arg_id||'), unexpected error while initializing: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
   END;

   -- Private, helper to STORE_CANONICAL_ARG_VALUE to perform an insert into the ARG_VALUES table
   PROCEDURE INSERT_ARG_VALUE(p_arg_id                  IN NUMBER,
                              p_valid_value_flag        IN VARCHAR2,
                              p_canonical_value         IN VARCHAR2,
                              p_parent_type             IN VARCHAR2,
                              p_parent_id               IN NUMBER DEFAULT NULL,
                              p_rowid_lbound            IN ROWID DEFAULT NULL,
                              p_rowid_ubound            IN ROWID DEFAULT NULL,
                              p_id_lbound               IN NUMBER DEFAULT NULL,
                              p_id_ubound               IN NUMBER DEFAULT NULL,
                              x_arg_val_id              OUT NOCOPY NUMBER)
   IS
      l_id      NUMBER;
   BEGIN
      INSERT INTO FND_OAM_DSCRAM_ARG_VALUES (ARG_VALUE_ID,
                                             ARG_ID,
                                             PARENT_TYPE,
                                             PARENT_ID,
                                             ROWID_LBOUND,
                                             ROWID_UBOUND,
                                             ID_LBOUND,
                                             ID_UBOUND,
                                             VALID_VALUE_FLAG,
                                             CANONICAL_VALUE,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN)
         VALUES
            (fnd_oam_dscram_arg_values_s.nextval,
             p_arg_id,
             p_parent_type,
             p_parent_id,
             p_rowid_lbound,
             p_rowid_ubound,
             p_id_lbound,
             p_id_ubound,
             p_valid_value_flag,
             p_canonical_value,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID,
             SYSDATE,
             FND_GLOBAL.USER_ID)
         RETURNING ARG_VALUE_ID INTO l_id;
      x_arg_val_id := l_id;

      --exceptions passed to store
   END;

   -- Private, used by GET_CANONICAL_ARG_VALUE to write an arg's canonical value to the DB in the proper place
   -- Assume conditions surrounding whether we should be writing the arg have already been evaluated.
   PROCEDURE STORE_ARG_VALUE(px_arg             IN OUT NOCOPY arg,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_return_msg       OUT NOCOPY VARCHAR2)
   IS

      l_ctxt            VARCHAR2(60) := PKG_NAME||'STORE_ARG_VALUE';

      l_arg_val_id      NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      IF px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE THEN
         --update the main args_b row
         UPDATE fnd_oam_dscram_args_b
            SET valid_value_flag = px_arg.valid_value_flag,
            canonical_value = px_arg.canonical_value,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE arg_id = px_arg.arg_id;
      ELSIF px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER THEN
         --try to update arg_values with parent_type=worker, failing that insert
         UPDATE fnd_oam_dscram_arg_values
            SET valid_value_flag = px_arg.valid_value_flag,
            canonical_value = px_arg.canonical_value,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE arg_id = px_arg.arg_id
            AND parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_WORKER AND
            parent_id = FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKER_ID;
         IF SQL%ROWCOUNT = 0 THEN
            fnd_oam_debug.log(1, l_ctxt, 'Inserting per-worker arg value.');
            INSERT_ARG_VALUE(px_arg.arg_id,
                             px_arg.valid_value_flag,
                             px_arg.canonical_value,
                             FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_WORKER,
                             FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKER_ID,
                             x_arg_val_id => l_arg_val_id);
         END IF;
      ELSIF px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE THEN
         --update arg_values with range values and parent_type = range
         UPDATE fnd_oam_dscram_arg_values
            SET valid_value_flag = px_arg.valid_value_flag,
            canonical_value = px_arg.canonical_value,
            rowid_lbound = px_arg.rowid_lbound,
            rowid_ubound = px_arg.rowid_ubound,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE arg_id = px_arg.arg_id AND
            parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RANGE AND
            rowid_lbound = px_arg.rowid_lbound AND
            rowid_ubound = px_arg.rowid_ubound;
         IF SQL%ROWCOUNT = 0 THEN
            fnd_oam_debug.log(1, l_ctxt, 'Inserting per-range arg value.');
            INSERT_ARG_VALUE(px_arg.arg_id,
                             px_arg.valid_value_flag,
                             px_arg.canonical_value,
                             FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RANGE,
                             p_rowid_lbound => px_arg.rowid_lbound,
                             p_rowid_ubound => px_arg.rowid_ubound,
                             x_arg_val_id => l_arg_val_id);
         END IF;
      ELSIF px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ALWAYS THEN
         fnd_oam_debug.log(1, l_ctxt, 'Inserting always arg value.');
         INSERT_ARG_VALUE(px_arg.arg_id,
                          px_arg.valid_value_flag,
                          px_arg.canonical_value,
                          NULL,
                          p_rowid_lbound => px_arg.rowid_lbound,
                          p_rowid_ubound => px_arg.rowid_ubound,
                          x_arg_val_id => l_arg_val_id);
      ELSE
         x_return_msg := 'Invalid write policy: '||px_arg.write_policy;
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Arg ID('||px_arg.arg_id||'), unexpected error while storing canonical value: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private Wrapper: STORE in an autonomous transaction for cases such as context args where we can't roll back or
   -- failure cases where we're going to roll back but we don't want future get_args to keep failing.
   PROCEDURE STORE_ARG_VALUE_AUTONOMOUSLY(px_arg                IN OUT NOCOPY arg,
                                          x_return_status       OUT NOCOPY VARCHAR2,
                                          x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      STORE_ARG_VALUE(px_arg,
                      x_return_status,
                      x_return_msg);
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END;

   -- Declaration to allow GET_CANONICAL_ARG_VALUE to get values for context args.
   PROCEDURE GET_CANONICAL_CTXT_ARG_VALUE(px_arg                        IN OUT NOCOPY arg,
                                          p_using_splitting             IN BOOLEAN,
                                          p_rowid_lbound                IN ROWID,
                                          p_rowid_ubound                IN ROWID,
                                          p_execution_cursor_id         IN INTEGER,
                                          p_force_store_autonomously    IN BOOLEAN,
                                          p_allow_sourcing              IN BOOLEAN,
                                          p_release_arg_lock            IN BOOLEAN,
                                          x_arg_lock_handle             OUT NOCOPY VARCHAR2,
                                          x_value                       OUT NOCOPY VARCHAR2,
                                          x_return_status               OUT NOCOPY VARCHAR2,
                                          x_return_msg                  OUT NOCOPY VARCHAR2);

   -- Private: obtains value for the argument using either the local state, external sources or the arg context.
   -- If it's writable, also writes out retrieved value to proper location based on write_policy using STORE.
   -- For locking the arg, we use a dbms_lock based lock instead of a FOR UPDATE to allow all of the sources/stores to happen in the parent
   -- transaction so that stored values are discarded if the results are discarded.  Values are stored autonomously if p_force_store_autonomously is set.
   -- Allow_sourcing and release_arg_lock can be manipulated to perform a shallow get to see if an arg already has a value and if not, maintain the lock
   -- so that the caller can update the arg and release the lock.  This is used in the UPDATE_WRITABLE-like procedures to default values.
   PROCEDURE GET_CANONICAL_ARG_VALUE(px_arg                     IN OUT NOCOPY arg,
                                     px_arg_context             IN OUT NOCOPY arg_context,
                                     p_using_splitting          IN BOOLEAN,
                                     p_rowid_lbound             IN ROWID,
                                     p_rowid_ubound             IN ROWID,
                                     p_execution_cursor_id      IN INTEGER,
                                     p_force_store_autonomously IN BOOLEAN,
                                     p_allow_sourcing           IN BOOLEAN,
                                     p_release_arg_lock         IN BOOLEAN,
                                     x_arg_lock_handle          OUT NOCOPY VARCHAR2,
                                     x_value                    OUT NOCOPY VARCHAR2,
                                     x_return_status            OUT NOCOPY VARCHAR2,
                                     x_return_msg               OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_CANONICAL_ARG_VALUE';

      l_determined_value        BOOLEAN;
      l_value_requires_store    BOOLEAN;
      l_valid_value_flag        VARCHAR2(3);
      l_canonical_value         VARCHAR2(2048);
      l_lock_handle             VARCHAR2(128) := NULL;
      l_retval                  INTEGER;

      l_temp                    NUMBER;
      l_ignore                  VARCHAR2(128);
      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(1, l_ctxt, 'Argument(ID): '||px_arg.arg_name||'('||px_arg.arg_id||')');

      --initialize the argument if it hasn't been initialized locally yet (sets up source_cursor/derived state)
      IF NOT px_arg.init_locally THEN
         INITIALIZE_ARG(px_arg,
                        px_arg_context,
                        p_using_splitting,
                        l_return_status,
                        l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         END IF;
      END IF;

      --if the arg went through init before and we stored that it failed, return an error, this is less likely
      IF px_arg.initialized_success_flag = FND_API.G_FALSE THEN
         x_return_msg := 'Arg ID ('||px_arg.arg_id||'), previous call to init stored that it failed.  Get cannot continue.';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --at this point, we should have a sucessfully initialized arg, try to determine its value
      l_determined_value := FALSE;
      l_value_requires_store := FALSE;

      --now check if valid_value_flag's been set to false meaning we have no value and sourcing fails
      IF px_arg.valid_value_flag = FND_API.G_FALSE THEN
         --note: this means that a malformed constant will not be overrideable by the arg_context, should be a very infrequent corner case.
         x_return_msg := 'Arg ID ('||px_arg.arg_id||'), previous call to get_value stored that fetching the value fails. Exiting.';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      -- see if we already have a value, skip the check if we write always
      ELSIF px_arg.valid_value_flag = FND_API.G_TRUE AND
            (NOT (IS_WRITABLE(px_arg)) OR
             NOT (px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ALWAYS)) THEN
         --if we already know the local value is valid then make sure we match the supplied rowid range as well
         IF (px_arg.rowid_lbound IS NOT NULL OR px_arg.rowid_ubound IS NOT NULL) THEN
            IF ((px_arg.rowid_lbound IS NULL OR (px_arg.rowid_lbound = p_rowid_lbound)) AND
                (px_arg.rowid_ubound IS NULL OR (px_arg.rowid_ubound = p_rowid_ubound))) THEN

               x_return_status := FND_API.G_RET_STS_SUCCESS;
               x_value := px_arg.canonical_value;
               fnd_oam_debug.log(1, l_ctxt, 'Ranged Value cached');
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
            END IF;
         ELSE
            --if not contingent on a range, the value is the arg's stored canonical value
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            x_value := px_arg.canonical_value;
            fnd_oam_debug.log(1, l_ctxt, 'Value cached');
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      ELSE
         -- we haven't cached that the value's valid somewhere, but it may have been calculated and stored already in the DB
         -- use different select statements to find the latest valid_value_flag and canonical_value
         l_valid_value_flag := NULL;
         IF px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE THEN
            --query the main args_b row
            SELECT valid_value_flag, canonical_value
               INTO l_valid_value_flag, l_canonical_value
               FROM fnd_oam_dscram_args_b
               WHERE arg_id = px_arg.arg_id;
            fnd_oam_debug.log(1, l_ctxt, 'Write Policy Once: first query valid_value_flag: '||l_valid_value_flag);
         ELSIF px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER THEN
            --Needed in the case of restart to get the value we may have comitted for this worker
            --query arg_values with parent_type=worker
            BEGIN
               SELECT valid_value_flag, canonical_value
                  INTO l_valid_value_flag, l_canonical_value
                  FROM fnd_oam_dscram_arg_values
                  WHERE arg_id = px_arg.arg_id AND
                  parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_WORKER AND
                  parent_id = FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKER_ID;
            EXCEPTION
               WHEN OTHERS THEN
                  l_valid_value_flag := NULL;
            END;
            fnd_oam_debug.log(1, l_ctxt, 'Write Policy Per-Worker: first query valid_value_flag: '||l_valid_value_flag);
         ELSIF px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE THEN
            --Since we don't share ranges, this won't happen on the initial execute, but it may be necessary on restart
            --if the arg's value was comitted since we won't read it back on initialize.
            --query arg_values with range values and parent_type = range
            BEGIN
               SELECT valid_value_flag, canonical_value
                  INTO l_valid_value_flag, l_canonical_value
                  FROM fnd_oam_dscram_arg_values
                  WHERE arg_id = px_arg.arg_id AND
                  parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RANGE AND
                  rowid_lbound = p_rowid_lbound AND
                  rowid_ubound = p_rowid_ubound;
            EXCEPTION
               WHEN OTHERS THEN
                  l_valid_value_flag := NULL;
            END;
            fnd_oam_debug.log(1, l_ctxt, 'Write Policy Per-Range: first query valid_value_flag: '||l_valid_value_flag);
         END IF;

         --if we found a value for valid_value_flag, we've determined a value or a failure
         IF l_valid_value_flag = FND_API.G_TRUE THEN
            l_determined_value := TRUE;
         ELSIF l_valid_value_flag = FND_API.G_FALSE THEN
            --A false means sourcing failes
            x_return_msg := 'Arg ID ('||px_arg.arg_id||'), non-locking select: previous call to get_value stored that fetching the value fails. Exiting.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      END IF;

      --for write_once, we need to lock the arg and check again, the rest don't need a lock because there's no cross-worker contention.
      IF NOT l_determined_value AND
         IS_WRITABLE(px_arg) AND
         px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE THEN

         --lock the arg
         IF FND_OAM_DSCRAM_UTILS_PKG.LOCK_ARG(px_arg.arg_id,
                                              l_lock_handle) THEN
            --do a normal select instead of a locking select since the above lock will hold for write_once args even if release_lock
            --is set when a worker is the first to determine a value for the arg.  The lock will be released when the first worker
            --to set the arg commits or rolls back.
            --Known Issue: when the run is in a non-normal mode, write-once args will be written by each worker because the batch
            --is never comitted.  In the normal mode, the first successful batch is the only one to write the arg value.
            SELECT valid_value_flag, canonical_value
               INTO l_valid_value_flag, l_canonical_value
               FROM fnd_oam_dscram_args_b
               WHERE arg_id = px_arg.arg_id;
            fnd_oam_debug.log(1, l_ctxt, 'Write Policy Once, locking query valid_value_flag: '||l_valid_value_flag);

            --re-check the valid value flag
            IF l_valid_value_flag = FND_API.G_TRUE THEN
               l_determined_value := TRUE;
            ELSIF l_valid_value_flag = FND_API.G_FALSE THEN
               --A false means sourcing failed previously
               px_arg.valid_value_flag := FND_API.G_FALSE;
               x_return_msg := 'Arg ID ('||px_arg.arg_id||'), locking select: previous call to get_value stored that fetching the value fails. Exiting.';
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               RAISE GET_FAILED;
            END IF;
         END IF;
      END IF;

      --at this point, we know whether the arg currently has a valid value based on the write policy.  If we haven't
      --determined a value, before sourcing it using the source_* fields, try to obtain it from the context if the arg allows override.
      IF NOT l_determined_value AND
         px_arg.allow_override_source AND
         px_arg_context.EXISTS(px_arg.arg_name) THEN

         IF IS_READABLE(px_arg_context(px_arg.arg_name)) AND
            px_arg_context(px_arg.arg_name).datatype = px_arg.datatype THEN

            GET_CANONICAL_CTXT_ARG_VALUE(px_arg_context(px_arg.arg_name),
                                         p_using_splitting,
                                         p_rowid_lbound,
                                         p_rowid_ubound,
                                         p_execution_cursor_id,
                                         p_force_store_autonomously,
                                         TRUE,
                                         TRUE,
                                         l_ignore,
                                         l_canonical_value,
                                         l_return_status,
                                         l_return_msg);
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               l_valid_value_flag := FND_API.G_TRUE;
               l_determined_value := TRUE;
               l_value_requires_store := TRUE;
            END IF;
         END IF;
      END IF;

      -- skip the sourcing section if we disallow it
      IF p_allow_sourcing THEN

         --This is a bit of a hack, but constants have the valid_value flag set to NULL to allow the above logic to try and fetch values from
         --different locations based on the write_policy so that arg_contexts can be used to get values.  The correct constant value is stored
         --in the canonical value.  This represents one case where the valid_value_flag does not need to be true to use the value of the
         --canonical value.
         IF NOT l_determined_value AND px_arg.is_constant AND l_valid_value_flag IS NULL THEN
            l_valid_value_flag := FND_API.G_TRUE;
            l_canonical_value := px_arg.canonical_value;
            l_determined_value := TRUE;
            l_value_requires_store := TRUE;
         END IF;

         --if the value is still unknown, first try state sourcing since it's cheap
         IF NOT l_determined_value AND px_arg.source_state_key IS NOT NULL THEN
            GET_CANONICAL_VALUE_FOR_KEY(px_arg,
                                        px_arg.source_state_key,
                                        p_using_splitting,
                                        p_rowid_lbound,
                                        p_rowid_ubound,
                                        l_canonical_value,
                                        l_return_status,
                                        l_return_msg);
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               BEGIN
                  VALIDATE_CANONICAL_VALUE(px_arg,
                                           l_canonical_value);
                  l_valid_value_flag := FND_API.G_TRUE;
               EXCEPTION
                  WHEN OTHERS THEN
                     l_valid_value_flag := FND_API.G_FALSE;
               END;
               l_determined_value := TRUE;
               l_value_requires_store := TRUE;
            ELSIF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_MISSING_STATE THEN
               -- if we didn't fail as much as we were called under the wrong circumstances, don't store this as a failure either
               x_return_status := l_return_status;
               x_return_msg := l_return_msg;
               RAISE GET_FAILED;
            ELSE
              --here we really did fail
              l_valid_value_flag := FND_API.G_FALSE;
              l_determined_value := TRUE;
              l_value_requires_store := TRUE;
           END IF;

         END IF;

         --if the value is still unknown, next try execution cursor sourcing since it's also relatively cheap
         IF NOT l_determined_value AND px_arg.source_use_exec_cursor AND p_execution_cursor_id IS NOT NULL THEN
            GET_CANONICAL_VALUE_FROM_CUR(px_arg,
                                         p_execution_cursor_id,
                                         l_canonical_value,
                                         l_return_status,
                                         l_return_msg);
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               --don't validate, the cursor get is strongly typed
               l_valid_value_flag := FND_API.G_TRUE;
               l_determined_value := TRUE;
               l_value_requires_store := TRUE;
            ELSE
              --failed
              l_valid_value_flag := FND_API.G_FALSE;
              l_determined_value := TRUE;
              l_value_requires_store := TRUE;
           END IF;
         END IF;

         --if the value is still unknown, try to do sql-based sourcing
         IF NOT l_determined_value AND px_arg.source_cursor_id IS NOT NULL THEN
            --now source the value for sql using the source_cursor_id, constants should have already been rolled into the value by init
            GET_CANONICAL_VALUE_FOR_SQL(px_arg,
                                        NULL,
                                        p_rowid_lbound,
                                        p_rowid_ubound,
                                        l_canonical_value,
                                        l_return_status,
                                        l_return_msg);
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               BEGIN
                  VALIDATE_CANONICAL_VALUE(px_arg,
                                           l_canonical_value);
                  l_valid_value_flag := FND_API.G_TRUE;
               EXCEPTION
                  WHEN OTHERS THEN
                     l_valid_value_flag := FND_API.G_FALSE;
               END;
               l_determined_value := TRUE;
               l_value_requires_store := TRUE;
            ELSIF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_MISSING_BINDS THEN
               -- if we didn't fail as much as we were called under the wrong circumstances, don't store this as a failure either
               x_return_status := l_return_status;
               x_return_msg := l_return_msg;
               RAISE GET_FAILED;
            ELSE
              --here we really did fail
              l_valid_value_flag := FND_API.G_FALSE;
              l_determined_value := TRUE;
              l_value_requires_store := TRUE;
           END IF;
         END IF;

      END IF; --end p_allow_sourcing check

      --if we don't have a value here, any arg can try to source from the context before being flagged as a failure.
      --This allows placeholder args for dmls where there is no source, just the expectation of inheriting a value from the context
      IF NOT l_determined_value AND
         px_arg_context.EXISTS(px_arg.arg_name) THEN
         fnd_oam_debug.log(1, l_ctxt, 'Doing Last ditch context check.');
         IF IS_READABLE(px_arg_context(px_arg.arg_name)) AND
            px_arg_context(px_arg.arg_name).datatype = px_arg.datatype THEN

            GET_CANONICAL_CTXT_ARG_VALUE(px_arg_context(px_arg.arg_name),
                                         p_using_splitting,
                                         p_rowid_lbound,
                                         p_rowid_ubound,
                                         p_execution_cursor_id,
                                         p_force_store_autonomously,
                                         TRUE,
                                         TRUE,
                                         l_ignore,
                                         l_canonical_value,
                                         l_return_status,
                                         l_return_msg);
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               l_valid_value_flag := FND_API.G_TRUE;
               l_determined_value := TRUE;
               l_value_requires_store := TRUE;
            ELSIF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_MISSING_BINDS THEN
               --since this is the last thing before failure, let missing binds return
               x_return_status := l_return_status;
               x_return_msg := l_return_msg;
               fnd_oam_debug.log(1, l_ctxt, 'Returning Missing Binds');
               RETURN;
            END IF;
         END IF;
      END IF;

      --at this point, we've done everything we can to determine the value, if we haven't and we allowed sourcing then the get's a failure
      IF NOT l_determined_value AND p_allow_sourcing THEN
         fnd_oam_debug.log(6, l_ctxt, 'Arg ID ('||px_arg.arg_id||'), failed to determine a value.');
         l_valid_value_flag := FND_API.G_FALSE;
         l_determined_value := TRUE;
         l_value_requires_store := TRUE;
      END IF;

      -- if we found a value, sync up the value state with the get even if we're not going to write it out
      IF l_determined_value THEN
         px_arg.valid_value_flag := l_valid_value_flag;
         IF FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(l_valid_value_flag) THEN
            px_arg.canonical_value := l_canonical_value;
         ELSE
            px_arg.canonical_value := NULL;
         END IF;

         --if we determined a value and we're fetching values for each range, store the range used.
         IF l_determined_value AND px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE THEN
            px_arg.rowid_lbound := p_rowid_lbound;
            px_arg.rowid_ubound := p_rowid_ubound;
         END IF;
      END IF;

      --if the get fetched a new value that needs to be stored, do that also
      IF IS_WRITABLE(px_arg) AND l_value_requires_store THEN
         --store the value autonomously when instructed.  We don't need to write autonomously for
         --write once args because other workers will hang on the write once lock and we don't want to
         --give up the value until we're sure it works for this range.  Also, it messes up the print_arg_context.
         IF p_force_store_autonomously THEN
            STORE_ARG_VALUE_AUTONOMOUSLY(px_arg,
                                         l_return_status,
                                         l_return_msg);
         ELSE
            STORE_ARG_VALUE(px_arg,
                            l_return_status,
                            l_return_msg);
         END IF;
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            px_arg.valid_value_flag := FND_API.G_FALSE;
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            RAISE GET_FAILED;
         END IF;
      END IF;

      --release the lock on the arg if told to do so and the arg isn't a just-stored write-once value.
      --Just-written, write-once args hold onto the lock until the batch is comitted or rolled back so that other
      --workers don't compute a new value. These args are treated as possible synchronization points.
      IF p_release_arg_lock AND
         ((px_arg.write_policy <> FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE) OR
          (px_arg.write_policy = FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE AND NOT l_value_requires_store)) THEN
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
            IF l_retval <> 0 THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to release arg lock: '||l_retval);
            END IF;
         END IF;
         x_arg_lock_handle := NULL;
      ELSE
         x_arg_lock_handle := l_lock_handle;
      END IF;

      --done, change return status based on whether we found a valid value even if we didn't store it
      IF FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(l_valid_value_flag) THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_value := l_canonical_value;
      ELSIF (NOT p_allow_sourcing AND l_valid_value_flag IS NULL) THEN
         --return success if something which was unallowed to source ended up without a value, since we're only
         --doing a shallow test to see if it has a value.  Caller must check px_arg's valid value flag to see if
         --it's a real successful get or just a sucessful lack of failure.
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_value := NULL;
      END IF;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN GET_FAILED THEN
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
            IF l_retval <> 0 THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to release arg lock: '||l_retval);
            END IF;
         END IF;

         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Arg ID('||px_arg.arg_id||'), unexpected error while getting canonical value: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);

         --store that the arg's value yields failure
         BEGIN
            IF IS_WRITABLE(px_arg) THEN
               px_arg.valid_value_flag := FND_API.G_FALSE;
               px_arg.canonical_value := NULL;
               px_arg.rowid_lbound := p_rowid_lbound;
               px_arg.rowid_ubound := p_rowid_ubound;
               STORE_ARG_VALUE_AUTONOMOUSLY(px_arg,
                                            l_return_status,
                                            l_return_msg);
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  fnd_oam_debug.log(6, l_ctxt, 'Store failure failed('||l_return_status||'): '||l_return_msg);
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               fnd_oam_debug.log(6, l_ctxt, 'Exception while storing failed arg fetch: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         END;
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
            IF l_retval <> 0 THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to release arg lock: '||l_retval);
            END IF;
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private Wrapper for context args
   PROCEDURE GET_CANONICAL_CTXT_ARG_VALUE(px_arg                        IN OUT NOCOPY arg,
                                          p_using_splitting             IN BOOLEAN,
                                          p_rowid_lbound                IN ROWID,
                                          p_rowid_ubound                IN ROWID,
                                          p_execution_cursor_id         IN INTEGER,
                                          p_force_store_autonomously    IN BOOLEAN,
                                          p_allow_sourcing              IN BOOLEAN,
                                          p_release_arg_lock            IN BOOLEAN,
                                          x_arg_lock_handle             OUT NOCOPY VARCHAR2,
                                          x_value                       OUT NOCOPY VARCHAR2,
                                          x_return_status               OUT NOCOPY VARCHAR2,
                                          x_return_msg                  OUT NOCOPY VARCHAR2)
   IS
      l_empty_arg_context       arg_context;
   BEGIN
      GET_CANONICAL_ARG_VALUE(px_arg,
                              l_empty_arg_context,
                              p_using_splitting,
                              p_rowid_lbound,
                              p_rowid_ubound,
                              p_execution_cursor_id,
                              p_force_store_autonomously,
                              p_allow_sourcing,
                              p_release_arg_lock,
                              x_arg_lock_handle,
                              x_value,
                              x_return_status,
                              x_return_msg);
   END;

   --Another, simpler wrapper used by internal_print_arg_context
   PROCEDURE GET_CANONICAL_CTXT_ARG_VALUE(px_arg                IN OUT NOCOPY arg,
                                          p_using_splitting     IN BOOLEAN,
                                          x_value               OUT NOCOPY VARCHAR2,
                                          x_return_status       OUT NOCOPY VARCHAR2,
                                          x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_empty_arg_context       arg_context;
      l_ignore                  VARCHAR2(128);
   BEGIN
      GET_CANONICAL_ARG_VALUE(px_arg,
                              l_empty_arg_context,
                              p_using_splitting,
                              NULL,
                              NULL,
                              NULL,
                              FALSE,
                              TRUE,
                              TRUE,
                              l_ignore,
                              x_value,
                              x_return_status,
                              x_return_msg);
   END;

   -- Public, getter for type VARCHAR2
   PROCEDURE GET_ARG_VALUE(px_arg                       IN OUT NOCOPY arg,
                           px_arg_context               IN OUT NOCOPY arg_context,
                           p_using_splitting            IN BOOLEAN,
                           p_rowid_lbound               IN ROWID,
                           p_rowid_ubound               IN ROWID,
                           p_execution_cursor_id        IN INTEGER,
                           x_value                      OUT NOCOPY VARCHAR2,
                           x_return_status              OUT NOCOPY VARCHAR2,
                           x_return_msg                 OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_ARG_VALUE(VARCHAR2)';

      l_ignore          VARCHAR2(128);
      l_varchar2        VARCHAR2(4000);
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';
      GET_CANONICAL_ARG_VALUE(px_arg,
                              px_arg_context,
                              p_using_splitting,
                              p_rowid_lbound,
                              p_rowid_ubound,
                              p_execution_cursor_id,
                              FALSE,
                              TRUE,
                              TRUE,
                              l_ignore,
                              l_varchar2,
                              l_return_status,
                              l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         x_value := NULL;
         RETURN;
      END IF;
      x_value := l_varchar2;

      --return success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_value := NULL;
   END;

   -- Public, getter for type NUMBER
   PROCEDURE GET_ARG_VALUE(px_arg                       IN OUT NOCOPY arg,
                           px_arg_context               IN OUT NOCOPY arg_context,
                           p_using_splitting            IN BOOLEAN,
                           p_rowid_lbound               IN ROWID,
                           p_rowid_ubound               IN ROWID,
                           p_execution_cursor_id        IN INTEGER,
                           x_value                      OUT NOCOPY NUMBER,
                           x_return_status              OUT NOCOPY VARCHAR2,
                           x_return_msg                 OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_ARG_VALUE(NUMBER)';

      l_ignore          VARCHAR2(128);
      l_varchar2        VARCHAR2(4000);
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';
      GET_CANONICAL_ARG_VALUE(px_arg,
                              px_arg_context,
                              p_using_splitting,
                              p_rowid_lbound,
                              p_rowid_ubound,
                              p_execution_cursor_id,
                              FALSE,
                              TRUE,
                              TRUE,
                              l_ignore,
                              l_varchar2,
                              l_return_status,
                              l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         x_value := NULL;
         RETURN;
      END IF;
      x_value := FND_NUMBER.CANONICAL_TO_NUMBER(l_varchar2);

      --return success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_value := NULL;
   END;

   -- Public, getter for type DATE
   PROCEDURE GET_ARG_VALUE(px_arg                       IN OUT NOCOPY arg,
                           px_arg_context               IN OUT NOCOPY arg_context,
                           p_using_splitting            IN BOOLEAN,
                           p_rowid_lbound               IN ROWID,
                           p_rowid_ubound               IN ROWID,
                           p_execution_cursor_id        IN INTEGER,
                           x_value                      OUT NOCOPY DATE,
                           x_return_status              OUT NOCOPY VARCHAR2,
                           x_return_msg                 OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_ARG_VALUE(DATE)';

      l_ignore          VARCHAR2(128);
      l_varchar2        VARCHAR2(4000);
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';
      GET_CANONICAL_ARG_VALUE(px_arg,
                              px_arg_context,
                              p_using_splitting,
                              p_rowid_lbound,
                              p_rowid_ubound,
                              p_execution_cursor_id,
                              FALSE,
                              TRUE,
                              TRUE,
                              l_ignore,
                              l_varchar2,
                              l_return_status,
                              l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         x_value := NULL;
         RETURN;
      END IF;
      x_value := FND_DATE.CANONICAL_TO_DATE(l_varchar2);

      --return success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_value := NULL;
   END;

   -- Public, getter for type ROWID
   PROCEDURE GET_ARG_VALUE_ROWID(px_arg                 IN OUT NOCOPY arg,
                                 px_arg_context         IN OUT NOCOPY arg_context,
                                 p_using_splitting      IN BOOLEAN,
                                 p_rowid_lbound         IN ROWID,
                                 p_rowid_ubound         IN ROWID,
                                 p_execution_cursor_id  IN INTEGER,
                                 x_value                OUT NOCOPY ROWID,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_ARG_VALUE_ROWID()';

      l_ignore          VARCHAR2(128);
      l_varchar2        VARCHAR2(4000);
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';
      GET_CANONICAL_ARG_VALUE(px_arg,
                              px_arg_context,
                              p_using_splitting,
                              p_rowid_lbound,
                              p_rowid_ubound,
                              p_execution_cursor_id,
                              FALSE,
                              TRUE,
                              TRUE,
                              l_ignore,
                              l_varchar2,
                              l_return_status,
                              l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         x_value := NULL;
         RETURN;
      END IF;
      x_value := CHARTOROWID(l_varchar2);

      --return success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_value := NULL;
   END;

   --Private, used by internal_print_arg_context to reset an arg to an unknown initialized status
   PROCEDURE RESET_INITIALIZED_AUTONOMOUSLY(p_arg_id    IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'RESET_INITIALIZED_AUTONOMOUSLY';
   BEGIN
      UPDATE fnd_oam_dscram_args_b
         SET initialized_success_flag = NULL,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.user_id,
         last_update_date = SYSDATE
         WHERE arg_id = p_arg_id;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Arg ID('||p_arg_id||'), failed to reset initialized flag: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         ROLLBACK;
   END;

   -- Private
   -- Debug method to print out an arg context.
   -- *WARNING*: performs rollbacks when p_get_values=TRUE to keep from comitting changes.  Should only be called
   -- when not in the middle of a transaction that did work.  If p_get_values=FALSE, can be called whenever.
   PROCEDURE INTERNAL_PRINT_ARG_CONTEXT(p_arg_ctxt              IN OUT NOCOPY arg_context,
                                        p_get_values            IN BOOLEAN DEFAULT FALSE,
                                        p_using_splitting       IN BOOLEAN DEFAULT FALSE,
                                        x_return_status         OUT NOCOPY VARCHAR2,
                                        x_return_msg            OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_PRINT_ARG_CONTEXT';

      l_s                       VARCHAR2(60);
      l_val                     VARCHAR2(4000);
      l_prev_init_flag          VARCHAR2(3);
      l_prev_val                VARCHAR2(4000);
      l_prev_valid_value_flag   VARCHAR2(3);
      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      l_s := p_arg_ctxt.FIRST;
      WHILE l_s IS NOT NULL LOOP
         fnd_oam_debug.log(1, l_ctxt, 'Arg Name(Permissions): '||p_arg_ctxt(l_s).arg_name||'('||p_arg_ctxt(l_s).permissions||')');
         IF p_get_values AND
            IS_READABLE(p_arg_ctxt(l_s)) THEN

            --go ahead and fetch the value
            l_prev_init_flag := p_arg_ctxt(l_s).initialized_success_flag;
            l_prev_valid_value_flag := p_arg_ctxt(l_s).valid_value_flag;
            l_prev_val := p_arg_ctxt(l_s).canonical_value;
            GET_CANONICAL_CTXT_ARG_VALUE(p_arg_ctxt(l_s),
                                         p_using_splitting,
                                         l_val,
                                         l_return_status,
                                         l_return_msg);
            --drop any arg state/values we just computed in the transaction
            ROLLBACK;

            --print the value if we suceeded
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               fnd_oam_debug.log(1, l_ctxt, 'Value: '||l_val);
            END IF;

            --reset the arg's local state
            p_arg_ctxt(l_s).init_locally := FALSE;
            p_arg_ctxt(l_s).initialized_success_flag := l_prev_init_flag;
            p_arg_ctxt(l_s).valid_value_flag := l_prev_valid_value_flag;
            p_arg_ctxt(l_s).canonical_value := l_prev_val;
            IF l_prev_init_flag IS NULL THEN
               --reset state set autonomously
               RESET_INITIALIZED_AUTONOMOUSLY(p_arg_ctxt(l_s).arg_id);
            END IF;

            --fail if the context arg was not failed sucessfully, ignore missing bind cases
            IF l_return_status NOT IN (FND_API.G_RET_STS_SUCCESS,
                                       FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_MISSING_BINDS) THEN
               x_return_status := l_return_status;
               x_return_msg := l_return_msg;
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               ROLLBACK;
               RETURN;
            END IF;
         ELSE
            IF p_arg_ctxt(l_s).valid_value_flag = FND_API.G_TRUE THEN
               fnd_oam_debug.log(1, l_ctxt, 'Value: '||p_arg_ctxt(l_s).canonical_value);
            ELSE
               fnd_oam_debug.log(1, l_ctxt, 'Value: ?');
            END IF;
         END IF;

         l_s := p_arg_ctxt.NEXT(l_s);
      END LOOP;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE PRINT_ARG_CONTEXT(px_arg_context   IN OUT NOCOPY arg_context)
   IS
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      --call the internal print_arg_context but don't allow it to fetch values
      INTERNAL_PRINT_ARG_CONTEXT(px_arg_context,
                                 FALSE,
                                 FALSE,
                                 l_return_status,
                                 l_return_msg);
   END;

   --Private, used for debug to print an arg list
   PROCEDURE PRINT_ARG_LIST(p_arg_list          IN OUT NOCOPY arg_list,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PRINT_ARG_LIST';

      k                 NUMBER;
      l_prev_init_flag  VARCHAR2(3);
      l_prev_val        VARCHAR2(4000);
      l_prev_valid_value_flag VARCHAR2(3);
      l_val             VARCHAR2(4000);
      l_ignore          VARCHAR2(128);

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      k := p_arg_list.FIRST;
      WHILE k IS NOT NULL LOOP
         fnd_oam_debug.log(1, l_ctxt, 'Arg Name(Permissions): '||p_arg_list(k).arg_name||'('||p_arg_list(k).permissions||')');

         --skip fetching the value since this is typically proceeded by a call to bind_args which does the gets
         IF p_arg_list(k).valid_value_flag = FND_API.G_TRUE THEN
            fnd_oam_debug.log(1, l_ctxt, 'Value: '||l_val);
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'Value: ?');
         END IF;

         k := p_arg_list.NEXT(k);
      END LOOP;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE FETCH_RUN_ARG_CONTEXT(p_run_id             IN NUMBER,
                                   x_arg_context        OUT NOCOPY arg_context,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_return_msg         OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'FETCH_RUN_ARG_CONTEXT';

      l_empty_arg_context       arg_context;
      l_arg_ctxt                arg_context;
      l_arg                     arg;

      l_arg_ids                         dbms_sql.number_table;
      l_arg_names                       dbms_sql.varchar2_table;
      l_initialized_success_flags       dbms_sql.varchar2_table;
      l_allow_override_source_flags     dbms_sql.varchar2_table;
      l_binding_enabled_flags           dbms_sql.varchar2_table;
      l_permissions                     dbms_sql.varchar2_table;
      l_write_policies                  dbms_sql.varchar2_table;
      l_datatypes                       dbms_sql.varchar2_table;
      l_valid_value_flags               dbms_sql.varchar2_table;
      l_canonical_values                long_varchar2_table;

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
      k                         NUMBER;
      l_ignore                  BOOLEAN;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- grab all the global and run args, global before run to allow run to override
      -- put both readable and writable args in the context
      SELECT arg_id, arg_name, initialized_success_flag, allow_override_source_flag, binding_enabled_flag, permissions, write_policy, datatype, valid_value_flag, canonical_value
         BULK COLLECT INTO l_arg_ids, l_arg_names, l_initialized_success_flags, l_allow_override_source_flags, l_binding_enabled_flags, l_permissions,
                           l_write_policies, l_datatypes, l_valid_value_flags, l_canonical_values
         FROM fnd_oam_dscram_args_b
         WHERE ((parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_GLOBAL) OR
                ((parent_type = FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RUN) AND
                 (parent_id = p_run_id)))
         AND enabled_flag = FND_API.G_TRUE
         ORDER BY parent_type ASC;

      k := l_arg_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         --add the arg to the context
         l_ignore := ADD_ARG_TO_CONTEXT(l_arg_ctxt,
                                        l_arg_ids(k),
                                        l_arg_names(k),
                                        l_initialized_success_flags(k),
                                        l_allow_override_source_flags(k),
                                        l_binding_enabled_flags(k),
                                        l_permissions(k),
                                        l_write_policies(k),
                                        l_datatypes(k),
                                        l_valid_value_flags(k),
                                        l_canonical_values(k));

         k := l_arg_ids.NEXT(k);
      END LOOP;

      IF FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_DIAGNOSTIC THEN
         --print the arg context and allow failures here to indicate an overall failure so
         --a diagnostic test can detect it
         internal_print_arg_context(l_arg_ctxt,
                                    TRUE,
                                    FALSE,
                                    l_return_status,
                                    l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            x_arg_context := l_empty_arg_context;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      ELSIF fnd_oam_debug.test(1, l_ctxt) THEN
         --try to print the arg context but don't init or fail if bad.
         print_arg_context(l_arg_ctxt);
      END IF;

      --return the context
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_arg_context := l_arg_ctxt;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_arg_context := l_empty_arg_context;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE FETCH_ARG_LIST(p_parent_type       IN VARCHAR2,
                            p_parent_id         IN NUMBER,
                            x_arg_list          OUT NOCOPY arg_list,
                            x_has_writable      OUT NOCOPY BOOLEAN,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'FETCH_ARG_LIST';

      l_arg             arg;
      l_arg_list        arg_list := arg_list();
      l_empty_arg_list  arg_list := arg_list();
      l_has_writable    BOOLEAN := FALSE;

      l_arg_ids                         dbms_sql.number_table;
      l_arg_names                       dbms_sql.varchar2_table;
      l_initialized_success_flags       dbms_sql.varchar2_table;
      l_allow_override_source_flags     dbms_sql.varchar2_table;
      l_binding_enabled_flags           dbms_sql.varchar2_table;
      l_permissions                     dbms_sql.varchar2_table;
      l_write_policies                  dbms_sql.varchar2_table;
      l_datatypes                       dbms_sql.varchar2_table;
      l_valid_value_flags               dbms_sql.varchar2_table;
      l_canonical_values                long_varchar2_table;

      k                         NUMBER;
      l_ignore                  BOOLEAN;
      l_arg_name                VARCHAR2(60);

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --get all the args attached to the specified parent type/id
      --includes an order_by clause to prevent deadlock which would be caused if two workers try to init
      --and bind the args in different orders.
      SELECT arg_id, arg_name, initialized_success_flag, allow_override_source_flag, binding_enabled_flag, permissions, write_policy, datatype, valid_value_flag, canonical_value
         BULK COLLECT INTO l_arg_ids, l_arg_names, l_initialized_success_flags, l_allow_override_source_flags, l_binding_enabled_flags, l_permissions,
                           l_write_policies, l_datatypes, l_valid_value_flags, l_canonical_values
         FROM fnd_oam_dscram_args_b
         WHERE parent_type = p_parent_type
         AND parent_id = p_parent_id
         AND enabled_flag = FND_API.G_TRUE
         ORDER BY arg_id ASC;

      --allocate the array
      l_arg_list.EXTEND(l_arg_ids.COUNT);

      --loop through the results
      k := l_arg_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         --create a representative 'arg' structure
         l_arg := INTERNAL_CREATE_ARG(l_arg_ids(k),
                                      l_arg_names(k),
                                      l_initialized_success_flags(k),
                                      l_allow_override_source_flags(k),
                                      l_binding_enabled_flags(k),
                                      l_permissions(k),
                                      l_write_policies(k),
                                      l_datatypes(k),
                                      l_valid_value_flags(k),
                                      l_canonical_values(k));

         --update our indicator variable if we found our condition
         IF IS_WRITABLE(l_arg) THEN
            l_has_writable := TRUE;
         END IF;

         --add the arg to the arg list
         l_arg_list(k) := l_arg;

         k := l_arg_ids.NEXT(k);
      END LOOP;

      --debug
      IF FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_DIAGNOSTIC THEN
         --print the arg list and allow failures here to indicate an overall failure so
         --a diagnostic test can detect it.  We don't get the values for args because it screws up
         --operations too much and bind_args will get them all when the time is right anyway.
         print_arg_list(l_arg_list,
                        l_return_status,
                        l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            x_arg_list := l_empty_arg_list;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      ELSIF fnd_oam_debug.test(1, l_ctxt) THEN
         --print the arg list
         print_arg_list(l_arg_list,
                        l_return_status,
                        l_return_msg);
      END IF;

      --return the final list
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_arg_list := l_arg_list;
      x_has_writable := l_has_writable;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Parent Type ('||p_parent_type||'), ID('||p_parent_id||'), while fetching arg list: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE BIND_ARG_LIST_TO_CURSOR(p_arg_list         IN OUT NOCOPY arg_list,
                                     px_arg_context     IN OUT NOCOPY arg_context,
                                     p_cursor_id        IN INTEGER,
                                     p_using_splitting  IN BOOLEAN,
                                     p_rowid_lbound     IN ROWID,
                                     p_rowid_ubound     IN ROWID,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'BIND_ARG_LIST_TO_CURSOR';

      k                         NUMBER;
      l_bindvar_name            VARCHAR2(120);
      l_varchar2                VARCHAR2(4000)  := NULL;
      l_number                  NUMBER          := NULL;
      l_date                    DATE            := NULL;
      l_rowid                   ROWID           := NULL;

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --traverse the arg list, everything that's readable MUST be bound, otherwise it wouldn't be in the list
      k := p_arg_list.FIRST;
      WHILE k IS NOT NULL LOOP

         --only bind args with binding enabled, these can be input and/or output args args
         IF p_arg_list(k).binding_enabled THEN

            --reset our placeholder vars so we don't carry over from the last arg
            l_varchar2 := NULL;
            l_number := NULL;
            l_date := NULL;
            l_rowid := NULL;

            fnd_oam_debug.log(1, l_ctxt, 'Binding Arg: '||p_arg_list(k).arg_name);

            --prep the name of the bind variable
            l_bindvar_name := ':'||p_arg_list(k).arg_name;

            --first do the fetch if its readable
            IF IS_READABLE(p_arg_list(k)) THEN
               CASE p_arg_list(k).datatype
                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2 THEN
                     --fetch
                     GET_ARG_VALUE(p_arg_list(k),
                                   px_arg_context,
                                   p_using_splitting,
                                   p_rowid_lbound,
                                   p_rowid_ubound,
                                   NULL,
                                   l_varchar2,
                                   l_return_status,
                                   l_return_msg);
                     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        fnd_oam_debug.log(1, l_ctxt, 'Value(VARCHAR2): '||l_varchar2);
                     ELSE
                        x_return_status := l_return_status;
                        x_return_msg := l_return_msg;
                        fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                        RETURN;
                     END IF;

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER THEN
                     --fetch
                     GET_ARG_VALUE(p_arg_list(k),
                                   px_arg_context,
                                   p_using_splitting,
                                   p_rowid_lbound,
                                   p_rowid_ubound,
                                   NULL,
                                   l_number,
                                   l_return_status,
                                   l_return_msg);
                     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        fnd_oam_debug.log(1, l_ctxt, 'Value(NUMBER): '||FND_NUMBER.NUMBER_TO_CANONICAL(l_number));
                     ELSE
                        --or fail
                        x_return_status := l_return_status;
                        x_return_msg := l_return_msg;
                        fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                        RETURN;
                     END IF;

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE THEN
                     --fetch
                     GET_ARG_VALUE(p_arg_list(k),
                                   px_arg_context,
                                   p_using_splitting,
                                   p_rowid_lbound,
                                   p_rowid_ubound,
                                   NULL,
                                   l_date,
                                   l_return_status,
                                   l_return_msg);
                     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        fnd_oam_debug.log(1, l_ctxt, 'Value(DATE): '||FND_DATE.DATE_TO_CANONICAL(l_date));
                     ELSE
                        --or fail
                        x_return_status := l_return_status;
                        x_return_msg := l_return_msg;
                        fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                        RETURN;
                     END IF;

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID THEN
                     --fetch
                     GET_ARG_VALUE_ROWID(p_arg_list(k),
                                         px_arg_context,
                                         p_using_splitting,
                                         p_rowid_lbound,
                                         p_rowid_ubound,
                                         NULL,
                                         l_rowid,
                                         l_return_status,
                                         l_return_msg);
                     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        fnd_oam_debug.log(1, l_ctxt, 'Value(ROWID): '||ROWIDTOCHAR(l_rowid));
                     ELSE
                        --or fail
                        x_return_status := l_return_status;
                        x_return_msg := l_return_msg;
                        fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                        RETURN;
                     END IF;
                  ELSE
                     x_return_msg := 'Arg ('||p_arg_list(k).arg_id||') has unknown datatype:'||p_arg_list(k).datatype;
                     fnd_oam_debug.log(6, l_ctxt, x_return_msg);
                     fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                     RETURN;
               END CASE;
            END IF;

            --even if we didn't get a value, do a binding - required for output args.
            BEGIN
               CASE p_arg_list(k).datatype
                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_VARCHAR2 THEN
                     DBMS_SQL.BIND_VARIABLE(p_cursor_id,
                                            l_bindvar_name,
                                            l_varchar2,
                                            4000);

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_NUMBER THEN
                     DBMS_SQL.BIND_VARIABLE(p_cursor_id,
                                            l_bindvar_name,
                                            l_number);

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_DATE THEN
                     DBMS_SQL.BIND_VARIABLE(p_cursor_id,
                                            l_bindvar_name,
                                            l_date);

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_DATATYPE_ROWID THEN
                     DBMS_SQL.BIND_VARIABLE_ROWID(p_cursor_id,
                                                  l_bindvar_name,
                                                  l_rowid);
                  ELSE
                     x_return_msg := 'Arg ('||p_arg_list(k).arg_id||') has unknown datatype:'||p_arg_list(k).datatype;
                     fnd_oam_debug.log(6, l_ctxt, x_return_msg);
                     fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                     RETURN;
               END CASE;
            EXCEPTION
               WHEN BIND_DOES_NOT_EXIST THEN
                  --catch a common error and provide better feedback.
                  fnd_oam_debug.log(1, l_ctxt, 'Arg ID('||p_arg_list(k).arg_id||'), Bindvar('||l_bindvar_name||') does not exist');
                  x_return_msg := 'Arg ID('||p_arg_list(k).arg_id||'), Bind Variable ('||l_bindvar_name||') failure: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
                  RETURN;
               WHEN OTHERS THEN
                  RAISE;
            END;

         END IF;

         k := p_arg_list.NEXT(k);
      END LOOP;

      --all bound, return success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE UPDATE_WRITABLE_ARG_VALUES(px_arg_list             IN OUT NOCOPY arg_list,
                                        px_arg_context          IN OUT NOCOPY arg_context,
                                        p_entity_finished       IN BOOLEAN,
                                        p_using_splitting       IN BOOLEAN,
                                        p_rowid_lbound          IN ROWID,
                                        p_rowid_ubound          IN ROWID,
                                        p_execution_cursor_id   IN INTEGER,
                                        x_return_status         OUT NOCOPY VARCHAR2,
                                        x_return_msg            OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'UPDATE_WRITABLE_ARG_VALUES';

      l_canonical_value         VARCHAR2(4000);
      l_force_store_autonomously        BOOLEAN := FALSE;

      k                         NUMBER;
      l_ignore                  VARCHAR2(128);

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --if we're in a non-normal mode, store the values we get autonomously to keep them from
      --getting rolled back
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_NORMAL THEN
         l_force_store_autonomously := TRUE;
      END IF;

      --loop through the arg list
      k := px_arg_list.FIRST;
      WHILE k IS NOT NULL LOOP
         --if the arg is writable, perform a get canonical value which does
         --an implicit store in an autonomous transaction.  If the arg has already read
         --a value then get will not replace it
         IF IS_WRITABLE(px_arg_list(k)) THEN
            --include an additional condition to keep ONCE/PER_WORKER args from being
            --executed until the arg is finished and execute PER_RANGE/ALWAYS when not finished or
            --we're finished and not using splitting.
            IF ((p_entity_finished AND
                 (NOT p_using_splitting OR
                  (px_arg_list(k).write_policy IN (FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ONCE,
                                                   FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_WORKER)))) OR
                (NOT p_entity_finished AND
                 (px_arg_list(k).write_policy IN (FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_PER_RANGE,
                                                  FND_OAM_DSCRAM_UTILS_PKG.G_WRITE_POLICY_ALWAYS)))) THEN

               GET_CANONICAL_ARG_VALUE(px_arg_list(k),
                                       px_arg_context,
                                       p_using_splitting,
                                       p_rowid_lbound,
                                       p_rowid_ubound,
                                       p_execution_cursor_id,
                                       l_force_store_autonomously,
                                       TRUE,
                                       TRUE,
                                       l_ignore,
                                       l_canonical_value,
                                       l_return_status,
                                       l_return_msg);
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
                  l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_MISSING_BINDS THEN

                  --if an arg failed to get a value, return it as an error, stop fetching other args
                  x_return_status := l_return_status;
                  x_return_msg := l_return_msg;
                  fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                  RETURN;
               ELSE
                  fnd_oam_debug.log(1, l_ctxt, 'Value: '||l_canonical_value);
               END IF;
            END IF;
         END IF;

         k := px_arg_list.NEXT(k);
      END LOOP;

      --return the final list
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE UPDATE_CONTEXT_USING_ARG_LIST(px_arg_context               IN OUT NOCOPY arg_context,
                                           p_arg_list                   IN arg_list,
                                           p_using_splitting            IN BOOLEAN)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'UPDATE_CONTEXT_USING_ARG_LIST';
      k                 NUMBER;
      l_arg_name        VARCHAR2(60);
      l_canonical_value VARCHAR2(4000);
      l_lock_handle     VARCHAR2(128) := NULL;
      l_retval          INTEGER;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --loop over each item in the arg list since its easier to lookup a match in the context
      k := p_arg_list.FIRST;
      WHILE k IS NOT NULL LOOP
         IF IS_READABLE(p_arg_list(k)) AND
            p_arg_list(k).valid_value_flag = FND_API.G_TRUE AND
            px_arg_context.EXISTS(p_arg_list(k).arg_name) THEN

            l_arg_name := p_arg_list(k).arg_name;
            -- do a cursory check of compatiblity before calling the context arg's get to check the db for its latest value
            IF (px_arg_context(l_arg_name).allow_override_source AND
                px_arg_context(l_arg_name).valid_value_flag IS NULL AND
                IS_WRITABLE(px_arg_context(l_arg_name)) AND
                p_arg_list(k).datatype = px_arg_context(l_arg_name).datatype) THEN

               --first fetch the latest value for the context arg without sourcing it and keeping the lock if we get one
               GET_CANONICAL_CTXT_ARG_VALUE(px_arg_context(l_arg_name),
                                            p_using_splitting,
                                            p_arg_list(k).rowid_lbound,
                                            p_arg_list(k).rowid_ubound,
                                            NULL,
                                            FALSE,
                                            FALSE,
                                            FALSE,
                                            l_lock_handle,
                                            l_canonical_value,
                                            l_return_status,
                                            l_return_msg);
               IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                  --the get should succeed without finding a valid value for us to default in the arg list's value
                  IF px_arg_context(l_arg_name).valid_value_flag IS NULL THEN
                     --this means we can default from the arg list
                     BEGIN
                        SET_STATE_ARG_VALUE(px_arg_context(l_arg_name),
                                            p_arg_list(k).canonical_value,
                                            p_arg_list(k).rowid_lbound,
                                            p_arg_list(k).rowid_ubound);
                        --and we should also store the context arg's new value
                        STORE_ARG_VALUE_AUTONOMOUSLY(px_arg_context(l_arg_name),
                                                     l_return_status,
                                                     l_return_msg);
                        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                           fnd_oam_debug.log(1, l_ctxt, 'Set the context arg to value: '||p_arg_list(k).canonical_value);
                        ELSE
                           --if we didn't store correctly, reset the context arg to unknown
                           px_arg_context(l_arg_name).valid_value_flag := NULL;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           --if the set or store fail, reset the context arg's value to unknown
                           px_arg_context(l_arg_name).valid_value_flag := NULL;
                     END;
                  ELSE
                     fnd_oam_debug.log(1, l_ctxt, 'Context already has value: '||l_canonical_value);
                  END IF;

                  --release the lock if we have one
                  IF l_lock_handle IS NOT NULL THEN
                     l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
                     IF l_retval <> 0 THEN
                        fnd_oam_debug.log(6, l_ctxt, 'Failed to release arg lock: '||l_retval);
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
         k := p_arg_list.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         --make sure there isn't a lock hanging around
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
            IF l_retval <> 0 THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to release arg lock: '||l_retval);
            END IF;
         END IF;

         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
   END;

   -- Public
   PROCEDURE DESTROY_ARG_LIST(px_arg_list               IN OUT NOCOPY arg_list,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_return_msg              OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DESTROY_ARG_LIST';

      k                         NUMBER;

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      k := px_arg_list.FIRST;
      WHILE k IS NOT NULL LOOP

         --close up the cursor if it exists
         IF px_arg_list(k).source_cursor_id IS NOT NULL AND
            DBMS_SQL.IS_OPEN(px_arg_list(k).source_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(px_arg_list(k).source_cursor_id);
         END IF;

         k := px_arg_list.NEXT(k);
      END LOOP;

      --delete the arg list
      px_arg_list.DELETE;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE DESTROY_ARG_CONTEXT(px_arg_context         IN OUT NOCOPY arg_context,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DESTROY_ARG_CONTEXT';

      l_s                       VARCHAR2(60);
      l_ignore                  VARCHAR2(128);
      l_canonical_value         VARCHAR2(4000);

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --go through the args
      l_s := px_arg_context.FIRST;
      WHILE l_s IS NOT NULL LOOP
         --if it's writable then try to let it store a value before we remove the arg
         IF IS_WRITABLE(px_arg_context(l_s)) THEN
            GET_CANONICAL_CTXT_ARG_VALUE(px_arg_context(l_s),
                                         FALSE,
                                         NULL,
                                         NULL,
                                         NULL,
                                         TRUE,
                                         TRUE,
                                         TRUE,
                                         l_ignore,
                                         l_canonical_value,
                                         l_return_status,
                                         l_return_msg);
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               fnd_oam_debug.log(1, l_ctxt, 'Arg('||l_s||'), stored final context value: '||l_canonical_value);
            END IF;
         END IF;

         --close up the arg's cursor if it exists
         IF px_arg_context(l_s).source_cursor_id IS NOT NULL AND
            DBMS_SQL.IS_OPEN(px_arg_context(l_s).source_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(px_arg_context(l_s).source_cursor_id);
         END IF;

         l_s := px_arg_context.NEXT(l_s);
      END LOOP;

      --delete the arg context
      px_arg_context.DELETE;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   -- Copied from FND_OAM_DS_PSETS_PKG, seems to mimic standard syntax of calls
   -- made from FND_TOP/sql/FNDNLINS.sql.
   PROCEDURE ADD_LANGUAGE
   IS
   BEGIN

      delete from FND_OAM_DSCRAM_ARGS_TL T
         where not exists
            (select NULL
             from FND_OAM_DSCRAM_ARGS_B B
             where B.ARG_ID = T.ARG_ID
             );

  update FND_OAM_DSCRAM_ARGS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FND_OAM_DSCRAM_ARGS_TL B
    where B.ARG_ID = T.ARG_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ARG_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ARG_ID,
      SUBT.LANGUAGE
    from FND_OAM_DSCRAM_ARGS_TL SUBB, FND_OAM_DSCRAM_ARGS_TL SUBT
    where SUBB.ARG_ID = SUBT.ARG_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FND_OAM_DSCRAM_ARGS_TL (
    ARG_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ARG_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_DSCRAM_ARGS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_DSCRAM_ARGS_TL T
    where T.ARG_ID = B.ARG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

   END ADD_LANGUAGE;

END FND_OAM_DSCRAM_ARGS_PKG;

/
