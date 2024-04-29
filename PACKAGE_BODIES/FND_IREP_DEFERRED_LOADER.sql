--------------------------------------------------------
--  DDL for Package Body FND_IREP_DEFERRED_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_IREP_DEFERRED_LOADER" as
/* $Header: FNDIRLDB.pls 120.12 2006/07/21 23:45:10 mfisher noship $ */

TYPE FND_NUMBER_TAB is table of NUMBER index by binary_integer;
TYPE FND_ONECHAR_TAB is table of varchar2(1) index by binary_integer;
TYPE FND_ROW_TAB is table of rowid index by binary_integer;
TYPE FND_ERROR_TEXT_TAB is table of varchar2(4000) index by binary_integer;

-- cleanup_batches  (PRIVATE)
--   Finds completed files stillmarked as running, updates the table and purges
--   FNDLOAD's Open Interface.
-- Upload batch file that has status (N)ew or (E)rror
-- IN
--   pStatus - File status, either 'N' for New or 'E' for Error.
-- Note: Statuses for rows:
--   E=Error, C=Completed, X=Error(old revision of file), R=Running
--   N=Initialized.  Likely paths are N-R-C, N-R-E-R-C, N-R-E-R-E-X

procedure cleanup_batches is

   LDT_RowID_Array       FND_ROW_TAB;
   LDT_Array FND_LOADER_OPEN_INTERFACE_PKG.FND_LDT_TAB;
   ReqID_Array FND_NUMBER_TAB;
   BatchID_Array FND_NUMBER_TAB;

   prevReqID Number;
   tempReqID Number;
   i number;
   kount number;

   cp_rphase varchar2(80);
   cp_rstatus varchar2(80);
   cp_dphase varchar2(30);
   cp_dstatus varchar2(30);
   cp_message varchar2(240);
   LDT_Status Varchar2(1);
   LDT_Errors Varchar2(4000);
   LDT_Start Date;
   LDT_Finish Date;
   LDT_Logfile VARCHAR2(150);

   CURSOR PendingFiles is
     SELECT rowid, '@' || file_product || ':' || file_path || '/' || file_name,
	REQUEST_ID, BATCH_ID
     FROM   FND_IREP_DEFERRED_LOAD_FILES
    WHERE  load_status = 'R' and REQUEST_ID is not Null
    ORDER BY  4,3,2;

begin
    FND_FILE.PUT_LINE(FND_FILE.LOG, '    Looking for recently uploaded files . . . ');
    OPEN PendingFiles;
      FETCH PendingFiles BULK COLLECT
                INTO LDT_RowID_Array, LDT_Array, ReqID_Array, BatchID_Array;
    CLOSE PendingFiles;

    if (LDT_Array.COUNT = 0) then
        FND_FILE.PUT_LINE(FND_FILE.LOG, '    No files to process.');
	return;
    end if;

    prevReqID := -99999;
    kount := 0;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '    Found ' || to_char(LDT_Array.COUNT)
					|| ' possible files to process.');

    for i in 1..LDT_Array.COUNT loop
	tempReqID := ReqID_Array(i);

        if (prevReqID < ReqID_Array(i)) then -- new request
       	   if (not FND_CONCURRENT.GET_REQUEST_STATUS(tempReqID, null, null,
	     cp_rphase, cp_rstatus, cp_dphase, cp_dstatus, cp_message)) then
      			cp_dphase  := 'COMPLETE';
			cp_dstatus := 'ERROR';
			cp_message := 'Request ' || to_char(ReqID_Array(i))
				 		 || ' not found.';
	     end if;
        end if;

        -- at this poing cp_dphase, cp_dstatus, cp_message should be current
	-- either due to being same as previous request, freshly fetched for
	-- new request, or populated for missing request.

        prevReqID := ReqID_Array(i);

        if (cp_dphase = 'COMPLETE') then
         kount := kount + 1;

         begin
          select NVL(STATUS, 'E'), START_TIME, FINISH_TIME,
		NVL(ERROR_TEXT, DECODE(STATUS, NULL,
		   NVL(cp_message, 'Request complete but batch not updated.'),
			Null)),
		LOGFILE
 	    into LDT_Status, LDT_Start, LDT_Finish, LDT_Errors, LDT_Logfile
            from FND_LOADER_OPEN_INTERFACE
           where BATCH_ID = BatchID_Array(i)
             and LDT = LDT_Array(i);
         exception
	   When others then
              LDT_Status := 'E';
              LDT_Start := Null;
              LDT_Finish := Null;
	      LDT_Errors := 'Batch ' ||to_char(BatchID_Array(i))
				     || ' not found.';
              LDT_Logfile := Null;
         end;

         update FND_IREP_DEFERRED_LOAD_FILES
            set   LOAD_STATUS = DECODE(LDT_Status, 'S', 'C', 'E'),
                  LOAD_ERRORS = LDT_Errors,
                  LOAD_START = LDT_Start,
		  LOAD_FINISH = LDT_Finish,
		  LOG_FILE = LDT_Logfile,
             	  LAST_UPDATE_DATE = sysdate,
             	  LAST_UPDATE_LOGIN = 0
          where rowid = LDT_RowID_Array(i);

          -- Purge interface table after copying back entire batch
          if (i = LDT_Array.COUNT) then -- absolute last row
            FND_LOADER_OPEN_INTERFACE_PKG.DELETE_BATCH(BatchID_Array(i));
          elsif (BatchID_Array(i) <> BatchID_Array(i+1)) then -- last in batch
            FND_LOADER_OPEN_INTERFACE_PKG.DELETE_BATCH(BatchID_Array(i));
          end if;
         end if;
    end loop;


    FND_FILE.PUT_LINE(FND_FILE.LOG, '    Processed ' || to_char(kount)
					|| ' files to completion.');
    commit;
