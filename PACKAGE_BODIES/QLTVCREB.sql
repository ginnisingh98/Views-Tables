--------------------------------------------------------
--  DDL for Package Body QLTVCREB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTVCREB" AS
/* $Header: qltvcreb.plb 120.6.12010000.2 2008/09/15 09:37:29 ntungare ship $ */

-- executes a sql statement dynamically

-- A constant to fool GSCC.  See bug 3554899
-- bso Wed Apr  7 22:27:11 PDT 2004
    g_period CONSTANT VARCHAR2(1) := '.';

--
-- The following set functions is an effort to extend the capability
-- of the global_view procedure, so it can handle view definitions
-- longer than 32K, the previous hard limit (because of PL/SQL varchar2
-- string limit). Now, the DBMS_SQL.Varchar2s type is used for storing
-- the view definition.  This is a table and is the data type used by
-- AD_DDL.DO_ARRAY_DDL.
--
-- April 22, 1998.  bso
--

    --
    -- Apps schema info
    --
    g_dummy           BOOLEAN;
    g_fnd             CONSTANT VARCHAR2(3) := 'FND';
    g_status          VARCHAR2(1);
    g_industry        VARCHAR2(10);
    g_schema          VARCHAR2(30);

/*
PROCEDURE table_print(A in DBMS_SQL.varchar2s) IS
-- Debug procedure, not used in production.
-- bso
    i binary_integer;
BEGIN
    --FOR i IN 1..A.count LOOP
    --    DBMS_OUTPUT.put_line(A(i));
    --END LOOP;
      FOR i IN 1..A.count LOOP
          insert into bso(l1, n1) values(A(i), i);
      END LOOP;
    commit;
END;
*/

--
-- bug 7409976
-- New type to hold the privileges granted on a view
-- ntungare
--
TYPE grants_tab_typ IS TABLE OF VARCHAR2(32767) INDEX BY binary_integer;

PROCEDURE create_clause(s in out NOCOPY DBMS_SQL.varchar2s, f in DBMS_SQL.varchar2s,
    keyword varchar2) IS
--
-- Add to s the content of f to make f the FROM or WHERE clause of s.
-- This procedure replaces the QLTSTORB.Create_From/Where_Clause procedures
-- because that one does not allow a clause that's > 32k.
--
-- s is the sql string in dbms_sql.varchar2s
-- f is the list of from or where clauses
-- keyword is either 'FROM' or 'WHERE'
--
-- bso
--
    i binary_integer;
    sep varchar2(10);
BEGIN
    IF f.count > 0 THEN
        IF keyword = 'FROM' THEN
            sep := ', ';
        ELSE
            sep := ' AND ';
        END IF;
        i := s.count + 1;
        s(i) := ' ' || keyword || ' ' || f(1);

        FOR j IN 2..f.count LOOP
            i := i + 1;
            s(i) :=  sep || f(j);
        END LOOP;
    END IF;
END;


PROCEDURE exec_ddl_table(schema in varchar2, shortname in varchar2,
    cmd in integer, statement in DBMS_SQL.varchar2s, name in varchar2) IS
-- Execute a data definition statement by using the AD_DDL.DO_ARRAY_DDL
-- function.  See Bug 574078.  Release 10.7 requires this patch to work.
-- bso

    --
    -- Bug 3756235
    -- This is a performance fix.  A global view usually has tens of
    -- thousands of "statements" because each statement(i) is a short
    -- string.  Thus, we have been calling ad_ddl.build_statement a
    -- lot.  The no. of calls can be reduced 10-fold if we concat the
    -- shorter strings into a long one before invoking the API.
    --
    -- 255 is the current max size of build_statement's input param.
    -- If this limit is lifted, this constant and the variable can
    -- be changed accordingly and the code will adapt to use the
    -- larger buffer for even better performance.  See AD's bug or
    -- enhancement 3754657.
    --
    -- bso Sat Jul 24 16:17:15 PDT 2004
    --
    max_size CONSTANT NUMBER := 255;
    s VARCHAR2(255);
    n INTEGER;

BEGIN
    --table_print(statement);

    n := 0;
    FOR i IN 1..statement.count LOOP
        --
        -- check if we have enough room in s to take in more statements
        -- if not, we should call build_statement to process the previous
        -- concatenated string.
        -- bso Sat Jul 24 16:17:15 PDT 2004
        --
        -- check the size of the statement using lengthb function instead of
        -- length, to handle NLS characters.
        -- vvs BUG 4129987 Wed Mar  2 04:48:07 PST 2005
        --
        IF nvl(lengthb(s), 0) + nvl(lengthb(statement(i)), 0) + 1 > max_size THEN
            n := n + 1;
            AD_DDL.build_statement(s, n);
            s := '';
        END IF;

        s := s || statement(i) || ' ';
    END LOOP;

    --
    -- Because the last command in the loop is a string concatenation,
    -- we will always have a final "s" to process here.
    -- bso Sat Jul 24 16:17:15 PDT 2004
    --
    n := n + 1;
    AD_DDL.build_statement(s, n);

    AD_DDL.do_array_ddl(schema, shortname, cmd, 1, n, name);
