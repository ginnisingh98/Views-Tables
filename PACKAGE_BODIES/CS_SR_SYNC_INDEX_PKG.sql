--------------------------------------------------------
--  DDL for Package Body CS_SR_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_SYNC_INDEX_PKG" AS
/* $Header: cssrsyxb.pls 120.2 2006/02/01 18:23:48 klou noship $ */

   -- errbuf = err messages
   -- retcode = 0 success, 1 = warning, 2=error

   -- bmode: S = sync  OFAST=optimize fast, OFULL = optimize full

  -- (TEXT) ---
  -- Add global exception handlers.
  invalid_mode_error   EXCEPTION;
  invalid_action_error EXCEPTION;
  drop_index_error     EXCEPTION;
  create_index_error   EXCEPTION;
  rebuild_cache_error  EXCEPTION;

  -- Declare cs and apps schema.
  g_cs_short_name   VARCHAR2(10) := UPPER('CS'); -- set at patching
  g_apps_short_name VARCHAR2(10) := UPPER('APPS'); -- set at patching

  -- (TEXT) eof --

  -- (4917652): add batch size for bulk update.
  G_BATCH_SIZE      NUMBER := 10000;
  -- 4917652_eof

-- Internal API to create summary index
PROCEDURE Create_Summary_Index (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER)
IS
   l_create_cmmd VARCHAR2(500):= NULL;

   l_index_name    VARCHAR2(30) := 'SUMMARY_CTX_INDEX';
   l_db_version NUMBER := null;
   l_compatibility VARCHAR2(100) := null;
   l_db_version_str VARCHAR2(100) := null;

   l_parallel_cmd VARCHAR2(100);

  CURSOR get_index_cursor(p_index_name VARCHAR2,
                          p_owner VARCHAR2) IS
  SELECT COUNT(*) FROM dba_indexes
  WHERE index_name = UPPER(p_index_name)
  AND owner= UPPER(p_owner);

  l_total NUMBER := 0;
  l_drop_index VARCHAR2(500);

  l_temp_var varchar2(200);


BEGIN
  -- Initialize variables
  l_parallel_cmd := ' ';

  DBMS_UTILITY.db_version(l_db_version_str, l_compatibility);

  If l_db_version_str is null Then
   l_db_version := 8;
  Else
   l_db_version := to_number(substr(l_db_version_str, 1,(instr(l_db_version_str, '.'))-1));
  End If;

  if l_db_version > 8 then
     l_parallel_cmd :=  ' PARALLEL ';
  end if ;

  --1. Drop index if exists.
  OPEN get_index_cursor(l_index_name, g_cs_short_name);
  FETCH get_index_cursor INTO l_total;
  CLOSE get_index_cursor;

  IF l_total > 0 THEN
    l_drop_index := 'drop index '||g_cs_short_name||
                    '.'||l_index_name||' force ';

    EXECUTE IMMEDIATE l_drop_index;
  END IF;

  --2. Create summary index.
  l_create_cmmd :=
  ' create index '||g_cs_short_name||
  '.SUMMARY_CTX_INDEX on cs_incidents_all_tl(summary) '||
  ' indextype is ctxsys.context '||
  ' parameters(''lexer ' || g_apps_short_name || '.CS_SR_GLOBAL_LEXER '||
  '              language column source_lang '||
  '              memory 10M '||
  '              storage ' ||g_apps_short_name||'.CS_SR_INDEX_STORAGE '||
  ' '' )';

  l_create_cmmd := l_create_cmmd || l_parallel_cmd;

  EXECUTE IMMEDIATE l_create_cmmd;

 -- DO NOT CATCH EXCEPTION. LET IT STACK UP.

END Create_Summary_Index;


PROCEDURE Sync_All_Index  (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER,
   BMODE          IN          VARCHAR2 DEFAULT NULL )
IS
   l_errbuf varchar2(2000);
   l_retcode number;
   l_mode varchar2(5);
BEGIN
   l_mode := bmode;

   if(bmode is null) then
      l_mode := 'S';

-- 'DR_Mode: Added Support for 'DR' mode
   elsif( bmode not in ('DR','S','OFAST', 'OFULL')) then
      errbuf := 'Invalid mode specified';
      begin
         --3..FND_FILE.PUT_LINE(3..FND_FILE.LOG, errbuf);
         FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      exception
         when others then
         null;
      end;

      retcode := 2;
      return;
   end if;

   Sync_Summary_Index (l_errbuf, l_retcode, l_mode);

   -- If not success, return error
   if( l_retcode <> 0 ) then
      errbuf  := l_errbuf;
      retcode := l_retcode;
   end if;

   -- Return successfully
   errbuf  := 'Success';
   retcode := 0;