end;

-- UploadBatch (PRIVATE)
-- Upload batch file that has status (N)ew or (E)rror
-- IN
--   pStatus - File status, either 'N' for New or 'E' for Error.
-- Note: Statuses for rows:
--   E=Error, C=Completed, X=Error(old revision of file), R=Running
--   N=Initialized.  Likely paths are N-R-C, N-R-E-R-C, N-R-E-R-E-X

procedure UploadBatch(pStatus varchar2)
is
  workerNum number;
  BatchID_Array 	FND_LOADER_OPEN_INTERFACE_PKG.FND_BATCH_ID_TAB;
  BatchStatus_Array 	FND_ONECHAR_TAB;
  LDT_Array 		FND_LOADER_OPEN_INTERFACE_PKG.FND_LDT_TAB;
  LDT_RowID_Array 	FND_ROW_TAB;
  BatchReqID_Array 	FND_NUMBER_TAB;
  LDT2Batch_Map 	FND_NUMBER_TAB;
  BatchError_Array      FND_ERROR_TEXT_TAB;
  requestID number;

  CURSOR curLoadFile IS
    SELECT rowid, '@' || file_product || ':' || file_path || '/' || file_name
    FROM   FND_IREP_DEFERRED_LOAD_FILES
    WHERE  load_status = pStatus
    ORDER BY  file_path, file_product, file_name;