END;


FUNCTION trans(name VARCHAR2) RETURN VARCHAR2 IS
--
-- The translate is there for NLS fix and pseudo-trans fix.
-- Problem is, we allow user to enter single quote in NLS fix.
-- Pseudo-trans will also translate element names into names
-- with asterisks and braces.  All these will cause error in
-- Discoverer Work Book (although they actually won't cause
-- problem in our view generation code).  Therefore, translate
-- them into underscores to help Discoverer out.
--
BEGIN
    RETURN upper(translate(name, ' ''"*{}', '______'));
END trans;


PROCEDURE drop_view(x VARCHAR2) IS
BEGIN
    ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.drop_view,
        'DROP VIEW "' || upper(x) || '"', x);
    EXCEPTION WHEN OTHERS THEN
        NULL;
END drop_view;


FUNCTION contains(a dbms_sql.number_table, x NUMBER) RETURN NUMBER IS
BEGIN
    FOR i IN a.first .. a.last LOOP
        IF a(i) = x THEN
            RETURN i;
        END IF;
    END LOOP;
    RETURN -1;
END contains;


PROCEDURE global_view(x_view_name IN VARCHAR2) IS

    --
    -- Complete rewrite on Thu Dec  7 14:08:03 PST 2000
    -- bso
    --

    --
    -- Used to construct the final dynamic sql.
    --
    v_sql_table     dbms_sql.varchar2s;
    v_from_table    dbms_sql.varchar2s;
    v_where_table   dbms_sql.varchar2s;


    --
    -- Maximum no. of columns allowed in a view.
    --
    max_columns CONSTANT NUMBER := 1000;

    --
    -- No. of fixed, seeded columns to be included in the beginning of the view
    --
    fixed_columns CONSTANT NUMBER := 14;
    column_count NUMBER;

    --
    -- Bug 1357601.  The decode statement used to "straighten" softcoded
    -- elements into a single column has a sever limit of 255 parameters.
    -- These variables are added to resolve the limit.  When the limit is
    -- up, we use the very last parameter of the decode statement to
    -- start a new decode, which can have another 255 params.  This is
    -- repeated as necessary.
    --
    -- decode_count keeps the no. of decodes being used so far.
    -- decode_param keeps the no. of parameters in the current decode.
    -- decode_limit is the server limit.  This should be updated if
    --    the server is enhanced in the future.
    --
    -- bso Thu Sep 21 13:11:19 PDT 2000
    --
    decode_count NUMBER;
    decode_param NUMBER;
    decode_limit CONSTANT NUMBER := 255;

    --
    -- Bug 4958779
    -- This cursor is not performing.  Removed and fetch element
    -- info on-the-fly.
    -- bso Tue Jan 31 14:57:53 PST 2006
    --
    -- CURSOR elements_cursor IS
    --    SELECT   qc.char_id, qc.name, qc.hardcoded_column, qc.datatype
    --    FROM     qa_chars qc
    --    WHERE    qc.enabled_flag = 1 and
    --             rownum < (max_columns - fixed_columns)
    --    ORDER BY qc.hardcoded_column, qc.name;
    --
    -- The elements to be included in the final view.
    --
    -- element_ids               dbms_sql.number_table;
    -- element_names             dbms_sql.varchar2s;
    -- element_hardcoded_columns dbms_sql.varchar2s;
    -- element_datatypes         dbms_sql.number_table;
    --
    l_element_id NUMBER;
    l_element_name qa_chars.name%TYPE;
    l_element_hardcoded_column qa_chars.hardcoded_column%TYPE;
    l_element_datatype NUMBER;

    --
    -- This cursor is used to fetch foreign key info for hardcoded,
    -- normalized elements.
    --
    CURSOR fk_cursor(x NUMBER) IS
        SELECT qc.fk_table_name,
               qc.fk_table_short_name,
               qc.fk_lookup_type,
               qc.pk_id,
               qc.fk_id,
               qc.pk_id2,
               qc.fk_id2,
               qc.pk_id3,
               qc.fk_id3,
               qc.fk_meaning,
               qc.fk_description,
               qc.fk_add_where
        FROM   qa_chars qc
        WHERE  qc.char_id = x;

    fk fk_cursor%ROWTYPE;

    --
    -- This cursor loops through qa_plan_chars to find all
    -- plan_id and result_column_name for each collection element.
    --
    -- The decode() function and distinct are there to cleverly
    -- eliminate all but one row of hardcoded elements.  We only
    -- need one row for each hardcoded ones.
    --
    CURSOR plan_cursor IS
        SELECT
        /*
           This is a batch program that needs to loop through
           all collection plans to generate a global view.
           Full table scan is expected.  Bryan So 1/31/2006
        */
                 distinct qpc.char_id,
                 decode(qc.hardcoded_column, null, qpc.plan_id, 0) plan_id,
                 upper(qpc.result_column_name) result_column_name,
                 qc.name,
                 qc.hardcoded_column
        FROM     qa_plan_chars qpc, qa_chars qc
        WHERE    qc.char_id = qpc.char_id AND
                 qpc.enabled_flag = 1 AND
                 qc.enabled_flag = 1
        ORDER BY qc.hardcoded_column, qc.name;

    pc plan_cursor%ROWTYPE;

    current_element NUMBER;
    temp            VARCHAR2(255);
    n               INTEGER;

    i               INTEGER;   -- I used these as counters for the
    j               INTEGER;   -- following lists: select list (v_sql_table),
    k               INTEGER;   -- from list, where list
    --
    -- I have used generic function such as table_add to an element
    -- to a PL/SQL table... it is way too slow.  3 times difference
    -- than using simple variable counters.
    --