END SYNC_ALL_INDEX;

PROCEDURE Sync_Summary_Index  (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER,
   BMODE          IN          VARCHAR2)

IS

-- To fix bug 3431755 added owner to the where clause
   -- cursor to get the owner of the CTX_SUMMARY_INDEX
   cursor get_ind_owner (p_owner varchar2) is
   select owner
   from   all_indexes
   where  index_name  = 'SUMMARY_CTX_INDEX'
   and    owner = p_owner
   and    index_type  = 'DOMAIN';

-- end of changes for bug 3431755

   l_ind_owner       VARCHAR2(90);
   sql_stmt1         VARCHAR2(250);

BEGIN

   if(bmode is null or bmode not in ('DR', 'S', 'OFAST', 'OFULL')) then
      errbuf := 'Invalid mode specified';

      begin
         --3..FND_FILE.PUT_LINE(3..FND_FILE.LOG, errbuf);
         FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      exception
         when others then
         null;
      end;

      retcode := 2;
      return;
   end if;

   --DR_MODE
   --1. Process the DR mode. We should not check the index
   --   owner before creating index, as we drop the index
   --   before calling the create index.
   IF (bmode = 'DR') THEN
      create_summary_index(errbuf,
                           retcode
                           );
   ELSE -- If not DR mode, process as it used to.

      open  get_ind_owner(g_cs_short_name);
      fetch get_ind_owner into l_ind_owner;

      if ( get_ind_owner%NOTFOUND ) then
         close get_ind_owner;

         errbuf := 'Index SUMMARY_CTX_INDEX is not found. Please create the domain index ' ||
	         	'before executing this concurrent program.';
         begin
            FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
         exception
            when others then
               null;
         end;
         retcode := 2;
         return;
      end if;

      close get_ind_owner;

      sql_stmt1 := 'alter index ' || l_ind_owner || '.summary_ctx_index REBUILD ONLINE';

      if(bmode = 'S') then
         sql_stmt1 := sql_stmt1 || ' parameters (''SYNC'') ';
      elsif(bmode = 'OFAST') then
         sql_stmt1 := sql_stmt1 || ' parameters (''OPTIMIZE FAST'') ';
      elsif(bmode = 'OFULL') then
         sql_stmt1 := sql_stmt1 || ' parameters (''OPTIMIZE FULL'') ';
      end if;

      if (bmode = 'S') then
       --ctx_ddl.sync_index( '1..summary_ctx_index' );
         ad_ctx_ddl.sync_index( l_ind_owner ||'.summary_ctx_index' );
      else
         EXECUTE IMMEDIATE sql_stmt1;
      end if;
   END IF;

   -- Return successfully
   errbuf := 'Success';
   retcode := 0;

EXCEPTION
   WHEN OTHERS THEN
      -- Return error
      errbuf := 'Unexpected error while attempting to sync domain index SUMMARY_CTX_INDEX.'
		|| ' Error : '|| SQLERRM;

      begin
         FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      exception
         when others then
            null;
      end;

      retcode := 2;

END Sync_Summary_Index;

---------------- (TEXT) -----------------------------

  -- Internal function: sync_index
  FUNCTION Sync_index(  index1   IN VARCHAR2,
                        bmode    IN VARCHAR2,
                        pindex_with IN VARCHAR2,
                        pworker  IN NUMBER DEFAULT 0)
  Return VARCHAR2
  IS
    l_index_name VARCHAR2(300) :=index1; -- g_cs_short_name||'.'||index1;

    l_max_worker     NUMBER        := get_max_parallel_worker;
    l_db_version     NUMBER        := null;
    l_compatibility  VARCHAR2(100) := null;
    l_db_version_str VARCHAR2(100) := null;
    l_worker         NUMBER        := pworker;
    l_index_with     VARCHAR2(30)  := pindex_with;


  BEGIN

    IF bmode = 'S' THEN
      ad_ctx_ddl.sync_index( l_index_name );
    ELSIF bmode = 'OFAST' THEN
      ad_ctx_ddl.optimize_index( l_index_name, CTX_DDL.OPTLEVEL_FAST, NULL, NULL );
    ELSIF bmode = 'OFULL' THEN
      ad_ctx_ddl.OPTIMIZE_INDEX( l_index_name, CTX_DDL.OPTLEVEL_FULL, NULL, NULL );
    ELSIF bmode = 'R' THEN

