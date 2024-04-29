--------------------------------------------------------
--  DDL for Package Body IBY_TRANSACTIONCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TRANSACTIONCC_PKG" AS
/*$Header: ibytxccb.pls 120.59.12010000.22 2010/03/29 07:42:18 sugottum ship $*/

  --
  -- Declare global variables
  --
  G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_TRANSACTIONCC_PKG';
  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_TRANSACTIONCC_PKG';

  --
  -- USE: Validates the current open batch for the given (payee,bep,bep key)
  --      combination.  This involves making sure: 1) the batch contains
  --      at least one trxn, 2) a payee security key is present if the
  --      batch contains encrypted trxns, 3) the batch contains trxns of
  --      only a single currency
  --
  PROCEDURE validate_open_batch
  (
  p_bep_id           IN     iby_trxn_summaries_all.bepid%TYPE,
  p_mbatch_id        IN     iby_batches_all.mbatchid%TYPE,
  p_sec_key_on       IN     VARCHAR2,
  x_trxn_count       OUT NOCOPY iby_batches_all.numtrxns%TYPE,
  x_batch_currency   OUT NOCOPY iby_batches_all.currencynamecode%TYPE
  )
  IS
    l_sec_trxn_count     NUMBER;
    l_batch_currency     iby_trxn_summaries_all.currencynamecode%TYPE;

    l_call_string        VARCHAR2(1000);
    l_call_params        JTF_VARCHAR2_TABLE_200 := JTF_VARCHAR2_TABLE_200();
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(5000);

    CURSOR c_currencycodes(ci_mbatch_id IN iby_batches_all.mbatchid%TYPE)
    IS
      SELECT ts.currencynamecode
        FROM iby_batches_all ba, iby_trxn_summaries_all ts
        WHERE (ba.mbatchid = ci_mbatch_id)
          AND (ba.payeeid = ts.payeeid)
          AND (ba.batchid = ts.batchid)
        GROUP BY ts.currencynamecode;

    CURSOR c_valsets(ci_bep_id iby_trxn_summaries_all.bepid%TYPE)
    IS
      SELECT validation_code_package, validation_code_entry_point
      FROM iby_validation_sets_b vs, iby_fndcpt_sys_cc_pf_b pf,
        iby_val_assignments va
      WHERE (vs.validation_code_language = 'PLSQL')
        AND (vs.validation_level_code = 'INSTRUCTION' )
        AND (pf.payment_system_id = ci_bep_id)
        AND (pf.settlement_format_code = va.assignment_entity_id)
        AND (va.val_assignment_entity_type = 'FORMAT')
        AND (va.validation_set_code = vs.validation_set_code)
        AND (NVL(va.inactive_date,SYSDATE-100) < SYSDATE);

  BEGIN

    IF (c_currencycodes%ISOPEN) THEN
      CLOSE c_currencycodes;
    END IF;

    --
    -- first check if any encrypted trxns exist in the batch;
    -- if so, then the security key must be present for the batch
    -- close to continue
    --
    SELECT COUNT(transactionid)
      INTO l_sec_trxn_count
      FROM iby_batches_all ba, iby_trxn_summaries_all ts
      WHERE (ba.mbatchid = p_mbatch_id)
        AND (ba.payeeid = ts.payeeid)
        AND (ba.batchid = ts.batchid)
        AND (NOT sub_key_id IS NULL);

     IF ( (l_sec_trxn_count>0) AND
          (p_sec_key_on<>iby_utility_pvt.C_API_YES) ) THEN
       raise_application_error(-20000,'IBY_10002',FALSE);
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('validate_ob', 'p_mbatch_id = ' || p_mbatch_id);

     END IF;
    SELECT COUNT(transactionid)
      INTO x_trxn_count
      FROM iby_batches_all ba, iby_trxn_summaries_all ts
      WHERE (ba.mbatchid = p_mbatch_id)
        AND (ba.payeeid = ts.payeeid)
        AND (ba.batchid = ts.batchid);
     --
     -- batch cannot be empty
     --
     IF (x_trxn_count<1) THEN
       raise_application_error(-20000,'IBY_50314',FALSE);
     END IF;
/* Multiple currencies may be allowed in the same batch*/
--     OPEN c_currencycodes(p_mbatch_id);

--     FETCH c_currencycodes INTO x_batch_currency;
--     FETCH c_currencycodes INTO l_batch_currency;
     --
     -- 2nd successful fetch indicates multiple currencies are in the batch
     --
--     IF (NOT c_currencycodes%NOTFOUND) THEN
--       CLOSE c_currencycodes;
--       raise_application_error(-20000,'IBY_20213',FALSE);
--     ELSE
--       CLOSE c_currencycodes;
--     END IF;

     -- perform payment format specific validations
     --
     l_call_params.extend(6);
     l_call_params(1) := '1';
     l_call_params(2) := '''' || FND_API.G_TRUE || '''';
     l_call_params(3) := TO_CHAR(p_mbatch_id);
     l_call_params(4) := '';
     l_call_params(5) := '';
     l_call_params(6) := '';

     FOR cp IN c_valsets(p_bep_id) LOOP
       l_call_string :=
         iby_utility_pvt.get_call_exec(cp.validation_code_package,
                                       cp.validation_code_entry_point,
                                       l_call_params);
       EXECUTE IMMEDIATE l_call_string USING
         OUT l_return_status,
         OUT l_msg_count,
         OUT l_msg_data;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise_application_error(-20000,
            'IBY_20220#ERRMSG=' || fnd_msg_pub.get(p_msg_index => 1,p_encoded => FND_API.G_FALSE),
            FALSE);
       END IF;
     END LOOP;

  END validate_open_batch;

  PROCEDURE prepare_instr_data
  (p_commit   IN  VARCHAR2,
   p_sys_key  IN  iby_security_pkg.DES3_KEY_TYPE,
   p_instrnum IN  iby_trxn_summaries_all.instrnumber%TYPE,
   p_instrtype IN  iby_trxn_summaries_all.instrtype%TYPE,
   x_instrnum OUT NOCOPY iby_trxn_summaries_all.instrnumber%TYPE,
   x_instr_subtype OUT NOCOPY iby_trxn_summaries_all.instrsubtype%TYPE,
   x_instr_hash    OUT NOCOPY iby_trxn_summaries_all.instrnum_hash%TYPE,
   x_range_id OUT NOCOPY iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE,
   x_instr_len OUT NOCOPY iby_trxn_summaries_all.instrnum_length%TYPE,
   x_segment_id OUT NOCOPY iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE
  )
  IS
    lx_instrnum       iby_trxn_summaries_all.instrnumber%TYPE;
    lx_unmask_digits  iby_trxn_summaries_all.instrnumber%TYPE;
    lx_cc_prefix      iby_cc_issuer_ranges.card_number_prefix%TYPE;
    lx_digit_check    iby_creditcard_issuers_b.digit_check_flag%TYPE;

    l_segment_cipher  iby_security_segments.segment_cipher_text%TYPE;
    lx_subkey_id      iby_sys_security_subkeys.sec_subkey_id%TYPE;
    lx_subkey         iby_sys_security_subkeys.subkey_cipher_text%TYPE;
  BEGIN
    IF (p_instrnum IS NULL) THEN RETURN; END IF;

    x_instrnum := iby_utility_pvt.encode64(p_instrnum);

    IF (NOT p_instrtype IN ('CREDITCARD','PURCHASECARD','PINLESSDEBITCARD'))
    THEN
      RETURN;
    END IF;

    iby_cc_validate.Get_CC_Issuer_Range
    (p_instrnum,x_instr_subtype,x_range_id,lx_cc_prefix,lx_digit_check);
     x_instr_hash := iby_security_pkg.get_hash(p_instrnum,FND_API.G_FALSE);

    IF (x_range_id IS NULL) THEN
      x_instr_len := LENGTH(p_instrnum);
      x_instr_subtype := 'UNKNOWN';
    END IF;

    IF (IBY_CREDITCARD_PKG.Get_CC_Encrypt_Mode() <>
        IBY_SECURITY_PKG.G_ENCRYPT_MODE_NONE)
    THEN
      -- mask the instrument number
      x_instrnum := LPAD('X',LENGTH(p_instrnum),'X');
      -- assuming the number has already been validate- i.e. check digit
      -- verified
      iby_creditcard_pkg.Compress_CC_Number
      (p_instrnum,lx_cc_prefix,lx_digit_check,IBY_SECURITY_PKG.G_MASK_ALL,0,
       lx_instrnum,lx_unmask_digits);

      IF (LENGTH(lx_instrnum) > 0) THEN
        l_segment_cipher :=
          HEXTORAW(IBY_SECURITY_PKG.Encode_Number(lx_instrnum,TRUE));
        IBY_SECURITY_PKG.Get_Sys_Subkey
        (FND_API.G_FALSE,p_sys_key,'Y',lx_subkey_id,lx_subkey);

        l_segment_cipher :=
          DBMS_OBFUSCATION_TOOLKIT.des3encrypt
         ( input => l_segment_cipher, key => lx_subkey,
           which => dbms_obfuscation_toolkit.ThreeKeyMode
         );

        SELECT iby_security_segments_s.NEXTVAL
        INTO x_segment_id
        FROM DUAL;

        INSERT INTO iby_security_segments
        (sec_segment_id, segment_cipher_text, sec_subkey_id, encoding_scheme,
         created_by, creation_date, last_updated_by, last_update_date,
         last_update_login, object_version_number
        )
        VALUES
        (x_segment_id, l_segment_cipher, lx_subkey_id, 'NUMERIC',
         fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
         fnd_global.login_id, 1
        );
      ELSE
        -- indicative of PCI encryption
        x_segment_id := -1;
      END IF;
    END IF;

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
    END IF;
  END prepare_instr_data;

  --
  -- USE: inserts transactional extensibility data
  --
  PROCEDURE insert_extensibility
  (
  p_trxnmid           IN     iby_trxn_summaries_all.trxnmid%TYPE,
  p_commit            IN     VARCHAR2,
  p_extend_names      IN     JTF_VARCHAR2_TABLE_100,
  p_extend_vals       IN     JTF_VARCHAR2_TABLE_200
  )
  IS
  BEGIN

    IF (p_extend_names IS NULL) THEN
      RETURN;
    END IF;


    FOR i IN p_extend_names.FIRST..p_extend_names.LAST LOOP
      INSERT INTO iby_trxn_extensibility
      (trxn_extend_id,trxnmid,extend_name,extend_value,created_by,
       creation_date,last_updated_by,last_update_date,last_update_login,
       object_version_number)
      VALUES
      (iby_trxn_extensibility_s.NEXTVAL,
       p_trxnmid,p_extend_names(i),p_extend_vals(i),
       fnd_global.user_id,sysdate,fnd_global.user_id,sysdate,
       fnd_global.login_id,1);
    END LOOP;

    IF (p_commit = 'Y') THEN
      COMMIT;
    END IF;
  END insert_extensibility;

  /* Inserts a new row into the IBY_TRXN_SUMMARIES_ALL table.  This method  */
  /* would be called every time a MIPP authorize operation is performed. */

PROCEDURE insert_auth_txn
	(
	 ecapp_id_in         IN     iby_trxn_summaries_all.ecappid%TYPE,
         req_type_in         IN     iby_trxn_summaries_all.ReqType%TYPE,
         order_id_in         IN     iby_transactions_v.order_id%TYPE,
         merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
         vendor_id_in        IN     iby_transactions_v.vendor_id%TYPE,
         vendor_key_in       IN     iby_transactions_v.bepkey%TYPE,
         amount_in           IN     iby_transactions_v.amount%TYPE,
         currency_in         IN     iby_transactions_v.currency%TYPE,
         status_in           IN     iby_transactions_v.status%TYPE,
         time_in             IN     iby_transactions_v.time%TYPE,
         payment_name_in     IN     iby_transactions_v.payment_name%TYPE,
	 payment_type_in     IN	    iby_transactions_v.payment_type%TYPE,
         trxn_type_in        IN     iby_transactions_v.trxn_type%TYPE,
	 authcode_in         IN     iby_transactions_v.authcode%TYPE,
	 referencecode_in    IN     iby_transactions_v.referencecode%TYPE,
         AVScode_in          IN     iby_transactions_v.AVScode%TYPE,
         acquirer_in         IN     iby_transactions_v.acquirer%TYPE,
         Auxmsg_in           IN     iby_transactions_v.Auxmsg%TYPE,
         vendor_code_in      IN     iby_transactions_v.vendor_code%TYPE,
         vendor_message_in   IN     iby_transactions_v.vendor_message%TYPE,
         error_location_in   IN     iby_transactions_v.error_location%TYPE,
         trace_number_in     IN	    iby_transactions_v.TraceNumber%TYPE,
	 org_id_in           IN     iby_trxn_summaries_all.org_id%type,
         billeracct_in       IN     iby_tangible.acctno%type,
         refinfo_in          IN     iby_tangible.refinfo%type,
         memo_in             IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	 payerinstrid_in     IN	    iby_trxn_summaries_all.payerinstrid%type,
	 instrnum_in	     IN     iby_trxn_summaries_all.instrnumber%type,
	 payerid_in          IN     iby_trxn_summaries_all.payerid%type,
	 instrtype_in        IN     iby_trxn_summaries_all.instrType%type,
         cvv2result_in       IN     iby_trxn_core.CVV2Result%type,
         master_key_in       IN     iby_security_pkg.DES3_KEY_TYPE,
         subkey_seed_in      IN     RAW,
         trxnref_in          IN     iby_trxn_summaries_all.trxnref%TYPE,
         dateofvoiceauth_in  IN     iby_trxn_core.date_of_voice_authorization%TYPE,
         instr_expirydate_in IN     iby_trxn_core.instr_expirydate%TYPE,
         instr_sec_val_in    IN     VARCHAR2,
         card_subtype_in     IN     iby_trxn_core.card_subtype_code%TYPE,
         card_data_level_in  IN     iby_trxn_core.card_data_level%TYPE,
         instr_owner_name_in    IN  iby_trxn_core.instr_owner_name%TYPE,
         instr_address_line1_in IN  iby_trxn_core.instr_owner_address_line1%TYPE,
         instr_address_line2_in IN  iby_trxn_core.instr_owner_address_line2%TYPE,
         instr_address_line3_in IN  iby_trxn_core.instr_owner_address_line3%TYPE,
         instr_city_in       IN     iby_trxn_core.instr_owner_city%TYPE,
         instr_state_in      IN     iby_trxn_core.instr_owner_state_province%TYPE,
         instr_country_in    IN     iby_trxn_core.instr_owner_country%TYPE,
         instr_postalcode_in IN     iby_trxn_core.instr_owner_postalcode%TYPE,
         instr_phonenumber_in IN    iby_trxn_core.instr_owner_phone%TYPE,
         instr_email_in      IN     iby_trxn_core.instr_owner_email%TYPE,
         pos_reader_cap_in   IN     iby_trxn_core.pos_reader_capability_code%TYPE,
         pos_entry_method_in IN     iby_trxn_core.pos_entry_method_code%TYPE,
         pos_card_id_method_in IN   iby_trxn_core.pos_id_method_code%TYPE,
         pos_auth_source_in  IN     iby_trxn_core.pos_auth_source_code%TYPE,
         reader_data_in      IN     iby_trxn_core.reader_data%TYPE,
         extend_names_in     IN     JTF_VARCHAR2_TABLE_100,
         extend_vals_in      IN     JTF_VARCHAR2_TABLE_200,
         debit_network_code_in IN   iby_trxn_core.debit_network_code%TYPE,
         surcharge_amount_in  IN    iby_trxn_core.surcharge_amount%TYPE,
         proc_tracenumber_in  IN    iby_trxn_core.proc_tracenumber%TYPE,
         transaction_id_out  OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         transaction_mid_out OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE,
         org_type_in         IN      iby_trxn_summaries_all.org_type%TYPE,
         payment_channel_code_in  IN iby_trxn_summaries_all.payment_channel_code%TYPE,
         factored_flag_in         IN iby_trxn_summaries_all.factored_flag%TYPE,
         process_profile_code_in     IN iby_trxn_summaries_all.process_profile_code%TYPE,
	 sub_key_id_in       IN     iby_trxn_summaries_all.sub_key_id%TYPE,
	 voiceAuthFlag_in    IN     iby_trxn_core.voiceauthflag%TYPE
)
  IS

    l_num_trxns      NUMBER	     := 0;
    l_trxn_mid	     NUMBER;
    l_transaction_id NUMBER;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
    l_mpayeeid iby_payee.mpayeeid%type;

    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(200);
    l_checksum_valid   BOOLEAN := FALSE;  -- whether the card number is valid.

    l_cc_type          VARCHAR2(80);
    lx_cc_hash         iby_trxn_summaries_all.instrnum_hash%TYPE;
    lx_range_id        iby_cc_issuer_ranges.cc_issuer_range_id%TYPE;
    lx_instr_len       iby_trxn_summaries_all.instrnum_length%TYPE;
    lx_segment_id      iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE;
    l_old_segment_id   iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE;

    l_instrnum         iby_trxn_summaries_all.instrnumber%type;
    l_expirydate       iby_trxn_core.instr_expirydate%type;

    l_pos_txn          iby_trxn_core.pos_trxn_flag%TYPE;
    l_payer_party_id   iby_trxn_summaries_all.payer_party_id%type;

    l_voiceauth_flag   iby_trxn_core.voiceauthflag%type;
    l_sub_key_id       iby_trxn_summaries_all.sub_key_id%TYPE;

    -- variables for CHNAME and EXPDATE encryption
    l_chname_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_expdate_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_masked_chname     VARCHAR2(100) := NULL;
  --  l_encrypted_date_format VARCHAR2(20);
    l_encrypted         VARCHAR2(1) := 'N';

 BEGIN

     l_num_trxns := getNumPendingTrxns(merchant_id_in,order_id_in,req_type_in);

     prepare_instr_data
     (FND_API.G_FALSE,master_key_in,instrnum_in,instrType_in,l_instrnum,
      l_cc_type,lx_cc_hash,lx_range_id,lx_instr_len,lx_segment_id);


     --
     -- NOTE: for all subsequent data encryptions, make sure that the
     --       parameter to increment the subkey is set to 'N' so that
     --       all encrypted data for the trxn uses the same key!!
     --       else data will NOT DECRYPT CORRECTLY!!
     --
     l_expirydate := instr_expirydate_in;



     -- PABP Fixes
     -- card holder name and instrument expiry are also considered to be
     -- sensitive. We need to encrypt those before inserting/updating the
     -- record in IBY_TRXN_CORE

     IF ((IBY_CREDITCARD_PKG.Get_CC_Encrypt_Mode() <>
          IBY_SECURITY_PKG.G_ENCRYPT_MODE_NONE)
	--  AND ( IBY_CREDITCARD_PKG.Other_CC_Attribs_Encrypted = 'Y')
	)
     THEN
      l_chname_sec_segment_id :=
                 IBY_SECURITY_PKG.encrypt_field_vals(instr_owner_name_in,
		                                     master_key_in,
						     null,
						     'N'
						     );
      l_expdate_sec_segment_id :=
                 IBY_SECURITY_PKG.encrypt_date_field(l_expirydate,
		                                     master_key_in,
						     null,
						     'N'
						     );

      l_masked_chname :=
                IBY_SECURITY_PKG.Mask_Data(instr_owner_name_in,
		                           IBY_SECURITY_PKG.G_MASK_ALL,
				           0,
					   'X'
					   );
      l_encrypted := 'Y';
      l_expirydate := NULL;
     ELSE
      l_masked_chname := instr_owner_name_in;
      l_encrypted := 'N';

     END IF;

     IF ((pos_reader_cap_in IS NULL)
         AND (pos_entry_method_in IS NULL)
         AND (pos_card_id_method_in IS NULL)
         AND (pos_auth_source_in IS NULL)
         AND (reader_data_in IS NULL)
        )
     THEN
       l_pos_txn := 'N';
     ELSE
       l_pos_txn := 'Y';
     END IF;

     IF (l_num_trxns = 0)    THEN
     	 -- new auth request, insert into table
      	SELECT iby_trxnsumm_mid_s.NEXTVAL
	INTO l_trxn_mid
	FROM dual;

  -- get the payer_party_id if exists
 begin
   if(payerid_in is not NULL) then
       l_payer_party_id :=to_number(payerid_in);
       end if;
  exception
    when others then
   select card_owner_id
   into l_payer_party_id
   from iby_creditcard
   where instrid=payerinstrid_in;
  end;

	l_transaction_id := getTID(merchant_id_in, order_id_in);

	transaction_id_out := l_transaction_id;
        transaction_mid_out := l_trxn_mid;

	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

       --Create an entry in iby_tangible table
       iby_bill_pkg.createBill(order_id_in,amount_in,currency_in,
		   billeracct_in,refinfo_in, memo_in,
                   order_medium_in, eft_auth_method_in, l_tmid);
--test_debug('subkeyid passed as: '|| sub_key_id_in);
       INSERT INTO iby_trxn_summaries_all
	(TrxnMID, TransactionID,TrxntypeID, ReqType, ReqDate,
	 Amount,CurrencyNameCode, UpdateDate,Status, PaymentMethodName,
	 TangibleID,MPayeeID, PayeeID,BEPID,bepKey,mtangibleid,
	 BEPCode,BEPMessage,Errorlocation,ecappid,org_id,
	 payerinstrid, instrnumber, payerid, instrType,

	 last_update_date,last_updated_by,creation_date, created_by,
         last_update_login,object_version_number,instrsubtype,trxnref,
         org_type, payment_channel_code, factored_flag,
         cc_issuer_range_id, instrnum_hash, instrnum_length,
         instrnum_sec_segment_id, payer_party_id, process_profile_code,
         salt_version,needsupdt,sub_key_id)
       VALUES (l_trxn_mid, l_transaction_id, trxn_type_in, req_type_in,
               sysdate,
	       amount_in, currency_in, time_in, status_in, payment_type_in,
	       order_id_in, l_mpayeeid, merchant_id_in, vendor_id_in,
	       vendor_key_in, l_tmid, vendor_code_in, vendor_message_in,
	       error_location_in, ecapp_id_in, org_id_in,
               payerinstrid_in, l_instrnum, payerid_in, instrType_in,
	       sysdate, fnd_global.user_id, sysdate, fnd_global.user_id,
               fnd_global.login_id, 1, l_cc_type, trxnref_in,
               org_type_in, payment_channel_code_in, factored_flag_in,
               lx_range_id, lx_cc_hash, lx_instr_len, lx_segment_id,
               l_payer_party_id, process_profile_code_in,
               iby_security_pkg.get_salt_version,'Y',sub_key_id_in);


      /*
       * Fix for bug 5190504:
       *
       * Set the voice auth flag in iby_trxn_core to 'Y'
       * in case, the voice auth date is not null.
       */
   --   IF (dateofvoiceauth_in IS NOT NULL) THEN
   --       l_voiceauth_flag := 'Y';
   --   ELSE
   --       l_voiceauth_flag := 'N';
   --   END IF;

       /*
        * The above logic will not set the voiceAuthFlag if the
	* voice auth date is NULL.
	* The voiceAuthFlag is now received by this API as an
	* input parameter.
	*/
	l_voiceauth_flag := voiceAuthFlag_in;

      INSERT INTO iby_trxn_core (
        TrxnMID, AuthCode, date_of_voice_authorization, voiceauthflag,
        ReferenceCode, TraceNumber,AVSCode, CVV2Result, Acquirer,
	Auxmsg, InstrName,
        Instr_Expirydate, expiry_sec_segment_id,
	Card_Subtype_Code, Card_Data_Level,
        Instr_Owner_Name, chname_sec_segment_id, encrypted,
	Instr_Owner_Address_Line1, Instr_Owner_Address_Line2,
        Instr_Owner_Address_Line3, Instr_Owner_City, Instr_Owner_State_Province,
        Instr_Owner_Country, Instr_Owner_PostalCode, Instr_Owner_Phone,
        Instr_Owner_Email,
        POS_Reader_Capability_Code, POS_Entry_Method_Code,
        POS_Id_Method_Code, POS_Auth_Source_Code, Reader_Data, POS_Trxn_Flag,
debit_network_code, surcharge_amount, proc_tracenumber,
        last_update_date, last_updated_by,
        creation_date, created_by, last_update_login, object_version_number
        ) VALUES (
        l_trxn_mid, authcode_in, dateofvoiceauth_in, l_voiceauth_flag,
        referencecode_in, trace_number_in, AVScode_in, cvv2result_in,
        acquirer_in, Auxmsg_in, payment_name_in,
        l_expirydate, l_expdate_sec_segment_id,
	card_subtype_in, card_data_level_in,
        l_masked_chname, l_chname_sec_segment_id, l_encrypted,
        instr_address_line1_in, instr_address_line2_in, instr_address_line3_in,
        instr_city_in, instr_state_in, instr_country_in, instr_postalcode_in,
        instr_phonenumber_in, instr_email_in,
        pos_reader_cap_in, pos_entry_method_in, pos_card_id_method_in,
        pos_auth_source_in, reader_data_in, l_pos_txn,debit_network_code_in, surcharge_amount_in, proc_tracenumber_in,
        sysdate,fnd_global.user_id,
        sysdate,fnd_global.user_id,fnd_global.login_id,1
        );

        -- probably a superflous call since the first insert is
        -- to log the transaction before it is sent to the payment system
        insert_extensibility(l_trxn_mid,'N',extend_names_in,extend_vals_in);

	--test_debug('insertion complete..');

    ELSE
	--(l_num_trxns = 1)
      -- One previous PENDING transaction, so update previous row
       SELECT TrxnMID, TransactionID, Mtangibleid, instrnum_sec_segment_id, sub_key_id
       INTO l_trxn_mid, transaction_id_out, l_tmid, l_old_segment_id, l_sub_key_id
       FROM iby_trxn_summaries_all
       WHERE (TangibleID = order_id_in)
       AND (UPPER(ReqType) = UPPER(req_type_in))
       AND (PayeeID = merchant_id_in)
       AND (status IN (11,9));

       transaction_mid_out := l_trxn_mid;

       --Re-use the previous subkey for a retry case
 --      sub_key_id_in := l_sub_key_id;

    -- Update iby_tangible table
      iby_bill_pkg.modBill(l_tmid,order_id_in,amount_in,currency_in,
			   billeracct_in,refinfo_in,memo_in,
                           order_medium_in, eft_auth_method_in);


      UPDATE iby_trxn_summaries_all
	 SET BEPID = vendor_id_in,
	     bepKey = vendor_key_in,
	     Amount = amount_in,
		-- amount, bepid is updated as the request can come in
		-- from another online
	     TrxntypeID = trxn_type_in,
	     CurrencyNameCode = currency_in,
	     UpdateDate = time_in,
	     Status = status_in,
	     ErrorLocation = error_location_in,
	     BEPCode = vendor_code_in,
	     BEPMessage = vendor_message_in,
             instrType = instrType,

		-- we don't update payerinstrid and org_id here
		-- as it may overwrite previous payerinstrid, org_id
		-- (from offline scheduling)
		-- in case this request comes in from scheduler

		-- could be a problem if this request comes in from
		-- another online, w/ a different payment instrment
		-- for a previous failed trxn, regardless, the
		--'instrnumber' will always be correct

		--org_id = org_id_in,
 		--payerinstrid = payerinstrid_in,
                -- same for org_type

             PaymentMethodName = NVL(payment_type_in,PaymentMethodName),
	     instrnumber = l_instrnum,
             instrnum_hash = lx_cc_hash,
             instrnum_length = lx_instr_len,
             cc_issuer_range_id = lx_range_id,
             instrnum_sec_segment_id = lx_segment_id,
             trxnref = trxnref_in,
	     last_update_date = sysdate,
	     last_updated_by = fnd_global.user_id,
	     creation_date = sysdate,
	     created_by = fnd_global.user_id,
	     object_version_number = object_version_number + 1,
             payment_channel_code = payment_channel_code_in,
             factored_flag = factored_flag_in
       WHERE TrxnMID = l_trxn_mid;

      DELETE iby_security_segments WHERE sec_segment_id = l_old_segment_id;

      UPDATE iby_trxn_core
	 SET AuthCode = authcode_in,
             date_of_voice_authorization = dateofvoiceauth_in,
           --voiceauthflag = DECODE(dateofvoiceauth_in, NULL, 'N', 'Y'),
	     voiceauthflag = voiceAuthFlag_in,
	     AvsCode = AVScode_in,
             CVV2Result = cvv2result_in,
	     ReferenceCode = referencecode_in,
	     Acquirer = acquirer_in,
	     Auxmsg = Auxmsg_in,
	     TraceNumber = trace_number_in,
             InstrName = NVL(payment_name_in,InstrName),
	     encrypted = l_encrypted,
             Instr_Expirydate = l_expirydate,
	     expiry_sec_segment_id = l_expdate_sec_segment_id,
	     Card_Subtype_Code = card_subtype_in,
             Card_Data_Level = card_data_level_in,
             Instr_Owner_Name = l_masked_chname,
	     chname_sec_segment_id = l_chname_sec_segment_id,
             Instr_Owner_Address_Line1 = instr_address_line1_in,
             Instr_Owner_Address_Line2 = instr_address_line2_in,
             Instr_Owner_Address_Line3 = instr_address_line3_in,
             Instr_Owner_City = instr_city_in,
             Instr_Owner_State_Province = instr_state_in,
             Instr_Owner_Country = instr_country_in,
             Instr_Owner_PostalCode = instr_postalcode_in,
             Instr_Owner_Phone = instr_phonenumber_in,
             Instr_Owner_Email = instr_email_in,
             POS_Reader_Capability_Code = pos_reader_cap_in,
             POS_Entry_Method_Code = pos_entry_method_in,
             POS_Id_Method_Code = pos_card_id_method_in,
             POS_Auth_Source_Code = pos_auth_source_in,
             Reader_Data = reader_data_in,
             POS_Trxn_Flag = l_pos_txn,
             debit_network_code = debit_network_code_in,
             surcharge_amount  = surcharge_amount_in,
             proc_tracenumber = proc_tracenumber_in,
	     last_update_date = sysdate,
	     last_updated_by = fnd_global.user_id,
	     creation_date = sysdate,
	     created_by = fnd_global.user_id,
	     object_version_number = object_version_number + 1
       WHERE TrxnMID = l_trxn_mid;

       insert_extensibility(l_trxn_mid,'N',extend_names_in,extend_vals_in);
    END IF;

    COMMIT;
  END insert_auth_txn;

  /* Inserts a new row into the IBY_TRXN_SUMMARIES table.  This method	 */
  /* would be called every time a capture, credit, return, or void */

  /* operation is performed.					       */

  PROCEDURE insert_other_txn
       ( ecapp_id_in	     IN	    iby_trxn_summaries_all.ecappid%TYPE,
	 req_type_in	     IN     iby_trxn_summaries_all.ReqType%TYPE,
	 order_id_in	     IN     iby_transactions_v.order_id%TYPE,
	 merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
	 vendor_id_in	     IN     iby_transactions_v.vendor_id%TYPE,
	 vendor_key_in	     IN     iby_transactions_v.bepkey%TYPE,
	 status_in	     IN     iby_transactions_v.status%TYPE,
	 time_in	     IN     iby_transactions_v.time%TYPE,
	 payment_type_in     IN     iby_transactions_v.payment_type%TYPE,
	 payment_name_in     IN     iby_transactions_v.payment_name%TYPE,
	 trxn_type_in	     IN	    iby_transactions_v.trxn_type%TYPE,
	 amount_in	     IN     iby_transactions_v.amount%TYPE,
	 currency_in	     IN     iby_transactions_v.currency%TYPE,
	 referencecode_in    IN     iby_transactions_v.referencecode%TYPE,
	 vendor_code_in      IN     iby_transactions_v.vendor_code%TYPE,
	 vendor_message_in   IN     iby_transactions_v.vendor_message%TYPE,
	 error_location_in   IN     iby_transactions_v.error_location%TYPE,
	 trace_number_in     IN     iby_transactions_v.TraceNumber%TYPE,
	 org_id_in           IN     iby_trxn_summaries_all.org_id%type,
	 billeracct_in	     IN     iby_tangible.acctno%type,
	 refinfo_in	     IN     iby_tangible.refinfo%type,
	 memo_in	     IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	 payerinstrid_in     IN	    iby_trxn_summaries_all.payerinstrid%type,
	 instrnum_in	     IN     iby_trxn_summaries_all.instrnumber%type,
	 payerid_in          IN     iby_trxn_summaries_all.payerid%type,
         master_key_in       IN     iby_security_pkg.DES3_KEY_TYPE,
         subkey_seed_in      IN     RAW,
         trxnref_in          IN     iby_trxn_summaries_all.trxnref%TYPE,
         instr_expirydate_in IN     iby_trxn_core.instr_expirydate%TYPE,
         card_subtype_in     IN     iby_trxn_core.card_subtype_code%TYPE,
         instr_owner_name_in    IN  iby_trxn_core.instr_owner_name%TYPE,
         instr_address_line1_in IN  iby_trxn_core.instr_owner_address_line1%TYPE,
         instr_address_line2_in IN  iby_trxn_core.instr_owner_address_line2%TYPE,
         instr_address_line3_in IN  iby_trxn_core.instr_owner_address_line3%TYPE,
         instr_city_in       IN     iby_trxn_core.instr_owner_city%TYPE,
         instr_state_in      IN     iby_trxn_core.instr_owner_state_province%TYPE,
         instr_country_in    IN     iby_trxn_core.instr_owner_country%TYPE,
         instr_postalcode_in IN     iby_trxn_core.instr_owner_postalcode%TYPE,
         instr_phonenumber_in IN    iby_trxn_core.instr_owner_phone%TYPE,
         instr_email_in      IN     iby_trxn_core.instr_owner_email%TYPE,
         extend_names_in     IN     JTF_VARCHAR2_TABLE_100,
         extend_vals_in      IN     JTF_VARCHAR2_TABLE_200,
	 transaction_id_in_out	IN OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
         transaction_mid_out OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE,
         org_type_in         IN      iby_trxn_summaries_all.org_type%TYPE,
         payment_channel_code_in  IN iby_trxn_summaries_all.payment_channel_code%TYPE,
         factored_flag_in         IN iby_trxn_summaries_all.factored_flag%TYPE,
	 settlement_date_in       IN iby_trxn_summaries_all.settledate%TYPE,
 	 settlement_due_date_in   IN iby_trxn_summaries_all.settlement_due_date%TYPE,
         process_profile_code_in   IN iby_trxn_summaries_all.process_profile_code%TYPE,
         instrtype_in              IN iby_trxn_summaries_all.instrtype%TYPE
       )
  IS

    l_num_trxns      NUMBER	     := 0;
    l_trxn_mid	     NUMBER;
    transaction_id NUMBER;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
    l_order_id iby_trxn_summaries_all.tangibleid%type;
    l_mpayeeid iby_payee.mpayeeid%type;
    l_org_id NUMBER;
    l_target_trxn_type iby_trxn_summaries_all.trxntypeid%TYPE := -1;
    l_instrtype iby_trxn_summaries_all.instrtype%type;
    l_instrsubtype iby_trxn_summaries_all.instrsubtype%type;

    lx_cc_hash         iby_trxn_summaries_all.instrnum_hash%TYPE;
    lx_range_id        iby_cc_issuer_ranges.cc_issuer_range_id%TYPE;
    lx_instr_len       iby_trxn_summaries_all.instrnum_length%TYPE;
    lx_segment_id      iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE;
    l_old_segment_id   iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE;

    l_instrnum         iby_trxn_summaries_all.instrnumber%TYPE;
    l_expirydate       iby_trxn_core.instr_expirydate%type;

    l_cursor_empty     BOOLEAN;
    l_process_profile_code   iby_trxn_summaries_all.process_profile_code%TYPE;
    l_payer_party_id   iby_trxn_summaries_all.payer_party_id%TYPE;
    l_pmt_chnl_code     iby_trxn_summaries_all.payment_channel_code%TYPE;
    l_module_name      CONSTANT VARCHAR2(200) := 'IBY_TRANSACTIONCC_PKG.insert_other_txn';

    CURSOR c_followon_info(ci_trxnid iby_trxn_summaries_all.transactionid%TYPE)
    IS
	SELECT mtangibleid, tangibleid, instrType, instrsubtype,
	       process_profile_code, payer_party_id, payment_channel_code
	FROM iby_trxn_summaries_all
	WHERE (transactionid = ci_trxnid)
        --
	-- only consider succeeded ones here
	-- b/c different mtangibleid may get created in case of failed
	-- auth
	--
	--  status 100 is equivalent to 0
	--
	AND (status IN (0,100))
        --
        -- sort by trxnmid as lowest value indicates the
        -- first trxn for this order, which is most likely
        -- to have all information
        --
        ORDER BY trxnmid ASC;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');
    END IF;
    l_instrsubtype := NULL;
    l_num_trxns := getNumPendingTrxns(merchant_id_in, order_id_in,
					req_type_in);
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Number of trxns::'||l_num_trxns);

    END IF;
    IF (c_followon_info%ISOPEN) THEN
      CLOSE c_followon_info;
    END IF;

    IF (l_num_trxns = 0)    THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'INSERTING TRANSACTION ROW');
      END IF;
      -- Insert transaction row
      SELECT iby_trxnsumm_mid_s.NEXTVAL
	INTO l_trxn_mid
	FROM dual;

      transaction_mid_out := l_trxn_mid;

     -- For OraPmtCredit we need to

     -- 1) return transactionid
     -- 2) Create an entry in iby_tangible table
      IF UPPER(req_type_in) = 'ORAPMTCREDIT'
      THEN

	transaction_id := getTID(merchant_id_in, order_id_in);

	transaction_id_in_out := transaction_id;

	iby_bill_pkg.createBill(order_id_in,amount_in,currency_in,
			   billeracct_in,refinfo_in, memo_in,
                           order_medium_in, eft_auth_method_in, l_tmid);

	l_org_id := org_id_in;
	l_order_id := order_id_in;
        --Bug# 8324289
        --Setting Profile code and instrument type so that the credit
        --transaction should get picked up by the settlement batch program.
        l_process_profile_code:= process_profile_code_in;
        l_instrtype:=instrtype_in;
        --
        -- NOTE: for all subsequent data encryptions, make sure that the
        --       parameter to increment the subkey is set to 'N' so that
        --       all encrypted data for the trxn uses the same key!!
        --       else data will NOT DECRYPT CORRECTLY!!
        --
        l_expirydate := instr_expirydate_in;

      ELSE
	-- follow on trxns
	--tangible info should already exist, get them based on
	--transactionid
        --
        OPEN c_followon_info(transaction_id_in_out);
        FETCH c_followon_info INTO l_tmid, l_order_id, l_instrtype, l_instrsubtype,
	        l_process_profile_code, l_payer_party_id, l_pmt_chnl_code;
        l_cursor_empty := c_followon_info%NOTFOUND;
        CLOSE c_followon_info;
        --
        -- not likely to occur, but making this assumption could lead to
        -- a tricky error later
        --
        IF (l_cursor_empty) THEN
          raise_application_error(-20000, 'IBY_20528#', FALSE);
        END IF;

	l_org_id := getOrgId(transaction_id_in_out);

      END IF;

	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

