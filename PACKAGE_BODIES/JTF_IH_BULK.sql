--------------------------------------------------------
--  DDL for Package Body JTF_IH_BULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_BULK" AS
/* $Header: JTFIHBKB.pls 120.7 2006/06/13 14:56:27 rdday noship $*/

-- profile option value that dictates stats data gathering and reporting
G_STATS_PROFILE_OPTION      VARCHAR2(30);
G_STATS_ENABLED             BOOLEAN      := FALSE;

-- the following package global variables are the easiest means of tracking them
-- across multiple procedures
G_XML_PARSE_TIME_TOTAL      NUMBER := 0;
G_XML_PARSE_TIME_MIN        NUMBER := 0;
G_XML_PARSE_TIME_MAX        NUMBER := 0;

G_INT_PROC_TIME_CUM         NUMBER := 0;
G_INT_PROC_TIME_MAX         NUMBER;
G_INT_PROC_TIME_MIN         NUMBER := 100000;
G_NUM_INT_TOTAL             NUMBER := 0;
G_NUM_INT_PROC_TOTAL        NUMBER := 0;
G_NUM_INT_MAX               NUMBER;
G_NUM_INT_MIN               NUMBER := 100000;

G_NUM_ACT_TOTAL             NUMBER := 0;
G_NUM_ACT_MAX               NUMBER;
G_NUM_ACT_MIN               NUMBER := 100000;

G_NUM_MED_TOTAL             NUMBER := 0;
G_NUM_MED_MAX               NUMBER;
G_NUM_MED_MIN               NUMBER := 100000;

-- for now these are not being tracked
g_num_mlcs_total            NUMBER := 0;
g_num_mlcs_max              NUMBER;
g_num_mlcs_min              NUMBER := 100000;

-- globally used in the package
G_DATE_FORMAT       CONSTANT VARCHAR2(50) := 'MON DD RRRR HH24:MI:SS';
G_GMT_TZ            CONSTANT NUMBER       := 0; -- GMT is 0
G_SERVER_TZ                  NUMBER;
G_CONC_REQUEST_ID            NUMBER;
G_CONC_PROGRAM_ID            NUMBER;
G_PROG_APPL_ID               NUMBER;
G_USER_ID                    NUMBER;
G_LOGIN_ID                   NUMBER;
G_USE_STDOUT                 BOOLEAN      := FALSE;
l_fnd_log_msg     VARCHAR2(2000);

-- moved here to track heart-beat across package
g_hrt_beat          NUMBER;

--
-- Strictly a convenience function to convert and return the input GMT time
-- as a db server time. Does nothing but call an HZ provided procedure.
--
FUNCTION SERVER_DATE_FROM_GMT_STR
(
  p_gmt_date_str IN VARCHAR2
) RETURN DATE IS

  l_gmt_date    DATE;
  l_server_date DATE;
  l_ret_status  VARCHAR2(5);
  l_msg_count   NUMBER;
  l_msg_data    VARCHAR2(2000);

BEGIN

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'FUNCTION SERVER_DATE_FROM_GMT_STR In Parameters'||
	      	     'p_gmt_date_str  = '|| p_gmt_date_str;
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.SERVER_DATE_FROM_GMT_STR.begin', l_fnd_log_msg);
  END IF;

  IF (p_gmt_date_str IS NULL) THEN
    RETURN NULL;
  END IF;

  l_gmt_date := TO_DATE(p_gmt_date_str, G_DATE_FORMAT);

  HZ_TIMEZONE_PUB.GET_TIME(P_API_VERSION      => 1.0,
                           P_INIT_MSG_LIST    => FND_API.G_FALSE,
                           P_SOURCE_TZ_ID     => G_GMT_TZ,
                           P_DEST_TZ_ID       => G_SERVER_TZ,
                           P_SOURCE_DAY_TIME  => l_gmt_date,
                           X_DEST_DAY_TIME    => l_server_date,
                           X_RETURN_STATUS    => l_ret_status,
                           X_MSG_COUNT        => l_msg_count,
                           X_MSG_DATA         => l_msg_data);

  -- what do you do if the time cannot be coverted ?!
  -- take the time as it is given to be server time
  IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
    NULL;
    l_server_date := l_gmt_date;
  END IF;

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'FUNCTION SERVER_DATE_FROM_GMT_STR Return Parameter'||
     	      	       'l_server_date  = '|| l_server_date;
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.SERVER_DATE_FROM_GMT_STR.end', l_fnd_log_msg);
  END IF;

  RETURN l_server_date;

END SERVER_DATE_FROM_GMT_STR;


-- Main procedure of this package. It is run as a concurrent program.
PROCEDURE BULK_PROCESSOR_CONC
(
  errbuf  OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2
) IS

  deq_options     dbms_aq.dequeue_options_t;
  deq_del_option  dbms_aq.dequeue_options_t;
  msg_props       dbms_aq.message_properties_t;
  bulk_obj        system.ih_bulk_type;
  l_dummy_payload system.ih_bulk_type;
  l_dummy_msg_id  RAW(16);
  l_msg_id        RAW(16);
  num_rec         NUMBER;
  l_ret_status    VARCHAR2(1);

  l_stats_profile_value varchar2(5);

  average         number(20, 2);
  l_not_eof       BOOLEAN;
  t1_beg          NUMBER;
  t1_end          NUMBER;
  t2_beg          NUMBER;
  t2_end          NUMBER;
  t3_beg          NUMBER;
  t3_end          NUMBER;
  l_time_onerec   NUMBER := 0;
  l_time_cum      NUMBER := 0;
  l_time_max      NUMBER;     -- these two values need to be such that
  l_time_min      NUMBER := 100000; -- they are easily reset.
  error           NUMBER;
  errm            VARCHAR2(2000);
  saved_bulk_obj  system.IH_BULK_TYPE;

  aq_eof          EXCEPTION;
  pragma EXCEPTION_INIT    (aq_eof, -25228);

  -- Bug3781768- Perf fix for literal usuage
  l_msg_id_perf   RAW (16);

BEGIN
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  l_fnd_log_msg := 'BULK_PROCESSOR_CONC Begin:';
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
  'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC.begin', l_fnd_log_msg);
END IF;

  -- global variables initialization to remove GSCC warnings
