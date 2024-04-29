--------------------------------------------------------
--  DDL for Package Body ASO_PAYMENT_DATA_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PAYMENT_DATA_MIGRATION_PVT" as
/* $Header: asovpdmb.pls 120.1 2006/07/31 21:06:17 skulkarn noship $ */
-- Start of Comments
-- FILENAME
--    asovmpdb.pls
--
-- DESCRIPTION
--    Package body of Aso_Payment_Data_Migration_Pvt
--
-- PROCEDURE LIST
--    Migrate_Credit_Card_Data
--
-- HISTORY
--    SEPT-07-2005 Initial Creation
--
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'ASO_PAYMENT_DATA_MIGRATION_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovmpdb.pls';


PROCEDURE Migrate_Credit_Card_Data_Mgr
(
   x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY NUMBER,
   X_batch_size  IN NUMBER := 1000,
   X_Num_Workers IN NUMBER  := 5
)
is
l_product   VARCHAR2(30) := 'ASO' ;

Begin
    --***********************************************************
    -- Log concurrent program Output
    --***********************************************************
    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Migrate ASO Credit Card Payment Data to Oracle Payment - Concurrent Program Manager');
    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Batch Size: X_batch_size:         '|| X_batch_size);
    fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Threads: X_Num_Workers: '|| X_Num_Workers);

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('****** Start of Migrate_Credit_Card_Data_Mgr API ******', 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data_Mgr: X_batch_size:  '|| X_batch_size, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data_Mgr: X_Num_Workers: '|| X_Num_Workers, 1, 'Y');
    end if;

    AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf                   => X_errbuf,
               X_retcode                  => X_retcode,
               X_WorkerConc_app_shortname => l_product,
               X_workerConc_progname      => 'ASOCCCONPWKR',
               X_batch_size               => X_batch_size,
               X_Num_Workers              => X_Num_Workers) ;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('****** End of Migrate_Credit_Card_Data_Mgr API ******', 1, 'Y');
    end if;

End Migrate_Credit_Card_Data_Mgr;




PROCEDURE Migrate_Credit_Card_Data_Wkr
(
   x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY NUMBER,
   X_batch_size  IN NUMBER,
   X_Worker_Id   IN NUMBER,
   X_Num_Workers IN NUMBER
)
is

  TYPE  Num15Tab   IS TABLE OF NUMBER(15)    INDEX BY BINARY_INTEGER;
  TYPE  Char1Tab   IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
  TYPE  Char30Tab  IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
  TYPE  Char80Tab  IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
  TYPE  Char100Tab IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  TYPE  Char150Tab IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE  Char255Tab IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  TYPE  DateTab    IS TABLE OF Date          INDEX BY BINARY_INTEGER;

  l_table_owner               VARCHAR2(30);
  l_any_rows_to_process       BOOLEAN;

  l_status                    VARCHAR2(30) ;
  l_industry                  VARCHAR2(30) ;
  l_retstatus                 BOOLEAN ;
  l_product                   VARCHAR2(30) := 'ASO' ;

  l_table_name                VARCHAR2(30) := 'ASO_PAYMENTS';
  l_script_name               VARCHAR2(100) := 'asovpdmb'||to_char(sysdate,'ddmonyyyyhhmiss')||'.pls';

  l_start_rowid               ROWID;
  l_end_rowid                 ROWID;
  l_rows_processed            NUMBER;

  l_index                     NUMBER;
  l_user_id                   NUMBER;

  l_encryption_enabled        BOOLEAN;

  payment_id_tab              Num15Tab;
  payment_ref_number_tab      Char30Tab; -- Changed
  credit_card_code_tab        char80Tab;
  cc_holder_name_tab          Char80Tab;
  cc_expiration_date_tab      Char30Tab;
  order_id_tab                Char100Tab;-- Changed
  trxn_ref_number1_tab        Char100Tab;
  party_id_tab                Num15Tab;
  trxn_extension_id_tab       Num15Tab;
  instrument_id_tab           Num15Tab;
  ext_payer_id_tab            Num15Tab;
  create_payer_flag_tab       Char1Tab;--Changed
  instr_assignment_id_tab     Num15Tab;
  cc_number_hash1_tab         Char30Tab;
  cc_number_hash2_tab         Char30Tab;
  cc_issuer_range_id_tab      Num15Tab;
  sec_segment_id_tab          Num15Tab;

  cc_number_length_tab        Num15Tab;
  cc_unmask_digits_tab        Char30Tab;
  masked_cc_number_tab        Char100Tab;
  cc_org_id                   Num15Tab;
  cc_cust_account_id          Num15Tab;
  cc_cust_account_id          Num15Tab;
  l_error_flag                varchar2(1) := 'N';


