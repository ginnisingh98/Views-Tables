--------------------------------------------------------
--  DDL for Package Body GML_GASNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_GASNO" as
/* $Header: GMLSNOB.pls 115.21 2002/11/08 16:08:16 gmangari ship $ */
/*=============================  GML_GASNO  =================================*/
/*============================================================================
  PURPOSE:       Creates procedures for exporting Ship Notice information
                 to a flat file, and the API called by Shipping to initiate
                 the extract process.

  NOTES:         To run the script:

                 sql> start GMLSNO.pls

  HISTORY:       01/26/99  mmacary   created.
                 02/23/99  rlein     modified.
                 04/06/99  siwang    modified for 11i.
                 05/06/99  dgrailic  modified for 11i.
                    Changed ECE_ to GML_ prefix.  Ported some 11.0 fixes to 11i
                    Corrected some obsolete references to DSNO to GASNO
                 06/08/99  dgrailic  made argumnet list agrree with concurent
                    program parameter list.
                 08/05/99  mguthrie   Added calls to ECE_FLATFILE_PVT.INIT_TABLE
                 10/27/99  SFeinstein B911176: changed format of date for Y2K
                 26-OCT-2002   Bug#2642152  RajaSekhar    Added NOCOPY hint

===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:      Extract_GASNO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible Deliveries on a Departure.

===========================================================================*/

 PROCEDURE Extract_GASNO_Outbound ( errbuf                     OUT NOCOPY VARCHAR2,
                                     retcode                    OUT NOCOPY VARCHAR2,
                                     p_OutputPath               IN  VARCHAR2,
                                     p_Filename                 IN  VARCHAR2,
                                     p_Orgn_Code                IN VARCHAR2,
                                     p_BOL_No_From              IN VARCHAR2,
                                     p_BOL_No_To                IN VARCHAR2,
                                     p_Creation_Date_From       IN VARCHAR2,
                                     p_Creation_Date_To         IN VARCHAR2,
                                     p_Customer_Name            IN VARCHAR2,
                                     p_debug_mode               IN  NUMBER default 0 )
  IS
    p_RunID                    NUMBER        :=  0;
    p_OutputWidth              INTEGER       :=  4000;
    p_TransactionType          VARCHAR2(120) := 'GASNO';
    p_CommunicationMethod      VARCHAR2(120) := 'EDI';
    p_SHP_Interface            VARCHAR2(120) := 'GML_GASNO_SHIPMENTS';
    p_STX_Interface            VARCHAR2(120) := 'GML_GASNO_SHIPMENT_TEXT';
    p_ORD_Interface            VARCHAR2(120) := 'GML_GASNO_ORDERS';
    p_OAC_Interface            VARCHAR2(120) := 'GML_GASNO_ORDER_CHARGES';
    p_OTX_Interface            VARCHAR2(120) := 'GML_GASNO_ORDER_TEXT';
    p_DTL_Interface            VARCHAR2(120) := 'GML_GASNO_DETAILS';
    p_DAC_Interface            VARCHAR2(120) := 'GML_GASNO_DETAIL_CHARGES';
    p_DTX_Interface            VARCHAR2(120) := 'GML_GASNO_DETAIL_TEXT';
    p_ALL_Interface            VARCHAR2(120) := 'GML_GASNO_DETAIL_ALLOCATIONS';
    v_OutputFilePtr            utl_file.file_type;
    v_OutputLine               VARCHAR2(2000);
    v_OutputRecordCount        NUMBER;
    v_industry                 VARCHAR2(240);
    v_oracle_schema            VARCHAR2(240);
    xProgress                  VARCHAR2(80);

    CURSOR c_OutputSource IS
       SELECT      text
       FROM        ece_output
       WHERE       run_id = p_RunID
       ORDER BY    line_id;

  BEGIN

    ec_debug.enable_debug ( p_debug_mode );
    ec_debug.push ( 'GML_GASNO.Extract_GASNO_Outbound' );
    ec_debug.pl ( 3, 'p_Orgn_Code: ', p_Orgn_Code );
    ec_debug.pl ( 3, 'p_BOL_No_From: ', p_BOL_No_From  );
    ec_debug.pl ( 3, 'p_BOL_No_To: ', p_BOL_No_To );
    ec_debug.pl ( 3, 'p_Creation_Date_From: ', p_Creation_Date_From );
    ec_debug.pl ( 3, 'p_Creation_Date_To: ', p_Creation_Date_To );
    ec_debug.pl ( 3, 'p_Customer_Name: ', p_Customer_Name );
    ec_debug.pl ( 3, 'p_OutputPath: ', p_OutputPath );
    ec_debug.pl ( 3, 'p_Filename: ', p_Filename );
    ec_debug.pl ( 3, 'p_debug_mode: ', p_debug_mode );

    xProgress := 'GASNO-10-1005';
    BEGIN
      SELECT   ece_output_runs_s.NEXTVAL
      INTO     p_RunID
      FROM     sys.dual;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 0,
                      'EC',
                      'GML_GET_NEXT_SEQ_FAILED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'SEQ',
                      'ECE_OUTPUT_RUNS_S' );
    END;
    ec_debug.pl(3, 'p_RunID: ',p_RunID);

    xProgress := 'GASNO-10-1015';
    ec_debug.pl ( 0, 'EC', 'GML_GASNO_START', NULL );

    xProgress := 'GASNO-10-1020';
    ec_debug.pl ( 0, 'EC', 'ECE_RUN_ID', 'RUN_ID', p_RunID );

    xProgress := 'GASNO-10-1030';
    GML_GASNO.Populate_Interface_Tables( p_CommunicationMethod,
                                         p_TransactionType,
                                         p_Orgn_Code,
                                         p_BOL_No_From,
                                         p_BOL_No_To,
                                         p_Creation_Date_From,
                                         p_Creation_Date_To,
                                         p_Customer_Name,
                                         p_RunID,
                                         p_SHP_Interface,
                                         p_STX_Interface,
                                         p_ORD_Interface,
                                         p_OAC_Interface,
                                         p_OTX_Interface,
                                         p_DTL_Interface,
                                         p_DAC_Interface,
                                         p_DTX_Interface,
                                         p_ALL_Interface );

    xProgress := 'GASNO-10-1040';
    GML_GASNO.Put_Data_To_Output_Table( p_CommunicationMethod,
                                        p_TransactionType,
                                        p_Orgn_Code,
                                        p_BOL_No_From,
                                        p_BOL_No_To,
                                        p_Creation_Date_From,
                                        p_Creation_Date_To,
                                        p_Customer_Name,
                                        p_RunID,
                                        p_OutputWidth,
                                        p_SHP_Interface,
                                        p_STX_Interface,
                                        p_ORD_Interface,
                                        p_OAC_Interface,
                                        p_OTX_Interface,
                                        p_DTL_Interface,
                                        p_DAC_Interface,
                                        p_DTX_Interface,
                                        p_ALL_Interface );

    xProgress := 'GASNO-10-1050';
    BEGIN
      SELECT   COUNT(*)
      INTO     v_OutputRecordCount
      FROM     ece_output
      WHERE    run_id = p_RunID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 0,
                      'EC',
                      'ECE_GET_COUNT_FAILED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'TABLE_NAME',
                      'ECE_OUTPUT' );
    END;
    ec_debug.pl ( 3, 'v_OutputRecordCount: ', v_OutputRecordCount );

    xProgress := 'GASNO-10-1060';
    IF v_OutputRecordCount > 0
    THEN
      xProgress := 'GASNO-10-1070';
      v_OutputFilePtr := utl_file.fopen ( p_OutputPath,
                                          p_FileName,
                                          'W' );

      xProgress := 'GASNO-10-1080';
      OPEN c_OutputSource;
      xProgress := 'GASNO-10-1090';
      LOOP
        xProgress := 'GASNO-10-1000';
        FETCH c_OutputSource
        INTO v_OutputLine;
        ec_debug.pl ( 3, 'v_OutputLine: ', v_OutputLine );

        xProgress := 'GASNO-10-1100';
        EXIT WHEN c_OutputSource%NOTFOUND;

        xProgress := 'GASNO-10-1200';
        utl_file.put_line ( v_OutputFilePtr,
                            v_OutputLine );
      END LOOP;

      xProgress := 'GASNO-10-1300';
      CLOSE c_OutputSource;

      xProgress := 'GASNO-10-1400';
      utl_file.fclose ( v_OutputFilePtr );

    END IF;

    xProgress := 'GASNO-10-1170';
    ec_debug.pl ( 0, 'EC', 'GML_GASNO_COMPLETE', NULL );

    xProgress := 'GASNO-10-1180';
    DELETE FROM ece_output
    WHERE       run_id = p_RunID;

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

   ec_debug.pop ( 'GML_GASNO.Extract_GASNO_Outbound' );
   ec_debug.disable_debug;
   COMMIT;

  EXCEPTION
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

    WHEN others then

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

  END Extract_GASNO_Outbound;

/*===========================================================================

  PROCEDURE NAME:      Populate_Interface_Tables

  PURPOSE:             This procedure initiates the export process for all
                       elegible Deliveries on a Departure.  For each Gateway
                       interface table in this transaction, a view has been
                       created to facilitate the extract process from the
                       Application tables.

===========================================================================*/

  PROCEDURE Populate_Interface_Tables ( p_CommunicationMethod      IN VARCHAR2,
                                        p_TransactionType          IN VARCHAR2,
                                        p_Orgn_Code                IN VARCHAR2,
                                        p_BOL_No_From              IN VARCHAR2,
                                        p_BOL_No_To                IN VARCHAR2,
                                        p_Creation_Date_From       IN VARCHAR2,
                                        p_Creation_Date_To         IN VARCHAR2,
                                        p_Customer_Name            IN VARCHAR2,
                                        p_RunID                    IN INTEGER,
                                        p_SHP_Interface             IN VARCHAR2,
                                        p_STX_Interface             IN VARCHAR2,
                                        p_ORD_Interface             IN VARCHAR2,
                                        p_OAC_Interface             IN VARCHAR2,
                                        p_OTX_Interface             IN VARCHAR2,
                                        p_DTL_Interface             IN VARCHAR2,
                                        p_DAC_Interface             IN VARCHAR2,
                                        P_DTX_Interface             IN VARCHAR2,
                                        p_ALL_Interface             IN VARCHAR2 )

  IS

    /*   Variable definitions.  'Source_tbl_type' is a PL/SQL table typedef */
    /*   with the following structure: */
    /*   data_loc_id             NUMBER */
    /*  table_name              VARCHAR2(50)    */
    /*  column_name             VARCHAR2(50)    */
    /*  base_table_name         VARCHAR2(50)    */
    /*  base_column_name        VARCHAR2(50)    */
    /*  xref_category_id        NUMBER    */
    /*  xref_key1_source_column VARCHAR2(50) */
    /*  xref_key2_source_column VARCHAR2(50) */
    /*  xref_key3_source_column VARCHAR2(50) */
    /*  xref_key4_source_column VARCHAR2(50) */
    /*  xref_key5_source_column VARCHAR2(50) */
    /*  data_type               VARCHAR2(50)    */
    /*  data_length             NUMBER          */
    /*  int_val                 VARCHAR2(400)   */
    /*  ext_val1                VARCHAR2(80)    */
    /*  ext_val2                VARCHAR2(80)    */
    /*  ext_val3                VARCHAR2(80)    */
    /*  ext_val4                VARCHAR2(80)    */
    /*  ext_val5                VARCHAR2(80)    */


    xProgress 			VARCHAR2(30);

    v_SHP_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_STX_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_ORD_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_OAC_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_OTX_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_DTL_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_DAC_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_DTX_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_ALL_Table          ece_flatfile_pvt.Interface_tbl_type;
    v_CrossRefTable      ece_flatfile_pvt.Interface_tbl_type;

    v_SHP_Cursor       INTEGER;
    v_STX_Cursor       INTEGER;
    v_ORD_Cursor       INTEGER;
    v_OAC_Cursor       INTEGER;
    v_OTX_Cursor       INTEGER;
    v_DTL_Cursor       INTEGER;
    v_DAC_Cursor       INTEGER;
    v_DTX_Cursor       INTEGER;
    v_ALL_Cursor       INTEGER;

    v_SHP_Select     VARCHAR2(32000);
    v_STX_Select     VARCHAR2(32000);
    v_ORD_Select     VARCHAR2(32000);
    v_OAC_Select     VARCHAR2(32000);
    v_OTX_Select     VARCHAR2(32000);
    v_DTL_Select     VARCHAR2(32000);
    v_DAC_Select     VARCHAR2(32000);
    v_DTX_Select     VARCHAR2(32000);
    v_ALL_Select     VARCHAR2(32000);


    v_SHP_From       VARCHAR2(32000);
    v_STX_From       VARCHAR2(32000);
    v_ORD_From       VARCHAR2(32000);
    v_OAC_From       VARCHAR2(32000);
    v_OTX_From       VARCHAR2(32000);
    v_DTL_From       VARCHAR2(32000);
    v_DAC_From       VARCHAR2(32000);
    v_DTX_From       VARCHAR2(32000);
    v_ALL_From       VARCHAR2(32000);

    v_SHP_Where      VARCHAR2(32000);
    v_STX_Where      VARCHAR2(32000);
    v_ORD_Where      VARCHAR2(32000);
    v_OAC_Where      VARCHAR2(32000);
    v_OTX_Where      VARCHAR2(32000);
    v_DTL_Where      VARCHAR2(32000);
    v_DAC_Where      VARCHAR2(32000);
    v_DTX_Where      VARCHAR2(32000);
    v_ALL_Where      VARCHAR2(32000);


    v_SHP_Count      INTEGER := 0;
    v_STX_Count      INTEGER := 0;
    v_ORD_Count      INTEGER := 0;
    v_OAC_Count      INTEGER := 0;
    v_OTX_Count      INTEGER := 0;
    v_DTL_Count      INTEGER := 0;
    v_DAC_Count      INTEGER := 0;
    v_DTX_Count      INTEGER := 0;
    v_ALL_Count      INTEGER := 0;
    v_CrossRefCount  INTEGER := 0;

    v_SHP_Key          NUMBER;
    v_STX_Key          NUMBER;
    v_ORD_Key          NUMBER;
    v_OAC_Key          NUMBER;
    v_OTX_Key          NUMBER;
    v_DTL_Key          NUMBER;
    v_DAC_Key          NUMBER;
    v_DTX_Key          NUMBER;
    v_ALL_Key          NUMBER;

    v_Dummy                INTEGER;
    v_Orgn_Code            VARCHAR2(32);
    v_BOL_No_From          VARCHAR2(32);
    v_BOL_No_To	           VARCHAR2(32);

/* SFeinstein 10/27/99 B911176: changed format of date for Y2K
    v_Creation_Date_From     VARCHAR2(15);
    v_Creation_Date_To       VARCHAR2(15);
*/
    v_Creation_Date_From     DATE        := TO_DATE(p_Creation_Date_From,'YYYY/MM/DD HH24:MI:SS');
    v_Creation_Date_To       DATE        := TO_DATE(p_Creation_Date_To,'YYYY/MM/DD HH24:MI:SS') + 1;
