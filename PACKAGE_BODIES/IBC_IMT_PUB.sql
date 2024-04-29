--------------------------------------------------------
--  DDL for Package Body IBC_IMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_IMT_PUB" AS
/* $Header: ibcpimtb.pls 120.1 2005/05/31 23:22:29 appldev  $ */
-- NAME
--   ibcpimtb.pls
--
-- DESCRIPTION
--   Package body for IBC_IMT_PUB in support of rebuilding iMT
--   indexes on IBC table IBC_Attribute_bundles.  Expected use of this package
--   is either through Apps Concurrent Manager or package DBMS_JOBS.
--
-- NOTES
--
-- HISTORY
-- Marzia Usman and Sri Rangarajan	Created		              11/07/2003
-- Siva Devaki                          Declared IN and OUT as NOCOPY 05/31/2005
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Optimize_IBC_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Optimize on all indexes across
--                 all IBC iMT-indexed columns in a time-distributed fashion.
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
--                   divided equally amongst all indexes within the IBC
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

PROCEDURE OPTIMIZE_IBC_IMT_INDEXES
          (ERRBUF                   OUT NOCOPY VARCHAR2,
	   RETCODE                  OUT NOCOPY NUMBER,
           p_optimize_level         IN  VARCHAR2 := ctx_ddl.optlevel_full,
           p_runtime                IN  NUMBER   := ctx_ddl.maxtime_unlimited)
AS
--
  l_maxtime             VARCHAR2(30);
  l_user_name		VARCHAR2(30);
  stmt			VARCHAR2(256);
  l_index_name		VARCHAR2(50);
  curs			INTEGER;
  ROWS			INTEGER;

CURSOR c_index_name IS
SELECT index_name  FROM all_indexes
WHERE index_name = 'IBC_ATTRIBUTE_BUNDLES_CTX'
AND owner = l_user_name;

--
BEGIN
--
  ---------------------------
  -- determine index owner --
  ---------------------------
  SELECT oracle_username INTO l_user_name
  FROM   fnd_oracle_userid
  WHERE  oracle_id = 549;

  IF p_optimize_level = 'FAST' THEN
    l_maxtime := NULL;
  ELSE
   IF p_runtime IS NULL
   OR p_runtime = ctx_ddl.maxtime_unlimited
   THEN
    l_maxtime := ' maxtime unlimited';
   ELSE
    -- Two indexes so split time in half.
    l_maxtime := ' maxtime '||TRUNC(p_runtime/2);
   END IF;
  END IF;

  -----------------------
  -- rebuild the index --
  -----------------------
  OPEN c_index_name;
  FETCH c_index_name INTO l_index_name;
  IF c_index_name%FOUND THEN
     ad_ctx_ddl.OPTIMIZE_INDEX(l_user_name||'.'||l_index_name,p_optimize_level,p_runtime);
  END IF;
  CLOSE c_index_name;

  /*
  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.IBC_ATTRIBUTE_BUNDLES_CTX rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  ROWS := dbms_sql.EXECUTE(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.IBC_ATTRIBUTE_BUNDLES_CTX rebuild online '||
          'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  ROWS := dbms_sql.EXECUTE(curs);
  dbms_sql.close_cursor(curs);
*/
--
EXCEPTION
 WHEN OTHERS THEN
	ERRBUF := SUBSTRB(SQLERRM, 1, 80);
	RETCODE := 2;
END Optimize_IBC_IMT_Indexes;

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : SYNC_IBC_IMT_INDEXES
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an IMT Sync on all indexes across
--                 all IBC IMT-indexed columns.
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

PROCEDURE SYNC_IBC_IMT_INDEXES
          (ERRBUF                   OUT NOCOPY VARCHAR2,
     	   RETCODE                  OUT NOCOPY NUMBER )
AS

  owner  VARCHAR2(30);
  stmt   VARCHAR2(256);
  l_owner_name 		  VARCHAR2(30);
  l_index_name VARCHAR2(50);

  curs   INTEGER;
  ROWS   INTEGER;

CURSOR c_index_name IS
SELECT index_name  FROM all_indexes
WHERE index_name = 'IBC_ATTRIBUTE_BUNDLES_CTX'
AND owner = l_owner_name;

BEGIN
  ---------------------------
  -- determine index owner --
  ---------------------------
  SELECT oracle_username INTO l_owner_name
  FROM   fnd_oracle_userid
  WHERE  oracle_id = 549;

  -----------------------
  -- rebuild the index --
  -----------------------
  OPEN c_index_name;
  FETCH c_index_name INTO l_index_name;
  IF c_index_name%FOUND
  THEN
    ad_ctx_ddl.SYNC_INDEX(l_owner_name||'.'||l_index_name);
  END IF;
  CLOSE c_index_name;
/*
  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.IBC_ATTRIBUTE_BUNDLES_CTX rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  ROWS := dbms_sql.EXECUTE(curs);
  dbms_sql.close_cursor(curs);

  curs := dbms_sql.open_cursor;
  stmt := 'alter index '||owner||'.IBC_ATTRIBUTE_BUNDLES_CTX rebuild online '||
          'parameters(''sync'')';
  dbms_sql.parse(curs, stmt, dbms_sql.native);
  ROWS := dbms_sql.EXECUTE(curs);
  dbms_sql.close_cursor(curs);
*/
--
EXCEPTION
 WHEN OTHERS THEN
	ERRBUF := SUBSTRB(SQLERRM, 1, 80);
	RETCODE := 2;
END SYNC_IBC_IMT_INDEXES;

END IBC_IMT_PUB;

/
