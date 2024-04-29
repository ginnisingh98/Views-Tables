--------------------------------------------------------
--  DDL for Package Body GML_GPOAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_GPOAO" as
/* $Header: GMLPAOB.pls 115.14 2002/11/08 06:39:15 gmangari ship $     */
/*=============================  GML_GPOAO  =================================*/
/*============================================================================
  PURPOSE:       Creates procedures for exporting PO Ack information
                 to a flat file, and the API called to initiate
                 the extract process.

  NOTES:         To load the package body, run the script:

                 sql> start GMLPAOB.pls

  HISTORY:       02/15/99  dgrailic  Created.
        05/17/99 dgrailic Change to use GML_ prefix for tables.
                  change table names to use full words instad of abbreviations
                  change SAC to DAC to better reflect detail charges
        08/05/99 mguthrie Added calls to ECE_FLATFILE_PVT.INIT_TABLE
        08/18/99 siwang Fixed few bugs.
        26-OCT-2002   Bug#2642152  RajaSekhar    Added NOCOPY hint

===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:      Extract_GPOAO_Outbound

  PURPOSE:  This PLSQL procedure produces an ASCII file containing
            an OPM PO Ack Outbound
            This ASCII file may then be processed by
            third-party EDI translation software to generate and send
            the EDI Outbound Ship Notice transaction.

  NOTES:    This script takes nine parameters:
               1.  The output path
               2.  The output file name
               3.  Required field, OPM organization code
               4.  Optional Order Number from
               5.  Optional Order Number to
               6.  Optional Creation Date from
               7.  Optional Creation Date to
               8.  Optional OF Customer Name
               9.  debug

            If this script exits with an error code, the output file
            should not be used.  Under an error condition, the database
            may not be in sync with the extracted data.

  HISTORY:  02/12/99 dgrailic Created.
            05/17/99 dgrailic Modified to use GML_ prefix
 ============================================================================ */
/*   Variable declarations.  Assign the Run_ID, Output Path, */
/*   and Temporary Filename to local PL/SQL variables. */

PROCEDURE Extract_GPOAO_Outbound ( errbuf              OUT NOCOPY VARCHAR2,
                                  retcode              OUT NOCOPY VARCHAR2,
                                  v_OutputPath         IN  VARCHAR2,
                                  v_Filename           IN  VARCHAR2,
                                  v_Orgn_Code          IN  VARCHAR2,
                                  v_Order_No_From      IN  VARCHAR2,
                                  v_Order_No_To        IN  VARCHAR2,
                                  v_Creation_Date_From IN  VARCHAR2,
                                  v_Creation_Date_To   IN  VARCHAR2,
                                  v_Customer_Name      IN  VARCHAR2,
                                  v_debug_mode         IN  NUMBER default 0 )
IS
   v_RunID                    NUMBER            :=  0;
   v_OutputWidth              INTEGER           :=  4000;
   v_TransactionType          VARCHAR2(120)     := 'GPOAO';
   v_CommunicationMethod      VARCHAR2(120)     := 'EDI';
   v_OutputFilePtr            utl_file.file_type;
   v_OutputLine               VARCHAR2(2000);
   v_OutputRecordCount        NUMBER;
   v_Trace                    VARCHAR2(80);
   v_industry                 VARCHAR2(240);
   v_oracle_schema            VARCHAR2(240);
   v_Org                      VARCHAR2(1);
   v_Type                     VARCHAR2(30)      := 'GPOAO';
   v_RequestID                NUMBER            := 0;

   v_ORD_Interface            VARCHAR2(80) := 'GML_GPOAO_ORDERS';
   v_OAC_Interface            VARCHAR2(80) := 'GML_GPOAO_ORDER_CHARGES';
   v_OTX_Interface            VARCHAR2(80) := 'GML_GPOAO_ORDER_TEXT';
   v_DTL_Interface            VARCHAR2(80) := 'GML_GPOAO_DETAILS';
   v_DAC_Interface            VARCHAR2(80) := 'GML_GPOAO_DETAIL_CHARGES';
   v_DTX_Interface            VARCHAR2(80) := 'GML_GPOAO_DETAIL_TEXT';
   v_ALL_Interface            VARCHAR2(80) := 'GML_GPOAO_DETAIL_ALLOCATIONS';
   xProgress                  VARCHAR2(80);

   /*  SW 07/09/99, Y2K date issue.               */
   v_Creat_Date_From           DATE         := TO_DATE(v_Creation_Date_From, 'YYYY/MM/DD HH24:MI:SS');
   v_Creat_Date_To             DATE         := TO_DATE(v_Creation_Date_To, 'YYYY/MM/DD HH24:MI:SS');
   /*  end of Y2K issue.        */

   CURSOR c_OutputSource IS
      SELECT      text
      FROM        ece_output
      WHERE       run_id = v_RunID
      ORDER BY    line_id;

   BEGIN

      ec_debug.enable_debug ( v_debug_mode );
      ec_debug.push ( 'GML_GPOAO.Extract_GPOAO_Outbound' );
      ec_debug.pl ( 3, 'v_Filename: ',v_Filename);
      ec_debug.pl ( 3, 'v_OutputPath: ',v_OutputPath );
      ec_debug.pl ( 3, 'v_Orgn_Code: ',v_Orgn_Code);
      ec_debug.pl ( 3, 'v_Order_No_From: ',v_Order_No_From);
      ec_debug.pl ( 3, 'v_Order_No_To: ',v_Order_No_To);
      ec_debug.pl ( 3, 'v_Creation_Date_From: ',v_Creation_Date_From);
      ec_debug.pl ( 3, 'v_Creation_Date_To: ',v_Creation_Date_To);
      ec_debug.pl ( 3, 'v_Customer_Name: ',v_Customer_Name);
      ec_debug.pl ( 3, 'v_debug_mode: ',v_debug_mode );


