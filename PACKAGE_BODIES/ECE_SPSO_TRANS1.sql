--------------------------------------------------------
--  DDL for Package Body ECE_SPSO_TRANS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_SPSO_TRANS1" AS
-- $Header: ECSPSOB.pls 120.4.12010000.3 2011/05/31 10:47:16 lswamina ship $

  /*===========================================================================

    PROCEDURE NAME:      Extract_SPSO_Outbound

    PURPOSE:             This procedure initiates the concurrent process to
                         extract the eligible transactions.

  ===========================================================================*/

  PROCEDURE Extract_SPSO_Outbound ( errbuf           OUT NOCOPY VARCHAR2,
                                    retcode          OUT NOCOPY VARCHAR2,
                                    cOutput_Path     IN  VARCHAR2,
                                    cOutput_Filename IN  VARCHAR2,
                                    p_schedule_id    IN  VARCHAR2 default 0,
                                    v_debug_mode     IN  NUMBER default 0,
                                    p_batch_id       IN  NUMBER default 0)   -- Bug 2064311
  IS

    p_communication_method  VARCHAR2(120)  :=  'EDI';
    p_transaction_type      VARCHAR2(120)  :=  'SPSO';
    p_document_type         VARCHAR2(120)  :=  'SPS';
    l_line_text             VARCHAR2(2000);
    uFile_type              utl_file.file_type;
    p_output_width          INTEGER        :=  4000;
    p_run_id                INTEGER;
    p_header_interface      VARCHAR2(120)  :=  'ECE_SPSO_HEADERS';
    p_item_interface        VARCHAR2(120)  :=  'ECE_SPSO_ITEMS';
    p_item_d_interface      VARCHAR2(120)  :=  'ECE_SPSO_ITEM_DET';
    p_transaction_date      DATE           :=  SYSDATE;
    xProgress               VARCHAR2(30);
    cEnabled                VARCHAR2(1)          := 'Y';
    ece_transaction_disabled   EXCEPTION;


    CURSOR c_output IS
       SELECT   text
       FROM     ece_output
       WHERE    run_id = p_run_id
       ORDER BY line_id;

  BEGIN

    ec_debug.enable_debug(v_debug_mode);
    ec_debug.push ( 'ECE_SPSO_Trans1.Extract_SPSO_Outbound' );
    ec_debug.pl ( 3, 'cOutput_Path: ',cOutput_Path );
    ec_debug.pl ( 3, 'cOutput_Filename: ',cOutput_Filename );
    ec_debug.pl ( 3, 'p_schedule_id: ',p_schedule_id );
    ec_debug.pl ( 3, 'v_debug_mode: ',v_debug_mode );
    ec_debug.pl(3,'p_batch_id:  ',p_batch_id);
         /* Check to see if the transaction is enabled. If not, abort */
         xProgress := 'SPSO-10-1001';
         fnd_profile.get('ECE_' || p_Transaction_Type || '_ENABLED',cEnabled);

         xProgress := 'SPSO-10-1002';
         IF cEnabled = 'N' THEN
            xProgress := 'SPSO-10-1003';
            RAISE ece_transaction_disabled;
         END IF;

    xProgress := 'SPSO-10-1005';
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

    xProgress := 'SPSO-10-1010';
    ec_debug.pl ( 0, 'EC', 'ECE_SPSO_START', NULL );

    xProgress := 'SPSO-10-1020';
    ec_debug.pl ( 0, 'EC', 'ECE_RUN_ID', 'RUN_ID', p_run_id );

    xProgress := 'SPSO-10-1030';
    ece_spso_trans1.populate_supplier_sched_api1 ( p_communication_method,
                                                   p_transaction_type,
                                                   p_transaction_date,
                                                   p_run_id,
                                                   p_document_type,
                                                   p_schedule_id,
                                                   p_batch_id,
                                                   p_header_interface,
                                                   p_item_interface,
                                                   p_item_d_interface );

    xProgress := 'SPSO-10-1040';
    ece_spso_trans2.populate_supplier_sched_api2 ( p_communication_method,
                                                   p_transaction_type,
                                                   p_document_type,
                                                   p_run_id,
                                                   p_schedule_id,
                                                   p_batch_id);

    xProgress := 'SPSO-10-1050';
    ece_spso_trans1.populate_supplier_sched_api3 ( p_communication_method,
                                                   p_transaction_type,
                                                   p_document_type,
                                                   p_run_id,
                                                   p_schedule_id,
                                                   p_batch_id);

    xProgress := 'SPSO-10-1060';
    ece_spso_trans1.put_data_to_output_table ( p_communication_method,
                                               p_transaction_type,
                                               p_output_width,
                                               p_run_id,
                                               p_header_interface,
                                               p_item_interface,
                                               p_item_d_interface );

    xProgress := 'SPSO-10-1070';

    -- Open the cursor to select the actual file output from ece_output.

    xProgress := 'SPSO-10-1080';
    OPEN c_output;
    LOOP
      FETCH c_output
      INTO l_line_text;

      if (c_output%ROWCOUNT > 0) then
         if (NOT utl_file.is_open(uFile_type)) then
             uFile_type := utl_file.fopen ( cOutput_Path,
                                            cOutput_Filename,
                                            'W' );
         end if;
      end if;

      EXIT WHEN c_output%NOTFOUND;

      -- Write the data from ece_output to the output file.

      xProgress := 'SPSO-10-1090';
      utl_file.put_line ( uFile_type,l_line_text );
      ec_debug.pl ( 3, 'l_line_text: ',l_line_text );

    END LOOP;

    CLOSE c_output;

    -- Close the output file.

    xProgress := 'SPSO-10-1100';
    if (utl_file.is_open( uFile_type)) then
    utl_file.fclose ( uFile_type );
    end if;

    xProgress := 'SPSO-10-1110';
    ec_debug.pl ( 0, 'EC', 'ECE_SPSO_COMPLETE ',NULL );

    -- Assume everything went ok so delete the records from ece_output.

    xProgress := 'SPSO-10-1120';
    DELETE
    FROM     ece_output
    WHERE    run_id = p_run_id;

    IF SQL%NOTFOUND
    THEN
      ec_debug.pl ( 0,
                    'EC',
                    'ECE_NO_ROW_PROCESSED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'TABLE_NAME',
                    'ECE_OUTPUT' );
    END IF;

   IF ec_mapping_utils.ec_get_trans_upgrade_status(p_transaction_type)  = 'U' THEN
      ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
      retcode := 1;
   END IF;

    ec_debug.pop ( 'ECE_SPSO_Trans1.Extract_SPSO_Outbound' );
    ec_debug.disable_debug;
    COMMIT;

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

  END Extract_SPSO_Outbound;