IF (l_instrsubtype is NULL) THEN
   l_instrsubtype := payment_name_in;
END IF;

      prepare_instr_data
      (FND_API.G_FALSE,master_key_in,
       instrnum_in,l_instrtype,l_instrnum,l_instrsubtype,
       lx_cc_hash,lx_range_id,lx_instr_len,lx_segment_id);
      l_instrsubtype := NVL(l_instrsubtype,payment_name_in);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'payment channel code passed='||payment_channel_code_in);
	      print_debuginfo(l_module_name, 'payment channel code passed='||payment_channel_code_in);
	      print_debuginfo(l_module_name, 'settledate='||settlement_date_in);
	      print_debuginfo(l_module_name, 'settlement_due_date='||settlement_due_date_in);

      END IF;
      INSERT INTO iby_trxn_summaries_all

	(TrxnMID, TransactionID,TrxntypeID, ReqType, ReqDate,
	 Amount,CurrencyNameCode, UpdateDate,Status, PaymentMethodName,
	 TangibleID,MPayeeID, PayeeID,BEPID,bepKey, MtangibleId,
	 BEPCode,BEPMessage,Errorlocation,ecappid,org_id,
	 payerinstrid, instrnumber, payerid,
	 last_update_date,last_updated_by,creation_date,created_by,
	 last_update_login,object_version_number,instrType,instrsubtype,trxnref,         org_type, payment_channel_code, factored_flag,
         instrnum_hash, instrnum_length, cc_issuer_range_id,
         instrnum_sec_segment_id, payer_party_id, process_profile_code,
         salt_version,needsupdt, settledate, settlement_due_date)
      VALUES (l_trxn_mid, transaction_id_in_out, trxn_type_in,
	      req_type_in, sysdate,
	      amount_in, currency_in, time_in, status_in, payment_type_in,
	      l_order_id, l_mpayeeid, merchant_id_in, vendor_id_in,
	      vendor_key_in, l_tmid, vendor_code_in, vendor_message_in,
              error_location_in, ecapp_id_in, l_org_id,
              payerinstrid_in, l_instrnum, payerid_in,
	      sysdate, fnd_global.user_id, sysdate, fnd_global.user_id,
              fnd_global.login_id, 1, l_instrtype, l_instrsubtype, trxnref_in,
              org_type_in, nvl(payment_channel_code_in, l_pmt_chnl_code), factored_flag_in,
              lx_cc_hash, lx_instr_len, lx_range_id, lx_segment_id,
              l_payer_party_id, l_process_profile_code,
              iby_security_pkg.get_salt_version,'Y', settlement_date_in, settlement_due_date_in
             );

      INSERT INTO iby_trxn_core
	(TrxnMID, ReferenceCode, TraceNumber, InstrName,
         Instr_Expirydate, Card_Subtype_Code,
         Instr_Owner_Name, Instr_Owner_Address_Line1,
         Instr_Owner_Address_Line2, Instr_Owner_Address_Line3,
         Instr_Owner_City, Instr_Owner_State_Province, Instr_Owner_Country,
         Instr_Owner_PostalCode, Instr_Owner_Phone, Instr_Owner_Email,
	 last_update_date,last_updated_by,creation_date,created_by,
	 last_update_login,object_version_number)
      VALUES
         (l_trxn_mid, referencecode_in, trace_number_in, payment_name_in,
          l_expirydate, card_subtype_in,
          instr_owner_name_in, instr_address_line1_in, instr_address_line2_in,
          instr_address_line3_in, instr_city_in, instr_state_in,
          instr_country_in, instr_postalcode_in, instr_phonenumber_in,
          instr_email_in,
	  sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
          fnd_global.login_id,1);

      insert_extensibility(l_trxn_mid,'N',extend_names_in,extend_vals_in);

ELSIF (l_num_trxns = 1)    THEN
      -- One previous transaction, so update previous row

       SELECT TrxnMID,Mtangibleid,transactionid, instrnum_sec_segment_id
	 INTO l_trxn_mid,l_tmid,transaction_id_in_out, l_old_segment_id
	 FROM iby_trxn_summaries_all
	WHERE TangibleID = order_id_in
	  AND UPPER(ReqType) = UPPER(req_type_in)
	  AND PayeeID = merchant_id_in
          AND Status IN (9,11);

        transaction_mid_out := l_trxn_mid;

	IF (UPPER(req_type_in) = 'ORAPMTCREDIT') THEN
	     --Update iby_tangible table
	     iby_bill_pkg.modBill(l_tmid,order_id_in,amount_in,currency_in,
				   billeracct_in,refinfo_in,memo_in,
                                   order_medium_in, eft_auth_method_in);

		-- do not update 'payerinstrid, org_id' here, same reason
		-- as shown in 'auth'

  l_expirydate := instr_expirydate_in;
        ELSE

          OPEN c_followon_info(transaction_id_in_out);
          FETCH c_followon_info INTO l_tmid, l_order_id, l_instrtype, l_instrsubtype,
	                  l_process_profile_code, l_payer_party_id, l_pmt_chnl_code;
          l_cursor_empty := c_followon_info%NOTFOUND;
          CLOSE c_followon_info;
          IF (l_cursor_empty) THEN
            raise_application_error(-20000, 'IBY_20528#', FALSE);
          END IF;

 	END IF;


      UPDATE iby_trxn_summaries_all
	 SET BEPID = vendor_id_in,
	     bepKey = vendor_key_in,
	     Amount = amount_in,
	     TrxntypeID = trxn_type_in,
	     CurrencyNameCode = currency_in,
	     UpdateDate = time_in,
	     Status = status_in,
	     ErrorLocation = error_location_in,
	     BEPCode = vendor_code_in,
	     BEPMessage = vendor_message_in,
             --payerinstrid = payerinstrid_in,
             PaymentMethodName = NVL(payment_type_in,PaymentMethodName),
             instrtype = NVL(l_instrtype,instrtype),
             instrsubtype = NVL(l_instrsubtype,instrsubtype),
             instrnumber = l_instrnum,
             instrnum_hash = lx_cc_hash,
             instrnum_length = lx_instr_len,
             cc_issuer_range_id = lx_range_id,
             instrnum_sec_segment_id = lx_segment_id,
             trxnref = trxnref_in,
	     Last_Update_Date = sysdate,
	     Last_Updated_by = fnd_global.user_id,
	     Creation_Date = sysdate,
	     Created_By = fnd_global.user_id,
	     Object_Version_Number = object_version_number + 1
       WHERE TrxnMID = l_trxn_mid;

      DELETE iby_security_segments WHERE sec_segment_id = l_old_segment_id;

      UPDATE iby_trxn_core
	 SET ReferenceCode = referencecode_in,
	     TraceNumber = trace_number_in,
             InstrName = NVL(payment_name_in,InstrName),
             Instr_Expirydate = instr_expirydate_in,
             Card_Subtype_Code = card_subtype_in,
             Instr_Owner_Name = instr_owner_name_in,
             Instr_Owner_Address_Line1 = instr_address_line1_in,
             Instr_Owner_Address_Line2 = instr_address_line2_in,
             Instr_Owner_Address_Line3 = instr_address_line3_in,
             Instr_Owner_City = instr_city_in,
             Instr_Owner_State_Province = instr_state_in,
             Instr_Owner_Country = instr_country_in,
             Instr_Owner_PostalCode = instr_postalcode_in,
             Instr_Owner_Phone = instr_phonenumber_in,
             Instr_Owner_Email = instr_email_in,
	     Last_Update_Date = sysdate,
	     Last_Updated_by = fnd_global.user_id,
	     Creation_Date = sysdate,
	     Created_By = fnd_global.user_id,
	     Object_Version_Number = object_version_number + 1
       WHERE TrxnMID = l_trxn_mid;

      insert_extensibility(l_trxn_mid,'N',extend_names_in,extend_vals_in);

    ELSE
      -- will never run into this block
      -- More than one previous transaction, which is an
      -- error
       	raise_application_error(-20000, 'IBY_20422#', FALSE);
      --raise_application_error(-20422, 'Multiple matching other transactions');


    END IF;


    -- for voids mark the target trxn as cancelled
    IF req_type_in='ORAPMTVOID' THEN

	-- get the targe trxn type
	--
	IF trxn_type_in = 4 THEN
	   -- auth only
	   l_target_trxn_type := 2;

	ELSIF trxn_type_in = 7 THEN
	   -- auth capture
	   l_target_trxn_type := 3;

	ELSIF trxn_type_in = 13 THEN
	   -- capture
	   l_target_trxn_type := 8;

	ELSIF trxn_type_in = 14 THEN
	   -- mark capture
	   l_target_trxn_type := 9;

	ELSIF trxn_type_in = 17 THEN
	   -- return
	   l_target_trxn_type := 5;

	ELSIF trxn_type_in = 18 THEN
	   -- mark return
	   l_target_trxn_type := 10;

	ELSIF trxn_type_in = 19 THEN
	   -- credit
	   l_target_trxn_type := 11;

	END IF;

	UPDATE iby_trxn_summaries_all
	SET
	  -- CHANGE: UPDATE STATUS FOR VOIDED GATEWAY TRXNS
	  --
	  -- currently only change the status for processor
	  -- batched trxns; in the future should probably
	  -- update for gateway trxns as well
	  --
	  status=decode(status,100,114,status),
	  last_update_date = sysdate,
   updatedate = sysdate,
	  last_updated_by = fnd_global.user_id,
	  object_version_number = object_version_number + 1
	WHERE (transactionid=transaction_id_in_out) AND (trxntypeid=l_target_trxn_type);
    END IF;

    COMMIT;


  END insert_other_txn;


  /* Inserts a row into the iby_transaction table if auth, capture, */
  /* return, credit, and void timeout				   */

   PROCEDURE insert_timeout_txn
	(req_type_in	     IN     iby_trxn_summaries_all.ReqType%TYPE,
	 order_id_in	     IN     iby_transactions_v.order_id%TYPE,

	 merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
	 vendor_id_in	     IN     iby_transactions_v.vendor_id%TYPE,
	 vendor_key_in	     IN     iby_transactions_v.bepkey%TYPE,
	 ecapp_id_in	  IN	 iby_trxn_summaries_all.ecappid%TYPE,
	 time_in	    IN	   iby_transactions_v.time%TYPE,


	 status_in	  IN	 iby_transactions_v.status%TYPE,
	 org_id_in IN iby_trxn_summaries_all.org_id%type,
	 amount_in	     IN     iby_tangible.amount%type,
	 currency_in	     IN     iby_tangible.currencynamecode%type,
	 billeracct_in	     IN     iby_tangible.acctno%type,
	 refinfo_in	     IN     iby_tangible.refinfo%type,
	 memo_in	     IN     iby_tangible.memo%type,
         order_medium_in     IN     iby_tangible.order_medium%TYPE,
         eft_auth_method_in  IN     iby_tangible.eft_auth_method%TYPE,
	payerinstrid_in	IN	iby_trxn_summaries_all.payerinstrid%type,
	instrnum_in	IN  iby_trxn_summaries_all.instrnumber%type,
	payerid_in IN iby_trxn_summaries_all.payerid%type,
	instrtype_in IN iby_trxn_summaries_all.instrType%type,
        master_key_in       IN     iby_security_pkg.DES3_KEY_TYPE,
        subkey_seed_in      IN     RAW,
        trxnref_in          IN     iby_trxn_summaries_all.trxnref%TYPE,
	transaction_id_out  OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE,
        transaction_mid_out OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE,
        trxntypeid_in IN iby_trxn_summaries_all.trxntypeid%TYPE,
         org_type_in         IN      iby_trxn_summaries_all.org_type%TYPE,
         payment_channel_code_in  IN iby_trxn_summaries_all.payment_channel_code%TYPE,
         factored_flag_in         IN iby_trxn_summaries_all.factored_flag%TYPE
        )

   IS

    l_num_trxns      NUMBER	     := 0;
    l_trxn_mid	     NUMBER;
    transaction_id NUMBER;
    l_tmid iby_trxn_summaries_all.mtangibleid%type;
    l_order_id iby_trxn_summaries_all.tangibleid%type;
    l_mpayeeid iby_payee.mpayeeid%type;
    l_org_id NUMBER;
    l_instrsubtype iby_trxn_summaries_all.instrsubtype%type;

    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(200);
    l_checksum_valid   BOOLEAN := FALSE;  -- To check whether the card number is valid.
    l_cc_type        VARCHAR2(80);

    l_instrnum         iby_trxn_summaries_all.instrnumber%TYPE;
    l_subkey_id        iby_payee_subkeys.payee_subkey_id%TYPE;

  BEGIN

    -- Count number of previous PENDING transactions

     l_num_trxns := getNumPendingTrxns(merchant_id_in, order_id_in,
					req_type_in);

    IF (l_num_trxns = 0)
    THEN
      -- Everything is fine, insert into table
      SELECT iby_trxnsumm_mid_s.NEXTVAL
	INTO l_trxn_mid
	FROM dual;

      transaction_id := getTID(merchant_id_in, order_id_in);

      transaction_id_out := transaction_id;
      transaction_mid_out := l_trxn_mid;

      iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

      -- Create an entry in iby_tangible table
      IF ((UPPER(req_type_in) = 'ORAPMTCREDIT') OR

	  (UPPER(req_type_in) = 'ORAPMTREQ')) THEN
	  iby_bill_pkg.createBill(order_id_in,amount_in,currency_in,
		   	billeracct_in,refinfo_in, memo_in,
                        order_medium_in, eft_auth_method_in, l_tmid);

	l_order_id := order_id_in;
	l_org_id := org_id_in;
      ELSE
	--tangible info should already exist, get them based on
	--transactionid
	SELECT DISTINCT mtangibleid, tangibleid
	INTO l_tmid, l_order_id
	FROM iby_trxn_summaries_all
	WHERE transactionid = transaction_id_out
	--
	-- 100 is equivalent to 0
	--
	AND (status IN (0,100));

	-- input org_id is null, check previous orgid
	l_org_id := getOrgId(transaction_id_out);
      END IF;

      iby_cc_validate.ValidateCC(1.0,FND_API.G_FALSE,instrnum_in,SYSDATE(),l_return_status,l_msg_count,l_msg_data,l_checksum_valid,l_cc_type);
      IF (l_cc_type is NULL) THEN
        iby_cc_validate.ValidateCC(1.0,FND_API.G_FALSE,instrnum_in,SYSDATE(),l_return_status,l_msg_count,l_msg_data,l_checksum_valid,l_cc_type);
      END IF;
/*
      prepare_instr_data(ecapp_id_in,merchant_id_in,master_key_in,
        instrnum_in,subkey_seed_in,FND_API.G_TRUE,l_instrnum,l_subkey_id);
*/
      INSERT INTO iby_trxn_summaries_all
	(TrxnMID, TransactionID, ReqType, ReqDate,
	 UpdateDate,Status, Amount, CurrencyNameCode,
	 TangibleID,MPayeeID, PayeeID,BEPID,bepKey, ECAppID,org_id,mtangibleid,
	payerinstrid, instrnumber, sub_key_id, payerid, instrType,
	 last_update_date,last_updated_by,creation_date,created_by,
	 last_update_login,object_version_number,instrsubtype,TrxnTypeID,trxnref,
         org_type, payment_channel_code, factored_flag,needsupdt)
      VALUES (l_trxn_mid, transaction_id_out, req_type_in, time_in,
	      time_in, status_in, amount_in, currency_in,
	      l_order_id, l_mpayeeid, merchant_id_in, vendor_id_in,
		vendor_key_in, ecapp_id_in, l_org_id,l_tmid,
		payerinstrid_in, l_instrnum, l_subkey_id, payerid_in, instrType_in,
		sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
		fnd_global.login_id,1,l_cc_type,trxntypeid_in,trxnref_in,
                org_type_in, payment_channel_code_in, factored_flag_in,'Y');


      INSERT INTO iby_trxn_core
	(TrxnMID,
	 last_update_date,last_updated_by,creation_date,created_by,
	 last_update_login,object_version_number)
      VALUES (l_trxn_mid,
	 sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id,1);


    ELSIF (l_num_trxns = 1)    THEN
      -- One previous transaction, so update previous row
       SELECT TrxnMID, TransactionID, MtangibleId
	 INTO l_trxn_mid, transaction_id_out, l_tmid

	 FROM iby_trxn_summaries_all
	WHERE TangibleID = order_id_in
	  AND UPPER(ReqType) = UPPER(req_type_in)
	  AND PayeeID = merchant_id_in
          AND Status IN (9,11);

      transaction_mid_out := l_trxn_mid;

      IF ((UPPER(req_type_in) = 'ORAPMTCREDIT') OR
	  (UPPER(req_type_in) = 'ORAPMTREQ')) THEN
	  -- Update iby_tangible table
 	iby_bill_pkg.modBill(l_tmid,order_id_in,amount_in,currency_in,
			   billeracct_in,refinfo_in,memo_in,
                           order_medium_in, eft_auth_method_in);

      END IF;

      UPDATE iby_trxn_summaries_all
	 SET UpdateDate = time_in,
	     Status = status_in,
	     BEPID = vendor_id_in,
	     bepKey = vendor_key_in,
	     ECAppID = ecapp_id_in,
	-- not updating payerinstrid, org_id, org_type for the same reason
		--payerinstrid = payerinstrid_in,
		instrnumber = l_instrnum,
		sub_key_id = l_subkey_id,
		instrType = instrType_in,
             trxnref = trxnref_in,

	     Last_Update_Date = sysdate,
	     Last_Updated_by = fnd_global.user_id,
	     Creation_Date = sysdate,
	     Created_By = fnd_global.user_id,
	     Object_Version_Number = object_version_number + 1,
             payment_channel_code = payment_channel_code_in,
             factored_flag = factored_flag_in
       WHERE TrxnMID = l_trxn_mid;

    ELSE

      -- will never run into this block
      -- More than one previous transaction, which is an
      -- error
       	raise_application_error(-20000, 'IBY_20422#', FALSE);
      --raise_application_error(-20422, 'Multiple matching timeout transactions');

    END IF;

    COMMIT;

  END insert_timeout_txn;


  /* Inserts a row about batch status into iby_batches_all.  This will */
  /* be called for link error, timeout error or other batch status   */

  PROCEDURE insert_batch_status
    (merch_batchid_in	 IN     iby_batches_all.batchid%TYPE,
     merchant_id_in	 IN     iby_batches_all.payeeid%TYPE,
     vendor_id_in        IN     iby_batches_all.bepid%TYPE,
     vendor_key_in       IN     iby_batches_all.bepkey%TYPE,
     pmt_type_in	 IN     iby_batches_all.paymentmethodname%TYPE,
     status_in		 IN     iby_batches_all.batchstatus%TYPE,
     time_in		 IN     iby_batches_all.batchclosedate%TYPE,
     viby_batchid_in	 IN     iby_batches_all.vpsbatchid%TYPE ,
     currency_in	 IN     iby_batches_all.currencynamecode%TYPE,
     numtrxns_in	 IN     iby_batches_all.NumTrxns%TYPE,
     batchstate_in	 IN     iby_batches_all.BatchStateid%TYPE,
     batchtotal_in	 IN     iby_batches_all.BatchTotal%TYPE,
     saleamount_in	 IN     iby_batches_all.BatchSales%TYPE,
     cramount_in	 IN     iby_batches_all.BatchCredit%TYPE,
     gwid_in		 IN     iby_batches_all.GWBatchID%TYPE,
     vendor_code_in	 IN     iby_batches_all.BEPcode%TYPE,
     vendor_message_in	 IN     iby_batches_all.BEPmessage%TYPE,
     error_location_in	 IN     iby_batches_all.errorlocation%TYPE,
     terminal_id_in	 IN     iby_batches_all.TerminalId%TYPE,
     acquirer_id_in	 IN     iby_batches_all.Acquirer%TYPE,
     org_id_in           IN     iby_trxn_summaries_all.org_id%TYPE,
     req_type_in         IN     iby_batches_all.reqtype%TYPE,
     sec_key_present_in  IN     VARCHAR2,
     mbatchid_out        OUT NOCOPY iby_batches_all.mbatchid%type
     )
  IS

    numrows NUMBER;
    l_mpayeeid iby_payee.mpayeeid%type;
    l_mbatchid iby_batches_all.mbatchid%type;
    l_beptype  iby_bepinfo.bep_type%TYPE;
    l_trxncount iby_batches_all.numtrxns%TYPE;
    l_batchcurr iby_batches_all.currencynamecode%TYPE;
    l_pinlessdebitcard  CONSTANT VARCHAR2(100) :='PINLESSDEBITCARD';
  BEGIN

   -- First check if a row already exists for this batch status

   SELECT COUNT(*)
   INTO numrows
   FROM iby_batches_all
   WHERE batchid = merch_batchid_in
     AND payeeid = merchant_id_in;

   -- insert batch status into iby_batches_all

  IF numrows = 0

  THEN
       --
       -- need to lock trxn summaries table to ensure that
       -- trxns which have not been validated do not sneak into
       -- the batch; gap between call to validate_open_batch
       -- and update of IBY_TRXN_SUMMARIES_ALL has been shown
       -- to be vulnerable to race conditions even under moderate
       -- concurrency loads
       --
       --LOCK TABLE iby_batches_all, iby_trxn_summaries_all IN EXCLUSIVE MODE;

       SELECT iby_batches_s.NEXTVAL
         INTO l_mbatchid
	 FROM dual;

       mbatchid_out := l_mbatchid;

       l_batchcurr := currency_in;
       l_trxncount := numtrxns_in;

       SELECT NVL(bep_type,iby_bepinfo_pkg.C_BEPTYPE_GATEWAY)
         INTO l_beptype
         FROM iby_bepinfo
         WHERE (bepid=vendor_id_in);

       --
       -- if the bep is a processor, then we create a batch
       --
       IF ( (l_beptype = iby_bepinfo_pkg.C_BEPTYPE_PROCESSOR) AND
            ((req_type_in = iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE) OR
             (req_type_in = iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE)))
       THEN

         --
         -- associate all trxns in the current open batch
         -- with the bathc id of the batch close
         --
         UPDATE iby_trxn_summaries_all
          SET
            status = iby_transactioncc_pkg.C_STATUS_BATCH_PENDING,
            batchid = merch_batchid_in,
            mbatchid = l_mbatchid,
            last_update_date = sysdate,
            updatedate = sysdate,
            last_updated_by = fnd_global.user_id,
            object_version_number = object_version_number + 1
	  WHERE (bepid = vendor_id_in)
	    AND (bepkey = vendor_key_in)
	    AND (payeeid = merchant_id_in)
	    AND (status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED)
	    AND ((instrtype IN (iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                           iby_creditcard_pkg.C_INSTRTYPE_PCARD)
		AND
	(req_type_in = iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE))
                 OR
	(instrtype IN (l_pinlessdebitcard)
		 AND
	(req_type_in = iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE))
	          OR
        instrtype IS NULL)
	    AND (batchid IS NULL);

       END IF;

       iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);
 -- Making Changes for bug:8363526
