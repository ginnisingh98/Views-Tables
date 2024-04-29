--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_TERR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_TERR_PVT" 
/* $Header: OKITERRB.pls 120.3 2005/10/04 17:15:09 ngmishra noship $ */
AS

g_global_Start_date        DATE;
g_start_date               DATE;
g_end_date                 DATE;
g_4712_date                DATE;
g_oki_schema               VARCHAR2(30);
g_sysdate                  DATE;
g_user_id                  NUMBER;
g_login_id                 NUMBER;
g_status                   VARCHAR2(100);
g_industry                 VARCHAR2(100);
g_user_name                VARCHAR2(100);
g_table_owner              VARCHAR2(100);
g_load_type                VARCHAR2(100);
G_CHILD_PROCESS_ISSUE      EXCEPTION;

/* This API is used to print the log messages.
   It has two paramters.
   p_string    : IN parameter, the string to be printed
   p_indent    : IN parameter, gives the information about number of
                 indentation */

PROCEDURE rlog  (  p_string IN VARCHAR2
                ,  p_indent IN NUMBER )
IS
   l_message       varchar2(2000);
BEGIN
    l_message := NULL;
    FOR i IN 1..p_indent
    LOOP
    l_message:='   '||l_message;
    END LOOP;

    l_message:=l_message||p_string;

COMMIT;
    fnd_file.put_line(  which => fnd_file.log,
                            buff  => l_message);
EXCEPTION
    WHEN OTHERS THEN
       fnd_file.put_line(  which => fnd_file.log,
                            buff  => sqlerrm || '' || sqlcode);
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_LOAD_TERR_PVT.log' ) ;
       fnd_file.put_line(  which => fnd_file.log,
                            buff  => fnd_message.get);
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
END rlog;

/* This API is used to launch the worker.
   It has only one parameter.
   p_worker_no      :  IN parameter, gives information about no of worker to spawn */

PROCEDURE launch_worker(p_worker_no IN NUMBER)
IS
   l_request_id NUMBER;

BEGIN

  fnd_profile.put('CONC_SINGLE_THREAD','N');

  l_request_id := FND_REQUEST.SUBMIT_REQUEST(g_oki_schema,
                                            'OKI_TERR_WORKER',
                                             NULL,
                                             NULL,
                                             FALSE,
                                             p_worker_no,
                                             g_load_type);

  rlog('Request ID of the concurrent request launched : ' || l_request_id,2);

  -- if the submission of the request fails , abort the program
  IF (l_request_id = 0) THEN
     rlog('Error in launching child workers',2);
     RAISE G_CHILD_PROCESS_ISSUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    rlog('Error in launch_worker : Error : ' || SQLERRM,2);
    RAISE;
END launch_worker;

/* This API does not take any paramters.
   It either truncates/deletes unwanted old records from
   either staging table or Fact table or Worker Status table.
 */
PROCEDURE reset_base_tables
IS
  l_tab_name         VARCHAR2(100);
  l_ind_name         VARCHAR2(100);
  l_sql_string       VARCHAR2(1000);

BEGIN

  IF g_load_type = 'INIT' THEN
      -- truncate tables
      l_sql_string := 'TRUNCATE TABLE '|| g_oki_schema ||'.OKI_JTF_TERRITORIES';
       EXECUTE IMMEDIATE l_sql_string;
      rlog( 'Truncated Table OKI_JTF_TERRITORIES',2);
  END IF;

  l_sql_string := 'TRUNCATE TABLE '|| g_oki_schema ||'.OKI_JTF_TERRITORIES_STG';
   EXECUTE IMMEDIATE l_sql_string;
  rlog( 'Truncated Table OKI_JTF_TERRITORIES_STG',2);

  DELETE FROM OKI_DBI_WORKER_STATUS
   WHERE OBJECT_NAME = 'OKI_JTF_TERRITORIES';
  COMMIT;

  If g_load_type ='INIT' THEN
      BIS_COLLECTION_UTILITIES.DeleteLogForObject('OKIJTFTERR');
      rlog( 'Completed resetting base tables and BIS log file ' || fnd_date.date_to_displayDT(sysdate),1);
  ELSE
  	  rlog( 'Completed resetting base tables ' || fnd_date.date_to_displayDT(sysdate),1);
  END IF;

EXCEPTION
    WHEN OTHERS
    THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                           ,  name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                         token => 'ROUTINE'
                     ,   value => 'OKI_LOAD_TERR_PVT.RESET_BASE_TABLES ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE;