/*===========================================================================

  PROCEDURE NAME:      Extract_SSSO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible deliveires on a dparture.

 ===========================================================================*/

  PROCEDURE Extract_SSSO_Outbound ( errbuf           OUT NOCOPY VARCHAR2,
                                    retcode          OUT NOCOPY VARCHAR2,
                                    cOutput_Path     IN  VARCHAR2,
                                    cOutput_Filename IN  VARCHAR2,
                                    p_schedule_id    IN  VARCHAR2,
                                    v_debug_mode     IN  NUMBER default 0,
                                    p_batch_id       IN  NUMBER default 0)   -- Bug 2064311
  IS

    xBeforeFormat           EXCEPTION;
    xProgress               VARCHAR2(80);
    p_communication_method  VARCHAR2(120)  := 'EDI';
    p_transaction_type      VARCHAR2(120)  := 'SSSO';
    p_document_type         VARCHAR2(120)  := 'SSS';
    l_line_text             VARCHAR2(2000);
    uFile_type              utl_file.file_type;
    p_output_width          INTEGER        :=  4000;
    p_run_id                NUMBER  ;
    p_header_interface      VARCHAR2(120)  := 'ECE_SPSO_HEADERS';
    p_item_interface        VARCHAR2(120)  := 'ECE_SPSO_ITEMS';
    p_item_d_interface      VARCHAR2(120)  := 'ECE_SPSO_ITEM_DET';
    p_transaction_date      DATE           :=  SYSDATE;
      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;

    CURSOR c_output IS
       SELECT   text
       FROM     ece_output
       WHERE    run_id = p_run_id
       ORDER BY line_id;

  BEGIN

    ec_debug.enable_debug(v_debug_mode);
    ec_debug.push ( 'ECE_SPSO_Trans1.Extract_SSSO_Outbound' );
    ec_debug.pl ( 3, 'cOutput_Path: ',cOutput_Path );
    ec_debug.pl ( 3, 'cOutput_Filename: ',cOutput_Filename );
    ec_debug.pl ( 3, 'p_schedule_id: ',p_schedule_id );
    ec_debug.pl ( 3, 'v_debug_mode: ',v_debug_mode );
    ec_debug.pl ( 3, 'p_batch_id ',p_batch_id );

         /* Check to see if the transaction is enabled. If not, abort */
         xProgress := 'SSSO-10-1001';
         fnd_profile.get('ECE_' || p_Transaction_Type || '_ENABLED',cEnabled);

         xProgress := 'SSSO-10-1002';
         IF cEnabled = 'N' THEN
            xProgress := 'SSSO-10-1003';
            RAISE ece_transaction_disabled;
         END IF;

    xProgress := 'SSSO-10-1005';
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
    ec_debug.pl(3, 'p_run_id: ',p_run_id);

    xProgress := 'SSSO-10-1010';
    ec_debug.pl ( 0, 'EC', 'ECE_SSSO_START', NULL );

    xProgress := 'SSSO-10-1020';
    ec_debug.pl ( 0, 'EC', 'ECE_RUN_ID', 'RUN_ID', p_run_id );

    xProgress := 'SSSO-10-1030';
    ece_spso_trans1.populate_supplier_sched_api1 ( p_communication_method,
                                                   p_transaction_type,
                                                   p_transaction_date,
                                                   p_run_id,
                                                   p_document_type,
                                                   p_schedule_id,
                                                   p_batch_id,
                                                   p_header_interface,
                                                   p_item_interface,
                                                   p_item_d_interface );

    xProgress := 'SSSO-10-1040';
    ece_spso_trans2.populate_supplier_sched_api2 ( p_communication_method,
                                                   p_transaction_type,
                                                   p_document_type,
                                                   p_run_id,
                                                   p_schedule_id,
                                                   p_batch_id );

    xProgress := 'SSSO-10-1050';
    ece_spso_trans1.populate_supplier_sched_api3 ( p_communication_method,
                                                   p_transaction_type,
                                                   p_document_type,
                                                   p_run_id,
                                                   p_schedule_id,
                                                   p_batch_id );

    xProgress := 'SSSO-10-1060';
    ece_spso_trans1.put_data_to_output_table ( p_communication_method,
                                               p_transaction_type,
                                               p_output_width,
                                               p_run_id,
                                               p_header_interface,
                                               p_item_interface,
                                               p_item_d_interface );


    xProgress  := 'SSSO-10-1070';

    -- Open the cursor to select the actual file output from ece_output.

    xProgress := 'SSSO-10-1080';
    OPEN c_output;
    LOOP
      FETCH c_output
      INTO l_line_text;
      if (c_output%ROWCOUNT > 0) then
         if (NOT utl_file.is_open(uFile_type)) then
             uFile_type := utl_file.fopen ( cOutput_Path,
                                            cOutput_Filename,
                                            'W' );
         end if;
      end if;
      EXIT WHEN c_output%NOTFOUND;

      -- Write the data from ece_output to the output file.

      xProgress := 'SSSO-10-1090';
      utl_file.put_line ( uFile_type,
                          l_line_text );
      ec_debug.pl ( 3, 'l_line_text: ',l_line_text );

    END LOOP;

    CLOSE c_output;

    -- Close the output file.

    xProgress := 'SSSO-10-1100';
    if (utl_file.is_open( uFile_type)) then
    utl_file.fclose ( uFile_type );
    end if;

    xProgress := 'SSSO-10-1110';
    ec_debug.pl ( 0, 'EC', 'ECE_SSSO_COMPLETE', NULL );

    -- Assume everything went ok so delete the records from ece_output.

    xProgress := 'SSSO-10-1120';
    DELETE
    FROM     ece_output
    WHERE    run_id = p_run_id;

    IF SQL%NOTFOUND
    THEN
      ec_debug.pl ( 0,
                    'EC',
                    'ECE_NO_ROW_PROCESSED',
                    'PROGRESS_LEVEL',
                    xProgress,
                    'TABLE_NAME',
                    'ECE_OUTPUT' );
    END IF;


    IF ec_mapping_utils.ec_get_trans_upgrade_status(p_transaction_type)  = 'U' THEN
       ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
       retcode := 1;
    END IF;

    ec_debug.pop ( 'ECE_SPSO_Trans1.Extract_SSSO_Outbound' );
    ec_debug.disable_debug;
    COMMIT;

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
                    'EC', '
                    ECE_UTIL_INVALID_OPERATION',
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

  END Extract_SSSO_Outbound;


  /* --------------------------------------------------------------------------*/

  --  PROCEDURE Populate_Supplier_Sched_API1
  --  This procedure has the following functionalities:
  --  1. Build SQL statement dynamically to extract data from
  --     Base Application Tables.
  --  2. Execute the dynamic SQL statement.
  --  3. Assign data into 2-dim PL/SQL table
  --  4. Pass data to the code conversion mechanism
  --  5. Populate the Interface tables with the extracted data.
  -- --------------------------------------------------------------------------

  PROCEDURE Populate_Supplier_Sched_API1 ( cCommunication_Method IN VARCHAR2,
                                           cTransaction_Type     IN VARCHAR2,
                                           dTransaction_date     IN DATE,
                                           iRun_id               IN INTEGER,
                                           p_document_type       IN VARCHAR2 DEFAULT 'SPS',
                                           p_schedule_id         IN INTEGER  DEFAULT 0,
                                           p_batch_id            IN NUMBER DEFAULT 0,
                                           cHeader_Interface     IN VARCHAR2,
                                           cItem_Interface       IN VARCHAR2,
                                           cItem_D_Interface     IN VARCHAR2 )
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

    xProgress                    VARCHAR2(30);
    v_LevelProcessed             VARCHAR2(40);
    cOutput_path                 VARCHAR2(120);

    l_header_tbl                 ece_flatfile_pvt.Interface_tbl_type;
    l_item_tbl                   ece_flatfile_pvt.Interface_tbl_type;
    l_key_tbl                    ece_flatfile_pvt.Interface_tbl_type;

    Header_sel_c                 INTEGER;
    Item_sel_c                   INTEGER;
    Item_D_sel_c                 INTEGER;

    cHeader_view                 VARCHAR2(50);
    cItem_view                   VARCHAR2(50);

    cHeader_select               VARCHAR2(32000);
    cItem_select                 VARCHAR2(32000);
    cItem_D_select               VARCHAR2(32000);

    cHeader_from                 VARCHAR2(32000);
    cItem_from                   VARCHAR2(32000);
    cItem_D_from                 VARCHAR2(32000);

    cHeader_where                VARCHAR2(32000);
    cItem_where                  VARCHAR2(32000);
    cItem_D_where                VARCHAR2(32000);

    iHeader_count                NUMBER := 0;
    iItem_count                  NUMBER := 0;
    iItem_D_count                NUMBER := 0;
    iKey_count                   NUMBER := 0;

    l_header_fkey                NUMBER;
    l_item_fkey                  NUMBER;
    l_Item_D_fkey                NUMBER;

    nHeader_key_pos              NUMBER;
    nItem_key_pos                NUMBER;
    nItem_D_key_pos              NUMBER;

    dummy                        INTEGER;
    nPos1                        NUMBER;
    nPos2                        NUMBER;
    nPos3                        NUMBER;
    nPos4                        NUMBER;
    nPos5                        NUMBER;
    nPos6                        NUMBER;
    nPos7                        NUMBER;
    nPos8                        NUMBER;
    nPos9                        NUMBER;
    nTrans_id                    NUMBER;

    n_trx_date_pos               NUMBER;
    n_vendor_id_pos              NUMBER;
    n_vendor_site_id_pos         NUMBER;
    n_organization_id_pos        NUMBER;
    n_item_id_pos                NUMBER;

    n_schedule_type_pos          NUMBER;
    n_schedule_id_pos            NUMBER;
    n_st_org_code_pos            NUMBER;
    n_cum_period_pos             NUMBER;
    n_enable_cum_flag_pos        NUMBER;
    n_st_name_pos                NUMBER;
    n_item_st_org_pos            NUMBER;
    n_st_add_1_pos               NUMBER;
    n_st_add_2_pos               NUMBER;
    n_st_add_3_pos               NUMBER;
    n_st_city_pos                NUMBER;
    n_st_county_pos              NUMBER;
    n_st_state_pos               NUMBER;
    n_st_country_pos             NUMBER;
    n_st_postal_pos              NUMBER;
    x_schedule_order             NUMBER;
    x_item_detail                NUMBER;
    exclude_zero_schedule_from_ff VARCHAR2(1) := 'N'; --bug 2944455

    l_init_msg_list              VARCHAR2(20);
    l_simulate                   VARCHAR2(20);
    l_validation_level           VARCHAR2(20);
    l_commit                     VARCHAR2(20);
    l_return_status              VARCHAR2(20);
    l_msg_count                  VARCHAR2(20);
    l_msg_data                   VARCHAR2(20);

    fail_convert_to_ext          EXCEPTION;


    -- ***************************************
    -- These variables are for the item loop
    -- ***************************************

    x_item_detail_sequence       NUMBER :=0;

    x_asl_id                     NUMBER;
    x_enable_authorizations_flag VARCHAR2(1);
    x_scheduler_id               NUMBER;
    x_asl_attribute_category     VARCHAR2(30);
    x_asl_attribute1             VARCHAR2(150);
    x_asl_attribute2             VARCHAR2(150);
    x_asl_attribute3             VARCHAR2(150);
    x_asl_attribute4             VARCHAR2(150);
    x_asl_attribute5             VARCHAR2(150);
    x_asl_attribute6             VARCHAR2(150);
    x_asl_attribute7             VARCHAR2(150);
    x_asl_attribute8             VARCHAR2(150);
    x_asl_attribute9             VARCHAR2(150);
    x_asl_attribute10            VARCHAR2(150);
    x_asl_attribute11            VARCHAR2(150);
    x_asl_attribute12            VARCHAR2(150);
    x_asl_attribute13            VARCHAR2(150);
    x_asl_attribute14            VARCHAR2(150);
    x_asl_attribute15            VARCHAR2(150);

    x_supplier_product_num       VARCHAR2(25);

    x_scheduler_first_name       VARCHAR2(150); --2507403 UTF8
    x_scheduler_last_name        VARCHAR2(150); --2507403 UTF8
    x_scheduler_work_telephone   VARCHAR2(60);

    x_planner_first_name         VARCHAR2(150); --2507403 UTF8
    x_planner_last_name          VARCHAR2(150); --2507403 UTF8
    x_planner_work_telephone     VARCHAR2(60);

    d_dummy_date         DATE;
    g_item_id            NUMBER;
  BEGIN

    ec_debug.push ( 'ece_spso_trans1.Populate_Supplier_Sched_API1' );
    ec_debug.pl ( 3, 'cCommunication_Method: ', cCommunication_Method );
    ec_debug.pl ( 3, 'cTransaction_Type: ',cTransaction_Type );
    ec_debug.pl ( 3, 'dTransaction_date: ',dTransaction_date );
    ec_debug.pl ( 3, 'iRun_id: ',iRun_id );
    ec_debug.pl ( 3, 'p_document_type: ',p_document_type );
    ec_debug.pl ( 3, 'p_schedule_id: ',p_schedule_id );
    ec_debug.pl ( 3, 'cHeader_Interface: ',cHeader_Interface );
    ec_debug.pl ( 3, 'cItem_Interface: ',cItem_Interface );
    ec_debug.pl ( 3, 'cItem_D_Interface: ',cItem_D_Interface );

    -- Retreive the system profile option ECE_OUT_FILE_PATH.  This will
    -- be the directory where the output file will be written.
    -- NOTE: THIS DIRECTORY MUST BE SPECIFIED IN THE PARAMETER utl_file_dir IN
    -- THE INIT.ORA FILE.  Refer to the Oracle7 documentation for more information
    -- on the package UTL_FILE.

    xProgress := 'SPSOB-10-0100';
    fnd_profile.get ( 'ECE_OUT_FILE_PATH',
                       cOutput_path );
    ec_debug.pl ( 3, 'cOutput_path: ',cOutput_path );


    xProgress := 'SPSOB-10-1000';
    ece_flatfile_pvt.INIT_TABLE ( cTransaction_Type,
                                  cHeader_Interface,
                                  NULL,
                                  FALSE,
                                  l_header_tbl,
                                  l_key_tbl );

    xProgress := 'SPSOB-10-1020';
    l_key_tbl := l_header_tbl;

    xProgress := 'SPSOB-10-1030';
    ece_flatfile_pvt.INIT_TABLE ( cTransaction_Type,
                                  cItem_Interface,
                                  NULL,
                                  TRUE,
                                  l_item_tbl,
                                  l_key_tbl );


    -- ***************************************************************************
    --
    -- Here, I am building the SELECT, FROM, and WHERE  clauses for the dynamic
    -- SQL call
    -- The ece_extract_utils_pub.select_clause uses the EDI data dictionary for the build.
    --
    -- **************************************************************************

    xProgress := 'SPSOB-10-1040';
    ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                          cCommunication_Method,
                                          cHeader_Interface,
                                          l_header_tbl,
                                          cHeader_select,
                                          cHeader_from,
                                          cHeader_where );

    xProgress := 'SPSOB-10-1050';
    ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                          cCommunication_Method,
                                          cItem_Interface,
                                          l_item_tbl,
                                          cItem_select,
                                          cItem_from,
                                          cItem_where );

    -- **************************************************************************
    --  Here, I am customizing the WHERE clause to join the Interface tables together.
    --  i.e. Headers -- Items -- Item Details
    --
    --  Select  Data1, Data2, Data3...........
    --  From    Header_View
    --  Where   A.Transaction_Record_ID = D.Transaction_Record_ID (+)
    --  and B.Transaction_Record_ID = E.Transaction_Record_ID (+)
    --  and C.Transaction_Record_ID = F.Transaction_Record_ID (+)
    -- ******* (Customization should be added here) ********
    --  and A.Communication_Method = 'EDI'
    --  and A.xxx = B.xxx   ........
    --  and B.yyy = C.yyy   .......
    -- **************************************************************************
    -- **************************************************************************
    --  :po_header_id is a place holder for foreign key value.
    --  A PL/SQL table (list of values) will be used to store data.
    --  Procedure ece_flatfile_pvt.Find_pos will be used to locate the specific
    --  data value in the PL/SQL table.
    --  dbms_sql (Native Oracle db functions that come with every Oracle Apps)
    --  dbms_sql.bind_variable will be used to assign data value to :transaction_id.
    --
    --  Let's use the above example:
    --
    --  1. Execute dynamic SQL 1 for headers (A) data
    --      Get value of A.xxx (foreign key to B)
    --
    --  2. bind value A.xxx to variable B.xxx
    --
    --  3. Execute dynamic SQL 2 for items (B) data
    --      Get value of B.yyy (foreigh key to C)
    --
    --  4. bind value B.yyy to variable C.yyy
    --
    --  5. Execute dynamic SQL 3 for line_details (C) data
    -- **************************************************************************
    -- **************************************************************************
    --   Change the following few lines as needed
    -- **************************************************************************

    xProgress := 'SPSOB-10-1060';
    IF cTransaction_Type = 'SPSO'
    THEN

      cHeader_view := 'ECE_SPSO_HEADERS_V';
      cItem_view   := 'ECE_SPSO_ITEMS_V';

    ELSIF cTransaction_Type = 'SSSO'
    THEN

      cHeader_view := 'ECE_SSSO_HEADERS_V';
      cItem_view   := 'ECE_SSSO_ITEMS_V';

    END IF;

    ec_debug.pl ( 3, 'cHeader_view: ',cHeader_view );
    ec_debug.pl ( 3, 'cItem_view: ',cItem_view );

    -- *****************************
    -- if user passed in a 0 (zero)
    -- select everything
    -- *****************************
/* Bug 2064311
  Appended batch_id to the  where condition of header view
  to improve performance . Batch id is appended when this transaction
  is launched thru supplier scheduling.

  batch id is defaulted as zero when this transaction is launched
  thru EDI
*/

    xProgress     := 'SPSOB-10-1070';

if p_batch_id = 0 then
    cHeader_where := cHeader_where                           ||
                     cHeader_view                            ||
                     '.COMMUNICATION_METHOD IN (''BOTH'','   ||
                     ':l_cCommunication_Method'              ||
                     ')'                                     ||
                     ' AND (('                               ||
                     cHeader_view                            ||
                     '.SCHEDULE_ID = :l_p_schedule_id'       ||
                     ' AND '                                 ||
                     ':l_p_schedule_id'                      ||
                     '<> 0)'                                 ||
                     ' OR '                                  ||
                     ':l_p_schedule_id'                      ||
                     ' = 0)';

else

 cHeader_where := cHeader_where ||
         cHeader_view ||'.COMMUNICATION_METHOD in (''BOTH'','||
            ':l_cCommunication_Method'|| ')' ||
        ' AND (('|| cHeader_view ||'.SCHEDULE_ID = '||':l_p_schedule_id' ||
                ' and '|| p_schedule_id || '<> 0)' ||
    ' OR ' || ':l_p_schedule_id' || ' = 0)'|| 'AND ' || cHeader_view||'.BATCH_ID='||':l_p_batch_id';

