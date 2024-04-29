--------------------------------------------------------
--  DDL for Package Body XLA_TRANSACTION_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TRANSACTION_ID_PKG" AS
-- $Header: xlacmtid.pkb 120.19.12010000.2 2008/12/11 11:18:50 vvekrish ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_transaction_id_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     This package provides routines to handle transaction identifiers.      |
|                                                                            |
| HISTORY                                                                    |
|     10/07/2002  S. Singhania    Created                                    |
|     11/30/2002  S. Singhania    Added code to test the validity of the     |
|                                   view and its columns in the database     |
|                                 Added p_request_id parameter to            |
|                                   get_query_string.                        |
|     12/12/2002  S. Singhania    Added EVT.ENTITY_ID in the select          |
|                                   string that is returned back from        |
|                                   function GET_QUERY_STRING                |
|     06/26/2003  S. Singhania    Removed the code that refers the table     |
|                                   XLA_ACCOUNTING_LOG. This was not         |
|                                   needed as events are marked with         |
|                                   parent request_id of accounting prog     |
|                                   rather than the child's request_id.      |
|     07/22/2003  S. Singhania    Added dbdrv command to the file            |
|     08/27/2003  S. Singhania    Replaced the funtion with the procedure    |
|                                   GET_QUERY_STRINGS so that the report     |
|                                   XLAACCPB.rdf can use this procedure to   |
|                                   build its query. bug # 3113574           |
|     10/13/2003  S. Singhania    Added NOCOPY hint to OUT parameters in     |
|                                   GET_QUERY_STRINGS                        |
|     03/24/2004  S. Singhania    Added local trace procedure and added      |
|                                   FND_LOG messages.                        |
|                                 Bug 3389175. Added a condition to perform  |
|                                   outerjoin to the Trx id view if fnd log  |
|                                   is enabled.                              |
|     06/27/2005  W. Shen         Bug 4447717. directly return if no         |
|                                   transaction identifier                   |
|     07/20/2005  W. Shen         Change the get_transcation_identifiers     |
|                                   from procedure to function to return     |
|                                   some error result so it can be processed |
|                                   0-- success                              |
|                                   1-- fail                                 |
|     12/30/2005  W. Chan         Bug 4908407. Make user transaction date    |
|                                   timezone converted.                      |
|     02/27/2006  V. Kumar        Bug 5013132 Using bind variable in Execute |
|                                   Immediate of l_sql_str                   |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring types
-------------------------------------------------------------------------------

TYPE t_rec IS RECORD
    (f1               VARCHAR2(80)
    ,f2               VARCHAR2(30)
    ,f3               VARCHAR2(240)
    ,f4               VARCHAR2(30));
TYPE t_array IS TABLE OF t_rec INDEX BY BINARY_INTEGER;


--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_transaction_id_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_transaction_id_pkg.trace');
END trace;


--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following are public routines
--
--    1.    get_query_strings
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

--=============================================================================
--
--
--
--=============================================================================

PROCEDURE get_query_strings
       (p_application_id         IN INTEGER
       ,p_entity_code            IN VARCHAR2
       ,p_event_class_code       IN VARCHAR2
       ,p_reporting_view_name    IN VARCHAR2
       ,p_request_id             IN NUMBER
       ,p_select_str             OUT NOCOPY VARCHAR2
       ,p_from_str               OUT NOCOPY VARCHAR2
       ,p_where_str              OUT NOCOPY VARCHAR2) IS
CURSOR cols_csr IS
   (SELECT xid.transaction_id_col_name_1   trx_col_1
          ,xid.transaction_id_col_name_2   trx_col_2
          ,xid.transaction_id_col_name_3   trx_col_3
          ,xid.transaction_id_col_name_4   trx_col_4
          ,xid.source_id_col_name_1        src_col_1
          ,xid.source_id_col_name_2        src_col_2
          ,xid.source_id_col_name_3        src_col_3
          ,xid.source_id_col_name_4        src_col_4
          ,xem.column_name                 column_name
          ,xem.column_title                prompt
          ,utc.data_type                   data_type
      FROM xla_entity_id_mappings   xid
          ,xla_event_mappings_vl    xem
          ,user_tab_columns         utc
     WHERE xid.application_id       = p_application_id
       AND xid.entity_code          = p_entity_code
       AND xem.application_id       = p_application_id
       AND xem.entity_code          = p_entity_code
       AND xem.event_class_code     = p_event_class_code
       AND utc.table_name           = p_reporting_view_name
       AND utc.column_name          = xem.column_name)
     ORDER BY xem.user_sequence;

