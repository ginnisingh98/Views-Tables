--------------------------------------------------------
--  DDL for Package Body ECE_AR_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_AR_TRANSACTION" AS
-- $Header: ECEINOB.pls 120.7.12000000.2 2007/03/20 18:14:02 cpeixoto ship $

   l_Organization_ID       NUMBER;
   l_Automotive_Installed  BOOLEAN;
   l_Industry              VARCHAR2(240);
   l_Schema                VARCHAR2(240);
   l_Status                VARCHAR2(240);
   l_Automotive_Status     VARCHAR2(240);
   l_Remit_To_Address_ID   NUMBER;
   base_currency_code      varchar2(3);
   rc                      BOOLEAN;

   xProgress               VARCHAR2(30);

  /*===========================================================================

    PROCEDURE NAME:      Extract_INO_Outbound

    PURPOSE:             This procedure initiates the concurrent process to
                         extract the invoices.

  ===========================================================================*/

   PROCEDURE extract_ino_outbound(
      errbuf              OUT NOCOPY VARCHAR2,
      retcode             OUT NOCOPY VARCHAR2,
      cOutputPath         IN  VARCHAR2,
      cOutput_Filename    IN  VARCHAR2,
      cCDate_From         IN  VARCHAR2,
      cCDate_To           IN  VARCHAR2,
      cCustomer_Name      IN  VARCHAR2,
      cSite_Use_Code      IN  VARCHAR2,
      cDocument_Type      IN  VARCHAR2,
      cTransaction_Number IN  VARCHAR2,
      cdebug_mode         IN  NUMBER    DEFAULT 0) IS

      xHeaderCount             NUMBER;
      iRun_id                  NUMBER              := 0;
      iRequestID               NUMBER              := 0;
      iOutput_width            INTEGER             := 4000;
      cTransaction_Type        VARCHAR2(120)       := 'INO';
      cFilename                VARCHAR2(30)        := NULL;
      dTransaction_date        DATE;
      cCommunication_Method    VARCHAR2(120)       := 'EDI';
      cHeader_Interface        VARCHAR2(120)       := 'ECE_AR_TRX_HEADERS';
      cHeader_1_Interface      VARCHAR2(120)       := 'ECE_AR_TRX_HEADER_1';
      cAlw_chg_Interface       VARCHAR2(120)       := 'ECE_AR_TRX_ALLOWANCE_CHARGES';
      cLine_Interface          VARCHAR2(120)       := 'ECE_AR_TRX_LINES';
      cLine_t_Interface        VARCHAR2(120)       := 'ECE_AR_TRX_LINE_TAX';
      l_line_text              VARCHAR2(2000);
      uFile_type               utl_file.file_type;
      cCreate_Date_From        DATE                := TO_DATE(cCDate_From,'YYYY/MM/DD HH24:MI:SS');
      cCreate_Date_To          DATE                := TO_DATE(cCDate_To,'YYYY/MM/DD HH24:MI:SS') + 1;
      cExport_Type             VARCHAR2(30)        := 'INVOICE';
      cEnabled                 VARCHAR2(1)         := 'Y';
      ece_transaction_disabled EXCEPTION;

      CURSOR c_output IS
         SELECT   text
         FROM     ece_output
         WHERE    run_id = iRun_id
         ORDER BY line_id;

      BEGIN
         ec_debug.enable_debug(cdebug_mode);
         ec_debug.push('ECE_AR_TRANSACTION.EXTRACT_INO_OUTBOUND');
         ec_debug.pl(3,'cOutputPath: '        ,cOutputPath);
         ec_debug.pl(3,'cOutput_Filename: '   ,cOutput_Filename);
         ec_debug.pl(3,'cCDate_From: '        ,cCDate_From);
         ec_debug.pl(3,'cCDate_To: '          ,cCDate_To);
         ec_debug.pl(3,'cCustomer_Name: '     ,cCustomer_Name);
         ec_debug.pl(3,'cSite_Use_Code: '     ,cSite_Use_Code);
         ec_debug.pl(3,'cDocument_Type: '     ,cDocument_Type);
         ec_debug.pl(3,'cTransaction_Number: ',cTransaction_Number);
         ec_debug.pl(3,'cdebug_mode: '        ,cdebug_mode);

         /* Check to see if the transaction is enabled. If not, abort */
         xProgress := 'INO-10-1000';
         fnd_profile.get('ECE_' || cTransaction_Type || '_ENABLED',cEnabled);

         xProgress := 'INO-10-1005';
         IF cEnabled = 'N' THEN
            xProgress := 'INO-10-1010';
            RAISE ece_transaction_disabled;
         END IF;

         xProgress := 'INO-10-1015';
         BEGIN
            SELECT ece_output_runs_s.NEXTVAL INTO iRun_id
            FROM   DUAL;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ec_debug.pl(1,
                          'EC',
                          'ECE_GET_NEXT_SEQ_FAILED',
                          'PROGRESS_LEVEL',
                           xProgress,
                          'SEQ',
                          'ECE_OUTPUT_RUNS_S');

         END;
         ec_debug.pl(3,'iRun_id: ',iRun_id);

         xProgress := 'INO-10-1020';
         ec_debug.pl(0,'EC','ECE_RUN_ID','RUN_ID',iRun_id);

         xProgress := 'INO-10-1030';
         BEGIN
            SELECT SYSDATE INTO dTransaction_date
            FROM   DUAL;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ec_debug.pl(1,
                          'EC',
                          'ECE_GET_SYSDATE_FAILED',
                          'PROGRESS_LEVEL',
                           xProgress,
                          'TABLE_NAME',
                          'DUAL');

         END;
         ec_debug.pl(3,'dTransaction_date: ',dTransaction_date);

         xProgress := 'INO-10-1040';
         ece_ar_transaction.populate_ar_trx(
            cCommunication_Method,
            cTransaction_Type,
            iOutput_width,
            dTransaction_date,
            iRun_id,
            cHeader_Interface,
            cHeader_1_Interface,
            cAlw_chg_Interface,
            cLine_Interface,
            cLine_t_Interface,
            cCreate_Date_From,
            cCreate_Date_To,
            cCustomer_Name,
            cSite_Use_Code,
            cDocument_Type,
            cTransaction_Number);

         xProgress := 'INO-10-1043';
         BEGIN
            SELECT COUNT(*) INTO xHeaderCount
            FROM   ece_ar_trx_headers
            WHERE   run_id = iRun_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ec_debug.pl(1,
                          'EC',
                          'ECE_GET_COUNT_FAILED',
                          'PROGRESS_LEVEL',
                           xProgress,
                          'TABLE_NAME',
                          'ECE_OUTPUT');

         END;
         ec_debug.pl(3,'xHeaderCount: ',xHeaderCount);

         xProgress := 'INO-10-1045';
         ec_debug.pl(0,'EC','ECE_TRANSACTIONS_PROCESSED','NUMBER_OF_TRX',xHeaderCount);

         xProgress := 'INO-10-1050';
         ece_ar_transaction.put_data_to_output_table(
            cCommunication_Method,
            cTransaction_Type,
            iOutput_width,
            iRun_id,
            cHeader_Interface,
            cHeader_1_Interface,
            cAlw_chg_Interface,
            cLine_Interface,
            cLine_t_Interface);

         -- Allow users to enter a null value for filename.  If it is null,
         -- generate a unique filename.  This is to handle the ability to setup
         -- transaction to run automatically on a periodic basis (i.e. daily)
         -- in SRS.
         IF cOutput_Filename IS NULL THEN
            cFilename := 'INO' || iRun_id || '.dat';
         ELSE
            cFilename := cOutput_Filename;
         END IF;

         -- Open the file for write.
         xProgress  := 'INO-10-1060';

         -- Open the cursor to select the actual file output from ece_output.
         xProgress := 'INO-10-1070';
         OPEN c_output;
         LOOP
            FETCH c_output INTO l_line_text;
            ec_debug.pl(3,'l_line_text: ',l_line_text);
            if (c_output%ROWCOUNT > 0) then
            if (NOT utl_file.is_open(uFile_type)) then
            uFile_type := utl_file.fopen(cOutputPath,
                                         cFilename,
                                         'W');
            end if;
            end if;
            EXIT WHEN c_output%NOTFOUND;

            -- Write the data from ece_output to the output file.
            xProgress := 'INO-10-1080';
            utl_file.put_line(uFile_type,
                              l_line_text);

         END LOOP;

         CLOSE c_output;

         -- Close the output file.
         xProgress := 'INO-10-1090';
         if (utl_file.is_open(uFile_type)) then
         utl_file.fclose(uFile_type);
         end if;

         -- Assume everything went ok so delete the records from ece_output.
         xProgress := 'INO-10-1100';
         DELETE FROM ece_output
         WHERE       run_id = iRun_id;

         IF SQL%NOTFOUND THEN
            ec_debug.pl(1,
                       'EC',
                       'ECE_NO_ROW_DELETED',
                       'PROGRESS_LEVEL',
                        xProgress,
                       'TABLE_NAME',
                       'ECE_OUTPUT' );
         END IF;

         -- Check if the Automotive Module is installed and if it is installed,
         -- export the file created to Radley Caras
         xProgress := 'INO-10-1110';
         l_automotive_installed := fnd_installation.get_app_info('VEH',
                                                                  l_status,
                                                                  l_industry,
                                                                  l_schema);
         l_automotive_status := l_status;
         ec_debug.pl(3,'l_automotive_status: ',l_automotive_status);

         IF l_automotive_status = 'I' THEN
            xProgress  := 'INO-10-1120';
            iRequestID := fnd_request.submit_request(Application => 'VEH',
                                                     Program     => 'VEH_DSN_IMPORT',
                                                     Description => 'Start Radley CARaS script to Import DSN',
                                                     Start_Time  =>  NULL,
                                                     Sub_Request =>  FALSE,
                                                     Argument1   =>  cExport_Type,
                                                     Argument2   =>  cOutputPath,
                                                     Argument3   =>  cFilename );
         END IF;

      IF ec_mapping_utils.ec_get_trans_upgrade_status(cTransaction_Type)  = 'U' THEN
         ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
         retcode := 1;
      END IF;

         ec_debug.pop('ECE_AR_TRANSACTION.EXTRACT_INO_OUTBOUND');
         ec_debug.disable_debug;

         COMMIT;

      EXCEPTION
         WHEN ece_transaction_disabled THEN
            ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',cTransaction_type);
            retcode := '1';
            ec_debug.disable_debug;
            ROLLBACK;

         WHEN utl_file.write_error THEN
            ec_debug.pl(0,'EC','ECE_UTL_WRITE_ERROR',NULL);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
            ROLLBACK;

         WHEN utl_file.invalid_path THEN
            ec_debug.pl(0,'EC','ECE_UTIL_INVALID_PATH',NULL);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
            ROLLBACK;

         WHEN utl_file.invalid_operation THEN
            ec_debug.pl(0,'EC','ECE_UTIL_INVALID_OPERATION',NULL);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
            ROLLBACK;

         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
            ROLLBACK;

      END extract_ino_outbound;

  PROCEDURE Define_Interface_Column ( c        IN INTEGER,
                                      col      IN VARCHAR,
                                      col_size IN INTEGER,
                                      tbl      IN ece_flatfile_pvt.Interface_tbl_type )
  IS

    i                     INTEGER := 0;

  BEGIN

    ec_debug.push ( 'ECE_AR_TRANSACTION.DEFINE_INTERFACE_COLUMN' );
    ec_debug.pl ( 3, 'c: ', c );
    ec_debug.pl ( 3, 'col: ',col );
    ec_debug.pl ( 3, 'col_size: ',col_size );

    xProgress := '2000-10';
    FOR k IN 1..tbl.count
    LOOP
      dbms_sql.define_column ( c,
                               k,
                               col,
                               col_size );
    END LOOP;

    ec_debug.pop('ECE_AR_TRANSACTION.DEFINE_INTERFACE_COLUMN');

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

  END Define_Interface_Column;

  PROCEDURE Update_AR ( Document_Type               IN  VARCHAR2,
                        Transaction_ID              IN  NUMBER,
                        Installment_Number          IN  NUMBER,
                        Multiple_Installments_Flag  IN  VARCHAR2,
                        Maximum_Installment_Number  IN  NUMBER,
                        Update_Date                 IN  DATE )
  IS


  l_Update_Value          VARCHAR2(20);
  l_EDI_Flag              VARCHAR2(1);
  l_Print_Flag            VARCHAR2(1);

  BEGIN

    ec_debug.push('ECE_AR_TRANSACTION.UPDATE_AR');
    ec_debug.pl ( 3, 'Document_Type: ', Document_Type );
    ec_debug.pl ( 3, 'Transaction_ID: ', Transaction_ID );
    ec_debug.pl ( 3, 'Installment_Number: ', Installment_Number );
    ec_debug.pl ( 3, 'Multiple_Installments_Flag: ',Multiple_Installments_Flag );
    ec_debug.pl ( 3, 'Maximum_Installment_Number: ',Maximum_Installment_Number );
    ec_debug.pl ( 3, 'Update_Date: ',Update_Date );

    xProgress := '2000-20';
    BEGIN                      /*2945057*/
      SELECT edi_flag,
             print_flag
        INTO l_EDI_flag,
             l_Print_flag
        FROM ra_customer_trx        rct,
             ece_tp_details         etd,
             hz_cust_acct_sites     rad,
             hz_cust_site_uses      rsu
       WHERE rct.bill_to_site_use_id = rsu.site_use_id
         AND rsu.cust_acct_site_id  = rad.cust_acct_site_id
         AND rad.tp_header_id       = etd.tp_header_id
         AND etd.document_type      = Update_AR.Document_Type
         AND rct.customer_trx_id    = Update_AR.Transaction_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'EDI FLAG, PRINT FLAG',
                      'TABLE_NAME',
                      'RA_CUSTOMER_TRX, ECE_TP_DETAILS, HZ_CUST_ACCT_SITES,HZ_CUST_SITE_USES' );
    END;

    IF l_EDI_Flag    = 'Y' AND
       l_Print_Flag  = 'Y'
    THEN
      l_Update_Value := 'EP';
    END IF;

    IF l_EDI_Flag    = 'Y' AND
       l_Print_Flag <> 'Y'
    THEN
      l_Update_Value := 'ED';
    END IF;

    IF l_EDI_Flag   <> 'Y' AND
       l_Print_Flag  = 'Y'
    THEN
      l_Update_Value := 'PR';
    END IF;

    ec_debug.pl ( 3, 'L_UPDATE_VALUE: ',l_Update_Value );

    xProgress := '2010-20';
    UPDATE ra_customer_trx
       SET last_update_date          = SYSDATE,
           printing_pending          = DECODE (Document_Type,
                                               'CM', 'N',
                                               'OACM', 'N',
                                               DECODE (Maximum_Installment_Number,
                                                       Installment_Number, 'N',
                                                       NULL, 'N',
                                                       1, 'N',
                                                       'Y')),
           printing_count            = NVL(printing_count,0) + 1,
           printing_last_printed     = SYSDATE,
           printing_original_date    = DECODE (NVL(printing_count,0),
                                               0, SYSDATE,
                                               printing_original_date ),
           last_printed_sequence_num = DECODE  (Multiple_Installments_Flag,
                                                'N',NULL,
                                                GREATEST(NVL(last_printed_sequence_num,0),
                                                         Installment_Number)),
           edi_processed_flag        = 'Y',
           edi_processed_status      = l_Update_Value
     WHERE customer_trx_id           = Update_AR.Transaction_ID;

    IF SQL%NOTFOUND
    THEN
      ec_debug.pl (0,
                   'EC',
                   'ECE_NO_ROW_UPDATED',
                   'PROGRESS_LEVEL',
                   xProgress,
                   'INFO',
                   'EDI PROCESSED',
                   'TABLE_NAME',
                   'RA_CUSTOMER_TRX' );
    END IF;

  /* The following lines were commented out was because of a request
     from a beta site.  Their business practice requires them to
     print multiple installment invoices at the same time.

     BE AWARE: by doing so, we are removing the data consistency test.
  */
  --  AND LAST_UPDATE_DATE = Update_AR.Update_Date;

    -- The join on last_update_date is to ensure that the
    -- record has not been updated by another user, between
    -- the select above and the lock created by this update.

  /*  IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20000,'Record changed by another user.');
    END IF;
  */

  ec_debug.pop('ECE_AR_TRANSACTION.UPDATE_AR');
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

  END Update_AR;

  PROCEDURE Get_Remit_Address ( Customer_Trx_ID      IN  NUMBER,
                                Remit_To_Address1    OUT NOCOPY VARCHAR2,
                                Remit_To_Address2    OUT NOCOPY VARCHAR2,
                                Remit_To_Address3    OUT NOCOPY VARCHAR2,
                                Remit_To_Address4    OUT NOCOPY VARCHAR2,
                                Remit_To_City        OUT NOCOPY VARCHAR2,
                                Remit_To_County      OUT NOCOPY VARCHAR2,
                                Remit_To_State       OUT NOCOPY VARCHAR2,
                                Remit_To_Province    OUT NOCOPY VARCHAR2,
                                Remit_To_Country     OUT NOCOPY VARCHAR2,
                                Remit_To_Code_Int    OUT NOCOPY VARCHAR2,
                                Remit_To_Postal_Code OUT NOCOPY VARCHAR2,
                                Remit_To_Customer_Name OUT NOCOPY VARCHAR2,  --2291130
                                Remit_To_Edi_Location_Code OUT NOCOPY VARCHAR2)
 IS

    dummy                 NUMBER;

  BEGIN

    ec_debug.push('ECE_AR_TRANSACTION.GET_REMIT_ADDRESS');
    ec_debug.pl ( 3, 'customer_trx_id: ', Customer_Trx_ID );

    xProgress := '2000-30';
    BEGIN
      SELECT  remit_to_address_id INTO l_Remit_To_Address_ID
        FROM  RA_CUSTOMER_TRX
       WHERE  CUSTOMER_TRX_ID = Get_Remit_Address.Customer_Trx_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'REMIT TO ADDRESS ID',
                      'TABLE_NAME',
                      'RA_CUSTOMER_TRX' );
    END;

    ec_debug.pl ( 3, 'l_Remit_To_Address_ID: ', l_Remit_To_Address_ID );

    IF l_Remit_To_Address_ID IS NULL
    THEN

      DECLARE

      CURSOR remit_cur IS
      SELECT rt.address_id
        FROM ra_customer_trx               rct,
             hz_cust_acct_sites            a,
             hz_party_sites                hps,
             hz_locations                  loc,
             ra_remit_tos                  rt
       WHERE rct.customer_trx_id           = Get_Remit_Address.Customer_Trx_ID
         AND rct.bill_to_address_id        = a.cust_acct_site_id AND
         a.party_site_id                   = hps.party_site_id  AND
         hps.location_id                   = loc.location_id
         AND rt.status                     = 'A'
         AND NVL(a.status,'A')             = 'A'
         AND rt.country                    = loc.COUNTRY
         AND ( loc.state                     = NVL(rt.state, loc.state)
             OR  (   loc.state              IS NULL
                 AND rt.state             IS NULL
                 )
             OR  (   loc.state              IS NULL
                 AND loc.postal_code        <= NVL(rt.postal_code_high, loc.postal_code)
                 AND loc.postal_code        >= NVL(rt.postal_code_low,  loc.postal_code)
                 AND (   postal_code_low  IS NOT NULL
                      OR postal_code_high IS NOT NULL
                     )
                 )
             )
         AND (  (    loc.postal_code        <= NVL(rt.postal_code_high, loc.postal_code)
                 AND loc.postal_code        >= NVL(rt.postal_code_low, loc.postal_code)
                )
           OR   (    loc.postal_code        IS NULL
                 AND rt.postal_code_low   IS NULL
                 AND rt.postal_code_high  IS NULL
                )
             )
       ORDER BY rt.state,
                rt.postal_code_low,
                rt.postal_code_high;

      BEGIN

        -- We only want the first record from the select since the
        -- order by puts the records in a special order

        xProgress := '2010-30';
        OPEN remit_cur;

        FETCH remit_cur INTO l_Remit_To_Address_ID;
        ec_debug.pl (3, 'l_Remit_To_Address_ID: ', l_Remit_To_Address_ID);

        IF remit_cur%NOTFOUND THEN
          l_Remit_To_Address_ID := NULL;
        END IF;

        CLOSE remit_cur;

      END;

    END IF;

    IF l_Remit_To_Address_ID IS NULL
    THEN
      xProgress := '2020-30';
      BEGIN
        SELECT MIN(address_id)
          INTO l_Remit_To_Address_ID
          FROM ra_remit_tos
         WHERE status  = 'A'
           AND state   = 'DEFAULT'
           AND country = 'DEFAULT';
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_NO_ROW_SELECTED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'INFO',
                        'MINIMUM ADDRESS ID',
                        'TABLE_NAME',
                        'RA_REMIT_TOS' );
      END;

      ec_debug.pl ( 3, 'l_Remit_To_Address_ID: ', l_Remit_To_Address_ID );

    END IF;

    xProgress := '2030-30';
    BEGIN
      SELECT loc.address1,
             loc.address2,
             loc.address3,
             loc.address4,
             loc.city,
             loc.county,
             loc.state,
             loc.province,
             loc.country,
             loc.postal_code,
             hcas.orig_system_reference,
             substr(loc.address_lines_phonetic,1,50),  --2291130
             hcas.ece_tp_location_code                  --2386848
     INTO Remit_To_Address1,
             Remit_To_Address2,
             Remit_To_Address3,
             Remit_To_Address4,
             Remit_To_City,
             Remit_To_County,
             Remit_to_state,
             Remit_To_Province,
             Remit_To_Country,
             Remit_To_Postal_Code,
             Remit_To_Code_Int,
             Remit_to_customer_name,                 --2291130
             Remit_to_edi_location_code
          FROM hz_cust_acct_sites      hcas,
               hz_party_sites          hps,
               hz_locations            loc
       WHERE  hps.party_site_id = hcas.party_site_id
          AND hps.location_id = loc.location_id
          AND hcas.cust_acct_site_id                = l_Remit_To_Address_ID;
 -- bug 4718847
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'RA ADDRESS',
                      'TABLE_NAME',
                      'HZ_CUST_ACCT_SITES' );
    END;

    ec_debug.pop('ECE_AR_TRANSACTION.GET_REMIT_ADDRESS');

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

  END Get_Remit_Address;

  PROCEDURE Get_Payment ( Customer_Trx_ID            IN  NUMBER,
                          Installment_Number         IN  NUMBER,
                          Multiple_Installments_Flag OUT NOCOPY VARCHAR2,
                          Maximum_Installment_Number OUT NOCOPY NUMBER,
                          Amount_Tax_Due             OUT NOCOPY NUMBER,
                          Amount_Charges_Due         OUT NOCOPY NUMBER,
                          Amount_Freight_Due         OUT NOCOPY NUMBER,
                          Amount_Line_Items_Due      OUT NOCOPY NUMBER,
                          Total_Amount_Due           OUT NOCOPY NUMBER )

  IS

    l_Term_ID                    NUMBER;
    l_Payment_Schedule_Exists    VARCHAR2(1);
    l_Term_Base_Amount           NUMBER;
    l_Term_Relative_Amount       NUMBER;
    l_Minimum_Installment_Number NUMBER;
    l_Amount_Tax_Due             NUMBER;
    l_Amount_Charges_Due         NUMBER;
    l_Amount_Freight_Due         NUMBER;
    l_Amount_Line_Items_Due      NUMBER;
    l_First_Installment_Code     VARCHAR2(30);
    l_Type                       VARCHAR2(30);
    l_Currency_Precision         NUMBER;

  -- This procedure gets the amount due/credited for a paricular installment
  -- of an Invoice or Credit Memo (or any of the related documents)

  BEGIN

    ec_debug.push ( 'ece_ar_transaction.Get_Payment' );
    ec_debug.pl ( 3, 'Customer_Trx_ID: ', Customer_Trx_ID );

    -- This select statement is used to determine whether this transaction
    -- has a payment_schedule.  If it does we can get all of the information
    -- we need directly from the payment_schedule, else we need to derive it
    -- from the payment term.

    xProgress := '2000-40';
    BEGIN
      SELECT rct.term_id,
             fc.precision,
             rctt.accounting_affect_flag,
             rctt.type,
             rt.first_installment_code,
             DECODE(rctt.type,
                    'CM',   'N',
                    'OACM', 'N',
                    DECODE(COUNT(*),
                           0, 'N',
                           1, 'N',
                           'Y')),
             MAX(rtl.sequence_num),
             MIN(rtl.sequence_num)
        INTO l_Term_ID,
             l_Currency_Precision,
             l_Payment_Schedule_Exists,
             l_Type,
             l_First_Installment_Code,
             Multiple_Installments_Flag,
             Maximum_Installment_Number,
             l_Minimum_Installment_Number
        FROM ra_customer_trx           rct,
             ra_cust_trx_types         rctt,
             ra_terms_lines            rtl,
             ra_terms                  rt,
             fnd_currencies fc
       WHERE rct.customer_trx_id       = Get_Payment.Customer_Trx_ID
         AND rct.invoice_currency_code = fc.currency_code
         AND rct.cust_trx_type_id      = rctt.cust_trx_type_id
         AND rct.term_id               = rt.term_id (+)
         AND rt.term_id                = rtl.term_id (+)
    GROUP BY rct.term_id,
             fc.precision,
             rctt.accounting_affect_flag,
             rctt.type,
             rt.first_installment_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'PAYMENT SCHEDULE',
                      'TABLE_NAME',
                      'RA_CUSTOMER_TRX, RA_CUST_TRX_TYPES, RA_TERMS_LINES, RA_TERMS, FND_CURRENCIES' );
    END;

    ec_debug.pl ( 3, 'l_Term_ID: ', l_Term_ID );
    ec_debug.pl ( 3, 'l_Currency_Precision: ', l_Currency_Precision );
    ec_debug.pl ( 3, 'l_Payment_Schedule_Exists: ', l_Payment_Schedule_Exists );
    ec_debug.pl ( 3, 'l_Type: ', l_Type );
    ec_debug.pl ( 3, 'l_First_Installment_Code: ', l_First_Installment_Code );
    ec_debug.pl ( 3, 'Multiple_Installments_Flag: ', Multiple_Installments_Flag );
    ec_debug.pl ( 3, 'Maximum_Installment_Number: ', Maximum_Installment_Number );
    ec_debug.pl ( 3, 'l_Minimum_Installment_Number: ', l_Minimum_Installment_Number );

    xProgress := '2010-40';
    BEGIN
      SELECT NVL(MIN(rtl.relative_amount),1),
             NVL(MIN(rt.base_amount),1)
        INTO l_Term_Relative_Amount,
             l_Term_Base_Amount
        FROM ra_terms         rt,
             ra_terms_lines   rtl
       WHERE rt.term_id       = l_Term_ID
         AND rt.term_id       = rtl.term_id
         AND rtl.sequence_num = Get_Payment.Installment_Number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'AMOUNT',
                      'TABLE_NAME',
                      'RA_TERMS, RA_TERMS_LINES' );
    END;

    ec_debug.pl ( 3, 'l_Term_Relative_Amount: ', l_Term_Relative_Amount );
    ec_debug.pl ( 3, 'l_Term_Base_Amount: ', l_Term_Base_Amount );

    IF l_Payment_Schedule_Exists = 'Y'
    THEN
      xProgress := '2020-40';
      BEGIN
        SELECT NVL(tax_original,0),
               NVL(freight_original,0),
               NVL(amount_line_items_original,0),
               NVL(amount_due_original,0)
          INTO Amount_Tax_Due,
               Amount_Freight_Due,
               Amount_Line_Items_Due,
               Total_Amount_Due
          FROM ar_payment_schedules
         WHERE customer_trx_id                              = Get_Payment.Customer_Trx_ID
           AND DECODE(l_Type,
                      'CM',   Get_Payment.Installment_Number,
                      'OACM', Get_Payment.Installment_Number,
                       NVL(terms_sequence_number,
                           Get_Payment.Installment_Number)) = Get_Payment.Installment_Number;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_NO_ROW_SELECTED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'INFO',
                        'PAYMENT SCHEDULE',
                        'TABLE_NAME',
                        'AR_PAYMENT_SCHEDULES' );
      END;

      ec_debug.pl ( 3, 'Amount_Tax_Due: ', Amount_Tax_Due );
      ec_debug.pl ( 3, 'Amount_Freight_Due: ', Amount_Freight_Due );
      ec_debug.pl ( 3, 'Amount_Line_Items_Due: ', Amount_Line_Items_Due );
      ec_debug.pl ( 3, 'Total_Amount_Due: ', Total_Amount_Due );

      xProgress := '2030-40';
      BEGIN
        SELECT NVL(SUM((NVL(rctl.quantity_invoiced,
                            rctl.quantity_credited) *
                       rctl.unit_selling_price)     *
                       l_Term_Relative_Amount       /
                       l_Term_Base_Amount),
                   0)
          INTO Amount_Charges_Due
          FROM ra_customer_trx_lines  rctl
         WHERE rctl.customer_trx_id   = Get_Payment.Customer_Trx_ID
           AND rctl.line_type         = 'CHARGES';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_NO_ROW_SELECTED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'INFO',
                        'CHARGE AMOUNT DUE',
                        'TABLE_NAME',
                        'RA_CUSTOMER_TRX_LINES' );
      END;

      ec_debug.pl ( 3, 'Amount_Charges_Due: ', Amount_Charges_Due );

    ELSE

      -- There isn't any payment_schedule, so we need to get the information by
      -- summing up the tax, freight and lines and then applying the payment
      -- term, currency precision and if tax/freight are prorated

      xProgress := '2040-40';
      BEGIN
        SELECT ROUND(SUM(extended_amount               *
                         l_Term_Relative_Amount        /
                         l_Term_Base_Amount),
                     l_Currency_Precision)
          INTO l_Amount_Line_Items_Due
          FROM ra_customer_trx_lines
         WHERE customer_trx_id = Get_Payment.Customer_Trx_ID
           AND line_type       NOT IN ('TAX','FREIGHT','CHARGES');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_NO_ROW_SELECTED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'INFO',
                        'LINE ITEM AMOUNT DUE',
                        'TABLE_NAME',
                        'RA_CUSTOMER_TRX_LINES' );
      END;

      ec_debug.pl ( 3, 'l_Amount_Line_Items_Due: ', l_Amount_Line_Items_Due );

      xProgress := '2050-40';
      BEGIN
        SELECT ROUND(SUM(extended_amount        *
                         l_Term_Relative_Amount /
                         l_Term_Base_Amount),
                     l_Currency_Precision)
          INTO l_Amount_Charges_Due
          FROM ra_customer_trx_lines
         WHERE customer_trx_id = Get_Payment.Customer_Trx_ID
           AND line_type       = 'CHARGES';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_NO_ROW_SELECTED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'INFO',
                        'CHARGE AMOUNT DUE',
                        'TABLE_NAME',
                        'RA_CUSTOMER_TRX_LINES' );
      END;

      ec_debug.pl ( 3, 'l_Amount_Charges_Due: ', l_Amount_Charges_Due );

      -- Check to see if the tax/freight are prorated across installments
      -- or if they are simply included on the first installment.

      xProgress := '2060-40';
      IF l_First_Installment_Code = 'INCLUDE'
      THEN
        xProgress := '2070-40';
        IF l_Minimum_Installment_Number = Get_Payment.Installment_Number
        THEN

          xProgress := '2080-40';
          BEGIN
            SELECT SUM(extended_amount)
              INTO l_Amount_Tax_Due
              FROM ra_customer_trx_lines
             WHERE customer_trx_id = Get_Payment.Customer_Trx_ID
               AND line_type       = 'TAX';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ec_debug.pl ( 1,
                            'EC',
                            'ECE_NO_ROW_SELECTED',
                            'PROGRESS_LEVEL',
                            xProgress,
                            'INFO',
                            'TAX AMOUNT DUE',
                            'TABLE_NAME',
                            'RA_CUSTOMER_TRX_LINES' );
          END;

          ec_debug.pl (3, 'l_Amount_Tax_Due: ', l_Amount_Tax_Due);

          xProgress := '2090-40';
          BEGIN
            SELECT SUM(extended_amount)
              INTO l_Amount_Freight_Due
              FROM ra_customer_trx_lines
             WHERE customer_trx_id = Get_Payment.Customer_Trx_ID
               AND line_type       = 'FREIGHT';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ec_debug.pl ( 1,
                            'EC',
                            'ECE_NO_ROW_SELECTED',
                            'PROGRESS_LEVEL',
                            xProgress,
                            'INFO',
                            'FREIGHT AMOUNT DUE',
                            'TABLE_NAME',
                            'RA_CUSTOMER_TRX_LINES' );
          END;

          ec_debug.pl (3, 'l_Amount_Freight_Due: ', l_Amount_Freight_Due);

        ELSE

          l_Amount_Tax_Due     := 0;
          l_Amount_Freight_Due := 0;

        END IF;

      ELSE

        xProgress := '2100-40';
        BEGIN
          SELECT ROUND(SUM(extended_amount         *
                           l_Term_Relative_Amount  /
                           l_Term_Base_Amount),
                       l_Currency_Precision)
            INTO l_Amount_Tax_Due
            FROM ra_customer_trx_lines
           WHERE customer_trx_id = Get_Payment.Customer_Trx_ID
             AND line_type       = 'TAX';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 1,
                          'EC',
                          'ECE_NO_ROW_SELECTED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'INFO',
                          'TAX AMOUNT DUE',
                          'TABLE_NAME',
                          'RA_CUSTOMER_TRX_LINES' );
        END;

        ec_debug.pl ( 3, 'l_Amount_Tax_Due: ', l_Amount_Tax_Due );

        xProgress := '2110-40';
        BEGIN
          SELECT ROUND(SUM(extended_amount         *
                           l_Term_Relative_Amount  /
                           l_Term_Base_Amount),
                       l_Currency_Precision)
            INTO l_Amount_Freight_Due
            FROM ra_customer_trx_lines
           WHERE customer_trx_id = Get_Payment.Customer_Trx_ID
             AND line_type       = 'FREIGHT';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             ec_debug.pl ( 1,
                           'EC',
                           'ECE_NO_ROW_SELECTED',
                           'PROGRESS_LEVEL',
                           xProgress,
                           'INFO',
                           'FREIGHT AMOUNT DUE',
                           'TABLE_NAME',
                           'RA_CUSTOMER_TRX_LINES' );
         END;

        ec_debug.pl ( 3, 'l_Amount_Freight_Due: ', l_Amount_Freight_Due );

      END IF;

      -- Total up the values and assign them to the out parameters.

      xProgress             := '2120-40';
      Total_Amount_Due      := l_Amount_Tax_Due          +
                               l_Amount_Freight_Due      +
                               l_Amount_Charges_Due      +
                               l_Amount_Line_items_Due;
      Amount_Tax_Due        := NVL(l_Amount_Tax_Due,0);
      Amount_Charges_Due    := NVL(l_Amount_Charges_Due,0);
      Amount_Freight_Due    := NVL(l_Amount_Freight_Due,0);
      Amount_Line_Items_Due := NVL(l_Amount_Line_Items_Due,0);

      ec_debug.pl ( 3, 'Total_Amount_Due: ', Total_Amount_Due );
      ec_debug.pl ( 3, 'Amount_Tax_Due: ', Amount_Tax_Due );
      ec_debug.pl ( 3, 'Amount_Charges_Due: ', Amount_Charges_Due );
      ec_debug.pl ( 3, 'Amount_Freight_Due: ', Amount_Freight_Due );
      ec_debug.pl ( 3, 'Amount_Line_Items_Due: ', Amount_Line_Items_Due );

    END IF;


    ec_debug.pop ( 'ece_ar_transaction.Get_Payment' );

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

  END Get_Payment;


  -- The following procedure gets the discount information
  -- for the term being used.  The discount info is a sub-table
  -- off of terms, this procedure will get the first three
  -- discounts, this is a denormalization, but is being used
  -- to avoid the overhead of another level of data.
  -- Also it is assumed that Credit Memo types (CM and OACM) do not have
  -- payment terms information, even though they mat have a payment term

  --Bug 2389231 Added a new column Invoice_date.

  PROCEDURE Get_Term_Discount ( Document_Type            IN  VARCHAR2,
                                Term_ID                  IN  NUMBER,
                                Term_Sequence_Number     IN  NUMBER,
                                Invoice_date             IN  DATE,
                                Discount_Percent1        OUT NOCOPY NUMBER,
                                Discount_Days1           OUT NOCOPY NUMBER,
                                Discount_Date1           OUT NOCOPY DATE,
                                Discount_Day_Of_Month1   OUT NOCOPY NUMBER,
                                Discount_Months_Forward1 OUT NOCOPY NUMBER,
                                Discount_Percent2        OUT NOCOPY NUMBER,
                                Discount_Days2           OUT NOCOPY NUMBER,
                                Discount_Date2           OUT NOCOPY DATE,
                                Discount_Day_Of_Month2   OUT NOCOPY NUMBER,
                                Discount_Months_Forward2 OUT NOCOPY NUMBER,
                                Discount_Percent3        OUT NOCOPY NUMBER,
                                Discount_Days3           OUT NOCOPY NUMBER,
                                Discount_Date3           OUT NOCOPY DATE,
                                Discount_Day_Of_Month3   OUT NOCOPY NUMBER,
                                Discount_Months_Forward3 OUT NOCOPY NUMBER )
  IS

    CURSOR discount IS
      SELECT discount_percent,
             discount_days,
             nvl(discount_date,Get_Term_Discount.Invoice_date + discount_days),    --Bug 2389231
             discount_day_of_month,
             discount_months_forward
        FROM ra_terms_lines_discounts
       WHERE term_id      = Get_Term_Discount.Term_ID
         AND sequence_num = Get_Term_Discount.Term_Sequence_Number;

    l_Counter                   NUMBER DEFAULT 1;
    l_Discount_Percent          NUMBER;
    l_Discount_Days             NUMBER;
    l_Discount_Date             DATE;
    l_Discount_Day_Of_Month     NUMBER;
    l_Discount_Months_Forward   NUMBER;


  BEGIN

    ec_debug.push ( 'ece_ar_transaction.Get_Term_Discount' );
    ec_debug.pl ( 3, 'Document_Type: ', Document_Type );
    ec_debug.pl ( 3, 'Term_ID: ',Term_ID );
    ec_debug.pl ( 3, 'Term_Sequence_Number: ',Term_Sequence_Number );

    xProgress := '2000-50';
    IF get_term_discount.Document_Type IN ('CM','OACM')
    THEN

      Discount_Percent1        := NULL;
      Discount_Days1           := NULL;
      Discount_Date1           := NULL;
      Discount_Day_Of_Month1   := NULL;
      Discount_Months_Forward1 := NULL;
      Discount_Percent2        := NULL;
      Discount_Days2           := NULL;
      Discount_Date2           := NULL;
      Discount_Day_Of_Month2   := NULL;
      Discount_Months_Forward2 := NULL;
      Discount_Percent3        := NULL;
      Discount_Days3           := NULL;
      Discount_Date3           := NULL;
      Discount_Day_Of_Month3   := NULL;
      Discount_Months_Forward3 := NULL;

    ELSE
      xProgress := '2010-50';
      OPEN discount;

      LOOP
        xProgress := '2020-50';
        FETCH discount
         INTO l_Discount_Percent,
              l_Discount_Days,
              l_Discount_Date,
              l_Discount_Day_Of_Month,
              l_Discount_Months_Forward;

        EXIT WHEN discount%NOTFOUND;

        ec_debug.pl ( 3, 'l_Discount_Percent: ',l_Discount_Percent );
        ec_debug.pl ( 3, 'l_Discount_Days: ',l_Discount_Days );
        ec_debug.pl ( 3, 'l_Discount_Date: ',l_Discount_Date );
        ec_debug.pl ( 3, 'l_Discount_Day_Of_Month: ',l_Discount_Day_Of_Month );
        ec_debug.pl ( 3, 'l_Discount_Months_Forward: ',l_Discount_Months_Forward );

        xProgress                  := '2030-50';
        IF l_counter = 1 THEN
          Discount_Percent1        := l_Discount_Percent;
          Discount_Days1           := l_Discount_Days;
          Discount_Date1           := l_Discount_Date;
          Discount_Day_Of_Month1   := l_Discount_Day_Of_Month;
          Discount_Months_Forward1 := l_Discount_Months_Forward;

          ec_debug.pl (3, 'Discount_Percent1: ',Discount_Percent1 );
          ec_debug.pl (3, 'Discount_Days1: ',Discount_Days1 );
          ec_debug.pl (3, 'Discount_Date1: ',Discount_Date1 );
          ec_debug.pl (3, 'Discount_Day_Of_Month1: ',Discount_Day_Of_Month1 );
          ec_debug.pl (3, 'Discount_Months_Forward1: ',Discount_Months_Forward1 );
        END IF;

        xProgress                  := '2040-50';
        IF l_counter = 2 THEN
          Discount_Percent2        := l_Discount_Percent;
          Discount_Days2           := l_Discount_Days;
          Discount_Date2           := l_Discount_Date;
          Discount_Day_Of_Month2   := l_Discount_Day_Of_Month;
          Discount_Months_Forward2 := l_Discount_Months_Forward;

          ec_debug.pl (3, 'Discount_Percent2: ',Discount_Percent2 );
          ec_debug.pl (3, 'Discount_Days2: ',Discount_Days2 );
          ec_debug.pl (3, 'Discount_Date2: ',Discount_Date2 );
          ec_debug.pl (3, 'Discount_Day_Of_Month2: ',Discount_Day_Of_Month2 );
          ec_debug.pl (3, 'Discount_Months_Forward2: ',Discount_Months_Forward2 );
        END IF;

        xProgress                  := '2050-50';
        IF l_counter = 3 THEN
          Discount_Percent3        := l_Discount_Percent;
          Discount_Days3           := l_Discount_Days;
          Discount_Date3           := l_Discount_Date;
          Discount_Day_Of_Month3   := l_Discount_Day_Of_Month;
          Discount_Months_Forward3 := l_Discount_Months_Forward;

          ec_debug.pl (3, 'Discount_Percent3: ',Discount_Percent3 );
          ec_debug.pl (3, 'Discount_Days3: ',Discount_Days3 );
          ec_debug.pl (3, 'Discount_Date3: ',Discount_Date3 );
          ec_debug.pl (3, 'Discount_Day_Of_Month3: ',Discount_Day_Of_Month3 );
          ec_debug.pl (3, 'Discount_Months_Forward3: ',Discount_Months_Forward3 );
        END IF;

        l_counter := l_counter + 1;

      END LOOP;

      xProgress := '2060-50';
      IF ( dbms_sql.last_row_count = 0 )
      THEN
        ec_debug.pl (1,
                     'EC',
                     'ECE_NO_ROW_SELECTED',
                     'PROGRESS_LEVEL',
                     xProgress,
                     'INFO',
                     'DISCOUNT',
                     'TABLE_NAME',
                     'RA_TERMS_LINES_DISCOUNTS' );
      END IF;

    END IF;

    ec_debug.pop ( 'ece_ar_transaction.Get_Term_Discount' );

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

  END Get_Term_Discount;

  -- The following function gets the currency code