/*
   Cursor that queries all transactions needed to be migrated

   Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
            the party contexts that are not in the external payer table can be identified.

         2. The credit card number needs to be numeric.
*/

          cursor encrypted_credit_card_cur(p_start_rowid ROWID, p_end_rowid ROWID) is
          SELECT pmt.payment_id,
                 translate(pmt.payment_ref_number,'0: -_', '0') payment_ref_number,
                 pmt.credit_card_code,
                 pmt.credit_card_holder_name,
                 pmt.credit_card_expiration_date,
                 to_char(pmt.payment_id) ||'-'|| hdr.quote_number, --order_id
                 to_char(hdr.quote_header_id) trxn_ref_number1,
                 nvl(hdr.invoice_to_cust_party_id, hdr.cust_party_id),  --party_id
                 IBY_FNDCPT_TX_EXTENSIONS_S.nextval, --trxn_extension_id
                 IBY_INSTR_S.nextval,
                 DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval, PAYER.EXT_PAYER_ID),
                 DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we should create new external payer
                 IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
                 sec.cc_number_hash1,
                 sec.cc_number_hash2,
                 sec.cc_issuer_range_id,
                 sec.sec_segment_id,
                 sec.cc_number_length,
                 sec.cc_unmask_digits,
                 lpad(sec.cc_unmask_digits, nvl(range.card_number_length, length(pmt.payment_ref_number)), 'X') masked_cc_number

          FROM  aso_payments pmt,
          iby_external_payers_all payer,
          aso_quote_headers_all hdr,
          iby_security_segments sec,
          iby_cc_issuer_ranges range

          WHERE pmt.quote_header_id = hdr.quote_header_id
          and   pmt.payment_type_code = 'CREDIT_CARD'
          and   pmt.payment_ref_number is not null
          and   nvl(hdr.invoice_to_cust_party_id, hdr.cust_party_id) = payer.party_id (+)
          and   payer.cust_account_id is null
          and   payer.acct_site_use_id is null
          and   payer.org_id is null
          --and   'OPERATING_UNIT' = payer.org_type(+)
          and   'CUSTOMER_PAYMENT' = payer.payment_function(+)
          and   pmt.rowid between p_start_rowid and p_end_rowid
          and   pmt.trxn_extension_id is null
          and   sec.sec_segment_id =  IBY_CC_SECURITY_PUB.get_segment_id(pmt.payment_ref_number)
          and   sec.cc_issuer_range_id = range.cc_issuer_range_id (+);



          cursor unencrypted_credit_card_cur(p_start_rowid ROWID, p_end_rowid ROWID) is
          SELECT pmt.payment_id,
                 pmt.payment_ref_number,
                 pmt.credit_card_code,
                 pmt.credit_card_holder_name,
                 pmt.credit_card_expiration_date,
                 to_char(pmt.payment_id) ||'-'|| hdr.quote_number, --order_id
                 to_char(hdr.quote_header_id) trxn_ref_number1,
                 nvl(hdr.invoice_to_cust_party_id, hdr.cust_party_id),  --party_id
                 iby_fndcpt_tx_extensions_s.nextval, --trxn_extension_id
                 iby_instr_s.nextval,
                 decode(payer.ext_payer_id, null, iby_external_payers_all_s.nextval, payer.ext_payer_id),
                 decode(payer.ext_payer_id, null,'Y', 'N'),  -- this flag determines whether we should create new external payer
                 iby_pmt_instr_uses_all_s.nextval,           -- the new instrument use id
                 iby_fndcpt_setup_pub.get_hash(pmt.payment_ref_number, fnd_api.g_false) cc_number_hash1,
                 iby_fndcpt_setup_pub.get_hash(pmt.payment_ref_number, fnd_api.g_true) cc_number_hash2,
                 iby_cc_validate.get_cc_issuer_range(pmt.payment_ref_number) cc_issuer_range_id,
                 --null sec_segment_id,
                 decode(iby_cc_validate.get_cc_issuer_range(pmt.payment_ref_number), null,length(pmt.payment_ref_number), null) cc_number_length,
                 substr(pmt.payment_ref_number,greatest(-4,-length(pmt.payment_ref_number))) cc_unmask_digits,
                 lpad(substr(pmt.payment_ref_number, greatest(-4,-length(pmt.payment_ref_number))), length(pmt.payment_ref_number), 'X' ) masked_cc_number

          FROM  aso_payments pmt,
          iby_external_payers_all payer,
          aso_quote_headers_all hdr

          WHERE pmt.quote_header_id = hdr.quote_header_id
          and   pmt.payment_type_code = 'CREDIT_CARD'
          and   pmt.payment_ref_number is not null
          and   nvl(hdr.invoice_to_cust_party_id, hdr.cust_party_id) = payer.party_id (+)
          and   payer.cust_account_id is null
          and   payer.acct_site_use_id is null
          and   payer.org_id is null
          --and   'OPERATING_UNIT' = payer.org_type(+)
          and   'CUSTOMER_PAYMENT' = payer.payment_function(+)
          and   pmt.rowid between p_start_rowid and p_end_rowid
          and   pmt.trxn_extension_id is null;


