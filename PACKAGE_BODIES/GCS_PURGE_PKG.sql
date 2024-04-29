--------------------------------------------------------
--  DDL for Package Body GCS_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_PURGE_PKG" AS
/* $Header: gcs_purgeb.pls 120.4 2007/10/09 13:49:41 rthati noship $ */
-- Procedure
--   purge_cons_runs
-- Purpose
--   An API for master to submit request to worker
-- Arguments
--   x_retcode                   Return code
--   x_errbuf                    Buffer error
--   p_consolidation_hierarchy   Consolidation hierarchy
--   p_consolidation_entity      Consolidation entity
--   p_cal_period_id             Period
--   p_balance_type_code         Balance type code
-- Modification History
--   Person           Date        Comments
--   ramesh.thati    25-09-2007   Purge Program - Bug # 6447909
-- Notes
--
   g_api			VARCHAR2(200)	:=	'gcs.plsql.GCS_PURGE_PKG';

   PROCEDURE purge_cons_runs
     (
       x_retcode                  OUT NOCOPY VARCHAR2,
       x_errbuf                   OUT NOCOPY VARCHAR2,
       p_consolidation_hierarchy  IN NUMBER,
       p_consolidation_entity     IN NUMBER,
       p_cal_period_id            IN NUMBER,
       p_balance_type_code        IN VARCHAR2
     )
   IS
     p_key         VARCHAR2(30);
     v_Num_Workers NUMBER;
   BEGIN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS.begin', '<<Enter>>');
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS', 'Consolidation Hierarchy    :  ' || p_consolidation_hierarchy);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS', 'Consolidation Entity       :  ' || p_consolidation_entity);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS', 'Calendar Period            :  ' || p_cal_period_id);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS', 'Balance Type               :  ' || p_balance_type_code);
     END IF;

     fnd_file.put_line(fnd_file.log, 'Beginning Consolidation Purge Program');
     fnd_file.put_line(fnd_file.log, '<<Parameter Listings>>');
     fnd_file.put_line(fnd_file.log, 'Consolidation Hierarchy	:	' || p_consolidation_hierarchy);
     fnd_file.put_line(fnd_file.log, 'Consolidation Entity	    :	' || p_consolidation_entity);
     fnd_file.put_line(fnd_file.log, 'Calendar Period		    :	' || p_cal_period_id);
     fnd_file.put_line(fnd_file.log, 'Balance Type              :   ' || p_balance_type_code);
     fnd_file.put_line(fnd_file.log, '<<End of Parameter Listings>>');

    BEGIN
      SELECT nvl(value,1)*2 no_of_workers
      INTO v_Num_Workers
      FROM v$parameter
      WHERE NAME = 'cpu_count';

      EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.PURGE_CONS_RUNS_WORKER', SubStr('Getting number of workers-'||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
        END IF;
        fnd_file.put_line(fnd_file.log, SubStr('Getting number of workers-'||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
        x_retcode :='2';
    END;

    BEGIN
      SELECT run_name
      INTO   p_key
      FROM  gcs_cons_eng_runs gcer
      WHERE gcer.hierarchy_id       =  p_consolidation_hierarchy
      AND   gcer.cal_period_id      =  p_cal_period_id
      AND   gcer.balance_type_code  =  p_balance_type_code
      AND   gcer.most_recent_flag   =  'Y'
      AND   gcer.run_entity_id      =  p_consolidation_entity;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.PURGE_CONS_RUNS_WORKER', SubStr('Getting the Unique Key(p_key)'||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
        END IF;
        fnd_file.put_line(fnd_file.log, SubStr('Getting the Unique Key(p_key)'||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
        x_retcode :='2';
    END;

    -- AD Parallel framework Manager processing

    --Purge all the info from ad processing tables
   ad_parallel_updates_pkg.purge_processed_units(X_owner  => 'GCS',
                                                 X_table  => 'GCS_CONS_ENG_RUNS',
                                                 X_script => p_key);

   ad_parallel_updates_pkg.delete_update_information(X_update_type => ad_parallel_updates_pkg.ROWID_RANGE,
                                                     X_owner       =>  'GCS',
                                                     X_table       =>  'GCS_CONS_ENG_RUNS',
                                                     X_script      =>  p_key);

   -- submit purge worker
   AD_CONC_UTILS_PKG.submit_subrequests(X_errbuf                    => x_errbuf,
                                        X_retcode                   => x_retcode,
                                        X_WorkerConc_app_shortname  => 'GCS',
                                        X_WorkerConc_progname       => 'FCH_PURGE_PROGRAM_WORKER',
                                        X_batch_size                => 10000,
                                        X_Num_Workers               => v_Num_Workers,
                                        X_Argument4                 => p_consolidation_hierarchy,
                                        X_Argument5                 => p_consolidation_entity,
                                        X_Argument6                 => p_cal_period_id,
                                        X_Argument7                 => p_balance_type_code);

     -- To commit the overall transaction
     COMMIT;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS.end', '<<Enter>>');
     END IF;
   EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        fnd_file.put_line(fnd_file.log, SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
        x_retcode :='2';
   END purge_cons_runs; -- end of procedure purge_cons_runs

-- Procedure
--   purge_cons_runs_worker
-- Purpose
--   An API for worker to purge its own set of rows. To purge historical data
--   with regard to consolidation runs.It will not purge manual adjustments or
--   rules generated entries. It will purge only Automatically generated entries
-- Arguments
--   x_retcode                   Return code
--   x_errbuf                    Buffer error
--   p_batch_size                No of rows to process
--   p_Worker_Id                 Worker ID,
--   p_Num_Workers               total Number of workers
--   p_consolidation_hierarchy   Consolidation hierarchy
--   p_consolidation_entity      Consolidation entity
--   p_cal_period_id             Period
--   p_balance_type_code         Balance type code
-- Modification History
--   Person           Date        Comments
--   ramesh.thati    25-09-2007   Purge Program - Bug # 6447909
-- Notes
--
   PROCEDURE purge_cons_runs_worker
      (
       X_errbuf                  OUT NOCOPY VARCHAR2,
       X_retcode                 OUT NOCOPY VARCHAR2,
       p_batch_size              IN NUMBER,
       p_Worker_Id               IN NUMBER,
       p_Num_Workers             IN NUMBER,
       p_consolidation_hierarchy IN NUMBER,
       p_consolidation_entity    IN NUMBER,
       p_cal_period_id           IN NUMBER,
       p_balance_type_code       IN VARCHAR2
     )
   IS
-- Cursor definition
-- Cursor to get the run_name and run_entity_id information by considering the
-- following cases
-- i) Not latest runs (most_recent_flag <> 'y').
-- i) Not already purged runs (status_code <> 'PURGED')

   CURSOR c_purge_cons_entity ( p_consolidation_hierarchy IN NUMBER,
                                p_consolidation_entity	  IN NUMBER,
                                p_cal_period_id           IN NUMBER,
                                p_balance_type_code       IN VARCHAR2,
                                p_start_rowid                ROWID,
                                p_end_rowid                  ROWID
                               ) IS
   SELECT DISTINCT run_name, run_entity_id, entity_name
   FROM  gcs_cons_eng_runs gcer,
         fem_entities_tl fem
   WHERE gcer.run_entity_id            =  fem.entity_id
   AND   gcer.hierarchy_id             =  p_consolidation_hierarchy
   AND   gcer.cal_period_id            =  p_cal_period_id
   AND   gcer.balance_type_code        =  p_balance_type_code
   AND   gcer.most_recent_flag         <> 'Y'
   AND   gcer.status_code              <> 'PURGED'
   AND   (gcer.associated_run_name IS NULL
          OR (gcer.associated_run_name IS NOT NULL
              AND NOT EXISTS (
                              SELECT run_name
                              FROM   gcs_cons_eng_runs gcer_inner
                              WHERE  gcer_inner.hierarchy_id=p_consolidation_hierarchy
                              AND    gcer_inner.cal_period_id = p_cal_period_id
                              AND    gcer_inner.balance_type_code = p_balance_type_code
                              AND    gcer_inner.most_recent_flag = 'Y'
                              AND    gcer_inner.run_name=gcer.associated_run_name
                              AND    gcer_inner.run_entity_id=gcer.run_entity_id
                             )
              )
         )
   AND   fem.language                  =  userenv('lang')
   AND   gcer.ROWID BETWEEN p_start_rowid AND p_end_rowid
   START WITH gcer.run_entity_id       =  p_consolidation_entity
   AND   gcer.hierarchy_id             =  p_consolidation_hierarchy
   AND   gcer.cal_period_id            =  p_cal_period_id
   AND   gcer.balance_type_code        =  p_balance_type_code
   CONNECT BY PRIOR gcer.run_entity_id =  gcer.parent_entity_id
   AND   gcer.hierarchy_id             =  p_consolidation_hierarchy
   AND   gcer.cal_period_id            =  p_cal_period_id
   AND   gcer.balance_type_code        =  p_balance_type_code;


-- Cursor to the entry_id and stat_entry_id that belong to perticular run_name
-- and run_entity_id. The following cases are considered to get the entry ids
-- i)   All the entris that do not belong lastest run are eligible for purging.
-- ii)  Only AUTOMATIC entries from gcs_entry_headers table are eligible for purging.
-- iii) stat_entry_ids along with entry_ids are also eligible for purging

   CURSOR c_purge_entry(p_consolidation_hierarchy   IN NUMBER,
                        p_cal_period_id             IN NUMBER,
                        p_balance_type_code         IN VARCHAR2,
                        p_run_name                  IN VARCHAR2,
                        p_run_entity_id             IN NUMBER
                       ) IS
   SELECT  DISTINCT gcerd_outer.entry_id,gcerd_outer.child_entity_id,geh.entry_name,geh.description
   FROM    gcs_cons_eng_runs     gcer_outer,
           gcs_cons_eng_run_dtls gcerd_outer,
           gcs_entry_headers     geh
   WHERE   gcer_outer.run_name                 =  gcerd_outer.run_name
   AND     gcer_outer.run_entity_id            =  gcerd_outer.consolidation_entity_id
   AND     gcerd_outer.entry_id                =  geh.entry_id
   AND     geh.entry_type_code                 =  'AUTOMATIC'
   AND     gcerd_outer.run_name                =  p_run_name
   AND     gcerd_outer.consolidation_entity_id =  p_run_entity_id
   AND     gcerd_outer.entry_id IS NOT NULL
   AND     NOT EXISTS (
                        SELECT 'X'
                        FROM  gcs_cons_eng_runs     gcer_inner,
                              gcs_cons_eng_run_dtls gcerd_inner
                        WHERE gcer_inner.most_recent_flag  = 'Y'
                        AND   gcer_inner.hierarchy_id      = gcer_outer.hierarchy_id
                        AND   gcer_inner.run_entity_id     = gcer_outer.run_entity_id
                        AND   gcer_inner.cal_period_id     = gcer_outer.cal_period_id
                        AND   gcer_inner.balance_type_code = gcer_outer.balance_type_code
                        AND   gcerd_inner.entry_id         = gcerd_outer.entry_id
                        AND   gcer_inner.run_name          = gcerd_inner.run_name
                       )
   UNION ALL

   SELECT  DISTINCT gcerd_outer.stat_entry_id,gcerd_outer.child_entity_id,geh.entry_name,geh.description
   FROM    gcs_cons_eng_runs     gcer_outer,
           gcs_cons_eng_run_dtls gcerd_outer,
           gcs_entry_headers     geh
   WHERE   gcer_outer.run_name                   =  gcerd_outer.run_name
   AND     gcer_outer.run_entity_id              =  gcerd_outer.consolidation_entity_id
   AND     gcerd_outer.stat_entry_id             =  geh.entry_id
   AND     geh.entry_type_code                   =  'AUTOMATIC'
   AND     gcerd_outer.run_name                  =  p_run_name
   AND     gcerd_outer.consolidation_entity_id   =  p_run_entity_id
   AND     gcerd_outer.stat_entry_id IS NOT NULL
   AND     NOT EXISTS (
                       SELECT 'X'
                       FROM  gcs_cons_eng_runs     gcer_inner,
                             gcs_cons_eng_run_dtls gcerd_inner
                       WHERE gcer_inner.most_recent_flag  = 'Y'
                       AND   gcer_inner.hierarchy_id      = gcer_outer.hierarchy_id
                       AND   gcer_inner.run_entity_id     = gcer_outer.run_entity_id
                       AND   gcer_inner.cal_period_id     = gcer_outer.cal_period_id
                       AND   gcer_inner.balance_type_code = gcer_outer.balance_type_code
                       AND   gcerd_inner.stat_entry_id    = gcerd_outer.stat_entry_id
                       AND   gcer_inner.run_name          = gcerd_inner.run_name
                     );