BEGIN

    --
    -- This is the beginning of the global view.
    --

    v_sql_table(1) := 'CREATE OR REPLACE FORCE VIEW ' || x_view_name;
    v_sql_table(2) := ' AS SELECT ';
    v_sql_table(3) := ' qr.rowid row_id,';                         -- 1
    v_sql_table(4) := ' qr.plan_id,';                              -- 2
    v_sql_table(5) := ' qp'||g_period||'name plan_name,';          -- 3 see bug 3554899
    v_sql_table(6) := ' qr.organization_id,';                      -- 4
    v_sql_table(7) := ' hou.name organization_name,';              -- 5
    v_sql_table(8) := ' qr.collection_id,';                        -- 6
    v_sql_table(9) := ' qr.occurrence,';                           -- 7
    v_sql_table(10) := ' qr.qa_last_update_date last_update_date,'; -- 8
    v_sql_table(11) := ' qr.qa_last_updated_by last_update_by_id,'; -- 9
    v_sql_table(12) := ' fu2.user_name last_updated_by,';           -- 10
    v_sql_table(13) := ' qr.qa_creation_date creation_date,';       -- 11
    v_sql_table(14) := ' qr.qa_created_by created_by_id,';          -- 12
    v_sql_table(15) := ' fu.user_name created_by,';                 -- 13
    v_sql_table(16) := ' qr.last_update_login';                     -- 14
    i := 17;
    column_count := fixed_columns;  -- 14

    -- Then add the necessary where and froms
    v_from_table(1) := 'qa_results qr';
    v_from_table(2) := 'qa_plans qp';
    v_from_table(3) := 'fnd_user_view fu';
    v_from_table(4) := 'fnd_user_view fu2';
    v_from_table(5) := 'hr_organization_units hou';
    j := 6;

    v_where_table(1) := 'qp'||g_period||'plan_id = qr.plan_id'; -- see bug 3554899
    v_where_table(2) := 'qr.qa_created_by = fu.user_id';
    v_where_table(3) := 'qr.qa_last_updated_by = fu2.user_id';
    v_where_table(4) := 'qr.organization_id = hou.organization_id';
    v_where_table(5) := '(qr.status IS NULL OR qr.status = 2)';
    k := 6;

    --
    -- Bug 4958779
    -- This cursor is not performing.  Removed and fetch element
    -- info on-the-fly.
    -- bso Tue Jan 31 14:57:53 PST 2006
    --
    -- -- Collection all elements to be included in the view.
    -- --
    -- OPEN elements_cursor;
    --
    -- FETCH elements_cursor BULK COLLECT INTO element_ids, element_names,
    --    element_hardcoded_columns, element_datatypes;
    --
    -- CLOSE elements_cursor;
    --

    --
    -- One option is to go through each element, but it is slightly
    -- more efficient to go through qa_plan_chars to avoid performing
    -- too many database parses.
    --
    -- FOR element IN elements_cursor LOOP
    --
    OPEN plan_cursor;
    FETCH plan_cursor INTO pc;

    LOOP
      EXIT WHEN column_count > (max_columns-2);  -- reserve 2 columns

      EXIT WHEN plan_cursor%NOTFOUND;

      --
      -- We will do the following only if element appears in the given
      -- element ID list.
      --
      current_element := pc.char_id;

      SELECT char_id, name, hardcoded_column, datatype
      INTO   l_element_id, l_element_name, l_element_hardcoded_column,
             l_element_datatype
      FROM   qa_chars
      WHERE  char_id = current_element;

        -- There are several conditions.

        --
        -- If the element has a specially-coded stored function, then
        -- use the stored function...
        --
        IF current_element = qa_ss_const.sales_order THEN
          v_sql_table(i) := ', qr.' || l_element_hardcoded_column;
          i := i + 1;
          v_sql_table(i) := ', qa_flex_util.sales_order(qr.so_header_id) "'
              || trans(l_element_name) || '"';
          i := i + 1;
          column_count := column_count + 2;

        ELSIF current_element = qa_ss_const.rma_number THEN
          v_sql_table(i) := ', qr.' || l_element_hardcoded_column;
          i := i + 1;
          v_sql_table(i) := ', qa_flex_util.rma_number(qr.rma_header_id) "'
              || trans(l_element_name) || '"';
          i := i + 1;
          column_count := column_count + 2;

        ELSIF current_element = qa_ss_const.project_number THEN
          v_sql_table(i) := ', qr.' || l_element_hardcoded_column;
          i := i + 1;
          v_sql_table(i) := ', qa_flex_util.project_number(qr.project_id) "'
              || trans(l_element_name) || '"';
          i := i + 1;
          column_count := column_count + 2;

        --
        -- If the element is hardcoded, then simply use the hardcoded column.
        --
        ELSIF l_element_hardcoded_column IS NOT NULL THEN

          --
          -- a small complication is if the element is a foreign key,
          -- such as ITEM_ID, then outer join to the foreign table.
          --
          OPEN fk_cursor(current_element);
          FETCH fk_cursor INTO fk;

          IF fk.fk_lookup_type IN (0, 1)
              --
              -- Safety check to make sure foreign key reference is
              -- there.  Otherwise, we will have a cross product with
              -- no join condition!
              --
              AND fk.fk_id IS NOT NULL
              AND fk.pk_id IS NOT NULL THEN
              --
              -- Here is where there is a foreign table.  First add
              -- the hardcoded column as is, so the ID column is present.
              --
              v_sql_table(i) := ', qr.' || l_element_hardcoded_column;
              i := i + 1;

              --
              -- Then add the foreign select as a separate column.
              --
              v_sql_table(i) := ', ' || fk.fk_table_short_name || '.' ||
                  fk.fk_meaning || ' "' || trans(l_element_name) || '"';
              i := i + 1;

              -- Then the foreign table in the from clause
              -- and finally the outer join in where clause.
              --
              v_from_table(j) :=
                  fk.fk_table_name || ' ' || fk.fk_table_short_name;
              j := j + 1;

              IF fk.pk_id IS NOT NULL AND fk.fk_id IS NOT NULL THEN
                  v_where_table(k) := 'qr.' || fk.fk_id || ' = ' ||
                      fk.fk_table_short_name || '.' || fk.pk_id || ' (+)';
                  k := k + 1;
              END IF;

              IF fk.pk_id2 IS NOT NULL AND fk.fk_id2 IS NOT NULL THEN
                  v_where_table(k) := 'qr.' || fk.fk_id2 || ' = ' ||
                      fk.fk_table_short_name || '.' || fk.pk_id2 || ' (+)';
                  k := k + 1;
              END IF;

              IF fk.pk_id3 IS NOT NULL AND fk.fk_id3 IS NOT NULL THEN
                  v_where_table(k) := 'qr.' || fk.fk_id3 || ' = ' ||
                      fk.fk_table_short_name || '.' || fk.pk_id3 || ' (+)';
                  k := k + 1;
              END IF;

              IF fk.fk_add_where IS NOT NULL THEN
                  v_where_table(k) := fk.fk_add_where;
                  k := k + 1;
              END IF;

              column_count := column_count + 2;

            ELSE
              --
              -- Not foreign key ... great, simply add the hardcoded
              -- column name, examples are LOT_NUMBER, QUANTITY...
              --
              v_sql_table(i) := ', qr.' || l_element_hardcoded_column ||
                  ' "' || trans(l_element_name) || '"';
              i := i + 1;

              column_count := column_count + 1;
            END IF;

            CLOSE fk_cursor;

        ELSE -- Here, hardcoded_column IS NULL

          --
          -- Here the element must be softcoded.  This is most interesting.
          -- Need to use a bunch of decode statement and also correct the
          -- canonical datatype to real datatype format.
          --
          -- For example, if defect code is assigned to CHARACTER2 in
          -- plan 101 and assigned to CHARACTER5 in plan 103, the decode
          -- statement will look like this:
          --
          -- decode(qr.plan_id, 101, character2, 103, character5) defect_code
          --

          decode_count := 0;     -- see comments in variable declaration.
          decode_param := decode_limit;

          WHILE pc.char_id = current_element LOOP
              --
              -- If maximum no. of arguments to the "decode" function is
              -- close to the server allowed 'decode_limit', then we want
              -- to start a new tail-end decode statement.
              --
              IF decode_param >= (decode_limit - 2) THEN
                  v_sql_table(i) := ', decode(qr.plan_id';
                  i := i + 1;
                  decode_count := decode_count + 1;
                  decode_param := 1;
              END IF;

              --
              -- CHARACTER column data are stored in canonical format.
              -- Convert to real number/real date if appropriate.
              --
              IF l_element_datatype = 2 THEN

              --
              -- Need to create views with 12 decimal places
              -- for number type elements. See Bug 2624112
              -- rkunchal Wed Oct 16 05:32:33 PDT 2002
              --
              --    temp := 'to_number(qr.' || pc.result_column_name ||
              --       ', ''9999999999999999999999999999999.999999'')';

                    temp := 'qltdate.any_to_number(qr.' || pc.result_column_name || ')';

              ELSIF l_element_datatype = 3 THEN
                  temp := 'to_date(qr.' || pc.result_column_name ||
                      ', ''YYYY/MM/DD'')';
              --
              -- Bug 3179845. Added to iinclude datetime type for Timezone.
              -- saugupta Tue Oct 14 05:08:00 PDT 2003
              --
              ELSIF l_element_datatype = 6 THEN
                  temp := 'to_date(qr.' || pc.result_column_name ||
                      ', ''YYYY/MM/DD HH24:MI:SS'')';
              ELSE
                  temp := 'qr.' || pc.result_column_name;
              END IF;

              v_sql_table(i) := ', ' || pc.plan_id || ', ' || temp;
              i := i + 1;
              decode_param := decode_param + 2;

              FETCH plan_cursor INTO pc;

              EXIT WHEN plan_cursor%NOTFOUND;

          END LOOP;

          --
          -- Close all decode() parenthesis
          --
          temp := '';
          FOR x IN 1 .. decode_count LOOP
              temp := temp || ')';
          END LOOP;

          v_sql_table(i) := temp || ' "' || trans(l_element_name) || '"';
          i := i + 1;
          column_count := column_count + 1;

        END IF;

      WHILE pc.char_id = current_element LOOP
        FETCH plan_cursor INTO pc;
        EXIT WHEN plan_cursor%NOTFOUND;
      END LOOP;

    END LOOP;

    CLOSE plan_cursor;

    -- create the from and where clause
    create_clause(v_sql_table, v_from_table, 'FROM');
    create_clause(v_sql_table, v_where_table, 'WHERE');

    --
    -- Find apps schema info.  To be used in ad_ddl calls.
    --
    exec_ddl_table(g_schema, 'QA', AD_DDL.create_view, v_sql_table, x_view_name);

