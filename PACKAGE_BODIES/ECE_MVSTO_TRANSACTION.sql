--------------------------------------------------------
--  DDL for Package Body ECE_MVSTO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_MVSTO_TRANSACTION" AS
-- $Header: ECEMVSOB.pls 120.2.12000000.2 2007/03/09 14:39:44 cpeixoto ship $

/*===========================================================================
  PROCEDURE NAME:      Extract_MVSTO_Outbound
  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible transactions.
===========================================================================*/

   PROCEDURE Extract_MVSTO_Outbound(errbuf         OUT NOCOPY  VARCHAR2,
                               retcode             OUT NOCOPY  VARCHAR2,
                               cOutput_Path        IN    VARCHAR2,
                               cOutput_Filename    IN    VARCHAR2,
                               cLegal_Entity       IN    VARCHAR2,
                               cZone_Code          IN    VARCHAR2,
                               cStat_Type          IN    VARCHAR2,
                               cPeriod_Name        IN    VARCHAR2,
                               cMovement_Type      IN    VARCHAR2,
                               cInclude_Address    IN    VARCHAR2 DEFAULT 'N',
                               v_debug_mode        IN    NUMBER   DEFAULT 0) IS

      xProgress                  VARCHAR2(80);
      iRun_id                    NUMBER               := 0;
      iOutput_width              INTEGER              :=  4000;
      cTransaction_Type          VARCHAR2(120)        := 'MVSTO';
      cCommunication_Method      VARCHAR2(120)        := 'EDI';
      cHeader_Interface          VARCHAR2(120)        := 'ECE_MVSTO_HEADERS';
      cLine_Interface            VARCHAR2(120)        := 'ECE_MVSTO_DETAILS';
      cLocation_Interface        VARCHAR2(120)        := 'ECE_MVSTO_LOCATIONS';
      l_line_text                VARCHAR2(2000);
      uFile_type                 utl_file.file_type;
      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;
      cFilename                  VARCHAR2(30)        := NULL;  --2430822

      CURSOR c_output IS
         SELECT   text
         FROM     ece_output
         WHERE    run_id = iRun_id
         ORDER BY line_id;

      BEGIN
         xProgress := 'MVSTO-10-1000';
         ec_debug.enable_debug(v_debug_mode);
         ec_debug.push ('ECE_MVSTO_TRANSACTION.Extract_MVSTO_Outbound');
         ec_debug.pl(3,'cOutput_Path: ',cOutput_Path);
         ec_debug.pl(3,'cOutput_Filename: ',cOutput_Filename);
         ec_debug.pl(3,'cLegal_Entity: ',cLegal_Entity);
         ec_debug.pl(3,'cZone_Code: ',cZone_Code);
         ec_debug.pl(3,'cStat_Type: ',cStat_Type);
         ec_debug.pl(3,'cPeriod_Name: ',cPeriod_Name);
         ec_debug.pl(3,'cMovement_Type: ',cMovement_Type);
         ec_debug.pl(3,'cInclude_Address: ',cInclude_Address);
         ec_debug.pl(3,'v_debug_mode: ',v_debug_mode);

         xProgress := 'MVSTO-10-1001';
         fnd_profile.get('ECE_' || cTransaction_Type || '_ENABLED',cEnabled);

         xProgress := 'MVSTO-10-1002';
         IF cEnabled = 'N' THEN
            xProgress := 'MVSTO-10-1003';
            RAISE ece_transaction_disabled;
         END IF;

         xProgress := 'MVSTO-10-1004';
         BEGIN
            SELECT   ece_output_runs_s.NEXTVAL
            INTO     iRun_id
            FROM     dual;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,
                              'EC',
                              'ECE_GET_NEXT_SEQ_FAILED',
                              'PROGRESS_LEVEL',
                              xProgress,
                              'SEQ',
                              'ECE_OUTPUT_RUNS_S');
         END;

         ec_debug.pl(3, 'iRun_id: ',iRun_id);

         xProgress := 'MVSTO-10-1005';
         ec_debug.pl(0,'EC','ECE_MVSTO_START',NULL);

    xProgress := 'MVSTO-10-1010';
    ec_debug.pl(0, 'EC', 'ECE_RUN_ID', 'RUN_ID', iRun_id);

    xProgress := 'MVSTO-10-1020';
    ece_mvsto_transaction.populate_mvsto_trx(cCommunication_Method,
                                         cTransaction_Type,
                                         iOutput_width,
                                         sysdate,
                                         iRun_id,
                                         cHeader_Interface,
                                         cLine_Interface,
                                         cLocation_Interface,
                                         cLegal_Entity,
                                         cZone_Code,
                                         cStat_Type,
                                         cPeriod_Name,
                                         cMovement_Type,
                                         cInclude_Address);

    xProgress := 'MVSTO-10-1030';
    ece_mvsto_transaction.put_data_to_output_table(cCommunication_Method,
                                                   cTransaction_Type,
                                                   iOutput_width,
                                                   iRun_id,
                                                   cHeader_Interface,
                                                   cLine_Interface,
                                                   cLocation_Interface);

     IF cOutput_Filename IS NULL THEN               --Bug 2430822
                   cFilename := 'MVSTO' || iRun_id || '.dat';
     ELSE
		   cFilename := cOutput_Filename;
     END IF;

    -- Open the file for write.

    xProgress := 'MVSTO-10-1040';

    -- Open the cursor to select the actual file output from ece_output.

    xProgress := 'MVSTO-10-1050';
    OPEN c_output;
    LOOP
      xProgress := 'MVSTO-10-1050';
      FETCH c_output
      INTO l_line_text;

      xProgress := 'MVSTO-10-1060';

      if (c_output%ROWCOUNT > 0) then
         if (NOT utl_file.is_open(uFile_type)) then
            uFile_type := UTL_FILE.fopen(cOutput_Path,
                                         cFilename,
                                         'W');
         end if;
      end if;
      EXIT WHEN c_output%NOTFOUND;
      ec_debug.pl(3, 'l_line_text: ',l_line_text);

      -- Write the data from ece_output to the output file.

      xProgress := 'MVSTO-10-1070';
      utl_file.put_line(uFile_type,
                          l_line_text);

    END LOOP;

    xProgress := 'MVSTO-10-1080';
    CLOSE c_output;

    -- Close the output file.

    xProgress := 'MVSTO-10-1090';
    if (utl_file.is_open( uFile_type)) then
    utl_file.fclose(uFile_type);
    end if;

    -- Assume everything went ok so delete the records from ece_output.

    DELETE
    FROM  ece_output
    WHERE run_id = iRun_id;

    IF SQL%NOTFOUND
    THEN
      ec_debug.pl(0,
                    'EC',
                    'ECE_NO_ROW_DELETED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'TABLE_NAME',
                    'ECE_OUTPUT');
    END IF;

   IF ec_mapping_utils.ec_get_trans_upgrade_status(cTransaction_Type)  = 'U' THEN
      ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
      retcode := 1;
   END IF;

   ec_debug.pl(0,'EC','ECE_MVSTO_END',NULL);
   ec_debug.pop('ECE_MVSTO_TRANSACTION.Extract_MVSTO_Outbound');
   ec_debug.disable_debug;
   COMMIT;

   EXCEPTION
      WHEN ece_transaction_disabled THEN
         ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',cTransaction_type);
         retcode := 2;
         ec_debug.disable_debug;
         ROLLBACK;
         RAISE;

    WHEN utl_file.write_error THEN
       ec_debug.pl(0,
                     'EC',
                     'ECE_UTL_WRITE_ERROR',
                     NULL);

       ec_debug.pl(0,
                     'EC',
                     'ECE_ERROR_MESSAGE',
                     'ERROR_MESSAGE',
                     SQLERRM);

       retcode := 2;
       ec_debug.disable_debug;
       ROLLBACK;
       RAISE;

    WHEN utl_file.invalid_path THEN

       ec_debug.pl(0,
                     'EC',
                     'ECE_UTIL_INVALID_PATH',
                     NULL);

       ec_debug.pl(0,
                     'EC',
                     'ECE_ERROR_MESSAGE',
                     'ERROR_MESSAGE',
                     SQLERRM);

       retcode := 2;
       ec_debug.disable_debug;
       ROLLBACK;
       RAISE;

    WHEN utl_file.invalid_operation THEN

       ec_debug.pl(0,
                     'EC',
                     'ECE_UTIL_INVALID_OPERATION',
                     NULL);

       ec_debug.pl(0,
                     'EC',
                     'ECE_ERROR_MESSAGE',
                     'ERROR_MESSAGE',
                     SQLERRM);

       retcode := 2;
       ec_debug.disable_debug;
       ROLLBACK;
       RAISE;

    WHEN OTHERS THEN
       ec_debug.pl(0,
                     'EC',
                     'ECE_PROGRAM_ERROR',
                     'PROGRESS_LEVEL',
                     xProgress);
       ec_debug.pl(0,
                     'EC',
                     'ECE_ERROR_MESSAGE',
                     'ERROR_MESSAGE',
                     SQLERRM);

       retcode := 2;
       ec_debug.disable_debug;
       ROLLBACK;
       RAISE;

  END Extract_MVSTO_Outbound;


  -- PROCEDURE POPULATE_MVSTO_TRX
  -- This procedure has the following functionalities:
  -- 1. Build SQL statement dynamically to extract data from
  --    Base Application Tables.
  -- 2. Execute the dynamic SQL statement.
  -- 3. Assign data into 2-dim PL/SQL table
  -- 4. Pass data to the code conversion mechanism
  -- 5. Populate the Interface tables with the extracted data.

  PROCEDURE POPULATE_MVSTO_TRX(cCommunication_Method   IN VARCHAR2,
                               cTransaction_Type       IN VARCHAR2,
                               iOutput_width           IN INTEGER,
                               dTransaction_date       IN DATE,
                               iRun_id                 IN INTEGER,
                               cHeader_Interface       IN VARCHAR2,
                               cLine_Interface         IN VARCHAR2,
                               cLocation_Interface     IN VARCHAR2,
                               cLegal_Entity           IN    VARCHAR2,
                               cZone_Code          IN    VARCHAR2,
                               cStat_Type          IN    VARCHAR2,
                               cPeriod_Name        IN    VARCHAR2,
                               cMovement_Type      IN    VARCHAR2,
                               cInclude_Address    IN    VARCHAR2)
  IS

      xProgress                  VARCHAR2(30);
      v_LevelProcessed           VARCHAR2(40);


      l_header_tbl               ece_flatfile_pvt.Interface_tbl_type;
      l_line_tbl                 ece_flatfile_pvt.Interface_tbl_type;
      l_location_tbl                 ece_flatfile_pvt.Interface_tbl_type;
      l_key_tbl                  ece_flatfile_pvt.Interface_tbl_type;

      Header_sel_c               INTEGER;
      Line_sel_c                 INTEGER;
      Location_sel_c             INTEGER;

      cHeader_select             VARCHAR2(32000);
      cLine_select               VARCHAR2(32000);
      cLocation_select           VARCHAR2(32000);

      cHeader_from               VARCHAR2(32000);
      cLine_from                 VARCHAR2(32000);
      cLocation_from             VARCHAR2(32000);

      cHeader_where              VARCHAR2(32000);
      cLine_where                VARCHAR2(32000);
      cLocation_where            VARCHAR2(32000);

      iHeader_count              NUMBER := 0;
      iLine_count                NUMBER := 0;
      iLocation_count            NUMBER := 0;
      iKey_count                 NUMBER := 0;

      l_header_fkey              NUMBER;
      l_line_fkey                NUMBER;
      l_location_fkey            NUMBER;

      nHeader_key_pos            NUMBER;
      nLine_key_pos              NUMBER;
      nLocation_key_pos          NUMBER;
      nLine_head_pos             NUMBER;
      nLoc_head_pos              NUMBER;
      nLoc_line_pos              NUMBER;
      nEdi_TransRef_pos          NUMBER;

      dummy                      INTEGER;
      n_trx_date_pos             NUMBER;
      nBill_To_Site_pos          NUMBER;
      nShip_To_Site_pos          NUMBER;
      nVendor_Site_pos           NUMBER;
      n_movement_id              NUMBER;
      v_YesFlag                  VARCHAR2(1) := 'Y';
      v_EdiTransactionRef        VARCHAR2(35);

      init_msg_list              VARCHAR2(20);
      simulate                   VARCHAR2(20);
      validation_level           VARCHAR2(20);
      commt                      VARCHAR2(20);
      return_status              VARCHAR2(20);
      msg_count                  VARCHAR2(20);
      msg_data                   VARCHAR2(20);

  BEGIN

    ec_debug.push('ECE_MVSTO_TRANSACTION.POPULATE_MVSTO_TRX');
    ec_debug.pl(3, 'cCommunication_Method: ', cCommunication_Method);
    ec_debug.pl(3, 'cTransaction_Type: ',cTransaction_Type);
    ec_debug.pl(3, 'iOutput_width: ',iOutput_width);
    ec_debug.pl(3, 'dTransaction_date: ',dTransaction_date);
    ec_debug.pl(3, 'iRun_id: ',iRun_id);
    ec_debug.pl(3, 'cHeader_Interface: ',cHeader_Interface);
    ec_debug.pl(3, 'cLine_Interface: ',cLine_Interface);
    ec_debug.pl(3, 'cLocation_Interface: ',cLocation_Interface);
    ec_debug.pl(3,'cLegal_Entity: ',cLegal_Entity);
    ec_debug.pl(3,'cZone_Code: ',cZone_Code);
    ec_debug.pl(3,'cStat_Type: ',cStat_Type);
    ec_debug.pl(3,'cPeriod_Name: ',cPeriod_Name);
    ec_debug.pl(3,'cMovement_Type: ',cMovement_Type);
    ec_debug.pl(3,'cInclude_Address: ',cInclude_Address);