end if;

  ec_debug.pl ( 3, 'cHeader_where: ',cHeader_where );

    xProgress     := 'SPSOB-10-1080';
    cItem_where   := cItem_where                             ||
                     cItem_view                              ||
                     '.SCHEDULE_ID = :schedule_id';

    ec_debug.pl ( 3, 'cItem_where: ',cItem_where );

    xProgress      := 'SPSOB-10-1090';
    cHeader_select := cHeader_select                         ||
                      cHeader_from                           ||
                      cHeader_where;

    ec_debug.pl ( 3, 'cHeader_select: ',cHeader_select );

    xProgress      := 'SPSOB-10-1100';
    cItem_select   := cItem_select                           ||
                      cItem_from                             ||
                      cItem_where;

    ec_debug.pl ( 3, 'cItem_select: ',cItem_select );

    -- ***************************************************
    -- ***
    -- ***   Get data setup for the dynamic SQL call.
    -- ***
    -- ***   Open a cursor for each of the SELECT call
    -- ***   This tells the database to reserve spaces
    -- ***   for the data returned by the SQL statement
    -- ***
    -- ***************************************************

    xProgress    := 'SPSOB-10-1110';
    Header_sel_c := dbms_sql.open_cursor;

    xProgress    := 'SPSOB-10-1120';
    Item_sel_c   := dbms_sql.open_cursor;

    -- ***************************************************
    --
    --   Parse each of the SELECT statement
    --   so the database understands the command
    --
    -- ***************************************************

    xProgress := 'SPSOB-10-1130';
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

    xProgress := 'SPSOB-10-1140';
    BEGIN
      dbms_sql.parse ( Item_sel_c,
                       cItem_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cItem_select );
        app_exception.raise_exception;
    END;

    -- *************************************************
    -- set counter
    -- *************************************************

    xProgress     := 'SPSOB-10-1150';
    iHeader_count := l_header_tbl.count;

    xProgress     := 'SPSOB-10-1160';
    iItem_count   := l_item_tbl.count;


    -- ***************************************************
    --
    --  Define TYPE for every columns in the SELECT statement
    --  For each piece of the data returns, we need to tell
    --  the database what type of information it will be.
    --
    --  e.g. ID is NUMBER, due_date is DATE
    --  However, for simplicity, we will convert
    --  everything to varchar2.
    --
    -- ***************************************************

    xProgress := 'SPSOB-10-1170';
    FOR k IN 1..iHeader_count
    LOOP
      dbms_sql.define_column ( Header_sel_c,
                               k,
                               cHeader_select,
                               ece_extract_utils_PUB.G_MaxColWidth );
    END LOOP;


    xProgress := 'SPSOB-10-1180';
    FOR k IN 1..iItem_count
    LOOP
      dbms_sql.define_column ( Item_sel_c,
                               k,
                               cItem_select,
                               ece_extract_utils_PUB.G_MaxColWidth );
    END LOOP;

    -- **************************************************************
    -- ***  The following is custom tailored for this transaction
    -- ***  It find the values and use them in the WHERE clause to
    -- ***  join tables together.
    -- **************************************************************

    -- ***************************************************
    -- To complete the Item SELECT statement,
    --  we will need values for the join condition.
    --
    -- ***************************************************

    xProgress      := 'SPSOB-10-1190';
    n_trx_date_pos := ece_extract_utils_pub.POS_OF ( l_header_tbl,
                                                     ece_extract_utils_pub.G_Transaction_date );
    ec_debug.pl ( 3, 'n_trx_date_pos: ',n_trx_date_pos );

    xProgress             := 'SPSOB-10-1200';
    n_vendor_id_pos       := ece_extract_utils_pub.POS_OF ( l_header_tbl,
                                                            'VENDOR_ID' );
    ec_debug.pl ( 3, 'n_vendor_id_pos: ',n_vendor_id_pos );

    xProgress             := 'SPSOB-10-1210';
    n_vendor_site_id_pos  := ece_extract_utils_pub.POS_OF ( l_header_tbl,
                                                            'VENDOR_SITE_ID' );
    ec_debug.pl ( 3, 'n_vendor_site_id_pos: ',n_vendor_site_id_pos );

    xProgress             := 'SPSOB-10-1220';
    n_organization_id_pos := ece_extract_utils_pub.POS_OF ( l_header_tbl,
                                                            'ORGANIZATION_ID' );
    ec_debug.pl ( 3, 'n_organization_id_pos: ',n_organization_id_pos );

    xProgress             := 'SPSOB-10-1230';
    n_st_org_code_pos     := ece_extract_utils_pub.POS_OF ( l_header_tbl,
                                                            'ST_ORG_CODE' );
    ec_debug.pl ( 3, 'n_st_org_code_pos: ',n_st_org_code_pos );

    xProgress             := 'SPSOB-10-1240';
    n_schedule_type_pos   := ece_extract_utils_pub.POS_OF ( l_header_tbl,
                                                            'SCHEDULE_TYPE' );
    ec_debug.pl ( 3, 'n_schedule_type_pos: ',n_schedule_type_pos );

    xProgress             := 'SPSOB-10-1250';
    n_st_name_pos         := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_NAME' );
    ec_debug.pl ( 3, 'n_st_name_pos: ',n_st_name_pos );

    ece_extract_utils_pub.Find_pos ( l_header_tbl,
                                     'SCHEDULE_ID',
                                     n_schedule_id_pos );
    ec_debug.pl ( 3, 'n_schedule_id_pos: ',n_schedule_id_pos );

    xProgress             := 'SPSOB-10-1260';
    n_item_id_pos         := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'SCHEDULE_ITEM_ID' );
    ec_debug.pl ( 3, 'n_item_id_pos: ',n_item_id_pos );

    xProgress := 'SPSOB-10-1270';
    n_enable_cum_flag_pos := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ENABLE_CUM_FLAG' );
    ec_debug.pl ( 3, 'n_enable_cum_flag_pos: ',n_enable_cum_flag_pos );

    xProgress := 'SPSOB-10-1280';
    n_cum_period_pos      := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'CUM_PERIOD_START_DATE' );
    ec_debug.pl ( 3, 'n_cum_period_pos: ',n_cum_period_pos );

    xProgress := 'SPSOB-10-1290';
    n_item_st_org_pos     := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_ORG_CODE' );
    ec_debug.pl ( 3, 'n_item_st_org_pos: ',n_item_st_org_pos );

    xProgress := 'SPSOB-10-1300';
    n_st_add_1_pos        := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_ADDRESS_LINE1' );
    ec_debug.pl ( 3, 'n_st_add_1_pos: ',n_st_add_1_pos );

    xProgress := 'SPSOB-10-1310';
    n_st_add_2_pos        := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_ADDRESS_LINE2' );
    ec_debug.pl ( 3, 'n_st_add_2_pos: ',n_st_add_2_pos );

    xProgress := 'SPSOB-10-1320';
    n_st_add_3_pos        := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_ADDRESS_LINE3' );
    ec_debug.pl ( 3, 'n_st_add_3_pos: ',n_st_add_3_pos );

    xProgress := 'SPSOB-10-1330';
    n_st_city_pos         := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_CITY' );
    ec_debug.pl ( 3, 'n_st_city_pos: ',n_st_city_pos );

    xProgress := 'SPSOB-10-1340';
    n_st_county_pos       := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_COUNTY' );
    ec_debug.pl ( 3, 'n_st_county_pos: ',n_st_county_pos );

    xProgress := 'SPSOB-10-1350';
    n_st_state_pos        := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_STATE' );
    ec_debug.pl ( 3, 'n_st_state_pos: ',n_st_state_pos );

    xProgress := 'SPSOB-10-1360';
    n_st_country_pos      := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_COUNTRY' );
    ec_debug.pl ( 3, 'n_st_country_pos: ',n_st_country_pos );

    xProgress := 'SPSOB-10-1370';
    n_st_postal_pos       := ece_extract_utils_pub.POS_OF ( l_item_tbl,
                                                            'ST_POSTAL_CODE' );
    ec_debug.pl ( 3, 'n_st_postal_pos: ',n_st_postal_pos );

    xProgress := 'SPSOB-10-1371';
    dbms_sql.bind_variable(Header_sel_c,'l_cCommunication_Method',cCommunication_Method);

    xProgress := 'SPSOB-10-1372';
    dbms_sql.bind_variable(Header_sel_c,'l_p_schedule_id',p_schedule_id);

    xProgress := 'SPSOB-10-1373';
    if (p_batch_id <>0) then
    dbms_sql.bind_variable(Header_sel_c,'l_p_batch_id',p_batch_id);
    end if;
    --  EXECUTE the SELECT statement

    xProgress := 'SPSOB-10-1380';
    dummy     := dbms_sql.execute ( Header_sel_c );

    -- ***************************************************
    --
    --  The model is:
    --   HEADER - ITEM - ITEM_D ...
    --
    --   With data for each HEADER line, populate the header interface
    --   table then get all ITEMS that belongs
    --   to the HEADER. Then get all
    --   ITEM_DS that belongs to the ITEM.
    --
    -- ***************************************************


    xProgress := 'SPSOB-10-1390';
    WHILE dbms_sql.fetch_rows ( Header_sel_c ) > 0
    LOOP           -- Header

      --  ***************************************************
      --
      --  store internal values in pl/sql table
      --
      --  ***************************************************

      xProgress := 'SPSOB-10-1400';
      FOR i IN 1..iHeader_count
      LOOP
        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_header_tbl(i).value );

        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_key_tbl(i).value );
      END LOOP;

      --  ***************************************************
      --
      --  also need to populate transaction_date and run_id
      --
      --  ***************************************************

      xProgress                          := 'SPSOB-10-1410';
      l_header_tbl(n_trx_date_pos).value := TO_CHAR(dTransaction_date,'YYYYMMDD HH24MISS');
      ec_debug.pl ( 3, 'l_header_tbl(n_trx_date_pos).value: ',l_header_tbl(n_trx_date_pos).value );

      --  pass the pl/sql table in for xref

      xProgress := 'SPSOB-10-1420';
      ec_code_Conversion_pvt.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                              p_init_msg_list      => l_init_msg_list,
                                                              p_simulate           => l_simulate,
                                                              p_commit             => l_commit,
                                                              p_validation_level   => l_validation_level,
                                                              p_return_status      => l_return_status,
                                                              p_msg_count          => l_msg_count,
                                                              p_msg_data           => l_msg_data,
                                                              p_key_tbl            => l_key_tbl,
                                                              p_tbl                => l_header_tbl );

      xProgress := 'SPSOB-10-1430';
      IF l_return_status = FND_API.G_RET_STS_ERROR
      OR l_return_status is NULL
      OR l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE fail_convert_to_ext;
      END IF;

      xProgress := 'SPSOB-10-1431';
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--        begin
--         select count(*) into
--         x_schedule_order from
--         chv_item_orders where
--         schedule_id = l_header_tbl(n_schedule_id_pos).value;
--        exception
--         when others then
--          null;
--        end;
    -- 2944455
      fnd_profile.get('ECE_SPSO_EXCLUDE_ZERO_SCHEDULE_FROM_FF',exclude_zero_schedule_from_ff);
              If NVL(exclude_zero_schedule_from_ff,'N')<>'Y' then
                    exclude_zero_schedule_from_ff := 'N';
              End If;
      --  ******************************************
      --
      --  insert into interface table
      --
      --  ******************************************
      if ((exclude_zero_schedule_from_ff = 'N')
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--           OR
--           (x_schedule_order > 0)
	  )  Then    -- 2944455
      xProgress := 'SPSOB-10-1440';
      BEGIN
        SELECT ece_spso_headers_s.nextval
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
                        'ECE_SPSO_HEADERS_S' );
      END;


      xProgress := 'SPSOB-10-1450';
      ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id                => iRun_id,
                                                        cTransaction_Type      => cTransaction_Type,
                                                        cCommunication_Method  => cCommunication_Method,
                                                        cInterface_Table       => cHeader_Interface,
                                                        p_source_tbl           => l_header_tbl,
                                                        p_foreign_key          => l_header_fkey );

      --  Now update the columns values of which have been obtained thru the procedure
      --  calls.

      --  ******************************************
      --
      --  Call custom program stub to populate the extension table
      --
      --  ******************************************

      xProgress := 'SPSOB-10-1460';
      ece_spso_x.populate_extension_headers ( l_header_fkey,
                                              l_header_tbl );

      --  ***************************************************
      --
      --  From Header data, we can assign values to
      --  place holders (foreign keys) in Item_select and
      --  Item_detail_Select
      --
      --  ***************************************************
      --  set values into binding variables
      --
      --  ***************************************************

      --  use the following bind_variable feature as you see fit.

      dbms_sql.bind_variable ( Item_sel_c,
                               'schedule_id',
                               l_header_tbl(n_schedule_id_pos).value );

      xProgress := 'SPSOB-10-1470';
      dummy     := dbms_sql.execute ( Item_sel_c );

      --  ***************************************************
      --
      --  item loop starts here
      --
      --  ***************************************************

      xProgress := 'SPSOB-10-1480';
      WHILE dbms_sql.fetch_rows ( Item_sel_c ) > 0
      LOOP        --- Item

        --    ***************************************************
        --
        --    store values in pl/sql table
        --
        --    ***************************************************


        xProgress := 'SPSOB-10-1490';
        FOR j IN 1..iItem_count
        LOOP
          dbms_sql.column_value ( Item_sel_c,
                                  j,
                                  l_item_tbl(j).value );

          dbms_sql.column_value ( Item_sel_c,
                                  j,
                                  l_key_tbl(j+iHeader_count).value );
        END LOOP;

        xProgress := 'SPSOB-10-1500';
/* Bug 1705597.
   Get item_id for the corresponding schedule_item_id
   from the view ece_spso_items_v and use this value
   in the following query to get asl_id and other data
*/

begin

select item_id into g_item_id from chv_schedule_items where
schedule_item_id = l_item_tbl(n_item_id_pos).value;