function get_currency_code
return varchar2
IS
Begin
ec_debug.push('ECE_AR_TRANSACTION.GET_CURRENCY_CODE');
  If  base_currency_code is  null Then
     select GLB.CURRENCY_CODE Base_Currency_Code
     into   base_currency_code
     from   AR_SYSTEM_PARAMETERS ASP, GL_SETS_OF_BOOKS GLB
     where  ASP.SET_OF_BOOKS_ID = GLB.SET_OF_BOOKS_ID ;
 End If;
 ec_debug.pop('ECE_AR_TRANSACTION.GET_CURRENCY_CODE');
 return base_currency_code;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
                                        'ECE_AR_TRANSACTION.GET_CURRENCY_CODE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_debug.pop('ECE_AR_TRANSACTION.GET_CURRENCY_CODE');
        return base_currency_code;
End;

  --  PROCEDURE Put_Data_To_Output_Table
  --  This procedure has the following functionalities:
  --  1. Build SQL statement dynamically to extract data from
  --     Interface Tables.
  --  2. Execute the dynamic SQL statement.
  --  3. Populate the ECE_OUTPUT table with the extracted data.
  --  4. Delete data from Interface Tables.
  -- --------------------------------------------------------------------------

  PROCEDURE Put_Data_To_Output_Table ( cCommunication_Method IN VARCHAR2,
                                       cTransaction_Type     IN VARCHAR2,
                                       iOutput_width         IN INTEGER,
                                       iRun_id               IN INTEGER,
                                       cHeader_Interface     IN VARCHAR2,
                                       cHeader_1_Interface   IN VARCHAR2,
                                       cAlw_chg_Interface    IN VARCHAR2,
                                       cLine_Interface       IN VARCHAR2,
                                       cLine_t_Interface     IN VARCHAR2 )
  IS

    /**
    This should be a parameter in the next version to distinguish between MAPS.
    For now, it will be hardcoded to NULL so the default will be the seeded FF transaction
    **/
    cMap_id       NUMBER := NULL;

    l_Header_tbl               ece_flatfile_pvt.Interface_tbl_type;
    l_Header_1_tbl             ece_flatfile_pvt.Interface_tbl_type;
    l_alw_chg_h_tbl            ece_flatfile_pvt.Interface_tbl_type;
    l_Line_tbl                 ece_flatfile_pvt.Interface_tbl_type;
    l_Line_t_tbl               ece_flatfile_pvt.Interface_tbl_type;
    l_alw_chg_l_tbl            ece_flatfile_pvt.Interface_tbl_type;

    c_Header_common_key_name   VARCHAR2(40);
    c_Header_1_common_key_name VARCHAR2(40);
    c_Alw_chg_common_key_name  VARCHAR2(40);
    c_Line_common_key_name     VARCHAR2(40);
    c_Line_t_common_key_name   VARCHAR2(40);
    c_file_common_key          VARCHAR2(255);

    nHeader_key_pos            NUMBER;
    nHeader_1_key_pos          NUMBER;
    nAlw_chg_key_pos           NUMBER;
    nLine_key_pos              NUMBER;
    nLine_t_key_pos            NUMBER;
    nTrans_code_pos            NUMBER;

    Header_sel_c               INTEGER;
    Header_1_sel_c             INTEGER;
    Alw_chg_h_sel_c            INTEGER;
    Alw_chg_l_sel_c            INTEGER;
    Line_sel_c                 INTEGER;
    Line_t_sel_c               INTEGER;

    Header_del_c1              INTEGER;
    Header_1_del_c1            INTEGER;
    Alw_chg_h_del_c1           INTEGER;
    Alw_chg_l_del_c1           INTEGER;
    Line_del_c1                INTEGER;
    Line_t_del_c1              INTEGER;

    Header_del_c2              INTEGER;
    Header_1_del_c2            INTEGER;
    Alw_chg_h_del_c2           INTEGER;
    Alw_chg_l_del_c2           INTEGER;
    Line_del_c2                INTEGER;
    Line_t_del_c2              INTEGER;

    cHeader_select             VARCHAR2(32000);
    cHeader_1_select           VARCHAR2(32000);
    cAlw_chg_h_select          VARCHAR2(32000);
    cAlw_chg_l_select          VARCHAR2(32000);
    cLine_select               VARCHAR2(32000);
    cLine_t_select             VARCHAR2(32000);

    cHeader_from               VARCHAR2(32000);
    cHeader_1_from             VARCHAR2(32000);
    cAlw_chg_h_from            VARCHAR2(32000);
    cAlw_chg_l_from            VARCHAR2(32000);
    cLine_from                 VARCHAR2(32000);
    cLine_t_from               VARCHAR2(32000);

    cHeader_where              VARCHAR2(32000);
    cHeader_1_where            VARCHAR2(32000);
    cAlw_chg_h_where           VARCHAR2(32000);
    cAlw_chg_l_where           VARCHAR2(32000);
    cLine_where                VARCHAR2(32000);
    cLine_t_where              VARCHAR2(32000);

    cAlw_chg_h_output_level    VARCHAR2(30);
    cAlw_chg_l_output_level    VARCHAR2(30);

    cHeader_delete1            VARCHAR2(32000);
    cHeader_1_delete1          VARCHAR2(32000);
    cAlw_chg_h_delete1         VARCHAR2(32000);
    cAlw_chg_l_delete1         VARCHAR2(32000);
    cLine_delete1              VARCHAR2(32000);
    cLine_t_delete1            VARCHAR2(32000);

    cHeader_delete2            VARCHAR2(32000);
    cHeader_1_delete2          VARCHAR2(32000);
    cAlw_chg_h_delete2         VARCHAR2(32000);
    cAlw_chg_l_delete2         VARCHAR2(32000);
    cLine_delete2              VARCHAR2(32000);
    cLine_t_delete2            VARCHAR2(32000);

    iHeader_count              NUMBER;
    iHeader_1_count            NUMBER;
    iAlw_chg_h_count           INTEGER;
    iAlw_chg_l_count           INTEGER;
    iLine_count                NUMBER;
    iLine_t_count              NUMBER;

    rHeader_rowid              ROWID;
    rHeader_1_rowid            ROWID;
    rAlw_chg_h_rowid           ROWID;
    rAlw_chg_l_rowid           ROWID;
    rLine_rowid                ROWID;
    rLine_t_rowid              ROWID;

    cHeader_X_Interface        VARCHAR2(50);
    cHeader_1_X_Interface      VARCHAR2(50);
    cAlw_chg_X_Interface       VARCHAR2(50);
    cLine_X_Interface          VARCHAR2(50);
    cLine_t_X_Interface        VARCHAR2(50);

    rHeader_X_rowid            ROWID;
    rHeader_1_X_rowid          ROWID;
    rAlw_chg_X_rowid           ROWID;
    rLine_X_rowid              ROWID;
    rLine_t_X_rowid            ROWID;

    dummy                      INTEGER;

    nPos1                      NUMBER;
    nTrans_id                  NUMBER;

    v_LevelProcessed           VARCHAR2(40);

  BEGIN

    ec_debug.push ( 'ece_ar_transaction.Put_Data_To_Output_Table' );
    ec_debug.pl ( 3, 'cCommunication_Method: ', cCommunication_Method );
    ec_debug.pl ( 3, 'cTransaction_Type: ',cTransaction_Type );
    ec_debug.pl ( 3, 'iOutput_width: ',iOutput_width );
    ec_debug.pl ( 3, 'iRun_id: ',iRun_id );
    ec_debug.pl ( 3, 'cHeader_1_Interface: ',cHeader_1_Interface );
    ec_debug.pl ( 3, 'cAlw_chg_Interface: ',cAlw_chg_Interface );
    ec_debug.pl ( 3, 'cLine_Interface: ',cLine_Interface );
    ec_debug.pl ( 3, 'cLine_t_Interface: ',cLine_t_Interface );

    -- **************************************************************************
    -- Here, I am building the SELECT, FROM, and WHERE  clauses for the dynamic
    -- SQL call
    -- The ece_flatfile.select_clause uses the db data dictionary for the build.
    -- (The db data dictionary store contains all types of info about Interface
    -- tables and Extension tables.)

    -- The DELETE clauses will be used to clean up both the interface and extension
    -- tables.  I am using ROWID to tell me which row in the interface table is
    -- being written to the output table, thus, can be deleted.
    -- **************************************************************************
    -- Here we have to find the output level of the interface tables for allowances
    -- and Charges.  The output level has to be passed on as an additional parameter
    -- here because the ECE_AR_TRX_ALLOWANCE_CHARGES is extracted twice into output
    -- table
    -- **************************************************************************

    xProgress := '2000-60';
    BEGIN
         SELECT MIN(eel.external_level)
         INTO cAlw_chg_h_output_level
         FROM ece_interface_tables eit,
           ece_level_matrices elm,
           ece_external_levels eel
   WHERE eit.interface_table_name = 'ECE_AR_TRX_ALLOWANCE_CHARGES'
   AND   eit.transaction_type = cTransaction_type
   AND   eit.interface_table_id = elm.interface_table_id
   AND   elm.external_level_id = eel.external_level_id
   AND   eel.map_id = (SELECT NVL(cMap_id, MAX(em1.map_id))
                         FROM ece_mappings em1
                         WHERE em1.map_code like 'EC_'||RTRIM(LTRIM(NVL(cTransaction_type,'%')))||'_FF');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'MINIMUM OUTPUT LEVEL',
                      'TABLE_NAME',
                      'ECE_INTERFACE_TABLES' );
     END;

     ec_debug.pl ( 3, 'cAlw_chg_h_output_level: ',cAlw_chg_h_output_level );

     xProgress := '2010-60';
     BEGIN
         SELECT MAX(eel.external_level)
        INTO cAlw_chg_l_output_level
         FROM ece_interface_tables eit,
           ece_level_matrices elm,
           ece_external_levels eel
   WHERE eit.interface_table_name = 'ECE_AR_TRX_ALLOWANCE_CHARGES'
   AND   eit.transaction_type = cTransaction_type
   AND   eit.interface_table_id = elm.interface_table_id
   AND   elm.external_level_id = eel.external_level_id
   AND   eel.map_id = (SELECT NVL(cMap_id, MAX(em1.map_id))
                         FROM ece_mappings em1
                         WHERE em1.map_code like 'EC_'||RTRIM(LTRIM(NVL(cTransaction_type,'%')))||'_FF');
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ec_debug.pl ( 1,
                      'EC',
                      'ECE_NO_ROW_SELECTED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'MAXIMUM OUTPUT LEVEL',
                      'TABLE_NAME',
                      'ECE_INTERFACE_TABLES' );
    END;

    ec_debug.pl ( 3, 'cAlw_chg_l_output_level: ',cAlw_chg_l_output_level );

    xProgress := '2020-60';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cHeader_Interface,
                                     cHeader_X_Interface,
                                     l_Header_tbl,
                                     c_Header_common_key_name,
                                     cHeader_select,
                                     cHeader_from,
                                     cHeader_where );

    xProgress := '2030-60';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cHeader_1_Interface,
                                     cHeader_1_X_Interface,
                                     l_Header_1_tbl,
                                     c_Header_1_common_key_name,
                                     cHeader_1_select,
                                     cHeader_1_from,
                                     cHeader_1_where );

    xProgress := '2040-60';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cAlw_chg_Interface,
                                     cAlw_chg_X_Interface,
                                     l_alw_chg_h_tbl,
                                     c_Alw_chg_common_key_name,
                                     cAlw_chg_h_select,
                                     cAlw_chg_h_from,
                                     cAlw_chg_h_where,
                                     cAlw_chg_h_output_level );

    xProgress := '2050-60';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cLine_Interface,
                                     cLine_X_Interface,
                                     l_Line_tbl,
                                     c_Line_common_key_name,
                                     cLine_select,
                                     cLine_from, cLine_where );

    xProgress := '2060-60';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cLine_t_Interface,
                                     cLine_t_X_Interface,
                                     l_Line_t_tbl,
                                     c_Line_t_common_key_name,
                                     cLine_t_select,
                                     cLine_t_from,
                                     cLine_t_where );

    xProgress := '2070-60';
    ece_flatfile_pvt.select_clause ( cTransaction_Type,
                                     cCommunication_Method,
                                     cAlw_chg_Interface,
                                     cAlw_chg_X_Interface,
                                     l_alw_chg_l_tbl,
                                     c_Alw_chg_common_key_name,
                                     cAlw_chg_l_select,
                                     cAlw_chg_l_from,
                                     cAlw_chg_l_where,
                                     cAlw_chg_l_output_level );

    -- **************************************************************************
    --  Here, I am customizing the WHERE clause to join the Interface tables together.
    --  i.e. Headers -- Lines -- Line Details
    --
    --  Select  Data1, Data2, Data3...........
    --  From    Header_Interface   A, Line_Interface   B, Line_details_Interface   C,
    --      Header_Interface_X D, Line_Interface_X E, Line_details_Interface_X F
    --  Where   A.Transaction_Record_ID = D.Transaction_Record_ID (+)
    --  and B.Transaction_Record_ID = E.Transaction_Record_ID (+)
    --  and C.Transaction_Record_ID = F.Transaction_Record_ID (+)
    -- $$$$$ (Customization should be added here) $$$$$$
    --  and A.Communication_Method = 'EDI'
    --  and A.xxx = B.xxx   ........
    --  and B.yyy = C.yyy   .......
    -- **************************************************************************


    /* --------------------------------------------------------------------------
      :transaction_id is a place holder for foreign key value.
      A PL/SQL table (list of values) will be used to store data.
      Procedure ece_flatfile.Find_pos will be used to locate the specific
      data value in the PL/SQL table.
      dbms_sql (Native Oracle db functions that come with every Oracle Apps)
      dbms_sql.bind_variable will be used to assign data value to :transaction_id.

      Let's use the above example:

      1. Execute dynamic SQL 1 for headers (A) data
          Get value of A.xxx (foreign key to B)

      2. bind value A.xxx to variable B.xxx

      3. Execute dynamic SQL 2 for lines (B) data
          Get value of B.yyy (foreigh key to C)

      4. bind value B.yyy to variable C.yyy

      5. Execute dynamic SQL 3 for line_details (C) data
       ----------------------------------------------------------------------------
    */

    xProgress          := '2080-60';
    cHeader_where      := cHeader_where                                ||
                          ' AND '                                      ||
                          cHeader_Interface                            ||
                          '.RUN_ID ='                                  ||
                          ':b1' ;
    ec_debug.pl ( 3, 'cHeader_where: ',cHeader_where );

    xProgress          := '2090-60';
    cHeader_1_where    := cHeader_1_where                              ||
                          ' AND '                                      ||
                          cHeader_1_Interface                          ||
                          '.RUN_ID ='                                  ||
                          ':b2'                                        ||
                          ' AND '                                      ||
                          cHeader_1_Interface                          ||
                          '.TRANSACTION_ID = :transaction_id';
    ec_debug.pl ( 3, 'cHeader_1_where: ',cHeader_1_where );

    xProgress          := '2100-60';
    cAlw_chg_h_where   := cAlw_chg_h_where                             ||
                          ' AND '                                      ||
                          cAlw_chg_Interface                           ||
                          '.RUN_ID ='                                  ||
                          ':b3'                                        ||
                          ' AND '                                      ||
                          cAlw_chg_Interface                           ||
                          '.TRANSACTION_ID = :transaction_id'          ||
                          ' AND '                                      ||
                          cAlw_chg_Interface                           ||
                          '.HEADER_DETAIL_INDICATOR = ''H''';
    ec_debug.pl ( 3, 'cAlw_chg_h_where: ',cAlw_chg_h_where );

    xProgress          := '2110-60';
    cLine_where        := cLine_where                                  ||
                          ' AND '                                      ||
                          cLine_Interface                              ||
                          '.RUN_ID ='                                  ||
                          ':b4'                                        ||
                          ' AND '                                      ||
                          cLine_Interface                              ||
                          '.TRANSACTION_ID = :transaction_id'          ||
                          ' ORDER BY '                                 ||
                          cLine_Interface                              ||
                          '.LINE_NUMBER';
    ec_debug.pl ( 3, 'cLine_where: ',cLine_where );

    xProgress          := '2120-60';
    cLine_t_where      := cLine_t_where                                ||
                          ' AND '                                      ||
                          cLine_t_Interface                            ||
                          '.RUN_ID ='                                  ||
                          ':b5'                                        ||
                          ' AND '                                      ||
                          cLine_t_Interface                            ||
                          '.TRANSACTION_ID = :transaction_id'          ||
                          ' AND '                                      ||
                          cLine_t_Interface                            ||
                          '.LINE_NUMBER = :line_number';
    ec_debug.pl ( 3, 'cLine_t_where: ',cLine_t_where );

    xProgress          := '2130-60';
    cAlw_chg_l_where   := cAlw_chg_l_where                             ||
                          ' AND '                                      ||
                          cAlw_chg_Interface                           ||
                          '.RUN_ID ='                                  ||
                          ':b6'                                        ||
                          ' AND '                                      ||
                          cAlw_chg_Interface                           ||
                          '.TRANSACTION_ID = :transaction_id'          ||
                          ' AND '                                      ||
                          cAlw_chg_Interface                           ||
                          '.HEADER_DETAIL_INDICATOR = ''D'''           ||
                          ' AND '                                      ||
                          cAlw_chg_Interface                           ||
                          '.LINE_NUMBER = :line_number';
    ec_debug.pl ( 3, 'cAlw_chg_l_where: ',cAlw_chg_l_where );

    xProgress          := '2140-60';
    cHeader_select     := cHeader_select                               ||
                          ','                                          ||
                          cHeader_Interface                            ||
                          '.ROWID, '                                   ||
                          cHeader_X_Interface                          ||
                          '.ROWID, '                                   ||
                          cHeader_Interface                            ||
                          '.TRANSACTION_ID';
    ec_debug.pl ( 3, 'cHeader_select: ',cHeader_select );

    xProgress          := '2150-60';
    cHeader_1_select   := cHeader_1_select                             ||
                          ','                                          ||
                          cHeader_1_Interface                          ||
                          '.ROWID, '                                   ||
                          cHeader_1_X_Interface                        ||
                          '.ROWID, '                                   ||
                          cHeader_1_Interface                          ||
                          '.TRANSACTION_ID';
    ec_debug.pl ( 3, 'cHeader_1_select: ',cHeader_1_select );

    xProgress          := '2160-60';
    cAlw_chg_h_select  := cAlw_chg_h_select                            ||
                          ','                                          ||
                          cAlw_chg_Interface                           ||
                          '.ROWID, '                                   ||
                          cAlw_chg_X_Interface                         ||
                          '.ROWID';
    ec_debug.pl ( 3, 'cAlw_chg_h_select: ',cAlw_chg_h_select );

    xProgress          := '2170-60';
    cLine_select       := cLine_select                                 ||
                          ','                                          ||
                          cLine_Interface                              ||
                          '.ROWID,'                                    ||
                          cLine_X_Interface                            ||
                          '.ROWID';
    ec_debug.pl ( 3, 'cLine_select: ',cLine_select );

    xProgress          := '2170-60';
    cLine_t_select     := cLine_t_select                               ||
                          ','                                          ||
                          cLine_t_Interface                            ||
                          '.ROWID,'                                    ||
                          cLine_t_X_Interface                          ||
                          '.ROWID';
    ec_debug.pl ( 3, 'cLine_t_select: ',cLine_t_select );

    xProgress          := '2180-60';
    cAlw_chg_l_select  := cAlw_chg_l_select                            ||
                          ','                                          ||
                          cAlw_chg_Interface                           ||
                          '.ROWID, '                                   ||
                          cAlw_chg_X_Interface                         ||
                          '.ROWID';
    ec_debug.pl ( 3, 'cAlw_chg_l_select: ',cAlw_chg_l_select );


    xProgress          := '2190-60';
    cHeader_select     := cHeader_select                               ||
                          cHeader_from                                 ||
                          cHeader_where                                ||
                          ' ORDER BY ' || cHeader_Interface || '.BILL_TO_CUSTOMER_NAME,' ||  /*Bug 2464584*/
                          cHeader_Interface || '.BILL_TO_CUSTOMER_LOCATION ' ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'cHeader_select: ',cHeader_select );

    cHeader_1_select   := cHeader_1_select                             ||
                          cHeader_1_from                               ||
                          cHeader_1_where                              ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'cHeader_1_select: ',cHeader_1_select );

    cAlw_chg_h_select  := cAlw_chg_h_select                            ||
                          cAlw_chg_h_from                              ||
                          cAlw_chg_h_where                             ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'cAlw_chg_h_select: ',cAlw_chg_h_select );

    cLine_select       := cLine_select                                 ||
                          cLine_from                                   ||
                          cLine_where                                  ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'cLine_select: ',cLine_select );

    cLine_t_select     := cLine_t_select                               ||
                          cLine_t_from                                 ||
                          cLine_t_where                                ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'cLine_t_select: ',cLine_t_select );

    cAlw_chg_l_select  := cAlw_chg_l_select                            ||
                          cAlw_chg_l_from                              ||
                          cAlw_chg_l_where                             ||
                          ' FOR UPDATE';
    ec_debug.pl ( 3, 'cAlw_chg_l_select: ',cAlw_chg_l_select );

    xProgress          := '2200-60';
    cHeader_delete1    := 'DELETE FROM '                               ||
                          cHeader_Interface                            ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cHeader_delete1: ',cHeader_delete1 );

    xProgress          := '2201-60';
    cHeader_1_delete1  := 'DELETE FROM '                               ||
                          cHeader_1_Interface                          ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cHeader_1_delete1: ',cHeader_1_delete1 );

    xProgress          := '2202-60';
    cAlw_chg_h_delete1 := 'DELETE FROM '                               ||
                          cAlw_chg_Interface                           ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cAlw_chg_h_delete1: ',cAlw_chg_h_delete1 );

    xProgress          := '2203-60';
    cLine_delete1      := 'DELETE FROM '                               ||
                          cLine_Interface                              ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cLine_delete1: ',cLine_delete1 );

    xProgress          := '2204-60';
    cLine_t_delete1    := 'DELETE FROM '                               ||
                          cLine_t_Interface                            ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cLine_t_delete1: ',cLine_t_delete1 );

    xProgress          := '2205-60';
    cAlw_chg_l_delete1 := 'DELETE FROM '                               ||
                          cAlw_chg_Interface                           ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cAlw_chg_l_delete1: ',cAlw_chg_l_delete1 );

    xProgress          := '2206-60';
    cHeader_delete2    := 'DELETE FROM '                               ||
                          cHeader_X_Interface                          ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cHeader_delete2: ',cHeader_delete2 );

    xProgress          := '2207-60';
    cHeader_1_delete2  := 'DELETE FROM '                               ||
                          cHeader_1_X_Interface                        ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cHeader_1_delete2: ',cHeader_1_delete2 );

    xProgress          := '2208-60';
    cAlw_chg_h_delete2 := 'DELETE FROM '                               ||
                          cAlw_chg_X_Interface                         ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cAlw_chg_h_delete2: ',cAlw_chg_h_delete2 );

    xProgress          := '2209-60';
    cLine_delete2      := 'DELETE FROM '                               ||
                          cLine_X_Interface                            ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cLine_delete2: ',cLine_delete2 );

    xProgress          := '2210-60';
    cLine_t_delete2    := 'DELETE FROM '                               ||
                          cLine_t_X_Interface                          ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cLine_t_delete2: ',cLine_t_delete2 );

    xProgress          := '2211-60';
    cAlw_chg_l_delete2 := 'DELETE FROM '                               ||
                          cAlw_chg_X_Interface                         ||
                          ' WHERE ROWID = :col_rowid';
    ec_debug.pl ( 3, 'cAlw_chg_l_delete2: ',cAlw_chg_l_delete2 );

    /***
     ***  Get data setup for the dynamic SQL call.
     ***
     ***  Open a cursor for each of the SELECT call
     ***/

    xProgress        := '2212-60';
    Header_sel_c     := dbms_sql.open_cursor;

    xProgress        := '2213-60';
    Header_1_sel_c   := dbms_sql.open_cursor;

    xProgress        := '2214-60';
    Alw_chg_h_sel_c  := dbms_sql.open_cursor;

    xProgress        := '2215-60';
    Line_sel_c       := dbms_sql.open_cursor;

    xProgress        := '2216-60';
    Line_t_sel_c     := dbms_sql.open_cursor;

    xProgress        := '2217-60';
    Alw_chg_l_sel_c  := dbms_sql.open_cursor;

    xProgress        := '2218-60';
    Header_del_c1    := dbms_sql.open_cursor;

    xProgress        := '2219-60';
    Header_1_del_c1  := dbms_sql.open_cursor;

    xProgress        := '2220-60';
    Alw_chg_h_del_c1 := dbms_sql.open_cursor;

    xProgress        := '2221-60';
    Line_del_c1      := dbms_sql.open_cursor;

    xProgress        := '2222-60';
    Line_t_del_c1    := dbms_sql.open_cursor;

    xProgress        := '2223-60';
    Alw_chg_l_del_c1 := dbms_sql.open_cursor;

    xProgress        := '2224-60';
    Header_del_c2    := dbms_sql.open_cursor;

    xProgress        := '2225-60';
    Header_1_del_c2  := dbms_sql.open_cursor;

    xProgress        := '2226-60';
    Alw_chg_h_del_c2 := dbms_sql.open_cursor;

    xProgress        := '2227-60';
    Line_del_c2      := dbms_sql.open_cursor;

    xProgress        := '2228-60';
    Line_t_del_c2    := dbms_sql.open_cursor;

    xProgress        := '2229-60';
    Alw_chg_l_del_c2 := dbms_sql.open_cursor;

    /***
     ***  Parse each of the SELECT and DELETE statement
     ***/

    xProgress := '2230-60';
    BEGIN
      dbms_sql.parse ( Header_sel_c,
                       cHeader_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_select);
        app_exception.raise_exception;
    END;

    xProgress := '2231-60';
    BEGIN
      dbms_sql.parse ( Header_1_sel_c,
                       cHeader_1_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_1_select);
        app_exception.raise_exception;
    END;

    xProgress := '2232-60';
    BEGIN
      dbms_sql.parse ( Alw_chg_h_sel_c,
                       cAlw_chg_h_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cAlw_chg_h_select );
        app_exception.raise_exception;
    END;

    xProgress := '2233-60';
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

    xProgress := '2234-60';
    BEGIN
      dbms_sql.parse ( Line_t_sel_c,
                       cLine_t_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_t_select );
        app_exception.raise_exception;
    END;

    xProgress := '2235-60';
    BEGIN
      dbms_sql.parse ( Alw_chg_l_sel_c,
                       cAlw_chg_l_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cAlw_chg_l_select );
        app_exception.raise_exception;
    END;

       xProgress := '2236-60';
    BEGIN
      dbms_sql.parse ( Header_del_c1,
                       cHeader_delete1,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_delete1 );
        app_exception.raise_exception;
    END;

    xProgress := '2237-60';
    BEGIN
      dbms_sql.parse ( Header_1_del_c1,
                       cHeader_1_delete1,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_1_delete1 );
        app_exception.raise_exception;
    END;

    xProgress := '2238-60';
    BEGIN
      dbms_sql.parse ( Alw_chg_h_del_c1,
                       cAlw_chg_h_delete1,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cAlw_chg_h_delete1 );
        app_exception.raise_exception;
    END;

    xProgress := '2239-60';
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

    xProgress := '2240-60';
    BEGIN
      dbms_sql.parse ( Line_t_del_c1,
                       cLine_t_delete1,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_t_delete1 );
        app_exception.raise_exception;
    END;

    xProgress := '2241-60';
    BEGIN
      dbms_sql.parse ( Alw_chg_l_del_c1,
                       cAlw_chg_l_delete1,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cAlw_chg_l_delete1 );
        app_exception.raise_exception;
    END;

       xProgress := '2242-60';
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

    xProgress := '2243-60';
    BEGIN
      dbms_sql.parse ( Header_1_del_c2,
                       cHeader_1_delete2,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_1_delete2 );
        app_exception.raise_exception;
    END;

    xProgress := '2244-60';
    BEGIN
      dbms_sql.parse ( Alw_chg_h_del_c2,
                       cAlw_chg_h_delete2,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cAlw_chg_h_delete2 );
        app_exception.raise_exception;
    END;

    xProgress := '2245-60';
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

    xProgress := '2246-60';
    BEGIN
      dbms_sql.parse ( Line_t_del_c2,
                       cLine_t_delete2,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_t_delete2 );
        app_exception.raise_exception;
    END;

    xProgress := '2247-60';
    BEGIN
      dbms_sql.parse ( Alw_chg_l_del_c2,
                       cAlw_chg_l_delete2,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cAlw_chg_l_delete2 );
        app_exception.raise_exception;
    END;

    -- *************************************************
    -- set counter
    -- *************************************************


    xProgress        := '2250-60';
    iHeader_count    := l_Header_tbl.count;
    ec_debug.pl ( 3, 'iHeader_count: ',iHeader_count );

    xProgress        := '2252-60';
    iHeader_1_count  := l_Header_1_tbl.count;
    ec_debug.pl ( 3, 'iHeader_1_count: ',iHeader_1_count );

    xProgress        := '2254-60';
    iAlw_chg_h_count := l_alw_chg_h_tbl.count;
    ec_debug.pl ( 3, 'iAlw_chg_h_count: ',iAlw_chg_h_count );

    xProgress        := '2256-60';
    iLine_count      := l_Line_tbl.count;
    ec_debug.pl ( 3, 'iLine_count: ',iLine_count );

    xProgress        := '2258-60';
    iLine_t_count    := l_Line_t_tbl.count;
    ec_debug.pl ( 3, 'iLine_t_count: ',iLine_t_count );

    xProgress        := '2260-60';
    iAlw_chg_l_count := l_alw_chg_l_tbl.count;
    ec_debug.pl ( 3, 'iAlw_chg_l_count: ',iAlw_chg_l_count );

    /***
     *** Define TYPE for every columns in the SELECT statement
     ***/


    xProgress := '2270-60';
    FOR k IN 1..iHeader_count
    LOOP
      dbms_sql.define_column ( Header_sel_c,
                               k,
                               cHeader_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    /***
     *** Need rowid for delete (Header Level)
     ***/

    xProgress := '2280-60';
    dbms_sql.define_column_rowid ( Header_sel_c,
                                   iHeader_count + 1,
                                   rHeader_rowid );

    xProgress := '2282-60';
    dbms_sql.define_column_rowid ( Header_sel_c,
                                   iHeader_count + 2,
                                   rHeader_X_rowid );

    xProgress := '2284-60';
    dbms_sql.define_column ( Header_sel_c,
                             iHeader_count + 3,
                             nTrans_id );


    xProgress := '2290-60';
    FOR k IN 1..iHeader_1_count
    LOOP
      dbms_sql.define_column ( Header_1_sel_c,
                               k,
                               cHeader_1_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    /***
     *** Need rowid for delete (Header 1 Level)
     ***/

    xProgress := '2292-60';
    dbms_sql.define_column_rowid ( Header_1_sel_c,
                                   iHeader_1_count + 1,
                                   rHeader_1_rowid );

    xProgress := '2294-60';
    dbms_sql.define_column_rowid ( Header_1_sel_c,
                                   iHeader_1_count + 2,
                                   rHeader_1_X_rowid );

    xProgress := '2300-60';
    FOR k IN 1..iAlw_chg_h_count
    LOOP
      dbms_sql.define_column ( Alw_chg_h_sel_c,
                               k,
                               cAlw_chg_h_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    /***
     *** Need rowid for delete (Allowance Charges Header Level)
     ***/

    xProgress := '2310-60';
    dbms_sql.define_column_rowid ( Alw_chg_h_sel_c,
                                   iAlw_chg_h_count + 1,
                                   rAlw_chg_h_rowid );

    xProgress := '2312-60';
    dbms_sql.define_column_rowid ( Alw_chg_h_sel_c,
                                   iAlw_chg_h_count + 2,
                                   rAlw_chg_X_rowid );

    xProgress := '2320-60';
    FOR k IN 1..iLine_count
    LOOP
      dbms_sql.define_column ( Line_sel_c,
                               k,
                               cLine_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

     /***
      *** Need rowid for delete (Line Level)
      ***/

    xProgress := '2330-60';
    dbms_sql.define_column_rowid ( Line_sel_c,
                                   iLine_count + 1,
                                   rLine_rowid );

    xProgress := '2332-60';
    dbms_sql.define_column_rowid ( Line_sel_c,
                                   iLine_count + 2,
                                   rLine_X_rowid );

    xProgress := '2340-60';
    FOR k IN 1..iLine_t_count
    LOOP
      dbms_sql.define_column ( Line_t_sel_c,
                               k,
                               cLine_t_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    /***
     *** Need rowid for delete (Line Level)
     ***/

    xProgress := '2350-60';
    dbms_sql.define_column_rowid ( Line_t_sel_c,
                                   iLine_t_count + 1,
                                   rLine_t_rowid );

    xProgress := '2352-60';
    dbms_sql.define_column_rowid ( Line_t_sel_c,
                                   iLine_t_count + 2,
                                   rLine_t_X_rowid );

    xProgress := '2360-60';
    FOR k IN 1..iAlw_chg_l_count
    LOOP
      dbms_sql.define_column ( Alw_chg_l_sel_c,
                               k,
                               cAlw_chg_l_select,
                               ece_flatfile_pvt.G_MaxColWidth );
    END LOOP;

    /***
     *** Need rowid for delete (Allowance Charges Detail Level)
     ***/

    xProgress := '2370-60';
    dbms_sql.define_column_rowid ( Alw_chg_l_sel_c,
                                   iAlw_chg_l_count + 1,
                                   rAlw_chg_l_rowid );

    xProgress := '2372-60';
    dbms_sql.define_column_rowid ( Alw_chg_l_sel_c,
                                   iAlw_chg_l_count + 2,
                                   rAlw_chg_X_rowid );

    /**************************************************************
     ***  The following is custom tailored for this transaction
     ***  It find the values and use them in the WHERE clause to
     ***  join tables together.
     **************************************************************/

    /*** To complete the SELECT statement,
     *** we will need values for the join condition.
     ***/

    xProgress := '2380-60';
    ece_flatfile_pvt.Find_pos ( l_Line_tbl,
                                'LINE_NUMBER',
                                nPos1 );
    ec_debug.pl ( 3, 'nPos1: ',nPos1 );

    -- EXECUTE the SELECT statement

    dbms_sql.bind_variable ( Header_sel_c, 'b1', iRun_id );

    xProgress := '2390-60';
    dummy := dbms_sql.execute ( Header_sel_c );

    /*** --------------------------------------------------------------
     ***  With data for each HEADER line, populate the ECE_OUTPUT table
     ***  then populate ECE_OUTPUT with data from all HEADER 1 that belongs
     ***  to the HEADER and Allowances and Charges that belong to the header
     ***  Then populate ECE_OUTPUT with data from all
     ***  LINES that belongs to the HEADER and then populate ECE_OUTPUT with
     ***  data from all LINE TAX, Allowances and Charges that belong to the line
     ***  ------------------------------------------------------------***/

    --  HEADER - HEADER 1 - HEADER ALLOWANCES and CHARGES - LINE - LINE ALLOWANCES and CHARGES
    --      - LINE TAX ...

    xProgress := '2400-60';
    WHILE dbms_sql.fetch_rows ( Header_sel_c ) > 0
    LOOP           -- Header

      /***
       *** store values in pl/sql table
       ***/

      xProgress := '2410-60';
      FOR i IN 1..iHeader_count
      LOOP
        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_Header_tbl(i).value );
      END LOOP;

      xProgress := '2420-60';
      dbms_sql.column_value ( Header_sel_c,
                              iHeader_count + 1,
                              rHeader_rowid );

      xProgress := '2422-60';
      dbms_sql.column_value ( Header_sel_c,
                              iHeader_count + 2,
                              rHeader_X_rowid );

      xProgress := '2424-60';
      dbms_sql.column_value (Header_sel_c,
                             iHeader_count + 3,
                             nTrans_id );

      xProgress := '2430-60';
      ece_flatfile_pvt.Find_pos ( l_Header_tbl,
                                  ece_flatfile_pvt.G_Translator_Code,
                                  nTrans_code_pos );
      ec_debug.pl ( 3, 'nTrans_code_pos: ',nTrans_code_pos );

      xProgress := '2432-60';
      ece_flatfile_pvt.Find_pos ( l_Header_tbl,
                                  c_header_common_key_name,
                                  nHeader_key_pos );
      ec_debug.pl ( 3, 'nHeader_key_pos: ',nHeader_key_pos );

      xProgress         := '2440-60';
      c_file_common_key := RPAD(SUBSTRB(NVL(l_Header_tbl(nTrans_code_pos).value,' '),
                                       1, 25),
                                25);
      ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

      xProgress         := '2442-60';
      c_file_common_key := c_file_common_key                                         ||
                           RPAD(SUBSTRB(NVL(l_Header_tbl(nHeader_key_pos).value,' '),
                                       1, 22),
                                22)                                                  ||
                           RPAD(' ',22)                                              ||
                           RPAD(' ',22);
      ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );


      xProgress := '2450-60';
      ece_flatfile_pvt.write_to_ece_output ( cTransaction_Type,
                                             cCommunication_Method,
                                             cHeader_Interface,
                                             l_Header_tbl,
                                             iOutput_width,
                                             iRun_id,
                                             c_file_common_key );

      /*** --------------------------------------------------------------
       ***   With Header data at hand, we can assign values to
       ***   place holders (foreign keys) in Header_detail_Select,
       ***   Line_select and Line_detail_Select
       *** ------------------------------------------------------------***/

       /***  -- set values into binding variables
        ***/
      xProgress := '2452-60';
      dbms_sql.bind_variable ( Header_1_sel_c, 'transaction_id', nTrans_id );

      dbms_sql.bind_variable ( Header_1_sel_c, 'b2', iRun_id );

      xProgress := '2454-60';
      dbms_sql.bind_variable ( Alw_chg_h_sel_c, 'transaction_id', nTrans_id );

      dbms_sql.bind_variable ( Alw_chg_h_sel_c, 'b3', iRun_id );

      xProgress := '2456-60';
      dbms_sql.bind_variable ( Line_sel_c, 'transaction_id', nTrans_id );

      dbms_sql.bind_variable ( Line_sel_c, 'b4', iRun_id );

      xProgress := '2458-60';
      dbms_sql.bind_variable ( Line_t_sel_c, 'transaction_id', nTrans_id );

      dbms_sql.bind_variable ( Line_t_sel_c, 'b5', iRun_id );

      xProgress := '2460-60';
      dbms_sql.bind_variable ( Alw_chg_l_sel_c, 'transaction_id', nTrans_id );

      dbms_sql.bind_variable ( Alw_chg_l_sel_c, 'b6', iRun_id );

      xProgress := '2470-60';
      dummy     := dbms_sql.execute ( Header_1_sel_c );

      /*****
       ***** -- header 1 loop starts here
       *****/

      xProgress := '2480-60';
      WHILE dbms_sql.fetch_rows ( Header_1_sel_c ) > 0
      LOOP        --- Header 1

        /*****
         *****   store values in pl/sql table
         *****/

        xProgress := '2490-60';
        FOR l IN 1..iHeader_1_count
        LOOP
          dbms_sql.column_value ( Header_1_sel_c,
                                  l,
                                  l_Header_1_tbl(l).value );
        END LOOP;

        xProgress := '2500-60';
        dbms_sql.column_value ( Header_1_sel_c,
                                iHeader_1_count + 1,
                                rHeader_1_rowid );

        xProgress := '2510-60';
        dbms_sql.column_value ( Header_1_sel_c,
                                iHeader_1_count + 2,
                                rHeader_1_X_rowid );

        xProgress := '2520-60';
        ece_flatfile_pvt.write_to_ece_output( cTransaction_Type,
                                              cCommunication_Method,
                                              cHeader_1_Interface,
                                              l_Header_1_tbl,
                                              iOutput_width,
                                              iRun_id,
                                              c_file_common_key );
	xProgress := '2530-60';
        dbms_sql.bind_variable ( Header_1_del_c1,
                                 'col_rowid',
                                 rHeader_1_rowid );

--        xProgress := '2532-60';
        dbms_sql.bind_variable ( Header_1_del_c2,
                                 'col_rowid',
                                 rHeader_1_X_rowid );

        xProgress := '2532-60';
        dummy     := dbms_sql.execute ( Header_1_del_c1 );

        xProgress := '2534-60';
        dummy     := dbms_sql.execute ( Header_1_del_c2 );

        /* Bug 1703536 - closed the end loop to end the header 1 loop */

      END LOOP;

      xProgress := '2536-60';
      IF ( dbms_sql.last_row_count = 0 ) THEN
        v_LevelProcessed := 'HEADER 1';
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


        xProgress := '2538-60';
        dummy     := dbms_sql.execute ( Alw_chg_h_sel_c );

        /*****
         ***** -- Allowances and Charges Header loop starts here
         *****/

        xProgress := '2540-60';
        WHILE dbms_sql.fetch_rows ( Alw_chg_h_sel_c ) > 0
        LOOP       --- Allowances and Charges Header

          /*****
           *****   store values in pl/sql table
           *****/

          xProgress := '2550-60';
          FOR m IN 1..iAlw_chg_h_count
          LOOP
            dbms_sql.column_value ( Alw_chg_h_sel_c,
                                    m,
                                    l_alw_chg_h_tbl(m).value );
          END LOOP;

          xProgress := '2560-60';
          dbms_sql.column_value ( Alw_chg_h_sel_c,
                                  iAlw_chg_h_count + 1,
                                  rAlw_chg_h_rowid );

          xProgress := '2562-60';
          dbms_sql.column_value ( Alw_chg_h_sel_c,
                                  iAlw_chg_h_count + 2,
                                  rAlw_chg_X_rowid );

          xProgress := '2570-60';
          ece_flatfile_pvt.write_to_ece_output ( cTransaction_Type,
                                                 cCommunication_Method,
                                                 cAlw_chg_Interface,
                                                 l_alw_chg_h_tbl,
                                                 iOutput_width,
                                                 iRun_id,
                                                 c_file_common_key );

          /*****
           ***** -- allowances and charges header loop ends here
           *****/

          /****
           ****   -- Use rowid for delete
           ****/

          xProgress := '2580-60';
          dbms_sql.bind_variable ( Alw_chg_h_del_c1,
                                   'col_rowid',
                                   rAlw_chg_h_rowid );

          xProgress := '2582-60';
          dbms_sql.bind_variable ( Alw_chg_h_del_c2,
                                   'col_rowid',
                                   rAlw_chg_X_rowid );

          xProgress := '2590-60';
          dummy := dbms_sql.execute ( Alw_chg_h_del_c1 );

          xProgress := '2592-60';
          dummy := dbms_sql.execute ( Alw_chg_h_del_c2 );

        END LOOP;

        xProgress := '2594-60';
        IF ( dbms_sql.last_row_count = 0 )
        THEN
          v_LevelProcessed := 'ALLOWANCE CHARGES HEADER';
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

        xProgress := '2600-60';
        dummy     := dbms_sql.execute ( Line_sel_c );

        /*****
         ***** -- line loop starts here
         *****/

        xProgress := '2610-60';
        WHILE dbms_sql.fetch_rows ( Line_sel_c ) > 0
        LOOP        --- Line

          /*****
           *****   store values in pl/sql table
           *****/

          xProgress := '2620-60';
          FOR j IN 1..iLine_count
          LOOP
            dbms_sql.column_value ( Line_sel_c,
                                    j,
                                    l_Line_tbl(j).value );
          END LOOP;

          xProgress := '2630-60';
          dbms_sql.column_value ( Line_sel_c,
                                  iLine_count + 1,
                                  rLine_rowid );

          xProgress := '2632-60';
          dbms_sql.column_value ( Line_sel_c,
                                  iLine_count + 2,
                                  rLine_X_rowid );

          xProgress := '2640-60';
          ece_flatfile_pvt.Find_pos ( l_Line_tbl,
                                      c_line_common_key_name,
                                      nLine_key_pos );
          ec_debug.pl ( 3, 'nLine_key_pos: ',nLine_key_pos );

          xProgress := '2650-60';
          c_file_common_key := RPAD(SUBSTRB(NVL(l_Header_tbl(nTrans_code_pos).value,' '),
                                           1, 25),
                                    25)                                                  ||
                               RPAD(SUBSTRB(NVL(l_Header_tbl(nHeader_key_pos).value,' '),
                                           1, 22),
                                    22)                                                  ||
                               RPAD(SUBSTRB(NVL(l_Line_tbl(nLine_key_pos).value,' '),
                                           1, 22),
                                    22)                                                  ||
                               RPAD(' ',22);
          ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

          xProgress := '2660-60';
          ece_flatfile_pvt.write_to_ece_output ( cTransaction_Type,
                                                 cCommunication_Method,
                                                 cLine_Interface,
                                                 l_Line_tbl,
                                                 iOutput_width,
                                                 iRun_id,
                                                 c_file_common_key );



          /*****
           *****   set LINE_NUMBER values
           *****/

          xProgress := '2670-60';
          dbms_sql.bind_variable ( Line_t_sel_c,
                                   'line_number',
                                   l_Line_tbl(nPos1).value );

          xProgress := '2672-60';
          dbms_sql.bind_variable ( Alw_chg_l_sel_c,
                                   'line_number',
                                   l_Line_tbl(nPos1).value );


          xProgress := '2680-60';
          dummy     := dbms_sql.execute ( Line_t_sel_c );

          /*****
           ***** -- line tax loop starts here
           *****/

          xProgress := '2690-60';
          WHILE dbms_sql.fetch_rows ( Line_t_sel_c ) > 0
          LOOP       --- Line Tax

            /*****
             *****   store values in pl/sql table
             *****/

            xProgress := '2700-60';
            FOR k IN 1..iLine_t_count LOOP
              dbms_sql.column_value ( Line_t_sel_c, k, l_Line_t_tbl(k).value );
            END LOOP;

            xProgress := '2710-60';
            dbms_sql.column_value ( Line_t_sel_c,
                                    iLine_t_count + 1,
                                    rLine_t_rowid );

            xProgress := '2712-60';
            dbms_sql.column_value ( Line_t_sel_c,
                                    iLine_t_count + 2,
                                    rLine_t_X_rowid );

            xProgress := '2720-60';
            ece_flatfile_pvt.Find_pos (l_Line_t_tbl,
                                       c_Line_t_common_key_name,
                                       nLine_t_key_pos );
            ec_debug.pl ( 3, 'nLine_t_key_pos: ',nLine_t_key_pos );

            xProgress         := '2730-60';
            c_file_common_key := RPAD(SUBSTRB(NVL(l_Header_tbl(nTrans_code_pos).value,' '),
                                             1, 25),
                                      25)                                                ||
                                 RPAD(SUBSTRB(NVL(l_Header_tbl(nHeader_key_pos).value,' '),
                                             1, 22),
                                      22)                                                ||
                                 RPAD(SUBSTRB(NVL(l_Line_tbl(nLine_key_pos).value,' '),
                                             1, 22),
                                      22)                                                ||
                                 RPAD(SUBSTRB(NVL(l_Line_t_tbl(nLine_t_key_pos).value,' '),
                                             1, 22),
                                      22);
            ec_debug.pl ( 3, 'c_file_common_key: ',c_file_common_key );

            xProgress := '2740-60';
            ece_flatfile_pvt.write_to_ece_output ( cTransaction_Type,
                                                   cCommunication_Method,
                                                   cLine_t_Interface,
                                                   l_Line_t_tbl,
                                                   iOutput_width,
                                                   iRun_id,
                                                   c_file_common_key );



            xProgress := '2750-60';
            dbms_sql.bind_variable ( Line_t_del_c1,
                                     'col_rowid',
                                     rLine_t_rowid );

            xProgress := '2752-60';
            dbms_sql.bind_variable ( Line_t_del_c2,
                                     'col_rowid',
                                     rLine_t_X_rowid );

            xProgress := '2760-60';
            dummy := dbms_sql.execute ( Line_t_del_c1 );

            xProgress := '2762-60';
            dummy := dbms_sql.execute ( Line_t_del_c2 );

          END LOOP;

          xProgress := '2764-60';
          IF ( dbms_sql.last_row_count = 0 )
          THEN
            v_LevelProcessed := 'LINE TAX';
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

          /****
           **** -- line tax loop ends here
           ****/

          xProgress := '2770-60';
          dummy     := dbms_sql.execute ( Alw_chg_l_sel_c );

          /*****
           ***** -- Allowances and Charges Line loop starts here
           *****/

          xProgress := '2780-60';
          WHILE dbms_sql.fetch_rows ( Alw_chg_l_sel_c ) > 0
          LOOP       --- Allowances and Charges Line

            /*****
             *****   store values in pl/sql table
             *****/

            xProgress := '2790-60';
            FOR n IN 1..iAlw_chg_l_count
            LOOP
              dbms_sql.column_value ( Alw_chg_l_sel_c,
                                      n,
                                      l_alw_chg_l_tbl(n).value );
            END LOOP;

            xProgress := '2800-60';
            dbms_sql.column_value ( Alw_chg_l_sel_c,
                                    iAlw_chg_l_count + 1,
                                    rAlw_chg_l_rowid );

            xProgress := '2810-60';
            dbms_sql.column_value ( Alw_chg_l_sel_c,
                                    iAlw_chg_l_count + 2,
                                    rAlw_chg_X_rowid );

            xProgress := '2820-60';
            ece_flatfile_pvt.write_to_ece_output ( cTransaction_Type,
                                                   cCommunication_Method,
                                                   cAlw_chg_Interface,
                                                   l_alw_chg_l_tbl,
                                                   iOutput_width,
                                                   iRun_id,
                                                   c_file_common_key );

            /*****
             ***** -- allowances and charges line loop ends here
             *****/

            /****
             ****   -- Use rowid for delete
             ****/

            xProgress := '2830-60';
            dbms_sql.bind_variable ( Alw_chg_l_del_c1,
                                     'col_rowid',
                                     rAlw_chg_l_rowid );

            xProgress := '2832-60';
            dbms_sql.bind_variable ( Alw_chg_l_del_c2,
                                     'col_rowid',
                                     rAlw_chg_X_rowid );

            xProgress := '2834-60';
            dummy     := dbms_sql.execute ( Alw_chg_l_del_c1 );

            xProgress := '2836-60';
            dummy     := dbms_sql.execute ( Alw_chg_l_del_c2 );

          END LOOP;

          xProgress := '2838-60';
          IF ( dbms_sql.last_row_count = 0 ) THEN
            v_LevelProcessed := 'ALLOWANCE CHARAGES LINE';
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

          /****
           ****   -- Use rowid for delete
           ****/

          xProgress := '2840-60';
          dbms_sql.bind_variable ( Line_del_c1,
                                   'col_rowid',
                                   rLine_rowid );

          xProgress := '2842-60';
          dbms_sql.bind_variable ( Line_del_c2,
                                   'col_rowid',
                                   rLine_X_rowid );

          xProgress := '2850-60';
          dummy := dbms_sql.execute ( Line_del_c1 );

          xProgress := '2852-60';
          dummy := dbms_sql.execute ( Line_del_c2 );

        END LOOP;

        xProgress := '2854-60';
        IF ( dbms_sql.last_row_count = 0 )
        THEN
          v_LevelProcessed := 'LINE';
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

        /***
         *** -- line loop ends here
         ***/
/* Bug 1703536 -
**     Commented the following code and moved it to the end of the
**     header 1 loop.
*/

/****
        xProgress := '2860-60';
        dbms_sql.bind_variable ( Header_1_del_c1,
                                 'col_rowid',
                                 rHeader_1_rowid );

        xProgress := '2862-60';
        dbms_sql.bind_variable ( Header_1_del_c2,
                                 'col_rowid',
                                 rHeader_1_X_rowid );

        xProgress := '2870-60';
        dummy     := dbms_sql.execute ( Header_1_del_c1 );

        xProgress := '2872-60';
        dummy     := dbms_sql.execute ( Header_1_del_c2 );

      END LOOP;

      xProgress := '2874-60';
      IF ( dbms_sql.last_row_count = 0 ) THEN
        v_LevelProcessed := 'HEADER 1';
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

****/
      /***
       *** -- header 1 loop ends here
       ***/

      xProgress := '2880-60';
      dbms_sql.bind_variable ( Header_del_c1,
                               'col_rowid',
                               rHeader_rowid );

      xProgress := '2882-60';
      dbms_sql.bind_variable ( Header_del_c2,
                               'col_rowid',
                               rHeader_X_rowid );

      xProgress := '2890-60';
      dummy := dbms_sql.execute ( Header_del_c1 );

      xProgress := '2892-60';
      dummy := dbms_sql.execute ( Header_del_c2 );

    END LOOP;

    xProgress := '2894-60';
    IF ( dbms_sql.last_row_count = 0 ) THEN
      v_LevelProcessed := 'HEADER';
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

    /***
     *** -- header loop ends here
     ***/

    /*** -- this commit is to make sure all data is deleted from interface tables
     ***/

    xProgress := '2900-60';
    --   COMMIT;

    /***
     *** -- close all open cursors here
     ***/
    xProgress := '2910-60';
    dbms_sql.close_cursor ( Header_sel_c );

    xProgress := '2911-60';
    dbms_sql.close_cursor ( Header_1_sel_c );

    xProgress := '2912-60';
    dbms_sql.close_cursor ( Alw_chg_h_sel_c );

    xProgress := '2913-60';
    dbms_sql.close_cursor ( Line_sel_c );

    xProgress := '2914-60';
    dbms_sql.close_cursor ( Line_t_sel_c );

    xProgress := '2915-60';
    dbms_sql.close_cursor ( Alw_chg_l_sel_c );

    xProgress := '2916-60';
    dbms_sql.close_cursor ( Header_del_c1 );

    xProgress := '2917-60';
    dbms_sql.close_cursor ( Header_1_del_c1 );

    xProgress := '2918-60';
    dbms_sql.close_cursor ( Alw_chg_h_del_c1 );

    xProgress := '2919-60';
    dbms_sql.close_cursor ( Line_del_c1 );

    xProgress := '2920-60';
    dbms_sql.close_cursor ( Line_t_del_c1 );

    xProgress := '2921-60';
    dbms_sql.close_cursor ( Alw_chg_l_del_c1 );

    ec_debug.pop('ece_ar_transaction.Put_Data_To_Output_Table');

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

  /* --------------------------------------------------------------------------*/

  --  PROCEDURE Populate_AR_Trx
  --  This procedure has the following functionalities:
  --  1. Build SQL statement dynamically to extract data from
  --      Base Application Tables.
  --  2. Execute the dynamic SQL statement.
  --  3. Assign data into 2-dim PL/SQL table
  --  4. Pass data to the code conversion mechanism
  --  5. Populate the Interface tables with the extracted data.
  -- --------------------------------------------------------------------------

  PROCEDURE Populate_AR_Trx ( cCommunication_Method IN VARCHAR2,
                              cTransaction_Type     IN VARCHAR2,
                              iOutput_width         IN INTEGER,
                              dTransaction_date     IN DATE,
                              iRun_id               IN INTEGER,
                              cHeader_Interface     IN VARCHAR2,
                              cHeader_1_Interface   IN VARCHAR2,
                              cAlw_Chg_Interface    IN VARCHAR2,
                              cLine_Interface       IN VARCHAR2,
                              cLine_t_Interface     IN VARCHAR2,
                              cCreate_Date_From     IN DATE,
                              cCreate_Date_To       IN DATE,
                              cCustomer_Name        IN VARCHAR2,
                              cSite_Use_Code        IN VARCHAR2,
                              cDocument_Type        IN VARCHAR2,
                              cTransaction_Number   IN VARCHAR2 )

  IS

    /**
    This should be a parameter in the next version to distinguish between MAPS.
    For now, it will be hardcoded to NULL so the default will be the seeded FF transaction
    **/
    cMap_id       NUMBER := NULL;

    l_header_tbl                 ece_flatfile_pvt.Interface_tbl_type;
    l_header_1_tbl               ece_flatfile_pvt.Interface_tbl_type;
    l_alw_chg_tbl                ece_flatfile_pvt.Interface_tbl_type;
    l_line_tbl                   ece_flatfile_pvt.Interface_tbl_type;
    l_line_t_tbl                 ece_flatfile_pvt.Interface_tbl_type;
    l_key_tbl                    ece_flatfile_pvt.Interface_tbl_type;
  --  l_veh_alw_chg_tbl            veh_allowance_charge_sv.tab_for_allowance_charge;

    Header_sel_c                 INTEGER;
    Header_1_sel_c               INTEGER;
    Alw_chg_sel_c                INTEGER;
    Line_sel_c                   INTEGER;
    Line_t_sel_c                 INTEGER;

    cHeader_select               VARCHAR2( 32000);
    cHeader_1_select             VARCHAR2( 32000);
    cAlw_chg_select              VARCHAR2( 32000);
    cLine_select                 VARCHAR2( 32000);
    cLine_t_select               VARCHAR2( 32000);

    cHeader_from                 VARCHAR2( 32000);
    cHeader_1_from               VARCHAR2( 32000);
    cAlw_chg_from                VARCHAR2( 32000);
    cLine_from                   VARCHAR2( 32000);
    cLine_t_from                 VARCHAR2( 32000);

    cHeader_where                VARCHAR2( 32000);
    cHeader_1_where              VARCHAR2( 32000);
    cAlw_chg_where               VARCHAR2( 32000);
    cLine_where                  VARCHAR2( 32000);
    cLine_t_where                VARCHAR2( 32000);

    iHeader_count                NUMBER := 0;
    iHeader_1_count              NUMBER := 0;
    iAlw_chg_count               NUMBER := 0;
    iLine_count                  NUMBER := 0;
    iLine_t_count                NUMBER := 0;
    iKey_count                   NUMBER := 0;

    l_header_fkey                NUMBER;
    l_header_1_fkey              NUMBER;
    l_alw_chg_fkey               NUMBER;
    l_line_fkey                  NUMBER;
    l_line_t_fkey                NUMBER;

    n_trx_date_pos               NUMBER;
    n_runid_pos                  NUMBER;

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
    nPos10                       NUMBER;
    nPos11                       NUMBER;
    nPos12                       NUMBER;
    nPos13                       NUMBER;
    nPos14                       NUMBER;
    nPos15                       NUMBER;
    nPos16                       NUMBER;
    nPos17                       NUMBER;
    nPos18                       NUMBER;
    nPos19                       NUMBER;
    nPos20                       NUMBER;
    nPos21                       NUMBER;
    nPos23                       NUMBER;
    nPos24                       NUMBER;
    nPos25                       NUMBER;
    nPos26                       NUMBER;
    nPos27                       NUMBER;
    nPos28                       NUMBER;	 -- Bug 2389231
    pos_1                        NUMBER;
    nTrans_id                    NUMBER;

   l_net_weight                  NUMBER:=0;
   l_gross_weight                NUMBER:=0;
   l_volume                      NUMBER:=0;
   l_weight_uom_code             VARCHAR2(3);
   l_volume_uom_code             VARCHAR2(3);
   l_shipment_number               NUMBER;
   l_booking_number              VARCHAR2(30);

   l_weight_uom_code_ext1        VARCHAR2(3);     -- bug 1979725 begin
   l_weight_uom_code_ext2        VARCHAR2(3);
   l_weight_uom_code_ext3        VARCHAR2(3);
   l_weight_uom_code_ext4        VARCHAR2(3);
   l_weight_uom_code_ext5        VARCHAR2(3);

   l_volume_uom_code_ext1        VARCHAR2(3);
   l_volume_uom_code_ext2        VARCHAR2(3);
   l_volume_uom_code_ext3        VARCHAR2(3);
   l_volume_uom_code_ext4        VARCHAR2(3);
   l_volume_uom_code_ext5        VARCHAR2(3);    -- bug 1979725 end

    l_remit_to_address1          VARCHAR2(240);
    l_remit_to_address2          VARCHAR2(240);
    l_remit_to_address3          VARCHAR2(240);
    l_remit_to_address4          VARCHAR2(240);
    l_remit_to_city              VARCHAR2(60);
    l_remit_to_county            VARCHAR2(60);
    l_remit_to_state             VARCHAR2(60);
    l_remit_to_province          VARCHAR2(60);
    l_remit_to_country           VARCHAR2(60);
    l_remit_to_postal_code       VARCHAR2(60);
    l_remit_to_customer_name     VARCHAR2(50); --2291130
    l_remit_to_edi_location_code VARCHAR2(40); --2386848
    l_Multiple_Installments_Flag VARCHAR2(1);
    l_Maximum_Installment_Number NUMBER;
    l_Amount_Tax_Due             NUMBER;
    l_Amount_Charges_Due         NUMBER;
    l_Amount_Freight_Due         NUMBER;
    l_Amount_Line_Items_Due      NUMBER;
    l_total_amount_due           NUMBER;
    l_Discount_Percent1          NUMBER;
    l_Discount_Days1             NUMBER;
    l_Discount_Date1             DATE;
    l_Discount_Day_Of_Month1     NUMBER;
    l_Discount_Months_Forward1   NUMBER;
    l_Discount_Percent2          NUMBER;
    l_Discount_Days2             NUMBER;
    l_Discount_Date2             DATE;
    l_Discount_Day_Of_Month2     NUMBER;
    l_Discount_Months_Forward2   NUMBER;
    l_Discount_Percent3          NUMBER;
    l_Discount_Days3             NUMBER;
    l_Discount_Date3             DATE;
    l_Discount_Day_Of_Month3     NUMBER;
    l_Discount_Months_Forward3   NUMBER;
    l_line_item_number           VARCHAR2(100);
    l_line_item_attrib_category  VARCHAR2( 30);
  -- BUG:4451874 Length changed to 240 characters
    l_line_item_attribute1       VARCHAR2(240);
    l_line_item_attribute2       VARCHAR2(240);
    l_line_item_attribute3       VARCHAR2(240);
    l_line_item_attribute4       VARCHAR2(240);
    l_line_item_attribute5       VARCHAR2(240);
    l_line_item_attribute6       VARCHAR2(240);
    l_line_item_attribute7       VARCHAR2(240);
    l_line_item_attribute8       VARCHAR2(240);
    l_line_item_attribute9       VARCHAR2(240);
    l_line_item_attribute10      VARCHAR2(240);
    l_line_item_attribute11      VARCHAR2(240);
    l_line_item_attribute12      VARCHAR2(240);
    l_line_item_attribute13      VARCHAR2(240);
    l_line_item_attribute14      VARCHAR2(240);
    l_line_item_attribute15      VARCHAR2(240);
    l_allowance_charge_indicator VARCHAR2(1);
    l_charge_code                VARCHAR2(50);
    l_special_charges_code       VARCHAR2(50);
    l_special_services_code      VARCHAR2(50);
    l_method_handling_code       VARCHAR2(50);
    init_msg_list                VARCHAR2(20);
    simulate                     VARCHAR2(20);
    validation_level             VARCHAR2(20);
    commt                        VARCHAR2(20);
    return_status                VARCHAR2(20);
    msg_count                    VARCHAR2(20);
    msg_data                     VARCHAR2(2000);
    l_remit_to_code_ext          VARCHAR2( 35);
    l_remit_to_code_int          VARCHAR2(240);
    l_sold_to_customer_code_ext  VARCHAR2( 35);
    l_ship_to_customer_code_ext  VARCHAR2( 35);
    l_bill_to_code_ext           VARCHAR2( 35);
    l_bill_to_tp_reference_ext1  VARCHAR2(240);
    l_bill_to_tp_reference_ext2  VARCHAR2(240);
    l_ship_to_tp_reference_ext1  VARCHAR2(240);
    l_ship_to_tp_reference_ext2  VARCHAR2(240);
    l_sold_to_tp_reference_ext1  VARCHAR2(240);
    l_sold_to_tp_reference_ext2  VARCHAR2(240);
    l_remit_to_tp_reference_ext1 VARCHAR2(240);
    l_remit_to_tp_reference_ext2 VARCHAR2(240);
    l_reference_ext1             VARCHAR2(240);
    l_reference_ext2             VARCHAR2(240);
    l_last_update_date           DATE;
    l_line_type                  VARCHAR2(20);
    l_cust_trx_line_id           NUMBER;
    l_header_detail_ind          VARCHAR2(1);
    l_data_found                 BOOLEAN := FALSE;
    l_delivery_id                NUMBER;
    l_delivery_name              VARCHAR2(30);
    l_output_level               VARCHAR2(1) := NULL;
    l_alw_chg_output_level       VARCHAR2(1);
    l_bill_to_contact_id         NUMBER;           /*2945057*/
    l_ship_to_contact_id         NUMBER;
    l_sold_to_contact_id         NUMBER;
    l_bill_to_contact_first_name VARCHAR2(240);
    l_bill_to_contact_last_name  VARCHAR2(240);
    l_bill_to_contact_job_title  VARCHAR2(240);
    l_ship_to_contact_first_name VARCHAR2(240);
    l_ship_to_contact_last_name  VARCHAR2(240);
    l_ship_to_contact_job_title  VARCHAR2(240);
    l_sold_to_contact_first_name VARCHAR2(240);
    l_sold_to_contact_last_name  VARCHAR2(240);
    l_sold_to_contact_job_title  VARCHAR2(240);    /*2945057*/

    v_LevelProcessed             VARCHAR2(40);

    d_dummy_date                 DATE;
  CURSOR c_header_1
         (tx_id IN NUMBER) IS
  SELECT
	     RTRIM(WTP.VEHICLE_NUM_PREFIX, '0123456789') EQUIPMENT_PREFIX ,
             SUBSTR(WTP.VEHICLE_NUMBER, NVL(LENGTH(RTRIM(WTP.VEHICLE_NUMBER, '0123456789')), 0)+1) EQUIPMENT_NUMBER,
             SUBSTR(WTP.ROUTING_INSTRUCTIONS, 1, 150) ROUTING_INSTRUCTIONS,
	     WDI.SEQUENCE_NUMBER PACKING_SLIP_NUMBER
           FROM
            WSH_DELIVERY_DETAILS
            WDD ,
            WSH_DELIVERY_LEGS
            WDL,
            WSH_TRIP_STOPS
            WTS,
            WSH_TRIPS
            WTP,
            WSH_DOCUMENT_INSTANCES
            WDI,
            RA_CUSTOMER_TRX_LINES
            RCTL
           WHERE
            TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE6) =
            WDD.SOURCE_LINE_ID AND
            TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE3) =
            WDL.DELIVERY_ID  AND
            WDL.PICK_UP_STOP_ID = WTS.STOP_ID  AND
            WTS.TRIP_ID = WTP.TRIP_ID AND
            NVL(TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE3),0) =
            WDI.ENTITY_ID  AND
            RCTL.customer_trx_id = tx_id
            AND RCTL.INTERFACE_LINE_CONTEXT =
            fnd_profile.value('ONT_SOURCE_CODE')
	    AND ROWNUM = 1;

  BEGIN

    ec_debug.push ( 'ece_ar_transaction.Populate_AR_Trx' );
    ec_debug.pl ( 3, 'cCommunication_Method: ', cCommunication_Method );
    ec_debug.pl ( 3, 'cTransaction_Type: ',cTransaction_Type );
    ec_debug.pl ( 3, 'iOutput_width: ',iOutput_width );
    ec_debug.pl ( 3, 'dTransaction_date: ',dTransaction_date );
    ec_debug.pl ( 3, 'iRun_id: ',iRun_id );
    ec_debug.pl ( 3, 'cHeader_Interface: ',cHeader_Interface );
    ec_debug.pl ( 3, 'cHeader_1_Interface: ',cHeader_1_Interface );
    ec_debug.pl ( 3, 'cAlw_Chg_Interface: ',cAlw_Chg_Interface );
    ec_debug.pl ( 3, 'cLine_Interface: ',cLine_Interface );
    ec_debug.pl ( 3, 'cLine_t_Interface: ',cLine_t_Interface );
    ec_debug.pl ( 3, 'cCreate_Date_From: ',cCreate_Date_From );
    ec_debug.pl ( 3, 'cCreate_Date_To: ',cCreate_Date_To );
    ec_debug.pl ( 3, 'cCustomer_Name: ',cCustomer_Name );
    ec_debug.pl ( 3, 'cSite_Use_Code: ',cSite_Use_Code );
    ec_debug.pl ( 3, 'cDocument_Type: ',cDocument_Type );
    ec_debug.pl ( 3, 'cTransaction_Number: ',cTransaction_Number );

    xProgress := '2000-70';
    ece_flatfile_pvt.init_table(cTransaction_Type,cHeader_Interface,NULL,FALSE,l_header_tbl,l_key_tbl);

    xProgress  := '2020-70';
    l_key_tbl  := l_header_tbl;

    xProgress  := '2022-70';
    iKey_count := l_header_tbl.count;

    xProgress  := '2030-70';
    ece_flatfile_pvt.init_table(cTransaction_Type,cHeader_1_Interface,NULL,TRUE,l_header_1_tbl,l_key_tbl);


           /*
        *  The output level is passed on for Allowance Charges table because the Interface
        *  Table ECE_AR_TRX_ALLOWANCE_CHARGES is referenced more than one in the
        *  ECE_INTERFACE_COLUMNS
       */

       xProgress := '2060-70';
       BEGIN
            SELECT MIN(eel.external_level)
           INTO l_alw_chg_output_level
           FROM ece_interface_tables eit,
           ece_level_matrices elm,
           ece_external_levels eel
      WHERE eit.interface_table_name = 'ECE_AR_TRX_ALLOWANCE_CHARGES'
           AND eit.transaction_type = cTransaction_type
      AND   eit.interface_table_id = elm.interface_table_id
      AND   elm.external_level_id = eel.external_level_id
      AND   eel.map_id = (SELECT NVL(cMap_id, MAX(em1.map_id))
                            FROM ece_mappings em1
                            WHERE em1.map_code like 'EC_'||RTRIM(LTRIM(NVL(cTransaction_type,'%')))||'_FF');
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           ec_debug.pl ( 1,
                         'EC',
                         'ECE_NO_ROW_SELECTED',
                         'PROGRESS_LEVEL',
                         xProgress,
                         'INFO',
                         'MINIMUM OUTPUT LEVEL',
                         'TABLE_NAME',
                         'ECE_INTERFACE_TABLES' );
       END;
       ec_debug.pl ( 3, 'l_alw_chg_output_level: ',l_alw_chg_output_level );


    xProgress := '2070-70';
    ece_flatfile_pvt.init_table(cTransaction_Type,cAlw_chg_Interface,l_alw_chg_output_level,TRUE,l_alw_chg_tbl,l_key_tbl);

    xProgress := '2100-70';
    ece_flatfile_pvt.init_table(cTransaction_Type,cLine_Interface,NULL,TRUE,l_line_tbl,l_key_tbl);

    xProgress := '2130-70';
    ece_flatfile_pvt.init_table(cTransaction_Type,cLine_t_Interface,NULL,TRUE,l_line_t_tbl,l_key_tbl);

    -- ***************************************************************************
    --
    -- Here, I am building the SELECT, FROM, and WHERE  clauses for the dynamic
    -- SQL call
    -- The ece_extract_utils_pub.select_clause uses the EDI data dictionary for the build.
    --
    -- **************************************************************************

    xProgress := '2160-70';
    ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                          cCommunication_Method,
                                          cHeader_Interface,
                                          l_header_tbl,
                                          cHeader_select,
                                          cHeader_from,
                                          cHeader_where );

    xProgress := '2170-70';
    ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                          cCommunication_Method,
                                          cHeader_1_Interface,
                                          l_header_1_tbl,
                                          cHeader_1_select,
                                          cHeader_1_from,
                                          cHeader_1_where );

    xProgress := '2180-70';
    ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                          cCommunication_Method,
                                          cAlw_chg_Interface,
                                          l_alw_chg_tbl,
                                          cAlw_chg_select,
                                          cAlw_chg_from,
                                          cAlw_chg_where );

    xProgress := '2190-70';
    ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                          cCommunication_Method,
                                          cLine_Interface,
                                          l_line_tbl,
                                          cLine_select,
                                          cLine_from ,
                                          cLine_where );

    xProgress := '2200-70';
    ece_extract_utils_pub.select_clause ( cTransaction_Type,
                                          cCommunication_Method,
                                          cLine_t_Interface,
                                          l_line_t_tbl,
                                          cLine_t_select,
                                          cLine_t_from ,
                                          cLine_t_where );

    -- **************************************************************************
    --  Here, I am customizing the WHERE clause to join the Interface tables together.
    --  i.e. Headers -- Lines -- Line Details
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
    --  :transaction_id is a place holder for foreign key value.
    --  A PL/SQL table (list of values) will be used to store data.
    --  Procedure ece_flatfile.Find_pos will be used to locate the specific
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
    --  3. Execute dynamic SQL 2 for lines (B) data
    --      Get value of B.yyy (foreigh key to C)
    --
    --  4. bind value B.yyy to variable C.yyy
    --
    --  5. Execute dynamic SQL 3 for line_details (C) data
    -- **************************************************************************
    -- **************************************************************************
    --   Change the following few lines as needed
    -- **************************************************************************


    xProgress     := '2210-70';
    cHeader_where := cHeader_where                                             ||
                     'ECE_INO_HEADER_V.COMMUNICATION_METHOD ='                 ||
                     ''''                                                      ||
                     cCommunication_Method                                     ||
                     '''';

    xProgress := '2220-70';
    IF cCreate_Date_From IS NOT NULL
    THEN
      xProgress     := '2222-70';
      cHeader_where := cHeader_where                                           ||
                       ' AND '                                                 ||
                       'ECE_INO_HEADER_V.CREATION_DATE >='                     ||
                       ':l_cCreate_Date_From';
    END IF;

    xProgress := '2230-70';
    IF cCreate_Date_To IS NOT NULL
    THEN
      xProgress     := '2232-70';
      cHeader_where := cHeader_where                                           ||
                       ' AND '                                                 ||
                       'ECE_INO_HEADER_V.CREATION_DATE <='                     ||
                       ':l_cCreate_Date_To';
    END IF;

    xProgress := '2240-70';
    IF cCustomer_Name IS NOT NULL
    THEN
      xProgress     := '2242-70';
      cHeader_where := cHeader_where                                           ||
                       ' AND '                                                 ||
                       'ECE_INO_HEADER_V.BILL_TO_CUSTOMER_NAME ='              ||
                       ':l_cCustomer_Name';
    END IF;

    xProgress := '2250-70';
    IF cSite_Use_Code IS NOT NULL
    THEN
      xProgress     := '2252-70';
      cHeader_where := cHeader_where                                           ||
                       ' AND '                                                 ||
                       'ECE_INO_HEADER_V.SITE_USE_CODE ='                      ||
                       ':l_cSite_Use_Code';
    END IF;

    xProgress := '2260-70';
    IF cDocument_Type IS NOT NULL
    THEN
      xProgress     := '2262-70';
      cHeader_where := cHeader_where                                           ||
                       ' AND '                                                 ||
                       'ECE_INO_HEADER_V.DOCUMENT_TYPE ='                      ||
                       ':l_cDocument_Type';
    END IF;

    xProgress := '2270-70';
    IF cTransaction_Number IS NOT NULL
    THEN
      xProgress     := '2272-70';
      cHeader_where := cHeader_where                                           ||
                       ' AND '                                                 ||
                       'ECE_INO_HEADER_V.TRANSACTION_NUMBER ='                 ||
                       ':l_cTransaction_Number';
    END IF;
    ec_debug.pl ( 3, 'cHeader_where: ',cHeader_where );

    xProgress         := '2280-70';
    cHeader_1_where   := cHeader_1_where                                       ||
                         'ECE_INO_HEADER_1_V.TRANSACTION_ID = :transaction_id AND ROWNUM = 1';
    ec_debug.pl ( 3, 'cHeader_1_where: ',cHeader_1_where );

    xProgress         := '2290-70';
    cAlw_chg_where    := cAlw_chg_where                                        ||
                         'ECE_INO_ALLOWANCE_CHARGES_V.TRANSACTION_ID = :transaction_id';
    ec_debug.pl ( 3, 'cAlw_chg_where: ',cAlw_chg_where );

    xProgress         := '2300-70';
    cLine_where       := cLine_where                                           ||
                         'ECE_INO_LINE_V.TRANSACTION_ID = :transaction_id';
    ec_debug.pl ( 3, 'cLine_where: ',cLine_where );

    xProgress         := '2310-70';
    cLine_t_where     := cLine_t_where                                         ||
                         'ECE_INO_LINE_TAX_V.TRANSACTION_ID = :transaction_id' ||
                         ' AND '                                               ||
                         'ECE_INO_LINE_TAX_V.LINE_NUMBER = :line_number';
    ec_debug.pl ( 3, 'cLine_t_where: ',cLine_t_where );

    -- **********************************************************************************
    -- If Allowance and Charges functionality becomes part of Standard EDI Gateway then
    -- remove check on automotive product being installed without modifying the where
    -- clause.
    -- **********************************************************************************

    xProgress := '2320-70';
    IF l_Automotive_Installed THEN
      xProgress     := '2330-70';
      cLine_t_where := cLine_t_where                                           ||
                       ' AND '                                                 ||
                       'ECE_INO_LINE_TAX_V.LINE_TYPE <>''FREIGHT''';
      ec_debug.pl ( 3, 'cLine_t_where: ',cLine_t_where );
    END IF;

    xProgress        := '2340-70';
    cHeader_select   := cHeader_select                                         ||
                        cHeader_from                                           ||
                        cHeader_where                                          ||
                        ' ORDER BY BILL_TO_CUSTOMER_NAME,BILL_TO_CUSTOMER_LOCATION';    /* Bug 2464584 */

    cHeader_1_select := cHeader_1_select                                       ||
                        cHeader_1_from                                         ||
                        cHeader_1_where;

    cAlw_chg_select  := cAlw_chg_select                                        ||
                        cAlw_chg_from                                          ||
                        cAlw_chg_where;

    cLine_select     := cLine_select                                           ||
                        cLine_from                                             ||
                        cLine_where;

    cLine_t_select   := cLine_t_select                                         ||
                        cLine_t_from                                           ||
                        cLine_t_where;

    ec_debug.pl ( 3, 'cHeader_select: ',cHeader_select );
    ec_debug.pl ( 3, 'cHeader_1_select: ',cHeader_1_select );
    ec_debug.pl ( 3, 'cAlw_chg_select: ',cAlw_chg_select );
    ec_debug.pl ( 3, 'cLine_select: ',cLine_select );
    ec_debug.pl ( 3, 'cLine_t_select: ',cLine_t_select );



    -- ***************************************************
    -- ***
    -- ***   Get data setup for the dynamic SQL call.
    -- ***
    -- ***   Open a cursor for each of the SELECT call
    -- ***   This tells the database to reserve spaces
    -- ***   for the data returned by the SQL statement
    -- ***
    -- ***************************************************

    xProgress      := '2350-70';
    Header_sel_c   := dbms_sql.open_cursor;

    xProgress      := '2352-70';
    Header_1_sel_c := dbms_sql.open_cursor;

    xProgress      := '2354-70';
    Alw_chg_sel_c  := dbms_sql.open_cursor;

    xProgress      := '2356-70';
    Line_sel_c     := dbms_sql.open_cursor;

    xProgress      := '2358-70';
    Line_t_sel_c   := dbms_sql.open_cursor;

    -- ***************************************************
    --
    --   Parse each of the SELECT statement
    --   so the database understands the command
    --
    -- ***************************************************

    xProgress := '2360-70';
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

    xProgress := '2362-70';
    BEGIN
      dbms_sql.parse ( Header_1_sel_c,
                       cHeader_1_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cHeader_1_select );
        app_exception.raise_exception;
    END;

    xProgress := '2364-70';
    BEGIN
      dbms_sql.parse ( Alw_chg_sel_c,
                       cAlw_chg_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cAlw_chg_select );
        app_exception.raise_exception;
    END;

    xProgress := '2366-70';
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

    xProgress := '2368-70';
    BEGIN
      dbms_sql.parse ( Line_t_sel_c,
                       cLine_t_select,
                       dbms_sql.native );
    EXCEPTION
      WHEN OTHERS THEN
        ece_error_handling_pvt.print_parse_error ( dbms_sql.last_error_position,
                                                   cLine_t_select );
        app_exception.raise_exception;
    END;

    -- *************************************************
    -- set counter
    -- *************************************************

    xProgress       := '2370-70';
    iHeader_count   := l_header_tbl.count;
    ec_debug.pl ( 3, 'iHeader_count: ',iHeader_count );

    xProgress       := '2372-70';
    iHeader_1_count := l_header_1_tbl.count;
    ec_debug.pl ( 3, 'iHeader_1_count: ',iHeader_1_count );

    xProgress       := '2374-70';
    iAlw_chg_count  := l_alw_chg_tbl.count;
    ec_debug.pl ( 3, 'iAlw_chg_count: ',iAlw_chg_count );

    xProgress       := '2376-70';
    iLine_count     := l_line_tbl.count;
    ec_debug.pl ( 3, 'iLine_count: ',iLine_count );

    xProgress       := '2378-70';
    iLine_t_count   := l_line_t_tbl.count;
    ec_debug.pl ( 3, 'iLine_t_count: ',iLine_t_count );

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

    xProgress := '2380-70';
    define_interface_column ( Header_sel_c,
                              cHeader_select,
                              ece_extract_utils_PUB.G_MaxColWidth,
                              l_header_tbl );

    xProgress := '2382-70';
    define_interface_column ( Header_1_sel_c,
                              cHeader_1_select,
                              ece_extract_utils_PUB.G_MaxColWidth,
                              l_header_1_tbl );

    xProgress := '2384-70';
    define_interface_column ( Alw_chg_sel_c,
                              cAlw_chg_select,
                              ece_extract_utils_PUB.G_MaxColWidth,
                              l_alw_chg_tbl );

    xProgress := '2386-70';
    define_interface_column ( Line_sel_c,
                              cLine_select,
                              ece_extract_utils_PUB.G_MaxColWidth,
                              l_line_tbl );
    xProgress := '2388-70';
    define_interface_column ( Line_t_sel_c,
                              cLine_t_select,
                              ece_extract_utils_PUB.G_MaxColWidth,
                              l_line_t_tbl );
    -- Bind Variables
    xProgress := '2388-70';
    IF cCreate_Date_From IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_cCreate_Date_From',
                                cCreate_Date_From);
    END IF;

    xProgress := '2388-71';
    IF cCreate_Date_To IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_cCreate_Date_To',
                                cCreate_Date_To);
    END IF;

    xProgress := '2388-72';
    IF cCustomer_Name IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_cCustomer_Name',
                                cCustomer_Name );
    END IF;

    xProgress := '2388-73';
    IF cSite_Use_Code IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_cSite_Use_Code',
                               cSite_Use_Code );
    END IF;

    xProgress := '2388-74';
    IF cDocument_Type IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_cDocument_Type',
                                cDocument_Type );
    END IF;

    xProgress := '2388-75';
    IF cTransaction_Number IS NOT NULL
    THEN
      dbms_sql.bind_variable ( Header_sel_c,
                               'l_cTransaction_Number',
                                cTransaction_Number );
    END IF;

    -- **************************************************************
    -- ***  The following is custom tailored for this transaction
    -- ***  It find the values and use them in the WHERE clause to
    -- ***  join tables together.
    -- **************************************************************

    -- ***************************************************
    -- To complete the Line SELECT statement,
    --  we will need values for the join condition.
    --
    -- ***************************************************
    --  EXECUTE the SELECT statement

    xProgress := '2390-70';
    dummy     := dbms_sql.execute(Header_sel_c);

    -- ***************************************************
    --
    --  The model is:
    --   HEADER - HEADER 1 - ALLOWANCE CHARGES - LINE - LINE TAX ...
    --
    --   With data for each HEADER line, populate the header interface
    --   table then get all HEADER DETAILS and ALLOWANCE CHARGES that belong to the HEADER,
    --   then get LINES that belong to the HEADER. Then get all
    --   LINE TAX that belongs to the LINE.
    --
    -- ***************************************************

    xProgress := '2400-70';
    WHILE dbms_sql.fetch_rows ( Header_sel_c ) > 0
    LOOP           -- Header

      -- ***************************************************
      --
      --  store internal values in pl/sql table
      --
      -- ***************************************************

      xProgress := '2410-70';
      FOR i IN 1..iHeader_count
      LOOP
        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_header_tbl(i).value );

        dbms_sql.column_value ( Header_sel_c,
                                i,
                                l_key_tbl(i).value );
      END LOOP;

      xProgress := '2420-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl,
                                       'TRANSACTION_ID',
                                       nPos1 );
      ec_debug.pl ( 3, 'nPos1: ',nPos1 );

      xProgress := '2422-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl,
                                       'INSTALLMENT_NUMBER',
                                       nPos2 );
      ec_debug.pl ( 3, 'nPos2: ',nPos2 );

      xProgress := '2424-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl,
                                       'DOCUMENT_TYPE',
                                       nPos3 );
      ec_debug.pl ( 3, 'nPos3: ',nPos3 );

      xProgress := '2426-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'PAYMENT_TERM_ID',
                                       nPos4 );
      ec_debug.pl ( 3, 'nPos4: ',nPos4 );

      xProgress := '2428-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'SHIP_TO_ADDRESS_ID',
                                       nPos5 );
      ec_debug.pl ( 3, 'nPos5: ',nPos5 );

      xProgress := '2430-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'SOLD_TO_ADDRESS_ID',
                                       nPos6 );
      ec_debug.pl ( 3, 'nPos6: ',nPos6 );

      xProgress := '2431-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'BILL_TO_ADDRESS_ID',
                                       nPos8 );
      ec_debug.pl ( 3, 'nPos8: ',nPos8 );

      xProgress := '2432-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'TP_LOCATION_CODE_EXT',
                                       nPos7 );
      ec_debug.pl ( 3, 'nPos7: ',nPos7 );

      xProgress := '2434-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_ADDRESS1',
                                       nPos10 );
      ec_debug.pl ( 3, 'nPos10: ',nPos10 );

      xProgress := '2436-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_ADDRESS2',
                                       nPos11 );
      ec_debug.pl ( 3, 'nPos11: ',nPos11 );

      xProgress := '2438-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_ADDRESS3',
                                       nPos12 );
      ec_debug.pl ( 3, 'nPos12: ',nPos12 );

      xProgress := '2440-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_ADDRESS4',
                                       nPos13 );
      ec_debug.pl ( 3, 'nPos13: ',nPos13 );

      xProgress := '2442-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_CITY',
                                       nPos14 );
      ec_debug.pl ( 3, 'nPos14: ',nPos14 );

      xProgress := '2444-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_COUNTY',
                                       nPos15 );
      ec_debug.pl ( 3, 'nPos15: ',nPos15 );

      xProgress := '2446-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_STATE',
                                       nPos16 );
      ec_debug.pl ( 3, 'nPos16: ',nPos16 );

      xProgress := '2448-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_PROVINCE',
                                       nPos17 );
      ec_debug.pl ( 3, 'nPos17: ',nPos17 );

      xProgress := '2450-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_COUNTRY',
                                       nPos18 );
      ec_debug.pl ( 3, 'nPos18: ',nPos18 );

      xProgress := '2452-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'REMIT_TO_POSTAL_CODE',
                                       nPos19 );
      ec_debug.pl ( 3, 'nPos19: ',nPos19 );

      xProgress := '2452-71';				--Bug 2389231
      ece_extract_utils_pub.Find_pos ( l_header_tbl  ,
                                       'INV_TRANSACTION_DATE',
                                       nPos28 );
      ec_debug.pl ( 3, 'nPos28: ',nPos28 );
      ec_debug.pl(3, 'l_header_tbl(nPos28).value',l_header_tbl(nPos28).value);

      -- ***************************************************
      --
      --  also need to populate transaction_date and run_id
      --
      -- ***************************************************

      xProgress := '2460-70';
      ece_extract_utils_pub.Find_pos ( l_header_tbl,
                                       ece_flatfile_pvt.G_Transaction_date,
                                       n_trx_date_pos );

      xProgress                          := '2470-70';
      l_header_tbl(n_trx_date_pos).value := TO_CHAR(dTransaction_date,'YYYYMMDD HH24MISS');
      ec_debug.pl ( 3, 'lheader_tbl(n_trx_date_pos).value: ',l_header_tbl(n_trx_date_pos).value );

      xProgress := '2475-70';