-- Start of change for bug fix 4321240
--

       DBMS_UTILITY.db_version(l_db_version_str, l_compatibility);
       If l_db_version_str is null Then
           l_db_version := 8;
       Else
        l_db_version := to_number(substr(l_db_version_str, 1,
                                        (instr(l_db_version_str, '.'))-1));
       End If;

       If l_db_version Is Not Null Then
         If l_db_version > 8 Then
            IF l_index_with = 'PARALLEL' THEN
               IF l_worker > l_max_worker THEN
                  l_worker := l_max_worker;
               END IF;
               IF l_worker > 0 THEN
                  EXECUTE IMMEDIATE 'alter index ' || l_index_name ||' REBUILD parallel '||TO_CHAR(l_worker);
               ELSE
                  EXECUTE IMMEDIATE 'alter index ' || l_index_name || ' REBUILD';
               END IF;
            ELSIF l_index_with = 'ONLINE' THEN
               EXECUTE IMMEDIATE 'alter index ' || l_index_name ||' REBUILD PARAMETERS (''REPLACE'') ONLINE';

            END IF;
         ELSE
            EXECUTE IMMEDIATE 'alter index ' || l_index_name ||' REBUILD';
         End if; -- l_db_version eof
       End If;
--
-- End of bug fix for bug 4321240

    ELSIF bmode = 'DR' THEN
      -- logic to drop or create is taken in the individual api.
      NULL;
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,
    		fnd_message.get_string('CS', 'CS_KB_SYN_INDEX_INV_MODE'));
      RAISE invalid_mode_error; -- let the exception populate back to the caller.
    END IF;

    Return 'Y';
  END Sync_index;

/*
 *  Internal
 *  is_validate_mode: VALIDATE a synchronization MODE.
 *  RETURN 'Y' IF THE MODE IS valid. Otherwise RETURN 'N'.
 */
  FUNCTION is_validate_mode(bmode IN VARCHAR2) RETURN VARCHAR
   IS
     l_valid_mode VARCHAR2(1)  := 'Y';
     l_mode       VARCHAR2(10) := bmode;
  BEGIN
    IF l_mode NOT IN ('S', 'R', 'OFAST', 'OFULL', 'DR' ) THEN
      l_valid_mode := 'N';
    END IF;
    RETURN l_valid_mode;
  END;

/*
 * Internal
 * get_max_parallel_worker: return the max number of processes
 *                          to be used for parallel indexing.
 */
  FUNCTION get_max_parallel_worker RETURN NUMBER
   IS
     l_worker NUMBER := 0;
  BEGIN
     SELECT to_number(nvl(VALUE, 0)) INTO  l_worker FROM v$parameter
     WHERE NAME = 'job_queue_processes';

     RETURN l_worker;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_worker;
  END;

/*
 * Internal
 * resolve_parallel_indexing: Return an indexing command line that
 *  enables parallel indexing.
 */
  FUNCTION resolve_parallel_indexing (
      p_create_cmd    IN VARCHAR2,
      p_worker        IN NUMBER DEFAULT 0,
      p_index_with    IN VARCHAR2
      ) RETURN VARCHAR
  IS
     l_cmd VARCHAR2(500) := p_create_cmd;
     l_worker        NUMBER   := p_worker;
     l_max_worker    NUMBER   := get_max_parallel_worker;
     l_index_with    VARCHAR2(30) := p_index_with;

     --3576867
     l_db_version NUMBER := null;
     l_compatibility VARCHAR2(100) := null;
     l_db_version_str VARCHAR2(100) := null;
  BEGIN
    If p_worker is null Then
      l_worker := 0;
    End If;

    DBMS_UTILITY.db_version(l_db_version_str, l_compatibility);
    If l_db_version_str is null Then
        l_db_version := 8;
    Else
     l_db_version := to_number(substr(l_db_version_str, 1,
                                     (instr(l_db_version_str, '.'))-1));
    End If;

    If l_db_version Is Not Null Then
      If l_db_version > 8 Then

