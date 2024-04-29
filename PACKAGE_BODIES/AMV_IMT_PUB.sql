--------------------------------------------------------
--  DDL for Package Body AMV_IMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_IMT_PUB" AS
/* $Header: amvpimtb.pls 120.1 2005/06/21 17:48:12 appldev ship $ */
-- NAME
--   amvpimtb.pls
--
-- DESCRIPTION
--   Package body for AMV_IMT_PUB in support of rebuilding iMT
--   indexes on AMV table amv_c_channels_tl.  Expected use of this package
--   is either through Apps Concurrent Manager or package DBMS_JOBS.
--
-- NOTES
--
-- HISTORY
--   12/14/99	J Ray		Created.
--   02/17/00	slkrishn		Updated.
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Optimize_AMV_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Optimize on all indexes across
--                 all AMV iMT-indexed columns in a time-distributed fashion.
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

PROCEDURE Optimize_AMV_IMT_Indexes
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
  where  oracle_id = 520;

  IF p_optimize_level = 'FAST' THEN
    l_maxtime := null;
  ELSE
   IF p_runtime IS NULL OR p_runtime = ctx_ddl.maxtime_unlimited THEN
    l_maxtime := ' maxtime unlimited';
   ELSE
    -- Two indexes so split time in half.
    l_maxtime := ' maxtime '||TRUNC(p_runtime/2);
   END IF;
  END IF;

  -----------------------
  -- rebuild the index --
  -----------------------
  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.amv_c_channels_name_ctx rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.amv_c_channels_desc_ctx rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

--
EXCEPTION
 WHEN OTHERS THEN
	ERRBUF := substrb(sqlerrm, 1, 80);
	RETCODE := 2;
END Optimize_AMV_IMT_Indexes;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Sync_AMV_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Sync on all indexes across
--                 all AMV iMT-indexed columns.
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

PROCEDURE Sync_AMV_IMT_Indexes
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
  where  oracle_id = 520;

  -----------------------
  -- rebuild the index --
  -----------------------
  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.amv_c_channels_name_ctx rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.amv_c_channels_desc_ctx rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  rows := dbms_sql.execute(curs);
  dbms_sql.close_cursor(curs);

--
EXCEPTION
 WHEN OTHERS THEN
	ERRBUF := substrb(sqlerrm, 1, 80);
	RETCODE := 2;
END Sync_AMV_IMT_Indexes;

END AMV_IMT_Pub;

/