exception
when no_data_found then null;
when others then null;
end;



        BEGIN
          SELECT
            paa.asl_id,
            paa.enable_authorizations_flag,
            paa.scheduler_id,
            ppf.first_name,
            ppf.last_name,
            ppf.work_telephone,
            paa.attribute_category,
            paa.attribute1,
            paa.attribute2,
            paa.attribute3,
            paa.attribute4,
            paa.attribute5,
            paa.attribute6,
            paa.attribute7,
            paa.attribute8,
            paa.attribute9,
            paa.attribute10,
            paa.attribute11,
            paa.attribute12,
            paa.attribute13,
            paa.attribute14,
            paa.attribute15
          INTO
            x_asl_id,
            x_enable_authorizations_flag,
            x_scheduler_id,
            x_scheduler_first_name,
            x_scheduler_last_name,
            x_scheduler_work_telephone,
            x_asl_attribute_category,
            x_asl_attribute1,
            x_asl_attribute2,
            x_asl_attribute3,
            x_asl_attribute4,
            x_asl_attribute5,
            x_asl_attribute6,
            x_asl_attribute7,
            x_asl_attribute8,
            x_asl_attribute9,
            x_asl_attribute10,
            x_asl_attribute11,
            x_asl_attribute12,
            x_asl_attribute13,
            x_asl_attribute14,
            x_asl_attribute15
          FROM
            po_asl_attributes   paa,
            per_all_people_f        ppf
          WHERE
                paa.vendor_id             = l_header_tbl(n_vendor_id_pos).value
            AND paa.vendor_site_id        = l_header_tbl(n_vendor_site_id_pos).value
            AND paa.item_id               = g_item_id --Bug 1705597
            AND paa.using_organization_id = chv_inq_sv.get_asl_org(
                                                       l_header_tbl(n_organization_id_pos).value,
                                                       l_header_tbl(n_vendor_id_pos).value,
                                                       l_header_tbl(n_vendor_site_id_pos).value,
                                                       g_item_id)  -- Bug 1705597
            AND scheduler_id              =   ppf.person_id(+)
	    AND ppf.effective_start_date (+) >= trunc(SYSDATE)
	    AND ppf.effective_end_date (+) <= trunc(SYSDATE)
	    AND decode(hr_security.view_all,'Y','TRUE',hr_security.show_record('PER_ALL_PEOPLE_F',
				ppf.person_id (+),
				ppf.person_type_id (+),
				ppf.employee_number (+),
				ppf.applicant_number (+) ))= 'TRUE';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 1,
                          'EC',
                          'ECE_NO_ROW_SELECTED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'INFO',
                          'ASL_ID',
                          'TABLE_NAME',
                          'PO_ASL_ATTRIBUTES' );
        END;

        ec_debug.pl ( 3, 'x_asl_id: ',x_asl_id );
        ec_debug.pl ( 3, 'x_enable_authorizations_flag: ',x_enable_authorizations_flag );
        ec_debug.pl ( 3, 'x_scheduler_id: ',x_scheduler_id );
        ec_debug.pl ( 3, 'x_scheduler_first_name: ',x_scheduler_first_name );
        ec_debug.pl ( 3, 'x_scheduler_last_name: ',x_scheduler_last_name );
        ec_debug.pl ( 3, 'x_scheduler_work_telephone: ',x_scheduler_work_telephone );
        ec_debug.pl ( 3, 'x_asl_attribute_category: ',x_asl_attribute_category );
        ec_debug.pl ( 3, 'x_asl_attribute1: ',x_asl_attribute1 );
        ec_debug.pl ( 3, 'x_asl_attribute2: ',x_asl_attribute2 );
        ec_debug.pl ( 3, 'x_asl_attribute3: ',x_asl_attribute3 );
        ec_debug.pl ( 3, 'x_asl_attribute4: ',x_asl_attribute4 );
        ec_debug.pl ( 3, 'x_asl_attribute5: ',x_asl_attribute5 );
        ec_debug.pl ( 3, 'x_asl_attribute6: ',x_asl_attribute6 );
        ec_debug.pl ( 3, 'x_asl_attribute7: ',x_asl_attribute7 );
        ec_debug.pl ( 3, 'x_asl_attribute8: ',x_asl_attribute8 );
        ec_debug.pl ( 3, 'x_asl_attribute9: ',x_asl_attribute9 );
        ec_debug.pl ( 3, 'x_asl_attribute10: ',x_asl_attribute10 );
        ec_debug.pl ( 3, 'x_asl_attribute11: ',x_asl_attribute11 );
        ec_debug.pl ( 3, 'x_asl_attribute12: ',x_asl_attribute12 );
        ec_debug.pl ( 3, 'x_asl_attribute13: ',x_asl_attribute13 );
        ec_debug.pl ( 3, 'x_asl_attribute14: ',x_asl_attribute14 );
        ec_debug.pl ( 3, 'x_asl_attribute15: ',x_asl_attribute15 );

        BEGIN
          xProgress := 'SPSOB-10-1510';
          SELECT    primary_vendor_item
            INTO    x_supplier_product_num
            FROM    po_approved_supplier_list
           WHERE    asl_id      =   x_asl_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 1,
                          'EC',
                          'ECE_NO_ROW_SELECTED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'INFO',
                          'PRIMARY_VENDOR_ITEM',
                          'TABLE_NAME',
                          'PO_APPROVED_SUPPLIER_LIST' );
        END;

        ec_debug.pl ( 3, 'x_supplier_product_num: ',x_supplier_product_num );


        BEGIN           -- Planner information
         xProgress := 'SPSOB-10-1520';
         SELECT last_name,
                first_name,
                work_telephone
           INTO x_planner_last_name,
                x_planner_first_name,
                x_planner_work_telephone
           FROM mtl_system_items    msi,
                mtl_planners        mpl,
                per_all_people_f        ppf
          WHERE msi.organization_id   = l_header_tbl(n_organization_id_pos).value
            AND msi.inventory_item_id = g_item_id -- Bug 1705597
            AND mpl.organization_id   = l_header_tbl(n_organization_id_pos).value
            AND msi.planner_code      = mpl.planner_code(+)
            AND mpl.employee_id       = ppf.person_id(+)
	    AND ppf.effective_start_date (+) >= trunc(SYSDATE)
	    AND ppf.effective_end_date (+) <= trunc(SYSDATE)
	    AND decode(hr_security.view_all,'Y','TRUE',hr_security.show_record('PER_ALL_PEOPLE_F',
				ppf.person_id (+),
				ppf.person_type_id (+),
				ppf.employee_number (+),
				ppf.applicant_number (+) ))= 'TRUE';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 1,
                          'EC',
                          'ECE_NO_ROW_SELECTED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'INFO',
                          'LAST_NAME',
                          'TABLE_NAME',
                          'MTL_SYSTEM_ITEMS' );
        END;

        ec_debug.pl ( 3, 'x_planner_last_name: ',x_planner_last_name );
        ec_debug.pl ( 3, 'x_planner_first_name: ',x_planner_first_name );
        ec_debug.pl ( 3, 'x_planner_work_telephone: ',x_planner_work_telephone );

   --   pass the pl/sql table in for xref


        xProgress := 'SPSOB-10-1530';
        ec_code_Conversion_pvt.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                                p_init_msg_list      => l_init_msg_list,
                                                                p_simulate           => l_simulate,
                                                                p_commit             => l_commit,
                                                                p_validation_level   => l_validation_level,
                                                                p_return_status      => l_return_status,
                                                                p_msg_count          => l_msg_count,
                                                                p_msg_data           => l_msg_data,
                                                                p_key_tbl            => l_key_tbl,
                                                                p_tbl                => l_item_tbl );

        xProgress := 'SPSOB-10-1540';
        IF l_return_status =  FND_API.G_RET_STS_ERROR
        OR l_return_status IS NULL
        OR l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
        THEN
          RAISE fail_convert_to_ext;
        END IF;

        BEGIN
          xProgress := 'SPSOB-10-1550';
          SELECT ece_spso_items_s.nextval
            INTO l_item_fkey
            FROM sys.dual;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 0,
                          'EC',
                          'ECE_GET_NEXT_SEQ_FAILED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'SEQ',
                          'ECE_SPSO_ITEMS_S' );
        END;

        ec_debug.pl ( 3, 'l_item_fkey: ',l_item_fkey );
        xProgress := 'SPSOB-10-1551';
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--               Begin
--                Select  count(schedule_id)
--                Into    x_item_detail
--                From    chv_item_orders
--                Where   schedule_id =  l_header_tbl(n_schedule_id_pos).value
--                And     schedule_item_id = l_item_tbl(n_item_id_pos).value;
--               Exception
--                when others then null;
--               End;
       if ((exclude_zero_schedule_from_ff = 'N')
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--          OR
--          (x_item_detail > 0)
	  )  Then                 --2944455

        xProgress := 'SPSOB-10-1560';
        ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id                => iRun_id,
                                                          cTransaction_Type      => cTransaction_Type,
                                                          cCommunication_Method  => cCommunication_Method,
                                                          cInterface_Table       => cItem_Interface,
                                                          p_source_tbl           => l_item_tbl,
                                                          p_foreign_key          => l_item_fkey );

        xProgress := 'SPSOB-10-1570';
        UPDATE ece_spso_items
           SET supplier_product_number       = x_supplier_product_num,
               item_scheduler_last_name      = x_scheduler_last_name,
               item_scheduler_first_name     = x_scheduler_first_name,
               item_scheduler_work_telephone = x_scheduler_work_telephone,
               item_planner_last_name        = x_planner_last_name,
               item_planner_first_name       = x_planner_first_name,
               item_planner_work_telephone   = x_planner_work_telephone,
               asl_attribute_category        = x_asl_attribute_category,
               asl_attribute1                = x_asl_attribute1,
               asl_attribute2                = x_asl_attribute2,
               asl_attribute3                = x_asl_attribute3,
               asl_attribute4                = x_asl_attribute4,
               asl_attribute5                = x_asl_attribute5,
               asl_attribute6                = x_asl_attribute6,
               asl_attribute7                = x_asl_attribute7,
               asl_attribute8                = x_asl_attribute8,
               asl_attribute9                = x_asl_attribute9,
               asl_attribute10               = x_asl_attribute10,
               asl_attribute11               = x_asl_attribute11,
               asl_attribute12               = x_asl_attribute12,
               asl_attribute13               = x_asl_attribute13,
               asl_attribute14               = x_asl_attribute14,
               asl_attribute15               = x_asl_attribute15,
               ship_to_org_enable_cum_flag   =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_enable_cum_flag_pos).value),
               ship_to_org_cum_start_date    =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,to_date(l_item_tbl(n_cum_period_pos).value,'YYYYMMDD HH24MISS')),
               ship_to_org_name              =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_name_pos).value),
               ship_to_org_code              =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_item_st_org_pos).value),
               ship_to_org_address_line_1    =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_add_1_pos).value),
               ship_to_org_address_line_2    =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_add_2_pos).value),
               ship_to_org_address_line_3    =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_add_3_pos).value),
               ship_to_org_city              =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_city_pos).value),
               ship_to_org_region_1          =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_county_pos).value),
               ship_to_org_region_2          =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_state_pos).value),
               ship_to_org_country           =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_country_pos).value),
               ship_to_org_postal_code       =
          DECODE(DECODE(l_header_tbl(n_schedule_type_pos).value, 'SHIP_SCHEDULE','N',
                        DECODE(NVL(l_header_tbl(n_st_org_code_pos).value,'-1'),'-1','Y','N')),
                 'N', NULL,l_item_tbl(n_st_postal_pos).value)
         WHERE
           transaction_record_id = l_item_fkey;

        IF SQL%NOTFOUND
        THEN
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_NO_ROW_UPDATED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'INFO',
                        'SUPPLIER_PRODUCT_NUMBER',
                        'TABLE_NAME',
                        'ECE_SPSO_ITEMS' );
        END IF;

        --    ******************************************
        --
        --    Call custom program stub to populate the extension table
        --
        --    ******************************************

        xProgress := 'SPSOB-10-1580';
        ece_spso_x.populate_extension_items ( l_item_fkey,
                                              l_item_tbl );
       END IF;
      END LOOP;

      xProgress := 'SPSOB-10-1583';
      IF ( dbms_sql.last_row_count = 0 )
      THEN
        v_LevelProcessed := 'ITEM';
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_DB_ROW_PROCESSED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'LEVEL_PROCESSED',
                      v_LevelProcessed,
                      'TRANSACTION_TYPE',
                      cTransaction_Type );
      END IF;
     END IF;
    END LOOP;

    xProgress := 'SPSOB-10-1586';
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

    xProgress := 'SPSOB-10-1590';
    dbms_sql.close_cursor ( Header_sel_c );

    xProgress := 'SPSOB-10-1600';
    dbms_sql.close_cursor ( Item_sel_c );

    ec_debug.pop ( 'ECE_SPSO_TRANS1.populate_supplier_sched_api1' );

  EXCEPTION
    WHEN fail_convert_to_ext THEN

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_XREF_NOT_FOUND',
                    NULL );

      ec_debug.pl ( 0,
                    'EC',
                    'ECE_ERROR_MESSAGE',
                    'ERROR_MESSAGE',
                    SQLERRM );

      app_exception.raise_exception;

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

  END Populate_Supplier_Sched_API1;


  -- ***********************************************
  --
  --  PROCEDURE Populate_Supplier_Sched_API3
  --
  -- ***********************************************


  PROCEDURE Populate_Supplier_Sched_API3 ( p_communication_method  IN  VARCHAR2,   -- EDI
                                           p_transaction_type      IN  VARCHAR2,   -- plan SPSO, ship SSSO
                                           p_document_type         IN  VARCHAR2,   -- plan SPS, ship SSS
                                           p_run_id                IN  NUMBER,
                                           p_schedule_id           IN  INTEGER  DEFAULT 0,
                                           p_batch_id              IN  NUMBER )  -- Bug 2064311
 IS

    xProgress                     VARCHAR2(30) := NULL;
    v_LevelProcessed              VARCHAR2(40);
    cOutput_path                  VARCHAR2(120);
    l_transaction_number          NUMBER := 0;  -- Bug 1742567
    exclude_zero_schedule_from_ff VARCHAR2(1) := 'N';  -- 2944455
    /****************************
    **    SELECT HEADER        **
    ****************************/

    CURSOR sch_hdr_c IS
     SELECT
      csh.schedule_id             SCHEDULE_ID,
      CSH.BATCH_ID                    BATCH_ID,  --Bug 2064311
      csh.organization_id         ORGANIZATION_ID,
      csh.vendor_id               VENDOR_ID,
      csh.vendor_site_id          VENDOR_SITE_ID,
      csh.schedule_type           SCHEDULE_TYPE,
      csh.schedule_horizon_start  FORECAST_HORIZON_START_DATE,
      csh.edi_count               EDI_COUNT,
      ccp.cum_period_start_date   SHIP_TO_ORG_CUM_START,
      etd.document_id             TRANSACTION_TYPE
     FROM
      chv_cum_periods             ccp,
      ece_tp_details              etd,
      po_vendor_sites             pvs,
      chv_schedule_headers        csh,
      chv_org_options		  coo
     WHERE
           csh.schedule_status    =   'CONFIRMED'
       AND etd.edi_flag           =   'Y'     -- EDI
       AND etd.document_id        =   p_transaction_type --ship SSSO,plan SPSO
       AND p_transaction_type     =   DECODE(schedule_type,
                                             'SHIP_SCHEDULE', 'SSSO',
                                             'SPSO')
       AND ((csh.schedule_id      =   p_schedule_id
             AND p_schedule_id   <> 0)
             OR  (p_schedule_id   = 0))
       AND  CSH.BATCH_ID = decode(P_BATCH_ID,0,CSH.BATCH_ID,P_BATCH_ID) -- Bug 2064311
       AND NVL(csh.communication_code,'NONE') IN  ('BOTH','EDI')
       AND csh.vendor_site_id     =   pvs.vendor_site_id
       AND pvs.tp_header_id       =   etd.tp_header_id
       AND csh.organization_id    =   ccp.organization_id(+)
       AND csh.organization_id    =   coo.organization_id(+)
       AND (
		( coo.enable_cum_flag = 'N' )
		or
		(	( coo.enable_cum_flag = 'Y')
       			AND
			(
				(
					ccp.cum_period_end_date IS NULL
             				AND 	csh.schedule_horizon_start >= ccp.cum_period_start_date
				)
             			OR
				( 	csh.schedule_horizon_start BETWEEN ccp.cum_period_start_date
					AND ccp.cum_period_end_date
				)
		        )
		)
	    )
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--       AND EXISTS (SELECT 1 FROM CHV_ITEM_ORDERS CIO
--                   WHERE CIO.SCHEDULE_ID = CSH.SCHEDULE_ID)
     ORDER BY
      csh.schedule_id
     FOR  UPDATE;

  BEGIN                -- begin header block

    ec_debug.push ( 'ECE_SPSO_TRANS1.populate_supplier_sched_api3' );
    ec_debug.pl ( 3, 'p_communication_method: ', p_communication_method );
    ec_debug.pl ( 3, 'p_transaction_type: ',p_transaction_type );
    ec_debug.pl ( 3, 'p_document_type: ',p_document_type );
    ec_debug.pl ( 3, 'p_run_id: ',p_run_id );
    ec_debug.pl ( 3, 'p_schedule_id: ',p_schedule_id );


    -- Retreive the system profile option ECE_OUT_FILE_PATH.  This will
    -- be the directory where the output file will be written.
    -- NOTE: THIS DIRECTORY MUST BE SPECIFIED IN THE PARAMETER utl_file_dir IN
    -- THE INIT.ORA FILE.  Refer to the Oracle7 documentation for more information
    -- on the package UTL_FILE.

    xProgress := 'SPSOB-30-0100';
    fnd_profile.get('ECE_OUT_FILE_PATH',
                    cOutput_path);
    ec_debug.pl ( 3, 'cOutput_path: ',cOutput_path );


    <<header>>

    xProgress := 'SPSOB-30-1000';
    FOR rec_hdr IN sch_hdr_c
    LOOP

      /**************************
      **    SELECT ITEM        **
      **************************/

      DECLARE
        x_transaction_date            DATE;
        x_last_quantity               NUMBER;
        x_shipment_num                VARCHAR2(30);

        x_item_detail_sequence        NUMBER :=0;

        x_enable_authorizations_flag  VARCHAR2(1);

        x_transaction_record_id       NUMBER;

        CURSOR  sch_item_c  IS
          SELECT
           csi.schedule_id                   SCHEDULE_ID,
           csi.schedule_item_id              SCHEDULE_ITEM_ID,
           csi.item_id                       ITEM_ID,
           csi.starting_auth_quantity        STARTING_AUTH_QUANTITY,
           csi.starting_cum_quantity         STARTING_CUM_QUANTITY,
           coo.enable_cum_flag               SHIP_TO_ORG_ENABLE_CUM_FLAG,
           ccp.cum_period_start_date         SHIP_TO_ORG_CUM_PERIOD_START,
           csi.last_receipt_transaction_id   LAST_RECEIPT_TRANSACTION_ID,
           csi.purchasing_unit_of_measure    PURCHASING_UNIT_OF_MEASURE
          FROM
           chv_schedule_headers              csh,
           chv_schedule_items                csi,
           chv_org_options                   coo,
           chv_cum_periods                   ccp,
           mtl_item_flexfields               mif,
           mtl_parameters                    mtp
          WHERE
                csi.schedule_id              = rec_hdr.schedule_id
            AND csi.schedule_id              = csh.schedule_id
            AND csi.organization_id          = coo.organization_id
            AND csi.organization_id          = mtp.organization_id
            AND csi.item_id                  = mif.item_id
            AND csi.organization_id          = mif.organization_id
            AND csi.organization_id          = ccp.organization_id(+)
	    AND  (
		     (COO.ENABLE_CUM_FLAG = 'N')
		      OR
		     (
			( COO.ENABLE_CUM_FLAG = 'Y')
			AND
			(
				(
				CCP.CUM_PERIOD_END_DATE IS NULL and csh.schedule_horizon_start >=
				ccp.cum_period_start_date
				)
			OR      (
				CSH.SCHEDULE_HORIZON_START BETWEEN CCP.CUM_PERIOD_START_DATE
				AND     CCP.CUM_PERIOD_END_DATE
				)
			)
			)
		)