-- Start of change for bug fix 4321240
--
         IF l_index_with = 'PARALLEL' THEN
            IF l_worker > l_max_worker THEN
               l_worker := l_max_worker;
            END IF;
            IF l_worker > 0 THEN
               l_cmd := l_cmd || ' parallel '||TO_CHAR(l_worker);
            END IF;
         ELSIF l_index_with = 'ONLINE' THEN
            l_cmd := l_cmd || ' ONLINE';
         END IF;
--
-- End of change for bug fix 4321240

      End if; -- l_db_version eof
    Else
      l_worker := 0;
    End If;

    RETURN l_cmd;
  EXCEPTION
     WHEN OTHERS  THEN
      -- any errors: do not append anything.
      RETURN p_create_cmd;
  END resolve_parallel_indexing;


-- New internal procedures for bug 4917652
/*
 * Populate service request text index.
 * Index coulmn: cs_incidents_all_b.text_index
 */
PROCEDURE populate_sr_text_index (
         x_msg_error     OUT NOCOPY VARCHAR2,
         x_return_status OUT NOCOPY VARCHAR2)
IS
 CURSOR all_srs IS
   SELECT rowid
   FROM cs_incidents_all_tl;

  TYPE l_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  l_rowid_list      l_rowid_type;
  l_index_name      VARCHAR2(250);

BEGIN
  -- Initialize local variables.
  x_return_status := fnd_api.G_RET_STS_SUCCESS;
  l_index_name    := 'CS_INCIDENTS_ALL_TL_N1';

  -- Bulk fetch a list of row id
  OPEN all_srs;
  LOOP
      FETCH all_srs BULK COLLECT INTO l_rowid_list limit G_BATCH_SIZE;
      FORALL i IN l_rowid_list.FIRST..l_rowid_list.LAST
        UPDATE cs_incidents_all_tl
        SET text_index = 'X'
        WHERE rowid = l_rowid_list(i);

      COMMIT;

      -- Check if all_srs is notfound.
      -- NOTE: this check should come at the end because for the last batch
      -- the total number of sets being fetched may be less than the G_BATCH_SIZE.
      -- If l_rowid_list is not filled with the exact number as the G_BATCH_SIZE,
      -- all_srs%notfound is true. Putting this at the end
      -- guarantees we process the last batch.
      EXIT WHEN all_srs%NOTFOUND;
  END LOOP;
  CLOSE all_srs;

  -- Call index synchronziation with
  -- bmode: 'S'
  -- pindex_with:
  -- pworker: 0
  x_return_status := Sync_index(
                         g_cs_short_name||'.'|| l_index_name,
                         'S',
                         'Online' -- will be by-passed in Sync_index for S mode
                         );
EXCEPTION
  WHEN OTHERS  THEN
    ROLLBACK; -- do not use savepoint because savepoint is cleared when commit.
    x_msg_error := 'populate_sr_text_index: '
         ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '
         ||SQLERRM;
    x_return_status := fnd_api.G_RET_STS_ERROR;
END populate_sr_text_index;
-- 4917652_eof