-- Will insert value for settledate as SYSDATE.
   INSERT INTO iby_batches_all
     (MBATCHID, BATCHID, MPAYEEID, PAYEEID, BEPID, BEPKEY, PAYMENTMETHODNAME,
      BATCHSTATUS, BATCHCLOSEDATE, VPSBATCHID, CURRENCYNAMECODE,
      NUMTRXNS, BATCHSTATEID, BATCHTOTAL, BATCHSALES, BATCHCREDIT,
      GWBATCHID, BEPCODE, BEPMESSAGE, ERRORLOCATION,

      TerminalId, Acquirer,reqtype, reqdate,
      last_update_date,last_updated_by,creation_date,created_by,
	last_update_login,  object_version_number,settledate)
   VALUES
     ( l_mbatchid, merch_batchid_in, l_mpayeeid, merchant_id_in, vendor_id_in,
      vendor_key_in, pmt_type_in, status_in, time_in, viby_batchid_in,
      '', 0, batchstate_in, batchtotal_in, saleamount_in,
      cramount_in, gwid_in, vendor_code_in, vendor_message_in,
      error_location_in, terminal_id_in, Acquirer_id_in,req_type_in, sysdate,
	 sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id,1,sysdate);

      validate_open_batch(vendor_id_in, l_mbatchid, sec_key_present_in,
                          l_trxncount, l_batchcurr);

      UPDATE iby_batches_all
      SET CURRENCYNAMECODE = l_batchcurr,
          NUMTRXNS = l_trxncount
      WHERE mbatchid = l_mbatchid;

    ELSIF (numrows = 1)
    THEN
         l_trxncount := numtrxns_in;
         IF (l_trxncount<1) THEN
           l_trxncount := NULL;
         END IF;
      -- One previous transaction, so update previous row
      	 UPDATE iby_batches_all
	 SET PAYMENTMETHODNAME = pmt_type_in,
	     BATCHSTATUS = status_in,
	     BATCHCLOSEDATE = time_in,
	     CURRENCYNAMECODE = NVL(currency_in,CURRENCYNAMECODE),
	     NUMTRXNS = NVL(l_trxncount,NUMTRXNS),
	     BATCHSTATEID = batchstate_in,
	     BATCHTOTAL = batchtotal_in,
	     BATCHSALES = saleamount_in,
	     BATCHCREDIT = cramount_in,
	     GWBATCHID = gwid_in,
	     BEPCODE = vendor_code_in,
	     BEPMESSAGE = vendor_message_in,
	     ERRORLOCATION = error_location_in,
	     Last_Update_Date = sysdate,
	     Last_Updated_by = fnd_global.user_id,

             -- Do not update creation timestamp
             -- when updating records: Bug 3128675
	     --Creation_Date = sysdate,
	     --Created_By = fnd_global.user_id,

	     Object_Version_Number = Object_Version_Number + 1

       WHERE batchid = merch_batchid_in
	 AND payeeid = merchant_id_in;

	IF ((req_type_in = 'ORAPMTCLOSEBATCH') OR
            (req_type_in = 'ORAPMTPDCCLOSEBATCH') ) THEN
		-- we don't update the following for querybatch
     	 	UPDATE iby_batches_all
		     SET VPSBATCHID = viby_batchid_in,
			reqtype = req_type_in,
			reqdate = sysdate
       		WHERE batchid = merch_batchid_in
	 		AND payeeid = merchant_id_in;
	END IF;

        SELECT mbatchid
        INTO mbatchid_out
        FROM iby_batches_all
        WHERE batchid = merch_batchid_in
	 AND payeeid = merchant_id_in;

   ELSE
      -- will never run into this block
      -- More than one pending transaction, which is an
      -- error
       	raise_application_error(-20000, 'IBY_20422#', FALSE);
  END IF;

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --
      -- rethrow any internally generated exception
      --
      --raise_application_error(SQLCODE, SQLERRM, FALSE);
      RAISE;
  END insert_batch_status;

/*--------------------------------------------------------------------
 | NAME:
 |     insert_batch_status_new
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
  PROCEDURE insert_batch_status_new
  (
  merch_batchid_in    IN     iby_batches_all.batchid%TYPE,
  profile_code_in     IN     iby_batches_all.process_profile_code%TYPE,
  merchant_id_in      IN     iby_batches_all.payeeid%TYPE,
  vendor_id_in        IN     iby_batches_all.bepid%TYPE,
  vendor_key_in       IN     iby_batches_all.bepkey%TYPE,
  pmt_type_in         IN     iby_batches_all.paymentmethodname%TYPE,
  status_in           IN     iby_batches_all.batchstatus%TYPE,
  time_in             IN     iby_batches_all.batchclosedate%TYPE,
  viby_batchid_in     IN     iby_batches_all.vpsbatchid%TYPE ,
  currency_in         IN     iby_batches_all.currencynamecode%TYPE,
  numtrxns_in         IN     iby_batches_all.NumTrxns%TYPE,
  batchstate_in	      IN     iby_batches_all.BatchStateid%TYPE,
  batchtotal_in	      IN     iby_batches_all.BatchTotal%TYPE,
  saleamount_in	      IN     iby_batches_all.BatchSales%TYPE,
  cramount_in	      IN     iby_batches_all.BatchCredit%TYPE,
  gwid_in             IN     iby_batches_all.GWBatchID%TYPE,
  vendor_code_in      IN     iby_batches_all.BEPcode%TYPE,
  vendor_message_in   IN     iby_batches_all.BEPmessage%TYPE,
  error_location_in   IN     iby_batches_all.errorlocation%TYPE,
  terminal_id_in      IN     iby_batches_all.TerminalId%TYPE,
  acquirer_id_in      IN     iby_batches_all.Acquirer%TYPE,
  org_id_in           IN     iby_trxn_summaries_all.org_id%TYPE,
  req_type_in         IN     iby_batches_all.reqtype%TYPE,
  sec_key_present_in  IN     VARCHAR2,
  acct_profile_in     IN     iby_batches_all.process_profile_code%TYPE,
  instr_type_in       IN     iby_batches_all.instrument_type%TYPE,
  br_disputed_flag_in IN     iby_batches_all.br_disputed_flag%TYPE,
  f_pmt_channel_in    IN     iby_trxn_summaries_all.
                                 payment_channel_code%TYPE,
  f_curr_in           IN     iby_trxn_summaries_all.
                                 currencynamecode%TYPE,
  f_settle_date       IN     iby_trxn_summaries_all.
                                 settledate%TYPE,
  f_due_date          IN     iby_trxn_summaries_all.
                                 settlement_due_date%TYPE,
  f_maturity_date     IN     iby_trxn_summaries_all.
                                 br_maturity_date%TYPE,
  f_instr_type        IN     iby_trxn_summaries_all.
                                 instrtype%TYPE,
  mbatch_ids_out      OUT    NOCOPY JTF_NUMBER_TABLE,
  batch_ids_out       OUT    NOCOPY JTF_VARCHAR2_TABLE_100
  )
  IS

  numrows NUMBER;

  l_mpayeeid  iby_payee.mpayeeid%type;
  l_mbatchid  iby_batches_all.mbatchid%type;
  l_beptype   iby_bepinfo.bep_type%TYPE;
  l_trxncount iby_batches_all.numtrxns%TYPE;
  l_batchcurr iby_batches_all.currencynamecode%TYPE;

  l_pinlessdebitcard  CONSTANT VARCHAR2(100) :='PINLESSDEBITCARD';

  l_batches_tab         batchAttrTabType;
  l_trxns_in_batch_tab  trxnsInBatchTabType;
  l_mbatch_ids_out      mBatchIdsTab;

  l_index               NUMBER;

  l_module_name         CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                              '.insert_batch_status_new';

  /*
   * Cursor to pick up all existing mbatchids for
   * a given (batch id, payee id, profile code)
   * combination.
   */
  CURSOR c_mbatch_ids (batch_id   IBY_BATCHES_ALL.batchid%TYPE,
                       payee_id   IBY_BATCHES_ALL.payeeid%TYPE,
                       profile_cd IBY_BATCHES_ALL.process_profile_code%TYPE
                       )
  IS
  SELECT
      mbatchid
  FROM
      IBY_BATCHES_ALL
  WHERE
      batchid = batch_id                 AND
      payeeid = payee_id                 AND
      process_profile_code = profile_cd
  ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     mbatch_ids_out := JTF_NUMBER_TABLE();
     batch_ids_out  := JTF_VARCHAR2_TABLE_100();

     /* First check if a row already exists for this batch status */
     SELECT
         COUNT(*)
     INTO
         numrows
     FROM
         IBY_BATCHES_ALL
     WHERE
         batchid = merch_batchid_in AND
         payeeid = merchant_id_in
     ;

     /*
      * If row does not exist, then insert batch status into iby_batches_all
      */
     IF numrows = 0 THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'num rows is zero');

         END IF;
         --
         -- need to lock trxn summaries table to ensure that
         -- trxns which have not been validated do not sneak into
         -- the batch; gap between call to validate_open_batch
         -- and update of IBY_TRXN_SUMMARIES_ALL has been shown
         -- to be vulnerable to race conditions even under moderate
         -- concurrency loads
         --
         --LOCK TABLE iby_batches_all, iby_trxn_summaries_all IN EXCLUSIVE MODE;

         --SELECT iby_batches_s.NEXTVAL
         --  INTO l_mbatchid
         --FROM dual;

         --mbatchid_out := l_mbatchid;

         l_batchcurr := currency_in;
         l_trxncount := numtrxns_in;

         SELECT
             NVL(bep_type,iby_bepinfo_pkg.C_BEPTYPE_GATEWAY)
         INTO
             l_beptype
         FROM
             IBY_BEPINFO
         WHERE
             (bepid=vendor_id_in)
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'STEP 1');

         END IF;
         --
         -- if the bep is a processor, then we create a batch
         --
         IF (
             (l_beptype = iby_bepinfo_pkg.C_BEPTYPE_PROCESSOR) AND
             (
              (req_type_in = iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE) OR
              (req_type_in = iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE)
             )
            ) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Invoking grouping ..');

             END IF;
             /*
              * Group all the transactions for this profile into
              * batches as per the grouping attributes on the profile.
              */
             performTransactionGrouping(
                 profile_code_in,
                 instr_type_in,
                 req_type_in,
                 f_pmt_channel_in,
                 f_curr_in,
                 f_settle_date,
                 f_due_date,
                 f_maturity_date,
                 f_instr_type,
                 l_batches_tab,
                 l_trxns_in_batch_tab
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, '# batches created: '
	                 || l_batches_tab.COUNT);

	             print_debuginfo(l_module_name, '# transactions processed: '
	                 || l_trxns_in_batch_tab.COUNT);

             END IF;
             /*
              * After grouping it is possible that multiple batches were
              * created. Each batch will be a separate row in the
              * IBY_BATCHES_ALL table with a unique mbatchid.
              *
              * The user may have provided a batch id (batch prefix), we will
              * have to assign that batch id to each of the created batches.
              *
              * This batch id would be sent to the payment system. It therefore
              * has to be unique. Therefore, we add a suffix to the user
              * provided batch id to ensure that batches created after grouping
              * have a unique batch id.
              */
             IF (l_batches_tab.COUNT > 0) THEN

                 l_index := 1;
                 FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

                     /*
                      * Assign a unique batch id to each batch.
                      */
                     l_batches_tab(k).batch_id :=
                         merch_batchid_in ||'_'|| l_index;
                     l_index := l_index + 1;

                 END LOOP;

             END IF;

             /*
              * After grouping, the transactions will be assigned a mbatch id.
              * Assign them a batch id as well (based on the batch id
              * corresponding to each mbatch id).
              */
             IF (l_trxns_in_batch_tab.COUNT > 0) THEN

                 FOR m IN l_trxns_in_batch_tab.FIRST ..
                     l_trxns_in_batch_tab.LAST LOOP

                     FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

                         /*
                          * Find the mbatch id in the batches array
                          * corresponding to the mbatchid of this transaction.
                          */
                         IF (l_trxns_in_batch_tab(m).mbatch_id =
                             l_batches_tab(k).mbatch_id) THEN

                             /*
                              * Assign the batch id from the batches array
                              * to this transaction.
                              */
                             l_trxns_in_batch_tab(m).batch_id :=
                                 l_batches_tab(k).batch_id;

                         END IF;

                     END LOOP;

                 END LOOP;

             END IF;

             /*
              * BEP and vendor related params.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'vendor_id_in: '
	                 || vendor_id_in);
	             print_debuginfo(l_module_name, 'vendor_key_in: '
	                 || vendor_key_in);
	             print_debuginfo(l_module_name, 'merchant_id_in: '
	                 || merchant_id_in);
	             print_debuginfo(l_module_name, 'req_type_in: '
	                 || req_type_in);

             END IF;
             --
             -- associate all trxns in the current open batch
             -- with the batch id of the batch close
             --
             IF (l_trxns_in_batch_tab.COUNT <> 0) THEN

                 FOR i IN l_trxns_in_batch_tab.FIRST ..
                     l_trxns_in_batch_tab.LAST LOOP

                     /*
                      * This SQL statement has been replaced by
                      * the SQL update statement (below). It is kept
                      * here for documentation purposes.
                      */
                     /*------------------------------------------
                     UPDATE
                         IBY_TRXN_SUMMARIES_ALL
                     SET
                         status = iby_transactioncc_pkg.C_STATUS_BATCH_PENDING,
                         batchid = merch_batchid_in
                                     || '_' || i,
                         mbatchid = l_trxns_in_batch_tab(i).mbatch_id,
                         last_update_date = sysdate,
                         updatedate = sysdate,
                         last_updated_by = fnd_global.user_id,
                         object_version_number = object_version_number + 1
                     WHERE
                         (bepid = vendor_id_in)     AND
                         (bepkey = vendor_key_in)   AND
                         (payeeid = merchant_id_in) AND
                         (status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED)i
                         AND
                         (
                           (instrtype IN
                               (iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                                iby_creditcard_pkg.C_INSTRTYPE_PCARD) AND
                           (req_type_in =
                               iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE))
                           OR
                           (instrtype IN (l_pinlessdebitcard) AND
                           (req_type_in = iby_transactioncc_pkg.
                                              C_REQTYPE_PDC_BATCHCLOSE)
                           )
                           OR
                           instrtype IS NULL
                         )
                         AND
                         (batchid IS NULL);
                     -------------------------------------------*/

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Going to update '
	                         || 'transaction ' || l_trxns_in_batch_tab(i).trxn_id);

                     END IF;
                     UPDATE
                         IBY_TRXN_SUMMARIES_ALL
                     SET
                         status                = iby_transactioncc_pkg.
                                                     C_STATUS_BATCH_PENDING,
                         batchid               = l_trxns_in_batch_tab(i).
                                                     batch_id,
                         mbatchid              = l_trxns_in_batch_tab(i).
                                                     mbatch_id,
                         last_update_date      = sysdate,
                         updatedate            = sysdate,
                         last_updated_by       = fnd_global.user_id,
                         object_version_number = object_version_number + 1
                     WHERE
                         transactionid = l_trxns_in_batch_tab(i).trxn_id AND
                         status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED
                         ;

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Finished updating '
	                         || 'transaction'
	                         || l_trxns_in_batch_tab(i).trxn_id
	                         );

                     END IF;
                 END LOOP;

             END IF; -- if trxn count <> 0

         END IF; -- if bep type = PROCESSOR

         iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

         IF (l_batches_tab.COUNT <> 0) THEN

             FOR i IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP
		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Going to insert batch for mbatchid'
	                     || l_batches_tab(i).mbatch_id);

                 END IF;

                 INSERT INTO
                     iby_batches_all
                 (
                 MBATCHID,
                 BATCHID,
                 MPAYEEID,
                 PAYEEID,
                 BEPID,
                 BEPKEY,
                 PAYMENTMETHODNAME,
                 BATCHSTATUS,
                 BATCHCLOSEDATE,
                 VPSBATCHID,
                 CURRENCYNAMECODE,
                 NUMTRXNS,
                 BATCHSTATEID,
                 BATCHTOTAL,
                 BATCHSALES,
                 BATCHCREDIT,
                 GWBATCHID,
                 BEPCODE,
                 BEPMESSAGE,
                 ERRORLOCATION,
                 TERMINALID,
                 ACQUIRER,
                 REQTYPE,
                 REQDATE,
                 PROCESS_PROFILE_CODE,
                 INSTRUMENT_TYPE,
                 BR_DISPUTED_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 OBJECT_VERSION_NUMBER,
                 PAYEEINSTRID,
                 LEGAL_ENTITY_ID,
                 ORG_ID,
                 ORG_TYPE,
                 SETTLEDATE
                 )
                 VALUES
                 (
                 l_batches_tab(i).mbatch_id,
                 merch_batchid_in || '_' || i,
                 l_mpayeeid,
                 merchant_id_in,
                 vendor_id_in,
                 l_batches_tab(i).bep_key,
                 pmt_type_in,
                 status_in,
                 time_in,
                 viby_batchid_in,
                 l_batches_tab(i).curr_code,
                 0,
                 batchstate_in,
                 batchtotal_in,
                 saleamount_in,
                 cramount_in,
                 gwid_in,
                 vendor_code_in,
                 vendor_message_in,
                 error_location_in,
                 terminal_id_in,
                 Acquirer_id_in,
                 req_type_in,
                 sysdate,
                 l_batches_tab(i).profile_code,
                 instr_type_in,
                 br_disputed_flag_in,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 fnd_global.login_id,
                 1,
                 l_batches_tab(i).int_bank_acct_id,
                 l_batches_tab(i).le_id,
                 l_batches_tab(i).org_id,
                 l_batches_tab(i).org_type,
                 l_batches_tab(i).settle_date
                 );

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'finished insert '
	                     || 'for batch id '
	                     || l_batches_tab(i).mbatch_id
	                     );

                 END IF;
                 validate_open_batch(
                     vendor_id_in,
                     l_batches_tab(i).mbatch_id,
                     sec_key_present_in,
                     l_trxncount,
                     l_batchcurr);

                 UPDATE
                     IBY_BATCHES_ALL
                 SET
                     currencynamecode = l_batchcurr,
                     numtrxns = l_trxncount
                 WHERE
                     mbatchid = l_batches_tab(i).mbatch_id
                 ;

                 /*
                  * Store the created mbatchids in the output param
                  * to return to the caller.
                  */
                 mbatch_ids_out.EXTEND;
                 mbatch_ids_out(i) := l_batches_tab(i).mbatch_id;

                 /*
                  * Store the created batchids in the output param
                  * to return to the caller.
                  */
                 batch_ids_out.EXTEND;
                 batch_ids_out(i) := l_batches_tab(i).batch_id;

             END LOOP;

         END IF; -- if l_batches_tab.COUNT <> 0

     ELSIF (numrows = 1) THEN

         l_trxncount := numtrxns_in;

         IF (l_trxncount<1) THEN
            l_trxncount := NULL;
         END IF;

         /* One previous transaction, so update previous row */
         UPDATE
             IBY_BATCHES_ALL
         SET
             PAYMENTMETHODNAME = pmt_type_in,
             BATCHSTATUS = status_in,
             BATCHCLOSEDATE = time_in,
             CURRENCYNAMECODE = NVL(currency_in,CURRENCYNAMECODE),
             NUMTRXNS = NVL(l_trxncount,NUMTRXNS),
             BATCHSTATEID = batchstate_in,
             BATCHTOTAL = batchtotal_in,
             BATCHSALES = saleamount_in,
             BATCHCREDIT = cramount_in,
             GWBATCHID = gwid_in,
             BEPCODE = vendor_code_in,
             BEPMESSAGE = vendor_message_in,
             ERRORLOCATION = error_location_in,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = fnd_global.user_id,

             -- Do not update creation timestamp
             -- when updating records: Bug 3128675
	     --CREATION_DATE = sysdate,
	     --CREATED_BY = fnd_global.user_id,

             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
         WHERE
             batchid = merch_batchid_in AND
             payeeid = merchant_id_in
         ;

	 IF ((req_type_in = 'ORAPMTCLOSEBATCH') OR
             (req_type_in = 'ORAPMTPDCCLOSEBATCH') ) THEN

             -- we don't update the following for querybatch
             UPDATE
                 iby_batches_all
             SET
                 VPSBATCHID = viby_batchid_in,
                 reqtype = req_type_in,
                 reqdate = sysdate
             WHERE
                 batchid = merch_batchid_in  AND
                 payeeid = merchant_id_in;

         END IF;

         --SELECT mbatchid
         --INTO mbatchid_out
         --FROM iby_batches_all
         --WHERE batchid = merch_batchid_in
         --AND payeeid = merchant_id_in;

         /*
          * Pick up all mbatchids for the given (batch id, merchant id,
          * account profile) combination.
          *
          * Since this is a retry, and retry is only applicable to a
          * specific batch, we should be getting only one mbatchid.
          */
         OPEN  c_mbatch_ids (merch_batchid_in, merchant_id_in, profile_code_in);
         FETCH c_mbatch_ids BULK COLLECT INTO l_mbatch_ids_out;
         CLOSE c_mbatch_ids;

         IF (l_mbatch_ids_out.COUNT <> 0) THEN

             FOR i IN l_mbatch_ids_out.FIRST .. l_mbatch_ids_out.LAST LOOP

                 /*
                  * In the retry scenario, the user will provide
                  * the batch id to retry explicitly. So in the
                  * retry case, we will returning only one batch id
                  * and one mbatch id.
                  */

                 mbatch_ids_out.EXTEND;
                 mbatch_ids_out(i) := l_mbatch_ids_out(i);

                 batch_ids_out.EXTEND;
                 batch_ids_out(i)  := merch_batchid_in;

             END LOOP;

         END IF;

     ELSE

         -- will never run into this block
         -- More than one pending transaction, which is an
         -- error
         raise_application_error(-20000, 'IBY_20422#', FALSE);

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'mbatchids out count: '
	       || mbatch_ids_out.COUNT);

     END IF;
     COMMIT;

 EXCEPTION

     WHEN OTHERS THEN
         ROLLBACK;
         --
         -- rethrow any internally generated exception
         --
         --raise_application_error(SQLCODE, SQLERRM, FALSE);
         RAISE;

 END insert_batch_status_new;


/*--------------------------------------------------------------------
 | NAME:
 |     insert_batch_status_new
 |
 | PURPOSE:
 |     This is an Overloaded API of the previous one. This one
 |     takes an Array of Account FC profiles instead of a single on.
 |     This virtually means that we are accepting multiple bep keys in the API.
 |     THis will turn on the feature where we will have multiple divisions per
 |     Settlement Batch file.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
  PROCEDURE insert_batch_status_new
  (
  merch_batchid_in    IN     iby_batches_all.batchid%TYPE,
  profile_code_array  IN     JTF_VARCHAR2_TABLE_100,
  merchant_id_in      IN     iby_batches_all.payeeid%TYPE,
  vendor_id_in        IN     iby_batches_all.bepid%TYPE,
  vendor_key_in       IN     iby_batches_all.bepkey%TYPE,
  pmt_type_in         IN     iby_batches_all.paymentmethodname%TYPE,
  status_in           IN     iby_batches_all.batchstatus%TYPE,
  time_in             IN     iby_batches_all.batchclosedate%TYPE,
  viby_batchid_in     IN     iby_batches_all.vpsbatchid%TYPE ,
  currency_in         IN     iby_batches_all.currencynamecode%TYPE,
  numtrxns_in         IN     iby_batches_all.NumTrxns%TYPE,
  batchstate_in	      IN     iby_batches_all.BatchStateid%TYPE,
  batchtotal_in	      IN     iby_batches_all.BatchTotal%TYPE,
  saleamount_in	      IN     iby_batches_all.BatchSales%TYPE,
  cramount_in	      IN     iby_batches_all.BatchCredit%TYPE,
  gwid_in             IN     iby_batches_all.GWBatchID%TYPE,
  vendor_code_in      IN     iby_batches_all.BEPcode%TYPE,
  vendor_message_in   IN     iby_batches_all.BEPmessage%TYPE,
  error_location_in   IN     iby_batches_all.errorlocation%TYPE,
  terminal_id_in      IN     iby_batches_all.TerminalId%TYPE,
  acquirer_id_in      IN     iby_batches_all.Acquirer%TYPE,
  org_id_in           IN     iby_trxn_summaries_all.org_id%TYPE,
  req_type_in         IN     iby_batches_all.reqtype%TYPE,
  sec_key_present_in  IN     VARCHAR2,
  acct_profile_in     IN     iby_batches_all.process_profile_code%TYPE,
  instr_type_in       IN     iby_batches_all.instrument_type%TYPE,
  br_disputed_flag_in IN     iby_batches_all.br_disputed_flag%TYPE,
  f_pmt_channel_in    IN     iby_trxn_summaries_all.
                                 payment_channel_code%TYPE,
  f_curr_in           IN     iby_trxn_summaries_all.
                                 currencynamecode%TYPE,
  f_settle_date       IN     iby_trxn_summaries_all.
                                 settledate%TYPE,
  f_due_date          IN     iby_trxn_summaries_all.
                                 settlement_due_date%TYPE,
  f_maturity_date     IN     iby_trxn_summaries_all.
                                 br_maturity_date%TYPE,
  f_instr_type        IN     iby_trxn_summaries_all.
                                 instrtype%TYPE,
  mbatch_ids_out      OUT    NOCOPY JTF_NUMBER_TABLE,
  batch_ids_out       OUT    NOCOPY JTF_VARCHAR2_TABLE_100
  )
  IS

  numrows NUMBER;

  l_mpayeeid  iby_payee.mpayeeid%type;
  l_mbatchid  iby_batches_all.mbatchid%type;
  l_beptype   iby_bepinfo.bep_type%TYPE;
  l_trxncount iby_batches_all.numtrxns%TYPE;
  l_batchcurr iby_batches_all.currencynamecode%TYPE;
--  profile_code_in   iby_batches_all.process_profile_code%TYPE;
  numProfiles NUMBER;
  strProfCodes VARCHAR2(200);

  l_pinlessdebitcard  CONSTANT VARCHAR2(100) :='PINLESSDEBITCARD';

  l_batches_tab         batchAttrTabType;
  l_trxns_in_batch_tab  trxnsInBatchTabType;
  l_mbatch_ids_out      mBatchIdsTab;

  l_index               NUMBER;

  l_cursor_stmt         VARCHAR2(1000);
  TYPE dyn_batches      IS REF CURSOR;
  l_batch_cursor        dyn_batches;

  l_module_name         CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                              '.insert_batch_status_new';

  /*
   * Cursor to pick up all existing mbatchids for
   * a given (batch id, payee id, profile code)
   * combination.
   */
