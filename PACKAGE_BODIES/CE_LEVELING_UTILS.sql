--------------------------------------------------------
--  DDL for Package Body CE_LEVELING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_LEVELING_UTILS" as
/* $Header: celutilb.pls 120.14.12010000.2 2009/05/20 12:05:21 ckansara ship $ */

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Generate_Button							|
|									|
|  DESCRIPTION								|
|	This procedure is called when the 'Generate' button 		|
| 	is pressed from the Cash Leveling Proposal confirmation page.	|
| 	In turn it submits a concurrent request that runs the		|
|	'Generate Cash Leveling Fund Transfers' concurrent program.	|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-DEC-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Generate_Button (p_as_of_date		DATE,
			p_accept_limit_error	VARCHAR2,
			p_run_id VARCHAR2) IS
  l_request_id 		NUMBER;
BEGIN
  l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                'CE', 'CECLEVEL','','',NULL,
                to_char(to_date(p_as_of_date,'DD-MM-RRRR'),
			'YYYY/MM/DD HH24:MI:SS'),
                p_accept_limit_error,
		p_run_id,
		fnd_global.local_chr(0),
		'','','','','','','','','','',
		'','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
		'','','','','','','');

END Generate_Button;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Cash_Leveling							|
|									|
|  DESCRIPTION								|
|	This procedure serves as the executable of the 			|
| 	'Generate Cash Leveling Fund Transfers' concurrent program.	|
| 	This procedure will generate a fund transfer for each 		|
|	proposed transfer in CE_PROPOSED_TRANSFERS. 			|
|									|
|  CALLED BY								|
|	'Generate Cash Leveling Fund Transfers' concurrent program	|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUN-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Cash_Leveling (errbuf			OUT NOCOPY VARCHAR2,
			retcode			OUT NOCOPY NUMBER,
			p_as_of_date		IN VARCHAR2,
			p_accept_limit_error 	IN VARCHAR2,
			p_run_id IN VARCHAR2) IS
  CURSOR C_proposed_transfers(c_run_id VARCHAR2) IS
    SELECT proposed_transfer_id,
	sub_account_id,
	conc_account_id,
	transfer_amount,
	cashpool_id
    FROM ce_proposed_transfers
    WHERE status = c_run_id;

  l_from_bank_account_id	NUMBER;
  l_to_bank_account_id		NUMBER;
  l_deal_type			VARCHAR2(3);
  l_deal_no			NUMBER;
  l_trx_number			NUMBER;
  l_offset_deal_no		NUMBER;
  l_offset_trx_number		NUMBER;
  l_effective_date_from		DATE;
  l_effective_date_to		DATE;
  l_success_flag		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_cashflows_created_flag	VARCHAR2(1);
  req_id			NUMBER;
  request_id			NUMBER;
  reqid				VARCHAR2(30);
  number_of_copies		NUMBER;
  printer			VARCHAR2(30);
  print_style			VARCHAR2(30);
  save_output_flag		VARCHAR2(30);
  save_output_bool		BOOLEAN;