END reset_base_tables;

/* This API calculates and prints the load duration. This is called by both
   initial ,incremntal load and worker.
   It has 3 parameters.
   p_start_date     :  IN parameter, start date of the load
   p_end_date       :  IN parameter, end date of the load
   p_string         :  IN parameter, this is to differentiate the call between
   	                  worker or by main programs. If it is not null, it is called
	                  by worker else it is called by main programs*/
PROCEDURE find_time_diff (p_start_date IN DATE,
                          p_end_date   IN DATE,
                          p_string IN VARCHAR2)
IS
  l_days    NUMBER;
  l_hours   NUMBER;
  l_minutes NUMBER;
  l_seconds NUMBER;
  l_date    TIMESTAMP;
  l_str     VARCHAR2(1000);
  l_temp_str VARCHAR2(1000);
BEGIN
  l_date    := TO_TIMESTAMP(p_end_date);
  l_days    := EXTRACT (day FROM l_date - p_start_date);
  l_hours   := EXTRACT (hour FROM l_date - p_start_date);
  l_minutes := EXTRACT (minute FROM l_date - p_start_date);
  l_seconds := EXTRACT (second FROM l_date - p_start_date);

  IF p_string IS NULL THEN
     IF g_load_type ='INIT' THEN
     l_str := 'Initial Load Completed in ';
     ELSE
     l_str := 'Incremental Load Completed in ';
     END IF;
  ELSE
  	l_str := p_string;
  END IF;

  l_temp_str := l_str;

  IF ( l_days > 0 ) THEN
  	IF l_days = 1 THEN
  	l_str := l_str || l_days || ' Day ';
    ELSE
  	l_str := l_str || l_days || ' Days ';
    END IF;
  END IF;
  IF ( l_hours > 0 ) THEN
  	IF l_hours = 1 THEN
  	l_str := l_str || l_hours || ' Hour ';
    ELSE
  	l_str := l_str || l_hours || ' Hours ';
    END IF;
  END IF;
  IF ( l_minutes > 0 ) THEN
  	IF l_minutes = 1 THEN
  	l_str := l_str || l_minutes || ' Minute ';
    ELSE
  	l_str := l_str || l_minutes || ' Minutes ';
    END IF;
  END IF;
  IF ( l_seconds <> 0 ) THEN
  	IF l_seconds = 1 THEN
  	l_str := l_str || l_seconds || ' Second ';
    ELSE
  	l_str := l_str || l_seconds || ' Seconds ';
    END IF;
  END IF;

  IF l_str = l_temp_str THEN
  	l_str := l_str || 'less than a second ';
  END IF;

  IF p_string IS NULL THEN
    rlog (l_str,0);
  ELSE
  	rlog (l_str,1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     rlog('Unable to calculate load running time ', 0);
END;

/* This API is used to spawn the workers.
   It has two paramters.
   p_no_of_workers    : IN parameter, gives information about
                        no of worker to spawn
   p_terr_count       : IN parameter, gives territory count. Based on
                        this parameter only workers will be distriubted. */

PROCEDURE spawn_workers( p_no_of_workers IN NUMBER
                       , p_terr_count    IN NUMBER)
IS
  l_no_of_workers NUMBER;
  l_terr_count    NUMBER;
  l_sql_string   VARCHAR2(1000);

BEGIN

  l_no_of_workers := p_no_of_workers;
  l_terr_count    := p_terr_count;


     FOR worker_no IN 1 .. l_no_of_workers LOOP

         UPDATE OKI_JTF_TERRITORIES_STG
         SET worker_number = worker_no
         WHERE worker_number IS NULL
         AND ROWNUM <= CEIL(l_terr_count/l_no_of_workers);

         IF ( SQL%ROWCOUNT > 0 ) THEN
            INSERT INTO OKI_DBI_WORKER_STATUS (
               object_name
             , worker_number
             , status
             , c_rows
              )
            VALUES(
              'OKI_JTF_TERRITORIES'
             , worker_no
             ,'UNASSIGNED'
             , -1
             );
         END IF;
         COMMIT;

     END LOOP;

     FOR worker_no IN 1 .. l_no_of_workers
     LOOP
         launch_worker(worker_no);
     END LOOP;

  -- To check if the child workers have completed the requests sucessfully.

     DECLARE
       l_unassigned_cnt       NUMBER := 0;
       l_completed_cnt        NUMBER := 0;
       l_wip_cnt              NUMBER := 0;
       l_failed_cnt           NUMBER := 0;
       l_tot_cnt              NUMBER := 0;

     BEGIN
       LOOP
         SELECT NVL(sum(decode(status,'UNASSIGNED',1,0)),0),
                NVL(sum(decode(status,'COMPLETED',1,0)),0),
                NVL(sum(decode(status,'IN PROCESS',1,0)),0),
                NVL(sum(decode(status,'FAILED',1,0)),0),
                count(*)
         INTO   l_unassigned_cnt,
                l_completed_cnt,
                l_wip_cnt,
                l_failed_cnt,
                l_tot_cnt
         FROM   OKI_DBI_WORKER_STATUS
         WHERE object_name = 'OKI_JTF_TERRITORIES';

         IF ( l_failed_cnt > 0 ) THEN
           rlog('One of the child workers Errored Out',2);
           RAISE G_CHILD_PROCESS_ISSUE;
         END IF;

         IF ( l_tot_cnt = l_completed_cnt ) THEN
            rlog('All Workers Finished Successfully at '||fnd_date.date_to_displayDT(sysdate),2);
            EXIT;
         END IF;
         DBMS_LOCK.sleep(5);
       END LOOP;

     EXCEPTION

       WHEN G_CHILD_PROCESS_ISSUE then
       	 IF g_load_type ='INIT' THEN
           l_sql_string := 'TRUNCATE TABLE '|| g_oki_schema ||'.OKI_JTF_TERRITORIES';
           EXECUTE IMMEDIATE l_sql_string;
         END IF;
         RAISE;

       WHEN OTHERS THEN
         rlog( 'Error while loading table OKI_JTF_TERRITORIES table   :   ' || SQLERRM, 2 );
         RAISE;

     END;   -- Monitor child process Ends here.

EXCEPTION
	WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                           ,  name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                         token => 'ROUTINE'
                     ,   value => 'OKI_LOAD_TERR_PVT.spawn_workers ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE;
END spawn_workers;

/* This API is used to load the staging table.
   It has only one paramter.
   p_terr_count       : OUT parameter, gives territory count.*/

PROCEDURE load_staging ( p_terr_count OUT NOCOPY NUMBER)
IS
l_tab_name  VARCHAR2(1000);
BEGIN
  rlog('Loading of Staging Table Started - ' || fnd_date.date_to_displayDT(sysdate),1);

	IF g_load_type ='INIT' THEN

     INSERT /* + APPEND */  INTO OKI_JTF_TERRITORIES_STG
        (   authoring_org_id
          , party_id
          , party_name
          , country_code
          , state_code
          , record_id
        )
      SELECT
            authoring_org_id
          , party_id
          , party_name
          , country_code
          , state_code
          , ROWNUM
      FROM
      (
       SELECT /* + parallel(b) parallel(sts) parallel(c) parallel(p) parallel(v)
                  parallel(h) parallel(ro) use_hash(b,c,p,v,h,ro,sts) */
              DISTINCT
              h.authoring_org_id,
              p.party_id,
              p.party_Name,
              c.country country_code,
              c.region_2 state_code
         FROM hr_all_organization_units b
            , hr_locations c
            , hz_parties p
            , okc_k_headers_all_b h
            , okc_k_vers_numbers v
            , okc_statuses_b sts
            , okc_k_party_roles_b ro
         WHERE h.authoring_org_id = b.organization_id
           AND b.location_id = c.location_id
           AND p.party_id = ro.object1_id1
           AND (   sts.ste_code = 'ACTIVE'
                 OR (sts.ste_code = 'EXPIRED' AND h.end_date >= g_sysdate - 120)
                 OR (sts.ste_code = 'ENTERED' AND h.start_date >= g_sysdate - 365)
               )
           AND v.last_update_date   >= g_start_date
           AND v.last_update_date+0 <= g_end_date
           AND h.id                = v.chr_id
           AND COALESCE(h.date_terminated,h.datetime_cancelled,h.end_date,g_4712_date) > g_global_start_date
           AND h.template_yn       = 'N'
           AND h.application_id    = 515
           AND h.buy_or_sell       ='S'
           AND h.scs_code IN ('SERVICE','WARRANTY')
           AND ro.dnz_chr_id      = h.id
           AND ro.cle_id   IS NULL
           AND ro.rle_code IN ('CUSTOMER','LICENSEE','BUYER')
           AND NVL(ro.primary_yn,'Y') = 'Y'
      );
    ELSE
    	INSERT /* + APPEND */  INTO OKI_JTF_TERRITORIES_STG
        (   authoring_org_id
          , party_id
          , party_name
          , country_code
          , state_code
          , record_id
        )
      SELECT
            authoring_org_id
          , party_id
          , party_name
          , country_code
          , state_code
          , ROWNUM
      FROM
      (
       SELECT
              DISTINCT
              h.authoring_org_id,
              p.party_id,
              p.party_Name,
              c.country country_code,
              c.region_2 state_code
         FROM hr_all_organization_units b
            , hr_locations c
            , hz_parties p
            , okc_k_headers_all_b h
            , okc_k_vers_numbers v
            , okc_statuses_b sts
            , okc_k_party_roles_b ro
         WHERE h.authoring_org_id = b.organization_id
           AND b.location_id = c.location_id
           AND p.party_id = ro.object1_id1
           AND (   sts.ste_code = 'ACTIVE'
                 OR (sts.ste_code = 'EXPIRED' AND h.end_date >= g_sysdate - 120)
                 OR (sts.ste_code = 'ENTERED' AND h.start_date >= g_sysdate - 365)
               )
           AND v.last_update_date   >= g_start_date
           AND v.last_update_date+0 <= g_end_date
           AND h.id                = v.chr_id
           AND COALESCE(h.date_terminated,h.datetime_cancelled,h.end_date,g_4712_date) > g_global_start_date
           AND h.template_yn       = 'N'
           AND h.application_id    = 515
           AND h.buy_or_sell       ='S'
           AND h.scs_code IN ('SERVICE','WARRANTY')
           AND ro.dnz_chr_id      = h.id
           AND ro.cle_id   IS NULL
           AND ro.rle_code IN ('CUSTOMER','LICENSEE','BUYER')
           AND NVL(ro.primary_yn,'Y') = 'Y'
      );
    END IF;
    p_terr_count := SQL%ROWCOUNT;
    COMMIT;
  rlog('No of records inserted into Staging table - ' || p_terr_count,1);

    l_tab_name := 'OKI_JTF_TERRITORIES_STG';
    fnd_stats.gather_table_stats(  ownname=> g_table_owner
                                 , tabname=> l_tab_name
                                 , percent=> 10);
  rlog('Loading of Staging Table Completed - ' || fnd_date.date_to_displayDT(sysdate),1);

EXCEPTION
	WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                           ,  name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                         token => 'ROUTINE'
                     ,   value => 'OKI_LOAD_TERR_PVT.load_staging ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
		RAISE;
END load_staging;

/* This API will be called by SubWorker Concurrent Program.
   This is the Driving Procedure for Workers
   It has four Parameters
   errbuf        : OUT parameter, Used to store the Error Information if
                   this API fails.
   retcode       : OUT parameter, Used to store the Error Code if
                   this API fails.
   p_worker_no   : IN parameter, gives information about
                   the worker number
   p_load_type   : IN parameter, gives information about load type.
                   possible values are 'INIT','INCR'*/

PROCEDURE worker( errbuf      OUT   NOCOPY VARCHAR2,
                  retcode     OUT   NOCOPY VARCHAR2,
                  p_worker_no IN NUMBER,
                  p_load_type IN VARCHAR2
                 ) IS

  l_unassigned_cnt       NUMBER;
  l_failed_cnt           NUMBER;
  l_wip_cnt              NUMBER;
  l_completed_cnt        NUMBER;
  l_total_cnt            NUMBER;
  l_count                NUMBER;
  l_recs_processed       NUMBER;
  l_start_date           DATE;
  l_string               VARCHAR2(1000);
BEGIN
    g_load_type := p_load_type;
    l_start_date := SYSDATE;
    l_unassigned_cnt     := 0;
    l_failed_cnt         := 0;
    l_wip_cnt            := 0;
    l_completed_cnt      := 0;
    l_total_cnt          := 0;
    l_count              := 0;
    l_recs_processed     := 0;
    errbuf  := NULL;
    retcode := 0;
    l_count := 0;

    SELECT NVL(sum(decode(status,'UNASSIGNED', 1, 0)),0),
           NVL(sum(decode(status,'FAILED', 1, 0)),0),
           NVL(sum(decode(status,'IN PROCESS', 1, 0)),0),
           NVL(sum(decode(status,'COMPLETED',1 , 0)),0),
           count(*)
    INTO   l_unassigned_cnt,
           l_failed_cnt,
           l_wip_cnt,
           l_completed_cnt,
           l_total_cnt
    FROM   OKI_DBI_WORKER_STATUS
    WHERE 1=1
    AND object_name = 'OKI_JTF_TERRITORIES';

    IF (l_failed_cnt > 0) THEN
      rlog('Another subworker have errored out.  Stop processing.',1);
    ELSIF (l_unassigned_cnt = 0) THEN
      rlog('No more jobs left.  Terminating.',1);
    ELSIF (l_completed_cnt = l_total_cnt) THEN
      rlog('All jobs completed, no more job.  Terminating',1);
    ELSIF (l_unassigned_cnt > 0) THEN
      rlog('Subworker ' || p_worker_no ||' Starts: - ' ||fnd_date.date_to_displayDT(SYSDATE),1);

      UPDATE OKI_DBI_WORKER_STATUS
      SET status = 'IN PROCESS'
      WHERE object_name = 'OKI_JTF_TERRITORIES'
      AND worker_number = p_worker_no
      AND STATUS ='UNASSIGNED';

      COMMIT;
-- Calling the procedure for loading the jtf table!

     load_jtf_terr (p_worker_no, l_count);

        UPDATE OKI_DBI_WORKER_STATUS
        SET    status = 'COMPLETED'
             , c_rows = l_count
        WHERE  object_name = 'OKI_JTF_TERRITORIES'
        AND    status = 'IN PROCESS'
        AND    worker_number = p_worker_no;
        COMMIT;

   END IF;

    rlog('Subworker ' || p_worker_no || ' Finishes: - ' ||fnd_date.date_to_displayDT(SYSDATE),1);

    l_string := 'Subworker ' || p_worker_no || ' Completed in ' ;

    find_time_diff( l_start_date
                  , sysdate
                  , l_string
                  );
EXCEPTION
   WHEN OTHERS THEN
     retcode := 2;
     rlog('Error in procedure worker : Error : ' || SQLERRM,1);
     RAISE;
END WORKER;

/* This API will be used in both initial and incremental load.
   This is the Driving Procedure.
   It has three Parameters
   errbuf              : OUT parameter, Used to store the Error Information if
                         this API fails.
   retcode             : OUT parameter, Used to store the Error Code if
                         this API fails.
   p_number_of_workers : IN parameter, gives information about
                         Number of workers to spawn.*/
PROCEDURE refresh_jtf_terr  ( errbuf  OUT NOCOPY VARCHAR2
                            , retcode OUT NOCOPY VARCHAR2
                            , p_number_of_workers IN NUMBER
                            ) IS

  l_errpos             NUMBER;
  l_tab_name           VARCHAR2(100);
  l_count              NUMBER;
  l_setup_ok           BOOLEAN;
  l_string             VARCHAR2(1000);
 BEGIN

   l_setup_ok := BIS_COLLECTION_UTILITIES.setup('OKIJTFTERR');
   IF (NOT l_setup_ok) THEN
       errbuf := fnd_message.get;
       rlog( 'BIS Setup Failure ',0);
       RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   END IF;

  l_errpos := 1;
  l_tab_name  := 'OKI_JTF_TERRITORIES';

  IF g_load_type ='INIT' THEN
    l_string := 'INITIAL';
  ELSE
  	l_string := 'INCREMENTAL';
  END IF;

  rlog( 'Service Contracts Intelligence - TERRITORY '||l_string ||' LOAD:  ' ||
         fnd_date.date_to_displayDT(SYSDATE),0);
  rlog( 'Parameter : Start date        '|| fnd_date.date_to_displayDT(g_start_date), 1);
  rlog( 'Parameter : End date          '|| fnd_date.date_to_displayDT(g_end_date), 1);
  rlog( 'Parameter : Number of Workers '|| p_number_of_workers, 1);


  l_errpos := 2;

  reset_base_tables;

  l_errpos := 3;

  load_staging(l_count);

  l_errpos := 4;
  IF l_count > 0 THEN
  rlog('Launching Sub-Workers to load/update OKI_JTF_TERRITORIES table '  || fnd_date.date_to_displayDT(SYSDATE),1);
  spawn_workers( p_number_of_workers
               , l_count);
  END IF;
  l_errpos := 5;

    l_errpos := 6;
    -- analyze table
    fnd_stats.gather_table_stats( ownname => g_table_owner
                                , tabname => l_tab_name
                                , percent => 10);
    l_errpos := 7;

    SELECT NVL(SUM(c_rows),0) INTO l_count
      FROM OKI_DBI_WORKER_STATUS
     WHERE object_name ='OKI_JTF_TERRITORIES';

     rlog('No of records inserted/updated in OKI_JTF_TERRITORIES table - ' || l_count , 1);

     BIS_COLLECTION_UTILITIES.wrapup( TRUE
                                    , l_count
                                    , 'OKI TERRITORY ' || l_string || ' LOAD COMPLETED SUCCESSFULLY'
                                    , g_start_date
                                    , g_end_date
                                    );

     rlog('SUCCESS: Load Program Successfully completed ' || fnd_date.date_to_displayDT(SYSDATE),0);

    find_time_diff( g_sysdate
                  , sysdate
                  , NULL);

    l_errpos := 7;
    retcode  :='0';

EXCEPTION
  WHEN OTHERS THEN
    retcode := sqlcode;
    errbuf  := sqlerrm;
    ROLLBACK;

    retcode := '2';
    BIS_COLLECTION_UTILITIES.wrapup( FALSE
                                   , l_count
                                   , errbuf  || ': ' || retcode
                                   , g_start_date
                                   , g_end_date
                                   );
    fnd_message.set_name(  application => 'FND'
                         , name        => 'CRM-DEBUG ERROR' ) ;
    fnd_message.set_token( token => 'ROUTINE'
                         , value => 'OKI_LOAD_TERR_PVT.refresh_jtf_terr' ) ;
    bis_collection_utilities.put_line(fnd_message.get) ;

    RAISE;
END refresh_jtf_terr;

/* This API will be called by Initial Load Concurrent Program.
   It has three Parameters
   errbuf             : OUT parameter, Used to store the Error Information if
                        this API fails.
   retcode            : OUT parameter, Used to store the Error Code if
                        this API fails.
   p_worker_number    : IN parameter, gives information about
                        Number of workers to spawn.*/
PROCEDURE initial_load ( errbuf  OUT NOCOPY VARCHAR2
                       , retcode OUT NOCOPY VARCHAR2
                       , p_number_of_workers IN NUMBER)
IS
BEGIN

g_load_type :='INIT';
g_start_date        := g_global_start_date;
g_end_date          := g_sysdate;

refresh_jtf_terr( errbuf
                , retcode
                , p_number_of_workers
                );
EXCEPTION
	WHEN OTHERS THEN
       bis_collection_utilities.put_line(errbuf || '' || retcode ) ;
       fnd_message.set_name(  application => 'FND'
                           ,  name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                         token => 'ROUTINE'
                     ,   value => 'OKI_LOAD_TERR_PVT.initial_load ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
END initial_load;

/* This API will be called by Incremental Load Concurrent Program.
   It has three Parameters
   errbuf             : OUT parameter, Used to store the Error Information if
                        this API fails.
   retcode            : OUT parameter, Used to store the Error Code if
                        this API fails.
   p_worker_number    : IN parameter, gives information about
                        Number of workers to spawn. */
PROCEDURE incr_load ( errbuf  OUT NOCOPY VARCHAR2
                    , retcode OUT NOCOPY VARCHAR2
                    , p_number_of_workers IN NUMBER)
IS
BEGIN

g_load_type := 'INCR';

g_start_date        := fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('OKIJTFTERR'))
                               - 0.004;

g_end_date          := g_sysdate;

refresh_jtf_terr( errbuf
                , retcode
                , p_number_of_workers
                );
EXCEPTION
	WHEN OTHERS THEN
       bis_collection_utilities.put_line(errbuf || '' || retcode ) ;
       fnd_message.set_name(  application => 'FND'
                           ,  name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                         token => 'ROUTINE'
                     ,   value => 'OKI_LOAD_TERR_PVT.initial_load ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
		RAISE;
END incr_load;

/* This API is used to load Territory fact.
   This will be called by SubWorkers and not be Main Request.
   It has two Parameters
   p_worker_number    : IN parameter, gives information about worker_number
   x_rec_count        : OUT parameter, gives no of records updated in
                        territory fact table by this worker */
PROCEDURE load_jtf_terr ( p_worker_number IN NUMBER
                        , x_rec_count     OUT NOCOPY NUMBER) IS

  l_errpos             NUMBER;
  l_sql_string         VARCHAR2(4000);
  l_counter            NUMBER :=0;
  l_rec_count          NUMBER;
  l_use_type           VARCHAR2(30);
  l_msg_count          NUMBER;
  l_msg_data           NUMBER;
  x_winning_res_id     NUMBER;
  x_winning_ter_id     NUMBER;
  retcode              NUMBER;
  l_sqlcode            VARCHAR2(100);
  l_sqlerrm            VARCHAR2(1000);
  l_return_status      VARCHAR2(1);
  l_gen_bulk_Rec       JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
  l_gen_return_Rec     JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;

  l_no_update_refresh   EXCEPTION;
  l_sysdate             DATE;

-- Select Distinct  customer and authoring org id combinations from oki sales contracts headers table

  CURSOR get_org_customer_codes (l_worker_number NUMBER) IS
   select
        authoring_org_id
      , party_id
      , party_name
      , country_code
      , state_code
      , record_id
   from OKI_JTF_TERRITORIES_STG t
   where worker_number = l_worker_number
;

get_org_customer_codes_rec           get_org_customer_codes%ROWTYPE;

BEGIN
 l_errpos := 1;
 l_counter := 0;
 l_sysdate := sysdate;

FOR get_org_customer_codes_rec IN get_org_customer_codes(p_worker_number)
  LOOP

   --
   --For each combination of authoring_org and customer combination populate
   --JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type plsql table with the list of
   --party_name, state_code, country_code and party_id
   --

       l_gen_bulk_rec.trans_object_id.EXTEND;
       l_gen_bulk_rec.trans_detail_object_id.EXTEND;
       l_gen_bulk_rec.SQUAL_CHAR01.EXTEND;
       l_gen_bulk_rec.SQUAL_CHAR04.EXTEND;
       l_gen_bulk_rec.SQUAL_CHAR07.EXTEND;
       l_gen_bulk_rec.SQUAL_NUM01.EXTEND;

       l_counter                                         := l_counter + 1;

       l_gen_bulk_rec.trans_object_id(l_counter)         := get_org_customer_codes_rec.record_id ;
       l_gen_bulk_rec.trans_detail_object_id(l_counter)  := get_org_customer_codes_rec.authoring_org_id;
       l_gen_bulk_rec.SQUAL_CHAR01(l_counter)            := get_org_customer_codes_rec.party_name;
       l_gen_bulk_rec.SQUAL_CHAR04(l_counter)            := get_org_customer_codes_rec.state_code;
       l_gen_bulk_rec.SQUAL_CHAR07(l_counter)            := get_org_customer_codes_rec.country_code;
       l_gen_bulk_rec.SQUAL_NUM01(l_counter)             := get_org_customer_codes_rec.party_id;
       l_use_type                                        := 'RESOURCE';

  END LOOP;

--
-- Now, the l_gen_bulk_rec has been initialized with all the customer name, country code, state code
-- combinations.  We call the JTF API with this.
--
   BEGIN
   	 rlog('Calling JTF get_winners - ' || fnd_date.date_to_displayDT(SYSDATE),2);

      JTF_TERR_ASSIGN_PUB.get_winners
                   (  p_api_version_number       => 1.0
                   ,  p_init_msg_list            => OKC_API.G_FALSE
                   ,  p_use_type                 => l_use_type
                   ,  p_source_id                => -1500
                   ,  p_trans_id                 => -1501
                   ,  p_trans_rec                => l_gen_bulk_rec
                   ,  p_resource_type            => FND_API.G_MISS_CHAR
                   ,  p_role                     => FND_API.G_MISS_CHAR
                   ,  p_top_level_terr_id        => FND_API.G_MISS_NUM
                   ,  p_num_winners              => FND_API.G_MISS_NUM
                   ,  x_return_status            => l_return_status
                   ,  x_msg_count                => l_msg_count
                   ,  x_msg_data                 => l_msg_data
                   ,  x_winners_rec              => l_gen_return_rec
                   );

     rlog ('Get winners :: x_return_status : '|| l_return_status, 2);
     rlog ('Get Winners :: x_msg_count     : '|| l_msg_count, 2);
     rlog ('Get Winners :: x_msg_data      : '|| l_msg_data, 2);
     rlog ('Returned From JTF get_winners - ' || fnd_date.date_to_displayDT(SYSDATE),2);

   EXCEPTION
      WHEN OTHERS THEN
         rlog('Error in JTF_TERR_ASSIGN_PUB call ',1);
         RAISE;
   END;

   --FOR i IN l_gen_return_rec.trans_object_id.FIRST .. l_gen_return_rec.trans_object_id.LAST
   FOR i IN 1 .. l_gen_return_rec.trans_object_id.COUNT
   LOOP
      BEGIN
         UPDATE OKI_JTF_TERRITORIES_STG
         SET terr_id            = l_gen_return_rec.terr_id(i),
             resource_id        = l_gen_return_rec.resource_id(i)
         WHERE authoring_org_id = l_gen_return_rec.trans_detail_object_id(i)
         AND record_id          = l_gen_return_rec.trans_object_id(i);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END LOOP;

   rlog('Loading of table OKI_JTF_TERRITORIES using subworker '|| p_worker_number ||' started - '
        || fnd_date.date_to_displayDT(SYSDATE),2);

   IF(l_gen_return_rec.trans_object_id.FIRST IS NULL) THEN
         rlog('Empty output from jtf function call' , 2);
   ELSE
   	   IF g_load_type ='INIT' THEN

         INSERT INTO oki_jtf_territories
            (
              authoring_org_id
            , customer_party_id
            , terr_id
            , resource_id
            , creation_date
            , created_by
            , last_update_date
            , last_updated_by
            , last_update_login
            )
         SELECT
              authoring_org_id
            , party_id
            , terr_id
            , resource_id
            , l_sysdate
            , g_user_id
            , l_sysdate
            , g_user_id
            , g_login_id
         FROM OKI_JTF_TERRITORIES_STG
         WHERE worker_number = p_worker_number
           AND terr_id IS NOT NULL;

        ELSE

        	MERGE INTO oki_jtf_territories b
           USING
           ( SELECT   authoring_org_id
                    , party_id
                    , terr_id
                    , resource_id
              FROM OKI_JTF_TERRITORIES_STG
              WHERE worker_number = p_worker_number
              AND terr_id IS NOT NULL
           ) s
           ON
           (   b.authoring_org_id  = s.authoring_org_id
           AND b.customer_party_id = s.party_id
           )
           WHEN MATCHED THEN UPDATE SET
           	 terr_id             =   s.terr_id
           , resource_id         =   s.resource_id
           , last_update_date    =   l_sysdate
           , last_updated_by     =   g_user_id
           , last_update_login   =   g_user_id
           WHEN NOT MATCHED THEN
           INSERT
           (
             authoring_org_id
           , customer_party_id
           , terr_id
           , resource_id
           , creation_date
           , created_by
           , last_update_date
           , last_updated_by
           , last_update_login
           )
           VALUES
           (
             s.authoring_org_id
           , s.party_id
           , s.terr_id
           , s.resource_id
           , l_sysdate
           , g_user_id
           , l_sysdate
           , g_user_id
           , g_login_id
           );
       END IF;
       l_rec_count := SQL%ROWCOUNT;
        IF l_rec_count >= 0 THEN
         x_rec_count  := NVL(l_rec_count,0);
        ELSE
        	RAISE l_no_update_refresh;
        END IF;
        rlog('No of records inserted/updated in OKI_JTF_TERRITORIES table using subworker '
            || p_worker_number ||' - ' || x_rec_count,2);
        rlog('Loading of table OKI_JTF_TERRITORIES using subworker '|| p_worker_number ||' completed - '
            || fnd_date.date_to_displayDT(SYSDATE),2);
   END IF;

   COMMIT;

EXCEPTION
 WHEN OTHERS THEN
  retcode := 2;

  UPDATE OKI_DBI_WORKER_STATUS
       SET    status = 'FAILED'
       WHERE  object_name = 'OKI_JTF_TERRITORIES'
       AND    status = 'IN PROCESS'
       AND    worker_number = p_worker_number;
       COMMIT;

    rlog('Error in procedure load_jtf_worker : Error : ' || SQLERRM,2);
    RAISE;
END load_jtf_terr;


BEGIN
    g_global_start_date        :=  bis_common_parameters.get_global_start_date;
    g_4712_date                :=  fnd_conc_date.string_to_date('4712/01/01');
    g_sysdate                  :=  SYSDATE ;
    g_user_id                  :=  NVL(fnd_global.user_id, -1);
    g_login_id                 :=  NVL(fnd_global.login_id, -1);
    g_user_name                := 'OKI';
    g_table_owner              := 'OKI';
    IF NOT (FND_INSTALLATION.GET_APP_INFO('OKI', g_status, g_industry, g_oki_schema)) THEN
       fnd_file.put_line(  which => fnd_file.log
                         , buff  => 'Error while retrieving schema name for product OKI');
       RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);
    END IF;
END OKI_LOAD_TERR_PVT;

/