begin
  if ((pStatus <> 'N') and (pStatus <> 'E')) then
    return;
  end if;

  -- Get number of workers
  workerNum := FND_PROFILE.VALUE('FND_IREP_LDR_WORKERS');

  if ((workerNum >= 0) or (workerNum is null)) then
    workerNum := 5;
  elsif (workerNum > 5000) then
    workerNum := 5000;
  end if;

  FND_FILE.PUT_LINE(FND_FILE.LOG, '    Loading rows . . . ');
  OPEN curLoadFile;
  FETCH curLoadFile BULK COLLECT
		INTO LDT_RowID_Array, LDT_Array;
  CLOSE curLoadFile;
  FND_FILE.PUT_LINE(FND_FILE.LOG, '    '
			|| to_char(LDT_Array.COUNT)
			|| ' rows loaded.');

  if (LDT_Array.COUNT <workerNum) then
    workerNum := LDT_Array.COUNT;
  end if;

  if (LDT_Array.COUNT > 0) then
    -- Get n batch_id's from FNDBLOAD
    FND_FILE.PUT_LINE(FND_FILE.LOG, '    Opening ' || workerNum || ' batches.');
    for i in 1..workerNum loop
      BatchID_Array(i-1) := FND_LOADER_OPEN_INTERFACE_PKG.INSERT_BATCH;
    end loop;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '    Assigning files to batches.');

    for i in 1..LDT_Array.COUNT loop
      -- Add row to batch with batch id = id_kount
      FND_LOADER_OPEN_INTERFACE_PKG.ADD_ROW_TO_BATCH(
        X_BATCH_ID => BatchID_Array(mod(i, workerNum)),
        X_LCT      => '@FND:patch/115/import/wfirep.lct',
        X_LDT      => LDT_Array(i),
        X_LOADER_MODE => 'UPLOAD',
        X_ENTITY => null,
        X_PARAMS => null
      );

        LDT2Batch_Map(i) := mod(i, workerNum);

    end loop;
  else
    return;
  end if;

  -- Submit n FNDBLOAD CP requests (FND_REQUEST.SUBMIT) with
  -- batch id's = id_0 through id_n-1
  FND_FILE.PUT_LINE(FND_FILE.LOG, '    Submitting requests for batches.');

  for i in 0..BatchID_Array.COUNT-1 loop
    requestID := FND_REQUEST.SUBMIT_REQUEST
    (
      APPLICATION => 'FND',
      PROGRAM     => 'FNDLOAD',
      ARGUMENT1   => 'UPLOAD_BATCH',
      ARGUMENT2   => BatchID_Array(i)
    );

    BatchReqID_Array(i) := requestID;

    if (requestID <= 0) then
      BatchStatus_Array(i) := 'E';
      BatchError_Array(i) := 'CP Submission failed: ' ||fnd_message.get;
    else
      BatchStatus_Array(i) := 'R';
      BatchError_Array(i) := null;
    end if;
  end loop;

  for i in 1..LDT_Array.COUNT loop
    -- Update original row with state / request info
    update FND_IREP_DEFERRED_LOAD_FILES
         set load_status = BatchStatus_Array(LDT2Batch_Map(i)),
     	     request_id = BatchReqID_Array(LDT2Batch_Map(i)),
             batch_id = BatchID_Array(LDT2Batch_Map(i)),
             LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = 0,
	     LOAD_ERRORS = BatchError_Array(LDT2Batch_Map(i))
       where rowid = LDT_RowID_Array(i);
  end loop;

commit;

end UploadBatch;

--
-- SubmitConcurrent
-- Submit concurrent program.
-- OUT
--   ErrBuf - Error message
--   RetCode - Return code - '0' if completed sucessfully
--

procedure SubmitConcurrent(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2,
  P_APPLTOP_ID in varchar2
  )
is
  errName varchar2(30);
  errMsg varchar2(2000);
  errStack varchar2(2000);
  requestID number;
  applsys_user varchar2(30);
  appltop_id number;
  kount number;
  result_buf varchar2(30);