--  CURSOR c_mbatch_ids (batch_id   IBY_BATCHES_ALL.batchid%TYPE,
--                       payee_id   IBY_BATCHES_ALL.payeeid%TYPE,
--                       strProfiles VARCHAR2
--                       )
--  IS
--  SELECT
--      mbatchid
--  FROM
--      IBY_BATCHES_ALL
--  WHERE
--      batchid = batch_id                 AND
--      payeeid = payee_id                 AND
--      process_profile_code IN (strProfiles)
 -- ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER: overloaded API.');

     END IF;
     mbatch_ids_out := JTF_NUMBER_TABLE();
     batch_ids_out  := JTF_VARCHAR2_TABLE_100();

     /* Form a comma separated string for the profile codes */
     numProfiles := profile_code_array.count;
     FOR i IN 1..(numProfiles-1) LOOP
        strProfCodes := strProfCodes||''''||profile_code_array(i)||''',';
     END LOOP;
     /* Append the last profile code without comma at the end */
     strProfCodes := strProfCodes||''''||profile_code_array(numProfiles)||'''';
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Comma Separated string of profile codes: '|| strProfCodes);

     END IF;
     /*
      * Form the dynamic reference cursor to pick up
      * all existing mbatchids for a given (batchid,payeeid and
      * a string of profile codes)
      */
     l_cursor_stmt := ' SELECT mbatchid FROM                             '||
                      ' IBY_BATCHES_ALL WHERE                            '||
		      ' batchid = '''||merch_batchid_in||''' AND         '||
		      ' payeeid = '''||merchant_id_in||''' AND           '||
		      ' process_profile_code IN ('||strProfCodes||')     '
		      ;


     /* First check if a row already exists for this batch status */
     SELECT
         COUNT(*)
     INTO
         numrows
     FROM
         IBY_BATCHES_ALL
     WHERE
         batchid = merch_batchid_in AND
         payeeid = merchant_id_in
     ;

     /*
      * If row does not exist, then insert batch status into iby_batches_all
      */
     IF numrows = 0 THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'num rows is zero');

         END IF;
         --
         -- need to lock trxn summaries table to ensure that
         -- trxns which have not been validated do not sneak into
         -- the batch; gap between call to validate_open_batch
         -- and update of IBY_TRXN_SUMMARIES_ALL has been shown
         -- to be vulnerable to race conditions even under moderate
         -- concurrency loads
         --
         --LOCK TABLE iby_batches_all, iby_trxn_summaries_all IN EXCLUSIVE MODE;

         --SELECT iby_batches_s.NEXTVAL
         --  INTO l_mbatchid
         --FROM dual;

         --mbatchid_out := l_mbatchid;

         l_batchcurr := currency_in;-- should be made NULL
         l_trxncount := numtrxns_in;

         SELECT
             NVL(bep_type,iby_bepinfo_pkg.C_BEPTYPE_GATEWAY)
         INTO
             l_beptype
         FROM
             IBY_BEPINFO
         WHERE
             (bepid=vendor_id_in)
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'STEP 1');

         END IF;
         --
         -- if the bep is a processor, then we create a batch
         --
         IF (
             (l_beptype = iby_bepinfo_pkg.C_BEPTYPE_PROCESSOR) AND
             (
              (req_type_in = iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE) OR
              (req_type_in = iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE)
             )
            ) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Invoking grouping ..');

             END IF;
             /*
              * Group all the transactions for this profile into
              * batches as per the grouping attributes on the profile.
              */
             performTransactionGrouping(
                 profile_code_array,
                 instr_type_in,
                 req_type_in,
                 f_pmt_channel_in,
                 f_curr_in,
                 f_settle_date,
                 f_due_date,
                 f_maturity_date,
                 f_instr_type,
		 merch_batchid_in,
                 l_batches_tab,
                 l_trxns_in_batch_tab
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, '# batches created: '
	                 || l_batches_tab.COUNT);

	             print_debuginfo(l_module_name, '# transactions processed: '
	                 || l_trxns_in_batch_tab.COUNT);

             END IF;
             /*
              * After grouping it is possible that multiple batches were
              * created. Each batch will be a separate row in the
              * IBY_BATCHES_ALL table with a unique mbatchid.
              *
              * The user may have provided a batch id (batch prefix), we will
              * have to assign that batch id to each of the created batches.
              *
              * This batch id would be sent to the payment system. It therefore
              * has to be unique. Therefore, we add a suffix to the user
              * provided batch id to ensure that batches created after grouping
              * have a unique batch id.
              */
             --IF (l_batches_tab.COUNT > 0) THEN

                 --l_index := 1;
                 --FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

                     /*
                      * Assign a unique batch id to each batch.
                      */
                     --l_batches_tab(k).batch_id :=
                         --merch_batchid_in ||'_'|| l_index;
                     --l_index := l_index + 1;

                 --END LOOP;

             --END IF;

             /*
              * After grouping, the transactions will be assigned a mbatch id.
              * Assign them a batch id as well (based on the batch id
              * corresponding to each mbatch id).
              */
             /*IF (l_trxns_in_batch_tab.COUNT > 0) THEN

                 FOR m IN l_trxns_in_batch_tab.FIRST ..
                     l_trxns_in_batch_tab.LAST LOOP

                     FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP


                         IF (l_trxns_in_batch_tab(m).mbatch_id =
                             l_batches_tab(k).mbatch_id) THEN


                             l_trxns_in_batch_tab(m).batch_id :=
                                 l_batches_tab(k).batch_id;

                         END IF;

                     END LOOP;

                 END LOOP;

             END IF;*/

             /*
              * BEP and vendor related params.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'vendor_id_in: '
	                 || vendor_id_in);
             END IF;
             /* need to change since mulitiple keys could be present here*/
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'vendor_key_in: '
	                 || vendor_key_in);
	             print_debuginfo(l_module_name, 'merchant_id_in: '
	                 || merchant_id_in);
	             print_debuginfo(l_module_name, 'req_type_in: '
	                 || req_type_in);

             END IF;
             --
             -- associate all trxns in the current open batch
             -- with the batch id of the batch close
             --
             --IF (l_trxns_in_batch_tab.COUNT <> 0) THEN

                 --FOR i IN l_trxns_in_batch_tab.FIRST ..
                     --l_trxns_in_batch_tab.LAST LOOP

                     /*
                      * This SQL statement has been replaced by
                      * the SQL update statement (below). It is kept
                      * here for documentation purposes.
                      */
                     /*------------------------------------------
                     UPDATE
                         IBY_TRXN_SUMMARIES_ALL
                     SET
                         status = iby_transactioncc_pkg.C_STATUS_BATCH_PENDING,
                         batchid = merch_batchid_in
                                     || '_' || i,
                         mbatchid = l_trxns_in_batch_tab(i).mbatch_id,
                         last_update_date = sysdate,
                         updatedate = sysdate,
                         last_updated_by = fnd_global.user_id,
                         object_version_number = object_version_number + 1
                     WHERE
                         (bepid = vendor_id_in)     AND
                         (bepkey = vendor_key_in)   AND
                         (payeeid = merchant_id_in) AND
                         (status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED)i
                         AND
                         (
                           (instrtype IN
                               (iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                                iby_creditcard_pkg.C_INSTRTYPE_PCARD) AND
                           (req_type_in =
                               iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE))
                           OR
                           (instrtype IN (l_pinlessdebitcard) AND
                           (req_type_in = iby_transactioncc_pkg.
                                              C_REQTYPE_PDC_BATCHCLOSE)
                           )
                           OR
                           instrtype IS NULL
                         )
                         AND
                         (batchid IS NULL);
                     -------------------------------------------*/

                     --IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     --print_debuginfo(l_module_name, 'Going to update '
	                         --|| 'transaction ' || l_trxns_in_batch_tab(i).trxn_id);

                     --END IF;

                     /*UPDATE
                         IBY_TRXN_SUMMARIES_ALL
                     SET
                         status                = iby_transactioncc_pkg.
                                                     C_STATUS_BATCH_PENDING,
                         batchid               = l_trxns_in_batch_tab(i).
                                                     batch_id,
                         mbatchid              = l_trxns_in_batch_tab(i).
                                                     mbatch_id,
                         last_update_date      = sysdate,
                         updatedate            = sysdate,
                         last_updated_by       = fnd_global.user_id,
                         object_version_number = object_version_number + 1
                     WHERE
                         transactionid = l_trxns_in_batch_tab(i).trxn_id AND
                         status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED
                         ;*/

                     /*IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Finished updating '
	                         || 'transaction'
	                         || l_trxns_in_batch_tab(i).trxn_id
	                         );

                     END IF;*/
                 --END LOOP;

             --END IF; -- if trxn count <> 0

         END IF; -- if bep type = PROCESSOR

         iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

         IF (l_batches_tab.COUNT <> 0) THEN

             FOR i IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

                 --Bug# 9313298
		 --Assign the batch_id to the batches tab
		 l_batches_tab(i).batch_id:=  merch_batchid_in || '_' || i;

		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Going to insert batch for mbatchid'
	                     || l_batches_tab(i).mbatch_id);
			 print_debuginfo(l_module_name, 'Going to insert batch for batchid'
	                     || l_batches_tab(i).batch_id);

                 END IF;

                 INSERT INTO
                     iby_batches_all
                 (
                 MBATCHID,
                 BATCHID,
                 MPAYEEID,
                 PAYEEID,
                 BEPID,
                 BEPKEY,
                 PAYMENTMETHODNAME,
                 BATCHSTATUS,
                 BATCHCLOSEDATE,
                 VPSBATCHID,
                 CURRENCYNAMECODE,
                 NUMTRXNS,
                 BATCHSTATEID,
                 BATCHTOTAL,
                 BATCHSALES,
                 BATCHCREDIT,
                 GWBATCHID,
                 BEPCODE,
                 BEPMESSAGE,
                 ERRORLOCATION,
                 TERMINALID,
                 ACQUIRER,
                 REQTYPE,
                 REQDATE,
                 PROCESS_PROFILE_CODE,
                 INSTRUMENT_TYPE,
                 BR_DISPUTED_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 OBJECT_VERSION_NUMBER,
                 PAYEEINSTRID,
                 LEGAL_ENTITY_ID,
                 ORG_ID,
                 ORG_TYPE,
                 SETTLEDATE
                 )
                 VALUES
                 (
                 l_batches_tab(i).mbatch_id,
                 merch_batchid_in || '_' || i,
                 l_mpayeeid,
                 merchant_id_in,
                 vendor_id_in,
                 l_batches_tab(i).bep_key,-- should be made NULL
                 pmt_type_in,
                 status_in,
                 time_in,
                 viby_batchid_in,
                 l_batches_tab(i).curr_code,-- should be made NULL
                 0,
                 batchstate_in,
                 batchtotal_in,
                 saleamount_in,
                 cramount_in,
                 gwid_in,
                 vendor_code_in,
                 vendor_message_in,
                 error_location_in,
                 terminal_id_in,
                 Acquirer_id_in,
                 req_type_in,
                 sysdate,
                -- l_batches_tab(i).profile_code,-- should be made NULL
		 profile_code_array(1),
                 instr_type_in,
                 br_disputed_flag_in,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 fnd_global.login_id,
                 1,
                 l_batches_tab(i).int_bank_acct_id,
                 l_batches_tab(i).le_id,
                 l_batches_tab(i).org_id,
                 l_batches_tab(i).org_type,
                 l_batches_tab(i).settle_date
                 );

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'finished insert '
	                     || 'for mbatch id '
	                     || l_batches_tab(i).mbatch_id
	                     );

                 END IF;
                 validate_open_batch(
                     vendor_id_in,
                     l_batches_tab(i).mbatch_id,
                     sec_key_present_in,
                     l_trxncount,
                     l_batchcurr);

                 UPDATE
                     IBY_BATCHES_ALL
                 SET
                     currencynamecode = l_batchcurr,-- should be made NULL
                     numtrxns = l_trxncount
                 WHERE
                     mbatchid = l_batches_tab(i).mbatch_id
                 ;

                 /*
                  * Store the created mbatchids in the output param
                  * to return to the caller.
                  */
                 mbatch_ids_out.EXTEND;
                 mbatch_ids_out(i) := l_batches_tab(i).mbatch_id;

                 /*
                  * Store the created batchids in the output param
                  * to return to the caller.
                  */
                 batch_ids_out.EXTEND;
		 --print_debuginfo(l_module_name, 'l_batches_tab(i).batch_id:'|| l_batches_tab(i).batch_id);
                 batch_ids_out(i) := l_batches_tab(i).batch_id;
		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo(l_module_name, 'batch_ids_out:'|| batch_ids_out(i));
			print_debuginfo(l_module_name, 'mbatch_ids_out:'|| mbatch_ids_out(i));
		 END IF;

             END LOOP;

         END IF; -- if l_batches_tab.COUNT <> 0

     ELSIF (numrows = 1) THEN

         l_trxncount := numtrxns_in;

         IF (l_trxncount<1) THEN
            l_trxncount := NULL;
         END IF;

         /* One previous transaction, so update previous row */
         UPDATE
             IBY_BATCHES_ALL
         SET
             PAYMENTMETHODNAME = pmt_type_in,
             BATCHSTATUS = status_in,
             BATCHCLOSEDATE = time_in,
             CURRENCYNAMECODE = NVL(currency_in,CURRENCYNAMECODE),-- should be made NULL
             NUMTRXNS = NVL(l_trxncount,NUMTRXNS),
             BATCHSTATEID = batchstate_in,
             BATCHTOTAL = batchtotal_in,
             BATCHSALES = saleamount_in,
             BATCHCREDIT = cramount_in,
             GWBATCHID = gwid_in,
             BEPCODE = vendor_code_in,
             BEPMESSAGE = vendor_message_in,
             ERRORLOCATION = error_location_in,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = fnd_global.user_id,

             -- Do not update creation timestamp
             -- when updating records: Bug 3128675
	     --CREATION_DATE = sysdate,
	     --CREATED_BY = fnd_global.user_id,

             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
         WHERE
             batchid = merch_batchid_in AND
             payeeid = merchant_id_in
         ;

	 IF ((req_type_in = 'ORAPMTCLOSEBATCH') OR
             (req_type_in = 'ORAPMTPDCCLOSEBATCH') ) THEN

             -- we don't update the following for querybatch
             UPDATE
                 iby_batches_all
             SET
                 VPSBATCHID = viby_batchid_in,
                 reqtype = req_type_in,
                 reqdate = sysdate
             WHERE
                 batchid = merch_batchid_in  AND
                 payeeid = merchant_id_in;

         END IF;

         --SELECT mbatchid
         --INTO mbatchid_out
         --FROM iby_batches_all
         --WHERE batchid = merch_batchid_in
         --AND payeeid = merchant_id_in;

         /*
          * Pick up all mbatchids for the given (batch id, merchant id,
          * account profile) combination.
          *
          * Since this is a retry, and retry is only applicable to a
          * specific batch, we should be getting only one mbatchid.
          */
  --       OPEN  c_mbatch_ids (merch_batchid_in, merchant_id_in, strProfCodes);
  --       FETCH c_mbatch_ids BULK COLLECT INTO l_mbatch_ids_out;
  --       CLOSE c_mbatch_ids;

           OPEN l_batch_cursor FOR l_cursor_stmt;
	   FETCH l_batch_cursor BULK COLLECT INTO l_mbatch_ids_out;
	   CLOSE l_batch_cursor;

         IF (l_mbatch_ids_out.COUNT <> 0) THEN

             FOR i IN l_mbatch_ids_out.FIRST .. l_mbatch_ids_out.LAST LOOP

                 /*
                  * In the retry scenario, the user will provide
                  * the batch id to retry explicitly. So in the
                  * retry case, we will returning only one batch id
                  * and one mbatch id.
                  */

                 mbatch_ids_out.EXTEND;
                 mbatch_ids_out(i) := l_mbatch_ids_out(i);

                 batch_ids_out.EXTEND;
                 batch_ids_out(i)  := merch_batchid_in;

             END LOOP;

         END IF;

     ELSE

         -- will never run into this block
         -- More than one pending transaction, which is an
         -- error
         raise_application_error(-20000, 'IBY_20422#', FALSE);

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'mbatchids out count: '
	       || mbatch_ids_out.COUNT);
	     print_debuginfo(l_module_name, 'batchids out count: '
	       || batch_ids_out.COUNT);

     END IF;
     COMMIT;

 EXCEPTION

     WHEN OTHERS THEN
         ROLLBACK;
         --
         -- rethrow any internally generated exception
         --
         --raise_application_error(SQLCODE, SQLERRM, FALSE);
         RAISE;

 END insert_batch_status_new;



/*--------------------------------------------------------------------
 | NAME:
 |     performTransactionGrouping
 |
 | PURPOSE:
 |
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performTransactionGrouping(
     p_profile_code       IN IBY_FNDCPT_USER_CC_PF_B.
                                 user_cc_profile_code%TYPE,
     instr_type           IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     req_type             IN IBY_BATCHES_ALL.
                                 reqtype%TYPE,
     f_pmt_channel_in     IN IBY_TRXN_SUMMARIES_ALL.
                                 payment_channel_code%TYPE,
     f_curr_in            IN IBY_TRXN_SUMMARIES_ALL.
                                 currencynamecode%TYPE,
     f_settle_date        IN IBY_TRXN_SUMMARIES_ALL.
                                 settledate%TYPE,
     f_due_date           IN IBY_TRXN_SUMMARIES_ALL.
                                 settlement_due_date%TYPE,
     f_maturity_date      IN IBY_TRXN_SUMMARIES_ALL.
                                 br_maturity_date%TYPE,
     f_instr_type         IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     x_batchTab           IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            batchAttrTabType,
     x_trxnsInBatchTab    IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            trxnsInBatchTabType
     )
 IS
 l_module_name           CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                  '.performTransactionGrouping';

 l_sql_str               VARCHAR2(5000);
 l_cursor_stmt           VARCHAR2(8000);

 l_first_record          VARCHAR2(1)   := 'Y';

 /* user defined grouping rule flags */
 l_org_flag              VARCHAR2(1)   := 'N';
 l_le_flag               VARCHAR2(1)   := 'N';
 l_int_bnk_flag          VARCHAR2(1)   := 'N';
 l_curr_flag             VARCHAR2(1)   := 'N';
 l_settle_date_flag      VARCHAR2(1)   := 'N';

 /* user defined limits */
 l_max_trxn_limit        NUMBER(15)    := 0;
 l_fx_rate_type          VARCHAR2(255) := '';
 l_fx_curr_code          VARCHAR2(10)  := '';
 l_max_amount_limit      NUMBER(15)    := 0;

 /*
  * NOTE:
  *
  * IBY_BATCHES_ALL.batchid  = user generated batch id
  * IBY_BATCHES_ALL.mbatchid = system generated batch id
  *
  * If batch close is invoked by the user, the batchid will
  * be a user defined string (should be unique).
  *
  * If batch close is invoked by the scheduler, the batch is
  * be a sequence number (iby_batchid_s.nextval).
  *
  * mbatchid will always be a sequence number (iby_batchid_s.nextval).
  *
  * In the new architecture, multiple mbatchids can be generated
  * for a single batchid (based on user defined grouping rules).
  */
 l_mbatch_id             IBY_BATCHES_ALL.mbatchid%TYPE;
 l_batch_total           NUMBER(15)    := 0;
 l_trxns_in_batch_count  NUMBER(15)    := 0;

 l_trx_fx_amount         NUMBER(15)    := 0;

 /*
  * Used to substitute null values in date comparisons.
  * It is assumed that not document payable would ever
  * have a year 1100 date.
  */
 l_impossible_date       DATE := TO_DATE('01/01/1100 10:25:55',
                                     'MM/DD/YYYY HH24:MI:SS');

 /*
  * These two are related data structures. Each row in batchAttrTabType
  * PLSQL table is used in inserting a row into the IBY_BATCHES_ALL
  * table.
  *
  * A separate data structure is needed to keep track of the transactions
  * that are part of a batch. This information is tracked in the
  * trxnsInBatchTabType table. The rows in trxnsInBatchTabType are
  * used to update the rows in IBY_TRXN_SUMMARIES_ALL table with
  * batch ids.
  *
  *            l_batchTab                        l_trxnsInBatchTab
  *       (insert into IBY_BATCHES_ALL)   (update IBY_TRXN_SUMMARIES_ALL)
  * /-------------------------------------\       /------------\
  * |MBatch |Profile|..|Curr   |Org    |..|       |MBatch |Trx |
  * |Id     |Code   |..|Code   |Id     |..|       |Id     |Id  |
  * |       |       |..|       |       |..|       |       |    |
  * |-------------------------------------|       |------------|
  * |   4000|     10|  |    USD|    204|  |       |   4000| 501|
  * |       |       |  |       |       |  |       |   4000| 504|
  * |       |       |  |       |       |  |       |   4000| 505|
  * |-------|-------|--|-------|-------|--|       |-------|----|
  * |   4001|     11|  |    -- |    342|  |       |   4001| 502|
  * |       |       |  |       |       |  |       |   4001| 509|
  * |       |       |  |       |       |  |       |   4001| 511|
  * |       |       |  |       |       |  |       |   4001| 523|
  * |       |       |  |       |       |  |       |     : |  : |
  * |-------|-------|--|-------|-------|--|       |-------|----|
  * |    :  |     : |  |    :  |     : |  |       |     : |  : |
  * \_______|_______|__|_______|_______|__/       \_______|____/
  *
  */

 l_batchRec          IBY_TRANSACTIONCC_PKG.batchAttrRecType;
 l_trxnsInBatchTab   IBY_TRANSACTIONCC_PKG.trxnsInBatchTabType;

 l_trxnsInBatchRec   IBY_TRANSACTIONCC_PKG.trxnsInBatchRecType;
 l_batchTab          IBY_TRANSACTIONCC_PKG.batchAttrTabType;

 l_trxnGrpCriTab     IBY_TRANSACTIONCC_PKG.trxnGroupCriteriaTabType;

 l_pinlessdebitcard  CONSTANT VARCHAR2(100) :='PINLESSDEBITCARD';
 l_bankaccount       CONSTANT VARCHAR2(100) :='BANKACCOUNT';

 /* previous transaction attributes */
 prev_trxn_id                iby_trxn_summaries_all.transactionid%TYPE;
 prev_trxn_currency          iby_trxn_summaries_all.currencynamecode%TYPE;
 prev_trxn_amount            iby_trxn_summaries_all.amount%TYPE;
 prev_int_bank_acct_id       iby_trxn_summaries_all.payeeinstrid%TYPE;
 prev_org_id                 iby_trxn_summaries_all.org_id%TYPE;
 prev_org_type               iby_trxn_summaries_all.org_type%TYPE;
 prev_settle_date            iby_trxn_summaries_all.settledate%TYPE;
 prev_le_id                  iby_trxn_summaries_all.legal_entity_id%TYPE;
 prev_bep_key                iby_trxn_summaries_all.bepkey%TYPE;
 prev_profile_cd             iby_trxn_summaries_all.process_profile_code%TYPE;

 /* current transaction attributes */
 curr_trxn_id                iby_trxn_summaries_all.transactionid%TYPE;
 curr_trxn_currency          iby_trxn_summaries_all.currencynamecode%TYPE;
 curr_trxn_amount            iby_trxn_summaries_all.amount%TYPE;
 curr_int_bank_acct_id       iby_trxn_summaries_all.payeeinstrid%TYPE;
 curr_org_id                 iby_trxn_summaries_all.org_id%TYPE;
 curr_org_type               iby_trxn_summaries_all.org_type%TYPE;
 curr_settle_date            iby_trxn_summaries_all.settledate%TYPE;
 curr_le_id                  iby_trxn_summaries_all.legal_entity_id%TYPE;
 curr_bep_key                iby_trxn_summaries_all.bepkey%TYPE;
 curr_profile_cd             iby_trxn_summaries_all.process_profile_code%TYPE;
 l_user_pf_table_name        VARCHAR2(100);
 l_sys_pf_table_name         VARCHAR2(100);
 l_user_pf_column_name       VARCHAR2(100);
 l_sys_pf_column_name        VARCHAR2(100);

 l_numeric_char_mask         VARCHAR2(100);

 TYPE dyn_transactions       IS REF CURSOR;
 l_trxn_cursor               dyn_transactions;

 /*
  * This cursor up will pick up all valid transactions for
  * the specified payment profile. The select statement will
  * order the transactions based on grouping criteria.
  *
  * Important Note:
  *
  * Always ensure that there is a corresponding order by
  * clause for each grouping criterion that you wish to use.
  * This is required in order to create minimum possible
  * batches from a given set of transactions.
  *
  * Note 2: The sample sql is not right as the base table for
  * process profile is different
  * the dynamic sql is changed according to that
  */
 CURSOR c_transactions (
            p_profile_code VARCHAR2,
            p_instr_type   VARCHAR2,
            p_req_type     VARCHAR2
            )
 IS
 SELECT
     txn.transactionid,
     txn.process_profile_code,
     txn.bepkey,
     txn.org_id,
     txn.org_type,
     txn.currencynamecode,
     txn.amount,
     txn.legal_entity_id,
     txn.payeeinstrid,
     txn.settledate,
     sys_prof.group_by_org,
     sys_prof.group_by_legal_entity,
     sys_prof.group_by_int_bank_account,
     sys_prof.group_by_settlement_curr,
     sys_prof.group_by_settlement_date,
     sys_prof.limit_by_amt_curr,
     sys_prof.limit_by_exch_rate_type,
     sys_prof.limit_by_total_amt,
     sys_prof.limit_by_settlement_num
 FROM
     IBY_TRXN_SUMMARIES_ALL  txn,
     IBY_FNDCPT_USER_CC_PF_B user_prof,
     IBY_FNDCPT_SYS_CC_PF_B  sys_prof
 WHERE
     user_prof.user_cc_profile_code = p_profile_code               AND
     txn.process_profile_code     = user_prof.user_cc_profile_code AND
     sys_prof.sys_cc_profile_code = user_prof.sys_cc_profile_code  AND
     txn.status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED      AND
     (
         /*
          * This clause will pick up credit card / purchase card
          * transactions.
          */
         (
             p_instr_type IN
             (
                 iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                 iby_creditcard_pkg.C_INSTRTYPE_PCARD
             )
             AND
             (
                 txn.reqtype IN
                 (
                 iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE,
                 iby_transactioncc_pkg.C_REQTYPE_CAPTURE,
                 iby_transactioncc_pkg.C_REQTYPE_CREDIT,
                 iby_transactioncc_pkg.C_REQTYPE_RETURN
                 )
             )
             AND
             (
                 txn.instrtype IN
                 (
                 iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                 iby_creditcard_pkg.C_INSTRTYPE_PCARD
                 )
             )
         )

         /*
          * This clause will pick up pinless debit card
          * transactions.
          */
         OR
         (
             p_instr_type IN
             (
                 l_pinlessdebitcard
             )
             AND
             (
                 txn.reqtype IN
                 (
                 iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE,
                 iby_transactioncc_pkg.C_REQTYPE_REQUEST
                 )
             )
             AND
             (
                 txn.instrtype IN
                 (
                 l_pinlessdebitcard
                 )
             )
         )

         /*
          * This clause will pick up bank account transactions
          * transactions.
          */
         OR
         (
             p_instr_type IN
             (
                 l_bankaccount
             )
             AND
             (
                 txn.reqtype IN
                 (
                 iby_transactioncc_pkg.C_REQTYPE_EFT_BATCHCLOSE,
                 iby_transactioncc_pkg.C_REQTYPE_BATCHREQ
                 )
             )
             AND
             (
                 txn.instrtype IN
                 (
                 l_bankaccount
                 )
             )

             /*
              * Fix for bug 5442922:
              *
              * For bank account instruments, the auth / verify
              * transaction will have trantypeid 20; The
              * capture transaction will have trxntypeid 100.
              *
              * Since we are picking up only capture transactions
              * here, explicitly specify the trxntypeid in the
              * WHERE clause. Otherwise, auths are also picked
              * up and put into the batch.
              */
             AND
             (
                 /*
                  * This trxn type 100 maps to
                  * IBY_FNDCPT_TRXN_PUB.BA_CAPTURE_TRXNTYPE
                  */
                 txn.trxntypeid = 100
             )
         )

         /*
          * This clause will pick up any transaction which does not
          * have an instrument type. This looks dangerous to me but
          * kept for backward compatibility - Ramesh
          */
         OR
         (
             txn.instrtype IS NULL
         )
     )                                                             AND
     txn.batchid IS NULL                                           AND
     /*
      *  Fix for bug 5632947:
      *
      *  Join with CE_SECURITY_PROFILES_V for MOAC compliance.
      */
     ((txn.org_id IS NULL) OR
     ((txn.org_id IS NOT NULL) AND
     (txn.org_id, txn.org_type) IN
         (SELECT
              ce.organization_id,
              ce.organization_type
          FROM
              ce_security_profiles_v ce
         )))
 ORDER BY
     txn.process_profile_code,   --
     txn.bepkey,                 -- Ensure that the
     txn.org_id,                 -- grouping rules below
     txn.org_type,               -- follow this same
     txn.legal_entity_id,        -- order (necessary
     txn.payeeinstrid,           -- for creating minimum
     txn.currencynamecode,       -- number of batches)
     txn.settledate              --
 ;


 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Payment Profile Cd: '||
	         p_profile_code);
	     print_debuginfo(l_module_name, 'Instrument Type: '   ||
	         instr_type);
	     print_debuginfo(l_module_name, 'Request Type: '      ||
	         req_type);

     END IF;
     /*
      * Filter params.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'f_pmt_channel_in: '
	         || f_pmt_channel_in);
	     print_debuginfo(l_module_name, 'f_curr_in: '
	         || f_curr_in);
	     print_debuginfo(l_module_name, 'f_settle_date: '
	         || f_settle_date);
	     print_debuginfo(l_module_name, 'f_due_date: '
	         || f_due_date);
	     print_debuginfo(l_module_name, 'f_maturity_date: '
	         || f_maturity_date);
	     print_debuginfo(l_module_name, 'f_instr_type: '
	         || f_instr_type);

     END IF;
     /*
      * Fix for bug 5407120:
      *
      * Before we do anything, alter the session to set the numeric
      * character mask. This is because of XML publisher limitation -
      * it cannot handle numbers like '230,56' which is the European
      * representation of '230.56'.
      *
      * Therefore, we explicitly set the numeric character mask at the
      * beginning of this routine and revert back to the default
      * setting at the end of this method.
      */
     BEGIN

         SELECT
             value
         INTO
             l_numeric_char_mask
         FROM
             V$NLS_PARAMETERS
         WHERE
             parameter='NLS_NUMERIC_CHARACTERS'
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Current numeric char mask: '
	             || l_numeric_char_mask
	             );

         END IF;
     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	                 || 'when attempting to retrieve numeric character mask.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
     END;

     /*
      * Now alter the session, to force the NLS numeric character
      * decimal indicator to be a '.'.
      */
     BEGIN

         EXECUTE IMMEDIATE
             'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,"'
             ;

     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	                 || 'when attempting to later session to set '
	                 || 'numeric character mask.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
     END;

     /*
      * Dynamically form SQL string to limit the rows that
      * are picked up for the batch close operation.
      *
      * Use the supplied filter parameters to form the SQL
      * string.
      */
     IF (f_pmt_channel_in IS NOT NULL) THEN
     l_sql_str:= l_sql_str||'AND nvl(payment_channel_code'''||f_pmt_channel_in||''') = '
                          || '''' || f_pmt_channel_in || '''';
     END IF;

     IF (f_curr_in IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND currencynamecode = '
                          || '''' || f_curr_in || '''';
     END IF;

     IF (f_settle_date IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND nvl(settledate,'''||f_settle_date||''') <= '
                          || '''' || f_settle_date || '''';
     END IF;

     IF (f_due_date IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND settlement_due_date <= '
                          || '''' || f_due_date || '''';
     END IF;

     IF (f_maturity_date IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND br_maturity_date <= '
                          || '''' || f_maturity_date || '''';
     END IF;

     IF (f_instr_type IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND nvl(instrtype,'''||f_instr_type||''') = '
                          || '''' || f_instr_type || '''';
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Dynamic SQL snippet: '
	         || l_sql_str);

     END IF;
    /* determine the process profile table and column */

     l_user_pf_table_name :='IBY_FNDCPT_USER_CC_PF_B';
     l_sys_pf_table_name  :='IBY_FNDCPT_SYS_CC_PF_B';
     l_user_pf_column_name :='USER_CC_PROFILE_CODE';
     l_sys_pf_column_name :='SYS_CC_PROFILE_CODE';
  IF (instr_type IS NOT NULL) THEN
       if(instr_type =l_bankaccount) THEN
                    l_user_pf_table_name :='IBY_FNDCPT_USER_EFT_PF_B';
                    l_sys_pf_table_name  :='IBY_FNDCPT_SYS_EFT_PF_B';
                    l_user_pf_column_name :='USER_EFT_PROFILE_CODE';
                    l_sys_pf_column_name :='SYS_EFT_PROFILE_CODE';
       ELSIF  (instr_type =l_pinlessdebitcard) THEN
                    l_user_pf_table_name :='IBY_FNDCPT_USER_DC_PF_B';
                    l_sys_pf_table_name  :='IBY_FNDCPT_SYS_DC_PF_B';
                    l_user_pf_column_name :='USER_DC_PROFILE_CODE';
                    l_sys_pf_column_name :='SYS_DC_PROFILE_CODE';
       END IF;

   END IF;
     /*
      * The cursor below is the same as the cursor c_transactions
      * defined at the beginning of this method.
      *
      * We cannot directly use c_transactions because we need to use
      * the provided filter params to form a dynamic where clause.
      *
      * For this reason, this cursor has been made into a dynamic cursor.
      * c_transactions is kept for documentation / debugging purposes
      * but is not used.
      */
     l_cursor_stmt :=
     'SELECT '
         || 'txn.transactionid,                  '
         || 'txn.process_profile_code,           '
         || 'txn.bepkey,                         '
         || 'txn.org_id,                         '
         || 'txn.org_type,                       '
         || 'txn.currencynamecode,               '
         || 'txn.amount,                         '
         || 'txn.legal_entity_id,                '
         || 'txn.payeeinstrid,                   '
         || 'txn.settledate,                     '
         || 'sys_prof.group_by_org,              '
         || 'sys_prof.group_by_legal_entity,     '
         || 'sys_prof.group_by_int_bank_account, '
         || 'sys_prof.group_by_settlement_curr,  '
         || 'sys_prof.group_by_settlement_date,  '
         || 'sys_prof.limit_by_amt_curr,         '
         || 'sys_prof.limit_by_exch_rate_type,   '
         || 'sys_prof.limit_by_total_amt,        '
         || 'sys_prof.limit_by_settlement_num    '
     || 'FROM  '
         || 'IBY_TRXN_SUMMARIES_ALL  txn,        '
         || l_user_pf_table_name || '  user_prof,  '
         ||  l_sys_pf_table_name || '  sys_prof    '
     || 'WHERE '
         || 'user_prof.'||l_user_pf_column_name||'  = :profile_code     AND '
         || 'txn.process_profile_code     = user_prof.'||l_user_pf_column_name||'  AND '
         || 'sys_prof.' ||l_sys_pf_column_name||'   = user_prof. '||l_sys_pf_column_name || ' AND '
         || 'txn.status = :open_batch                                      AND '
         || '( '
             /*
              * This clause will pick up credit card / purchase card
              * transactions.
              */
             || '( '
                || ':A IN (:C1, :C2) AND (txn.reqtype IN (:T1A, :T1B, :T1C, :T1D)) AND '
                || '(txn.instrtype IN (:C3, :C4)) '
             || ') '

             /*
              * This clause will pick up pinless debit card
              * transactions.
              */
             || 'OR '
             || '( '
                 || ':C IN (:P1) AND (txn.reqtype IN (:T2A, :T2B)) AND '
                 || '(txn.instrtype IN (:P2)) '
             || ') '

             /*
              * This clause will pick up bank account transactions
              * transactions.
              */

             || 'OR '
             || '( '
                 || ':E IN (:B1) AND (txn.reqtype IN (:T3A, :T3B, :T3C)) AND '
                 || '(txn.instrtype IN (:B2)) '


                 /*
                  * Fix for bug 5442922:
                  *
                  * For bank account instruments, the auth / verify
                  * transaction will have trantypeid 20; The
                  * capture transaction will have trxntypeid 100.
                  *
                  * Since we are picking up only capture transactions
                  * here, explicitly specify the trxntypeid in the
                  * WHERE clause. Otherwise, auths are also picked
                  * up and put into the batch.
                  */
                 || 'AND '
                 || '( '
                     /*
                      * This trxn type 100 maps to
                      * IBY_FNDCPT_TRXN_PUB.BA_CAPTURE_TRXNTYPE
                      */
                     || 'txn.trxntypeid = 100 '
                 || ') '

             || ') '

             /*
              * This clause will pick up any transaction which does not
              * have an instrument type. This looks dangerous to me but
              * kept for backward compatibility - Ramesh
              */
             || 'OR '
             || '( '
                 || 'txn.instrtype IS NULL '
             || ') '
         || ')                                                             AND '
         || 'txn.batchid IS NULL                                           AND '
         /*
          *  Fix for bug 5632947:
          *
          *  Join with CE_SECURITY_PROFILES_V for MOAC compliance.
          */
         || '((txn.org_id IS NULL) OR '
         || '((txn.org_id IS NOT NULL) AND '
         || '(txn.org_id, txn.org_type) IN '
         || '    (SELECT '
         || '         ce.organization_id, '
         || '         ce.organization_type '
         || '     FROM  '
         || '         ce_security_profiles_v ce '
         || '    ))) '
         || NVL (l_sql_str, 'AND 1=1 ')
     || 'ORDER BY '
         || 'txn.process_profile_code, '  --
         || 'txn.bepkey,               '  -- Ensure that the
         || 'txn.org_id,               '  -- grouping rules below
         || 'txn.org_type,             '  -- follow this same
         || 'txn.legal_entity_id,      '  -- order (necessary
         || 'txn.payeeinstrid,         '  -- for creating minimum
         || 'txn.currencynamecode,     '  -- number of batches)
         || 'txn.settledate            '  --
     ;

     OPEN l_trxn_cursor FOR
         l_cursor_stmt
     USING
         p_profile_code,                                 /* profile_code */
         iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED,    /* open_batch */
         instr_type,                                     /* A */
         iby_creditcard_pkg.C_INSTRTYPE_CCARD,           /* C1 */
         iby_creditcard_pkg.C_INSTRTYPE_PCARD,           /* C2 */
         iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE,     /* T1A */
         iby_transactioncc_pkg.C_REQTYPE_CAPTURE,        /* T1B */
         iby_transactioncc_pkg.C_REQTYPE_CREDIT,         /* T1C */
         iby_transactioncc_pkg.C_REQTYPE_RETURN,         /* T1D */
         iby_creditcard_pkg.C_INSTRTYPE_CCARD,           /* C3 */
         iby_creditcard_pkg.C_INSTRTYPE_PCARD,           /* C4 */
         instr_type,                                     /* C */
         l_pinlessdebitcard,                             /* P1 */
         iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE, /* T2A */
         iby_transactioncc_pkg.C_REQTYPE_REQUEST,        /* T2B */
         l_pinlessdebitcard,                             /* P2 */
         instr_type,                                     /* E */
         l_bankaccount,                                  /* B1 */
         iby_transactioncc_pkg.C_REQTYPE_EFT_BATCHCLOSE, /* T3A */
         iby_transactioncc_pkg.C_REQTYPE_BATCHREQ,       /* T3B */
         iby_transactioncc_pkg.C_REQTYPE_REQUEST,        /* T3C */
         l_bankaccount                                   /* B2 */
         ;
     FETCH l_trxn_cursor BULK COLLECT INTO l_trxnGrpCriTab;
     CLOSE l_trxn_cursor;

     /*
      * Exit if no documents were found.
      */
     IF (l_trxnGrpCriTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No transactions were '
	             || 'retrieved from DB for profile '
	             || p_profile_code
	             || '. Exiting transaction grouping ..');

	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;
     ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, '# valid transactions '
	             || 'retrieved from DB for profile '
	             || p_profile_code
	             || ' = '
	             || l_trxnGrpCriTab.COUNT);
         END IF;
     END IF;

     /*
      * Loop through all the fetched documents, grouping them
      * into payments.
      */
     FOR i in l_trxnGrpCriTab.FIRST .. l_trxnGrpCriTab.LAST LOOP

         curr_trxn_id           := l_trxnGrpCriTab(i).trxn_id;
         curr_profile_cd        := l_trxnGrpCriTab(i).process_profile_code;
         curr_int_bank_acct_id  := l_trxnGrpCriTab(i).int_bank_acct_id;
         curr_bep_key           := l_trxnGrpCriTab(i).bep_key;
         curr_org_id            := l_trxnGrpCriTab(i).org_id;
         curr_org_type          := l_trxnGrpCriTab(i).org_type;
         curr_trxn_currency     := l_trxnGrpCriTab(i).curr_code;
         curr_trxn_amount       := l_trxnGrpCriTab(i).amount;
         curr_le_id             := l_trxnGrpCriTab(i).legal_entity_id;
         curr_settle_date       := l_trxnGrpCriTab(i).settle_date;

         l_org_flag             := l_trxnGrpCriTab(i).group_by_org;
         l_le_flag              := l_trxnGrpCriTab(i).group_by_le;
         l_int_bnk_flag         := l_trxnGrpCriTab(i).group_by_int_bank_acct;
         l_curr_flag            := l_trxnGrpCriTab(i).group_by_curr;
         l_settle_date_flag     := l_trxnGrpCriTab(i).group_by_settle_date;

         l_max_trxn_limit       := l_trxnGrpCriTab(i).num_trxns_limit;

         l_fx_rate_type         := l_trxnGrpCriTab(i).fx_rate_type;
         l_fx_curr_code         := l_trxnGrpCriTab(i).max_amt_curr;
         l_max_amount_limit     := l_trxnGrpCriTab(i).max_amt_limit;

         /*
          * Log all the fetched document fields
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name,
	             'Fetched data for transaction:' || curr_trxn_id
	             || ', internal bank account: ' || curr_int_bank_acct_id
	             || ', profile: '               || curr_profile_cd
	             || ', bep key: '               || curr_bep_key
	             || ', org: '                   || curr_org_id
	             || ', org type: '              || curr_org_type
	             || ', le:  '                   || curr_le_id
	             || ', currency: '              || curr_trxn_currency
	             || ', amount: '                || curr_trxn_amount
	             || ', settle date: '           || curr_settle_date
	             );

	         print_debuginfo(l_module_name,
	             'Fetched data for transaction:' || curr_trxn_id
	             || ', org flag: '               || l_org_flag
	             || ', le flag: '                || l_le_flag
	             || ', int bank acct flag: '     || l_int_bnk_flag
	             || ', currency flag: '          || l_curr_flag
	             || ', settle date flag: '       || l_settle_date_flag
	             || ', max trxns limit: '        || l_max_trxn_limit
	             || ', max amount limit: '       || l_max_amount_limit
	             || ', exch rate: '              || l_fx_rate_type
	             || ', exch currency: '          || l_fx_curr_code
	             );

         END IF;
         IF (l_first_record = 'Y') THEN
             prev_trxn_id              := curr_trxn_id;
             prev_int_bank_acct_id     := curr_int_bank_acct_id;
             prev_profile_cd           := curr_profile_cd;
             prev_org_id               := curr_org_id;
             prev_org_type             := curr_org_type;
             prev_le_id                := curr_le_id;
             prev_bep_key              := curr_bep_key;
             prev_trxn_currency        := curr_trxn_currency;
             prev_trxn_amount          := curr_trxn_amount;
             prev_settle_date          := curr_settle_date;
         END IF;

         /*
          * We have just fetched a new transaction for this profile.
          * We will either insert this transaction into a new batch or
          * we will be inserting this transaction into the currently running
          * batch.
          *
          * In either case, we need to insert this trxn into a batch.
          * So pre-populate the batch record with attributes of
          * this document. This is because the batch takes on the
          * attributes of its constituent transactions.
          *
          * Note: For user defined grouping rules, we will
          * have to populate the batch attributes only if
          * the user has turned on grouping by that attribute.
          */

         /* Only pre-fill hardcoded grouping rule attributes */
         l_batchRec.profile_code       := curr_profile_cd;
         l_batchRec.bep_key            := curr_bep_key;

         /*
          * Pre-fill grouping rule attributes for user defined
          * grouping rules (that are enabled by the user).
          *
          * It is necessary to pre-fill user defined grouping
          * attributes before the grouping rules are triggered
          * because we don't know which user defined grouping rules
          * are going to get triggered first, and once a rule is
          * triggered all rules below it are skipped. So it is too
          * late to populate grouping attributes within the grouping
          * rule itself.
          */
         IF (l_org_flag = 'Y') THEN
             l_batchRec.org_id   := curr_org_id;
             l_batchRec.org_type := curr_org_type;
         END IF;

         IF (l_le_flag = 'Y') THEN
             l_batchRec.le_id := curr_le_id;
         END IF;

         IF (l_int_bnk_flag = 'Y') THEN
             l_batchRec.int_bank_acct_id := curr_int_bank_acct_id;
         END IF;

         IF (l_curr_flag = 'Y') THEN
             l_batchRec.curr_code := curr_trxn_currency;
         END IF;

         IF (l_settle_date_flag = 'Y') THEN
             l_batchRec.settle_date := curr_settle_date;
         END IF;

         /*
          * Pre-fill the document record with the details
          * of the current document.
          */
         l_trxnsInBatchRec.trxn_id := curr_trxn_id;

         /*-- HARDCODED GROUPING RULES START HERE --*/

         /*
          * Grouping Step 1: Payment Profile Code
          */
         IF (prev_profile_cd <> curr_profile_cd) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Grouping by payment '
	                 || 'profile triggered for transaction '
	                 || curr_trxn_id);

             END IF;
             insertTrxnIntoBatch(l_batchRec, l_batchTab,
                 true, l_mbatch_id, l_trxnsInBatchTab,
                 l_trxnsInBatchRec, l_trxns_in_batch_count);

             GOTO label_finish_iteration;

         END IF;

         /*
          * Grouping Step 2: Payment System Account (Bep Key)
          */
         IF (prev_bep_key <> curr_bep_key) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Grouping by payment '
	                 || 'system account triggered for transaction '
	                 || curr_trxn_id);

             END IF;
             insertTrxnIntoBatch(l_batchRec, l_batchTab,
                 true, l_mbatch_id, l_trxnsInBatchTab,
                 l_trxnsInBatchRec, l_trxns_in_batch_count);

             GOTO label_finish_iteration;

         END IF;

         /*-- USER DEFINED GROUPING RULES START HERE --*/

         /*
          * Grouping Step 3: Organization ID And Organization Type
          */
         IF (l_org_flag = 'Y') THEN

             IF (prev_org_id <> curr_org_id)     OR
                (NVL(prev_org_type, 0) <> NVL(curr_org_type, 0)) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by organization '
	                     || 'id/type triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 3: Legal Entity ID
          */
         IF (l_le_flag = 'Y') THEN

             IF (prev_le_id <> curr_le_id) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by legal '
	                     || 'entity triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 4: Internal Bank Account ID
          */
         IF (l_int_bnk_flag = 'Y') THEN

             IF (prev_int_bank_acct_id <> curr_int_bank_acct_id) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by internal bank '
	                     || 'account triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 5: Settlement Currency
          */
         IF (l_curr_flag = 'Y') THEN

             IF (prev_trxn_currency <> curr_trxn_currency) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by settlement '
	                     || 'currency triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 6: Settlement Date
          */
         IF (l_settle_date_flag = 'Y') THEN

             IF (prev_settle_date <> curr_settle_date) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by settlement '
	                     || 'date triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 7: Max Transactions Per Batch
          */
         IF (l_max_trxn_limit IS NOT NULL) THEN

             IF (l_trxns_in_batch_count = l_max_trxn_limit) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'max trxns per batch triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 8: Max Amount Per Batch
          */
         IF (l_max_amount_limit IS NOT NULL) THEN

             IF (l_batch_total + l_trx_fx_amount > l_max_amount_limit) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'max batch amount triggered by transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * End Of Grouping:
          * If a transaction reaches here, it means that this transaction
          * is similar to the previous transaction as far a grouping
          * criteria is concerned.
          *
          * Add this transaction to the currently running batch.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No grouping rules '
	             || 'were triggered for transaction '
	             || curr_trxn_id);

         END IF;
         insertTrxnIntoBatch(l_batchRec, l_batchTab,
             false, l_mbatch_id, l_trxnsInBatchTab,
             l_trxnsInBatchRec, l_trxns_in_batch_count);


         <<label_finish_iteration>>

         /*
          * Lastly, before going into the next iteration
          * of the loop copy all the current grouping criteria
          * into 'prev' fields so that we can compare these
          * fields with the next record.
          *
          * No need to copy the current values into the previous ones for
          * the first record because we have already done it at the beginning.
          */
         IF (l_first_record <> 'Y') THEN
             prev_trxn_id           := curr_trxn_id;
             prev_profile_cd        := curr_profile_cd;
             prev_int_bank_acct_id  := curr_int_bank_acct_id;
             prev_bep_key           := curr_bep_key;
             prev_org_id            := curr_org_id;
             prev_org_type          := curr_org_type;
             prev_trxn_currency     := curr_trxn_currency;
             prev_trxn_amount       := curr_trxn_amount;
             prev_le_id             := curr_le_id;
             prev_settle_date       := curr_settle_date;
         END IF;

         /*
          *  Remember to reset the first record flag before going
          *  into the next iteration.
          */
         IF (l_first_record = 'Y') THEN
             l_first_record := 'N';
         END IF;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, '+----------------------------------+');

         END IF;
     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Created '
	         || l_batchTab.COUNT   || ' batch(s) from '
	         || l_trxnsInBatchTab.COUNT || ' transaction(s) for profile '
	         || p_profile_code || '.');

     END IF;
     /*
      * Finally, return the batches created by grouping to the caller.
      */
     x_batchTab        := l_batchTab;
     x_trxnsInBatchTab := l_trxnsInBatchTab;


     /*
      * Fix for bug 5407120:
      *
      * Revert back thenumeric character mask to its original
      * setting. See begininning of this methods for comments
      * regarding this issue.
      *
      */
     BEGIN

         IF (l_numeric_char_mask IS NOT NULL) THEN

             EXECUTE IMMEDIATE
                 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '
                    || '"'
                    || l_numeric_char_mask
                    || '"'
                 ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Reverted numeric char mask to: '
	                 || l_numeric_char_mask
	                 );

             END IF;
         END IF;

     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	                 || 'when attempting to revert numeric character mask.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END performTransactionGrouping;


/*--------------------------------------------------------------------
 | NAME:
 |     performTransactionGrouping
 |
 | PURPOSE:
 |     This is the Overloaded API for the earlier one. This will be invoked
 |     by the corresponding overloaded procedure insert_batch_ststus_new.
 |     This one also takes an array of User profile codes instead of one.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performTransactionGrouping(
     profile_code_array   IN JTF_VARCHAR2_TABLE_100,
     instr_type           IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     req_type             IN IBY_BATCHES_ALL.
                                 reqtype%TYPE,
     f_pmt_channel_in     IN IBY_TRXN_SUMMARIES_ALL.
                                 payment_channel_code%TYPE,
     f_curr_in            IN IBY_TRXN_SUMMARIES_ALL.
                                 currencynamecode%TYPE,
     f_settle_date        IN IBY_TRXN_SUMMARIES_ALL.
                                 settledate%TYPE,
     f_due_date           IN IBY_TRXN_SUMMARIES_ALL.
                                 settlement_due_date%TYPE,
     f_maturity_date      IN IBY_TRXN_SUMMARIES_ALL.
                                 br_maturity_date%TYPE,
     f_instr_type         IN IBY_TRXN_SUMMARIES_ALL.
                                 instrtype%TYPE,
     merch_batchid_in     IN iby_batches_all.batchid%TYPE,

     x_batchTab           IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            batchAttrTabType,
     x_trxnsInBatchTab    IN OUT NOCOPY IBY_TRANSACTIONCC_PKG.
                                            trxnsInBatchTabType
     )
 IS
 l_module_name           CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                  '.performTransactionGrouping';

 l_sql_str               VARCHAR2(5000);
 l_cursor_stmt           VARCHAR2(8000);

 l_first_record          VARCHAR2(1)   := 'Y';

 /* user defined grouping rule flags */
 l_org_flag              VARCHAR2(1)   := 'N';
 l_le_flag               VARCHAR2(1)   := 'N';
 l_int_bnk_flag          VARCHAR2(1)   := 'N';
 l_curr_flag             VARCHAR2(1)   := 'N';
 l_settle_date_flag      VARCHAR2(1)   := 'N';

 /* user defined limits */
 l_max_trxn_limit        NUMBER(15)    := 0;
 l_fx_rate_type          VARCHAR2(255) := '';
 l_fx_curr_code          VARCHAR2(10)  := '';
 l_max_amount_limit      NUMBER(15)    := 0;

 /*
  * NOTE:
  *
  * IBY_BATCHES_ALL.batchid  = user generated batch id
  * IBY_BATCHES_ALL.mbatchid = system generated batch id
  *
  * If batch close is invoked by the user, the batchid will
  * be a user defined string (should be unique).
  *
  * If batch close is invoked by the scheduler, the batch is
  * be a sequence number (iby_batchid_s.nextval).
  *
  * mbatchid will always be a sequence number (iby_batchid_s.nextval).
  *
  * In the new architecture, multiple mbatchids can be generated
  * for a single batchid (based on user defined grouping rules).
  */
 l_mbatch_id             IBY_BATCHES_ALL.mbatchid%TYPE;
 l_batch_total           NUMBER(15)    := 0;
 l_trxns_in_batch_count  NUMBER(15)    := 0;

 l_trx_fx_amount         NUMBER(15)    := 0;

 /*
  * Used to substitute null values in date comparisons.
  * It is assumed that not document payable would ever
  * have a year 1100 date.
  */
 l_impossible_date       DATE := TO_DATE('01/01/1100 10:25:55',
                                     'MM/DD/YYYY HH24:MI:SS');

 /*
  * These two are related data structures. Each row in batchAttrTabType
  * PLSQL table is used in inserting a row into the IBY_BATCHES_ALL
  * table.
  *
  * A separate data structure is needed to keep track of the transactions
  * that are part of a batch. This information is tracked in the
  * trxnsInBatchTabType table. The rows in trxnsInBatchTabType are
  * used to update the rows in IBY_TRXN_SUMMARIES_ALL table with
  * batch ids.
  *
  *            l_batchTab                        l_trxnsInBatchTab
  *       (insert into IBY_BATCHES_ALL)   (update IBY_TRXN_SUMMARIES_ALL)
  * /-------------------------------------\       /------------\
  * |MBatch |Profile|..|Curr   |Org    |..|       |MBatch |Trx |
  * |Id     |Code   |..|Code   |Id     |..|       |Id     |Id  |
  * |       |       |..|       |       |..|       |       |    |
  * |-------------------------------------|       |------------|
  * |   4000|     10|  |    USD|    204|  |       |   4000| 501|
  * |       |       |  |       |       |  |       |   4000| 504|
  * |       |       |  |       |       |  |       |   4000| 505|
  * |-------|-------|--|-------|-------|--|       |-------|----|
  * |   4001|     11|  |    -- |    342|  |       |   4001| 502|
  * |       |       |  |       |       |  |       |   4001| 509|
  * |       |       |  |       |       |  |       |   4001| 511|
  * |       |       |  |       |       |  |       |   4001| 523|
  * |       |       |  |       |       |  |       |     : |  : |
  * |-------|-------|--|-------|-------|--|       |-------|----|
  * |    :  |     : |  |    :  |     : |  |       |     : |  : |
  * \_______|_______|__|_______|_______|__/       \_______|____/
  *
  */

 l_batchRec          IBY_TRANSACTIONCC_PKG.batchAttrRecType;
 l_trxnsInBatchTab   IBY_TRANSACTIONCC_PKG.trxnsInBatchTabType;
 emptyTrxnInsBatchTab IBY_TRANSACTIONCC_PKG.trxnsInBatchTabType;

 l_trxnsInBatchRec   IBY_TRANSACTIONCC_PKG.trxnsInBatchRecType;
 l_batchTab          IBY_TRANSACTIONCC_PKG.batchAttrTabType;

 l_trxnGrpCriTab     IBY_TRANSACTIONCC_PKG.trxnGroupCriteriaTabType;
 emptyGrpCriTab      IBY_TRANSACTIONCC_PKG.trxnGroupCriteriaTabType;

 l_pinlessdebitcard  CONSTANT VARCHAR2(100) :='PINLESSDEBITCARD';
 l_bankaccount       CONSTANT VARCHAR2(100) :='BANKACCOUNT';

 /* previous transaction attributes */
 prev_trxn_id                iby_trxn_summaries_all.transactionid%TYPE;
 prev_trxn_currency          iby_trxn_summaries_all.currencynamecode%TYPE;
 prev_trxn_amount            iby_trxn_summaries_all.amount%TYPE;
 prev_int_bank_acct_id       iby_trxn_summaries_all.payeeinstrid%TYPE;
 prev_org_id                 iby_trxn_summaries_all.org_id%TYPE;
 prev_org_type               iby_trxn_summaries_all.org_type%TYPE;
 prev_settle_date            iby_trxn_summaries_all.settledate%TYPE;
 prev_le_id                  iby_trxn_summaries_all.legal_entity_id%TYPE;
 prev_bep_key                iby_trxn_summaries_all.bepkey%TYPE;
 prev_profile_cd             iby_trxn_summaries_all.process_profile_code%TYPE;

 /* current transaction attributes */
 curr_trxn_id                iby_trxn_summaries_all.transactionid%TYPE;
 curr_trxn_currency          iby_trxn_summaries_all.currencynamecode%TYPE;
 curr_trxn_amount            iby_trxn_summaries_all.amount%TYPE;
 curr_int_bank_acct_id       iby_trxn_summaries_all.payeeinstrid%TYPE;
 curr_org_id                 iby_trxn_summaries_all.org_id%TYPE;
 curr_org_type               iby_trxn_summaries_all.org_type%TYPE;
 curr_settle_date            iby_trxn_summaries_all.settledate%TYPE;
 curr_le_id                  iby_trxn_summaries_all.legal_entity_id%TYPE;
 curr_bep_key                iby_trxn_summaries_all.bepkey%TYPE;
 curr_profile_cd             iby_trxn_summaries_all.process_profile_code%TYPE;
 l_user_pf_table_name        VARCHAR2(100);
 l_sys_pf_table_name         VARCHAR2(100);
 l_user_pf_column_name       VARCHAR2(100);
 l_sys_pf_column_name        VARCHAR2(100);

 l_numeric_char_mask         VARCHAR2(100);

 TYPE dyn_transactions       IS REF CURSOR;
 l_trxn_cursor               dyn_transactions;

 strProfCodes                VARCHAR2(200);
 numProfiles                 NUMBER;
 recLimit                    NUMBER := 1000;
 l_index                     NUMBER;

 /*
  * This cursor up will pick up all valid transactions for
  * the specified payment profile. The select statement will
  * order the transactions based on grouping criteria.
  *
  * Important Note:
  *
  * Always ensure that there is a corresponding order by
  * clause for each grouping criterion that you wish to use.
  * This is required in order to create minimum possible
  * batches from a given set of transactions.
  *
  * Note 2: The sample sql is not right as the base table for
  * process profile is different
  * the dynamic sql is changed according to that
  */
 CURSOR c_transactions (
            strProfiles VARCHAR2,
            p_instr_type   VARCHAR2,
            p_req_type     VARCHAR2
            )
 IS
 SELECT
     txn.transactionid,
     txn.process_profile_code,
     txn.bepkey,
     txn.org_id,
     txn.org_type,
     txn.currencynamecode,
     txn.amount,
     txn.legal_entity_id,
     txn.payeeinstrid,
     txn.settledate,
     sys_prof.group_by_org,
     sys_prof.group_by_legal_entity,
     sys_prof.group_by_int_bank_account,
     sys_prof.group_by_settlement_curr,
     sys_prof.group_by_settlement_date,
     sys_prof.limit_by_amt_curr,
     sys_prof.limit_by_exch_rate_type,
     sys_prof.limit_by_total_amt,
     sys_prof.limit_by_settlement_num
 FROM
     IBY_TRXN_SUMMARIES_ALL  txn,
     IBY_FNDCPT_USER_CC_PF_B user_prof,
     IBY_FNDCPT_SYS_CC_PF_B  sys_prof
 WHERE
     user_prof.user_cc_profile_code IN (strProfiles)               AND
     txn.process_profile_code     = user_prof.user_cc_profile_code AND
     sys_prof.sys_cc_profile_code = user_prof.sys_cc_profile_code  AND
     txn.status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED      AND
     (
         /*
          * This clause will pick up credit card / purchase card
          * transactions.
          */
         (
             p_instr_type IN
             (
                 iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                 iby_creditcard_pkg.C_INSTRTYPE_PCARD
             )
             AND
             (
                 txn.reqtype IN
                 (
                 iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE,
                 iby_transactioncc_pkg.C_REQTYPE_CAPTURE,
                 iby_transactioncc_pkg.C_REQTYPE_CREDIT,
                 iby_transactioncc_pkg.C_REQTYPE_RETURN
                 )
             )
             AND
             (
                 txn.instrtype IN
                 (
                 iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                 iby_creditcard_pkg.C_INSTRTYPE_PCARD
                 )
             )
         )

         /*
          * This clause will pick up pinless debit card
          * transactions.
          */
         OR
         (
             p_instr_type IN
             (
                 l_pinlessdebitcard
             )
             AND
             (
                 txn.reqtype IN
                 (
                 iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE,
                 iby_transactioncc_pkg.C_REQTYPE_REQUEST
                 )
             )
             AND
             (
                 txn.instrtype IN
                 (
                 l_pinlessdebitcard
                 )
             )
         )

         /*
          * This clause will pick up bank account transactions
          * transactions.
          */
         OR
         (
             p_instr_type IN
             (
                 l_bankaccount
             )
             AND
             (
                 txn.reqtype IN
                 (
                 iby_transactioncc_pkg.C_REQTYPE_EFT_BATCHCLOSE,
                 iby_transactioncc_pkg.C_REQTYPE_BATCHREQ
                 )
             )
             AND
             (
                 txn.instrtype IN
                 (
                 l_bankaccount
                 )
             )

             /*
              * Fix for bug 5442922:
              *
              * For bank account instruments, the auth / verify
              * transaction will have trantypeid 20; The
              * capture transaction will have trxntypeid 100.
              *
              * Since we are picking up only capture transactions
              * here, explicitly specify the trxntypeid in the
              * WHERE clause. Otherwise, auths are also picked
              * up and put into the batch.
              */
             AND
             (
                 /*
                  * This trxn type 100 maps to
                  * IBY_FNDCPT_TRXN_PUB.BA_CAPTURE_TRXNTYPE
                  */
                 txn.trxntypeid = 100
             )
         )

         /*
          * This clause will pick up any transaction which does not
          * have an instrument type. This looks dangerous to me but
          * kept for backward compatibility - Ramesh
          */
         OR
         (
             txn.instrtype IS NULL
         )
     )                                                             AND
     txn.batchid IS NULL                                           AND
     /*
      *  Fix for bug 5632947:
      *
      *  Join with CE_SECURITY_PROFILES_V for MOAC compliance.
      */
     ((txn.org_id IS NULL) OR
     ((txn.org_id IS NOT NULL) AND
     (txn.org_id, txn.org_type) IN
         (SELECT
              ce.organization_id,
              ce.organization_type
          FROM
              ce_security_profiles_v ce
         )))
 ORDER BY
     txn.process_profile_code,   --
     txn.bepkey,                 -- Ensure that the
     txn.org_id,                 -- grouping rules below
     txn.org_type,               -- follow this same
     txn.legal_entity_id,        -- order (necessary
     txn.payeeinstrid,           -- for creating minimum
     txn.currencynamecode,       -- number of batches)
     txn.settledate              --
 ;


 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER: Overloaded API.');

     END IF;
   --  print_debuginfo(l_module_name, 'Payment Profile Cd: '||
   --      p_profile_code);
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'Payment Profile Cd: '||
	        strProfCodes);
	     print_debuginfo(l_module_name, 'Instrument Type: '   ||
	         instr_type);
	     print_debuginfo(l_module_name, 'Request Type: '      ||
	         req_type);

     END IF;
     /*
      * Filter params.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'f_pmt_channel_in: '
	         || f_pmt_channel_in);
	     print_debuginfo(l_module_name, 'f_curr_in: '
	         || f_curr_in);
	     print_debuginfo(l_module_name, 'f_settle_date: '
	         || f_settle_date);
	     print_debuginfo(l_module_name, 'f_due_date: '
	         || f_due_date);
	     print_debuginfo(l_module_name, 'f_maturity_date: '
	         || f_maturity_date);
	     print_debuginfo(l_module_name, 'f_instr_type: '
	         || f_instr_type);

     END IF;
     /*
      * Fix for bug 5407120:
      *
      * Before we do anything, alter the session to set the numeric
      * character mask. This is because of XML publisher limitation -
      * it cannot handle numbers like '230,56' which is the European
      * representation of '230.56'.
      *
      * Therefore, we explicitly set the numeric character mask at the
      * beginning of this routine and revert back to the default
      * setting at the end of this method.
      */
     BEGIN

         SELECT
             value
         INTO
             l_numeric_char_mask
         FROM
             V$NLS_PARAMETERS
         WHERE
             parameter='NLS_NUMERIC_CHARACTERS'
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Current numeric char mask: '
	             || l_numeric_char_mask
	             );

         END IF;
     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	                 || 'when attempting to retrieve numeric character mask.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
     END;

     /*
      * Now alter the session, to force the NLS numeric character
      * decimal indicator to be a '.'.
      */
     BEGIN

         EXECUTE IMMEDIATE
             'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,"'
             ;

     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	                 || 'when attempting to later session to set '
	                 || 'numeric character mask.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
     END;

     /*
      * Dynamically form SQL string to limit the rows that
      * are picked up for the batch close operation.
      *
      * Use the supplied filter parameters to form the SQL
      * string.
      */
     IF (f_pmt_channel_in IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND payment_channel_code = '
                          || '''' || f_pmt_channel_in || '''';
     END IF;

     IF (f_curr_in IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND currencynamecode = '
                          || '''' || f_curr_in || '''';
     END IF;

     IF (f_settle_date IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND settledate <= '
                          || '''' || f_settle_date || '''';
     END IF;

     IF (f_due_date IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND settlement_due_date <= '
                          || '''' || f_due_date || '''';
     END IF;

     IF (f_maturity_date IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND br_maturity_date <= '
                          || '''' || f_maturity_date || '''';
     END IF;

     IF (f_instr_type IS NOT NULL) THEN
         l_sql_str := l_sql_str || ' AND instrtype = '
                          || '''' || f_instr_type || '''';
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Dynamic SQL snippet: '
	         || l_sql_str);

     END IF;
    /* determine the process profile table and column */

     l_user_pf_table_name :='IBY_FNDCPT_USER_CC_PF_B';
     l_sys_pf_table_name  :='IBY_FNDCPT_SYS_CC_PF_B';
     l_user_pf_column_name :='USER_CC_PROFILE_CODE';
     l_sys_pf_column_name :='SYS_CC_PROFILE_CODE';
  IF (instr_type IS NOT NULL) THEN
       if(instr_type =l_bankaccount) THEN
                    l_user_pf_table_name :='IBY_FNDCPT_USER_EFT_PF_B';
                    l_sys_pf_table_name  :='IBY_FNDCPT_SYS_EFT_PF_B';
                    l_user_pf_column_name :='USER_EFT_PROFILE_CODE';
                    l_sys_pf_column_name :='SYS_EFT_PROFILE_CODE';
       ELSIF  (instr_type =l_pinlessdebitcard) THEN
                    l_user_pf_table_name :='IBY_FNDCPT_USER_DC_PF_B';
                    l_sys_pf_table_name  :='IBY_FNDCPT_SYS_DC_PF_B';
                    l_user_pf_column_name :='USER_DC_PROFILE_CODE';
                    l_sys_pf_column_name :='SYS_DC_PROFILE_CODE';
       END IF;

   END IF;

     /* Form a comma separated string for the profile codes */
     numProfiles := profile_code_array.count;
     FOR i IN 1..(numProfiles-1) LOOP
        strProfCodes := strProfCodes||''''||profile_code_array(i)||''',';
     END LOOP;
     /* Append the last profile code without comma at the end */
     strProfCodes := strProfCodes||''''||profile_code_array(numProfiles)||'''';

     /*
      * The cursor below is the same as the cursor c_transactions
      * defined at the beginning of this method.
      *
      * We cannot directly use c_transactions because we need to use
      * the provided filter params to form a dynamic where clause.
      *
      * For this reason, this cursor has been made into a dynamic cursor.
      * c_transactions is kept for documentation / debugging purposes
      * but is not used.
      */
     l_cursor_stmt :=
     'SELECT '
         || 'txn.transactionid,                  '
         || 'txn.process_profile_code,           '
         || 'txn.bepkey,                         '
         || 'txn.org_id,                         '
         || 'txn.org_type,                       '
         || 'txn.currencynamecode,               '
         || 'txn.amount,                         '
         || 'txn.legal_entity_id,                '
         || 'txn.payeeinstrid,                   '
         || 'txn.settledate,                     '
         || 'sys_prof.group_by_org,              '
         || 'sys_prof.group_by_legal_entity,     '
         || 'sys_prof.group_by_int_bank_account, '
         || 'sys_prof.group_by_settlement_curr,  '
         || 'sys_prof.group_by_settlement_date,  '
         || 'sys_prof.limit_by_amt_curr,         '
         || 'sys_prof.limit_by_exch_rate_type,   '
         || 'sys_prof.limit_by_total_amt,        '
         || 'sys_prof.limit_by_settlement_num    '
     || 'FROM  '
         || 'IBY_TRXN_SUMMARIES_ALL  txn,        '
         || l_user_pf_table_name || '  user_prof,  '
         ||  l_sys_pf_table_name || '  sys_prof    '
     || 'WHERE '
         || 'user_prof.'||l_user_pf_column_name||'  IN ('||strProfCodes||')     AND '
         || 'txn.process_profile_code     = user_prof.'||l_user_pf_column_name||'  AND '
         || 'sys_prof.' ||l_sys_pf_column_name||'   = user_prof. '||l_sys_pf_column_name || ' AND '
         || 'txn.status = :open_batch                                      AND '
         || '( '
             /*
              * This clause will pick up credit card / purchase card
              * transactions.
              */
             || '( '
                || ':A IN (:C1, :C2) AND (txn.reqtype IN (:T1A, :T1B, :T1C, :T1D, :T1E)) AND '
                || '(txn.instrtype IN (:C3, :C4)) '
             || ') '

             /*
              * This clause will pick up pinless debit card
              * transactions.
              */
             || 'OR '
             || '( '
                 || ':C IN (:P1) AND (txn.reqtype IN (:T2A, :T2B)) AND '
                 || '(txn.instrtype IN (:P2)) '
             || ') '

             /*
              * This clause will pick up bank account transactions
              * transactions.
              */

             || 'OR '
             || '( '
                 || ':E IN (:B1) AND (txn.reqtype IN (:T3A, :T3B, :T3C)) AND '
                 || '(txn.instrtype IN (:B2)) '


                 /*
                  * Fix for bug 5442922:
                  *
                  * For bank account instruments, the auth / verify
                  * transaction will have trantypeid 20; The
                  * capture transaction will have trxntypeid 100.
                  *
                  * Since we are picking up only capture transactions
                  * here, explicitly specify the trxntypeid in the
                  * WHERE clause. Otherwise, auths are also picked
                  * up and put into the batch.
                  */
                 || 'AND '
                 || '( '
                     /*
                      * This trxn type 100 maps to
                      * IBY_FNDCPT_TRXN_PUB.BA_CAPTURE_TRXNTYPE
                      */
                     || 'txn.trxntypeid = 100 '
                 || ') '

             || ') '

             /*
              * This clause will pick up any transaction which does not
              * have an instrument type. This looks dangerous to me but
              * kept for backward compatibility - Ramesh
              */
             || 'OR '
             || '( '
                 || 'txn.instrtype IS NULL '
             || ') '
         || ')                                                             AND '
         || 'txn.batchid IS NULL                                           AND '
         /*
          *  Fix for bug 5632947:
          *
          *  Join with CE_SECURITY_PROFILES_V for MOAC compliance.
          */
         || '((txn.org_id IS NULL) OR '
         || '((txn.org_id IS NOT NULL) AND '
         || '(txn.org_id, txn.org_type) IN '
         || '    (SELECT '
         || '         ce.organization_id, '
         || '         ce.organization_type '
         || '     FROM  '
         || '         ce_security_profiles_v ce '
         || '    ))) '
         || NVL (l_sql_str, 'AND 1=1 ')
     || 'ORDER BY '
         || 'txn.process_profile_code, '  --
         || 'txn.bepkey,               '  -- Ensure that the
         || 'txn.org_id,               '  -- grouping rules below
         || 'txn.org_type,             '  -- follow this same
         || 'txn.legal_entity_id,      '  -- order (necessary
         || 'txn.payeeinstrid,         '  -- for creating minimum
         || 'txn.currencynamecode,     '  -- number of batches)
         || 'txn.settledate            '  --
     ;

     OPEN l_trxn_cursor FOR
         l_cursor_stmt
     USING
         -- comment out this one as we have already put this value in a comma separated string
         --p_profile_code,                                 /* profile_code */
         iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED,    /* open_batch */
         instr_type,                                     /* A */
         iby_creditcard_pkg.C_INSTRTYPE_CCARD,           /* C1 */
         iby_creditcard_pkg.C_INSTRTYPE_PCARD,           /* C2 */
         iby_transactioncc_pkg.C_REQTYPE_BATCHCLOSE,     /* T1A */
         iby_transactioncc_pkg.C_REQTYPE_CAPTURE,        /* T1B */
         iby_transactioncc_pkg.C_REQTYPE_CREDIT,         /* T1C */
         iby_transactioncc_pkg.C_REQTYPE_RETURN,         /* T1D */
         iby_transactioncc_pkg.C_REQTYPE_REQUEST,         /* T1E */
         iby_creditcard_pkg.C_INSTRTYPE_CCARD,           /* C3 */
         iby_creditcard_pkg.C_INSTRTYPE_PCARD,           /* C4 */
         instr_type,                                     /* C */
         l_pinlessdebitcard,                             /* P1 */
         iby_transactioncc_pkg.C_REQTYPE_PDC_BATCHCLOSE, /* T2A */
         iby_transactioncc_pkg.C_REQTYPE_REQUEST,        /* T2B */
         l_pinlessdebitcard,                             /* P2 */
         instr_type,                                     /* E */
         l_bankaccount,                                  /* B1 */
         iby_transactioncc_pkg.C_REQTYPE_EFT_BATCHCLOSE, /* T3A */
         iby_transactioncc_pkg.C_REQTYPE_BATCHREQ,       /* T3B */
         iby_transactioncc_pkg.C_REQTYPE_REQUEST,        /* T3C */
         l_bankaccount                                   /* B2 */
         ;
    --Bug 8658052
    --Included fetch limit
     LOOP
     FETCH l_trxn_cursor BULK COLLECT INTO l_trxnGrpCriTab LIMIT recLimit;

     --CLOSE l_trxn_cursor;

     /*
      * Exit if no documents were found.
      */
     IF (l_trxnGrpCriTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No transactions were '
	             || 'retrieved from DB for profile '
	             || strProfCodes
	             || '. Exiting transaction grouping ..');

	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;
     ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, '# valid transactions '
	             || 'retrieved from DB for profile '
	             || strProfCodes
	             || ' = '
	             || l_trxnGrpCriTab.COUNT);
         END IF;
     END IF;

     /*
      * Loop through all the fetched documents, grouping them
      * into payments.
      */
     FOR i in l_trxnGrpCriTab.FIRST .. l_trxnGrpCriTab.LAST LOOP

         curr_trxn_id           := l_trxnGrpCriTab(i).trxn_id;
         curr_profile_cd        := l_trxnGrpCriTab(i).process_profile_code;
         curr_int_bank_acct_id  := l_trxnGrpCriTab(i).int_bank_acct_id;
         curr_bep_key           := l_trxnGrpCriTab(i).bep_key;
         curr_org_id            := l_trxnGrpCriTab(i).org_id;
         curr_org_type          := l_trxnGrpCriTab(i).org_type;
         curr_trxn_currency     := l_trxnGrpCriTab(i).curr_code;
         curr_trxn_amount       := l_trxnGrpCriTab(i).amount;
         curr_le_id             := l_trxnGrpCriTab(i).legal_entity_id;
         curr_settle_date       := l_trxnGrpCriTab(i).settle_date;

         l_org_flag             := l_trxnGrpCriTab(i).group_by_org;
         l_le_flag              := l_trxnGrpCriTab(i).group_by_le;
         l_int_bnk_flag         := l_trxnGrpCriTab(i).group_by_int_bank_acct;
         l_curr_flag            := l_trxnGrpCriTab(i).group_by_curr;
         l_settle_date_flag     := l_trxnGrpCriTab(i).group_by_settle_date;

         l_max_trxn_limit       := l_trxnGrpCriTab(i).num_trxns_limit;

         l_fx_rate_type         := l_trxnGrpCriTab(i).fx_rate_type;
         l_fx_curr_code         := l_trxnGrpCriTab(i).max_amt_curr;
         l_max_amount_limit     := l_trxnGrpCriTab(i).max_amt_limit;

         /*
          * Log all the fetched document fields
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name,
	             'Fetched data for transaction:' || curr_trxn_id
	             || ', internal bank account: ' || curr_int_bank_acct_id
	             || ', profile: '               || curr_profile_cd
	             || ', bep key: '               || curr_bep_key
	             || ', org: '                   || curr_org_id
	             || ', org type: '              || curr_org_type
	             || ', le:  '                   || curr_le_id
	             || ', currency: '              || curr_trxn_currency
	             || ', amount: '                || curr_trxn_amount
	             || ', settle date: '           || curr_settle_date
	             );

	         print_debuginfo(l_module_name,
	             'Fetched data for transaction:' || curr_trxn_id
	             || ', org flag: '               || l_org_flag
	             || ', le flag: '                || l_le_flag
	             || ', int bank acct flag: '     || l_int_bnk_flag
	             || ', currency flag: '          || l_curr_flag
	             || ', settle date flag: '       || l_settle_date_flag
	             || ', max trxns limit: '        || l_max_trxn_limit
	             || ', max amount limit: '       || l_max_amount_limit
	             || ', exch rate: '              || l_fx_rate_type
	             || ', exch currency: '          || l_fx_curr_code
	             );

         END IF;
         IF (l_first_record = 'Y') THEN
             prev_trxn_id              := curr_trxn_id;
             prev_int_bank_acct_id     := curr_int_bank_acct_id;
             prev_profile_cd           := curr_profile_cd;
             prev_org_id               := curr_org_id;
             prev_org_type             := curr_org_type;
             prev_le_id                := curr_le_id;
             prev_bep_key              := curr_bep_key;
             prev_trxn_currency        := curr_trxn_currency;
             prev_trxn_amount          := curr_trxn_amount;
             prev_settle_date          := curr_settle_date;
         END IF;

         /*
          * We have just fetched a new transaction for this profile.
          * We will either insert this transaction into a new batch or
          * we will be inserting this transaction into the currently running
          * batch.
          *
          * In either case, we need to insert this trxn into a batch.
          * So pre-populate the batch record with attributes of
          * this document. This is because the batch takes on the
          * attributes of its constituent transactions.
          *
          * Note: For user defined grouping rules, we will
          * have to populate the batch attributes only if
          * the user has turned on grouping by that attribute.
          */

         /* Only pre-fill hardcoded grouping rule attributes */
	 /* Commenting out this one as, we no more have profile code and currency
	    as hard coded grouping rules
	 */
         --l_batchRec.profile_code       := curr_profile_cd;
         --l_batchRec.bep_key            := curr_bep_key;

         /*
          * Pre-fill grouping rule attributes for user defined
          * grouping rules (that are enabled by the user).
          *
          * It is necessary to pre-fill user defined grouping
          * attributes before the grouping rules are triggered
          * because we don't know which user defined grouping rules
          * are going to get triggered first, and once a rule is
          * triggered all rules below it are skipped. So it is too
          * late to populate grouping attributes within the grouping
          * rule itself.
          */
         IF (l_org_flag = 'Y') THEN
             l_batchRec.org_id   := curr_org_id;
             l_batchRec.org_type := curr_org_type;
         END IF;

         IF (l_le_flag = 'Y') THEN
             l_batchRec.le_id := curr_le_id;
         END IF;

         IF (l_int_bnk_flag = 'Y') THEN
             l_batchRec.int_bank_acct_id := curr_int_bank_acct_id;
         END IF;

         IF (l_curr_flag = 'Y') THEN
             l_batchRec.curr_code := curr_trxn_currency;
         END IF;

         IF (l_settle_date_flag = 'Y') THEN
             l_batchRec.settle_date := curr_settle_date;
         END IF;

         /*
          * Pre-fill the document record with the details
          * of the current document.
          */
         l_trxnsInBatchRec.trxn_id := curr_trxn_id;

         /*-- HARDCODED GROUPING RULES START HERE --*/
	 /* Commenting out this one as, we no more have profile code and currency
	    as hard coded grouping rules
	 */

         /*
          * Grouping Step 1: Payment Profile Code
          */
    /*     IF (prev_profile_cd <> curr_profile_cd) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Grouping by payment '
	                 || 'profile triggered for transaction '
	                 || curr_trxn_id);

             END IF;
             insertTrxnIntoBatch(l_batchRec, l_batchTab,
                 true, l_mbatch_id, l_trxnsInBatchTab,
                 l_trxnsInBatchRec, l_trxns_in_batch_count);

             GOTO label_finish_iteration;

         END IF;
    */

         /*
          * Grouping Step 2: Payment System Account (Bep Key)
          */
    /*
         IF (prev_bep_key <> curr_bep_key) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Grouping by payment '
	                 || 'system account triggered for transaction '
	                 || curr_trxn_id);

             END IF;
             insertTrxnIntoBatch(l_batchRec, l_batchTab,
                 true, l_mbatch_id, l_trxnsInBatchTab,
                 l_trxnsInBatchRec, l_trxns_in_batch_count);

             GOTO label_finish_iteration;

         END IF;
    */

         /*-- USER DEFINED GROUPING RULES START HERE --*/

         /*
          * Grouping Step 3: Organization ID And Organization Type
          */
         IF (l_org_flag = 'Y') THEN

             IF (prev_org_id <> curr_org_id)     OR
                (NVL(prev_org_type, 0) <> NVL(curr_org_type, 0)) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by organization '
	                     || 'id/type triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 3: Legal Entity ID
          */
         IF (l_le_flag = 'Y') THEN

             IF (prev_le_id <> curr_le_id) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by legal '
	                     || 'entity triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 4: Internal Bank Account ID
          */
         IF (l_int_bnk_flag = 'Y') THEN

             IF (prev_int_bank_acct_id <> curr_int_bank_acct_id) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by internal bank '
	                     || 'account triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 5: Settlement Currency
          */
         IF (l_curr_flag = 'Y') THEN

             IF (prev_trxn_currency <> curr_trxn_currency) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by settlement '
	                     || 'currency triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 6: Settlement Date
          */
         IF (l_settle_date_flag = 'Y') THEN

             IF (prev_settle_date <> curr_settle_date) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by settlement '
	                     || 'date triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 7: Max Transactions Per Batch
          */
         IF (l_max_trxn_limit IS NOT NULL) THEN

             IF (l_trxns_in_batch_count = l_max_trxn_limit) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'max trxns per batch triggered for transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * Grouping Step 8: Max Amount Per Batch
          */
         IF (l_max_amount_limit IS NOT NULL) THEN

             IF (l_batch_total + l_trx_fx_amount > l_max_amount_limit) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'max batch amount triggered by transaction '
	                     || curr_trxn_id);

                 END IF;
                 insertTrxnIntoBatch(l_batchRec, l_batchTab,
                     true, l_mbatch_id, l_trxnsInBatchTab,
                     l_trxnsInBatchRec, l_trxns_in_batch_count);

                 GOTO label_finish_iteration;

             END IF;

         END IF;

         /*
          * End Of Grouping:
          * If a transaction reaches here, it means that this transaction
          * is similar to the previous transaction as far a grouping
          * criteria is concerned.
          *
          * Add this transaction to the currently running batch.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No grouping rules '
	             || 'were triggered for transaction '
	             || curr_trxn_id);

         END IF;
         insertTrxnIntoBatch(l_batchRec, l_batchTab,
             false, l_mbatch_id, l_trxnsInBatchTab,
             l_trxnsInBatchRec, l_trxns_in_batch_count);


         <<label_finish_iteration>>

         /*
          * Lastly, before going into the next iteration
          * of the loop copy all the current grouping criteria
          * into 'prev' fields so that we can compare these
          * fields with the next record.
          *
          * No need to copy the current values into the previous ones for
          * the first record because we have already done it at the beginning.
          */
         IF (l_first_record <> 'Y') THEN
             prev_trxn_id           := curr_trxn_id;
             prev_profile_cd        := curr_profile_cd;
             prev_int_bank_acct_id  := curr_int_bank_acct_id;
             prev_bep_key           := curr_bep_key;
             prev_org_id            := curr_org_id;
             prev_org_type          := curr_org_type;
             prev_trxn_currency     := curr_trxn_currency;
             prev_trxn_amount       := curr_trxn_amount;
             prev_le_id             := curr_le_id;
             prev_settle_date       := curr_settle_date;
         END IF;

         /*
          *  Remember to reset the first record flag before going
          *  into the next iteration.
          */
         IF (l_first_record = 'Y') THEN
             l_first_record := 'N';
         END IF;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, '+----------------------------------+');

         END IF;

	 x_batchTab:= l_batchTab;
	--x_trxnsInBatchTab(x_trxnsInBatchTab.COUNT+1):= l_trxnsInBatchTab(i);

	print_debuginfo(l_module_name, 'l_batchTab.COUNT:'||
			x_batchTab.COUNT);
	print_debuginfo(l_module_name, 'l_trxnsInBatchTab.COUNT:'||
			l_trxnsInBatchTab.COUNT);

     END LOOP;

     -- Moved logic from insert_batch_status_new
       IF (l_batchTab.COUNT > 0) THEN

                 l_index := 1;
                 FOR k IN l_batchTab.FIRST .. l_batchTab.LAST LOOP

                     /*
                      * Assign a unique batch id to each batch.
                      */
                     l_batchTab(k).batch_id :=
                         merch_batchid_in ||'_'|| l_index;
                     l_index := l_index + 1;
                 END LOOP;

        END IF;

        IF (l_trxnsInBatchTab.COUNT > 0) THEN

                 FOR m IN l_trxnsInBatchTab.FIRST ..
                     l_trxnsInBatchTab.LAST LOOP

                     FOR k IN l_batchTab.FIRST .. l_batchTab.LAST LOOP

                         /*
                          * Find the mbatch id in the batches array
                          * corresponding to the mbatchid of this transaction.
                          */
                         IF (l_trxnsInBatchTab(m).mbatch_id =
                             l_batchTab(k).mbatch_id) THEN

                             /*
                              * Assign the batch id from the batches array
                              * to this transaction.
                              */
                             l_trxnsInBatchTab(m).batch_id :=
                                 l_batchTab(k).batch_id;
			     l_trxnsInBatchRec:= l_trxnsInBatchTab(m);
			     -- Converting Table of records to record of tables
			     trxnTab.transactionid(m):= l_trxnsInBatchRec.trxn_id;
                             trxnTab.mbatchid(m):= l_trxnsInBatchRec.mbatch_id;
			     trxnTab.batchid(m):= l_trxnsInBatchRec.batch_id;

                         END IF;

                     END LOOP;

                 END LOOP;

        END IF;

	-- Bulk Update
	FORALL i in trxnTab.transactionid.FIRST .. trxnTab.transactionid.LAST

		     UPDATE
                         IBY_TRXN_SUMMARIES_ALL
                     SET
                         status                = iby_transactioncc_pkg.
                                                     C_STATUS_BATCH_PENDING,
                         batchid               = trxnTab.batchid(i),
                         mbatchid              = trxnTab.mbatchid(i),
                         last_update_date      = sysdate,
                         updatedate            = sysdate,
                         last_updated_by       = fnd_global.user_id,
                         object_version_number = object_version_number + 1
                     WHERE
                         transactionid = trxnTab.transactionid(i) AND
                         status = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED
                         ;
       -- Bug# 8658052
       -- Freeing up the memory space. Assign an empty table
       l_trxnGrpCriTab:= emptyGrpCriTab;
       delete_trxnTable;
       l_trxnsInBatchTab:=emptyTrxnInsBatchTab;
       print_debuginfo(l_module_name, 'After freeing up memory space');

 END LOOP; -- Bulk fetch end loop

 CLOSE l_trxn_cursor;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Created '
	         || l_batchTab.COUNT   || ' batch(s) from '
	         || l_trxnsInBatchTab.COUNT || ' transaction(s) for profile '
	         || 'removed this value for the time being' || '.');
	if(l_batchTab.COUNT > 0) THEN
		print_debuginfo(l_module_name, 'l_batchTab.BATCHID:'|| l_batchTab(0).batch_id);
		print_debuginfo(l_module_name, 'l_batchTab.MBATCHID:'|| l_batchTab(0).mbatch_id);
	END IF;
     END IF;
     /*
      * Finally, return the batches created by grouping to the caller.
      */
     x_batchTab        := l_batchTab;
     x_trxnsInBatchTab := l_trxnsInBatchTab;


     /*
      * Fix for bug 5407120:
      *
      * Revert back thenumeric character mask to its original
      * setting. See begininning of this methods for comments
      * regarding this issue.
      *
      */
     BEGIN

         IF (l_numeric_char_mask IS NOT NULL) THEN

             EXECUTE IMMEDIATE
                 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '
                    || '"'
                    || l_numeric_char_mask
                    || '"'
                 ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Reverted numeric char mask to: '
	                 || l_numeric_char_mask
	                 );

             END IF;
         END IF;

     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	                 || 'when attempting to revert numeric character mask.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END performTransactionGrouping;