/*   Get a unique ID for the run of this script.  This ID is used to group the */
/*   records in the output table (ECE_OUTPUT) so that multiple processes may use */
/*   this table concurrently. */
    xProgress := 'GPOAO-10-1010';
    BEGIN
      SELECT   ece_output_runs_s.NEXTVAL
      INTO     v_RunID
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
    ec_debug.pl(3, 'v_RunID: ',v_RunID);

      xProgress := 'GPOAO-10-1015';
      ec_debug.pl ( 0, 'EC', 'GML_GPOAO_START', NULL );

      xProgress := 'GPOAO-10-1020';
      ec_debug.pl ( 0, 'EC', 'ECE_RUN_ID', 'RUN_ID', v_RunID );

      xProgress := 'GPOAO-10-1030';

      GML_GPOAO.populate_interface_tables(
         v_CommunicationMethod,
         v_TransactionType,
         v_Orgn_code,
         v_Order_No_From,
         v_Order_No_To,
         v_Creat_Date_From,
         v_Creat_Date_To,
         v_Customer_Name,
         v_RunID,
         v_ORD_Interface,
         v_OAC_Interface,
         v_OTX_Interface,
         v_DTL_Interface,
         v_DAC_Interface,
         v_DTX_Interface,
         v_ALL_Interface
         );


      xProgress := 'GPOAO-10-1040';

      GML_GPOAO.put_data_to_output_table(
         v_CommunicationMethod,
         v_TransactionType,
         v_Orgn_code,
         v_Order_No_From,
         v_Order_No_To,
         v_Creat_Date_From,
         v_Creat_Date_To,
         v_Customer_Name,
         v_RunID,
         v_OutputWidth,
         v_ORD_Interface,
         v_OAC_Interface,
         v_OTX_Interface,
         v_DTL_Interface,
         v_DAC_Interface,
         v_DTX_Interface,
         v_ALL_Interface
         );

    xProgress := 'GPOAO-10-1050';
    BEGIN
      SELECT   COUNT(*)
      INTO     v_OutputRecordCount
      FROM     ece_output
      WHERE    run_id = v_RunID;
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
    ec_debug.pl ( 3, 'v_OutputRecordCount: ',v_OutputRecordCount );

    xProgress := 'GPOAO-10-1060';
    IF v_OutputRecordCount > 0 THEN
       xProgress := 'GPOAO-10-1070';
       v_OutputFilePtr := utl_file.fopen(v_OutputPath,v_FileName,'W');

       xProgress := 'GPOAO-10-1080';
       OPEN c_OutputSource;
       xProgress := 'GPOAO-10-1090';
       LOOP
            xProgress := 'GPOAO-10-1100';
            FETCH c_OutputSource INTO v_OutputLine;
            ec_debug.pl ( 3, 'v_OutputLine: ',v_OutputLine );

            xProgress := 'GPOAO-10-1110';
            EXIT WHEN c_OutputSource%NOTFOUND;

            xProgress := 'GPOAO-10-1120';
            utl_file.put_line(v_OutputFilePtr,v_OutputLine);
       END LOOP;

       xProgress := 'GPOAO-10-1130';
       CLOSE c_OutputSource;

       xProgress := 'GPOAO-10-1140';
       utl_file.fclose(v_OutputFilePtr);
    END IF;

      xProgress := 'GPOAO-10-1170';
      ec_debug.pl ( 0, 'EC', 'GML_GPOAO_COMPLETE' ,NULL );

      xProgress := 'GPOAO-10-1180';
      DELETE FROM ece_output
      WHERE       run_id = v_RunID;

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

   ec_debug.pop ( 'GML_GPOAO.Extract_GPOAO_Outbound' );
   ec_debug.disable_debug;
   COMMIT;

   EXCEPTION
      WHEN utl_file.write_error THEN
       ec_debug.pl ( 0, 'EC', 'ECE_UTL_WRITE_ERROR', NULL );

       ec_debug.pl ( 0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM );

       retcode := 2;
       ec_debug.disable_debug;
       ROLLBACK;
       RAISE;

      WHEN utl_file.invalid_path THEN
       ec_debug.pl ( 0, 'EC', 'ECE_UTL_INVALID_PATH', NULL );

       ec_debug.pl ( 0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM );

       retcode := 2;
       ec_debug.disable_debug;
       ROLLBACK;
       RAISE;

      WHEN utl_file.invalid_operation THEN
       ec_debug.pl ( 0,
                     'EC',
                     'ECE_UTL_INVALID_OPERATION',
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

  END Extract_GPOAO_Outbound;

/*===========================================================================

  PROCEDURE NAME:      Populate_Interface_Tables

  PURPOSE:             This procedure initiates the export process for the
                       PO Ack.  For each Gateway
                       interface table in this transaction, a view has been
                       created to facilitate the extract process from the
                       Application tables.

===========================================================================*/

  PROCEDURE Populate_Interface_Tables ( p_CommunicationMethod      IN VARCHAR2,
                                        p_TransactionType          IN VARCHAR2,
                                        p_Orgn_Code                IN VARCHAR2,
                                        p_Order_No_From            IN VARCHAR2,
                                        p_Order_No_To              IN VARCHAR2,
                                        p_Creation_Date_From       IN DATE,
                                        p_Creation_Date_To         IN DATE,
                                        p_Customer_Name            IN VARCHAR2,
                                        p_RunID                    IN INTEGER,
                                        p_ORD_Interface            IN VARCHAR2,
                                        p_OAC_Interface            IN VARCHAR2,
                                        p_OTX_Interface            IN VARCHAR2,
                                        p_DTL_Interface            IN VARCHAR2,
                                        p_DAC_Interface            IN VARCHAR2,
                                        p_DTX_Interface            IN VARCHAR2,
                                        p_ALL_Interface            IN VARCHAR2 )

  IS

    /*   Variable definitions.  'Source_tbl_type' is a PL/SQL table typedef */
    /*   with the following structure: */
    /*   data_loc_id             NUMBER */
    /*   table_name              VARCHAR2(50)    */
    /*   column_name             VARCHAR2(50)    */
    /*   base_table_name         VARCHAR2(50)    */
    /*   base_column_name        VARCHAR2(50)    */
    /*   xref_category_id        NUMBER    */
    /*   xref_key1_source_column VARCHAR2(50) */
    /*   xref_key2_source_column VARCHAR2(50) */
    /*   xref_key3_source_column VARCHAR2(50) */
    /*   xref_key4_source_column VARCHAR2(50) */
    /*   xref_key5_source_column VARCHAR2(50) */
    /*   data_type               VARCHAR2(50)    */
    /*   data_length             NUMBER          */
    /*   int_val                 VARCHAR2(400)   */
    /*   ext_val1                VARCHAR2(80)    */
    /*   ext_val2                VARCHAR2(80)   */
    /*   ext_val3                VARCHAR2(80)    */
    /*   ext_val4                VARCHAR2(80)    */
    /*   ext_val5                VARCHAR2(80)    */

    /*  Acronyms used for variables */
    /*  ORD: Order Level */
    /*  OAC: Order Charges Level */
    /*  OTX: Order Text Level */
    /*  DTL: Line Level */
    /*  DAC: Line Charges Level */
    /*  DTX: Line Text Level */
    /*  ALL: Line Allocations Level */

    v_ORD_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_OAC_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_OTX_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_DTL_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_DAC_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_DTX_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_ALL_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_CrossRefTable    ece_flatfile_pvt.Interface_tbl_type;

    v_ORD_Cursor       INTEGER;
    v_OAC_Cursor       INTEGER;
    v_OTX_Cursor       INTEGER;
    v_DTL_Cursor       INTEGER;
    v_DAC_Cursor       INTEGER;
    v_DTX_Cursor       INTEGER;
    v_ALL_Cursor       INTEGER;

    v_ORD_Select     VARCHAR2(32000);
    v_OAC_Select     VARCHAR2(32000);
    v_OTX_Select     VARCHAR2(32000);
    v_DTL_Select     VARCHAR2(32000);
    v_DAC_Select     VARCHAR2(32000);
    v_DTX_Select     VARCHAR2(32000);
    v_ALL_Select     VARCHAR2(32000);

    v_ORD_From       VARCHAR2(32000);
    v_OAC_From       VARCHAR2(32000);
    v_OTX_From       VARCHAR2(32000);
    v_DTL_From       VARCHAR2(32000);
    v_DAC_From       VARCHAR2(32000);
    v_DTX_From       VARCHAR2(32000);
    v_ALL_From       VARCHAR2(32000);

    v_ORD_Where      VARCHAR2(32000);
    v_OAC_Where      VARCHAR2(32000);
    v_OTX_Where      VARCHAR2(32000);
    v_DTL_Where      VARCHAR2(32000);
    v_DAC_Where      VARCHAR2(32000);
    v_DTX_Where      VARCHAR2(32000);
    v_ALL_Where      VARCHAR2(32000);

    v_ORD_Count      INTEGER := 0;
    v_OAC_Count      INTEGER := 0;
    v_OTX_Count      INTEGER := 0;
    v_DTL_Count      INTEGER := 0;
    v_DAC_Count      INTEGER := 0;
    v_DTX_Count      INTEGER := 0;
    v_ALL_Count      INTEGER := 0;

    v_ORD_Key          NUMBER;
    v_OAC_Key          NUMBER;
    v_OTX_Key          NUMBER;
    v_DTL_Key          NUMBER;
    v_DAC_Key          NUMBER;
    v_DTX_Key          NUMBER;
    v_ALL_Key          NUMBER;

    v_CrossRefCount  INTEGER := 0;
    xProgress 			VARCHAR2(30);

    v_Dummy                INTEGER;
    v_Orgn_Code            VARCHAR2(4);
    v_Order_No_From        VARCHAR2(32);
    v_Order_No_To	       VARCHAR2(32);
    v_Creation_Date_From   DATE;
    v_Creation_Date_To     DATE;
    v_Customer_Name        VARCHAR2(50);
    v_TimeStampSequence    INTEGER;
    v_RunIDPosition        INTEGER;
    v_TimeStampPosition    INTEGER;
    v_TransactionRefKeyPos INTEGER;
    v_TimeStampDate        DATE;
    v_ReturnStatus         VARCHAR2(10);
    v_MessageCount         NUMBER;
    v_MessageData          VARCHAR2(255);
    v_OutputLevel          VARCHAR2(30);

    v_Order_Id_Position   INTEGER;
    v_Order_Id            INTEGER;
    v_Line_Id_Position    INTEGER;
    v_Line_Id             INTEGER;
    v_assignment_type     NUMBER;
    v_format_size         NUMBER;
    v_pad_char            VARCHAR2(1);

  BEGIN

    /*  */
    /*   Load each PL/SQL table.  The FOR loop implicitly handles all */
    /*   cursor processing. */
    /*  */
    ec_debug.push ( 'GML_GPOAO.Populate_Interface_Tables' );
    ec_debug.pl ( 3, 'p_Orgn_Code : ',p_Orgn_Code  );
    ec_debug.pl ( 3, 'p_Order_No_From : ',p_Order_No_From  );

    v_Orgn_Code := p_Orgn_Code;
    v_Order_No_From := p_Order_No_From;
    v_Order_No_To   := p_Order_No_To;
    v_Creation_Date_From := p_Creation_Date_From;
    v_Creation_Date_To   := p_Creation_Date_To;
    v_Customer_Name := p_Customer_Name;

    xProgress := 'GPOAOB-10-0010';
    ec_debug.pl ( 3, 'v_Order_No_From : ',v_Order_No_From );
    /*  Get doc numbering info to properlly format doc numbers entered  */
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
      doc_type='OPSO'
    ;

    ec_debug.pl ( 3, 'v_assignment_type: ',v_assignment_type);
    If ( v_assignment_type = 2 ) Then /*  If automatic document numbering */
      If ( p_Order_No_From is NOT NULL ) Then
        v_Order_No_From := lpad(p_Order_No_From, v_format_size, v_pad_char);
        ec_debug.pl ( 3, 'v_Order_No_From : ',v_Order_No_From );
        SELECT
           lpad(p_Order_No_From, v_format_size, v_pad_char)
        INTO
           v_Order_No_From
        FROM
           dual
        ;
      End If;
      If ( p_Order_No_To is NOT NULL ) Then
        v_Order_No_To := lpad(p_Order_No_To, v_format_size, v_pad_char);
        ec_debug.pl ( 3, 'v_Order_No_To : ',v_Order_No_To );
        SELECT
           lpad(p_Order_No_To, v_format_size, v_pad_char)
        INTO
           v_Order_No_To
        FROM
           dual
        ;
      End If;
    End If;


    ec_debug.pl ( 3, 'v_Order_No_From : ',v_Order_No_From );
    ec_debug.pl ( 3, 'v_Order_No_To : ',v_Order_No_To );

    /*  */
    /*   Initialize the Cross Reference PL/SQL table.  This table is a */
    /*   concatenation of all the interface PL/SQL tables. */
    /*  */

    /* ********************************************************* */
    /* **                   Order Level                       ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1000';
    ece_flatfile_pvt.init_table(p_TransactionType,p_ORD_Interface,NULL,FALSE,v_ORD_Table,v_CrossRefTable);

    v_CrossRefTable := v_ORD_Table;
      xProgress := 'GPOAOB-10-1020';
    v_CrossRefCount := v_ORD_Table.COUNT;


    /* ********************************************************* */
    /* **                 Order Charges Level                 ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1030';
    ece_flatfile_pvt.init_table(p_TransactionType,p_OAC_Interface,NULL,TRUE,v_OAC_Table,v_CrossRefTable);


    /* ********************************************************* */
    /* **                 Order Text Level                    ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1060';
    ece_flatfile_pvt.init_table(p_TransactionType,p_OTX_Interface,NULL,TRUE,v_OTX_Table,v_CrossRefTable);

    /* ********************************************************* */
    /* **                   Line Level                        ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1090';
    ece_flatfile_pvt.init_table(p_TransactionType,p_DTL_Interface,NULL,TRUE,v_DTL_Table,v_CrossRefTable);


    /* ********************************************************* */
    /* **               Line Charges Level                    ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1120';
    ece_flatfile_pvt.init_table(p_TransactionType,p_DAC_Interface,NULL,TRUE,v_DAC_Table,v_CrossRefTable);


    /* ********************************************************* */
    /* **                 Line Text Level                     ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1150';
    ece_flatfile_pvt.init_table(p_TransactionType,p_DTX_Interface,NULL,TRUE,v_DTX_Table,v_CrossRefTable);

    /* ********************************************************* */
    /* **              Line Allocations Level                 ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1180';
    ece_flatfile_pvt.init_table(p_TransactionType,p_ALL_Interface,NULL,TRUE,v_ALL_Table,v_CrossRefTable);

    /*  */
    /*   The 'select_clause' procedure will build the SELECT, FROM and WHERE */
    /*   clauses in preparation for the dynamic SQL call using the EDI data */
    /*   dictionary for the build.  Any necessary customizations to these */
    /*   clauses need to be made *after* the clause is built, but *before* */
    /*   the SQL call. */
    /*  */

    xProgress := 'GPOAOB-10-1210';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_ORD_Interface,
                                          v_ORD_Table,
                                          v_ORD_Select,
                                          v_ORD_From,
                                          v_ORD_Where );

    xProgress := 'GPOAOB-10-1220';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_OAC_Interface,
                                          v_OAC_Table,
                                          v_OAC_Select,
                                          v_OAC_From,
                                          v_OAC_Where );

    xProgress := 'GPOAOB-10-1230';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_OTX_Interface,
                                          v_OTX_Table,
                                          v_OTX_Select,
                                          v_OTX_From,
                                          v_OTX_Where );

    xProgress := 'GPOAOB-10-1240';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_DTL_Interface,
                                          v_DTL_Table,
                                          v_DTL_Select,
                                          v_DTL_From,
                                          v_DTL_Where );

    xProgress := 'GPOAOB-10-1250';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_DAC_Interface,
                                          v_DAC_Table,
                                          v_DAC_Select,
                                          v_DAC_From,
                                          v_DAC_Where );

    xProgress := 'GPOAOB-10-1260';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_DTX_Interface,
                                          v_DTX_Table,
                                          v_DTX_Select,
                                          v_DTX_From,
                                          v_DTX_Where );

    xProgress := 'GPOAOB-10-1270';
    ece_extract_utils_pub.select_clause ( p_TransactionType,
                                          p_CommunicationMethod,
                                          p_ALL_Interface,
                                          v_ALL_Table,
                                          v_ALL_Select,
                                          v_ALL_From,
                                          v_ALL_Where );

    /*  */
    /*   Customize the WHERE clauses to find the elegible Orders */
    /*  */

    /* ********************************************************* */
    /* **              Order Level Where Clause               ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-10-1280';
    /*  orgn code is required, so start with it */
    v_ORD_Where := v_ORD_Where || p_ORD_Interface || '_V.ORGN_CODE = :Orgn_Code';

    If v_Order_No_From is not NULL Then
      If v_Order_No_To is not NULL Then
        /*  Specify range in where clause */
        v_ORD_Where := v_ORD_Where || ' AND ' ||
          p_ORD_Interface || '_V.ORDER_NO >= :Order_No_From' || ' AND ' ||
          p_ORD_Interface || '_V.ORDER_NO <= :Order_No_To';
      Else
        /*  Specify match */
        v_ORD_Where := v_ORD_Where || ' AND ' ||
          p_ORD_Interface || '_V.ORDER_NO = :Order_No_From';
      End If;
    End If;

    If v_Creation_Date_From is not NULL Then
      If v_Creation_Date_To is not NULL Then
        /*  Specify range in where clause */
        v_ORD_Where := v_ORD_Where || ' AND ' ||
          p_ORD_Interface || '_V.CREATION_DATE >= :Creation_Date_From'
            || ' AND ' || 'trunc(' ||
          p_ORD_Interface || '_V.CREATION_DATE) <= :Creation_Date_To';
      Else
        /*  Specify match */
        v_ORD_Where := v_ORD_Where || ' AND ' || 'trunc( ' ||
          p_ORD_Interface || '_V.CREATION_DATE ) = trunc(:Creation_Date_From)';
      End If;
    End If;

    If v_Customer_Name is not NULL Then
      /*  Specify match */
      v_ORD_Where := v_ORD_Where || ' AND ' ||
          p_ORD_Interface || '_V.SHIPTO_CUST_NAME = :Customer_Name';
    End If;

    ec_debug.pl ( 3, 'v_ORD_Where: ',v_ORD_Where);

    /* ********************************************************* */
    /* **         Order Charges Level Where Clause            ** */
    /* ********************************************************* */

    v_OAC_Where := v_OAC_Where ||
          p_OAC_Interface || '_V.ORDER_ID = :Order_Id';

    /* ********************************************************* */
    /* **           Order Text Level Where Clause             ** */
    /* ********************************************************* */

    v_OTX_Where := v_OTX_Where ||
          p_OTX_Interface || '_V.ORDER_ID = :Order_Id' || ' AND ' ||
          p_OTX_Interface || '_V.LINE_NO > 0';

    /* ********************************************************* */
    /* **             Line Level Where Clause                 ** */
    /* ********************************************************* */

    v_DTL_Where := v_DTL_Where ||
          p_DTL_Interface || '_V.ORDER_ID = :Order_Id';

    /* ********************************************************* */
    /* **         Line Charges Level Where Clause             ** */
    /* ********************************************************* */

    v_DAC_Where := v_DAC_Where ||
          p_DAC_Interface || '_V.LINE_ID = :Line_Id';

    /* ********************************************************* */
    /* **           Line Text Level Where Clause              ** */
    /* ********************************************************* */

    v_DTX_Where := v_DTX_Where ||
          p_DTX_Interface || '_V.LINE_ID = :Line_Id' || ' AND ' ||
          p_DTX_Interface || '_V.LINE_NO > 0';

    /* ********************************************************* */
    /* **        Line Allocations Level Where Clause          ** */
    /* ********************************************************* */

    v_ALL_Where := v_ALL_Where ||
          p_ALL_Interface || '_V.LINE_ID = :Line_Id';

    /*  */
    /*   Build the complete SELECT statement for each level. */
    /*  */

    xProgress := 'GPOAOB-10-1400';
    v_ORD_Select        := v_ORD_Select       ||
                           v_ORD_From         ||
                           v_ORD_Where;
    ec_debug.pl (3, 'v_ORD_Select:', v_ORD_Select);


    v_OAC_Select        := v_OAC_Select       ||
                           v_OAC_From         ||
                           v_OAC_Where;

    v_OTX_Select        := v_OTX_Select       ||
                           v_OTX_From         ||
                           v_OTX_Where;

    v_DTL_Select        := v_DTL_Select       ||
                           v_DTL_From         ||
                           v_DTL_Where;
    ec_debug.pl (3, 'v_DTL_Select:', v_DTL_Select);

    v_DAC_Select        := v_DAC_Select       ||
                           v_DAC_From         ||
                           v_DAC_Where;
    ec_debug.pl (3, 'v_DAC_Select:', v_DAC_Select);

    v_DTX_Select        := v_DTX_Select       ||
                           v_DTX_From         ||
                           v_DTX_Where;

    v_ALL_Select        := v_ALL_Select       ||
                           v_ALL_From         ||
                           v_ALL_Where;

    /*  */
    /*   Open a cursor for each of the SELECT calls.  This tells the */
    /*   database to reserve space for the data returned by the SELECT */
    /*   statement. */
    /*  */

    xProgress := 'GPOAOB-10-1410';
    v_ORD_Cursor           := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-10-1420';
    v_OAC_Cursor           := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-10-1430';
    v_OTX_Cursor           := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-10-1440';
    v_DTL_Cursor           := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-10-1450';
    v_DAC_Cursor           := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-10-1460';
    v_DTX_Cursor           := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-10-1470';
    v_ALL_Cursor           := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-10-1480';

    /*  */
    /*   Parse each SELECT statement so the database understands the */
    /*   command. */
    /*  */

    xProgress := 'GPOAOB-10-1500';
    dbms_sql.parse ( v_ORD_Cursor,
                     v_ORD_Select,
                     dbms_sql.native );
    ec_debug.pl (3, 'v_ORD_Select:', v_ORD_Select);

    xProgress := 'GPOAOB-10-1510';
    dbms_sql.parse ( v_OAC_Cursor,
                     v_OAC_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-10-1520';
    dbms_sql.parse ( v_OTX_Cursor,
                     v_OTX_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-10-1530';
    dbms_sql.parse ( v_DTL_Cursor,
                     v_DTL_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-10-1540';
    dbms_sql.parse ( v_DAC_Cursor,
                     v_DAC_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-10-1550';
    dbms_sql.parse ( v_DTX_Cursor,
                     v_DTX_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-10-1560';
    dbms_sql.parse ( v_ALL_Cursor,
                     v_ALL_Select,
                     dbms_sql.native );

    /*  */
    /*   Initialize all counters. */
    /*  */

    xProgress := 'GPOAOB-10-1561';
    v_ORD_Count       := v_ORD_Table.COUNT;
    ec_debug.pl ( 3, 'v_ORD_Count: ',v_ORD_Count);

    xProgress := 'GPOAOB-10-1562';
    v_OAC_Count       := v_OAC_Table.COUNT;
    ec_debug.pl ( 3, 'v_OAC_Count: ',v_OAC_Count);

    xProgress := 'GPOAOB-10-1563';
    v_OTX_Count       := v_OTX_Table.COUNT;
    ec_debug.pl ( 3, 'v_OTX_Count: ',v_OTX_Count);

    xProgress := 'GPOAOB-10-1564';
    v_DTL_Count       := v_DTL_Table.COUNT;
    ec_debug.pl ( 3, 'v_DTL_Count: ',v_DTL_Count);

    xProgress := 'GPOAOB-10-1565';
    v_DAC_Count       := v_DAC_Table.COUNT;
    ec_debug.pl ( 3, 'v_DAC_Count: ',v_DAC_Count);

    xProgress := 'GPOAOB-10-1566';
    v_DTX_Count       := v_DTX_Table.COUNT;
    ec_debug.pl ( 3, 'v_DTX_Count: ',v_DTX_Count);

    xProgress := 'GPOAOB-10-1567';
    v_ALL_Count       := v_ALL_Table.COUNT;
    ec_debug.pl ( 3, 'v_ALL_Count: ',v_ALL_Count);

    /*  */
    /*   Define the data type for every column in each SELECT statement */
    /*   so the database understands how to populate it.  Using the */
    /*   K.I.S.S. principle, every data type will be converted to */
    /*   VARCHAR2. */
    /* - */

    xProgress := 'GPOAOB-10-1600';
    FOR v_LoopCount IN 1..v_ORD_Count
    LOOP
      xProgress := 'GPOAOB-10-1605';
      dbms_sql.define_column ( v_ORD_Cursor,
                               v_LoopCount,
                               v_ORD_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GPOAOB-10-1610';
    FOR v_LoopCount IN 1..v_OAC_Count
    LOOP
      xProgress := 'GPOAOB-10-1615';
      dbms_sql.define_column ( v_OAC_Cursor,
                               v_LoopCount,
                               v_OAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GPOAOB-10-1620';
    FOR v_LoopCount IN 1..v_OTX_Count
    LOOP
      xProgress := 'GPOAOB-10-1625';
      dbms_sql.define_column ( v_OTX_Cursor,
                               v_LoopCount,
                               v_OTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GPOAOB-10-1630';
    FOR v_LoopCount IN 1..v_DTL_Count
    LOOP
      xProgress := 'GPOAOB-10-1635';
      dbms_sql.define_column ( v_DTL_Cursor,
                               v_LoopCount,
                               v_DTL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GPOAOB-10-1640';
    FOR v_LoopCount IN 1..v_DAC_Count
    LOOP
      xProgress := 'GPOAOB-10-1645';
      dbms_sql.define_column ( v_DAC_Cursor,
                               v_LoopCount,
                               v_DAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GPOAOB-10-1650';
    FOR v_LoopCount IN 1..v_DTX_Count
    LOOP
      xProgress := 'GPOAOB-10-1655';
      dbms_sql.define_column ( v_DTX_Cursor,
                               v_LoopCount,
                               v_DTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    xProgress := 'GPOAOB-10-1660';
    FOR v_LoopCount IN 1..v_ALL_Count
    LOOP
      xProgress := 'GPOAOB-10-1665';
      dbms_sql.define_column ( v_ALL_Cursor,
                               v_LoopCount,
                               v_ALL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Bind the variables in the Order level SELECT clause. */
    /*  */

    xProgress := 'GPOAOB-10-1700';
    dbms_sql.bind_variable ( v_ORD_Cursor,
                             'ORGN_CODE',
                             v_Orgn_Code );

    If v_Order_No_From is not NULL Then
      xProgress := 'GPOAOB-10-1701';
      dbms_sql.bind_variable ( v_ORD_Cursor,
                               'Order_No_From',
                               v_Order_No_From );
      If v_Order_No_To is not NULL Then
        xProgress := 'GPOAOB-10-1702';
        dbms_sql.bind_variable ( v_ORD_Cursor,
                                 'Order_No_To',
                                 v_Order_No_To );
      End If;
    End If;

    If v_Creation_Date_From is not NULL Then
      xProgress := 'GPOAOB-10-1703';
      dbms_sql.bind_variable ( v_ORD_Cursor,
                               'Creation_Date_From',
                               v_Creation_Date_From );
      If v_Creation_Date_To is not NULL Then
        xProgress := 'GPOAOB-10-1704';
        dbms_sql.bind_variable ( v_ORD_Cursor,
                                 'Creation_Date_To',
                                 v_Creation_Date_To );
      End If;
    End If;

    If v_Customer_Name is not NULL Then
      xProgress := 'GPOAOB-10-1705';
      dbms_sql.bind_variable ( v_ORD_Cursor,
                               'Customer_Name',
                               v_Customer_Name );
    End If;

    /*  */
    /*   Execute the Order level SELECT statement. */
    /*  */

    xProgress := 'GPOAOB-10-1710';
    v_Dummy := dbms_sql.execute ( v_ORD_Cursor );

    /*  */
    /*   Begin the Order level loop. */
    /*  */

    xProgress := 'GPOAOB-10-1720';
    WHILE dbms_sql.fetch_rows ( v_ORD_Cursor ) > 0
    LOOP

      /*  */
      /*   Store the returned values in the PL/SQL table. */
      /*  */

      xProgress := 'GPOAOB-10-1730';
      FOR v_LoopCount IN 1..v_ORD_Count
      LOOP
        xProgress := 'GPOAOB-10-1740';
        dbms_sql.column_value ( v_ORD_Cursor,
                                v_LoopCount,
                                v_ORD_Table(v_LoopCount).value );
      END LOOP;

      /*  */
      /*   Find the column position of the Order_ID in the PL/SQL table */
      /*   and use the value stored in that column to bind the variables in */
      /*   the SELECT clauses of the other levels. */
      /*  */

      xProgress := 'GPOAOB-10-1750';
      ece_extract_utils_pub.find_pos ( v_ORD_Table,
                                       'ORDER_ID',
                                       v_Order_Id_Position );

      /*

        Everything is stored in the PL/SQL table as VARCHAR2, so convert
        the Order_ID value to NUMBER.

      */

      xProgress := 'GPOAOB-10-1752';
      v_Order_Id := TO_NUMBER ( v_ORD_Table(v_Order_Id_Position).value );
      ec_debug.pl( 3, 'v_Order_Id:', v_Order_Id);

      /*  */
      /*   Cross-reference all necessary columns in the PL/SQL table. */
      /*  */

      xProgress := 'GPOAOB-10-1800';
      ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                              p_Return_Status      => v_ReturnStatus,
                                                              p_Msg_Count          => v_MessageCount,
                                                              p_Msg_Data           => v_MessageData,
                                                              p_Key_Tbl            => v_CrossRefTable,
                                                              p_Tbl                => v_ORD_Table );

      /*  */
      /*   Retrieve the next sequence number for the primary key value, and */
      /*   insert this record into the Order interface table. */
      /*  */

      xProgress := 'GPOAOB-10-1810';
      SELECT GML_GPOAO_ORDERS_S.nextval
      INTO   v_ORD_Key
      FROM   sys.dual;

      xProgress := 'GPOAOB-10-1820';
      ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                        p_TransactionType,
                                                        p_CommunicationMethod,
                                                        p_ORD_Interface,
                                                        v_ORD_Table,
                                                        v_ORD_Key );

      /*  */
      /*   Call the (customizable) procedure to populate the corresponding */
      /*   extension table. */
      /*  */

      xProgress := 'GPOAOB-10-1830';
      GML_GPOAO_X.populate_ORD_ext ( v_ORD_Key,
                                         v_ORD_Table );

      /*  */
      /*   Execute the Order Charges level SELECT statement. */
      /*  */

      xProgress := 'GPOAOB-10-1754';
      dbms_sql.bind_variable ( v_OAC_Cursor,
                               'ORDER_ID',
                               v_Order_ID );

      xProgress := 'GPOAOB-10-1840';
      v_Dummy := dbms_sql.execute ( v_OAC_Cursor );

      /*  */
      /*   Begin the Order Charges level loop. */
      /*  */

      xProgress := 'GPOAOB-10-1850';
      WHILE dbms_sql.fetch_rows ( v_OAC_Cursor ) > 0
      LOOP

        /*  */
        /*   Store the returned values in the PL/SQL table. */
        /*  */

        xProgress := 'GPOAOB-10-1860';
        FOR v_LoopCount IN 1..v_OAC_Count
        LOOP
          xProgress := 'GPOAOB-10-1870';
          dbms_sql.column_value ( v_OAC_Cursor,
                                  v_LoopCount,
                                  v_OAC_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Cross-reference all necessary columns in the PL/SQL table. */
        /*  */

        xProgress := 'GPOAOB-10-1880';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_OAC_Table );

        /*  */
        /*   Since this interface table is a logical extension of the Order */
        /*   level table, use the same key value to insert this record into */
        /*   the Order Charges table. */
        /*  */

        v_OAC_Key := v_ORD_Key;

        xProgress := 'GPOAOB-10-1890';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_OAC_Interface,
                                                          v_OAC_Table,
                                                          v_OAC_Key );

        /*  */
        /*   Call the (customizable) procedure to populate the corresponding */
        /*   extension table. */
        /*  */

        xProgress := 'GPOAOB-10-1890';
        GML_GPOAO_X.populate_OAC_ext ( v_OAC_Key,
                                                  v_OAC_Table );

      END LOOP;  /*  while oac */

      /*  */
      /*   Execute the Order Text level SELECT statement. */
      /*  */

      xProgress := 'GPOAOB-10-1670';
      dbms_sql.bind_variable ( v_OTX_Cursor,
                               'ORDER_ID',
                               v_Order_ID );

      xProgress := 'GPOAOB-10-1900';
      v_Dummy := dbms_sql.execute ( v_OTX_Cursor );

      /*  */
      /*   Begin the Order Text level loop. */
      /*  */

      xProgress := 'GPOAOB-10-1910';
      WHILE dbms_sql.fetch_rows ( v_OTX_Cursor ) > 0
      LOOP

        /*  */
        /*   Store the returned values in the PL/SQL table. */
        /*  */

        xProgress := 'GPOAOB-10-1920';
        FOR v_LoopCount IN 1..v_OTX_Count
        LOOP
          xProgress := 'GPOAOB-10-1930';
          dbms_sql.column_value ( v_OTX_Cursor,
                                  v_LoopCount,
                                  v_OTX_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Cross-reference all necessary columns in the PL/SQL table. */
        /*  */

        xProgress := 'GPOAOB-10-1940';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_OTX_Table );

        /*  */
        /*   Since this interface table is a logical extension of the Order */
        /*   level table, use the same key value to insert this record into */
        /*   the Order Text table. */
        /*  */

        v_OTX_Key := v_ORD_Key;

        xProgress := 'GPOAOB-10-1950';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_OTX_Interface,
                                                          v_OTX_Table,
                                                          v_OTX_Key );

        /*  */
        /*   Call the (customizable) procedure to populate the corresponding */
        /*   extension table. */
        /*  */

        xProgress := 'GPOAOB-10-1960';
        GML_GPOAO_X.populate_OTX_ext ( v_OTX_Key,
                                                  v_OTX_Table );

      END LOOP;  /*  while otx */

      xProgress := 'GPOAOB-10-1970';
      dbms_sql.bind_variable ( v_DTL_Cursor,
                               'ORDER_ID',
                               v_Order_ID );
      /*  */
      /*   Execute the Detail level SELECT statement. */
      /*  */

      xProgress := 'GPOAOB-10-1980';
      v_Dummy := dbms_sql.execute ( v_DTL_Cursor );

      /*  */
      /*   Begin the Detail level loop. */
      /*  */

      xProgress := 'GPOAOB-10-1990';
      WHILE dbms_sql.fetch_rows ( v_DTL_Cursor ) > 0
      LOOP

        /*  */
        /*   Store the returned values in the PL/SQL table. */
        /*  */

        xProgress := 'GPOAOB-10-2000';
        FOR v_LoopCount IN 1..v_DTL_Count
        LOOP
          xProgress := 'GPOAOB-10-2010';
          dbms_sql.column_value ( v_DTL_Cursor,
                                v_LoopCount,
                                v_DTL_Table(v_LoopCount).value );
        END LOOP;

      /*  */
      /*   Find the column position of the Line_ID in the PL/SQL table */
      /*   and use the value stored in that column to bind the variables in */
      /*   the SELECT clauses of the other levels. */
      /*  */

      xProgress := 'GPOAOB-10-2020';
      ece_extract_utils_pub.find_pos ( v_DTL_Table,
                                       'Line_ID',
                                       v_Line_Id_Position );

      /*
      **
      **  Everything is stored in the PL/SQL table as VARCHAR2, so convert
      **  the Line_ID value to NUMBER.
      **
      */

      xProgress := 'GPOAOB-10-2030';
      v_Line_Id := TO_NUMBER ( v_DTL_Table(v_Line_Id_Position).value );
      ec_debug.pl( 3, 'v_Line_Id:', v_Line_Id);

      /*  */
      /*   Cross-reference all necessary columns in the PL/SQL table. */
      /*  */

      xProgress := 'GPOAOB-10-2060';
      ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                              p_Return_Status      => v_ReturnStatus,
                                                              p_Msg_Count          => v_MessageCount,
                                                              p_Msg_Data           => v_MessageData,
                                                              p_Key_Tbl            => v_CrossRefTable,
                                                              p_Tbl                => v_DTL_Table );

      /*  */
      /*   Retrieve the next sequence number for the primary key value, and */
      /*   insert this record into the Detail interface table. */
      /*  */

      xProgress := 'GPOAOB-10-2070';
      SELECT GML_GPOAO_DETAILS_S.nextval
      INTO   v_DTL_Key
      FROM   sys.dual;
      ec_debug.pl( 3, 'V_DTL_Key:', v_DTL_Key);

      xProgress := 'GPOAOB-10-2080';
      ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                        p_TransactionType,
                                                        p_CommunicationMethod,
                                                        p_DTL_Interface,
                                                        v_DTL_Table,
                                                        v_DTL_Key );

      /*  */
      /*   Call the (customizable) procedure to populate the corresponding */
      /*   extension table. */
      /*  */

      xProgress := 'GPOAOB-10-2090';
      GML_GPOAO_X.populate_DTL_ext ( v_DTL_Key,
                                         v_DTL_Table );

      /*  */
      /*   Execute the Detail Charges level SELECT statement. */
      /*  */

      xProgress := 'GPOAOB-10-2040';
      dbms_sql.bind_variable ( v_DAC_Cursor,
                               'LINE_ID',
                               v_Line_ID );

      xProgress := 'GPOAOB-10-2100';
      v_Dummy := dbms_sql.execute ( v_DAC_Cursor );

      /*  */
      /*   Begin the Detail Charges level loop. */
      /*  */
      xProgress := 'GPOAOB-10-2110';
      WHILE dbms_sql.fetch_rows ( v_DAC_Cursor ) > 0
      LOOP
        /*  */
        /*   Store the returned values in the PL/SQL table. */
        /*  */

        xProgress := 'GPOAOB-10-2120';
        FOR v_LoopCount IN 1..v_DAC_Count
        LOOP
          xProgress := 'GPOAOB-10-2130';
          dbms_sql.column_value ( v_DAC_Cursor,
                                  v_LoopCount,
                                  v_DAC_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Cross-reference all necessary columns in the PL/SQL table. */
        /*  */

        xProgress := 'GPOAOB-10-2130';
        ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                p_Return_Status      => v_ReturnStatus,
                                                                p_Msg_Count          => v_MessageCount,
                                                                p_Msg_Data           => v_MessageData,
                                                                p_Key_Tbl            => v_CrossRefTable,
                                                                p_Tbl                => v_DAC_Table );

        /*  */
        /*   Since this interface table is a logical extension of the Detail */
        /*   level table, use the same key value to insert this record into */
        /*   the Order Charges table. */
        /*  */

        v_DAC_Key := v_DTL_Key;

        xProgress := 'GPOAOB-10-2140';
        ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                          p_TransactionType,
                                                          p_CommunicationMethod,
                                                          p_DAC_Interface,
                                                          v_DAC_Table,
                                                          v_DAC_Key );

        /*  */
        /*   Call the (customizable) procedure to populate the corresponding */
        /*   extension table. */
        /*  */

        xProgress := 'GPOAOB-10-2150';
        GML_GPOAO_X.populate_DAC_ext ( v_DAC_Key, v_DAC_Table );

        END LOOP;  /*  while dac */

        /*  */
        /*   Execute the Detail Text level SELECT statement. */
        /*  */

        xProgress := 'GPOAOB-10-2160';
        dbms_sql.bind_variable ( v_DTX_Cursor,
                                 'LINE_ID',
                                 v_Line_ID );

        xProgress := 'GPOAOB-10-2170';
        v_Dummy := dbms_sql.execute ( v_DTX_Cursor );

        /*  */
        /*   Begin the Detail Text level loop. */
        /*  */

        xProgress := 'GPOAOB-10-2180';
        WHILE dbms_sql.fetch_rows ( v_DTX_Cursor ) > 0
        LOOP

          /*  */
          /*   Store the returned values in the PL/SQL table. */
          /*  */

          xProgress := 'GPOAOB-10-2190';
          FOR v_LoopCount IN 1..v_DTX_Count
          LOOP
            xProgress := 'GPOAOB-10-2200';
            dbms_sql.column_value ( v_DTX_Cursor,
                                    v_LoopCount,
                                    v_DTX_Table(v_LoopCount).value );
          END LOOP;

          /*  */
          /*   Cross-reference all necessary columns in the PL/SQL table. */
          /*  */

          xProgress := 'GPOAOB-10-2210';
          ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                  p_Return_Status      => v_ReturnStatus,
                                                                  p_Msg_Count          => v_MessageCount,
                                                                  p_Msg_Data           => v_MessageData,
                                                                  p_Key_Tbl            => v_CrossRefTable,
                                                                  p_Tbl                => v_DTX_Table );

          /*  */
          /*   Since this interface table is a logical extension of the Detail */
          /*   level table, use the same key value to insert this record into */
          /*   the Order Text table. */
          /*  */

          v_DTX_Key := v_DTL_Key;

          xProgress := 'GPOAOB-10-2220';
          ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                            p_TransactionType,
                                                            p_CommunicationMethod,
                                                            p_DTX_Interface,
                                                            v_DTX_Table,
                                                            v_DTX_Key );

          /*  */
          /*   Call the (customizable) procedure to populate the corresponding */
          /*   extension table. */
          /*  */

          xProgress := 'GPOAOB-10-2230';
          GML_GPOAO_X.populate_DTX_ext ( v_DTX_Key,  v_DTX_Table );
          END LOOP;  /*  while dtx */

        /*  */
        /*   Execute the Allocations level SELECT statement. */
        /*  */

        xProgress := 'GPOAOB-10-2160';
        dbms_sql.bind_variable ( v_ALL_Cursor,
                                 'LINE_ID',
                                 v_Line_ID );

        xProgress := 'GPOAOB-10-2170';
        v_Dummy := dbms_sql.execute ( v_ALL_Cursor );

        /*  */
        /*   Begin the Allocations level loop. */
        /*  */
        xProgress := 'GPOAOB-10-2180';
        WHILE dbms_sql.fetch_rows ( v_ALL_Cursor ) > 0
        LOOP

          /*  */
          /*   Store the returned values in the PL/SQL table. */
          /*  */

          xProgress := 'GPOAOB-10-2190';
          FOR v_LoopCount IN 1..v_ALL_Count
          LOOP
            xProgress := 'GPOAOB-10-2200';
            dbms_sql.column_value ( v_ALL_Cursor,
                                    v_LoopCount,
                                    v_ALL_Table(v_LoopCount).value );
          END LOOP;

          /*  */
          /*   Cross-reference all necessary columns in the PL/SQL table. */
          /*  */

          xProgress := 'GPOAOB-10-2210';
          ec_code_conversion_pvt.populate_plsql_tbl_with_extval ( p_API_Version_Number => 1.0,
                                                                  p_Return_Status      => v_ReturnStatus,
                                                                  p_Msg_Count          => v_MessageCount,
                                                                  p_Msg_Data           => v_MessageData,
                                                                  p_Key_Tbl            => v_CrossRefTable,
                                                                  p_Tbl                => v_ALL_Table );

          /*  */
          /*   Since this interface table is a logical extension of the Allocations */
          /*   level table, use the same key value to insert this record into */
          /*   the Order Text table. */
          /*  */

          v_ALL_Key := v_DTL_Key;

          xProgress := 'GPOAOB-10-2220';
          ece_extract_utils_pub.insert_into_interface_tbl ( p_RunID,
                                                            p_TransactionType,
                                                            p_CommunicationMethod,
                                                            p_ALL_Interface,
                                                            v_ALL_Table,
                                                            v_ALL_Key );

          /*  */
          /*   Call the (customizable) procedure to populate the corresponding */
          /*   extension table. */
          /*  */

          xProgress := 'GPOAOB-10-2230';
          GML_GPOAO_X.populate_ALL_ext ( v_ALL_Key, v_ALL_Table );

          END LOOP;  /*  while all */

      END LOOP;  /*  while dtl */
      /*  */
      ec_debug.pl(3, 'Exported order_id: ' , v_order_id);
      /*  */
      /*   update edi count in the op_ordr_hdr table */
      /*  */
      xProgress := 'GPOAOB-10-2160';
      UPDATE
        op_ordr_hdr
      SET
        edi_trans_count = edi_trans_count+1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id
      WHERE
        order_id = v_order_id;

    /*  */
    END LOOP;  /*  while ord */

    /*   Commit the interface table inserts. */
    /*  */


    xProgress := 'GASNOB-10-2300';
    ec_debug.pop ( 'GML_GPOAO.Populate_Interface_Tables' );

    COMMIT;

    /*  */
    /*   Close all open cursors. */
    /*  */

    xProgress := 'GPOAOB-10-2310';
    dbms_sql.close_cursor ( v_ORD_Cursor );
    xProgress := 'GPOAOB-10-2310';
    dbms_sql.close_cursor ( v_OAC_Cursor );
    xProgress := 'GPOAOB-10-2310';
    dbms_sql.close_cursor ( v_OTX_Cursor );
    xProgress := 'GPOAOB-10-2310';
    dbms_sql.close_cursor ( v_DTL_Cursor );
    xProgress := 'GPOAOB-10-2310';
    dbms_sql.close_cursor ( v_DAC_Cursor );
    xProgress := 'GPOAOB-10-2310';
    dbms_sql.close_cursor ( v_DTX_Cursor );
    xProgress := 'GPOAOB-10-2310';
    dbms_sql.close_cursor ( v_ALL_Cursor );

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
                                       p_Order_No_From           IN VARCHAR2,
                                       p_Order_No_To             IN VARCHAR2,
                                       p_Creation_Date_From      IN DATE,
                                       p_Creation_Date_To        IN DATE,
                                       p_Customer_Name           IN VARCHAR2,
                                       p_RunID                   IN INTEGER,
                                       p_OutputWidth             IN INTEGER,
                                       p_ORD_Interface           IN VARCHAR2,
                                       p_OAC_Interface           IN VARCHAR2,
                                       p_OTX_Interface           IN VARCHAR2,
                                       p_DTL_Interface           IN VARCHAR2,
                                       p_DAC_Interface           IN VARCHAR2,
                                       p_DTX_Interface           IN VARCHAR2,
                                       p_ALL_Interface           IN VARCHAR2 )

  IS

    /*  */
    /*   Variable definitions.  'Interface_tbl_type' is a PL/SQL table */
    /*   typedef with the following structure: */
    /*  */
    /*   table_name              VARCHAR2(50) */
    /*   column_name             VARCHAR2(50) */
    /*   record_num              NUMBER */
    /*   position                NUMBER */
    /*   data_type               VARCHAR2(50) */
    /*   data_length             NUMBER */
    /*   value                   VARCHAR2(400) */
    /*   layout_code             VARCHAR2(2) */
    /*   record_qualifier        VARCHAR2(3) */
    /*  */
    xProgress			  VARCHAR2(30);


    /*  Acronyms used for variables */
    /*  ORD: Order Level */
    /*  OAC: Order Charges Level */
    /*  OTX: Order Text Level */
    /*  DTL: Line Level */
    /*  DAC: Line Charges Level */
    /*  DTX: Line Text Level */
    /*  ALL: Line Allocations Level */

    v_ORD_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_OAC_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_OTX_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_DTL_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_DAC_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_DTX_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_ALL_Table        ece_flatfile_pvt.Interface_tbl_type;
    v_CrossRefTable    ece_flatfile_pvt.Interface_tbl_type;

    v_ORD_Select_Cursor       INTEGER;
    v_OAC_Select_Cursor       INTEGER;
    v_OTX_Select_Cursor       INTEGER;
    v_DTL_Select_Cursor       INTEGER;
    v_DAC_Select_Cursor       INTEGER;
    v_DTX_Select_Cursor       INTEGER;
    v_ALL_Select_Cursor       INTEGER;

    v_ORD_Delete_Cursor       INTEGER;
    v_OAC_Delete_Cursor       INTEGER;
    v_OTX_Delete_Cursor       INTEGER;
    v_DTL_Delete_Cursor       INTEGER;
    v_DAC_Delete_Cursor       INTEGER;
    v_DTX_Delete_Cursor       INTEGER;
    v_ALL_Delete_Cursor       INTEGER;

    v_ORD_Delete_XCursor       INTEGER;
    v_OAC_Delete_XCursor       INTEGER;
    v_OTX_Delete_XCursor       INTEGER;
    v_DTL_Delete_XCursor       INTEGER;
    v_DAC_Delete_XCursor       INTEGER;
    v_DTX_Delete_XCursor       INTEGER;
    v_ALL_Delete_XCursor       INTEGER;

    v_ORD_Select     VARCHAR2(32000);
    v_OAC_Select     VARCHAR2(32000);
    v_OTX_Select     VARCHAR2(32000);
    v_DTL_Select     VARCHAR2(32000);
    v_DAC_Select     VARCHAR2(32000);
    v_DTX_Select     VARCHAR2(32000);
    v_ALL_Select     VARCHAR2(32000);

    v_ORD_From       VARCHAR2(32000);
    v_OAC_From       VARCHAR2(32000);
    v_OTX_From       VARCHAR2(32000);
    v_DTL_From       VARCHAR2(32000);
    v_DAC_From       VARCHAR2(32000);
    v_DTX_From       VARCHAR2(32000);
    v_ALL_From       VARCHAR2(32000);

    v_ORD_Where      VARCHAR2(32000);
    v_OAC_Where      VARCHAR2(32000);
    v_OTX_Where      VARCHAR2(32000);
    v_DTL_Where      VARCHAR2(32000);
    v_DAC_Where      VARCHAR2(32000);
    v_DTX_Where      VARCHAR2(32000);
    v_ALL_Where      VARCHAR2(32000);

    v_ORD_Delete     VARCHAR2(32000);
    v_OAC_Delete     VARCHAR2(32000);
    v_OTX_Delete     VARCHAR2(32000);
    v_DTL_Delete     VARCHAR2(32000);
    v_DAC_Delete     VARCHAR2(32000);
    v_DTX_Delete     VARCHAR2(32000);
    v_ALL_Delete     VARCHAR2(32000);

    v_ORD_XDelete    VARCHAR2(32000);
    v_OAC_XDelete    VARCHAR2(32000);
    v_OTX_XDelete    VARCHAR2(32000);
    v_DTL_XDelete    VARCHAR2(32000);
    v_DAC_XDelete    VARCHAR2(32000);
    v_DTX_XDelete    VARCHAR2(32000);
    v_ALL_XDelete    VARCHAR2(32000);

    v_ORD_Count      INTEGER := 0;
    v_OAC_Count      INTEGER := 0;
    v_OTX_Count      INTEGER := 0;
    v_DTL_Count      INTEGER := 0;
    v_DAC_Count      INTEGER := 0;
    v_DTX_Count      INTEGER := 0;
    v_ALL_Count      INTEGER := 0;

    v_ORD_RowID      ROWID;
    v_OAC_RowID      ROWID;
    v_OTX_RowID      ROWID;
    v_DTL_RowID      ROWID;
    v_DAC_RowID      ROWID;
    v_DTX_RowID      ROWID;
    v_ALL_RowID      ROWID;

    v_ORD_XRowID      ROWID;
    v_OAC_XRowID      ROWID;
    v_OTX_XRowID      ROWID;
    v_DTL_XRowID      ROWID;
    v_DAC_XRowID      ROWID;
    v_DTX_XRowID      ROWID;
    v_ALL_XRowID      ROWID;

    v_ORD_CommonKeyName VARCHAR2(40);
    v_OAC_CommonKeyName VARCHAR2(40);
    v_OTX_CommonKeyName VARCHAR2(40);
    v_DTL_CommonKeyName VARCHAR2(40);
    v_DAC_CommonKeyName VARCHAR2(40);
    v_DTX_CommonKeyName VARCHAR2(40);
    v_ALL_CommonKeyName VARCHAR2(40);

    v_KeyPad                      VARCHAR2(22) := RPAD(' ', 22);
    v_FileCommonKey               VARCHAR2(255);
    v_TranslatorCode              VARCHAR2(30);
    v_RecordCommonKey0            VARCHAR2(25);
    v_RecordCommonKey1            VARCHAR2(22);
    v_RecordCommonKey2            VARCHAR2(22);
    v_RecordCommonKey3            VARCHAR2(22);

    v_ORD_XInterface          VARCHAR2(50);
    v_OAC_XInterface          VARCHAR2(50);
    v_OTX_XInterface          VARCHAR2(50);
    v_DTL_XInterface          VARCHAR2(50);
    v_DAC_XInterface          VARCHAR2(50);
    v_DTX_XInterface          VARCHAR2(50);
    v_ALL_XInterface          VARCHAR2(50);

    v_ORD_CKNamePosition          INTEGER;
    v_OAC_CKNamePosition          INTEGER;
    v_OTX_CKNamePosition          INTEGER;
    v_DTL_CKNamePosition          INTEGER;
    v_DAC_CKNamePosition          INTEGER;
    v_DTX_CKNamePosition          INTEGER;
    v_ALL_CKNamePosition          INTEGER;

    v_Dummy                       INTEGER;
    v_Order_ID                    INTEGER;
    v_Order_Id_Position           INTEGER;
    v_Line_ID                     INTEGER;
    v_Line_Id_Position            INTEGER;

    v_TranslatorCodePosition      INTEGER;
    v_DeliveryCKNamePosition      INTEGER;
    v_AllowChgCKNamePosition      INTEGER;
    v_ContainerCKNamePosition     INTEGER;
    v_OrderCKNamePosition         INTEGER;
    v_ItemCKNamePosition          INTEGER;
    v_ItemDetailCKNamePosition    INTEGER;
    v_DeliveryIDPosition          INTEGER;
    v_TransactionRecordIDPosition INTEGER;
    v_OrderHeaderIDPosition       INTEGER;
    v_ItemIDPosition              INTEGER;
    v_PickingLineIDPosition       INTEGER;
    v_ContainerIDPosition         INTEGER;
    v_SequenceNumberPosition      INTEGER;

    v_DeliveryID                  INTEGER;
    v_TransactionRecordID         INTEGER;
    v_ContainerID                 INTEGER;
    v_OrderHeaderID               INTEGER;
    v_ItemID                      INTEGER;
    v_PickingLineID               INTEGER;
    v_SequenceNumber              INTEGER;

  BEGIN

    /*
    **
    **  Debug statements for the parameter values.
    **
    */

    ec_debug.push ( 'GML_GPOAO.Put_Data_To_Output_Table' );
    ec_debug.pl ( 3, 'p_CommunicationMethod: ', p_CommunicationMethod );
    ec_debug.pl ( 3, 'p_TransactionType: ', p_TransactionType );
    ec_debug.pl ( 3, 'p_Orgn_Code: ', p_Orgn_Code );
    ec_debug.pl ( 3, 'p_Order_No_From: ', p_Order_No_From );
    ec_debug.pl ( 3, 'p_Order_No_To: ', p_Order_No_To );
    ec_debug.pl ( 3, 'p_Creation_Date_From: ', p_Creation_Date_From );
    ec_debug.pl ( 3, 'p_Creation_Date_To: ', p_Creation_Date_To );
    ec_debug.pl ( 3, 'p_Customer_Name: ', p_Customer_Name );
    ec_debug.pl ( 3, 'p_RunID: ', p_RunID );
    ec_debug.pl ( 3, 'p_OutputWidth: ', p_OutputWidth );
    ec_debug.pl ( 3, 'p_ORD_Interface: ', p_ORD_Interface );
    ec_debug.pl ( 3, 'p_OAC_Interface: ', p_OAC_Interface );
    ec_debug.pl ( 3, 'p_OTX_Interface: ', p_OTX_Interface );
    ec_debug.pl ( 3, 'p_DTL_Interface: ', p_DTL_Interface );
    ec_debug.pl ( 3, 'p_DAC_Interface: ', p_DAC_Interface );
    ec_debug.pl ( 3, 'p_DTX_Interface: ', p_DTX_Interface );
    ec_debug.pl ( 3, 'p_ALL_Interface: ', p_ALL_Interface );

    /*  */
    /*  */
    /*   The 'select_clause' procedure will build the SELECT, FROM and WHERE */
    /*   clauses in preparation for the dynamic SQL call using the EDI data */
    /*   dictionary for the build.  Any necessary customizations to these */
    /*   the SQL call. */
    /*  */

    xProgress := 'GPOAOB-40-1010';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_ORD_Interface,
                                     v_ORD_XInterface,
                                     v_ORD_Table,
                                     v_ORD_CommonKeyName,
                                     v_ORD_Select,
                                     v_ORD_From,
                                     v_ORD_Where );

    xProgress := 'GPOAOB-40-1020';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_OAC_Interface,
                                     v_OAC_XInterface,
                                     v_OAC_Table,
                                     v_OAC_CommonKeyName,
                                     v_OAC_Select,
                                     v_OAC_From,
                                     v_OAC_Where );

    xProgress := 'GPOAOB-40-1030';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_OTX_Interface,
                                     v_OTX_XInterface,
                                     v_OTX_Table,
                                     v_OTX_CommonKeyName,
                                     v_OTX_Select,
                                     v_OTX_From,
                                     v_OTX_Where );

    xProgress := 'GPOAOB-40-1040';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_DTL_Interface,
                                     v_DTL_XInterface,
                                     v_DTL_Table,
                                     v_DTL_CommonKeyName,
                                     v_DTL_Select,
                                     v_DTL_From,
                                     v_DTL_Where );

    xProgress := 'GPOAOB-40-1050';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_DAC_Interface,
                                     v_DAC_XInterface,
                                     v_DAC_Table,
                                     v_DAC_CommonKeyName,
                                     v_DAC_Select,
                                     v_DAC_From,
                                     v_DAC_Where );

    xProgress := 'GPOAOB-40-1060';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_DTX_Interface,
                                     v_DTX_XInterface,
                                     v_DTX_Table,
                                     v_DTX_CommonKeyName,
                                     v_DTX_Select,
                                     v_DTX_From,
                                     v_DTX_Where );

    xProgress := 'GPOAOB-40-1070';
    ece_flatfile_pvt.select_clause ( p_TransactionType,
                                     p_CommunicationMethod,
                                     p_ALL_Interface,
                                     v_ALL_XInterface,
                                     v_ALL_Table,
                                     v_ALL_CommonKeyName,
                                     v_ALL_Select,
                                     v_ALL_From,
                                     v_ALL_Where );

    /*  */
    /*   Customize the SELECT clauses to include the ROWID.  Records */
    /*   will be deleted from the interface tables using these values. */
    /*   Also add any columns that do not appear in the flatfile, but */
    /*   will be needed for internal processing (i.e. ID values). */
    /*  */

    xProgress := 'GPOAOB-40-1080';
    v_ORD_Select := v_ORD_Select                 ||
                        ', '                     ||
                        p_ORD_Interface          ||
                        '.ROWID, '               ||
                        v_ORD_XInterface         ||
                        '.ROWID, '               ||
                        p_ORD_Interface          ||
                        '.TRANSACTION_RECORD_ID';

    v_OAC_Select := v_OAC_Select                 ||
                        ', '                     ||
                        p_OAC_Interface          ||
                        '.ROWID, '               ||
                        v_OAC_XInterface         ||
                        '.ROWID, '               ||
                        p_OAC_Interface          ||
                        '.TRANSACTION_RECORD_ID';

    v_OTX_Select := v_OTX_Select                 ||
                        ', '                     ||
                        p_OTX_Interface          ||
                        '.ROWID, '               ||
                        v_OTX_XInterface         ||
                        '.ROWID, '               ||
                        p_OTX_Interface          ||
                        '.TRANSACTION_RECORD_ID';

    v_DTL_Select := v_DTL_Select                 ||
                        ', '                     ||
                        p_DTL_Interface          ||
                        '.ROWID, '               ||
                        v_DTL_XInterface         ||
                        '.ROWID, '               ||
                        p_DTL_Interface          ||
                        '.TRANSACTION_RECORD_ID';

   v_DAC_Select := v_DAC_Select                 ||
                        ', '                     ||
                        p_DAC_Interface          ||
                        '.ROWID, '               ||
                        v_DAC_XInterface         ||
                        '.ROWID, '               ||
                        p_DAC_Interface          ||
                        '.TRANSACTION_RECORD_ID';

    v_DTX_Select := v_DTX_Select                 ||
                        ', '                     ||
                        p_DTX_Interface          ||
                        '.ROWID, '               ||
                        v_DTX_XInterface         ||
                        '.ROWID, '               ||
                        p_DTX_Interface          ||
                        '.TRANSACTION_RECORD_ID';

    v_ALL_Select := v_ALL_Select                 ||
                        ', '                     ||
                        p_ALL_Interface          ||
                        '.ROWID, '               ||
                        v_ALL_XInterface         ||
                        '.ROWID, '               ||
                        p_ALL_Interface          ||
                        '.TRANSACTION_RECORD_ID';

    /*  */
    /*   Customize the WHERE clauses to: */
    /*  */

    xProgress := 'GPOAOB-40-1090';
    v_ORD_Where := v_ORD_Where  ||              ' AND ' ||
      p_ORD_Interface || '.RUN_ID = :Run_ID' ||
      ' ORDER BY ' ||
      p_ORD_Interface || '.ORDER_NO';


    xProgress := 'GPOAOB-40-1091';
    v_OAC_Where := v_OAC_Where  ||              ' AND ' ||
      p_OAC_Interface || '.RUN_ID = :Run_ID' || ' AND ' ||
      p_OAC_Interface || '.ORDER_ID = :ORDER_ID' ||
      ' ORDER BY ' ||
      p_OAC_Interface || '.SAC_CODE_INT';

    xProgress := 'GPOAOB-40-1091';
    v_OTX_Where := v_OTX_Where  ||              ' AND ' ||
      p_OTX_Interface || '.RUN_ID = :Run_ID' || ' AND ' ||
      p_OTX_Interface || '.ORDER_ID = :ORDER_ID' ||
      ' ORDER BY ' ||
      p_OTX_Interface || '.LINE_NO';

    xProgress := 'GPOAOB-40-1095';
    v_DTL_Where := v_DTL_Where  ||  ' AND '  ||
      p_DTL_Interface || '.RUN_ID = :Run_ID' || ' AND ' ||
      p_DTL_Interface || '.ORDER_ID = :ORDER_ID' ||
      ' ORDER BY '    ||
      p_DTL_Interface || '.SO_LINE_NO';

    xProgress := 'GPOAOB-40-1096';
    v_DAC_Where := v_DAC_Where  ||  ' AND '      ||
      p_DAC_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_DAC_Interface || '.LINE_ID = :LINE_ID'   ||
      ' ORDER BY '    ||
      p_DAC_Interface || '.SAC_CODE_INT';

    xProgress := 'GPOAOB-40-1097';
    v_DTX_Where := v_DTX_Where  ||  ' AND ' ||
      p_DTX_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_DTX_Interface || '.LINE_ID = :LINE_ID'   ||
      ' ORDER BY '    ||
      p_DTX_Interface || '.LINE_NO';

    xProgress := 'GPOAOB-40-1098';
    v_ALL_Where := v_ALL_Where  ||  ' AND ' ||
      p_ALL_Interface || '.RUN_ID = :Run_ID'     ||
      ' AND '         ||
      p_ALL_Interface || '.LINE_ID = :LINE_ID' ||
      ' ORDER BY '    ||
      p_ALL_Interface || '.LOT_NO';

    /*  */
    /*   Build the complete SELECT statement for each level. */
    /*  */

    xProgress := 'GPOAOB-40-1100';
    v_ORD_Select := v_ORD_Select                 ||
                        v_ORD_From               ||
                        v_ORD_Where              ||
                        ' FOR UPDATE';

    v_OAC_Select := v_OAC_Select                 ||
                        v_OAC_From               ||
                        v_OAC_Where              ||
                        ' FOR UPDATE';

    v_OTX_Select := v_OTX_Select                 ||
                        v_OTX_From               ||
                        v_OTX_Where              ||
                        ' FOR UPDATE';

    v_DTL_Select := v_DTL_Select                 ||
                        v_DTL_From               ||
                        v_DTL_Where              ||
                        ' FOR UPDATE';

    v_DAC_Select := v_DAC_Select                 ||
                        v_DAC_From               ||
                        v_DAC_Where              ||
                        ' FOR UPDATE';

    v_DTX_Select := v_DTX_Select                 ||
                        v_DTX_From               ||
                        v_DTX_Where              ||
                        ' FOR UPDATE';

    v_ALL_Select := v_ALL_Select                 ||
                        v_ALL_From               ||
                        v_ALL_Where              ||
                        ' FOR UPDATE';

    /*  */
    /*   Build the DELETE clauses for each interface and extension table. */
    /*  */

    xProgress := 'GPOAOB-40-1110';
    v_ORD_Delete :=  'DELETE FROM '                        ||
                         p_ORD_Interface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_OAC_Delete :=  'DELETE FROM '                        ||
                         p_OAC_Interface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_OTX_Delete :=  'DELETE FROM '                        ||
                         p_OTX_Interface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_DTL_Delete :=  'DELETE FROM '                        ||
                         p_DTL_Interface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_DAC_Delete :=  'DELETE FROM '                        ||
                         p_DAC_Interface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_DTX_Delete :=  'DELETE FROM '                        ||
                         p_DTX_Interface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_ALL_Delete :=  'DELETE FROM '                        ||
                         p_ALL_Interface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_ORD_XDelete :=  'DELETE FROM '                        ||
                         v_ORD_XInterface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_OAC_XDelete :=  'DELETE FROM '                        ||
                         v_OAC_XInterface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_OTX_XDelete :=  'DELETE FROM '                        ||
                         v_OTX_XInterface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_DTL_XDelete :=  'DELETE FROM '                        ||
                         v_DTL_XInterface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_DAC_XDelete :=  'DELETE FROM '                        ||
                         v_DAC_XInterface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_DTX_XDelete :=  'DELETE FROM '                        ||
                         v_DTX_XInterface                   ||
                         ' WHERE ROWID = :Row_ID';

    v_ALL_XDelete :=  'DELETE FROM '                        ||
                         v_ALL_XInterface                   ||
                         ' WHERE ROWID = :Row_ID';

    /*  */
    /*   Open a cursor for each SELECT and DELETE call.  This tells */
    /*   the database to reserve space for the data returned by the */
    /*   SELECT and DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-1120';
    v_ORD_Select_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1122';
    v_OAC_Select_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1124';
    v_OTX_Select_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1126';
    v_DTL_Select_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1128';
    v_DAC_Select_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1130';
    v_DTX_Select_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1132';
    v_ALL_Select_Cursor        := dbms_sql.open_cursor;

    xProgress := 'GPOAOB-40-1134';
    v_ORD_Delete_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1136';
    v_OAC_Delete_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1138';
    v_OTX_Delete_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1140';
    v_DTL_Delete_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1142';
    v_DAC_Delete_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1144';
    v_DTX_Delete_Cursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1146';
    v_ALL_Delete_Cursor        := dbms_sql.open_cursor;

    xProgress := 'GPOAOB-40-1148';
    v_ORD_Delete_XCursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1150';
    v_OAC_Delete_XCursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1152';
    v_OTX_Delete_XCursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1154';
    v_DTL_Delete_XCursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1156';
    v_DAC_Delete_XCursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1158';
    v_DTX_Delete_XCursor        := dbms_sql.open_cursor;
    xProgress := 'GPOAOB-40-1160';
    v_ALL_Delete_XCursor        := dbms_sql.open_cursor;

    /*  */
    /*   Parse each SELECT and DELETE statement so the database understands */
    /*   the command. */
    /*  */

    xProgress := 'GPOAOB-40-1170';
    dbms_sql.parse ( v_ORD_Select_Cursor,
                     v_ORD_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1171';
    dbms_sql.parse ( v_OAC_Select_Cursor,
                     v_OAC_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1172';
    dbms_sql.parse ( v_OTX_Select_Cursor,
                     v_OTX_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1173';
    dbms_sql.parse ( v_DTL_Select_Cursor,
                     v_DTL_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1174';
    dbms_sql.parse ( v_DAC_Select_Cursor,
                     v_DAC_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1175';
    dbms_sql.parse ( v_DTX_Select_Cursor,
                     v_DTX_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1176';
    dbms_sql.parse ( v_ALL_Select_Cursor,
                     v_ALL_Select,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1180';
    dbms_sql.parse ( v_ORD_Delete_Cursor,
                     v_ORD_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1181';
    dbms_sql.parse ( v_OAC_Delete_Cursor,
                     v_OAC_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1182';
    dbms_sql.parse ( v_OTX_Delete_Cursor,
                     v_OTX_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1183';
    dbms_sql.parse ( v_DTL_Delete_Cursor,
                     v_DTL_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1184';
    dbms_sql.parse ( v_DAC_Delete_Cursor,
                     v_DAC_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1185';
    dbms_sql.parse ( v_DTX_Delete_Cursor,
                     v_DTX_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1186';
    dbms_sql.parse ( v_ALL_Delete_Cursor,
                     v_ALL_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1190';
    dbms_sql.parse ( v_ORD_Delete_XCursor,
                     v_ORD_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1191';
    dbms_sql.parse ( v_OAC_Delete_XCursor,
                     v_OAC_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1192';
    dbms_sql.parse ( v_OTX_Delete_XCursor,
                     v_OTX_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1193';
    dbms_sql.parse ( v_DTL_Delete_XCursor,
                     v_DTL_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1194';
    dbms_sql.parse ( v_DAC_Delete_XCursor,
                     v_DAC_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1195';
    dbms_sql.parse ( v_DTX_Delete_XCursor,
                     v_DTX_Delete,
                     dbms_sql.native );

    xProgress := 'GPOAOB-40-1196';
    dbms_sql.parse ( v_ALL_Delete_XCursor,
                     v_ALL_Delete,
                     dbms_sql.native );

    /*  */
    /*   Initialize all counters. */
    /*  */

    xProgress := 'GPOAOB-40-1400';
    v_ORD_Count       := v_ORD_Table.COUNT;
    xProgress := 'GPOAOB-40-1402';
    v_OAC_Count       := v_OAC_Table.COUNT;
    xProgress := 'GPOAOB-40-1404';
    v_OTX_Count       := v_OTX_Table.COUNT;
    xProgress := 'GPOAOB-40-1406';
    v_DTL_Count       := v_DTL_Table.COUNT;
    xProgress := 'GPOAOB-40-1408';
    v_DAC_Count       := v_DAC_Table.COUNT;
    xProgress := 'GPOAOB-40-1410';
    v_DTX_Count       := v_DTX_Table.COUNT;
    xProgress := 'GPOAOB-40-1412';
    v_ALL_Count       := v_ALL_Table.COUNT;

    /*  */
    /*   Define the data type for every column in each SELECT statement */
    /*   so the database understands how to populate it.  Using the */
    /*   K.I.S.S. principle, every data type will be converted to */
    /*   VARCHAR2. */
    /*  */

    xProgress := 'GPOAOB-40-1500';
    FOR v_LoopCount IN 1..v_ORD_Count
    LOOP
      xProgress := 'GPOAOB-40-1510';
      dbms_sql.define_column ( v_ORD_Select_Cursor,
                               v_LoopCount,
                               v_ORD_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Define the ROWIDs for the DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-1520';
    dbms_sql.define_column_rowid ( v_ORD_Select_Cursor,
                                   v_ORD_Count + 1,
                                   v_ORD_RowID );

    xProgress := 'GPOAOB-40-1530';
    dbms_sql.define_column_rowid ( v_ORD_Select_Cursor,
                                   v_ORD_Count + 2,
                                   v_ORD_XRowID );

    /*  */
    /*   Define the internal ID columns. */
    /*  */
    xProgress := 'GPOAOB-40-1550';
    dbms_sql.define_column ( v_ORD_Select_Cursor,
                             v_ORD_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GPOAOB-40-1600';
    FOR v_LoopCount IN 1..v_OAC_Count
    LOOP
      xProgress := 'GPOAOB-40-1610';
      dbms_sql.define_column ( v_OAC_Select_Cursor,
                               v_LoopCount,
                               v_OAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Define the ROWIDs for the DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-1620';
    dbms_sql.define_column_rowid ( v_OAC_Select_Cursor,
                                   v_OAC_Count + 1,
                                   v_OAC_RowID );

    xProgress := 'GPOAOB-40-1630';
    dbms_sql.define_column_rowid ( v_OAC_Select_Cursor,
                                   v_OAC_Count + 2,
                                   v_OAC_XRowID );

    /*  */
    /*   Define the internal ID columns. */
    /*  */

    xProgress := 'GPOAOB-40-1640';
    dbms_sql.define_column ( v_OAC_Select_Cursor,
                             v_OAC_Count + 3,
                             v_TransactionRecordID );

    /*  */
    xProgress := 'GPOAOB-40-1700';
    FOR v_LoopCount IN 1..v_OTX_Count
    LOOP
      xProgress := 'GPOAOB-40-1710';
      dbms_sql.define_column ( v_OTX_Select_Cursor,
                               v_LoopCount,
                               v_OTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Define the ROWIDs for the DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-1720';
    dbms_sql.define_column_rowid ( v_OTX_Select_Cursor,
                                   v_OTX_Count + 1,
                                   v_OTX_RowID );

    xProgress := 'GPOAOB-40-1730';
    dbms_sql.define_column_rowid ( v_OTX_Select_Cursor,
                                   v_OTX_Count + 2,
                                   v_OTX_XRowID );

    /*  */
    /*   Define the internal ID columns. */
    /*  */

    xProgress := 'GPOAOB-40-1750';
    dbms_sql.define_column ( v_OTX_Select_Cursor,
                             v_OTX_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GPOAOB-40-1800';
    FOR v_LoopCount IN 1..v_DTL_Count
    LOOP
      xProgress := 'GPOAOB-40-1810';
      dbms_sql.define_column ( v_DTL_Select_Cursor,
                               v_LoopCount,
                               v_DTL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Define the ROWIDs for the DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-1820';
    dbms_sql.define_column_rowid ( v_DTL_Select_Cursor,
                                   v_DTL_Count + 1,
                                   v_DTL_RowID );

    xProgress := 'GPOAOB-40-1830';
    dbms_sql.define_column_rowid ( v_DTL_Select_Cursor,
                                   v_DTL_Count + 2,
                                   v_DTL_XRowID );

    /*  */
    /*   Define the internal ID columns. */
    /*  */

    xProgress := 'GPOAOB-40-1850';
    dbms_sql.define_column ( v_DTL_Select_Cursor,
                             v_DTL_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GPOAOB-40-1900';
    FOR v_LoopCount IN 1..v_DAC_Count
    LOOP
      xProgress := 'GPOAOB-40-1910';
      dbms_sql.define_column ( v_DAC_Select_Cursor,
                               v_LoopCount,
                               v_DAC_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Define the ROWIDs for the DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-1920';
    dbms_sql.define_column_rowid ( v_DAC_Select_Cursor,
                                   v_DAC_Count + 1,
                                   v_DAC_RowID );

    xProgress := 'GPOAOB-40-1930';
    dbms_sql.define_column_rowid ( v_DAC_Select_Cursor,
                                   v_DAC_Count + 2,
                                   v_DAC_XRowID );

    /*  */
    /*   Define the internal ID columns. */
    /*  */

    xProgress := 'GPOAOB-40-1950';
    dbms_sql.define_column ( v_DAC_Select_Cursor,
                             v_DAC_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GPOAOB-40-2000';
    FOR v_LoopCount IN 1..v_DTX_Count
    LOOP
      xProgress := 'GPOAOB-40-2010';
      dbms_sql.define_column ( v_DTX_Select_Cursor,
                               v_LoopCount,
                               v_DTX_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Define the ROWIDs for the DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-2020';
    dbms_sql.define_column_rowid ( v_DTX_Select_Cursor,
                                   v_DTX_Count + 1,
                                   v_DTX_RowID );

    xProgress := 'GPOAOB-40-2030';
    dbms_sql.define_column_rowid ( v_DTX_Select_Cursor,
                                   v_DTX_Count + 2,
                                   v_DTX_XRowID );

    /*  */
    /*   Define the internal ID columns. */
    /*  */

    xProgress := 'GPOAOB-40-2050';
    dbms_sql.define_column ( v_DTX_Select_Cursor,
                             v_DTX_Count + 3,
                             v_TransactionRecordID );

    xProgress := 'GPOAOB-40-2100';
    FOR v_LoopCount IN 1..v_ALL_Count
    LOOP
      xProgress := 'GPOAOB-40-2110';
      dbms_sql.define_column ( v_ALL_Select_Cursor,
                               v_LoopCount,
                               v_ALL_Select,
                               ece_extract_utils_pub.G_MaxColWidth );
    END LOOP;

    /*  */
    /*   Define the ROWIDs for the DELETE statements. */
    /*  */

    xProgress := 'GPOAOB-40-2120';
    dbms_sql.define_column_rowid ( v_ALL_Select_Cursor,
                                   v_ALL_Count + 1,
                                   v_ALL_RowID );

    xProgress := 'GPOAOB-40-2210';
    dbms_sql.define_column_rowid ( v_ALL_Select_Cursor,
                                   v_ALL_Count + 2,
                                   v_ALL_XRowID );

    /*  */
    /*   Define the internal ID columns. */
    /*  */

    xProgress := 'GPOAOB-40-2150';
    dbms_sql.define_column ( v_ALL_Select_Cursor,
                             v_ALL_Count + 3,
                             v_TransactionRecordID );

    /*  */
    /*  Bind columns needed for order select */
    /*   */

    xProgress := 'GPOAOB-40-2170';
    dbms_sql.bind_variable ( v_ORD_Select_Cursor,
                             'RUN_ID',
                             p_RunID );

    /*  */
    /*   Execute the Order level SELECT statement. */
    /*  */

    xProgress := 'GPOAOB-40-2200';
    v_Dummy := dbms_sql.execute ( v_ORD_Select_Cursor );

    /* ********************************************************* */
    /* **                Order Level Loop                     ** */
    /* ********************************************************* */

    xProgress := 'GPOAOB-40-2210';
    WHILE dbms_sql.fetch_rows ( v_ORD_Select_Cursor ) > 0
    LOOP

      /*  */
      /*   Store the returned values in the PL/SQL table. */
      /*  */

      xProgress := 'GPOAOB-40-2220';
      FOR v_LoopCount IN 1..v_ORD_Count
      LOOP
        xProgress := 'GPOAOB-40-2230';
        dbms_sql.column_value ( v_ORD_Select_Cursor,
                                v_LoopCount,
                                v_ORD_Table(v_LoopCount).value );
      END LOOP;

      /*  */
      /*   Store the ROWIDs. */
      /*  */

      xProgress := 'GPOAOB-40-2240';
      dbms_sql.column_value ( v_ORD_Select_Cursor,
                              v_ORD_Count + 1,
                              v_ORD_RowID );

      xProgress := 'GPOAOB-40-2250';
      dbms_sql.column_value ( v_ORD_Select_Cursor,
                              v_ORD_Count + 2,
                              v_ORD_XRowID );

      /*  */
      /*   Locate the necessary data elements and build the common key */
      /*   record for this level.  Common key elements are used for each */
      /*   record, so save the values. */
      /*  */
      xProgress := 'GPOAOB-40-2260';
      ece_flatfile_pvt.find_pos ( v_ORD_Table,
                                  /*  ece_flatfile_pvt.G_Translator_Code, */
                                  'TP_CODE',
                                  v_TranslatorCodePosition );

      xProgress := 'GPOAOB-40-2270';
      ece_flatfile_pvt.find_pos ( v_ORD_Table,
                                  v_ORD_CommonKeyName,
                                  v_ORD_CKNamePosition );

      xProgress := 'GPOAOB-40-2280';
      v_RecordCommonKey0 := RPAD ( NVL(SUBSTRB ( v_ORD_Table(v_TranslatorCodePosition).value,
                                   1,
                                   25 ),' '),
                                   25 );

      xProgress := 'GPOAOB-40-2290';
      v_RecordCommonKey1 := RPAD ( NVL(SUBSTRB ( v_ORD_Table(v_ORD_CKNamePosition).value,
                                   1,
                                   22 ),' '),
                                   22 );

      xProgress := 'GPOAOB-40-2300';
      v_FileCommonKey := v_RecordCommonKey0 ||
                         v_RecordCommonKey1 ||
                         v_KeyPad           ||
                         v_KeyPad;

      /*  */
      /*   Write the record to the output table. */
      /*  */
/*
dbms_output.put_line('Writing to ece_output');
dbms_output.put_line('Transaction Type: ' || p_TransactionType);
dbms_output.put_line('Comm Method: ' || p_CommunicationMethod);
dbms_output.put_line('Int: ' || p_ORD_Interface);
dbms_output.put_line('Width: ' || p_OutputWidth);
dbms_output.put_line('RnID: ' || p_RunID);
dbms_output.put_line('CommonKey: ' || v_FileCommonKey || '<-' );
*/
      xProgress := 'GPOAOB-40-2310';
      ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                             p_CommunicationMethod,
                                             p_ORD_Interface,
                                             v_ORD_Table,
                                             p_OutputWidth,
                                             p_RunID,
                                             v_FileCommonKey );

      /*  */
      /*   Store the values of the necessary elements (Order_ID and */
      /*   and Transaction_Record_ID) in the Order level SELECT clause */
      /*   into local variables and use the values to bind the variables */
      /*   in the SELECT clauses of the Order Charges, Text, Detail levels */
      /*  */

      xProgress := 'GPOAOB-40-2320';
      dbms_sql.column_value ( v_ORD_Select_Cursor,
                              v_ORD_Count + 3,
                              v_TransactionRecordID );

      xProgress := 'GPOAOB-40-2323';
      ece_flatfile_pvt.find_pos ( v_ORD_Table,
                                  'ORDER_ID',
                                  v_Order_Id_Position );

      /*
      **
      **  Everything is stored in the PL/SQL table as VARCHAR2, so convert
      **  the Order_ID value to NUMBER.
      **
      */

      xProgress := 'GPOAOB-40-2324';
      v_Order_Id := TO_NUMBER ( v_ORD_Table(v_Order_Id_Position).value );

      xProgress := 'GPOAOB-40-2325';
      dbms_sql.bind_variable ( v_OAC_Select_Cursor,
                               'RUN_ID',
                               p_RunID );

      xProgress := 'GPOAOB-40-2326';
      dbms_sql.bind_variable ( v_OAC_Select_Cursor,
                               'Order_ID',
                               v_Order_ID );

      xProgress := 'GPOAOB-40-2327';
      dbms_sql.bind_variable ( v_OTX_Select_Cursor,
                               'RUN_ID',
                               p_RunID );

      xProgress := 'GPOAOB-40-2328';
      dbms_sql.bind_variable ( v_OTX_Select_Cursor,
                               'Order_ID',
                               v_Order_ID );

      /*  */
      /*   Execute the Order Charges SELECT statement. */
      /*  */

      xProgress := 'GPOAOB-40-2330';
      v_Dummy := dbms_sql.execute ( v_OAC_Select_Cursor );

      /* ********************************************************* */
      /* **            Order Charges Level Loop                 ** */
      /* ********************************************************* */

      /*  */
      /*   Fetch the rows, and store the returned values in the  */
      /*   PL/SQL table. */
      /*  */

      xProgress := 'GPOAOB-40-2340';
      WHILE dbms_sql.fetch_rows ( v_OAC_Select_Cursor ) > 0
      LOOP
        xProgress := 'GPOAOB-40-2350';
        FOR v_LoopCount IN 1..v_OAC_Count
        LOOP
          xProgress := 'GPOAOB-40-2360';
          dbms_sql.column_value ( v_OAC_Select_Cursor,
                                  v_LoopCount,
                                  v_OAC_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Get the ROWIDs. */
        /*  */

        xProgress := 'GPOAOB-40-2370';
        dbms_sql.column_value ( v_OAC_Select_Cursor,
                                v_OAC_Count + 1,
                                v_OAC_RowID );

        xProgress := 'GPOAOB-40-2380';
        dbms_sql.column_value ( v_OAC_Select_Cursor,
                                v_OAC_Count + 2,
                                v_OAC_XRowID );

        /*  */
        /*  Update Common Key */
        /*  */
        xProgress := 'GPOAOB-40-2382';
        ece_flatfile_pvt.find_pos ( v_OAC_Table,
                                    v_OAC_CommonKeyName,
                                    v_OAC_CKNamePosition );

        xProgress := 'GPOAOB-40-2384';
        v_RecordCommonKey2 := RPAD ( NVL(SUBSTRB ( v_OAC_Table(v_OAC_CKNamePosition).value,
                                   1,
                                   22 ),' '),
                                   22 );

        xProgress := 'GPOAOB-40-2386';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_KeyPad;

        /*  */
        /*   Write the record to the output table. */
        /*  */

        xProgress := 'GPOAOB-40-2390';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_OAC_Interface,
                                               v_OAC_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        /*  */
        /*   Bind the variables (ROWIDs) in the DELETE statements for the */
        /*   OAC interface tables. */
        /*  */

        xProgress := 'GPOAOB-40-2391';
        dbms_sql.bind_variable ( v_OAC_Delete_Cursor,
                                 'Row_ID',
                                 v_OAC_RowID );

        xProgress := 'GPOAOB-40-2392';
        dbms_sql.bind_variable ( v_OAC_Delete_XCursor,
                                 'Row_ID',
                                 v_OAC_XRowID );

        /*  */
        /*   Delete the rows from the interface tables. */
        /*  */

        xProgress := 'GPOAOB-40-2393';
        v_Dummy := dbms_sql.execute ( v_OAC_Delete_Cursor );

        xProgress := 'GPOAOB-40-2394';
        v_Dummy := dbms_sql.execute ( v_OAC_Delete_XCursor );

      END LOOP; /*  Order Charge Level */

      /*  */
      /*   Execute the Order Text SELECT statement. */
      /*  */

      xProgress := 'GPOAOB-40-2330';
      v_Dummy := dbms_sql.execute ( v_OTX_Select_Cursor );

      /* ********************************************************* */
      /* **              Order Text Level Loop                  ** */
      /* ********************************************************* */


      /*  */
      /*   Fetch the rows, and store the returned values in the  */
      /*   PL/SQL table. */
      /*  */

      xProgress := 'GPOAOB-40-2440';
      WHILE dbms_sql.fetch_rows ( v_OTX_Select_Cursor ) > 0
      LOOP
        xProgress := 'GPOAOB-40-2450';
        FOR v_LoopCount IN 1..v_OTX_Count
        LOOP
          xProgress := 'GPOAOB-40-2460';
          dbms_sql.column_value ( v_OTX_Select_Cursor,
                                  v_LoopCount,
                                  v_OTX_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Get the ROWIDs. */
        /*  */

        xProgress := 'GPOAOB-40-2470';
        dbms_sql.column_value ( v_OTX_Select_Cursor,
                                v_OTX_Count + 1,
                                v_OTX_RowID );

        xProgress := 'GPOAOB-40-2480';
        dbms_sql.column_value ( v_OTX_Select_Cursor,
                                v_OTX_Count + 2,
                                v_OTX_XRowID );

        /*  */
        /*  Update Common Key */
        /*  */
        xProgress := 'GPOAOB-40-2482';
        ece_flatfile_pvt.find_pos ( v_OTX_Table,
                                    v_OTX_CommonKeyName,
                                    v_OTX_CKNamePosition );


        xProgress := 'GPOAOB-40-2484';
        v_RecordCommonKey2 := RPAD ( NVL(SUBSTRB ( v_OTX_Table(v_OTX_CKNamePosition).value,
                                   1,
                                   22 ),' '),
                                   22 );

        xProgress := 'GPOAOB-40-2486';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_KeyPad;

        /*  */
        /*   Write the record to the output table. */
        /*  */

        xProgress := 'GPOAOB-40-2490';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_OTX_Interface,
                                               v_OTX_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        /*  */
        /*   Bind the variables (ROWIDs) in the DELETE statements for the */
        /*   OTX interface tables. */
        /*  */

        xProgress := 'GPOAOB-40-2491';
        dbms_sql.bind_variable ( v_OTX_Delete_Cursor,
                                 'Row_ID',
                                 v_OTX_RowID );

        xProgress := 'GPOAOB-40-2492';
        dbms_sql.bind_variable ( v_OTX_Delete_XCursor,
                                 'Row_ID',
                                 v_OTX_XRowID );

        /*  */
        /*   Delete the rows from the interface tables. */
        /*  */

        xProgress := 'GPOAOB-40-2493';
        v_Dummy := dbms_sql.execute ( v_OTX_Delete_Cursor );

        xProgress := 'GPOAOB-40-2494';
        v_Dummy := dbms_sql.execute ( v_OTX_Delete_XCursor );

      END LOOP; /*  Order Text Level */

      /*  */
      /*   Bind the variables (ROWIDs) in the DELETE statements for the */
      /*   Delivery and Delivery Attribute interface tables. */
      /*  */

        /*  */
        /*   Execute the Detail level SELECT statement. */
        /*  */
        xProgress := 'GPOAOB-40-2500';
        dbms_sql.bind_variable ( v_DTL_Select_Cursor,
                                 'RUN_ID',
                                 p_RunID );

        dbms_sql.bind_variable ( v_DTL_Select_Cursor,
                                 'Order_ID',
                                 v_Order_ID );

        xProgress := 'GPOAOB-40-2510';
        v_Dummy := dbms_sql.execute ( v_DTL_Select_Cursor );

        /*  */
        /*   Begin the Detail level loop. */
        /*  */
        xProgress := 'GPOAOB-40-2520';
        WHILE dbms_sql.fetch_rows ( v_DTL_Select_Cursor ) > 0
        LOOP
          xProgress := 'GPOAOB-40-2530';
          FOR v_LoopCount IN 1..v_DTL_Count
          LOOP
            xProgress := 'GPOAOB-40-2540';
            dbms_sql.column_value ( v_DTL_Select_Cursor,
                                    v_LoopCount,
                                    v_DTL_Table(v_LoopCount).value);
          END LOOP;

          /*  */
          /*   Store the ROWIDs. */
          /*  */

          xProgress := 'GPOAOB-40-2550';
          dbms_sql.column_value ( v_DTL_Select_Cursor,
                                  v_DTL_Count + 1,
                                  v_DTL_RowID );

          xProgress := 'GPOAOB-40-2560';
          dbms_sql.column_value ( v_DTL_Select_Cursor,
                                  v_DTL_Count + 2,
                                  v_DTL_XRowID );

          /*  */
          /*   Find the Line Number in the PL/SQL table and add this */
          /*   value to the common key. */
          /*  */

          xProgress := 'GPOAOB-40-2570';
          ece_flatfile_pvt.find_pos ( v_DTL_Table,
                                      v_DTL_CommonKeyName,
                                      v_DTL_CKNamePosition);

          xProgress := 'GPOAOB-40-2580';
          v_RecordCommonKey2 := RPAD ( NVL(SUBSTRB ( v_DTL_Table(v_DTL_CKNamePosition).value,
                                       1, 22 ),' '), 22 );

          xProgress := 'GPOAOB-40-2590';
          v_FileCommonKey := v_RecordCommonKey0 ||
                             v_RecordCommonKey1 ||
                             v_RecordCommonKey2 ||
                             v_KeyPad;

          /*  */
          /*   Write the record to the output table. */
          /*  */

          xProgress := 'GPOAOB-40-2600';
          ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                                 p_CommunicationMethod,
                                                 p_DTL_Interface,
                                                 v_DTL_Table,
                                                 p_OutputWidth,
                                                 p_RunID,
                                                 v_FileCommonKey );

          xProgress := 'GPOAOB-40-2610';
          dbms_sql.bind_variable ( v_DTL_Delete_Cursor,
                                   'Row_ID',
                                   v_DTL_RowID );

          xProgress := 'GPOAOB-40-2620';
          dbms_sql.bind_variable ( v_DTL_Delete_XCursor,
                                   'Row_ID',
                                   v_DTL_XRowID );

          /*  */
          /*   Delete the rows from the interface table. */
          /*  */

          xProgress := 'GPOAOB-40-2630';
          v_Dummy := dbms_sql.execute ( v_DTL_Delete_Cursor );

          xProgress := 'GPOAOB-40-2640';
          v_Dummy := dbms_sql.execute ( v_DTL_Delete_XCursor );

      /*  */
      /*   Execute the Detail DAC SELECT statement. */
      /*  */
      xProgress := 'GPOAOB-40-2650';
      ece_flatfile_pvt.find_pos( v_DTL_Table,
                                 'Line_ID',
                                 v_Line_ID_Position );

      xProgress := 'GPOAOB-40-2660';
      v_Line_Id := TO_NUMBER ( v_DTL_Table(v_Line_Id_Position).value );

      xProgress := 'GPOAOB-40-2670';
      dbms_sql.bind_variable ( v_DAC_Select_Cursor,
                               'RUN_ID',
                               p_RunID );

      dbms_sql.bind_variable ( v_DAC_Select_Cursor,
                               'Line_ID',
                               v_Line_ID );

      xProgress := 'GPOAOB-40-2680';
      v_Dummy := dbms_sql.execute ( v_DAC_Select_Cursor );

      /*  */
      /*   Begin the DETAIL DAC loop. */
      /*  */

      xProgress := 'GPOAOB-40-2690';
      WHILE dbms_sql.fetch_rows ( v_DAC_Select_Cursor ) > 0
      LOOP
        xProgress := 'GPOAOB-40-2700';
        FOR v_LoopCount IN 1..v_DAC_Count
        LOOP
          xProgress := 'GPOAOB-40-2710';
          dbms_sql.column_value ( v_DAC_Select_Cursor,
                                  v_LoopCount,
                                  v_DAC_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Store the ROWIDs. */
        /*  */

        xProgress := 'GPOAOB-40-2720';
        dbms_sql.column_value ( v_DAC_Select_Cursor,
                                v_DAC_Count + 1,
                                v_DAC_RowID );

        xProgress := 'GPOAOB-40-2730';
        dbms_sql.column_value ( v_DAC_Select_Cursor,
                                v_DAC_Count + 2,
                                v_DAC_XRowID );

        xProgress := 'GPOAOB-40-2735';
        ece_flatfile_pvt.find_pos ( v_DAC_Table,
                                    v_DAC_CommonKeyName,
                                    v_DAC_CKNamePosition);

        xProgress := 'GPOAOB-40-2736';
        v_RecordCommonKey3 := RPAD ( NVL(SUBSTRB ( v_DAC_Table(v_DAC_CKNamePosition).value,
                                     1, 22 ),' '), 22 );

        xProgress := 'GPOAOB-40-2740';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;

        /*  */
        /*   Write the record to the output table. */
        /*  */
        xProgress := 'GPOAOB-40-2770';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_DAC_Interface,
                                               v_DAC_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GPOAOB-40-2780';
        dbms_sql.bind_variable ( v_DAC_Delete_Cursor,
                                 'Row_ID',
                                 v_DAC_RowID );

        xProgress := 'GPOAOB-40-2790';
        dbms_sql.bind_variable ( v_DAC_Delete_XCursor,
                                 'Row_ID',
                                 v_DAC_XRowID );

        xProgress := 'GPOAOB-40-2800';
        v_Dummy := dbms_sql.execute ( v_DAC_Delete_Cursor );

        xProgress := 'GPOAOB-40-2340';
        v_Dummy := dbms_sql.execute ( v_DAC_Delete_XCursor );
       END LOOP; /*  while dac */

      xProgress := 'GPOAOB-40-2670';
      dbms_sql.bind_variable ( v_DTX_Select_Cursor,
                               'RUN_ID',
                               p_RunID );

      dbms_sql.bind_variable ( v_DTX_Select_Cursor,
                               'Line_ID',
                               v_Line_ID );

      xProgress := 'GPOAOB-40-2680';
      v_Dummy := dbms_sql.execute ( v_DTX_Select_Cursor );

      /*  */
      /*   Begin the DETAIL Text loop. */
      /*  */

      xProgress := 'GPOAOB-40-2690';
      WHILE dbms_sql.fetch_rows ( v_DTX_Select_Cursor ) > 0
      LOOP
        xProgress := 'GPOAOB-40-2700';
        FOR v_LoopCount IN 1..v_DTX_Count
        LOOP
          xProgress := 'GPOAOB-40-2710';
          dbms_sql.column_value ( v_DTX_Select_Cursor,
                                  v_LoopCount,
                                  v_DTX_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Store the ROWIDs. */
        /*  */

        xProgress := 'GPOAOB-40-2720';
        dbms_sql.column_value ( v_DTX_Select_Cursor,
                                v_DTX_Count + 1,
                                v_DTX_RowID );

        xProgress := 'GPOAOB-40-2730';
        dbms_sql.column_value ( v_DTX_Select_Cursor,
                                v_DTX_Count + 2,
                                v_DTX_XRowID );


        xProgress := 'GPOAOB-40-2735';
        ece_flatfile_pvt.find_pos ( v_DTX_Table,
                                    v_DTX_CommonKeyName,
                                    v_DTX_CKNamePosition);

        xProgress := 'GPOAOB-40-2736';
        v_RecordCommonKey3 := RPAD ( NVL(SUBSTRB ( v_DTX_Table(v_DTX_CKNamePosition).value,
                                     1, 22 ),' '), 22 );

        xProgress := 'GPOAOB-40-2740';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;

        /*  */
        /*   Write the record to the output table. */
        /*  */
        xProgress := 'GPOAOB-40-2770';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_DTX_Interface,
                                               v_DTX_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GPOAOB-40-2780';
        dbms_sql.bind_variable ( v_DTX_Delete_Cursor,
                                 'Row_ID',
                                 v_DTX_RowID );

        xProgress := 'GPOAOB-40-2790';
        dbms_sql.bind_variable ( v_DTX_Delete_XCursor,
                                 'Row_ID',
                                 v_DTX_XRowID );

        xProgress := 'GPOAOB-40-2800';
        v_Dummy := dbms_sql.execute ( v_DTX_Delete_Cursor );

        xProgress := 'GPOAOB-40-2340';
        v_Dummy := dbms_sql.execute ( v_DTX_Delete_XCursor );
       END LOOP; /*  while dtx */

      xProgress := 'GPOAOB-40-2670';
      dbms_sql.bind_variable ( v_ALL_Select_Cursor,
                               'RUN_ID',
                               p_RunID );

      dbms_sql.bind_variable ( v_ALL_Select_Cursor,
                               'Line_ID',
                               v_Line_ID );

      xProgress := 'GPOAOB-40-2680';
      v_Dummy := dbms_sql.execute ( v_ALL_Select_Cursor );

      /*  */
      /*   Begin the Allocations loop. */
      /*  */

      xProgress := 'GPOAOB-40-2690';
      WHILE dbms_sql.fetch_rows ( v_ALL_Select_Cursor ) > 0
      LOOP
        xProgress := 'GPOAOB-40-2700';
        FOR v_LoopCount IN 1..v_ALL_Count
        LOOP
          xProgress := 'GPOAOB-40-2710';
          dbms_sql.column_value ( v_ALL_Select_Cursor,
                                  v_LoopCount,
                                  v_ALL_Table(v_LoopCount).value );
        END LOOP;

        /*  */
        /*   Store the ROWIDs. */
        /*  */

        xProgress := 'GPOAOB-40-2720';
        dbms_sql.column_value ( v_ALL_Select_Cursor,
                                v_ALL_Count + 1,
                                v_ALL_RowID );

        xProgress := 'GPOAOB-40-2730';
        dbms_sql.column_value ( v_ALL_Select_Cursor,
                                v_ALL_Count + 2,
                                v_ALL_XRowID );


        xProgress := 'GPOAOB-40-2735';
        ece_flatfile_pvt.find_pos ( v_ALL_Table,
                                    v_ALL_CommonKeyName,
                                    v_ALL_CKNamePosition);

        xProgress := 'GPOAOB-40-2736';
        v_RecordCommonKey3 := RPAD ( NVL(SUBSTRB ( v_ALL_Table(v_ALL_CKNamePosition).value,
                                     1, 22 ),' '), 22 );

        xProgress := 'GPOAOB-40-2740';
        v_FileCommonKey := v_RecordCommonKey0 ||
                           v_RecordCommonKey1 ||
                           v_RecordCommonKey2 ||
                           v_RecordCommonKey3;

        /*  */
        /*   Write the record to the output table. */
        /*  */
        xProgress := 'GPOAOB-40-2770';
        ece_flatfile_pvt.write_to_ece_output ( p_TransactionType,
                                               p_CommunicationMethod,
                                               p_ALL_Interface,
                                               v_ALL_Table,
                                               p_OutputWidth,
                                               p_RunID,
                                               v_FileCommonKey );

        xProgress := 'GPOAOB-40-2780';
        dbms_sql.bind_variable ( v_ALL_Delete_Cursor,
                                 'Row_ID',
                                 v_ALL_RowID );

        xProgress := 'GPOAOB-40-2790';
        dbms_sql.bind_variable ( v_ALL_Delete_XCursor,
                                 'Row_ID',
                                 v_ALL_XRowID );

        xProgress := 'GPOAOB-40-2800';
        v_Dummy := dbms_sql.execute ( v_ALL_Delete_Cursor );

        xProgress := 'GPOAOB-40-2340';
        v_Dummy := dbms_sql.execute ( v_ALL_Delete_XCursor );
       END LOOP; /*  while all */

     END LOOP; /*  while dtl */

      xProgress := 'GPOAOB-40-2990';
      dbms_sql.bind_variable ( v_ORD_Delete_Cursor,
                               'Row_ID',
                               v_ORD_RowID );

      xProgress := 'GPOAOB-40-3000';
      dbms_sql.bind_variable ( v_ORD_Delete_XCursor,
                               'Row_ID',
                               v_ORD_XRowID );

      /*  */
      /*   Delete the rows from the interface tables. */
      /*  */

      xProgress := 'GPOAOB-40-3030';
      v_Dummy := dbms_sql.execute ( v_ORD_Delete_Cursor );

      xProgress := 'GPOAOB-40-3040';
      v_Dummy := dbms_sql.execute ( v_ORD_Delete_XCursor );

    END LOOP; /*  Order Level */

    /*  */
    /*   Commit the interface table DELETEs. */
    /*  */

    xProgress := 'GASNOB-40-3070';
    ec_debug.pop ( 'GML_GPOAO.Put_Data_To_Output_Table' );
    COMMIT;

    /*  */
    /*   Close all open cursors. */
    /*  */

    xProgress := 'GPOAOB-40-3080';
    dbms_sql.close_cursor ( v_ORD_Select_Cursor );
    xProgress := 'GPOAOB-40-3081';
    dbms_sql.close_cursor ( v_OAC_Select_Cursor );
    xProgress := 'GPOAOB-40-3082';
    dbms_sql.close_cursor ( v_OTX_Select_Cursor );
    xProgress := 'GPOAOB-40-3083';
    dbms_sql.close_cursor ( v_DTL_Select_Cursor );
    xProgress := 'GPOAOB-40-3084';
    dbms_sql.close_cursor ( v_DAC_Select_Cursor );
    xProgress := 'GPOAOB-40-3085';
    dbms_sql.close_cursor ( v_DTX_Select_Cursor );
    xProgress := 'GPOAOB-40-3086';
    dbms_sql.close_cursor ( v_ALL_Select_Cursor );

    xProgress := 'GPOAOB-40-3088';
    dbms_sql.close_cursor ( v_ORD_Delete_Cursor );
    xProgress := 'GPOAOB-40-3089';
    dbms_sql.close_cursor ( v_OAC_Delete_Cursor );
    xProgress := 'GPOAOB-40-3090';
    dbms_sql.close_cursor ( v_OTX_Delete_Cursor );
    xProgress := 'GPOAOB-40-3091';
    dbms_sql.close_cursor ( v_DTL_Delete_Cursor );
    xProgress := 'GPOAOB-40-3092';
    dbms_sql.close_cursor ( v_DAC_Delete_Cursor );
    xProgress := 'GPOAOB-40-3093';
    dbms_sql.close_cursor ( v_DTX_Delete_Cursor );
    xProgress := 'GPOAOB-40-3094';
    dbms_sql.close_cursor ( v_ALL_Delete_Cursor );

    xProgress := 'GPOAOB-40-3096';
    dbms_sql.close_cursor ( v_ORD_Delete_XCursor );
    xProgress := 'GPOAOB-40-3097';
    dbms_sql.close_cursor ( v_OAC_Delete_XCursor );
    xProgress := 'GPOAOB-40-3098';
    dbms_sql.close_cursor ( v_OTX_Delete_XCursor );
    xProgress := 'GPOAOB-40-3099';
    dbms_sql.close_cursor ( v_DTL_Delete_XCursor );
    xProgress := 'GPOAOB-40-3100';
    dbms_sql.close_cursor ( v_DAC_Delete_XCursor );
    xProgress := 'GPOAOB-40-3101';
    dbms_sql.close_cursor ( v_DTX_Delete_XCursor );
    xProgress := 'GPOAOB-40-3102';
    dbms_sql.close_cursor ( v_ALL_Delete_XCursor );

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

END GML_GPOAO;

/