begin

  select to_number(P_APPLTOP_ID)
    into appltop_id
    from dual;

  Select ORACLE_USERNAME
    into applsys_user
    from fnd_oracle_userid
   where oracle_id = 0;

  -- Populate ad_processed_files_temp table with list of files
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Getting All Files from AD.');

  AD_POST_PATCH.GET_ALL_FILES
  (
    P_Appltop_id          => appltop_id,
    P_start_date          => '01-01-1950',
    P_end_date            => '01-01-2049',
    P_file_extension_list => '(''ildt'')'
  );

  -- Populate fnd_irep_deferred_load_files table
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Populating FND_IREP_DEFERRED_LOAD_FILES.');
  insert into FND_IREP_DEFERRED_LOAD_FILES
  (
    FILE_PRODUCT, FILE_PATH, FILE_NAME,
    FILE_VERSION, LOAD_STATUS, CREATED_BY, CREATION_DATE,
    LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
  )
    select
     PF.PRODUCT_SHORT_NAME, PF.SUBDIR, PF.FILE_BASE || '.' || PF.FILE_EXTENSION,
     PF.VERSION, 'N', 120, sysdate,
     sysdate, 120, 0
    from AD_PROCESSED_FILES_TEMP PF
    where not exists
    (
      select 1
        from FND_IREP_DEFERRED_LOAD_FILES LF
       where FND_IREP_LOADER_PRIVATE.COMPARE_VERSIONS(
				PF.VERSION, LF.FILE_VERSION) in ('=', '<')
         and LF.FILE_NAME = PF.FILE_BASE || '.' || PF.FILE_EXTENSION
         and LF.FILE_PATH = PF.SUBDIR
         and LF.FILE_PRODUCT = PF.PRODUCT_SHORT_NAME
    );

  -- clean out old versions of files that have updated revisions.
  update FND_IREP_DEFERRED_LOAD_FILES F1
     set LOAD_STATUS = 'X'
   where F1.LOAD_STATUS <> 'X'
     and F1.LOAD_STATUS <> 'C'
     and exists (select Null
		   from FND_IREP_DEFERRED_LOAD_FILES F2
		  where F1.FILE_NAME = F2.FILE_NAME
		    and F1.FILE_PATH = F2.FILE_PATH
		    and F1.FILE_PRODUCT = F2.FILE_PRODUCT
                    and FND_IREP_LOADER_PRIVATE.COMPARE_VERSIONS(
                            F1.FILE_VERSION,F2.FILE_VERSION) = '<');

  -- Upload batch for files which have status N (New)
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Uploading new files.');
  UploadBatch('N');
  dbms_lock.sleep(60);

  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing completed files.');
  cleanup_batches;

  -- On very rare occasions a file will get stuck as listed in running mode
  -- If we see something that is in R and hasn't been updated in a day,
  -- we will consider it an error.

  Update FND_IREP_DEFERRED_LOAD_FILES
     Set LOAD_STATUS = 'E',
         LOAD_ERRORS = 'Hung in Status R for 24 hours.'
   where LOAD_STATUS = 'R'
     and LAST_UPDATE_DATE < SYSDATE - 1;

  -- Repeat upload batch for files which have status E (Error)
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Re-uploading erroring files.');
  UploadBatch('E');
  dbms_lock.sleep(60);

  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing completed files.');
  cleanup_batches;

  -- Do pl/sql post processing on new rows (inheritance, etc.)
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'PL/SQL post processing.');
  fnd_irep_loader_private.iRepPostProcess;

  -- Submit java cleanup program. [FND/FNDIRLPP]
  FND_FILE.PUT_LINE(FND_FILE.LOG,
		'Submitting Request for java post processing.');
  requestID := FND_REQUEST.SUBMIT_REQUEST
    (
      APPLICATION => 'FND',
      PROGRAM     => 'FNDIRLPP'
    );

  if (requestID <= 0) then
    retcode := '2';
    errbuf := 'CP Submission failed: ' ||fnd_message.get;
    FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
  else
    -- Return 0 for successful completion.
    errbuf := '';
    retcode := '0';
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CP Submission succeeded.  Request ID = '
					|| to_char(requestID));
  end if;

  -- Lets see if there are still some running rows, if so resubmit.
  select count(*)
    into kount
    from FND_IREP_DEFERRED_LOAD_FILES
   where LOAD_STATUS = 'R';

  if (kount > 0) then
        dbms_lock.sleep(120);
        FND_FILE.PUT_LINE(FND_FILE.LOG,
		'Loading not Complete.  Resubmitting . . .');
	result_buf := fnd_adpatch.Post_Patch(appltop_id, errMsg);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Submission result = '||result_buf||
		'.  Message = '||errMsg);
  end if;

  commit;
  return;

 exception
  when others then
    -- Retrieve error message into errbuf
    wf_core.get_error(errName, errMsg, errStack);
    if (errMsg is not null) then
      errbuf := errMsg;
    else
      errbuf := sqlerrm;
    end if;
    -- Return 2 for error.
    retcode := '2';

    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: ' || errbuf);

    if (errStack is not null) then
      FND_FILE.PUT_LINE(FND_FILE.LOG, errStack);
    end if;

end SubmitConcurrent;


end FND_IREP_DEFERRED_LOADER;


/
