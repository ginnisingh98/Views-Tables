--------------------------------------------------------
--  DDL for Package Body JTF_FM_HISTORY_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_HISTORY_UTIL_PVT" AS
/* $Header: jtfvfmhb.pls 120.12 2006/06/23 23:01:17 jakaur ship $*/
g_pkg_name      CONSTANT VARCHAR2(30) := 'JTF_FM_HISTORY_PVT';


/*----------------------------------------------------------------------------
Forward declaration of private objects
-----------------------------------------------------------------------------*/
 PROCEDURE delete_request_contents ( p_request_id    IN         NUMBER
                                   , x_return_status OUT NOCOPY VARCHAR2
                                   ) ;

 PROCEDURE delete_processed ( p_request_id    IN         NUMBER
                            , x_return_status OUT NOCOPY VARCHAR2
                            ) ;

 PROCEDURE delete_content_failures ( p_request_id    IN         NUMBER
                                   , x_return_status OUT NOCOPY VARCHAR2
                                   );

 PROCEDURE delete_email_stats ( p_request_id     IN         NUMBER
                              , x_return_status  OUT NOCOPY VARCHAR2
                              );

 PROCEDURE delete_request_history ( p_rowid          IN         ROWID
                                  , x_return_status  OUT NOCOPY VARCHAR2
                                  );
