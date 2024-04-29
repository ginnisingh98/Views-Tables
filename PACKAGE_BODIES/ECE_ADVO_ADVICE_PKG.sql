--------------------------------------------------------
--  DDL for Package Body ECE_ADVO_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_ADVO_ADVICE_PKG" AS
-- $Header: ECADVOB.pls 120.2.12000000.3 2007/03/09 14:37:48 cpeixoto ship $

/*===========================================================================
  PROCEDURE NAME:      Extract_ADVO_Outbound
  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible transactions.
===========================================================================*/

   PROCEDURE Extract_ADVO_Outbound(errbuf             OUT NOCOPY  VARCHAR2,
                                   retcode            OUT NOCOPY  VARCHAR2,
                                   cOutput_Path       IN    VARCHAR2,
                                   cOutput_Filename   IN    VARCHAR2,
                                   p_TP_Group         IN    VARCHAR2,
                                   p_TP               IN    VARCHAR2,
                                   p_Response_to_doc  IN    VARCHAR2,
                                   cDate_From         IN    VARCHAR2,
                                   cDate_To           IN    VARCHAR2,
                                   p_ext_ref1         IN    VARCHAR2,
                                   p_ext_ref2         IN    VARCHAR2,
                                   p_ext_ref3         IN    VARCHAR2,
                                   p_ext_ref4         IN    VARCHAR2,
                                   p_ext_ref5         IN    VARCHAR2,
                                   p_ext_ref6         IN    VARCHAR2,
                                   v_debug_mode       IN    NUMBER   DEFAULT 0) IS

      xProgress                VARCHAR2(80);
      p_communication_method   VARCHAR2(120)       := 'EDI';
      p_transaction_type       VARCHAR2(120)       := 'ADVO';
      p_document_type          VARCHAR2(120)       := 'ADV';
      l_line_text              VARCHAR2(2000);
      uFile_type               utl_file.file_type;
      p_Date_From              DATE                := TO_DATE(cDate_From,'YYYY/MM/DD HH24:MI:SS');
      p_Date_To                DATE                := TO_DATE(cDate_To,'YYYY/MM/DD HH24:MI:SS') + 1;
      p_output_width           INTEGER             := 4000;
      p_run_id                 NUMBER;
      p_header_interface       VARCHAR2(120)       := 'ECE_ADVO_HEADERS_INTERFACE';
      p_line_interface         VARCHAR2(120)       := 'ECE_ADVO_DETAILS_INTERFACE';
      p_transaction_date       DATE                := SYSDATE;
      cEnabled                 VARCHAR2(1)         := 'Y';
      ece_transaction_disabled EXCEPTION;

    CURSOR c_output IS
       SELECT   text
       FROM     ece_output
       WHERE    run_id = p_run_id
       ORDER BY line_id;

  BEGIN

    ec_debug.enable_debug ( v_debug_mode );
    ec_debug.push ( 'ECE_ADVO_ADVICE_PKG.Extract_ADVO_Outbound' );
    ec_debug.pl ( 3, 'cOutput_Path: ',cOutput_Path );
    ec_debug.pl ( 3, 'cOutput_Filename: ',cOutput_Filename );
    ec_debug.pl ( 3, 'p_TP_Group: ',p_TP_Group );
    ec_debug.pl ( 3, 'p_TP: ',p_TP );
    ec_debug.pl ( 3, 'p_Response_to_doc: ',p_Response_to_doc );
    ec_debug.pl ( 3, 'cDate_From: ',cDate_From );
    ec_debug.pl ( 3, 'cDate_To: ',cDate_To );
    ec_debug.pl ( 3, 'p_ext_ref1: ',p_ext_ref1 );
    ec_debug.pl ( 3, 'p_ext_ref2: ',p_ext_ref2 );
    ec_debug.pl ( 3, 'p_ext_ref3: ',p_ext_ref3 );
    ec_debug.pl ( 3, 'p_ext_ref4: ',p_ext_ref4 );
    ec_debug.pl ( 3, 'p_ext_ref5: ',p_ext_ref5 );
    ec_debug.pl ( 3, 'p_ext_ref6: ',p_ext_ref6 );
    ec_debug.pl ( 3, 'v_debug_mode: ',v_debug_mode );

         /* Check to see if the transaction is enabled. If not, abort */
         xProgress := 'ADVO-10-1001';
         fnd_profile.get('ECE_' || p_Transaction_Type || '_ENABLED',cEnabled);

         xProgress := 'ADVO-10-1002';
         IF cEnabled = 'N' THEN
            xProgress := 'ADVO-10-1003';
            RAISE ece_transaction_disabled;
         END IF;

    xProgress := 'ADVO-10-1005';
    BEGIN
      SELECT   ece_output_runs_s.NEXTVAL
      INTO     p_run_id
      FROM     sys.dual;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 0,
                      'EC',
                      'ECE_GET_NEXT_SEQ_FAILED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'SEQ',
                      'ECE_OUTPUT_RUNS_S' );
    END;
    ec_debug.pl ( 3, 'p_run_id: ',p_run_id );

    xProgress := 'ADVO-10-1010';
    ec_debug.pl ( 0, 'EC', 'ECE_ADVO_START', NULL );

    xProgress := 'ADVO-10-1020';
    ec_debug.pl ( 0, 'EC', 'ECE_RUN_ID', 'RUN_ID', p_run_id );

    xProgress := 'ADVO-10-1030';
    ECE_ADVO_ADVICE_PKG.EXTRACT_FROM_BASE_APPS ( p_communication_method,
                                                 p_transaction_type,
                                                 p_output_width,
                                                 p_transaction_date,
                                                 p_run_id,
                                                 p_header_interface,
                                                 p_line_interface,
                                                 p_TP_Group,
                                                 p_TP,
                                                 p_Response_to_doc,
                                                 p_Date_From,
                                                 p_Date_To,
                                                 p_ext_ref1,
                                                 p_ext_ref2,
                                                 p_ext_ref3,
                                                 p_ext_ref4,
                                                 p_ext_ref5,
                                                 p_ext_ref6 );

    xProgress := 'ADVO-10-1040';

    ece_advo_advice_pkg.Put_Data_To_Output_Table ( p_communication_method,
                                                   p_transaction_type,
                                                   p_output_width,
                                                   p_run_id,
                                                   p_header_interface,
                                                   p_line_interface );

    xProgress := 'ADVO-10-1050';

    /*
    **
    **  Open the cursor to select the actual file output from ece_output.
    **
    */

    xProgress := 'ADVO-10-1060';
    OPEN c_output;
    LOOP
      FETCH c_output
      INTO  l_line_text;
      if (c_output%ROWCOUNT > 0) then
         if (NOT utl_file.is_open(uFile_type)) then
             uFile_type := utl_file.fopen ( cOutput_Path,
                                            cOutput_Filename,
                                            'W' );
         end if;
      end if;

      EXIT WHEN c_output%NOTFOUND;

      ec_debug.pl ( 3, 'l_line_text: ',l_line_text );

      /*
      **
      **  Write the data from ece_output to the output file.
      **
      */

      xProgress := 'ADVO-10-1070';
      utl_file.put_line ( uFile_type,
                          l_line_text );
    END LOOP;

    CLOSE c_output;

    /*
    **
    **  Close the output file.
    **
    */

    xProgress := 'ADVO-10-1080';
    if (utl_file.is_open( uFile_type)) then
    utl_file.fclose ( uFile_type );
    end if;

    /*
    **
    **  Assume everything went ok so delete the records from ece_output.
    **
    */

    xProgress := 'ADVO-10-1090';
    ec_debug.pl ( 0, 'EC', 'ECE_ADVO_COMPLETE', NULL );

    xProgress := 'ADVO-10-1100';
    DELETE
    FROM     ece_output
    WHERE    run_id = p_run_id;

    IF SQL%NOTFOUND
    THEN
      ec_debug.pl ( 0,
                    'EC',
                    'ECE_NO_ROW_DELETED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'TABLE_NAME',
                    'ECE_OUTPUT' );
    END IF;

    --- Everything is successful. Commit the Changes.
    commit;

   IF ec_mapping_utils.ec_get_trans_upgrade_status(p_transaction_type)  = 'U' THEN
      ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
      retcode := 1;
   END IF;

    ec_debug.pop ( 'ece_advo_advice_pkg.Extract_ADVO_Outbound' );
    ec_debug.disable_debug;

  EXCEPTION
      WHEN ece_transaction_disabled THEN
         ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',p_Transaction_type);
         retcode := 1;
         ec_debug.disable_debug;
         ROLLBACK;

    WHEN utl_file.write_error THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_UTL_WRITE_ERROR',
                    NULL );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM );

      retcode := 2;
      ec_debug.disable_debug;
      ROLLBACK;
      RAISE;

    WHEN utl_file.invalid_path THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_UTIL_INVALID_PATH',
                    NULL );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM );

      retcode := 2;
      ec_debug.disable_debug;
      ROLLBACK;
      RAISE;

    WHEN utl_file.invalid_operation THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_UTIL_INVALID_OPERATION',
                    NULL );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM );

      retcode := 2;
      ec_debug.disable_debug;
      ROLLBACK;
      RAISE;

    WHEN OTHERS THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_PROGRAM_ERROR',
                    'PROGRESS_LEVEL',
                    xProgress );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM );

      retcode := 2;
      ec_debug.disable_debug;
      ROLLBACK;
      RAISE;

  END Extract_ADVO_Outbound;

  /* --------------------------------------------------------------------------
  REM  PROCEDURE Extract_From_Base_Apps
  REM This procedure has the following functionalities:
  REM 1. Build SQL statement dynamically to extract data from
  REM    Base Application Tables.
  REM 2. Execute the dynamic SQL statement.
  REM 3. Assign data into 2-dim PL/SQL table
  REM 4. Pass data to the code conversion mechanism
  REM 5. Populate the Interface tables with the extracted data.
  REM --------------------------------------------------------------------------
  */

  PROCEDURE Extract_From_Base_Apps ( cCommunication_Method IN VARCHAR2,
                                     cTransaction_Type     IN VARCHAR2,
                                     iOutput_width         IN INTEGER,
                                     dTransaction_date     IN DATE,
                                     iRun_id               IN INTEGER,
                                     cHeader_Interface     IN VARCHAR2,
                                     cLine_Interface       IN VARCHAR2,
                                     p_TP_Group            IN VARCHAR2,
                                     p_TP                  IN VARCHAR2,
                                     p_Response_to_doc     IN VARCHAR2,
                                     p_Date_From           IN DATE,
                                     p_Date_To             IN DATE,
                                     p_ext_ref1            IN VARCHAR2,
                                     p_ext_ref2            IN VARCHAR2,
                                     p_ext_ref3            IN VARCHAR2,
                                     p_ext_ref4            IN VARCHAR2,
                                     p_ext_ref5            IN VARCHAR2,
                                     p_ext_ref6            IN VARCHAR2 )
  IS

    /*
    **
    **  Variable definitions.  'Interface_tbl_type' is a PL/SQL table typedef
    **  with the following structure:
    **
    **  base_table_name         VARCHAR2(50)
    **  base_column_name        VARCHAR2(50)
    **  interface_table_name    VARCHAR2(50)
    **  interface_column_name   VARCHAR2(50)
    **  Record_num              NUMBER
    **  Position                NUMBER
    **  data_type               VARCHAR2(50)
    **  data_length             NUMBER
    **  value                   VARCHAR2(400)
    **  layout_code             VARCHAR2(2)
    **  record_qualifier        VARCHAR2(3)
    **  interface_column_id     NUMBER
    **  conversion_seq          NUMBER
    **  xref_category_id        NUMBER
    **  conversion_group_id     NUMBER
    **  xref_key1_source_column VARCHAR2(50)
    **  xref_key2_source_column VARCHAR2(50)
    **  xref_key3_source_column VARCHAR2(50)
    **  xref_key4_source_column VARCHAR2(50)
    **  xref_key5_source_column VARCHAR2(50)
    **  ext_val1                VARCHAR2(80)
    **  ext_val2                VARCHAR2(80)
    **  ext_val3                VARCHAR2(80)
    **  ext_val4                VARCHAR2(80)
    **  ext_val5                VARCHAR2(80)
    **
    */

    xProgress                VARCHAR2(30);
    v_LevelProcessed         VARCHAR2(40);
    cOutput_path             VARCHAR2(120);

    l_header_tbl             ece_flatfile_pvt.Interface_tbl_type;
    l_line_tbl               ece_flatfile_pvt.Interface_tbl_type;
    l_key_tbl                ece_flatfile_pvt.Interface_tbl_type;

    Header_sel_c             INTEGER;
    Line_sel_c               INTEGER;

    cHeader_select           VARCHAR2(32000);
    cLine_select             VARCHAR2(32000);

    cHeader_from             VARCHAR2(32000);
    cLine_from               VARCHAR2(32000);

    cHeader_where            VARCHAR2(32000);
    cLine_where              VARCHAR2(32000);

    iHeader_count            NUMBER := 0;
    iLine_count              NUMBER := 0;
    iKey_count               NUMBER := 0;

    l_header_fkey            NUMBER;
    l_line_fkey              NUMBER;

    l_header_row_processed   INTEGER;
    l_line_row_processed     INTEGER;

    l_return_status          VARCHAR2(10);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(255);

    n_advice_header_id_pos   NUMBER;
    n_trx_date_pos           NUMBER;
    n_runid_pos              NUMBER;

    d_dummy_date             DATE;

  BEGIN

    /*
    **
    **  Debug statements for the parameter values.
    **
    */

    ec_debug.push ( 'ece_advo_advice_pkg.Extract_From_Base_Apps' );
    ec_debug.pl ( 3, 'cCommunication_Method: ', cCommunication_Method );
    ec_debug.pl ( 3, 'cTransaction_Type: ',cTransaction_Type );
    ec_debug.pl ( 3, 'iOutput_width: ',iOutput_width );
    ec_debug.pl ( 3, 'dTransaction_date: ',dTransaction_date );
    ec_debug.pl ( 3, 'iRun_id: ',iRun_id );
    ec_debug.pl ( 3, 'cHeader_Interface: ',cHeader_Interface );
    ec_debug.pl ( 3, 'cLine_Interface: ',cLine_Interface );
    ec_debug.pl ( 3, 'p_TP_Group: ',p_TP_Group );
    ec_debug.pl ( 3, 'p_Response_to_doc: ',p_Response_to_doc );
    ec_debug.pl ( 3, 'p_Date_From: ',p_Date_From );
    ec_debug.pl ( 3, 'p_Date_To: ',p_Date_To );
    ec_debug.pl ( 3, 'p_ext_ref1: ',p_ext_ref1 );
    ec_debug.pl ( 3, 'p_ext_ref2: ',p_ext_ref2 );
    ec_debug.pl ( 3, 'p_ext_ref3: ',p_ext_ref3 );
    ec_debug.pl ( 3, 'p_ext_ref4: ',p_ext_ref4 );
    ec_debug.pl ( 3, 'p_ext_ref5: ',p_ext_ref5 );
    ec_debug.pl ( 3, 'p_ext_ref6: ',p_ext_ref6 );

    /*
    **
    **  The "Init_Table" procedure will build the internal PL/SQL
    **  table for each level as well as the internal PL/SQL "Key"
    **  table used by the Cross Reference engine.  The "Key" table
    **  is a concatenation of ALL column values used in this
    **  transaction, regardless of level.
    **
    */

    xProgress := 'ADVOB-10-1000';
    ece_flatfile_pvt.INIT_TABLE( cTransaction_Type,
                                 cHeader_Interface,
                                 NULL,
                                 FALSE,
                                 l_header_tbl,
                                 l_key_tbl );

    xProgress := 'ADVOB-10-1010';
    l_key_tbl := l_header_tbl;

    xProgress := 'ADVOB-10-1030';
    ece_flatfile_pvt.INIT_TABLE( cTransaction_Type,
                                 cLine_Interface,
                                 NULL,
                                 TRUE,
                                 l_Line_tbl,
                                 l_key_tbl );

    /*
    **
    **  The 'select_clause' procedure will build the SELECT, FROM and WHERE
    **  clauses in preparation for the dynamic SQL call using the EDI data
    **  dictionary for the build.  Any necessary customizations to these
    **  clauses need to be made *after* the clause is built, but *before*
    **  the SQL call.
    **
    */

     xProgress := 'ADVOB-10-1040';
     ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                           cCommunication_Method,
                                           cHeader_Interface,
                                           l_header_tbl,
                                           cHeader_select,
                                           cHeader_from,
                                           cHeader_where );


     xProgress := 'ADVOB-10-1050';
     ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                           cCommunication_Method,
                                           cLine_Interface,
                                           l_line_tbl,
                                           cLine_select,
                                           cLine_from,
                                           cLine_where );


    /*
    **
    **  Customize the WHERE clauses.  The WHERE clause for the Header
    **  level is conditional, depending on the values of the parameters
    **  passed to this procedure.
    **
    */

    cHeader_where := cHeader_where                                  ||
                     ' 1 = 1 ';


    xProgress := 'ADVOB-10-1060';
    IF p_TP_Group IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.tp_group_code = '        ||
                       ':l_TP_Group';
    END IF;

    xProgress := 'ADVOB-10-1070';
    IF p_TP IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.tp_location_code_ext = ' ||
                       ':l_TP';
    END IF;

    xProgress := 'ADVOB-10-1080';
    IF p_Response_to_doc IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.related_document_id = '  ||
                       ':l_Response_to_doc';
    END IF;

    xProgress := 'ADVOB-10-1090';
    IF p_Date_From IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.transaction_date >= '    ||
                       ':l_Date_From';
    END IF;

    xProgress := 'ADVOB-10-1100';
    IF p_Date_To IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.transaction_date <= '    ||
                       ':l_Date_To';
    END IF;

    xProgress := 'ADVOB-10-1110';
    IF p_ext_ref1 IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.external_reference1 = '  ||
                       ':l_ext_ref1';

    END IF;

    xProgress := 'ADVOB-10-1120';
    IF p_ext_ref2 IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.external_reference2 = '  ||
                       ':l_ext_ref2';

    END IF;

    xProgress := 'ADVOB-10-1130';
    IF p_ext_ref3 IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.external_reference3 = '  ||
                       ':l_ext_ref3';

    END IF;

    xProgress := 'ADVOB-10-1140';
    IF p_ext_ref4 IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.external_reference4 = '  ||
                       ':l_ext_ref4';

    END IF;

    xProgress := 'ADVOB-10-1150';
    IF p_ext_ref5 IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.external_reference5 = '  ||
                       ':l_ext_ref5';

    END IF;

    xProgress := 'ADVOB-10-1160';
    IF p_ext_ref6 IS NOT NULL
    THEN
      cHeader_where := cHeader_where                                ||
                       ' AND '                                      ||
                       'ece_advo_headers_v.external_reference6 = '  ||
                       ':l_ext_ref6';

    END IF;

    xProgress   := 'ADVOB-10-1170';
    cLine_where := cLine_where                                      ||
                   'ADVICE_HEADER_ID = :l_advice_header_id';

    /*
    **
    **  Build the complete SELECT statement for each level.
    **
    */

    xProgress      := 'ADVOB-10-1180';
    cHeader_select := cHeader_select                                ||
                      cHeader_from                                  ||
                      cHeader_where;
    ec_debug.pl ( 3, 'cHeader_select: ',cHeader_select );

    xProgress      := 'ADVOB-10-1190';
    cLine_select   := cLine_select                                  ||
                      cLine_from                                    ||
                      cLine_where;
    ec_debug.pl ( 3, 'cLine_select: ',cLine_select );

    /*
    **
    **  Open a cursor for each of the SELECT calls.  This tells the
    **  database to reserve space for the data returned by the SELECT
    **  statement.
    **
    */

    xProgress    := 'ADVOB-10-1200';
    Header_sel_c := dbms_sql.open_cursor;

    xProgress    := 'ADVOB-10-1210';
    Line_sel_c   := dbms_sql.open_cursor;

    /*
    **
    **  Parse each SELECT statement so the database understands the
    **  command.  If the parse fails, trap and print the point of
    **  failure and exit the procedure with an error.
    **
    */

    xProgress := 'ADVOB-10-1220';
    BEGIN
      dbms_sql.parse ( Header_sel_c,
                       cHeader_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_select );
        app_exception.raise_exception;
    END;

    xProgress := 'ADVOB-10-1230';
    BEGIN
      dbms_sql.parse ( Line_sel_c,
                       cLine_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_select );
        app_exception.raise_exception;
    END;

    /*
    **
    **  Initialize counter variables.
    **
    */

    xProgress     := 'ADVOB-10-1240';
    iHeader_count := l_header_tbl.count;
    ec_debug.pl ( 3, 'iHeader_count: ',iHeader_count );

    xProgress     := 'ADVOB-10-1250';
    iLine_count   := l_line_tbl.count;
    ec_debug.pl ( 3, 'iLine_count: ',iLine_count );

    /*
    **
    **  Define the data type for every column in each SELECT statement
    **  so the database understands how to populate it.
    **
    */

    xProgress := 'ADVOB-10-1260';
    FOR k IN 1..iHeader_count
    LOOP
      dbms_sql.define_column ( Header_sel_c,
                               k,
                               cHeader_select,
                               ece_extract_utils_PUB.G_MaxColWidth );
    END LOOP;

    xProgress := 'ADVOB-10-1270';
    FOR k IN 1..iLine_count
    LOOP
      dbms_sql.define_column ( Line_sel_c,
                               k,
                               cLine_select,
                               ece_extract_utils_PUB.G_MaxColWidth );
    END LOOP;

    /*
    **
    **  Find the positions of the Transaction_Date and the
    **  Advice_Header_ID in the PL/SQL table.
    **
    */

    xProgress := 'ADVOB-10-1280';
    ece_extract_utils_pub.Find_pos ( l_header_tbl,
                                     ece_extract_utils_pub.G_Transaction_date,
                                     n_trx_date_pos );
    ec_debug.pl(3, 'n_trx_date_pos: ',n_trx_date_pos );

    xProgress := 'ADVOB-10-1290';
    ece_extract_utils_pub.Find_pos ( l_header_tbl,
                                     'ADVICE_HEADER_ID',
                                     n_advice_header_id_pos );
    ec_debug.pl(3, 'n_advice_header_id_pos: ',n_advice_header_id_pos );


    xProgress := 'ADVOB-10-1291';
    IF p_TP_Group IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_TP_Group',
                               p_TP_Group );
    END IF;

    xProgress := 'ADVOB-10-1292';
    IF p_TP IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_TP',
                               p_TP );
    END IF;

    xProgress := 'ADVOB-10-1293';
    IF p_Response_to_doc IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_Response_to_doc',
                               p_Response_to_doc);
    END IF;

    xProgress := 'ADVOB-10-1294';
    IF p_Date_From IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_Date_From',
                               p_Date_From );
    END IF;

    xProgress := 'ADVOB-10-1295';
    IF p_Date_To IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_Date_To',
                               p_Date_To );
    END IF;

    xProgress := 'ADVOB-10-1296';
    IF p_ext_ref1 IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_ext_ref1',
                               p_ext_ref1 );
    END IF;

    xProgress := 'ADVOB-10-1297';
    IF p_ext_ref2 IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_ext_ref2',
                               p_ext_ref2 );
    END IF;

    xProgress := 'ADVOB-10-1298';
    IF p_ext_ref3 IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_ext_ref3',
                               p_ext_ref3 );
    END IF;

    xProgress := 'ADVOB-10-1299';
    IF p_ext_ref4 IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_ext_ref4',
                               p_ext_ref4 );
    END IF;

    xProgress := 'ADVOB-10-1300';
    IF p_ext_ref5 IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_ext_ref5',
                               p_ext_ref5 );
    END IF;

    xProgress := 'ADVOB-10-1301';
    IF p_ext_ref6 IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_ext_ref6',
                               p_ext_ref6 );
    END IF;

    /*
    **
    **  Execute the Header level SELECT statement.
    **
    */

    xProgress              := 'ADVOB-10-1302';
    l_header_row_processed := dbms_sql.execute ( Header_sel_c );

    /*
    **
    **  Begin the Header level loop.
    **
    */

    xProgress := 'ADVOB-10-1310';
    WHILE dbms_sql.fetch_rows ( Header_sel_c ) > 0
    LOOP           -- Header

      /*
      **
      **  Store the returned values in the PL/SQL table.
      **
      */

      xProgress := 'ADVOB-10-1320';
      FOR i IN 1..iHeader_count
      LOOP
        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_header_tbl(i).value );
      -- fix for 5711134

        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_key_tbl(i).value );


      END LOOP;

      ec_debug.pl ( 3, 'l_header_tbl(n_advice_header_id_pos).value: ',l_header_tbl(n_advice_header_id_pos).value );

      /*
      **
      **  Update ECE_ADVO_HEADERS to archive the current Advice header.
      **
      */

      UPDATE ece_advo_headers
         SET edi_processed_flag = 'Y',
             edi_process_date   = SYSDATE
       WHERE advice_header_id   = l_header_tbl(n_advice_header_id_pos).value;

      IF SQL%NOTFOUND
      THEN
        ec_debug.pl ( 0,
                      'EC',
                      'ECE_NO_ROW_UPDATED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'EDI_PROCESSED_FLAG',
                      'TABLE_NAME',
                      'ECE_ADVO_HEADERS' );
      END IF;

      /*
      **
      **  Set the value of the Transaction_Date column in the
      **  PL/SQL table.
      **
      */

      xProgress := 'ADVOB-10-1330';
      l_header_tbl(n_trx_date_pos).value := TO_CHAR(dTransaction_date,'YYYYMMDD HH24MISS' );
      ec_debug.pl ( 3, 'l_header_tbl(n_trx_date_pos).value: ',l_header_tbl(n_trx_date_pos).value );

      /*
      **
      **  Pass the PL/SQL table to the Code Cross Reference engine.
      **
      */

      xProgress := 'ADVOB-10-1340';
      EC_Code_Conversion_PVT.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                              p_return_status      => l_return_status,
                                                              p_msg_count          => l_msg_count,
                                                              p_msg_data           => l_msg_data,
                                                              p_key_tbl            => l_key_tbl,
                                                              p_tbl                => l_header_tbl );

      /*
      **
      **  Retrieve the next sequence number for the primary key value, and
      **  insert this record into the Header interface table.
      **
      */

      xProgress := 'ADVOB-10-1350';
      BEGIN
        SELECT ece_advo_headers_interface_s.nextval
          INTO l_header_fkey
          FROM sys.dual;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 0,
                        'EC',
                        'ECE_GET_NEXT_SEQ_FAILED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'SEQ',
                        'ECE_ADVO_HEADERS_INTERFACE_S' );
      END;

      ec_debug.pl ( 3, 'l_header_fkey: ',l_header_fkey );

      xProgress := 'ADVOB-10-1360';
      ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id,
                                                        cTransaction_Type,
                                                        cCommunication_Method,
                                                        cHeader_Interface,
                                                        l_header_tbl,
                                                        l_header_fkey );

      /*
      **
      **  Call the (customizable) procedure to populate the corresponding
      **  extension table.
      **
      */

      xProgress := 'ADVOB-10-1370';
      ece_advo_X.populate_extension_headers ( l_header_fkey,
                                              l_header_tbl );

      /*
      **
      **  Bind the "Advice_Header_ID" variable in
      **  the SELECT clause of the Line level.
      **
      */

      xProgress := 'ADVOB-10-1380';
      dbms_sql.bind_variable ( Line_sel_c,
                               'l_advice_header_id',
                               l_header_tbl(n_advice_header_id_pos).value );

      /*
      **
      **  Execute the Line level SELECT statement.
      **
      */

      xProgress := 'ADVOB-10-1390';
      l_line_row_processed := dbms_sql.execute ( Line_sel_c );

      /*
      **
      **  Begin the Line level loop.
      **
      */

      xProgress := 'ADVOB-10-1400';
      WHILE dbms_sql.fetch_rows ( Line_sel_c ) > 0
      LOOP        --- Line

        /*
        **
        **  Store the returned values in the PL/SQL table.
        **
        */

        xProgress := 'ADVOB-10-1410';
        FOR j IN 1..iLine_count LOOP
          dbms_sql.column_value ( Line_sel_c,
                                  j,
                                  l_line_tbl(j).value );

        -- fix for bug 5711134
          dbms_sql.column_value ( Line_sel_c,
                                  j,
                                  l_key_tbl(iHeader_count + j).value );

        END LOOP;

        /*
        **
        **  Pass the PL/SQL table to the Code Cross Reference engine.
        **
        */

        xProgress := 'ADVOB-10-1420';
        EC_Code_Conversion_PVT.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                                p_return_status      => l_return_status,
                                                                p_msg_count          => l_msg_count,
                                                                p_msg_data           => l_msg_data,
                                                                p_key_tbl            => l_key_tbl,
                                                                p_tbl                => l_line_tbl );

        /*
        **
        **  Retrieve the next sequence number for the primary key value, and
        **  insert this record into the Line interface table.
        **
        */

        xProgress := 'ADVOB-10-1430';
        BEGIN
          SELECT ece_advo_details_interface_s.nextval
            INTO l_line_fkey
            FROM sys.dual;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 0,
                          'EC',
                          'ECE_GET_NEXT_SEQ_FAILED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'SEQ',
                          'ECE_ADVO_DETAILS_INTERFACE_S' );
        END;

        ec_debug.pl ( 3, 'l_line_fkey: ',l_line_fkey );

        xProgress := 'ADVOB-10-1440';
        ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id,
                                                          cTransaction_Type,
                                                          cCommunication_Method,
                                                          cLine_Interface,
                                                          l_line_tbl,
                                                          l_line_fkey );

        /*
        **
        **  Call the (customizable) procedure to populate the corresponding
        **  extension table.
        **
        */

        xProgress := 'ADVOB-10-1440';
        ece_advo_X.populate_extension_details ( l_line_fkey,
                                                l_line_tbl );


      END LOOP;  /*  Line WHILE loop  */

      xProgress := 'ADVOB-10-1443';
      IF ( dbms_sql.last_row_count = 0 )
      THEN
        v_LevelProcessed := 'DETAIL';
        ec_debug.pl ( 0,
                      'EC',
                      'ECE_NO_DB_ROW_PROCESSED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'LEVEL_PROCESSED',
                      v_LevelProcessed,
                      'TRANSACTION_TYPE',
                      cTransaction_Type );
      END IF;

    END LOOP;  /*  Header WHILE loop  */

    xProgress := 'ADVOB-10-1446';
    IF ( dbms_sql.last_row_count = 0 )
    THEN
      v_LevelProcessed := 'HEADER';
      ec_debug.pl ( 0,
                    'EC',
                    'ECE_NO_DB_ROW_PROCESSED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'LEVEL_PROCESSED',
                    v_LevelProcessed,
                    'TRANSACTION_TYPE',
                    cTransaction_Type );
    END IF;

    /*
    **
    **  Close all open cursors.
    **
    */

    xProgress := 'ADVOB-10-1450';
    dbms_sql.close_cursor(Header_sel_c );

    xProgress := 'ADVOB-10-1460';
    dbms_sql.close_cursor(Line_sel_c );

    ec_debug.pop('ece_advo_advice_pkg.Extract_From_Base_Apps' );

  EXCEPTION
    WHEN OTHERS THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_PROGRAM_ERROR',
                    'PROGRESS_LEVEL',
                    xProgress  );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM );

      app_exception.raise_exception;

  END Extract_From_Base_Apps;


  -- **************************************************************************
  --  PROCEDURE Put_Data_To_Output_Table
  --  This procedure has the following functionalities:
  --  1. Build SQL statement dynamically to extract data from
  --      Interface Tables.
  --  2. Execute the dynamic SQL statement.
  --  3. Populate the ECE_OUTPUT table with the extracted data.
  --  4. Delete data from Interface Tables.
  -- **************************************************************************


  PROCEDURE Put_Data_To_Output_Table ( cCommunication_Method IN VARCHAR2,
                                       cTransaction_Type     IN VARCHAR2,
                                       iOutput_width         IN INTEGER,
                                       iRun_id               IN INTEGER,
                                       cHeader_Interface     IN VARCHAR2,
                                       cLine_Interface       IN VARCHAR2 )
  IS

    /*
    **
    **  Variable definitions.  'Interface_tbl_type' is a PL/SQL table typedef
    **  with the following structure:
    **
    **  base_table_name         VARCHAR2(50)
    **  base_column_name        VARCHAR2(50)
    **  interface_table_name    VARCHAR2(50)
    **  interface_column_name   VARCHAR2(50)
    **  Record_num              NUMBER
    **  Position                NUMBER
    **  data_type               VARCHAR2(50)
    **  data_length             NUMBER
    **  value                   VARCHAR2(400)
    **  layout_code             VARCHAR2(2)
    **  record_qualifier        VARCHAR2(3)
    **  interface_column_id     NUMBER
    **  conversion_seq          NUMBER
    **  xref_category_id        NUMBER
    **  conversion_group_id     NUMBER
    **  xref_key1_source_column VARCHAR2(50)
    **  xref_key2_source_column VARCHAR2(50)
    **  xref_key3_source_column VARCHAR2(50)
    **  xref_key4_source_column VARCHAR2(50)
    **  xref_key5_source_column VARCHAR2(50)
    **  ext_val1                VARCHAR2(80)
    **  ext_val2                VARCHAR2(80)
    **  ext_val3                VARCHAR2(80)
    **  ext_val4                VARCHAR2(80)
    **  ext_val5                VARCHAR2(80)
    **
    */

    xProgress                VARCHAR2(30);
    v_LevelProcessed         VARCHAR2(40);
    cOutput_path             VARCHAR2(120);

    l_header_tbl             ece_flatfile_pvt.Interface_tbl_type;
    l_line_tbl               ece_flatfile_pvt.Interface_tbl_type;

    c_header_common_key_name VARCHAR2(40);
    c_line_common_key_name   VARCHAR2(40);
    c_key_3                  VARCHAR2(22):= RPAD(' ',22);
    c_file_common_key        VARCHAR2(255);

    nHeader_key_pos          NUMBER;
    nLine_key_pos            NUMBER;
    nLine_t_key_pos          NUMBER;
    nTrans_code_pos          NUMBER;

    Header_sel_c             INTEGER;
    Line_sel_c               INTEGER;

    Header_del_c1            INTEGER;
    Line_del_c1              INTEGER;

    Header_del_c2            INTEGER;
    Line_del_c2              INTEGER;

    cHeader_select           VARCHAR2(32000);
    cLine_select             VARCHAR2(32000);

    cHeader_from             VARCHAR2(32000);
    cLine_from               VARCHAR2(32000);

    cHeader_where            VARCHAR2(32000);
    cLine_where              VARCHAR2(32000);

    cHeader_delete1          VARCHAR2(32000);
    cLine_delete1            VARCHAR2(32000);

    cHeader_delete2          VARCHAR2(32000);
    cLine_delete2            VARCHAR2(32000);

    iHeader_count            NUMBER;
    iLine_count              NUMBER;

    n_advice_header_id_pos   NUMBER;

    rHeader_rowid            ROWID;
    rLine_rowid              ROWID;

    cHeader_X_Interface      VARCHAR2(50);
    cLine_X_Interface        VARCHAR2(50);

    rHeader_X_rowid          ROWID;
    rLine_X_rowid            ROWID;

    dummy                    INTEGER;

  BEGIN

    /*
    **
    **  Debug statements for the parameter values.
    **
    */

    ec_debug.push ( 'ece_advo_advice_pkg.Put_Data_To_Output_Table' );
    ec_debug.pl ( 3, 'cCommunication_Method: ', cCommunication_Method );
    ec_debug.pl ( 3, 'cTransaction_Type: ',cTransaction_Type );
    ec_debug.pl ( 3, 'iOutput_width: ',iOutput_width );
    ec_debug.pl ( 3, 'iRun_id: ',iRun_id );
    ec_debug.pl ( 3, 'cHeader_Interface: ',cHeader_Interface );
    ec_debug.pl ( 3, 'cLine_Interface: ',cLine_Interface );



    /*
    **
    **  The 'select_clause' procedure will build the SELECT, FROM and WHERE
    **  clauses in preparation for the dynamic SQL call using the EDI data
    **  dictionary for the build.  Any necessary customizations to these
    **  clauses need to be made *after* the clause is built, but *before*
    **  the SQL call.
    **
    */


    xProgress := 'ADVOB-20-1020';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cHeader_Interface,
                                     cHeader_X_Interface,
                                     l_header_tbl,
                                     c_header_common_key_name,
                                     cHeader_select,
                                     cHeader_from,
                                     cHeader_where );


    xProgress := 'ADVOB-20-1030';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cLine_Interface,
                                     cLine_X_Interface,
                                     l_line_tbl,
                                     c_line_common_key_name,
                                     cLine_select,
                                     cLine_from,
                                     cLine_where );

    /*
    **
    **  Customize the WHERE clauses to insure the proper joins, and
    **  customize the SELECT clauses to include the ROWID.  Records
    **  will be deleted from the interface tables using these ROWID
    **  values.
    **
    */

    xProgress     := 'ADVOB-20-1040';
    cHeader_where := cHeader_where                                ||
                     ' AND '                                      ||
                     cHeader_Interface                            ||
                     '.RUN_ID ='                                  ||
                     ':l_iRun_id';


    xProgress     := 'ADVOB-20-1050';
    cLine_where   := cLine_where                                  ||
                     ' AND '                                      ||
                     cLine_Interface                              ||
                     '.RUN_ID ='                                  ||
                     ':x_iRun_id'                                 ||
                     ' AND '                                      ||
                     cLine_Interface                              ||
                     '.ADVICE_HEADER_ID = :x_advice_header_id';

    xProgress      := 'ADVOB-20-1060';
    cHeader_select := cHeader_select                              ||
                      ','                                         ||
                      cHeader_Interface                           ||
                      '.ROWID, '                                  ||
                      cHeader_X_Interface                         ||
                      '.ROWID';

    xProgress      := 'ADVOB-20-1070';
    cLine_select   := cLine_select                                ||
                      ','                                         ||
                      cLine_Interface                             ||
                      '.ROWID,'                                   ||
                      cLine_X_Interface                           ||
                      '.ROWID';

    /*
    **
    **  Build the complete SELECT and DELETE statements
    **  for each level.
    **
    */

    xProgress      := 'ADVOB-20-1080';
    cHeader_select := cHeader_select                              ||
                      cHeader_from                                ||
                      cHeader_where                               ||
                      ' FOR UPDATE';
    ec_debug.pl ( 3, 'cHeader_select: ',cHeader_select );

    xProgress      := 'ADVOB-20-1090';
    cLine_select   := cLine_select                                ||
                      cLine_from                                  ||
                      cLine_where                                 ||
                      ' FOR UPDATE';
    ec_debug.pl ( 3, 'cLine_select: ',cLine_select );

    xProgress       := 'ADVOB-20-1100';
    cHeader_delete1 := 'DELETE FROM '                             ||
                       cHeader_Interface                          ||
                       ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cHeader_delete1: ',cHeader_delete1 );

    xProgress       := 'ADVOB-20-1110';
    cLine_delete1   := 'DELETE FROM '                             ||
                       cLine_Interface                            ||
                       ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cLine_delete1: ',cLine_delete1 );

    xProgress       := 'ADVOB-20-1120';
    cHeader_delete2 := 'DELETE FROM '                             ||
                       cHeader_X_Interface                        ||
                       ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cHeader_delete2: ',cHeader_delete2 );

    xProgress       := 'ADVOB-20-1130';
    cLine_delete2   := 'DELETE FROM '                             ||
                       cLine_X_Interface                          ||
                       ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cLine_delete2: ',cLine_delete2 );

    /*
    **
    **  Open a cursor for each SELECT and DELETE call.  This tells
    **  the database to reserve space for the data returned by the
    **  SELECT and DELETE statements.
    **
    */

    xProgress     := 'ADVOB-20-1140';
    Header_sel_c  := dbms_sql.open_cursor;

    xProgress     := 'ADVOB-20-1150';
    Line_sel_c    := dbms_sql.open_cursor;

    xProgress     := 'ADVOB-20-1160';
    Header_del_c1 := dbms_sql.open_cursor;

    xProgress     := 'ADVOB-20-1170';
    Line_del_c1   := dbms_sql.open_cursor;

    xProgress     := 'ADVOB-20-1180';
    Header_del_c2 := dbms_sql.open_cursor;

    xProgress     := 'ADVOB-20-1190';
    Line_del_c2   := dbms_sql.open_cursor;

    /*
    **
    **  Parse each SELECT and DELETE statement so the database understands
    **  the command.
    **
    */

    xProgress := 'ADVOB-20-1200';
    BEGIN
      dbms_sql.parse ( Header_sel_c,
                       cHeader_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_select  );
        app_exception.raise_exception;
    END;

    xProgress := 'ADVOB-20-1210';
    BEGIN
      dbms_sql.parse ( Line_sel_c,
                       cLine_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_select );
        app_exception.raise_exception;
    END;

    xProgress := 'ADVOB-20-1220';
    BEGIN
      dbms_sql.parse ( Header_del_c1,
                       cHeader_delete1,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_delete1  );
        app_exception.raise_exception;
    END;

    xProgress := 'ADVOB-20-1230';
    BEGIN
      dbms_sql.parse ( Line_del_c1,
                       cLine_delete1,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_delete1 );
        app_exception.raise_exception;
    END;

    xProgress := 'ADVOB-20-1240';
    BEGIN
      dbms_sql.parse ( Header_del_c2,
                       cHeader_delete2,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_delete2 );
        app_exception.raise_exception;
    END;

    xProgress := 'ADVOB-20-1250';
    BEGIN
      dbms_sql.parse ( Line_del_c2,
                       cLine_delete2,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_delete2 );
        app_exception.raise_exception;
    END;

    /*
    **
    **  Initialize all counters.
    **
    */

    xProgress     := 'ADVOB-20-1260';
    iHeader_count := l_header_tbl.count;
    ec_debug.pl ( 3, 'iHeader_count: ',iHeader_count );

    xProgress     := 'ADVOB-20-1270';
    iLine_count   := l_line_tbl.count;
    ec_debug.pl ( 3, 'iLine_count: ',iLine_count );

    /*
    **
    **  Define the data type for every column in the Header
    **  SELECT statement so the database understands how to
    **  populate it.
    **
    */

    xProgress := 'ADVOB-20-1280';
    FOR k IN 1..iHeader_count
    LOOP
      dbms_sql.define_column ( Header_sel_c,
                               k,
                               cHeader_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    /*
    **
    **  Define the ROWIDs for the Header
    **  DELETE statements.
    **
    */

    xProgress := 'ADVOB-20-1290';
    dbms_sql.define_column_rowid ( Header_sel_c,
                                   iHeader_count + 1,
                                   rHeader_rowid );

    xProgress := 'ADVOB-20-1300';
    dbms_sql.define_column_rowid ( Header_sel_c,
                                   iHeader_count + 2,
                                   rHeader_X_rowid );

    /*
    **
    **  Define the data type for every column in the Line
    **  SELECT statement so the database understands how to
    **  populate it.
    **
    */

    xProgress := 'ADVOB-20-1310';
    FOR k IN 1..iLine_count
    LOOP
      dbms_sql.define_column ( Line_sel_c,
                               k,
                               cLine_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    /*
    **
    **  Define the ROWIDs for the Line
    **  DELETE statements.
    **
    */

    xProgress := 'ADVOB-20-1320';
    dbms_sql.define_column_rowid ( Line_sel_c,
                                   iLine_count + 1,
                                   rLine_rowid );

    xProgress := 'ADVOB-20-1330';
    dbms_sql.define_column_rowid ( Line_sel_c,
                                   iLine_count + 2,
                                   rLine_X_rowid );

    /*
    **
    **  Find the necessary columns in the PL/SQL tables for the
    **  Common Key values.
    **
    */

    xProgress := 'ADVOB-20-1340';
    ece_flatfile_pvt.Find_pos ( l_header_tbl,
                                ece_flatfile_pvt.G_Translator_Code,
                                nTrans_code_pos );
    ec_debug.pl ( 3, 'nTrans_code_pos: ',nTrans_code_pos );

    xProgress := 'ADVOB-20-1350';
    ece_flatfile_pvt.Find_pos ( l_header_tbl,
                                c_header_common_key_name,
                                nHeader_key_pos );
    ec_debug.pl ( 3, 'nHeader_key_pos: ',nHeader_key_pos );

    xProgress := 'ADVOB-20-1360';
    ece_flatfile_pvt.Find_pos ( l_header_tbl,
                                'ADVICE_HEADER_ID',
                                n_advice_header_id_pos );
    ec_debug.pl ( 3, 'n_advice_header_id_pos: ',n_advice_header_id_pos );


    xProgress := 'ADVOB-20-1370';
    ece_flatfile_pvt.Find_pos ( l_line_tbl,
                                c_line_common_key_name,
                                nLine_key_pos );
    ec_debug.pl ( 3, 'nLine_key_pos: ',nLine_key_pos );

    xProgress := 'ADVOB-20-1371';
    dbms_sql.bind_variable ( Header_sel_c,
                               'l_iRun_id',
                               iRun_id );


    /*
    **
    **  Execute the Header level SELECT statement.
    **
    */

    xProgress := 'ADVOB-20-1380';
    dummy := dbms_sql.execute ( Header_sel_c );

    /*
    **
    **  Begin the Header level loop.
    **
    */

    xProgress := 'ADVOB-20-1390';
    WHILE dbms_sql.fetch_rows ( Header_sel_c ) > 0
    LOOP           -- Header

      /*
      **
      **  Store the returned values in the PL/SQL table.
      **
      */

      xProgress := 'ADVOB-20-1400';
      FOR i IN 1..iHeader_count
      LOOP
        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_header_tbl(i).value );
      END LOOP;

      /*
      **
      **  Store the ROWIDs.
      **
      */

      xProgress := 'ADVOB-20-1410';
      dbms_sql.column_value ( Header_sel_c,
                              iHeader_count + 1,
                              rHeader_rowid );

      xProgress := 'ADVOB-20-1420';
      dbms_sql.column_value ( Header_sel_c,
                              iHeader_count + 2,
                              rHeader_X_rowid );

      /*
      **
      **  Build the Common Key record for this level.
      **
      */

      xProgress         := 'ADVOB-20-1430';
      c_file_common_key := RPAD(NVL(SUBSTRB(l_header_tbl(nTrans_code_pos).value, 1, 25),
                                    ' '),
                                25 );

      xProgress         := 'ADVOB-20-1440';
      c_file_common_key := c_file_common_key                                             ||
                           RPAD(NVL(SUBSTRB(l_header_tbl(nHeader_key_pos).value, 1, 22),
                                    ' '),
                                22)                                                      ||
                           c_key_3                                                       ||
                           c_key_3;
      ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

      /*
      **
      **  Write the record to the output table.
      **
      */

      xProgress := 'ADVOB-20-1450';
      ece_flatfile_pvt.write_to_ece_output ( cTransaction_Type,
                                             cCommunication_Method,
                                             cHeader_Interface,
                                             l_header_tbl,
                                             iOutput_width,
                                             iRun_id,
                                             c_file_common_key );

      /*
      **
      **  Bind the Advice_Header_ID variable in the Line
      **  SELECT clause.
      **
      */

      xProgress := 'ADVOB-20-1460';
      dbms_sql.bind_variable ( Line_sel_c,
                               'x_iRun_id',
                                iRun_id);


      xProgress := 'ADVOB-20-1461';
      dbms_sql.bind_variable ( Line_sel_c,
                               'x_advice_header_id',
                               l_header_tbl(n_advice_header_id_pos).value );

      /*
      **
      **  Execute the Line level SELECT statement.
      **
      */

      xProgress := 'ADVOB-20-1470';
      dummy     := dbms_sql.execute ( Line_sel_c );

      /*
      **
      **  Begin the Line level loop.
      **
      */

      xProgress := 'ADVOB-20-1480';
      WHILE dbms_sql.fetch_rows(Line_sel_c) > 0 LOOP        --- Line

        /*
        **
        **  Store the returned values in the PL/SQL table.
        **
        */

        xProgress := 'ADVOB-20-1490';
        FOR j IN 1..iLine_count
        LOOP
          dbms_sql.column_value ( Line_sel_c,
                                  j,
                                  l_line_tbl(j).value );
        END LOOP;

        /*
        **
        **  Store the ROWIDs.
        **
        */

        xProgress := 'ADVOB-20-1500';
        dbms_sql.column_value ( Line_sel_c,
                                iLine_count + 1,
                                rLine_rowid );

        xProgress := 'ADVOB-20-1510';
        dbms_sql.column_value ( Line_sel_c,
                                iLine_count + 2,
                                rLine_X_rowid );

        /*
        **
        **  Build the Common Key record for this level.
        **
        */

        xProgress := 'ADVOB-20-1520';
        c_file_common_key := RPAD(NVL(SUBSTRB(l_header_tbl(nTrans_code_pos).value, 1, 25),
                                      ' '),
                                  25)                                                     ||
                             RPAD(NVL(SUBSTRB(l_header_tbl(nHeader_key_pos).value, 1, 22),
                                      ' '),
                                  22)                                                     ||
                             RPAD(NVL(SUBSTRB(l_line_tbl(nLine_key_pos).value, 1, 22),
                                      ' '),
                                  22)                                                     ||
                             c_key_3;
        ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

        /*
        **
        **  Write the record to the output table.
        **
        */

        xProgress := 'ADVOB-20-1530';
        ece_flatfile_pvt.write_to_ece_output ( cTransaction_Type,
                                               cCommunication_Method,
                                               cLine_Interface,
                                               l_line_tbl,
                                               iOutput_width,
                                               iRun_id,
                                               c_file_common_key );

        /*
        **
        **  Bind the variables (ROWIDs) in the DELETE statements.
        **
        */

        xProgress := 'ADVOB-20-1540';
        dbms_sql.bind_variable ( Line_del_c1,
                                 'col_rowid',
                                 rLine_rowid );

        xProgress := 'ADVOB-20-1550';
        dbms_sql.bind_variable ( Line_del_c2,
                                 'col_rowid',
                                 rLine_X_rowid );

        /*
        **
        **  Delete the rows from the interface table.
        **
        */

        xProgress := 'ADVOB-20-1560';
        dummy := dbms_sql.execute ( Line_del_c1 );

        xProgress := 'ADVOB-20-1570';
        dummy := dbms_sql.execute ( Line_del_c2 );

      END LOOP;  /*  Line WHILE loop  */

      xProgress := 'ADVOB-20-1575';
      IF ( dbms_sql.last_row_count = 0 )
      THEN
        v_LevelProcessed := 'LINE';
        ec_debug.pl ( 0,
                      'EC',
                      'ECE_NO_DB_ROW_PROCESSED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'LEVEL_PROCESSED',
                      v_LevelProcessed,
                      'TRANSACTION_TYPE',
                      cTransaction_Type  );
      END IF;

      /*
      **
      **  Bind the variables (ROWIDs) in the DELETE statements.
      **
      */

      xProgress := 'ADVOB-20-1580';
      dbms_sql.bind_variable ( Header_del_c1,
                               'col_rowid',
                               rHeader_rowid );

      xProgress := 'ADVOB-20-1590';
      dbms_sql.bind_variable ( Header_del_c2,
                               'col_rowid',
                               rHeader_X_rowid );

      /*
      **
      **  Delete the rows from the interface table.
      **
      */

      xProgress := 'ADVOB-20-1600';
      dummy := dbms_sql.execute ( Header_del_c1 );

      xProgress := 'ADVOB-20-1610';
      dummy := dbms_sql.execute ( Header_del_c2 );


    END LOOP;  /*  Header WHILE loop  */

    xProgress := 'ADVOB-20-1615';
    IF ( dbms_sql.last_row_count = 0 )
    THEN
      v_LevelProcessed := 'HEADER';
      ec_debug.pl ( 0,
                    'EC',
                    'ECE_NO_DB_ROW_PROCESSED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'LEVEL_PROCESSED',
                    v_LevelProcessed,
                    'TRANSACTION_TYPE',
                    cTransaction_Type  );
    END IF;

    /*
    **
    **  Close all open cursors.
    **
    */

    xProgress := 'ADVOB-20-1620';
    dbms_sql.close_cursor ( Header_sel_c );

    xProgress := 'ADVOB-20-1630';
    dbms_sql.close_cursor ( Line_sel_c );

    xProgress := 'ADVOB-20-1640';
    dbms_sql.close_cursor ( Header_del_c1 );

    xProgress := 'ADVOB-20-1650';
    dbms_sql.close_cursor ( Line_del_c1   );

    ec_debug.pop ( 'ece_advo_advice_pkg.Put_Data_To_Output_Table' );

  EXCEPTION
    WHEN OTHERS THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_PROGRAM_ERROR',
                    'PROGRESS_LEVEL',
                    xProgress  );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM  );

      app_exception.raise_exception;

  END Put_Data_To_Output_Table;

END ece_advo_advice_pkg;

/