/*  end B911176 fix    */

    v_Customer_Name        VARCHAR2(32);
    v_BOL_ID_Position      INTEGER;
    V_BOL_ID               INTEGER;
    v_Line_ID_Position     INTEGER;
    v_Line_ID              INTEGER;
    v_Order_ID             INTEGER;
    v_Order_ID_Position    INTEGER;
    v_RunIDPosition        INTEGER;
    v_TimeStampSequence    INTEGER;
    v_TimeStampPosition    INTEGER;
    v_WarehouseCodeIntPos  INTEGER;
    v_TransactionRefKeyPos INTEGER;
    v_TimeStampDate        DATE;
    v_ReturnStatus         VARCHAR2(10);
    v_MessageCount         NUMBER;
    v_MessageData          VARCHAR2(255);
    v_OutputLevel          VARCHAR2(30);

    v_assignment_type      NUMBER;
    v_format_size          NUMBER;
    v_pad_char             VARCHAR2(1);

  BEGIN

    /*

      Debug statements for the parameter values.

    */

    ec_debug.push ( 'GML_GASNO.Populate_Interface_Tables' );
    ec_debug.pl ( 3, 'p_CommunicationMethod: ', p_CommunicationMethod );
    ec_debug.pl ( 3, 'p_TransactionType: ', p_TransactionType );
    ec_debug.pl ( 3, 'p_Orgn_Code: ', p_Orgn_Code );
    ec_debug.pl ( 3, 'p_BOL_No_From: ', p_BOL_No_From );
    ec_debug.pl ( 3, 'p_BOL_No_To: ', p_BOL_No_To );
    ec_debug.pl ( 3, 'p_Creation_Date_From: ', p_Creation_Date_From );
    ec_debug.pl ( 3, 'p_Creation_Date_To: ', p_Creation_Date_To );
    ec_debug.pl ( 3, 'p_Customer_Name: ', p_Customer_Name );
    ec_debug.pl ( 3, 'p_RunID: ', p_RunID );
    ec_debug.pl ( 3, 'p_SHP_Interface: ', p_SHP_Interface );
    ec_debug.pl ( 3, 'p_STX_Interface: ', p_STX_Interface );
    ec_debug.pl ( 3, 'p_ORD_Interface: ', p_ORD_Interface );
    ec_debug.pl ( 3, 'p_OAC_Interface: ', p_OAC_Interface );
    ec_debug.pl ( 3, 'p_OTX_Interface: ', p_OTX_Interface );
    ec_debug.pl ( 3, 'p_DTL_Interface: ', p_DTL_Interface );
    ec_debug.pl ( 3, 'p_DAC_Interface: ', p_DAC_Interface );
    ec_debug.pl ( 3, 'p_DTX_Interface: ', p_DTX_Interface );
    ec_debug.pl ( 3, 'p_ALL_Interface: ', p_ALL_Interface );

    /*
      Load each PL/SQL table.  The FOR loop implicitly handles all
      cursor processing.
    */
    v_Orgn_Code   := p_Orgn_Code;
    ec_debug.pl ( 3, 'v_Orgn_Code: ', v_Orgn_Code );
    v_BOL_No_From := p_BOL_No_From;
    ec_debug.pl ( 3, 'v_BOL_No_From: ', v_BOL_No_From );
    v_BOL_No_To   := p_BOL_No_To;
    ec_debug.pl ( 3, 'v_BOL_No_To: ', v_BOL_No_To );
/* SFeinstein 10/27/99 B911176: removed code for format change above
    v_Creation_Date_From := p_Creation_Date_From;
    v_Creation_Date_To   := p_Creation_Date_To;
*/
    ec_debug.pl ( 3, 'v_Creation_Date_From: ', v_Creation_Date_From );
    ec_debug.pl ( 3, 'v_Creation_Date_To: ', v_Creation_Date_To );
    v_Customer_Name      := p_Customer_Name;
    ec_debug.pl ( 3, 'v_Customer_Name: ', v_Customer_Name );


    /*
     Pad right charactors before querying numbers.
     */
    xProgress := 'GPOAOB-10-0010';
    ec_debug.pl ( 3, 'p_BOL_No_From: ', p_BOL_No_From);
    /*  Get doc numbering info to properlly format doc numbers entered */
    SELECT
      assignment_type,
      format_size,
      nvl(pad_char,' ')
    INTO
      v_assignment_type,
      v_format_size,
      v_pad_char
    FROM
      sy_docs_seq
    WHERE
      orgn_code=v_Orgn_Code AND
      doc_type='OPSP'
    ;

    ec_debug.pl ( 3, 'v_assignment_type: ',v_assignment_type);
    If ( v_assignment_type = 2 ) Then /*  If automatic document numbering */
      If ( p_BOL_No_From is NOT NULL ) Then
        v_BOL_No_From := lpad(p_BOL_No_From, v_format_size, v_pad_char);
        ec_debug.pl ( 3, 'v_BOL_No_From : ', v_BOL_No_From);
        SELECT
           lpad(p_BOL_No_From, v_format_size, v_pad_char)
        INTO
           v_BOL_No_From
        FROM
           dual
        ;
      End If;
      If ( p_BOL_No_To is NOT NULL ) Then
        v_BOL_No_To := lpad(p_BOL_No_To, v_format_size, v_pad_char);
        ec_debug.pl ( 3, 'v_BOL_No_To : ',v_BOL_No_To );
        SELECT
           lpad(p_BOL_No_To, v_format_size, v_pad_char)
        INTO
           v_BOL_No_To
        FROM
           dual
        ;
      End If;
    End If;

    ec_debug.pl ( 3, 'v_BOL_No_From : ',v_BOL_No_From );
    ec_debug.pl ( 3, 'v_BOL_No_To : ',v_BOL_No_To );

    xProgress := 'GASNOB-10-1000';
    ece_flatfile_pvt.init_table(p_TransactionType,p_SHP_Interface,NULL,FALSE,v_SHP_Table,v_CrossRefTable);

    /* */
    /*  Initialize the Cross Reference PL/SQL table.  This table is a */
    /*  concatenation of all the interface PL/SQL tables. */
    /* */

    v_CrossRefTable := v_SHP_Table;
    xProgress := 'GASNOB-10-1020';
    v_CrossRefCount := v_SHP_Table.COUNT;
    ec_debug.pl ( 3, 'v_CrossRefCount: ', v_CrossRefCount );

    xProgress := 'GASNOB-10-1030';
    ece_flatfile_pvt.init_table(p_TransactionType,p_STX_Interface,NULL,TRUE,v_STX_Table,v_CrossRefTable);

    xProgress := 'GASNOB-10-1070';
    ece_flatfile_pvt.init_table(p_TransactionType,p_ORD_Interface,NULL,TRUE,v_ORD_Table,v_CrossRefTable);

    xProgress := 'GASNOB-10-1100';
    ece_flatfile_pvt.init_table(p_TransactionType,p_OAC_Interface,NULL,TRUE,v_OAC_Table,v_CrossRefTable);

    xProgress := 'GASNOB-10-1130';
    ece_flatfile_pvt.init_table(p_TransactionType,p_OTX_Interface,NULL,TRUE,v_OTX_Table,v_CrossRefTable);

    xProgress := 'GASNOB-10-1160';
    ece_flatfile_pvt.init_table(p_TransactionType,p_DTL_Interface,NULL,TRUE,v_DTL_Table,v_CrossRefTable);


    xProgress := 'GASNOB-10-1190';
    ece_flatfile_pvt.init_table(p_TransactionType,p_DAC_Interface,NULL,TRUE,v_DAC_Table,v_CrossRefTable);

    xProgress := 'GASNOB-10-1211';
    ece_flatfile_pvt.init_table(p_TransactionType,p_DTX_Interface,NULL,TRUE,v_DTX_Table,v_CrossRefTable);

    xProgress := 'GASNOB-10-1213';
    ece_flatfile_pvt.init_table(p_TransactionType,p_ALL_Interface,NULL,TRUE,v_ALL_Table,v_CrossRefTable);


    /* */
    /*  The 'select_clause' procedure will build the SELECT, FROM and WHERE */
    /*  clauses in preparation for the dynamic SQL call using the EDI data */
    /*  dictionary for the build.  Any necessary customizations to these */
    /*  clauses need to be made *after* the clause is built, but *before* */
    /*  the SQL call. */
    /* */

    xProgress := 'GASNOB-10-1220';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_SHP_Interface,
                                          v_SHP_Table,
                                          v_SHP_Select,
                                          v_SHP_From,
                                          v_SHP_Where );

    xProgress := 'GASNOB-10-1230';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_STX_Interface,
                                          v_STX_Table,
                                          v_STX_Select,
                                          v_STX_From,
                                          v_STX_Where );

    xProgress := 'GASNOB-10-1240';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_ORD_Interface,
                                          v_ORD_Table,
                                          v_ORD_Select,
                                          v_ORD_From,
                                          v_ORD_Where );

    xProgress := 'GASNOB-10-1250';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_OAC_Interface,
                                          v_OAC_Table,
                                          v_OAC_Select,
                                          v_OAC_From,
                                          v_OAC_Where );

    xProgress := 'GASNOB-10-1260';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_OTX_Interface,
                                          v_OTX_Table,
                                          v_OTX_Select,
                                          v_OTX_From,
                                          v_OTX_Where );

   xProgress := 'GASNOB-10-1270';
   ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_DTL_Interface,
                                          v_DTL_Table,
                                          v_DTL_Select,
                                          v_DTL_From,
                                          v_DTL_Where );

    xProgress := 'GASNOB-10-1280';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_DAC_Interface,
                                          v_DAC_Table,
                                          v_DAC_Select,
                                          v_DAC_From,
                                          v_DAC_Where );

    xProgress := 'GASNOB-10-1281';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          P_DTX_Interface,
                                          v_DTX_Table,
                                          v_DTX_Select,
                                          v_DTX_From,
                                          v_DTX_Where );
    xProgress := 'GASNOB-10-1281';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_ALL_Interface,
                                          v_ALL_Table,
                                          v_ALL_Select,
                                          v_ALL_From,
                                          v_ALL_Where );

    /* */
    /*  Customize the WHERE clauses to use the elegible Deliveries for */
    /*  this Departure. */
    /* */

    xProgress := 'GASNOB-10-1290';
    v_SHP_Where := v_SHP_Where || p_SHP_Interface || '_V.Orgn_Code = :Orgn_Code';

    If v_BOL_No_From is not NULL Then
      If v_BOL_No_To is not NULL Then
        /* Specify range in where clause */
        v_SHP_Where := v_SHP_Where || ' AND ' ||
          p_SHP_Interface || '_V.BOL_NO >= :BOL_No_From' || ' AND ' ||
          p_SHP_Interface || '_V.BOL_NO <= :BOL_No_To';
      Else
        /* Specify match */
        v_SHP_Where := v_SHP_Where || ' AND ' ||
          p_SHP_Interface || '_V.BOL_NO = :BOL_No_From';
      End If;
    End If;

    If v_Creation_Date_From is not NULL Then
      If v_Creation_Date_To is not NULL Then
        /* Specify range in where clause */
        v_SHP_Where := v_SHP_Where || ' AND ' ||
          p_SHP_Interface || '_V.CREATION_DATE >= :Creation_Date_From' || ' AND ' ||
        'trunc(' || p_SHP_Interface || '_V.CREATION_DATE) <= :Creation_Date_To';
      Else
        /* Specify match */
        v_SHP_Where := v_SHP_Where || ' AND ' ||
        'trunc(' || p_SHP_Interface || '_V.CREATION_DATE) = :Creation_Date_From';
      End If;
    End If;

    If v_Customer_Name is not NULL Then
      /* Specify match */
      v_SHP_Where := v_SHP_Where || ' AND ' ||
          p_SHP_Interface || '_V.SHIPTO_CUST_NAME = :Customer_Name';
    End If;

    xProgress := 'GASNOB-10-1300';
    v_STX_Where := v_STX_Where ||
          p_STX_Interface || '_V.BOL_ID = :BOL_ID' || ' AND ' ||
          p_STX_Interface || '_V.Line_No > 0';

    xProgress := 'GASNOB-10-1310';
    v_ORD_Where := v_ORD_Where ||
          p_ORD_Interface || '_V.Order_ID   IN '  ||
                             '( SELECT DISTINCT  Order_ID '           ||
                             '  FROM '  || p_DTL_Interface || '_V '   ||
                             '  WHERE ' || p_DTL_Interface || '_V.BOL_ID = :BOL_ID ) ';

    xProgress := 'GASNOB-10-1320';
    v_OAC_Where := v_OAC_Where ||
          p_OAC_Interface || '_V.Order_ID = :Order_ID';

    xProgress := 'GASNOB-10-1330';
    v_OTX_Where := v_OTX_Where ||
          p_OTX_Interface || '_V.ORDER_ID = :Order_Id' || ' AND ' ||
          p_OTX_Interface || '_V.LINE_NO > 0';

    xProgress := 'GASNOB-10-1340';
    v_DTL_Where := v_DTL_Where ||
          p_DTL_Interface || '_V.BOL_ID   = :BOL_ID'   || ' AND ' ||
          p_DTL_Interface || '_V.ORDER_ID = :Order_Id';

    xProgress := 'GASNOB-10-1350';
    v_DAC_Where := v_DAC_Where ||
          p_DAC_Interface || '_V.Line_ID = :Line_ID';

    xProgress := 'GASNOB-10-1351';
    v_DTX_Where := v_DTX_Where ||
          p_DTX_Interface || '_V.Line_ID = :Line_ID' || ' AND ' ||
          p_DTX_Interface || '_V.LINE_NO > 0';

    xProgress := 'GASNOB-10-1352';
    v_ALL_Where := v_ALL_Where ||
          p_ALL_Interface || '_V.Line_ID = :Line_ID';

    /* */
    /*  Build the complete SELECT statement for each level. */
    /* */

    xProgress := 'GASNOB-10-1360';
    v_SHP_Select        := v_SHP_Select       ||
                               v_SHP_From         ||
                               v_SHP_Where;
    ec_debug.pl ( 3, 'v_SHP_Select: ', v_SHP_Select );

    v_STX_Select        := v_STX_Select ||
                               v_STX_From   ||
                               v_STX_Where;
    ec_debug.pl ( 3, 'v_STX_Select: ', v_STX_Select );

    v_ORD_Select        := v_ORD_Select       ||
                               v_ORD_From         ||
                               v_ORD_Where;
    ec_debug.pl ( 3, 'v_ORD_Select: ', v_ORD_Select );

    v_OAC_Select        := v_OAC_Select      ||
                               v_OAC_From        ||
                               v_OAC_Where;
    ec_debug.pl ( 3, 'v_OAC_Select: ', v_OAC_Select );

    v_OTX_Select        := v_OTX_Select          ||
                               v_OTX_From            ||
                               v_OTX_Where;
    ec_debug.pl ( 3, 'v_OTX_Select: ', v_OTX_Select );

    v_DTL_Select        := v_DTL_Select           ||
                               v_DTL_From             ||
                               v_DTL_Where;
    ec_debug.pl ( 3, 'v_DTL_Select: ', v_DTL_Select );

    v_DAC_Select        := v_DAC_Select     ||
                               v_DAC_From       ||
                               v_DAC_Where;
    ec_debug.pl ( 3, 'v_DAC_Select: ', v_DAC_Select );

    v_DTX_Select        := v_DTX_Select     ||
                               v_DTX_From       ||
                               v_DTX_Where;
    ec_debug.pl ( 3, 'v_DTX_Select: ', v_DTX_Select );

    v_ALL_Select        := v_ALL_Select     ||
                               v_ALL_From       ||
                               v_ALL_Where;
    /* */
    /*  Open a cursor for each of the SELECT calls.  This tells the */
    /*  database to reserve space for the data returned by the SELECT */
    /*  statement. */
    /* */

    xProgress := 'GASNOB-10-1370';
    v_SHP_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1372';
    v_STX_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1374';
    v_ORD_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1376';
    v_OAC_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1378';
    v_OTX_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1380';
    v_DTL_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1382';
    v_DAC_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1384';
    v_DTX_Cursor := dbms_sql.open_cursor;

    xProgress := 'GASNOB-10-1386';
    v_ALL_Cursor := dbms_sql.open_cursor;

    /* */
    /*  Parse each SELECT statement so the database understands the */
    /*  command. */
    /* */

    xProgress := 'GASNOB-10-1390';
    BEGIN
      dbms_sql.parse ( v_SHP_Cursor,
                       v_SHP_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_SHP_Select );
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-10-1400';
    BEGIN
      dbms_sql.parse ( v_STX_Cursor,
                       v_STX_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_STX_Select );
        app_exception.raise_exception;
    END;

    /* dbms_output.put_line( ' Length of ORD Select = ' || length( v_ORD_Select)); */

    xProgress := 'GASNOB-10-1410';
    BEGIN
      dbms_sql.parse ( v_ORD_Cursor,
                       v_ORD_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_ORD_Select );
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-10-1420';
    BEGIN
      dbms_sql.parse ( v_OAC_Cursor,
                       v_OAC_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OAC_Select );
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-10-1430';
    BEGIN
      dbms_sql.parse ( v_OTX_Cursor,
                       v_OTX_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OTX_Select );
        app_exception.raise_exception;
    END;