--  G_STATS_PROFILE_OPTION := 'JTF_IH_BULK_STATS_ENABLED';
  G_INT_PROC_TIME_MAX := -1;
  G_NUM_INT_MAX := -1;
  G_NUM_ACT_MAX := -1;
  G_NUM_MED_MAX := -1;
  g_num_mlcs_max := -1;
  G_USER_ID := FND_GLOBAL.USER_ID;
  G_LOGIN_ID := FND_GLOBAL.LOGIN_ID;

  -- local variables initialization to remove GSCC warnings
  l_time_max := -1;

  -- To do -
  -- (Relatively straight forward process to begin with.)
  -- Check if we need to recover from a crash
  -- (new step added for recovering from crashes)
  -- Get first message from queue.
  -- process it.
  -- if more available, repeat process; else done.

  -- check if we have to gather stats or not
  /*l_stats_profile_value := FND_PROFILE.VALUE(G_STATS_PROFILE_OPTION);
  IF (l_stats_profile_value = 'Y' OR l_stats_profile_value = 'y') THEN
    G_STATS_ENABLED := TRUE;
  END IF;*/

  --IF (g_stats_enabled) THEN
    t2_beg := DBMS_UTILITY.GET_TIME;
  --END IF;

  -- get server tz value, it is required to transform the start and end date
  -- time values from gmt. default to GMT if server time zone is not set.
  G_SERVER_TZ := FND_PROFILE.VALUE('SERVER_TIMEZONE_ID');
  IF (G_SERVER_TZ IS NULL) THEN

    --FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_NO_TZ');
    --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);


  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_NO_TZ');
    FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
    		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', TRUE);
  END IF;
    G_SERVER_TZ := 0;

  END IF;


  -- retrieve and save some global values for use throughout
  -- N O T E - all the following values will be -1 when run in command line mode
  G_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
  G_USER_ID         := FND_GLOBAL.USER_ID;
  G_LOGIN_ID        := FND_GLOBAL.LOGIN_ID;
  G_CONC_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
  G_PROG_APPL_ID    := FND_GLOBAL.PROG_APPL_ID;

  -- All the FND_GLOBAL values are -1 if this program is run in command line
  -- mode. Some of the values are important for recovery and such, so they are
  -- being taken care of.
  IF (G_CONC_REQUEST_ID = -1) THEN
    SELECT DBMS_UTILITY.get_time INTO G_CONC_REQUEST_ID FROM dual;
  END IF;

  IF (G_CONC_PROGRAM_ID = -1) THEN
    G_CONC_PROGRAM_ID := G_CONC_REQUEST_ID;
  END IF;

  IF (G_USER_ID = -1) THEN
    SELECT UID INTO G_USER_ID FROM dual;
  END IF;

  -- Before we get to regular programming, check if any crash recovery needs to
  -- be done.
  PERFORM_CRASH_RECOVERY();

  -- Before beginning to process records from AQ, create a record in the
  -- recovery table. This record will keep getting updated as bulk records
  -- get processed. It will be deleted before this routine ends.

  -- Perf fix for literal usuage
  l_msg_id_perf := '0';

  INSERT INTO jtf_ih_bulk_recovery
  ( recovery_id, request_id, msg_id, bulk_interaction_request,
    num_int_processed, created_by, creation_date, last_updated_by,
    last_update_date, last_update_login, program_id, program_application_id,
    program_update_date)
  VALUES
  (jtf_ih_bulk_recovery_s1.nextval, G_CONC_REQUEST_ID, l_msg_id_perf,
   EMPTY_CLOB(), null, G_USER_ID, sysdate, G_USER_ID, sysdate, G_LOGIN_ID,
   G_CONC_REQUEST_ID, G_PROG_APPL_ID, sysdate);

  g_hrt_beat := -50;
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Created row in recovery table');

  -- dequeue options
  -- dequeue mode shall be LOCKED for now, the data will get deleted after
  -- saving in RECOVERY table
  deq_options.dequeue_mode := dbms_aq.LOCKED;
  deq_options.navigation := dbms_aq.NEXT_MESSAGE;
  deq_options.wait := dbms_aq.NO_WAIT;

  -- these are the options for the second dequeue
  deq_del_option.dequeue_mode := dbms_aq.REMOVE_NODATA;
  deq_del_option.wait := dbms_aq.NO_WAIT;

  num_rec := 0;

  --LOOP
  l_not_eof := TRUE;
  WHILE l_not_eof LOOP

    BEGIN

      -- this is being done so that the exception handler way down below can
      -- log any bulk requests that are fetched but not processed
      l_msg_id := null;

      DBMS_AQ.DEQUEUE (
         queue_name          => 'JTF_IH_BULK_Q',
         dequeue_options     => deq_options,
         message_properties  => msg_props,
         payload             => bulk_obj,
         msgid               => l_msg_id);

      IF (g_stats_enabled) THEN
        t1_beg := DBMS_UTILITY.GET_TIME;
      END IF;

      -- Turns out, at least during testing, that the clob can be empty
      IF (DBMS_LOB.GETLENGTH(bulk_obj.bulkInteractionRequest) > 0) THEN
        -- before beginning to process the bulk record, save it in the recovery
        -- table
        g_hrt_beat := -51;
        SELECT user_data INTO saved_bulk_obj
        FROM jtf_ih_bulk_qtbl
        WHERE msgid = l_msg_id;

        g_hrt_beat := -51.50;
        UPDATE jtf_ih_bulk_recovery
        SET
          bulk_writer_code = saved_bulk_obj.bulkWriterCode,
          bulk_batch_type = saved_bulk_obj.bulkBatchType,
          bulk_batch_id = saved_bulk_obj.bulkBatchId,
          bulk_interaction_id = saved_bulk_obj.bulkInteractionId,
          bulk_interaction_request = saved_bulk_obj.bulkInteractionRequest,
          msg_id = l_msg_id,
          last_update_date = sysdate,
          program_update_date = sysdate
        WHERE request_id = G_CONC_REQUEST_ID;

        g_hrt_beat := -51.60;

        -- Now delete the row from AQ
        deq_del_option.msgid := l_msg_id;

        DBMS_AQ.DEQUEUE (
           queue_name          => 'JTF_IH_BULK_Q',
           dequeue_options     => deq_del_option,
           message_properties  => msg_props,
           payload             => l_dummy_payload,
           msgid               => l_dummy_msg_id);

        g_hrt_beat := -52;
        COMMIT WORK;

        g_hrt_beat := -53;
        --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Updated row in recovery table and removed from AQ');

        -- process payload data
        l_ret_status := PROCESS_BULK_RECORD(bulk_obj.bulkWriterCode,
                                            bulk_obj.bulkBatchType,
                                            bulk_obj.bulkBatchId,
                                            bulk_obj.bulkInteractionRequest);

        g_hrt_beat := -54;
        --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Process_record returned - ' || l_ret_status);
      ELSE

        g_hrt_beat := -51;

        -- Now delete row from AQ
        deq_del_option.msgid := l_msg_id;

        DBMS_AQ.DEQUEUE (
           queue_name          => 'JTF_IH_BULK_Q',
           dequeue_options     => deq_del_option,
           message_properties  => msg_props,
           payload             => l_dummy_payload,
           msgid               => l_dummy_msg_id);

        g_hrt_beat := -52;
        COMMIT WORK;

        g_hrt_beat := -53;

	-- logging High Level: Found a bulk request of zero length
        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ZERO_LEN_REQ');
        FND_MESSAGE.SET_TOKEN('WRITER_CODE', bulk_obj.bulkWriterCode);
        FND_MESSAGE.SET_TOKEN('BATCH_TYPE', bulk_obj.bulkBatchType);
        FND_MESSAGE.SET_TOKEN('BATCH_ID', bulk_obj.bulkBatchId);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);


              -- logging Detail Level: Found a bulk request of zero length
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	   FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ZERO_LEN_REQ');
	   FND_MESSAGE.SET_TOKEN('WRITER_CODE', bulk_obj.bulkWriterCode);
	   FND_MESSAGE.SET_TOKEN('BATCH_TYPE', bulk_obj.bulkBatchType);
           FND_MESSAGE.SET_TOKEN('BATCH_ID', bulk_obj.bulkBatchId);
	   FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
	  		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', TRUE);
	END IF;

      END IF;

        t1_end := DBMS_UTILITY.GET_TIME;

        -- processing times - one record, maximum, minimum and cumulative
        l_time_onerec := (t1_end-t1_beg)*10;

        IF (l_time_onerec > l_time_max) THEN
          l_time_max := l_time_onerec;
        END IF;

        IF (l_time_onerec < l_time_min) THEN
          l_time_min := l_time_onerec;
        END IF;

        l_time_cum := l_time_cum + l_time_onerec;
        g_hrt_beat := -55;

      --Logging Detail Level
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      	   l_fnd_log_msg := 'Time taken to process one record = '|| l_time_onerec ||
      	                    ', writer code = ' || bulk_obj.bulkWriterCode ||
                            ', batch type = ' || bulk_obj.bulkBatchType   ||
                            ', batch id = ' || bulk_obj.bulkBatchId;
      	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      	  		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', l_fnd_log_msg);
      END IF;

      num_rec := num_rec + 1;

      EXCEPTION
        WHEN aq_eof THEN

          -- this error is ok, we just ran out of records in the aq
          l_not_eof := FALSE;

          -- logging Detail Level: End of records in Advanced Queue
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_AQ_EOF');
	    FND_MESSAGE.SET_TOKEN('NUM_REC', num_rec);
	    FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
	  	  		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', TRUE);
	  END IF;

	  -- logging High Level: End of records in Advanced Queue
          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_AQ_EOF');
          FND_MESSAGE.SET_TOKEN('NUM_REC', num_rec);
	  FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          -- output this irrespective of stats flag so that there is some
          -- indication of work done.

          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_AQ_EOF');
          FND_MESSAGE.SET_TOKEN('NUM_REC', num_rec);
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_NUM_REC_PROC');
          FND_MESSAGE.SET_TOKEN('NUM_REC', num_rec);
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_NUM_TOTAL_INT');
          FND_MESSAGE.SET_TOKEN('NUM_INT', G_NUM_INT_TOTAL);
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_NUM_OK_INT');
          FND_MESSAGE.SET_TOKEN('NUM_INT', G_NUM_INT_PROC_TOTAL);
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_NUM_ERR_INT');
          FND_MESSAGE.SET_TOKEN('NUM_INT', (G_NUM_INT_TOTAL-G_NUM_INT_PROC_TOTAL));
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

        WHEN OTHERS THEN
          RAISE;
    END;
  END LOOP;

  -- We are done processing bulk records, now get rid of the record in the
  -- recovery table
  DELETE FROM jtf_ih_bulk_recovery
  WHERE request_id = G_CONC_REQUEST_ID;

  -- crazy, but if more than one record is ever deleted here something bad is
  -- going on - so log the error (and don't commit ?)
  IF (SQL%ROWCOUNT > 1) THEN

    -- High level logging:The number of records deleted from
    -- the recovery table during cleanup is not 1 as expected
    FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_RECOV_DEL_WARN');
    FND_MESSAGE.SET_TOKEN('ROW_COUNT', SQL%ROWCOUNT);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

    IF( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_RECOV_DEL_WARN');
      FND_MESSAGE.SET_TOKEN('ROW_COUNT', SQL%ROWCOUNT);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
      		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', TRUE);
    END IF;

  ELSE
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Deleted row from recovery table.');
    COMMIT;
  END IF;


    t2_end := DBMS_UTILITY.GET_TIME;

    --Logging Detail Level
    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'Cumulative counts - ' ||
                       'Total time taken for this run     - ' || (t2_end-t2_beg)*10 ||
                       ', Total number of records processed - ' || num_rec   ||
                       ', Total processing time             - ' || l_time_cum ||
                       ', Total xml parse time              - ' || G_XML_PARSE_TIME_TOTAL ||
                       ', Total interaction processing time - ' || G_INT_PROC_TIME_CUM ||
                       ', Total number of interactions      - ' || G_NUM_INT_TOTAL ||
                       ', Total successfull interactions    - ' || G_NUM_INT_PROC_TOTAL ||
                       ', Total number of activities        - ' || G_NUM_ACT_TOTAL ||
                       ', Total number of media items       - ' || G_NUM_MED_TOTAL;
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', l_fnd_log_msg);
    END IF;

    --Logging Detail Level
    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'Maximums and minimums - ' ||
                       'Maximum record processing time - ' || l_time_max ||
                       ', Minimum record processing time - ' || l_time_min   ||
                       ', Maximum xml parse time - ' || G_XML_PARSE_TIME_MAX ||
                       ', Minimum xml parse time - ' || G_XML_PARSE_TIME_MIN ||
                       ', Maximum interaction processing time - ' || G_INT_PROC_TIME_MAX ||
                       ', Minimum interaction processing time - ' || G_INT_PROC_TIME_MIN ||
                       ', Maximum number of interactions per request - ' || G_NUM_INT_MAX ||
                       ', Minimum number of interactions per request - ' || G_NUM_INT_MIN ||
                       ', Maximum number of activities per interactions - ' || G_NUM_ACT_MAX ||
                       ', Minimum number of activities per interactions - ' || G_NUM_ACT_MIN ||
                       ', Maximum number of media items per interactions - ' || G_NUM_MED_MAX ||
                       ', Minimum number of media items per interactions - ' || G_NUM_MED_MIN;
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', l_fnd_log_msg);
    END IF;

    IF (num_rec > 0) THEN
      average := l_time_cum/num_rec;

      --Logging Detail Level
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          l_fnd_log_msg := 'Averages - ' ||
                           'Average record processing time - ' || average;
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
         		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', l_fnd_log_msg);
       END IF;
    END IF;


    IF (G_NUM_INT_PROC_TOTAL > 0) THEN
      --Logging Detail Level
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        l_fnd_log_msg := 'Average interaction processing time - ' ||
                         G_INT_PROC_TIME_CUM/G_NUM_INT_PROC_TOTAL;
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
              	'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', l_fnd_log_msg);
      END IF;
    END IF;


  -- everything ought to have been OK for us to reach this point
  -- set return values accordingly
  -- per documentation - The parameter retcode returns 0 for success,
  --                     1 for success with warnings, and 2 for error.
  retcode := '0';
  errbuf := FND_MESSAGE.GET_STRING('JTF', 'JTF_IH_BULK_OK');

  FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'PROCESS_BULK_RECORD Out parameters :'||
                         ', errbuf       = '|| errbuf ||
                         ', retcode     = '|| retcode;
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC.end', l_fnd_log_msg);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      DECLARE
        errm VARCHAR2(2000);
      BEGIN

        errm := SQLERRM;
        IF (errm IS NULL) THEN
          errm := FND_MESSAGE.GET_STRING('JTF', 'JTF_IH_BULK_NOERRM');
        END IF;

        LOG_EXC_OTHERS('BULK_PROCESSOR_CONC');

        -- error table before we bye-bye
        /*IF (msg_id IS NOT NULL) THEN
          NULL;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'payload ought to go into errors ,msg_id = ' || l_msg_id);
          -- stick message into errors
        END IF;*/

        retcode := '2';

        FND_MESSAGE.set_name('JTF', 'JTF_IH_BULK_FAIL');


        FND_MESSAGE.set_token('ERR_MSG', SQLERRM);
        errbuf := FND_MSG_PUB.GET();
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);

        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      	  l_fnd_log_msg := errbuf;
      	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      	        'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC', l_fnd_log_msg);
      	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
       	   		'jtf.plsql.JTF_IH_BULK.BULK_PROCESSOR_CONC',errbuf);
        END IF;

     END;

END BULK_PROCESSOR_CONC;

--
-- Function to process a single bulk record.
--
-- Description - Processes the input bulk interaction record. The optional
--               parameter allows processing to start at some offset besides the
--               beginning in the list of interactions.
--
-- Parameters
--
-- p_bulk_writer_code          IN VARCHAR2  bulk writer code
-- p_bulk_batch_type           IN VARCHAR2  batch type
-- p_bulk_batch_id             IN NUMBER    batch id
-- p_bulk_interaction_request  IN CLOB      interaction request itself, xml doc
-- p_int_offset                IN  NUMBER   optional offset value to not process all
--                                          interactions in the bulk record
--
--
FUNCTION PROCESS_BULK_RECORD
(
  p_bulk_writer_code          IN VARCHAR2,
  p_bulk_batch_type           IN VARCHAR2,
  p_bulk_batch_id             IN NUMBER,
  p_bulk_interaction_request  IN CLOB,
  p_int_offset                IN NUMBER DEFAULT 0
) RETURN VARCHAR2 IS
  xml_p               dbms_xmlparser.parser;
  xml_doc             dbms_xmldom.DOMDocument;
  int_rec             JTF_IH_PUB.INTERACTION_REC_TYPE;
  int_nl              dbms_xmldom.DOMNodeList;
  int_node            dbms_xmldom.DOMNode;
  int_elem            dbms_xmldom.DomElement;
  med_nl              dbms_xmldom.DOMNodeList;
  med_id_tbl          media_id_trkr_type;
  num_int             NUMBER;
  num_med             NUMBER;
  num_act             NUMBER;
  act_nl              dbms_xmldom.DOMNodeList;
  act_tbl             JTF_IH_PUB.ACTIVITY_TBL_TYPE;

  -- local variables
  l_resource_id         NUMBER;
  l_user_id             NUMBER;
  l_bulk_interaction_id NUMBER;
  l_num_int_done        NUMBER;
  l_commit_int_num      NUMBER;
  l_ret_status          varchar2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_error               VARCHAR2(30);
  l_err_msg             VARCHAR2(2000);
  l_ret_msg             VARCHAR2(2000);
  t1_beg                NUMBER;
  t1_end                NUMBER;
  l_parse_time          NUMBER;
  l_int_proc_time       NUMBER;
  L_BLANK               VARCHAR2(1);
  L_COMMIT_THRESHOLD    NUMBER := 100;
  l_error_msgLOG        VARCHAR2(2000);

  processing_error      EXCEPTION;
