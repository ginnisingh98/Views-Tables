--------------------------------------------------------
--  DDL for Package Body CS_KB_CONC_PROG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_CONC_PROG_PKG" AS
/* $Header: csksynib.pls 120.2.12010000.3 2009/10/15 06:54:13 amganapa ship $ */

  /* errbuf = err messages
     retcode = 0 SUCCESS, 1 = warning, 2=error
  */

  /* bmode: S = sync  OFAST=optimize fast, OFULL = optimize full,
            R = REBUILD, DR = DROP/Recreate
  */

  -- **********************
  --  PRIVATE DECLARATIONS
  -- **********************

  invalid_mode_error EXCEPTION;
  invalid_action_error EXCEPTION;
  drop_index_error     EXCEPTION;
  create_index_error   EXCEPTION;
  rebuild_cache_error  EXCEPTION;

  g_cs_short_name   VARCHAR2(10) := UPPER('CS'); -- set at patching
  g_apps_short_name VARCHAR2(10) := UPPER('APPS'); -- set at patching
  -- New for bug 4321268
  G_BATCH_SIZE      NUMBER := 10000;
  --This flag was set to Y to fix bug 8757484
  attachment_flag  VARCHAR2(3):= 'Y'; --12.1.3

   -- New internal procedures for bug 4321268
  /*
   *   Populate solution text index.
   *
   */
  PROCEDURE populate_set_index (
		    x_msg_error     OUT NOCOPY VARCHAR2,
  	            x_return_status OUT NOCOPY VARCHAR2
		   )
  IS
   CURSOR all_published_solutions IS
     SELECT tl.rowid -- tl.set_id
     FROM cs_kb_sets_tl tl, cs_kb_sets_b b
     WHERE b.set_id = tl.set_id
     AND b.status = 'PUB';


    TYPE l_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    l_rowid_list      l_rowid_type;

    l_soln_comp_index VARCHAR2(250) := 'CS_KB_SETS_TL_N3';
     l_soln_comp_attach_index VARCHAR2(250) := 'CS_KB_SETS_ATTACH_TL_N3';  --12.1.3

  BEGIN
  --12.1.3
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.populate_set_index',
                     ' attachment_flag:'||attachment_flag);
    END IF;



      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.populate_set_index',
                     'l_soln_comp_index:'||l_soln_comp_index);
    END IF;
  --12.1.3
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Fetch out the list of IDs for all published solutions
    OPEN all_published_solutions;
    LOOP
        FETCH all_published_solutions BULK COLLECT INTO l_rowid_list limit G_BATCH_SIZE;
	--12.1.3
	--The else condition was commented to fix bug 8757484
	IF attachment_flag = 'Y' THEN
		FORALL i IN l_rowid_list.FIRST..l_rowid_list.LAST

		  UPDATE cs_kb_sets_tl
		  SET composite_assoc_attach_index = 'R'
		  WHERE rowid = l_rowid_list(i);
	--ELSE
		FORALL i IN l_rowid_list.FIRST..l_rowid_list.LAST
		  UPDATE cs_kb_sets_tl
		  SET composite_assoc_index = 'R'
		  WHERE rowid = l_rowid_list(i);
        END IF;
        --12.1.3
        COMMIT;
    /*
        -- click off the sync. program
        launch_sync_request(
                   p_mode              => 'S',
                   p_conc_request_name => 'CS_KB_SYNC_SOLUTIONS_INDEX',
		   x_msg_error         => x_msg_error,
		   x_return_status     => x_return_status );

        IF x_return_status != fnd_api.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;

        x_return_status := fnd_api.G_RET_STS_SUCCESS;
     */

        -- Check if all_published_solutions is notfound.
        -- NOTE: this check should come at the end because for the last batch
        -- the total number of sets being fetched may be less than the l_batch_size.
        -- If l_set_id_list is not filled with the exact number as the l_batch_size,
        -- all_published_solutons%notfound is true. Putting this at the end
        -- guarantees we process the last batch.
         EXIT WHEN all_published_solutions%NOTFOUND;
    END LOOP;
    CLOSE all_published_solutions;
    Sync_index( l_soln_comp_index, 'S', 0 );