END global_view;

--
-- bug 7409976
-- New procedure to create a stack of
-- all the grants present on the views
-- ntungare
--
PROCEDURE create_grant_sql(p_view_name  IN VARCHAR2,
                           x_grants_tab OUT NOCOPY grants_tab_typ) AS

    TYPE privs_rec IS RECORD(grantee   VARCHAR2(200),
                             obj_priv  VARCHAR2(200),
                             grantable VARCHAR2(200));
    TYPE privs_rec_tab_type IS TABLE OF privs_rec INDEX BY BINARY_INTEGER;
    privs_rec_tab  privs_rec_tab_type ;

    grant_option VARCHAR2(2000):= ' WITH GRANT OPTION ';

    grant_stmt  VARCHAR2(4000);
BEGIN
    SELECT grantee, privilege, grantable
      BULK COLLECT INTO privs_rec_tab
    FROM User_TAB_PRIVS
      WHERE table_name = p_view_name
    ORDER BY grantee;

    FOR cntr in 1..privs_rec_tab.COUNT
      LOOP
         grant_stmt := 'GRANT '|| privs_rec_tab(cntr).obj_priv ||' ON '||p_view_name ||
                       ' TO '  || privs_rec_tab(cntr).grantee;

         IF (privs_rec_tab(cntr).grantable = 'YES') THEN
            grant_stmt := grant_stmt ||grant_option;
         END IF;

         x_grants_tab(cntr) := grant_stmt;
      END LOOP;