Begin
    --***********************************************************
    -- Log concurrent program Output
    --***********************************************************
    fnd_file.put_line(FND_FILE.OUTPUT, 'Modified Program');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Migrate ASO Credit Card Payment Data to Oracle Payment - Concurrent Program');
    fnd_file.put_line(FND_FILE.OUTPUT, '');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
    fnd_file.put_line(FND_FILE.OUTPUT, 'Batch Size        : '|| X_batch_size);
    fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Threads : '|| X_Num_Workers);

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('****** Start of Migrate_Credit_Card_Data API ******', 1, 'Y');
    END IF;

    l_user_id := NVL(fnd_global.user_id, -1);

    if aso_debug_pub.g_debug_flag = 'Y' then
        aso_debug_pub.add('Migrate_Credit_Card_Data: l_user_id:     '|| l_user_id, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: l_table_owner: '|| l_table_owner, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: l_table_name:  '|| l_table_name, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: l_script_name: '|| l_script_name, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: x_worker_id:   '|| x_worker_id, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: x_num_workers: '|| x_num_workers, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: x_batch_size:  '|| x_batch_size, 1, 'Y');
    end if;

    --
    -- get schema name of the table for ROWID range processing
    --
    l_retstatus := fnd_installation.get_app_info(l_product, l_status, l_industry, l_table_owner) ;

    if aso_debug_pub.g_debug_flag = 'Y' then
        --aso_debug_pub.add('Migrate_Credit_Card_Data_Wkr: l_retstatus:   '|| l_retstatus, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data_Wkr: l_table_owner: '|| l_table_owner, 1, 'Y');
    end if;

    ad_parallel_updates_pkg.initialize_rowid_range( ad_parallel_updates_pkg.ROWID_RANGE,
                                                    l_table_owner,
                                                    l_table_name,
                                                    l_script_name,
                                                    x_worker_id,
                                                    x_num_workers,
                                                    x_batch_size,
                                                    0
                                                  );

    ad_parallel_updates_pkg.get_rowid_range( l_start_rowid,
                                             l_end_rowid,
                                             l_any_rows_to_process,
                                             x_batch_size,
                                             TRUE
                                           );

    if aso_debug_pub.g_debug_flag = 'Y' then
        aso_debug_pub.add('Migrate_Credit_Card_Data: l_start_rowid:         '|| l_start_rowid, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: l_end_rowid:           '|| l_end_rowid, 1, 'Y');
        --aso_debug_pub.add('Migrate_Credit_Card_Data: l_any_rows_to_process: '|| l_any_rows_to_process, 1, 'Y');
        aso_debug_pub.add('Migrate_Credit_Card_Data: x_batch_size:          '|| x_batch_size, 1, 'Y');
    end if;

    --Check if 11i cc encryption is enabled or not
    l_encryption_enabled := iby_cc_security_pub.encryption_enabled();

    --if aso_debug_pub.g_debug_flag = 'Y' then
        --aso_debug_pub.add('Migrate_Credit_Card_Data: l_encryption_enabled: '|| l_encryption_enabled, 1, 'Y');
    --end if;


    WHILE (l_any_rows_to_process = TRUE) LOOP


        	IF l_encryption_enabled THEN

	      OPEN encrypted_credit_card_cur(l_start_rowid, l_end_rowid);

           	-- Fetch the transactions
           	FETCH encrypted_credit_card_cur
           	BULK COLLECT INTO payment_id_tab,
                             payment_ref_number_tab,
                             credit_card_code_tab,
                             cc_holder_name_tab,
                             cc_expiration_date_tab,
                             order_id_tab,
                             trxn_ref_number1_tab,
                             party_id_tab,
                             trxn_extension_id_tab,
                             instrument_id_tab,
                             ext_payer_id_tab,
                             create_payer_flag_tab,
                             instr_assignment_id_tab,
                             cc_number_hash1_tab,
                             cc_number_hash2_tab,
                             cc_issuer_range_id_tab,
                             sec_segment_id_tab,
                             cc_number_length_tab,
                             cc_unmask_digits_tab,
                             masked_cc_number_tab;

          	CLOSE encrypted_credit_card_cur;

             aso_debug_pub.add('Before for loop payment_id_tab.count: '|| payment_id_tab.count );
             fnd_file.put_line(FND_FILE.OUTPUT, 'Before for loop payment_id_tab.count: '|| payment_id_tab.count );

          IF payment_id_tab.count > 0 THEN

             FOR i in  payment_id_tab.first..payment_id_tab.last LOOP

               if aso_debug_pub.g_debug_flag = 'Y' then
                   -- new debug messages
                  aso_debug_pub.add('******************************************');
                  aso_debug_pub.add('payment_id_tab('||i||'): '|| payment_id_tab(i) );
                  aso_debug_pub.add('payment_ref_number_tab('||i||'): '|| payment_ref_number_tab(i) );
                  aso_debug_pub.add('credit_card_code_tab('||i||'): '|| credit_card_code_tab(i) );
                  aso_debug_pub.add('cc_expiration_date_tab('||i||') '|| cc_expiration_date_tab(i) );
                  aso_debug_pub.add('cc_holder_name_tab('||i||'): '|| cc_holder_name_tab(i) );
                  aso_debug_pub.add('cc_expiration_date_tab('||i||'): '|| cc_expiration_date_tab(i) );
                  aso_debug_pub.add('order_id_tab('||i||'): '|| order_id_tab(i) );
                  aso_debug_pub.add('trxn_ref_number1_tab('||i||'): '|| trxn_ref_number1_tab(i) );
                  aso_debug_pub.add('party_id_tab('||i||'): '|| party_id_tab(i) );
                  aso_debug_pub.add('trxn_extension_id_tab('||i||'): '|| trxn_extension_id_tab(i) );
                  aso_debug_pub.add('instrument_id_tab('||i||'): '|| instrument_id_tab(i));
                  aso_debug_pub.add('create_payer_flag_tab('||i||'): '|| create_payer_flag_tab(i) );
                  aso_debug_pub.add('instr_assignment_id_tab: '|| instr_assignment_id_tab(i) );
                  aso_debug_pub.add('cc_number_hash1_tab('||i||'): '|| cc_number_hash1_tab(i) );
                  aso_debug_pub.add('cc_number_hash2_tab('||i||'): '|| cc_number_hash2_tab(i) );
                  aso_debug_pub.add('cc_issuer_range_id_tab('||i||'): '|| cc_issuer_range_id_tab(i) );
                  aso_debug_pub.add('sec_segment_id_tab('||i||'): '|| sec_segment_id_tab(i) );
                  aso_debug_pub.add('cc_number_length_tab('||i||'): '|| cc_number_length_tab(i) );
                  aso_debug_pub.add('cc_unmask_digits_tab('||i||'): '|| cc_unmask_digits_tab(i) );
                  aso_debug_pub.add('masked_cc_number_tab('||i||'): '|| masked_cc_number_tab(i) );

                  aso_debug_pub.add('******************************************');
                END IF;
              END LOOP;
             if aso_debug_pub.g_debug_flag = 'Y' then
              aso_debug_pub.add('After for loop payment_id_tab.count: '|| payment_id_tab.count );
             end if;


        BEGIN -- begin1

             fnd_file.put_line(FND_FILE.OUTPUT, 'Before insering into table IBY_CREDITCARD');

             -- create new credit cards with single use only
             FORALL i IN payment_id_tab.first..payment_id_tab.last SAVE EXCEPTIONS

                 INSERT INTO IBY_CREDITCARD( CARD_OWNER_ID,
                                             INSTRUMENT_TYPE,
                                             PURCHASECARD_FLAG,
                                             CARD_ISSUER_CODE,
                                             ACTIVE_FLAG,
                                             SINGLE_USE_FLAG,
                                             EXPIRYDATE,
                                             CHNAME,
                                             CCNUMBER,
                                             INSTRID,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN,
                                             ENCRYPTED,
                                             CC_NUMBER_HASH1,
                                             CC_NUMBER_HASH2,
                                             CC_ISSUER_RANGE_ID,
                                             --SEC_SEGMENT_ID_TAB, --getting expression is of wrong type error, so commenting out, but needs to verify it latter on
                                             CARD_MASK_SETTING,
                                             CARD_UNMASK_LENGTH,
                                             CC_NUMBER_LENGTH,
                                             MASKED_CC_NUMBER,
                                             --SEC_SUBKEY_ID,
                                             OBJECT_VERSION_NUMBER
                                           )
                 VALUES ( party_id_tab(i),
                          'CREDITCARD',
                          'N',
                          credit_card_code_tab(i),
                          'Y',
                          'Y',
                          cc_expiration_date_tab(i),
                          cc_holder_name_tab(i),
                          decode(sec_segment_id_tab(i), null,payment_ref_number_tab(i), cc_unmask_digits_tab(i)),
                          instrument_id_tab(i),
                          l_user_id,
                          sysdate,
                          l_user_id,
                          sysdate,
                          l_user_id,
					      decode(SEC_SEGMENT_ID_TAB(i),null,'N','Y'),
                          cc_number_hash1_tab(i),
                          cc_number_hash2_tab(i),
                          cc_issuer_range_id_tab(i),
                          --sec_segment_id_tab(i),--getting expression is of wrong type error, so commenting out, but needs to verify it latter on
                          'DISPLAY_LAST',
                          4,
                          cc_number_length_tab(i),
                          masked_cc_number_tab(i),
                          1
                        );
             fnd_file.put_line(FND_FILE.OUTPUT, 'After insering into table IBY_CREDITCARD');

       EXCEPTION

                    WHEN OTHERS THEN
                        l_error_flag := 'Y';

                         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Error occurred during iteration ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                                               ' Oracle error is ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_CREDITCARD for Payment ID ' || payment_id_tab(j));
                         END LOOP;

        END; --end begin1


        -- Now insert into the instrument use table
        BEGIN  -- begin2
             fnd_file.put_line(FND_FILE.OUTPUT, 'Before insering into table IBY_PMT_INSTR_USES_ALL ');

	        FORALL i IN payment_id_tab.first .. payment_id_tab.last SAVE EXCEPTIONS

                 INSERT INTO  IBY_PMT_INSTR_USES_ALL( INSTRUMENT_PAYMENT_USE_ID,
                                                      EXT_PMT_PARTY_ID,
                                                      INSTRUMENT_TYPE,
                                                      INSTRUMENT_ID,
                                                      PAYMENT_FUNCTION,
                                                      ORDER_OF_PREFERENCE,
                                                      START_DATE,
                                                      CREATED_BY,
                                                      CREATION_DATE,
                                                      LAST_UPDATED_BY,
                                                      LAST_UPDATE_DATE,
                                                      LAST_UPDATE_LOGIN,
                                                      OBJECT_VERSION_NUMBER,
                                                      payment_flow
                                                    )

	            SELECT instr_assignment_id_tab(i),
                        ext_payer_id_tab(i),
                        'CREDITCARD',
                        instrument_id_tab(i),
                        'CUSTOMER_PAYMENT',
                        1,
                        sysdate,
                        l_user_id,
                        sysdate,
                        l_user_id,
                        sysdate,
                        l_user_id,
                        1,
                        'FUNDS_CAPTURE'

	            FROM IBY_EXTERNAL_PAYERS_ALL

	            -- Note: For products that do not use all the party context columns, it is mandatory to
                 --       add NOT NULL clause for those columns.

	            WHERE payment_function = 'CUSTOMER_PAYMENT'
	            and   party_id = party_id_tab(i)
	            and   org_type is  null
	            and   org_id is null
	            and   cust_account_id is null
	            and   acct_site_use_id is null
	            and   rownum = 1;


             fnd_file.put_line(FND_FILE.OUTPUT, 'After insering into table IBY_PMT_INSTR_USES_ALL ');

        EXCEPTION

                    WHEN OTHERS THEN
                        l_error_flag := 'Y';

                         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Error occurred during iteration ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX || ' Oracle error is ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_PMT_INSTR_USES_ALL for Payment Id: ' || payment_id_tab(j));
                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_PMT_INSTR_USES_ALL for Instrument Assignment Id: ' || instr_assignment_id_tab(j));
                         END LOOP;

        END; --end2

        -- insert the transactions into IBY transaction extension table

        BEGIN  --begin3

             fnd_file.put_line(FND_FILE.OUTPUT, 'Before insering into table IBY_FNDCPT_TX_EXTENSIONS');

	        FORALL i IN payment_id_tab.first .. payment_id_tab.last SAVE EXCEPTIONS

                 INSERT INTO  IBY_FNDCPT_TX_EXTENSIONS( TRXN_EXTENSION_ID,
                                                        PAYMENT_CHANNEL_CODE,
                                                        INSTR_ASSIGNMENT_ID,
                                                        ORDER_ID,
                                                        PO_NUMBER,
                                                        TRXN_REF_NUMBER1,
                                                        TRXN_REF_NUMBER2,
                                                        ADDITIONAL_INFO,
                                                        TANGIBLEID,
	                                                   CREATED_BY,
	                                                   CREATION_DATE,
	                                                   LAST_UPDATED_BY,
	                                                   LAST_UPDATE_DATE,
	                                                   LAST_UPDATE_LOGIN,
	                                                   OBJECT_VERSION_NUMBER,
                                                         encrypted,
                                                         origin_application_id
											 )

                 VALUES( trxn_extension_id_tab(i),
                         'CREDIT_CARD',
                         instr_assignment_id_tab(i),
                         order_id_tab(i),
                         null,
                         trxn_ref_number1_tab(i),
                         null,
                         null,
                         null,
                         l_user_id,
                         sysdate,
                         l_user_id,
                         sysdate,
                         l_user_id,
                         1,
                         'Y',
                         679
                       );

             fnd_file.put_line(FND_FILE.OUTPUT, 'After insering into table IBY_FNDCPT_TX_EXTENSIONS');

        EXCEPTION

                    WHEN OTHERS THEN
                        l_error_flag := 'Y';

                         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Error occurred during iteration ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX || ' Oracle error is ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_PMT_INSTR_USES_ALL for trxn_ref_number1_tab(j): ' || trxn_ref_number1_tab(j));
                         END LOOP;

        END; --end3

       END IF; -- END IF FOR THE payment_id_tab.count

     ELSE  ---l_encryption_enabled is false

             fnd_file.put_line(FND_FILE.OUTPUT, 'l_encryption_enabled is false');


           OPEN unencrypted_credit_card_cur(l_start_rowid, l_end_rowid);
           -- Fetch the transactions
           FETCH unencrypted_credit_card_cur
           BULK COLLECT INTO payment_id_tab,
                             payment_ref_number_tab,
                             credit_card_code_tab,
                             cc_holder_name_tab,
                             cc_expiration_date_tab,
                             order_id_tab,
                             trxn_ref_number1_tab,
                             party_id_tab,
                             trxn_extension_id_tab,
                             instrument_id_tab,
                             ext_payer_id_tab,
                             create_payer_flag_tab,
                             instr_assignment_id_tab,
                             cc_number_hash1_tab,
                             cc_number_hash2_tab,
                             cc_issuer_range_id_tab,
                             --sec_segment_id_tab,
                             cc_number_length_tab,
                             cc_unmask_digits_tab,
                             masked_cc_number_tab;

         CLOSE unencrypted_credit_card_cur;

         aso_debug_pub.add('Before for loop payment_id_tab.count: '|| payment_id_tab.count );
         fnd_file.put_line(FND_FILE.OUTPUT, 'Before for loop payment_id_tab.count: '|| payment_id_tab.count );

        IF payment_id_tab.count > 0 THEN

        FOR i in  payment_id_tab.first..payment_id_tab.last LOOP

               if aso_debug_pub.g_debug_flag = 'Y' then
                   -- new debug messages
                  aso_debug_pub.add('******************************************');
                  aso_debug_pub.add('payment_id_tab('||i||'): '|| payment_id_tab(i) );
                  aso_debug_pub.add('payment_ref_number_tab('||i||'): '|| payment_ref_number_tab(i) );
                  aso_debug_pub.add('credit_card_code_tab('||i||'): '|| credit_card_code_tab(i) );
                  aso_debug_pub.add('cc_holder_name_tab('||i||'): '|| cc_holder_name_tab(i) );
                  aso_debug_pub.add('cc_expiration_date_tab('||i||') '|| cc_expiration_date_tab(i) );
                  aso_debug_pub.add('order_id_tab('||i||'): '|| order_id_tab(i) );
                  aso_debug_pub.add('trxn_ref_number1_tab('||i||'): '|| trxn_ref_number1_tab(i) );
                  aso_debug_pub.add('party_id_tab('||i||'): '|| party_id_tab(i) );
                  aso_debug_pub.add('trxn_extension_id_tab('||i||'): '|| trxn_extension_id_tab(i) );
                  aso_debug_pub.add('instrument_id_tab('||i||'): '|| instrument_id_tab(i));
                  aso_debug_pub.add('ext_payer_id_tab('||i||'): '|| ext_payer_id_tab(i));
                  aso_debug_pub.add('create_payer_flag_tab('||i||'): '|| create_payer_flag_tab(i) );
                  aso_debug_pub.add('instr_assignment_id_tab: '|| instr_assignment_id_tab(i) );
                  aso_debug_pub.add('cc_number_hash1_tab('||i||'): '|| cc_number_hash1_tab(i) );
                  aso_debug_pub.add('cc_number_hash2_tab('||i||'): '|| cc_number_hash2_tab(i) );
                  aso_debug_pub.add('cc_issuer_range_id_tab('||i||'): '|| cc_issuer_range_id_tab(i) );
                  --aso_debug_pub.add('sec_segment_id_tab('||i||'): '|| sec_segment_id_tab(i) );
                  aso_debug_pub.add('cc_number_length_tab('||i||'): '|| cc_number_length_tab(i) );
                  aso_debug_pub.add('cc_unmask_digits_tab('||i||'): '|| cc_unmask_digits_tab(i) );
                  aso_debug_pub.add('masked_cc_number_tab('||i||'): '|| masked_cc_number_tab(i) );
                  aso_debug_pub.add('******************************************');
                END IF;
              END LOOP;

           BEGIN  --begin4
             -- create new credit cards with single use only

             fnd_file.put_line(FND_FILE.OUTPUT, 'Before insering into table IBY_CREDITCARD');

             FORALL i IN payment_id_tab.first..payment_id_tab.last SAVE EXCEPTIONS

                 INSERT INTO IBY_CREDITCARD( CARD_OWNER_ID,
                                             INSTRUMENT_TYPE,
                                             PURCHASECARD_FLAG,
                                             CARD_ISSUER_CODE,
                                             ACTIVE_FLAG,
                                             SINGLE_USE_FLAG,
                                             EXPIRYDATE,
                                             CHNAME,
                                             CCNUMBER,
                                             INSTRID,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN,
                                             ENCRYPTED,
                                             CC_NUMBER_HASH1,
                                             CC_NUMBER_HASH2,
                                             CC_ISSUER_RANGE_ID,
                                             --SEC_SEGMENT_ID_TAB,
                                             CARD_MASK_SETTING,
                                             CARD_UNMASK_LENGTH,
                                             CC_NUMBER_LENGTH,
                                             MASKED_CC_NUMBER,
                                             --SEC_SUBKEY_ID,
                                             OBJECT_VERSION_NUMBER
                                           )
                 VALUES ( party_id_tab(i),
                          'CREDITCARD',
                          'N',
                          credit_card_code_tab(i),
                          'Y',
                          'Y',
                          cc_expiration_date_tab(i),
                          cc_holder_name_tab(i),
                          --decode(sec_segment_id_tab(i), null,payment_ref_number_tab(i), cc_unmask_digits_tab(i)),
                          payment_ref_number_tab(i),
                          instrument_id_tab(i),
                          l_user_id,
                          sysdate,
                          l_user_id,
                          sysdate,
                          l_user_id,
					 --decode(SEC_SEGMENT_ID_TAB(i), NULL,'N','Y'),
					 'N',
                          cc_number_hash1_tab(i),
                          cc_number_hash2_tab(i),
                          cc_issuer_range_id_tab(i),
                          --sec_segment_id_tab(i),
                          'DISPLAY_LAST',
                          4,
                          cc_number_length_tab(i),
                          masked_cc_number_tab(i),
                          1
                        );

             fnd_file.put_line(FND_FILE.OUTPUT, 'After insering into table IBY_CREDITCARD');

	   EXCEPTION

                    WHEN OTHERS THEN
                        l_error_flag := 'Y';

                         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Error occurred during iteration ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                                               ' Oracle error is ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_CREDITCARD for Payment ID ' || payment_id_tab(j));
                         END LOOP;

        END;  --end4


        -- Now insert into the instrument use table
        BEGIN  --begin5

             fnd_file.put_line(FND_FILE.OUTPUT, 'Before insering into table IBY_PMT_INSTR_USES_ALL');

	        FORALL i IN payment_id_tab.first .. payment_id_tab.last SAVE EXCEPTIONS

                 INSERT INTO  IBY_PMT_INSTR_USES_ALL( INSTRUMENT_PAYMENT_USE_ID,
                                                      EXT_PMT_PARTY_ID,
                                                      INSTRUMENT_TYPE,
                                                      INSTRUMENT_ID,
                                                      PAYMENT_FUNCTION,
                                                      ORDER_OF_PREFERENCE,
                                                      START_DATE,
                                                      CREATED_BY,
                                                      CREATION_DATE,
                                                      LAST_UPDATED_BY,
                                                      LAST_UPDATE_DATE,
                                                      LAST_UPDATE_LOGIN,
                                                      OBJECT_VERSION_NUMBER,
                                                      payment_flow
                                                    )

	            SELECT instr_assignment_id_tab(i),
                        ext_payer_id_tab(i),
                        'CREDITCARD',
                        instrument_id_tab(i),
                        'CUSTOMER_PAYMENT',
                        1,
                        sysdate,
                        l_user_id,
                        sysdate,
                        l_user_id,
                        sysdate,
                        l_user_id,
                        1,
                        'FUNDS_CAPTURE'

	            FROM IBY_EXTERNAL_PAYERS_ALL

	            -- Note: For products that do not use all the party context columns, it is mandatory to
                 --       add NOT NULL clause for those columns.

	            WHERE payment_function = 'CUSTOMER_PAYMENT'
	            and   party_id = party_id_tab(i)
	            and   org_type is  null
	            and   org_id is null
	            and   cust_account_id is null
	            and   acct_site_use_id is null
	            and   rownum = 1;

             fnd_file.put_line(FND_FILE.OUTPUT, 'After insering into table IBY_PMT_INSTR_USES_ALL');

         EXCEPTION

                    WHEN OTHERS THEN
                        l_error_flag := 'Y';

                         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Error occurred during iteration ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX || ' Oracle error is ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_PMT_INSTR_USES_ALL for Payment Id: ' || payment_id_tab(j));
                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_PMT_INSTR_USES_ALL for Instrument Assignment Id: ' || instr_assignment_id_tab(j));
                         END LOOP;

        END; --end5


        -- insert the transactions into IBY transaction extension table

        BEGIN -- begin6

             fnd_file.put_line(FND_FILE.OUTPUT, 'Before insering into table IBY_FNDCPT_TX_EXTENSIONS');

	        FORALL i IN payment_id_tab.first .. payment_id_tab.last SAVE EXCEPTIONS

                 INSERT INTO  IBY_FNDCPT_TX_EXTENSIONS( TRXN_EXTENSION_ID,
                                                        PAYMENT_CHANNEL_CODE,
                                                        INSTR_ASSIGNMENT_ID,
                                                        ORDER_ID,
                                                        PO_NUMBER,
                                                        TRXN_REF_NUMBER1,
                                                        TRXN_REF_NUMBER2,
                                                        ADDITIONAL_INFO,
                                                        TANGIBLEID,
	                                                   CREATED_BY,
	                                                   CREATION_DATE,
	                                                   LAST_UPDATED_BY,
	                                                   LAST_UPDATE_DATE,
	                                                   LAST_UPDATE_LOGIN,
	                                                   OBJECT_VERSION_NUMBER,
                                                         encrypted,
                                                         origin_application_id
											 )

                 VALUES( trxn_extension_id_tab(i),
                         'CREDIT_CARD',
                         instr_assignment_id_tab(i),
                         order_id_tab(i),
                         null,
                         trxn_ref_number1_tab(i),
                         null,
                         null,
                         null,
                         l_user_id,
                         sysdate,
                         l_user_id,
                         sysdate,
                         l_user_id,
                         1,
                         'Y',
                         679
                       );

             fnd_file.put_line(FND_FILE.OUTPUT, 'After insering into table IBY_FNDCPT_TX_EXTENSIONS');

        EXCEPTION

                    WHEN OTHERS THEN
                        l_error_flag := 'Y';

                         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Error occurred during iteration ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX || ' Oracle error is ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Insert failing at IBY_PMT_INSTR_USES_ALL for trxn_ref_number1_tab(j): ' || trxn_ref_number1_tab(j));
                         END LOOP;

        END; --end6
    END IF; -- for payment table count
   END IF; ---end if for  l_encryption_enabled



        -- update the foreign key relationship

    BEGIN -- begin7

          IF  (l_error_flag = 'N' and payment_id_tab.count > 0 ) THEN

             fnd_file.put_line(FND_FILE.OUTPUT, 'Before updating the aso_payments table');

             FORALL i IN payment_id_tab.first..payment_id_tab.last SAVE EXCEPTIONS

                 UPDATE aso_payments a
                 SET    a.TRXN_EXTENSION_ID = TRXN_EXTENSION_ID_TAB(i),
			         a.CREDIT_CARD_APPROVAL_CODE = NULL,
				    a.CREDIT_CARD_APPROVAL_DATE = NULL,
				    a.CREDIT_CARD_CODE = NULL,
				    a.CREDIT_CARD_EXPIRATION_DATE = NULL,
				    a.CREDIT_CARD_HOLDER_NAME = NULL,
				    a.PAYMENT_REF_NUMBER = NULL
                 WHERE  a.payment_id = payment_id_tab(i);

             fnd_file.put_line(FND_FILE.OUTPUT, 'After updating the aso_payments table');

          ELSE
                IF  payment_id_tab.count = 0 THEN
                 fnd_file.put_line(FND_FILE.OUTPUT,'No payment tbl records to update');
                elsif  l_error_flag = 'Y' then
                 fnd_file.put_line(FND_FILE.OUTPUT,'Did not update aso_payments table because of errors');
                end if;
          END IF;


    EXCEPTION

                    WHEN OTHERS THEN

                         FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Error occurred during iteration ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX || ' Oracle error is ' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE );

                             fnd_file.put_line(FND_FILE.OUTPUT, 'Update failing at asopayments for payment_id_tab(j): ' || payment_id_tab(j));
                         END LOOP;

                 --l_rows_processed := SQL%ROWCOUNT;

               --  ad_parallel_updates_pkg.processed_rowid_range( l_rows_processed, l_end_rowid);
    END;
 --end7

       l_rows_processed := SQL%ROWCOUNT;
       ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_end_rowid);

 IF  (l_error_flag = 'N') THEN
    COMMIT;
    fnd_file.put_line(FND_FILE.OUTPUT, '*** Commiting the changes ****** ');
 END IF;
        --
        -- get new range of rowids
        --

        ad_parallel_updates_pkg.get_rowid_range( l_start_rowid,
                                                 l_end_rowid,
                                                 l_any_rows_to_process,
                                                 x_batch_size,
                                                 FALSE
									  );



    END LOOP; -- loop for l_any_rows_to_process


    X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;


  -- handle any exception if necessary

    EXCEPTION
      WHEN OTHERS THEN
       aso_debug_pub.add('Inside Exception',1,'Y' );
       fnd_file.put_line(FND_FILE.OUTPUT, 'Inside the outermost exception block');
       X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
       raise;
End Migrate_Credit_Card_Data_Wkr;


END Aso_Payment_Data_Migration_Pvt;

/