--bug11893659 We ll be printing the item record (2000th) and the item details record (4000th)
--even if the item does not have future requirements.
--            AND EXISTS (SELECT 1 FROM CHV_ITEM_ORDERS CIO
--                        WHERE CIO.SCHEDULE_ITEM_ID = CSI.SCHEDULE_ITEM_ID)
          ORDER BY
           csi.schedule_id,
           csi.schedule_item_id,
           mif.item_id,
           mtp.organization_code;


      BEGIN            -- begin item block

        <<item>>

        xProgress := 'SPSOB-30-1010';
        FOR  rec_item  IN  sch_item_c
        LOOP

          /*********************************************************
          **  select the last sequence number assigned to **
          **  the detail record of the same schedule item id. **
          *********************************************************/

          BEGIN
            xProgress := 'SPSOB-30-1020';
            SELECT  MAX(schedule_item_detail_sequence)
            INTO    x_item_detail_sequence
            FROM    ece_spso_item_det
            WHERE   schedule_id      = rec_item.schedule_id
              AND   schedule_item_id = rec_item.schedule_item_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ec_debug.pl ( 1,
                            'EC',
                            'ECE_NO_ROW_SELECTED',
                            'PROGRESS_LEVEL',
                            xProgress,
                            'INFO',
                            'MAX(SCHEDULE_ITEM_DETAIL_SEQUENCE)',
                            'TABLE_NAME',
                            'ECE_SPSO_ITEM_DET' );
          END;

          ec_debug.pl ( 3, 'x_item_detail_sequence: ',x_item_detail_sequence );

          BEGIN
            xProgress := 'SPSOB-30-1030';
            SELECT  transaction_record_id
            INTO    x_transaction_record_id
            FROM    ece_spso_items
            WHERE   schedule_id      = rec_item.schedule_id
              AND   schedule_item_id = rec_item.schedule_item_id
              AND   run_id           = p_run_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ec_debug.pl ( 1,
                            'EC',
                            'ECE_NO_ROW_SELECTED',
                            'PROGRESS_LEVEL',
                            xProgress,
                            'INFO',
                            'TRANSACTION_RECORD_ID',
                            'TABLE_NAME',
                            'ECE_SPSO_ITEMS' );
          END;

          ec_debug.pl ( 3, 'x_transaction_record_id: ',x_transaction_record_id );

          /*************************************************
          **   SELECT ENABLE_AUTHORIZATION_FLAG       **
          **   FROM APPROVED SUPPLIER LIST TABLE      **
          **   FOR THE SPECIFIED VENODR, SITE, ITEM AND   **
          **   ORGANIZATION.              **
          *************************************************/

          BEGIN           --  ASL block
            xProgress := 'SPSOB-30-1040';
            SELECT
               enable_authorizations_flag
            INTO
               x_enable_authorizations_flag
            FROM  po_asl_attributes   paa
            WHERE vendor_id       =   rec_hdr.vendor_id
              AND vendor_site_id      =   rec_hdr.vendor_site_id
              AND item_id         =   rec_item.item_id
              AND using_organization_id = chv_inq_sv.get_asl_org(
                                                     rec_hdr.organization_id,
                                                     rec_hdr.vendor_id,
                                                     rec_hdr.vendor_site_id,
                                                     rec_item.item_id);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ec_debug.pl ( 1,
                            'EC',
                            'ECE_NO_ROW_SELECTED',
                            'PROGRESS_LEVEL',
                            xProgress,
                            'INFO',
                            'ENABLE_AUTHORIZATIONS_FLAG',
                            'TABLE_NAME',
                            'PO_ASL_ATTRIBUTES' );
          END;

          ec_debug.pl ( 3, 'x_enable_authorizations_flag: ',x_enable_authorizations_flag );

          /**************************************
          **   SELECT AND INSERT ITEM DETAIL   **
          **************************************/

          DECLARE
            x_start_date          DATE;
            x_detail_category     VARCHAR2(25);
            x_item_order          NUMBER;
            x_item_detail         NUMBER;

            CURSOR    sch_detail_c    IS
              SELECT  authorization_code  AUTHORIZATION_CODE,
                      cutoff_date         CUTOFF_DATE,
                      schedule_quantity   SCHEDULE_QUANTITY
             FROM     chv_authorizations
             WHERE    reference_id        = rec_item.schedule_item_id
               AND    reference_type      = 'SCHEDULE_ITEMS';

          BEGIN           -- begin item detail block

          /***************************************
          ** insert prior authorization detail  **
          ***************************************/

            xProgress := 'SPSOB-30-1050';
            ece_spso_trans1.update_chv_schedule_headers ( rec_hdr.transaction_type,
                                                          rec_hdr.schedule_id,
                                                          rec_hdr.batch_id,  --Bug 2064311
                                                          rec_hdr.edi_count );