/* 2945057*/
              select bill_to_contact_id,ship_to_contact_id,sold_to_contact_id
              into l_bill_to_contact_id,l_ship_to_contact_id,l_sold_to_contact_id
              from ra_customer_trx
              where customer_trx_id=l_header_tbl(nPos1).value;

      If (l_bill_to_contact_id is not null) then
         begin
           xProgress := '2476-70';
            SELECT
                substrb(PARTY.PERSON_LAST_NAME,1,50),
                substrb(PARTY.PERSON_FIRST_NAME,1,40),
                ORG_CONT.JOB_TITLE
            into l_bill_to_contact_last_name,l_bill_to_contact_first_name,l_bill_to_contact_job_title
            FROM
          	 HZ_CUST_ACCOUNT_ROLES  ACCT_ROLE,
                 HZ_PARTIES             PARTY,
 	         HZ_RELATIONSHIPS       REL,
         	 HZ_ORG_CONTACTS        ORG_CONT
            WHERE
                 ACCT_ROLE.PARTY_ID         = REL.PARTY_ID
                 AND ACCT_ROLE.ROLE_TYPE            = 'CONTACT'
                 AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
                 AND REL.DIRECTIONAL_FLAG      	= 'F'
                 AND REL.SUBJECT_TABLE_NAME    	= 'HZ_PARTIES'
                 AND REL.OBJECT_TABLE_NAME      = 'HZ_PARTIES'
                 AND REL.SUBJECT_ID             = PARTY.PARTY_ID
                 AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID =  l_bill_to_contact_id;
        /*    select last_name,first_name,job_title
            into l_bill_to_contact_last_name,l_bill_to_contact_first_name,l_bill_to_contact_job_title
            from ra_contacts
            where contact_id=l_bill_to_contact_id; */
         exception
         when others then
	    ec_debug.pl ( 3, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress );
         end;
      End If;

      If (l_ship_to_contact_id is not null) then
          begin
            xProgress :='2477-70';
             SELECT
                substrb(PARTY.PERSON_LAST_NAME,1,50),
                substrb(PARTY.PERSON_FIRST_NAME,1,40),
                ORG_CONT.JOB_TITLE
            into l_ship_to_contact_last_name,l_ship_to_contact_first_name,l_ship_to_contact_job_title
            FROM
          	 HZ_CUST_ACCOUNT_ROLES  ACCT_ROLE,
                 HZ_PARTIES             PARTY,
 	         HZ_RELATIONSHIPS       REL,
         	 HZ_ORG_CONTACTS        ORG_CONT,
         	 HZ_PARTIES             REL_PARTY
            WHERE
                 ACCT_ROLE.PARTY_ID         = REL.PARTY_ID
                 AND ACCT_ROLE.ROLE_TYPE            = 'CONTACT'
                 AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
                 AND REL.DIRECTIONAL_FLAG          		= 'F'
                 AND REL.SUBJECT_TABLE_NAME         = 'HZ_PARTIES'
                 AND REL.OBJECT_TABLE_NAME          = 'HZ_PARTIES'
                 AND REL.SUBJECT_ID                 = PARTY.PARTY_ID
                 AND REL.PARTY_ID                   = REL_PARTY.PARTY_ID
                 AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID =  l_ship_to_contact_id;