l_col_array                t_array;
l_null_col_array           t_array;
l_col_string               VARCHAR2(4000)   := NULL;
l_view_name                VARCHAR2(80);
l_join_string              VARCHAR2(4000)   := NULL;
l_sql_string               VARCHAR2(4000);
l_index                    INTEGER;
l_outerjoin                VARCHAR2(30);
l_log_module               VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_query_strings';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_QUERY_STRINGS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_entity_code = '||p_entity_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_reporting_view_name = '||p_reporting_view_name
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_request_id = '||p_request_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   ----------------------------------------------------------------------------
   -- creating a dummy array that contains "NULL" strings
   ----------------------------------------------------------------------------
   FOR i IN 1..10 LOOP
      l_null_col_array(i).f1 := 'NULL';
      l_null_col_array(i).f2 := 'NULL';
      l_null_col_array(i).f3 := 'NULL';
      l_null_col_array(i).f4 := 'NULL';
   END LOOP;

   ----------------------------------------------------------------------------
   -- initiating the array that contains name of the columns to be selected
   -- from the TID View.
   ----------------------------------------------------------------------------
   l_col_array := l_null_col_array;

   ----------------------------------------------------------------------------
   -- creating SELECT,FROM and WHERE clause strings when the reporting view is
   -- defined for an Event Class.
   ----------------------------------------------------------------------------
   IF p_reporting_view_name IS NOT NULL THEN
      -------------------------------------------------------------------------
      -- creating string to be added to FROM clause
      -------------------------------------------------------------------------
      l_view_name   := ',' || p_reporting_view_name || '    TIV';

      l_index := 0;
      FOR c1 IN cols_csr LOOP
         l_index := l_index + 1;

         ----------------------------------------------------------------------
         -- creating string to be added to WHERE clause
         ----------------------------------------------------------------------
         IF l_index = 1 THEN
            -------------------------------------------------------------------
            -- Bug 3389175
            -- Following logic is build to make sure all events are reported
            -- if debug is enabled evenif there is no data for the event in the
            -- transaction id view.
            -- if log enabled  then
            --        outer join to TID view
            -- endif
            -------------------------------------------------------------------
            IF g_log_level <> C_LEVEL_LOG_DISABLED THEN
               l_outerjoin := '(+)';
            ELSE
               l_outerjoin := NULL;
            END IF;

            IF c1.trx_col_1 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_1 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_1;
            END IF;
            IF c1.trx_col_2 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_2 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_2;
            END IF;
            IF c1.trx_col_3 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_3 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_3;
            END IF;
            IF c1.trx_col_4 IS NOT NULL THEN
               l_join_string := l_join_string ||
                                ' AND TIV.'|| c1.trx_col_4 ||l_outerjoin ||
                                ' = ENT.'|| c1.src_col_4;
            END IF;
         END IF;

         ----------------------------------------------------------------------
         -- getting the PROMPTs to be displayed
         ----------------------------------------------------------------------
         --l_col_array(l_index).f1 := ''''||c1.prompt||'''';
         l_col_array(l_index).f1 := ''''||REPLACE (c1.PROMPT, '''', '''''')||'''';  -- bug 7636128

         ----------------------------------------------------------------------
         -- getting the columns to be displayed
         ----------------------------------------------------------------------
         IF c1.data_type = 'NUMBER' THEN
            l_col_array(l_index).f2 := 'TIV.'|| c1.column_name;
         ELSIF c1.data_type = 'VARCHAR2' THEN
            l_col_array(l_index).f3 := 'TIV.'|| c1.column_name;
         ELSIF c1.data_type = 'DATE' THEN
            l_col_array(l_index).f4 := 'TIV.'|| c1.column_name;
         END IF;
      END LOOP;
   END IF;

  -----------------------------------------------------------------------------
  -- building the string to be added to the SELECT clause
  -----------------------------------------------------------------------------
   FOR i IN 1..l_col_array.count LOOP
      l_col_string := l_col_string || ',' ||
                      l_col_array(i).f1||'   prompt_'    ||TO_CHAR(i)||','||
                      l_col_array(i).f2||'   value_num_' ||TO_CHAR(i)||','||
                      l_col_array(i).f3||'   value_char_'||TO_CHAR(i)||','||
                      l_col_array(i).f4||'   value_date_'||TO_CHAR(i);
   END LOOP;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_col_string = '||l_col_string
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;
  -----------------------------------------------------------------------------
  -- Following tests whether the view and columns are defined in the data base
  -----------------------------------------------------------------------------
   IF p_reporting_view_name IS NOT NULL THEN
      BEGIN
         ----------------------------------------------------------------------
         -- build and execute a dummy query if the view name is defined for
         -- the class
         -- NOTE: following never fails because the cursor joins to
         -- user_tab_columns table that will make sure that view and column
         -- names fetched exists. This can beremoved unless we decide to go
         -- for outerjoin on this table.
         ----------------------------------------------------------------------
         l_sql_string :=
            '  SELECT'                                         ||
            '  NULL                        dummy'              ||
            l_col_string                                       ||
            '  FROM'                                           ||
            '  dual                        dual'               ||
            l_view_name                                        ||
            '  WHERE'                                          ||
            '  ROWNUM = 1';

         EXECUTE IMMEDIATE l_sql_string;
      EXCEPTION
      WHEN OTHERS THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'Technical Warning: There seems to a problem in retreiving '||
                              'transaction identifiers from '||p_reporting_view_name
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
         END IF;

         ----------------------------------------------------------------------
         -- if the above query raises an exception following clears the FROM
         -- and WHERE strings and creates the error to be displayed to the user
         ----------------------------------------------------------------------
         l_col_array       := l_null_col_array;
         l_col_string      := NULL;
         l_col_array(1).f1 := '''Error''';
         l_col_array(1).f3 := '''Problem with Transaction Identifier View''';
         l_view_name       := NULL;
         l_join_string     := NULL;

         FOR i IN 1..l_col_array.count LOOP
            l_col_string := l_col_string || ',' ||
                            l_col_array(i).f1||'   prompt_'    ||TO_CHAR(i)||','||
                            l_col_array(i).f2||'   value_num_' ||TO_CHAR(i)||','||
                            l_col_array(i).f3||'   value_char_'||TO_CHAR(i)||','||
                            l_col_array(i).f4||'   value_date_'||TO_CHAR(i);
         END LOOP;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => 'l_col_string = '||l_col_string
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END IF;
      END;
   END IF;

   p_select_str := l_col_string;
   p_from_str   := l_view_name;
   p_where_str  := l_join_string;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_select_str = '||p_select_str
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_from_str = '||p_from_str
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_where_str = '||p_where_str
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'End of procedure GET_QUERY_STRINGS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_ss_transaction_id_pkg.get_query_strings');
END get_query_strings;