BEGIN

 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

  -- Get original request id
  fnd_profile.get('CONC_REQUEST_ID', reqid);
  request_id := to_number(reqid);

  -- Generate fund transfer for each proposed transfer
  FOR p_transfer in C_proposed_transfers(p_run_id) LOOP
    IF p_transfer.transfer_amount <> 0 THEN
      SELECT nvl(effective_date_from,to_date(p_as_of_date,'YYYY/MM/DD HH24:MI:SS')),
	     nvl(effective_date_to,to_date(p_as_of_date,'YYYY/MM/DD HH24:MI:SS'))
      INTO l_effective_date_from, l_effective_date_to
      FROM ce_cashpools
      WHERE cashpool_id = p_transfer.cashpool_id;

      IF (to_date(p_as_of_date,'YYYY/MM/DD HH24:MI:SS') >= l_effective_date_from
	AND to_date(p_as_of_date,'YYYY/MM/DD HH24:MI:SS') <= l_effective_date_to) THEN

        IF p_transfer.transfer_amount > 0 THEN
	  l_from_bank_account_id := p_transfer.conc_account_id;
	  l_to_bank_account_id := p_transfer.sub_account_id;
        ELSE
	  l_from_bank_account_id := p_transfer.sub_account_id;
	  l_to_bank_account_id := p_transfer.conc_account_id;
        END IF;


        CE_LEVELING_UTILS.Generate_Fund_Transfer(l_from_bank_account_id,
					l_to_bank_account_id,
					p_transfer.cashpool_id,
					abs(p_transfer.transfer_amount),
					to_date(p_as_of_date,'YYYY/MM/DD HH24:MI:SS'),
					null,
					p_accept_limit_error,
					request_id,
					l_deal_type,
					l_deal_no,
					l_trx_number,
					l_offset_deal_no,
					l_offset_trx_number,
					l_success_flag,
					to_number(null),
					l_msg_count,
					l_cashflows_created_flag,
					'L' -- called_by_flag
     					);
      ELSE -- cash pool is not effective
        DELETE FROM ce_proposed_transfers
        WHERE proposed_transfer_id = p_transfer.proposed_transfer_id;
        commit;
      END IF;
    ELSE -- transfer amount = 0
      DELETE FROM ce_proposed_transfers
      WHERE proposed_transfer_id = p_transfer.proposed_transfer_id;
      commit;
    END IF;
  END LOOP;

  -- Purge all submitted transfers
  DELETE FROM ce_proposed_transfers
  WHERE status = p_run_id;
  commit;

  -- Launch the Cash Leveling Execution Report

  -- Get print options
  cep_standard.debug('Request Id is ' || request_id);
  IF( NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag)) THEN
    cep_standard.debug('Message: get print options failed');
  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;

    IF( FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES ('CE',
					   'CECLEXER',
					   printer,
					   print_style,
				           save_output_flag)) THEN
      cep_standard.debug('Message: get print options failed');
    END IF;

    -- Set print options
    IF (NOT FND_REQUEST.set_print_options(printer,
                                          print_style,
                                          number_of_copies,
                                          save_output_bool)) THEN
      cep_standard.debug('Set print options failed');
    END IF;
  END IF;

  -- Submit the concurrent request for the Cash Leveling Execution Report
  -- and pass in the original request_id
  req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			          'CECLEXER',
				  NULL,
				  trunc(sysdate),
			          FALSE,
				  request_id);

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION - OTHERS: Cash_Leveling');
	RAISE;
END Cash_Leveling;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Generate_Fund_Transfer						|
|									|
|  DESCRIPTION								|
|	This shared procedure will be used by both ZBA and 		|
|	Cash Leveling to generate a fund transfer by calling		|
|	Treasury's deal creation APIs 					|
|									|
|  CALLED BY								|
|	CE_LEVELING_UTILS.Cash_Leveling					|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUN-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Generate_Fund_Transfer (X_from_bank_account_id	NUMBER,
			 	X_to_bank_account_id		NUMBER,
				X_cashpool_id			NUMBER,
				X_amount			NUMBER,
				X_transfer_date			DATE,
				X_settlement_authorized		VARCHAR2,
				X_accept_limit_error		VARCHAR2,
				X_request_id			NUMBER,
				X_deal_type	OUT NOCOPY	VARCHAR2,
				X_deal_no	OUT NOCOPY	NUMBER,
				X_trx_number	OUT NOCOPY	NUMBER,
				X_offset_deal_no OUT NOCOPY	NUMBER,
				X_offset_trx_number OUT NOCOPY	NUMBER,
				X_success_flag 	OUT NOCOPY	VARCHAR2,
				X_statement_line_id		NUMBER,
				X_msg_count	OUT NOCOPY 	NUMBER,
				X_cashflows_created_flag OUT NOCOPY VARCHAR2,
				X_called_by_flag		VARCHAR2) IS

  l_from_le_id			NUMBER(15);
  l_to_le_id			NUMBER(15);
  l_conc_account_id		NUMBER(15);
  l_company_account_id		NUMBER(15);
  l_party_account_id		NUMBER(15);
  l_currency_code		VARCHAR2(15);
  l_action_code			VARCHAR2(3);
  l_deal_type			VARCHAR2(3);
  l_deal_no			NUMBER;
  l_trx_number			NUMBER;
  l_offset_deal_no		NUMBER;
  l_offset_trx_number		NUMBER;
  l_success_flag		VARCHAR2(1);
  l_bat_profile			VARCHAR2(30);
  l_payment_details_from	VARCHAR2(4);
  l_count			NUMBER;
  l_trx_subtype			VARCHAR2(30);
  l_result			VARCHAR2(7);
  l_msg_count			NUMBER;
  l_authorization_bat CE_CASHPOOLS.authorization_bat%TYPE;
  l_trx_type CE_STATEMENT_LINES.trx_type%TYPE;
  l_from_bank_account_id CE_BANK_ACCOUNTS.bank_Account_id%TYPE;
  l_to_bank_Account_id CE_BANK_ACCOUNTS.bank_account_id%TYPE;