/*
             select last_name,first_name,job_title
             into l_ship_to_contact_last_name,l_ship_to_contact_first_name,l_ship_to_contact_job_title
             from ra_contacts
             where contact_id=l_ship_to_contact_id; */
          exception
          when others then
	     ec_debug.pl ( 3, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress );
          end;
      End If;

      If (l_sold_to_contact_id is not null) then
          begin
            xProgress :='2477-70';
	     SELECT
                substrb(PARTY.PERSON_LAST_NAME,1,50),
                substrb(PARTY.PERSON_FIRST_NAME,1,40),
                ORG_CONT.JOB_TITLE
            into l_sold_to_contact_last_name,l_sold_to_contact_first_name,l_sold_to_contact_job_title
            FROM
          	 HZ_CUST_ACCOUNT_ROLES  ACCT_ROLE,
                 HZ_PARTIES             PARTY,
 	         HZ_RELATIONSHIPS       REL,
         	 HZ_ORG_CONTACTS        ORG_CONT,
         	 HZ_PARTIES             REL_PARTY
            WHERE
                 ACCT_ROLE.PARTY_ID         = REL.PARTY_ID
                 AND ACCT_ROLE.ROLE_TYPE            = 'CONTACT'
                 AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
                 AND REL.DIRECTIONAL_FLAG          		= 'F'
                 AND REL.SUBJECT_TABLE_NAME         = 'HZ_PARTIES'
                 AND REL.OBJECT_TABLE_NAME          = 'HZ_PARTIES'
                 AND REL.SUBJECT_ID                 = PARTY.PARTY_ID
                 AND REL.PARTY_ID                   = REL_PARTY.PARTY_ID
                 AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID =  l_sold_to_contact_id;
           /*  select last_name,first_name,job_title
             into l_sold_to_contact_last_name,l_sold_to_contact_first_name,l_sold_to_contact_job_title
             from ra_contacts
             where contact_id=l_sold_to_contact_id; */
          exception
          when others then
	     ec_debug.pl ( 3, 'EC', 'ECE_PROGRAM_ERROR', 'PROGRESS_LEVEL', xProgress );
          end;
      End If;
