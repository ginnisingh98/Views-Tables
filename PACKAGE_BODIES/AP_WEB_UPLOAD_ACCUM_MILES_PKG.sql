--------------------------------------------------------
--  DDL for Package Body AP_WEB_UPLOAD_ACCUM_MILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_UPLOAD_ACCUM_MILES_PKG" AS
/* $Header: apwacmub.pls 120.2.12010000.2 2009/09/11 09:26:08 meesubra ship $ */
   -- ---------------------------------------------------
   -- Procedure     PutLine
   -- Description   Used for logging
   --
   -- ----------------------------------------------------
   PROCEDURE PutLine(p_buff IN VARCHAR2) IS
   BEGIN
      fnd_file.put_line(fnd_file.log, p_buff);
   END PutLine;

   -- --------------------------------------------------------
   -- Procedure     OpenDataFile
   -- Description   Opens a given data file
   --
   --
   -- ---------------------------------------------------------
   PROCEDURE OpenDataFile(P_DataFile      IN VARCHAR2,
                          P_FileHandle    OUT NOCOPY utl_file.file_type,
                          P_ErrorBuffer   OUT NOCOPY VARCHAR2,
                          P_ReturnCode    OUT NOCOPY NUMBER) IS
      l_DatafilePath	VARCHAR2(240);
      l_Datafile		VARCHAR2(240);
      l_DatafilePtr		utl_file.file_type;
      l_Ntdir			NUMBER;
      l_Unixdir		    NUMBER;
   BEGIN

       IF ( g_DebugSwitch = 'Y' ) THEN
       -- ----------- Begin Loggin ------------------
          PutLine('Begin OpenDataFile ( ' || P_DataFile || ' )');
       -- ----------- End Logging -------------------
       END IF;

       l_NtDir := instrb(P_DataFile, '\', -1);
       l_UnixDir := instrb(P_DataFile, '/', -1);
       IF (l_NtDir > 0) THEN
          l_DatafilePath := substrb(P_Datafile, 0, l_NtDir-1);
          l_Datafile := substrb(P_DataFile, l_NtDir+1);
       ELSIF (l_unixdir > 0) THEN
          l_DatafilePath := substrb(P_DataFile, 0, l_UnixDir-1);
          l_Datafile := substrb(P_DataFile, l_UnixDir+1);
       ELSE
          l_DatafilePath := '';
          l_Datafile := P_DataFile;
       END IF;

       IF ( g_DebugSwitch = 'Y' ) THEN
          -- --------- Begin logging ----------------------
          PutLine('------------ Begin File Breakup Info ----------------');
          PutLine('  l_NtDir: '|| to_char(l_NtDir));
          PutLine('  l_UnixDir: '|| to_char(l_UnixDir));
          PutLine('  l_DatafilePath: '|| l_DatafilePath);
          PutLine('  l_Datafile: '|| l_Datafile);
          PutLine('------------ End File Breakup Info ------------------');
          -- --------- End logging -------------------------
       END IF;

       --
       -- Open the datafile for read
       P_FileHandle := utl_file.fopen(l_DatafilePath, l_Datafile, 'r');
       P_ReturnCode := 0;

       EXCEPTION
          WHEN OTHERS THEN
             utl_file.fclose(l_datafileptr);
             fnd_message.set_name('AK', 'AK_INVALID_FILE_OPERATION');
             fnd_message.set_token('PATH', l_datafilepath);
             fnd_message.set_token('FILE', l_datafile);
             P_ErrorBuffer := fnd_message.get();
             P_ReturnCode  := 2;

   END OpenDataFile;

   -- ---------------------------------------------------------
   -- Procedure      CloseDataFile
   -- Descrition     Closes a data file for a given handle
   --
   -- ---------------------------------------------------------
   PROCEDURE CloseDataFile(P_FileHandle IN utl_file.file_type) IS
      l_FileHandle     utl_file.FILE_TYPE;
   BEGIN

       IF ( g_DebugSwitch = 'Y' ) THEN
          -- ----------- Begin Loggin ------------------
          PutLine('Begin CloseDataFile');
          -- ----------- End Logging -------------------
       END IF;

       l_FileHandle := P_FileHandle;
       utl_file.fclose(l_FileHandle);

   END CloseDataFile;


   -- -----------------------------------------------------------
   -- Function     GetEmployeeId
   -- Description  Returns employee id for an employee number if
   --              employee is active; else returns -1
   --
   -- ------------------------------------------------------------
   FUNCTION GetEmployeeId ( P_EmployeeNum IN VARCHAR2,
                            P_OrgId       IN NUMBER) RETURN NUMBER IS
      l_EmployeeId NUMBER;

   BEGIN

      SELECT employee_id
      INTO   l_EmployeeId
      FROM (
         SELECT h.employee_id
         FROM  per_employees_current_x h,
               financials_system_params_all f
         WHERE h.employee_num = P_EmployeeNum
         AND   AP_WEB_DB_HR_INT_PKG.isPersonCwk(h.employee_id)='N'
         AND   h.business_group_id = f.business_group_id
         AND   f.org_id = P_OrgId
         UNION ALL
         SELECT h.person_id employee_id
         FROM  PER_CONT_WORKERS_CURRENT_X h,
               financials_system_params_all f
         WHERE h.npw_number = P_EmployeeNum
         AND   h.business_group_id = f.business_group_id
         AND   f.org_id = P_OrgId
           );

      RETURN l_EmployeeId;

      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            RETURN -2;
         WHEN OTHERS THEN
            RETURN -1;

   END GetEmployeeId;


   -- -----------------------------------------------------------------------
   -- Procedure      UploadAccumulatedMiles
   -- Description    Validates and uploads accumulated mileage for employees
   --
   --
   -- ------------------------------------------------------------------------
   PROCEDURE UploadAccumulatedMiles ( P_ErrorBuffer   OUT NOCOPY VARCHAR2,
                                      P_ReturnCode    OUT NOCOPY NUMBER,
                                      P_DataFile      IN VARCHAR2,
                                      P_OrgId         IN NUMBER,
                                      P_PeriodId      IN NUMBER,
                                      P_UOM           IN VARCHAR2,
                                      P_DebugSwitch   IN VARCHAR2) IS
      -- Enter the procedure variables here. As shown below
      l_RequestId     NUMBER;
      l_Result	      BOOLEAN;
      l_Status	      VARCHAR2(240);
      l_Message	      VARCHAR2(240);
      l_Errors        NUMBER;
      l_FileHandle    utl_file.FILE_TYPE;
      l_NumLines      NUMBER;
      l_RowIndex      NUMBER;
      l_NumRejected   NUMBER;
      l_Line          VARCHAR2(240);
      l_Length        NUMBER;
      l_DelimPos      NUMBER;
      l_EmployeeNum   VARCHAR2(30);
      l_EmployeeId    NUMBER;
      l_AccumMiles    NUMBER;
      l_ErrorLine     NUMBER;
      l_LastUpdatedBy NUMBER;
      l_LastUpdateLogin NUMBER;
      l_DmlErrors     EXCEPTION;
      l_InvalidFormat EXCEPTION;


      TYPE EmployeeIdTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE AccumMilesTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE EmployeeNumTabType IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
      TYPE InvalidEmpTabType IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

      l_EmployeeIdTab  EmployeeIdTabType;
      l_AccumMilesTab  AccumMilesTabType;
      l_EmployeeNumTab EmployeeNumTabType;
      l_InvalidEmpTab  InvalidEmpTabType;

   BEGIN

      g_DebugSwitch  := P_DebugSwitch;
      l_RequestId    := FND_GLOBAL.CONC_REQUEST_ID;
      l_LastUpdatedBy   := to_number(FND_GLOBAL.USER_ID);
      l_LastUpdateLogin := to_number(FND_GLOBAL.LOGIN_ID);

      PutLine('==========================================================================');
      PutLine(' REQUEST ID: '||l_RequestId);
      PutLine('==========================================================================');

      IF ( g_DebugSwitch = 'Y' ) THEN
      -- ----------- Begin Loggin ------------------
        PutLine('---------------  Begin UploadAccumulatedMiles ------------------');


        PutLine('------------------------------------------------------------');
        PutLine('--           P  A  R  A  M  E  T  E  R  S                 --');
        PutLine('------------------------------------------------------------');
        PutLine('File Name               : '||P_DataFile);
        PutLine('Organization Id         : '||P_OrgId);
        PutLine('Schedule Period Id      : '||P_PeriodId);
        PutLine('Distance Unit Of Measure: '||P_UOM);
        PutLine('Debug Switch            : '||P_DebugSwitch);
      -- ----------- End Logging -------------------
      END IF;

      -- Open the data file
      OpenDataFile(P_DataFile,
                   l_FileHandle,
                   l_Message,
                   l_Errors);

      IF ( l_Errors > 0  ) THEN
         P_ErrorBuffer   := l_Message;
         P_ReturnCode    := 2;
         --P_RequestStatus := 'FAILED';
         -- ----------- Logging ------------
         PutLine('Error opening file: '||l_Message);
         RETURN;
      END IF;

      l_NumLines := 0;
      l_NumRejected := 0;
      l_RowIndex := 0;

      LOOP
      BEGIN
         utl_file.get_line(l_FileHandle, l_Line);
         l_NumLines := l_NumLines + 1;
         l_Length := length(l_Line);

         l_DelimPos := instr(l_Line, ';', 1, 1);
         l_EmployeeNum := substr ( l_Line, 1,  l_DelimPos - 1 );
         l_AccumMiles := to_number( trim(substr ( l_Line, l_DelimPos + 1, l_Length - l_DelimPos)));

         -- If the mileage is stored in miles, we need to convert into
         -- km. Now, I am rounding to 2 digit precission but is this valid?
	 -- Wrong conversion used for SWMILES to KM - bug 8852462
         IF ( 'MILES' = P_UOM ) THEN
           l_AccumMiles := round(l_AccumMiles * 1.609, 2);
         ELSIF ( 'SWMILES' = P_UOM ) THEN
           l_AccumMiles := round(l_AccumMiles * 10 , 2);
         END IF;

         l_EmployeeId := GetEmployeeId (l_EmployeeNum, P_OrgId) ;

         -- If we found the employee id, then insert a row
         IF ( l_EmployeeId > -1 ) THEN
            -- Increment the index
            l_RowIndex := l_RowIndex + 1;

            -- Insert data
            l_EmployeeIdTab(l_RowIndex) := l_EmployeeId;
            l_AccumMilesTab(l_RowIndex) := l_AccumMiles;
            l_EmployeeNumTab(l_RowIndex) := l_EmployeeNum;

         ELSIF ( l_EmployeeId = -1 ) THEN
            l_NumRejected := l_NumRejected + 1;
            l_InvalidEmpTab(l_NumRejected) := rpad(l_EmployeeNum, 15,' ')||'    ERROR     No active employee found';
         ELSIF ( l_EmployeeId = -2 ) THEN
            l_NumRejected := l_NumRejected + 1;
            l_InvalidEmpTab(l_NumRejected) := rpad(l_EmployeeNum, 15,' ')||'    ERROR     Multiple employees found';
         END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXIT;
            WHEN OTHERS THEN
               RAISE l_InvalidFormat;
      END;
      END LOOP;

      -- Close the data file
      CloseDataFile(l_FileHandle);

      IF ( g_DebugSwitch = 'Y' ) THEN
         -- --------------------- Logging ------------------------------------
         PutLine('Completed reading data file. Begin processing data ....');
         -- ------------------------------------------------------------------
      END IF;

      -- If any of the rows were rejected because of invalid employee, record
      -- those in the log file.
      IF (l_NumRejected > 0 ) THEN
         PutLine('======================================================================');
         PutLine('Following data has not been loaded because it failed validation: ');
         PutLine('----------------------------------------------------------------------');
         PutLine('Employee Number    Status    Comments');
         PutLine('----------------------------------------------------------------------');

         FOR i IN 1..l_NumRejected LOOP
            PutLine(l_InvalidEmpTab(i));
         END LOOP;

         PutLine('======================================================================');

      END IF;

      IF ( g_DebugSwitch = 'Y' ) THEN
         -- ------------ Logging -------------------------------------------------------
         PutLine('Calling bulk insert for '||to_char(l_RowIndex)||' records ...');
         -- ----------------------------------------------------------------------------
      END IF;

      -- -----------------------------------------
      -- This is the buld insert call
      -- -----------------------------------------
      BEGIN
         FORALL i IN 1..l_RowIndex SAVE EXCEPTIONS

            INSERT INTO ap_web_employee_info_all
               (    employee_id,
          	    value_type,
	            numeric_value,
	            period_id,
	            creation_date,
	            created_by,
	            last_update_date,
	            last_updated_by,
                    last_update_login,
                    org_id)
            VALUES(    l_EmployeeIdTab(i),
	               'CUM_REIMB_DISTANCE',
	               l_AccumMilesTab(i),
	               P_PeriodId,
	               sysdate,
	               l_LastUpdatedBy,
	               sysdate,
	               l_LastUpdatedBy,
                       l_LastUpdateLogin,
                       P_OrgId );
         EXCEPTION
            WHEN OTHERS THEN
               l_Errors := SQL%BULK_EXCEPTIONS.COUNT;

               PutLine('======================================================================');
               PutLine('Errors reported during insert: ');
               PutLine('----------------------------------------------------------------------');
               PutLine('Employee Number    Accumulated Miles    Error');
               PutLine('----------------------------------------------------------------------');

               FOR i IN 1..l_Errors LOOP
                  l_ErrorLine := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
                  PutLine(rpad(l_EmployeeNumTab(l_ErrorLine),19)||
                           lpad(l_AccumMilesTab(l_ErrorLine),17)||
                           '    '||
                           SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
               END LOOP;
      END; -- end of bulk insert

      PutLine('=============================================================');
      PutLine('LOAD SUMMARY');
      PutLine('=============================================================');
      PutLine('Total number of records in file:'||lpad(l_NumLines, 10 ));
      PutLine('Number of loaded records       :'||lpad(l_NumLines -l_NumRejected -l_Errors, 10 ));
      PutLine('Number of invalid records      :'||lpad(l_NumRejected, 10 ));
      PutLine('Number of errored records      :'||lpad(l_Errors, 10 ));
      PutLine('=============================================================');

      -- Set the return status anc code
      P_ReturnCode    := 0;
      COMMIT;

      IF ( g_DebugSwitch = 'Y' ) THEN
         -- ----------- Begin Loggin ------------------
         PutLine('End UploadAccumulatedMiles');
         -- ----------- End Logging -------------------
      END IF;

   END UploadAccumulatedMiles;

END AP_WEB_UPLOAD_ACCUM_MILES_PKG;

/