--12.1.3
   --Commented to fix bug 8757484
   --IF attachment_flag = 'Y' THEN
     Sync_index( l_soln_comp_attach_index, 'S', 0 );
  -- END IF;
 --12.1.3
  EXCEPTION
    WHEN OTHERS  THEN
      ROLLBACK; -- do not use savepoint because savepoint is cleared when commit.
      x_msg_error := 'populate_set_index: '
	  ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END populate_set_index;

  /*
   *   Populate element text index.
   *
   */
  PROCEDURE populate_element_index (
	   x_msg_error     OUT NOCOPY VARCHAR2,
	   x_return_status OUT NOCOPY VARCHAR2
		   )
  IS
      l_statement_comp_index VARCHAR2(250) := 'CS_KB_ELEMENTS_TL_N2';
  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    SAVEPOINT populate_element_index_SAV;

    -- We do not use bulk update in this case because the concurrent request
    -- is incompatbile with itself. Even we kick off the sync. request, it
    -- will be in pending status until "DR" or "R" request is finished. So,
    UPDATE /*+ parallel(t) */ cs_kb_elements_tl t
    SET t.composite_text_index = 'B';

    COMMIT;

    -- Reestablish savepoint, as commit cleared it.
    SAVEPOINT populate_element_index_SAV;

    -- Start synchronizing index.
    Sync_index( l_statement_comp_index, 'S', 0 );

  EXCEPTION
    WHEN OTHERS  THEN
      ROLLBACK TO populate_element_index_SAV;
      x_msg_error := 'populate_element_index: '
	  ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END populate_element_index;


  /*
   *   Populate soluton categories text index.
   *
   */
  PROCEDURE populate_soln_cat_index (
  	        x_msg_error     OUT NOCOPY VARCHAR2,
 	     	x_return_status OUT NOCOPY VARCHAR2
		   )
  IS
    index1 VARCHAR2(250) := 'CS_KB_SOLN_CAT_TL_N1';

  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    SAVEPOINT populate_soln_cat_index_SAV;
    UPDATE /*+ parallel(t) */ cs_kb_soln_categories_tl t
    SET t.name = t.name;

    COMMIT;

    -- reestablish savepoint after commit.
    SAVEPOINT populate_soln_cat_index_SAV;

    -- Start index synchronization
    Sync_index( index1, 'S', 0 );

  EXCEPTION
    WHEN OTHERS  THEN
      ROLLBACK TO populate_soln_cat_index_SAV;
      x_msg_error := 'populate_sol_cat_index: '
	  ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END populate_soln_cat_index;


  /*
   *   Populate forum index.
   *
   */
  PROCEDURE populate_forum_index (
	        x_msg_error     OUT NOCOPY VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2
		   )
  IS
    index3 VARCHAR2(250) := 'CS_FORUM_MESSAGES_TL_N4';
  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    SAVEPOINT populate_forum_index_SAV;

    UPDATE /*+ parallel(t) */ cs_forum_messages_tl t
    SET t.composite_assoc_col = 'B';

    COMMIT;

    -- reestablish savepoint after commit
    SAVEPOINT populate_forum_index_SAV;

     -- Start index synchronization
     Sync_index( index3, 'S', 0 );
  EXCEPTION
    WHEN OTHERS  THEN
      ROLLBACK TO populate_forum_index_SAV;
      x_msg_error := 'populate_forum_index: '
	  ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END populate_forum_index;
 -- 4321268_new_apis_eof
  /*
   *  get_max_parallel_worker: get THE job_queue_processes value.
   */
  FUNCTION get_max_parallel_worker RETURN NUMBER
   IS
     l_worker NUMBER := 0;

     -- 4321268
     -- Fetch the correct paremeters to calculate max. parallel workers.
     CURSOR get_param_value(p_name IN varchar2) IS
     SELECT to_number(nvl(VALUE, 0))
     FROM v$parameter
     WHERE name = lower(p_name);

     l_cpu_count NUMBER;
     l_thread_per_cpu NUMBER;
     -- 4321268_eof
  BEGIN
  --4321268
    OPEN get_param_value('cpu_count');
    FETCH get_param_value INTO l_cpu_Count;
    CLOSE get_param_value;

    OPEN get_param_value('parallel_threads_per_cpu');
    FETCH get_param_value INTO l_thread_per_cpu;
    CLOSE get_param_value;

   --  SELECT to_number(nvl(VALUE, 0)) INTO  l_worker FROM v$parameter
   --  WHERE NAME = 'job_queue_processes';
    l_worker := l_cpu_count * l_thread_per_cpu;
  --4321268
     RETURN l_worker;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_worker;
  END;

  /*
   *  is_validate_mode: VALIDATE a synchronization MODE.
   *  RETURN 'Y' IF THE MODE IS valid. Otherwise RETURN 'N'.
   */
  FUNCTION is_validate_mode(bmode IN VARCHAR2) RETURN VARCHAR
   IS
     l_valid_mode VARCHAR2(1)  := 'Y';
     l_mode       VARCHAR2(10) := bmode;
  BEGIN
    IF l_mode NOT IN ('S', 'R', 'OFAST', 'OFULL', 'RC', 'DR' ) THEN
      l_valid_mode := 'N';
    END IF;
    RETURN l_valid_mode;

  END;

 	/*
   * do_create
   *   This PROCEDURE executes THE CREATE command.
   */
  PROCEDURE do_create ( p_create_cmd    IN VARCHAR2,
		        p_index_name    IN VARCHAR2,
		        p_index_version IN VARCHAR2,
			x_msg_error     OUT NOCOPY VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2
		   )
  IS

   l_update VARCHAR2(1) := 'Y';
  BEGIN
     -- initialize return status
     x_return_status := fnd_api.G_RET_STS_ERROR;

     EXECUTE IMMEDIATE p_create_cmd;

     x_return_status := fnd_api.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS  THEN
      x_msg_error := 'do_create: '||p_index_name||' :'
	||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
      x_return_status := fnd_api.G_RET_STS_ERROR;
  END do_create;


  /*
   * resolve_parallel_indexing
   */
  FUNCTION resolve_parallel_indexing (
               p_create_cmd    IN VARCHAR2,
	       p_worker        IN NUMBER DEFAULT 0
               ) RETURN VARCHAR
  IS
     l_cmd VARCHAR2(500) := p_create_cmd;
     l_worker        NUMBER       := p_worker;
     l_max_worker    NUMBER       := get_max_parallel_worker;

     --3576867
     l_db_version NUMBER := null;
     l_compatibility VARCHAR2(100) := null;
     l_db_version_str VARCHAR2(100) := null;
  BEGIN
    --3576867
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
    -- 3576867 eof

    IF l_worker > 0 THEN
      l_cmd := l_cmd || ' parallel '||TO_CHAR(l_worker);
    END IF;

    RETURN l_cmd;
  EXCEPTION
     WHEN OTHERS  THEN
      -- any errors: do not append anything.
      RETURN p_create_cmd;
  END resolve_parallel_indexing;

  -- ************************
  --  PUBLIC IMPLEMENTATIONS
  -- ************************

  PROCEDURE Sync_index( index1   IN VARCHAR2,
                        bmode    IN VARCHAR2,
                        pworker  IN NUMBER DEFAULT 0)
  IS
    l_index_name VARCHAR2(300) := g_cs_short_name||'.'||index1;

  BEGIN
    IF bmode = 'S' THEN
      AD_CTX_DDL.sync_index( l_index_name );
    ELSIF bmode = 'OFAST' THEN
      AD_CTX_DDL.OPTIMIZE_INDEX( l_index_name, CTX_DDL.OPTLEVEL_FAST, NULL, NULL );
    ELSIF bmode = 'OFULL' THEN
      AD_CTX_DDL.OPTIMIZE_INDEX( l_index_name, CTX_DDL.OPTLEVEL_FULL, NULL, NULL );
    ELSIF bmode = 'R' THEN
     --  4321268: rebuild in parallel mode always. Serial online mode,
     --           is taking care in the individual index program.
      IF pworker IS NOT NULL AND pworker > 0 THEN

        EXECUTE IMMEDIATE 'alter index ' || l_index_name ||' REBUILD parallel '|| to_char(pworker);
      END IF;
     -- 4321268_eof
    ELSIF bmode = 'DR' THEN
      -- logic to drop or create is taken in the individual api.
      NULL;
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,
    		fnd_message.get_string('CS', 'CS_KB_SYN_INDEX_INV_MODE'));
      RAISE invalid_mode_error;
    END IF;
  END Sync_index;


  /*
   * Sync_All_index: synchronize ALL KM indices IN serial MODE.
   * Deprecated since 11.5.10.
   */
  PROCEDURE Sync_All_Index  (ERRBUF OUT NOCOPY VARCHAR2,
                             RETCODE OUT NOCOPY NUMBER,
                             BMODE IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN

     -- Return successfully
    errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
    retcode :=0;
  END Sync_All_Index;

   /*
   * Create_Set_Index
   *   This PROCEDURE creates THE solution INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Set_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  )
  IS
     l_create_cmmd VARCHAR2(500):= NULL;
      l_create_cmmd1 VARCHAR2(500):= NULL; --12.1.3
     l_index_version VARCHAR2(15) := '115.10.1';
     l_index_name    VARCHAR2(30) := 'cs_kb_sets_tl_N3';
     l_index_name1    VARCHAR2(30) := 'cs_kb_sets_attach_tl_N3';
     l_dummy_col  VARCHAR2(100):='.cs_kb_sets_tl(composite_assoc_index) '; --12.1.3
     l_datastore VARCHAR2(100):= '.CS_KB_COMPOSITE_ELES '; --12.1.3

  BEGIN


   l_create_cmmd :=
        ' CREATE INDEX '||g_cs_short_name||'.'||l_index_name||' on '
     || g_cs_short_name||'.cs_kb_sets_tl(composite_assoc_index) '
     || ' INDEXTYPE IS ctxsys.context '
     || ' parameters (''datastore '||g_apps_short_name||'.CS_KB_COMPOSITE_ELES '
     || ' section group '||g_apps_short_name||'.CS_KB_BASIC_GRP '
     || ' lexer  '||g_apps_short_name||'.CS_KB_GLOBAL_LEXER language column SOURCE_LANG '
     || ' wordlist '||g_apps_short_name||'.CS_KB_FUZZY_PREF '
     --4321268
     || ' storage ' ||g_apps_short_name||'.CS_KB_INDEX_STORAGE '; -- <-command not yet completed
     -- 4321268_eof
     -- Start 12.1.3
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Create_Set_Index',
                     ' attachment_flag:'||attachment_flag);
    END IF;

/* l_create_cmmd :=
        ' CREATE INDEX '||g_cs_short_name||'.'||l_index_name||' on '
     || g_cs_short_name||l_dummy_col
     || ' INDEXTYPE IS ctxsys.context '
     || ' parameters (''datastore '||g_apps_short_name||l_datastore
     || ' section group '||g_apps_short_name||'.CS_KB_BASIC_GRP '
     || ' lexer  '||g_apps_short_name||'.CS_KB_GLOBAL_LEXER language column SOURCE_LANG '
     || ' wordlist '||g_apps_short_name||'.CS_KB_FUZZY_PREF '
     --4321268
     || ' storage ' ||g_apps_short_name||'.CS_KB_INDEX_STORAGE '; -- <-command not yet completed
     -- 4321268_eof*/

   IF attachment_flag = 'Y' THEN
    -- l_index_name := 'cs_kb_sets_attach_tl_N3';
      l_dummy_col :='.cs_kb_sets_tl(composite_assoc_attach_index) ';
     l_datastore := '.CS_KB_COMPOSITE_ATTACH_ELES ';
      l_create_cmmd1 :=
        ' CREATE INDEX '||g_cs_short_name||'.'||l_index_name1||' on '
     || g_cs_short_name||l_dummy_col
     || ' INDEXTYPE IS ctxsys.context '
     || ' parameters (''datastore '||g_apps_short_name||l_datastore
     || ' section group '||g_apps_short_name||'.CS_KB_BASIC_GRP '
     || ' lexer  '||g_apps_short_name||'.CS_KB_GLOBAL_LEXER language column SOURCE_LANG '
     || ' wordlist '||g_apps_short_name||'.CS_KB_FUZZY_PREF '
     --4321268
     || ' storage ' ||g_apps_short_name||'.CS_KB_INDEX_STORAGE '; -- <-command not yet completed
     -- 4321268_eof
   END IF;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Create_Set_Index',
                     'l_index_name:'||l_index_name||  'l_dummy_col:'||l_dummy_col||  'l_datastore:'||l_datastore);
    END IF;

           IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Create_Set_Index',
                     ' l_create_cmmd:'|| l_create_cmmd);
    END IF;

      -- End 12.1.3
     x_return_status := fnd_api.G_RET_STS_ERROR;

     -- 4321268
     IF  nvl(pworker,0) = 0 THEN
        -- Create index online
        -- 1. Create index without populate
        l_create_cmmd := l_create_cmmd || ' nopopulate '') ';
	l_create_cmmd1 := l_create_cmmd1 || ' nopopulate '') ';  --12.1.3

     ELSE
         l_create_cmmd := l_create_cmmd || ''')';
     l_create_cmmd := resolve_parallel_indexing(l_create_cmmd, pworker);
     --12.1.3
      l_create_cmmd1 := l_create_cmmd1 || ''')';
     l_create_cmmd1 := resolve_parallel_indexing(l_create_cmmd1, pworker);
     --12.1.3
     END IF;
           IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Create_Set_Index',
                     ' l_create_cmmd before do_create:'|| l_create_cmmd);
    END IF;

     -- 4321268_eof

     do_create(
       p_create_cmd    => l_create_cmmd,
       p_index_name    => l_index_name,
       p_index_version => l_index_version,
       x_msg_error     => x_msg_error,
       x_return_status => x_return_status );
	--12.1.3
      IF attachment_flag = 'Y' THEN
	IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Create_Set_Index',
           ' l_create_cmmd inside do_create:'|| l_create_cmmd1 ||l_index_name1);
	END IF;


      do_create(
       p_create_cmd    => l_create_cmmd1,
       p_index_name    => l_index_name1,
       p_index_version => l_index_version,
       x_msg_error     => x_msg_error,
       x_return_status => x_return_status );
     END IF;
     IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
     	RAISE create_index_error;
     END IF;

     -- 4321268
     IF nvl(pworker, 0) = 0 THEN
             populate_set_index (
		   x_msg_error ,
                   x_return_status
	);
     END IF;
     IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
     	RAISE create_index_error;
     END IF;
      -- 4321268_eof


     x_return_status := fnd_api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN create_index_error THEN
  		 NULL;  -- x_msg_error is set in the do_create api.
    WHEN others THEN
      x_msg_error := 'Create_Set_Index: '
       ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
  END Create_Set_Index;


  /*
   * Create_Element_Index
   *   This PROCEDURE creates THE STATEMENT INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Element_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  )
  IS
     l_create_cmmd VARCHAR2(500):= NULL;

     l_index_version VARCHAR2(15) := '115.10.1';
     l_index_name    VARCHAR2(30) := 'cs_kb_elements_tl_N2';
  BEGIN
    l_create_cmmd :=
        ' CREATE INDEX '||g_cs_short_name||'.cs_kb_elements_tl_N2 on '
      ||g_cs_short_name||'.cs_kb_elements_tl(composite_text_index) '
      ||' INDEXTYPE IS ctxsys.context '
      ||' parameters (''datastore '||g_apps_short_name||'.CS_KB_ELES '
      ||' section group '||g_apps_short_name||'.CS_KB_BASIC_GRP '
      ||' lexer '||g_apps_short_name||'.CS_KB_GLOBAL_LEXER language column SOURCE_LANG '
      ||' wordlist '||g_apps_short_name||'.CS_KB_FUZZY_PREF '
      --4321268
      || ' storage ' ||g_apps_short_name||'.CS_KB_INDEX_STORAGE '; -- <-command not yet completed
      -- 4321268_eof

     x_return_status := fnd_api.G_RET_STS_ERROR;

     -- 4321268
     IF  nvl(pworker,0) = 0 THEN
        -- Create index online
        -- 1. Create index without populate
        l_create_cmmd := l_create_cmmd || ' nopopulate '') ';
     ELSE
         l_create_cmmd := l_create_cmmd || ''')';
     l_create_cmmd := resolve_parallel_indexing(l_create_cmmd, pworker);

     END IF;
     -- 4321268_eof

      do_create
        (  p_create_cmd    => l_create_cmmd,
           p_index_name    => l_index_name,
	   p_index_version => l_index_version,
	   x_msg_error     => x_msg_error,
	   x_return_status => x_return_status
	);

     -- 4321268
     IF nvl(pworker, 0) = 0 THEN
             populate_element_index (
		 x_msg_error ,
                 x_return_status
		   );
     END IF;
     IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
     	RAISE create_index_error;
     END IF;
      -- 4321268_eof

     IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
     	RAISE create_index_error;
     END IF;
     x_return_status := fnd_api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN create_index_error THEN
      NULL;  -- x_msg_error is set in the do_create api.
    WHEN others THEN
      x_msg_error := 'Create_Element_Index: '
        ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
  END Create_Element_Index;


  /*
   * Create_Soln_Cat_Index
   *   This PROCEDURE creates THE CATEGORY INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Soln_Cat_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  )
  IS
     l_create_cmmd VARCHAR2(500):= NULL;
     l_index_version VARCHAR2(15) := '115.10.1';
     l_index_name    VARCHAR2(30) := 'CS_KB_SOLN_CAT_TL_N1';

  BEGIN
    l_create_cmmd :=
          ' CREATE INDEX '||g_cs_short_name||'.CS_KB_SOLN_CAT_TL_N1 on '
        ||g_cs_short_name||'.cs_kb_soln_categories_tl(name) '
        ||' INDEXTYPE IS ctxsys.context '
        ||' parameters ('' '
        ||' lexer '||g_apps_short_name||'.CS_KB_GLOBAL_LEXER language column SOURCE_LANG '
        ||' wordlist '||g_apps_short_name||'.CS_KB_FUZZY_PREF '
        --4321268
        || ' storage ' ||g_apps_short_name||'.CS_KB_INDEX_STORAGE '; -- <-command not yet completed
        -- 4321268_eof

      x_return_status := fnd_api.G_RET_STS_ERROR;

      -- 4321268
      IF  nvl(pworker,0) = 0 THEN
        -- Create index online
        -- 1. Create index without populate
         l_create_cmmd := l_create_cmmd || ' nopopulate '') ';
      ELSE

         l_create_cmmd := l_create_cmmd || ''')';
      l_create_cmmd := resolve_parallel_indexing(l_create_cmmd, pworker);

      END IF;
      -- 4321268_eof

      do_create
      (  p_create_cmd    => l_create_cmmd,
         p_index_name    => l_index_name,
	 p_index_version => l_index_version,
	 x_msg_error     => x_msg_error,
	 x_return_status => x_return_status
       );

     -- 4321268
     IF nvl(pworker, 0) = 0 THEN
             populate_soln_cat_index (
	           x_msg_error ,
		   x_return_status
		   );
     END IF;
     IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
     	RAISE create_index_error;
     END IF;
     -- 4321268_eof
     x_return_status := fnd_api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN create_index_error THEN
  		 NULL;  -- x_msg_error is set in the do_create api.
    WHEN others THEN
      x_msg_error := 'Create_Element_Index: '
        ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
  END Create_Soln_Cat_Index;

   /*
   * Create_Forum_Index
   *   This PROCEDURE creates THE forum INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Forum_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  )
  IS
     l_create_cmmd VARCHAR2(500):= NULL;

     l_index_version VARCHAR2(15) := '115.10.1';
     l_index_name    VARCHAR2(30) := 'cs_forum_messages_tl_n4';
  BEGIN
    l_create_cmmd :=
         'create index '||g_cs_short_name||'.cs_forum_messages_tl_n4 '
      || 'on '||g_cs_short_name||'.cs_forum_messages_tl(composite_assoc_col) '
      || 'indextype is ctxsys.context parameters( '''
      || 'datastore '||g_apps_short_name||'.CS_FORUM_MESG_ELES '
      || ' section group '||g_apps_short_name||'.CS_KB_BASIC_GRP '
      || 'lexer '||g_apps_short_name||'.CS_KB_GLOBAL_LEXER language column SOURCE_LANG '
      || 'wordlist '||g_apps_short_name||'.CS_KB_FUZZY_PREF '
      --4321268
      || ' storage ' ||g_apps_short_name||'.CS_KB_INDEX_STORAGE '; -- <-command not yet completed
      -- 4321268_eof

     x_return_status := fnd_api.G_RET_STS_ERROR;

     -- 4321268
     IF  nvl(pworker,0) = 0 THEN
        -- Create index online
        -- 1. Create index without populate
        l_create_cmmd := l_create_cmmd || ' nopopulate '') ';
     ELSE
         l_create_cmmd := l_create_cmmd || ''')';
     l_create_cmmd := resolve_parallel_indexing(l_create_cmmd, pworker);

     END IF;
     -- 4321268_eof

      do_create
        (  p_create_cmd    => l_create_cmmd,
           p_index_name    => l_index_name,
           p_index_version => l_index_version,
           x_msg_error     => x_msg_error,
           x_return_status => x_return_status
         );

     -- 4321268
     IF nvl(pworker, 0) = 0 THEN
             populate_forum_index (
                     x_msg_error ,
		     x_return_status
		   );
     END IF;
     IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
     	RAISE create_index_error;
     END IF;
      -- 4321268_eof
     x_return_status := fnd_api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN create_index_error THEN
      NULL;  -- x_msg_error is set in the do_create api.
    WHEN others THEN
      x_msg_error := 'Create_Forum_Index: '
            ||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
  END Create_Forum_Index;



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

    -- If only if the index exists:
    OPEN get_index_cursor(p_index_name, g_cs_short_name);
    FETCH get_index_cursor INTO l_total;
    CLOSE get_index_cursor;

    IF l_total > 0 THEN
      drop_index := 'drop index '||g_cs_short_name||'.'||p_index_name||' force ';
      EXECUTE IMMEDIATE drop_index;
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Logic to remove the index version in the
    -- global system table.
  EXCEPTION
    WHEN others THEN
      x_msg_error := 'Drop_Index: '||
                 fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||
                 SQLERRM;
  END Drop_Index;


  /*
   * Sync_Set_Index
   *   This PROCEDURE syncs THE Oracle Text INDEX FOR KM Solutions TO
   *   bring THE INDEX up-TO-DATE.
   */
  PROCEDURE Sync_Set_Index
  (  errbuf OUT NOCOPY VARCHAR2,
     retcode OUT NOCOPY NUMBER,
     bmode   IN VARCHAR2,
     pworker IN NUMBER DEFAULT  0,
     attachment IN VARCHAR2)
  IS
    CURSOR delay_marked_solns_batch_csr( c_batch_size NUMBER ) IS
      SELECT set_id
      FROM cs_kb_sets_b
     -- 3679483
       -- WHERE reindex_flag = 'Y'
      WHERE reindex_flag = 'U'
     -- 3679483 eof
      AND ROWNUM <= c_batch_size;

    l_solution_id NUMBER := 0;

    l_soln_comp_index VARCHAR2(250) := 'CS_KB_SETS_TL_N3';
     l_soln_comp_attach_index VARCHAR2(250):= 'CS_KB_SETS_ATTACH_TL_N3'; --12.1.3
    l_num_batch_rows_updated NUMBER := 0;
    l_reindex_batch_size NUMBER := 300;
    l_mode VARCHAR2(10) := bmode;

    l_return_status VARCHAR2(1) :=  fnd_api.G_RET_STS_ERROR;
  BEGIN
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Sync_Set_Index',
                     'Index attachments:'||attachment);
    END IF;
    --12.1.3
   --Commented to fix bug 8757484
   --IF attachment = 'Y' THEN
      attachment_flag :='Y';
   --END IF;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Sync_Set_Index',
                     'l_soln_comp_index:'||l_soln_comp_index);
    END IF;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.cs_kb_conc_prog_pkg.Sync_Set_Index',
                     'l_soln_comp_attach_index:'||l_soln_comp_attach_index);
    END IF;

   --12.1.3
    -- Initialize some variables
    retcode := 2; -- init return val to FAIL

    IF l_mode IS NULL THEN
      l_mode := 'S';
    END IF;

    IF is_validate_mode(l_mode) = 'N' THEN
     RAISE invalid_mode_error;
   END IF;

     -- check whether it is 'DR'
     IF l_mode = 'DR' THEN
       -- At this point we can assume that we can safely drop the index.
        Drop_Index(l_soln_comp_index,
                   errbuf,
                   l_return_status);
	--12.1.3
	--IF attachment = 'Y' THEN
		Drop_Index(l_soln_comp_attach_index,
                   errbuf,
                   l_return_status);
	--END IF;
	--12.1.3
        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE drop_index_error;
        END IF;

        Create_Set_Index(pworker,
                         errbuf,
                         l_return_status);
        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE create_index_error;
        END IF;
     ELSIF l_mode = 'RC' THEN
       -- Rebuild content cache
        Rebuild_Soln_Content_Cache( errbuf, retcode );
        IF retcode <> 0 THEN
          RAISE rebuild_cache_error;
        END IF;
     ELSE
      fnd_profile.get('CS_KB_REINDEX_BATCH_SIZE', l_reindex_batch_size);
      IF ( l_reindex_batch_size IS NULL ) THEN
        l_reindex_batch_size := 300;
      END IF;

      -- Sync the composite solution index up-front.
      -- This will bring any solutions already marked for reindexing
      -- up-to date and make them searchable.
      -- 4321268
      IF (pworker IS NULL OR pworker = 0) AND l_mode = 'R' THEN
         populate_set_index (
			    x_msg_error      => errbuf,
		     	x_return_status  => l_return_status
		   );
      Else
      Sync_index( l_soln_comp_index, l_mode, PWORKER );
      --12.1.3
	--IF attachment = 'Y' THEN
		 Sync_index( l_soln_comp_attach_index, l_mode, PWORKER );
	--END IF;
	--12.1.3
      END IF;
      -- 4321268_eof

      -- Query up solutions that have been delay-marked for reindexing.
      -- Loop through these solutions in batches (batch size defined by
      -- profile option) and transfer the delay-mark to immediate mark.
      -- After the mark transfer for each of these batches, sync the index
      -- to make the batch of solutions searchable.
      LOOP
        l_num_batch_rows_updated := 0;

        OPEN delay_marked_solns_batch_csr( l_reindex_batch_size );
        LOOP
          FETCH delay_marked_solns_batch_csr INTO l_solution_id;
          -- Exit inner loop when there are no more delay-marked
          -- statements in the batch
          EXIT WHEN delay_marked_solns_batch_csr%NOTFOUND;

         -- Immediately mark the solution composite text index column
	 /* Commented for 12.1.3
          UPDATE cs_kb_sets_tl
          SET composite_assoc_index = 'U'
          WHERE set_id = l_solution_id;*/
	   --12.1.3
	  --IF attachment = 'Y' THEN
		UPDATE cs_kb_sets_tl
		SET composite_assoc_attach_index = 'U'
		WHERE set_id = l_solution_id;
	  --ELSE
		UPDATE cs_kb_sets_tl
		SET composite_assoc_index = 'U'
		WHERE set_id = l_solution_id;
         --END IF;
	  --12.1.3

          -- Clear the delayed index mark on the solution
          UPDATE cs_kb_sets_b
          SET reindex_flag = NULL
          WHERE set_id = l_solution_id;

          l_num_batch_rows_updated := l_num_batch_rows_updated + 1;
        END LOOP;
        CLOSE delay_marked_solns_batch_csr;
        COMMIT;

        -- Exit outer loop when there are no more rows to update
        EXIT WHEN l_num_batch_rows_updated = 0;

        -- Otherwise sync the index and loop again for the next batch
        Sync_index( l_soln_comp_index, l_mode, PWORKER );

      END LOOP;
    END IF; -- l_mode check

    -- klou (SRCHEFF)
    -- Update magic word.
    Update_Magic_Word;

    -- Set return value and log message to Success
    errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
    retcode := 0;

  EXCEPTION
    WHEN invalid_mode_error THEN
      BEGIN
        errbuf := fnd_message.get_string('CS', 'CS_KB_SYN_INDEX_INV_MODE');
      END;
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
      errbuf := 'Sync_Set_Index: '||
             fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||
             SQLERRM;
      -- Write out error to concurrent program log
      BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      EXCEPTION
        WHEN others THEN
          NULL;
      END;

  END Sync_Set_Index;



  /*
   * Sync_Element_Index
   *   This PROCEDURE syncs THE Oracle Text INDEX FOR KM Statements TO
   *   bring THE INDEX up-TO-DATE.
   */
  PROCEDURE Sync_Element_Index
  ( ERRBUF OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY NUMBER,
    BMODE IN VARCHAR2,
    pworker  IN NUMBER DEFAULT 0)
  IS
    CURSOR delay_marked_stmts_batch_csr( c_batch_size NUMBER ) IS
      SELECT element_id
      FROM cs_kb_elements_b
      -- 3679483
      -- WHERE reindex_flag = 'Y'
      WHERE reindex_flag = 'U'
      -- 3679483 eof
      AND ROWNUM <= c_batch_size;

    l_statement_id NUMBER := 0;
    l_statement_comp_index VARCHAR2(250) := 'CS_KB_ELEMENTS_TL_N2';
    l_num_batch_rows_updated NUMBER := 0;
    l_reindex_batch_size NUMBER := 300;
    l_mode   VARCHAR2(10) := bmode;
    l_return_status VARCHAR2(1) :=  fnd_api.G_RET_STS_ERROR;
  BEGIN
    -- Initialize some variables
    retcode := 2; -- init return val to FAIL

    IF l_mode IS NULL THEN
      l_mode := 'S';
    END IF;

    IF is_validate_mode(l_mode) = 'N' THEN
     RAISE invalid_mode_error;
    END IF;

     -- check whether it is 'DR'
     IF l_mode = 'DR' THEN
       -- At this point we can assume that we can safely drop the index.
        Drop_Index(l_statement_comp_index,
                   errbuf,
                   l_return_status);
        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE drop_index_error;
        END IF;

        Create_Element_Index(pworker,
                             errbuf,
                             l_return_status);
        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE create_index_error;
        END IF;
     ELSE
        fnd_profile.get('CS_KB_REINDEX_BATCH_SIZE', l_reindex_batch_size);
        IF ( l_reindex_batch_size IS NULL ) THEN
          l_reindex_batch_size := 300;
        END IF;

        -- Sync the composite statement index up-front.
        -- This will bring any statement already marked for reindexing
        -- up-to date and make them searchable.
        -- 4321268
        IF (pworker IS NULL OR pworker = 0) AND l_mode = 'R' THEN
             populate_element_index (
    			    x_msg_error      => errbuf,
    		     	x_return_status  => l_return_status
    		   );
        ELSE
            Sync_index( l_statement_comp_index, bmode, PWORKER );
        END IF;
        -- 4321268_eof
        -- Query up statements that have been delay-marked for reindexing.
        -- Loop through these statements in batches (batch size defined by
        -- profile option) and transfer the delay-mark to immediate mark.
        -- After the mark transfer for each of these batches, sync the index
        -- to make the batch of statements searchable.
        LOOP
          l_num_batch_rows_updated := 0;

          OPEN delay_marked_stmts_batch_csr( l_reindex_batch_size );
          LOOP
            FETCH delay_marked_stmts_batch_csr INTO l_statement_id;
            -- Exit inner loop when there are no more delay-marked
            -- statements in the batch
            EXIT WHEN delay_marked_stmts_batch_csr%NOTFOUND;

            -- Immediately mark the statement composite text index column
            UPDATE cs_kb_elements_tl
            SET composite_text_index = 'U'
            WHERE element_id = l_statement_id;

            -- Clear the delayed index mark on the statement
            UPDATE cs_kb_elements_b
            SET reindex_flag = NULL
            WHERE element_id = l_statement_id;

            l_num_batch_rows_updated := l_num_batch_rows_updated + 1;
          END LOOP;
          CLOSE delay_marked_stmts_batch_csr;
          COMMIT;

          -- Exit outer loop when there are no more rows to update
          EXIT WHEN l_num_batch_rows_updated = 0;

          -- Otherwise sync the index and loop again for the next batch
          Sync_index( l_statement_comp_index, bmode );

        END LOOP;
      END IF;
    -- Set return value and log message to Success
    errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
    retcode := 0;

  EXCEPTION
    WHEN invalid_mode_error THEN
      BEGIN
        errbuf := fnd_message.get_string('CS', 'CS_KB_SYN_INDEX_INV_MODE');
      END;
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
      errbuf := 'Sync_Element_Index: '||
               fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||
               SQLERRM;
      -- Write out error to concurrent program log
      BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      EXCEPTION
        WHEN others THEN
          NULL;
      END;
  END Sync_Element_Index;


   PROCEDURE Sync_Forum_Index(ERRBUF OUT NOCOPY VARCHAR2,
                              RETCODE OUT NOCOPY NUMBER,
                              BMODE IN VARCHAR2,
                              pworker  IN NUMBER DEFAULT 0)

  IS
    index3 VARCHAR2(250) := 'CS_FORUM_MESSAGES_TL_N4';
    l_mode VARCHAR2(10) := bmode;
    l_return_status VARCHAR2(1) :=  fnd_api.G_RET_STS_ERROR;
  BEGIN
   -- Initialize some variables
   retcode := 2; -- init return val to FAIL

   IF l_mode IS NULL THEN
    l_mode := 'S';
   END IF;

   IF is_validate_mode(l_mode) = 'N' THEN
    RAISE invalid_mode_error;
   END IF;

    -- check whether it is 'DR'
    IF l_mode = 'DR' THEN
      -- At this point we can assume that we can safely drop the index.
      Drop_Index(index3,
                 errbuf,
                 l_return_status);
      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE drop_index_error;
      END IF;

      Create_Forum_Index(pworker,
                         errbuf,
                         l_return_status);
      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE create_index_error;
      END IF;
    ELSE
      -- 4321268
      IF (pworker IS NULL OR pworker = 0) AND l_mode = 'R' THEN
         populate_forum_index (
			    x_msg_error      => errbuf,
		     	x_return_status  => l_return_status
		   );
      Else
          Sync_index( index3, l_mode, PWORKER );
      END IF;
      -- 4321268_eof
    END IF;

   -- Return successfully
   errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
   retcode := 0;
  EXCEPTION
  WHEN invalid_mode_error THEN
    BEGIN
      errbuf := fnd_message.get_string('CS', 'CS_KB_SYN_INDEX_INV_MODE');
    END;
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
      errbuf := 'Sync_Forum_Index: '||
              fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||
              SQLERRM;
    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
   END Sync_Forum_Index;

  PROCEDURE Sync_Soln_Cat_Index(ERRBUF OUT NOCOPY VARCHAR2,
                                RETCODE OUT NOCOPY NUMBER,
                                BMODE IN VARCHAR2,
                                pworker  IN NUMBER DEFAULT 0)
  IS
  index1 VARCHAR2(250) := 'CS_KB_SOLN_CAT_TL_N1';
  l_mode VARCHAR2(10) := bmode;
  l_return_status VARCHAR2(1) :=  fnd_api.G_RET_STS_ERROR;

  BEGIN
    retcode := 2;

    IF l_mode IS NULL THEN
      l_mode := 'S';
    END IF;

    IF is_validate_mode(l_mode) = 'N' THEN
     RAISE invalid_mode_error;
    END IF;

     -- check whether it is 'DR'
     IF l_mode = 'DR' THEN
       -- At this point we can assume that we can safely drop the index.
        Drop_Index(index1,
                   errbuf,
                   l_return_status);
        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE drop_index_error;
        END IF;

      Create_Soln_Cat_Index(pworker,
                            errbuf,
                            l_return_status);
      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE create_index_error;
      END IF;
     ELSE
      -- 4321268
      IF (pworker IS NULL OR pworker = 0) AND l_mode = 'R' THEN
         populate_soln_cat_index (
			    x_msg_error      => errbuf,
		     	x_return_status  => l_return_status
		   );
      Else
          Sync_index( index1, l_mode, PWORKER );
      END IF;
      -- 4321268_eof
     END IF;

    -- Return successfully
    errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
    retcode := 0;
  EXCEPTION
   WHEN invalid_mode_error THEN
    BEGIN
      errbuf := fnd_message.get_string('CS', 'CS_KB_SYN_INDEX_INV_MODE');
    END;
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
    errbuf := 'Sync_Soln_Cat_Index: '||
              fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||
              SQLERRM;
    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
  END Sync_Soln_Cat_Index;