BEGIN

  l_bat_profile :=  FND_PROFILE.VALUE('CE_BANK_ACCOUNT_TRANSFERS');

  IF (l_bat_profile = 'XTR') THEN
	    SELECT authorization_bat
	    INTO l_authorization_bat
	    FROM ce_cashpools
	    WHERE cashpool_id = X_cashpool_id;
	  IF (l_authorization_bat IS NOT NULL) THEN
	      -- cashpool was setup for CE
	      CE_ZBA_DEAL_INF_PKG.insert_row (
               	         CE_ZBA_DEAL_GENERATION.csh_statement_header_id,
                       	 CE_ZBA_DEAL_GENERATION.csl_statement_line_id,
			'CE_INVALID_CASHPOOL_FOR_XTR');
	      x_success_flag := 'FAIL';
 	     RETURN;
	  END IF;
  END IF;

  -- Get company account, party account, and action code
  -- Company account = Concentration account
  SELECT decode(nvl(single_conc_account_flag,'Y'),'Y',conc_account_id,
	  	fund_conc_account_id),
	currency_code
  INTO l_conc_account_id,
	l_currency_code
  FROM ce_cashpools
  WHERE cashpool_id = X_cashpool_id;

--bug5346601
    l_from_bank_account_id := X_from_Bank_Account_id;
    l_to_bank_account_id := X_to_Bank_Account_id;
--bug5346601

--bug5335122
IF X_from_bank_account_id = l_conc_account_id THEN
    l_company_account_id := X_from_bank_account_id;
    l_party_account_id := X_to_bank_account_id;
    l_action_code := 'PAY';
ELSE
    l_company_account_id := X_to_bank_account_id;
    l_party_account_id := X_from_bank_account_id;
    l_action_code := 'REC';
END IF;
--bug5335122

IF X_called_by_flag = 'Z' THEN
  SELECT trx_type INTO l_trx_type
  FROM ce_statement_lines
  WHERE statement_line_id=X_statement_line_id;

  -- Bug5122576. X_from_bank_account_id is the statement line's bank
  -- account id and X_to_bank_account_id is the offset
  -- bank account. The real from and to bank accounts
  -- are determined here and stored in the l_ variables.
  -- This is only for ZBA. For CL the accounts are determined above.

 IF X_from_bank_account_id = l_conc_account_id THEN
    IF l_trx_type = 'SWEEP_OUT' THEN
       l_company_account_id := X_from_bank_account_id;
       l_party_account_id := X_to_bank_account_id;
       l_action_code := 'PAY';
       l_from_bank_account_id := X_from_Bank_Account_id;
       l_to_bank_account_id := X_to_Bank_Account_id;
    ELSE
       l_company_account_id := X_to_bank_account_id;
       l_party_account_id := X_from_bank_account_id;
       l_action_code := 'REC';
       l_from_bank_account_id := X_to_Bank_Account_id;
       l_to_bank_account_id := X_from_Bank_Account_id;
    END IF;
  ELSE
     IF  l_trx_type = 'SWEEP_OUT' THEN
       l_from_bank_account_id := X_from_Bank_Account_id;
       l_to_bank_account_id := X_to_Bank_Account_id;
     ELSE
       l_from_bank_account_id := X_to_Bank_Account_id;
       l_to_bank_account_id := X_from_Bank_Account_id;
     END IF;
 END IF;