END create_grant_sql;

--  Plan View creates a view of QA_RESULTS using the user defined names
--  for the Character fields found there

--  Kevin Wiggen  September 22 1994


PROCEDURE plan_view(x_view_name IN VARCHAR2, x_old_view_name IN VARCHAR2,
    x_plan_id IN NUMBER) IS

    v_select VARCHAR2(20000);
    v_from   VARCHAR2(20000);
    v_where  VARCHAR2(20000);
    v_final  VARCHAR2(32000);

    temp     VARCHAR2(255);

    CURSOR pcursor is
        --
        -- See comments in global_view
        --
        SELECT   qc.char_id,
                 upper(translate(qc.name,' ''*{}','_____')) name,
                 qpc.result_column_name,
                 qc.hardcoded_column,
                 qc.FK_LOOKUP_TYPE,
                 qc.FK_TABLE_NAME,
                 qc.FK_TABLE_SHORT_NAME,
                 qc.PK_ID,
                 qc.FK_ID,
                 qc.PK_ID2,
                 qc.FK_ID2,
                 qc.PK_ID3,
                 qc.FK_ID3,
                 qc.FK_MEANING,
                 qc.FK_DESCRIPTION,
                 qc.FK_ADD_WHERE,
                 qc.DATATYPE
        FROM     qa_chars qc,
                 qa_plan_chars qpc
        WHERE    qc.char_id = qpc.char_id
        AND      qpc.plan_id = x_plan_id
        ORDER BY qpc.prompt_sequence;

     --
     -- bug 6350575
     -- 12.1 QWB Usability Improvements Project
     --
     v_plan_view_create  VARCHAR2(2000);
     v_deref_view_create VARCHAR2(2000);
     v_deref_view_final  VARCHAR2(32000);
     v_deref_view_where  VARCHAR2(20000);
     v_deref_view_name   VARCHAR2(30);

     --
     -- bug 7409976
     -- ntungare
     --
     x_pv_grants_tab  grants_tab_typ; -- Collection for grants on Plan  View
     x_dv_grants_tab  grants_tab_typ; -- Collection for grants on Deref View