PROCEDURE del_sync_prog
 IS
BEGIN
  fnd_program.delete_program ('CS_KB_SYNC_INDEX', 'CS');
  fnd_program.delete_executable ('CS_KB_SYNC_INDEX', 'CS');
  COMMIT;
END del_sync_prog;


PROCEDURE update_set_count_sum (ERRBUF OUT NOCOPY VARCHAR2,
                                RETCODE OUT NOCOPY NUMBER)
  AS

  TYPE list_of_def_id_type IS TABLE OF CS_KB_USED_SUM_DEFS_B.DEF_ID%TYPE
    INDEX BY BINARY_INTEGER;
  list_of_def_id    list_of_def_id_type;
  TYPE list_of_days_type IS TABLE OF CS_KB_USED_SUM_DEFS_B.DAYS%TYPE
    INDEX BY BINARY_INTEGER;
  list_of_days    list_of_days_type;
  i        NUMBER(10);
  v_used_count    CS_KB_SET_USED_SUMS.USED_COUNT%TYPE;
  current_date    DATE;
  whether_exist    NUMBER:=0;
  x_user_id NUMBER;
  x_login_id NUMBER;

  CURSOR  set_cursor IS
    SELECT SET_ID FROM CS_KB_SETS_B;
BEGIN
  SELECT SysDate INTO current_date FROM dual;
  x_user_id := FND_GLOBAL.user_id;
  x_login_id := FND_GLOBAL.login_id;

  SELECT def_id, days BULK COLLECT INTO list_of_def_id, list_of_days
          FROM CS_KB_USED_SUM_DEFS_B;

  -- for each set
  FOR set_record IN set_cursor LOOP

    -- for each used summary
    i:= list_of_def_id.FIRST;
    WHILE (i IS NOT NULL) LOOP

      -- count
      SELECT count(H.HISTORY_ID) INTO v_used_count
      FROM CS_KB_HISTORIES_B H, CS_KB_SET_USED_HISTS USED_HISTS
      WHERE H.HISTORY_ID=USED_HISTS.HISTORY_ID AND
        USED_HISTS.SET_ID=set_record.set_id AND
        USED_HISTS.USED_TYPE=CS_KNOWLEDGE_PVT.G_PF AND
        ((current_date-H.entry_date)<=list_of_days(i));

      IF(v_used_count> 0) THEN

        -- insert or update to set_used_sum
        SELECT count(SET_ID) INTO whether_exist
          FROM CS_KB_SET_USED_SUMS
          WHERE SET_ID=set_record.SET_ID AND DEF_ID=list_of_def_id(i);

        IF (whether_exist=0) THEN

          INSERT INTO CS_KB_SET_USED_SUMS (
          SET_ID,
          DEF_ID,
          USED_COUNT,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN)
          VALUES (
          set_record.set_id,
          list_of_def_id(i),
          v_used_count,
          current_date,
          x_user_id, --to_number(FND_PROFILE.VALUE ('USER_ID')),
          current_date,
          x_user_id, --to_number(FND_PROFILE.VALUE ('USER_ID')),
          x_login_id --to_number(FND_PROFILE.VALUE('LOGIN_ID'))
          );

        ELSE

          UPDATE CS_KB_SET_USED_SUMS SET
            USED_COUNT=v_used_count,
            LAST_UPDATE_DATE=current_date,
            LAST_UPDATED_BY=x_user_id, --to_number(FND_PROFILE.VALUE ('USER_ID')),
            LAST_UPDATE_LOGIN=x_login_id --to_number(FND_PROFILE.VALUE('LOGIN_ID'))
          WHERE set_id = set_record.set_id
          AND def_id = list_of_def_id(i);
        END IF;

      ELSIF v_used_count = 0 THEN

         DELETE FROM CS_KB_SET_USED_SUMS
         WHERE set_id = set_record.set_id
         AND def_id = list_of_def_id(i);

      END IF;

      i:=list_of_def_id.NEXT(i);
    END LOOP;
  END LOOP;

  --clean up deleted summary definition entries
  DELETE FROM cs_kb_set_used_sums
  WHERE def_id NOT IN (SELECT def_id
  FROM cs_kb_used_sum_defs_b);

  COMMIT;
  retcode := 0;
