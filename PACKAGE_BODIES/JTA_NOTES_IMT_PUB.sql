--------------------------------------------------------
--  DDL for Package Body JTA_NOTES_IMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_NOTES_IMT_PUB" AS
/* $Header: jtfpntib.pls 115.5 2004/09/14 22:59:38 akaran ship $ */

FUNCTION get_index_owner
--------------------------------------------------------------------------
-- Get the schema name for CRM Foundation schema
--------------------------------------------------------------------------
RETURN VARCHAR2
AS
  l_owner   varchar2(30);

BEGIN

  SELECT oracle_username INTO l_owner
  FROM   fnd_oracle_userid
  WHERE  oracle_id = 690;

  RETURN l_owner;

END get_index_owner;

PROCEDURE check_notes_index
(
 p_index_owner VARCHAR2
)
AS
  CURSOR check_index
  (
   p_owner VARCHAR2
  )
  IS
  /**
  SELECT 1
  FROM ALL_OBJECTS
  WHERE OBJECT_NAME = 'JTF_NOTES_TL_C1'
  AND OBJECT_TYPE = 'INDEX'
  AND OWNER = p_owner;
  **/
  SELECT IDX_LANGUAGE_COLUMN
  FROM CTXSYS.ctx_indexes
  WHERE idx_name = 'JTF_NOTES_TL_C1';

  l_language     VARCHAR2(256);

BEGIN

  --
  -- First check if the index alreay exists. If it does then return from here
  --
  OPEN check_index(p_index_owner);
  FETCH check_index INTO l_language;
  IF (check_index%FOUND)
  THEN
      IF (l_language = 'SOURCE_LANG')
      THEN
   	    CLOSE check_index;
        -- Index is valid and correct, so quit
	    RETURN;
      ELSE
        -- The index was created with wrong language parameters, so drop it
        EXECUTE IMMEDIATE 'DROP INDEX '||p_index_owner||'.JTF_NOTES_TL_C1';
      END IF;
  END IF;
  CLOSE check_index;

  BEGIN
    --
    -- In any case we will want to update the constraints and (re-)create the index
    --
    EXECUTE IMMEDIATE 'ALTER TABLE '||p_index_owner||'.JTF_NOTES_TL DROP PRIMARY KEY CASCADE';
  EXCEPTION
  WHEN OTHERS
  THEN
    --
    -- In case the primary key doesn't exist the drop will fail, which we will ignore
    --
    NULL;
-- End Add
  END;

  EXECUTE IMMEDIATE 'ALTER TABLE '||p_index_owner||'.JTF_NOTES_TL ADD CONSTRAINT jtf_notes_tl_pk PRIMARY KEY (JTF_NOTE_ID,LANGUAGE)';
  EXECUTE IMMEDIATE 'CREATE INDEX '||p_index_owner||'.JTF_NOTES_TL_C1 ON '||p_index_owner||'.JTF_NOTES_TL(notes) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS (''LANGUAGE COLUMN SOURCE_LANG'')';

END check_notes_index;

PROCEDURE optimize_notes_index
--------------------------------------------------------------------------
-- Start of comments
--  API name    : optimize_notes_index
--  Type        : Public
--  Function    : optimize the JTF_NOTES_TL.JTF_NOTES_TL_C1 index
--  Pre-reqs    : None.
--  Parameters  :
--     name                 direction  type       required?
--     ----                 ---------  ----       ---------
--     errbuf               out        varchar2   Yes
--     retcode              out        number     Yes
--     p_optimize_level        in      varchar2   No
--     p_runtime               in      number     No
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
-- End of comments
--------------------------------------------------------------------------
( errbuf              OUT NOCOPY VARCHAR2
, retcode             OUT NOCOPY NUMBER
, p_optimize_level IN            VARCHAR2 := ctx_ddl.optlevel_full
, p_runtime        IN            NUMBER   := ctx_ddl.maxtime_unlimited
)
AS
  l_maxtime     VARCHAR2(30);
  l_stmt        VARCHAR2(256);
  l_owner       VARCHAR2(30);

BEGIN

  IF UPPER(p_optimize_level) NOT IN ('FAST','FULL')
  THEN
    fnd_message.set_name('JTF', 'JTF_NOTES_BAD_PARAMETER_VALUE');
    fnd_message.set_token('VALUE', NVL(p_optimize_level,'NULL'));
    fnd_message.set_token('PARAMETER', 'p_optimize_level');
    RAISE_APPLICATION_ERROR(-20000,fnd_message.get);
  END IF;

  IF (p_runtime IS NOT NULL)
  THEN
    IF (  (trunc(p_runtime) <> p_runtime)
       or (p_runtime < 0)
       or (p_runtime > ctx_ddl.maxtime_unlimited)
       )
    THEN
      fnd_message.set_name('JTF', 'JTF_NOTES_BAD_PARAMETER_VALUE');
      fnd_message.set_token('VALUE', NVL(p_runtime,'NULL'));
      fnd_message.set_token('PARAMETER', 'p_runtime');
      RAISE_APPLICATION_ERROR(-20000,fnd_message.get);
    END IF;
  END IF;

  --
  -- Get the index owner
  --
  l_owner := get_index_owner;

  --
  -- Call to check if the index exists
  --
  check_notes_index(l_owner);

  -----------------
  -- set maxtime --
  -----------------
  IF (UPPER(p_optimize_level) = 'FAST')
  THEN
    l_maxtime := NULL;
  ELSE
    IF (   (p_runtime IS NULL)
       OR  (p_runtime = ctx_ddl.maxtime_unlimited)
       )
    THEN
      l_maxtime := ' maxtime unlimited';
    ELSE
      l_maxtime := ' maxtime '||TRUNC(p_runtime);
    END IF;
  END IF;

  -----------------------
  -- rebuild the index --
  -----------------------
  l_stmt := 'alter index '||l_owner||'.JTF_NOTES_TL_C1 ' ||
            'rebuild online '||
            'parameters(''optimize '|| p_optimize_level || l_maxtime ||''')';

  EXECUTE IMMEDIATE l_stmt;

EXCEPTION
 WHEN OTHERS
 THEN
   errbuf := SUBSTR(SQLERRM, 1, 80);
   retcode := 2;

END optimize_notes_index;


PROCEDURE sync_notes_index
--------------------------------------------------------------------------
-- Start of comments
--  API name    : sync_notes_index
--  Type        : Public
--  Function    : synchronize the JTF_NOTES_TL.JTF_NOTES_TL_C1 index
--  Pre-reqs    : None.
--  Parameters  :
--     name                 direction  type       required?
--     ----                 ---------  ----       ---------
--     errbuf               out        varchar2   Yes
--     retcode              out        number     Yes
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
-- End of comments
--------------------------------------------------------------------------
( errbuf  OUT NOCOPY VARCHAR2
, retcode OUT NOCOPY NUMBER
)
AS
  l_stmt   VARCHAR2(256);
  l_owner  VARCHAR2(30);

BEGIN
  --
  -- Get the index owner
  --
  l_owner := get_index_owner;

  --
  -- Call to check if the index exists
  --
  check_notes_index(l_owner);

  -----------------------
  -- rebuild the index --
  -----------------------
  l_stmt := 'alter index '||l_owner||'.JTF_NOTES_TL_C1 ' ||
            'rebuild online '||
            'parameters(''sync'')';

  EXECUTE IMMEDIATE l_stmt;

EXCEPTION
 WHEN OTHERS
 THEN
   errbuf := SUBSTR(SQLERRM, 1, 80);
   retcode := 2;

END SYNC_NOTES_INDEX;

END JTA_NOTES_IMT_PUB;

/
