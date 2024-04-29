--------------------------------------------------------
--  DDL for Package Body ZPB_AW_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_AW_STATUS" AS
/* $Header: zpb_aw_status.plb 120.6 2007/12/04 14:40:40 mbhat ship $ */
G_PERSONAL_ALIAS_FLAG  VARCHAR2(1) := 'N';

------------------------------------------------------------------------------
-- RUN_QUERY (private)
--
-- Runs the actual query (p_sql) and sets the last query valuset (p_dimVset)
------------------------------------------------------------------------------
PROCEDURE RUN_QUERY (p_sql     IN CLOB,
                     p_dimVset IN VARCHAR2)
   IS
      l_text     DBMS_SQL.VARCHAR2S;
      l_cursor   INTEGER;
      l_member   VARCHAR2(60);
      l_members  VARCHAR2(4000);
      l_ignore1  INTEGER;
      l_ignore2  INTEGER;
      l_pos      INTEGER;
      l_length   INTEGER;
      l_count    INTEGER;
BEGIN
   l_length  := DBMS_LOB.GETLENGTH(p_sql);
   l_pos     := 1;
   l_count   := 0;
   l_members := null;
   while (l_pos <= l_length) loop
      l_text(l_count) := DBMS_LOB.SUBSTR(p_sql, 150, l_pos);
      l_count := l_count+1;
      l_pos   := l_pos+150;
   end loop;

   l_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_cursor, l_text, l_text.FIRST, l_text.LAST, FALSE,
                  DBMS_SQL.NATIVE);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_member, 60);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, l_ignore1);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 3, l_ignore2);
   l_ignore1 := DBMS_SQL.EXECUTE(l_cursor);
   loop
      exit when (DBMS_SQL.FETCH_ROWS(l_cursor) = 0);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_member);
      l_members := l_members||' '''||l_member||'''';
      if (length(l_members) > 3900) then
         zpb_aw.execute ('lmt '||p_dimVset||' add '||l_members);
         l_members := null;
      end if;
   end loop;
   if (l_members is not null) then
      zpb_aw.execute ('lmt '||p_dimVset||' add '||l_members);
   end if;
   DBMS_SQL.CLOSE_CURSOR(l_cursor);
END RUN_QUERY;

------------------------------------------------------------------------------
-- GET_STATUS
--
-- Takes a query defined in ZPB_SQL_STATUS and sets the status of the
-- LASTQUERYVS for each dimension defined in that query
--
-- IN: p_aw    - The AW the query is defined on
--     p_query - The query name
------------------------------------------------------------------------------
PROCEDURE GET_STATUS (p_aw    IN VARCHAR2,
                      p_query IN VARCHAR2)
   IS
      l_sql_statement CLOB;
      l_dimension     VARCHAR2(30);
      l_ecmDim        VARCHAR2(30);
      l_aw            VARCHAR2(30);
      l_awQual        VARCHAR2(30);
      l_member        VARCHAR2(60);
      l_pers          VARCHAR2(30);
      l_value         VARCHAR2(30);
      l_value2        VARCHAR2(30);
      l_members       VARCHAR2(4000);
      l_global_ecm    zpb_ecm.global_ecm;
      l_dim_ecm       zpb_ecm.dimension_ecm;


      TYPE QueryCursType IS REF CURSOR;
      queryCurs       QueryCursType;

  CURSOR queries IS
    SELECT status_sql_id, status_sql, dimension_name, hierarchy_name
       FROM zpb_status_sql
       WHERE (query_path = p_query)
       ORDER BY DIMENSION_NAME, ROW_NUM;
BEGIN
   if (instr (upper(p_aw), upper(zpb_aw.get_schema)||'.') = 0 and
       instr (upper(p_aw), 'ZPB') > 0) then
      l_aw := zpb_aw.get_schema||'.'||p_aw;
    else
      l_aw := p_aw;
   end if;

   --
   -- Store the personal AW and reset it if the AW is different
   --
   l_pers  := null;
   if (zpb_aw.interpbool('shw aw(attached ''PERSONAL'')')
       and instr(l_aw, '.')>0 and instr(l_aw, 'DATA')=0) then
      l_value := zpb_aw.eval_text('aw(name ''PERSONAL'')');
      if (l_value <> upper(l_aw)) then
         l_pers := l_value;
         if (zpb_aw.interpbool('shw aw(attached ''' || l_pers || ''')')) then
           zpb_aw.execute ('aw aliaslist '||l_pers||' unalias PERSONAL');
         end if;
         if (zpb_aw.interpbool('shw aw(attached ''' || l_aw || ''')')) then
           zpb_aw.execute ('aw aliaslist '||l_aw||' alias PERSONAL');
         end if;
         zpb_aw_status.set_personal_alias_flag();
         -- setting this flag so as aw.initialize is not called in get_limitmap

      end if;
   end if;

   l_awQual     := l_aw||'!';
   l_global_ecm := zpb_ecm.get_global_ecm (l_aw);
   zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                   ' remove all');
   l_dimension := '<NULL>';
   l_sql_statement := ' ';
   for each in queries loop
      if (l_dimension <> each.dimension_name and l_dimension <> '<NULL>') then
         l_ecmDim := zpb_aw.eval_text('lmt('||l_awQual||l_global_ecm.DimDim||
                                    ' to '||l_awQual||l_global_ecm.ExpObjVar||
                                    ' eq '''||l_dimension||''')');
         l_dim_ecm := zpb_ecm.get_dimension_ecm(l_ecmDim, l_aw);
         zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                         ' add '''||l_ecmDim||'''');

         zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LastQueryVS||
                         ' remove all');

         RUN_QUERY(l_sql_statement, l_awQual||l_dim_ecm.LastQueryVS);

         l_dimension     := each.dimension_name;
         l_sql_statement := each.status_sql;
       else
         l_dimension     := each.dimension_name;
         DBMS_LOB.WRITEAPPEND(l_sql_statement,
                              length(each.status_sql),
                              each.status_sql);
      end if;
   end loop;

   --
   -- Run last query:
   --
   --zpb_aw.execute ('CALL MD.VIEW.CMD.SET ('''||l_dimension||
   --                ''' '''||l_aw||''')');
   if (l_dimension <> '<NULL>') then
      l_ecmDim := zpb_aw.eval_text('lmt('||l_awQual||l_global_ecm.DimDim||
                                   ' to '||l_awQual||l_global_ecm.ExpObjVar||
                                   ' eq '''||l_dimension||''')');
      l_dim_ecm := zpb_ecm.get_dimension_ecm(l_ecmDim, l_aw);
      zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                      ' add '''||l_ecmDim||'''');

      zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LastQueryVS||' remove all');

      RUN_QUERY(l_sql_statement, l_awQual||l_dim_ecm.LastQueryVS);
    else
      ZPB_LOG.WRITE_EVENT ('zpb_aw_status.get_status',
                           'Could not find query: '||p_query);
   end if;
   --zpb_aw.execute ('CALL MD.VIEW.CMD.CLEANUP');
   if (l_pers is not null) then
     if (zpb_aw.interpbool('shw aw(attached ''' || l_aw || ''')')) then
       zpb_aw.execute ('aw aliaslist '||l_aw||' unalias PERSONAL');
     end if;
     if (zpb_aw.interpbool('shw aw(attached ''' || l_pers || ''')')) then
       zpb_aw.execute ('aw aliaslist '||l_pers||' alias PERSONAL');
     end if;
     zpb_aw_status.RESET_PERSONAL_ALIAS_FLAG();

   end if;

exception
   --
   -- Must cleanup and reset PERSONAL alias in case of crash
   --
   when others then
      if (l_pers is not null) then
        if (zpb_aw.interpbool('shw aw(attached ''' || l_aw || ''')')) then
          zpb_aw.execute ('aw aliaslist '||l_aw||' unalias PERSONAL');
        end if;
        if (zpb_aw.interpbool('shw aw(attached ''' || l_pers || ''')')) then
          zpb_aw.execute ('aw aliaslist '||l_pers||' alias PERSONAL');
        end if;
        zpb_aw_status.RESET_PERSONAL_ALIAS_FLAG();
      end if;

      ZPB_LOG.LOG_PLSQL_EXCEPTION('zpb_aw_status', 'get_status');
   RAISE;

END GET_STATUS;

------------------------------------------------------------------------------
-- REPLACE_EXCEPTION_OBJS
--
-- Function used by GET_EXCEPTION_STATUS to change the table and column names
-- in the query to the correct table (from the default exception view and
-- column names)
--
-- IN: p_sql     The SQL to convert
--     p_newView The view to point the SQL against
--     p_newCol  The column in the view to use
--
------------------------------------------------------------------------------
PROCEDURE REPLACE_EXCEPTION_OBJS (p_sql      IN OUT NOCOPY CLOB,
                                  p_sharedAW IN            VARCHAR2,
                                  p_newView  IN            VARCHAR2,
                                  p_newCol   IN            VARCHAR2)
   is
      l_excView       VARCHAR2(30);
      l_excCol        VARCHAR2(30);
      l_excViewLen    number;
      l_excColLen     number;
      i               number;
begin
   l_excView    := zpb_metadata_names.get_exception_check_tbl(p_sharedAw);
   l_excCol     := zpb_metadata_names.get_exception_column;
   l_excViewLen := length(l_excView);
   l_excColLen  := length(l_excCol);

   i := DBMS_LOB.INSTR(p_sql, l_excView);
   loop
      exit when i = 0;
      p_sql := DBMS_LOB.SUBSTR(p_sql, 1, i-1)||p_newView||DBMS_LOB.SUBSTR(p_sql, i+l_excViewLen);
      i := DBMS_LOB.INSTR(p_sql, l_excView, i);
   end loop;

   i:= DBMS_LOB.INSTR(p_sql, l_excCol);
   loop
      exit when i = 0;
      p_sql := DBMS_LOB.SUBSTR(p_sql, 1, i-1)||p_newCol||DBMS_LOB.SUBSTR(p_sql, i+l_excColLen);
      i := DBMS_LOB.INSTR(p_sql, l_excCol, i);
   end loop;

end REPLACE_EXCEPTION_OBJS;

------------------------------------------------------------------------------
-- GET_EXCEPTION_STATUS
--
-- Takes a query defined in ZPB_SQL_STATUS and sets the status of the
-- LASTQUERYVS for each dimension defined in that query.  Also sets the
-- LASTQUERYDIMVS structure for all dimensions affected by the query
--
-- This query is expected to be defined on the exception table. The instance
-- passed in will modify the SQL to be executed on the current instance view
-- of that instance/BP
--
-- IN: p_aw    - The AW the query is defined on
--     p_query - The query name
------------------------------------------------------------------------------
PROCEDURE GET_EXCEPTION_STATUS (p_user_id  IN VARCHAR2,
                                p_query    IN VARCHAR2,
                                p_instance IN VARCHAR2)
   is
      l_sql_statement CLOB;
      l_dimension     VARCHAR2(30);
      l_ecmDim        VARCHAR2(30);
      l_aw            VARCHAR2(30);
      l_schema        VARCHAR2(6);
      l_sharedAw      VARCHAR2(30);
      l_awQual        VARCHAR2(30);
      l_member        VARCHAR2(60);
      l_meas          VARCHAR2(30);
      l_newView       VARCHAR2(30);
      l_newCol        VARCHAR2(30);
      l_value         VARCHAR2(30);
      l_value2        VARCHAR2(30);
      l_members       VARCHAR2(4000);
      l_global_ecm    zpb_ecm.global_ecm;
      l_dim_ecm       zpb_ecm.dimension_ecm;

      TYPE QueryCursType IS REF CURSOR;
      queryCurs       QueryCursType;

  CURSOR queries IS
    SELECT status_sql_id, status_sql, dimension_name, hierarchy_name
       FROM zpb_status_sql
       WHERE (query_path = p_query)
       ORDER BY DIMENSION_NAME, ROW_NUM;
BEGIN
   l_aw         := zpb_aw.get_personal_aw(p_user_id);
   l_schema     := zpb_aw.get_schema||'.';
   l_sharedAw   := l_schema||zpb_aw.get_shared_aw;
   l_awQual     := l_schema||l_aw||'!';
   l_global_ecm := zpb_ecm.get_global_ecm (l_aw);

   l_meas    := zpb_aw.eval_text('CM.GETINSTOBJECT ('''||p_instance||
                                 ''' ''SHARED DATA OBJECT ID''');
   l_newCol  := zpb_aw.eval_text('SHARED!'||l_global_ecm.MeasColVar||
                                 ' (SHARED!MEASURE '''||l_meas||''')');
   l_newView := zpb_aw.eval_text('SHARED!'||l_global_ecm.MeasViewRel||
                                 ' (SHARED!MEASURE '''||l_meas||''')');

   zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                   ' remove all');

   l_dimension     := '<NULL>';
   l_sql_statement := ' ';
   for each in queries loop
      if (l_dimension <> each.dimension_name and l_dimension <> '<NULL>') then

         l_ecmDim := zpb_aw.eval_text('lmt('||l_awQual||l_global_ecm.DimDim||
                                     ' to '||l_awQual||l_global_ecm.ExpObjVar||
                                      ' eq '''||l_dimension||''')');
         l_dim_ecm := zpb_ecm.get_dimension_ecm(l_ecmDim, l_aw);

         zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                         ' add '''||l_ecmDim||'''');
         zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LastQueryVS||
                         ' remove all');

         REPLACE_EXCEPTION_OBJS(l_sql_statement,l_sharedAW,l_newView,l_newCol);
         RUN_QUERY(l_sql_statement, l_awQual||l_dim_ecm.LastQueryVS);

         l_dimension     := each.dimension_name;
         l_sql_statement := each.status_sql;
       else
         l_dimension     := each.dimension_name;
         DBMS_LOB.WRITEAPPEND(l_sql_statement,
                              length(each.status_sql),
                              each.status_sql);
      end if;
   end loop;

   --
   -- Run last query:
   --
   if (l_dimension <> '<NULL>') then
      l_ecmDim := zpb_aw.eval_text ('lmt('||l_awQual||l_global_ecm.DimDim||
                                    ' to '||l_awQual||l_global_ecm.ExpObjVar||
                                    ' eq '''||l_dimension||''')');
      l_dim_ecm := zpb_ecm.get_dimension_ecm(l_ecmDim, l_aw);
      zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                      ' add '''||l_ecmDim||'''');
      zpb_aw.execute ('lmt '||l_awQual||l_dim_ecm.LastQueryVS||' remove all');

      REPLACE_EXCEPTION_OBJS(l_sql_statement, l_sharedAW, l_newView, l_newCol);
      RUN_QUERY(l_sql_statement, l_awQual||l_dim_ecm.LastQueryVS);
    else
      ZPB_LOG.WRITE_EVENT ('zpb_aw_status.get_exception_status',
                           'Could not find query: '||p_query);
   end if;
end GET_EXCEPTION_STATUS;

------------------------------------------------------------------------------
-- GET_QUERY_DIMS
--
-- Sets the LastQueryDimVS for the dimensions that are part of the query
------------------------------------------------------------------------------
PROCEDURE GET_QUERY_DIMS (p_aw        IN VARCHAR2,
                          p_query     IN VARCHAR2)
   is
      l_ecmDim        VARCHAR2(30);
      l_aw            VARCHAR2(30);
      l_awQual        VARCHAR2(30);
      l_global_ecm    zpb_ecm.global_ecm;

      cursor dimensions is
         select distinct DIMENSION_NAME
            from ZPB_STATUS_SQL
            where (query_path = p_query);
begin

   if (instr (upper(p_aw), upper(zpb_aw.get_schema)||'.') = 0 and
       instr (upper(p_aw), 'ZPB') > 0) then
      l_aw := zpb_aw.get_schema||'.'||p_aw;
    else
      l_aw := p_aw;
   end if;

   l_awQual     := l_aw||'!';
   l_global_ecm := zpb_ecm.get_global_ecm (l_aw);
   zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                   ' remove all');

   for each in dimensions loop
      l_ecmDim := zpb_aw.eval_text('lmt('||l_awQual||l_global_ecm.DimDim||
                                   ' to '||l_awQual||l_global_ecm.ExpObjVar||
                                   ' eq '''||each.DIMENSION_NAME||''')');
      zpb_aw.execute ('lmt '||l_awQual||l_global_ecm.LastQueryDimsVS||
                      ' add '''||l_ecmDim||'''');
   end loop;

end GET_QUERY_DIMS;

------------------------------------------------------------------------------
-- GET_STATUS_COUNT
--
-- Returns the # of dimension members that are part of a particular query and
-- dimension.  p_dimension is the AW name of the dimension, like CCTR_ORGS
------------------------------------------------------------------------------
FUNCTION GET_STATUS_COUNT (p_aw        IN VARCHAR2,
                           p_query     IN VARCHAR2,
                           p_dimension IN VARCHAR2)
   return NUMBER
   is
      l_sql_statement VARCHAR2(32767);
      l_aw            VARCHAR2(30);
      l_pers          VARCHAR2(30);
      l_value         VARCHAR2(30);
      l_count         NUMBER;

      TYPE QueryCursType IS REF CURSOR;
      queryCurs       QueryCursType;

  CURSOR queries IS
    SELECT status_sql
       FROM zpb_status_sql
       WHERE (query_path = p_query)
       AND DIMENSION_NAME = p_dimension
       ORDER BY ROW_NUM;
BEGIN
   dbms_aw.execute ('call cm.log(''moo'' 2 '''||p_aw||': '||p_query||': '||p_dimension||''')');
   dbms_aw.execute ('call cm.log(''moo'' 2 '''||sys_context('ZPB_CONTEXT', 'business_area_id')||''')');
   if (instr (upper(p_aw), upper(zpb_aw.get_schema)||'.') = 0 and
       instr (upper(p_aw), 'ZPB') > 0) then
      l_aw := zpb_aw.get_schema||'.'||p_aw;
    else
      l_aw := p_aw;
   end if;

   --
   -- Store the personal AW and reset it if the AW is different
   --
   l_pers  := null;
   if (zpb_aw.interpbool('shw aw(attached ''PERSONAL'')')
       and instr(l_aw, '.')>0 and instr(l_aw, 'DATA')=0) then
      l_value := zpb_aw.eval_text('aw(name ''PERSONAL'')');
      if (l_value <> upper(l_aw)) then
         l_pers := l_value;
         if (zpb_aw.interpbool('shw aw(attached '''||l_pers||''')')) then
           zpb_aw.execute ('aw aliaslist '||l_pers||' unalias PERSONAL');
         end if;
         if (zpb_aw.interpbool('shw aw(attached '''||l_aw||''')')) then
           zpb_aw.execute ('aw aliaslist '||l_aw||' alias PERSONAL');
         end if;
         zpb_aw_status.set_personal_alias_flag();
         -- setting this flag so as aw.initialize is not called in get_limitmap

      end if;
   end if;

   l_count := 0;
   l_sql_statement := 'select count(*) from (';
   for each in queries loop
      l_count := l_count + 1;
      l_sql_statement := l_sql_statement||each.status_sql;
   end loop;

   if (l_count > 0) then
      open queryCurs for l_sql_statement||')';
      fetch queryCurs into l_count;
      close queryCurs;
   end if;

   --zpb_aw.execute ('CALL MD.VIEW.CMD.CLEANUP');
   if (l_pers is not null) then
      if (zpb_aw.interpbool('shw aw(attached '''||l_aw||''')')) then
        zpb_aw.execute ('aw aliaslist '||l_aw||' unalias PERSONAL');
      end if;
      if (zpb_aw.interpbool('shw aw(attached '''||l_pers||''')')) then
        zpb_aw.execute ('aw aliaslist '||l_pers||' alias PERSONAL');
      end if;
      zpb_aw_status.RESET_PERSONAL_ALIAS_FLAG();
   end if;

   return l_count;

exception
   --
   -- Must cleanup and reset PERSONAL alias in case of crash
   --
   when others then
      if (l_pers is not null) then
         if (zpb_aw.interpbool('shw aw(attached '''||l_aw||''')')) then
           zpb_aw.execute ('aw aliaslist '||l_aw||' unalias PERSONAL');
         end if;
         if (zpb_aw.interpbool('shw aw(attached '''||l_pers||''')')) then
           zpb_aw.execute ('aw aliaslist '||l_pers||' alias PERSONAL');
         end if;
         zpb_aw_status.RESET_PERSONAL_ALIAS_FLAG();
      end if;

      ZPB_LOG.LOG_PLSQL_EXCEPTION('zpb_aw_status', 'get_status');
      RAISE;
   return -1;

end GET_STATUS_COUNT;

PROCEDURE SET_PERSONAL_ALIAS_FLAG
is
begin
   G_PERSONAL_ALIAS_FLAG := 'Y';
 end SET_PERSONAL_ALIAS_FLAG;

PROCEDURE RESET_PERSONAL_ALIAS_FLAG
is
begin
   G_PERSONAL_ALIAS_FLAG := 'N';
   end RESET_PERSONAL_ALIAS_FLAG;


FUNCTION GET_PERSONAL_ALIAS_FLAG  return VARCHAR2
as
begin
   RETURN G_PERSONAL_ALIAS_FLAG ;
   end GET_PERSONAL_ALIAS_FLAG;



END ZPB_AW_STATUS;

/