BEGIN

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'FUNCTION PROCESS_BULK_RECORD In parameters :'||
                     'p_bulk_writer_code           = '|| p_bulk_writer_code ||
                     ', p_bulk_batch_type          = '|| p_bulk_batch_type ||
                     ', p_bulk_batch_id            = '|| p_bulk_batch_id||
                     ', p_bulk_interaction_request = '|| p_bulk_interaction_request ||
                     ', p_int_offset               = '|| p_int_offset;
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
         'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD.begin', l_fnd_log_msg);
  END IF;

  -- local variables initialization to remove GSCC warnings
  l_num_int_done := -1;
  l_commit_int_num := -1;
  l_ret_msg := '';
  L_BLANK := '';

  -- optimistic
  l_ret_status := FND_API.G_RET_STS_SUCCESS;

  g_hrt_beat := 1;

  -- savepoint to roll back any work done for this bulk record
  SAVEPOINT BULK_RECORD;

  -- get new parser instance
  xml_p := dbms_xmlparser.newParser();

  -- set parser attributes
  dbms_xmlparser.setValidationMode(xml_p, FALSE);
  -- Bug fix 3812373. Commenting out set error log not needed.
  -- dbms_xmlparser.setErrorLog(xml_p, '/tmp/msistaXmlErrors.txt');

  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Calling ParseClob');

  -- parse the bulk record clob

    g_hrt_beat := 1.5;
    -- Start debug code for bad XML
    BEGIN

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      	   		'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', 'Calling ParseClob');
       END IF;
       dbms_xmlparser.parseClob(xml_p, p_bulk_interaction_request);
    EXCEPTION
      WHEN OTHERS THEN
       DECLARE
         errm VARCHAR2(2000);
       BEGIN
         errm := SQLERRM;
         IF (errm IS NULL) THEN
           errm := 'No Error Message in SQLERRM for parsing errors';
         END IF;
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Message: ' || errm );
         IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
       	   		'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD',errm);
         END IF;
         l_ret_status := FND_API.G_RET_STS_ERROR;
       END;
    END;

  --IF (g_stats_enabled) THEN
    t1_beg := DBMS_UTILITY.GET_TIME;
  --END IF;


  --IF (g_stats_enabled) THEN
    t1_end := DBMS_UTILITY.GET_TIME;
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Parse returned.');
    l_parse_time := ((t1_end-t1_beg)*10);

    g_hrt_beat := 1.6;
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Time taken for Parse - ' || l_parse_time);

    -- globally tracked parse time
    G_XML_PARSE_TIME_TOTAL := G_XML_PARSE_TIME_TOTAL + l_parse_time;
    IF (l_parse_time < G_XML_PARSE_TIME_MIN) THEN
      G_XML_PARSE_TIME_MIN := l_parse_time;
    END IF;
    IF (l_parse_time > G_XML_PARSE_TIME_MAX) THEN
      G_XML_PARSE_TIME_MAX := l_parse_time;
    END IF;
  --END IF;

  -- the parse call above would have build the xml document in memory.
  -- the job now is to get the individual elements out of the document and
  -- process them with the regular IH public API.
  g_hrt_beat := 1.7;
  xml_doc := dbms_xmlparser.getDocument(xml_p);

  g_hrt_beat := 2;

  -- To do -
  --
  -- a. get all interaction nodes
  -- b. for each interaction node -
  /*   1. convert interaction node to a document
          i. get all Media nodes from this doc.
          ii.for each media node
            a. get childNodes (they would be MLCS)
            b. for each mlcs node, create a mlcs record and accumulate
            c. get attributes of media node
            d. if MEDIA_ID value is not set for the media item,
               call JTF_IH_PUB.Create_MediaItem with the attributes and mlcs
            e. if MEDIA_ID is already set, call the Add_MediaLifeCycle and
               Close_MediaItem methods
            f. keep track of mediaitem_identifier to media_id values
         iii.get all Activity nodes from this doc now.
          iv.for each activity node
            a.gather each activity's attrs, incl media_id using the mapping from
              b.1.ii.e
            b.create a Activity record and save
       2. gather all interaction attributes
       3. call JTF_IH_PUB.Create_Interaction using attr and activity records
       4. release the interaction document resource.
     c. any errors in recording an interatn will result in logging the interactn
        to the error table.
     d. clean up and return.
  */

  -- a. get all interaction nodes
  int_nl := dbms_xmldom.getElementsByTagName(xml_doc, 'INTERACTION');
  num_int := dbms_xmldom.getLength(int_nl);

  g_hrt_beat := 3;
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '# of interactions in req = ' || num_int);

  -- keep track of interactions processed for use in logging
  l_num_int_done := 0;

  -- b. for each interaction node -
  /*   1. convert interaction node to a document
          i. get all Media nodes from this doc.
          ...
         iii.get all Activity nodes from this doc now.
         ...
       2. gather all interaction attributes
       3. call JTF_IH_PUB.Create_Interaction using attr and activity records
  */
  FOR i IN p_int_offset..num_int-1 LOOP
    l_error_msgLOG := '';
    BEGIN -- dummy block

      g_hrt_beat := 3.4;

      SAVEPOINT BEGIN_INTERACTION;

      g_hrt_beat := 3.41;

      IF (g_stats_enabled) THEN
        t1_beg := DBMS_UTILITY.GET_TIME;
      END IF;

      g_hrt_beat := 3.42;

      -- blank out any previous errors
      l_error := L_BLANK;
      l_ret_msg := '';

      --dbms_output.new_line();
      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '---------------');
      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'begin INT loop iteration # - ' || i);

      g_hrt_beat := 3.5;

      int_node := dbms_xmldom.item(int_nl, i);

      g_hrt_beat := 4;

      --1. convert interaction node to a document as well as a doc element
      int_elem := dbms_xmldom.makeElement(int_node);
      l_bulk_interaction_id := dbms_xmldom.getAttribute(int_elem, 'bulk_interaction_id');

      -- extract the resource id from the interaction element and get its user_id
      -- we will use the resource's user id for all ih entities of this interaction
      l_resource_id := dbms_xmldom.getAttribute(int_elem, 'resource_id');

      BEGIN
        SELECT user_id INTO l_user_id
        FROM jtf_rs_resource_extns
        WHERE resource_id = l_resource_id AND
              ( end_date_active IS NULL OR
                TRUNC(end_date_active) >= TRUNC(SYSDATE) );

        -- if the resource_id is not valid, don't attempt logging this interaction
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_INVALID_RESOURCE_ID');
	              FND_MESSAGE.SET_TOKEN('RESOURCE_ID', l_resource_id);
          l_error_msgLOG := FND_MESSAGE.GET;

          --Logging Detail Level
          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             l_fnd_log_msg := l_error_msgLOG;
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	  	  		'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', l_fnd_log_msg);
	  END IF;
          RAISE processing_error;
      END;


      --i. get all Media nodes from this doc.
      med_nl := dbms_xmldom.getChildrenByTagName(int_elem, 'MEDIAITEM');
      num_med := dbms_xmldom.getLength(med_nl);

      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '# of media_items in int req num ' || i || ' = ' || num_med);

      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'BULK_INTERACTION_ID = ' || l_bulk_interaction_id);

      g_hrt_beat := 5;

      -- delegate media node processing
      IF (num_med > 0) THEN
        PROCESS_MEDIA_ITEMS(med_nl, l_bulk_interaction_id, p_bulk_writer_code,
                            p_bulk_batch_type, p_bulk_batch_id, l_user_id, med_id_tbl,
                            l_ret_status, l_ret_msg);
        IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_error := 'JTF_IH_BULK_MEDIA_FAIL';
          --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_error || ', ' || l_ret_msg);
          l_error_msgLOG := l_ret_msg;
          RAISE processing_error;
          -- raise exception or otherwise handle this
        ELSE
          NULL;
          --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'PROCESS_MEDIA_ITEM returned OK');
        END IF;
      END IF;

      g_hrt_beat := 6;

      -- Media is done, now the activity records
      --    iii.get all Activity nodes from this doc now.
      --    iv. for each activity node
      --      a.gather each activity's attributes, including media_id using the
      --        mapping from b.1.ii.e
      --      b.create a Activity record and save
      act_nl := dbms_xmldom.getChildrenByTagName(int_elem, 'ACTIVITY');
      num_act := dbms_xmldom.getLength(act_nl);

      g_hrt_beat := 7;

      -- delegate the activity processing
      IF (num_act > 0) THEN
        GATHER_ACT_TBL(act_nl, l_bulk_interaction_id, p_bulk_writer_code,
                       p_bulk_batch_type, p_bulk_batch_id, med_id_tbl,
                       act_tbl, l_ret_status, l_ret_msg);

        IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_error := 'JTF_IH_BULK_ACT_FAIL';

          --Logging Detail Level
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ACT_FAIL');
	    FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
	  	'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', TRUE);
	  END IF;

          l_error_msgLOG := l_ret_msg;
          RAISE processing_error;
        END IF;
      END IF;

      g_hrt_beat := 8;

      -- media nodes are done and we have gathered activities,
      -- if there were no errors, we would be here so process the interaction now
      --2. gather all interaction attributes
      --3. call JTF_IH_PUB.Create_Interaction using attr and activity records
      GATHER_INT_ATTR(int_elem, l_bulk_interaction_id, p_bulk_writer_code,
                      p_bulk_batch_type, p_bulk_batch_id, int_rec,
                      l_ret_status, l_ret_msg);

        IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_error := 'JTF_IH_BULK_ACT_FAIL';
          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_INT_FAIL');
          l_ret_msg := FND_MESSAGE.GET ||' '|| l_ret_msg;
          --FND_FILE.PUT_LINE(FND_FILE.LOG, l_ret_msg);
          l_error_msgLOG := l_ret_msg;
          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    l_fnd_log_msg := l_ret_msg;
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	    		'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', l_fnd_log_msg);
	  END IF;
          RAISE processing_error;
        END IF;


      -- the above routine only does a bunch of dbms_xmldom.getAttribute() calls to
      -- gather all attributes of the interaction; as such there is no error
      -- catching or processing in the routine.
      --
      -- if and when it changes there will need to be some code here to check
      -- and log any errors.

      g_hrt_beat := 9;

      JTF_IH_PUB.Create_Interaction(p_api_version     => 1.0,
                                    p_init_msg_list   => FND_API.G_TRUE,
                                    p_commit          => FND_API.G_FALSE,
                                    p_user_id         => l_user_id,
                                    x_return_status   => l_ret_status,
                                    x_msg_count       => l_msg_count,
                                    x_msg_data        => l_msg_data,
                                    p_interaction_rec => int_rec,
                                    p_activities      => act_tbl);

      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Create_Interaction returned - ' || l_ret_status);
      IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_error := 'JTF_IH_BULK_INT_FAIL';
        --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_error || ', msg_count = ' || l_msg_count);

        --Logging Detail Level
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	   FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_INT_FAIL2');
	   FND_MESSAGE.SET_TOKEN('RTN_NAME', 'Create_Interaction');
           FND_MESSAGE.SET_TOKEN('MSG_COUNT', l_msg_count);
	   FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
	 	'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', TRUE);
	END IF;

        FOR i in 1..l_msg_count LOOP
          l_msg_data := FND_MSG_PUB.Get(i, 'F');
	  FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ERROR_MSG');
          FND_MESSAGE.SET_TOKEN('MSG_NUM', i);
          FND_MESSAGE.SET_TOKEN('MSG_TXT', l_msg_data);
          l_error_msgLOG := l_error_msgLOG ||' '|| FND_MESSAGE.GET;
          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            l_fnd_log_msg := l_error_msgLOG;
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	  	'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', l_error_msgLOG);
	  END IF;

          --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Message number - ' || i || ', is - ' || l_msg_data);
          l_ret_msg := l_ret_msg ||
            SUBSTRB(l_msg_data, 0, (2000-LENGTHB(l_ret_msg))) || ' ';
        END LOOP;

        RAISE processing_error;
      END IF;

      g_hrt_beat := 10;

      -- commit interactions if necessary
      IF ( MOD(i,L_COMMIT_THRESHOLD) = 0) THEN

        l_commit_int_num := i;

        -- update the crash recovery table too
        UPDATE jtf_ih_bulk_recovery
        SET num_int_processed = l_commit_int_num,
            last_update_date = sysdate,
            program_update_date = sysdate
        WHERE request_id = G_CONC_REQUEST_ID;

        COMMIT WORK;

      END IF;
      -- increment number of interactions processed
      l_num_int_done := l_num_int_done+1;

      --IF (g_stats_enabled) THEN
        t1_end := DBMS_UTILITY.GET_TIME;

        l_int_proc_time := (t1_end - t1_beg)*10;

        -- this is being done here so that interactions without errors are the
        -- only ones tallied for these times
        G_INT_PROC_TIME_CUM := G_INT_PROC_TIME_CUM + l_int_proc_time;

        IF (l_int_proc_time < G_INT_PROC_TIME_MIN) THEN
          G_INT_PROC_TIME_MIN := l_int_proc_time;
        END IF;

        IF (l_int_proc_time > G_INT_PROC_TIME_MAX) THEN
          G_INT_PROC_TIME_MAX := l_int_proc_time;
        END IF;

        -- activity tallying
        G_NUM_ACT_TOTAL := G_NUM_ACT_TOTAL + num_act;

        IF (num_act > G_NUM_ACT_MAX ) THEN
          G_NUM_ACT_MAX := num_act;
        END IF;

        IF (num_act < G_NUM_ACT_MIN ) THEN
          G_NUM_ACT_MIN := num_act;
        END IF;

        -- media items tallying
        G_NUM_MED_TOTAL := G_NUM_MED_TOTAL + num_act;

        IF (num_act > G_NUM_MED_MAX ) THEN
          G_NUM_MED_MAX := num_act;
        END IF;

        IF (num_act < G_NUM_MED_MIN ) THEN
          G_NUM_MED_MIN := num_act;
        END IF;
      --END IF;

      -- exception block to catch errors, practice is to log the current int. in
      -- the bulk errors table and carry on. unknown errors will use SQLERRM for
      -- error message
      EXCEPTION
        -- the idea is to carry on with the other remaining interactions in the
        -- bulk request.
        WHEN processing_error THEN

          IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_INT_NODE_ERR');
	    FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
	   	'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', TRUE);
	  END IF;


          g_hrt_beat := 11.5;

          -- rollback all work done for this interaction
          ROLLBACK TO SAVEPOINT BEGIN_INTERACTION;

          g_hrt_beat := 11.6;

          IF (l_error = L_BLANK) THEN
            g_hrt_beat := 11.64;
            l_error_msgLOG := SQLERRM;
          ELSE
            g_hrt_beat := 11.61;
            l_err_msg := FND_MESSAGE.GET_STRING('JTF', l_error);
          END IF;

          g_hrt_beat := 11.65;

          l_error_msgLOG := l_err_msg ||' '||l_error_msgLOG;
          l_ret_status := LOG_BULK_ERROR(int_node, p_bulk_writer_code,
                                         p_bulk_batch_type, p_bulk_batch_id,
                                         l_bulk_interaction_id,
                                         --l_err_msg, l_ret_msg);
                                         l_error_msgLOG, l_ret_msg);
          --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'LOG_BULK_ERROR call done');
          g_hrt_beat := 11.7;

    END; -- dummy block

    g_hrt_beat := 11.8;
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'end INT loop iteration # - ' || i);

  END LOOP; -- INT nodes

  g_hrt_beat := 12;
  dbms_xmldom.freeDocument(xml_doc);

  g_hrt_beat := 13;
  dbms_xmlparser.freeParser(xml_p);

  g_hrt_beat := 14;

  -- commit any outstanding work.
  -- update the crash recovery table too - here the num int processed is diff
  -- from above
  UPDATE jtf_ih_bulk_recovery
  SET num_int_processed = l_num_int_done,
      last_update_date = sysdate,
      program_update_date = sysdate
  WHERE request_id = G_CONC_REQUEST_ID;
  COMMIT WORK;

  -- the first two totals are gathered irrespective of the stats flag because
  -- they are output to the log file as summary information
  --
  -- gather interaction statistics
  G_NUM_INT_PROC_TOTAL := G_NUM_INT_PROC_TOTAL + l_num_int_done;
  G_NUM_INT_TOTAL      := G_NUM_INT_TOTAL + NUM_INT;

  --IF (g_stats_enabled) THEN
    IF (num_int > G_NUM_INT_MAX) THEN
      G_NUM_INT_MAX := num_int;
    END IF;

    IF (num_int < G_NUM_INT_MIN) THEN
      G_NUM_INT_MIN := num_int;
    END IF;
  --END IF;

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'FUNCTION PROCESS_BULK_RECORD return variable :'||
       	                       'l_ret_status       = '|| l_ret_status;
       --dbms_output.put_line(l_fnd_log_msg);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD.end', l_fnd_log_msg);
    END IF;


  RETURN l_ret_status;

  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        error NUMBER := SQLCODE;
        -- Bug fix 3812373. Increasing the errm size from 300 to 1000
        errm  varchar2(1000) := SQLERRM;
        errbuf varchar2(1000);
      BEGIN
        NULL;
        /*
        debug message - uncomment if necessary.

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Exception occurred in PROCESS_BULK_RECORD');
        IF (error IS NOT NULL) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error code is - ' || error);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error msg - ' || errm);
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'No error code');
        END IF;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Hrt beat = ' || g_hrt_beat);
        */


        FND_FILE.PUT_LINE(FND_FILE.LOG, errm);

        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_REQ_FAIL2');
        FND_MESSAGE.SET_TOKEN('NUM_INT_DONE', l_num_int_done);
        FND_MESSAGE.SET_TOKEN('NUM_INT_COMMIT', l_commit_int_num);

        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_REQ_FAIL2');
	  FND_MESSAGE.SET_TOKEN('NUM_INT_DONE', l_num_int_done);
	  FND_MESSAGE.SET_TOKEN('NUM_INT_COMMIT', l_commit_int_num);
	  FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
		'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD', TRUE);
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
       	   		'jtf.plsql.JTF_IH_BULK.PROCESS_BULK_RECORD',errm);
	END IF;

        -- rollback work in the current bulk record
        ROLLBACK TO SAVEPOINT BULK_RECORD;

        -- in case of this exception, shunt the entire bulk request to error tbl
        l_ret_status := LOG_BULK_ERROR( p_bulk_writer_code,
                                        p_bulk_batch_type,
                                        p_bulk_batch_id,
                                        l_bulk_interaction_id,
                                        p_bulk_interaction_request,
                                        FND_MESSAGE.GET_STRING('JTF','JTF_IH_BULK_REQ_FAIL'),
                                        errm);
        l_ret_status := FND_API.G_RET_STS_ERROR;
      END;

    -- an exception is always unexpected
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;
END PROCESS_BULK_RECORD;

