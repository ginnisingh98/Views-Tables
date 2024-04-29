--------------------------------------------------------
--  DDL for Package Body IBC_CONTENT_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CONTENT_SYNC_INDEX_PKG" AS
/* $Header: ibcsyinb.pls 120.3 2005/09/01 21:37:03 srrangar noship $ */

   -- errbuf = err messages
   -- retcode = 0 success, 1 = warning, 2=error
   -- bmode: S = sync  OFAST=optimize fast, OFULL = optimize full

  -- Add global exception handlers.
  invalid_mode_error   EXCEPTION;
  invalid_action_error EXCEPTION;
  drop_index_error     EXCEPTION;
  create_index_error   EXCEPTION;
  rebuild_cache_error  EXCEPTION;

  -- Declare ibc and apps schema.
  g_apps_short_name VARCHAR2(10) := UPPER('APPS'); -- set at patching
  g_ibc_short_name   VARCHAR2(10) := UPPER('IBC'); -- set at patching

  -- Internal function: sync_index
  FUNCTION Sync_index(  index1   IN VARCHAR2,
                        bmode    IN VARCHAR2,
                        pworker  IN NUMBER DEFAULT 0)
  Return VARCHAR2
  IS
    l_index_name VARCHAR2(300) := index1; --g_ibc_short_name||'.'||index1;

  BEGIN

    IF bmode = 'S' THEN
      ad_ctx_ddl.sync_index( l_index_name );
    ELSIF bmode = 'OFAST' THEN
      ad_ctx_ddl.optimize_index( l_index_name, CTX_DDL.OPTLEVEL_FAST, NULL, NULL );
    ELSIF bmode = 'OFULL' THEN
      ad_ctx_ddl.OPTIMIZE_INDEX( l_index_name, CTX_DDL.OPTLEVEL_FULL, NULL, NULL );
    ELSIF bmode = 'R' THEN
      EXECUTE IMMEDIATE 'alter index ' || l_index_name ||' REBUILD';
    ELSIF bmode = 'DR' THEN
      -- logic to drop or create is taken in the individual api.
      NULL;
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,
    		fnd_message.get_string('ibc', 'IBC_SYNC_INDEX_INV_MODE'));
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
 * enables parallel indexing.
 */
  FUNCTION resolve_parallel_indexing (
      p_create_cmd    IN VARCHAR2,
      p_worker        IN NUMBER DEFAULT 0
      ) RETURN VARCHAR
  IS
     l_cmd VARCHAR2(500) := p_create_cmd;
     l_worker        NUMBER   := p_worker;
     l_max_worker    NUMBER   := get_max_parallel_worker;


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
       IF l_worker > l_max_worker THEN
   	   l_worker := l_max_worker;
     	END IF;
      End if; -- l_db_version eof
    Else
      l_worker := 0;
    End If;

    IF l_worker > 0 THEN
      l_cmd := l_cmd || ' parallel '||TO_CHAR(l_worker);
    END IF;

    RETURN l_cmd;
  EXCEPTION
     WHEN OTHERS  THEN
      -- any errors: do not append anything.
      RETURN p_create_cmd;
  END resolve_parallel_indexing;