END update_set_count_sum;


-- klou (SRCHEFF), since 11.5.10
/**
 * UPDATE THE magic word PROFILE.
 *
 */
PROCEDURE Update_Magic_Word IS
  CURSOR Get_Magic_Word_Csr IS
    SELECT fnd_profile.value('CS_KB_SEARCH_NONEXIST_KEYWORD') FROM dual;

  CURSOR Test_Magic_Word_Csr(p_keyword VARCHAR2) IS
    SELECT NULL
    FROM cs_kb_sets_vl SetEO
    WHERE
    contains(SetEO.composite_assoc_index, p_keyword, 10) >= 1
    AND ROWNUM < 2
    AND SetEO.status = 'PUB';

  CURSOR Get_Random_Word_Csr IS
   /*
      dbms_random.string(opt => 'l', len => 8)
       different opt VALUES are:
       'u' -- upper case
       'l' -- lower case
       'a' -- alpha characters only (mixed case)
       'x' -- any alpha-numeric characters (upper)
       'p' -- any printable characters
    */
   SELECT dbms_random.string( 'l', 5) FROM dual;

  l_magic_word      VARCHAR2(240) := NULL;
  l_old_magic_word  VARCHAR2(240) := NULL;
  l_result          Test_Magic_Word_Csr%ROWTYPE;