/*--------------------------------------------------------------------
 | NAME:
 |     insertTrxnIntoBatch
 |
 | PURPOSE:
 |     Inserts a given transaction into a currently running batch
 |     or into a new batch as per given flag.
 |
 |     This method is called by every grouping rule to add
 |     a given transaction into a current batch/new batch.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insertTrxnIntoBatch(
     x_batchRec            IN OUT NOCOPY batchAttrRecType,
     x_batchTab            IN OUT NOCOPY batchAttrTabType,
     p_newBatchFlag        IN            BOOLEAN,
     x_currentBatchId      IN OUT NOCOPY IBY_BATCHES_ALL.batchid%TYPE,
     x_trxnsInBatchTab     IN OUT NOCOPY trxnsInBatchTabType,
     x_trxnsInBatchRec     IN OUT NOCOPY trxnsInBatchRecType,
     x_trxnsInBatchCount   IN OUT NOCOPY NUMBER
     )
 IS
 l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                '.insertTrxnIntoBatch';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * GROUPING LOGIC IS IN IF-ELSE BLOCK BELOW:
      *
      * Irrespective of whether this transaction is part of
      * an existing batch or whether it should be part
      * of a new batch, ensure that the PLSQL batches
      * table is updated with the details of this transaction
      * within this if-else block.
      *
      * We need to do this each time we enter this procedure
      * because this might well be the last transaction in
      * in the provided profile, and this procedure may
      * not be called again for this profile. So
      * the PLSQL batches table should always be up-to-date
      * when it exits this procedure.
      */

     IF (p_newBatchFlag = true) THEN

         /*
          * This is a new batch; Get an id for this batch
          */
         getNextBatchId(x_currentBatchId);

         /*
          * Create a new batch record using the incoming
          * transaction as a constituent, and insert this record
          * into the PLSQL batches table.
          */
         x_batchRec.mbatch_id        := x_currentBatchId;
         x_trxnsInBatchCount         := 1;

         x_batchTab(x_batchTab.COUNT + 1) := x_batchRec;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name,' Inserted transaction : '
	             || x_trxnsInBatchRec.trxn_id || ' into new batch: '
	             || x_currentBatchId);

         END IF;
         /*
          * Assign the batch id of the new batch to this
          * trxn, and insert the trxn into the trxns array.
          */
         x_trxnsInBatchRec.mbatch_id := x_batchRec.mbatch_id;
         x_trxnsInBatchTab(x_trxnsInBatchTab.COUNT + 1) := x_trxnsInBatchRec;

     ELSE

         /*
          * This means we need to add the incoming transaction to
          * the current batch.
          */

         /*
          * First check special case: Payments PLSQL table is empty
          *
          * If the PLSQL table for batches is empty, we have to
          * initialize it by inserting a dummy record. This dummy
          * record will get overwritten below.
          */
         IF (x_batchTab.COUNT = 0) THEN

             getNextBatchId(x_currentBatchId);

             x_batchRec.mbatch_id := x_currentBatchId;
             x_trxnsInBatchCount := 0;

             /*
              * Insert the first record into the table. This
              * is a dummy record.
              */
             x_batchTab(x_batchTab.COUNT + 1) := x_batchRec;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Created a new batch: '
	                 || x_currentBatchId);

             END IF;
         END IF;

         /*
          * The incoming transaction should be part of the current batch.
          * So add the document amount to the current payment
          * record and increment the document count for the current
          * payment record.
          */
         x_batchRec.mbatch_id   := x_currentBatchId;
         x_trxnsInBatchCount    := x_trxnsInBatchCount + 1;

         --x_batchRec.payment_amount :=
         --    x_batchRec.payment_amount + x_trxnsInBatchRec.document_amount;

         /*
          * Overwrite the current batch record in the
          * PLSQL batches table with the updated record.
          */
         x_batchTab(x_batchTab.COUNT) := x_batchRec;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Inserted transaction: '
	             || x_trxnsInBatchRec.trxn_id || ' into existing batch: '
	             || x_currentBatchId);

         END IF;
         /*
          * Assign the batch id of the current batch to this
          * transaction, and insert the trxn into the trxns array.
          */
         x_trxnsInBatchRec.mbatch_id := x_batchRec.mbatch_id;
         x_trxnsInBatchTab(x_trxnsInBatchTab.COUNT + 1) := x_trxnsInBatchRec;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END insertTrxnIntoBatch;