/*
    dbms_output.put_line( ' Length of DTL Select = ' || length( v_DTL_Select));

    dbms_output.put_line( substr( v_DTL_Select,1,100));
    dbms_output.put_line( substr( v_DTL_Select,101,100));
    dbms_output.put_line( substr( v_DTL_Select,201,100));
    dbms_output.put_line( substr( v_DTL_Select,301,100));
    dbms_output.put_line( substr( v_DTL_Select,401,100));
    dbms_output.put_line( substr( v_DTL_Select,501,100));
    dbms_output.put_line( substr( v_DTL_Select,601,100));
    dbms_output.put_line( substr( v_DTL_Select,701,100));
    dbms_output.put_line( substr( v_DTL_Select,801,100));
    dbms_output.put_line( substr( v_DTL_Select,901,100));
    dbms_output.put_line( substr( v_DTL_Select,1001,100));
    dbms_output.put_line( substr( v_DTL_Select,1101,100));
    dbms_output.put_line( substr( v_DTL_Select,1201,100));
    dbms_output.put_line( substr( v_DTL_Select,1301,100));
    dbms_output.put_line( substr( v_DTL_Select,1401,100));
    dbms_output.put_line( substr( v_DTL_Select,1501,100));
    dbms_output.put_line( substr( v_DTL_Select,1601,100));
    dbms_output.put_line( substr( v_DTL_Select,1701,100));
    dbms_output.put_line( substr( v_DTL_Select,1801,100));
    dbms_output.put_line( substr( v_DTL_Select,1901,100));
    dbms_output.put_line( substr( v_DTL_Select,2001,100));
    dbms_output.put_line( substr( v_DTL_Select,2101,100));
    dbms_output.put_line( substr( v_DTL_Select,2201,100));
    dbms_output.put_line( substr( v_DTL_Select,2301,100));
    dbms_output.put_line( substr( v_DTL_Select,2401,100));
    dbms_output.put_line( substr( v_DTL_Select,2501,100));
    dbms_output.put_line( substr( v_DTL_Select,2601,100));
    dbms_output.put_line( substr( v_DTL_Select,2701,100));
    dbms_output.put_line( substr( v_DTL_Select,2801,100));
    dbms_output.put_line( substr( v_DTL_Select,2901,100));
    dbms_output.put_line( substr( v_DTL_Select,3001,100));
*/

    xProgress := 'GASNOB-10-1440';
    BEGIN
      dbms_sql.parse ( v_DTL_Cursor,
                       v_DTL_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTL_Select );
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-10-1450';
    BEGIN
      dbms_sql.parse ( v_DAC_Cursor,
                       v_DAC_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DAC_Select );
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-10-1451';
    BEGIN
      dbms_sql.parse ( v_DTX_Cursor,
                       v_DTX_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTX_Select );
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-10-1452';
    BEGIN
      dbms_sql.parse ( v_ALL_Cursor,
                       v_ALL_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_ALL_Select );
        app_exception.raise_exception;
    END;

    /* set counters */
    xProgress := 'GASNOB-10-1453';
    v_SHP_Count := v_SHP_table.COUNT;
    ec_debug.pl (3, 'v_SHP_Count: ', v_SHP_Count);

    xProgress := 'GASNOB-10-1454';
    v_STX_Count := v_STX_table.COUNT;
    ec_debug.pl (3, 'v_STX_Count: ', v_STX_Count);

    xProgress := 'GASNOB-10-1455';
    v_ORD_Count := v_ORD_table.COUNT;
    ec_debug.pl (3, 'v_ORD_Count: ', v_ORD_Count);

    xProgress := 'GASNOB-10-1456';
    v_OAC_Count := v_OAC_table.COUNT;
    ec_debug.pl (3, 'v_OAC_Count: ', v_OAC_Count);

    xProgress := 'GASNOB-10-1457';
    v_OTX_Count := v_OTX_table.COUNT;
    ec_debug.pl (3, 'v_OTX_Count: ', v_OTX_Count);

    xProgress := 'GASNOB-10-1458';
    v_DTL_Count := v_DTL_table.COUNT;
    ec_debug.pl (3, 'v_DTL_Count: ', v_DTL_Count);

    xProgress := 'GASNOB-10-1459';
    v_DAC_Count := v_DAC_table.COUNT;
    ec_debug.pl (3, 'v_DAC_Count: ', v_DAC_Count);

    xProgress := 'GASNOB-10-1460';
    v_DTX_Count := v_DTX_table.COUNT;
    ec_debug.pl (3, 'v_DTX_Count: ', v_DTX_Count);

    xProgress := 'GASNOB-10-1461';
    v_ALL_Count := v_ALL_table.COUNT;
    ec_debug.pl (3, 'v_ALL_Count: ', v_ALL_Count);

    /* */
    /*  Define the data type for every column in each SELECT statement */
    /*  so the database understands how to populate it.  Using the */
    /*  K.I.S.S. principle, every data type will be converted to */
    /*  VARCHAR2. */
    /* */

    xProgress := 'GASNOB-10-1466';
    FOR v_LoopCount IN 1..v_SHP_Count
    LOOP
      xProgress := 'GASNOB-10-1470';
      dbms_sql.define_column ( v_SHP_Cursor,
                               v_LoopCount,
                               v_SHP_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1480';
    FOR v_LoopCount IN 1..v_STX_Count
    LOOP
      xProgress := 'GASNOB-10-1490';
      dbms_sql.define_column ( v_STX_Cursor,
                               v_LoopCount,
                               v_STX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1500';
    FOR v_LoopCount IN 1..v_ORD_Count
    LOOP
      xProgress := 'GASNOB-10-1510';
      dbms_sql.define_column ( v_ORD_Cursor,
                               v_LoopCount,
                               v_ORD_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1520';
    FOR v_LoopCount IN 1..v_OAC_Count
    LOOP
      xProgress := 'GASNOB-10-1530';
      dbms_sql.define_column ( v_OAC_Cursor,
                               v_LoopCount,
                               v_OAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1540';
    FOR v_LoopCount IN 1..v_OTX_Count
    LOOP
      xProgress := 'GASNOB-10-1550';
      dbms_sql.define_column ( v_OTX_Cursor,
                               v_LoopCount,
                               v_OTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1560';
    FOR v_LoopCount IN 1..v_DTL_Count
    LOOP
      xProgress := 'GASNOB-10-1570';
      dbms_sql.define_column ( v_DTL_Cursor,
                               v_LoopCount,
                               v_DTL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1580';
    FOR v_LoopCount IN 1..v_DAC_Count
    LOOP
      xProgress := 'GASNOB-10-1590';
      dbms_sql.define_column ( v_DAC_Cursor,
                               v_LoopCount,
                               v_DAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1580';
    FOR v_LoopCount IN 1..v_DTX_Count
    LOOP
      xProgress := 'GASNOB-10-1590';
      dbms_sql.define_column ( v_DTX_Cursor,
                               v_LoopCount,
                               v_DTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GASNOB-10-1580';
    FOR v_LoopCount IN 1..v_ALL_Count
    LOOP
      xProgress := 'GASNOB-10-1590';
      dbms_sql.define_column ( v_ALL_Cursor,
                               v_LoopCount,
                               v_ALL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /* */
    /*  Bind the variables in the Delivery level SELECT clause. */
    /* */

    xProgress := 'GASNOB-10-1600';
    dbms_sql.bind_variable ( v_SHP_Cursor,
                             'Orgn_Code',
                             v_Orgn_Code );

    If v_BOL_No_From is not NULL Then
      xProgress := 'GASNOB-10-1601';
      dbms_sql.bind_variable ( v_SHP_Cursor,
                               'BOL_No_From',
                               v_BOL_No_From );
      If v_BOL_No_To is not NULL Then
        xProgress := 'GASNOB-10-1602';
        dbms_sql.bind_variable ( v_SHP_Cursor,
                                 'BOL_No_To',
                                 v_BOL_No_To );
      End If;
    End If;

    If v_Creation_Date_From is not NULL Then
      xProgress := 'GASNOB-10-1603';
      dbms_sql.bind_variable ( v_SHP_Cursor,
                               'Creation_Date_From',
                               v_Creation_Date_From );
      If v_Creation_Date_To is not NULL Then
        xProgress := 'GASNOB-10-1604';
        dbms_sql.bind_variable ( v_SHP_Cursor,
                                 'Creation_Date_To',
                                 v_Creation_Date_To );
      End If;
    End If;

    If v_Customer_Name is not NULL Then
      xProgress := 'GASNOB-10-1705';
      dbms_sql.bind_variable ( v_SHP_Cursor,
                               'Customer_Name',
                               v_Customer_Name );
    End If;

    /* */
    /*  Execute the SHP level SELECT statement. */
    /* */

    xProgress := 'GASNOB-10-1610';
    v_Dummy := dbms_sql.execute ( v_SHP_Cursor );

    /* */
    /*  Begin the SHP level loop. */
    /* */

    xProgress := 'GASNOB-10-1620';
    WHILE dbms_sql.fetch_rows ( v_SHP_Cursor ) > 0
    LOOP

      /* */
      /*  Store the returned values in the PL/SQL table. */
      /* */

      xProgress := 'GASNOB-10-1630';
      FOR v_LoopCount IN 1..v_SHP_Count
      LOOP
        xProgress := 'GASNOB-10-1640';
        dbms_sql.column_value ( v_SHP_Cursor,
                                v_LoopCount,
                                v_SHP_Table(v_LoopCount).value );
      END LOOP;

      /* */
      /*  Find the column position of the BOL_ID in the PL/SQL table */
      /*  and use the value stored in that column to bind the variables in */
      /*  the SELECT clauses of the other levels. */
      /* */

      xProgress := 'GASNOB-10-1650';
      ece_extract_utils_pub.find_pos ( v_SHP_Table,
                                       'BOL_ID',
                                       V_BOL_ID_Position );
      /* */
      /*  Everything is stored in the PL/SQL table as VARCHAR2, so convert */
      /*  the BOL_ID value to NUMBER. */
      /* */

      xProgress := 'GASNOB-10-1660';
      v_BOL_ID := TO_NUMBER ( v_SHP_Table(v_BOL_ID_Position).value );
      ec_debug.pl ( 3, 'v_BOL_ID: ', v_BOL_ID );

      /* */
      /*  Cross-reference all necessary columns in the PL/SQL table. */
      /* */

      xProgress := 'GASNOB-10-1800';
      ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                              p_Return_Status      => v_ReturnStatus,
                                                              p_Msg_Count          => v_MessageCount,
                                                              p_Msg_Data           => v_MessageData,
                                                              p_Key_Tbl            => v_CrossRefTable,
                                                              p_Tbl                => v_SHP_Table );

      /* */
      /*  Retrieve the next sequence number for the primary key value, and */
      /*  insert this record into the Ship interface table. */
      /* */

      xProgress := 'GASNOB-10-1810';
      BEGIN
        SELECT GML_GASNO_SHIPMENTS_S.nextval
        INTO   v_SHP_Key
        FROM   sys.dual;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 0,
                        'EC',
                        'ECE_GET_NEXT_SEQ_FAILED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'SEQ',
                        'GML_GASNO_SHIPMENTS_S' );
      END;
      ec_debug.pl ( 3, 'v_SHP_Key: ', v_SHP_Key );

      xProgress := 'GASNOB-10-1820';
      ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                        p_TransactionType,
                                                        p_CommunicationMethod,
                                                        p_SHP_Interface,
                                                        v_SHP_Table,
                                                        v_SHP_Key );

      /* */
      /*  Call the (customizable) procedure to populate the corresponding */
      /*  extension table. */
      /* */

      xProgress := 'GASNOB-10-1830';
      GML_GASNO_X.populate_SHP_ext ( v_SHP_Key, v_SHP_Table );

      /* */
      /*  Execute the Ship Text level SELECT statement. */
      /* */

      xProgress := 'GASNOB-10-1670';
      dbms_sql.bind_variable ( v_STX_Cursor,
                               'BOL_ID',
                               v_BOL_ID );

      xProgress := 'GASNOB-10-1840';
      v_Dummy := dbms_sql.execute ( v_STX_Cursor );

      /* */
      /*  Begin the STX level loop. */
      /* */

      xProgress := 'GASNOB-10-1850';
      WHILE dbms_sql.fetch_rows ( v_STX_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-1860';
        FOR v_LoopCount IN 1..v_STX_Count
        LOOP
          xProgress := 'GASNOB-10-1870';
          dbms_sql.column_value ( v_STX_Cursor,
                                  v_LoopCount,
                                  v_STX_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-1880';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_STX_Table );

        /* */
        /*  Since this interface table is a logical extension of the Ship */
        /*  level table, use the same key value to insert this record into */
        /*  the Ship Text table. */
        /* */

        v_STX_Key := v_SHP_Key;
        ec_debug.pl ( 3, 'v_STX_Key: ', v_STX_Key );

        xProgress := 'GASNOB-10-1890';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_STX_Interface,
                                                          v_STX_Table,
                                                          v_STX_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-1891';
        GML_GASNO_X.populate_STX_ext ( v_STX_Key, v_STX_Table );

      END LOOP;  /* while stx */

      xProgress := 'GASNOB-10-1690';
      dbms_sql.bind_variable ( v_ORD_Cursor,
                               'BOL_ID',
                               v_BOL_ID );

      /* */
      /*  Execute the Order level SELECT statement. */
      /* */

      xProgress := 'GASNOB-10-1900';
      v_Dummy := dbms_sql.execute ( v_ORD_Cursor );

      /* */
      /*  Begin the Order level loop. */
      /* */

      xProgress := 'GASNOB-10-1910';
      WHILE dbms_sql.fetch_rows ( v_ORD_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-1920';
        FOR v_LoopCount IN 1..v_ORD_Count
        LOOP
          xProgress := 'GASNOB-10-1930';
          dbms_sql.column_value ( v_ORD_Cursor,
                                  v_LoopCount,
                                  v_ORD_Table(v_LoopCount).value );
        END LOOP;

        /*   */
        /*  Find the column position of the Order_ID in the PL/SQL table */
        /*  and use the value stored in that column to bind the variables in */
        /*  the SELECT clauses of the other levels.  */
        /* */

        xProgress := 'GASNOB-10-1935';
        ece_extract_utils_pub.find_pos ( v_ORD_Table,
                                         'Order_ID',
                                         V_Order_ID_Position );

        v_Order_ID := TO_NUMBER(v_ORD_Table(v_Order_ID_Position).value);
        ec_debug.pl ( 3, 'v_Order_ID: ', v_Order_ID );

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-1940';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_ORD_Table );

        /* */
        /*  Retrieve the next sequence number for the primary key value, and */
        /*  insert this record into the Order interface table. */
        /* */

        xProgress := 'GASNOB-10-1950';
        BEGIN
          SELECT GML_GASNO_ORDERS_S.nextval
          INTO   v_ORD_Key
          FROM   sys.dual;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 0,
                        'EC',
                        'ECE_GET_NEXT_SEQ_FAILED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'SEQ',
                        'GML_GASNO_ORDERS_S' );
        END;
        ec_debug.pl ( 3, 'v_ORD_Key: ', v_ORD_Key );

        xProgress := 'GASNOB-10-1960';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_ORD_Interface,
                                                          v_ORD_Table,
                                                          v_ORD_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-1970';
        GML_GASNO_X.populate_ORD_ext ( v_ORD_Key, v_ORD_Table );

      /* */
      /*  Execute the Charge/Allowance level SELECT statement. */
      /* */
      xProgress := 'GASNOB-10-1710';
      dbms_sql.bind_variable ( v_OAC_Cursor,
                               'Order_ID',
                               v_Order_ID );

      xProgress := 'GASNOB-10-1980';
      v_Dummy := dbms_sql.execute ( v_OAC_Cursor );

      /* */
      /*  Begin the Order DAC level loop. */
      /* */

      xProgress := 'GASNOB-10-1990';
      WHILE dbms_sql.fetch_rows ( v_OAC_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2000';
        FOR v_LoopCount IN 1..v_OAC_Count
        LOOP
          xProgress := 'GASNOB-10-2010';
          dbms_sql.column_value ( v_OAC_Cursor,
                                  v_LoopCount,
                                  v_OAC_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2020';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_OAC_Table );

        /* */
        /*  Use the same key value for Order DAC as for the Order table */
        /* */

        v_OAC_Key := v_ORD_Key;
        ec_debug.pl ( 3, 'v_OAC_Key: ', v_OAC_Key );

        xProgress := 'GASNOB-10-2040';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_OAC_Interface,
                                                          v_OAC_Table,
                                                          v_OAC_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-2050';
        GML_GASNO_X.populate_OAC_ext ( v_OAC_Key, v_OAC_Table );

      END LOOP;  /* while oac */

      xProgress := 'GASNOB-10-1730';
      dbms_sql.bind_variable ( v_OTX_Cursor,
                               'Order_ID',
                               v_Order_ID );

      xProgress := 'GASNOB-10-2060';
      v_Dummy := dbms_sql.execute ( v_OTX_Cursor );

      /* */
      /*  Begin the Order level loop. */
      /* */

      xProgress := 'GASNOB-10-2070';
      WHILE dbms_sql.fetch_rows ( v_OTX_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2080';
        FOR v_LoopCount IN 1..v_OTX_Count
        LOOP
          xProgress := 'GASNOB-10-2090';
          dbms_sql.column_value ( v_OTX_Cursor,
                                  v_LoopCount,
                                  v_OTX_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2100';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_OTX_Table );

        /* */
        /*  Use the same key value for Order Text as for the Order table */
        /* */

        v_OTX_Key := v_ORD_Key;
        ec_debug.pl ( 3, 'v_OTX_Key: ', v_OTX_Key );

        xProgress := 'GASNOB-10-2120';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_OTX_Interface,
                                                          v_OTX_Table,
                                                          v_OTX_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-2130';
        GML_GASNO_X.populate_OTX_ext ( v_OTX_Key, v_OTX_Table );

      END LOOP;  /* while otx */


      xProgress := 'GASNOB-10-1740';
      dbms_sql.bind_variable ( v_DTL_Cursor,
                               'BOL_ID',
                               v_BOL_ID );

      xProgress := 'GASNOB-10-1750';
      dbms_sql.bind_variable ( v_DTL_Cursor,
                               'Order_ID',
                               v_Order_ID );

      /* */
      /*  Execute the Detail level SELECT statement. */
      /* */

      xProgress := 'GASNOB-10-2140';
      v_Dummy := dbms_sql.execute ( v_DTL_Cursor );

      /* */
      /*  Begin the Item level loop. */
      /* */

      xProgress := 'GASNOB-10-2150';
      WHILE dbms_sql.fetch_rows ( v_DTL_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2160';
        FOR v_LoopCount IN 1..v_DTL_Count
        LOOP
          xProgress := 'GASNOB-10-2170';
          dbms_sql.column_value ( v_DTL_Cursor,
                                  v_LoopCount,
                                  v_DTL_Table(v_LoopCount).value );
        END LOOP;

        xProgress := 'GASNOB-10-2175';
        ece_extract_utils_pub.find_pos ( v_DTL_Table,
                                         'Line_ID',
                                         V_Line_ID_Position );

        v_Line_ID := TO_NUMBER(v_DTL_Table(v_Line_ID_Position).value);
        ec_debug.pl ( 3, 'v_Line_ID: ', v_Line_ID );

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2180';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_DTL_Table );

        /* */
        /*  Retrieve the next sequence number for the primary key value, and */
        /*  insert this record into the Detail interface table. */
        /* */

        xProgress := 'GASNOB-10-2190';
        BEGIN
          SELECT GML_GASNO_DETAILS_S.nextval
          INTO   v_DTL_Key
          FROM   sys.dual;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 0,
                          'EC',
                          'ECE_GET_NEXT_SEQ_FAILED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'SEQ',
                          'GML_GASNO_DETAILS_S' );
        END;
        ec_debug.pl ( 3, 'v_DTL_Key: ', v_DTL_Key );

        xProgress := 'GASNOB-10-2200';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_DTL_Interface,
                                                          v_DTL_Table,
                                                          v_DTL_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-2210';
        GML_GASNO_X.populate_DTL_ext ( v_DTL_Key, v_DTL_Table );

      /* */
      /*  Execute the Detail Charge/Allowance level SELECT statement. */
      /* */

      xProgress := 'GASNOB-10-1760';
      dbms_sql.bind_variable ( v_DAC_Cursor,
                               'Line_ID',
                               v_Line_ID );

      xProgress := 'GASNOB-10-2220';
      v_Dummy := dbms_sql.execute ( v_DAC_Cursor );

      /* */
      /*  Begin the Detail DAC level loop. */
      /* */

      xProgress := 'GASNOB-10-2230';
      WHILE dbms_sql.fetch_rows ( v_DAC_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2240';
        FOR v_LoopCount IN 1..v_DAC_Count
        LOOP
          xProgress := 'GASNOB-10-2250';
          dbms_sql.column_value ( v_DAC_Cursor,
                                  v_LoopCount,
                                  v_DAC_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2260';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_DAC_Table );


        /* */
        /*  Use the same key value for Detail DAC as for the Detail table */
        /* */

        v_DAC_Key := v_DTL_Key;
        ec_debug.pl ( 3, 'v_DAC_Key: ', v_DAC_Key );


        xProgress := 'GASNOB-10-2280';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_DAC_Interface,
                                                          v_DAC_Table,
                                                          v_DAC_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-2290';
        GML_GASNO_X.populate_DAC_ext ( v_DAC_Key, v_DAC_Table );

        END LOOP;  /* while Dac */

      /* */
      /*  Execute the Detail Text level SELECT statement. */
      /* */

      xProgress := 'GASNOB-10-2300';
      dbms_sql.bind_variable ( v_DTX_Cursor,
                               'Line_ID',
                               v_Line_ID );

      xProgress := 'GASNOB-10-2310';
      v_Dummy := dbms_sql.execute ( v_DTX_Cursor );

      /* */
      /*  Begin the Detail Text level loop. */
      /* */

      xProgress := 'GASNOB-10-2320';
      WHILE dbms_sql.fetch_rows ( v_DTX_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2330';
        FOR v_LoopCount IN 1..v_DTX_Count
        LOOP
          xProgress := 'GASNOB-10-2340';
          dbms_sql.column_value ( v_DTX_Cursor,
                                  v_LoopCount,
                                  v_DTX_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2350';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_DTX_Table );

        /* */
        /*  Use the same key value for Detail Text as for the Detail table */
        /* */

        v_DTX_Key := v_DTL_Key;
        ec_debug.pl ( 3, 'v_DTX_Key: ', v_DTX_Key );


        xProgress := 'GASNOB-10-2360';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_DTX_Interface,
                                                          v_DTX_Table,
                                                          v_DTX_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-2370';
        GML_GASNO_X.populate_DTX_ext ( v_DTX_Key, v_DTX_Table );

        END LOOP;  /* while dtx */

      /* */
      /*  Execute the Allocations level SELECT statement. */
      /* */

      xProgress := 'GASNOB-10-2380';
      dbms_sql.bind_variable ( v_ALL_Cursor,
                               'Line_ID',
                               v_Line_ID );

      xProgress := 'GASNOB-10-2390';
      v_Dummy := dbms_sql.execute ( v_ALL_Cursor );

      /* */
      /*  Begin the Allocations level loop. */
      /* */

      xProgress := 'GASNOB-10-2400';
      WHILE dbms_sql.fetch_rows ( v_ALL_Cursor ) > 0
      LOOP

        /* */
        /*  Store the returned values in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2410';
        FOR v_LoopCount IN 1..v_ALL_Count
        LOOP
          xProgress := 'GASNOB-10-2420';
          dbms_sql.column_value ( v_ALL_Cursor,
                                  v_LoopCount,
                                  v_ALL_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Cross-reference all necessary columns in the PL/SQL table. */
        /* */

        xProgress := 'GASNOB-10-2430';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_ALL_Table );


        /* */
        /*  Use the same key value for Allocations as for the Detail table */
        /* */

        v_ALL_Key := v_DTL_Key;
        ec_debug.pl ( 3, 'v_ALL_Key: ', v_ALL_Key );


        xProgress := 'GASNOB-10-2440';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_ALL_Interface,
                                                          v_ALL_Table,
                                                          v_ALL_Key );

        /* */
        /*  Call the (customizable) procedure to populate the corresponding */
        /*  extension table. */
        /* */

        xProgress := 'GASNOB-10-2450';
        GML_GASNO_X.populate_ALL_ext ( v_ALL_Key, v_ALL_Table );

        END LOOP;  /* while all */

      END LOOP;  /* while dtl */
      END LOOP;  /* while ord */
    END LOOP;  /* while shp */

    /* */
    /*  Commit the interface table inserts. */
    /* */


    xProgress := 'GASNOB-10-2300';
    COMMIT;

    /* */
    /*  Close all open cursors. */
    /* */

    xProgress := 'GASNOB-10-2310';
    dbms_sql.close_cursor ( v_SHP_Cursor );
    xProgress := 'GASNOB-10-2312';
    dbms_sql.close_cursor ( v_STX_Cursor );
    xProgress := 'GASNOB-10-2314';
    dbms_sql.close_cursor ( v_ORD_Cursor);
    xProgress := 'GASNOB-10-2316';
    dbms_sql.close_cursor ( v_OAC_Cursor );
    xProgress := 'GASNOB-10-2318';
    dbms_sql.close_cursor ( v_OTX_Cursor );
    xProgress := 'GASNOB-10-2320';
    dbms_sql.close_cursor ( v_DTL_Cursor );
    xProgress := 'GASNOB-10-2322';
    dbms_sql.close_cursor ( v_DAC_Cursor );
    xProgress := 'GASNOB-10-2323';
    dbms_sql.close_cursor ( v_DTX_Cursor );
    xProgress := 'GASNOB-10-2324';
    dbms_sql.close_cursor ( v_ALL_Cursor );

    ec_debug.pop ( 'GML_GASNO.Populate_Interface_Tables' );

  EXCEPTION
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

    app_exception.raise_exception;

  END Populate_Interface_Tables;



/*===========================================================================

  PROCEDURE NAME:      Put_Data_To_Output_Table

  PURPOSE:             This procedure extracts and sequences information from
                       the Gateway interface tables and inserts the sequenced
                       data into the Gateway output table.

===========================================================================*/

  PROCEDURE Put_Data_To_Output_Table ( p_CommunicationMethod     IN VARCHAR2,
                                       p_TransactionType         IN VARCHAR2,
                                       p_Orgn_Code               IN VARCHAR2,
                                       p_BOL_No_From             IN VARCHAR2,
                                       p_BOL_No_To               IN VARCHAR2,
                                       p_Creation_Date_From      IN VARCHAR2,
                                       p_Creation_Date_To        IN VARCHAR2,
                                       p_Customer_Name           IN VARCHAR2,
                                       p_RunID                   IN INTEGER,
                                       p_OutputWidth             IN INTEGER,
                                       p_SHP_Interface            IN VARCHAR2,
                                       p_STX_Interface            IN VARCHAR2,
                                       p_ORD_Interface            IN VARCHAR2,
                                       p_OAC_Interface            IN VARCHAR2,
                                       p_OTX_Interface            IN VARCHAR2,
                                       p_DTL_Interface            IN VARCHAR2,
                                       p_DAC_Interface            IN VARCHAR2,
                                       p_DTX_Interface            IN VARCHAR2,
                                       p_ALL_Interface            IN VARCHAR2 )

  IS

    /* */
    /*  Variable definitions.  'Interface_tbl_type' is a PL/SQL table */
    /*  typedef with the following structure: */
    /* */
    /*  table_name              VARCHAR2(50) */
    /*  column_name             VARCHAR2(50) */
    /*  record_num              NUMBER */
    /*  position                NUMBER */
    /*  data_type               VARCHAR2(50) */
    /*  data_length             NUMBER */
    /*  value                   VARCHAR2(400) */
    /*  layout_code             VARCHAR2(2) */
    /*  record_qualifier        VARCHAR2(3) */
    /* */

    xProgress		  VARCHAR2(30);

    v_SHP_Table             ece_flatfile_pvt.interface_tbl_type;
    v_STX_Table             ece_flatfile_pvt.interface_tbl_type;
    v_ORD_Table             ece_flatfile_pvt.interface_tbl_type;
    v_OAC_Table             ece_flatfile_pvt.interface_tbl_type;
    v_OTX_Table             ece_flatfile_pvt.interface_tbl_type;
    v_DTL_Table             ece_flatfile_pvt.interface_tbl_type;
    v_DAC_Table             ece_flatfile_pvt.interface_tbl_type;
    v_DTX_Table             ece_flatfile_pvt.interface_tbl_type;
    v_ALL_Table             ece_flatfile_pvt.interface_tbl_type;

    v_SHP_CommonKeyName      VARCHAR2(40);
    v_STX_CommonKeyName      VARCHAR2(40);
    v_ORD_CommonKeyName      VARCHAR2(40);
    v_OAC_CommonKeyName      VARCHAR2(40);
    v_OTX_CommonKeyName      VARCHAR2(40);
    v_DTL_CommonKeyName      VARCHAR2(40);
    v_DAC_CommonKeyName      VARCHAR2(40);
    v_DTX_CommonKeyName      VARCHAR2(40);
    v_ALL_CommonKeyName      VARCHAR2(40);

    v_KeyPad                      VARCHAR2(22) := RPAD(' ', 22);
    v_FileCommonKey               VARCHAR2(255);
    v_TranslatorCode              VARCHAR2(30);
    v_RecordCommonKey0            VARCHAR2(25);
    v_RecordCommonKey1            VARCHAR2(22);
    v_RecordCommonKey2            VARCHAR2(22);
    v_RecordCommonKey3            VARCHAR2(22);

    v_SHP_SelectCursor      NUMBER;
    v_STX_SelectCursor      NUMBER;
    v_ORD_SelectCursor      NUMBER;
    v_OAC_SelectCursor      NUMBER;
    v_OTX_SelectCursor      NUMBER;
    v_DTL_SelectCursor      NUMBER;
    v_DAC_SelectCursor      NUMBER;
    v_DTX_SelectCursor      NUMBER;
    v_ALL_SelectCursor      NUMBER;

    v_SHP_DeleteCursor      NUMBER;
    v_STX_DeleteCursor      NUMBER;
    v_ORD_DeleteCursor      NUMBER;
    v_OAC_DeleteCursor      NUMBER;
    v_OTX_DeleteCursor      NUMBER;
    v_DTL_DeleteCursor      NUMBER;
    v_DAC_DeleteCursor      NUMBER;
    v_DTX_DeleteCursor      NUMBER;
    v_ALL_DeleteCursor      NUMBER;

    v_SHP_XDeleteCursor     NUMBER;
    v_STX_XDeleteCursor     NUMBER;
    v_ORD_XDeleteCursor     NUMBER;
    v_OAC_XDeleteCursor     NUMBER;
    v_OTX_XDeleteCursor     NUMBER;
    v_DTL_XDeleteCursor     NUMBER;
    v_DAC_XDeleteCursor     NUMBER;
    v_DTX_XDeleteCursor     NUMBER;
    v_ALL_XDeleteCursor     NUMBER;

    v_SHP_Select            VARCHAR2(32000);
    v_STX_Select            VARCHAR2(32000);
    v_ORD_Select            VARCHAR2(32000);
    v_OAC_Select            VARCHAR2(32000);
    v_OTX_Select            VARCHAR2(32000);
    v_DTL_Select            VARCHAR2(32000);
    v_DAC_Select            VARCHAR2(32000);
    v_DTX_Select            VARCHAR2(32000);
    v_ALL_Select            VARCHAR2(32000);

    v_SHP_From              VARCHAR2(32000);
    v_STX_From              VARCHAR2(32000);
    v_ORD_From              VARCHAR2(32000);
    v_OAC_From              VARCHAR2(32000);
    v_OTX_From              VARCHAR2(32000);
    v_DTL_From              VARCHAR2(32000);
    v_DAC_From              VARCHAR2(32000);
    v_DTX_From              VARCHAR2(32000);
    v_ALL_From              VARCHAR2(32000);

    v_SHP_Where             VARCHAR2(32000);
    v_STX_Where             VARCHAR2(32000);
    v_ORD_Where             VARCHAR2(32000);
    v_OAC_Where             VARCHAR2(32000);
    v_OTX_Where             VARCHAR2(32000);
    v_DTL_Where             VARCHAR2(32000);
    v_DAC_Where             VARCHAR2(32000);
    v_DTX_Where             VARCHAR2(32000);
    v_ALL_Where             VARCHAR2(32000);

    v_SHP_Delete              VARCHAR2(32000);
    v_STX_Delete              VARCHAR2(32000);
    v_ORD_Delete              VARCHAR2(32000);
    v_OAC_Delete              VARCHAR2(32000);
    v_OTX_Delete              VARCHAR2(32000);
    v_DTL_Delete              VARCHAR2(32000);
    v_DAC_Delete              VARCHAR2(32000);
    v_DTX_Delete              VARCHAR2(32000);
    v_ALL_Delete              VARCHAR2(32000);

    v_SHP_XDelete              VARCHAR2(32000);
    v_STX_XDelete              VARCHAR2(32000);
    v_ORD_XDelete              VARCHAR2(32000);
    v_OAC_XDelete              VARCHAR2(32000);
    v_OTX_XDelete              VARCHAR2(32000);
    v_DTL_XDelete              VARCHAR2(32000);
    v_DAC_XDelete              VARCHAR2(32000);
    v_DTX_XDelete              VARCHAR2(32000);
    v_ALL_XDelete              VARCHAR2(32000);

    v_SHP_Count             INTEGER;
    v_STX_Count             INTEGER;
    v_ORD_Count             INTEGER;
    v_OAC_Count             INTEGER;
    v_OTX_Count             INTEGER;
    v_DTL_Count             INTEGER;
    v_DAC_Count             INTEGER;
    v_DTX_Count             INTEGER;
    v_ALL_Count             INTEGER;

    v_SHP_RowID            ROWID;
    v_STX_RowID            ROWID;
    v_ORD_RowID            ROWID;
    v_OAC_RowID            ROWID;
    v_OTX_RowID            ROWID;
    v_DTL_RowID            ROWID;
    v_DAC_RowID            ROWID;
    v_DTX_RowID            ROWID;
    v_ALL_RowID            ROWID;

    v_SHP_XRowID            ROWID;
    v_STX_XRowID            ROWID;
    v_ORD_XRowID            ROWID;
    v_OAC_XRowID            ROWID;
    v_OTX_XRowID            ROWID;
    v_DTL_XRowID            ROWID;
    v_DAC_XRowID            ROWID;
    v_DTX_XRowID            ROWID;
    v_ALL_XRowID            ROWID;

    v_SHP_XInterface       VARCHAR2(50);
    v_STX_XInterface       VARCHAR2(50);
    v_ORD_XInterface       VARCHAR2(50);
    v_OAC_XInterface       VARCHAR2(50);
    v_OTX_XInterface       VARCHAR2(50);
    v_DTL_XInterface       VARCHAR2(50);
    v_DAC_XInterface       VARCHAR2(50);
    v_DTX_XInterface       VARCHAR2(50);
    v_ALL_XInterface       VARCHAR2(50);

    v_Dummy                       INTEGER;
    v_TranslatorCodePosition      INTEGER;
    v_SHP_CKNamePosition          INTEGER;
    v_STX_CKNamePosition          INTEGER;
    v_ORD_CKNamePosition          INTEGER;
    v_OAC_CKNamePosition          INTEGER;
    v_OTX_CKNamePosition          INTEGER;
    v_DTL_CKNamePosition          INTEGER;
    v_DAC_CKNamePosition          INTEGER;
    v_DTX_CKNamePosition          INTEGER;
    v_ALL_CKNamePosition          INTEGER;
    V_BOL_ID_Position             INTEGER;
    v_TransactionRecordIDPosition INTEGER;
    v_OrderHeaderIDPosition       INTEGER;
    v_Line_ID_Position            INTEGER;
    v_PickingLineIDPosition       INTEGER;
    v_Order_ID                    INTEGER;
    v_Order_ID_Position           INTEGER;
    v_SequenceNumberPosition      INTEGER;

    v_RunID                       INTEGER;
    v_BOL_ID                      INTEGER;
    v_TransactionRecordID         INTEGER;
    v_OrderHeaderID               INTEGER;
    v_Line_ID                     INTEGER;
    v_PickingLineID               INTEGER;
    v_SequenceNumber              INTEGER;

  BEGIN

    /*

      Debug statements for the parameter values.

    */

    ec_debug.push ( 'GML_GASNO.Put_Data_To_Output_Table' );
    ec_debug.pl ( 3, 'p_CommunicationMethod: ', p_CommunicationMethod );
    ec_debug.pl ( 3, 'p_TransactionType: ', p_TransactionType );
    ec_debug.pl ( 3, 'p_Orgn_Code: ', p_Orgn_Code );
    ec_debug.pl ( 3, 'p_BOL_No_From: ', p_BOL_No_From );
    ec_debug.pl ( 3, 'p_BOL_No_To: ', p_BOL_No_To );
    ec_debug.pl ( 3, 'p_Creation_Date_From: ', p_Creation_Date_From );
    ec_debug.pl ( 3, 'p_Creation_Date_To: ', p_Creation_Date_To );
    ec_debug.pl ( 3, 'p_Customer_Name: ', p_Customer_Name );
    ec_debug.pl ( 3, 'p_RunID: ', p_RunID );
    ec_debug.pl ( 3, 'p_OutputWidth: ', p_OutputWidth );
    ec_debug.pl ( 3, 'p_SHP_Interface: ', p_SHP_Interface );
    ec_debug.pl ( 3, 'p_STX_Interface: ', p_STX_Interface );
    ec_debug.pl ( 3, 'p_ORD_Interface: ', p_ORD_Interface );
    ec_debug.pl ( 3, 'p_OAC_Interface: ', p_OAC_Interface );
    ec_debug.pl ( 3, 'p_OTX_Interface: ', p_OTX_Interface );
    ec_debug.pl ( 3, 'p_DTL_Interface: ', p_DTL_Interface );
    ec_debug.pl ( 3, 'p_DAC_Interface: ', p_DAC_Interface );
    ec_debug.pl ( 3, 'p_DTX_Interface: ', p_DTX_Interface );
    ec_debug.pl ( 3, 'p_ALL_Interface: ', p_ALL_Interface );

    /* */
    /*  The Model/Option solution is handled by only including shippable */
    /*  items in the transaction (via the view) -- no further processing */
    /*  is necessary. */
    /* */

    /* */
    /*  The 'select_clause' procedure will build the SELECT, FROM and WHERE */
    /*  clauses in preparation for the dynamic SQL call using the EDI data */
    /*  dictionary for the build.  Any necessary customizations to these */
    /*  the SQL call. */
    /* */

    v_RunID := p_RunID;
    xProgress := 'GASNOB-40-1000';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_SHP_Interface,
                                     v_SHP_XInterface,
                                     v_SHP_Table,
                                     v_SHP_CommonKeyName,
                                     v_SHP_Select,
                                     v_SHP_From,
                                     v_SHP_Where );

    xProgress := 'GASNOB-40-1010';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_STX_Interface,
                                     v_STX_XInterface,
                                     v_STX_Table,
                                     v_STX_CommonKeyName,
                                     v_STX_Select,
                                     v_STX_From,
                                     v_STX_Where );

    xProgress := 'GASNOB-40-1020';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_ORD_Interface,
                                     v_ORD_XInterface,
                                     v_ORD_Table,
                                     v_ORD_CommonKeyName,
                                     v_ORD_Select,
                                     v_ORD_From,
                                     v_ORD_Where );

    xProgress := 'GASNOB-40-1030';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_OAC_Interface,
                                     v_OAC_XInterface,
                                     v_OAC_Table,
                                     v_OAC_CommonKeyName,
                                     v_OAC_Select,
                                     v_OAC_From,
                                     v_OAC_Where );

    xProgress := 'GASNOB-40-1040';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_OTX_Interface,
                                     v_OTX_XInterface,
                                     v_OTX_Table,
                                     v_OTX_CommonKeyName,
                                     v_OTX_Select,
                                     v_OTX_From,
                                     v_OTX_Where );


    xProgress := 'GASNOB-40-1050';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_DTL_Interface,
                                     v_DTL_XInterface,
                                     v_DTL_Table,
                                     v_DTL_CommonKeyName,
                                     v_DTL_Select,
                                     v_DTL_From,
                                     v_DTL_Where );

    xProgress := 'GASNOB-40-1060';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_DAC_Interface,
                                     v_DAC_XInterface,
                                     v_DAC_Table,
                                     v_DAC_CommonKeyName,
                                     v_DAC_Select,
                                     v_DAC_From,
                                     v_DAC_Where );

    xProgress := 'GASNOB-40-1070';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_DTX_Interface,
                                     v_DTX_XInterface,
                                     v_DTX_Table,
                                     v_DTX_CommonKeyName,
                                     v_DTX_Select,
                                     v_DTX_From,
                                     v_DTX_Where );

    xProgress := 'GASNOB-40-1070';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_ALL_Interface,
                                     v_ALL_XInterface,
                                     v_ALL_Table,
                                     v_ALL_CommonKeyName,
                                     v_ALL_Select,
                                     v_ALL_From,
                                     v_ALL_Where );

    /* */
    /*  Customize the SELECT clauses to include the ROWID.  Records */
    /*  will be deleted from the interface tables using these values. */
    /*  Also add any columns that do not appear in the flatfile, but */
    /*  will be needed for internal processing (i.e. ID values). */
    /* */

    xProgress := 'GASNOB-40-1080';
    v_SHP_Select := v_SHP_Select                     ||
                        ', '                         ||
                        p_SHP_Interface              ||
                        '.ROWID, '                   ||
                        v_SHP_XInterface             ||
                        '.ROWID, '                   ||
                        p_SHP_Interface              ||
                        '.TRANSACTION_RECORD_ID';

    v_STX_Select := v_STX_Select                     ||
                              ', '                   ||
                              p_STX_Interface        ||
                              '.ROWID, '             ||
                              v_STX_XInterface       ||
                              '.ROWID, '             ||
                              p_STX_Interface        ||
                              '.TRANSACTION_RECORD_ID';

    v_ORD_Select := v_ORD_Select                    ||
                          ', '                      ||
                          p_ORD_Interface           ||
                          '.ROWID, '                ||
                          v_ORD_XInterface          ||
                          '.ROWID, '                ||
                          p_ORD_Interface           ||
                          '.TRANSACTION_RECORD_ID';

    v_OAC_Select := v_OAC_Select                    ||
                      ', '                          ||
                      p_OAC_Interface               ||
                      '.ROWID, '                    ||
                      v_OAC_XInterface              ||
                      '.ROWID, '                    ||
                      p_OAC_Interface               ||
                      '.TRANSACTION_RECORD_ID';

    v_OTX_Select := v_OTX_Select                    ||
                         ', '                       ||
                         p_OTX_Interface            ||
                         '.ROWID, '                 ||
                         v_OTX_XInterface           ||
                         '.ROWID, '                 ||
                         p_OTX_Interface            ||
                         '.TRANSACTION_RECORD_ID';

    v_DTL_Select := v_DTL_Select                         ||
                     ', '                                ||
                     p_DTL_Interface                     ||
                     '.ROWID, '                          ||
                     v_DTL_XInterface                    ||
                     '.ROWID, '                          ||
                     p_DTL_Interface                     ||
                     '.TRANSACTION_RECORD_ID';

    v_DAC_Select := v_DAC_Select                         ||
                    ', '                                 ||
                    p_DAC_Interface                      ||
                    '.ROWID, '                           ||
                    v_DAC_XInterface                     ||
                    '.ROWID, '                           ||
                    p_DAC_Interface                      ||
                    '.TRANSACTION_RECORD_ID';

    v_DTX_Select := v_DTX_Select                   ||
                       ', '                        ||
                       p_DTX_Interface             ||
                       '.ROWID, '                  ||
                       v_DTX_XInterface            ||
                       '.ROWID, '                  ||
                       p_DTX_Interface             ||
                       '.TRANSACTION_RECORD_ID';


    v_ALL_Select := v_ALL_Select                   ||
                       ', '                        ||
                       p_ALL_Interface             ||
                       '.ROWID, '                  ||
                       v_ALL_XInterface            ||
                       '.ROWID, '                  ||
                       p_ALL_Interface             ||
                       '.TRANSACTION_RECORD_ID';

    /* */
    /*  Customize the WHERE clauses to: */
    /* */

    xProgress := 'GASNOB-40-1090';

    xProgress := 'GASNOB-40-1091';
    v_SHP_Where := v_SHP_Where  ||  ' AND '  ||
      p_SHP_Interface || '.RUN_ID = :Run_ID' ||
      ' ORDER BY '                           ||
      p_SHP_Interface || '.BOL_NO';

    xProgress := 'GASNOB-40-1091';
    v_STX_Where := v_STX_Where  ||  ' AND '  ||
      p_STX_Interface || '.RUN_ID = :Run_ID' ||
      ' AND '         ||
      p_STX_Interface || '.BOL_ID = :BOL_ID' ||
      ' ORDER BY '    ||
      p_STX_Interface || '.PARA_CODE_INT, '  ||
      p_STX_Interface || '.SUB_PARACODE, '   ||
      p_STX_Interface || '.LINE_NO';

    xProgress := 'GASNOB-40-1092';
    v_ORD_Where := v_ORD_Where  ||  ' AND '  ||
      p_ORD_Interface || '.RUN_ID = :Run_ID' ||
      ' AND '         ||
      p_ORD_Interface || '.ORDER_ID  IN ' ||
                      '( SELECT DISTINCT  Order_ID '           ||
                      '  FROM '  || p_DTL_Interface ||
                      '  WHERE ' || p_DTL_Interface || '.BOL_ID = :BOL_ID) '||
      ' ORDER BY '    ||
      p_ORD_Interface || '.ORDER_NO';

    xProgress := 'GASNOB-40-1093';
    v_OAC_Where := v_OAC_Where  ||  ' AND '      ||
      p_OAC_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_OAC_Interface || '.ORDER_ID = :ORDER_ID' ||
      ' ORDER BY '    ||
      p_OAC_Interface || '.SAC_CODE_INT';

    xProgress := 'GASNOB-40-1094';
    v_OTX_Where := v_OTX_Where  ||  ' AND ' ||
      p_OTX_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_OTX_Interface || '.ORDER_ID = :ORDER_ID' ||
      ' ORDER BY '    ||
      p_OTX_Interface || '.PARA_CODE_INT, ' ||
      p_OTX_Interface || '.SUB_PARACODE, '  ||
      p_OTX_Interface || '.LINE_NO';

    xProgress := 'GASNOB-40-1095';
    v_DTL_Where := v_DTL_Where  ||  ' AND '      ||
      p_DTL_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_DTL_Interface || '.BOL_ID = :BOL_ID'     ||
      ' AND '         ||
      p_DTL_Interface || '.ORDER_ID = :ORDER_ID' ||
      ' ORDER BY '    ||
      p_DTL_Interface || '.SO_LINE_NO';

    xProgress := 'GASNOB-40-1096';
    v_DAC_Where := v_DAC_Where  ||  ' AND '      ||
      p_DAC_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_DAC_Interface || '.LINE_ID = :LINE_ID'   ||
      ' ORDER BY '    ||
      p_DAC_Interface || '.SAC_CODE_INT';

    xProgress := 'GASNOB-40-1097';
    v_DTX_Where := v_DTX_Where  ||  ' AND ' ||
      p_DTX_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_DTX_Interface || '.LINE_ID = :LINE_ID'   ||
      ' ORDER BY '    ||
      p_DTX_Interface || '.PARA_CODE_INT, ' ||
      p_DTX_Interface || '.SUB_PARACODE, '  ||
      p_DTX_Interface || '.LINE_NO';

    xProgress := 'GASNOB-40-1098';
    v_ALL_Where := v_ALL_Where  ||  ' AND ' ||
      p_ALL_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_ALL_Interface || '.LINE_ID = :LINE_ID';

    /* */
    /*  Build the complete SELECT statement for each level. */
    /* */

    xProgress := 'GASNOB-40-1100';
    v_SHP_Select := v_SHP_Select             ||
                        v_SHP_From               ||
                        v_SHP_Where              ||
                        ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_SHP_Select: ', v_SHP_Select );

    v_STX_Select := v_STX_Select ||
                              v_STX_From   ||
                              v_STX_Where  ||
                              ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_STX_Select: ', v_STX_Select );


    v_ORD_Select := v_ORD_Select         ||
                          v_ORD_From           ||
                          v_ORD_Where          ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_ORD_Select: ', v_ORD_Select );

    v_OAC_Select := v_OAC_Select                 ||
                      v_OAC_From                   ||
                      v_OAC_Where                  ||
                      ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_OAC_Select: ', v_OAC_Select );

    v_OTX_Select := v_OTX_Select           ||
                         v_OTX_From             ||
                         v_OTX_Where            ||
                         ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_OTX_Select: ', v_OTX_Select );

    v_DTL_Select := v_DTL_Select                   ||
                     v_DTL_From                     ||
                     v_DTL_Where                    ||
                     ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_DTL_Select: ', v_DTL_Select );

    v_DAC_Select := v_DAC_Select                     ||
                    v_DAC_From                       ||
                    v_DAC_Where                      ||
                    ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_DAC_Select: ', v_DAC_Select );

    v_DTX_Select := v_DTX_Select         ||
                          v_DTX_From           ||
                          v_DTX_Where          ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_DTX_Select: ', v_DTX_Select );

    v_ALL_Select := v_ALL_Select         ||
                          v_ALL_From           ||
                          v_ALL_Where          ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'v_ALL_Select: ', v_ALL_Select );

    /* */
    /*  Build the DELETE clauses for each interface and extension table. */
    /* */

    xProgress := 'GASNOB-40-1110';
    v_SHP_Delete :=  'DELETE FROM '                    ||
                         p_SHP_Interface               ||
                         ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_SHP_Delete: ', v_SHP_Delete );

    v_SHP_XDelete :=  'DELETE FROM '                   ||
                          v_SHP_XInterface             ||
                          ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_SHP_XDelete: ', v_SHP_XDelete );

    v_STX_Delete :=  'DELETE FROM '              ||
                               p_STX_Interface   ||
                               ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_STX_Delete: ', v_STX_Delete );

    v_STX_XDelete :=  'DELETE FROM '            ||
                                v_STX_XInterface ||
                                ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_STX_XDelete: ', v_STX_XDelete );

    v_ORD_Delete :=  'DELETE FROM '                  ||
                           p_ORD_Interface             ||
                           ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_ORD_Delete: ', v_ORD_Delete );

    v_ORD_XDelete :=  'DELETE FROM '                 ||
                            v_ORD_XInterface           ||
                            ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_ORD_XDelete: ', v_ORD_XDelete );

    v_OAC_Delete :=  'DELETE FROM '                      ||
                        p_OAC_Interface                ||
                        ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_OAC_Delete: ', v_OAC_Delete );

    v_OAC_XDelete :=  'DELETE FROM '                     ||
                         v_OAC_XInterface              ||
                         ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_OAC_XDelete: ', v_OAC_XDelete );

    v_OTX_Delete :=  'DELETE FROM '                       ||
                       p_OTX_Interface                    ||
                      ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_OTX_Delete: ', v_OTX_Delete );

    v_OTX_XDelete :=  'DELETE FROM '                      ||
                       v_OTX_XInterface                   ||
                       ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_OTX_XDelete: ', v_OTX_XDelete );

    v_DTL_Delete :=  'DELETE FROM '                        ||
                     p_DTL_Interface                       ||
                     ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_DTL_Delete: ', v_DTL_Delete );

    v_DTL_XDelete :=  'DELETE FROM '                       ||
                      v_DTL_XInterface                     ||
                      ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_DTL_XDelete: ', v_DTL_XDelete );

    v_DAC_Delete :=  'DELETE FROM '                  ||
                           p_DAC_Interface           ||
                           ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_DAC_Delete: ', v_DAC_Delete );

    v_DAC_XDelete :=  'DELETE FROM '                 ||
                            v_DAC_XInterface         ||
                            ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_DAC_XDelete: ', v_DAC_XDelete );

    v_DTX_Delete :=  'DELETE FROM '                  ||
                           p_DTX_Interface           ||
                           ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_DTX_Delete: ', v_DTX_Delete );

    v_DTX_XDelete :=  'DELETE FROM '                 ||
                            v_DTX_XInterface         ||
                            ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_DTX_XDelete: ', v_DTX_XDelete );

    v_ALL_Delete :=  'DELETE FROM '                  ||
                           p_ALL_Interface           ||
                           ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_ALL_Delete: ', v_ALL_Delete );

    v_ALL_XDelete :=  'DELETE FROM '                 ||
                            v_ALL_XInterface         ||
                            ' WHERE ROWID = :Row_ID';
    ec_debug.pl ( 3, 'v_ALL_XDelete: ', v_ALL_XDelete );

    /* */
    /*  Open a cursor for each SELECT and DELETE call.  This tells */
    /*  the database to reserve space for the data returned by the */
    /*  SELECT and DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1120';
    v_SHP_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1122';
    v_STX_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1124';
    v_ORD_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1126';
    v_OAC_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1128';
    v_OTX_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1130';
    v_DTL_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1132';
    v_DAC_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1134';
    v_DTX_SelectCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1135';
    v_ALL_SelectCursor  := dbms_sql.open_cursor;

    xProgress := 'GASNOB-40-1136';
    v_SHP_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1138';
    v_STX_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1140';
    v_ORD_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1142';
    v_OAC_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1144';
    v_OTX_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1146';
    v_DTL_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1148';
    v_DAC_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1150';
    v_DTX_DeleteCursor  := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1151';
    v_ALL_DeleteCursor  := dbms_sql.open_cursor;

    xProgress := 'GASNOB-40-1152';
    v_SHP_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1154';
    v_STX_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1156';
    v_ORD_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1158';
    v_OAC_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1160';
    v_OTX_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1162';
    v_DTL_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1164';
    v_DAC_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1166';
    v_DTX_XDeleteCursor := dbms_sql.open_cursor;
    xProgress := 'GASNOB-40-1166';
    v_ALL_XDeleteCursor := dbms_sql.open_cursor;

    /* */
    /*  Parse each SELECT and DELETE statement so the database understands */
    /*  the command. */
    /* */

    xProgress := 'GASNOB-40-1170';
    BEGIN
      dbms_sql.parse ( v_SHP_SelectCursor,
                       v_SHP_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_SHP_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1180';
    BEGIN
      dbms_sql.parse ( v_STX_SelectCursor,
                       v_STX_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_STX_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1190';
    BEGIN
      dbms_sql.parse ( v_ORD_SelectCursor,
                       v_ORD_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_ORD_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1200';
    BEGIN
      dbms_sql.parse ( v_OAC_SelectCursor,
                       v_OAC_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OAC_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1210';
    BEGIN
      dbms_sql.parse ( v_OTX_SelectCursor,
                       v_OTX_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OTX_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1220';
    BEGIN
      dbms_sql.parse ( v_DTL_SelectCursor,
                       v_DTL_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTL_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1230';
    BEGIN
      dbms_sql.parse ( v_DAC_SelectCursor,
                       v_DAC_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DAC_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1240';
    BEGIN
      dbms_sql.parse ( v_DTX_SelectCursor,
                       v_DTX_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTX_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1245';
    BEGIN
      dbms_sql.parse ( v_ALL_SelectCursor,
                       v_ALL_Select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_ALL_Select) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1250';
    BEGIN
      dbms_sql.parse ( v_SHP_DeleteCursor,
                       v_SHP_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_SHP_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1260';
    BEGIN
      dbms_sql.parse ( v_STX_DeleteCursor,
                       v_STX_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_STX_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1270';
    BEGIN
      dbms_sql.parse ( v_ORD_DeleteCursor,
                       v_ORD_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_ORD_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1280';
    BEGIN
      dbms_sql.parse ( v_OAC_DeleteCursor,
                       v_OAC_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OAC_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1290';
    BEGIN
      dbms_sql.parse ( v_OTX_DeleteCursor,
                       v_OTX_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OTX_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1300';
    BEGIN
      dbms_sql.parse ( v_DTL_DeleteCursor,
                       v_DTL_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTL_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1310';
    BEGIN
      dbms_sql.parse ( v_DAC_DeleteCursor,
                       v_DAC_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DAC_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1320';
    BEGIN
      dbms_sql.parse ( v_DTX_DeleteCursor,
                       v_DTX_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTX_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1325';
    BEGIN
      dbms_sql.parse ( v_ALL_DeleteCursor,
                       v_ALL_Delete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_ALL_Delete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1330';
    BEGIN
      dbms_sql.parse ( v_SHP_XDeleteCursor,
                       v_SHP_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_SHP_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1340';
    BEGIN
      dbms_sql.parse ( v_STX_XDeleteCursor,
                       v_STX_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_STX_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1350';
    BEGIN
      dbms_sql.parse ( v_ORD_XDeleteCursor,
                       v_ORD_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_ORD_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1360';
    BEGIN
      dbms_sql.parse ( v_OAC_XDeleteCursor,
                       v_OAC_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OAC_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1370';
    BEGIN
      dbms_sql.parse ( v_OTX_XDeleteCursor,
                       v_OTX_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_OTX_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1380';
    BEGIN
      dbms_sql.parse ( v_DTL_XDeleteCursor,
                       v_DTL_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTL_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1390';
    BEGIN
      dbms_sql.parse ( v_DAC_XDeleteCursor,
                       v_DAC_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DAC_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1400';
    BEGIN
      dbms_sql.parse ( v_DTX_XDeleteCursor,
                       v_DTX_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_DTX_XDelete) ;
        app_exception.raise_exception;
    END;

    xProgress := 'GASNOB-40-1405';
    BEGIN
      dbms_sql.parse ( v_ALL_XDeleteCursor,
                       v_ALL_XDelete,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   v_SHP_Delete) ;
        app_exception.raise_exception;
    END;

    /* */
    /*  Initialize all counters. */
    /* */

    xProgress := 'GASNOB-40-1410';
    v_SHP_Count := v_SHP_Table.COUNT;
    ec_debug.pl ( 3, 'v_SHP_Count: ', v_SHP_Count );

    xProgress := 'GASNOB-40-1412';
    v_STX_Count :=v_STX_Table.COUNT;
    ec_debug.pl ( 3, 'v_STX_Count: ', v_STX_Count );

    xProgress := 'GASNOB-40-1414';
    v_ORD_Count := v_ORD_Table.COUNT;
    ec_debug.pl ( 3, 'v_ORD_Count: ', v_ORD_Count );

    xProgress := 'GASNOB-40-1416';
    v_OAC_Count := v_OAC_Table.COUNT;
    ec_debug.pl ( 3, 'v_OAC_Count: ', v_OAC_Count );

    xProgress := 'GASNOB-40-1418';
    v_OTX_Count := v_OTX_Table.COUNT;
    ec_debug.pl ( 3, 'v_OTX_Count: ', v_OTX_Count );

    xProgress := 'GASNOB-40-1420';
    v_DTL_Count := v_DTL_Table.COUNT;
    ec_debug.pl ( 3, 'v_DTL_Count: ', v_DTL_Count );

    xProgress := 'GASNOB-40-1422';
    v_DAC_Count := v_DAC_Table.COUNT;
    ec_debug.pl ( 3, 'v_DAC_Count: ', v_DAC_Count );

    xProgress := 'GASNOB-40-1424';
    v_DTX_Count := v_DTX_Table.COUNT;
    ec_debug.pl ( 3, 'v_DTX_Count: ', v_DTX_Count );

    xProgress := 'GASNOB-40-1424';
    v_ALL_Count := v_ALL_Table.COUNT;
    ec_debug.pl ( 3, 'v_ALL_Count: ', v_ALL_Count );

    /* */
    /*  Define the data type for every column in each SELECT statement */
    /*  so the database understands how to populate it.  Using the */
    /*  K.I.S.S. principle, every data type will be converted to */
    /*  VARCHAR2. */
    /* */

    xProgress := 'GASNOB-40-1430';
    FOR v_LoopCount IN 1..v_SHP_Count
    LOOP
      xProgress := 'GASNOB-40-1440';
      dbms_sql.define_column ( v_SHP_SelectCursor,
                               v_LoopCount,
                               v_SHP_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1450';
    dbms_sql.define_column_rowid ( v_SHP_SelectCursor,
                                   v_SHP_Count + 1,
                                   v_SHP_RowID );

    xProgress := 'GASNOB-40-1460';
    dbms_sql.define_column_rowid ( v_SHP_SelectCursor,
                                   v_SHP_Count + 2,
                                   v_SHP_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1480';
    dbms_sql.define_column ( v_SHP_SelectCursor,
                             v_SHP_Count + 3,
                             v_TransactionRecordID );

    xPRogress := 'GASNOB-40-1490';
    FOR v_LoopCount IN 1..v_STX_Count
    LOOP
      xProgress := 'GASNOB-40-1500';
      dbms_sql.define_column ( v_STX_SelectCursor,
                               v_LoopCount,
                               v_STX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWID for the DELETE statements. */
    /* */

     xProgress := 'GASNOB-40-1510';
    dbms_sql.define_column_rowid ( v_STX_SelectCursor,
                                   v_STX_Count + 1,
                                   v_STX_RowID );

    xProgress := 'GASNOB-40-1520';
    dbms_sql.define_column_rowid ( v_STX_SelectCursor,
                                   v_STX_Count + 2,
                                   v_STX_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1525';
    dbms_sql.define_column ( v_STX_SelectCursor,
                             v_STX_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GASNOB-40-1530';
    FOR v_LoopCount IN 1..v_ORD_Count
    LOOP
      xProgress := 'GASNOB-40-1540';
      dbms_sql.define_column ( v_ORD_SelectCursor,
                               v_LoopCount,
                               v_ORD_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1550';
    dbms_sql.define_column_rowid ( v_ORD_SelectCursor,
                                   v_ORD_Count + 1,
                                   v_ORD_RowID );

    xProgress := 'GASNOB-40-1560';
    dbms_sql.define_column_rowid ( v_ORD_SelectCursor,
                                   v_ORD_Count + 2,
                                   v_ORD_XRowID );
    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1565';
    dbms_sql.define_column ( v_ORD_SelectCursor,
                             v_ORD_Count + 3,
                             v_TransactionRecordID );

    xPRogress := 'GASNOB-40-1570';
    FOR v_LoopCount IN 1..v_OAC_Count
    LOOP
      xProgress := 'GASNOB-40-1580';
      dbms_sql.define_column ( v_OAC_SelectCursor,
                               v_LoopCount,
                               v_OAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1590';
    dbms_sql.define_column_rowid ( v_OAC_SelectCursor,
                                   v_OAC_Count + 1,
                                   v_OAC_RowID );

    xProgress := 'GASNOB-40-1600';
    dbms_sql.define_column_rowid ( v_OAC_SelectCursor,
                                   v_OAC_Count + 2,
                                   v_OAC_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1605';
    dbms_sql.define_column ( v_OAC_SelectCursor,
                             v_OAC_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GASNOB-40-1610';
    FOR v_LoopCount IN 1..v_OTX_Count
    LOOP
      xPRogress := 'GASNOB-40-1620';
      dbms_sql.define_column ( v_OTX_SelectCursor,
                               v_LoopCount,
                               v_OTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1630';
    dbms_sql.define_column_rowid ( v_OTX_SelectCursor,
                                   v_OTX_Count + 1,
                                   v_OTX_RowID );

    xProgress := 'GASNOB-40-1640';
    dbms_sql.define_column_rowid ( v_OTX_SelectCursor,
                                   v_OTX_Count + 2,
                                   v_OTX_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1650';
    dbms_sql.define_column ( v_OTX_SelectCursor,
                             v_OTX_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GASNOB-40-1660';
    FOR v_LoopCount IN 1..v_DTL_Count
    LOOP
      xProgress := 'GASNOB-40-1670';
      dbms_sql.define_column ( v_DTL_SelectCursor,
                               v_LoopCount,
                               v_DTL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1680';
    dbms_sql.define_column_rowid ( v_DTL_SelectCursor,
                                   v_DTL_Count + 1,
                                   v_DTL_RowID );

    xProgress := 'GASNOB-40-1690';
    dbms_sql.define_column_rowid ( v_DTL_SelectCursor,
                                   v_DTL_Count + 2,
                                   v_DTL_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1700';
    dbms_sql.define_column ( v_DTL_SelectCursor,
                             v_DTL_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GASNOB-40-1710';
    FOR v_LoopCount IN 1..v_DAC_Count
    LOOP
      xProgress := 'GASNOB-40-1720';
      dbms_sql.define_column ( v_DAC_SelectCursor,
                               v_LoopCount,
                               v_DAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1730';
    dbms_sql.define_column_rowid ( v_DAC_SelectCursor,
                                   v_DAC_Count + 1,
                                   v_DAC_RowID );

    xProgress := 'GASNOB-40-1740';
    dbms_sql.define_column_rowid ( v_DAC_SelectCursor,
                                   v_DAC_Count + 2,
                                   v_DAC_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNO-40-1750';
    dbms_sql.define_column ( v_DAC_SelectCursor,
                             v_DAC_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GASNOB-40-1770';
    FOR v_LoopCount IN 1..v_DTX_Count
    LOOP
      xProgress := 'GASNOB-40-1780';
      dbms_sql.define_column ( v_DTX_SelectCursor,
                               v_LoopCount,
                               v_DTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1790';
    dbms_sql.define_column_rowid ( v_DTX_SelectCursor,
                                   v_DTX_Count + 1,
                                   v_DTX_RowID );

    xPRogress := 'GASNOB-40-1800';
    dbms_sql.define_column_rowid ( v_DTX_SelectCursor,
                                   v_DTX_Count + 2,
                                   v_DTX_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1805';
    dbms_sql.define_column ( v_DTX_SelectCursor,
                             v_DTX_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GASNOB-40-1810';
    FOR v_LoopCount IN 1..v_ALL_Count
    LOOP
      xProgress := 'GASNOB-40-1811';
      dbms_sql.define_column ( v_ALL_SelectCursor,
                               v_LoopCount,
                               v_ALL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /* */
    /*  Define the ROWIDs for the DELETE statements. */
    /* */

    xProgress := 'GASNOB-40-1812';
    dbms_sql.define_column_rowid ( v_ALL_SelectCursor,
                                   v_ALL_Count + 1,
                                   v_ALL_RowID );

    xProgress := 'GASNOB-40-1813';
    dbms_sql.define_column_rowid ( v_ALL_SelectCursor,
                                   v_ALL_Count + 2,
                                   v_ALL_XRowID );

    /* */
    /*  Define the internal ID columns. */
    /* */

    xProgress := 'GASNOB-40-1814';
    dbms_sql.define_column ( v_ALL_SelectCursor,
                             v_ALL_Count + 3,
                             v_TransactionRecordID );

    /* */
    /*  Bind the variable in the SHP level SELECT clause. */
    /* */

    xProgress := 'GASNOB-40-1810';
    dbms_sql.bind_variable ( v_SHP_SelectCursor,
                             'Run_ID',
                             p_RunID );

    /* */
    /*  Execute the Shipment level SELECT statement. */
    /* */

    xProgress := 'GASNOB-40-1820';
    v_Dummy := dbms_sql.execute ( v_SHP_SelectCursor );

    /* */
    /*  Begin the Shipment level loop. */
    /* */

    xProgress := 'GASNOB-40-1830';
    WHILE dbms_sql.fetch_rows ( v_SHP_SelectCursor ) > 0
    LOOP

      /* */
      /*  Store the returned values in the PL/SQL table. */
      /* */

      xProgress := 'GASNOB-40-1840';
      FOR v_LoopCount IN 1..v_SHP_Count
      LOOP
        xProgress := 'GASNOB-40-1850';
        dbms_sql.column_value ( v_SHP_SelectCursor,
                                v_LoopCount,
                                v_SHP_Table(v_LoopCount).value );
      END LOOP;

      /* */
      /*  Store the ROWIDs. */
      /* */

      xProgress := 'GASNOB-40-1860';
      dbms_sql.column_value ( v_SHP_SelectCursor,
                              v_SHP_Count + 1,
                              v_SHP_RowID );

      xProgress := 'GASNOB-40-1870';
      dbms_sql.column_value ( v_SHP_SelectCursor,
                              v_SHP_Count + 2,
                              v_SHP_XRowID );

      /* */
      /*  Locate the necessary data elements and build the common key */
      /*  record for this level.  Common key elements are used for each */
      /*  record, so save the values. */
      /* */

      xProgress := 'GASNOB-40-1880';
      ece_flatfile_pvt.find_pos ( v_SHP_Table,
                                  /*ece_flatfile_pvt.G_Translator_Code, */
                                 'TP_CODE',
                                 v_TranslatorCodePosition );
/*
      dbms_output.put_line(' v_shp_commonkeyname = ' || v_shp_commonkeyname);
      dbms_output.put_line(' v_shp_cknameposition = ' || v_shp_cknameposition);
*/
      xProgress := 'GASNOB-40-1890';
      ece_flatfile_pvt.find_pos ( v_SHP_Table,
                                  v_SHP_CommonKeyName,
                                  v_SHP_CKNamePosition );

      xProgress := 'GASNOB-40-1900';
      v_RecordCommonKey0 := RPAD ( NVL(SUBSTRB ( v_SHP_Table(v_TranslatorCodePosition).value,
                                   1, 25 ),' '), 25 );

      xProgress := 'GASNOB-40-1910';
      v_RecordCommonKey1 := RPAD ( NVL(SUBSTRB ( v_SHP_Table(v_SHP_CKNamePosition).value,
                                   1, 22 ),' '), 22 );

      xProgress := 'GASNOB-40-1920';
      v_FileCommonKey := v_RecordCommonKey0 ||
                         v_RecordCommonKey1 ||
                         v_KeyPad           ||
                         v_KeyPad;

      /* */
      /*  Write the record to the output table. */
      /* */

      xProgress := 'GASNOB-40-1930';
      ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                             p_CommunicationMethod,
                                             p_SHP_Interface,
                                             v_SHP_Table,
                                             p_OutputWidth,
                                             p_RunID,
                                             v_FileCommonKey );

      /* */
      /*  Store the values of the necessary elements (BOL_ID and */
      /*  and Transaction_Record_ID) in the Shipment level SELECT clause */
      /*  into local variables and use the values to bind the variables */
      /*  in the SELECT clauses of the lower levels to come */
      /* */

      xProgress := 'GASNOB-40-1940';
      dbms_sql.column_value ( v_SHP_SelectCursor,
                              v_SHP_Count + 3,
                              v_TransactionRecordID );


      xProgress := 'GASNOB-40-2020';
      ece_flatfile_pvt.find_pos( v_SHP_Table,
                                 'BOL_ID',
                                 v_BOL_ID_Position );

      /* */
      /*  Execute the Shipment Text SELECT statement. */
      /* */
      xProgress := 'GASNOB-40-2025';
      v_BOL_Id := TO_NUMBER ( v_SHP_Table(v_BOL_Id_Position).value );

      xProgress := 'GASNOB-40-2028';
      dbms_sql.bind_variable ( v_STX_SelectCursor,
                               'RUN_ID',
                               v_RunID );

      dbms_sql.bind_variable ( v_STX_SelectCursor,
                               'BOL_ID',
                               v_BOL_ID );

      xProgress := 'GASNOB-40-2030';
      v_Dummy := dbms_sql.execute ( v_STX_SelectCursor );

      /* */
      /*  Fetch the (single) row, and store the returned values in the  */
      /*  PL/SQL table. */
      /* */

      xProgress := 'GASNOB-40-2050';
    WHILE dbms_sql.fetch_rows(v_STX_SelectCursor) > 0
    LOOP
      FOR v_LoopCount IN 1..v_STX_Count
      LOOP
        xProgress := 'GASNOB-40-2060';
        dbms_sql.column_value ( v_STX_SelectCursor,
                                v_LoopCount,
                                v_STX_Table(v_LoopCount).value );
      END LOOP;

      /* */
      /*  Store the ROWIDs. */
      /* */

      xProgress := 'GASNOB-40-2070';
      dbms_sql.column_value ( v_STX_SelectCursor,
                              v_STX_Count + 1,
                              v_STX_RowID );

      xProgress := 'GASNOB-40-2080';
      dbms_sql.column_value ( v_STX_SelectCursor,
                              v_STX_Count + 2,
                              v_STX_XRowID );

      xProgress := 'GASNOB-40-2082';
      ece_flatfile_pvt.find_pos ( v_STX_Table,
                                  v_STX_CommonKeyName,
                                  v_STX_CKNamePosition );

        xProgress := 'GASNOB-40-2084';
        v_RecordCommonKey2 := RPAD ( NVL(SUBSTRB ( v_STX_Table(v_STX_CKNamePosition).value,
                                   1, 22 ),' '), 22 );

        xProgress := 'GASNOB-40-2086';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_KeyPad;
      /* */
      /*  Write the record to the output table. */
      /* */

      xProgress := 'GASNOB-40-2090';
      ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                             p_CommunicationMethod,
                                             p_STX_Interface,
                                             v_STX_Table,
                                             p_OutputWidth,
                                             p_RunID,
                                             v_FileCommonKey );

        xProgress := 'GASNOB-40-2091';
        dbms_sql.bind_variable ( v_STX_DeleteCursor,
                                 'Row_ID',
                                 v_STX_RowID );

        xProgress := 'GASNOB-40-2092';
        dbms_sql.bind_variable ( v_STX_XDeleteCursor,
                                 'Row_ID',
                                 v_STX_XRowID );

        xProgress := 'GASNOB-40-2093';
        v_Dummy := dbms_sql.execute ( v_STX_DeleteCursor );

        xProgress := 'GASNOB-40-2094';
        v_Dummy := dbms_sql.execute ( v_STX_XDeleteCursor );

   END LOOP; /* while stx */

      /* */
      /*  Execute the Order level SELECT statement. */
      /* */
      xProgress := 'GASNOB-40-2095';
      dbms_sql.bind_variable ( v_ORD_SelectCursor,
                               'RUN_ID',
                               v_RunID );

      dbms_sql.bind_variable ( v_ORD_SelectCursor,
                               'BOL_ID',
                               v_BOL_ID );

      xProgress := 'GASNOB-40-2100';
      v_Dummy := dbms_sql.execute ( v_ORD_SelectCursor );

      /* */
      /*  Begin the Order level loop. */
      /* */
      xProgress := 'GASNOB-40-2110';
      WHILE dbms_sql.fetch_rows ( v_ORD_SelectCursor ) > 0
      LOOP
        xProgress := 'GASNOB-40-2120';
        FOR v_LoopCount IN 1..v_ORD_Count
        LOOP
          xPRogress := 'GASNOB-40-2130';
          dbms_sql.column_value ( v_ORD_SelectCursor,
                                  v_LoopCount,
                                  v_ORD_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Store the ROWIDs. */
        /* */

        xProgress := 'GASNOB-40-2140';
        dbms_sql.column_value ( v_ORD_SelectCursor,
                                v_ORD_Count + 1,
                                v_ORD_RowID );

        xProgress := 'GASNOB-40-2150';
        dbms_sql.column_value ( v_ORD_SelectCursor,
                                v_ORD_Count + 2,
                                v_ORD_XRowID );

        xProgress := 'GASNOB-40-2151';
        ece_flatfile_pvt.find_pos ( v_ORD_Table,
                                    v_ORD_CommonKeyName,
                                    v_ORD_CKNamePosition );

        xProgress := 'GASNOB-40-2152';
        v_RecordCommonKey2 := RPAD ( NVL(SUBSTRB ( v_ORD_Table(v_ORD_CKNamePosition).value,
                                   1, 22 ),' '), 22 );

        xProgress := 'GASNOB-40-2153';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_KeyPad;

        /* */
        /*  Write the record to the output table. */
        /* */

        xProgress := 'GASNOB-40-2160';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_ORD_Interface,
                                               v_ORD_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        /* */
        /*  Bind the variables (ROWIDs) in the DELETE statements. */
        /* */

        xProgress := 'GASNOB-40-2170';
        dbms_sql.bind_variable ( v_ORD_DeleteCursor,
                                 'Row_ID',
                                 v_ORD_RowID );

        xProgress := 'GASNOB-40-2180';
        dbms_sql.bind_variable ( v_ORD_XDeleteCursor,
                                 'Row_ID',
                                 v_ORD_XRowID );

        /* */
        /*  Delete the rows from the interface table. */
        /* */

        xProgress := 'GASNOB-40-2190';
        v_Dummy := dbms_sql.execute ( v_ORD_DeleteCursor );

        xProgress := 'GASNOB-40-2200';
        v_Dummy := dbms_sql.execute ( v_ORD_XDeleteCursor );

      /* */
      /*  Execute the Order DAC SELECT statement. */
      /* */
      xProgress := 'GASNOB-40-2205';
      ece_flatfile_pvt.find_pos( v_ORD_Table,
                                 'Order_ID',
                                 v_Order_ID_Position );

      xProgress := 'GASNOB-40-2206';
      v_Order_Id := TO_NUMBER ( v_ORD_Table(v_Order_Id_Position).value );

      xProgress := 'GASNOB-40-2207';
      dbms_sql.bind_variable ( v_OAC_SelectCursor,
                               'RUN_ID',
                               v_RunID );

      dbms_sql.bind_variable ( v_OAC_SelectCursor,
                               'Order_ID',
                               v_Order_ID );

      xProgress := 'GASNOB-40-2210';
      v_Dummy := dbms_sql.execute ( v_OAC_SelectCursor );

      /* */
      /*  Begin the Order DAC loop. */
      /* */

      xProgress := 'GASNOB-40-2220';
      WHILE dbms_sql.fetch_rows ( v_OAC_SelectCursor ) > 0
      LOOP
        xProgress := 'GASNOB-40-2230';
        FOR v_LoopCount IN 1..v_OAC_Count
        LOOP
          xProgress := 'GASNOB-40-2240';
          dbms_sql.column_value ( v_OAC_SelectCursor,
                                  v_LoopCount,
                                  v_OAC_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Store the ROWIDs. */
        /* */

        xProgress := 'GASNOB-40-2250';
        dbms_sql.column_value ( v_OAC_SelectCursor,
                                v_OAC_Count + 1,
                                v_OAC_RowID );

        xProgress := 'GASNOB-40-2260';
        dbms_sql.column_value ( v_OAC_SelectCursor,
                                v_OAC_Count + 2,
                                v_OAC_XRowID );

        xProgress := 'GASNOB-40-2270';
        ece_flatfile_pvt.find_pos ( v_OAC_Table,
                                    v_OAC_CommonKeyName,
                                    v_OAC_CKNamePosition);

        xProgress := 'GASNOB-40-2280';
        v_RecordCommonKey3 := RPAD ( NVL(SUBSTRB ( v_OAC_Table(v_OAC_CKNamePosition).value,
                                              1, 22 ),' '), 22 );

        xProgress := 'GASNOB-40-2290';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;
        ec_debug.pl ( 3, 'v_FileCommonKey: ',v_FileCommonKey );

        /* */
        /*  Write the record to the output table. */
        /* */

        xProgress := 'GASNOB-40-2300';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_OAC_Interface,
                                               v_OAC_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GASNOB-40-2310';
        dbms_sql.bind_variable ( v_OAC_DeleteCursor,
                                 'Row_ID',
                                 v_OAC_RowID );

        xProgress := 'GASNOB-40-2320';
        dbms_sql.bind_variable ( v_OAC_XDeleteCursor,
                                 'Row_ID',
                                 v_OAC_XRowID );

        xProgress := 'GASNOB-40-2330';
        v_Dummy := dbms_sql.execute ( v_OAC_DeleteCursor );

        xProgress := 'GASNOB-40-2340';
        v_Dummy := dbms_sql.execute ( v_OAC_XDeleteCursor );
      END LOOP; /* while oac */

      /* */
      /*  Execute the Order Text SELECT statement. */
      /* */
      xProgress := 'GASNOB-40-2350';
      dbms_sql.bind_variable ( v_OTX_SelectCursor,
                               'RUN_ID',
                               v_RunID );

      dbms_sql.bind_variable ( v_OTX_SelectCursor,
                               'Order_ID',
                               v_Order_ID );

      xProgress := 'GASNOB-40-2360';
      v_Dummy := dbms_sql.execute ( v_OTX_SelectCursor );

      /* */
      /*  Begin the Order Text loop. */
      /* */

      xProgress := 'GASNOB-40-2370';
      WHILE dbms_sql.fetch_rows ( v_OTX_SelectCursor ) > 0
      LOOP
        xProgress := 'GASNOB-40-2380';
        FOR v_LoopCount IN 1..v_OTX_Count
        LOOP
          xProgress := 'GASNOB-40-2390';
          dbms_sql.column_value ( v_OTX_SelectCursor,
                                  v_LoopCount,
                                  v_OTX_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Store the ROWIDs. */
        /* */

        xProgress := 'GASNOB-40-2400';
        dbms_sql.column_value ( v_OTX_SelectCursor,
                                v_OTX_Count + 1,
                                v_OTX_RowID );

        xProgress := 'GASNOB-40-2410';
        dbms_sql.column_value ( v_OTX_SelectCursor,
                                v_OTX_Count + 2,
                                v_OTX_XRowID );

        xProgress := 'GASNOB-40-2420';
        ece_flatfile_pvt.find_pos ( v_OTX_Table,
                                    v_OTX_CommonKeyName,
                                    v_OTX_CKNamePosition);

        xProgress := 'GASNOB-40-2430';
        v_RecordCommonKey3 := RPAD ( NVL(SUBSTRB ( v_OTX_Table(v_OTX_CKNamePosition).value,
                                              1, 22 ),' '), 22 );

        xProgress := 'GASNOB-40-2440';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;

        /* */
        /*  Write the record to the output table. */
        /* */

        xProgress := 'GASNOB-40-2450';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_OTX_Interface,
                                               v_OTX_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GASNOB-40-2460';
        dbms_sql.bind_variable ( v_OTX_DeleteCursor,
                                 'Row_ID',
                                 v_OTX_RowID );

        xProgress := 'GASNOB-40-2470';
        dbms_sql.bind_variable ( v_OTX_XDeleteCursor,
                                 'Row_ID',
                                 v_OTX_XRowID );

        xProgress := 'GASNOB-40-2480';
        v_Dummy := dbms_sql.execute ( v_OTX_DeleteCursor );

        xProgress := 'GASNOB-40-2490';
        v_Dummy := dbms_sql.execute ( v_OTX_XDeleteCursor );
      END LOOP; /* while otx */

        /* */
        /*  Execute the Detail level SELECT statement. */
        /* */
        xProgress := 'GASNOB-40-2500';
        dbms_sql.bind_variable ( v_DTL_SelectCursor,
                                 'RUN_ID',
                                 v_RunID );

        dbms_sql.bind_variable ( v_DTL_SelectCursor,
                                 'BOL_ID',
                                 v_BOL_ID );

        dbms_sql.bind_variable ( v_DTL_SelectCursor,
                                 'Order_ID',
                                 v_Order_ID );

        xProgress := 'GASNOB-40-2510';
        v_Dummy := dbms_sql.execute ( v_DTL_SelectCursor );

        /* */
        /*  Begin the Detail level loop. */
        /* */
        xProgress := 'GASNOB-40-2520';
        WHILE dbms_sql.fetch_rows ( v_DTL_SelectCursor ) > 0
        LOOP
          xProgress := 'GASNOB-40-2530';
          FOR v_LoopCount IN 1..v_DTL_Count
          LOOP
            xProgress := 'GASNOB-40-2540';
            dbms_sql.column_value ( v_DTL_SelectCursor,
                                    v_LoopCount,
                                    v_DTL_Table(v_LoopCount).value);
          END LOOP;

          /* */
          /*  Store the ROWIDs. */
          /* */

          xProgress := 'GASNOB-40-2550';
          dbms_sql.column_value ( v_DTL_SelectCursor,
                                  v_DTL_Count + 1,
                                  v_DTL_RowID );

          xProgress := 'GASNOB-40-2560';
          dbms_sql.column_value ( v_DTL_SelectCursor,
                                  v_DTL_Count + 2,
                                  v_DTL_XRowID );

          /* */
          /*  Find the Line Number in the PL/SQL table and add this */
          /*  value to the common key. */
          /* */

          xProgress := 'GASNOB-40-2570';
          ece_flatfile_pvt.find_pos ( v_DTL_Table,
                                      v_DTL_CommonKeyName,
                                      v_DTL_CKNamePosition);

          xProgress := 'GASNOB-40-2580';
          v_RecordCommonKey3 := RPAD ( NVL(SUBSTRB ( v_DTL_Table(v_DTL_CKNamePosition).value,
                                       1, 22 ),' '), 22 );

          xProgress := 'GASNOB-40-2590';
          v_FileCommonKey := v_RecordCommonKey0 ||
                             v_RecordCommonKey1 ||
                             v_RecordCommonKey2 ||
                             v_RecordCommonKey3;
          ec_debug.pl ( 3, 'v_FileCommonKey: ',v_FileCommonKey );

          /* */
          /*  Write the record to the output table. */
          /* */

          xProgress := 'GASNOB-40-2600';
          ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                                 p_CommunicationMethod,
                                                 p_DTL_Interface,
                                                 v_DTL_Table,
                                                 p_OutputWidth,
                                                 p_RunID,
                                                 v_FileCommonKey );

          xProgress := 'GASNOB-40-2610';
          dbms_sql.bind_variable ( v_DTL_DeleteCursor,
                                   'Row_ID',
                                   v_DTL_RowID );

          xProgress := 'GASNOB-40-2620';
          dbms_sql.bind_variable ( v_DTL_XDeleteCursor,
                                   'Row_ID',
                                   v_DTL_XRowID );

          /* */
          /*  Delete the rows from the interface table. */
          /* */

          xProgress := 'GASNOB-40-2630';
          v_Dummy := dbms_sql.execute ( v_DTL_DeleteCursor );

          xProgress := 'GASNOB-40-2640';
          v_Dummy := dbms_sql.execute ( v_DTL_XDeleteCursor );

      /* */
      /*  Execute the Detail DAC SELECT statement. */
      /* */
      xProgress := 'GASNOB-40-2650';
      ece_flatfile_pvt.find_pos( v_DTL_Table,
                                 'Line_ID',
                                 v_Line_ID_Position );

      xProgress := 'GASNOB-40-2660';
      v_Line_Id := TO_NUMBER ( v_DTL_Table(v_Line_Id_Position).value );
      ec_debug.pl ( 3, 'v_Line_Id: ', v_Line_Id );

      xProgress := 'GASNOB-40-2670';
      dbms_sql.bind_variable ( v_DAC_SelectCursor,
                               'RUN_ID',
                               v_RunID );

      dbms_sql.bind_variable ( v_DAC_SelectCursor,
                               'Line_ID',
                               v_Line_ID );

      xProgress := 'GASNOB-40-2680';
      v_Dummy := dbms_sql.execute ( v_DAC_SelectCursor );

      /* */
      /*  Begin the DETAIL DAC loop. */
      /* */

      xProgress := 'GASNOB-40-2690';
      WHILE dbms_sql.fetch_rows ( v_DAC_SelectCursor ) > 0
      LOOP
        xProgress := 'GASNOB-40-2700';
        FOR v_LoopCount IN 1..v_DAC_Count
        LOOP
          xProgress := 'GASNOB-40-2710';
          dbms_sql.column_value ( v_DAC_SelectCursor,
                                  v_LoopCount,
                                  v_DAC_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Store the ROWIDs. */
        /* */

        xProgress := 'GASNOB-40-2720';
        dbms_sql.column_value ( v_DAC_SelectCursor,
                                v_DAC_Count + 1,
                                v_DAC_RowID );

        xProgress := 'GASNOB-40-2730';
        dbms_sql.column_value ( v_DAC_SelectCursor,
                                v_DAC_Count + 2,
                                v_DAC_XRowID );


        xProgress := 'GASNOB-40-2740';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;
        ec_debug.pl ( 3, 'v_FileCommonKey: ', v_FileCommonKey );

        /* */
        /*  Write the record to the output table. */
        /* */

        xProgress := 'GASNOB-40-2770';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_DAC_Interface,
                                               v_DAC_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GASNOB-40-2780';
        dbms_sql.bind_variable ( v_DAC_DeleteCursor,
                                 'Row_ID',
                                 v_DAC_RowID );

        xProgress := 'GASNOB-40-2790';
        dbms_sql.bind_variable ( v_DAC_XDeleteCursor,
                                 'Row_ID',
                                 v_DAC_XRowID );

        xProgress := 'GASNOB-40-2800';
        v_Dummy := dbms_sql.execute ( v_DAC_DeleteCursor );

        xProgress := 'GASNOB-40-2810';
        v_Dummy := dbms_sql.execute ( v_DAC_XDeleteCursor );
        END LOOP; /* while Dac */

        xProgress := 'GASNOB-40-2840';
        dbms_sql.bind_variable ( v_DTX_SelectCursor,
                               'RUN_ID',
                               v_RunID );

        dbms_sql.bind_variable ( v_DTX_SelectCursor,
                                'Line_ID',
                               v_Line_ID );

      xProgress := 'GASNOB-40-2850';
      v_Dummy := dbms_sql.execute ( v_DTX_SelectCursor );

      /* */
      /*  Begin the DETAIL TEXT loop. */
      /* */

      xProgress := 'GASNOB-40-2860';
      WHILE dbms_sql.fetch_rows ( v_DTX_SelectCursor ) > 0
      LOOP
        xProgress := 'GASNOB-40-2870';
        FOR v_LoopCount IN 1..v_DTX_Count
        LOOP
          xProgress := 'GASNOB-40-2880';
          dbms_sql.column_value ( v_DTX_SelectCursor,
                                  v_LoopCount,
                                  v_DTX_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Store the ROWIDs. */
        /* */

        xProgress := 'GASNOB-40-2890';
        dbms_sql.column_value ( v_DTX_SelectCursor,
                                v_DTX_Count + 1,
                                v_DTX_RowID );

        xProgress := 'GASNOB-40-2900';
        dbms_sql.column_value ( v_DTX_SelectCursor,
                                v_DTX_Count + 2,
                                v_DTX_XRowID );


        xProgress := 'GASNOB-40-2910';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;
        ec_debug.pl ( 3, 'v_FileCommonKey: ', v_FileCommonKey );

        /* */
        /*  Write the record to the output table. */
        /* */

        xProgress := 'GASNOB-40-2920';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_DTX_Interface,
                                               v_DTX_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GASNOB-40-2930';
        dbms_sql.bind_variable ( v_DTX_DeleteCursor,
                                 'Row_ID',
                                 v_DTX_RowID );

        xProgress := 'GASNOB-40-2940';
        dbms_sql.bind_variable ( v_DTX_XDeleteCursor,
                                 'Row_ID',
                                 v_DTX_XRowID );

        xProgress := 'GASNOB-40-2950';
        v_Dummy := dbms_sql.execute ( v_DTX_DeleteCursor );

        xProgress := 'GASNOB-40-2960';
        v_Dummy := dbms_sql.execute ( v_DTX_XDeleteCursor );
       END LOOP; /* while dtx */

        xProgress := 'GASNOB-40-2970';
        dbms_sql.bind_variable ( v_ALL_SelectCursor,
                               'RUN_ID',
                               v_RunID );

        dbms_sql.bind_variable ( v_ALL_SelectCursor,
                                'Line_ID',
                               v_Line_ID );

      xProgress := 'GASNOB-40-2980';
      v_Dummy := dbms_sql.execute ( v_ALL_SelectCursor );

      /* */
      /*  Begin the DETAIL ALOCATIONS loop */
      /* */

      xProgress := 'GASNOB-40-2990';
      WHILE dbms_sql.fetch_rows ( v_ALL_SelectCursor ) > 0
      LOOP
        xProgress := 'GASNOB-40-2993';
        FOR v_LoopCount IN 1..v_ALL_Count
        LOOP
          xProgress := 'GASNOB-40-2995';
          dbms_sql.column_value ( v_ALL_SelectCursor,
                                  v_LoopCount,
                                  v_ALL_Table(v_LoopCount).value );
        END LOOP;

        /* */
        /*  Store the ROWIDs. */
        /* */

        xProgress := 'GASNOB-40-3000';
        dbms_sql.column_value ( v_ALL_SelectCursor,
                                v_ALL_Count + 1,
                                v_ALL_RowID );

        xProgress := 'GASNOB-40-3010';
        dbms_sql.column_value ( v_ALL_SelectCursor,
                                v_ALL_Count + 2,
                                v_ALL_XRowID );


        xProgress := 'GASNOB-40-3020';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;
        ec_debug.pl ( 3, 'v_FileCommonKey: ', v_FileCommonKey );

        /* */
        /*  Write the record to the output table. */
        /* */

        xProgress := 'GASNOB-40-3030';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_ALL_Interface,
                                               v_ALL_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GASNOB-40-3040';
        dbms_sql.bind_variable ( v_ALL_DeleteCursor,
                                 'Row_ID',
                                 v_ALL_RowID );

        xProgress := 'GASNOB-40-3050';
        dbms_sql.bind_variable ( v_ALL_XDeleteCursor,
                                 'Row_ID',
                                 v_ALL_XRowID );

        xProgress := 'GASNOB-40-3060';
        v_Dummy := dbms_sql.execute ( v_ALL_DeleteCursor );

        xProgress := 'GASNOB-40-3070';
        v_Dummy := dbms_sql.execute ( v_ALL_XDeleteCursor );
        END LOOP; /* while all */
       END LOOP; /* while dtl */
    END LOOP; /* while ord */
    xProgress := 'GASNOB-40-3140';
    dbms_sql.bind_variable ( v_SHP_DeleteCursor,
                             'Row_ID',
                             v_SHP_RowID );

    xProgress := 'GASNOB-40-3150';
    dbms_sql.bind_variable ( v_SHP_XDeleteCursor,
                             'Row_ID',
                             v_SHP_XRowID );

    xProgress := 'GASNOB-40-3160';
    v_Dummy := dbms_sql.execute ( v_SHP_DeleteCursor );

    xProgress := 'GASNOB-40-3160';
    v_Dummy := dbms_sql.execute ( v_SHP_XDeleteCursor );
  END LOOP; /* while shp */

    /* */
    /*  Commit the interface table DELETEs. */
    /* */

    xProgress := 'GASNOB-40-3071';
    COMMIT;

    /* */
    /*  Close all open cursors. */
    /* */

    xProgress := 'GASNOB-40-3080';
    dbms_sql.close_cursor ( v_SHP_SelectCursor );
    xProgress := 'GASNOB-40-3081';
    dbms_sql.close_cursor ( v_STX_SelectCursor );
    xProgress := 'GASNOB-40-3082';
    dbms_sql.close_cursor ( v_ORD_SelectCursor );
    xProgress := 'GASNOB-40-3083';
    dbms_sql.close_cursor ( v_OAC_SelectCursor );
    xProgress := 'GASNOB-40-3084';
    dbms_sql.close_cursor ( v_OTX_SelectCursor );
    xProgress := 'GASNOB-40-3085';
    dbms_sql.close_cursor ( v_DTL_SelectCursor );
    xProgress := 'GASNOB-40-3086';
    dbms_sql.close_cursor ( v_DAC_SelectCursor );
    xProgress := 'GASNOB-40-3087';
    dbms_sql.close_cursor ( v_DTX_SelectCursor );
    xProgress := 'GASNOB-40-3088';
    dbms_sql.close_cursor ( v_ALL_SelectCursor );

    xProgress := 'GASNOB-40-3088';
    dbms_sql.close_cursor ( v_SHP_DeleteCursor );
    xProgress := 'GASNOB-40-3089';
    dbms_sql.close_cursor ( v_STX_DeleteCursor );
    xProgress := 'GASNOB-40-3090';
    dbms_sql.close_cursor ( v_ORD_DeleteCursor );
    xProgress := 'GASNOB-40-3091';
    dbms_sql.close_cursor ( v_OAC_DeleteCursor );
    xProgress := 'GASNOB-40-3092';
    dbms_sql.close_cursor ( v_OTX_DeleteCursor );
    xProgress := 'GASNOB-40-3093';
    dbms_sql.close_cursor ( v_DTL_DeleteCursor );
    xProgress := 'GASNOB-40-3094';
    dbms_sql.close_cursor ( v_DAC_DeleteCursor );
    xProgress := 'GASNOB-40-3095';
    dbms_sql.close_cursor ( v_DTX_DeleteCursor );
    xProgress := 'GASNOB-40-3095';
    dbms_sql.close_cursor ( v_ALL_DeleteCursor );

    xProgress := 'GASNOB-40-3096';
    dbms_sql.close_cursor ( v_SHP_XDeleteCursor );
    xProgress := 'GASNOB-40-3097';
    dbms_sql.close_cursor ( v_STX_XDeleteCursor );
    xProgress := 'GASNOB-40-3098';
    dbms_sql.close_cursor ( v_ORD_XDeleteCursor );
    xProgress := 'GASNOB-40-3099';
    dbms_sql.close_cursor ( v_OAC_XDeleteCursor );
    xProgress := 'GASNOB-40-3100';
    dbms_sql.close_cursor ( v_OTX_XDeleteCursor );
    xProgress := 'GASNOB-40-3101';
    dbms_sql.close_cursor ( v_DTL_XDeleteCursor );
    xProgress := 'GASNOB-40-3102';
    dbms_sql.close_cursor ( v_DAC_XDeleteCursor );
    xProgress := 'GASNOB-40-3103';
    dbms_sql.close_cursor ( v_DTX_XDeleteCursor );
    xProgress := 'GASNOB-40-3104';
    dbms_sql.close_cursor ( v_ALL_XDeleteCursor );

  EXCEPTION
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

      app_exception.raise_exception;

  END Put_Data_To_Output_Table;

END GML_GASNO;

/