--
-- Utility function to handle media nodes for an interaction.
--
-- Parameters
--
--  med_nl                - IN  - dbms_xmldom.DomNodeList of media nodes
--  p_bulk_interaction_id - IN  - self explanatory
--  bulk_writer_code      - IN  - self explanatory
--  bulk_batch_type       - IN  - self explanatory
--  bulk_batch_id         - IN  - self explanatory
--  p_user_id             - IN  - user id of the user submitting the request
--  x_med_id_tbl          - OUT - this carries the media_identifier to media_id relation
--  x_ret_status          - OUT - self explanatory
--  x_ret_msg             - OUT - self explanatory
--
PROCEDURE PROCESS_MEDIA_ITEMS
(
  med_nl                IN            dbms_xmldom.DomNodeList,
  p_bulk_interaction_id IN            NUMBER,
  p_bulk_writer_code    IN            VARCHAR2,
  p_bulk_batch_type     IN            VARCHAR2,
  p_bulk_batch_id       IN            NUMBER,
  p_user_id             IN            NUMBER,
  x_med_id_tbl          IN OUT NOCOPY media_id_trkr_type,
  x_ret_status          IN OUT NOCOPY VARCHAR2,
  x_ret_msg             IN OUT NOCOPY VARCHAR2
) IS

  med_ident           NUMBER;
  med_node            dbms_xmldom.DOMNode;
  med_elem            dbms_xmldom.DOMElement;
  mlcs_nl             dbms_xmldom.DOMNodeList;
  mlcs_node           dbms_xmldom.DOMNode;
  mlcs_elem           dbms_xmldom.DOMElement;
  num_mlcs            number;
  med_rec             JTF_IH_PUB.media_rec_type;
  mlcs_rec            JTF_IH_PUB.media_lc_rec_type;
  mlcs_tbl            JTF_IH_PUB.mlcs_tbl_type;
  med_id              number;
  l_milcs_id          number;

  date_str            VARCHAR2(50);
  num_med             NUMBER;
  l_media_id_given    BOOLEAN;
  l_ret_status        VARCHAR2(1);
  l_rtn_name          VARCHAR2(30);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  t1_beg              NUMBER;
  t1_end              NUMBER;
  l_err_media	      VARCHAR2(2000);

  media_exception     EXCEPTION;