/*
 * Sync_Text_Index
 *  Synchronize the CS_INCIDENTS_ALL_TL_N1 text index.
 *  Supported mode: S, DR, OFAST, OFAST, R
 */
 PROCEDURE Sync_Text_Index (
      ERRBUF OUT NOCOPY VARCHAR2,
      RETCODE OUT NOCOPY NUMBER,
      BMODE IN VARCHAR2,
      PINDEX_WITH IN VARCHAR2,
      pworker  IN NUMBER DEFAULT 0)

  IS
    index3 VARCHAR2(250) := 'CS_INCIDENTS_ALL_TL_N1';
    l_mode VARCHAR2(10)  := bmode;
    l_return_status VARCHAR2(1) :=  fnd_api.G_RET_STS_ERROR;
    l_create_cmmd VARCHAR2(500):= NULL;
    l_index_with varchar2(30) := pindex_with;

  BEGIN
   -- Initialize some variables
   retcode := 2; -- init return val to FAIL

   IF l_mode IS NULL THEN  -- default it to 'Sync'
    l_mode := 'S';
   END IF;

   l_index_with := nvl(l_index_with, 'ONLINE');

   IF is_validate_mode(l_mode) = 'N' THEN
    RAISE invalid_mode_error;
   END IF;

    -- check whether it is 'DR'
    IF l_mode = 'DR' THEN
      Drop_Index(index3,
                 errbuf,
                 l_return_status);
      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE drop_index_error;
      END IF;

      -- Create the index
      l_create_cmmd :=
     	  ' CREATE INDEX '||g_cs_short_name||'.cs_incidents_all_tl_n1 '
        ||'on '||g_cs_short_name||'.cs_incidents_all_tl(text_index) '
        ||' indextype is ctxsys.context parameters ('''
        ||' datastore '||g_apps_short_name||'.CS_SR_TEXT_INDEX_ELES '
        ||' section group '||g_apps_short_name||'.CS_SR_BASIC_GRP '
        ||' lexer '||g_apps_short_name
        ||'.CS_SR_GLOBAL_LEXER language column  SOURCE_LANG '
        --4917652: leave command opened for further processing
        ||' storage '||g_apps_short_name||'.CS_SR_INDEX_STORAGE'; --< command not yet completed
        --4917652_eof

     -- 4917652:
     -- If index with ONLINE mode, then we should create the index with nopopulate and
     -- then mark the index offline for rebuild.
     -- Else, create the text index in parallel. Note that this operation will block
     -- any DML on the table.
     IF  l_index_with = 'ONLINE' THEN
        -- Create index online
        -- 1. Create index without populate
        l_create_cmmd := l_create_cmmd || ' nopopulate '') ';
     ELSE -- then, it is with Parallel mode.
        -- 1. Completes the uncompleted command.
        l_create_cmmd := l_create_cmmd || ''')';

        -- 2. Resolve parallel indexing command.
        l_create_cmmd := resolve_parallel_indexing(
                         l_create_cmmd,
                         pworker,
                         l_index_with);
     END IF;
     -- 4917652_eof

      Begin
         EXECUTE IMMEDIATE l_create_cmmd;

         -- 4917652
         -- If it is online mode, then we need to sync the index.
         IF  l_index_with = 'ONLINE' THEN
            populate_sr_text_index (
                x_msg_error     => errbuf,
                x_return_status => l_return_status);
         END IF;
         -- 4917652_eof

      Exception
         When others then
           errbuf := 'Sync_Text_Index: '||index3||' :'
               ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
         Raise create_index_error;
      End;
    ELSE -- Then it is OFAST, OFULL, S, and R modes:

      -- 4917652
      IF  l_index_with = 'ONLINE' AND bmode = 'R' THEN
         populate_sr_text_index (
      	    x_msg_error     => errbuf,
            x_return_status => l_return_status);
      ELSE
         l_return_status := Sync_index(g_cs_short_name||'.'|| index3,
                                    bmode,
                                    pindex_with,
                                    pworker );
      END IF;
      -- 4917652_eof
    END IF;

   -- Return successfully
   errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
   retcode := 0;
 EXCEPTION
  WHEN invalid_mode_error THEN
      errbuf := fnd_message.get_string('CS',
                                       'CS_KB_SYN_INDEX_INV_MODE');
  WHEN drop_index_error THEN
    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
  WHEN create_index_error THEN
    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
  WHEN others THEN
      errbuf := 'Sync_Text_Index: '||
              fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '|| SQLERRM;
    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
   END Sync_Text_Index;

 /* Drop_index
  *  Check whether a text index exists in the CS schema. If yes, drops it.
  */
  PROCEDURE Drop_Index
  ( p_index_name IN VARCHAR,
    x_msg_error     OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2
  )
  IS
     drop_index VARCHAR2(100) := NULL;

     CURSOR get_index_cursor(p_index_name VARCHAR2, p_owner VARCHAR2) IS
       SELECT COUNT(*) FROM dba_indexes
       WHERE index_name = UPPER(p_index_name)
       AND owner= UPPER(p_owner);
     l_total NUMBER := 0;

  BEGIN
    x_return_status := fnd_api.G_RET_STS_ERROR;
    IF  p_index_name IS NULL THEN
       RETURN;
    END IF;

    -- If and only if the index exists:
    OPEN get_index_cursor(p_index_name, g_cs_short_name);
    FETCH get_index_cursor INTO l_total;
    CLOSE get_index_cursor;

    IF l_total > 0 THEN
      drop_index := 'drop index '||g_cs_short_name||'.'||p_index_name||' force ';
      EXECUTE IMMEDIATE drop_index;
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN others THEN
      x_msg_error := 'Drop_Index: '||
           fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '|| SQLERRM;
  END Drop_Index;



-------------- (TEXT) eof ----------------------------


END CS_SR_SYNC_INDEX_PKG;

/
