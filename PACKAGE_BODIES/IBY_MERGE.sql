--------------------------------------------------------
--  DDL for Package Body IBY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_MERGE" AS
/*$Header: IBYMERGB.pls 120.1.12010000.2 2009/09/10 10:48:29 sgogula noship $ */

	/*-------------------------------------------------------------
	|  FUNCTION
	|      GET_EXTERNAL_PAYER_ID
	|     RETURN NUMBER
	|  DESCRIPTION :
	|      FUNCTION TO RETURN A EXTERNAL PAYER ID
	|	FOR A GIVEN CUST ACCOUNT ID AND ACCOUNT SITE USE ID
	|--------------------------------------------------------------*/

	FUNCTION  GET_EXTERNAL_PAYER_ID
	 (
	     account_id iby_external_payers_all.cust_account_id%TYPE,
		 account_site_use_id iby_external_payers_all.acct_site_use_id%TYPE
	  ) RETURN NUMBER IS
	  ext_payer_id  iby_external_payers_all.ext_payer_id%TYPE;
	BEGIN
	        OPEN cur_get_ext_payer_id(account_id,account_site_use_id);
			FETCH cur_get_ext_payer_id INTO ext_payer_id;
			CLOSE cur_get_ext_payer_id;
			RETURN ext_payer_id;
	END GET_EXTERNAL_PAYER_ID;

	/*-------------------------------------------------------------
	|
	|  PROCEDURE
	|      TRX_SUMMARY_MERGE
	|  DESCRIPTION :
	|      Account merge procedure for the table, TRX_SUMMARY_MERGE
	|--------------------------------------------------------------*/
	PROCEDURE TRX_SUMMARY_MERGE (
	        req_id                       NUMBER,
	        set_num                      NUMBER,
	        process_mode                 VARCHAR2) IS

	  TYPE merge_header_id_list_type IS TABLE OF
	       ra_customer_merge_headers.customer_merge_header_id%TYPE
	       INDEX BY BINARY_INTEGER;
	  merge_header_id_list merge_header_id_list_type;

	  TYPE trxnmid_list_type IS TABLE OF
	         iby_trxn_summaries_all.trxnmid%TYPE
	        INDEX BY BINARY_INTEGER;
	  primary_key_id_list trxnmid_list_type;

	  TYPE cust_account_id_list_type IS TABLE OF
	         iby_trxn_summaries_all.cust_account_id%TYPE
	        INDEX BY BINARY_INTEGER;
	  num_col1_orig_list cust_account_id_list_type;
	  num_col1_new_list cust_account_id_list_type;

	  TYPE acct_site_id_list_type IS TABLE OF
	         iby_trxn_summaries_all.acct_site_id%TYPE
	        INDEX BY BINARY_INTEGER;
	  num_col2_orig_list acct_site_id_list_type;
	  num_col2_new_list acct_site_id_list_type;

	  TYPE acct_site_use_id_list_type IS TABLE OF
	         iby_trxn_summaries_all.acct_site_use_id%TYPE
	        INDEX BY BINARY_INTEGER;
	  num_col3_orig_list acct_site_use_id_list_type;
	  num_col3_new_list acct_site_use_id_list_type;

	  ext_payer_from_list 	ext_payer_id_list_type;
	  ext_payer_to_list 	ext_payer_id_list_type;

	  l_profile_val VARCHAR2(30);
	  CURSOR merged_records IS
	        SELECT DISTINCT customer_merge_header_id
	              ,trxnmid
	              ,cust_account_id
	              ,acct_site_id
	              ,acct_site_use_id
	         FROM iby_trxn_summaries_all yt, ra_customer_merges m
	         WHERE (
	            yt.cust_account_id = m.duplicate_id
	            OR yt.acct_site_id = m.duplicate_address_id
	            OR yt.acct_site_use_id = m.duplicate_site_id
	         ) AND    m.process_flag = 'N'
	         AND    m.request_id = req_id
	         AND    m.set_number = set_num;
	  l_last_fetch BOOLEAN := FALSE;
	  l_count NUMBER;
	BEGIN
	  IF process_mode='LOCK' THEN
	    NULL;
	  ELSE
	    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
	    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IBY_TRXN_SUMMARIES_ALL',FALSE);
	    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
	    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

	    open merged_records;
	    LOOP
	      FETCH merged_records BULK COLLECT INTO
	         merge_header_id_list
	          , primary_key_id_list
	          , num_col1_orig_list
	          , num_col2_orig_list
	          , num_col3_orig_list
	          ;
	      IF merged_records%NOTFOUND THEN
	         l_last_fetch := TRUE;
	      END IF;
	      IF merge_header_id_list.COUNT = 0 and l_last_fetch then
	        exit;
	      END IF;
	      FOR i in 1..merge_header_id_list.COUNT LOOP
	         num_col1_new_list(i) := hz_acct_merge_util.getdup_account(num_col1_orig_list(i));
	         num_col2_new_list(i) := hz_acct_merge_util.getdup_site(num_col2_orig_list(i));
	         num_col3_new_list(i) := hz_acct_merge_util.getdup_site_use(num_col3_orig_list(i));
			/*
			    For a given Account and Site Combination, there can be a single Payer.
			    Get the Payer Id for both the duplicate and Target Account
			 */
			 ext_payer_from_list(i) := get_external_payer_id(num_col1_orig_list(i),num_col3_orig_list(i));
			 ext_payer_to_list(i) := get_external_payer_id(num_col1_new_list(i),num_col3_new_list(i));
	      END LOOP;
	      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	        FORALL I in 1..merge_header_id_list.COUNT
	         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
	           merge_log_id,
	           table_name,
	           merge_header_id,
	           primary_key_id,
	           num_col1_orig,
	           num_col1_new,
	           num_col2_orig,
	           num_col2_new,
	           num_col3_orig,
	           num_col3_new,
	           action_flag,
	           request_id,
	           created_by,
	           creation_date,
	           last_update_login,
	           last_update_date,
	           last_updated_by
	      ) VALUES (         hz_customer_merge_log_s.nextval,
	         'IBY_TRXN_SUMMARIES_ALL',
	         merge_header_id_list(i),
	         primary_key_id_list(i),
	         num_col1_orig_list(i),
	         num_col1_new_list(i),
	         num_col2_orig_list(i),
	         num_col2_new_list(i),
	         num_col3_orig_list(i),
	         num_col3_new_list(i),
	         'U',
	         req_id,
	         hz_utility_pub.created_by,
	         hz_utility_pub.creation_date,
	         hz_utility_pub.last_update_login,
	         hz_utility_pub.last_update_date,
	         hz_utility_pub.last_updated_by
	      );

	    END IF;
	    /*
		  Update the Payement Instrument Assignment Id with the new value
		  From the Payment Instrument Use Id, get the Instrument Id
		  Check if the same instrument id exists for the payer of the
		  target account.If exists, update the record with the new  Payment Instrument Use Id
	        */
		FORALL i in 1..ext_payer_from_list.COUNT
		UPDATE iby_trxn_summaries_all DUP
		SET payer_instr_assignment_id =
				     (SELECT to_instr.instrument_payment_use_id FROM
					   iby_pmt_instr_uses_all from_inst,
					   iby_pmt_instr_uses_all to_instr
					   WHERE from_inst.instrument_payment_use_id = dup.payer_instr_assignment_id
					   AND to_instr.ext_pmt_party_id = ext_payer_to_list(i)
					   AND to_instr.instrument_id = from_inst.instrument_id
					   AND from_inst.ext_pmt_party_id = ext_payer_from_list(i))
		WHERE payer_instr_assignment_id IS NOT NULL
		AND ext_payer_from_list(i) IS NOT NULL
		AND ext_payer_to_list(i) IS NOT NULL
		AND reqtype IN ('ORAPMTREQ','ORAPMTBATCHREQ')
		AND status <> 0
		AND EXISTS
		(
		   SELECT to_instr.instrument_payment_use_id FROM
		   iby_pmt_instr_uses_all from_inst,
		   iby_pmt_instr_uses_all to_instr
		   WHERE from_inst.instrument_payment_use_id = dup.payer_instr_assignment_id
		   AND to_instr.ext_pmt_party_id = ext_payer_to_list(i)
		   AND to_instr.instrument_id = from_inst.instrument_id
		   AND from_inst.ext_pmt_party_id = ext_payer_from_list(i)
		);
	   /*
	            If the Instrument type is credit card, check if the duplicate and target
	            payers are having creditcards with similar hashcode1 and hashcode2
		 If exists, update the record with the new  Payment Instrument Use Id
	       */
		FORALL i in 1..ext_payer_from_list.COUNT
		UPDATE iby_trxn_summaries_all dup
		SET payer_instr_assignment_id =
		       (SELECT to_uses.instrument_payment_use_id FROM
				iby_pmt_instr_uses_all  from_uses,
				iby_pmt_instr_uses_all  to_uses,
				iby_creditcard from_cards,
				iby_creditcard to_cards
				WHERE from_uses.instrument_payment_use_id = dup.payer_instr_assignment_id
				AND from_uses.instrument_id = from_cards.instrid
				AND to_cards.cc_number_hash1 = from_cards.cc_number_hash1
				AND to_cards.cc_number_hash2 = from_cards.cc_number_hash2
				AND to_uses.instrument_id = to_cards.instrid
				AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i)
                AND from_uses.ext_pmt_party_id = ext_payer_from_list(i))
	    WHERE payer_instr_assignment_id IS NOT NULL
	  	AND reqtype in ('ORAPMTREQ','ORAPMTBATCHREQ')
		AND status <> 0
		AND ext_payer_from_list(i) is not null
		AND ext_payer_to_list(i) is not null
		AND EXISTS
	   (
		    SELECT To_uses.instrument_payment_use_id FROM
			iby_pmt_instr_uses_all  from_uses,
			iby_pmt_instr_uses_all  to_uses,
			iby_creditcard from_cards,
			iby_creditcard to_cards
			WHERE from_uses.instrument_payment_use_id = dup.payer_instr_assignment_id
			AND from_uses.instrument_type = 'CREDITCARD'
			AND from_uses.instrument_id = from_cards.instrid
			AND to_cards.cc_number_hash1 = from_cards.cc_number_hash1
			AND to_cards.cc_number_hash2 = from_cards.cc_number_hash2
			AND to_uses.instrument_id = to_cards.instrid
			AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i)
			AND from_uses.ext_pmt_party_id = ext_payer_from_list(i)
	   ) ;
	   /*
	            If the Instrument type is Bank Account, check if the duplicate and target
	            payers are having  same hash values.
		 If exists, update the record with the new  Payment Instrument Use Id
	       */
		FORALL i in 1..ext_payer_from_list.COUNT
		UPDATE iby_trxn_summaries_all dup
		SET payer_instr_assignment_id =
		    (
			    SELECT To_uses.instrument_payment_use_id FROM
				iby_pmt_instr_uses_all  from_uses,
				iby_pmt_instr_uses_all  to_uses,
				iby_ext_bank_accounts from_accounts,
				iby_ext_bank_accounts to_accounts
				WHERE from_uses.instrument_payment_use_id = dup.payer_instr_assignment_id
				AND from_uses.instrument_type = 'BANKACCOUNT'
				AND from_uses.instrument_id = from_accounts.ext_bank_account_id
				AND to_accounts.iban_hash1  = from_accounts.iban_hash1
				AND to_accounts.iban_hash2 = from_accounts.iban_hash2
				AND to_uses.instrument_id = to_accounts.ext_bank_account_id
				AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i)
				AND from_uses.ext_pmt_party_id = ext_payer_from_list(i)
           )
	    WHERE payer_instr_assignment_id IS NOT NULL
	  	AND reqtype in ('ORAPMTREQ','ORAPMTBATCHREQ')
		AND status <> 0
		AND ext_payer_from_list(i) is not null
		AND ext_payer_to_list(i) is not null
		AND EXISTS
	   (
		    SELECT To_uses.instrument_payment_use_id FROM
			iby_pmt_instr_uses_all  from_uses,
			iby_pmt_instr_uses_all  to_uses,
			iby_ext_bank_accounts from_accounts,
			iby_ext_bank_accounts to_accounts
			WHERE from_uses.instrument_payment_use_id = dup.payer_instr_assignment_id
			AND from_uses.instrument_type = 'BANKACCOUNT'
			AND from_uses.instrument_id = from_accounts.ext_bank_account_id
			AND to_accounts.iban_hash1  = from_accounts.iban_hash1
			AND to_accounts.iban_hash2 = from_accounts.iban_hash2
			AND to_uses.instrument_id = to_accounts.ext_bank_account_id
			AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i)
			AND from_uses.ext_pmt_party_id = ext_payer_from_list(i)
	   ) ;
	   /*
	              Update the Cust Account and Site Use with the new values
	       */
		FORALL i in 1..merge_header_id_list.COUNT
	    UPDATE iby_trxn_summaries_all yt SET
	           cust_account_id=num_col1_new_list(i)
	          ,acct_site_id=num_col2_new_list(i)
	          ,acct_site_use_id=num_col3_new_list(i)
	          , last_update_date=SYSDATE
	          , last_updated_by=arp_standard.profile.user_id
	          , last_update_login=arp_standard.profile.last_update_login
	    WHERE trxnmid=primary_key_id_list(i)
		AND reqtype IN ('ORAPMTREQ','ORAPMTBATCHREQ')
		AND status <> 0

	         ;
	      l_count := l_count + SQL%ROWCOUNT;
	      IF l_last_fetch THEN
	         EXIT;
	      END IF;
	    END LOOP;

	    arp_message.set_name('AR','AR_ROWS_UPDATED');
	    arp_message.set_token('NUM_ROWS',to_char(l_count));
	  END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	    arp_message.set_line( 'TRX_SUMMARY_MERGE');
	    RAISE;
	END TRX_SUMMARY_MERGE;

	/*-------------------------------------------------------------
	|
	|  PROCEDURE
	|      TRANSACTIONS_EXT_MERGE
	|  DESCRIPTION :
	|      Account merge procedure for the table, IBY_FNDCPT_TX_EXTENSIONS
	|--------------------------------------------------------------*/

	PROCEDURE TRANSACTIONS_EXT_MERGE
	(
	ext_payer_from_list ext_payer_id_list_type,
	ext_payer_to_list ext_payer_id_list_type
	) IS
	BEGIN
	  /*Merge Instruments Use only if the same instrument exists at both the levels
	         We need to merge only those records which are not yer captured
	        */
	  iby_debug_pub.Add('Updating the instrument Assignment Id...');
	  FORALL i in 1..ext_payer_from_list.COUNT
	  UPDATE IBY_FNDCPT_TX_EXTENSIONS DUP
	  SET instr_assignment_id =
	     (SELECT to_instr.instrument_payment_use_id FROM
		   iby_pmt_instr_uses_all from_inst,
		   iby_pmt_instr_uses_all to_instr
		   WHERE from_inst.instrument_payment_use_id = dup.instr_assignment_id
		   AND to_instr.ext_pmt_party_id = ext_payer_to_list(i)
		   AND to_instr.instrument_id = from_inst.instrument_id)
		WHERE ext_payer_id = ext_payer_from_list(i)
		AND ext_payer_from_list(i) IS NOT NULL
		AND  ext_payer_to_list(i) IS NOT NULL
		AND  instr_assignment_id IS NOT NULL
	   AND ( EXISTS (
              SELECT      1
	          FROM iby_trxn_summaries_all s
	               ,iby_fndcpt_tx_operations o
	          WHERE o.trxn_extension_id = dup.trxn_extension_id
	          AND s.transactionid = o.transactionid
	          AND s.reqtype IN ('ORAPMTREQ','ORAPMTBATCHREQ')
	          AND s.status <> 0 )
		  OR NOT EXISTS
			(
			  Select 1 from iby_fndcpt_tx_operations o
			  where o.trxn_extension_id = dup.trxn_extension_id
			)
		)
	   AND EXISTS
	   (
		   SELECT to_instr.instrument_payment_use_id FROM
		   iby_pmt_instr_uses_all from_inst,
		   iby_pmt_instr_uses_all to_instr
		   WHERE from_inst.instrument_payment_use_id = dup.instr_assignment_id
		   AND to_instr.ext_pmt_party_id = ext_payer_to_list(i)
		   AND to_instr.instrument_id = from_inst.instrument_id
	   );
	  /*  For credit cards we need to check the Hashcodes. Same hashcodes mean the same instrument*/
	   iby_debug_pub.Add('Modifying instrument use id for credit cards');
	   FORALL i in 1..ext_payer_from_list.COUNT
	   UPDATE iby_fndcpt_tx_extensions dup
	   SET instr_assignment_id =
	    (SELECT to_uses.instrument_payment_use_id FROM
			iby_pmt_instr_uses_all  from_uses,
			iby_pmt_instr_uses_all  to_uses,
			iby_creditcard from_cards,
			iby_creditcard to_cards
			WHERE from_uses.instrument_payment_use_id = dup.instr_assignment_id
			AND from_uses.instrument_id = from_cards.instrid
			AND to_cards.cc_number_hash1 = from_cards.cc_number_hash1
			AND to_cards.cc_number_hash2 = from_cards.cc_number_hash2
			AND to_uses.instrument_id = to_cards.instrid
			AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i) )
	    WHERE ext_payer_id = ext_payer_from_list(i)
	  	AND ext_payer_from_list(i) IS NOT NULL
		AND  ext_payer_to_list(i) IS NOT NULL
		AND  instr_assignment_id IS NOT NULL
	    AND ( EXISTS (
              SELECT      1
	          FROM iby_trxn_summaries_all s
	               ,iby_fndcpt_tx_operations o
	          WHERE o.trxn_extension_id = dup.trxn_extension_id
	          AND s.transactionid = o.transactionid
	          AND s.reqtype IN ('ORAPMTREQ','ORAPMTBATCHREQ')
	          AND s.status <> 0 )
		  OR NOT EXISTS
			(
			  Select 1 from iby_fndcpt_tx_operations o
			  where o.trxn_extension_id = dup.trxn_extension_id
			)
		)
	    AND EXISTS
	    (

		    SELECT to_uses.instrument_payment_use_id FROM
			iby_pmt_instr_uses_all  from_uses,
			iby_pmt_instr_uses_all  to_uses,
			iby_creditcard from_cards,
			iby_creditcard to_cards
			WHERE from_uses.instrument_payment_use_id = dup.instr_assignment_id
			AND from_uses.instrument_type = 'CREDITCARD'
			AND from_uses.instrument_id = from_cards.instrid
			AND to_cards.cc_number_hash1 = from_cards.cc_number_hash1
			AND to_cards.cc_number_hash2 = from_cards.cc_number_hash2
			AND to_uses.instrument_id = to_cards.instrid
			AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i)
	     ) ;

		 /*  For Bank Accounts we need to check the Hashcodes. Same hashcodes mean the same instrument*/
	   iby_debug_pub.Add('Modifying instrument use id for bank accounts');
	   FORALL i in 1..ext_payer_from_list.COUNT
	   UPDATE iby_fndcpt_tx_extensions dup
	   SET instr_assignment_id =
	    (SELECT to_uses.instrument_payment_use_id FROM
			iby_pmt_instr_uses_all  from_uses,
			iby_pmt_instr_uses_all  to_uses,
			iby_ext_bank_accounts from_accounts,
			iby_ext_bank_accounts to_accounts
			WHERE from_uses.instrument_payment_use_id = dup.instr_assignment_id
			AND from_uses.instrument_type = 'BANKACCOUNT'
			AND from_uses.instrument_id = from_accounts.ext_bank_account_id
			AND to_accounts.iban_hash1 = from_accounts.iban_hash1
			AND to_accounts.iban_hash2 = from_accounts.iban_hash2
			AND to_uses.instrument_id = to_accounts.ext_bank_account_id
			AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i)  )
	    WHERE ext_payer_id = ext_payer_from_list(i)
	  	AND ext_payer_from_list(i) IS NOT NULL
		AND  ext_payer_to_list(i) IS NOT NULL
		AND  instr_assignment_id IS NOT NULL
	    AND ( EXISTS (
              SELECT      1
	          FROM iby_trxn_summaries_all s
	               ,iby_fndcpt_tx_operations o
	          WHERE o.trxn_extension_id = dup.trxn_extension_id
	          AND s.transactionid = o.transactionid
	          AND s.reqtype IN ('ORAPMTREQ','ORAPMTBATCHREQ')
	          AND s.status <> 0 )
		  OR NOT EXISTS
			(
			  Select 1 from iby_fndcpt_tx_operations o
			  where o.trxn_extension_id = dup.trxn_extension_id
			)
		)
	    AND EXISTS
	    (

		    SELECT to_uses.instrument_payment_use_id FROM
			iby_pmt_instr_uses_all  from_uses,
			iby_pmt_instr_uses_all  to_uses,
			iby_ext_bank_accounts from_accounts,
			iby_ext_bank_accounts to_accounts
			WHERE from_uses.instrument_payment_use_id = dup.instr_assignment_id
			AND from_uses.instrument_type = 'BANKACCOUNT'
			AND from_uses.instrument_id = from_accounts.ext_bank_account_id
			AND to_accounts.iban_hash1 = from_accounts.iban_hash1
			AND to_accounts.iban_hash2 = from_accounts.iban_hash2
			AND to_uses.instrument_id = to_accounts.ext_bank_account_id
			AND to_uses.ext_pmt_party_id =  ext_payer_to_list(i)
	     ) ;
	    /*  Update the Payer with the new value */
	    iby_debug_pub.Add('Modifying the Payer value');
	    FORALL i in 1..ext_payer_from_list.COUNT
	    UPDATE iby_fndcpt_tx_extensions dup
	    SET ext_payer_id = ext_payer_to_list(i)
	    WHERE ext_payer_id = ext_payer_from_list(i)
	    AND ext_payer_from_list(i) IS NOT NULL
		AND  ext_payer_to_list(i) IS NOT NULL
		AND
		( EXISTS (
              SELECT      1
	          FROM iby_trxn_summaries_all s
	               ,iby_fndcpt_tx_operations o
	          WHERE o.trxn_extension_id = dup.trxn_extension_id
	          AND s.transactionid = o.transactionid
	          AND s.reqtype IN ('ORAPMTREQ','ORAPMTBATCHREQ')
	          AND s.status <> 0 )
		  OR NOT EXISTS
			(
			  Select 1 from iby_fndcpt_tx_operations o
			  where o.trxn_extension_id = dup.trxn_extension_id
			)
		);

	EXCEPTION
	  WHEN OTHERS THEN
	    arp_message.set_line( 'TRANSACTIONS_EXT_MERGE');
	    RAISE;

	END TRANSACTIONS_EXT_MERGE;

	/*-------------------------------------------------------------
	|
	|  PROCEDURE
	|      PAYMENT_METHODS_MERGE
	|  DESCRIPTION :
	|      Account merge procedure for the table, IBY_EXT_PARTY_PMT_MTHDS
	|--------------------------------------------------------------*/
	PROCEDURE PAYMENT_METHODS_MERGE
	(
	  ext_payer_from_list ext_payer_id_list_type,
	  ext_payer_to_list ext_payer_id_list_type
	 ) IS

	BEGIN
	 /*
	     At target account, if there exists a payer method for an instrument
	     similar to that of the target account, inactivate the payment method
	     for the target account, else transfer the same
	  */
	  iby_debug_pub.Add('Merging the Payment Methods');
	   FORALL i in 1..ext_payer_from_list.COUNT
	   UPDATE iby_ext_party_pmt_mthds dup
	   SET ext_pmt_party_id = ext_payer_to_list(i),
	       last_update_date = SYSDATE,
	       last_updated_by = arp_standard.profile.user_id,
	       last_update_login = arp_standard.profile.last_update_login
		WHERE  ext_pmt_party_id = 	ext_payer_from_list(i)
	    AND ext_payer_from_list(i) IS NOT NULL
	    AND ext_payer_to_list(i) IS NOT NULL
	    AND NOT EXISTS
	    (
		   SELECT  ext_party_pmt_mthd_id
	       FROM  iby_ext_party_pmt_mthds mto
	       WHERE  mto.ext_pmt_party_id = ext_payer_to_list(i)
	       AND  mto.payment_method_code = dup.payment_method_code
		   AND  mto.payment_flow = dup.payment_flow
		   AND mto.payment_function = dup.payment_function
	     );
		iby_debug_pub.Add('Transferring the Payment Methods');
	    FORALL i in 1..ext_payer_from_list.COUNT
	    UPDATE iby_ext_party_pmt_mthds dup
	    SET inactive_date = SYSDATE,
	       last_update_date = SYSDATE,
	       last_updated_by = arp_standard.profile.user_id,
	       last_update_login = arp_standard.profile.last_update_login
		WHERE  ext_pmt_party_id = 	ext_payer_from_list(i)
		AND ext_payer_from_list(i) IS NOT NULL
	    AND ext_payer_to_list(i) IS NOT NULL
	    AND EXISTS
	    (
		   SELECT  ext_party_pmt_mthd_id
	       FROM  iby_ext_party_pmt_mthds mto
	       WHERE  mto.ext_pmt_party_id = ext_payer_to_list(i)
	       AND  mto.payment_method_code = dup.payment_method_code
		   AND  mto.payment_flow = dup.payment_flow
		   AND mto.payment_function = dup.payment_function
	     );

	EXCEPTION
	  WHEN OTHERS THEN
	    arp_message.set_line( 'PAYMENT_METHODS_MERGE');
	    RAISE;

	END  PAYMENT_METHODS_MERGE;

	/*-------------------------------------------------------------
	|
	|  PROCEDURE
	|      INSTRUMENT_MERGE
	|  DESCRIPTION :
	|      Account merge procedure for the table, IBY_PMT_INSTR_USES_ALL
	|--------------------------------------------------------------*/
	PROCEDURE INSTRUMENT_MERGE
	(
	  ext_payer_from_list ext_payer_id_list_type,
	  ext_payer_to_list ext_payer_id_list_type
	) IS
	BEGIN
	 /*
	     If there exists a similar instrument at both the accounts,
	    inactivate the payment method for the target account, else transfer the same
	  */
	 iby_debug_pub.Add('Transferring the Instruments');
		FORALL i in 1..ext_payer_from_list.COUNT
		UPDATE iby_pmt_instr_uses_all dup
		SET ext_pmt_party_id = ext_payer_to_list(i),
	    last_update_date = SYSDATE,
	    last_updated_by = arp_standard.profile.user_id,
	    last_update_login = arp_standard.profile.last_update_login
		WHERE ext_pmt_party_id = 	ext_payer_from_list(i)
		AND ext_payer_from_list(i) IS NOT NULL
		AND ext_payer_to_list(i) IS NOT NULL
		AND NOT EXISTS
	    (
		   SELECT  instrument_id
	       FROM  iby_pmt_instr_uses_all mto
	       WHERE  mto.ext_pmt_party_id = ext_payer_to_list(i)
	       AND  mto.instrument_id = dup.instrument_id
		   AND mto.payment_flow = dup.payment_flow
		   AND mto.payment_function = dup.payment_function
		   AND mto.instrument_type = dup.instrument_type
	    );
		/*
		 If two  Credit cards carries the  same hash codes , it means there
		 exists a single instrument., in which case, we need to transfer
		*/
		iby_debug_pub.Add('Transferring the Credit Cards');
		FORALL i in 1..ext_payer_from_list.COUNT
	    UPDATE iby_pmt_instr_uses_all dup
		SET ext_pmt_party_id = ext_payer_to_list(i),
	    last_update_date = SYSDATE,
	    last_updated_by = arp_standard.profile.user_id,
	    last_update_login = arp_standard.profile.last_update_login
	    WHERE ext_pmt_party_id = 	ext_payer_from_list(i)
	    AND ext_payer_from_list(i) IS NOT NULL
	    AND ext_payer_to_list(i) IS NOT NULL
		AND dup.instrument_type = 'CREDITCARD'
		AND NOT EXISTS
		(
		   SELECT 1 FROM
		   iby_creditcard from_card,
		   iby_creditcard to_card,
		   iby_pmt_instr_uses_all uses
		   WHERE from_card.instrid = dup.instrument_id
		   AND to_card.cc_number_hash1 = from_card.cc_number_hash1
		   AND to_card.cc_number_hash2 = from_card.cc_number_hash2
		   AND to_card.instrid = uses.instrument_id
		   AND uses.ext_pmt_party_id = ext_payer_to_list(i)

		);

		/*
		 If two  Bank Accounts  carries the  same hash codes , it means there
		 exists a single instrument., in which case, we need to transfer
		*/
		iby_debug_pub.Add('Transferring the Credit Cards');
		FORALL i in 1..ext_payer_from_list.COUNT
	    UPDATE iby_pmt_instr_uses_all dup
		SET ext_pmt_party_id = ext_payer_to_list(i),
	    last_update_date = SYSDATE,
	    last_updated_by = arp_standard.profile.user_id,
	    last_update_login = arp_standard.profile.last_update_login
	    WHERE ext_pmt_party_id = 	ext_payer_from_list(i)
	    AND ext_payer_from_list(i) IS NOT NULL
	    AND ext_payer_to_list(i) IS NOT NULL
		AND dup.instrument_type = 'BANKACCOUNT'
		AND NOT EXISTS
		(
		   SELECT 1 FROM
		   iby_ext_bank_accounts from_account,
		   iby_ext_bank_accounts to_account,
		   iby_pmt_instr_uses_all uses
		   WHERE from_account.ext_bank_account_id = dup.instrument_id
		   AND to_account.iban_hash1 = from_account.iban_hash1
		   AND to_account.iban_hash2 = from_account.iban_hash2
		   AND to_account.ext_bank_account_id = uses.instrument_id
		   AND uses.ext_pmt_party_id = ext_payer_to_list(i)

		);



		iby_debug_pub.Add('Inactivating the Instruments for duplicat account');
		FORALL i in 1..ext_payer_from_list.COUNT
	    UPDATE iby_pmt_instr_uses_all dup
	    SET end_date = SYSDATE,
		last_update_date = SYSDATE,
		last_updated_by = arp_standard.profile.user_id,
		last_update_login = arp_standard.profile.last_update_login
	    WHERE ext_pmt_party_id = 	ext_payer_from_list(i)
	    AND ext_payer_from_list(i) IS NOT NULL
	    AND ext_payer_to_list(i) IS NOT NULL
		AND  EXISTS
		(
		   SELECT  instrument_id
		   FROM  iby_pmt_instr_uses_all mto
		   WHERE  mto.ext_pmt_party_id = ext_payer_to_list(i)
		   AND  mto.instrument_id = dup.instrument_id
		   AND mto.payment_flow = dup.payment_flow
		   AND mto.payment_function = dup.payment_function
		   AND mto.instrument_type = dup.instrument_type
		);

		iby_debug_pub.Add('Inactivating the Credit cards for dupliacte account');
		FORALL i in 1..ext_payer_from_list.COUNT
	    UPDATE iby_pmt_instr_uses_all dup
		SET end_date = SYSDATE,
	    last_update_date = SYSDATE,
	    last_updated_by = arp_standard.profile.user_id,
	    last_update_login = arp_standard.profile.last_update_login
	    WHERE ext_pmt_party_id = 	ext_payer_from_list(i)
	    AND ext_payer_from_list(i) IS NOT NULL
	    AND ext_payer_to_list(i) IS NOT NULL
		AND dup.instrument_type = 'CREDITCARD'
		AND  EXISTS
		(
		  SELECT 1 FROM
		  iby_creditcard from_card,
		  iby_creditcard to_card,
		  iby_pmt_instr_uses_all uses
		  WHERE from_card.instrid = dup.instrument_id
		  AND to_card.cc_number_hash1 = from_card.cc_number_hash1
		  AND to_card.cc_number_hash2 = from_card.cc_number_hash2
		  AND to_card.instrid = uses.instrument_id
		  AND uses.ext_pmt_party_id = ext_payer_to_list(i)
		 );

		iby_debug_pub.Add('Inactivating the Bank Accounts for dupliacte account');
		FORALL i in 1..ext_payer_from_list.COUNT
	    UPDATE iby_pmt_instr_uses_all dup
		SET end_date = SYSDATE,
	    last_update_date = SYSDATE,
	    last_updated_by = arp_standard.profile.user_id,
	    last_update_login = arp_standard.profile.last_update_login
	    WHERE ext_pmt_party_id = 	ext_payer_from_list(i)
	    AND ext_payer_from_list(i) IS NOT NULL
	    AND ext_payer_to_list(i) IS NOT NULL
		AND dup.instrument_type = 'BANKACCOUNT'
		AND  EXISTS
		(
		   SELECT 1 FROM
		   iby_ext_bank_accounts from_account,
		   iby_ext_bank_accounts to_account,
		   iby_pmt_instr_uses_all uses
		   WHERE from_account.ext_bank_account_id = dup.instrument_id
		   AND to_account.iban_hash1 = from_account.iban_hash1
		   AND to_account.iban_hash2 = from_account.iban_hash2
		   AND to_account.ext_bank_account_id = uses.instrument_id
		   AND uses.ext_pmt_party_id = ext_payer_to_list(i)
		 );



	EXCEPTION
	  WHEN OTHERS THEN
	    arp_message.set_line( 'INSTRUMENT_MERGE');
	    RAISE;

	END INSTRUMENT_MERGE;

	/*-------------------------------------------------------------
	|
	|  PROCEDURE
	|      MERGE
	|  DESCRIPTION :
	|      Account merge procedure for the table, IBY_EXTERNAL_PAYERS_ALL
	|
	|  ******************************
	|
	|--------------------------------------------------------------*/

	PROCEDURE MERGE (
	        req_id                       NUMBER,
	        set_num                      NUMBER,
	        process_mode                 VARCHAR2) IS

	  TYPE merge_header_id_list_type IS TABLE OF
	       ra_customer_merge_headers.customer_merge_header_id%TYPE
	       INDEX BY BINARY_INTEGER;
	  merge_header_id_list merge_header_id_list_type;

	  primary_key_id_list ext_payer_id_list_type;

	  TYPE cust_account_id_list_type IS TABLE OF
	         iby_external_payers_all.cust_account_id%TYPE
	        INDEX BY BINARY_INTEGER;
	  num_col1_orig_list cust_account_id_list_type;
	  num_col1_new_list cust_account_id_list_type;

	  TYPE acct_site_use_id_list_type IS TABLE OF
	         iby_external_payers_all.acct_site_use_id%TYPE
	        INDEX BY BINARY_INTEGER;
	  num_col2_orig_list acct_site_use_id_list_type;
	  num_col2_new_list acct_site_use_id_list_type;

	  ext_payer_from_list 	ext_payer_id_list_type;
	  ext_payer_to_list 	ext_payer_id_list_type;


	  l_profile_val VARCHAR2(30);
	  CURSOR merged_records IS
	        SELECT DISTINCT customer_merge_header_id
	              ,ext_payer_id
	              ,cust_account_id
	              ,acct_site_use_id
	         FROM iby_external_payers_all yt, ra_customer_merges m
	         WHERE (
	            yt.cust_account_id = m.duplicate_id
	            OR yt.acct_site_use_id = m.duplicate_site_id
	         ) AND    m.process_flag = 'N'
	         AND    m.request_id = req_id
	         AND    m.set_number = set_num;
	  l_last_fetch BOOLEAN := FALSE;
	  l_count NUMBER;
	  l_payer_transferred BOOLEAN;
	BEGIN
	  IF process_mode='LOCK' THEN
	    NULL;
	  ELSE
	    arp_message.set_name('AR','AR_UPDATING_TABLE');
	    arp_message.set_token('TABLE_NAME','IBY_EXTERNAL_PAYERS_ALL',FALSE);
	    hz_acct_merge_util.load_set(set_num, req_id);
	    l_profile_val :=  fnd_profile.value('HZ_AUDIT_ACCT_MERGE');

	    open merged_records;
	    LOOP
	      FETCH merged_records BULK COLLECT INTO
	         merge_header_id_list
	          , primary_key_id_list
	          , num_col1_orig_list
	          , num_col2_orig_list
	          ;
	      IF merged_records%NOTFOUND THEN
	         l_last_fetch := TRUE;
	      END IF;
	      IF merge_header_id_list.COUNT = 0 and l_last_fetch then
	        exit;
	      END IF;
	      FOR I in 1..merge_header_id_list.COUNT LOOP
	         num_col1_new_list(i) := hz_acct_merge_util.getdup_account(num_col1_orig_list(i));
	         num_col2_new_list(i) := hz_acct_merge_util.getdup_site_use(num_col2_orig_list(i));
			 /*
			    For a given Account and Site Combination, there can be a single Payer.
			    Get the Payer Id for both the duplicate and Target Account
			 */
			 ext_payer_from_list(i) := get_external_payer_id(num_col1_orig_list(i),num_col2_orig_list(i));
			 ext_payer_to_list(i) := get_external_payer_id(num_col1_new_list(i),num_col2_new_list(i));
	      END LOOP;
	      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	        FORALL I in 1..merge_header_id_list.COUNT
	         INSERT INTO hz_customer_merge_log (
	           merge_log_id,
	           table_name,
	           merge_header_id,
	           primary_key_id,
	           num_col1_orig,
	           num_col1_new,
	           num_col2_orig,
	           num_col2_new,
	           action_flag,
	           request_id,
	           created_by,
	           creation_date,
	           last_update_login,
	           last_update_date,
	           last_updated_by
	      ) VALUES (         hz_customer_merge_log_s.nextval,
	         'IBY_EXTERNAL_PAYERS_ALL',
	         merge_header_id_list(i),
	         primary_key_id_list(i),
	         num_col1_orig_list(i),
	         num_col1_new_list(i),
	         num_col2_orig_list(i),
	         num_col2_new_list(i),
	         'U',
	         req_id,
	         hz_utility_pub.created_by,
	         hz_utility_pub.creation_date,
	         hz_utility_pub.last_update_login,
	         hz_utility_pub.last_update_date,
	         hz_utility_pub.last_updated_by
	      );

	    END IF;
		iby_debug_pub.Add('Transferring the  Payer Records');
		/*
		   If there is a payer at the duplicate account and if there doesnt exist any
		   payer at the target account, transfer the payer by updating the
		   account and site use with the new values
		*/
		FORALL i in 1..merge_header_id_list.COUNT
	      UPDATE IBY_EXTERNAL_PAYERS_ALL yt SET
	           cust_account_id=num_col1_new_list(i)
	          ,acct_site_use_id=num_col2_new_list(i)
	          , last_update_date=SYSDATE
	          , last_updated_by=arp_standard.profile.user_id
	          , last_update_login=arp_standard.profile.last_update_login
	      WHERE ext_payer_id=primary_key_id_list(i)
		  AND   primary_key_id_list(i) = ext_payer_from_list(i)
		  AND   ext_payer_from_list(i) is not null
	      AND   ext_payer_to_list(i) is null
	         ;
		  iby_debug_pub.Add('Performing Transaction summary Merge');
		  trx_summary_merge(req_id,set_num,process_mode);
		  iby_debug_pub.Add('Performing Transaction Extensiopns Merge');
	      transactions_ext_merge(ext_payer_from_list,ext_payer_to_list);
		  iby_debug_pub.Add('Performing Instruments Merge');
		  instrument_merge(ext_payer_from_list,ext_payer_to_list);
		  iby_debug_pub.Add('Performing Payment Methods Merge');
	      payment_methods_merge(ext_payer_from_list,ext_payer_to_list);
	      l_count := l_count + SQL%ROWCOUNT;
	      IF l_last_fetch THEN
	         EXIT;
	      END IF;
	    END LOOP;

	    arp_message.set_name('AR','AR_ROWS_UPDATED');
	    arp_message.set_token('NUM_ROWS',to_char(l_count));
	  END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	    arp_message.set_line( 'MERGE');
	    RAISE;
	END MERGE;


END IBY_MERGE;

/