BEGIN
  SAVEPOINT Update_Magic_Word_Sav;
   -- get magic word
   OPEN Get_Magic_Word_Csr;
   FETCH Get_Magic_Word_Csr INTO l_magic_word;
   CLOSE Get_Magic_Word_Csr;

   IF l_magic_word IS NULL THEN
    OPEN Get_Random_Word_Csr;
    FETCH Get_Random_Word_Csr INTO l_magic_word;
    CLOSE Get_Random_Word_Csr;
--  l_magic_word := 'xyxyz';
   END IF;

   -- Backup l_magic_word
   l_old_magic_word := l_magic_word;
--dbms_output.put_line('magic word is '||l_magic_word);
   LOOP
     OPEN  Test_Magic_Word_Csr(l_magic_word);
     FETCH Test_Magic_Word_Csr INTO l_result;
     EXIT WHEN Test_Magic_Word_Csr%NOTFOUND;
     CLOSE Test_Magic_Word_Csr;

     OPEN Get_Random_Word_Csr;
     FETCH Get_Random_Word_Csr INTO l_magic_word;
     CLOSE Get_Random_Word_Csr;

   END LOOP;

   IF Test_Magic_Word_Csr%ISOPEN THEN
    CLOSE Test_Magic_Word_Csr;
   END IF;

   IF l_magic_word <> l_old_magic_word THEN
     -- Update profile
     IF  Fnd_Profile.Save(
           X_NAME  => 'CS_KB_SEARCH_NONEXIST_KEYWORD',  /* Profile name you are setting */
           X_VALUE =>  l_magic_word, /* Profile value you are setting */
           X_LEVEL_NAME => 'SITE'   /* 'SITE', 'APPL', 'RESP', or 'USER' */
           ) THEN
       COMMIT WORK;
     END IF;
   END IF;

