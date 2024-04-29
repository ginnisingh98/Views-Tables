--------------------------------------------------------
--  DDL for Package Body IBY_PAYMENTMANAGERDB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYMENTMANAGERDB_PKG" AS
/* $Header: ibypmmgb.pls 120.10.12010000.6 2010/01/21 07:14:22 sgogula ship $ */


  G_DEBUG_MODULE CONSTANT VARCHAR2(100):='iby.plsql.IBY_PAYMENTMANAGERDB_PKG';


  /* APIs to fetch the bep configuration for the given      */


--IN: 1-15
--OUT: 12-28

 PROCEDURE listbep (
         p_amount                IN        iby_trxn_summaries_all.amount%type,
         p_payment_channel_code  IN        iby_trxn_summaries_all.payment_channel_code%type,
         p_currency              IN        iby_trxn_summaries_all.currencynamecode%type,
         p_payee_id              IN        iby_trxn_summaries_all.payeeid%type,
         p_cc_type               IN        VARCHAR2,
         p_cc_num                IN        iby_creditcard.ccnumber%type,
         p_aba_routing_no        IN        iby_bankacct.routingno%type,
         p_org_id                IN        iby_trxn_summaries_all.org_id%type,
         p_fin_app_type          IN        VARCHAR2,
         p_transaction_id_in     IN        iby_trxn_summaries_all.TransactionID%TYPE,
         p_payment_operation_in  IN        VARCHAR2,
         p_ecappid_in            IN        iby_ecapp.ecappid%type,
         p_instr_subtype         IN        iby_trxn_summaries_all.instrsubtype%type,
         p_bnf_routing_no        IN        iby_bankacct.routingno%type,
         p_factored_flag         IN        iby_trxn_summaries_all.factored_flag%type,
         p_int_bank_acct_id      IN        NUMBER,
         p_br_signed_flag        IN        iby_trxn_summaries_all.br_signed_flag%TYPE,
         p_br_drawee_issued_flag IN        iby_trxn_summaries_all.br_drawee_issued_flag%TYPE,
         p_ar_receipt_mth_id     IN        iby_trxn_summaries_all.ar_receipt_method_id%TYPE,
         px_payee_id_in_out      IN  OUT NOCOPY iby_payee.PayeeID%TYPE,
         px_order_id_in_out      IN  OUT NOCOPY VARCHAR2,
         px_payment_name_in_out  IN  OUT NOCOPY VARCHAR2,
         px_bep_lang_in_out      IN  OUT NOCOPY VARCHAR2,
         x_payee_username_out        OUT NOCOPY iby_payee.Username%TYPE,
         x_payee_passwd_out          OUT NOCOPY iby_payee.Password%TYPE,
         x_payee_operation_out       OUT NOCOPY NUMBER,
         x_bepid_out                 OUT NOCOPY iby_BEPInfo.BEPID%TYPE,
         x_bep_suffix_out            OUT NOCOPY IBY_BEPInfo.Suffix%TYPE,
         x_bep_url_out               OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         x_bep_key_out               OUT NOCOPY IBY_BEPKeys.Key%TYPE,
         x_bep_pmtscheme_out         OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         x_bep_username_out          OUT NOCOPY IBY_BEPInfo.BEPUsername%TYPE,
         x_bep_passwd_out            OUT NOCOPY IBY_BEPInfo.BEPPassword%TYPE,
         x_security_out              OUT NOCOPY NUMBER,
         x_setnoinit_flag_out        OUT NOCOPY NUMBER,
         x_lead_time_out             OUT NOCOPY iby_bepinfo.leadtime%TYPE,
         x_bep_type_out              OUT NOCOPY IBY_BEPInfo.Bep_Type%TYPE,
         x_fndcpt_user_profile_code_out OUT NOCOPY
                                     IBY_FNDCPT_USER_CC_PF_VL.USER_CC_PROFILE_CODE%TYPE
         )
    	 IS
         BEGIN
	 listbep (
         p_amount,
         p_payment_channel_code,
         p_currency,
         p_payee_id,
         p_cc_type,
         p_cc_num,
         p_aba_routing_no,
         p_org_id,
         p_fin_app_type,
         p_transaction_id_in,
         p_payment_operation_in,
         p_ecappid_in,
         p_instr_subtype,
         p_bnf_routing_no,
         null,
         p_factored_flag,
         p_int_bank_acct_id,
         p_br_signed_flag,
         p_br_drawee_issued_flag,
         p_ar_receipt_mth_id,
         px_payee_id_in_out,
         px_order_id_in_out,
         px_payment_name_in_out,
         px_bep_lang_in_out,
         x_payee_username_out,
         x_payee_passwd_out,
         x_payee_operation_out,
         x_bepid_out,
         x_bep_suffix_out,
         x_bep_url_out,
         x_bep_key_out,
         x_bep_pmtscheme_out,
         x_bep_username_out,
         x_bep_passwd_out,
         x_security_out,
         x_setnoinit_flag_out,
         x_lead_time_out,
         x_bep_type_out,
         x_fndcpt_user_profile_code_out,
	 null);

	 END listbep;

 PROCEDURE listbep (
         p_amount                IN        iby_trxn_summaries_all.amount%type,
         p_payment_channel_code  IN        iby_trxn_summaries_all.payment_channel_code%type,
         p_currency              IN        iby_trxn_summaries_all.currencynamecode%type,
         p_payee_id              IN        iby_trxn_summaries_all.payeeid%type,
         p_cc_type               IN        VARCHAR2,
         p_cc_num                IN        iby_creditcard.ccnumber%type,
         p_aba_routing_no        IN        iby_bankacct.routingno%type,
         p_org_id                IN        iby_trxn_summaries_all.org_id%type,
         p_fin_app_type          IN        VARCHAR2,
         p_transaction_id_in     IN        iby_trxn_summaries_all.TransactionID%TYPE,
         p_payment_operation_in  IN        VARCHAR2,
         p_ecappid_in            IN        iby_ecapp.ecappid%type,
         p_instr_subtype         IN        iby_trxn_summaries_all.instrsubtype%type,
         p_bnf_routing_no        IN        iby_bankacct.routingno%type,
         p_merchant_bank_country IN        VARCHAR2,
         p_factored_flag         IN        iby_trxn_summaries_all.factored_flag%type,
         p_int_bank_acct_id      IN        NUMBER,
         p_br_signed_flag        IN        iby_trxn_summaries_all.br_signed_flag%TYPE,
         p_br_drawee_issued_flag IN        iby_trxn_summaries_all.br_drawee_issued_flag%TYPE,
         p_ar_receipt_mth_id     IN        iby_trxn_summaries_all.ar_receipt_method_id%TYPE,
         px_payee_id_in_out      IN  OUT NOCOPY iby_payee.PayeeID%TYPE,
         px_order_id_in_out      IN  OUT NOCOPY VARCHAR2,
         px_payment_name_in_out  IN  OUT NOCOPY VARCHAR2,
         px_bep_lang_in_out      IN  OUT NOCOPY VARCHAR2,
         x_payee_username_out        OUT NOCOPY iby_payee.Username%TYPE,
         x_payee_passwd_out          OUT NOCOPY iby_payee.Password%TYPE,
         x_payee_operation_out       OUT NOCOPY NUMBER,
         x_bepid_out                 OUT NOCOPY iby_BEPInfo.BEPID%TYPE,
         x_bep_suffix_out            OUT NOCOPY IBY_BEPInfo.Suffix%TYPE,
         x_bep_url_out               OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         x_bep_key_out               OUT NOCOPY IBY_BEPKeys.Key%TYPE,
         x_bep_pmtscheme_out         OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         x_bep_username_out          OUT NOCOPY IBY_BEPInfo.BEPUsername%TYPE,
         x_bep_passwd_out            OUT NOCOPY IBY_BEPInfo.BEPPassword%TYPE,
         x_security_out              OUT NOCOPY NUMBER,
         x_setnoinit_flag_out        OUT NOCOPY NUMBER,
         x_lead_time_out             OUT NOCOPY iby_bepinfo.leadtime%TYPE,
         x_bep_type_out	             OUT NOCOPY IBY_BEPInfo.Bep_Type%TYPE,
         x_fndcpt_user_profile_code_out OUT NOCOPY
                                     IBY_FNDCPT_USER_CC_PF_VL.USER_CC_PROFILE_CODE%TYPE,
         p_payer_bank_country IN        VARCHAR2
         )
  IS
    l_api_name           CONSTANT VARCHAR2(30)   := 'listbep';
    l_module_name        CONSTANT VARCHAR2(200)  := G_DEBUG_MODULE || '.' ||
                                                    l_api_name;
    l_bepid		 iby_default_bep.bepid%TYPE;
    l_base_url           iby_bepinfo.baseurl%TYPE;
    l_pay_op             VARCHAR2(100);
    l_routing_fields     RoutingAPIFields_rec_type;

    l_currency           VARCHAR2(15);
    l_position		 NUMBER;

    l_payeename		 iby_payee.name%type;
    l_bepname		 iby_bepinfo.name%type;

    -- *** R12 Modification *** ---
    -- Added variables l_instr_type and l_mpayeeid
    l_instr_type         iby_trxn_summaries_all.instrtype%TYPE;
    l_mpayeeid           iby_payee.mpayeeid%TYPE;
    l_bank_id            ce_bank_accounts_v.bank_id%TYPE;

  BEGIN
    iby_debug_pub.add('ENTER',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);

    l_position := -1;
    x_bepid_out := -1;

    -- need perform this operation because inv/pay doesn't come in upper case
    l_pay_op := UPPER(p_payment_operation_in);

    -- basic error checking
    -- Reject any illegal payment operation
    checkPaymentOperation(l_pay_op);

    ---Obtain BEP information by
    --- 1) If a valid routingrule is supplied by user, use it (mostly used
    ---	by BATCH operations, ORAPAY/ORAINV
    --- 2) Applying routing for ORAPMTREQ and ORAPMTCREDIT, or
    --- 3) For Batch/ORAINV/ORAPAY operations,
    ---		fetch based on routing rule name
    ---	   (pxp_ayment_name_in_out), use default bep for CC if not set
    --- 4) For others, retrieve previous stored bepid by trxnid for other
    ---  operations, must have valid input trxnid
    IF ((l_pay_op = 'ORAPMTREQ') OR
        (l_pay_op = 'ORAPMTCREDIT') OR
	    (l_pay_op = 'ORAPMTCLOSEBATCH') OR
	    (l_pay_op = 'ORAPMTQRYBATCHSTATUS') OR
	    (l_pay_op = 'ORAINV') OR
	    (l_pay_op = 'ORAPMTBATCHREQ') OR
	    (l_pay_op = 'ORAPAY')) THEN
      IF (px_payment_name_in_out IS NULL) THEN
	-- we don't have a valid routing rule from user input!
	-- need get bepid
	      --- *** R12 Modification *** ---
    -- Fetch Instrument Type from Payment Channel Code
    SELECT a.INSTRUMENT_TYPE INTO l_instr_type
      FROM IBY_FNDCPT_ALL_PMT_CHANNELS_V a
      WHERE a.PAYMENT_CHANNEL_CODE = p_payment_channel_code;

    iby_debug_pub.add('INSTRUMENT_TYPE = '||l_instr_type,
      iby_debug_pub.G_LEVEL_INFO,l_module_name);

    --- *** R12 Modification *** ---
    -- Fetch MPayeeId from PayeeId
    SELECT a.mpayeeid INTO l_mpayeeid
      FROM IBY_PAYEE a
      WHERE a.payeeid = p_payee_id;
    iby_debug_pub.add('debug pt 6',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);
    IF (NOT p_int_bank_acct_id IS NULL) THEN
      SELECT bank_id INTO l_bank_id
      FROM ce_bank_accounts_v
      WHERE (bank_account_id = p_int_bank_acct_id);
    END IF;
     iby_debug_pub.add('debug pt 1',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);
   --- *** R12 Note *** ---
   -- 1. The Instrument Type obtained above is used to populate the Routing fields and
   -- evaluate the applicable Routing Rules, as in the earlier implementation
   --- *** ---
   --- *** R12 Modification *** ---
   -- Parameter 'p_factored_flag' added
    populateRoutingFields(p_amount, l_instr_type, p_instr_subtype, p_currency, p_payee_id,
                          p_cc_type, p_cc_num, p_aba_routing_no, p_bnf_routing_no, p_org_id,
                          p_fin_app_type,p_merchant_bank_country,p_factored_flag,p_payer_bank_country,l_routing_fields);
    l_routing_fields.int_bank_id := l_bank_id;
    l_routing_fields.int_bank_acct_id := p_int_bank_acct_id;
    l_routing_fields.ar_receipt_method_id := p_ar_receipt_mth_id;
    l_routing_fields.br_drawee_issued_flag := p_br_drawee_issued_flag;
    l_routing_fields.br_signed_flag := p_br_signed_flag;
     -- added for the payment channel code. Bug 9175090
    l_routing_fields.pmt_channel_code := p_payment_channel_code;

 iby_debug_pub.add('debug pt 2',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);
	  IF ((l_pay_op = 'ORAPMTREQ') OR (l_pay_op = 'ORAPMTCREDIT') OR (l_pay_op = 'ORAPMTBATCHREQ')) THEN

                IF (not iby_payee_pkg.payeeExists(p_ecappid_in, p_payee_id)) THEN
                  raise_application_error(-20000, 'IBY_20515#', FALSE);
                END IF; -- If payee does not exist
    iby_debug_pub.add('debug pt 3',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);
        -- Apply routingrules and find the routing rule (pmt
		-- method name) we should be using based on
		-- amount, instrument type, not applicable to batch ops
        -- getPmtName(payment_name_in_out, amount_in, l_instr_type, currency_in);
 	       getPmtName(l_routing_fields,
                      px_payment_name_in_out);
	  END IF;
      --dbms_output.put_line(SubStr('px_payment_name_in_out = '||px_payment_name_in_out,1,255));
      --- *** R12 Modification *** ---
      -- Procedure 'getBepIdByPmtName' gets the FndCptUserProfileCode.
      IF (px_payment_name_in_out IS NOT NULL ) THEN
		-- for ORAPMTREQ and ORAPMTCREDIT only, routing logic
		-- has come up w/ some rule that fits
	  	-- fetch the bepid that specified by the routing rule
		getBepIdByPmtName(px_payment_name_in_out,
                          px_payee_id_in_out,
                          x_bepid_out,
                          x_bep_key_out,
                          x_fndcpt_user_profile_code_out);
		-- now we have bep id from routing
      iby_debug_pub.add('debug pt 4',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);
	  ELSE
		-- for ORAPMTCLOSEBATCH, ORAPMTQRYBATCHSTATUS, where rule
		-- is not specified OR
		-- no rule match case for ORAPMTREQ and ORAPMTCREDIT
		-- still no applicable routing rule, go for default
        -- Find default BEPID
        l_position := 1;
        --- *** R12 Modification *** ---
        -- Given the MPayeeId and Payment Channel Code, getDefaultBepId
        -- returns the BepAccountId and the FndCptUserProfileCode.
		getDefaultBepId(l_mpayeeid,
		                p_payment_channel_code,
                        x_bepid_out,
		                x_bep_key_out,
                        x_fndcpt_user_profile_code_out);

          	IF ( x_bepid_out = -1) THEN
            	    -- Default BEP has not been configured
            	    raise_application_error(-20000, 'IBY_25001#', FALSE);
          	END IF;

          	IF ( x_bep_key_out IS NULL) THEN
            	    -- Default BEP Key has not been configured
                    SELECT p.name INTO l_payeename FROM iby_payee p
                    WHERE px_payee_id_in_out = p.payeeid;
                    SELECT b.name INTO l_bepname FROM iby_bepinfo b
                    WHERE x_bepid_out = b.bepid;
            	    raise_application_error(-20000, 'IBY_25002#PAYEENAME='
                                            || l_payeename || '#BEPNAME='
                                            || l_bepname || '#', FALSE);
          	END IF;
           iby_debug_pub.add('debug pt 5',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);
	   	-- now we have default bep id
        END IF;
      END IF;
      --- *** R12 Note *** ---
      -- The lines below retrieve the Bep Information to populate the output parameters.
      -- Though this is not used anymore, there is no need to change it.
      --- *** --
      -- everything is now can be retrieved based on bepid
	  getBepById(x_bepid_out,
                 x_bep_suffix_out,
                 l_base_url,
			     x_security_out,
                 x_bep_username_out,
                 x_bep_passwd_out,
                 x_bep_type_out,
                 x_lead_time_out);
	  -- getPmtSchemeName(x_bepid_out, l_instr_type, x_bep_pmtscheme_out);
      getPmtSchemeName(x_bepid_out,
                       l_routing_fields.instr_type,
                       x_bep_pmtscheme_out);

    ELSE -- Operation Types
    --dbms_output.put_line(SubStr('From Transaction : '||p_transaction_id_in,1,255));
	-- all other transactions should be non-batch operations,
	-- follow-ups to ORAPMTREQ, ORAPMTCREDIT,
	-- they should have a valid input trxnid, and have been previously
	-- routed! we just need fetch previously routed bep info!
	IF (p_transaction_id_in IS NULL or p_transaction_id_in < 0) THEN
	   raise_application_error(-20000, 'IBY_20528#', FALSE);
	END IF;
    -- routing rule is ignored for follow-up trxns
	px_payment_name_in_out := NULL;

	l_position := 3;-- possible non-existent tid
	-- get related bep, tangible information

      --- *** R12 Modification *** ---
      -- Added fndcpt_user_profile_code to select Statement below
      --- *** --
      SELECT distinct BEPID,a.TangibleID, PayeeID, b.currencynamecode,
	     instrtype, bepkey, PROCESS_PROFILE_CODE
        INTO x_bepid_out,px_order_id_in_out, px_payee_id_in_out, l_currency,
	   --
	   -- unfortunately pmt instr type is not passed for
	   -- follow-on trxns so it must also be fetched from the DB
	   --   [bug # 1925098]
	   --
	     l_routing_fields.instr_type, x_bep_key_out,
	     x_fndcpt_user_profile_code_out
        FROM iby_trxn_summaries_all a, iby_tangible b
       WHERE TransactionID = p_transaction_id_in
		AND a.mtangibleid = b.mtangibleid
        -- previously must have succeeded ones
        -- 100 is for processors, indicating it is in an open batch
        -- Added the conditions for Bankaccount
        AND ( ((NOT instrtype IS NULL) AND status in (0, 11, 100, 9)) OR ((instrtype = 'BANKACCOUNT') AND status <> -99) );


	--AND status <> -99 -- cancelled
	--AND status <> 14; -- cancelled

	-- we won't allow user to change the currency code in follow-on
	-- transactions such as CAPTURE and RETURN
	IF (l_pay_op = 'ORAPMTCAPTURE'
		or l_pay_op = 'ORAPMTRETURN') THEN
		IF (UPPER(l_currency) <> UPPER(l_routing_fields.currency)) THEN
	            raise_application_error(-20000, 'IBY_204462#CURRENT='
				|| l_routing_fields.currency || '#OLD=' ||
				l_currency || '#' , FALSE);
		END IF;
	END IF;
    --- *** R12 Note *** ---
    -- The lines below retrieve the Bep Information to populate the output parameters.
    -- Though this is not used anymore, there is no need to change it.
    --- *** --
	getBepById(x_bepid_out,
               x_bep_suffix_out,
               l_base_url,
			   x_security_out,
               x_bep_username_out,
               x_bep_passwd_out,
               x_bep_type_out,
               x_lead_time_out);
	-- getPmtSchemeName(x_bepid_out, l_instr_type, x_bep_pmtscheme_out);
    getPmtSchemeName(x_bepid_out,
                     l_routing_fields.instr_type,
                     x_bep_pmtscheme_out);
    END IF;

    IF ((l_pay_op = 'ORAPMTREQ') AND
          (x_bep_pmtscheme_out = 'SET')) THEN
       -- It's a special oraset_set not preceded by oraset_init,
       -- so get bep by the payment name just like for
       -- oraset_init, but set the setnoinit_flag to 1
       x_setnoinit_flag_out := 1;
    END IF;

    -- NLS modification : get language information
    getBEPLang(x_bepid_out, px_bep_lang_in_out);

    -- Construct bep URL based on baseurl
    getBepUrl(l_base_url,
              l_pay_op,
              x_bep_pmtscheme_out,
              x_bep_suffix_out,
		      x_bep_url_out);

    -- Get the payee name to set for OapfStoreId unless
    -- it's an orapay for SSL, in which case we don't need it
    IF (px_payee_id_in_out IS NOT NULL)    THEN
      -- Get payee info
      l_position := 6;
-- hard coded the supportedOp as this feature is not supported
-- the value 2147483647 is the maximum integer value as set in the UI
      SELECT Username, Password, '2147483647'
        INTO x_payee_username_out, x_payee_passwd_out,
		x_payee_operation_out
        FROM iby_payee
        WHERE PayeeID = px_payee_id_in_out
          AND upper(Activestatus) = 'Y';

	  -- make sure payee support accepted payment instrument
      checkPayeeByAccpPmtMthd(px_payee_id_in_out,
                              l_routing_fields.instr_type);

    END IF;

    -- we need some non-NULL parameter out
    -- for default bep case or follow-up trxns, otherwise it will
    -- crash in java layer
    -- pl/sql layer (or jdbc) doesn't seem to allow empty string ('')
    -- it becomes 'null' in java layer
    IF (px_payment_name_in_out IS NULL) THEN
	px_payment_name_in_out := ' ';
    END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
   -- another possible error for SELECT ... INTO is:
   -- multiple data found for all the select statement

	IF (l_position = 1) THEN
            --Default BEP has not been configured
            raise_application_error(-20000, 'IBY_25001#', FALSE);
	END IF;

	IF (l_position = 3) THEN
	    -- Invalid transaction id
	   raise_application_error(-20000, 'IBY_20528#', FALSE);
	END IF;

	IF (l_position = 6) THEN
	    -- missing payee info, invalid payeeid
	   raise_application_error(-20000, 'IBY_20305#', FALSE);
	END IF;

        --Unknown no_data_found error
        raise_application_error(-20000, 'IBY_20300#', FALSE);

  END listbep;

  PROCEDURE listbep (
         p_payee_id              IN  iby_bepkeys.OwnerId%TYPE,
         p_bepkey                IN  iby_bepkeys.KEY%TYPE,
         p_instr_type            IN  iby_trxn_summaries_all.InstrType%TYPE,
         px_bep_suffix_in_out    IN  OUT NOCOPY iby_bepinfo.Suffix%TYPE,
         x_bepid_out                 OUT NOCOPY iby_bepinfo.BepId%TYPE,
         x_bep_url_out               OUT NOCOPY iby_bepinfo.BaseUrl%TYPE,
         x_bep_pmtscheme_out         OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         x_bep_username_out          OUT NOCOPY iby_bepinfo.BEPUsername%TYPE,
         x_bep_passwd_out            OUT NOCOPY iby_bepinfo.BEPPassword%TYPE,
         x_security_out              OUT NOCOPY NUMBER,
         x_setnoinit_flag_out        OUT NOCOPY NUMBER,
         x_bep_type_out	             OUT NOCOPY iby_bepinfo.Bep_Type%TYPE,
         x_bep_lang_out      	     OUT NOCOPY VARCHAR2,
         x_lead_time_out             OUT NOCOPY iby_bepinfo.leadtime%TYPE
	)
  IS
        l_op_type               iby_trxn_summaries_all.reqtype%TYPE;
	l_base_url		IBY_BEPInfo.BaseURL%TYPE;
	l_key_count		NUMBER;

  BEGIN
	getBepBySuffix(px_bep_suffix_in_out,x_bepid_out,l_base_url,x_bep_pmtscheme_out,p_instr_type);
	getBepById(x_bepid_out, px_bep_suffix_in_out, l_base_url, x_security_out, x_bep_username_out,
		x_bep_passwd_out, x_bep_type_out, x_lead_time_out);
	--
	-- base empty string for payment operation, since invoice/pay is not supported any
	-- longer
	--
	getBepUrl(l_base_url, '', x_bep_pmtscheme_out, px_bep_suffix_in_out, x_bep_url_out);
	getBEPLang(x_bepid_out, x_bep_lang_out);

	--
	-- do not modify setnoninit_flag as it is used only for the SET protocol

	SELECT count(Key)
	INTO l_key_count
	FROM iby_bepkeys
	WHERE (OwnerId = p_payee_id) AND (BEPId = x_bepid_out) AND (Key = p_bepkey);
	--
	-- safeguard from the user providing a wrong bep key
	--
	IF (l_key_count <> 1) THEN
	   raise_application_error(-20000, 'IBY_20532#PAYEEID='||p_payee_id||'#BEPNAME='||px_bep_suffix_in_out, FALSE);
	END IF;

        IF (p_instr_type = 'BANKACCOUNT') THEN
          l_op_type := 'ORAPMTEFTCLOSEBATCH';
        ELSIF (p_instr_type = 'BANKPAYMENT') THEN
          l_op_type := 'ORAPMTEFTPCLOSEBATCH';
        ELSIF (p_instr_type = 'CREDITCARD') THEN
          l_op_type := 'ORAPMTCLOSEBATCH';
        END IF;

  END listbep;



  /* Internal procedure that finds the pmt method name using routing rules */
  PROCEDURE getPmtName(
     p_routingAPIfields          IN   RoutingAPIFields_rec_type,
     px_pmt_name_in_out          IN   OUT NOCOPY VARCHAR2
     )

  IS
    err_msg   VARCHAR2(100);
    l_flag    NUMBER := 0;
    l_hitCounter        NUMBER;
    l_payeeid VARCHAR2(100);
    l_parameter_code iby_pmtmthd_conditions.parameter_code%TYPE;

  --- *** R12 Note *** ---
  -- Though Payment Channel Code will be the driving parameter in the Procedure
  -- listbep, keeping the the instrument type and instrument subtype as the driving
  -- parameters in the main query below
  --- *** --
  CURSOR c_routingRules (p_payeeid iby_routinginfo.payeeid%TYPE,
                         p_instrtype iby_routinginfo.instr_type%TYPE,
                         p_instr_subtype iby_routinginfo.instr_sub_type%TYPE,
			 p_payment_channel_code iby_routinginfo.payment_channel_code%TYPE) IS
  SELECT a.paymentmethodname, a.paymentmethodid FROM  iby_routinginfo a
    WHERE  a.configured = 1
      -- Once financing supports multiple payees, the payee condition should
      -- be changed from 'like' back to '='
      -- AND  a.payeeid = p_payeeid
      AND  a.payeeid like p_payeeid
      AND  a.instr_type = p_instrtype
      AND ((a.instr_sub_type IS NULL)  OR (a.instr_sub_type = NVL(p_instr_subtype, ' ')))
      AND a.payment_channel_code = p_payment_channel_code
    ORDER BY a.priority;

  CURSOR c_ruleCondt(p_key iby_routinginfo.paymentmethodid%TYPE) IS
  SELECT * FROM iby_pmtmthd_conditions x
    WHERE x.paymentmethodid = p_key order by x.parameter_code,x.entry_sequence ;

  BEGIN
    -- Get bep information for this order for this payee

  -- set payee to '%' if instrument type is financing. This is only until
  -- financing supports multiple payees.
  IF (p_routingAPIfields.instr_type = 'FINANCING') THEN
    l_payeeid := '%';
  ELSE
    l_payeeid := p_routingAPIfields.payee_id;
  END IF;


-- 'AND' logic for different criterion and 'OR' logic for different conditions of the same criterion
  FOR v_routingRules IN c_routingRules(l_payeeid, p_routingAPIfields.instr_type, p_routingAPIfields.instr_subtype, p_routingAPIfields.pmt_channel_code) LOOP
  l_flag := 0;
  l_parameter_code := NULL;
    FOR v_ruleCondt IN c_ruleCondt(v_routingRules.paymentmethodid) LOOP
      IF (l_parameter_code IS NULL) THEN
        l_parameter_code := v_ruleCondt.parameter_code;
      END IF;
      IF( (l_parameter_code = v_ruleCondt.parameter_code) AND (l_flag = 1) )THEN
        GOTO continue_loop;
      END IF;
      IF (l_parameter_code <> v_ruleCondt.parameter_code) THEN
        IF(l_flag = 0) THEN EXIT; END IF;
        l_parameter_code := v_ruleCondt.parameter_code;
        l_flag := 0;
      END IF;

      IF (v_ruleCondt.parameter_code = 'AMOUNT') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF  (p_routingAPIfields.amount = v_ruleCondt.value) THEN
            l_flag := 1;
          ELSE
            l_flag := 0; -- EXIT;
          END IF; -- if p_routingAPIfields.amount = v_ruleCondt.value
        END IF; -- if v_ruleCondt.operation_code = 'EQ'
        IF (v_ruleCondt.operation_code = 'NE') THEN
          IF  (p_routingAPIfields.amount <> v_ruleCondt.value) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.amount <> v_ruleCondt.value
        END IF; -- if v_ruleCondt.operation_code = 'NE'
        IF (v_ruleCondt.operation_code = 'LE') THEN
          IF  (p_routingAPIfields.amount <= v_ruleCondt.value) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.amount <= v_ruleCondt.value
        END IF; -- if v_ruleCondt.operation_code = 'LE'
        IF (v_ruleCondt.operation_code = 'LT') THEN
          IF  (p_routingAPIfields.amount < v_ruleCondt.value) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.amount < v_ruleCondt.value
        END IF; -- if v_ruleCondt.operation_code = 'LT'
        IF (v_ruleCondt.operation_code = 'GE') THEN
          IF  (p_routingAPIfields.amount >= v_ruleCondt.value) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.amount >= v_ruleCondt.value
        END IF; -- if v_ruleCondt.operation_code = 'GE'
        IF (v_ruleCondt.operation_code = 'GT') THEN
          IF  (p_routingAPIfields.amount > v_ruleCondt.value) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.amount > v_ruleCondt.value
        END IF; -- if v_ruleCondt.operation_code = 'GT'

      --
      -- adds routing based on currency where the parameter code
      -- is "CURR" and the operators are "EQ" , "NE"
      --
      ELSIF (v_ruleCondt.parameter_code = 'CURR') THEN
	IF (v_ruleCondt.operation_code = 'EQ') THEN
	  -- currency codes should be treated case insensitive
	  IF (UPPER(p_routingAPIfields.currency) = UPPER(v_ruleCondt.value)) THEN
	    l_flag := 1;
	  ELSE
	    l_flag := 0;
	  END IF; -- if p_routingAPIfields.currency = v_ruleCondt.value
	END IF; -- if v_ruleCondt.operation_code = 'EQ'
	IF (v_ruleCondt.operation_code = 'NE') THEN
	  IF (UPPER(p_routingAPIfields.currency) <> UPPER(v_ruleCondt.value)) THEN
	    l_flag := 1;
	  ELSE
	    l_flag := 0;
	  END IF; -- if p_routingAPIfields.currency <> v_ruleCondt.value
	END IF; -- if v_ruleCondt.operation_code = 'NE'

      ELSIF (v_ruleCondt.parameter_code = 'CC_TYPE') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.cc_type) = UPPER(v_ruleCondt.value))
            THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.cc_type = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.cc_type) <> UPPER(v_ruleCondt.value)) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.cc_type
        END IF; -- if v_ruleCondt.value = operation_code = 'EQ'

      ELSIF (v_ruleCondt.parameter_code = 'CC_NUM') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.cc_num) LIKE UPPER(v_ruleCondt.value))
            THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.cc_num = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.cc_num) LIKE UPPER(v_ruleCondt.value)) THEN
            l_flag := 0;
          ELSE
           l_flag := 1;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.cc_num
        END IF; -- if v_ruleCondt.value = operation_code = 'EQ'

      ELSIF (v_ruleCondt.parameter_code = 'ABA_ROUTING_NO') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.aba_routing_no) = UPPER(v_ruleCondt.value))
            THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.aba_routing_no = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.aba_routing_no) <> UPPER(v_ruleCondt.value)) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.aba_routing_no
        END IF; -- if v_ruleCondt.value = operation_code = 'EQ'

      ELSIF (v_ruleCondt.parameter_code = 'ABA_ROUTING_NO_PY') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.bnf_routing_no) = UPPER(v_ruleCondt.value))
            THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.bnf_routing_no = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.bnf_routing_no) <> UPPER(v_ruleCondt.value)) THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.bnf_routing_no
        END IF; -- if v_ruleCondt.value = operation_code

      ELSIF (v_ruleCondt.parameter_code = 'ORG_ID') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.org_id) = UPPER(v_ruleCondt.value))
            THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.org_id = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.org_id) <> UPPER(v_ruleCondt.value)) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.org_id
        END IF; -- if v_ruleCondt.value = operation_code = 'EQ'

      ELSIF (v_ruleCondt.parameter_code = 'APPLICATION_TYPE') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.financing_app_type) =
              UPPER(v_ruleCondt.value))
            THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.financing_app_type = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.financing_app_type) <>
              UPPER(v_ruleCondt.value)) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.financing_app_type
        END IF; -- if v_ruleCondt.value = operation_code = 'EQ'

      ELSIF (v_ruleCondt.parameter_code = 'COUNTRY_PY' ) THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.merchant_bank_country) =
              UPPER(v_ruleCondt.value))
            THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.financing_app_type = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.merchant_bank_country) <>
              UPPER(v_ruleCondt.value)) THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.financing_app_type
        END IF; -- if v_ruleCondt.value = operation_code = 'EQ'

      ELSIF (v_ruleCondt.parameter_code = 'COUNTRY_PR' ) THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.payer_bank_country) =
              UPPER(v_ruleCondt.value))
            THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.financing_app_type = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.payer_bank_country) <>
              UPPER(v_ruleCondt.value)) THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if v_ruleCondt.value <> p_routingAPIfields.payer_bank_country
        END IF; -- if v_ruleCondt.value = operation_code = 'EQ'

      --- *** R12 Modification *** ---
      -- Added  parameter 'FACTOR_FLAG'
      ELSIF (v_ruleCondt.parameter_code = 'FACTOR_FLAG') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (UPPER(p_routingAPIfields.factor_flag) =
              UPPER(v_ruleCondt.value))
            THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF; -- if p_routingAPIfields.payment_factor_flag = v_ruleCondt.value
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (UPPER(p_routingAPIfields.factor_flag) <>
              UPPER(v_ruleCondt.value)) THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        END IF;
      --
      -- 1st party ("payee") bank account id
      ELSIF (v_ruleCondt.parameter_code = 'PY_BANK_ACCOUNT') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (TO_CHAR(p_routingAPIfields.int_bank_acct_id) = v_ruleCondt.value)
          THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (TO_CHAR(p_routingAPIfields.int_bank_acct_id) <> v_ruleCondt.value)
          THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        END IF;
      ELSIF (v_ruleCondt.parameter_code = 'PY_BANK') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (TO_CHAR(p_routingAPIfields.int_bank_id) = v_ruleCondt.value)
          THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (TO_CHAR(p_routingAPIfields.int_bank_id) <> v_ruleCondt.value)
          THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        END IF;
      ELSIF (v_ruleCondt.parameter_code = 'AR_RECEIPT_METHOD_ID') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (p_routingAPIfields.ar_receipt_method_id = v_ruleCondt.value)
          THEN
           l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        ELSIF (v_ruleCondt.operation_code = 'NE') THEN
          IF (p_routingAPIfields.ar_receipt_method_id <> v_ruleCondt.value)
          THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        END IF;
      ELSIF (v_ruleCondt.parameter_code = 'BR_DRAWEE_ISSUED_FLAG') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (p_routingAPIfields.br_drawee_issued_flag = v_ruleCondt.value)
          THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        END IF;
      ELSIF (v_ruleCondt.parameter_code = 'BR_SIGNED_FLAG') THEN
        IF (v_ruleCondt.operation_code = 'EQ') THEN
          IF (p_routingAPIfields.br_signed_flag = v_ruleCondt.value)
          THEN
            l_flag := 1;
          ELSE
            l_flag := 0;
          END IF;
        END IF;
      END IF;

      <<continue_loop>>
      NULL;

    END LOOP;

  IF (l_flag = 1) THEN
    px_pmt_name_in_out := v_routingRules.paymentmethodname;
    EXIT;
  END IF;
  END LOOP;

  -- increment the hitCounter for this rule before leaving this method.
  SELECT hitcounter
    INTO l_hitcounter
    FROM iby_routinginfo
   WHERE paymentmethodname = px_pmt_name_in_out;

  l_hitcounter := NVL(l_hitcounter,0) + 1;

  UPDATE iby_routinginfo
     SET hitcounter = l_hitcounter
   WHERE paymentmethodname = px_pmt_name_in_out;
  COMMIT;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      IF c_routingRules%ISOPEN      THEN
          CLOSE c_routingRules;
      END IF;

      IF c_ruleCondt%ISOPEN      THEN
          CLOSE c_ruleCondt;
      END IF;

      IF (p_routingAPIfields.amount IS NULL)      THEN
          raise_application_error(-20000, 'IBY_204562#', FALSE);
        --raise_application_error(-20351, 'Amount not specified');
      END IF;

      IF (p_routingAPIfields.instr_type IS NULL)      THEN
          raise_application_error(-20000, 'IBY_204563#', FALSE);
        --raise_application_error(-20352,'Instrument type not specified');
      END IF;

    WHEN OTHERS THEN
      err_msg := SUBSTR(SQLERRM, 1, 100);
          raise_application_error(-20000, 'IBY_204564#'||'ERROR#'||err_msg||'#', FALSE);
      --raise_application_error(-20354,'OTHERS error in getPmtName: '||err_msg);
  END getPmtName;


  /* Internal procedure that gets the bep configuration by  */
  /* bep suffix.                                            */
  PROCEDURE getBepBySuffix
        (i_suffix          IN     IBY_BEPInfo.Suffix%TYPE,
         o_bepid           OUT NOCOPY IBY_BEPInfo.BEPID%TYPE,
         o_bep_base_url    OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         o_pmtschemename   OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         i_instrtype     IN     iby_accttype.instrtype%type )
  IS

  BEGIN

    -- Get bep info
    SELECT bepid , baseurl
      INTO o_bepid, o_bep_base_url
      FROM iby_bepinfo
     WHERE suffix = i_suffix;

     -- Get payment scheme name
	getPmtSchemeName(o_bepid, i_instrtype, o_pmtschemename);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      -- Suffix not found in IBY_BEPINFO table
      IF (o_bepid IS NULL)     THEN
          raise_application_error(-20000, 'IBY_20361#', FALSE);
      END IF;

	--unknown no data found error
          raise_application_error(-20000, 'IBY_20360#', FALSE);

    --WHEN OTHERS THEN
      --    raise_application_error(-20000, 'IBY_20364#', FALSE);

   END getBepBySuffix;


   -- reject any illegal payment operation
   PROCEDURE checkPaymentOperation(p_payment_operation_in IN VARCHAR2)
   IS
   BEGIN
     IF ((p_payment_operation_in <> 'ORAPMTREQ')AND
        (p_payment_operation_in <> 'ORAPMTBATCHREQ') AND
        (p_payment_operation_in <> 'ORAPMTMOD') AND
        (p_payment_operation_in <> 'ORAPMTCANC') AND
        (p_payment_operation_in <> 'ORAPMTINQ') AND
        (p_payment_operation_in <> 'ORAPMTCAPTURE') AND
        (p_payment_operation_in <> 'ORAPMTRETURN') AND
        (p_payment_operation_in <> 'ORAPMTCREDIT') AND
        (p_payment_operation_in <> 'ORAPMTVOID') AND
        (p_payment_operation_in <> 'ORAPMTCLOSEBATCH') AND
        (p_payment_operation_in <> 'ORAPMTQRYBATCHSTATUS') AND
        (p_payment_operation_in <> 'ORAPMTQRYTXSTATUS') AND
        (p_payment_operation_in <> 'ORAINV') AND
        (p_payment_operation_in <> 'ORAPAY'))

     THEN
	  -- invalid payment operation
          raise_application_error(-20000, 'IBY_20301#', FALSE);
     END IF;

   END checkPaymentOperation;