/* build the EDI Transaction Reference value */
    v_EdiTransactionRef := substrb(cLegal_Entity,1,14) || '-' ||
                           substrb(cZone_Code,1,1)          || '-' ||
                           substrb(cPeriod_Name,1,3)        || '-' ||
                           substrb(cStat_Type,1,6)          || '-' ||
                           substrb(CMovement_Type,1,2);

    xProgress  := 'MVSTOB-20-1010';
    ece_flatfile_pvt.INIT_TABLE(cTransaction_Type,
                                  cHeader_Interface,
                                  NULL,
                                  FALSE,
                                  l_header_tbl,
                                  l_key_tbl);

    xProgress  := 'MVSTOB-20-1020';
    l_key_tbl  := l_header_tbl;

    xProgress  := 'MVSTOB-20-1025';
    iKey_count := l_header_tbl.COUNT;

    xProgress  := 'MVSTOB-20-1030';
    ece_flatfile_pvt.INIT_TABLE(cTransaction_Type,
                                  cLine_Interface,
                                  NULL,
                                  TRUE,
                                  l_Line_tbl,
                                  l_key_tbl);

    xProgress  := 'MVSTOB-20-1040';
    ece_flatfile_pvt.INIT_TABLE(cTransaction_Type,
                                  cLocation_Interface,
                                  NULL,
                                  TRUE,
                                  l_Location_tbl,
                                  l_key_tbl);

    -- ****************************************************************************
    -- Here, I am building the SELECT, FROM, and WHERE  clauses for the dynamic SQL
    -- call. The ece_extract_utils_pub.select_clause uses the EDI data dictionary
    -- for the build.
    -- ****************************************************************************

    xProgress := 'MVSTOB-20-1050';
    ece_extract_utils_pub.select_clause(cTransaction_Type,
                                          cCommunication_Method,
                                          cHeader_Interface,
                                          l_header_tbl,
                                          cHeader_select,
                                          cHeader_from,
                                          cHeader_where);

    xProgress := 'MVSTOB-20-1060';
    ece_extract_utils_pub.select_clause(cTransaction_Type,
                                          cCommunication_Method,
                                          cLine_Interface,
                                          l_line_tbl,
                                          cLine_select,
                                          cLine_from,
                                          cLine_where);

   xProgress := 'MVSTOB-20-1070';
    ece_extract_utils_pub.select_clause(cTransaction_Type,
                                          cCommunication_Method,
                                          cLocation_Interface,
                                          l_location_tbl,
                                          cLocation_select,
                                          cLocation_from,
                                          cLocation_where);

   xProgress := 'MVSTOB-20-1080';
    cHeader_where := cHeader_where                                 ||
                     'ece_mvsto_headers_v.communication_method ='  ||
		     ''''					   ||
                     cCommunication_Method			   || --3009582
		     '''';

    xProgress := 'MVSTOB-20-1090';
    IF cLegal_Entity IS NOT NULL THEN
       cHeader_where := cHeader_where                                ||
                        ' AND '                                      ||
                        'ece_mvsto_headers_v.entity_org_id ='        ||
                        ':l_cLegal_Entity';
    END IF;

    xProgress := 'MVSTOB-20-1100';
    IF cZone_Code IS NOT NULL THEN
       cHeader_where := cHeader_where                        ||
                        ' AND '                              ||
                        'ece_mvsto_headers_v.zone_code ='    ||
                        ':l_cZone_Code';

    END IF;


    xProgress := 'MVSTOB-20-1110';
    IF cStat_Type IS NOT NULL THEN
       cHeader_where := cHeader_where                        ||
                        ' AND '                              ||
                        'ece_mvsto_headers_v.stat_type ='    ||
                        ':l_cStat_Type';
    END IF;


    xProgress := 'MVSTOB-20-1120';
    IF cPeriod_Name IS NOT NULL THEN
       cHeader_where := cHeader_where                          ||
                        ' AND '                                ||
                        'ece_mvsto_headers_v.period_name ='    ||
                        ':l_cPeriod_Name';

    END IF;


    xProgress := 'MVSTOB-20-1130';
    IF cMovement_Type IS NOT NULL THEN
       cHeader_where := cHeader_where                           ||
                        ' AND '                                 ||
                        'ece_mvsto_headers_v.movement_type ='   ||
                        ':l_cMovement_Type';

    END IF;

   xProgress := 'MVSTOB-20-1140';
    IF cLegal_Entity IS NOT NULL THEN
       cLine_where := cLine_where                                    ||
                        'ece_mvsto_details_v.entity_org_id ='        ||
                        ':l_cLegal_Entity';

    END IF;

    xProgress := 'MVSTOB-20-1150';
    IF cZone_Code IS NOT NULL THEN
       cLine_where := cLine_where                               ||
                        ' AND '                                 ||
                        'ece_mvsto_details_v.zone_code ='       ||
                        ':l_cZone_Code';

    END IF;

   xProgress := 'MVSTOB-20-1160';
    IF cStat_Type IS NOT NULL THEN
       cLine_where := cLine_where                               ||
                        ' AND '                                 ||
                        'ece_mvsto_details_v.stat_type ='       ||
                        ':l_cStat_Type';

    END IF;


    xProgress := 'MVSTOB-20-1170';
    IF cPeriod_Name IS NOT NULL THEN
       cLine_where := cLine_where                               ||
                        ' AND '                                 ||
                        'ece_mvsto_details_v.period_name ='     ||
                        ':l_cPeriod_Name';

    END IF;


    xProgress := 'MVSTOB-20-1180';
    IF cMovement_Type IS NOT NULL THEN
       cLine_where := cLine_where                               ||
                        ' AND '                                 ||
                        'ece_mvsto_details_v.movement_type ='   ||
                        ':l_cMovement_Type';

    END IF;

    xProgress := 'MVSTOB-20-1185';
    cLocation_where := cLocation_where                                          ||
     ' ECE_MVSTO_LOCATIONS_V.BILL_TO_SITE_USE_ID(+) = :bill_to_site_use_id AND' ||
     ' ECE_MVSTO_LOCATIONS_V.SHIP_TO_SITE_USE_ID(+) = :ship_to_site_use_id AND' ||
     ' ECE_MVSTO_LOCATIONS_V.VENDOR_CODE_INT(+) = :vendor_site_id AND ' ||
     '''' || v_YesFlag || ''''|| ' = :l_cInclude_Address';


    xProgress := 'MVSTOB-20-1190';
    cHeader_select   := cHeader_select              ||
                        cHeader_from                ||
                        cHeader_where;
    ec_debug.pl(3, 'cHeader_select: ',cHeader_select);

    cLine_select     := cLine_select                ||
                        cLine_from                  ||
                        cLine_where;
    ec_debug.pl(3, 'cLine_select: ',cLine_select);

    cLocation_select     := cLocation_select        ||
                        cLocation_from              ||
                        cLocation_where;
    ec_debug.pl(3, 'cLocation_select: ',cLocation_select);

    -- ***************************************************
    -- ***   Get data setup for the dynamic SQL call.
    -- ***   Open a cursor for each of the SELECT call
    -- ***   This tells the database to reserve spaces
    -- ***   for the data returned by the SQL statement
    -- ***************************************************

    xProgress      := 'MVSTOB-20-1200';
    Header_sel_c   := DBMS_SQL.OPEN_CURSOR;

    xProgress      := 'MVSTOB-20-1210';
    Line_sel_c     := DBMS_SQL.OPEN_CURSOR;

    xProgress      := 'MVSTOB-20-1220';
    Location_sel_c     := DBMS_SQL.OPEN_CURSOR;
    -- ***************************************************
    -- Parse each of the SELECT statement
    -- so the database understands the command

    -- ***************************************************
    xProgress := 'MVSTOB-20-1230';
    BEGIN
       DBMS_SQL.PARSE(Header_sel_c,
                        cHeader_select,
                        DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ECE_ERROR_HANDLING_PVT.print_parse_error(dbms_sql.last_error_position,
                                                   cHeader_select);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-20-1240';
    BEGIN
       DBMS_SQL.PARSE(Line_sel_c,
                        cLine_select,
                        DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ECE_ERROR_HANDLING_PVT.print_parse_error(dbms_sql.last_error_position,
                                                   cLine_select);
        app_exception.raise_exception;
    END;

   xProgress := 'MVSTOB-20-1250';
    BEGIN
       DBMS_SQL.PARSE(Location_sel_c,
                        cLocation_select,
                        DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ECE_ERROR_HANDLING_PVT.print_parse_error(dbms_sql.last_error_position,
                                                   cLocation_select);
        app_exception.raise_exception;
    END;


    -- ************
    -- set counter
    -- ************

    xProgress       := 'MVSTOB-20-1260';
    iHeader_count   := l_header_tbl.COUNT;

    xProgress       := 'MVSTOB-20-1270';
    iLine_count     := l_line_tbl.COUNT;

    xProgress       := 'MVSTOB-20-1280';
    iLocation_count     := l_location_tbl.COUNT;
    -- ******************************************************
    --  Define TYPE for every columns in the SELECT statement
    --  For each piece of the data returns, we need to tell
    --  the database what type of information it will be.
    --  e.g. ID is NUMBER, due_date is DATE
    --  However, for simplicity, we will convert
    --  everything to varchar2.
    -- ******************************************************

    xProgress := 'MVSTOB-20-1290';
    ece_flatfile_pvt.DEFINE_INTERFACE_COLUMN_TYPE(Header_sel_c,
                                                    cHeader_select,
                                                    ece_extract_utils_PUB.G_MaxColWidth,
                                                    l_Header_tbl);

    xProgress := 'MVSTOB-20-1300';
    ece_flatfile_pvt.DEFINE_INTERFACE_COLUMN_TYPE(Line_sel_c,
                                                    cLine_select,
                                                    ece_extract_utils_PUB.G_MaxColWidth,
                                                    l_Line_tbl);

    xProgress := 'MVSTOB-20-1310';
    ece_flatfile_pvt.DEFINE_INTERFACE_COLUMN_TYPE(Location_sel_c,
                                                    cLocation_select,
                                                    ece_extract_utils_PUB.G_MaxColWidth,
                                                    l_Location_tbl);

    -- **************************************************************
    -- ***  The following is custom tailored for this transaction
    -- ***  It find the values and use them in the WHERE clause to
    -- ***  join tables together.
    -- **************************************************************

    -- ***************************************************
    -- To complete the Line SELECT statement,
    --  we will need values for the join condition.
    -- ***************************************************

    xProgress := 'MVSTOB-20-1320';
    ece_extract_utils_pub.Find_pos(l_header_tbl,
                                    ece_extract_utils_pub.G_Transaction_date,
                                    n_trx_date_pos);
    ec_debug.pl(3, 'n_trx_date_pos: ', n_trx_date_pos);

    -- Bind the Variables
    xProgress := 'MVSTOB-20-1320';
    IF cLegal_Entity IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Header_sel_c,
                               'l_cLegal_Entity',
                               cLegal_Entity);
    END IF;

    xProgress := 'MVSTOB-20-1321';
    IF cZone_Code IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Header_sel_c,
                               'l_cZone_Code',
                               cZone_Code);
    END IF;

    xProgress := 'MVSTOB-20-1322';
    IF cStat_Type IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Header_sel_c,
                               'l_cStat_Type',
                               cStat_Type);
    END IF;

    xProgress := 'MVSTOB-20-1323';
    IF cPeriod_Name IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Header_sel_c,
                               'l_cPeriod_Name',
                               cPeriod_Name);
    END IF;

    xProgress := 'MVSTOB-20-1324';
    IF cMovement_Type IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Header_sel_c,
                               'l_cMovement_Type',
                               cMovement_Type);
    END IF;

    xProgress := 'MVSTOB-20-1325';
    IF cLegal_Entity IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Line_sel_c,
                               'l_cLegal_Entity',
                               cLegal_Entity);
    END IF;

    xProgress := 'MVSTOB-20-1326';
    IF cZone_Code IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Line_sel_c,
                               'l_cZone_Code',
                               cZone_Code);
    END IF;

    xProgress := 'MVSTOB-20-1327';
    IF cStat_Type IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Line_sel_c,
                               'l_cStat_Type',
                               cStat_Type);
    END IF;

    xProgress := 'MVSTOB-20-1328';
    IF cPeriod_Name IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Line_sel_c,
                               'l_cPeriod_Name',
                               cPeriod_Name);
    END IF;

    xProgress := 'MVSTOB-20-1329';
    IF cMovement_Type IS NOT NULL THEN
	DBMS_SQL.BIND_VARIABLE(Line_sel_c,
                               'l_cMovement_Type',
                               cMovement_Type);
    END IF;

    -- EXECUTE the SELECT statement

    xProgress := 'MVSTOB-20-1400';
    dummy := DBMS_SQL.EXECUTE(Header_sel_c);

    -- ***************************************************
    -- The model is:
    -- HEADER - LINE - LOCATION...
    -- With data for each HEADER line, populate the header
    -- interfacetable then get all DETAILS that belongs
    -- to the HEADER. Then get all the locations that belong
    -- to the line.
    -- ***************************************************

    xProgress := 'MVSTOB-20-1410';
    WHILE DBMS_SQL.FETCH_ROWS(Header_sel_c) > 0
    LOOP           -- Header

      -- **************************************
      --  store internal values in pl/sql table
      -- **************************************

      xProgress := 'MVSTOB-20-1420';
      ece_flatfile_pvt.ASSIGN_COLUMN_VALUE_TO_TBL(Header_sel_c,
                                                    0,
                                                    l_header_tbl,
                                                    l_key_tbl);

      -- ***************************************************
      --  also need to populate transaction_date and run_id
      -- ***************************************************

      xProgress := 'MVSTOB-20-1430';
      l_header_tbl(n_trx_date_pos).value := TO_CHAR(dTransaction_date,'YYYYMMDD HH24MISS');

      -- pass the pl/sql table in for xref

      xProgress := 'MVSTOB-20-1460';
      ec_code_Conversion_pvt.populate_plsql_tbl_with_extval(p_api_version_number => 1.0,
                                                              p_init_msg_list      => init_msg_list,
                                                              p_simulate           => simulate,
                                                              p_commit             => commt,
                                                              p_validation_level   => validation_level,
                                                              p_return_status      => return_status,
                                                              p_msg_count          => msg_count,
                                                              p_msg_data           => msg_data,
                                                              p_key_tbl            => l_key_tbl,
                                                              p_tbl                => l_header_tbl);

      -- ***************************
      -- insert into interface table
      -- ***************************

      xProgress := 'MVSTOB-20-1480';
      BEGIN
        SELECT   ece_MVSTO_headers_s.NEXTVAL
        INTO     l_header_fkey
        FROM     DUAL;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl(0,
                      'EC',
                      'ECE_GET_NEXT_SEQ_FAILED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'SEQ',
                      'ECE_MVSTO_HEADER_S');
      END;
      ec_debug.pl(3, 'l_header_fkey: ',l_header_fkey);

      xProgress := 'MVSTOB-20-1490';
      ece_Extract_Utils_PUB.insert_into_interface_tbl(iRun_id,
                                                        cTransaction_Type,
                                                        cCommunication_Method,
                                                        cHeader_Interface,
                                                        l_header_tbl,
                                                        l_header_fkey);

      -- Now update the columns values of which have been obtained
      -- thru the procedure calls.

      -- ********************************************************
      -- Call custom program stub to populate the extension table
      -- ********************************************************

      xProgress := 'MVSTOB-20-1500';
      ece_mvsto_x.populate_ext_header (l_header_fkey,
                                     l_header_tbl);

      xProgress := 'MVSTOB-20-1530';
      dummy := DBMS_SQL.EXECUTE(Line_sel_c);

      -- *********************
      -- line loop starts here
      -- *********************

      xProgress := 'MVSTOB-20-1540';
      WHILE DBMS_SQL.FETCH_ROWS(Line_sel_c) > 0
      LOOP     --- Line

        -- ****************************
        -- store values in pl/sql table
        -- ****************************

        xProgress := 'MVSTOB-20-1550';
        ece_flatfile_pvt.ASSIGN_COLUMN_VALUE_TO_TBL(Line_sel_c,
                                                      iHeader_count,
                                                      l_line_tbl,
                                                      l_key_tbl);

        xProgress := 'MVSTOB-20-1551';
        ece_extract_utils_pub.Find_pos(l_line_tbl,
                                         'BILL_TO_SITE_USE_ID',
                                         nBill_To_Site_pos);
        ec_debug.pl(3, 'nBill_To_Site_pos: ',nBill_To_Site_pos);

        xProgress := 'MVSTOB-20-1552';
        ece_extract_utils_pub.Find_pos(l_line_tbl,
                                         'SHIP_TO_SITE_USE_ID',
                                         nShip_To_Site_pos);
        ec_debug.pl(3, 'nShip_To_Site_pos: ',nShip_To_Site_pos);

        xProgress := 'MVSTOB-20-1554';
        ece_extract_utils_pub.Find_pos(l_line_tbl,
                                         'VENDOR_SITE_ID',
                                         nVendor_Site_pos);
        ec_debug.pl(3, 'nVendor_To_Site_pos: ',nVendor_Site_pos);

        xProgress := 'MVSTOB-20-1555';
        ece_extract_utils_pub.Find_pos(l_line_tbl,
                                         'MOVEMENT_ID',
                                         nLine_key_pos);
        ec_debug.pl(3, 'nLine_key_pos: ',nLine_key_pos);

        n_movement_id := l_line_tbl(nLine_key_pos).value;
        ec_debug.pl(3, 'n_movement_id: ',n_movement_id);

        xProgress := 'MVSTOB-20-1555';
        ece_extract_utils_pub.Find_pos(l_line_tbl,
                                         'TRANSACTION_HEADER_ID',
                                         nLine_head_pos);
        ec_debug.pl(3, 'nLine_head_pos: ',nLine_head_pos);

        l_line_tbl(nLine_head_pos).value := l_header_fkey;
        ec_debug.pl(3, 'l_line_tbl(nLine_head_pos).value: ',l_line_tbl(nLine_head_pos).value);

        xProgress := 'MVSTOB-20-1560';
        ece_extract_utils_pub.Find_pos(l_line_tbl,
                                         'EDI_TRANSACTION_REFERENCE',
                                         nEdi_TransRef_pos);
        ec_debug.pl(3, 'nEdi_TransRef_pos: ',nEdi_TransRef_pos);

        l_line_tbl(nEdi_TransRef_pos).value :=  v_EdiTransactionRef;
        ec_debug.pl(3, 'l_line_tbl(nEdi_TransRef_pos).value: ',l_line_tbl(nEdi_TransRef_pos).value);


        xProgress := 'MVSTOB-20-1570';
        ec_code_Conversion_pvt.populate_plsql_tbl_with_extval(p_api_version_number => 1.0,
                                                                p_init_msg_list      => init_msg_list,
                                                                p_simulate           => simulate,
                                                                p_commit             => commt,
                                                                p_validation_level   => validation_level,
                                                                p_return_status      => return_status,
                                                                p_msg_count          => msg_count,
                                                                p_msg_data           => msg_data,
                                                                p_key_tbl            => l_key_tbl,
                                                                p_tbl                => l_line_tbl);

        xProgress := 'MVSTOB-20-1590';
        BEGIN
          SELECT   ece_MVSTO_details_s.NEXTVAL
          INTO     l_line_fkey
          FROM     DUAL;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl(0,
                        'EC',
                        'ECE_GET_NEXT_SEQ_FAILED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'SEQ',
                        'ECE_MVSTO_LINE_S');
        END;
        ec_debug.pl(3, 'l_line_fkey: ',l_line_fkey);

        xProgress := 'MVSTOB-20-1600';
        ece_Extract_Utils_PUB.insert_into_interface_tbl(iRun_id,
                                                          cTransaction_Type,
                                                          cCommunication_Method,
                                                          cLine_Interface,
                                                          l_line_tbl,
                                                          l_line_fkey);

        -- ********************************************************
        -- Call custom program stub to populate the extension table
        -- ********************************************************

        xProgress := 'MVSTOB-20-1620';
        ece_MVSTO_x.populate_ext_line(l_line_fkey,
                                      l_line_tbl);

        -- **********************
        -- set LINE_NUMBER values
        -- **********************

        xProgress := 'MVSTOB-20-1630';
        DBMS_SQL.BIND_VARIABLE(Location_sel_c,
                                 'bill_to_site_use_id',
                                 l_line_tbl(nBill_To_Site_pos).value);


        xProgress := 'MVSTOB-20-1635';
        DBMS_SQL.BIND_VARIABLE(Location_sel_c,
                                 'ship_to_site_use_id',
                                 l_line_tbl(nShip_To_Site_pos).value);

        xProgress := 'MVSTOB-20-1645';
        DBMS_SQL.BIND_VARIABLE(Location_sel_c,
                                 'vendor_site_id',
                                 l_line_tbl(nVendor_Site_pos).value);

        xProgress := 'MVSTOB-20-1646';
        DBMS_SQL.BIND_VARIABLE(Location_sel_c,
                                 'l_cInclude_Address',
                                 cInclude_Address);

        xProgress := 'MVSTOB-20-1650';
        dummy := DBMS_SQL.EXECUTE(Location_sel_c);

      -- *********************
      -- location loop starts here
      -- *********************

        xProgress := 'MVSTOB-20-1655';
        WHILE DBMS_SQL.FETCH_ROWS(Location_sel_c) > 0
        LOOP     --- Location

          -- ****************************
          -- store values in pl/sql table
          -- ****************************

         xProgress := 'MVSTOB-20-1660';
         ece_flatfile_pvt.ASSIGN_COLUMN_VALUE_TO_TBL(Location_sel_c,
                                                     iHeader_count + iLine_count,
                                                        l_location_tbl,
                                                        l_key_tbl);

          xProgress := 'MVSTOB-20-1670';
          ec_code_Conversion_pvt.populate_plsql_tbl_with_extval(p_api_version_number => 1.0,
                                                                  p_init_msg_list      => init_msg_list,
                                                                  p_simulate           => simulate,
                                                                  p_commit             => commt,
                                                                  p_validation_level   => validation_level,
                                                                  p_return_status      => return_status,
                                                                  p_msg_count          => msg_count,
                                                                  p_msg_data           => msg_data,
                                                                  p_key_tbl            => l_key_tbl,
                                                                  p_tbl                => l_location_tbl);


        ece_extract_utils_pub.Find_pos(l_location_tbl,
                                         'TRANSACTION_HEADER_ID',
                                         nLoc_head_pos);
        ec_debug.pl(3, 'nLoc_head_pos: ',nLoc_head_pos);

        l_location_tbl(nLoc_head_pos).value := l_header_fkey;
        ec_debug.pl(3, 'l_location_tbl(nLoc_head_pos).value: ',l_location_tbl(nLoc_head_pos).value);

        xProgress := 'MVSTOB-20-1555';
        ece_extract_utils_pub.Find_pos(l_location_tbl,
                                         'TRANSACTION_LINE_ID',
                                         nLoc_line_pos);
        ec_debug.pl(3, 'nLoc_line_pos: ',nLoc_line_pos);

        l_line_tbl(nLoc_line_pos).value := l_line_fkey;
        ec_debug.pl(3, 'l_location_tbl(nLoc_line_pos).value: ',l_location_tbl(nLoc_line_pos).value);

          xProgress := 'MVSTOB-20-1680';
          BEGIN
            SELECT   ece_MVSTO_locations_s.NEXTVAL
            INTO     l_location_fkey
            FROM     DUAL;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl(0,
                          'EC',
                          'ECE_GET_NEXT_SEQ_FAILED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'SEQ',
                          'ECE_MVSTO_LOCATION_S');
          END;
          ec_debug.pl(3, 'l_location_fkey: ',l_location_fkey);

          xProgress := 'MVSTOB-20-1690';
          ece_Extract_Utils_PUB.insert_into_interface_tbl(iRun_id,
                                                            cTransaction_Type,
                                                            cCommunication_Method,
                                                            cLine_Interface,
                                                            l_location_tbl,
                                                            l_location_fkey);

          -- ********************************************************
          -- Call custom program stub to populate the extension table
          -- ********************************************************

          xProgress := 'MVSTOB-20-1700';
          ece_MVSTO_x.populate_ext_line(l_location_fkey,
                                        l_location_tbl);


        END LOOP; -- Location LEVEL Loop

        xProgress := 'MVSTOB-20-1713';
        UPDATE mtl_movement_statistics
        SET EDI_TRANSACTION_REFERENCE      = v_EdiTransactionRef,
            EDI_TRANSACTION_DATE           = SYSDATE,
            EDI_SENT_FLAG                  = 'Y'
        WHERE movement_id                 = n_movement_id;

        IF SQL%NOTFOUND THEN
           ec_debug.pl ( 0,
                    'EC',
                    'ECE_NO_ROW_UPDATED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'INFO',
                    'TIME STAMP',
                    'TABLE_NAME',
                    'MTL_MOVEMENT_STATISTICS' );
        END IF;

      END LOOP;    -- LINE LEVEL Loop

      xProgress := 'MVSTOB-20-1714';
      IF(dbms_sql.last_row_count = 0) THEN
        v_LevelProcessed := 'LINE';
        ec_debug.pl(1,
                      'EC',
                      'ECE_NO_DB_ROW_PROCESSED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'LEVEL_PROCESSED',
                      v_LevelProcessed,
                      'TRANSACTION_TYPE',
                      cTransaction_Type);
      END IF;

    END LOOP;       -- HEADER LEVEL Loop

    xProgress := 'MVSTOB-20-1716';
    IF(dbms_sql.last_row_count = 0) THEN
      v_LevelProcessed := 'HEADER';
      ec_debug.pl(0,
                    'EC',
                    'ECE_NO_DB_ROW_PROCESSED',
                    'LEVEL_PROCESSED',
                    v_LevelProcessed,
                    'PROGRESS_LEVEL',
                    xProgress,
                    'TRANSACTION_TYPE',
                    cTransaction_Type);
    END IF;


    xProgress := 'MVSTOB-20-1730';
    DBMS_SQL.CLOSE_CURSOR(Line_sel_c);

    xProgress := 'MVSTOB-20-1740';
    DBMS_SQL.CLOSE_CURSOR(Header_sel_c);
    ec_debug.pop('ECE_MVSTO_TRANSACTION.POPULATE_MVSTO_TRX');

  EXCEPTION
    WHEN OTHERS THEN

      ec_debug.pl(0,
                    'EC',
                    'ECE_PROGRAM_ERROR',
                    'PROGRESS_LEVEL',
                    xProgress);

      ec_debug.pl(0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM);

      app_exception.raise_exception;

   END POPULATE_MVSTO_TRX;


  PROCEDURE PUT_DATA_TO_OUTPUT_TABLE(cCommunication_Method   IN VARCHAR2,
                                       cTransaction_Type       IN VARCHAR2,
                                       iOutput_width           IN INTEGER,
                                       iRun_id                 IN INTEGER,
                                       cHeader_Interface       IN VARCHAR2,
                                       cLine_Interface         IN VARCHAR2,
                                       cLocation_Interface     IN VARCHAR2)
  IS

    xProgress                  VARCHAR2(80);
    v_LevelProcessed           VARCHAR2(40);

    l_header_tbl               ece_flatfile_pvt.Interface_tbl_type;
    l_line_tbl                 ece_flatfile_pvt.Interface_tbl_type;
    l_location_tbl             ece_flatfile_pvt.Interface_tbl_type;

    c_header_common_key_name   VARCHAR2(40);
    c_line_common_key_name     VARCHAR2(40);
    c_location_key_name        VARCHAR2(40);
    c_file_common_key          VARCHAR2(255);

    nHeader_key_pos            NUMBER;
    nLine_key_pos              NUMBER;
    nLocation_key_pos          NUMBER;
    nTrans_code_pos            NUMBER;
    nTrans_rhid_pos            NUMBER;
    nTrans_rlid_pos            NUMBER;


    Header_sel_c               INTEGER;
    Line_sel_c                 INTEGER;
    Location_sel_c             INTEGER;

    Header_del_c1              INTEGER;
    Line_del_c1                INTEGER;
    Location_del_c1            INTEGER;

    Header_del_c2              INTEGER;
    Line_del_c2                INTEGER;
    Location_del_c2            INTEGER;

    cHeader_select             VARCHAR2(32000);
    cLine_select               VARCHAR2(32000);
    cLocation_select           VARCHAR2(32000);

    cHeader_from               VARCHAR2(32000);
    cLine_from                 VARCHAR2(32000);
    cLocation_from             VARCHAR2(32000);

    cHeader_where              VARCHAR2(32000);
    cLine_where                VARCHAR2(32000);
    cLocation_where            VARCHAR2(32000);

    cHeader_delete1            VARCHAR2(32000);
    cLine_delete1              VARCHAR2(32000);
    cLocation_delete1           VARCHAR2(32000);

    cHeader_delete2            VARCHAR2(32000);
    cLine_delete2              VARCHAR2(32000);
    cLocation_delete2           VARCHAR2(32000);

    iHeader_count              NUMBER;
    iLine_count                NUMBER;
    iLocation_count            NUMBER;

    rHeader_rowid              ROWID;
    rLine_rowid                ROWID;
    rLocation_rowid            ROWID;

    cHeader_X_Interface        VARCHAR2(50);
    cLine_X_Interface          VARCHAR2(50);
    cLocation_X_Interface      VARCHAR2(50);

    rHeader_X_rowid            ROWID;
    rLine_X_rowid              ROWID;
    rLocation_X_rowid          ROWID;

    dummy                      INTEGER;

    ntransaction_header_id      NUMBER;
    ntransaction_line_id        NUMBER;

  BEGIN

    ec_debug.push('ECE_MVSTO_TRANSACTION.PUT_DATA_TO_OUTPUT_TABLE');
    ec_debug.pl(3, 'cCommunication_Method: ', cCommunication_Method);
    ec_debug.pl(3, 'cTransaction_Type: ',cTransaction_Type);
    ec_debug.pl(3, 'iOutput_width: ',iOutput_width);
    ec_debug.pl(3, 'iRun_id: ',iRun_id);
    ec_debug.pl(3, 'cHeader_Interface: ',cHeader_Interface);
    ec_debug.pl(3, 'cLine_Interface: ',cLine_Interface);
    ec_debug.pl(3, 'cLocation_Interface: ',cLocation_Interface);

    -- Here, I am building the SELECT, FROM, and WHERE  clauses for the dynamic
    -- SQL call.
    -- The ece_flatfile.select_clause uses the db data dictionary for the build.
    -- (The db data dictionary store contains all types of info about Interface
    -- tables and Extension tables.)

    -- The DELETE clauses will be used to clean up both the interface and extension
    -- tables.  I am using ROWID to tell me which row in the interface table is
    -- being written to the output table, thus, can be deleted.

    xProgress := 'MVSTOB-10-1000';
    ece_flatfile_pvt.select_clause(cTransaction_Type,
                                     cCommunication_Method,
                                     cHeader_Interface,
                                     cHeader_X_Interface,
                                     l_header_tbl,
                                     c_header_common_key_name,
                                     cHeader_select,
                                     cHeader_from,
                                     cHeader_where);

    xProgress := 'MVSTOB-10-1010';
    ece_flatfile_pvt.select_clause(cTransaction_Type,
                                     cCommunication_Method,
                                     cLine_Interface,
                                     cLine_X_Interface,
                                     l_line_tbl,
                                     c_line_common_key_name,
                                     cLine_select,
                                     cLine_from,
                                     cLine_where);

  xProgress := 'MVSTOB-10-1010';
    ece_flatfile_pvt.select_clause(cTransaction_Type,
                                     cCommunication_Method,
                                     cLocation_Interface,
                                     cLocation_X_Interface,
                                     l_location_tbl,
                                     c_location_key_name,
                                     cLocation_select,
                                     cLocation_from,
                                     cLocation_where);


    xProgress := 'MVSTOB-10-1030';
    cHeader_where     := cHeader_where                               ||
                         ' AND '                                     ||
                         cHeader_Interface                           ||
                         '.RUN_ID = '                                ||
                         ':l_Run_id';

    cLine_where       := cLine_where                                 ||
                         ' AND '                                     ||
                         cLine_Interface                             ||
                         '.RUN_ID = '                                ||
                         ':m_Run_id'                                ||
                         ' AND '                                     ||
                         cLine_Interface                             ||
                         '.TRANSACTION_HEADER_ID = :transaction_header_id';
   cLocation_where     := cLocation_where                            ||
                         ' AND '                                     ||
                         cLocation_Interface                         ||
                         '.RUN_ID = '                                ||
                         ':x_Run_id'                                ||
                         ' AND '                                     ||
                         cLocation_Interface                         ||
                         '.TRANSACTION_HEADER_ID = :transaction_header_id AND '||
                           cLocation_Interface                         ||
                         '.TRANSACTION_LINE_ID = :transaction_line_id';

    xProgress := 'MVSTOB-10-1040';
    cHeader_select    := cHeader_select                              ||
                         ','                                         ||
                         cHeader_Interface                           ||
                         '.ROWID,'                                   ||
                         cHeader_X_Interface                         ||
                         '.ROWID ';

    cLine_select      := cLine_select                                ||
                         ','                                         ||
                         cLine_Interface                             ||
                         '.ROWID,'                                   ||
                         cLine_X_Interface                           ||
                         '.ROWID ';

  cLocation_select      := cLocation_select                          ||
                         ','                                         ||
                         cLocation_Interface                         ||
                         '.ROWID,'                                   ||
                         cLocation_X_Interface                       ||
                         '.ROWID ';


    xProgress := 'MVSTOB-10-1050';
    cHeader_select    := cHeader_select                              ||
                         cHeader_from                                ||
                         cHeader_where;

    ec_debug.pl(3, 'cHeader_select: ',cHeader_select);

    cLine_select      := cLine_select                                ||
                         cLine_from                                  ||
                         cLine_where                                 ||
                         ' ORDER BY '                                ||
                         cLine_Interface                             ||
                         '.MOVEMENT_ID ';
    ec_debug.pl(3, 'cLine_select: ',cLine_select);

    cLocation_select    := cLocation_select                          ||
                         cLocation_from                              ||
                         cLocation_where;

    ec_debug.pl(3, 'cLocation_select: ',cLocation_select);


    xProgress := 'MVSTOB-10-1060';
    cHeader_delete1   := 'DELETE FROM '                              ||
                         cHeader_Interface                           ||
                         ' WHERE ROWID = :col_rowid';
    ec_debug.pl(3, 'cHeader_delete1: ',cHeader_delete1);

    cLine_delete1     := 'DELETE FROM '                              ||
                         cLine_Interface                             ||
                         ' WHERE ROWID = :col_rowid';
    ec_debug.pl(3, 'cLine_delete1: ',cLine_delete1);

    cLocation_delete1     := 'DELETE FROM '                          ||
                         cLocation_Interface                         ||
                         ' WHERE ROWID = :col_rowid';
    ec_debug.pl(3, 'cLocation_delete1: ',cLocation_delete1);


    xProgress := 'MVSTOB-10-1070';
    cHeader_delete2   := 'DELETE FROM '                              ||
                         cHeader_X_Interface                         ||
                         ' WHERE ROWID = :col_rowid';
    ec_debug.pl(3, 'cHeader_delete2: ',cHeader_delete2);

    cLine_delete2     := 'DELETE FROM '                              ||
                         cLine_X_Interface                           ||
                         ' WHERE ROWID = :col_rowid';
    ec_debug.pl(3, 'cLine_delete2: ',cLine_delete2);

    cLocation_delete2     := 'DELETE FROM '                          ||
                         cLocation_X_Interface                       ||
                         ' WHERE ROWID = :col_rowid';
    ec_debug.pl(3, 'cLocation_delete2: ',cLocation_delete2);


    -- ***************************************************
    -- ***   Get data setup for the dynamic SQL call.
    -- ***
    -- ***   Open a cursor for each of the SELECT call
    -- ***   This tells the database to reserve spaces
    -- ***   for the data returned by the SQL statement
    -- ***************************************************

    xProgress       := 'MVSTOB-10-1080';
    Header_sel_c    := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1090';
    Line_sel_c      := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1100';
    Location_sel_c  := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1110';
    Header_del_c1   := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1120';
    Line_del_c1     := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1130';
    Location_del_c1 := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1140';
    Header_del_c2   := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1150';
    Line_del_c2     := DBMS_SQL.OPEN_CURSOR;

    xProgress       := 'MVSTOB-10-1160';
    Location_del_c2 := DBMS_SQL.OPEN_CURSOR;


    -- *****************************************
    -- Parse each of the SELECT statement
    -- so the database understands the command
    -- *****************************************

    xProgress := 'MVSTOB-10-1170';
    BEGIN
       DBMS_SQL.PARSE(Header_sel_c,
                        cHeader_select,
                        DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cHeader_select);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1180';
    BEGIN
      DBMS_SQL.PARSE(Line_sel_c,
                       cLine_select,
                       DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cLine_select);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1190';
    BEGIN
      DBMS_SQL.PARSE(Location_sel_c,
                       cLocation_select,
                       DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cLocation_select);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1200';
    BEGIN
      DBMS_SQL.PARSE(Header_del_c1  ,cHeader_delete1  ,DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cHeader_delete1);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1210';
    BEGIN
      DBMS_SQL.PARSE(Line_del_c1    ,cLine_delete1    ,DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cLine_delete1);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1220';
    BEGIN
      DBMS_SQL.PARSE(Location_del_c1    ,cLocation_delete1    ,DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cLocation_delete1);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1230';
    BEGIN
      DBMS_SQL.PARSE(Header_del_c2  ,cHeader_delete2  ,DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cHeader_delete2);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1240';
    BEGIN
      DBMS_SQL.PARSE(Line_del_c2    ,cLine_delete2    ,DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cLine_delete2);
        app_exception.raise_exception;
    END;

    xProgress := 'MVSTOB-10-1250';
    BEGIN
      DBMS_SQL.PARSE(Location_del_c2    ,cLocation_delete2    ,DBMS_SQL.NATIVE);
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                   cLocation_delete2);
        app_exception.raise_exception;
    END;


    -- *************
    -- set counter
    -- *************

    xProgress       := 'MVSTOB-10-1260';
    iHeader_count   := l_header_tbl.COUNT;
    iLine_count     := l_line_tbl.COUNT;
    iLocation_count := l_location_tbl.COUNT;

    -- ******************************************************
    --  Define TYPE for every columns in the SELECT statement
    --  For each piece of the data returns, we need to tell
    --  the database what type of information it will be.
    --  e.g. ID is NUMBER, due_date is DATE
    --  However, for simplicity, we will convert
    --  everything to varchar2.
    -- ******************************************************

    xProgress := 'MVSTOB-10-1270';
    ece_flatfile_pvt.DEFINE_INTERFACE_COLUMN_TYPE(Header_sel_c,
                                                    cHeader_select,
                                                    ece_flatfile_pvt.G_MaxColWidth,
                                                    l_header_tbl);

    -- ***************************************************
    -- Need rowid for delete (Header Level)
    -- ***************************************************

    xProgress := 'MVSTOB-10-1280';
    DBMS_SQL.DEFINE_COLUMN_ROWID(Header_sel_c,
                                   iHeader_count + 1,
                                   rHeader_rowid);

    xProgress := 'MVSTOB-10-1290';
    DBMS_SQL.DEFINE_COLUMN_ROWID(Header_sel_c,
                                   iHeader_count + 2,
                                   rHeader_X_rowid);

    xProgress := 'MVSTOB-10-1310';
    ece_flatfile_pvt.DEFINE_INTERFACE_COLUMN_TYPE(Line_sel_c,
                                                    cLine_select,
                                                    ece_flatfile_pvt.G_MaxColWidth,
                                                    l_line_tbl);

    -- ***************************************************
    -- Need rowid for delete (Line Level)
    -- ***************************************************

    xProgress := 'MVSTOB-10-1320';
    DBMS_SQL.DEFINE_COLUMN_ROWID(Line_sel_c,
                                   iLine_count + 1,
                                   rLine_rowid);

    xProgress := 'MVSTOB-10-1330';
    DBMS_SQL.DEFINE_COLUMN_ROWID(Line_sel_c,
                                   iLine_count + 2,
                                   rLine_X_rowid);

    xProgress := 'MVSTOB-10-1340';
    ece_flatfile_pvt.DEFINE_INTERFACE_COLUMN_TYPE(Location_sel_c,
                                                    cLocation_select,
                                                    ece_flatfile_pvt.G_MaxColWidth,
                                                    l_location_tbl);


    -- ***************************************************
    -- Need rowid for delete (Location Level)
    -- ***************************************************

    xProgress := 'MVSTOB-10-1360';
    DBMS_SQL.DEFINE_COLUMN_ROWID(Location_sel_c,
                                   iLocation_count + 1,
                                   rLocation_rowid);

    xProgress := 'MVSTOB-10-1370';
    DBMS_SQL.DEFINE_COLUMN_ROWID(Location_sel_c,
                                   iLocation_count + 2,
                                   rLocation_X_rowid);

    -- ************************************************************
    -- ***  The following is custom tailored for this transaction
    -- ***  It find the values and use them in the WHERE clause to
    -- ***  join tables together.
    -- ************************************************************

    -- *******************************************
    -- To complete the Line SELECT statement,
    -- we will need values for the join condition.
    -- *******************************************

    -- Bind Variables

      xProgress := 'MVSTOB-10-1371';
      DBMS_SQL.BIND_VARIABLE(Header_sel_c,
                               'l_Run_id',
                               iRun_Id);

      xProgress := 'MVSTOB-10-1372';
      DBMS_SQL.BIND_VARIABLE(Line_sel_c,
                               'm_Run_id',
                               iRun_Id);

      xProgress := 'MVSTOB-10-1373';
      DBMS_SQL.BIND_VARIABLE(Location_sel_c,
                               'x_Run_id',
                               iRun_Id);

    --- EXECUTE the SELECT statement

    xProgress := 'MVSTOB-10-1380';
    dummy := DBMS_SQL.EXECUTE(Header_sel_c);

    -- ********************************************************************
    -- ***   With data for each HEADER line, populate the ECE_OUTPUT table
    -- ***   then populate ECE_OUTPUT with data from all DETAILS that belongs
    -- ***   to the HEADER. Then populate ECE_OUTPUT with data from all
    -- ***   LINE TAX that belongs to the LINE.
    -- ********************************************************************

    -- HEADER - LINE - LOCATION...

    xProgress := 'MVSTOB-10-1390';
    WHILE DBMS_SQL.FETCH_ROWS(Header_sel_c) > 0
    LOOP           -- Header

      -- ******************************
      --   store values in pl/sql table
      -- ******************************

      xProgress := 'MVSTOB-10-1400';
      ece_flatfile_pvt.ASSIGN_COLUMN_VALUE_TO_TBL(Header_sel_c,
                                                    l_header_tbl);

      xProgress := 'MVSTOB-10-1410';
      DBMS_SQL.COLUMN_VALUE(Header_sel_c,
                              iHeader_count + 1,
                              rHeader_rowid);

      xProgress := 'MVSTOB-10-1420';
      DBMS_SQL.COLUMN_VALUE(Header_sel_c,
                              iHeader_count + 2,
                              rHeader_X_rowid);

      xProgress := 'MVSTOB-10-1430';
      ece_flatfile_pvt.Find_pos(l_header_tbl,
                                  'TRANSACTION_RECORD_ID',
                                  nTrans_rhid_pos);
      ntransaction_header_id := l_header_tbl(nTrans_rhid_pos).value;

      --Bug # 952306
      xProgress := 'MVSTOB-10-1440';
      ece_flatfile_pvt.Find_pos(l_header_tbl,
                                'TRANSLATOR_CODE',nTrans_code_pos);

      xProgress := 'MVSTOB-10-1450';
      ece_flatfile_pvt.Find_pos(l_header_tbl,
                                  c_header_common_key_name,
                                  nHeader_key_pos);

      --Bug # 952306
      xProgress := 'MVSTOB-10-1460';
      c_file_common_key := RPAD(NVL(SUBSTRB(l_header_tbl(nTrans_code_pos).value,1,25),' '),25);


      xProgress         := 'MVSTOB-10-1470';
      c_file_common_key := c_file_common_key                         ||
                           RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value,' '),
                                       1,
                                       22),22) || RPAD(' ',22)       ||
                           RPAD(' ',22);

      ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);

      xProgress := 'MVSTOB-10-1480';
      ece_flatfile_pvt.write_to_ece_output(cTransaction_Type,
                                             cCommunication_Method,
                                             cHeader_Interface,
                                             l_header_tbl,
                                             iOutput_width,
                                             iRun_id,
                                             c_file_common_key);

      xProgress := 'MVSTOB-10-1490';
      DBMS_SQL.BIND_VARIABLE(Line_sel_c,
                               'transaction_header_id',
                               ntransaction_header_id);

      xProgress := 'MVSTOB-10-1500';
      DBMS_SQL.BIND_VARIABLE(Location_sel_c,
                               'transaction_header_id',
                               ntransaction_header_id);

      xProgress := 'MVSTOB-10-1510';
      dummy := DBMS_SQL.EXECUTE(Line_sel_c);

      -- ***************************************************
      --   line loop starts here
      -- ***************************************************
      xProgress := 'MVSTOB-10-1520';
      WHILE DBMS_SQL.FETCH_ROWS(Line_sel_c) > 0
      LOOP     --- Line

        -- ***************************************************
        --   store values in pl/sql table
        -- ***************************************************

        xProgress := 'MVSTOB-10-1530';
        ece_flatfile_pvt.ASSIGN_COLUMN_VALUE_TO_TBL (Line_sel_c,
                                                     l_line_tbl);

        xProgress := 'MVSTOB-10-1533';
        DBMS_SQL.COLUMN_VALUE(Line_sel_c,
                                iLine_count + 1,
                                rLine_rowid);

        xProgress := 'MVSTOB-10-1535';
        DBMS_SQL.COLUMN_VALUE(Line_sel_c,
                                iLine_count + 2,
                                rLine_X_rowid);

        xProgress := 'MVSTOB-10-1445';
        ece_flatfile_pvt.Find_pos(l_line_tbl,
                                    'TRANSACTION_RECORD_ID',
                                    nTrans_rlid_pos);
        ntransaction_line_id := l_line_tbl(nTrans_rlid_pos).value;

        xProgress := 'MVSTOB-10-1540';
        ece_flatfile_pvt.Find_pos(l_line_tbl,
                                    c_line_common_key_name,
                                    nLine_key_pos);

	 --Bug # 952306
      xProgress := 'MVSTOB-10-1540';
      c_file_common_key := RPAD(NVL(SUBSTRB(l_header_tbl(nTrans_code_pos).value,1,25),' '),25);
	xProgress := 'MVSTOB-10-1550';
        c_file_common_key := c_file_common_key || RPAD(SUBSTRB(NVL
                                          (l_header_tbl(nHeader_key_pos).value,' '),
                                           1,
                                           22),22) ||
                                    RPAD(SUBSTRB(NVL
                                          (l_line_tbl(nLine_key_pos).value,' '),
                                           1,
                                           22),22) ||
                                    RPAD(' ',22);
        ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);

        xProgress := 'MVSTOB-10-1560';
        ece_flatfile_pvt.write_to_ece_output(cTransaction_Type,
                                               cCommunication_Method,
                                               cLine_Interface,
                                               l_line_tbl,
                                               iOutput_width,
                                               iRun_id,
                                               c_file_common_key);

      xProgress := 'MVSTOB-10-1570';
      DBMS_SQL.BIND_VARIABLE(Location_sel_c,
                               'transaction_line_id',
                               ntransaction_line_id);

      xProgress := 'MVSTOB-10-1580';
      dummy := DBMS_SQL.EXECUTE(Location_sel_c);

      -- ***************************************************
      --   location loop starts here
      -- ***************************************************
      xProgress := 'MVSTOB-10-1590';
      WHILE DBMS_SQL.FETCH_ROWS(Location_sel_c) > 0
      LOOP     --- Line

        -- ***************************************************
        --   store values in pl/sql table
        -- ***************************************************

        xProgress := 'MVSTOB-10-1600';
        ece_flatfile_pvt.ASSIGN_COLUMN_VALUE_TO_TBL (Location_sel_c,
                                                     l_location_tbl);

       xProgress := 'MVSTOB-10-1603';
        DBMS_SQL.COLUMN_VALUE(Location_sel_c,
                                iLocation_count + 1,
                                rLocation_rowid);

        xProgress := 'MVSTOB-10-1606';
        DBMS_SQL.COLUMN_VALUE(Location_sel_c,
                                iLocation_count + 2,
                                rLocation_X_rowid);

        --Bug # 952306
      xProgress := 'MVSTOB-10-1610';
      c_file_common_key := RPAD(NVL(SUBSTRB(l_header_tbl(nTrans_code_pos).value,1,25),' '),25);
	xProgress := 'MVSTOB-10-1620';
        c_file_common_key := c_file_common_key || RPAD(SUBSTRB(NVL (l_header_tbl(nHeader_key_pos).value,' '), 1, 22),22) || RPAD(SUBSTRB(NVL (l_line_tbl(nLine_key_pos).value,' '), 1, 22),22);

        ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);

        xProgress := 'MVSTOB-10-1630';
        ece_flatfile_pvt.write_to_ece_output(cTransaction_Type,
                                               cCommunication_Method,
                                               cLocation_Interface,
                                               l_location_tbl,
                                               iOutput_width,
                                               iRun_id,
                                               c_file_common_key);

        xProgress := 'MVSTOB-10-1680';
        DBMS_SQL.BIND_VARIABLE(Location_del_c1,
                                 'col_rowid',
                                 rLocation_rowid);

        xProgress := 'MVSTOB-10-1690';
        DBMS_SQL.BIND_VARIABLE(Location_del_c2,
                                 'col_rowid',
                                 rLocation_X_rowid);

        xProgress := 'MVSTOB-10-1660';
        dummy := DBMS_SQL.EXECUTE(Location_del_c1);

        xProgress := 'MVSTOB-10-1670';
        dummy := DBMS_SQL.EXECUTE(Location_del_c2);

      END LOOP; -- Location Level

      xProgress := 'MVSTOB-10-1674';
      IF(dbms_sql.last_row_count = 0) THEN
        v_LevelProcessed := 'LOCATION';
        ec_debug.pl(1,
                      'EC',
                      'ECE_NO_DB_ROW_PROCESSED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'LEVEL_PROCESSED',
                      v_LevelProcessed,
                      'TRANSACTION_TYPE',
                      cTransaction_Type);
      END IF;

        -- *********************
        -- Use rowid for delete
        -- *********************

        xProgress := 'MVSTOB-10-1680';
        DBMS_SQL.BIND_VARIABLE(Line_del_c1,
                                 'col_rowid',
                                 rLine_rowid);

        xProgress := 'MVSTOB-10-1690';
        DBMS_SQL.BIND_VARIABLE(Line_del_c2,
                                 'col_rowid',
                                 rLine_X_rowid);

        xProgress := 'MVSTOB-10-1700';
        dummy := DBMS_SQL.EXECUTE(Line_del_c1);

        xProgress := 'MVSTOB-10-1710';
        dummy := DBMS_SQL.EXECUTE(Line_del_c2);

      END LOOP; -- Line Level

      xProgress := 'MVSTOB-10-1714';
      IF(dbms_sql.last_row_count = 0) THEN
        v_LevelProcessed := 'LINE';
        ec_debug.pl(1,
                      'EC',
                      'ECE_NO_DB_ROW_PROCESSED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'LEVEL_PROCESSED',
                      v_LevelProcessed,
                      'TRANSACTION_TYPE',
                      cTransaction_Type);
      END IF;

      xProgress := 'MVSTOB-10-1720';
      DBMS_SQL.BIND_VARIABLE(Header_del_c1,
                               'col_rowid',
                               rHeader_rowid);

      xProgress := 'MVSTOB-10-1730';
      DBMS_SQL.BIND_VARIABLE(Header_del_c2,
                               'col_rowid',
                               rHeader_X_rowid);

      xProgress := 'MVSTOB-10-1740';
      dummy := DBMS_SQL.EXECUTE(Header_del_c1);

      xProgress := 'MVSTOB-10-1750';
      dummy := DBMS_SQL.EXECUTE(Header_del_c2);

    END LOOP; -- Header Level

    xProgress := 'MVSTOB-10-1754';
    IF(dbms_sql.last_row_count = 0) THEN
      v_LevelProcessed := 'HEADER';
      ec_debug.pl(1,
                    'EC',
                    'ECE_NO_DB_ROW_PROCESSED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'LEVEL_PROCESSED',
                    v_LevelProcessed,
                    'TRANSACTION_TYPE',
                    cTransaction_Type);
    END IF;

    xProgress := 'MVSTOB-10-1760';
    DBMS_SQL.CLOSE_CURSOR(Header_sel_c);

    xProgress := 'MVSTOB-10-1770';
    DBMS_SQL.CLOSE_CURSOR(Line_sel_c);

    xProgress := 'MVSTOB-10-1780';
    DBMS_SQL.CLOSE_CURSOR(Location_sel_c);

    xProgress := 'MVSTOB-10-1790';
    DBMS_SQL.CLOSE_CURSOR(Header_del_c1);

    xProgress := 'MVSTOB-10-1800';
    DBMS_SQL.CLOSE_CURSOR(Line_del_c1);

    xProgress := 'MVSTOB-10-1812';
    DBMS_SQL.CLOSE_CURSOR(Location_del_c1);

    xProgress := 'MVSTOB-10-1814';
    DBMS_SQL.CLOSE_CURSOR(Header_del_c2);

    xProgress := 'MVSTOB-10-1816';
    DBMS_SQL.CLOSE_CURSOR(Line_del_c2);

    xProgress := 'MVSTOB-10-1818';
    DBMS_SQL.CLOSE_CURSOR(Location_del_c2);

    xProgress := 'MVSTOB-10-1820';
    ec_debug.pop('ECE_MVSTO_TRANSACTION.PUT_DATA_TO_OUTPUT_TABLE');

  EXCEPTION
    WHEN OTHERS THEN

      ec_debug.pl(0,
                    'EC',
                    'ECE_PROGRAM_ERROR',
                    'PROGRESS_LEVEL',
                    xProgress);

      ec_debug.pl(0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM);

      app_exception.raise_exception;

  END PUT_DATA_TO_OUTPUT_TABLE;

END ECE_MVSTO_TRANSACTION;


/