/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |     This procedure prints the debug message to the concurrent manager
 |     log file.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(
     p_module     IN VARCHAR2,
     p_debug_text IN VARCHAR2
     )
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 BEGIN

     /*
      * If FND_GLOBAL.conc_request_id is -1, it implies that
      * this method has not been invoked via the concurrent
      * manager. In that case, write to apps log else write
      * to concurrent manager log file.
      */
     /*Remove this 2 lines after debugging*/
    -- INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
    --        || p_debug_text, sysdate);
    -- commit;

     IF (FND_GLOBAL.conc_request_id = -1) THEN

         /*
          * OPTION I:
          * Write debug text to the common application log file.
          */
         IBY_DEBUG_PUB.add(
             substr(RPAD(p_module,55) || ' : ' || p_debug_text, 0, 150),
             FND_LOG.G_CURRENT_RUNTIME_LEVEL,
             'iby.plsql.IBY_VALIDATIONSETS_PUB'
             );

         /*
          * OPTION II:
          * Write debug text to DBMS output file.
          */
         --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
         --    p_debug_text, 0, 150));

         /*
          * OPTION III:
          * Write debug text to temporary table.
          *
          * Use this script to create a debug table.
          * CREATE TABLE TEMP_IBY_LOGS(TEXT VARCHAR2(4000), TIME DATE);
          */
         /* uncomment these two lines for debugging */
         --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
         --    || p_debug_text, sysdate);

         --COMMIT;

     ELSE

         /*
          * OPTION I:
          * Write debug text to the concurrent manager log file.
          */
         FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_debug_text);

         /*
          * OPTION II:
          * Write debug text to DBMS output file.
          */
         --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
         --    p_debug_text, 0, 150));

         /*
          * OPTION III:
          * Write debug text to temporary table.
          *
          * Use this script to create a debug table.
          * CREATE TABLE TEMP_IBY_LOGS(TEXT VARCHAR2(4000), TIME DATE);
          */
         /* uncomment these two lines for debugging */
         --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
         --    || p_debug_text, sysdate);

         --COMMIT;

     END IF;

 END print_debuginfo;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextBatchId
 |
 | PURPOSE:
 |     Returns the next batch id from a sequence. These ids are
 |     used to uniquely number batches.
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getNextBatchId(
     x_batchID IN OUT NOCOPY IBY_BATCHES_ALL.batchid%TYPE
     )
 IS

 BEGIN

     SELECT IBY_BATCHID_S.NEXTVAL INTO x_batchID
         FROM DUAL;

 END getNextBatchId;

  -- Checks if a row already exists in transactions table
  -- based on the values passed.  This function is called by
  -- for query batch and query transaction operations to check
  -- before inserting a row.

  FUNCTION checkrows
	(order_id_in  	     IN     iby_transactions_v.order_id%TYPE,
	 merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
	 vendor_id_in	     IN     iby_transactions_v.vendor_id%TYPE,

	 status_in	     IN     iby_transactions_v.status%TYPE,
	 trxn_type_in	     IN     iby_transactions_v.trxn_type%TYPE)
   RETURN number

  IS

   	l_numrows	NUMBER := 0;
	l_needupdate    boolean;
	 l_tx1	     iby_transactions_v.trxn_type%TYPE;
	 l_tx2	     iby_transactions_v.trxn_type%TYPE;

     CURSOR c_getNumTrxns(tx1 NUMBER,
             tx2 NUMBER DEFAULT NULL)
	IS
           SELECT count(*)
           FROM iby_transactions_v
           WHERE order_Id = order_id_in
           AND merchant_id = merchant_id_in
	   AND vendor_id = vendor_id_in
	   AND status = status_in
	   AND trxn_type = tx1;
           --AND trxn_type IN (tx1, tx2);
	   --AND trxn_type IS NOT NULL;  -- add this for 'other operations' case

   BEGIN
	IF (c_getNumTrxns%isopen) THEN
		close c_getNumTrxns;
	END IF;

	-- no longer distinguish different trxntypeid returned by
	-- Cybercash, considering 'closeBatch' effect
	/*
	IF (trxn_type_in = 8 or trxn_type_in = 9) THEN
	   -- capture operations
	   l_needupdate := true;
	   open c_getNumTrxns(8, 9);

	ELSIF (trxn_type_in = 5 or trxn_type_in = 10) THEN
	   -- return operations
	   l_needupdate := true;
	   l_tx1 := 5;
	   l_tx2 := 10;
	   open c_getNumTrxns(5, 10);
	ELSIF (trxn_type_in = 13 or trxn_type_in = 14) THEN
		-- void capture
	   l_needupdate := true;
	   l_tx1 := 13;
	   l_tx2 := 14;
	   open c_getNumTrxns(13, 14);
	ELSIF (trxn_type_in = 17 or trxn_type_in = 18) THEN
		-- void return
	   l_needupdate := true;
	   l_tx1 := 17;
	   l_tx2 := 18;
	   open c_getNumTrxns(17, 18);
	ELSE
	   -- other operations
	   l_needupdate := false;
	   open c_getNumTrxns(trxn_type_in);
	END IF;

	*/

	open c_getNumTrxns(trxn_type_in);

	FETCH c_getNumTrxns INTO l_numrows;
	/* IF (l_numrows > 0 AND l_needupdate) THEN
	   UPDATE iby_trxn_summaries_all
	   SET trxntypeid = trxn_type_in
           WHERE tangibleid = order_id_in
           AND payeeid = merchant_id_in
	   AND bepid = vendor_id_in
	   AND status = status_in
           AND trxntypeid IN (l_tx1, l_tx2);
	END IF; */

	CLOSE c_getNumTrxns;

   	RETURN l_numrows;

   END checkrows;


  /* Inserts the transaction record for the closebatch operation */

  PROCEDURE insert_batch_txn
    (ecapp_id_in	 IN	iby_trxn_summaries_all.ECAPPID%TYPE,

     order_id_in      IN     iby_transactions_v.order_id%TYPE,
     merchant_id_in   IN     iby_transactions_v.merchant_id%TYPE,
     merch_batchid_in	 IN	 iby_transactions_v.MerchBatchID%TYPE,
     vendor_id_in     IN     iby_transactions_v.vendor_id%TYPE,
     vendor_key_in    IN     iby_transactions_v.bepkey%TYPE,
     status_in		 IN	iby_transactions_v.status%TYPE,
     time_in		 IN	iby_transactions_v.time%TYPE,
     trxn_type_in	 IN	iby_transactions_v.trxn_type%TYPE,
     vendor_code_in	 IN	iby_transactions_v.vendor_code%TYPE,
     vendor_message_in	 IN	iby_transactions_v.vendor_message%TYPE,
     error_location_in	 IN	iby_transactions_v.error_location%TYPE,

     trace_number_in	    IN	  iby_transactions_v.TraceNumber%TYPE,
	 org_id_in IN iby_trxn_summaries_all.org_id%type,
     transaction_id_out  OUT NOCOPY iby_trxn_summaries_all.TransactionID%TYPE)

  IS

    num_rows 	NUMBER;
    l_trxn_mid	     NUMBER;
    transaction_id NUMBER;

    l_mpayeeid iby_payee.mpayeeid%type;
    l_mbatchid iby_batches_all.mbatchid%type;
    l_mtangibleid iby_tangible.mtangibleid%type;

    l_prev_trxn_count number;
    l_reqtype iby_trxn_summaries_all.reqtype%type;
    l_instrtype iby_trxn_summaries_all.instrtype%type;
    l_instrsubtype iby_trxn_summaries_all.instrsubtype%type;
  BEGIN

  -- Update the existing row for this order id with merchant batch id
  -- Only the transaction types auth,authcapture,return,capture,markcapture
  -- and markreturn are taken into account.

  -- capture/markedcapture
  -- mark the authonly, authcapture, capture and Markcapture with the batchid
  IF (trxn_type_in = 8 OR trxn_type_in = 9)  THEN
	l_reqtype := 'ORAPMTCAPTURE';
	--dbms_output.put_line('position 1');
    getMBatchId(merch_batchid_in, merchant_id_in, l_mbatchid);
    UPDATE iby_trxn_summaries_all
    SET BatchID = merch_batchid_in,
    	MBatchID = l_mbatchid,
    last_update_date=sysdate,
    updatedate = sysdate,
    last_updated_by = fnd_global.user_id,
    creation_date = sysdate,
    created_by = fnd_global.user_id,
    object_version_number = object_version_number + 1
    WHERE TangibleID =	order_id_in
    AND PayeeID = merchant_id_in
    AND TrxntypeID IN (2, 3, 8,9)
    AND Status = 0;

  -- For return/credit transaction type, mark the return, MarkReturn
  --	transaction type  with batchid
  ELSIF (trxn_type_in = 5 OR trxn_type_in = 10) THEN
	l_reqtype := 'ORAPMTRETURN';
	--dbms_output.put_line('position 2');
    getMBatchId(merch_batchid_in, merchant_id_in, l_mbatchid);

    UPDATE iby_trxn_summaries_all

    SET BatchID = merch_batchid_in,
	MBatchID = l_mbatchid,
    last_update_date=sysdate,
    updatedate = sysdate,
    last_updated_by = fnd_global.user_id,
    creation_date = sysdate,
    created_by = fnd_global.user_id,
    object_version_number = object_version_number + 1
    WHERE TangibleID =	order_id_in
    AND PayeeID = merchant_id_in
	AND TrxntypeID IN (5, 10)
    AND Status = 0;

  END IF;

  num_rows := checkrows(order_id_in, merchant_id_in, vendor_id_in,
			status_in, trxn_type_in);

  --dbms_output.put_line('position 3 ' || num_rows);


 IF num_rows = 0  THEN
  -- Now insert a new row for this transaction in the batch
  -- Get the transaction id first
      SELECT count(*)
      INTO l_prev_trxn_count
      FROM iby_trxn_summaries_all
      WHERE  tangibleid = order_id_in AND
	     payeeid = merchant_id_in;

	IF (l_prev_trxn_count = 0) THEN
		-- this happens when previous trxn wasn't recorded in
		-- payment server, e.g, Aalok/Jonathan's testing --jjwu
		-- what about mtangibleid ???
	  transaction_id_out := getTID(merchant_id_in, order_id_in);
	  l_mtangibleid := -1;
	ELSE
      	   SELECT DISTINCT transactionid, mtangibleid, instrtype, instrsubtype
      	   INTO transaction_id_out, l_mtangibleid, l_instrtype, l_instrsubtype
       	   FROM iby_trxn_summaries_all
           WHERE  tangibleid = order_id_in AND
	        payeeid = merchant_id_in
		AND status = 0;
	END IF;

	--dbms_output.put_line('position 4');
  -- Get the master transaction id for this record

     SELECT iby_trxnsumm_mid_s.NEXTVAL
	INTO l_trxn_mid
	FROM dual;

	--dbms_output.put_line('position 5');

	getMBatchId(merch_batchid_in, merchant_id_in, l_mbatchid);
	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);


	-- this insertion from close/query batch is problematic
	-- 1) there is no corresponding entry in ibY_trxn_core table
	-- 2) mtangible id might not be correct, there might not be
	--    an entry in iby_tangible table
	-- 3) currency, amount is missing
	-- regardless, this should be a rare case, it exists because
	-- 1) Cybercash doesn't return 'trxntypeid' for capture/return
	--    accurately
	-- 2) during testing, there are trxns submitted directly to bep
	--    (not through iPayment)
	-- 3) during testing, requests submitted to Cybercash regular
	--    and Cybercash SSL are considered different, but during close
	--    batch, they are mixed.
     INSERT INTO iby_trxn_summaries_all
	(TrxnMID, TransactionID,TangibleID,MPayeeID, PayeeID,BEPID, bepKey,
	 ECAppID,org_id, Status, UpdateDate,TrxnTypeID, MBatchID, BatchID,
	 BEPCode,BEPMessage,Errorlocation,
	ReqType, ReqDate, mtangibleid,
	 last_update_date,last_updated_by,creation_date,created_by,

	 last_update_login,object_version_number,instrType,instrsubtype,needsupdt)
      VALUES (l_trxn_mid,  transaction_id_out,
	      order_id_in, l_mpayeeid, merchant_id_in, vendor_id_in,
	       vendor_key_in, ecapp_id_in, org_id_in, status_in, time_in,
		trxn_type_in, l_mbatchid, merch_batchid_in,
	      vendor_code_in, vendor_message_in, error_location_in,
		l_reqtype, sysdate, l_mtangibleid,
	 	sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
		fnd_global.login_id,1,l_instrtype,l_instrsubtype,'Y');
	--dbms_output.put_line('position 6');
  ELSE

    -- retrieve existing tid out
    SELECT distinct(transactionid)
      INTO transaction_id_out
      FROM iby_trxn_summaries_all
      WHERE tangibleid = order_id_in
	AND payeeid = merchant_id_in
	AND bepid = vendor_id_in
	AND trxntypeid = trxn_type_in
	AND status = status_in;

  END IF;

  COMMIT;
  END insert_batch_txn;


 /* Inserts transaction record for transaction query operation */

  PROCEDURE insert_query_txn
    (transaction_id_in   IN     iby_trxn_summaries_all.TransactionID%TYPE,
     order_id_in         IN     iby_transactions_v.order_id%TYPE,
     merchant_id_in      IN     iby_transactions_v.merchant_id%TYPE,
     vendor_id_in        IN     iby_transactions_v.vendor_id%TYPE,
     vendor_key_in       IN     iby_transactions_v.bepkey%TYPE,
     status_in           IN     iby_transactions_v.status%TYPE,
     time_in             IN     iby_transactions_v.time%TYPE DEFAULT sysdate,
     trxn_type_in        IN     iby_transactions_v.trxn_type%TYPE,
     amount_in           IN     iby_transactions_v.amount%TYPE DEFAULT NULL,
     currency_in         IN     iby_transactions_v.currency%TYPE DEFAULT NULL,
     payment_name_in     IN     iby_transactions_v.payment_name%TYPE DEFAULT NULL,
     authcode_in         IN     iby_transactions_v.authcode%TYPE DEFAULT NULL,
     referencecode_in    IN     iby_transactions_v.referencecode%TYPE DEFAULT NULL,
     avscode_in          IN     iby_transactions_v.AVScode%TYPE DEFAULT NULL,
     acquirer_in         IN     iby_transactions_v.acquirer%TYPE DEFAULT NULL,
     auxmsg_in           IN     iby_transactions_v.Auxmsg%TYPE DEFAULT NULL,
     vendor_code_in      IN     iby_transactions_v.vendor_code%TYPE DEFAULT NULL,
     vendor_message_in   IN     iby_transactions_v.vendor_message%TYPE DEFAULT NULL,
     error_location_in   IN     iby_transactions_v.error_location%TYPE DEFAULT NULL,
     trace_number_in     IN     iby_transactions_v.TraceNumber%TYPE DEFAULT NULL,
     org_id_in           IN     iby_trxn_summaries_all.org_id%type DEFAULT NULL,
     ecappid_in          IN     iby_ecapp.ecappid%type,
     req_type_in         IN     iby_trxn_summaries_all.reqtype%type)
  IS

    num_rows	  NUMBER;
    l_trxn_mid	     NUMBER;
    l_mpayeeid iby_payee.mpayeeid%type;
   l_mtangibleid iby_trxn_summaries_all.mtangibleid%type;
	l_cnt number;
    l_instrtype iby_trxn_summaries_all.instrtype%type;
    l_instrsubtype iby_trxn_summaries_all.instrsubtype%type;
   l_trxnref iby_trxn_summaries_all.trxnref%type;

    CURSOR c_trxnmid(
                    ci_trxnid iby_trxn_summaries_all.TransactionID%TYPE,
                    ci_merchid iby_trxn_summaries_all.PayeeId%TYPE,
                    --ci_trxntype iby_trxn_summaries_all.TrxnTypeId%TYPE,
                    ci_reqtype iby_trxn_summaries_all.ReqType%TYPE,
                    ci_status iby_trxn_summaries_all.Status%TYPE
                    )
    IS
      SELECT trxnmid
      FROM iby_trxn_summaries_all
      WHERE (status = ci_status)
      AND (payeeid = ci_merchid)
      AND (transactionid = ci_trxnid)
      AND (reqtype = ci_reqtype);

    CURSOR c_order_info
           (
           ci_orderid iby_transactions_v.order_id%TYPE,
           ci_merchid iby_transactions_v.merchant_id%TYPE
           )
    IS
      SELECT mtangibleid, instrtype, instrsubtype, trxnref
      FROM iby_trxn_summaries_all
      WHERE (tangibleid = ci_orderid)
      AND (payeeid = ci_merchid)
      AND (mtangibleid <> -1)
      ORDER BY reqdate DESC;

  BEGIN

  IF (c_trxnmid%ISOPEN) THEN
    CLOSE c_trxnmid;
  END IF;

  IF (c_order_info%ISOPEN) THEN
    CLOSE c_order_info;
  END IF;

  -- find any transitional trxns and update them
  --
  OPEN c_trxnmid(transaction_id_in,merchant_id_in,req_type_in,9);
  FETCH c_trxnmid INTO l_trxn_mid;

  IF (c_trxnmid%NOTFOUND) THEN
    CLOSE c_trxnmid;
  ELSE
    -- a transitional trxn (cut off in mid-process)
    -- exists ; update it instead of adding a new
    -- row
    CLOSE c_trxnmid;

    UPDATE iby_trxn_summaries_all
    SET ReqDate = NVL(time_in,reqdate),
        --Amount = amount_in,
        --CurrencyNameCode = currency_in,
        UpdateDate = NVL(time_in,updatedate),
        Status = status_in,
	BEPCode = vendor_code_in,
        BEPMessage = vendor_message_in,
        Errorlocation = error_location_in,
        instrType = NVL(l_instrtype,instrType),
        instrsubtype = NVL(l_instrsubtype,instrsubtype),
        --org_id = org_id_in,
	last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
	last_update_login = fnd_global.login_id,
        object_version_number = object_version_number+1
    WHERE (trxnmid = l_trxn_mid);

    UPDATE iby_trxn_core
    SET AuthCode = authcode_in,
        ReferenceCode = referencecode_in,
        AVSCode = avscode_in,
        Acquirer = acquirer_in,
        Auxmsg = auxmsg_in,
	TraceNumber = trace_number_in,
        InstrName = NVL(payment_name_in,instrname),
	last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id,
        object_version_number = object_version_number+1
    WHERE (trxnmid = l_trxn_mid);

    COMMIT;
    RETURN;
  END IF;

   -- Check if row is already in table using unique
   -- key of order_id, merchant_id, vendor_id, transaction_type
   -- and status.  We dont want to update those
   -- rows which have non-zero status.	We would like to save
   -- them for history

  -- collate differnt trxn types as certain gateways may be returning
  -- codes different from the value stored in trnxtypeid
  --
  IF (trxn_type_in = 8 or trxn_type_in = 9) THEN
    num_rows := checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,8);
    num_rows := num_rows + checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,9);
  ELSIF (trxn_type_in = 5 or trxn_type_in = 10) THEN
    num_rows := checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,5);
    num_rows := num_rows + checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,10);
  ELSIF (trxn_type_in = 13 or trxn_type_in = 14) THEN
    num_rows := checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,13);
    num_rows := num_rows + checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,14);
  ELSIF (trxn_type_in = 17 or trxn_type_in = 18) THEN
    num_rows := checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,17);
    num_rows := num_rows + checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,18);
  ELSE
    num_rows := num_rows + checkrows(order_id_in,merchant_id_in,vendor_id_in,status_in,trxn_type_in);
  END IF;

  -- If no record found insert this row otherwise no need to update
  IF num_rows = 0
  THEN

      SELECT iby_trxnsumm_mid_s.NEXTVAL
	INTO l_trxn_mid
	FROM dual;

	iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);


	-- try to get mtangibleid
	select count(*) into l_cnt from iby_trxn_summaries_all
	where tangibleid = order_id_in and
	payeeid = merchant_id_in and
	mtangibleid <> -1;

	-- no -1:
	-- see insert_batch_txn, we want to ignore trxns done directly
	-- on BEP, w/o going through iPayment
	-- and other unknown cases

	if (l_cnt > 0) then
          OPEN c_order_info(order_id_in,merchant_id_in);
          FETCH c_order_info INTO l_mtangibleid, l_instrtype, l_instrsubtype,