/* Procedure: checkPayeeByAccpPmtMthd
 * Function: to make sure given instrument type is supported by payee
*/

   PROCEDURE checkPayeeByAccpPmtMthd(i_payeeid iby_payee.payeeid%type,
				i_instr_type iby_accttype.instrtype%type)
   IS
	l_instr_type iby_accttype.instrtype%type;
	l_fin_payee_flag iby_payee.financing_payee_flag%type;

	cursor c_get_instrtype(ci_payeeid iby_payee.payeeid%type,
				ci_instr_type iby_accttype.instrtype%type)
	IS

		SELECT instrtype FROM iby_accttype a, iby_accppmtmthd b
		WHERE a.accttypeid = b.accttypeid
		AND b.payeeid = ci_payeeid
		AND b.status = 1
		AND a.instrtype = ci_instr_type;

	cursor c_get_fin_payee_flag(ci_payeeid iby_payee.payeeid%type)
	IS
		SELECT FINANCING_PAYEE_FLAG FROM iby_payee
		WHERE payeeid = ci_payeeid;
   BEGIN

     IF (i_instr_type = 'FINANCING') THEN
	IF c_get_fin_payee_flag%isopen THEN
		close c_get_fin_payee_flag;
	END IF;

	OPEN c_get_fin_payee_flag(i_payeeid);
	FETCH c_get_fin_payee_flag INTO l_fin_payee_flag;
	IF (l_fin_payee_flag <> 'Y') THEN
	   	raise_application_error(-20000, 'IBY_204455#INSTRTYPE=' ||
		i_instr_type || '#PAYEEID=' ||	i_payeeid || '#', FALSE);
	END IF;

        CLOSE c_get_fin_payee_flag;

     ELSE
	IF c_get_instrtype%isopen THEN
		close c_get_instrtype;
	END IF;

	OPEN c_get_instrtype(i_payeeid, i_instr_type);
	FETCH c_get_instrtype INTO l_instr_type;
	IF (c_get_instrtype%notfound) THEN
	   	raise_application_error(-20000, 'IBY_204455#INSTRTYPE=' ||
		i_instr_type || '#PAYEEID=' ||	i_payeeid || '#', FALSE);
	END IF;

	CLOSE c_get_instrtype;
      END IF;

   END checkPayeeByAccpPmtMthd;