BEGIN

 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'PROCESS_MEDIA_ITEMS In parameters :'||
    	             'med_nl TYPE dbms_xmldom.DomNodeList'||
    	             ', p_bulk_interaction_id     = '|| p_bulk_interaction_id ||
    	             ', p_bulk_writer_code        = '|| p_bulk_writer_code||
    	             ', p_bulk_batch_type         = '|| p_bulk_batch_type ||
    	             ', p_bulk_batch_id           = '|| p_bulk_batch_id ||
    	             ', p_user_id                 = '|| p_user_id ||
    	             ', x_med_id_tbl TYPE media_id_trkr_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER' ||
    	             ', x_ret_status              = '|| x_ret_status ||
    	             ', x_ret_msg                 = '|| x_ret_msg;
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.PROCESS_MEDIA_ITEMS.begin', l_fnd_log_msg);
  END IF;
  -- to do
  /*
    ii.for each media node
      a. get childNodes (they would be MLCS)
      b. for each mlcs node, create a mlcs record and accumulate
      c. get attributes of media node
      d. if MEDIA_ID value is not set for the media item,
         call JTF_IH_PUB.Create_MediaItem with the attributes and mlcs
      e. if MEDIA_ID is already set, call the Add_MediaLifeCycle and
         Close_MediaItem methods
      f. keep track of mediaitem_identifier to media_id values
  */

  l_ret_status := FND_API.G_RET_STS_SUCCESS;
  num_med := dbms_xmldom.getLength(med_nl);

  g_hrt_beat := 13.0;

  --ii.for each media node
  FOR j IN 0..num_med-1 LOOP
    med_node := dbms_xmldom.item(med_nl, j);

    -- an element is easier to get attribute values from
    med_elem := dbms_xmldom.makeElement(med_node);

    -- get the media identifier
    med_ident   := dbms_xmldom.getAttribute(med_elem, 'mediaitem_identifier');

    -- we need to note whether we were passed a media id or not
    -- generate a media_id first - if it is not passed to us (AO gives us the media_id)
    med_id := dbms_xmldom.getAttribute(med_elem, 'media_id');
    IF (med_id IS null) THEN
      g_hrt_beat := 13.11;
      l_media_id_given := FALSE;
      --dbms_output.PUT('media_id is null for media_ident ' || med_ident);
      SELECT jtf_ih_media_items_s1.NEXTVAL INTO med_id FROM sys.dual;
      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' obtained from db med_id = ' || med_id);
    ELSE
      g_hrt_beat := 13.12;
      l_media_id_given := TRUE;
      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'media_id is NOT null for media_ident ' || med_ident || ', med_id = ' || med_id);
    END IF;

    --a. get childNodes (they would be MLCS)
    mlcs_nl := dbms_xmldom.getChildNodes(med_node);
    num_mlcs := dbms_xmldom.getLength(mlcs_nl);

    g_hrt_beat := 13.2;

    --b. for each mlcs node, create a mlcs record and accumulate
    FOR k IN 1..num_mlcs LOOP
      mlcs_node := dbms_xmldom.item(mlcs_nl, (k-1)); -- indices run from 0 here

      -- each mlcs node has only mlcs attributes, gather them and create an mlcs record
      -- elements are easier to get attribute values out of.
      mlcs_elem := dbms_xmldom.makeElement(mlcs_node);

      -- get all attributes of each mlcs and accumulate in the collection
      date_str                          := dbms_xmldom.getAttribute(mlcs_elem, 'start_date_time');
      -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
      mlcs_tbl(k).start_date_time       := TO_DATE(date_str, G_DATE_FORMAT);
      date_str                          := dbms_xmldom.getAttribute(mlcs_elem, 'end_date_time');
      -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
      mlcs_tbl(k).end_date_time         := TO_DATE(date_str, G_DATE_FORMAT);

      mlcs_tbl(k).type_type             := dbms_xmldom.getAttribute(mlcs_elem, 'type_type');
      mlcs_tbl(k).type_id               := dbms_xmldom.getAttribute(mlcs_elem, 'type_id');
      mlcs_tbl(k).duration              := dbms_xmldom.getAttribute(mlcs_elem, 'duration');
      mlcs_tbl(k).milcs_type_id         := dbms_xmldom.getAttribute(mlcs_elem, 'milcs_type_id');
      mlcs_tbl(k).media_id              := med_id;
      mlcs_tbl(k).handler_id            := dbms_xmldom.getAttribute(mlcs_elem, 'handler_id');
      mlcs_tbl(k).resource_id           := dbms_xmldom.getAttribute(mlcs_elem, 'resource_id');
      mlcs_tbl(k).milcs_code            := dbms_xmldom.getAttribute(mlcs_elem, 'milcs_code');

      -- bulk attributes
      mlcs_tbl(k).bulk_writer_code      := p_bulk_writer_code;
      mlcs_tbl(k).bulk_batch_type       := p_bulk_batch_type;
      mlcs_tbl(k).bulk_batch_id         := p_bulk_batch_id;
      mlcs_tbl(k).bulk_interaction_id   := p_bulk_interaction_id;

      /*Is useful in figuring out which attribute is bad, if necessary
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).start_date_time = ' || mlcs_tbl(k).start_date_time);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).end_date_time = ' || mlcs_tbl(k).end_date_time);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).type_type = ' || mlcs_tbl(k).type_type);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).type_id = ' || mlcs_tbl(k).type_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).duration = ' || mlcs_tbl(k).duration);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).milcs_type_id = ' || mlcs_tbl(k).milcs_type_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).media_id      = ' || med_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).handler_id = ' || mlcs_tbl(k).handler_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).resource_id = ' || mlcs_tbl(k).resource_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).milcs_code = ' || mlcs_tbl(k).milcs_code);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '-- bulk attributes');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).bulk_writer_code = ' || mlcs_tbl(k).bulk_writer_code);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).bulk_batch_type = ' || mlcs_tbl(k).bulk_batch_type);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).bulk_batch_id = ' || mlcs_tbl(k).bulk_batch_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'mlcs_tbl(k).bulk_interaction_id = ' || mlcs_tbl(k).bulk_interaction_id);
      */

    END LOOP; --  MLCS nodes

    g_hrt_beat := 13.3;

    --c. get attributes of media node
    date_str                              := dbms_xmldom.getAttribute(med_elem, 'start_date_time');
    -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
    med_rec.start_date_time               := TO_DATE(date_str, G_DATE_FORMAT);
    date_str                              := dbms_xmldom.getAttribute(med_elem, 'end_date_time');
    -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
    med_rec.end_date_time                 := TO_DATE(date_str, G_DATE_FORMAT);
    med_rec.media_id                      := med_id;
    med_rec.source_id                     := dbms_xmldom.getAttribute(med_elem, 'source_id');
    med_rec.direction                     := dbms_xmldom.getAttribute(med_elem, 'direction');
    med_rec.duration                      := dbms_xmldom.getAttribute(med_elem, 'duration');
    med_rec.interaction_performed         := dbms_xmldom.getAttribute(med_elem, 'interaction_performed');
    med_rec.media_data                    := dbms_xmldom.getAttribute(med_elem, 'media_data');
    date_str                              := dbms_xmldom.getAttribute(med_elem, 'source_item_create_date_time');
    -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
    med_rec.source_item_create_date_time  := TO_DATE(date_str, G_DATE_FORMAT);
    med_rec.source_item_id                := dbms_xmldom.getAttribute(med_elem, 'source_item_id');
    med_rec.media_item_type               := dbms_xmldom.getAttribute(med_elem, 'media_item_type');
    med_rec.media_item_ref                := dbms_xmldom.getAttribute(med_elem, 'media_item_ref');
    med_rec.media_abandon_flag            := dbms_xmldom.getAttribute(med_elem, 'media_abandon_flag');
    med_rec.media_transferred_flag        := dbms_xmldom.getAttribute(med_elem, 'media_transferred_flag');
    med_rec.server_group_id               := dbms_xmldom.getAttribute(med_elem, 'server_group_id');
    med_rec.dnis                          := dbms_xmldom.getAttribute(med_elem, 'dnis');
    med_rec.ani                           := dbms_xmldom.getAttribute(med_elem, 'ani');
    med_rec.classification                := dbms_xmldom.getAttribute(med_elem, 'classification');
    med_rec.address                       := dbms_xmldom.getAttribute(med_elem, 'address');

    -- bulk attributes
    med_rec.bulk_writer_code              := p_bulk_writer_code;
    med_rec.bulk_batch_type               := p_bulk_batch_type;
    med_rec.bulk_batch_id                 := p_bulk_batch_id;
    med_rec.bulk_interaction_id           := p_bulk_interaction_id;

    /* Is useful figuring out which attribute is bad if necessary
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.start_date_time = ' || med_rec.start_date_time);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.end_date_time = ' || med_rec.end_date_time);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.media_id = ' || med_rec.media_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.source_id = ' || med_rec.source_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.direction = ' || med_rec.direction);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.duration = ' || med_rec.duration);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.interaction_performed = ' || med_rec.interaction_performed);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.media_data = ' || med_rec.media_data );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.source_item_create_date_time = ' || med_rec.source_item_create_date_time);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.source_item_id = ' || med_rec.source_item_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.media_item_type = ' || med_rec.media_item_type);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.media_item_ref = ' || med_rec.media_item_ref );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.media_abandon_flag = ' || med_rec.media_abandon_flag);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.media_transferred_flag = ' || med_rec.media_transferred_flag);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.server_group_id = ' || med_rec.server_group_id );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.dnis = ' || med_rec.dnis);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.ani = ' || med_rec.ani);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.classification = ' || med_rec.classification);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.address = ' || med_rec.address);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '-- bulk attributes');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.bulk_writer_code = ' || med_rec.bulk_writer_code);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.bulk_batch_type = ' || med_rec.bulk_batch_type);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.bulk_batch_id = ' || med_rec.bulk_batch_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'med_rec.bulk_interaction_id = ' || med_rec.bulk_interaction_id);
    */

    g_hrt_beat := 13.4;

    -- we have all attributes and any mlcs records of one media item, create it

    --d. if MEDIA_ID value is not set for the media item,
    --   call JTF_IH_PUB.Create_MediaItem with the attributes and mlcs
    IF (l_media_id_given = FALSE) THEN
      JTF_IH_PUB.create_mediaitem(p_api_version       =>  1.0,
                                  p_init_msg_list     =>  FND_API.G_TRUE,
                                  p_commit            =>  FND_API.G_FALSE,
                                  p_user_id           =>  p_user_id,
                                  x_return_status     =>  l_ret_status,
                                  x_msg_count         =>  l_msg_count,
                                  x_msg_data          =>  l_msg_data,
                                  p_media             =>  med_rec,
                                  p_mlcs              =>  mlcs_tbl);

      -- The dbms_output will need to be replaced by proper logging for error
      -- messages.
      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Create_MediaItem returned - ' || l_ret_status);
      IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_rtn_name := 'Create_MediaItem';
        /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Create_MediaItem failed' ||
                                           ', msg_count = ' || l_msg_count ||
                                           ', msg_data = ' || l_msg_data);*/
        RAISE media_exception;
      END IF;
    --e. if MEDIA_ID is already set, call the Add_MediaLifeCycle and
    --   Close_MediaItem methods
    ELSE  -- IF (l_media_id_given = TRUE)
      g_hrt_beat := 13.5;
      -- loop through all mlcs records and create them
      FOR l IN 1..mlcs_tbl.COUNT LOOP
        JTF_IH_PUB.Add_MediaLifecycle( p_api_version       => 1.0,
                                       p_init_msg_list     => FND_API.G_TRUE,
                                       p_commit            => FND_API.G_FALSE,
                                       p_user_id           =>  p_user_id,
                                       x_return_status     => l_ret_status,
                                       x_msg_count         => l_msg_count,
                                       x_msg_data          => l_msg_data,
                                       p_media_lc_rec      => mlcs_tbl(l),
                                       x_milcs_id          => l_milcs_id);
        IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_rtn_name := 'Add_MediaLifecycle';
          /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Add_MediaLifecycle failed' ||
                                             ', msg_count = ' || l_msg_count ||
                                             ', msg_data = ' || l_msg_data);*/
          RAISE media_exception;
        END IF;
      END LOOP;

      -- now update the media item and close it as well.
      JTF_IH_PUB.Close_MediaItem(p_api_version   => 1.0,
                                  p_init_msg_list => FND_API.G_TRUE,
                                  p_commit        => FND_API.G_FALSE,
                                  p_user_id       =>  p_user_id,
                                  x_return_status => l_ret_status,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data,
                                  p_media_rec     => med_rec);

      IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_rtn_name := 'Close_MediaItem';
        /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Close_MediaItem failed' ||
                                           ', msg_count = ' || l_msg_count ||
                                           ', msg_data = ' || l_msg_data);*/
        RAISE media_exception;
      END IF;
    END IF; --(l_media_id_given = TRUE/FALSE)

    --f. keep track of mediaitem_identifier to media_id values
    -- relate the media_id to media_ident, is needed for activity rec. later
    x_med_id_tbl(med_ident) := med_id;

  END LOOP;   -- MED nodes

  g_hrt_beat := 13.6;
  x_ret_status := l_ret_status;

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'PROCESS_MEDIA_ITEMS Out parameters:' ||
      	             'x_med_id_tbl TYPE media_id_trkr_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER' ||
        	             'x_ret_status              = '|| x_ret_status ||
        	             'x_ret_msg                 = '|| x_ret_msg;
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.PROCESS_MEDIA_ITEMS.end', l_fnd_log_msg);
    END IF;

  EXCEPTION
    -- this exception is raised if any of the JTF_IH_PUB's media calls fail.
    WHEN media_exception THEN

    IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_MEDIA_FAIL2');
      FND_MESSAGE.SET_TOKEN('RTN_NAME', l_rtn_name);
      FND_MESSAGE.SET_TOKEN('MSG_COUNT', l_msg_count);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
	'jtf.plsql.JTF_IH_BULK.PROCESS_MEDIA_ITEMS.end', TRUE);
    END IF;

      x_ret_msg := '';
      FOR i in 1..l_msg_count LOOP
         l_msg_data := FND_MSG_PUB.Get(i, 'F');

        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ERROR_MSG');
        FND_MESSAGE.SET_TOKEN('MSG_NUM', i);
        FND_MESSAGE.SET_TOKEN('MSG_TXT', l_msg_data);
        l_err_media := FND_MESSAGE.GET;
        --FND_FILE.PUT_LINE(FND_FILE.LOG, l_err_media);

        x_ret_msg := x_ret_msg || l_err_media;

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    l_fnd_log_msg := l_err_media;
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
	    'jtf.plsql.JTF_IH_BULK.PROCESS_MEDIA_ITEMS.end', l_fnd_log_msg);
        END IF;
        --x_ret_msg := x_ret_msg || substrb(l_msg_data, 0, (2000-lengthb(x_ret_msg))) ||
        --                            substrb(l_msg_data, 0, (2000-lengthb(', ')));
      END LOOP;

      -- return error
      x_ret_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      DECLARE
        error NUMBER := SQLCODE;
        errm  varchar2(300) := SQLERRM;
      BEGIN
        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_MEDIA_FAIL_UNEXP');
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
	    'jtf.plsql.JTF_IH_BULK.PROCESS_MEDIA_ITEMS', TRUE);
	END IF;

        --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ERR_CODE_MSG');
          FND_MESSAGE.SET_TOKEN('ERR_CODE', error);
          FND_MESSAGE.SET_TOKEN('ERR_MSG', errm);
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
		    'jtf.plsql.JTF_IH_BULK.PROCESS_MEDIA_ITEMS', TRUE);
	END IF;

        --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

        x_ret_msg := errm;

        -- an unknown exception is always unexpected
        x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;

      END;

END PROCESS_MEDIA_ITEMS;