END IF;
  IF l_bat_profile = 'CE' THEN
    SELECT count(1)
    INTO l_count
    FROM ce_cashpool_sub_accts
    WHERE cashpool_id = X_cashpool_id
    AND account_id = X_from_bank_account_id
    AND type in ('CONC','INV','FUND');

    IF l_count = 0 THEN
      l_payment_details_from := 'SRC';
    ELSE
      l_payment_details_from := 'DEST';
    END IF;

    -- Call BAT API to create the transfer
    CE_BAT_API.create_transfer(
			X_called_by_flag,
   			X_from_bank_account_id,
   			X_to_bank_account_id,
  			X_statement_line_id,
   			X_cashpool_id,
   			X_amount,
			l_payment_details_from,
   			X_transfer_date,
			X_cashflows_created_flag,
   			l_result,
			l_msg_count,
			l_trx_number
			);

    SELECT tst.transaction_sub_type_name
    INTO l_trx_subtype
    FROM ce_trxns_subtype_codes tst, ce_cashpools cp
    WHERE cp.trxn_subtype_code_id = tst.trxn_subtype_code_id(+)
    AND cp.cashpool_id = X_cashpool_id;

    IF l_result = 'SUCCESS' THEN
      l_success_flag := 'Y';
    ELSE
      l_success_flag := 'N';
    END IF;
    IF l_msg_count = 0 THEN
      l_count := 1;
    ELSE
      l_count := l_msg_count;
    END IF;

  ELSE -- bat_profile = 'XTR'
    SELECT account_owner_org_id
    INTO l_from_le_id
    FROM ce_bank_accounts
    WHERE bank_account_id = X_from_bank_account_id;

    SELECT account_owner_org_id
    INTO l_to_le_id
    FROM ce_bank_accounts
    WHERE bank_account_id = X_to_bank_account_id;

    -- Call the relevant XTR wrapper API based on the deal type
    IF l_from_le_id = l_to_le_id THEN -- Inter-Account Transfer (IAC)
      l_deal_type := 'IAC';
      XTR_WRAPPER_API_P.IAC_GENERATION(
				X_cashpool_id,
				l_from_bank_account_id,
				l_to_bank_account_id,
				X_transfer_date,
				X_amount,
				l_trx_number,
				l_success_flag,
				X_called_by_flag);
    ELSE -- Intercompany Funding (IG)
      l_deal_type := 'IG';
      XTR_WRAPPER_API_P.IG_GENERATION(
			        X_cashpool_id,
				l_company_account_id,
      				l_party_account_id,
				l_currency_code,
				X_transfer_date,
				X_amount,
      				l_action_code,
				X_accept_limit_error,
				l_deal_no,
				l_trx_number,
				l_offset_deal_no,
				l_offset_trx_number,
				l_success_flag,
				X_called_by_flag);

    END IF;

    l_count := 1;
  END IF; -- end bat_profile check

  -- Populate CE_LEVELING_MESSAGES
  IF X_called_by_flag = 'L' THEN
    FOR i IN 1..l_count LOOP
      INSERT INTO ce_leveling_messages(
			leveling_message_id,
			request_id,
			sub_account_id,
			conc_account_id,
			transfer_amount,
			message_name,
			message_text,
			deal_type,
			deal_no,
			trx_number,
			offset_deal_no,
			offset_trx_number,
			success_flag,
			cashpool_id,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login
		) VALUES (CE_LEVELING_MESSAGES_S.nextval,
			nvl(X_request_id,-1),
			l_party_account_id,
			l_company_account_id,
			X_amount,
			null,
              		FND_MSG_PUB.get(1, FND_API.G_FALSE),
			l_deal_type,
			l_deal_no,
			l_trx_number,
			l_offset_deal_no,
			l_offset_trx_number,
			l_success_flag,
			X_cashpool_id,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1));
      FND_MSG_PUB.delete_msg(1);
      COMMIT;
    END LOOP;
  ELSE
    X_deal_type := l_deal_type;
    X_deal_no := l_deal_no;
    X_trx_number := l_trx_number;
    X_offset_deal_no := l_offset_deal_no;
    X_offset_trx_number := l_offset_trx_number;
    X_success_flag := l_success_flag;
    X_msg_count := l_msg_count;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION - OTHERS: Generate_Fund_Transfer');
	RAISE;