BEGIN
   --
   -- bug 6350575
   -- 12. QWB Usability Improvements Project
   -- Deriving the Deref view name
   --
   SELECT substr(import_view_name, 1, length(import_view_name)-2)||'DV'
     INTO v_deref_view_name FROM qa_plans
   WHERE plan_id = x_plan_id;

   --
   -- When QLTPLMDF deletes a plan, it calls this proc with
   -- null x_view_name and with x_old_view_name populated.
   -- Need to drop the old view name and return.
   --
   IF x_old_view_name IS NOT NULL THEN
       --
       -- bug 7409976
       -- Getting a list of all the grants on the plan view
       -- before dropping it
       -- ntungare
       --
       create_grant_sql(p_view_name  => x_old_view_name,
                        x_grants_tab => x_pv_grants_tab);

       drop_view(x_old_view_name);

       --
       -- bug 7409976
       -- Getting a list of all the grants on the deref view
       -- before dropping it
       -- ntungare
       --
       create_grant_sql(p_view_name  => v_deref_view_name,
                        x_grants_tab => x_dv_grants_tab);

       drop_view(v_deref_view_name);
   END IF;

   IF x_view_name IS NULL THEN
       RETURN;
   END IF;

   --
   -- bug 6350575
   -- 12.1 QWB Usability Improvements Project
   -- building the create clause for the plan view
   --
   v_plan_view_create := 'CREATE OR REPLACE FORCE VIEW "' || upper(x_view_name) || '" AS ';

   --
   -- bug 6350575
   -- 12.1 QWB Usability Improvements Project
   -- building the create clause for the plan view
   --
   v_deref_view_create := 'CREATE OR REPLACE FORCE VIEW "' || upper(v_deref_view_name) || '" AS ';

   v_select := ' SELECT
       qr.rowid row_id,
       qr.plan_id,
       qp'||g_period||'name plan_name,
       qr.organization_id,
       hou.name organization_name,
       qr.collection_id,
       qr.occurrence,
       qr.qa_last_update_date last_update_date,
       qr.qa_last_updated_by last_updated_by_id,
       fu2.user_name last_updated_by,
       qr.qa_creation_date creation_date,
       qr.qa_created_by created_by_id,
       fu.user_name created_by,
       qr.last_update_login';

    v_from := ' FROM qa_results qr,
       qa_plans qp,
       fnd_user_view fu,
       fnd_user_view fu2,
       hr_organization_units hou';

    v_where := ' WHERE qp'||g_period||'plan_id = ' || x_plan_id || ' AND '||
       --
       -- bug 6044832
       -- Added an additional where clause, so that
       -- the index on QA_RESULTS is looked at, while
       -- querying the view, even with high volume of
       -- data
       -- ntungare Mon Jul 16 03:02:23 PDT 2007
       --
       -- bug 6350575
       -- 12.1 QWB USABILITY IMPROVEMENTS PROJECT
       -- removed the status where caluse since it would be
       -- added at the end
       --
       'qr'||g_period||'plan_id = '|| x_plan_id || ' AND
       qp'||g_period||'plan_id = qr.plan_id AND
       qr.qa_created_by = fu.user_id AND
       qr.qa_last_updated_by = fu2.user_id AND
       qr.organization_id = hou.organization_id';
       --AND
       --(qr.status IS NULL OR qr.status = 2)';

    FOR fk in pcursor LOOP

        IF fk.char_id = qa_ss_const.sales_order THEN
          v_select := v_select || ', qr.' || fk.hardcoded_column;
          v_select := v_select ||
            ', qa_flex_util.sales_order(qr.so_header_id) "' || fk.name || '"';

        ELSIF fk.char_id = qa_ss_const.rma_number THEN
          v_select := v_select || ', qr.' || fk.hardcoded_column;
          v_select := v_select ||
            ', qa_flex_util.rma_number(qr.rma_header_id) "' || fk.name || '"';

        ELSIF fk.char_id = qa_ss_const.project_number THEN
          v_select := v_select || ', qr.' || fk.hardcoded_column;
          v_select := v_select ||
            ', qa_flex_util.project_number(qr.project_id) "' || fk.name || '"';

        --
        -- If the element is hardcoded, then simply use the hardcoded column.
        --
        ELSIF fk.hardcoded_column IS NOT NULL THEN

          --
          -- a small complication is if the element is a foreign key,
          -- such as ITEM_ID, then outer join to the foreign table.
          --
          IF fk.fk_lookup_type IN (0, 1)
              --
              -- Safety check to make sure foreign key reference is
              -- there.  Otherwise, we will have a cross product with
              -- no join condition!
              --
              AND fk.fk_id IS NOT NULL
              AND fk.pk_id IS NOT NULL THEN

              --
              -- Here is where there is a foreign table.  First add
              -- the hardcoded column as is, so the ID column is present.
              --
              v_select := v_select || ', qr.' || fk.hardcoded_column;

              --
              -- Then add the foreign select as a separate column.
              --
              v_select := v_select || ', ' || fk.fk_table_short_name || '.' ||
                  fk.fk_meaning || ' "' || fk.name || '"';

              -- Then the foreign table in the from clause
              -- and finally the outer join in where clause.
              --
              v_from := v_from || ', ' || fk.fk_table_name || ' ' ||
                  fk.fk_table_short_name;

              IF fk.pk_id IS NOT NULL AND fk.fk_id IS NOT NULL THEN
                  v_where := v_where || ' AND qr.' || fk.fk_id || ' = ' ||
                      fk.fk_table_short_name || '.' || fk.pk_id || ' (+)';
              END IF;

              IF fk.pk_id2 IS NOT NULL AND fk.fk_id2 IS NOT NULL THEN
                  v_where := v_where || ' AND qr.' || fk.fk_id2 || ' = ' ||
                      fk.fk_table_short_name || '.' || fk.pk_id2 || ' (+)';
              END IF;

              IF fk.pk_id3 IS NOT NULL AND fk.fk_id3 IS NOT NULL THEN
                  v_where := v_where || ' AND qr.' || fk.fk_id3 || ' = ' ||
                      fk.fk_table_short_name || '.' || fk.pk_id3 || ' (+)';
              END IF;

              IF fk.fk_add_where IS NOT NULL THEN
                  v_where := v_where || ' AND ' || fk.fk_add_where;
              END IF;

            ELSE
              --
              -- Not foreign key ... great, simply add the hardcoded
              -- column name, examples are LOT_NUMBER, QUANTITY...
              --
              v_select := v_select || ', qr.' || fk.hardcoded_column ||
                  ' "' || fk.name || '"';
            END IF;
        ELSE
            --
            -- Element is softcoded.  Use result_column name.
            --
            -- CHARACTER column data are stored in canonical format.
            -- Convert to real number/real date if appropriate.
            --
            IF fk.datatype = 2 THEN

              --
              -- Need to create views with 12 decimal places
              -- for number type elements. See Bug 2624112
              -- rkunchal Wed Oct 16 05:32:33 PDT 2002
              --
              --  temp := 'to_number(qr.' || fk.result_column_name ||
              --       ', ''9999999999999999999999999999999.999999'')';

                temp := 'qltdate.any_to_number(qr.' || fk.result_column_name || ')';

            ELSIF fk.datatype = 3 THEN
                temp := 'to_date(qr.' || fk.result_column_name ||
                      ', ''YYYY/MM/DD'')';
           --
           -- Bug 3179845. Added to include datetime type in plan_view
           -- saugupta Tue Oct 14 05:29:19 PDT 2003
           --
           ELSIF fk.datatype = 6  THEN
                temp := 'to_date(qr.' || fk.result_column_name ||
                      ', ''YYYY/MM/DD HH24:MI:SS'')';
            ELSE
                temp := 'qr.' || fk.result_column_name;
            END IF;

            v_select := v_select || ', ' || temp || ' "' || fk.name || '"';
        END IF;

    END LOOP;

    -- create a dynamic call to do_ddl for either the 10.6 or 10.7 api
    -- bug 6350575
    -- 12.1 QWB Usability Improvements Project
    -- Adding the status clause to the plan view
    -- The Deref view does not contain the status
    -- where clause
    --
    v_deref_view_where := v_where;
    v_where :=  v_where || ' AND (qr.status IS NULL OR qr.status = 2)';

    --
    -- bug 6350575
    -- 12.1 QWB Usability Improvements
    -- Appending the create clause to the Plan view
    --
    v_final := v_plan_view_create || v_select || v_from || v_where;

    --
    -- bug 6350575
    -- 12.1 QWB Usability Improvements
    -- Building the final query for the deref view
    --
    v_deref_view_final := v_deref_view_create || v_select || v_from || v_deref_view_where;

    ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.create_view, v_final,
        x_view_name);

    --
    -- bug 6350575
    -- 12.1 QWB Usability Improvements
    -- Creating the deref view
    --
    ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.create_view, v_deref_view_final,
        v_deref_view_name);

    --
    -- bug 6350575
    -- 12.1 QWB Usability Improvements
    -- Updating the deref view name in the qa_plans table
    --
    UPDATE qa_plans set deref_view_name = v_deref_view_name
      WHERE plan_id = x_plan_id;

    --
    -- bug 7409976
    -- Regranting the privileges on the plan view and
    -- deref view
    -- ntungare
    --
    FOR Cntr in 1..x_pv_grants_tab.COUNT
       LOOP
          EXECUTE IMMEDIATE x_pv_grants_tab(cntr);
       END LOOP; -- End of loop for plan view

    FOR Cntr in 1..x_dv_grants_tab.COUNT
       LOOP
          EXECUTE IMMEDIATE x_dv_grants_tab(cntr);
       END LOOP; -- End of loop for deref view