--
-- Utility function to gather activity attributes for an interaction.
--
-- Parameters
--
--  act_nl              - IN  - dbms_xmldom.DomNodeList of act nodes
--  p_bulk_interaction_id - IN  - self explanatory
--  p_bulk_writer_code    - IN  - self explanatory
--  p_bulk_batch_type     - IN  - self explanatory
--  p_bulk_batch_id       - IN  - self explanatory
--  med_id_tbl            - IN  - this carries the media_identifier to media_id relation
--  x_act_tbl             - OUT - parsed activity records collection
--  x_ret_status          - OUT - self explanatory
--  x_ret_msg             - OUT - self explanatory
--
PROCEDURE GATHER_ACT_TBL
(
  act_nl                IN            dbms_xmldom.DomNodeList,
  p_bulk_interaction_id IN            NUMBER,
  p_bulk_writer_code    IN            VARCHAR2,
  p_bulk_batch_type     IN            VARCHAR2,
  p_bulk_batch_id       IN            NUMBER,
  med_id_tbl            IN            media_id_trkr_type,
  x_act_tbl             IN OUT NOCOPY JTF_IH_PUB.ACTIVITY_TBL_TYPE,
  x_ret_status          IN OUT NOCOPY VARCHAR2,
  x_ret_msg             IN OUT NOCOPY VARCHAR2
) IS

  med_ident           NUMBER;
  act_node            dbms_xmldom.DOMNode;
  act_elem            dbms_xmldom.DOMElement;
  act_rec             JTF_IH_PUB.activity_rec_type;
  med_id              NUMBER;
  act_id              NUMBER;

  date_str            VARCHAR2(50);
  num_act             NUMBER;
BEGIN

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  l_fnd_log_msg := 'GATHER_ACT_TBL In parameters :'||
		     'act_nl TYPE dbms_xmldom.DomNodeList'||
		     ', p_bulk_interaction_id     = '|| p_bulk_interaction_id ||
		     ', p_bulk_writer_code        = '|| p_bulk_writer_code||
		     ', p_bulk_batch_type         = '|| p_bulk_batch_type ||
		     ', p_bulk_batch_id           = '|| p_bulk_batch_id ||
		     ', x_med_id_tbl TYPE media_id_trkr_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER' ||
		     ', x_act_tbl TYPE JTF_IH_PUB.ACTIVITY_TBL_TYPE' ||
		     ', x_ret_status              = '|| x_ret_status ||
		     ', x_ret_msg                 = '|| x_ret_msg;
  --dbms_output.put_line(l_fnd_log_msg);
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                 'jtf.plsql.JTF_IH_BULK.GATHER_ACT_TBL.begin', l_fnd_log_msg);
  END IF;
  -- to do
  /*
    iv.for each activity node
      a.gather each activity's attributes, including media_id using the mapping from b.1.ii.e
      b.create a Activity record and save
  */

  num_act := dbms_xmldom.getLength(act_nl);

  --ii.for each media node
  FOR j IN 1..num_act LOOP
    act_node := dbms_xmldom.item(act_nl, j-1);

    -- an element is easier to get attribute values from
    act_elem := dbms_xmldom.makeElement(act_node);

    -- get the media identifier if available
    med_id := NULL;
    med_ident   := dbms_xmldom.getAttribute(act_elem, 'mediaitem_identifier');
    IF (med_ident IS NOT NULL) THEN
      -- get the corresponding media_id from the med_id_tbl
      med_id := med_id_tbl(med_ident);
    END IF;


    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'media_id and media_ident values are ' || med_id || ', ' || med_ident);

    --a.gather each activity's attributes, including media_id using the mapping from b.1.ii.e
    date_str                                := dbms_xmldom.getAttribute(act_elem, 'start_date_time');
    -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
    x_act_tbl(j).start_date_time            := TO_DATE(date_str, G_DATE_FORMAT);
    date_str                                := dbms_xmldom.getAttribute(act_elem, 'end_date_time');
    -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
    x_act_tbl(j).end_date_time              := TO_DATE(date_str, G_DATE_FORMAT);

    IF (med_id IS NOT NULL) THEN
      x_act_tbl(j).media_id                   := med_id;
    END IF;

    x_act_tbl(j).cust_account_id            := dbms_xmldom.getAttribute(act_elem, 'cust_account_id');
    x_act_tbl(j).cust_org_id                := dbms_xmldom.getAttribute(act_elem, 'cust_org_id');
    x_act_tbl(j).role                       := dbms_xmldom.getAttribute(act_elem, 'role');
    x_act_tbl(j).task_id                    := dbms_xmldom.getAttribute(act_elem, 'task_id');
    x_act_tbl(j).doc_id                     := dbms_xmldom.getAttribute(act_elem, 'doc_id');
    x_act_tbl(j).doc_ref                    := dbms_xmldom.getAttribute(act_elem, 'doc_ref');
    x_act_tbl(j).doc_source_object_name     := dbms_xmldom.getAttribute(act_elem, 'doc_source_object_name');
    x_act_tbl(j).action_item_id             := dbms_xmldom.getAttribute(act_elem, 'action_item_id');
    x_act_tbl(j).outcome_id                 := dbms_xmldom.getAttribute(act_elem, 'outcome_id');
    x_act_tbl(j).result_id                  := dbms_xmldom.getAttribute(act_elem, 'result_id');
    x_act_tbl(j).reason_id                  := dbms_xmldom.getAttribute(act_elem, 'reason_id');
    x_act_tbl(j).description                := dbms_xmldom.getAttribute(act_elem, 'description');
    x_act_tbl(j).action_id                  := dbms_xmldom.getAttribute(act_elem, 'action_id');
    x_act_tbl(j).interaction_action_type    := dbms_xmldom.getAttribute(act_elem, 'interaction_action_type');
    x_act_tbl(j).object_id                  := dbms_xmldom.getAttribute(act_elem, 'object_id');
    x_act_tbl(j).object_type                := dbms_xmldom.getAttribute(act_elem, 'object_type');
    x_act_tbl(j).source_code_id             := dbms_xmldom.getAttribute(act_elem, 'source_code_id');
    x_act_tbl(j).source_code                := dbms_xmldom.getAttribute(act_elem, 'source_code');
    x_act_tbl(j).script_trans_id            := dbms_xmldom.getAttribute(act_elem, 'script_trans_id');
    x_act_tbl(j).attribute1                 := dbms_xmldom.getAttribute(act_elem, 'attribute1');
    x_act_tbl(j).attribute2                 := dbms_xmldom.getAttribute(act_elem, 'attribute2');
    x_act_tbl(j).attribute3                 := dbms_xmldom.getAttribute(act_elem, 'attribute3');
    x_act_tbl(j).attribute4                 := dbms_xmldom.getAttribute(act_elem, 'attribute4');
    x_act_tbl(j).attribute5                 := dbms_xmldom.getAttribute(act_elem, 'attribute5');
    x_act_tbl(j).attribute6                 := dbms_xmldom.getAttribute(act_elem, 'attribute6');
    x_act_tbl(j).attribute7                 := dbms_xmldom.getAttribute(act_elem, 'attribute7');
    x_act_tbl(j).attribute8                 := dbms_xmldom.getAttribute(act_elem, 'attribute8');
    x_act_tbl(j).attribute9                 := dbms_xmldom.getAttribute(act_elem, 'attribute9');
    x_act_tbl(j).attribute10                := dbms_xmldom.getAttribute(act_elem, 'attribute10');
    x_act_tbl(j).attribute11                := dbms_xmldom.getAttribute(act_elem, 'attribute11');
    x_act_tbl(j).attribute12                := dbms_xmldom.getAttribute(act_elem, 'attribute12');
    x_act_tbl(j).attribute13                := dbms_xmldom.getAttribute(act_elem, 'attribute13');
    x_act_tbl(j).attribute14                := dbms_xmldom.getAttribute(act_elem, 'attribute14');
    x_act_tbl(j).attribute15                := dbms_xmldom.getAttribute(act_elem, 'attribute15');
    x_act_tbl(j).attribute_category         := dbms_xmldom.getAttribute(act_elem, 'attribute_category');

    -- bulk attributes
    x_act_tbl(j).bulk_writer_code              := p_bulk_writer_code;
    x_act_tbl(j).bulk_batch_type               := p_bulk_batch_type;
    x_act_tbl(j).bulk_batch_id                 := p_bulk_batch_id;
    x_act_tbl(j).bulk_interaction_id           := p_bulk_interaction_id;
  END LOOP;   -- MED nodes

  x_ret_status := FND_API.G_RET_STS_SUCCESS;

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'GATHER_ACT_TBL Out parameters :'||
         	             'x_act_tbl TYPE JTF_IH_PUB.ACTIVITY_TBL_TYPE' ||
         	             ', x_ret_status              = '|| x_ret_status ||
         	             ', x_ret_msg                 = '|| x_ret_msg;
          --dbms_output.put_line(l_fnd_log_msg);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
          'jtf.plsql.JTF_IH_BULK.GATHER_ACT_TBL.end', l_fnd_log_msg);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        error NUMBER := SQLCODE;
        errm  varchar2(300) := SQLERRM;
      BEGIN

        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ACT_FAIL_UNEXP');
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
	        'jtf.plsql.JTF_IH_BULK.GATHER_ACT_TBL', TRUE);
        END IF;

        --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ERR_CODE_MSG');
          FND_MESSAGE.SET_TOKEN('ERR_CODE', error);
          FND_MESSAGE.SET_TOKEN('ERR_MSG', errm);
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
	        'jtf.plsql.JTF_IH_BULK.GATHER_ACT_TBL', TRUE);
        END IF;

        --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

        x_ret_msg := errm;
      END;

    -- an exception is always unexpected
    x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GATHER_ACT_TBL;

--
-- Utility function to gather all interaction attributes from xml.
--
-- Parameters
--
--  int_elem              - IN  - dbms_xmldom.DomElement, with xml data
--  p_bulk_interaction_id - IN  - self explanatory
--  p_bulk_writer_code    - IN  - self explanatory
--  p_bulk_batch_type     - IN  - self explanatory
--  p_bulk_batch_id       - IN  - self explanatory
--  int_rec               - OUT - this is the return interaction record
--  x_ret_status          - OUT - self explanatory
--  x_ret_msg             - OUT - self explanatory
--
PROCEDURE GATHER_INT_ATTR
(
  int_elem                IN            dbms_xmldom.DomElement,
  p_bulk_interaction_id   IN            NUMBER,
  p_bulk_writer_code      IN            VARCHAR2,
  p_bulk_batch_type       IN            VARCHAR2,
  p_bulk_batch_id         IN            NUMBER,
  x_int_rec               IN OUT NOCOPY JTF_IH_PUB.INTERACTION_REC_TYPE,
  x_ret_status            IN OUT NOCOPY VARCHAR2,
  x_ret_msg               IN OUT NOCOPY VARCHAR2
) IS
  date_str            VARCHAR2(50);
BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'GATHER_INT_ATTR In parameters :'||
          	             'int_elem TYPE dbms_xmldom.DomElement'||
          	             ', p_bulk_interaction_id     = '|| p_bulk_interaction_id ||
          	             ', p_bulk_writer_code        = '|| p_bulk_writer_code||
          	             ', p_bulk_batch_type         = '|| p_bulk_batch_type ||
          	             ', p_bulk_batch_id           = '|| p_bulk_batch_id ||
          	             ', x_int_rec TYPE JTF_IH_PUB.INTERACTION_REC_TYPE'||
          	             ', x_ret_status              = '|| x_ret_status ||
          	             ', x_ret_msg                 = '|| x_ret_msg;
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.GATHER_INT_ATTR.begin', l_fnd_log_msg);
    END IF;

  date_str                               := dbms_xmldom.getAttribute(int_elem, 'start_date_time');
  -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
  x_int_rec.start_date_time              := TO_DATE(date_str, G_DATE_FORMAT);
  date_str                               := dbms_xmldom.getAttribute(int_elem, 'end_date_time');
  -- RDD - Bug 5330922 - Removed the call to convert GMT input to server date - Input now in Server Date
  x_int_rec.end_date_time                := TO_DATE(date_str, G_DATE_FORMAT);

  x_int_rec.reference_form               := dbms_xmldom.getAttribute(int_elem, 'reference_form');
  x_int_rec.follow_up_action             := dbms_xmldom.getAttribute(int_elem, 'follow_up_action');
  x_int_rec.duration                     := dbms_xmldom.getAttribute(int_elem, 'duration');
  x_int_rec.inter_interaction_duration   := dbms_xmldom.getAttribute(int_elem, 'inter_interaction_duration');
  x_int_rec.non_productive_time_amount   := dbms_xmldom.getAttribute(int_elem, 'non_productive_time_amount');
  x_int_rec.preview_time_amount          := dbms_xmldom.getAttribute(int_elem, 'preview_time_amount');
  x_int_rec.productive_time_amount       := dbms_xmldom.getAttribute(int_elem, 'productive_time_amount');
  x_int_rec.wrapup_time_amount           := dbms_xmldom.getAttribute(int_elem, 'wrap_Up_time_amount');
  x_int_rec.handler_id                   := dbms_xmldom.getAttribute(int_elem, 'handler_id');
  x_int_rec.script_id                    := dbms_xmldom.getAttribute(int_elem, 'script_id');
  x_int_rec.outcome_id                   := dbms_xmldom.getAttribute(int_elem, 'outcome_id');
  x_int_rec.result_id                    := dbms_xmldom.getAttribute(int_elem, 'result_id');
  x_int_rec.reason_id                    := dbms_xmldom.getAttribute(int_elem, 'reason_id');
  x_int_rec.resource_id                  := dbms_xmldom.getAttribute(int_elem, 'resource_id');
  x_int_rec.party_id                     := dbms_xmldom.getAttribute(int_elem, 'party_id');
  x_int_rec.parent_id                    := dbms_xmldom.getAttribute(int_elem, 'parent_id');
  x_int_rec.object_id                    := dbms_xmldom.getAttribute(int_elem, 'object_id');
  x_int_rec.object_type                  := dbms_xmldom.getAttribute(int_elem, 'object_type');
  x_int_rec.source_code_id               := dbms_xmldom.getAttribute(int_elem, 'source_code_id');
  x_int_rec.source_code                  := dbms_xmldom.getAttribute(int_elem, 'source_code');
  x_int_rec.attribute1                   := dbms_xmldom.getAttribute(int_elem, 'attribute1');
  x_int_rec.attribute2                   := dbms_xmldom.getAttribute(int_elem, 'attribute2');
  x_int_rec.attribute3                   := dbms_xmldom.getAttribute(int_elem, 'attribute3');
  x_int_rec.attribute4                   := dbms_xmldom.getAttribute(int_elem, 'attribute4');
  x_int_rec.attribute5                   := dbms_xmldom.getAttribute(int_elem, 'attribute5');
  x_int_rec.attribute6                   := dbms_xmldom.getAttribute(int_elem, 'attribute6');
  x_int_rec.attribute7                   := dbms_xmldom.getAttribute(int_elem, 'attribute7');
  x_int_rec.attribute8                   := dbms_xmldom.getAttribute(int_elem, 'attribute8');
  x_int_rec.attribute9                   := dbms_xmldom.getAttribute(int_elem, 'attribute9');
  x_int_rec.attribute10                  := dbms_xmldom.getAttribute(int_elem, 'attribute10');
  x_int_rec.attribute11                  := dbms_xmldom.getAttribute(int_elem, 'attribute11');
  x_int_rec.attribute12                  := dbms_xmldom.getAttribute(int_elem, 'attribute12');
  x_int_rec.attribute13                  := dbms_xmldom.getAttribute(int_elem, 'attribute13');
  x_int_rec.attribute14                  := dbms_xmldom.getAttribute(int_elem, 'attribute14');
  x_int_rec.attribute15                  := dbms_xmldom.getAttribute(int_elem, 'attribute15');
  x_int_rec.attribute_category           := dbms_xmldom.getAttribute(int_elem, 'attribute_category');
  x_int_rec.method_code                  := dbms_xmldom.getAttribute(int_elem, 'method_code');
  x_int_rec.primary_party_id             := dbms_xmldom.getAttribute(int_elem, 'primary_party_id');
  x_int_rec.contact_party_id             := dbms_xmldom.getAttribute(int_elem, 'contact_party_id');
  x_int_rec.contact_rel_party_id         := dbms_xmldom.getAttribute(int_elem, 'contact_rel_party_id');

  --
  -- These two are defaulted, plus they are not exposed so ignore them
  --x_int_rec.touchpoint1_type             := dbms_xmldom.getAttribute(int_elem, 'touchpoint1_type');
  --x_int_rec.touchpoint2_type             := dbms_xmldom.getAttribute(int_elem, 'touchpoint2_type');
  --

  -- bulk ids
  x_int_rec.bulk_writer_code             := p_bulk_writer_code;
  x_int_rec.bulk_batch_type              := p_bulk_batch_type;
  x_int_rec.bulk_batch_id                := p_bulk_batch_id;
  x_int_rec.bulk_interaction_id          := p_bulk_interaction_id;

  x_ret_status := FND_API.G_RET_STS_SUCCESS;

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'GATHER_INT_ATTR Out parameters :'||
         	             'x_int_rec TYPE JTF_IH_PUB.INTERACTION_REC_TYPE'||
         	             'x_ret_status              = '|| x_ret_status ||
         	             'x_ret_msg                 = '|| x_ret_msg;
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.GATHER_INT_ATTR.end', l_fnd_log_msg);
    END IF;
END GATHER_INT_ATTR;

--
-- Utility function to gather all interaction attributes from xml.
--
-- Parameters
--
--  int_node              - IN  - dbms_xmldom.DomNode, with interaction xml data
--  p_bulk_writer_code    - IN  - self explanatory
--  p_bulk_batch_type     - IN  - self explanatory
--  p_bulk_batch_id       - IN  - self explanatory
--  p_bulk_interaction_id - IN  - self explanatory
--  p_error_msg           - IN  - message describing what failed
--  p_ret_msg             - IN  - message describing underlying cause
--
-- N O T E - It would be simpler if we could use dbms_xmldom.WriteToClob() to convert
--           the p_int_node into a CLOB and then call the version 2 of this
--           routine. But, that does not seem possible because a CLOB locator
--           has to be tied to db column.
--
FUNCTION LOG_BULK_ERROR
(
  p_int_node            IN dbms_xmldom.DOMNode,
  p_bulk_writer_code    IN VARCHAR2,
  p_bulk_batch_type     IN VARCHAR2,
  p_bulk_batch_id       IN NUMBER,
  p_bulk_interaction_id IN NUMBER,
  p_error_msg           IN VARCHAR2,
  p_ret_msg             IN VARCHAR2
) RETURN VARCHAR2 IS

bad_int_clob    CLOB;
rec_id          NUMBER;
error_msg_2     VARCHAR2(2000);

-- Bug3781768 Perf issue with literal usage
l_obj_version_perf  NUMBER;

BEGIN

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'FUNCTION LOG_BULK_ERROR In parameters :'||
       	             'p_int_node TYPE dbms_xmldom.DOMNode' ||
       	             ', p_bulk_writer_code        = '|| p_bulk_writer_code||
       	             ', p_bulk_batch_type         = '|| p_bulk_batch_type ||
       	             ', p_bulk_batch_id           = '|| p_bulk_batch_id ||
       	             ', p_bulk_interaction_id     = '|| p_bulk_interaction_id ||
       	             ', p_error_msg               = '|| p_error_msg ||
       	             ', p_ret_msg                 = '|| p_ret_msg;
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR.begin', l_fnd_log_msg);
  END IF;
  SAVEPOINT BULK_ERROR;

  -- this is a sort of complicated logic here - basically, we don't want to
  -- overrun the buffer length of error_msg_2 so we are trying to fit as much
  -- as possible from the three strings into error_msg_2
  error_msg_2 := SUBSTRB(p_error_msg, 0, 2000);
  error_msg_2 := error_msg_2 || SUBSTRB(' - ', 0, (2000 - LENGTHB(error_msg_2)));
  --error_msg_2 := error_msg_2 || SUBSTRB(p_ret_msg, 0, (2000 - LENGTHB(error_msg_2)));

  /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'In LOG_BULK_ERROR');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_error_msg = ' || p_error_msg);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_ret_msg = ' || p_ret_msg);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'error_msg_2 = ' || error_msg_2);
  */

  SELECT JTF_IH_BULK_ERRORS_S1.NEXTVAL INTO rec_id FROM sys.dual;

  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'BULK_ERROR_ID = ' || rec_id);

  -- Bug3781768 Perf issue with literal usage
  l_obj_version_perf := 0;

  INSERT INTO JTF_IH_BULK_ERRORS
  (bulk_error_id, object_version_number, creation_date, created_by,
   last_update_date, last_updated_by, last_update_login, program_id,
   request_id, program_application_id, program_update_date,
   bulk_writer_code, bulk_batch_id, bulk_batch_type, bulk_interaction_id,
   error_message, inter_req_xml_doc)
  VALUES
  (rec_id, l_obj_version_perf, sysdate, G_USER_ID,
   sysdate, G_USER_ID, G_LOGIN_ID, G_CONC_PROGRAM_ID,
   G_CONC_REQUEST_ID, G_PROG_APPL_ID, sysdate,
   p_bulk_writer_code, p_bulk_batch_id, p_bulk_batch_type,
   p_bulk_interaction_id, error_msg_2, EMPTY_CLOB());

  SELECT inter_req_xml_doc INTO bad_int_clob
  FROM jtf_ih_bulk_errors
  WHERE bulk_error_id = rec_id;

  bad_int_clob := 'AAAA';

  dbms_xmldom.writeToClob(p_int_node, bad_int_clob);

  UPDATE jtf_ih_bulk_errors
  SET inter_req_xml_doc = bad_int_clob
  WHERE bulk_error_id = rec_id;

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'FUNCTION LOG_BULK_ERROR return variable :'||
        	             'FND_API.G_RET_STS_SUCCESS        = '|| FND_API.G_RET_STS_SUCCESS;
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR.end', l_fnd_log_msg);
    END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN

      IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_LOG1_FAIL');
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
	    'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR', TRUE);
      END IF;

      --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

      IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ERR_CODE_MSG');
        FND_MESSAGE.SET_TOKEN('ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('ERR_MSG', SQLERRM);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
		    'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR', TRUE);
      END IF;

      --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
      -- because we got an error saving in the bulk errors, save the xml piece in
      -- the concurrent log file

      -- tbd.

      ROLLBACK WORK TO SAVEPOINT BULK_ERROR;

      RETURN FND_API.G_RET_STS_UNEXP_ERROR;
END LOG_BULK_ERROR;


--
-- Version 2 - takes IH_BULK_OBJ
-- Utility function to gather all interaction attributes from xml.
--
-- Parameters
--
--  p_bulk_writer_code          - IN  - self explanatory
--  p_bulk_batch_type           - IN  - self explanatory
--  p_bulk_batch_id             - IN  - self explanatory
--  p_bulk_interaction_id       - IN  - self explanatory
--  p_bulk_interaction_request  - IN  - self explanatory
--  p_error_msg                 - IN  - message describing what failed
--  p_ret_msg                   - IN  - message describing underlying cause
--
FUNCTION LOG_BULK_ERROR
(
  p_bulk_writer_code          IN VARCHAR2,
  p_bulk_batch_type           IN VARCHAR2,
  p_bulk_batch_id             IN NUMBER,
  p_bulk_interaction_id       IN NUMBER,
  p_bulk_interaction_request  IN CLOB,
  p_error_msg                 IN VARCHAR2,
  p_ret_msg                   IN VARCHAR2
) RETURN VARCHAR2 IS

rec_id          NUMBER;
error_msg_2     VARCHAR2(2000);

-- Bug3781768 Perf issue with literal usage
l_obj_version_perf  NUMBER;

BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'FUNCTION LOG_BULK_ERROR In parameters :'||
         	             'p_bulk_writer_code        = '|| p_bulk_writer_code||
         	             ', p_bulk_batch_type         = '|| p_bulk_batch_type ||
         	             ', p_bulk_batch_id             = '|| p_bulk_batch_id ||
         	             ', p_bulk_interaction_id     = '|| p_bulk_interaction_id ||
         	             ', p_error_msg               = '|| p_error_msg ||
         	             ', p_ret_msg                 = '|| p_ret_msg;
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR.begin', l_fnd_log_msg);
    END IF;
  SAVEPOINT BULK_ERROR;

  -- this is a sort of complicated logic here - basically, we don't want to
  -- overrun the buffer length of error_msg_2 so we are trying to fit as much
  -- as possible from the three strings into error_msg_2
  error_msg_2 := SUBSTRB(p_error_msg, 0, 2000);
  error_msg_2 := error_msg_2 || SUBSTRB(' - ', 0, (2000 - LENGTHB(error_msg_2)));
  error_msg_2 := error_msg_2 || SUBSTRB(p_ret_msg, 0, (2000 - LENGTHB(error_msg_2)));

  SELECT JTF_IH_BULK_ERRORS_S1.NEXTVAL INTO rec_id FROM sys.dual;

  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'BULK_ERROR_ID = ' || rec_id);

  -- Bug3781768 Perf issue with literal usage
  l_obj_version_perf  := 0;

  INSERT INTO JTF_IH_BULK_ERRORS
  (bulk_error_id, object_version_number, creation_date, created_by,
   last_update_date, last_updated_by, last_update_login, program_id,
   request_id, program_application_id, program_update_date,
   bulk_writer_code, bulk_batch_id, bulk_batch_type, bulk_interaction_id,
   error_message, inter_req_xml_doc)
  VALUES
  (rec_id, l_obj_version_perf, sysdate, G_USER_ID,
   sysdate, G_USER_ID, G_LOGIN_ID, G_CONC_PROGRAM_ID,
   G_CONC_REQUEST_ID, G_PROG_APPL_ID, sysdate,
   p_bulk_writer_code, p_bulk_batch_id, p_bulk_batch_type,
   p_bulk_interaction_id, error_msg_2, p_bulk_interaction_request);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'FUNCTION LOG_BULK_ERROR return variable :'||
      	             'FND_API.G_RET_STS_SUCCESS        = '|| FND_API.G_RET_STS_SUCCESS;
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR.end', l_fnd_log_msg);
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN

      IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_LOG2_FAIL');
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
           'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR', TRUE);
      END IF;

      --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

      IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_ERR_CODE_MSG');
        FND_MESSAGE.SET_TOKEN('ERR_CODE', SQLCODE);
        FND_MESSAGE.SET_TOKEN('ERR_MSG', SQLERRM);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
 	    'jtf.plsql.JTF_IH_BULK.LOG_BULK_ERROR', TRUE);
      END IF;

      --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

      -- because we got an error saving in the bulk errors, save the xml piece in
      -- the concurrent log file

      -- tbd.

      ROLLBACK WORK TO SAVEPOINT BULK_ERROR;

      RETURN FND_API.G_RET_STS_UNEXP_ERROR;
END LOG_BULK_ERROR;

FUNCTION FIND_ONE_CRASH_RECD
(
  l_rec_recd IN OUT NOCOPY JTF_IH_BULK_RECOVERY%ROWTYPE
) RETURN BOOLEAN IS

  TYPE BulkRecoveryCurTyp IS REF CURSOR RETURN JTF_IH_BULK_RECOVERY%ROWTYPE;
  l_rec_cv      BulkRecoveryCurTyp;
  l_call_status BOOLEAN;
  l_found_recd  BOOLEAN;
  l_phase       VARCHAR2(80);
  l_status      VARCHAR2(80);
  l_dev_phase   VARCHAR2(30);
  l_dev_status  VARCHAR2(30);
  l_message     VARCHAR2(240);

BEGIN
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'FUNCTION FIND_ONE_CRASH_RECD In parameters :'||
         	             'l_rec_recd TYPE JTF_IH_BULK_RECOVERY%ROWTYPE';
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.FIND_ONE_CRASH_RECD.begin', l_fnd_log_msg);
  END IF;

  g_hrt_beat := -70;
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Entered find_one_crash_Recd');

  OPEN l_rec_cv FOR SELECT * FROM JTF_IH_BULK_RECOVERY;

  -- look for a crash victim in the RECORD_ID for each row in this table

  l_found_recd := FALSE;
  FETCH l_rec_cv INTO l_rec_recd;

  WHILE (l_rec_cv%FOUND AND (NOT l_found_recd)) LOOP

    g_hrt_beat := -70.5;
    /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Data in recov tbl - recovery_id, req_id, msg_id, num_int, (bulk_params)= ' ||
                        l_rec_recd.recovery_id || ', ' ||
                        l_rec_recd.request_id  || ', ' ||
                        l_rec_recd.msg_id      || ', ' ||
                        l_rec_recd.num_int_processed || ', ' ||
                        '(' ||
                          l_rec_recd.bulk_writer_code || ', ' ||
                          l_rec_recd.bulk_batch_type || ', ' ||
                          l_rec_recd.bulk_batch_id || ', ' ||
                          l_rec_recd.bulk_interaction_id ||
                        ')');*/

    l_call_status := FND_CONCURRENT.GET_REQUEST_STATUS(
                            REQUEST_ID => l_rec_recd.request_id,
                            PHASE      => l_phase,
                            STATUS     => l_status,
                            DEV_PHASE  => l_dev_phase,
                            DEV_STATUS => l_dev_status,
                            MESSAGE    => l_message);

    g_hrt_beat := -70.5;
    /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'get_request_stat - req_id, phase, status, d_phase, d_status, msg = ' ||
                              l_rec_recd.request_id || ', ' ||
                              l_phase || ', ' ||
                              l_status || ', ' ||
                              l_dev_phase || ', ' ||
                              l_dev_status || ', ' ||
                              l_message);*/

    -- if this program has completed without deleting its record,
    -- it is a crash victim
    IF (l_dev_phase = 'COMPLETE') THEN
      g_hrt_beat := -71;

      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_CRASH_FND');
        FND_MESSAGE.SET_TOKEN('REQ_ID', l_rec_recd.request_id);
        FND_MESSAGE.SET_TOKEN('WRITER_CODE', l_rec_recd.bulk_writer_code);
        FND_MESSAGE.SET_TOKEN('BATCH_TYPE', l_rec_recd.bulk_batch_type);
        FND_MESSAGE.SET_TOKEN('BATCH_ID', l_rec_recd.bulk_batch_id);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
	      'jtf.plsql.JTF_IH_BULK.FIND_ONE_CRASH_RECD', TRUE);
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

      l_found_recd := TRUE;
    END IF;

    -- get next row
    FETCH l_rec_cv INTO l_rec_recd;

  END LOOP; -- WHILE (l_rec_cv%FOUND AND (NOT l_found_recd))

  CLOSE l_rec_cv;

  IF (l_found_recd = TRUE) THEN

    -- 'grab' the record by changing the request_id to our own
    UPDATE JTF_IH_BULK_RECOVERY
    SET request_id = G_CONC_REQUEST_ID,
        program_id = G_CONC_REQUEST_ID,
        program_application_id = G_PROG_APPL_ID,
        last_update_date = sysdate,
        program_update_date = sysdate
    WHERE recovery_id = l_rec_recd.recovery_id;

    -- make change permanent so that any other crash recovery attempts will ignore
    -- this record
    COMMIT;

    g_hrt_beat := -79;
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Return TRUE find_one_crash_Recd');

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          l_fnd_log_msg := 'FUNCTION FIND_ONE_CRASH_RECD Return parameters :'||
           	               'return boolean    = TRUE';
          --dbms_output.put_line(l_fnd_log_msg);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
          'jtf.plsql.JTF_IH_BULK.FIND_ONE_CRASH_RECD.end', l_fnd_log_msg);
        END IF;

    RETURN TRUE;
  ELSE
    g_hrt_beat := -78;
    --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Return FALSE find_one_crash_Recd');

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          l_fnd_log_msg := 'FUNCTION FIND_ONE_CRASH_RECD Return parameters :'||
           	           'return boolean    = FALSE';
          --dbms_output.put_line(l_fnd_log_msg);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
          'jtf.plsql.JTF_IH_BULK.FIND_ONE_CRASH_RECD.end', l_fnd_log_msg);
    END IF;

    RETURN FALSE;
  END IF;

END FIND_ONE_CRASH_RECD;


PROCEDURE CLEAR_ONE_CRASH_RECD( l_rec_recd IN JTF_IH_BULK_RECOVERY%ROWTYPE) IS

  l_ret_status VARCHAR2(5);
BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'CLEAR_ONE_CRASH_RECD In parameters :'||
           	     'l_rec_recd';
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.CLEAR_ONE_CRASH_RECD.begin', l_fnd_log_msg);
    END IF;

  g_hrt_beat := -60;
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Enter CLEAR_ONE_CRASH_RECD');


  /* To Do -
    Sort of simple - just pass the bulk record from here to the regular
    processing procedure above; it will take care of it. Once that is done,
    delete the current record from the recovery table.

    The XML parser's NodeList is indexed from 0 to n-1, so the num_int_processed
    works fine as an index to the first non-processed interaction.

   */
  l_ret_status := PROCESS_BULK_RECORD(l_rec_recd.bulk_writer_code,
                                      l_rec_recd.bulk_batch_type,
                                      l_rec_recd.bulk_batch_id,
                                      l_rec_recd.bulk_interaction_request,
                                      l_rec_recd.num_int_processed);

  IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
    g_hrt_beat := -61;
    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_RECOV_FAIL');
      FND_MESSAGE.SET_TOKEN('MSG_ID', l_rec_recd.msg_id);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
            'jtf.plsql.JTF_IH_BULK.CLEAR_ONE_CRASH_RECD', TRUE);
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
  END IF;

  -- now that the crash victim has been taken care of, get rid of it
  DELETE FROM jtf_ih_bulk_recovery
  WHERE request_id = G_CONC_REQUEST_ID;

  COMMIT;

  g_hrt_beat := -69;
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'End CLEAR_ONE_CRASH_RECD');
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'CLEAR_ONE_CRASH_RECD no Out Parameters';
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.CLEAR_ONE_CRASH_RECD.end', l_fnd_log_msg);
  END IF;

END CLEAR_ONE_CRASH_RECD;


--
-- This procedure attempts to perform crash recovery
--
-- Parameters - none
--
PROCEDURE PERFORM_CRASH_RECOVERY is

  l_rec_recd    JTF_IH_BULK_RECOVERY%ROWTYPE;

BEGIN

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'PERFORM_CRASH_RECOVERY No In parameters';
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.PERFORM_CRASH_RECOVERY.begin', l_fnd_log_msg);
  END IF;
  /*
    To do -

    1. Look for crash victim
    2. If found -
      a. process any left over records
      b. go back to 1
    3. If not found go back to regular job

  */
  g_hrt_beat := -100;
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Entered crash_recovery');

  WHILE (find_one_crash_recd(l_rec_recd)) LOOP
    clear_one_crash_recd(l_rec_recd);
  END LOOP; -- while(l_rec_recd is not null)

  g_hrt_beat := -99;
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Normal ending crash_recovery');

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_fnd_log_msg := 'PERFORM_CRASH_RECOVERY No Out parameters';
      --dbms_output.put_line(l_fnd_log_msg);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'jtf.plsql.JTF_IH_BULK.PERFORM_CRASH_RECOVERY.end', l_fnd_log_msg);
    END IF;

  RETURN;

  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        errm VARCHAR2(2000);
      BEGIN
        errm := SQLERRM;
        IF (errm IS NULL) THEN
          errm := 'No Error Message in SQLERRM for parsing errors';
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Message: ' || errm );
        g_hrt_beat := -98;
	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_RECOV_UNEXP');
	  FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
	  	    'jtf.plsql.JTF_IH_BULK.PERFORM_CRASH_RECOVERY', TRUE);
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
       	   		'jtf.plsql.JTF_IH_BULK.PERFORM_CRASH_RECOVERY',errm);
        END IF;
     END;

      --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

      LOG_EXC_OTHERS('PERFORM_CRASH_RECOVERY');

END PERFORM_CRASH_RECOVERY;

--
-- Utility procedure to do logging work in case of an unknown exception.
--
-- Purpose - to replace common code in various routines
--
-- Parameters -
-- p_proc_name IN VARCHAR2  Procedure name where the exception happenned
--
PROCEDURE LOG_EXC_OTHERS (p_proc_name IN VARCHAR2) IS
error NUMBER;
errm  VARCHAR2(2000);
BEGIN

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'LOG_EXC_OTHERS In parameters : '||
                     'p_proc_name     =' || p_proc_name;
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.LOG_EXC_OTHERS.begin', l_fnd_log_msg);
  END IF;

  error := SQLCODE;
  IF (error IS NULL) THEN
    error := -1;
  END IF;

  errm  := SQLERRM;
  IF (errm IS NULL) THEN
    errm := FND_MESSAGE.GET_STRING('JTF', 'JTF_IH_BULK_NOERRM');
  END IF;

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_MESSAGE.SET_NAME('JTF', 'JTF_IH_BULK_PROC_EXCP');
    FND_MESSAGE.SET_TOKEN('PROC_NAME', p_proc_name);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,
      'jtf.plsql.JTF_IH_BULK.LOG_EXC_OTHERS', TRUE);
  END IF;

  --FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_fnd_log_msg := 'LOG_EXC_OTHERS No Out parameters';
    --dbms_output.put_line(l_fnd_log_msg);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'jtf.plsql.JTF_IH_BULK.LOG_EXC_OTHERS.begin', l_fnd_log_msg);
  END IF;

  RETURN;

END LOG_EXC_OTHERS;


END JTF_IH_BULK;

/