END Generate_Fund_Transfer;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Populate_Nested_Accounts					|
|									|
|  DESCRIPTION								|
|	This procedure populates the sub-accounts of nested cash pools	|
|	as sub-accounts of the parent cash pool as well			|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUN-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Populate_Nested_Accounts(p_parent_cashpool_id NUMBER,
				p_cashpool_id NUMBER) IS
BEGIN

UPDATE	ce_cashpools
SET	parent_cashpool_id = p_parent_cashpool_id
WHERE	cashpool_id = p_cashpool_id;

INSERT INTO ce_cashpool_sub_accts(
			cashpool_sub_acct_id,
			cashpool_id,
			type,
			account_id,
			party_code,
			legal_entity_id,
			nested_parent_pool_id,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		SELECT 	CE_CASHPOOL_SUB_ACCTS_S.nextval,
			p_parent_cashpool_id,
			'NEST',
			sub.account_id,
			sub.party_code,
			sub.legal_entity_id,
			sub.cashpool_id,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1)
		FROM 	ce_cashpool_sub_accts sub
		WHERE	sub.cashpool_id = p_cashpool_id
		AND	sub.type <> 'POOL';

END Populate_Nested_Accounts;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Delete_Sub_Accounts						|
|									|
|  DESCRIPTION								|
|	This procedure deletes the sub-accounts of a cash pool		|
|	prior to re-populating						|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	14-SEP-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Delete_Sub_Accounts(p_cashpool_id NUMBER) IS
BEGIN

UPDATE 	ce_cashpools
SET	parent_cashpool_id = null
WHERE	parent_cashpool_id = p_cashpool_id;

DELETE FROM ce_cashpool_sub_accts
WHERE cashpool_id = p_cashpool_id;

END Delete_Sub_Accounts;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Update_Parent_Nested_Accounts					|
|									|
|  DESCRIPTION								|
|	This procedure updates the parent cash pool's nested 		|
|	sub accounts of the current child cash pool to reflect 		|
|	any changes to the current child cash pool's sub accounts	|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	11-JAN-2005	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Update_Parent_Nested_Accounts(p_cashpool_id NUMBER,
				p_parent_cashpool_id NUMBER) IS
BEGIN

DELETE FROM ce_cashpool_sub_accts
WHERE cashpool_id = p_parent_cashpool_id
AND nested_parent_pool_id = p_cashpool_id;

INSERT INTO ce_cashpool_sub_accts(
			cashpool_sub_acct_id,
			cashpool_id,
			type,
			account_id,
			party_code,
			legal_entity_id,
			nested_parent_pool_id,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		SELECT 	CE_CASHPOOL_SUB_ACCTS_S.nextval,
			p_parent_cashpool_id,
			'NEST',
			sub.account_id,
			sub.party_code,
			sub.legal_entity_id,
			sub.cashpool_id,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1)
		FROM 	ce_cashpool_sub_accts sub
		WHERE	sub.cashpool_id = p_cashpool_id
		AND	sub.type <> 'POOL';

END Update_Parent_Nested_Accounts;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Populate_Target_Balances					|
|									|
|  DESCRIPTION								|
|	This procedure populates target balances for a particular	|
|	sub-account of a cash pool					|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUN-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Populate_Target_Balances(p_bank_account_id	NUMBER,
				p_min_target_balance	NUMBER,
				p_max_target_balance 	NUMBER,
				p_min_payment_amt	NUMBER,
				p_min_receipt_amt	NUMBER,
				p_round_factor		VARCHAR2,
				p_round_rule		VARCHAR2) IS