--=============================================================================
--
--
--
--=============================================================================
FUNCTION get_transaction_identifiers(
      p_application_id in INTEGER,
      p_entity_code in VARCHAR2,
      p_event_class_code in VARCHAR2,
      p_event_id in INTEGER,
      p_transactionid1_prompt out NOCOPY VARCHAR2,
      p_transactionid1_value out NOCOPY VARCHAR2,
      p_transactionid2_prompt out NOCOPY VARCHAR2,
      p_transactionid2_value out NOCOPY VARCHAR2,
      p_transactionid3_prompt out NOCOPY VARCHAR2,
      p_transactionid3_value out NOCOPY VARCHAR2,
      p_transactionid4_prompt out NOCOPY VARCHAR2,
      p_transactionid4_value out NOCOPY VARCHAR2,
      p_transactionid5_prompt out NOCOPY VARCHAR2,
      p_transactionid5_value out NOCOPY VARCHAR2,
      p_transactionid6_prompt out NOCOPY VARCHAR2,
      p_transactionid6_value out NOCOPY VARCHAR2,
      p_transactionid7_prompt out NOCOPY VARCHAR2,
      p_transactionid7_value out NOCOPY VARCHAR2,
      p_transactionid8_prompt out NOCOPY VARCHAR2,
      p_transactionid8_value out NOCOPY VARCHAR2,
      p_transactionid9_prompt out NOCOPY VARCHAR2,
      p_transactionid9_value out NOCOPY VARCHAR2,
      p_transactionid10_prompt out NOCOPY VARCHAR2,
      p_transactionid10_value out NOCOPY VARCHAR2)  return NUMBER is