END plan_view;


PROCEDURE import_plan_view(x_view_name IN VARCHAR2, x_old_view_name IN VARCHAR2,
    x_plan_id IN NUMBER) IS
--
-- import view creation for QA_RESULTS_INTERFACE and collection import
--

    v_select VARCHAR2(20000);

    --
    -- See comments in global_view about translate()
    --
    CURSOR pcursor is
        SELECT   qpc.result_column_name,
                 upper(translate(qc.name,' ''*{}','_____')) name,
                 qc.hardcoded_column,
                 qc.developer_name
        FROM     qa_plan_chars qpc, qa_chars qc
        WHERE    qpc.char_id = qc.char_id AND qpc.plan_id = x_plan_id
        ORDER BY prompt_sequence;

    --
    -- bug 7409976
    -- ntungare
    --
    x_grants_tab  grants_tab_typ;
BEGIN

    --
    -- When QLTPLMDF deletes a plan, it calls this proc with
    -- null x_view_name and with x_old_view_name populated.
    -- Need to drop the old view name and return.
    --
    IF x_old_view_name IS NOT NULL THEN
        --
        -- bug 7409976
        -- Getting a list of all the grants on the view
        -- before dropping it
        -- ntungare
        --
        create_grant_sql(p_view_name  => x_old_view_name,
                         x_grants_tab => x_grants_tab);

        drop_view(x_old_view_name);
    END IF;

    IF x_view_name IS NULL THEN
        RETURN;
    END IF;

    --
    -- R12 Project MOAC 4637896
    -- Added operating_unit and operating_unit_id as columns in an
    -- import view.  These are now needed because according to MOAC
    -- PO Number is no longer unique across OUs.  Thus user has to
    -- specify OU name in order to resolve PO Number uniquely in
    -- the worst case.
    -- bso Sun Oct  2 11:41:00 PDT 2005
    --
    v_select := 'CREATE OR REPLACE FORCE VIEW "' || upper(x_view_name) ||
      '" AS SELECT
        transaction_interface_id,
        qa_last_updated_by_name,
        qa_created_by_name,
        collection_id,
        source_code,
        source_line_id,
        process_status,
        organization_code,
        operating_unit_id,
        operating_unit,
        plan_name,
        insert_type,
        matching_elements,
        spec_name';

    FOR prec in pcursor LOOP

    -- If the column is hardcoded column access the developer name and leave
    -- the developer name as the actual name for it in the view
    -- Otherwise, use the result column name to get the correct column but
    -- use the characteristic name as the column name in the view.

        --
        -- Added the following IF condition for ASO project
        -- To uniquely identify a Maintenance_Requirement it takes
        -- two fields, namely, Title and Version_Number.
        -- rkunchal Thu Jul 25 01:43:48 PDT 2002
        --

        IF prec.developer_name = 'MAINTENANCE_REQUIREMENT' THEN
           v_select := v_select || ', VERSION_NUMBER';
        END IF;

        IF prec.hardcoded_column IS NOT NULL THEN
           v_select := v_select || ', ' || prec.developer_name;
        ELSE

           -- originally we were going to change the datatype to number or
           -- date here if that was the datatype of the element.  when we
           -- did this, however, it was no longer possible to insert into
           -- this column of the view (it became a virtual column).

           v_select := v_select || ', ' || prec.result_column_name ||
               ' "' || prec.name || '"';
        END IF;
    END LOOP;

    v_select := v_select || ' FROM QA_RESULTS_INTERFACE';

    ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.create_view, v_select,
        x_view_name);

    --
    -- bug 7409976
    -- Regranting the privileges
    -- ntungare
    --
    FOR Cntr in 1..x_grants_tab.COUNT
       LOOP
          EXECUTE IMMEDIATE x_grants_tab(cntr);
       END LOOP;
END import_plan_view;

BEGIN

    g_dummy := fnd_installation.get_app_info(g_fnd, g_status,
        g_industry, g_schema);

END  QLTVCREB ;

/