l_trxnref;
          CLOSE c_order_info;
	else
		-- I can not get mtangibleid from the iby_tangible table
		-- because it is missing the payee info
		l_mtangibleid := -1;
	end if;

      INSERT INTO iby_trxn_summaries_all
	(ECAppID, TrxnMID, TransactionID,TrxntypeID, ReqDate, ReqType,
	 Amount,CurrencyNameCode, UpdateDate,Status,
	 TangibleID,MPayeeID, PayeeID,BEPID, bepKey, MTangibleID,
	 BEPCode,BEPMessage,Errorlocation, org_id,
	 last_update_date,last_updated_by,creation_date,created_by,
	 last_update_login,object_version_number,instrType,instrsubtype,trxnref,needsupdt)
      VALUES (ecappid_in, l_trxn_mid, transaction_id_in, trxn_type_in,
		time_in, req_type_in,
	      amount_in, currency_in, time_in, status_in,
	      order_id_in, l_mpayeeid, merchant_id_in, vendor_id_in,
		vendor_key_in, l_mtangibleid,
	      vendor_code_in, vendor_message_in, error_location_in, org_id_in,
		 sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
		fnd_global.login_id,1,l_instrtype,l_instrsubtype,l_trxnref,'Y');

      INSERT INTO iby_trxn_core
	(TrxnMID, AuthCode, ReferenceCode, AVSCode, Acquirer, Auxmsg,
	TraceNumber, InstrName,
	 last_update_date,last_updated_by,creation_date,created_by,last_update_login,

	  object_version_number)
      VALUES (l_trxn_mid, authcode_in,referencecode_in,avscode_in, acquirer_in,
auxmsg_in, trace_number_in, payment_name_in,

	 sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id,1);

  END IF;

  COMMIT;


  END insert_query_txn;


  /* updates the statuses of trxns saved in a batch */
  PROCEDURE updateBatchedTrxns
	(
	payeeid_in	IN	iby_trxn_summaries_all.payeeid%TYPE,
	bepid_in	IN	iby_trxn_summaries_all.bepid%TYPE,
	bepkey_in	IN	iby_trxn_summaries_all.bepkey%TYPE,
	oldstatus_in	IN	iby_trxn_summaries_all.status%TYPE,
	newstatus_in	IN	iby_trxn_summaries_all.status%TYPE,
	oldbatchid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	newbatchid_in	IN      iby_trxn_summaries_all.batchid%TYPE
	)
  IS
	l_mbatchid	iby_trxn_summaries_all.mbatchid%TYPE;
  BEGIN

	BEGIN
	     getMBatchId(oldbatchid_in, payeeid_in, l_mbatchid);
	--
	-- catch exception in the case where the batch id has not been
	-- stored yet in IBY_BATCHES_ALL ; this can happen when we
	-- want to change the status of transitional trxns
	--
	EXCEPTION WHEN others THEN
	     l_mbatchid := NULL;
	END;

	UPDATE iby_trxn_summaries_all
	SET
	  status = newstatus_in,
	  batchid = newbatchid_in,
	  mbatchid = l_mbatchid,
	  last_update_date = sysdate,
          updatedate = sysdate,
          last_updated_by = fnd_global.user_id,
          object_version_number = object_version_number + 1
	WHERE (bepid = bepid_in)
	  AND (bepkey = bepkey_in)
	  AND (payeeid = payeeid_in)
	  AND (status = oldstatus_in)
          AND ((instrtype='CREDITCARD') OR (instrtype='PURCHASECARD') OR (instrtype IS NULL))
	  AND ((batchid IS NULL AND oldbatchid_IN IS NULL) OR (batchid = oldbatchid_in));

	COMMIT;

  END updateBatchedTrxns;


  /* Regular version of this method. */
  PROCEDURE updateBatchQueryTrxn
	(
	payeeid_in	IN	iby_trxn_summaries_all.payeeid%TYPE,
	orderid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	trxn_type_in	IN      iby_trxn_summaries_all.trxntypeid%TYPE,
	batchid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	bep_code_in     IN      iby_trxn_summaries_all.bepcode%TYPE,
	bep_msg_in      IN      iby_trxn_summaries_all.bepmessage%TYPE,
	error_loc_in    IN      iby_trxn_summaries_all.errorlocation%TYPE,
	trxnid_out      OUT NOCOPY iby_trxn_summaries_all.transactionid%TYPE
	)
  IS
  BEGIN

      UPDATE
	iby_trxn_summaries_all

      SET
	status=status_in,
	--
	-- only change these values if they have non-trivial values
	--
	bepcode=DECODE(NVL(bep_code_in,''), '',bepcode, bep_code_in),
	bepmessage=DECODE(NVL(bep_msg_in,''), '',bepmessage, bep_msg_in),
	errorlocation=DECODE(NVL(error_loc_in,''), '',errorlocation, error_loc_in),
	last_update_date = sysdate,
	last_updated_by = fnd_global.user_id,
	object_version_number = object_version_number + 1

      WHERE

        --
        -- Where clause modified to support
        -- returns (transaction type 5):
        -- Returns(5) and credits(11) are to be
        -- treated as equivalents because in the
        -- processor model we send return transactions
        -- as credits. When we query for the status of
        -- such a credit, we must remember to update the
        -- status of the original return.
        --

	(payeeid = payeeid_in) AND
	(tangibleid = orderid_in) AND
	(trxntypeid IN (trxn_type_in, 5)) AND
	(batchid = batchid_in);

      IF (SQL%NOTFOUND) THEN
	trxnid_out := -1;
      ELSE
        trxnid_out := getTID(payeeid_in, orderid_in);
      END IF;

      COMMIT;

  END updateBatchQueryTrxn;


  /* auth version of the method. */
  PROCEDURE updateBatchQueryTrxn
	(
	payeeid_in	IN	iby_trxn_summaries_all.payeeid%TYPE,
	orderid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	trxn_type_in	IN      iby_trxn_summaries_all.trxntypeid%TYPE,
	batchid_in	IN	iby_trxn_summaries_all.batchid%TYPE,
	status_in	IN	iby_trxn_summaries_all.status%TYPE,
	bep_code_in     IN      iby_trxn_summaries_all.bepcode%TYPE,
	bep_msg_in      IN      iby_trxn_summaries_all.bepmessage%TYPE,
	error_loc_in    IN      iby_trxn_summaries_all.errorlocation%TYPE,
	authcode_in     IN      iby_trxn_core.authcode%TYPE,
	avscode_in      IN      iby_trxn_core.avscode%TYPE,
	cvv2result_in   IN      iby_trxn_core.cvv2result%TYPE,
	trxnid_out      OUT NOCOPY iby_trxn_summaries_all.transactionid%TYPE
	)
  IS
	l_trxnmid	iby_trxn_summaries_all.trxnmid%TYPE;
  BEGIN

     updateBatchQueryTrxn(payeeid_in,orderid_in,trxn_type_in,batchid_in,status_in,bep_code_in,bep_msg_in,error_loc_in,trxnid_out);

     SELECT
       trxnmid
     INTO
       l_trxnmid
     FROM
       iby_trxn_summaries_all
     WHERE

        --
        -- Where clause modified to support
        -- returns (transaction type 5):
        -- Returns(5) and credits(11) are to be
        -- treated as equivalents because in the
        -- processor model we send return transactions
        -- as credits. When we query for the status of
        -- such a credit, we must remember to update the
        -- status of the original return.
        --

       (transactionid = trxnid_out) AND
       (payeeid = payeeid_in) AND
       (trxntypeid IN (trxn_type_in, 5));

     IF (SQL%NOTFOUND) THEN
       RETURN;
     END IF;

     UPDATE
       iby_trxn_core
     SET
       authcode=authcode_in,
       cvv2result=cvv2result_in,
       avscode=avscode_in
     WHERE
       (trxnmid=l_trxnmid);

     COMMIT;

  END updateBatchQueryTrxn;

  PROCEDURE Update_Batch
  (
   ecapp_id_in          IN      iby_batches_all.ecappid%TYPE,
   payeeid_in	        IN      iby_trxn_summaries_all.payeeid%TYPE,
   batchid_in           IN      iby_trxn_summaries_all.batchid%TYPE,
   batch_status_in      IN      iby_batches_all.batchstatus%TYPE,
   batch_total_in       IN      iby_batches_all.batchtotal%TYPE,
   sale_amount_in       IN      iby_batches_all.batchsales%TYPE,
   credit_amount_in     IN      iby_batches_all.batchcredit%TYPE,
   bep_code_in          IN      iby_batches_all.bepcode%TYPE,
   bep_message_in       IN      iby_batches_all.bepmessage%TYPE,
   error_location_in    IN      iby_batches_all.errorlocation%TYPE,
   ack_type_in          IN      VARCHAR2,
   trxn_orderid_in	IN	JTF_VARCHAR2_TABLE_100,
   trxn_reqtype_in      IN      JTF_VARCHAR2_TABLE_100,
   trxn_status_in	IN	JTF_VARCHAR2_TABLE_100,
   trxn_bep_code_in     IN      JTF_VARCHAR2_TABLE_100,
   trxn_bep_msg_in      IN      JTF_VARCHAR2_TABLE_100,
   trxn_error_loc_in    IN      JTF_VARCHAR2_TABLE_100,
   trxn_authcode_in     IN      JTF_VARCHAR2_TABLE_100,
   trxn_avscode_in      IN      JTF_VARCHAR2_TABLE_100,
   trxn_cvv2result_in   IN      JTF_VARCHAR2_TABLE_100,
   trxn_tracenumber     IN      JTF_VARCHAR2_TABLE_100
  )
  IS
    l_tmid     iby_trxn_summaries_all.trxnmid%TYPE;
    l_tid      iby_trxn_summaries_all.transactionid%TYPE;
    l_count    NUMBER := 0;
    l_module VARCHAR2(100) := G_DEBUG_MODULE || '.Update_Batch';

    CURSOR c_tmid
           (ci_payeeid iby_trxn_summaries_all.payeeid%TYPE,
            ci_orderid iby_trxn_summaries_all.tangibleid%TYPE,
            ci_reqtype iby_trxn_summaries_all.reqtype%TYPE,
            ci_mbatchid iby_trxn_summaries_all.mbatchid%TYPE
            )
    IS
      SELECT trxnmid, transactionid
      FROM iby_trxn_summaries_all
      WHERE (payeeid = ci_payeeid)
        AND (tangibleid = ci_orderid)
        -- ack cannot distinguish between credits and returns
        AND (DECODE(reqtype, 'ORAPMTRETURN','ORAPMTCREDIT', reqtype) =
           ci_reqtype)
        AND (status = iby_transactioncc_pkg.C_STATUS_BATCH_PENDING)
        AND (mbatchid = ci_mbatchid);

      -- [lmallick] - bug# 9414266
   -- gets the trxnmid of the capture trxn associated with the auth
   -- that includes the tracenumber.  The tracenumber is assigned only
   -- to the auth not capture trxns

   -- Modified the curser to strengthen the filter criteria by
   -- including 'mbatchid'. FDC doesn't accept tracenumbers of more
   -- than 6 digits in the IBY.Q (and above) versions. We need to reset
   -- the tracenumber field if it has reached a length of 7. This will
   -- cause duplicates. Including mbatchid in the filter will eliminate
   -- such possibilities to a great extent. (Maybe, in future,we can
   -- include orderid and/or authcode. But, currently these are passed
   -- as null. Fixes on those attributes may help us in making the flow
   -- even more robust.)

   CURSOR c_tracenumber
          (ci_tracenumber iby_trxn_core.tracenumber%TYPE,
	   ci_mbatchid iby_trxn_summaries_all.mbatchid%TYPE
	  ) IS
    SELECT ibs.trxnmid, ibs.transactionid
      FROM iby_trxn_summaries_all ibs,
           iby_trxn_summaries_all orig_trxn,
           iby_trxn_core   ibc
     WHERE ibs.transactionid = orig_trxn.transactionid
       AND ibs.trxntypeid = 8
       AND orig_trxn.trxnmid=ibc.trxnmid
       AND ibc.tracenumber=ci_tracenumber
       AND ibs.mbatchid=ci_mbatchid
       AND ibs.status = iby_transactioncc_pkg.C_STATUS_BATCH_PENDING;

  BEGIN

    IF (c_tmid%ISOPEN) THEN CLOSE c_tmid; END IF;
    IF (c_tracenumber%ISOPEN) THEN CLOSE c_tracenumber; END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module,'batch_total_in:'|| batch_total_in);
	    print_debuginfo(l_module,'sale_amount_in:'|| sale_amount_in);
	    print_debuginfo(l_module,'credit_amount_in:'|| credit_amount_in);
	    print_debuginfo(l_module,'bep_code_in:'|| bep_code_in);
	    print_debuginfo(l_module,'bep_message_in:'|| bep_message_in);
    END IF;

    UPDATE iby_batches_all
    SET batchstatus = batch_status_in,
      batchtotal = batch_total_in,
      batchsales = sale_amount_in,
      batchcredit = credit_amount_in,
      bepcode = bep_code_in,
      bepmessage = bep_message_in,
      errorlocation = error_location_in,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      object_version_number = object_version_number + 1
    WHERE (payeeid = payeeid_in)
      AND (mbatchid = batchid_in);

    -- trxn status data probably not known
    -- immediately after batch close
    --
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo(l_module,'trxn_status_in.count: '|| trxn_status_in.count);
    END IF;

    IF (trxn_status_in.count<>0) THEN


    FOR i IN trxn_status_in.FIRST .. trxn_status_in.LAST LOOP
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module,'tracenumber= '||trxn_tracenumber(i));
    END IF;
    IF(NVL(trxn_tracenumber(i), 0)<>0)  THEN


   OPEN c_tracenumber(trxn_tracenumber(i), batchid_in);
   FETCH  c_tracenumber into l_tmid, l_tid;

   ELSE
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module,'tracenumber is 0 ');
      END IF;

      OPEN c_tmid(payeeid_in,trxn_orderid_in(i),trxn_reqtype_in(i),batchid_in);
      FETCH c_tmid INTO l_tmid, l_tid;

  END IF;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module,'l_tmid= '||l_tmid||', l_tid = '||l_tid);
      END IF;

      --trxnid_out.extend(1);
      l_count := l_count +1;

      IF (l_tmid IS NOT NULL) THEN
	      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo(l_module,'l_tmid is not null. Updating iby_trxn tables.');
	      END IF;
        UPDATE iby_trxn_summaries_all
        SET status = TO_NUMBER(trxn_status_in(i)),
          bepcode = trxn_bep_code_in(i),
          bepmessage = trxn_bep_msg_in(i),
          errorlocation = TO_NUMBER(trxn_error_loc_in(i)),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          object_version_number = object_version_number + 1
        WHERE (trxnmid = l_tmid);

        UPDATE iby_trxn_core
        SET authcode = trxn_authcode_in(i),
          avscode = trxn_avscode_in(i),
          cvv2result = trxn_cvv2result_in(i),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          object_version_number = object_version_number + 1
        WHERE (trxnmid = l_tmid);

        --trxnid_out(i) := l_tid;
      ELSE

        --trxnid_out(i) := -1;
        null;
      END IF;

    IF (c_tmid%ISOPEN) THEN
      CLOSE c_tmid;
    END IF;

    IF (c_tracenumber%ISOPEN) THEN
      CLOSE c_tracenumber;
    END IF;


    END LOOP;
    ELSE

    -- for some acknowledgements missing transactions are
    -- implicitly assumed to have succeeded or failed
    --
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module,'ack_type is: '||ack_type_in);
    END IF;
    IF ((ack_type_in = 'P') OR (ack_type_in = 'N')) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module,'Updating transaction status:');
      END IF;
      UPDATE iby_trxn_summaries_all
      SET
          status = DECODE(ack_type_in,
                          'P',C_STATUS_BEP_FAIL,
                          'N',C_STATUS_SUCCESS,
                          C_STATUS_OPEN_BATCHED),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          object_version_number = object_version_number + 1
      WHERE (payeeid = payeeid_in)
        AND (mbatchid = batchid_in)
        AND (status = iby_transactioncc_pkg.C_STATUS_BATCH_PENDING);
    END IF;
    END IF;

    COMMIT;
    print_debuginfo(l_module,'Exit');
  END Update_Batch;


/*
** Procedure: getMBatchId
** Purpose: retrieve mBatchid from iby_Batch table based on Batchid
*/


Procedure getMBatchId(i_Batchid in iby_Batches_all.Batchid%type,
			i_Payeeid in iby_Batches_all.Payeeid%type,
			o_mBatchid out nocopy iby_Batches_all.mBatchid%type)
is
  cursor  c_get_mBatchid(ci_Batchid iby_Batches_All.Batchid%type,
			ci_PayeeId iby_batches_all.PayeeID%type)
  is
    SELECT mBatchid from iby_Batches_All
    WHERE Batchid = ci_Batchid
	AND PayeeID = ci_PayeeID;
BEGIN

  IF (c_get_mbatchid%isopen) THEN
	close c_get_mBatchid;
  END IF;

  open c_get_mBatchid(i_Batchid, i_payeeid);

  fetch c_get_mBatchid into o_mBatchid;
    if ( c_get_mBatchid%notfound ) then
       	raise_application_error(-20000, 'IBY_20211#', FALSE);
	--raise_application_error(-20211, 'Batchid not found', FALSE);
    end if;

  close c_get_mBatchid;
END;


/*
	for QueryTrxn where there will be no orgid inserted
	try to see if there is already some valid org id stored,
	if so, use the non-null one first
*/
Function getOrgId(i_tid in iby_trxn_summaries_all.transactionid%type)
return number
IS
   l_org_id NUMBER := NULL;
   l_count NUMBER;

   cursor c_getNonNullOrgId(ci_tid
			iby_trxn_summaries_all.transactionid%type)

   is
	SELECT DISTINCT org_id
	FROM iby_trxn_summaries_all
	WHERE transactionid = i_tid
	AND status <> -99 AND status <> 14  -- ignore cancelled trxns
	AND org_id IS NOT NULL;

BEGIN

	IF (c_getNonNullOrgId%isopen) THEN
		close c_getNonNullOrgId;
	END IF;

	open c_getNonNullOrgId(i_tid);
	Fetch c_getNonNullOrgId INTO l_org_id;
	-- if not found, l_org_id will remain null
	close c_getNonNullOrgId;

	return l_org_id;
END;


/*    Count number of previous PENDING transactions, ignoring the
	cancelled ones
*/

Function getNumPendingTrxns(i_payeeid in iby_payee.payeeid%type,
			i_tangibleid in iby_tangible.tangibleid%type,
			i_reqtype in iby_trxn_summaries_all.reqtype%type)