/*2945057*/

      -- The following procedures get the payment and remit address
      -- information for this transaction

      xProgress := '2480-70';
      ece_ar_transaction.Get_Payment ( l_header_tbl(nPos1).value,
                                       l_header_tbl(nPos2).value,
                                       l_Multiple_Installments_Flag,
                                       l_Maximum_Installment_Number,
                                       l_Amount_Tax_Due,
                                       l_Amount_Charges_Due,
                                       l_Amount_Freight_Due,
                                       l_Amount_Line_Items_Due,
                                       l_total_amount_due );

      xProgress := '2490-70';
      ece_ar_transaction.Get_Remit_Address ( l_header_tbl(nPos1).value,
                                             l_remit_to_address1,
                                             l_remit_to_address2,
                                             l_remit_to_address3,
                                             l_remit_to_address4,
                                             l_remit_to_city,
                                             l_remit_to_county,
                                             l_remit_to_state,
                                             l_remit_to_province,
                                             l_remit_to_country,
                                             l_remit_to_code_int,
                                             l_remit_to_postal_code,
                                             l_remit_to_customer_name,      --2291130
                                             l_remit_to_edi_location_code); --2386848

      -- Now update the values in pl/sql table
      -- This is being done so that code conversion can be done on derived fields thru
      -- a procedure.

      xProgress := '2500-70';
      l_header_tbl(nPos10).value := l_remit_to_address1;
      ec_debug.pl ( 3, 'lheader_tbl(nPos10).value: ',l_header_tbl(nPos10).value );
      xProgress := '2501-70';
      l_header_tbl(nPos11).value := l_remit_to_address2;
      ec_debug.pl ( 3, 'lheader_tbl(nPos11).value: ',l_header_tbl(nPos11).value );
      xProgress := '2502-70';
      l_header_tbl(nPos12).value := l_remit_to_address3;
      ec_debug.pl ( 3, 'lheader_tbl(nPos12).value: ',l_header_tbl(nPos12).value );
      xProgress := '2503-70';
      l_header_tbl(nPos13).value := l_remit_to_address4;
      ec_debug.pl ( 3, 'lheader_tbl(nPos13).value: ',l_header_tbl(nPos13).value );
      xProgress := '2504-70';
      l_header_tbl(nPos14).value := l_remit_to_city;
      ec_debug.pl ( 3, 'lheader_tbl(nPos14).value: ',l_header_tbl(nPos14).value );
      xProgress := '2505-70';
      l_header_tbl(nPos15).value := l_remit_to_county;
      ec_debug.pl ( 3, 'lheader_tbl(nPos15).value: ',l_header_tbl(nPos15).value );
      xProgress := '2506-70';
      l_header_tbl(nPos16).value := l_remit_to_state;
      ec_debug.pl ( 3, 'lheader_tbl(nPos16).value: ',l_header_tbl(nPos16).value );
      xProgress := '2507-70';
      l_header_tbl(nPos17).value := l_remit_to_province;
      ec_debug.pl ( 3, 'lheader_tbl(nPos17).value: ',l_header_tbl(nPos17).value );
      xProgress := '2508-70';
      l_header_tbl(nPos18).value := l_remit_to_country;
      ec_debug.pl ( 3, 'lheader_tbl(nPos18).value: ',l_header_tbl(nPos18).value );
      xProgress := '2509-70';
      l_header_tbl(nPos19).value := l_remit_to_postal_code;
      ec_debug.pl ( 3, 'lheader_tbl(nPos19).value: ',l_header_tbl(nPos19).value );

      -- The following procedure gets the discount information
      -- for the term being used.  The discount info is a sub-table
      -- off of terms, this procedure will get the first three
      -- discounts, this is a denormalization, but is being used
      -- to avoid the overhead of another level of data


      xProgress := '2510-70';
     -- Bug 2389231
      ece_ar_transaction.Get_Term_Discount ( l_header_tbl(nPos3).value,
                                             l_header_tbl(nPos4).value,
                                             l_header_tbl(nPos2).value,
                                             to_date(l_header_tbl(nPos28).value,'YYYYMMDD HH24MISS'),
                                             l_Discount_Percent1,
                                             l_Discount_Days1,
                                             l_Discount_Date1,
                                             l_Discount_Day_Of_Month1,
                                             l_Discount_Months_Forward1,
                                             l_Discount_Percent2,
                                             l_Discount_Days2,
                                             l_Discount_Date2,
                                             l_Discount_Day_Of_Month2,
                                             l_Discount_Months_Forward2,
                                             l_Discount_Percent3,
                                             l_Discount_Days3,
                                             l_Discount_Date3,
                                             l_Discount_Day_Of_Month3,
                                             l_Discount_Months_Forward3 );

      -- The following procedures get the trading partner details for
      -- remit to, ship to and sold to addresses

      xProgress := '2520-70';
      ec_trading_partner_pvt.Get_TP_Location_Code ( p_api_version_number => 1.0,
                                                    p_init_msg_list      => init_msg_list,
                                                    p_simulate           => simulate,
                                                    p_commit             => commt,
                                                    p_validation_level   => validation_level,
                                                    p_return_status      => return_status,
                                                    p_msg_count          => msg_count,
                                                    p_msg_data           => msg_data,
                                                    p_entity_address_id  => l_header_tbl(nPos8).value,
                                                    p_info_type          => ec_trading_partner_pvt.G_CUSTOMER,
                                                    p_location_code_ext  => l_bill_to_code_ext,
                                                    p_reference_ext1     => l_bill_to_tp_reference_ext1,
                                                    p_reference_ext2     => l_bill_to_tp_reference_ext2 );


    /*  xProgress := '2520-70';
      ec_trading_partner_pvt.Get_TP_Location_Code ( p_api_version_number => 1.0,
                                                    p_init_msg_list      => init_msg_list,
                                                    p_simulate           => simulate,
                                                    p_commit             => commt,
                                                    p_validation_level   => validation_level,
                                                    p_return_status      => return_status,
                                                    p_msg_count          => msg_count,
                                                    p_msg_data           => msg_data,
                                                    p_entity_address_id  => l_Remit_To_Address_ID,
                                                    p_info_type          => ec_trading_partner_pvt.G_CUSTOMER,
                                                    p_location_code_ext  => l_remit_to_code_ext,
                                                    p_reference_ext1     => l_remit_to_tp_reference_ext1,
                                                    p_reference_ext2     => l_remit_to_tp_reference_ext2 );

      xProgress := '2530-70';
      ec_trading_partner_pvt.Get_TP_Location_Code ( p_api_version_number => 1.0,
                                                    p_init_msg_list      => init_msg_list,
                                                    p_simulate           => simulate,
                                                    p_commit             => commt,
                                                    p_validation_level   => validation_level,
                                                    p_return_status      => return_status,
                                                    p_msg_count          => msg_count,
                                                    p_msg_data           => msg_data,
                                                    p_entity_address_id  => l_header_tbl(nPos5).value,
                                                    p_info_type          => ec_trading_partner_pvt.G_CUSTOMER,
                                                    p_location_code_ext  => l_ship_to_customer_code_ext,
                                                    p_reference_ext1     => l_ship_to_tp_reference_ext1,
                                                    p_reference_ext2     => l_ship_to_tp_reference_ext2 );

      xProgress := '2540-70';
      ec_trading_partner_pvt.Get_TP_Location_Code ( p_api_version_number => 1.0,
                                                    p_init_msg_list      => init_msg_list,
                                                    p_simulate           => simulate,
                                                    p_commit             => commt,
                                                    p_validation_level   => validation_level,
                                                    p_return_status      => return_status,
                                                    p_msg_count          => msg_count,
                                                    p_msg_data           => msg_data,
                                                    p_entity_address_id  => l_header_tbl(nPos6).value,
                                                    p_info_type          => ec_trading_partner_pvt.G_CUSTOMER,
                                                    p_location_code_ext  => l_sold_to_customer_code_ext,
                                                    p_reference_ext1     => l_sold_to_tp_reference_ext1,
                                                    p_reference_ext2     => l_sold_to_tp_reference_ext2 );
*/
      --  The application specific feedback logic begins here.
      --  The procedure below contains all of the logic necessary
      --  to update the AR base tables.

      xProgress := '2550-70';

      ece_ar_transaction.Update_AR ( l_header_tbl(nPos3).value,
                                     l_header_tbl(nPos1).value,
                                     l_header_tbl(nPos2).value,
                                     l_Multiple_Installments_Flag,
                                     l_Maximum_Installment_Number,
                                     l_last_update_date );

      -- ***********************************
      -- pass the pl/sql table in for xref
      -- ***********************************

      xProgress := '2560-70';
      ec_code_Conversion_pvt.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                              p_init_msg_list      => init_msg_list,
                                                              p_simulate           => simulate,
                                                              p_commit             => commt,
                                                              p_validation_level   => validation_level,
                                                              p_return_status      => return_status,
                                                              p_msg_count          => msg_count,
                                                              p_msg_data           => msg_data,
                                                              p_key_tbl            => l_key_tbl,
                                                              p_tbl                => l_header_tbl );

      -- ******************************************
      --
      --     insert into interface table
      --
      -- ******************************************

      xProgress := '2570-70';
      BEGIN
        SELECT ece_ar_trx_headers_s.nextval
          INTO l_header_fkey
          FROM sys.dual;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_GET_NEXT_SEQ_FAILED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'SEQ',
                        'ECE_AR_TRX_HEADERS_S' );
      END;

      xProgress := '2580-70';
      ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id,
                                                        cTransaction_Type,
                                                        cCommunication_Method,
                                                        cHeader_Interface,
                                                        l_header_tbl,
                                                        l_header_fkey );

      -- Now update the columns values of which have been obtained thru the procedure
      -- calls.

      xProgress := '2590-70';
      UPDATE ece_ar_trx_headers
         SET maximum_installment_number =  l_Maximum_Installment_Number,
             amount_tax_due             =  l_Amount_Tax_Due,
             amount_charges_due         =  l_Amount_Charges_Due,
             amount_freight_due         =  l_Amount_Freight_Due,
             amount_line_items_due      =  l_Amount_Line_Items_Due,
             total_amount_due           =  l_total_amount_due,
             Discount_Percent1          =  l_Discount_Percent1,
             Discount_Days1             =  l_Discount_Days1,
             Discount_Date1             =  l_Discount_Date1,
             Discount_Day_Of_Month1     =  l_Discount_Day_Of_Month1,
             Discount_Months_Forward1   =  l_Discount_Months_Forward1,
             Discount_Percent2          =  l_Discount_Percent2,
             Discount_Days2             =  l_Discount_Days2,
             Discount_Date2             =  l_Discount_Date2,
             Discount_Day_Of_Month2     =  l_Discount_Day_Of_Month2,
             Discount_Months_Forward2   =  l_Discount_Months_Forward2,
             Discount_Percent3          =  l_Discount_Percent3,
             Discount_Days3             =  l_Discount_Days3,
             Discount_Date3             =  l_Discount_Date3,
             Discount_Day_Of_Month3     =  l_Discount_Day_Of_Month3,
             Discount_Months_Forward3   =  l_Discount_Months_Forward3,
             remit_to_code_ext          =  l_remit_to_edi_location_code,   --2386848
             remit_to_code_int          =  l_remit_to_code_int,
            /* ship_to_customer_code_ext  =  l_ship_to_customer_code_ext,  --2386848
             sold_to_customer_code_ext  =  l_sold_to_customer_code_ext, */
             bill_to_customer_code_ext  =  l_header_tbl(nPos7).value,
             bill_to_tp_reference_ext1  =  l_bill_to_tp_reference_ext1,
             bill_to_tp_reference_ext2  =  l_bill_to_tp_reference_ext2,
           /*  ship_to_tp_reference_ext1  =  l_ship_to_tp_reference_ext1,   --2386848
             ship_to_tp_reference_ext2  =  l_ship_to_tp_reference_ext2,
             sold_to_tp_reference_ext1  =  l_sold_to_tp_reference_ext1,
             sold_to_tp_reference_ext2  =  l_sold_to_tp_reference_ext2,
             remit_to_tp_reference_ext1 =  l_remit_to_tp_reference_ext1,
             remit_to_tp_reference_ext2 =  l_remit_to_tp_reference_ext2, */
             tp_document_purpose_code   =  'OR',
             remit_to_customer_name    = l_remit_to_customer_name, --2291130
             bill_to_contact_last_name = l_bill_to_contact_last_name,
             bill_to_contact_first_name = l_bill_to_contact_first_name,
             bill_to_contact_job_title = l_bill_to_contact_job_title,
             ship_to_contact_last_name = l_ship_to_contact_last_name,
             ship_to_contact_first_name = l_ship_to_contact_first_name,
             ship_to_contact_job_title = l_ship_to_contact_job_title,
             sold_to_contact_last_name = l_sold_to_contact_last_name,
             sold_to_contact_first_name = l_sold_to_contact_first_name,
             sold_to_contact_job_title = l_sold_to_contact_job_title
    WHERE transaction_record_id      =  l_header_fkey;

      IF SQL%NOTFOUND
      THEN
        ec_debug.pl ( 0,
                      'EC',
                      'ECE_NO_ROW_UPDATED',
                      'PROGRESS_LEVEL',
                      xProgress,
                      'INFO',
                      'AMOUNT, DISCOUNT AND LOCATIONS',
                      'TABLE_NAME',
                      'ECE_AR_TRX_HEADERS' );
      END IF;

      -- ******************************************
      --
      --     Call custom program stub to populate the extension table
      --
      -- ******************************************

      xProgress := '2600-70';
      ece_ino_x.populate_extension_header ( l_header_fkey, l_header_tbl );

      --  the parameter of this procedure has not been finalized!!
      --  ALL of you has to create this  package in a seperate file
      -- even if it is empty.

      -- ***************************************************
      --
      --    From Header data, we can assign values to
      --    place holders (foreign keys) in Line_select and
      --    Line_detail_Select
      --
      -- ***************************************************
      --    -- set values into binding variables
      --
      -- ***************************************************

      -- use the following bind_variable feature as you see fit.

      xProgress := '2610-70';
      dbms_sql.bind_variable ( Header_1_sel_c,
                               'transaction_id',
                               l_header_tbl(nPos1).value );

      xProgress := '2612-70';
      dbms_sql.bind_variable ( Alw_chg_sel_c,
                               'transaction_id',
                               l_header_tbl(nPos1).value );

      xProgress := '2614-70';
      dbms_sql.bind_variable ( Line_sel_c,
                               'transaction_id',
                               l_header_tbl(nPos1).value );

      xProgress := '2616-70';
      dbms_sql.bind_variable ( Line_t_sel_c,
                               'transaction_id',
                               l_header_tbl(nPos1).value );

      xProgress := '2620-70';
      dummy := dbms_sql.execute( Header_1_sel_c );

      -- ***************************************************
      --
      --   header detail loop starts here
      --
      -- ***************************************************

      /* Header 1 loop begins here */

      xProgress := '2630-70';
      WHILE dbms_sql.fetch_rows ( Header_1_sel_c ) > 0
      LOOP        --- Header Detail

        -- ***************************************************
        --
        --   store values in pl/sql table
        --
        -- ***************************************************

        xProgress := '2640-70';
        FOR l IN 1..iHeader_1_count LOOP
          dbms_sql.column_value ( Header_1_sel_c,
                                  l,
                                  l_header_1_tbl(l).value );

          dbms_sql.column_value ( Header_1_sel_c,
                                  l,
                                  l_key_tbl(l+iHeader_count).value );
        END LOOP;

        -- ***************************************************
        --  pass the pl/sql table in for xref
        -- ***************************************************

        xProgress := '2650-70';
        ece_extract_utils_pub.Find_pos ( l_header_1_tbl,
                                         'PACKING_SLIP_NUMBER',
                                         nPos4 );
        ec_debug.pl ( 3, 'nPos4: ',nPos4 );
        xProgress := '2660-70';
        ece_extract_utils_pub.Find_pos ( l_header_1_tbl,
                                         'SHIP_FROM_CODE_INT',
                                         nPos5 );
        ec_debug.pl ( 3, 'nPos5: ',nPos5 );

        xProgress := '2664-70';
        ece_extract_utils_pub.Find_pos ( l_header_1_tbl,
                                         'INTERFACE_ATTRIBUTE3',
                                         pos_1 );
        ec_debug.pl ( 3, 'pos_1: ',pos_1 );

	xProgress := '2665-70';
        ece_extract_utils_pub.Find_pos ( l_header_1_tbl,
                                         'EQUIPMENT_PREFIX',
                                         nPos8);

        xProgress := '2666-70';
        ece_extract_utils_pub.Find_pos ( l_header_1_tbl,
                                         'EQUIPMENT_NUMBER',
                                         nPos9);
        xProgress := '2667-70';
        ece_extract_utils_pub.Find_pos ( l_header_1_tbl,
                                         'ROUTING_INSTRUCTIONS',
                                         nPos10);

	xProgress := '2667-72';
        ece_extract_utils_pub.Find_pos ( l_header_1_tbl,
                                         'TRANSACTION_ID',
                                         nPos12);

        BEGIN

	FOR rec_header_1 IN c_header_1(l_header_1_tbl(nPos12).value)
	LOOP
	     l_header_1_tbl(nPos8).value := rec_header_1.equipment_prefix;
             l_header_1_tbl(nPos9).value :=  rec_header_1.equipment_number;
	     l_header_1_tbl(nPos10).value := rec_header_1.routing_instructions;
	     l_header_1_tbl(nPos4).value := rec_header_1.packing_slip_number;
	END LOOP;
	EXCEPTION
	WHEN OTHERS THEN
	null;
        END;


        xProgress       := '2668-70';
        l_delivery_name := l_header_1_tbl(pos_1).value;
        ec_debug.pl ( 3, 'l_delivery_name: ',l_delivery_name );

        xProgress := '2670-70';
        IF ( l_delivery_name IS NOT NULL )
        THEN

          BEGIN
            SELECT delivery_id
              INTO l_delivery_id
              FROM wsh_deliveries
             WHERE name = l_delivery_name;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_delivery_id := NULL;
          END;

        ELSE

          l_delivery_id := NULL;

        END IF;

        ec_debug.pl ( 3, 'l_delivery_id: ',l_delivery_id );

        xProgress := '2680-70';
        ec_code_Conversion_pvt.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                                p_init_msg_list      => init_msg_list,
                                                                p_simulate           => simulate,
                                                                p_commit             => commt,
                                                                p_validation_level   => validation_level,
                                                                p_return_status      => return_status,
                                                                p_msg_count          => msg_count,
                                                                p_msg_data           => msg_data,
                                                                p_key_tbl            => l_key_tbl,
                                                                p_tbl                => l_header_1_tbl );

        xProgress := '2690-70';
        BEGIN
          SELECT ece_ar_trx_header_1_s.nextval
            INTO l_header_1_fkey
            FROM sys.dual;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            ec_debug.pl ( 1,
                          'EC',
                          'ECE_GET_NEXT_SEQ_FAILED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'SEQ',
                          'ECE_AR_TRX_HEADERS_1_S' );
        END;
        ec_debug.pl ( 3, 'l_header_1_fkey: ',l_header_1_fkey );

        xProgress := '2700-70';
        ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id,
                                                          cTransaction_Type,
                                                          cCommunication_Method,
                                                          cHeader_1_Interface,
                                                          l_header_1_tbl,
                                                          l_header_1_fkey );

        -- Now update Ship_From_Code_Int, Ship_From_Code_Ext columns on ECE_AR_TRX_HEADERS
        -- using the values obtained the Header 1 Select.

        xProgress := '2710-70';
        ec_debug.pl ( 3, 'l_header_1_tbl(nPos5).value: ',l_header_1_tbl(nPos5).value );
        ec_debug.pl ( 3, 'l_header_1_tbl(nPos5).ext_val1: ',l_header_1_tbl(nPos5).ext_val1 );

 -- Bug 1992730 : Modified the SHIP_FROM_CODE_EXT to SHIP_FROM_CODE_EXT1 in sql below.
 -- Bug 1979725. Also update ship_from_code_ext1..ext5
         UPDATE ECE_AR_TRX_HEADERS
           SET ship_from_code_int         =  l_header_1_tbl(nPos5).value,
               ship_from_code_ext1        =  l_header_1_tbl(nPos5).ext_val1,
               ship_from_code_ext2        =  l_header_1_tbl(nPos5).ext_val2,
               ship_from_code_ext3        =  l_header_1_tbl(nPos5).ext_val3,
               ship_from_code_ext4        =  l_header_1_tbl(nPos5).ext_val4,
               ship_from_code_ext5        =  l_header_1_tbl(nPos5).ext_val5
         WHERE transaction_record_id      =  l_header_fkey;

        IF SQL%NOTFOUND
        THEN
          ec_debug.pl ( 0,
                        'EC',
                        'ECE_NO_ROW_UPDATED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'INFO',
                        'SHIP FROM CODE',
                        'TABLE_NAME',
                        'ECE_AR_TRX_HEADERS' );
        END IF;

        -- ******************************************
        --
        --     Call custom program stub to populate the extension table
        --
        -- ******************************************
        -- BUG 1706520: Modified the following call to populate_extension_header_1.

        xProgress := '2720-70';
        ece_Ino_X.populate_extension_header_1 (l_header_1_fkey, l_header_1_tbl );

     /* Bug 1703536 - closed the end loop to end the header 1 loop */

    END LOOP;
    /* header 1 loop ends here */

       xProgress := '2722-70';
      IF ( dbms_sql.last_row_count = 0 ) THEN
        v_LevelProcessed := 'HEADER 1';
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

        xProgress := '2730-70';
        dummy     := dbms_sql.execute (Alw_chg_sel_c );

        -- ***************************************************
        --
        --   allowance and charges loop starts here
        --
        -- ***************************************************

        xProgress := '2740-70';
        WHILE dbms_sql.fetch_rows (Alw_chg_sel_c ) > 0
        LOOP     --- Allowance and Charges

          -- ***************************************************
          --
          --   store values in pl/sql table
          --
          -- ***************************************************

          xProgress := '2750-70';
          FOR m IN 1..iAlw_chg_count
          LOOP
            dbms_sql.column_value ( Alw_chg_sel_c,
                                    m,
                                    l_alw_chg_tbl(m).value );

            dbms_sql.column_value ( Alw_chg_sel_c,
                                    m,
                                    l_key_tbl(m+iHeader_count).value );
          END LOOP;

          -- ***************************************************
          --  pass the pl/sql table in for xref
          -- ***************************************************

          xProgress := '2760-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'TRANSACTION_ID',
                                           nPos1 );
          ec_debug.pl ( 3, 'nPos1: ',nPos1 );

          xProgress := '2761-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'CUSTOMER_TRX_LINE_ID',
                                           nPos2 );
          ec_debug.pl ( 3, 'nPos2: ',nPos2 );

          xProgress := '2762-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'LINK_TO_CUST_TRX_LINE_ID',
                                           nPos3 );
          ec_debug.pl ( 3, 'nPos3: ',nPos3 );

          xProgress := '2763-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'LINE_NUMBER',
                                           nPos5 );
          ec_debug.pl ( 3, 'nPos5: ',nPos5 );

          xProgress := '2764-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_INDICATOR',
                                           nPos6 );
          ec_debug.pl ( 3, 'nPos6: ',nPos6 );

          xProgress := '2765-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_AMOUNT',
                                           nPos7 );
          ec_debug.pl ( 3, 'nPos7: ',nPos7 );

          xProgress := '2766-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'SPECIAL_SERVICES_CODE',
                                           nPos8 );
          ec_debug.pl ( 3, 'nPos8: ',nPos8 );

          xProgress := '2767-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'METHOD_HANDLING_CODE',
                                           nPos9 );
          ec_debug.pl ( 3, 'nPos9: ',nPos9 );

          xProgress := '2768-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'SPECIAL_CHARGES_CODE',
                                           nPos10 );
          ec_debug.pl ( 3, 'nPos10: ',nPos10 );

          xProgress := '2769-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_DESC',
                                           nPos11 );
          ec_debug.pl ( 3, 'nPos11: ',nPos11 );

          xProgress := '2770-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'AGENCY_QUALIFIER_CODE',
                                           nPos12 );
          ec_debug.pl ( 3, 'nPos12: ',nPos12 );

          xProgress := '2771-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_RATE',
                                           nPos13 );
          ec_debug.pl ( 3, 'nPos13: ',nPos13 );

          xProgress := '2772-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_PCT_QUALIFIER',
                                           nPos14 );
          ec_debug.pl ( 3, 'nPos14: ',nPos14 );

          xProgress := '2773-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_PCT',
                                           nPos15 );
          ec_debug.pl ( 3, 'nPos15: ',nPos15 );

          xProgress := '2774-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_UOM_CODE',
                                           nPos16 );
          ec_debug.pl ( 3, 'nPos16: ',nPos16 );

          xProgress := '2775-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                           'ALLOWANCE_CHARGE_QUANTITY',
                                           nPos17 );
          ec_debug.pl ( 3, 'nPos17: ',nPos17 );

          xProgress := '2776-70';
          ece_extract_utils_pub.Find_pos ( l_alw_chg_tbl,
                                          'HEADER_DETAIL_INDICATOR',
                                          nPos18 );
          ec_debug.pl ( 3, 'nPos18: ',nPos18 );

          --    Check for automotive installation and call the procedure get_allownace_charge.
          --    Both the header and detail level charges are populated here
          --    If the allowances and charges are incorporated as part of the standard product
          --    in future, then modify the code appropriately to exclude check about automotive
          --    installation

          l_data_found := FALSE;

          xProgress := '2780-70';
          IF l_alw_chg_tbl(nPos3).value = 0
          THEN
            l_alw_chg_tbl(nPos18).value := 'H';
            l_alw_chg_tbl(nPos5).value  := 0;
          ELSE
            l_alw_chg_tbl(nPos18).value := 'D';
          END IF;
          ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos18).value: ',l_alw_chg_tbl(nPos18).value );

          xProgress := '2790-70';
          IF l_Automotive_Installed
          THEN
            xProgress    := '2800-70';
     /*       l_data_found := ece_ino_stub.ece_auto_stub ( l_alw_chg_tbl(nPos2).value,
                                                         l_delivery_id,
                                                         l_alw_chg_tbl(nPos18).value,
                                                         l_veh_alw_chg_tbl );*/
          null;
          END IF;

          IF l_data_found
          THEN

            xProgress := '2810-70';
    /*        FOR i IN 0 .. l_veh_alw_chg_tbl.COUNT - 1
            LOOP

              xProgress := '2811-70';
              l_alw_chg_tbl(nPos6).value      := l_veh_alw_chg_tbl(i).charge_type;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos6).value: ',l_alw_chg_tbl(nPos6).value );

              xProgress := '2812-70';
              l_alw_chg_tbl(nPos7).value      := ABS(l_veh_alw_chg_tbl(i).amount);
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos7).value: ',l_alw_chg_tbl(nPos7).value );

              xProgress := '2813-70';
              l_alw_chg_tbl(nPos8).value      := l_veh_alw_chg_tbl(i).special_services_code;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos8).value: ',l_alw_chg_tbl(nPos8).value );

              xProgress := '2814-70';
              l_alw_chg_tbl(nPos9).value      := l_veh_alw_chg_tbl(i).method_handling_code;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos9).value: ',l_alw_chg_tbl(nPos9).value );

              xProgress := '2815-70';
              l_alw_chg_tbl(nPos10).value     := l_veh_alw_chg_tbl(i).special_charge_code;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos10).value: ',l_alw_chg_tbl(nPos10).value );

              xProgress := '2816-70';
              l_alw_chg_tbl(nPos11).value     := l_veh_alw_chg_tbl(i).description;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos11).value: ',l_alw_chg_tbl(nPos11).value );

              xProgress := '2817-70';
              l_alw_chg_tbl(nPos12).value     := l_veh_alw_chg_tbl(i).agency_qualifier_code;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos12).value: ',l_alw_chg_tbl(nPos12).value );

              xProgress := '2818-70';
              l_alw_chg_tbl(nPos13).value     := NVL(l_veh_alw_chg_tbl(i).allowance_charge_rate,0);
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos13).value: ',l_alw_chg_tbl(nPos13).value );

              xProgress := '2819-70';
              l_alw_chg_tbl(nPos14).value     := l_veh_alw_chg_tbl(i).allowance_charge_pct_qualifier;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos14).value: ',l_alw_chg_tbl(nPos14).value );

              xProgress := '2820-70';
              l_alw_chg_tbl(nPos15).value     := NVL(l_veh_alw_chg_tbl(i).allowance_charge_pct,0);
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos15).value: ',l_alw_chg_tbl(nPos15).value );

              xProgress := '2821-70';
              l_alw_chg_tbl(nPos16).value     := l_veh_alw_chg_tbl(i).unit_of_measure_code;
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos16).value: ',l_alw_chg_tbl(nPos16).value );

              xProgress := '2822-70';
              l_alw_chg_tbl(nPos17).value     := NVL(l_veh_alw_chg_tbl(i).quantity,0);
              ec_debug.pl ( 3, 'l_alw_chg_tbl(nPos17).value: ',l_alw_chg_tbl(nPos17).value );

              xProgress := '2830-70';
              ec_code_Conversion_pvt.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                                      p_init_msg_list      => init_msg_list,
                                                                      p_simulate           => simulate,
                                                                      p_commit             => commt,
                                                                      p_validation_level   => validation_level,
                                                                      p_return_status      => return_status,
                                                                      p_msg_count          => msg_count,
                                                                      p_msg_data           => msg_data,
                                                                      p_key_tbl            => l_key_tbl,
                                                                      p_tbl                => l_alw_chg_tbl );

              xProgress := '2840-70';
              BEGIN
                SELECT ece_ar_trx_allowance_charges_s.nextval
                  INTO l_alw_chg_fkey
                  FROM sys.dual;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  ec_debug.pl ( 1,
                                'EC',
                                'ECE_GET_NEXT_SEQ_FAILED',
                                'PROGRESS_LEVEL',
                                xProgress,
                                'SEQ',
                                'ECE_AR_TRX_ALLOWANCE_CHARGES_S' );
              END;
              ec_debug.pl ( 3, 'l_alw_chg_fkey: ',l_alw_chg_fkey );

              xProgress := '2850-70';
              ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id,
                                                                cTransaction_Type,
                                                                cCommunication_Method,
                                                                cAlw_chg_Interface,
                                                                l_alw_chg_tbl,
                                                                l_alw_chg_fkey );


              -- ******************************************
              --
              --     Call custom program stub to populate the extension table
              --
              -- ******************************************
              --   ece_Ino_X.populate_extension_line(l_alw_chg_fkey, l_alw_chg_tbl);

            END LOOP; -- l_veh_alw_chg loop */

          END IF;

        END LOOP;  -- allowence and charges

        xProgress := '2854-70';
        IF ( dbms_sql.last_row_count = 0 ) THEN
          v_LevelProcessed := 'ALLOWANCE CHARGES';
          ec_debug.pl ( 1,
                        'EC',
                        'ECE_NO_DB_ROW_PROCESSED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'LEVEL_PROCESSED',
                        v_LevelProcessed,
                        'TRANSACTION_TYPE',
                        cTransaction_Type);
        END IF;

        --  the parameter of this procedure has not been finalized!!
        --  ALL of you has to create this  package in a seperate file
        -- even if it is empty.

        xProgress := '2860-70';
        dummy := dbms_sql.execute ( Line_sel_c );

        -- ***************************************************
        --
        --   line loop starts here
        --
        -- ***************************************************

        xProgress := '2870-70';
        WHILE dbms_sql.fetch_rows ( Line_sel_c ) > 0
        LOOP        --- Line

          -- ***************************************************
          --
          --   store values in pl/sql table
          --
          -- ***************************************************

          xProgress := '2880-70';
          FOR j IN 1..iLine_count
          LOOP
            dbms_sql.column_value ( Line_sel_c,
                                    j,
                                    l_line_tbl(j).value );

            dbms_sql.column_value ( Line_sel_c,
                                    j,
                                    l_key_tbl(j+iHeader_count).value );
          END LOOP;

          xProgress := '2890-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'ITEM_ID',
                                           nPos1 );
          ec_debug.pl ( 3, 'nPos1: ',nPos1 );

          xProgress := '2891-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'LINE_NUMBER',
                                           nPos9 );
          ec_debug.pl ( 3, 'nPos9: ',nPos9 );

          xProgress := '2900-70';
          ece_inventory.get_item_number ( l_line_tbl(nPos1).value,
                                          l_Organization_ID,
                                          l_line_item_number,
                                          l_line_item_attrib_category,
                                          l_line_item_attribute1,
                                          l_line_item_attribute2,
                                          l_line_item_attribute3,
                                          l_line_item_attribute4,
                                          l_line_item_attribute5,
                                          l_line_item_attribute6,
                                          l_line_item_attribute7,
                                          l_line_item_attribute8,
                                          l_line_item_attribute9,
                                          l_line_item_attribute10,
                                          l_line_item_attribute11,
                                          l_line_item_attribute12,
                                          l_line_item_attribute13,
                                          l_line_item_attribute14,
                                          l_line_item_attribute15 );

          -- ***************************************************
          --  pass the pl/sql table in for xref
          -- ***************************************************

          xProgress := '2910-70';
          ec_code_Conversion_pvt.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                                  p_init_msg_list      => init_msg_list,
                                                                  p_simulate           => simulate,
                                                                  p_commit             => commt,
                                                                  p_validation_level   => validation_level,
                                                                  p_return_status      => return_status,
                                                                  p_msg_count          => msg_count,
                                                                  p_msg_data           => msg_data,
                                                                  p_key_tbl            => l_key_tbl,
                                                                  p_tbl                => l_line_tbl );

          xProgress := '2920-70';
          BEGIN
            SELECT ece_ar_trx_lines_s.nextval
              INTO l_line_fkey
              FROM sys.dual;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ec_debug.pl ( 1,
                            'EC',
                            'ECE_GET_NEXT_SEQ_FAILED',
                            'PROGRESS_LEVEL',
                            xProgress,
                            'SEQ',
                            'ECE_AR_TRX_LINES_S' );
          END;
          ec_debug.pl ( 3, 'l_line_fkey: ',l_line_fkey );

          xProgress := '2930-70';
          ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id,
                                                            cTransaction_Type,
                                                            cCommunication_Method,
                                                            cLine_Interface,
                                                            l_line_tbl,
                                                            l_line_fkey );

          --  Now update the columns values of which have been obtained thru the procedure
          --  calls.

          xProgress := '2940-70';
          UPDATE ece_ar_trx_lines
             SET line_item_number           =  l_line_item_number,
                 line_item_attrib_category  =  l_line_item_attrib_category,
                 line_item_attribute1       =  l_line_item_attribute1,
                 line_item_attribute2       =  l_line_item_attribute2,
                 line_item_attribute3       =  l_line_item_attribute3,
                 line_item_attribute4       =  l_line_item_attribute4,
                 line_item_attribute5       =  l_line_item_attribute5,
                 line_item_attribute6       =  l_line_item_attribute6,
                 line_item_attribute7       =  l_line_item_attribute7,
                 line_item_attribute8       =  l_line_item_attribute8,
                 line_item_attribute9       =  l_line_item_attribute9,
                 line_item_attribute10      =  l_line_item_attribute10,
                 line_item_attribute11      =  l_line_item_attribute11,
                 line_item_attribute12      =  l_line_item_attribute12,
                 line_item_attribute13      =  l_line_item_attribute13,
                 line_item_attribute14      =  l_line_item_attribute14,
                 line_item_attribute15      =  l_line_item_attribute15
           WHERE transaction_record_id      =  l_line_fkey;

          IF SQL%NOTFOUND
          THEN
            ec_debug.pl ( 1,
                         'EC',
                         'ECE_NO_ROW_UPDATED',
                          'PROGRESS_LEVEL',
                          xProgress,
                          'INFO',
                          'LINE ITEM',
                          'TABLE_NAME',
                          'ECE_AR_TRX_LINES' );
          END IF;


          xProgress := '2941-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'NET_WEIGHT',
                                           nPos20 );
          ec_debug.pl ( 3, 'nPos20: ',nPos20);

         xProgress := '2942-70';
         ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'GROSS_WEIGHT',
                                           nPos21 );
          ec_debug.pl ( 3, 'nPos21: ',nPos21);

          xProgress := '2943-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'VOLUME',
                                           nPos23 );
          ec_debug.pl ( 3, 'nPos23: ',nPos23);

          xProgress := '2944-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'WEIGHT_UOM_CODE_INT',
                                           nPos24 );
          ec_debug.pl ( 3, 'nPos24: ',nPos24);

          xProgress := '2945-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'VOLUME_UOM_CODE_INT',
                                           nPos25 );
          ec_debug.pl ( 3, 'nPos25: ',nPos25);

          xProgress := '2946-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'SHIPMENT_NUMBER',
                                           nPos26 );
          ec_debug.pl ( 3, 'nPos26: ',nPos26);

          xProgress := '2947-70';
          ece_extract_utils_pub.Find_pos ( l_line_tbl,
                                           'BOOKING_NUMBER',
                                           nPos27 );
          ec_debug.pl ( 3, 'nPos27: ',nPos27);

        l_net_weight   := nvl(l_line_tbl(nPos20).value,0) + l_net_weight;
        l_gross_weight := nvl(l_line_tbl(nPos21).value,0) + l_gross_weight;
        l_volume       := nvl(l_line_tbl(nPos23).value,0) + l_volume;
        l_weight_uom_code := nvl(l_line_tbl(nPos24).value,null);
        l_volume_uom_code := nvl(l_line_tbl(nPos25).value,null);
        l_shipment_number := nvl(l_line_tbl(nPos26).value,0);
        l_booking_number := nvl(l_line_tbl(nPos27).value,null);

        ec_debug.pl ( 3, 'l_line_tbl(nPos20).value: ',l_line_tbl(nPos20).value );
        ec_debug.pl ( 3, 'l_line_tbl(nPos21).value: ',l_line_tbl(nPos21).value );
        ec_debug.pl ( 3, 'l_line_tbl(nPos23).value: ',l_line_tbl(nPos23).value );
        ec_debug.pl ( 3, 'Net Weight:', l_net_weight);
        ec_debug.pl ( 3, 'Gross Weight:',l_gross_weight);
        ec_debug.pl ( 3, 'Weight UOM Code:',l_weight_uom_code);
        ec_debug.pl ( 3, 'Volume:',l_volume);
        ec_debug.pl ( 3, 'Volume UOM Code:',l_volume_uom_code);
        ec_debug.pl ( 3, 'Shipment Number:',l_shipment_number);
        ec_debug.pl ( 3, 'Booking Number:',l_booking_number);


          -- ******************************************
          --
          --     Call custom program stub to populate the extension table
          --
          -- ******************************************

          xProgress := '2950-70';
          ece_Ino_X.populate_extension_line( l_line_fkey,
                                             l_line_tbl );

          --  the parameter of this procedure has not been finalized!!
          --  ALL of you has to create this  package in a seperate file
          -- even if it is empty.

          -- ***************************************************
          --
          --   set LINE_NUMBER values
          --
          -- ***************************************************

          xProgress := '2960-70';
          dbms_sql.bind_variable (Line_t_sel_c,
                                  'LINE_NUMBER',
                                  l_line_tbl(nPos9).value );

          xProgress := '2970-70';
          dummy := dbms_sql.execute ( Line_t_sel_c );

          -- ***************************************************
          --
          --    line tax loop starts here
          --
          -- ***************************************************

          xProgress := '2980-70';
          WHILE dbms_sql.fetch_rows ( Line_t_sel_c ) > 0
          LOOP       --- Line Tax

            -- ***************************************************
            --
            --    store values in pl/sql table
            --
            -- ***************************************************

            xProgress := '2990-70';
            FOR k IN 1..iLine_t_count
            LOOP
              dbms_sql.column_value ( Line_t_sel_c,
                                      k,
                                      l_line_t_tbl(k).value );

              dbms_sql.column_value ( Line_t_sel_c,
                                      k,
                                      l_key_tbl(k+iHeader_count+iLine_count).value );
            END LOOP;


            xProgress := '3000-70';
            ece_extract_utils_pub.Find_pos ( l_line_t_tbl,
                                             'LINE_TYPE',
                                             nPos1 );
            ec_debug.pl ( 3, 'nPos1: ',nPos1 );

            xProgress := '3002-70';
            ece_extract_utils_pub.Find_pos ( l_line_t_tbl,
                                             'LINK_TO_CUST_TRX_LINE_ID',
                                             nPos2 );
            ec_debug.pl ( 3, 'nPos2: ',nPos2 );

            xProgress := '3004-70';
            ece_extract_utils_pub.Find_pos ( l_line_t_tbl,
                                             'CUSTOMER_TRX_LINE_ID',
                                             nPos3 );
            ec_debug.pl ( 3, 'nPos3: ',nPos3 );

            xProgress := '3006-70';
            ece_extract_utils_pub.Find_pos ( l_line_t_tbl,
                                             'TAX_AMOUNT',
                                             nPos4 );
            ec_debug.pl ( 3, 'nPos4: ',nPos4 );


            xProgress := '3010-70';
            BEGIN
              SELECT ece_ar_trx_line_tax_s.nextval
                INTO l_line_t_fkey
                FROM sys.dual;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                ec_debug.pl ( 1,
                              'EC',
                              'ECE_GET_NEXT_SEQ_FAILED',
                              'PROGRESS_LEVEL',
                              xProgress,
                              'SEQ',
                              'ECE_AR_TRX_LINE_TAX_S' );
            END;

            ec_debug.pl ( 3, 'l_line_t_fkey: ',l_line_t_fkey );

            -- ******************************************
            --     pass the pl/sql table in for xref
            -- ******************************************


            xProgress := '3020-70';
            ec_code_Conversion_pvt.populate_plsql_tbl_with_extval ( p_api_version_number => 1.0,
                                                                    p_init_msg_list      => init_msg_list,
                                                                    p_simulate           => simulate,
                                                                    p_commit             => commt,
                                                                    p_validation_level   => validation_level,
                                                                    p_return_status      => return_status,
                                                                    p_msg_count          => msg_count,
                                                                    p_msg_data           => msg_data,
                                                                    p_key_tbl            => l_key_tbl,
                                                                    p_tbl                => l_line_t_tbl );

            xProgress := '3030-70';
            ece_Extract_Utils_PUB.insert_into_interface_tbl ( iRun_id,
                                                              cTransaction_Type,
                                                              cCommunication_Method,
                                                              cLine_t_Interface,
                                                              l_line_t_tbl,
                                                              l_line_t_fkey );

            -- ******************************************
            --
            --     Call custom program stub to populate the extension table
            --
            -- ******************************************

            xProgress := '3040-70';
            ece_Ino_X.populate_extension_line_tax ( l_line_t_fkey,
                                                    l_line_t_tbl );

          END LOOP;

          xProgress := '3042-70';
          IF ( dbms_sql.last_row_count = 0 )
          THEN
            v_LevelProcessed := 'LINE TAX';
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

        END LOOP;

        xProgress := '3044-70';
        IF ( dbms_sql.last_row_count = 0 )
        THEN
          v_LevelProcessed := 'LINE';
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

      xProgress := '3046-70';
      UPDATE ece_ar_trx_headers
      SET      net_weight        =    l_net_weight,
               gross_weight      =    l_gross_weight,
               volume            =    l_volume,
               weight_uom_code_int   =    l_weight_uom_code,
               volume_uom_code_int   =    l_volume_uom_code,
               booking_number    =    l_booking_number
      WHERE transaction_record_id      =  l_header_fkey;