-- Type Definition
-- To collect the result of cursor c_purge_cons_entity
   TYPE t_purge_cons_entity_id IS TABLE OF c_purge_cons_entity%ROWTYPE;
-- To collect the result of cursor c_purge_entry
   TYPE t_purge_entry_id       IS TABLE OF c_purge_entry%ROWTYPE;

-- Local Variable definition
   l_purge_cons_entity_list   t_purge_cons_entity_id;
   l_purge_entry_id_rec       t_purge_entry_id;
   l_run_name                 NUMBER;
   l_entity_name              VARCHAR2(100);
   v_product                  VARCHAR2(30) := 'GCS';
   v_table_name               VARCHAR2(30) := 'GCS_CONS_ENG_RUNS';
   p_key                      VARCHAR2(30);
   v_status                   VARCHAR2(30);
   v_industry                 VARCHAR2(30);
   v_retstatus                BOOLEAN;
   v_table_owner              VARCHAR2(30);
   v_any_rows_to_process      BOOLEAN := FALSE;
   v_start_rowid              ROWID;
   v_end_rowid                ROWID;
   v_rows_processed           NUMBER:=0;
   v_module_name              VARCHAR2(100);


   BEGIN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS_WORKER.begin', '<<Enter>>');
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS_WORKER', 'Consolidation Hierarchy    :  ' || p_consolidation_hierarchy);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS_WORKER', 'Consolidation Entity       :  ' || p_consolidation_entity);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS_WORKER', 'Calendar Period            :  ' || p_cal_period_id);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS_WORKER', 'Balance Type               :  ' || p_balance_type_code);
     END IF;

     fnd_file.put_line(fnd_file.log, 'Beginning Consolidation Purge Program');
     fnd_file.put_line(fnd_file.log, '<<Parameter Listings>>');
     fnd_file.put_line(fnd_file.log, 'Consolidation Hierarchy	:	' || p_consolidation_hierarchy);
     fnd_file.put_line(fnd_file.log, 'Consolidation Entity	    :	' || p_consolidation_entity);
     fnd_file.put_line(fnd_file.log, 'Calendar Period		    :	' || p_cal_period_id);
     fnd_file.put_line(fnd_file.log, 'Balance Type		        :	' || p_balance_type_code);
     fnd_file.put_line(fnd_file.log, '<<End of Parameter Listings>>');

      --
      -- Get schema name of the table for ROWID range processing
      --
      v_retstatus := fnd_installation.get_app_info( v_product,
                                                    v_status,
                                                    v_industry,
                                                    v_table_owner);

      IF ((v_retstatus = FALSE) OR (v_table_owner IS NULL)) THEN
        raise_application_error(-20001, 'Cannot get schema name for product : '||v_product);
      END IF;

      -- Worker processing
      -- To Generate Unique key

      SELECT run_name
      INTO   p_key
      FROM   gcs_cons_eng_runs gcer
      WHERE  gcer.hierarchy_id       =  p_consolidation_hierarchy
      AND    gcer.cal_period_id      =  p_cal_period_id
      AND    gcer.balance_type_code  =  p_balance_type_code
      AND    gcer.most_recent_flag   = 'Y'
      AND    gcer.run_entity_id      = p_consolidation_entity;

      -- To initialize the rowid range
      ad_parallel_updates_pkg.initialize_rowid_range( ad_parallel_updates_pkg.ROWID_RANGE,
                                                      v_table_owner,
                                                      v_table_name,
                                                      p_key,
                                                      p_Worker_Id,
                                                      p_Num_Workers,
                                                      p_batch_size,
                                                      0);

      -- To get its repective rowid range
      ad_parallel_updates_pkg.get_rowid_range( v_start_rowid,
                                               v_end_rowid,
                                               v_any_rows_to_process,
                                               p_batch_size,
                                               TRUE);

     -- v_any_rows_to_process = TRUE  means there are some rows to process
     -- v_any_rows_to_process = FALSE means there are no rows to process
     IF (v_any_rows_to_process = FALSE) THEN
       fnd_file.put_line(fnd_file.log, '<<------------------- No Rows to Process---------------------->>');
     END IF;
     -- This loop will be keep on repeated until all the rows allocated to a
     -- worker are processed i.e until v_any_rows_to_process becomes FALSE
     WHILE (v_any_rows_to_process = TRUE) LOOP
       -- Initially the number of rows prcessed are set zero.
       v_rows_processed :=0;
       -- Opening the cursor c_purge_cons_entity to collect the run names and run_entity_id
       -- that eligible for purging
       OPEN c_purge_cons_entity( p_consolidation_hierarchy,
                                 p_consolidation_entity,
                                 p_cal_period_id,
                                 p_balance_type_code,
                                 v_start_rowid,
                                 v_end_rowid);
       LOOP
         FETCH c_purge_cons_entity BULK COLLECT INTO l_purge_cons_entity_list LIMIT 1000;
         IF(l_purge_cons_entity_list.FIRST IS NOT NULL AND
            l_purge_cons_entity_list.LAST IS NOT NULL) THEN
           FOR i IN l_purge_cons_entity_list.FIRST .. l_purge_cons_entity_list.LAST LOOP
             -- Opening the cursor to get the entries that belong to current run
             -- and but not belong to most recent run
             OPEN c_purge_entry(p_consolidation_hierarchy,
                                p_cal_period_id,
                                p_balance_type_code,
                                l_purge_cons_entity_list(i).run_name,
                                l_purge_cons_entity_list(i).run_entity_id);
             LOOP
               FETCH c_purge_entry BULK COLLECT INTO l_purge_entry_id_rec LIMIT 1000;
               IF (l_purge_entry_id_rec.FIRST IS NOT NULL AND
                   l_purge_entry_id_rec.LAST IS NOT NULL) THEN
                 -- To print the header information like Run Name and Consolidation entity in log file
                 fnd_file.put_line(fnd_file.log, '+------------------------------------+--------------------------+-------------------------------------------------------------------------------------------+');
                 fnd_file.put_line(fnd_file.log, '| Run Name                           : '|| rpad(l_purge_cons_entity_list(i).run_name,117,' ')||'|');
                 fnd_file.put_line(fnd_file.log, '| Consolidation Entity ID            : '|| rpad(l_purge_cons_entity_list(i).entity_name,117,' ')||'|');
                 fnd_file.put_line(fnd_file.log, '+------------------------------------+--------------------------+-------------------------------------------------------------------------------------------+');
                 fnd_file.put_line(fnd_file.log, '| Child Entity                       | Entry Name               | Description                                                                               |');
                 fnd_file.put_line(fnd_file.log, '+------------------------------------+--------------------------+-------------------------------------------------------------------------------------------+');

                 FOR j IN l_purge_entry_id_rec.FIRST .. l_purge_entry_id_rec.LAST LOOP
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.PURGE_CONS_RUNS_WORKER', 'Run Name           :  ' ||l_purge_cons_entity_list(i).run_name ||
                                                                                                 'Run Entity ID      :  ' ||l_purge_cons_entity_list(i).run_entity_id||
                                                                                                 'Entry ID:          :  ' ||l_purge_entry_id_rec(j).entry_id||
                                                                                                 'Child Entity ID    :  ' ||l_purge_entry_id_rec(j).child_entity_id);
                   END IF;
                   -- To purge the entry line information
                   DELETE FROM gcs_entry_lines WHERE entry_id   = l_purge_entry_id_rec(j).entry_id;
                   -- To purge the entry header information
                   DELETE FROM gcs_entry_headers WHERE entry_id = l_purge_entry_id_rec(j).entry_id;
                   -- To get the Child entity name
                   SELECT entity_name
                   INTO   l_entity_name
                   FROM   fem_entities_tl fem
                   WHERE  fem.entity_id = l_purge_entry_id_rec(j).child_entity_id
                   AND    fem.language  = userenv('lang');
                   -- To print purged informatin into log file
                   fnd_file.put_line(fnd_file.log,'| '||rpad(l_entity_name,35,' ')||'| '||
                                                        rpad(l_purge_entry_id_rec(j).entry_name,25,' ')||'| '||
                                                        rpad(l_purge_entry_id_rec(j).description,90,' ')||'|');
                 END LOOP; -- end of inner for loop
               END IF;
               EXIT WHEN c_purge_entry%NOTFOUND;
             END LOOP; -- end of inner cursor(c_purge_entry) loop
             CLOSE c_purge_entry;

             -- To purge the run detial information
             DELETE FROM gcs_cons_eng_run_dtls gcerd
             WHERE gcerd.run_name                =  l_purge_cons_entity_list(i).run_name
             AND   gcerd.consolidation_entity_id =  l_purge_cons_entity_list(i).run_entity_id;

             -- To update the run information to PURGED.
             UPDATE gcs_cons_eng_runs
             SET    status_code   = 'PURGED'
             WHERE  run_name      = l_purge_cons_entity_list(i).run_name
             AND    run_entity_id = l_purge_cons_entity_list(i).run_entity_id;
             -- To keep track of how many rows processed so far
             v_rows_processed := v_rows_processed + SQL%ROWCOUNT;
           END LOOP; -- end of outer cursor forloop
         END IF;
         EXIT WHEN c_purge_cons_entity%NOTFOUND;
       END LOOP; -- enf of outer cursor(c_purge_cons_entity) loop
       fnd_file.put_line(fnd_file.log, '+------------------------------------+--------------------------+-------------------------------------------------------------------------------------------+');
       CLOSE c_purge_cons_entity;
       --To update number rows processed so far
       ad_parallel_updates_pkg.processed_rowid_range( v_rows_processed, v_end_rowid);
       COMMIT;
       --To get next of rows for processing
       ad_parallel_updates_pkg.get_rowid_range( v_start_rowid,
                                                v_end_rowid,
                                                v_any_rows_to_process,
                                                p_batch_size,
                                                FALSE);
     END LOOP; -- while loop for parallel processsing
     X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.PURGE_CONS_RUNS_WORKER.end', '<<Enter>>');
     END IF;
     EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       fnd_file.put_line(fnd_file.log, SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
       x_retcode :='2';
   END purge_cons_runs_worker; -- end of procedure purge_cons_runs
END GCS_PURGE_PKG; -- end of package GCS_PURGE_PKG

/