BEGIN

UPDATE 	ce_bank_accounts
SET	min_target_balance = nvl(p_min_target_balance,to_number(null)),
	max_target_balance = nvl(p_max_target_balance,to_number(null)),
	cashpool_min_payment_amt = nvl(p_min_payment_amt,0),
	cashpool_min_receipt_amt = nvl(p_min_receipt_amt,0),
	cashpool_round_factor = to_number(nvl(p_round_factor,'0')),
	cashpool_round_rule = nvl(p_round_rule,'R')
WHERE	bank_account_id = p_bank_account_id;

END Populate_Target_Balances;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Populate_BAT_Payment_Details					|
|									|
|  DESCRIPTION								|
|	This procedure populates BAT payment details for a particular	|
|	sub-account of a cash pool					|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUL-2005	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Populate_BAT_Payment_Details(p_bank_account_id	NUMBER,
				p_payment_method_code		VARCHAR2,
				p_bank_charge_bearer_code	VARCHAR2,
				p_payment_reason_code		VARCHAR2,
				p_payment_reason_comments	VARCHAR2,
				p_remittance_message1		VARCHAR2,
				p_remittance_message2		VARCHAR2,
				p_remittance_message3		VARCHAR2) IS
BEGIN

UPDATE 	ce_bank_accounts
SET	pool_payment_method_code = p_payment_method_code,
	pool_bank_charge_bearer_code = p_bank_charge_bearer_code,
	pool_payment_reason_code = p_payment_reason_code,
	pool_payment_reason_comments = p_payment_reason_comments,
	pool_remittance_message1 = p_remittance_message1,
	pool_remittance_message2 = p_remittance_message2,
	pool_remittance_message3 = p_remittance_message3
WHERE	bank_account_id = p_bank_account_id;

END Populate_BAT_Payment_Details;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Update_Bank_Account_Id						|
|									|
|  DESCRIPTION								|
|	This procedure updates the bank account id in ce_cashpools	|
|	and ce_cashpool_sub_accts when a bank account that is also a	|
|	cash pool sub-account is "linked" or "unlinked" with AP		|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	15-JUN-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Update_Bank_Account_Id(p_old_bank_account_id	NUMBER,
				p_new_bank_account_id	NUMBER) IS
BEGIN

UPDATE 	ce_cashpool_sub_accts
SET 	account_id = p_new_bank_account_id
WHERE 	account_id = p_old_bank_account_id
AND 	type <> 'POOL';

UPDATE 	ce_cashpool_sub_accts
SET 	conc_account_id = p_new_bank_account_id
WHERE 	conc_account_id = p_old_bank_account_id;

UPDATE 	ce_cashpool_sub_accts
SET 	inv_conc_account_id = p_new_bank_account_id
WHERE 	inv_conc_account_id = p_old_bank_account_id;

UPDATE 	ce_cashpool_sub_accts
SET 	fund_conc_account_id = p_new_bank_account_id
WHERE 	fund_conc_account_id = p_old_bank_account_id;

UPDATE 	ce_cashpools
SET 	conc_account_id = p_new_bank_account_id
WHERE 	conc_account_id = p_old_bank_account_id;

UPDATE 	ce_cashpools
SET 	inv_conc_account_id = p_new_bank_account_id
WHERE 	inv_conc_account_id = p_old_bank_account_id;

UPDATE 	ce_cashpools
SET 	fund_conc_account_id = p_new_bank_account_id
WHERE 	fund_conc_account_id = p_old_bank_account_id;

UPDATE 	ce_cp_worksheet_lines
SET 	bank_account_id = p_new_bank_account_id
WHERE 	bank_account_id = p_old_bank_account_id;

UPDATE 	ce_forecast_rows
SET	bank_account_id = p_new_bank_account_id
WHERE 	bank_account_id = p_old_bank_account_id;