return number

IS

l_num_trxns number;

BEGIN

     SELECT count(*)
       INTO l_num_trxns
       FROM iby_trxn_summaries_all
      WHERE TangibleID = i_tangibleid
	AND UPPER(ReqType) = UPPER(i_reqtype)
	AND PayeeID = i_payeeid
	AND (status IN (11,9));

    IF (l_num_trxns > 1) THEN
      -- should never run into this block
       	raise_application_error(-20000, 'IBY_20422#', FALSE);
    END IF;

   return l_num_trxns;
END;


/* get TID based on orderid */
Function getTID(i_payeeid in iby_payee.payeeid%type,
		i_tangibleid in iby_tangible.tangibleid%type)
return number

IS

l_tid number;
cursor c_tid(ci_payeeid in iby_payee.payeeid%type,
		ci_tangibleid in iby_tangible.tangibleid%type)
  is
	SELECT distinct transactionid
	FROM iby_trxn_summaries_all
	WHERE tangibleid = ci_tangibleid
	AND payeeid = ci_payeeid;

BEGIN
	if (c_tid%isopen) then
	   close c_tid;
	end if;

	open c_tid(i_payeeid, i_tangibleid);
	fetch c_tid into l_tid;
	if (c_tid%notfound) then
	  SELECT iby_trxnsumm_trxnid_s.NEXTVAL
	  INTO l_tid
	  FROM dual;
	end if;

	close c_tid;

	return l_tid;

END getTID;


/* get TID based on orderid, payeeid (if unique) */
Function getTIDUniqueCheck(i_payeeid in iby_payee.payeeid%type,
		i_tangibleid in iby_tangible.tangibleid%type)
return number

IS

l_tid number;
cursor c_tid(ci_payeeid in iby_payee.payeeid%type,
		ci_tangibleid in iby_tangible.tangibleid%type)
  is
	SELECT distinct transactionid
	FROM iby_trxn_summaries_all
	WHERE tangibleid = ci_tangibleid
	AND payeeid = ci_payeeid;

BEGIN
	if (c_tid%isopen) then
	   close c_tid;
	end if;

	open c_tid(i_payeeid, i_tangibleid);
	fetch c_tid into l_tid;

        -- If no exception was thrown it means
        -- that we found a record in the cursor
        -- that matches the given criteria (which
        -- further means that there already exists
        -- a transaction id for this (orderid, payeeid)
        -- combination). So return -1 to indicate that
        -- this transaction is non-unique.
        l_tid := -1;

	if (c_tid%notfound) then
	  SELECT iby_trxnsumm_trxnid_s.NEXTVAL
	  INTO l_tid
	  FROM dual;
	end if;

	close c_tid;

	return l_tid;

END getTIDUniqueCheck;

  FUNCTION unencrypt_instr_num
  (p_instrnum    IN iby_trxn_summaries_all.instrnumber%TYPE,
   p_payee_key   IN iby_security_pkg.des3_key_type,
   p_payee_subkey_cipher IN iby_payee_subkeys.subkey_cipher_text%TYPE,
   p_sys_key     IN RAW,
   p_sys_subkey_cipher IN iby_sys_security_subkeys.subkey_cipher_text%TYPE,
   p_segment_id  IN iby_security_segments.sec_segment_id%TYPE,
   p_segment_cipher IN iby_security_segments.segment_cipher_text%TYPE,
   p_card_prefix IN iby_cc_issuer_ranges.card_number_prefix%TYPE,
   p_card_len    IN iby_cc_issuer_ranges.card_number_length%TYPE,
   p_digit_check IN iby_creditcard_issuers_b.digit_check_flag%TYPE
  )
  RETURN iby_trxn_summaries_all.instrnumber%TYPE
  IS
    l_subkey_cleartxt  iby_security_pkg.des3_key_type;
    l_subkey_raw       RAW(24);
    l_number           iby_trxn_summaries_all.instrnumber%TYPE;
    l_number_len       NUMBER;
  BEGIN

    -- handle 2 cases: not encrypted, PCI-encrypted

    --
    -- PCI-encrypted data from 11i
    --
    IF (NOT p_segment_id IS NULL) THEN
      l_subkey_raw :=
        dbms_obfuscation_toolkit.des3decrypt
        ( input => p_sys_subkey_cipher , key => p_sys_key,
          which => dbms_obfuscation_toolkit.ThreeKeyMode
        );
      l_number :=
        dbms_obfuscation_toolkit.des3decrypt
        ( input => p_segment_cipher , key => l_subkey_raw,
          which => dbms_obfuscation_toolkit.ThreeKeyMode
        );

      l_number_len := p_card_len - NVL(LENGTH(p_card_prefix),0);
      IF (p_digit_check = 'Y') THEN
        l_number_len := l_number_len - 1;
      END IF;
      -- if the rest of the number is in the unmasked digit, don't bother
      -- decompressing
      IF ( l_number_len > 0 ) THEN
        l_number :=
          IBY_SECURITY_PKG.Decode_Number(l_number,l_number_len,TRUE);
      ELSE
        l_number := '';
      END IF;

      RETURN
        IBY_CREDITCARD_PKG.Uncompress_CC_Number
        (l_number,l_number_len,p_card_prefix,p_digit_check,
         iby_security_pkg.G_MASK_ALL,0,'');
    ELSE
      RETURN iby_utility_pvt.decode64(p_instrnum);
    END IF;
  END unencrypt_instr_num;

  PROCEDURE unencrypt_instr_num
  (trxnmid_in    IN iby_trxn_summaries_all.trxnmid%TYPE,
   master_key_in IN iby_security_pkg.DES3_KEY_TYPE,
   instr_num_out OUT NOCOPY iby_trxn_summaries_all.instrnumber%TYPE
  )
  IS
    l_subkey_cipher   iby_payee_subkeys.subkey_cipher_text%TYPE;
    l_cipher_instrnum iby_trxn_summaries_all.instrnumber%TYPE;
    l_segment_id       iby_trxn_summaries_all.instrnum_sec_segment_id%TYPE;
    l_segment_cipher   iby_security_segments.segment_cipher_text%TYPE;
    l_sys_subkey_cipher iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    l_card_prefix      iby_cc_issuer_ranges.card_number_prefix%TYPE;
    l_card_length      iby_cc_issuer_ranges.card_number_length%TYPE;
    l_digit_check      iby_creditcard_issuers_b.digit_check_flag%TYPE;

    CURSOR c_instr_num(ci_trxnmid iby_trxn_summaries_all.trxnmid%TYPE)
    IS
      SELECT NULL, tx.instrnumber,
        tx.instrnum_sec_segment_id, k.subkey_cipher_text,
        seg.segment_cipher_text, r.card_number_prefix,
        NVL(r.card_number_length,tx.instrnum_length), i.digit_check_flag
      FROM iby_trxn_summaries_all tx,
        iby_security_segments seg, iby_sys_security_subkeys k,
        iby_cc_issuer_ranges r, iby_creditcard_issuers_b i
      WHERE (tx.trxnmid = ci_trxnmid)
        AND (tx.instrnum_sec_segment_id = seg.sec_segment_id(+))
        AND (seg.sec_subkey_id = k.sec_subkey_id(+))
        AND (tx.cc_issuer_range_id = r.cc_issuer_range_id(+))
        AND (tx.instrsubtype = i.card_issuer_code(+));
  BEGIN

    IF (c_instr_num%ISOPEN) THEN close c_instr_num; END IF;

    OPEN c_instr_num(trxnmid_in);
    FETCH c_instr_num
    INTO l_subkey_cipher, l_cipher_instrnum, l_segment_id, l_sys_subkey_cipher,
      l_segment_cipher, l_card_prefix, l_card_length, l_digit_check;

    IF (c_instr_num%NOTFOUND) THEN
      CLOSE c_instr_num;
      raise_application_error(-20000, 'IBY_204463#', FALSE);
    ELSE
      CLOSE c_instr_num;
    END IF;
    instr_num_out :=
      unencrypt_instr_num
      (l_cipher_instrnum, NULL, l_subkey_cipher, master_key_in,
       l_sys_subkey_cipher, l_segment_id, l_segment_cipher, l_card_prefix,
       l_card_length, l_digit_check);
  END unencrypt_instr_num;


  FUNCTION unencrypt_instr_num
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
        master_key_in   IN      iby_security_pkg.DES3_KEY_TYPE
	)
  RETURN iby_trxn_summaries_all.instrnumber%TYPE
  IS
	l_instrnum iby_trxn_summaries_all.instrnumber%TYPE;
  BEGIN
	unencrypt_instr_num(trxnmid_in,master_key_in,l_instrnum);
	RETURN l_instrnum;
  END unencrypt_instr_num;

  FUNCTION unencrypt_instr_num_ui_wrp
	(
	trxnmid_in	IN	iby_trxn_summaries_all.trxnmid%TYPE,
        master_key_in   IN      iby_security_pkg.DES3_KEY_TYPE
	)
  RETURN iby_trxn_summaries_all.instrnumber%TYPE
  IS
	l_instrnum iby_trxn_summaries_all.instrnumber%TYPE;
  BEGIN
	l_instrnum := unencrypt_instr_num(trxnmid_in,master_key_in);
	RETURN l_instrnum;

  EXCEPTION
    WHEN OTHERS THEN
      return null;

  END unencrypt_instr_num_ui_wrp;

  PROCEDURE Encrypt_CC_Data
  (p_sys_key IN IBY_SECURITY_PKG.DES3_KEY_TYPE, x_err_code OUT NOCOPY VARCHAR2)
  IS
    -- types
    TYPE  Num15Tab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    TYPE  Char60Tab IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;

    -- bulk tables
    l_trxnmid_tbl     Num15Tab;
    l_maskedcc_tbl    Char60Tab;
    l_issuer_tbl      Char60Tab;
    l_cchash_tbl      Char60Tab;
    l_rangeid_tbl     Num15Tab;
    l_instrlen_tbl    Num15Tab;
    l_segmentid_tbl   Num15Tab;

    l_index           NUMBER;

    -- variables for CHNAME and EXPDATE encryption
    l_chname_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_expdate_sec_segment_id iby_security_segments.sec_segment_id%TYPE;
    l_masked_chname     VARCHAR2(100) := NULL;
    l_encrypted         VARCHAR2(1) := 'N';

    CURSOR c_tx_ccnumber
    IS
      SELECT /*+ rowid(tx) */
        tx.trxnmid,
        iby_utility_pvt.decode64(instrnumber) ccnum,
        tx.instrtype
      FROM iby_trxn_summaries_all tx
      WHERE
        (NOT instrnumber IS NULL)
        AND (DECODE(instrtype, 'PINLESSDEBITCARD','CREDITCARD',
                               'PURCHASECARD','CREDITCARD',
        -- instrument type will be NULL for credit card credit trxns
                               NULL,DECODE(reqtype,
                                           'ORAPMTCREDIT','CREDITCARD',
                                           NULL),
                               instrtype) = 'CREDITCARD')
        AND (instrnum_sec_segment_id IS NULL);


   -- The below cursor will fetch all un-encrypted rows from
   -- IBY_TRXN_CORE table. Though we could probably have merged this
   -- cursor with the earlier one, we maintain a separate one since
   -- there could be records in this table that are un-encrypted but the
   -- corresponding records in iby_trxn_summaries_all are encrypted.
   CURSOR c_trxn_core
    IS
      SELECT
        tx.trxnmid tmid,
        core.instr_expirydate expdate,
        core.instr_owner_name chname
      FROM iby_trxn_summaries_all tx,
           iby_trxn_core core
      WHERE
         (DECODE(tx.instrtype, 'PINLESSDEBITCARD','CREDITCARD',
                               'PURCHASECARD','CREDITCARD',
        -- instrument type will be NULL for credit card credit trxns
                               NULL,DECODE(tx.reqtype,
                                           'ORAPMTCREDIT','CREDITCARD',
                                           NULL),
                               tx.instrtype) = 'CREDITCARD')
    	AND tx.trxnmid = core.trxnmid
	AND NVL(core.encrypted, 'N') = 'N';


  BEGIN

    IF (iby_creditcard_pkg.Get_CC_Encrypt_Mode() =
        iby_security_pkg.G_ENCRYPT_MODE_NONE)
    THEN
      RETURN;
    END IF;
    iby_security_pkg.validate_sys_key(p_sys_key,x_err_code);
    IF (NOT x_err_code IS NULL) THEN
      RETURN;
    END IF;

    l_index := 1;

    FOR txn_rec IN c_tx_ccnumber LOOP
      IBY_TRANSACTIONCC_PKG.prepare_instr_data
      (FND_API.G_FALSE,
       p_sys_key,
       txn_rec.ccnum,
       txn_rec.instrtype,
       l_maskedcc_tbl(l_index),
       l_issuer_tbl(l_index),
       l_cchash_tbl(l_index),
       l_rangeid_tbl(l_index),
       l_instrlen_tbl(l_index),
       l_segmentid_tbl(l_index)
      );
     l_trxnmid_tbl(l_index) := txn_rec.trxnmid;

     IF (l_index=1000) THEN
       FORALL i IN l_trxnmid_tbl.first..l_trxnmid_tbl.last
         UPDATE iby_trxn_summaries_all
         SET
           instrnumber = l_maskedcc_tbl(i),
           instrnum_hash = l_cchash_tbl(i),
           cc_issuer_range_id = l_rangeid_tbl(i),
           instrnum_length = l_instrlen_tbl(i),
           instrnum_sec_segment_id = l_segmentid_tbl(i)
         WHERE trxnmid=l_trxnmid_tbl(i);

       COMMIT;

       l_index := 1;
       l_maskedcc_tbl.delete;
       l_issuer_tbl.delete;
       l_cchash_tbl.delete;
       l_rangeid_tbl.delete;
       l_instrlen_tbl.delete;
       l_segmentid_tbl.delete;
       l_trxnmid_tbl.delete;
     ELSE
       l_index := l_index + 1;
     END IF;
    END LOOP;

    IF (l_trxnmid_tbl.COUNT>0) THEN
      FORALL i IN l_trxnmid_tbl.first..l_trxnmid_tbl.last
        UPDATE iby_trxn_summaries_all
        SET
           instrnumber = l_maskedcc_tbl(i),
           instrnum_hash = l_cchash_tbl(i),
           cc_issuer_range_id = l_rangeid_tbl(i),
           instrnum_length = l_instrlen_tbl(i),
           instrnum_sec_segment_id = l_segmentid_tbl(i)
         WHERE trxnmid=l_trxnmid_tbl(i);

       COMMIT;
    END IF;

  -- Loop thru the iby_trxn_core table only if the other card attributes
  -- present here need to be secured

  --IF( IBY_CREDITCARD_PKG.Other_CC_Attribs_Encrypted = 'Y') THEN
     FOR core_rec IN c_trxn_core LOOP
        l_chname_sec_segment_id :=
                 IBY_SECURITY_PKG.encrypt_field_vals(core_rec.chname,
		                                     p_sys_key,
						     null,
						     'N'
						     );
        l_expdate_sec_segment_id :=
                 IBY_SECURITY_PKG.encrypt_date_field(core_rec.expdate,
		                                     p_sys_key,
						     null,
						     'N'
						     );
        l_masked_chname :=
                IBY_SECURITY_PKG.Mask_Data(core_rec.chname,
		                           IBY_SECURITY_PKG.G_MASK_ALL,
				           0,
					   'X'
					   );
        l_encrypted := 'Y';

        UPDATE iby_trxn_core SET
        encrypted = 'Y',
        instr_owner_name = l_masked_chname,
        chname_sec_segment_id = l_chname_sec_segment_id,
        instr_expirydate = NULL,
        expiry_sec_segment_id = l_expdate_sec_segment_id,
        object_version_number = object_version_number + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
        WHERE (trxnmid = core_rec.tmid);

     END LOOP;
  --END IF;

  COMMIT;

  END Encrypt_CC_Data;

  PROCEDURE Decrypt_CC_Data
  (p_sys_key IN IBY_SECURITY_PKG.DES3_KEY_TYPE, x_err_code OUT NOCOPY VARCHAR2)
  IS
    -- types
    TYPE  Num15Tab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    TYPE  Char60Tab IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;

    -- bulk tables
    l_trxnmid_tbl     Num15Tab;
    l_instrnum_tbl    Char60Tab;
    l_segmentid_tbl   Num15Tab;

    l_index           NUMBER;

    -- variabled for CHNAME and EXPDATE decryption
    l_chname            VARCHAR2(80);
    l_str_exp_date      VARCHAR2(20);
    l_exp_date          DATE;

    CURSOR c_tx_ccnumber(ci_sys_key IN IBY_SECURITY_PKG.DES3_KEY_TYPE)
    IS
      SELECT /*+ rowid(tx) */
        tx.trxnmid,
        iby_transactioncc_pkg.unencrypt_instr_num
        (tx.instrnumber, NULL, NULL, ci_sys_key,
         k.subkey_cipher_text, tx.instrnum_sec_segment_id,
         seg.segment_cipher_text, r.card_number_prefix,
         NVL(r.card_number_length,tx.instrnum_length),
         i.digit_check_flag) ccnum,
         instrnum_sec_segment_id
      FROM iby_trxn_summaries_all tx,
        iby_security_segments seg, iby_sys_security_subkeys k,
        iby_cc_issuer_ranges r, iby_creditcard_issuers_b i
      WHERE
/*
        (NOT instrnumber IS NULL)
        AND (DECODE(instrtype, 'PINLESSDEBITCARD','CREDITCARD',
                               'PURCHASECARD','CREDITCARD',
        -- instrument type will be NULL for credit card credit trxns
                               NULL,DECODE(reqtype,
                                           'ORAPMTCREDIT','CREDITCARD',
                                           NULL),
                               instrtype) = 'CREDITCARD')
*/
        (NOT instrnum_sec_segment_id IS NULL)
        AND (tx.instrnum_sec_segment_id = seg.sec_segment_id(+))
        AND (seg.sec_subkey_id = k.sec_subkey_id(+))
        AND (tx.cc_issuer_range_id = r.cc_issuer_range_id(+))
        AND (tx.instrsubtype = i.card_issuer_code(+));

    CURSOR c_trxn_core
    IS
      SELECT
        trxnmid,
	instr_expirydate,
        expiry_sec_segment_id,
	instr_owner_name,
        chname_sec_segment_id
      FROM iby_trxn_core
      WHERE NVL(encrypted, 'N') = 'Y';

  BEGIN
    IF (iby_creditcard_pkg.Get_CC_Encrypt_Mode() =
        iby_security_pkg.G_ENCRYPT_MODE_NONE)
    THEN
      RETURN;
    END IF;
    iby_security_pkg.validate_sys_key(p_sys_key,x_err_code);
    IF (NOT x_err_code IS NULL) THEN
      RETURN;
    END IF;

    l_index := 1;

    FOR txn_rec IN c_tx_ccnumber(p_sys_key) LOOP

      l_trxnmid_tbl(l_index) := txn_rec.trxnmid;
      l_instrnum_tbl(l_index) := iby_utility_pvt.encode64(txn_rec.ccnum);
      l_segmentid_tbl(l_index) := txn_rec.instrnum_sec_segment_id;

      IF (l_index=1000) THEN
        FORALL i IN l_trxnmid_tbl.first..l_trxnmid_tbl.last
          UPDATE iby_trxn_summaries_all
          SET
            instrnumber = l_instrnum_tbl(i),
            instrnum_sec_segment_id = NULL
          WHERE trxnmid=l_trxnmid_tbl(i);

        FORALL i IN l_segmentid_tbl.first..l_segmentid_tbl.last
          DELETE iby_security_segments
          WHERE sec_segment_id = l_segmentid_tbl(i);

        COMMIT;

        l_index := 1;
        l_segmentid_tbl.delete;
        l_instrnum_tbl.delete;
        l_trxnmid_tbl.delete;
      ELSE
        l_index := l_index + 1;
      END IF;
    END LOOP;

    IF (l_trxnmid_tbl.COUNT>0) THEN
      FORALL i IN l_trxnmid_tbl.first..l_trxnmid_tbl.last
      UPDATE iby_trxn_summaries_all
         SET
           instrnumber = l_instrnum_tbl(i),
           instrnum_sec_segment_id = NULL
         WHERE trxnmid=l_trxnmid_tbl(i);

      FORALL i IN l_segmentid_tbl.first..l_segmentid_tbl.last
        DELETE iby_security_segments
        WHERE sec_segment_id = l_segmentid_tbl(i);

      COMMIT;
    END IF;

    --IF( IBY_CREDITCARD_PKG.Other_CC_Attribs_Encrypted = 'Y') THEN
       FOR core_rec IN c_trxn_core LOOP
         IF (core_rec.expiry_sec_segment_id IS NOT NULL) THEN
           l_exp_date := IBY_SECURITY_PKG.decrypt_date_field
	                            (core_rec.expiry_sec_segment_id,
				     p_sys_key
				     );

         ELSE
           -- The exp date wasn't encrypted
           l_exp_date := core_rec.instr_expirydate;
         END IF;

         IF(core_rec.chname_sec_segment_id IS NOT NULL) THEN
           l_chname := IBY_SECURITY_PKG.decrypt_field_vals
	                            (core_rec.chname_sec_segment_id,
				     p_sys_key
				     );
         ELSE
           -- CHNAME wasn't encrypted
           l_chname := core_rec.instr_owner_name;
         END IF;

        UPDATE iby_trxn_core SET
        encrypted = 'N',
        instr_owner_name = l_chname,
        chname_sec_segment_id = NULL,
        instr_expirydate = l_exp_date,
        expiry_sec_segment_id = NULL,
        object_version_number = object_version_number + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
        WHERE (trxnmid = core_rec.trxnmid);

     END LOOP;
  --END IF;

  COMMIT;

  END Decrypt_CC_Data;

  PROCEDURE check_batch_size
        (
	ecappid_in      IN      iby_trxn_summaries_all.ecappid%TYPE,
	payeeid_in      IN      iby_trxn_summaries_all.payeeid%TYPE,
	bepid_in        IN      iby_trxn_summaries_all.bepid%TYPE,
	bepkey_in       IN      iby_trxn_summaries_all.bepkey%TYPE,
        orgid_in        IN      iby_batches_all.org_id%TYPE,
        seckey_present_in IN    VARCHAR2,
        trxncount_out   OUT NOCOPY NUMBER,
        batchid_out     OUT NOCOPY iby_batches_all.batchid%TYPE
        )
  IS

        l_max_batch_size iby_bepinfo.max_batch_size%TYPE;
        l_mbatch_id iby_batches_all.mbatchid%TYPE;

        CURSOR c_trxn_count
            (
            ci_ecappid iby_trxn_summaries_all.ecappid%TYPE,
            ci_payeeid iby_trxn_summaries_all.payeeid%TYPE,
            ci_bepid   iby_trxn_summaries_all.bepid%TYPE,
            ci_bepkey  iby_trxn_summaries_all.bepkey%TYPE
            ) IS
          SELECT count(transactionid)
          FROM iby_trxn_summaries_all
          WHERE (ci_bepid=bepid)
            AND (ci_payeeid=payeeid)
            AND (ci_bepkey=bepkey)
            --
            -- can have multiple trxns from a
            -- different ecapp's for a single payee account;
            -- don't bother until ecapp scoping is seriously
            -- supported by IBY
            --
            --AND (ci_ecappid=ecappid)
            AND (status=iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED)
            AND (batchid IS NULL)
            AND (instrtype IN (iby_creditcard_pkg.C_INSTRTYPE_CCARD,
                           iby_creditcard_pkg.C_INSTRTYPE_PCARD)
               OR instrtype IS NULL);

        CURSOR c_max_bsize(ci_bepid iby_trxn_summaries_all.bepid%TYPE) IS
          SELECT NVL(max_batch_size,-1)
          FROM iby_bepinfo
          WHERE (ci_bepid=bepid);

  BEGIN
        IF (c_trxn_count%ISOPEN) THEN
          CLOSE c_trxn_count;
        END IF;
        IF (c_max_bsize%ISOPEN) THEN
          CLOSE c_max_bsize;
        END IF;

        OPEN c_max_bsize(bepid_in);
        FETCH c_max_bsize INTO l_max_batch_size;

        --
        -- nothing found; bep id must be bad
        --
        IF (c_max_bsize%NOTFOUND) THEN
           CLOSE c_max_bsize;
           raise_application_error(-20000, 'IBY_40201', FALSE);
        END IF;

        CLOSE c_max_bsize;

        OPEN c_trxn_count(ecappid_in,payeeid_in,bepid_in,bepkey_in);
        FETCH c_trxn_count INTO trxncount_out;

        IF (c_trxn_count%NOTFOUND) THEN
          trxncount_out := 0;
        END IF;

        CLOSE c_trxn_count;

        IF (l_max_batch_size>0) THEN
          IF (l_max_batch_size<=trxncount_out) THEN
            --
            -- lock required to ensure only 1 batch close occurs after
            -- the maximum size is surpassed among all competing concurrent
            -- threads; lock both tables (even though iby_batches_all
            -- is sufficient) so as to ensure no deadlock can happen
            -- later
            --
            --LOCK TABLE iby_batches_all, iby_trxn_summaries_all
              --IN EXCLUSIVE MODE;

            -- check batch size once more to ensure another thread has
            -- not closed it between the last check and possession of
            -- the table lock; necessary to prevent tiny batches of size
            -- 0, 1, etc. from being created
            --
            OPEN c_trxn_count(ecappid_in,payeeid_in,bepid_in,bepkey_in);
            FETCH c_trxn_count INTO trxncount_out;

            IF (c_trxn_count%NOTFOUND) THEN
              trxncount_out := 0;
            END IF;

            IF (l_max_batch_size>trxncount_out) THEN
              -- relinquish table locks
              ROLLBACK;
              RETURN;
            END IF;

            SELECT to_char(IBY_BATCHID_S.nextval)
            INTO batchid_out
            FROM dual;
            --
            -- define the batch; note that this method
            -- commits data, so no need for a commit
            -- statement to follow
            --
            iby_transactioncc_pkg.insert_batch_status
            (
            batchid_out,
            payeeid_in,
            bepid_in,
            bepkey_in,
            iby_creditcard_pkg.C_INSTRTYPE_CCARD,
            iby_transactioncc_pkg.C_STATUS_COMMUNICATION_ERROR,
            SYSDATE,
            '',
            '',
            trxncount_out,
            iby_transactioncc_pkg.C_STATUS_COMMUNICATION_ERROR,
            0,
            0,
            0,
            '',
            '',
            '',
            '',
            '',
            '',
            orgid_in,
            'ORAPMTCLOSEBATCH',
            seckey_present_in,
            l_mbatch_id
            );

          END IF;
        END IF;

        COMMIT;

  EXCEPTION
    --
    -- make sure to release the table lock
    --
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(SQLCODE, SQLERRM, FALSE);
  END check_batch_size;

/*--------------------------------------------------------------------
 | NAME:
 |   Update_Payer_Notif_Batch
 |
 | PURPOSE:
 |     This procedure updates the payer_notification_required flag for
 |     all the transactions in a batch.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE Update_Payer_Notif_Batch(
     mbatchid_in  IN iby_batches_all.mbatchid%TYPE
 ) IS

    l_process_profile   iby_batches_all.process_profile_code%TYPE;
    l_payer_notif_flag  VARCHAR2(1);
    l_instrument_type   iby_batches_all.instrument_type%TYPE;


  CURSOR c_payer_notif_cc (c_user_profile iby_fndcpt_user_cc_pf_b.user_cc_profile_code%TYPE) IS
  SELECT DECODE(payer_notification_format, null, 'N', 'Y')
    FROM iby_fndcpt_user_cc_pf_b up, iby_fndcpt_sys_cc_pf_b sp
   WHERE up.sys_cc_profile_code = sp.sys_cc_profile_code
     AND up.user_cc_profile_code = c_user_profile;

  CURSOR c_payer_notif_dc (c_user_profile iby_fndcpt_user_dc_pf_b.user_dc_profile_code%TYPE) IS
  SELECT DECODE(payer_notification_format, null, 'N', 'Y')
    FROM iby_fndcpt_user_dc_pf_b up, iby_fndcpt_sys_dc_pf_b sp,
         iby_batches_all b
   WHERE up.sys_dc_profile_code = sp.sys_dc_profile_code
     AND up.user_dc_profile_code =c_user_profile;

  CURSOR c_payer_notif_eft (c_user_profile iby_fndcpt_user_eft_pf_b.user_eft_profile_code%TYPE) IS
  SELECT DECODE(payer_notification_format, null, 'N', 'Y')
    FROM iby_fndcpt_user_eft_pf_b up, iby_fndcpt_sys_eft_pf_b sp,
         iby_batches_all b
   WHERE up.sys_eft_profile_code = sp.sys_eft_profile_code
     AND up.user_eft_profile_code = c_user_profile;

  CURSOR c_instr_type(i_mbatchid iby_batches_all.mbatchid%TYPE) IS
  SELECT instrument_type, process_profile_code
    FROM iby_batches_all
   WHERE mbatchid = i_mbatchid;

 BEGIN

    IF (c_instr_type%ISOPEN) THEN CLOSE c_instr_type; END IF;
    IF (c_payer_notif_cc%ISOPEN) THEN CLOSE c_payer_notif_cc; END IF;
    IF (c_payer_notif_dc%ISOPEN) THEN CLOSE c_payer_notif_dc; END IF;
    IF (c_payer_notif_eft%ISOPEN) THEN CLOSE c_payer_notif_eft; END IF;

    OPEN c_instr_type(mbatchid_in);
    FETCH c_instr_type INTO l_instrument_type, l_process_profile;
    CLOSE c_instr_type;

    -- get the payer_notification depending on the instrument_type
    -- from the different FCPP
    IF l_instrument_type = 'DEBITCARD' THEN
      OPEN c_payer_notif_dc(l_process_profile);
      FETCH c_payer_notif_dc INTO l_payer_notif_flag;
      CLOSE c_payer_notif_dc;

    ELSIF l_instrument_type = 'BANKACCOUNT' THEN
      OPEN c_payer_notif_eft(l_process_profile);
      FETCH c_payer_notif_eft INTO l_payer_notif_flag;
      CLOSE c_payer_notif_eft;

    ELSE
      OPEN c_payer_notif_cc(l_process_profile);
      FETCH c_payer_notif_cc INTO l_payer_notif_flag;
      CLOSE c_payer_notif_cc;

    END IF;

    -- set the payer_notification_required flag to yes
    -- if the payer_notification_format is defined for the FCPP
    -- at batch and trxn level and if the batch is successfull.
    -- Only for settlement trxn
    UPDATE iby_batches_all
    SET
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      object_version_number = object_version_number + 1,
      payer_notification_required = l_payer_notif_flag
    WHERE (mbatchid = mbatchid_in);

    -- the update will update only settlement trxn.
    -- authcapture, capture and markcapture
    UPDATE iby_trxn_summaries_all
       SET payer_notification_required = l_payer_notif_flag,
           last_update_date=sysdate,
           last_updated_by = fnd_global.user_id,
           object_version_number = object_version_number + 1
     WHERE mbatchid = mbatchid_in
       AND TrxntypeID IN (3,8,9,100);

 END Update_Payer_Notif_Batch;

 /*--------------------------------------------------------------------
 | NAME:
 |
 | PURPOSE:
 |     This procedure is used to free up the memory used by
 |     global memory structure
 |
 | PARAMETERS:
 |
 |     NONE
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE delete_trxnTable IS
 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                       '.delete_trxnTable';
 BEGIN

 print_debuginfo(l_module_name, 'ENTER');
 trxnTab.transactionid.delete;
 trxnTab.mbatchid.delete;
 trxnTab.batchid.delete;
 print_debuginfo(l_module_name, 'EXIT');
 END;

END iby_transactioncc_pkg;

/