l_reporting_view_name xla_event_class_attrs.reporting_view_name%TYPE;
CURSOR cols_csr IS
   (SELECT xid.transaction_id_col_name_1   trx_col_1
          ,xid.transaction_id_col_name_2   trx_col_2
          ,xid.transaction_id_col_name_3   trx_col_3
          ,xid.transaction_id_col_name_4   trx_col_4
          ,xid.source_id_col_name_1        src_col_1
          ,xid.source_id_col_name_2        src_col_2
          ,xid.source_id_col_name_3        src_col_3
          ,xid.source_id_col_name_4        src_col_4
          ,xem.column_name                 column_name
          ,xem.column_title                prompt
          ,utc.data_type                   data_type
      FROM xla_entity_id_mappings   xid
          ,xla_event_mappings_vl    xem
          ,user_tab_columns         utc
     WHERE xid.application_id       = p_application_id
       AND xid.entity_code          = p_entity_code
       AND xem.application_id       = p_application_id
       AND xem.entity_code          = p_entity_code
       AND xem.event_class_code     = p_event_class_code
       AND utc.table_name           = l_reporting_view_name
       AND utc.column_name          = xem.column_name)
     ORDER BY xem.user_sequence;

l_col_array                t_array;
l_null_col_array           t_array;
l_col_string               VARCHAR2(4000)   := NULL;
l_view_name                VARCHAR2(80);
l_join_string              VARCHAR2(4000)   := NULL;
l_sql_string               VARCHAR2(4000);
l_index                    INTEGER;
l_server_timezone_id       INTEGER;
l_client_timezone_id       INTEGER;
l_date_format              VARCHAR2(80);
l_log_module               VARCHAR2(240);
Begin
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_transaction_identifiers';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of procedure GET_TRANSACTION_IDENTIFIERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_application_id = '||p_application_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_entity_code = '||p_entity_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

  select reporting_view_name
  into   l_reporting_view_name
  from   xla_event_class_attrs
  where  application_id=p_application_id
         and entity_code=p_entity_code
         and event_class_code=p_event_class_code;
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'l_reporting_vie_name:'||l_reporting_view_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
  ----------------------------------------------------------------------------
  -- creating a dummy array that contains "NULL" strings
  ----------------------------------------------------------------------------
  FOR i IN 1..10 LOOP
    l_null_col_array(i).f1 := '';
    l_null_col_array(i).f2 := 'NULL';
    l_null_col_array(i).f3 := 'NULL';
    l_null_col_array(i).f4 := 'NULL';
  END LOOP;

  ----------------------------------------------------------------------------
  -- initiating the array that contains name of the columns to be selected
  -- from the TID View.
  ----------------------------------------------------------------------------
  l_col_array := l_null_col_array;

  ----------------------------------------------------------------------------
  -- Get information for timezone conversion
  ----------------------------------------------------------------------------
  l_server_timezone_id := fnd_profile.value('SERVER_TIMEZONE_ID');
  l_client_timezone_id := fnd_profile.value('CLIENT_TIMEZONE_ID');
  l_date_format := fnd_profile.value('ICX_DATE_FORMAT_MASK');

  ----------------------------------------------------------------------------
  -- creating SELECT,FROM and WHERE clause strings when the reporting view is
  -- defined for an Event Class.
  ----------------------------------------------------------------------------
  IF l_reporting_view_name IS NOT NULL THEN
    -------------------------------------------------------------------------
    -- creating string to be added to FROM clause
    -------------------------------------------------------------------------
    l_view_name   := ', ' || l_reporting_view_name || '    TIV';

    l_index := 0;
    FOR c1 IN cols_csr LOOP
      l_index := l_index + 1;

      ----------------------------------------------------------------------
      -- creating string to be added to WHERE clause
      ----------------------------------------------------------------------
      IF l_index = 1 THEN
        IF c1.trx_col_1 IS NOT NULL THEN
          l_join_string := l_join_string || ' AND TIV.'|| c1.trx_col_1 ||
                                ' = ENT.'|| c1.src_col_1;
        END IF;
        IF c1.trx_col_2 IS NOT NULL THEN
          l_join_string := l_join_string || ' AND TIV.'|| c1.trx_col_2 ||
                                ' = ENT.'|| c1.src_col_2;
        END IF;
        IF c1.trx_col_3 IS NOT NULL THEN
          l_join_string := l_join_string || ' AND TIV.'|| c1.trx_col_3 ||
                                ' = ENT.'|| c1.src_col_3;
        END IF;
        IF c1.trx_col_4 IS NOT NULL THEN
          l_join_string := l_join_string || ' AND TIV.'|| c1.trx_col_4 ||
                              ' = ENT.'|| c1.src_col_4;
        END IF;
      END IF;

      ----------------------------------------------------------------------
      -- getting all the PROMPTs to be displayed
      ----------------------------------------------------------------------
      l_col_array(l_index).f1 := c1.prompt;

      ----------------------------------------------------------------------
      -- getting all the columns to be displayed
      ----------------------------------------------------------------------
      IF c1.data_type = 'VARCHAR2' THEN
        l_col_array(l_index).f3 := 'TIV.'|| c1.column_name;
      ELSIF c1.data_type = 'DATE' THEN
        IF(l_server_timezone_id is null or l_client_timezone_id is null) THEN
          l_col_array(l_index).f3 := 'to_char(TIV.'|| c1.column_name||', '''||l_date_format||' HH24:MI:SS'')';
        ELSE
          l_col_array(l_index).f3 := 'to_char(HZ_TIMEZONE_PUB.Convert_DateTime('||l_server_timezone_id
                                                     ||','||l_client_timezone_id
                                                     ||', TIV.'|| c1.column_name||'), '''||l_date_format||' HH24:MI:SS'')';
        END IF;
      ELSE
        l_col_array(l_index).f3 := 'to_char(TIV.'|| c1.column_name||')';
      END IF;
    END LOOP;
  END IF;

  IF(l_index = 0) THEN
    p_transactionid1_value:=null;
    p_transactionid2_value:=null;
    p_transactionid3_value:=null;
    p_transactionid4_value:=null;
    p_transactionid5_value:=null;
    p_transactionid6_value:=null;
    p_transactionid7_value:=null;
    p_transactionid8_value:=null;
    p_transactionid9_value:=null;
    p_transactionid10_value:=null;
    p_transactionid1_prompt:=null;
    p_transactionid2_prompt:=null;
    p_transactionid3_prompt:=null;
    p_transactionid4_prompt:=null;
    p_transactionid5_prompt:=null;
    p_transactionid6_prompt:=null;
    p_transactionid7_prompt:=null;
    p_transactionid8_prompt:=null;
    p_transactionid9_prompt:=null;
    p_transactionid10_prompt:=null;
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'no transaction identifiers, return'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;
    return 0;
  END IF;

  -----------------------------------------------------------------------------
  -- building the string to be added to the SELECT clause
  -----------------------------------------------------------------------------
  l_col_string:=l_col_array(1).f3||' value_1';
  FOR i IN 2..l_col_array.count LOOP
    l_col_string := l_col_string || ',' ||
                      l_col_array(i).f3||' value_'||TO_CHAR(i);
  END LOOP;

  -----------------------------------------------------------------------------
  -- Following tests whether the view and columns are defined in the data base
  -----------------------------------------------------------------------------
  IF l_reporting_view_name IS NOT NULL THEN
  BEGIN
    ----------------------------------------------------------------------
    -- build and execute a dummy query if the view name is defined for
    -- the class
    ----------------------------------------------------------------------
    l_sql_string :=
            '  SELECT'                                         ||
            '  NULL                        dummy, '             ||
            l_col_string                                       ||
            '  FROM'                                           ||
            '  dual                        dual'               ||
            l_view_name                                        ||
            '  WHERE'                                          ||
            '  ROWNUM = 1';
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'dummy query:'||substr(l_sql_string, 1, 1000)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'query:'||substr(l_sql_string, 1001, 1000)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'query:'||substr(l_sql_string, 2001, 1000)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'query:'||substr(l_sql_string, 3001, 990)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

    EXECUTE IMMEDIATE l_sql_string;
  EXCEPTION
    WHEN OTHERS THEN
      ----------------------------------------------------------------------
      -- if the above query raises an exception following clears the FROM
      -- and WHERE strings and creates the error to be displayed to the user
      ----------------------------------------------------------------------
      l_col_array       := l_null_col_array;
      l_col_string      := NULL;
      l_col_array(1).f1 := '''Error''';
      l_col_array(1).f3 := '''Problem with Transaction Identifier View''';
      l_view_name       := NULL;
      l_join_string     := NULL;
      l_col_string:=l_col_array(1).f3||' value_1';
      FOR i IN 2..l_col_array.count LOOP
        l_col_string := l_col_string || ',' ||
                            l_col_array(i).f3||'   value_char_'||TO_CHAR(i);
      END LOOP;
  END;
  END IF;

  -----------------------------------------------------------------------------
  -- build the actual query
  -----------------------------------------------------------------------------
  l_sql_string :=
      ' SELECT '                                         ||
      l_col_string                                       ||
      '  FROM'                                           ||
      '  xla_events                  evt'                ||
      ' ,xla_transaction_entities    ent'                ||
      l_view_name                                        ||
      '  WHERE'                                          ||
      '  evt.event_id           =  :1 '                  ||
      '  and evt.application_id =  :2 '                  ||
      '  and ent.entity_id      = evt.entity_id'         ||
      '  and ent.application_id = evt.application_id '   ||
      l_join_string;
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'query:'||substr(l_sql_string, 1, 1000)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'query:'||substr(l_sql_string, 1001, 1000)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'query:'||substr(l_sql_string, 2001, 1000)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'query:'||substr(l_sql_string, 3001, 990)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  begin
    EXECUTE IMMEDIATE l_sql_string into
          p_transactionid1_value,
          p_transactionid2_value,
          p_transactionid3_value,
          p_transactionid4_value,
          p_transactionid5_value,
          p_transactionid6_value,
          p_transactionid7_value,
          p_transactionid8_value,
          p_transactionid9_value,
          p_transactionid10_value
    USING p_event_id
         ,p_application_id;
    exception
      when NO_DATA_FOUND then
      -- if no data found, we just show the prompt, no data
        null;
      when TOO_MANY_ROWS THEN
        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace
              (p_msg      => 'end with too many rows'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);
        END IF;
        return 1;
  end;

  p_transactionid1_prompt:=l_col_array(1).f1;
  p_transactionid2_prompt:=l_col_array(2).f1;
  p_transactionid3_prompt:=l_col_array(3).f1;
  p_transactionid4_prompt:=l_col_array(4).f1;
  p_transactionid5_prompt:=l_col_array(5).f1;
  p_transactionid6_prompt:=l_col_array(6).f1;
  p_transactionid7_prompt:=l_col_array(7).f1;
  p_transactionid8_prompt:=l_col_array(8).f1;
  p_transactionid9_prompt:=l_col_array(9).f1;
  p_transactionid10_prompt:=l_col_array(10).f1;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'p_transactionid1_prompt = '||p_transactionid1_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid1_value = '||p_transactionid1_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid2_prompt = '||p_transactionid2_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid2_value = '||p_transactionid2_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid3_prompt = '||p_transactionid3_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid3_value = '||p_transactionid3_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid4_prompt = '||p_transactionid4_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid4_value = '||p_transactionid4_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid5_prompt = '||p_transactionid5_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid5_value = '||p_transactionid5_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid6_prompt = '||p_transactionid6_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid6_value = '||p_transactionid6_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid7_prompt = '||p_transactionid7_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid7_value = '||p_transactionid7_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid8_prompt = '||p_transactionid8_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid8_value = '||p_transactionid8_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid9_prompt = '||p_transactionid9_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid9_value = '||p_transactionid9_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid10_prompt = '||p_transactionid10_prompt
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_transactionid10_value = '||p_transactionid10_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of procedure GET_TRANSACTION_IDENTIFIERS'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   return 0;
EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_transaction_id_pkg.get_transaction_identifiers');
end get_transaction_identifiers;


--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_transaction_id_pkg;

/