/*----------------------------------------------------------------------------
Forward declaration of private objects ends here
-----------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
-- PROCEDURE
--  DELETE_HISTORY_RECORDS
--
-- PURPOSE
--   Delete a request history record from all the related tablers
--
-- PARAMETERS
	-- request history id
--------------------------------------------------------------------------------
PROCEDURE DELETE_REQUEST_HISTORY(p_request_id   IN  NUMBER)
IS
BEGIN
DELETE  FROM JTF_FM_PROCESSED WHERE REQUEST_ID = p_request_id;
DELETE  FROM JTF_FM_REQUEST_CONTENTS WHERE REQUEST_ID = p_request_id;
DELETE  FROM JTF_FM_REQUEST_HISTORY WHERE HIST_REQ_ID = p_request_id;

COMMIT WORK;

END DELETE_REQUEST_HISTORY;

--------------------------------------------------------------------------------
-- PROCEDURE
--  DELETE_HISTORY_RECORDS_BATCH
--
-- PURPOSE
--   Delete request history record from all the related tablers. All those records
--   which were processed prior to a given date should be deleted.
--
-- PARAMETERS
--   p_data_age
--     Number of days back from current date.
--------------------------------------------------------------------------------
PROCEDURE delete_request_history_batch ( x_error_buffer     OUT NOCOPY VARCHAR2
                                       , x_return_code      OUT NOCOPY NUMBER
                                       , p_data_age         IN         NUMBER
                                       )
IS
CURSOR c_headers IS
       SELECT  hist_req_id request_id, ROWID, submit_dt_tm last_update_date
         FROM  jtf_fm_request_history_all
        WHERE  TRUNC(submit_dt_tm) <= TRUNC(SYSDATE) - p_data_age
     ORDER BY  hist_req_id ASC;
l_return_status   VARCHAR2(1);
l_message         VARCHAR2(4000);
e_error_found     EXCEPTION;
BEGIN
  l_message := 'Starting the purge program....';
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  l_message := 'Requests processed on or prior to '||TO_CHAR((SYSDATE - p_data_age), 'DD-MON-RRRR')||' will be purged.';
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  l_message := '';
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  FOR c_header_record IN c_headers
  LOOP
    FND_FILE.NEW_LINE(FND_FILE.LOG, 2);
    l_message := 'Starting purging for request ID: '|| c_header_record.request_id ||' (Last Updated On: '|| TO_CHAR(c_header_record.last_update_date, 'DD-MON-RRRR') ||')';
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

    BEGIN
      SAVEPOINT before_delete;
      delete_processed  ( p_request_id    => c_header_record.request_id
                        , x_return_status => l_return_status
                        );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE e_error_found;
      END IF;

      delete_request_contents ( p_request_id    => c_header_record.request_id
                              , x_return_status => l_return_status
                              );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE e_error_found;
      END IF;


      delete_content_failures ( p_request_id    => c_header_record.request_id
                              , x_return_status => l_return_status
                              );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE e_error_found;
      END IF;


      delete_email_stats ( p_request_id    => c_header_record.request_id
                         , x_return_status => l_return_status
                         );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE e_error_found;
      END IF;

      delete_request_history ( p_rowid         => c_header_record.rowid
                             , x_return_status => l_return_status
                             );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE e_error_found;
      END IF;


      COMMIT;
    EXCEPTION
      WHEN e_error_found
      THEN
        ROLLBACK TO before_delete;
        FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
        x_return_code  := 2;
        x_error_buffer := SQLERRM;
    END;

    l_message :=  'Ending purging for request ID: '|| c_header_record.request_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
  END LOOP;

  l_message := 'Purging funished.';
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '');


  x_return_code := 0;
EXCEPTION
  WHEN OTHERS
  THEN
    x_return_code   := 2;
    x_error_buffer  := SQLERRM;
END delete_request_history_batch;

--------------------------------------------------------------------------------
-- PROCEDURE
--  DELETE_REQUEST_CONTENT
--
-- PURPOSE
--   Delete history record from jtf_fm_request_contents table for a given request ID.
--
-- PARAMETERS
--   p_request_id
--     Request ID for which the records should be deleted.
--------------------------------------------------------------------------------
PROCEDURE delete_request_contents ( p_request_id    IN         NUMBER
                                  , x_return_status OUT NOCOPY VARCHAR2
                                  )
IS
l_message  VARCHAR2(4000);
l_count    NUMBER         DEFAULT 0;
BEGIN
  DELETE
    FROM  jtf_fm_request_contents
   WHERE  request_id = p_request_id  ;

  l_count   := SQL%ROWCOUNT;

  l_message := RPAD('JTF_FM_REQUEST_CONTENTS table, records purged: ', 60, ' ') || l_count;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS
 THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END delete_request_contents ;

--------------------------------------------------------------------------------
-- PROCEDURE
--  DELETE_PROCESSED
--
-- PURPOSE
--   Delete history record from jtf_fm_processed table for a given request ID.
--
-- PARAMETERS
--   p_request_id
--     Request ID for which the records should be deleted.
--------------------------------------------------------------------------------
PROCEDURE delete_processed ( p_request_id    IN         NUMBER
                           , x_return_status OUT NOCOPY VARCHAR2
                           )
IS
l_count    NUMBER          DEFAULT 0;
l_message  VARCHAR2(4000);
BEGIN
  DELETE
    FROM  jtf_fm_processed
   WHERE  request_id = p_request_id  ;

  l_count   := SQL%ROWCOUNT;

  l_message := RPAD('JTF_FM_PROCESSED table, records purged: ', 60, ' ') || l_count;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS
 THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END delete_processed ;

--------------------------------------------------------------------------------
-- PROCEDURE
--  DELETE_CONTENT_FAILURES
--
-- PURPOSE
--   Delete history records from jtf_fm_content_failures table for a given request ID.
--
-- PARAMETERS
--   p_request_id
--     Request ID for which the records should be deleted.
--------------------------------------------------------------------------------
PROCEDURE delete_content_failures ( p_request_id    IN         NUMBER
                                  , x_return_status OUT NOCOPY VARCHAR2
                                  )
IS
l_count    NUMBER          DEFAULT 0;
l_message  VARCHAR2(4000);
BEGIN
  DELETE
    FROM  jtf_fm_content_failures
   WHERE  request_id = p_request_id  ;

  l_count   := SQL%ROWCOUNT;

  l_message := RPAD('JTF_FM_CONTENT_FAILURES table, records purged: ', 60, ' ') || l_count;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS
 THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END delete_content_failures ;

--------------------------------------------------------------------------------
-- PROCEDURE
--  DELETE_EMAIL_STATS
--
-- PURPOSE
--   Delete history record from jtf_fm_email_stats table for a given request ID.
--
-- PARAMETERS
--   p_request_id
--     Request ID for which the records should be deleted.
--------------------------------------------------------------------------------
PROCEDURE delete_email_stats ( p_request_id     IN         NUMBER
                             , x_return_status  OUT NOCOPY VARCHAR2
                             )
IS
l_count    NUMBER          DEFAULT 0;
l_message  VARCHAR2(4000);
BEGIN
  DELETE
    FROM  jtf_fm_email_stats
   WHERE  request_id = p_request_id  ;

  l_count   := SQL%ROWCOUNT;

  l_message := RPAD('JTF_FM_EMAIL_STAT table, records purged: ', 60, ' ') || l_count;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS
 THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END delete_email_stats ;

--------------------------------------------------------------------------------
-- PROCEDURE
--  DELETE_REQUEST_HISTORY
--
-- PURPOSE
--   Delete history record from jtf_fm_request_history table for a given ROWID.
--
-- PARAMETERS
--   p_request_id
--     Request ID for which the records should be deleted.
--------------------------------------------------------------------------------
PROCEDURE delete_request_history ( p_rowid          IN         ROWID
                                 , x_return_status  OUT NOCOPY VARCHAR2
                                 )
IS
l_count    NUMBER          DEFAULT 0;
l_message  VARCHAR2(4000);
BEGIN
  DELETE
    FROM  jtf_fm_request_history
   WHERE  ROWID = p_rowid;

  l_count   := SQL%ROWCOUNT;

  l_message := RPAD('JTF_FM_REQUEST_HISTORY table, records purged: ', 60, ' ') || l_count;
  FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS
 THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END delete_request_history;

--------------------------------------------------------------------------------
-- PROCEDURE
--  PURGE_HISTORY_MGR
--
-- PURPOSE
--   The parent program that will start off the child threads for deletion.
--   Delete history record from various tables for a given data age.
--
-- PARAMETERS
--   p_data_age
--     Number of days for which the records should be deleted.
--   p_batch_size
--     Number of records after which a commit should be applied.
--   p_num_workers
--     Number of worker threads that should be started.
--------------------------------------------------------------------------------

PROCEDURE purge_history_mgr ( x_errbuf        OUT NOCOPY VARCHAR2
                            , x_retcode       OUT NOCOPY VARCHAR2
                            , p_data_age      IN         NUMBER
                            , p_batch_size    IN         NUMBER
                            , p_num_workers   IN         NUMBER
                            ) IS
l_errbuf           VARCHAR2(32767);
l_retcode          NUMBER;
l_count            NUMBER := 0;
l_conc_request_id  NUMBER;
l_children_done    BOOLEAN;
BEGIN

 -- updating the purge_flag
  UPDATE jtf_fm_request_history_all
  SET    purge_flag  = 'Y'
  WHERE  TRUNC(last_update_date) <= TRUNC(SYSDATE) - p_data_age
  ;

  COMMIT;

  l_conc_request_id := FND_GLOBAL.conc_request_id();

  ad_conc_utils_pkg.submit_subrequests( x_errbuf                      => l_errbuf
                                      , x_retcode                     => l_retcode
                                      , x_workerconc_app_shortname    => 'JTF'
                                      , x_workerconc_progname         => 'JTF_FM_PURGE_REQ_WKR'
                                      , x_batch_size                  => p_batch_size
                                      , x_num_workers                 => p_num_workers
                                      , x_argument4                   => l_conc_request_id
                                      );

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Starting purge program.....');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Requests processed on or prior to '||TO_CHAR((SYSDATE - p_data_age), 'DD-MON-RRRR')||' will be purged.');
    FND_FILE.NEW_LINE(FND_FILE.LOG, 2);

  l_children_done := FND_CONCURRENT.children_done ( parent_request_id   => l_conc_request_id
                                                  , recursive_flag      => 'N'
                                                  , interval            => 15
                                                  );

  IF ((l_retcode <> ad_conc_utils_pkg.conc_fail) AND
      (l_children_done))
  THEN
    DECLARE
      CURSOR c_history_id IS
             SELECT  hist_req_id
             FROM    jtf_fm_request_history_all
             WHERE   purge_flag = 'Y'
             ORDER BY hist_req_id ASC;
      TYPE typ_request_id IS TABLE OF jtf_fm_request_history_all.hist_req_id%TYPE;
      tab_request_id    typ_request_id;
    BEGIN
      FND_FILE.NEW_LINE(FND_FILE.LOG, 2);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'JTF_FM_PROCESSED table purged.');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Starting purging of other child tables....');

      OPEN c_history_id;
      LOOP
        FETCH c_history_id BULK COLLECT INTO tab_request_id LIMIT 1000;
          FORALL i IN 1 .. tab_request_id.COUNT
            DELETE
            FROM   jtf_fm_request_contents
            WHERE  request_id = tab_request_id(i)
          ;

          FORALL i IN 1 .. tab_request_id.COUNT
            DELETE
            FROM   jtf_fm_content_failures
            WHERE  request_id = tab_request_id(i)
          ;

          FORALL i IN 1 .. tab_request_id.COUNT
            DELETE
            FROM   jtf_fm_email_stats
            WHERE  request_id = tab_request_id(i)
          ;

        EXIT WHEN c_history_id%NOTFOUND;
        COMMIT;
      END LOOP;
      CLOSE c_history_id;


      DELETE
      FROM   jtf_fm_request_history_all
      WHERE  purge_flag = 'Y';

      l_count := SQL%ROWCOUNT;

      COMMIT;

      DELETE
      FROM   jtf_fm_int_request_header
      WHERE  TRUNC(last_update_date) <= TRUNC(SYSDATE) - p_data_age
      ;

      COMMIT;

      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of Requests Purged: '|| l_count);

    EXCEPTION
      WHEN OTHERS
      THEN
        x_retcode := ad_conc_utils_pkg.conc_fail;
        x_errbuf  := SQLERRM;
        RAISE;
    END;
  END IF;


  x_retcode := ad_conc_utils_pkg.conc_success;

EXCEPTION
  WHEN OTHERS
  THEN
    x_retcode := ad_conc_utils_pkg.conc_fail;
    x_errbuf  := SQLERRM;
    RAISE;
END purge_history_mgr;

--------------------------------------------------------------------------------
-- PROCEDURE
--  PURGE_HISTORY_WKR
--
-- PURPOSE
--   The worker program that will delete ther rows from JTF_FM_PROCESSED
--   table based upon the ROWID (based upon LTU Processing).
--
-- PARAMETERS
--   x_batch_size
--     Number of records after which a commit should be applied.
--   x_worker_id
--     Unique identifier for a worker thread.
--   x_num_workers
--     Number of worker threads that should be started.
--   x_argument4
--     Concurrent program ID. Passed in by the parent thread.
--------------------------------------------------------------------------------
PROCEDURE purge_history_wkr ( x_errbuf       OUT NOCOPY VARCHAR2
                            , x_retcode      OUT NOCOPY VARCHAR2
                            , x_batch_size   IN         NUMBER
                            , x_worker_id    IN         NUMBER
                            , x_num_workers  IN         NUMBER
                            , x_argument4    IN         VARCHAR2
                            ) IS
l_worker_id            NUMBER;
l_product              VARCHAR2(30) := 'JTF';
l_table_name           VARCHAR2(30) := 'JTF_FM_PROCESSED';
l_update_name          VARCHAR2(30);
l_status               VARCHAR2(30);
l_industry             VARCHAR2(30);
l_restatus             BOOLEAN;
l_table_owner          VARCHAR2(30);
l_any_rows_to_process  BOOLEAN;
l_start_rowid          ROWID;
l_end_rowid            ROWID;
l_rows_processed       NUMBER;
BEGIN
  --
  --Get schema name of the table for ROWID range processing
  --

  l_restatus := fnd_installation.get_app_info ( l_product, l_status, l_industry, l_table_owner );

  IF (( l_restatus = FALSE ) OR
      ( l_table_owner IS NULL))
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cannot get schema name for product: '|| l_product );
  END IF;

  FND_FILE.PUT_LINE( FND_FILE.LOG, 'X_Worker_Id: '|| x_worker_id );
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'X_Num_Workers: '|| x_num_workers );

  l_update_name := x_argument4;


  --
  -- Worker Processing
  --

  BEGIN
    ad_parallel_updates_pkg.initialize_rowid_range
    (
      ad_parallel_updates_pkg.ROWID_RANGE
    , l_table_owner
    , l_table_name
    , l_update_name
    , x_worker_id
    , x_num_workers
    , x_batch_size
    , 0
    );

    ad_parallel_updates_pkg.get_rowid_range
    (
      l_start_rowid
    , l_end_rowid
    , l_any_rows_to_process
    , x_batch_size
    , TRUE
    );

    WHILE ( l_any_rows_to_process = TRUE )
    LOOP
      DELETE /*+ rowid(jfp) */
      FROM   jtf_fm_processed jtp
      WHERE  request_id IN ( SELECT /*+ index(jrh, jtf.jtf_fm_request_history_all_nu2) */ hist_req_id
                             FROM   jtf_fm_request_history_all jrh
                             WHERE  purge_flag = 'Y'
                            )
      AND ROWID BETWEEN l_start_rowid AND l_end_rowid
      ;

      l_rows_processed := SQL%ROWCOUNT;

      ad_parallel_updates_pkg.processed_rowid_range
      (
        l_rows_processed
      , l_end_rowid
      );

      COMMIT;

      ad_parallel_updates_pkg.get_rowid_range
      (
        l_start_rowid
      , l_end_rowid
      , l_any_rows_to_process
      , x_batch_size
      , FALSE
      );
    END LOOP;

    x_retcode := ad_conc_utils_pkg.conc_success;

  EXCEPTION
    WHEN OTHERS
    THEN
      x_retcode := ad_conc_utils_pkg.conc_fail;
      x_errbuf  := SQLERRM;
      RAISE;
  END;

EXCEPTION
  WHEN OTHERS
  THEN
    x_retcode  := ad_conc_utils_pkg.conc_fail;
    x_errbuf   := SQLERRM;
END purge_history_wkr;

END JTF_FM_HISTORY_UTIL_PVT;

/