/*
 *  Sync_Text_Index
 *  Synchronize the IBC_CITEM_VERSIONS_TL_CTX1 text index.
 *  Supported mode: S, DR, OFAST, OFAST, R
 */
 PROCEDURE Sync_Text_Index (
      ERRBUF OUT NOCOPY VARCHAR2,
      RETCODE OUT NOCOPY NUMBER,
      BMODE IN VARCHAR2,
      pworker  IN NUMBER DEFAULT 0)
  IS

   cursor c_index_name(l_index_name IN VARCHAR2) is
   select idx_name from ctxsys.ctx_indexes
   where idx_name=l_index_name
   and upper(idx_owner)=UPPER('IBC');

    index3 VARCHAR2(250) := 'IBC_CITEM_VERSIONS_TL_CT1';
    index1 VARCHAR2(250) := 'IBC_ATTRIBUTE_BUNDLES_CTX';
    l_mode VARCHAR2(10)  := bmode;
    l_return_status VARCHAR2(1) :=  fnd_api.G_RET_STS_ERROR;
    l_create_cmmd VARCHAR2(500):= NULL;
    l_temp VARCHAR2(250);

  BEGIN
   -- Initialize some variables
   retcode := 2; -- init return val to FAIL

   OPEN c_index_name(index3);
   FETCH c_index_name INTO l_temp;

    IF c_index_name%NOTFOUND THEN
	l_mode := 'DR';
    END IF ;

    CLOSE c_index_name;

   IF l_mode IS NULL THEN  -- default it to 'Sync'
    l_mode := 'S';
   END IF;

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
     	  ' CREATE INDEX '||g_ibc_short_name||'.'||index3
        ||' on '||g_ibc_short_name||'.ibc_citem_versions_tl(textidx) '
        ||' indextype is ctxsys.context parameters ('''
        ||' datastore '||g_apps_short_name||'.IBC_CONTENT_INDEX_ELES '
	||' section group '||g_apps_short_name||'.IBC_CONTENT_BASIC_GRP '
        ||' lexer '||g_apps_short_name
        ||'.IBC_CONTENT_GLOBAL_LEXER language column  SOURCE_LANG '
	||' storage '||g_apps_short_name||'.IBC_CONTENT_INDEX_STORAGE'') ';

      l_create_cmmd := resolve_parallel_indexing(l_create_cmmd, pworker);

      Begin
         EXECUTE IMMEDIATE l_create_cmmd;
      Exception
         When others then
           errbuf := 'Sync_Text_Index: '||index3||' :'
               ||fnd_message.GET_STRING('IBC','IBC_UNEXPECTED_ERROR')||' '||SQLERRM;
         Raise create_index_error;
      End;
    ELSE
      -- execute  sync on IBC_CITEM_VERSIONS_TL_CT1
      l_return_status := Sync_index(g_ibc_short_name||'.'|| index3,
                                    bmode );
      -- execute sync on IBC_ATTRIBUTE_BUNDLES_CTX
      l_return_status := Sync_index(g_ibc_short_name||'.'|| index1,
                                    bmode );

    END IF;

   -- Return successfully
   errbuf := fnd_message.get_string('IBC', 'IBC_SUCCESS');
   retcode := 0;
 EXCEPTION
  WHEN invalid_mode_error THEN
      errbuf := fnd_message.get_string('IBC',
                                       'IBC_SYNC_INDEX_INV_MODE');
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
              fnd_message.GET_STRING('IBC','IBC_UNEXPECTED_ERROR')||' '|| SQLERRM;
    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
   END Sync_Text_Index;

 /* Drop_index
  * Check whether a text index exists in the IBC schema. If yes, drop it.
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
    OPEN get_index_cursor(p_index_name, g_ibc_short_name);
    FETCH get_index_cursor INTO l_total;
    CLOSE get_index_cursor;

    IF l_total > 0 THEN
      drop_index := 'drop index '||g_ibc_short_name||'.'||p_index_name||' force ';
      EXECUTE IMMEDIATE drop_index;
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN others THEN
      x_msg_error := 'Drop_Index: '||
           fnd_message.GET_STRING('IBC','IBC_UNEXPECTED_ERROR')||' '|| SQLERRM;
  END Drop_Index;

  /*
   * Request_Content_Sync_Index - This procedure submits a concurrent request
   * to sync Content Text indexes.
   */

  PROCEDURE Request_Content_Sync_Index
  ( x_request_id    OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2 )
  IS
    l_request_id            NUMBER;
    l_sync_idx_progname     VARCHAR2(100) := 'IBC_CONTENT_SYNC_TEXT_INDEX';
    l_sync_mode             VARCHAR2(1) := 'S';
    l_pending_phase_code    VARCHAR2(1) := 'P';
    l_num_pending_requests  NUMBER := 0;
    l_return_status         VARCHAR2(1) := fnd_api.G_RET_STS_ERROR;
  begin

    -- Detect how many Pending, but not scheduled Content Sync-Index
    -- concurrent program requests.
    select count(*)
    into l_num_pending_requests
    from fnd_concurrent_programs cp,
      fnd_application ap,
      fnd_concurrent_requests cr
    where ap.application_short_name = g_ibc_short_name
      and cp.concurrent_program_name = l_sync_idx_progname
      and cp.application_id = ap.application_id
      and cr.concurrent_program_id = cp.concurrent_program_id
      and cr.phase_code = l_pending_phase_code
      and cr.requested_start_date <= sysdate;

    --
    -- If there are no unscheduled pending Content Sync-Index concurrent
    -- requests, then submit one. Otherwise, if there is already
    -- an unscheduled pending request, which will anyway run
    -- there is no need to submit another request.
    --

    if( l_num_pending_requests = 0 )
    then
      l_request_id :=
        fnd_request.submit_request
        ( application => g_ibc_short_name,
          program     => l_sync_idx_progname,
          description => null,
          start_time  => null,
          sub_request => FALSE,
          argument1   => l_sync_mode,
	  argument2   => 0);

    if( l_request_id > 0 )
      then
        l_return_status := fnd_api.G_RET_STS_SUCCESS;
      end if;
    else
      -- There is already a pending request, so just return success
      l_request_id := 0;
      l_return_status := fnd_api.G_RET_STS_SUCCESS;
    end if;

    x_request_id := l_request_id;
    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      x_request_id := 0;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END Request_Content_Sync_Index;

END IBC_CONTENT_SYNC_INDEX_PKG;

/