END Update_Bank_Account_Id;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Match_Cashpool							|
|									|
|  DESCRIPTION								|
|	This procedure finds the matching cash pool containing	 	|
|	a given pair of bank accounts					|
|									|
|  CALLED BY								|
|	CE_ZBA_DEAL_GENERATION.zba_generation				|
|  REQUIRES								|
|									|
|  HISTORY								|
|	10-DEC-2004	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
FUNCTION Match_Cashpool(p_header_bank_account_id	IN NUMBER,
                    	p_offset_bank_account_num	IN VARCHAR2,
                    	p_trx_type 			IN VARCHAR2,
                    	p_trx_date			IN DATE,
                    	p_offset_bank_account_id 	OUT NOCOPY NUMBER,
                    	p_cashpool_id            	OUT NOCOPY NUMBER)
		RETURN BOOLEAN IS

  l_cashpool_id 		NUMBER(15);
  l_type			VARCHAR2(4);
  l_offset_type			VARCHAR2(4);
  l_offset_bank_account_id	NUMBER(15);
  l_error_flag			VARCHAR2(1);

BEGIN

  l_error_flag := 'N';

	--   Bug 8489586 Start
	SELECT cps. account_id
			INTO l_offset_bank_account_id
			FROM ce_bank_accounts  cba,ce_cashpools cp,CE_CASHPOOL_SUB_ACCTS cps
			WHERE cba.bank_account_id = cp.conc_account_id AND cp.cashpool_id = cps.cashpool_id AND cps.account_id IN
			  (SELECT bank_account_id FROM ce_bank_accounts WHERE bank_account_num = p_offset_bank_account_num);
	--   Bug 8489586 End

  IF p_trx_type = 'SWEEP_IN' THEN -- Sweep in
    SELECT cashpool_id, type
    INTO l_cashpool_id, l_type
    FROM ce_cashpool_sub_accts
    WHERE type in ('ACCT','CONC','INV')
    AND account_id = p_header_bank_account_id
    AND cashpool_id in
	(select cashpool_id
	 from ce_cashpools
	 where sweeps_flag = 'Y'
	 and nvl(effective_date_to,p_trx_date) >= p_trx_date);

    SELECT type
    INTO l_offset_type
    FROM ce_cashpool_sub_accts
    WHERE cashpool_id = l_cashpool_id
    AND account_id = l_offset_bank_account_id
    AND type in ('ACCT','CONC','FUND');

    -- If neither account is a valid concentration account
    -- or if both accounts are concentration accounts, raise error
    IF ((l_type = 'ACCT' AND l_offset_type = 'ACCT')
	OR (l_type = 'INV' AND l_offset_type = 'FUND')) THEN
      l_error_flag := 'Y';
    END IF;

  ELSE -- Sweep out
    SELECT cashpool_id, type
    INTO l_cashpool_id, l_type
    FROM ce_cashpool_sub_accts
    WHERE type in ('ACCT','CONC','FUND')
    AND account_id = p_header_bank_account_id
    AND cashpool_id in
	(select cashpool_id
	 from ce_cashpools
	 where sweeps_flag = 'Y'
	 and nvl(effective_date_to,p_trx_date) >= p_trx_date);

    SELECT type
    INTO l_offset_type
    FROM ce_cashpool_sub_accts
    WHERE cashpool_id = l_cashpool_id
    AND account_id = l_offset_bank_account_id
    AND type in ('ACCT','CONC','INV');

    -- If neither account is a valid concentration account
    -- or if both accounts are concentration accounts, raise error
    IF ((l_type = 'ACCT' AND l_offset_type = 'ACCT')
	OR (l_type = 'FUND' AND l_offset_type = 'INV')) THEN
      l_error_flag := 'Y';
    END IF;

  END IF;

  p_offset_bank_account_id := l_offset_bank_account_id;
  p_cashpool_id := l_cashpool_id;

  IF l_error_flag = 'Y' THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
	RETURN FALSE;
END Match_Cashpool;

END CE_LEVELING_UTILS;

/