EXCEPTION
  WHEN Others THEN
   ROLLBACK TO Update_Magic_Word_Sav;
END Update_Magic_Word;


PROCEDURE Update_Usage_Score(ERRBUF OUT NOCOPY VARCHAR2,
                             RETCODE OUT NOCOPY NUMBER) AS

BEGIN
  SAVEPOINT Update_Usage_Score_Sav;
  Cs_Knowledge_Audit_Pvt.Update_Solution_Usage_Score(p_commit =>fnd_api.g_true);
  errbuf  := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
  retcode := 0;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Update_Usage_Score_Sav;
    retcode := 2;
    errbuf := sqlerrm;
    BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    EXCEPTION
        WHEN others THEN
          NULL;
    END;

END Update_Usage_Score;


  /*
   * Rebuild_Soln_Content_Cache
   *  Repopulate THE solution content CACHE COLUMN FOR ALL published
   *  solutions. Content CACHE entries will be commited IN batches.
   */
  PROCEDURE Rebuild_Soln_Content_Cache
  ( errbuf OUT nocopy VARCHAR2,
    retcode OUT nocopy NUMBER )
  IS
    CURSOR all_published_solutions IS
     SELECT tl.set_id
     FROM cs_kb_sets_tl tl, cs_kb_sets_b b
     WHERE b.set_id = tl.set_id
       AND b.status = 'PUB';
    TYPE solnIdListType IS TABLE OF cs_kb_sets_tl.set_id%TYPE INDEX BY BINARY_INTEGER;
    solnIdList       solnIdListType;
    lCommitBatchSize NUMBER          := 100;
    lCounter         NUMBER          := 0;
  BEGIN
    SAVEPOINT start_rebuild_cache;

    -- Fetch out the list of IDs for all published solutions
    OPEN all_published_solutions;
    FETCH all_published_solutions BULK COLLECT INTO solnIdList;
    CLOSE all_published_solutions;

    -- Loop through the solution id list and repopulate the content
    -- cache for each solution. Commit will be performed for every
    -- lCommitBatchSize repopulations performed.
    FOR i IN solnIdList.FIRST..solnIdList.LAST LOOP
      cs_kb_sync_index_pkg.populate_soln_content_cache(solnIdList(i));
      CS_KB_SYNC_INDEX_PKG.Pop_Soln_Attach_Content_Cache (solnIdList(i));  --12.1.3
      lCounter := lCounter + 1;
      IF ( lCounter = lCommitBatchSize ) THEN
        COMMIT;
        lCounter := 0;
      END IF;
    END LOOP;
    COMMIT;
    errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
    retcode := 0;
  EXCEPTION
    WHEN others THEN
      ROLLBACK TO start_rebuild_cache;
      errbuf := 'Rebuild_Soln_Content_Cache: '||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
      -- Write out error to concurrent program log
      BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      EXCEPTION
        WHEN others THEN
          NULL;
      END;
  END;

  /*
   * Mark_Idx_on_Sec_Change
   *  Mark text INDEX COLUMNS (solutions AND statements) WHEN KM
   *  security setup changes. Marking THE text COLUMNS IS done OFF-line
   *  IN a concurrent program TO give better UI response TIME.
   *  THE way THE program works IS BY passing IN a security CHANGE
   *  action TYPE code. FOR EACH action TYPE, there IS a LIST OF
   *  PARAMETERS that get passed THROUGH parameter1-4.
   */
  PROCEDURE Mark_Idx_on_Sec_Change
  ( ERRBUF                       OUT NOCOPY VARCHAR2,
    RETCODE                      OUT NOCOPY NUMBER,
    SECURITY_CHANGE_ACTION_TYPE  IN         VARCHAR2   DEFAULT NULL,
    PARAMETER1                   IN         NUMBER     DEFAULT NULL,
    PARAMETER2                   IN         NUMBER     DEFAULT NULL )
  IS
    l_orig_visibility_id   NUMBER := 0;
    l_orig_parent_category_id   NUMBER := 0;
    l_visibility_id        NUMBER := 0;
    l_category_id          NUMBER := 0;
    l_cat_grp_id           NUMBER := 0;
  BEGIN
    -- Initialize some variables
    retcode := ERROR; -- init return val to FAIL

    FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_BEG')||' '||  'Mark_Idx_on_Sec_Change');

    -- Call out to appropriate helper function for the
    -- security setup change action type
    IF ( security_change_action_type = 'ADD_VIS' )
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_PROC')||' '||  'ADD_VIS');
      l_visibility_id := PARAMETER1;
      cs_kb_sync_index_pkg.Mark_Idx_on_Add_Vis( l_visibility_id );
    ELSIF ( security_change_action_type = 'REM_VIS' )
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_PROC')||' '||  'REM_VIS');
      l_visibility_id := PARAMETER1;
      cs_kb_sync_index_pkg.Mark_Idx_on_Rem_Vis( l_visibility_id );
    ELSIF ( security_change_action_type = 'CHANGE_CAT_VIS' )
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_PROC')||' '||  'CHANGE_CAT_VIS');
      l_category_id := PARAMETER1;
      l_orig_visibility_id := PARAMETER2;
      cs_kb_sync_index_pkg.Mark_Idx_on_Change_Cat_Vis( l_category_id, l_orig_visibility_id );
    ELSIF ( security_change_action_type = 'ADD_CAT_TO_CAT_GRP' )
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_PROC')||' '||  'ADD_CAT_TO_CAT_GRP');
      l_cat_grp_id := PARAMETER1;
      l_category_id := PARAMETER2;
      cs_kb_sync_index_pkg.Mark_Idx_on_Add_Cat_To_Cat_Grp( l_cat_grp_id, l_category_id );
    ELSIF ( security_change_action_type = 'REM_CAT_FROM_CAT_GRP' )
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_PROC')||' '||  'REM_CAT_FROM_CAT_GRP');
      l_cat_grp_id := PARAMETER1;
      l_category_id := PARAMETER2;
      cs_kb_sync_index_pkg.Mark_Idx_on_Rem_Cat_fr_Cat_Grp( l_cat_grp_id, l_category_id );
    ELSIF ( security_change_action_type = 'CHANGE_PARENT_CAT' )
    THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_PROC')||' '||  'CHANGE_PARENT_CAT');
      l_category_id := PARAMETER1;
      l_orig_parent_category_id := PARAMETER2;
      cs_kb_sync_index_pkg.Mark_Idx_on_Change_Parent_Cat( l_category_id, l_orig_parent_category_id );
    ELSE -- invalid action

      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_IND_INV_TYPE'));
--  'Error: Invalid change security setup action type specified'
      RAISE invalid_action_error;
    END IF;
    COMMIT;
    -- Set return value and log message to Success
    FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get_string('CS', 'CS_KB_SYNC_SUCESS_END'));
-- 'Successfully Completed.'
    errbuf := fnd_message.get_string('CS', 'CS_KB_C_SUCCESS');
    retcode := SUCCESS;

  EXCEPTION
    WHEN invalid_action_error THEN
      BEGIN
        errbuf := fnd_message.get_string('CS', 'CS_KB_SYN_INDEX_INV_ACT');
--  'Invalid action specified'
      END;
    WHEN others THEN
      ROLLBACK;
      errbuf := 'Mark_Idx_on_Sec_Change: '||fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
      -- Write out error to concurrent program log
      BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      EXCEPTION
        WHEN others THEN
          NULL;
      END;
  END Mark_Idx_on_Sec_Change;

END CS_KB_CONC_PROG_PKG;

/
