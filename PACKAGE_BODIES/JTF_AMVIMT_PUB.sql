--------------------------------------------------------
--  DDL for Package Body JTF_AMVIMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AMVIMT_PUB" AS
/* $Header: jtfpimtb.pls 115.8 2002/11/26 22:30:42 stopiwal ship $ */
-- NAME
--   jtfpimtb.pls
--
-- DESCRIPTION
--   Package body for JTF_AMVIMT_PUB in support of rebuilding iMT
--   indexes on JTF table jtf_amv_items_b and _tl.
--   Expected use of this package is either through Apps Concurrent Manager.
--
-- NOTES
--
-- HISTORY
--   12/14/99	J Ray		Created.
--   02/17/00	slkrishn		Updated.
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Optimize_JTF_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Optimize on all indexes across
--                 all JTF iMT-indexed columns in a time-distributed fashion.
--    Parameters :
--
--    IN         : p_optimize_level                    IN  VARCHAR2    Optional
--                   Specifies the type of iMT index optimization to perform.
--                   Valid values are 'FAST','FULL', ctx_ddl.optlevel_fast or
--                   ctx_ddl.optlevel_full.
--
--                   Default is ctx_ddl.optlevel_full.
--
--               : p_runtime                           IN  NUMBER      Optional
--                   Integer that indicates the total run-time (in seconds) of
--                   this optimization function call.  This time will be
--                   divided equally amongst all indexes within the AMV
--                   subsystem.  A null value implies execution until
--                   completion of the task.
--
--                   Default is ctx_ddl.maxtime_unlimited.
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
--
-- End of comments
--

PROCEDURE Optimize_JTF_IMT_Indexes
          (ERRBUF                   OUT NOCOPY VARCHAR2,
		 RETCODE                  OUT NOCOPY NUMBER,
           p_optimize_level         IN  VARCHAR2 := ctx_ddl.optlevel_full,
           p_runtime                IN  NUMBER   := ctx_ddl.maxtime_unlimited)
AS
--
  l_maxtime                VARCHAR2(30);
  owner  varchar2(30);
  stmt   varchar2(256);
  curs   integer;
  rows   integer;

--
BEGIN
--
  ---------------------------
  -- determine index owner --
  ---------------------------
  select oracle_username into owner
  from   fnd_oracle_userid
  where  oracle_id = 690;

  IF p_optimize_level = 'FAST' THEN
    l_maxtime := null;
  ELSE
   IF p_runtime IS NULL OR p_runtime = ctx_ddl.maxtime_unlimited THEN
    l_maxtime := ' maxtime unlimited';
   ELSE
    -- Two indexes so split time in half.
    l_maxtime := ' maxtime '||TRUNC(p_runtime/4);
   END IF;
  END IF;

  -----------------------
  -- rebuild the index --
  -----------------------
  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_url_ctx rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_name_ctx rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_desc_ctx rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_text_ctx rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

--
EXCEPTION
 WHEN OTHERS THEN
 	ERRBUF := substr(sqlerrm, 1, 80);
 	RETCODE := 2;
END Optimize_JTF_IMT_Indexes;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Sync_JTF_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Sync on all indexes across
--                 all JTF iMT-indexed columns.
--
--    Parameters : None.
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
--
-- End of comments
--

PROCEDURE Sync_JTF_IMT_Indexes
          (ERRBUF                   OUT NOCOPY VARCHAR2,
		 RETCODE                  OUT NOCOPY NUMBER )

AS

  owner  varchar2(30);
  stmt   varchar2(256);
  curs   integer;
  rows   integer;

begin
  ---------------------------
  -- determine index owner --
  ---------------------------
  select oracle_username into owner
  from   fnd_oracle_userid
  where  oracle_id = 690;

  -----------------------
  -- rebuild the index --
  -----------------------
  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_url_ctx rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_name_ctx rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_desc_ctx rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.jtf_amv_items_text_ctx rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

--
EXCEPTION
 WHEN OTHERS THEN
 	ERRBUF := substr(sqlerrm, 1, 80);
 	RETCODE := 2;
END Sync_JTF_IMT_Indexes;

END JTF_AMVIMT_Pub;

/