--bug12422231 Modified to tackle the case when profile is 'Y'
--(regression from 11893659)
                Select count(*)
                Into x_item_order
                From chv_item_orders
                Where schedule_id = rec_hdr.schedule_id;

                Select  count(schedule_id)
                Into    x_item_detail
                From    chv_item_orders
                Where   schedule_id = rec_hdr.schedule_id
                And     schedule_item_id = rec_item.schedule_item_id;

                   fnd_profile.get('ECE_SPSO_EXCLUDE_ZERO_SCHEDULE_FROM_FF',exclude_zero_schedule_from_ff);
                   If NVL(exclude_zero_schedule_from_ff,'N')<>'Y' then
                      exclude_zero_schedule_from_ff := 'N';
                   End If;               -- 2944455


            xProgress := 'SPSOB-30-1060';
            IF x_enable_authorizations_flag = 'Y'    AND
               p_transaction_type           = 'SPSO'
            THEN
                IF ((exclude_zero_schedule_from_ff = 'N')

--bug12422231 Modified to tackle the case when profile is 'Y'
--(regression from 11893659)
		     OR
                     (exclude_zero_schedule_from_ff = 'Y' AND x_item_order > 0 AND x_item_detail > 0)
		    ) Then  -- 2944455

              xProgress := 'SPSOB-30-1070';
              IF rec_item.ship_to_org_enable_cum_flag ='Y'
              THEN

                --  increment detail record sequence counter

                xProgress := 'SPSOB-30-1080';
                x_item_detail_sequence := NVL(x_item_detail_sequence,0) + 1;

                xProgress := 'SPSOB-30-1090';
                INSERT INTO ece_spso_item_det
                  (
                   run_id,
                   schedule_item_detail_sequence,
                   schedule_id,
                   schedule_item_id,
                   detail_category,
                   detail_descriptor,
                   starting_date,
                   forecast_quantity,
                   release_quantity,
                   total_quantity,
                   transaction_record_id
                  )
              VALUES
                  (
                   p_run_id,
                   x_item_detail_sequence,
                   rec_item.schedule_id,
                   rec_item.schedule_item_id,
                   'AUTHORIZATION',
                   'PRIOR',
                   rec_hdr.forecast_horizon_start_date,
                   0,
                   0,
                   NVL(rec_item.starting_auth_quantity,0),
                   ece_spso_item_det_s.nextval
                  );
                       -- Bug 1742567
                       select
                        ece_spso_item_det_s.currval
                        into
                        l_transaction_number
                        from
                        dual;
                        ECE_SPSO_X.populate_extension_item_det(l_transaction_number,
                                                rec_item.schedule_id,
                                                rec_item.schedule_item_id);

            END IF;

            /****************************************
            ** insert current authorization detail **
            ****************************************/

            --  authorization start date is the cum start date.
            --  cum_flag is enabled since cum quantity is included
            --  in authorization quantity.


            xProgress := 'SPSOB-30-1100';
            IF rec_item.ship_to_org_enable_cum_flag = 'Y' THEN

              x_start_date :=  rec_item.ship_to_org_cum_period_start;

            ELSE

              x_start_date :=  rec_hdr.forecast_horizon_start_date;

            END IF;
            ec_debug.pl ( 3, 'x_start_date: ',x_start_date );

            xProgress := 'SPSOB-30-1110';

            <<authorization>>

            FOR rec_detail IN sch_detail_c
            LOOP

              --  increment detail record sequence counter

              x_item_detail_sequence := NVL(x_item_detail_sequence,0) + 1;

              xProgress := 'SPSOB-30-1120';

              INSERT INTO ece_spso_item_det
                (
                 run_id,
                 schedule_item_detail_sequence,
                 schedule_id,
                 schedule_item_id,
                 detail_category,
                 detail_descriptor,
                 starting_date,
                 ending_date,
                 forecast_quantity,
                 release_quantity,
                 total_quantity,
                 transaction_record_id
                )
              VALUES
                (
                 p_run_id,
                 x_item_detail_sequence,
                 rec_item.schedule_id,
                 rec_item.schedule_item_id,
                 'AUTHORIZATION',
                 rec_detail.authorization_code,
                 x_start_date,
                 rec_detail.cutoff_date,
                 0,
                 0,
                 NVL(rec_detail.schedule_quantity,0),
                 ece_spso_item_det_s.nextval
                );
                        -- Bug 1742567
                        select
                        ece_spso_item_det_s.currval
                        into
                        l_transaction_number
                        from
                        dual;
                        ECE_SPSO_X.populate_extension_item_det(l_transaction_number,
                                                rec_item.schedule_id,
                                                rec_item.schedule_item_id);

            END LOOP authorization;
           END IF;
          END IF;


          /********************************
          ** insert last receipt detail  **
          ********************************/

          xProgress := 'SPSOB-30-1130';
          IF ((exclude_zero_schedule_from_ff = 'N') OR
                   (x_item_order > 0 AND x_item_detail > 0))  Then -- 2944455
          IF rec_item.last_receipt_transaction_id IS NOT NULL
          THEN

            --  increment detail record sequence counter

            x_item_detail_sequence := NVL(x_item_detail_sequence,0) + 1;
            ec_debug.pl ( 3, 'x_item_detail_sequence: ',x_item_detail_sequence );

            xProgress := 'SPSOB-30-1140';

            --  DEBUG Sri's proc package name may chg
            --  DEBUG comments

            chv_inq_sv.get_receipt_qty ( rec_item.last_receipt_transaction_id,
                                         rec_item.item_id,
                                         rec_item.purchasing_unit_of_measure,
                                         x_last_quantity,
                                         x_shipment_num,
                                         x_transaction_date );

            --  ***************************
            --  the following UPDATE is added for version 2.0
            --  ***************************

            xProgress := 'SPSOB-30-1150';
            ec_debug.pl ( 3, 'x_shipment_num: ',x_shipment_num );
            ec_debug.pl ( 3, 'x_transaction_date: ',x_transaction_date );
            ec_debug.pl ( 3, 'x_last_quantity: ',x_last_quantity );

            UPDATE ece_spso_items
               SET last_receipt_shipment_code = x_shipment_num,
                   last_receipt_date          = x_transaction_date,
                   last_receipt_quantity      = x_last_quantity
             WHERE transaction_record_id      = x_transaction_record_id;

            xProgress := 'SPSOB-30-1160';

            INSERT INTO ece_spso_item_det
               (
                run_id,
                schedule_item_detail_sequence,
                schedule_id,
                schedule_item_id,
                detail_category,
                detail_descriptor,
                starting_date,
                forecast_quantity,
                release_quantity,
                total_quantity,
                document_type,
                document_number,
                transaction_record_id
               )
            VALUES
               (
                p_run_id,
                x_item_detail_sequence,
                rec_item.schedule_id,
                rec_item.schedule_item_id,
                'RECEIPT',
                'LAST',
                x_transaction_date,
                0,
                0,
                NVL(x_last_quantity,0),
                'SHIPMENT',
                x_shipment_num,
                ece_spso_item_det_s.nextval
               );
                        -- Bug 1742567
                        select
                        ece_spso_item_det_s.currval
                        into
                        l_transaction_number
                        from
                        dual;
                        ECE_SPSO_X.populate_extension_item_det(l_transaction_number,
                                                rec_item.schedule_id,
                                                rec_item.schedule_item_id);

          END IF;


          /********************************
          **  insert CUM receipt detail  **
          ********************************/


          xProgress := 'SPSOB-30-1170';
          IF rec_item.ship_to_org_enable_cum_flag = 'Y'
          THEN

            --  increment detail record sequence counter

            x_item_detail_sequence := NVL(x_item_detail_sequence,0) + 1;
            ec_debug.pl ( 3, 'x_item_detail_sequence: ',x_item_detail_sequence );

            xProgress := 'SPSOB-30-1180';

            INSERT INTO ece_spso_item_det
              (
               run_id,
               schedule_item_detail_sequence,
               schedule_id,
               schedule_item_id,
               detail_category,
               detail_descriptor,
               starting_date,
               ending_date,
               forecast_quantity,
               release_quantity,
               total_quantity,
               transaction_record_id
              )
            VALUES
              (
               p_run_id,
               x_item_detail_sequence,
               rec_item.schedule_id,
               rec_item.schedule_item_id,
               'RECEIPT',
               'CUMULATIVE',
               rec_item.ship_to_org_cum_period_start,
               rec_hdr.forecast_horizon_start_date,
               0,
               0,
               NVL(rec_item.starting_cum_quantity,0),
               ece_spso_item_det_s.nextval
              );
                        -- Bug 1742567
                        select
                        ece_spso_item_det_s.currval
                        into
                        l_transaction_number
                        from
                        dual;
                        ECE_SPSO_X.populate_extension_item_det(l_transaction_number,
                                                rec_item.schedule_id,
                                                rec_item.schedule_item_id);

            END IF;

            --  ***************************
            --  the following UPDATE is added for version 2.0
            --  ***************************

            xProgress := 'SPSOB-30-1190';
            ec_debug.pl ( 3, 'rec_item.starting_cum_quantity: ',NVL(rec_item.starting_cum_quantity,0) );
            UPDATE ece_spso_items
               SET last_receipt_cum_qty  = NVL(rec_item.starting_cum_quantity,0)
             WHERE transaction_record_id = x_transaction_record_id;
   END IF;

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

          END;              -- item detail block



        END LOOP item;      -- item for loop

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

      END;              -- item block

    END LOOP header;        -- header for loop

    ec_debug.pop ( 'ece_spso_trans1.Populate_Supplier_Sched_API3' );

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

  END Populate_Supplier_Sched_API3; -- end of procedure


  /*************************************************************************
  **  procedure UPDATE_CHV_SCHEDULE_HEADERS               **
  **  This procedure will update the records in CHV_SCHEDULE_HEADERS table**
  **  which have been extracted for EDI transmission. The communication   **
  **  code will be set according to their inital value. If the record is  **
  **  flaged for BOTH print and edi, after performing EDI transaction it  **
  **  will be reset to print. If the initial vaues is EDI then after  **
  **  completion of transaction the code will be set to NONE.     **
  *************************************************************************/

  PROCEDURE Update_CHV_Schedule_Headers ( p_transaction_type  IN VARCHAR2,
                                          p_schedule_id       IN INTEGER  := 0,
                                          p_batch_id          IN      NUMBER,
                                          p_edi_count         IN NUMBER   := 0 )
  IS

    xProgress   VARCHAR2(30) := NULL;
    cOutput_path   varchar2(120);

  BEGIN

    ec_debug.push ( 'ECE_SPSO_TRANS1.UPDATE_CHV_SCHEDULE_HEADERS' );
    ec_debug.pl ( 3, 'p_transaction_type: ',p_transaction_type );
    ec_debug.pl ( 3, 'p_schedule_id: ',p_schedule_id );
    ec_debug.pl ( 3, 'p_edi_count: ',p_edi_count );

    -- Retreive the system profile option ECE_OUT_FILE_PATH.  This will
    -- be the directory where the output file will be written.
    -- NOTE: THIS DIRECTORY MUST BE SPECIFIED IN THE PARAMETER utl_file_dir IN
    -- THE INIT.ORA FILE.  Refer to the Oracle7 documentation for more information
    -- on the package UTL_FILE.

    xProgress := 'SPSOB-40-0100';
    fnd_profile.get ( 'ECE_OUT_FILE_PATH',
                      cOutput_path );

    ec_debug.pl ( 3, 'cOutput_path: ',cOutput_path );

    xProgress := 'SPSOB-40-1000';

    UPDATE chv_schedule_headers
       SET communication_code = DECODE ( communication_code,
                                         'BOTH',  'PRINT',
                                         'EDI',   'NONE',
                                         'NONE',  'NONE',
                                         'PRINT', 'PRINT',
                                         NULL ),
           last_update_date   = SYSDATE,
           last_updated_by    = -1,
           last_edi_date      = SYSDATE,
           edi_count          = NVL(p_edi_count,0) + 1
     WHERE ((schedule_id      = p_schedule_id             AND
             p_schedule_id   <> 0)                        OR
            (p_schedule_id = 0                            AND
             NVL(communication_code, 'NONE') IN ('BOTH','EDI')))
       AND p_transaction_type = DECODE ( schedule_type,
                                         'SHIP_SCHEDULE', 'SSSO',
                                         'SPSO' )
       AND batch_id = decode(p_batch_id,0,batch_id,p_batch_id);  -- Bug 2064311
     ec_debug.pop ( 'ECE_SPSO_TRANS1.UPDATE_CHV_SCHEDULE_HEADERS' );

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

  END Update_CHV_Schedule_Headers;


  /*************************************************************************
  **  procedure PUT_DATA_TO_OUTPUT_TABLE                                  **
  **  This procedure has the following functionalities:                   **
  **  1. Build SQL statement dynamically to extract data from             **
  **      Interface Tables.                                               **
  **  2. Execute the dynamic SQL statement.                               **
  **  3. Populate the ECE_OUTPUT table with the extracted data.           **
  **  4. Delete data from Interface Tables.                               **
  **  To use this procedure must have access to the procedures in         **
  **      ECE_FLATFILE package.                                           **
  **  HISTORY:                                                            **
  **   Apr  3, 1995    wlang     Created.                                 **
  **                                                                      **
  **   May 15, 1996    mbabaloy                                           **
  *************************************************************************/

  PROCEDURE Put_Data_To_Output_Table ( p_communication_method IN VARCHAR2,
                                       p_transaction_type     IN VARCHAR2, -- plan SPSO, ship SSSO
                                       p_output_width         IN INTEGER,
                                       p_run_id               IN INTEGER,
                                       p_header_interface     IN VARCHAR2 := 'ECE_SPSO_HEADERS',
                                       p_item_interface       IN VARCHAR2 := 'ECE_SPSO_ITEMS',
                                       p_item_d_interface     IN VARCHAR2 := 'ECE_SPSO_ITEM_DET',
				       p_ship_d_interface     IN VARCHAR2 := 'ECE_SPSO_SHIP_DET')
  IS
    xProgress                VARCHAR2(30);
    cOutput_path             VARCHAR2(120);

    l_header_tbl             ece_flatfile_pvt.Interface_tbl_type;
    l_item_tbl               ece_flatfile_pvt.Interface_tbl_type;
    l_item_d_tbl             ece_flatfile_pvt.Interface_tbl_type;
    l_ship_d_tbl             ece_flatfile_pvt.Interface_tbl_type;

    c_header_common_key_name VARCHAR2(40);
    c_item_common_key_name   VARCHAR2(40);
    c_item_d_common_key_name VARCHAR2(40);
    c_ship_d_common_key_name VARCHAR2(40);
    c_file_common_key        VARCHAR2(255);

    nHeader_key_pos          NUMBER;
    nItem_key_pos            NUMBER;
    nItem_D_key_pos          NUMBER;
    nShip_D_key_pos          NUMBER;
    nTrans_code_pos          NUMBER;

    v_header_sel_c           INTEGER;
    v_item_sel_c             INTEGER;
    v_item_d_sel_c           INTEGER;
    v_ship_d_sel_c           INTEGER;

    v_header_del_c1          INTEGER;
    v_item_del_c1            INTEGER;
    v_item_d_del_c1          INTEGER;
    v_ship_d_del_c1          INTEGER;

    v_header_del_c2          INTEGER;
    v_item_del_c2            INTEGER;
    v_item_d_del_c2          INTEGER;
    v_ship_d_del_c2          INTEGER;

    x_header_select          VARCHAR2(32000);
    x_item_select            VARCHAR2(32000);
    x_item_d_select          VARCHAR2(32000);
    x_ship_d_select          VARCHAR2(32000);

    x_header_from            VARCHAR2(32000);
    x_item_from              VARCHAR2(32000);
    x_item_d_from            VARCHAR2(32000);
    x_ship_d_from            VARCHAR2(32000);

    x_header_where           VARCHAR2(32000);
    x_item_where             VARCHAR2(32000);
    x_item_d_where           VARCHAR2(32000);
    x_ship_d_where           VARCHAR2(32000);

    x_header_delete1         VARCHAR2(32000);
    x_item_delete1           VARCHAR2(32000);
    x_item_d_delete1         VARCHAR2(32000);
    x_ship_d_delete1         VARCHAR2(32000);

    x_header_delete2         VARCHAR2(32000);
    x_item_delete2           VARCHAR2(32000);
    x_item_d_delete2         VARCHAR2(32000);
    x_ship_d_delete2         VARCHAR2(32000);

    x_header_count           NUMBER;
    x_item_count             NUMBER;
    x_item_d_count           NUMBER;
    x_ship_d_count           NUMBER;

    x_header_rowid           ROWID;
    x_item_rowid             ROWID;
    x_item_d_rowid           ROWID;
    x_ship_d_rowid           ROWID;

    x_header_x_interface     VARCHAR2(50);
    x_item_x_interface       VARCHAR2(50);
    x_item_d_x_interface     VARCHAR2(50);
    x_ship_d_x_interface     VARCHAR2(50);

    x_header_x_rowid         ROWID;
    x_item_x_rowid           ROWID;
    x_item_d_x_rowid         ROWID;
    x_ship_d_x_rowid         ROWID;

    x_header_start_num       INTEGER;

    x_item_start_num         INTEGER;
    x_item_d_start_num       INTEGER;
    x_dummy                  INTEGER;

    x_schedule_id            NUMBER;
    n_schedule_id_pos        NUMBER;
    x_schedule_item_id       NUMBER;
    x_schedule_item_id_pos   NUMBER;
    x_pos1                   NUMBER;
    x_pos2                   NUMBER;
    x_sch_item_detail_seq    NUMBER;

    c_header_select          VARCHAR2(100);

  BEGIN

    ec_debug.push ( 'ECE_SPSO_TRANS1.PUT_DATA_TO_OUTPUT_TABLE' );
    ec_debug.pl ( 3, 'p_communication_method: ', p_communication_method );
    ec_debug.pl ( 3, 'p_transaction_type: ',p_transaction_type );
    ec_debug.pl ( 3, 'p_output_width: ',p_output_width );
    ec_debug.pl ( 3, 'p_run_id: ',p_run_id );
    ec_debug.pl ( 3, 'p_header_interface: ',p_header_interface );
    ec_debug.pl ( 3, 'p_item_interface: ',p_item_interface );
    ec_debug.pl ( 3, 'p_item_d_interface: ',p_item_d_interface );
    ec_debug.pl ( 3, 'p_ship_d_interface: ',p_ship_d_interface );

    -- Retreive the system profile option ECE_OUT_FILE_PATH.  This will
    -- be the directory where the output file will be written.
    -- NOTE: THIS DIRECTORY MUST BE SPECIFIED IN THE PARAMETER utl_file_dir IN
    -- THE INIT.ORA FILE.  Refer to the Oracle7 documentation for more information
    -- on the package UTL_FILE.

    xProgress := 'SPSOB-50-0100';
    fnd_profile.get ( 'ECE_OUT_FILE_PATH',
                      cOutput_path );
    ec_debug.pl ( 3, 'cOutput_path: ',cOutput_path );

    /* --------------------------------------------------------------------------
    -- Here, I am building the SELECT, FROM, and WHERE  clauses for the dynamic
    -- SQL call
    -- The ece_flatfile_pvt.select_clause uses the db data dictionary for the build.
    -- (The db data dictionary store contains all types of info about Interface
    -- tables and Extension tables.)

    -- The DELETE clauses will be used to clean up both the interface and extension
    -- tables.  I am using ROWID to tell me which row in the interface table is
    -- being written to the output table, thus, can be deleted.
    --------------------------------------------------------------------------*/

    xProgress := 'SPSOB-50-1000';
    ece_flatfile_pvt.select_clause ( p_transaction_type,
                                     p_communication_method,
                                     p_header_interface,
                                     x_header_x_interface,
                                     l_header_tbl,
                                     c_header_common_key_name,
                                     x_header_select,
                                     x_header_from,
                                     x_header_where );

    xProgress := 'SPSOB-50-1010';
    ece_flatfile_pvt.select_clause ( p_transaction_type,
                                     p_communication_method,
                                     p_item_interface,
                                     x_item_x_interface,
                                     l_item_tbl,
                                     c_item_common_key_name,
                                     x_item_select,
                                     x_item_from ,
                                     x_item_where );

    xProgress := 'SPSOB-50-1020';
    ece_flatfile_pvt.select_clause ( p_transaction_type,
                                     p_communication_method,
                                     p_item_d_interface,
                                     x_item_d_x_interface,
                                     l_item_d_tbl,
                                     c_item_d_common_key_name,
                                     x_item_d_select,
                                     x_item_d_from ,
                                     x_item_d_where );

     xProgress := 'SPSOB-50-1030';
     if (p_transaction_type = 'SSSO') then
     ece_flatfile_pvt.select_clause ( p_transaction_type,
                                     p_communication_method,
                                     p_ship_d_interface,
                                     x_ship_d_x_interface,
                                     l_ship_d_tbl,
                                     c_ship_d_common_key_name,
                                     x_ship_d_select,
                                     x_ship_d_from ,
                                     x_ship_d_where );
      end if;
    /* --------------------------------------------------------------------------
    REM Here, I am customizing the WHERE clause to join the Interface
    REM     tables together.  i.e. Headers -- Items -- Item Details
    REM Select  Data1, Data2, Data3...........
    REM From    v_header_Interface A, v_item_Interface B,
    REM     v_item_details_Interface   C,
    REM     v_header_Interface_X D, v_item_Interface_X E,
    REM     v_item_details_Interface_X F
    REM Where   A.Transaction_Record_ID = D.Transaction_Record_ID (+)
    REM and B.Transaction_Record_ID = E.Transaction_Record_ID (+)
    REM and C.Transaction_Record_ID = F.Transaction_Record_ID (+)
    REM $$$$$ (Customization should be added here) $$$$$$
    REM and A.Communication_Method = 'EDI'
    REM and A.xxx = B.xxx   ........
    REM and B.yyy = C.yyy   .......
    REM -------------------------------------------------------------------------*/


    /* --------------------------------------------------------------------------
      :schedule_id is a place holder for foreign key value.
      A PL/SQL table (list of values) will be used to store data.
      Procedure ece_flatfile_pvt.Find_pos will be used to locate the specific
      data value in the PL/SQL table.
      dbms_sql (Native Oracle db functions that come with every Oracle Apps)
      dbms_sql.bind_variable will be used to assign data value to :schedule_id

      Let's use the above example:

      1. Execute dynamic SQL 1 for headers (A) data
          Get value of A.xxx (foreign key to B)

      2. bind value A.xxx to variable B.xxx

      3. Execute dynamic SQL 2 for lines (B) data
          Get value of B.yyy (foreign key to C)

      4. bind value B.yyy to variable C.yyy

      5. Execute dynamic SQL 3 for line_details (C) data
    --------------------------------------------------------------------------*/


    xProgress       := 'SPSOB-50-1030';
    x_header_where  := x_header_where                           ||
                       ' AND '                                  ||
                       p_header_interface                       ||
                       '.RUN_ID ='                              ||
                       ':l_p_run_id';

    ec_debug.pl ( 3, 'x_header_where: ',x_header_where );

    xProgress        := 'SPSOB-50-1040';
    x_item_where     := x_item_where                            ||
                        ' AND '                                 ||
                        p_item_interface                        ||
                        '.RUN_ID ='                             ||
                        ':l_p_run_id'                           ||
                        ' AND '                                 ||
                        p_item_interface                        ||
                        '.SCHEDULE_ID = :schedule_id'           ||
                        ' ORDER BY '                            ||
                        p_item_interface                        ||
                        '.SCHEDULE_ID, '                        ||
                        p_item_interface                        ||
                        '.SCHEDULE_ITEM_ID, '                   ||
                        p_item_interface                        ||
                        '.ITEM_NUMBER, '                        ||
                        p_item_interface                        ||
                        '.SHIP_TO_ORG_CODE';

    ec_debug.pl ( 3, 'x_item_where: ',x_item_where );

    xProgress        := 'SPSOB-50-1050';
    x_item_d_where   := x_item_d_where                          ||
                        ' AND '                                 ||
                        p_item_d_interface                      ||
                        '.RUN_ID ='                             ||
                        ':l_p_run_id'                           ||
                        ' AND '                                 ||
                        p_item_d_interface                      ||
                        '.SCHEDULE_ID = :schedule_id'           ||
                        ' AND '                                 ||
                        p_item_d_interface                      ||
                        '.SCHEDULE_ITEM_ID = :schedule_item_id' ||
                        ' ORDER BY '                            ||
                        p_item_d_interface                      ||
                        '.SCHEDULE_ID, '                        ||
                        p_item_d_interface                      ||
                        '.SCHEDULE_ITEM_DETAIL_SEQUENCE';

      ec_debug.pl ( 3, 'x_item_d_where: ',x_item_d_where );
     xProgress := 'SPSOB-50-1055';
    if (p_transaction_type = 'SSSO') then
    x_ship_d_where := x_ship_d_where                            ||
                      ' AND '                                   ||
		      p_ship_d_interface                        ||
		      '.RUN_ID = :l_p_run_id'                   ||
                      ' AND '                                   ||
		      p_ship_d_interface                        ||
		      '.SCHEDULE_ID = :schedule_id'             ||
                      ' AND '                                   ||
		      p_ship_d_interface                        ||
		      '.SCHEDULE_ITEM_ID = :schedule_item_id'   ||
                      ' AND '                                   ||
		      p_ship_d_interface                        ||
		      '.SCHEDULE_ITEM_DETAIL_SEQUENCE = :schedule_item_detail_sequence'
                      || ' ORDER BY '                           ||
		      p_ship_d_interface                        ||
		      '.SCHEDULE_ID, '                          ||
                      p_ship_d_interface                        ||
		      '.SCHEDULE_ITEM_DETAIL_SEQUENCE,'         ||
                      p_ship_d_interface                        ||
		      '.SCHEDULE_SHIP_ID';


    ec_debug.pl ( 3, 'x_ship_d_where: ',x_ship_d_where );

    end if;

    xProgress        := 'SPSOB-50-1060';
    x_header_select  := x_header_select                         ||
                        ','                                     ||
                        p_header_interface                      ||
                        '.ROWID,'                               ||
                        x_header_x_interface                    ||
                        '.ROWID,'                               ||
                        p_header_interface                      ||
                        '.SCHEDULE_ID' ;

    ec_debug.pl ( 3, 'x_header_select: ',x_header_select );

    xProgress        := 'SPSOB-50-1070';
    x_item_select    := x_item_select                           ||
                        ','                                     ||
                        p_item_interface                        ||
                        '.ROWID,'                               ||
                        x_item_x_interface                      ||
                        '.ROWID,'                               ||
                        p_item_interface                        ||
                        '.SCHEDULE_ITEM_ID' ;

    ec_debug.pl ( 3, 'x_item_select: ',x_item_select );

    xProgress        := 'SPSOB-50-1080';
    x_item_d_select  := x_item_d_select                         ||
                        ','                                     ||
                        p_item_d_interface                      ||
                        '.ROWID,'                               ||
                        x_item_d_x_interface                    ||
                        '.ROWID, '                              ||
			p_item_d_interface                      ||
			'.SCHEDULE_ITEM_DETAIL_SEQUENCE';

    ec_debug.pl ( 3, 'x_item_d_select: ',x_item_d_select );

    xProgress       := 'SPSOB-50-1085';
    if (p_transaction_type = 'SSSO') then
    x_ship_d_select := x_ship_d_select                          ||
                       ','                                      ||
		       p_ship_d_interface                       ||
		       '.ROWID,'                                ||
                       x_ship_d_x_interface                     ||
		       '.ROWID';

     ec_debug.pl ( 3, 'x_ship_d_select: ',x_ship_d_select );
     end if;

    xProgress        := 'SPSOB-50-1090';
    x_header_select  := x_header_select                         ||
                        x_header_from                           ||
                        x_header_where                          ||
                        ' FOR UPDATE';

    ec_debug.pl ( 3, 'x_header_select: ',x_header_select);

    xProgress := 'SPSOB-50-1100';
    x_item_select   := x_item_select   || x_item_from   || x_item_where;
    ec_debug.pl ( 3, 'x_item_select: ',x_item_select);

    xProgress        := 'SPSOB-50-1110';
    x_item_d_select  := x_item_d_select                         ||
                        x_item_d_from                           ||
                        x_item_d_where ;

    ec_debug.pl ( 3, 'x_item_d_select: ',x_item_d_select );

     xProgress := 'SPSOB-50-1115';
     if (p_transaction_type = 'SSSO') then
     x_ship_d_select := x_ship_d_select                         ||
                        x_ship_d_from                           ||
			x_ship_d_where ;
     ec_debug.pl ( 3, 'x_ship_d_select: ',x_ship_d_select );
     end if;

    xProgress        := 'SPSOB-50-1120';
    x_header_delete1 := 'DELETE FROM '                          ||
                        p_header_interface                      ||
                        ' WHERE ROWID = :col_rowid';

    ec_debug.pl ( 3, 'x_header_delete1: ',x_header_delete1 );

    xProgress        := 'SPSOB-50-1130';
    x_item_delete1   := 'DELETE FROM '                          ||
                        p_item_interface                        ||
                        ' WHERE ROWID = :col_rowid';

    ec_debug.pl ( 3, 'x_item_delete1: ',x_item_delete1 );

    xProgress        := 'SPSOB-50-1140';
    x_item_d_delete1 := 'DELETE FROM '                          ||
                        p_item_d_interface                      ||
                        ' WHERE ROWID = :col_rowid';

     ec_debug.pl ( 3, 'x_item_d_delete1: ',x_item_d_delete1 );

     xProgress        := 'SPSOB-50-1145';
     if (p_transaction_type = 'SSSO') then
     x_ship_d_delete1 := 'DELETE FROM '                         ||
                         p_ship_d_interface                     ||
                         ' WHERE ROWID = :col_rowid';
     ec_debug.pl ( 3, 'x_ship_d_delete1: ',x_ship_d_delete1 );
     end if;

    xProgress        := 'SPSOB-50-1150';
    x_header_delete2 := 'DELETE FROM '                          ||
                        x_header_x_interface                    ||
                        ' WHERE ROWID = :col_rowid';

    ec_debug.pl ( 3, 'x_header_delete2: ',x_header_delete2 );

    xProgress        := 'SPSOB-50-1160';
    x_item_delete2   := 'DELETE FROM '                          ||
                        x_item_x_interface                      ||
                        ' WHERE ROWID = :col_rowid';

    ec_debug.pl ( 3, 'x_item_delete2: ',x_item_delete2 );

    xProgress        := 'SPSOB-50-1170';
    x_item_d_delete2 := 'DELETE FROM '                          ||
                        x_item_d_x_interface                    ||
                        ' WHERE ROWID = :col_rowid';


    ec_debug.pl ( 3, 'x_item_d_delete2: ',x_item_d_delete2 );

    xProgress := 'SPSOB-50-1175';
    if (p_transaction_type = 'SSSO') then
    x_ship_d_delete2 := 'DELETE FROM '                          ||
                         x_ship_d_x_interface                   ||
                         ' WHERE ROWID = :col_rowid';
    end if;

    --***************************************************
    --*** Get data setup for the dynamic SQL call.     **
    --***         and                                  **
    --*** Open a cursor for each of the SELECT calls   **
    --***************************************************

    xProgress       := 'SPSOB-50-1180';
    v_header_sel_c  := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1190';
    v_item_sel_c    := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1200';
    v_item_d_sel_c  := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1205';
    if (p_transaction_type = 'SSSO') then
    v_ship_d_sel_c  := dbms_sql.open_cursor;
    end if;
    xProgress       := 'SPSOB-50-1210';
    v_header_del_c1 := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1220';
    v_item_del_c1   := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1230';
    v_item_d_del_c1 := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1235';
    if (p_transaction_type = 'SSSO') then
    v_ship_d_del_c1 := dbms_sql.open_cursor;
    end if;

    xProgress       := 'SPSOB-50-1240';
    v_header_del_c2 := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1250';
    v_item_del_c2   := dbms_sql.open_cursor;

    xProgress       := 'SPSOB-50-1260';
    v_item_d_del_c2 := dbms_sql.open_cursor;

     xProgress       := 'SPSOB-50-1265';
     if (p_transaction_type = 'SSSO') then
    v_ship_d_del_c2 := dbms_sql.open_cursor;
     end if;
    --******************************************************
    --*** Parse each of the SELECT and DELETE statement  **
    --******************************************************

    xProgress := 'SPSOB-50-1270';
    BEGIN
      dbms_sql.parse ( v_header_sel_c,
                       x_header_select,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_header_select );
         app_exception.raise_exception;
     END;

    xProgress := 'SPSOB-50-1280';
    BEGIN
      dbms_sql.parse ( v_item_sel_c,
                       x_item_select,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_item_select );
         app_exception.raise_exception;
     END;

    xProgress := 'SPSOB-50-1290';
    BEGIN
      dbms_sql.parse ( v_item_d_sel_c,
                       x_item_d_select,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_item_d_select );
         app_exception.raise_exception;
     END;

     xProgress := 'SPSOB-50-1295';
    if (p_transaction_type = 'SSSO') then
    BEGIN
      dbms_sql.parse ( v_ship_d_sel_c,
                       x_ship_d_select,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_ship_d_select );
         app_exception.raise_exception;
     END;
     end if;
    xProgress := 'SPSOB-50-1300';
    BEGIN
      dbms_sql.parse ( v_header_del_c1,
                       x_header_delete1,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_header_delete1 );
         app_exception.raise_exception;
     END;

    xProgress := 'SPSOB-50-1310';
    BEGIN
      dbms_sql.parse ( v_item_del_c1,
                       x_item_delete1,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_item_delete1 );
         app_exception.raise_exception;
     END;

    xProgress := 'SPSOB-50-1320';
    BEGIN
      dbms_sql.parse ( v_item_d_del_c1,
                       x_item_d_delete1,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_item_d_delete1 );
         app_exception.raise_exception;
     END;

    xProgress := 'SPSOB-50-1325';
    if (p_transaction_type = 'SSSO') then
    BEGIN
      dbms_sql.parse ( v_ship_d_del_c1,
                       x_ship_d_delete1,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_ship_d_delete1 );
         app_exception.raise_exception;
     END;
     end if;

    xProgress := 'SPSOB-50-1330';
    BEGIN
      dbms_sql.parse ( v_header_del_c2,
                       x_header_delete2,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_header_delete2 );
         app_exception.raise_exception;
     END;

    xProgress := 'SPSOB-50-1340';
    BEGIN
      dbms_sql.parse ( v_item_del_c2,
                       x_item_delete2,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_item_delete2 );
         app_exception.raise_exception;
     END;

    xProgress := 'SPSOB-50-1350';
    BEGIN
      dbms_sql.parse ( v_item_d_del_c2,
                       x_item_d_delete2,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_item_d_delete2 );
         app_exception.raise_exception;
     END;

     xProgress := 'SPSOB-50-1355';
     if (p_transaction_type = 'SSSO') then
    BEGIN
      dbms_sql.parse ( v_ship_d_del_c2,
                       x_ship_d_delete2,
                       dbms_sql.native );
    EXCEPTION
       WHEN OTHERS THEN
         ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                    x_ship_d_delete2 );
         app_exception.raise_exception;
     END;
     end if;

     -- *************************************************
     -- set counter
     -- *************************************************

     xProgress      := 'SPSOB-50-1360';
     x_header_count := l_header_tbl.count;
     ec_debug.pl ( 3, 'x_header_count: ',x_header_count );

     xProgress      := 'SPSOB-50-1370';
     x_item_count   := l_item_tbl.count;
     ec_debug.pl ( 3, 'x_item_count: ',x_item_count );

     xProgress      := 'SPSOB-50-1380';
     x_item_d_count := l_item_d_tbl.count;
     ec_debug.pl ( 3, 'x_item_d_count: ',x_item_d_count );

      xProgress      := 'SPSOB-50-1380';
      if (p_transaction_type = 'SSSO') then
     x_ship_d_count := l_ship_d_tbl.count;
     ec_debug.pl ( 3, 'x_ship_d_count: ',x_ship_d_count );
      end if;
    --******************************************************************
    --*** Define data TYPE for every columns in the SELECT statement   **
    --******************************************************************

    xProgress := 'SPSOB-50-1390';

    xProgress := 'SPSOB-50-1400';
    FOR k IN 1..x_header_count
    LOOP

      dbms_sql.define_column ( v_header_sel_c,
                               k,
                               x_header_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    --********************************************
    --*** Need rowid for delete (Header Level)   **
    --********************************************

    xProgress := 'SPSOB-50-1410';
    dbms_sql.define_column_rowid ( v_header_sel_c,
                                   x_header_count + 1,
                                   x_header_rowid);

    xProgress := 'SPSOB-50-1420';
    dbms_sql.define_column_rowid ( v_header_sel_c,
                                   x_header_count + 2,
                                   x_header_x_rowid);

    xProgress := 'SPSOB-50-1430';
    dbms_sql.define_column ( v_header_sel_c,
                             x_header_count + 3,
                             x_schedule_id);

    xProgress := 'SPSOB-50-1440';
    FOR k IN 1..x_item_count
    LOOP

      dbms_sql.define_column ( v_item_sel_c,
                               k,
                               x_item_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;


    --******************************************
    --*** Need rowid for delete (Item Level)   **
    --*******************************************

    xProgress := 'SPSOB-50-1450';
    dbms_sql.define_column_rowid ( v_item_sel_c,
                                   x_item_count + 1,
                                   x_item_rowid );

    xProgress := 'SPSOB-50-1460';
    dbms_sql.define_column_rowid ( v_item_sel_c,
                                   x_item_count + 2,
                                   x_item_x_rowid );

    xProgress := 'SPSOB-50-1470';
    dbms_sql.define_column ( v_item_sel_c,
                             x_item_count + 3,
                             x_schedule_item_id );

    xProgress := 'SPSOB-50-1480';
    FOR k IN 1..x_item_d_count
    LOOP

      dbms_sql.define_column (v_item_d_sel_c,
                              k,
                              x_item_d_select,
                              ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;


    --**************************************************
    --*** Need rowid for delete (Item details Level)   **
    --**************************************************

    xProgress := 'SPSOB-50-1490';
    dbms_sql.define_column_rowid ( v_item_d_sel_c,
                                   x_item_d_count + 1,
                                   x_item_d_rowid);

    xProgress := 'SPSOB-50-1500';
    dbms_sql.define_column_rowid ( v_item_d_sel_c,
                                   x_item_d_count + 2,
                                   x_item_d_x_rowid );

    xProgress := 'SPSOB-50-1501';
    dbms_sql.define_column       ( v_item_d_sel_c,
                                   (x_item_d_count+3),
				   x_sch_item_detail_seq);


     if (p_transaction_type = 'SSSO') then
     For k IN 1..x_ship_d_count loop
     dbms_sql.define_column      ( v_ship_d_sel_c,
                                   k,
				   x_ship_d_select,
                                   ece_flatfile_pvt.G_MaxColWidth);
     End Loop;


    xProgress := 'SPSOB-50-1502';
    dbms_sql.define_column_rowid ( v_ship_d_sel_c,
                                   (x_ship_d_count+1),
                                   x_ship_d_rowid);
    xProgress := 'SPSOB-50-1505';
    dbms_sql.define_column_rowid ( v_ship_d_sel_c,
                                   (x_ship_d_count+2),
                                    x_ship_d_x_rowid);
     end if;


    --***************************************************************
    --***  The following is custom tailored for this transaction    **
    --***  It finds the values and uses them in the WHERE clause to **
    --***  join tables together.                        **
    --***************************************************************

    --**************************************************
    --*** To complete the SELECT statement,      **
    --*** we will need values for the join condition.  **
    --**************************************************

    --  *** These following commented lines are reserved for Rel11

    --  **************************************************
    --  *** Perform FIND_POS outside of the LOOP!
    --  *** This could improve performance.
    --  **************************************************

    xProgress       := 'SPSOB-50-1510';
    nTrans_code_pos := ece_flatfile_pvt.POS_OF ( l_header_tbl,
                                                 ece_flatfile_pvt.G_Translator_Code );
    ec_debug.pl ( 3, 'nTrans_code_pos: ',nTrans_code_pos );

    xProgress       := 'SPSOB-50-1520';
    nHeader_key_pos := ece_flatfile_pvt.POS_OF ( l_header_tbl,
                                                 c_header_common_key_name );
    ec_debug.pl ( 3, 'nHeader_key_pos: ',nHeader_key_pos );

    xProgress     := 'SPSOB-50-1530';
    nItem_key_pos := ece_flatfile_pvt.POS_OF ( l_item_tbl,
                                               c_item_common_key_name );
    ec_debug.pl ( 3, 'nItem_key_pos: ',nItem_key_pos);

    xProgress       := 'SPSOB-50-1540';
    nItem_d_key_pos := ece_flatfile_pvt.POS_OF ( l_item_d_tbl,
                                                 c_item_d_common_key_name );
    ec_debug.pl ( 3, 'nItem_d_key_pos: ',nItem_d_key_pos );

    xProgress := 'SPSOB-50-1545';
    if (p_transaction_type = 'SSSO') then
    nShip_d_key_pos := ece_flatfile_pvt.POS_OF(  l_ship_d_tbl,
                                                 c_ship_d_common_key_name );

    ec_debug.pl ( 3, 'nShip_d_key_pos: ',nShip_d_key_pos );
    end if;

    xProgress       := 'SPSOB-50-1541';
    dbms_sql.bind_variable(v_header_sel_c,'l_p_run_id',p_run_id);

    xProgress       := 'SPSOB-50-1542';
    dbms_sql.bind_variable(v_item_sel_c,'l_p_run_id',p_run_id);

    xProgress       := 'SPSOB-50-1543';
    dbms_sql.bind_variable(v_item_d_sel_c,'l_p_run_id',p_run_id);

    xProgress       := 'SPSOB-50-1544';
    if (p_transaction_type = 'SSSO') then
    dbms_sql.bind_variable(v_ship_d_sel_c,'l_p_run_id',p_run_id);
    end if;
    --**************************************
    --*** EXECUTE the SELECT statement   **
    --**************************************

    xProgress := 'SPSOB-50-1550';
    x_dummy   := dbms_sql.execute(v_header_sel_c);


    --***********************************************************************
    --*** With data for each HEADER line, populate the ECE_OUTPUT table   **
    --*** then populate ECE_OUTPUT with data from all ITEMS that belong   **
    --*** to the HEADER. Then populate ECE_OUTPUT with data from all  **
    --*** ITEM DETAILS that belongs to the ITEM.              **
    --***********************************************************************

    xProgress := 'SPSOB-50-1560';
    WHILE dbms_sql.fetch_rows ( v_header_sel_c ) > 0
    LOOP           -- Header

      --***********************************
      --*** store values in pl/sql table  **
      --***********************************

      xProgress := 'SPSOB-50-1570';
      FOR i IN 1..x_header_count
      LOOP

        dbms_sql.column_value ( v_header_sel_c,
                                i,
                                l_header_tbl(i).value );

      END LOOP;


      xProgress := 'SPSOB-50-1580';
      dbms_sql.column_value ( v_header_sel_c,
                              x_header_count + 1,
                              x_header_rowid );

      xProgress := 'SPSOB-50-1590';
      dbms_sql.column_value ( v_header_sel_c,
                              x_header_count + 2,
                              x_header_x_rowid );


      xProgress := 'SPSOB-50-1600';
      dbms_sql.column_value ( v_header_sel_c,
                              x_header_count + 3,
                              x_schedule_id );

      xProgress         := 'SPSOB-50-1610';
      c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),
                                       1, 25),
                                25);

      xProgress         := 'SPSOB-50-1620';
      c_file_common_key := c_file_common_key                                          ||
                           RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value,' '),
                                       1, 22),
                                22)                                                   ||
                           RPAD(' ',22)                                               ||
                           RPAD(' ',22);
      ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

      xProgress := 'SPSOB-50-1630';
      ece_flatfile_pvt.write_to_ece_output ( p_transaction_type,
                                             p_communication_method,
                                             p_header_interface,
                                             l_header_tbl,
                                             p_output_width,
                                             p_run_id,
                                             c_file_common_key );

      --*************************************************************
      --***   With Header data at hand, we can assign values to **
      --***   place holders (foreign keys) in v_item_select and **
      --***   v_item_detail_Select                  **
      --*************************************************************

      --*****************************************
      --**  set values into binding variables   **
      --*****************************************

      --  These following commented lines are reserved for Rel11

      xProgress := 'SPSOB-50-1640';
      dbms_sql.bind_variable ( v_item_sel_c,
                               'SCHEDULE_ID',
                               x_schedule_id );

      xProgress := 'SPSOB-50-1650';
      dbms_sql.bind_variable ( v_item_d_sel_c,
                               'SCHEDULE_ID',
                               x_schedule_id );

      xProgress := 'SPSOB-50-1655';
      if (p_transaction_type = 'SSSO') then
      dbms_sql.bind_variable ( v_ship_d_sel_c,
                               'SCHEDULE_ID',
			       x_schedule_id );
      end if;

      xProgress := 'SPSOB-50-1660';
      x_dummy   := dbms_sql.execute ( v_item_sel_c );


      --****************************
      --**  Item loop starts here  **
      --****************************

      xProgress := 'SPSOB-50-1670';
      WHILE dbms_sql.fetch_rows ( v_item_sel_c ) > 0
      LOOP        --- Line

        --***********************************
        --**   store values in pl/sql table   **
        --************************************

        xProgress := 'SPSOB-50-1680';
        FOR j IN 1..x_item_count
        LOOP

          dbms_sql.column_value ( v_item_sel_c,
                                  j,
                                  l_item_tbl(j).value );

        END LOOP;


        xProgress := 'SPSOB-50-1690';
        dbms_sql.column_value ( v_item_sel_c,
                                x_item_count + 1,
                                x_item_rowid );

        xProgress := 'SPSOB-50-1700';
        dbms_sql.column_value ( v_item_sel_c,
                                x_item_count + 2,
                                x_item_x_rowid );

        xProgress := 'SPSOB-50-1710';
        dbms_sql.column_value ( v_item_sel_c,
                                x_item_count + 3,
                                x_schedule_item_id );

        xProgress            := 'SPSOB-50-1720';
           c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),
                                            1, 25),
                                     25)                                                   ||
                                RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value,' '),
                                            1, 22),
                                    22)                                                    ||
                                RPAD(SUBSTRB(NVL(l_item_tbl(nItem_key_pos).value,' '),
                                            1, 22),
                                    22)                                                    ||
                                RPAD(' ',22);
        ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

        xProgress := 'SPSOB-50-1730';
        ece_flatfile_pvt.write_to_ece_output ( p_transaction_type,
                                               p_communication_method,
                                               p_item_interface,
                                               l_item_tbl,
                                               p_output_width,
                                               p_run_id,
                                               c_file_common_key );


        --***********************************
        --**   set SCHEDULE_ITEM_ID values    **
        --***********************************

        xProgress := 'SPSOB-50-1740';
        dbms_sql.bind_variable ( v_item_d_sel_c,
                                 'SCHEDULE_ITEM_ID',
                                 x_schedule_item_id);

        xProgress := 'SPSOB-50-1745';
	if (p_transaction_type = 'SSSO') then
	dbms_sql.bind_variable ( v_ship_d_sel_c,
	                         'SCHEDULE_ITEM_ID',
				 x_schedule_item_id);
	end if;

        xProgress := 'SPSOB-50-1750';
        x_dummy   := dbms_sql.execute ( v_item_d_sel_c );


        --***********************************
        --**   item detail loop starts here   **
        --***********************************

        xProgress := 'SPSOB-50-1760';
        WHILE dbms_sql.fetch_rows ( v_item_d_sel_c ) > 0
        LOOP    --- Line Detail


          --************************************
          --**   store values in pl/sql table  **
          --************************************

          xProgress := 'SPSOB-50-1770';
          FOR k IN 1..x_item_d_count
          LOOP

            dbms_sql.column_value ( v_item_d_sel_c,
                                    k,
                                    l_item_d_tbl(k).value );

          END LOOP;


          xProgress := 'SPSOB-50-1780';
          dbms_sql.column_value ( v_item_d_sel_c,
                                  x_item_d_count + 1,
                                  x_item_d_rowid );

          xProgress := 'SPSOB-50-1790';
          dbms_sql.column_value ( v_item_d_sel_c,
                                  x_item_d_count + 2,
                                  x_item_d_x_rowid );

          xProgress := 'SPSOB-50-1795';
          dbms_sql.column_value(v_item_d_sel_c,
	                         x_item_d_count+3,
                                 x_sch_item_detail_seq);

          xProgress         := 'SPSOB-50-1800';
          c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),
                                           1, 25),
                                    25)                                                    ||
                               RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value,' '),
                                           1, 22),
                                    22)                                                    ||
                               RPAD(SUBSTRB(NVL(l_item_tbl(nItem_key_pos).value,' '),
                                           1, 22),
                                    22)                                                    ||
                               RPAD(SUBSTRB(NVL(l_item_d_tbl(nItem_d_key_pos).value,' '),
                                           1, 22),
                                    22);
          ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

          xProgress := 'SPSOB-50-1810';
          ece_flatfile_pvt.write_to_ece_output ( p_transaction_type,
                                                 p_communication_method,
                                                 p_item_d_interface,
                                                 l_item_d_tbl,
                                                 p_output_width,
                                                 p_run_id,
                                                 c_file_common_key );

              --***********************************
      --**   set SCHEDULE_ITEM_DETAIL_SEQUENCE  values        **
      --***********************************

        xProgress := 'SPSOB-50-1820';
	if (p_transaction_type = 'SSSO') then
        dbms_sql.bind_variable(v_ship_d_sel_c, 'SCHEDULE_ITEM_DETAIL_SEQUENCE',
                                               x_sch_item_detail_seq);

        xProgress := 'SPSOB-50-1822';
         x_dummy := dbms_sql.execute(v_ship_d_sel_c);
        --***********************************
        --**   ship detail loop starts here       **
        --***********************************

        xProgress := 'SPSOB-50-1823';
         WHILE dbms_sql.fetch_rows(v_ship_d_sel_c) > 0 LOOP	--- Ship Detail

           xProgress := 'SPSOB-50-1825';
           for k in 1..x_ship_d_count loop

              dbms_sql.column_value(v_ship_d_sel_c, k, l_ship_d_tbl(k).value);

           end loop;
           xProgress := 'SPSOB-50-1830';
           dbms_sql.column_value(v_ship_d_sel_c, x_ship_d_count+1,
							x_ship_d_rowid);
           xProgress := 'SPSOB-50-1835';
           dbms_sql.column_value(v_ship_d_sel_c, x_ship_d_count+2,
							x_ship_d_x_rowid);

           xProgress := 'SPSOB-50-1840';
           c_file_common_key := rpad(substr(nvl(l_header_tbl(nTrans_code_pos).value,' '), 1, 25), 25)
			|| rpad(substr(nvl(l_header_tbl(nHeader_key_pos).value,' '), 1, 22), 22)
			|| rpad(substr(nvl(l_item_tbl(nItem_key_pos).value,' '),   1, 22), 22)
			|| rpad(substr(nvl(l_item_d_tbl(nItem_d_key_pos).value,' '),   1, 22), 22);

           xProgress := 'SPSOB-50-1845';
           ece_flatfile_pvt.write_to_ece_output(
               p_transaction_type, p_communication_method, p_ship_d_interface,
               l_ship_d_tbl, p_output_width, p_run_id, c_file_common_key);

           xProgress := 'SPSOB-50-1850';
           dbms_sql.bind_variable(v_ship_d_del_c1, 'col_rowid',x_ship_d_rowid);

           xProgress := 'SPSOB-50-1855';
           dbms_sql.bind_variable(v_ship_d_del_c2, 'col_rowid',
							x_ship_d_x_rowid);
           xProgress := 'SPSOB-50-1856';
           x_dummy := dbms_sql.execute(v_ship_d_del_c1);

           xProgress := 'SPSOB-50-1857';
           x_dummy := dbms_sql.execute(v_ship_d_del_c2);

        END LOOP;
	end if;

      --********************************
      --** Ship detail loop ends here  **
      --********************************
          xProgress := 'SPSOB-50-1820';
          dbms_sql.bind_variable ( v_item_d_del_c1,
                                   'col_rowid',
                                   x_item_d_rowid );

          xProgress := 'SPSOB-50-1830';
          dbms_sql.bind_variable ( v_item_d_del_c2,
                                   'col_rowid',
                                   x_item_d_x_rowid );

          xProgress := 'SPSOB-50-1840';
          x_dummy   := dbms_sql.execute ( v_item_d_del_c1 );

          xProgress := 'SPSOB-50-1850';
          x_dummy   := dbms_sql.execute ( v_item_d_del_c2 );

        END LOOP;

        --********************************
        --** item detail loop ends here  **
        --********************************


        xProgress := 'SPSOB-50-1860';
        dbms_sql.bind_variable ( v_item_del_c1,
                                 'col_rowid',
                                 x_item_rowid );

        xProgress := 'SPSOB-50-1870';
        dbms_sql.bind_variable ( v_item_del_c2,
                                 'col_rowid',
                                 x_item_x_rowid );

        xProgress := 'SPSOB-50-1880';
        x_dummy   := dbms_sql.execute ( v_item_del_c1 );

        xProgress := 'SPSOB-50-1890';
        x_dummy   := dbms_sql.execute ( v_item_del_c2 );

      END LOOP;

      --***************************
      --**  item loop ends here   **
      --***************************


      xProgress := 'SPSOB-50-1900';
      dbms_sql.bind_variable ( v_header_del_c1,
                               'col_rowid',
                               x_header_rowid );

      xProgress := 'SPSOB-50-1910';
      dbms_sql.bind_variable ( v_header_del_c2,
                               'col_rowid',
                               x_header_x_rowid );

      xProgress := 'SPSOB-50-1920';
      x_dummy   := dbms_sql.execute ( v_header_del_c1 );

      xProgress := 'SPSOB-50-1930';
      x_dummy   := dbms_sql.execute ( v_header_del_c2 );

    END LOOP;

    --*****************************
    --**   header loop ends here  **
    --*****************************

    xProgress := 'SPSOB-50-1940';
    dbms_sql.close_cursor ( v_header_sel_c );

    xProgress := 'SPSOB-50-1950';
    dbms_sql.close_cursor ( v_item_sel_c );

    xProgress := 'SPSOB-50-1960';
    dbms_sql.close_cursor ( v_item_d_sel_c );

    xProgress := 'SPSOB-50-1966';
    if (p_transaction_type = 'SSSO') then
    dbms_sql.close_cursor ( v_ship_d_sel_c );
    end if;

    xProgress := 'SPSOB-50-1970';
    dbms_sql.close_cursor ( v_header_del_c1 );

    xProgress := 'SPSOB-50-1980';
    dbms_sql.close_cursor ( v_item_del_c1 );

    xProgress := 'SPSOB-50-1990';
    dbms_sql.close_cursor ( v_item_d_del_c1 );

    xProgress := 'SPSOB-50-1990';
    if (p_transaction_type = 'SSSO') then
    dbms_sql.close_cursor ( v_ship_d_del_c1 );
    end if;

    ec_debug.pop ( 'ece_spso_trans1.Put_Data_To_Output_Table' );

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

  END Put_Data_To_Output_Table;   -- end of procedure

END ECE_SPSO_TRANS1;


/