/* Bug 1979725*  begin*/
/* Copy the value of ext1 to ext5 for
   weight uom code and volume uom code
   from lines to header
*/

        xProgress := '3044-70.1';
begin
select weight_uom_code_ext1,
       weight_uom_code_ext2,
       weight_uom_code_ext3,
       weight_uom_code_ext4,
       weight_uom_code_ext5
into
       l_weight_uom_code_ext1,
       l_weight_uom_code_ext2,
       l_weight_uom_code_ext3,
       l_weight_uom_code_ext4,
       l_weight_uom_code_ext5
from
      ece_ar_trx_lines
where weight_uom_code_int = l_weight_uom_code
and rownum < 2;

exception
when no_data_found then
ec_debug.pl(1,'no data found',xprogress);
when others then
ec_debug.pl(1,xprogress);
end;



        xProgress := '3044-70.2';
begin
select volume_uom_code_ext1,
       volume_uom_code_ext2,
       volume_uom_code_ext3,
       volume_uom_code_ext4,
       volume_uom_code_ext5
into
       l_volume_uom_code_ext1,
       l_volume_uom_code_ext2,
       l_volume_uom_code_ext3,
       l_volume_uom_code_ext4,
       l_volume_uom_code_ext5
from
      ece_ar_trx_lines
where volume_uom_code_int = l_volume_uom_code
and rownum < 2;