/* Procedure: getBEPLang
 * Function:  fetch valid nlslang based on input lang
 */
procedure getBEPLang(i_bepid IN iby_bepinfo.bepid%type,
			io_beplang IN OUT NOCOPY iby_beplangs.beplang%type)
IS
   CURSOR   c_getPreferred(ci_bepid iby_bepinfo.bepid%type) IS
      SELECT beplang
        FROM iby_BEPlangs
       WHERE BEPID = ci_bepid
	AND Preferred = 0
	AND BEPLang <> '' AND BEPLang IS NOT NULL; -- reject anything trivial

   l_bep_lang_count NUMBER;
BEGIN

   l_bep_lang_count := 0;

   IF (io_beplang IS NULL or
	io_beplang = '' or
	io_beplang = ' ') THEN
	  return;   -- it's not set, keep it that way
   END IF;

    -- if given BEP accepts input lang, keep as is
    -- otherwise gives preferred, if preferred missing,
    -- give empty string (actually ' ', as plsql doesn't treat '' as NULL)
    SELECT count(*)
      INTO l_bep_lang_count
      FROM iby_BEPlangs
      WHERE BEPID = i_bepid
        AND UPPER(BEPlang) = UPPER(io_beplang);

    IF (l_bep_lang_count = 0)   THEN
	-- no match, fetched the preferred instead
	   -- overwrite input lang w/ non-trivial preferred value
	IF (c_getPreferred%isopen) THEN
	   CLOSE c_getPreferred;
	END IF;
	open c_getPreferred(i_bepid);
	fetch c_getPreferred into io_beplang;
	IF (c_getPreferred%notfound) THEN
	   io_beplang := ' ';-- can't set empty string, see Note above
	END IF;
	close c_getPreferred;
    END IF;
END getBEPLang;


/*
 * This function is a wrapper around the getBEPLang() procedure.
 * Since a function call is an rvalue, it can be used in an SQL
 * statement to specify the NLSLANG.
 */
/* comment out for now */
/*
FUNCTION getNLSLang(i_bepid IN iby_bepinfo.bepid%type,
    i_beplang IN iby_beplangs.beplang%type) RETURN VARCHAR2 IS
    v_Lang iby_beplangs.beplang%type;
BEGIN
    v_Lang := i_beplang;
    iby_paymentmanagerdb_pkg.getBEPLang(i_bepid, v_Lang);
    RETURN v_Lang;
END getNLSLang;
*/


-- Get payment scheme name for given bep based on instrtype
PROCEDURE getPmtSchemeName(i_bepid IN iby_bepinfo.bepid%type,
         		i_instrtype IN iby_accttype.instrtype%type,
			o_pmtschemename OUT NOCOPY
				iby_pmtschemes.pmtschemename%type)
IS

  l_scheme_not_found BOOLEAN := TRUE;
  l_bankpay_bep VARCHAR2(10);
  l_trxn_bep VARCHAR2(10);

  CURSOR c_getPmtSchemeName(ci_bepid iby_bepinfo.bepid%type,
			ci_name1 iby_pmtschemes.pmtschemename%type,
			ci_name2 iby_pmtschemes.pmtschemename%type DEFAULT NULL,
			ci_name3 iby_pmtschemes.pmtschemename%type DEFAULT NULL)
  IS
      SELECT p.PmtSchemename
        FROM iby_pmtschemes p, iby_bepinfo b
       WHERE p.bepid = b.bepid
         AND b.bepid = ci_bepid
	AND p.PMTSCHEMENAME IN (ci_name1, ci_name2, ci_name3);

BEGIN

    IF (c_getPmtSchemeName%isOpen) THEN
      close c_getPmtSchemeName;
    END IF;

    -- check to see if the indicated BEP matches
    -- the single BEP which has been configured to support
    -- bank payment trxns
    --
    -- If no Routing Rules are set, default payment system should
    -- be used. Hence commenting out code below to read from Profile
    -- option for BANKPAYMENT instrument.
    --
    --IF (UPPER(i_instrtype) = 'BANKPAYMENT') THEN
    --  o_pmtschemename := 'BANKPAYMENT';
    --  iby_utility_pvt.get_property(iby_paymentmanagerdb_pkg.C_PAYABLES_BEP_PROP_NAME,l_bankpay_bep);
      -- no need to use a cursor as the bepid filter
      -- is unique and should have been validated
      -- by now to point to an existing BEP
      --
      --SELECT suffix
      --INTO l_trxn_bep
      --FROM iby_bepinfo
      --WHERE (bepid=i_bepid);
      --l_scheme_not_found := l_trxn_bep <> NVL(l_bankpay_bep,'');
    --ELSE
      -- Change 'CREDITCARD' to 'SSL' and 'SET' for payment scheme
      -- Leave other payment types alone

      -- Commenting out above condition as Routing Rules for
      -- instrument BANKPAYMENT are supported now -nmukerje
      IF (UPPER(i_instrtype) = 'CREDITCARD') THEN
        open c_getPmtSchemeName(i_bepid, 'SET', 'SSL');
      ELSE
	open c_getPmtSchemeName(i_bepid, UPPER(i_instrtype));
      END IF;

      FETCH c_getPmtSchemeName INTO o_pmtschemename;
      l_scheme_not_found := c_getPmtSchemeName%NOTFOUND;
      CLOSE c_getPmtSchemeName;

    --END IF;

    IF (l_scheme_not_found) THEN
      -- No payment scheme found for bep with given instrtype
      raise_application_error(-20000, 'IBY_20362#BEPID=' ||
					i_bepid || '#', FALSE);
    --ELSE
	-- we should only have a single entry
	-- bep can only support 'SSL' and 'BANKACCOUNT' at the same time
	-- not any other combinations
    END IF;

END getPmtSchemeName;


PROCEDURE getBepUrl(i_base_url IN iby_bepinfo.baseurl%type,
			i_payment_op IN VARCHAR2,
		    i_pmtschemename IN iby_pmtschemes.pmtschemename%type,
		    i_suffix IN iby_bepinfo.suffix%type,
		    o_bep_url OUT NOCOPY VARCHAR2)
IS
BEGIN
    IF (i_pmtschemename = 'SSL' OR i_pmtschemename = 'PURCHASECARD' OR
        i_pmtschemename = 'FINANCING' OR i_pmtschemename = 'BANKACCOUNT' OR
        i_pmtschemename = 'BANKPAYMENT'
        OR i_pmtschemename = 'PINLESSDEBITCARD'
) THEN
      IF (i_payment_op = 'ORAINV')   THEN
        -- Construct CIPP INVOICE URL
        o_bep_url := i_base_url||'/orainv_'|| i_suffix;
      ELSIF (i_payment_op = 'ORAPAY')      THEN
        -- Construct CIPP PAY URL
        o_bep_url := i_base_url||'/orapay_'|| i_suffix;
      ELSE
        -- Construct MIPP URL
        o_bep_url := i_base_url||'/oramipp_'|| i_suffix;
      END IF;
     ELSIF (i_pmtschemename = 'SET')    THEN
      -- Construct SET URL
      o_bep_url := i_base_url || '/oraset_' || i_suffix;
    END IF;
END getBepUrl;

PROCEDURE getBepIdByPmtName(i_paymentmethodname IN   VARCHAR2,
                            i_payeeid           IN   iby_payee.payeeid%type,
                            o_bepid             OUT NOCOPY iby_bepinfo.bepid%type,
                            o_bepkey            OUT NOCOPY iby_bepkeys.key%type,
                            o_fc_user_profile_code     IN   OUT NOCOPY VARCHAR2)
IS
  CURSOR c_getBepIdByPmtName(ci_paymentmethodname VARCHAR2)
	IS
    	SELECT b.bepid, r.bepkey, r.fndcpt_user_profile_code
        FROM iby_routinginfo r, iby_bepinfo b
     	WHERE r.paymentmethodname = ci_paymentmethodname
	AND r.configured = 1
	AND r.bepid = b.bepid;

BEGIN

	IF (c_getBepIdByPmtName%isopen) THEN
	  close c_getBepIdByPmtName;
	END IF;

	open c_getBepIdByPmtName(i_paymentmethodname);
	fetch c_getBepIdByPmtName into o_bepid, o_bepkey, o_fc_user_profile_code;
	IF (c_getBepIdByPmtName%notfound) THEN
		o_bepid := -1;
	END IF;

	IF (c_getBepIdByPmtName%isopen) THEN
          close c_getBepIdByPmtName;
	END IF;

END getBepIdByPmtName;

PROCEDURE getDefaultBepId(i_mpayeeid          IN  iby_payee.mpayeeid%type,
                          i_payment_channel_code  IN  iby_trxn_summaries_all.payment_channel_code%type,
                          o_bepid             OUT NOCOPY iby_bepinfo.bepid%type,
                          o_bepkey            OUT NOCOPY iby_bepkeys.key%type,
                          o_fndcpt_user_profile_code OUT NOCOPY
                                              IBY_FNDCPT_USER_CC_PF_VL.USER_CC_PROFILE_CODE%TYPE)
IS
  -- *** R12 Modification *** ---
  -- Cursor retrieves default bep key and FndcptUserProfileCode
  -- given the mpayeeid and payment channel code
  CURSOR c_defaultBep(ci_mpayeeid iby_payee.mpayeeid%type,
                      ci_payment_channel_code iby_trxn_summaries_all.payment_channel_code%type)
	IS
	SELECT a.bepid,
	       c.key,
           a.fndcpt_user_profile_code
	FROM iby_default_bep a, iby_bepinfo b, iby_bepkeys c
	WHERE a.payment_channel_code = ci_payment_channel_code
	AND a.mpayeeid = ci_mpayeeid
	AND a.bepid = b.bepid
	AND UPPER(b.activeStatus) = 'Y'
    AND c.bep_account_id = a.bep_account_id;

BEGIN
    --dbms_output.put_line(SubStr('in getDefaultBepId',1,255));
	IF (c_defaultBep%isopen) THEN
	  close c_defaultBep;
	END IF;
    --dbms_output.put_line(SubStr('i_mpayeeid = '||i_mpayeeid,1,255));
    --dbms_output.put_line(SubStr('i_payment_channel_code = '||i_payment_channel_code,1,255));
	open c_defaultBep(i_mpayeeid, i_payment_channel_code);
	fetch c_defaultBep into o_bepid, o_bepkey, o_fndcpt_user_profile_code;
	close c_defaultBep;

END getDefaultBepId;


PROCEDURE getBepById(i_bepid IN iby_bepinfo.bepid%type,
		o_suffix OUT NOCOPY iby_bepinfo.suffix%type,
		o_baseurl OUT NOCOPY iby_bepinfo.baseurl%type,
		o_securityscheme OUT NOCOPY iby_bepinfo.securityscheme%type,
		o_bepusername OUT NOCOPY iby_bepinfo.bepusername%type,
		o_beppassword OUT NOCOPY iby_bepinfo.beppassword%type,
		o_beptype     OUT NOCOPY iby_bepinfo.bep_type%TYPE,
		o_leadtime    OUT NOCOPY iby_bepinfo.leadtime%TYPE)
IS
   CURSOR c_getBepById(ci_bepid iby_bepinfo.bepid%type)
   IS
    SELECT suffix, baseurl, securityscheme, BEPUsername, BEPPassword, bep_type, leadtime
    FROM iby_bepinfo
    WHERE bepid = ci_bepid;

BEGIN
	IF (i_bepid = -1) THEN
		-- shouldn't happen!
		raise_application_error(-20000, 'IBY_20521#', FALSE);
	END IF;

	IF c_getBepById%isopen THEN
	  close c_getBepById;
	END IF;

	open c_getBepById(i_bepid);
	fetch c_getBepById into o_suffix, o_baseurl, o_securityscheme,
				o_bepusername, o_beppassword, o_beptype, o_leadtime;

	close c_getBepById;
END getBepById;

PROCEDURE populateRoutingFields(
         p_amount         IN  iby_trxn_summaries_all.amount%type,
         p_instr_type     IN  iby_trxn_summaries_all.instrtype%type,
         p_instr_subtype  IN  iby_trxn_summaries_all.instrsubtype%type,
         p_currency       IN  iby_trxn_summaries_all.currencynamecode%type,
         p_payee_id       IN  iby_trxn_summaries_all.payeeid%type,
         p_cc_type        IN  VARCHAR2,
         p_cc_num         IN  iby_creditcard.ccnumber%type,
         p_aba_routing_no IN  iby_bankacct.routingno%type,
         p_bnf_routing_no IN  iby_bankacct.routingno%type,
         p_org_id         IN  iby_trxn_summaries_all.org_id%type,
         p_fin_app_type   IN  VARCHAR2,
         p_merchant_bank_country IN VARCHAR2,
         p_factor_flag    IN iby_trxn_summaries_all.factored_flag%type,
	 p_payer_bank_country  IN VARCHAR2,
         x_routingfields  OUT NOCOPY RoutingAPIFields_rec_type
)
IS


BEGIN

  --- *** R12 Modification *** ---
  -- Added  'factor_flag'.
  x_routingfields.amount := p_amount;
  x_routingfields.instr_type := p_instr_type;
  x_routingfields.instr_subtype := p_instr_subtype;
  x_routingfields.currency := p_currency;
  x_routingfields.payee_id := p_payee_id;
  x_routingfields.cc_type := p_cc_type;
  x_routingfields.cc_num := p_cc_num;
  x_routingfields.aba_routing_no := p_aba_routing_no;
  x_routingfields.bnf_routing_no := p_bnf_routing_no;
  x_routingfields.org_id := p_org_id;
  x_routingfields.financing_app_type := p_fin_app_type;
  x_routingfields.merchant_bank_country := p_merchant_bank_country;
  x_routingfields.factor_flag := p_factor_flag;
  x_routingfields.payer_bank_country := p_payer_bank_country;


END populateRoutingFields;

END iby_paymentmanagerdb_pkg;

/