exception
when no_data_found then
ec_debug.pl(1,'no data found',xprogress);
when others then
ec_debug.pl(1,xprogress);
end;


        xProgress := '3044-70.3';
begin
update ece_ar_trx_headers
set
volume_uom_code_ext1 = l_volume_uom_code_ext1,
volume_uom_code_ext2 = l_volume_uom_code_ext2,
volume_uom_code_ext3 = l_volume_uom_code_ext3,
volume_uom_code_ext4 = l_volume_uom_code_ext4,
volume_uom_code_ext5 = l_volume_uom_code_ext5,
weight_uom_code_ext1 = l_weight_uom_code_ext1,
weight_uom_code_ext2 = l_weight_uom_code_ext2,
weight_uom_code_ext3 = l_weight_uom_code_ext3,
weight_uom_code_ext4 = l_weight_uom_code_ext4,
weight_uom_code_ext5 = l_weight_uom_code_ext5
where
transaction_record_id      =  l_header_fkey;


exception
when no_data_found then
ec_debug.pl(1,'no data found',xprogress);
when others then
ec_debug.pl(1,xprogress);
end;
/* Bug 1979925 end */


/* Bug 1703536 -Commented the following and was moved to the
** end of the header 1 loop
*/
/*****
      END LOOP;

      xProgress := '3046-70';
      IF ( dbms_sql.last_row_count = 0 ) THEN
        v_LevelProcessed := 'HEADER 1';
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
*****/
    END LOOP;

    xProgress := '3048-70';
    IF ( dbms_sql.last_row_count = 0 ) THEN
      v_LevelProcessed := 'HEADER';
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

    xProgress := '3050-70';
    --   COMMIT;

    xProgress := '3060-70';
    dbms_sql.close_cursor ( Header_sel_c );

    xProgress := '3062-70';
    dbms_sql.close_cursor ( Header_1_sel_c );

    xProgress := '3064-70';
    dbms_sql.close_cursor ( Alw_chg_sel_c );

    xProgress := '3066-70';
    dbms_sql.close_cursor ( Line_sel_c );

    xProgress := '3068-70';
    dbms_sql.close_cursor ( Line_t_sel_c );

    ec_debug.pop ( 'ece_ar_transaction.Populate_AR_Trx' );

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

  END Populate_AR_Trx;

BEGIN

   xProgress := '2000-80';
   oe_profile.get('SO_ORGANIZATION_ID',l_Organization_ID);

   xProgress := '2010-80';
   IF (l_Automotive_Status IS NULL) THEN
      xProgress := '2020-80';
      l_Automotive_Installed := fnd_installation.get_app_info('VEH',l_Status,l_Industry,l_Schema);
      l_Automotive_Status    := l_Status;
      ec_debug.pl(3,'l_Automotive_Status: ',l_Automotive_Status);
   END IF;

  xProgress := '2030-80';
  IF ( l_Automotive_Status = 'I' )
  THEN
    l_Automotive_Installed := TRUE;
  ELSE
    l_Automotive_Installed := FALSE;
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

END ece_ar_transaction;

/
