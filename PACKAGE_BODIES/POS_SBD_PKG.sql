--------------------------------------------------------
--  DDL for Package Body POS_SBD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SBD_PKG" as
/*$Header: POSSBDB.pls 120.17.12010000.2 2013/03/05 11:57:29 pneralla ship $ */


g_log_module_name varchar2(30) := 'POS_SBD_PKG';

PROCEDURE buyer_remove_account (
  p_account_request_id	   IN NUMBER
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
	l_step NUMBER;
BEGIN

	l_step := 0;
	x_status := 'E';

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin buyer_remove_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);
	END IF;

  	POS_SBD_PKG.remove_account
  	(
		p_account_request_id,
   		p_object_version_number,
   		x_status,
   		x_exception_msg
  	);

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End buyer_remove_account ');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20011, 'Failure at step ' || l_step || Sqlerrm, true);
END buyer_remove_account;


PROCEDURE supplier_remove_account (
  p_account_request_id	   IN NUMBER
, p_object_version_number IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
 l_step NUMBER;
BEGIN
  	l_step := 0;
  	x_status := 'E';

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin supplier_remove_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);
	END IF;

  	POS_SBD_PKG.remove_account
  	(
   		p_account_request_id,
   		p_object_version_number,
   		x_status,
   		x_exception_msg
  	);

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End supplier_remove_account ');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20012, 'Failure at step ' || l_step || Sqlerrm, true);
END supplier_remove_account;

PROCEDURE remove_account (
  p_account_request_id	   IN NUMBER
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
 	l_step NUMBER;
	l_status IBY_TEMP_EXT_BANK_ACCTS.status%TYPE;
 	l_temp_ext_bank_account_id NUMBER;

 	-- Account Request details
 	CURSOR  l_acct_status_cur IS
        SELECT iby.status, iby.temp_ext_bank_acct_id, req.object_version_number
        FROM   iby_temp_ext_bank_accts iby, pos_acnt_gen_req req
        WHERE  req.account_request_id = p_account_request_id
        AND iby.temp_ext_bank_acct_id = req.temp_ext_bank_acct_id for update nowait;

 	-- Assignments Impacted
 	CURSOR  l_assign_req_cur IS
        SELECT req.assignment_request_id, summ.assignment_id, summ.priority,
	       req.request_type, req.mapping_id, req.party_site_id,
	       req.address_request_id, req.object_version_number
        FROM   pos_acnt_addr_req req, pos_acnt_addr_summ_req summ
        where  req.assignment_request_id = summ.assignment_request_id
        AND    summ.account_request_id = p_account_request_id for update nowait;

 	l_assign_req_rec l_assign_req_cur%ROWTYPE;

 	l_assignment_request_id NUMBER;
 	l_assignment_id NUMBER;
	l_priority NUMBER;
 	l_needToDelete boolean;
 	l_object_version_number number;

 	-- Assignment Details
 	CURSOR  l_assign_req_detail_below_cur IS
        SELECT assignment_id, priority, start_date, end_date,
	ext_bank_account_id, account_request_id, assignment_status
        FROM   pos_acnt_addr_summ_req
        where  assignment_request_id = l_assignment_request_id
        and    priority > l_priority for update nowait;
 	l_assign_req_det_below_rec l_assign_req_detail_below_cur%ROWTYPE;

 	CURSOR  l_assign_req_detail_above_cur IS
        SELECT assignment_id, priority
        FROM   pos_acnt_addr_summ_req
        where  assignment_request_id = l_assignment_request_id
        and    priority < l_priority;
 	l_assign_req_detail_above_rec l_assign_req_detail_above_cur%ROWTYPE;

	CURSOR l_need_to_del_cur is
	select summ.assignment_id from pos_acnt_addr_summ_req summ
	where assignment_request_id = l_assignment_request_id
	and assignment_status = 'CURRENT'
	and not exists(select 1 from pos_acnt_addr_summ_req
		       where assignment_request_id = l_assignment_request_id
		       and assignment_status <> 'CURRENT');
	l_need_to_del_rec l_need_to_del_cur%ROWTYPE;
BEGIN

  	l_step := 0;
  	x_status := 'E';

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin remove_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);
	END IF;

	l_step := 1;
  	open l_acct_status_cur;
  	fetch l_acct_status_cur into l_status, l_temp_ext_bank_account_id, l_object_version_number;
  	-- Wrong Acount ID Issue: Verify that the account request is valid
  	if l_acct_status_cur%NOTFOUND then
  		close l_acct_status_cur;
		x_exception_msg := 'The Bank account does not exist.';
		raise_application_error(-20013, x_exception_msg, TRUE);
	else
		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_status ' || l_status);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_temp_ext_bank_account_id ' || l_temp_ext_bank_account_id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_object_version_number ' || l_object_version_number);
		END IF;

  	end if;

	close l_acct_status_cur;

	l_step := 2;

  	-- Concurrency Issue: Verify no one else has updated the account
  	if l_object_version_number <> p_object_version_number then
		x_exception_msg := 'The bank account has been updated.';
		raise_application_error(-20014, x_exception_msg, TRUE);
  	end if;

  	l_step := 3;

  	-- Verify that its a NEW request
  	if l_status <> 'NEW' then
		x_exception_msg := 'The bank account cannot be deleted. Account Status is ' || l_status;
  		raise_application_error(-20015, x_exception_msg , TRUE);
  	end if;

	-- Delete the row in the IBY temp table
  	l_step := 4;

	POS_SBD_IBY_PKG.remove_iby_temp_account
	(
	  p_iby_temp_ext_bank_account_id => l_temp_ext_bank_account_id
	, x_status        => x_status
	, x_exception_msg => x_exception_msg
	);

  	-- Update the priorities in POS_ACNT_ADDR_SUMM_REQ
  	-- Delete the row in the POS_ACNT_ADDR_SUMM_REQ
  	l_step := 5;

  	for l_assign_req_rec in l_assign_req_cur loop

		l_step := 6;

		l_assignment_request_id := l_assign_req_rec.assignment_request_id;
  		l_assignment_id := l_assign_req_rec.assignment_id;
  		l_priority := l_assign_req_rec.priority;
		l_needToDelete := true;

 		for l_assign_req_det_below_rec in l_assign_req_detail_below_cur loop
			l_step := 7;

			-- Update the priority in POS_ACNT_ADDR_SUMM_REQ
			POS_SBD_PKG.supplier_update_assignment(
			  p_assignment_id          => l_assign_req_det_below_rec.assignment_id
			, p_assignment_request_id  => l_assign_req_rec.assignment_request_id
			, p_object_version_number  => l_assign_req_rec.object_version_number
			, p_account_request_id	   => l_assign_req_det_below_rec.account_request_id
			, p_ext_bank_account_id    => l_assign_req_det_below_rec.ext_bank_account_id
			, p_request_type           => l_assign_req_rec.request_type
			, p_mapping_id             => l_assign_req_rec.mapping_id
			, p_party_site_id          => l_assign_req_rec.party_site_id
			, p_address_request_id     => l_assign_req_rec.address_request_id
			, p_priority               => l_assign_req_det_below_rec.priority - 1
			, p_start_date             => l_assign_req_det_below_rec.start_date
			, p_end_date               => l_assign_req_det_below_rec.end_date
			, x_status        	   => x_status
			, x_exception_msg 	   => x_exception_msg
			);

			l_needToDelete := false;
		end loop;

		l_step := 8;
		-- Delete the row in POS_ACNT_ADDR_SUMM_REQ
		l_assignment_id := l_assign_req_rec.assignment_id;

		POS_SBD_TBL_PKG.del_row_pos_acnt_summ_req (
	  	  p_assignment_id => l_assignment_id
		, x_status        => x_status
		, x_exception_msg => x_exception_msg
		);

		l_step := 9;
		-- Delete the row in POS_ACNT_ADDR_REQ if needed
		if l_needToDelete = true then

			-- Check if there are any other rows left.
			l_step := 10;
			open l_assign_req_detail_above_cur;
			fetch l_assign_req_detail_above_cur into l_assign_req_detail_above_rec;
			if l_assign_req_detail_above_cur%NOTFOUND then
				l_step := 11;
				POS_SBD_TBL_PKG.del_row_pos_acnt_addr_req (
				  p_assignment_request_id => l_assignment_request_id
				, x_status        => x_status
				, x_exception_msg => x_exception_msg
				);
			end if;
			close l_assign_req_detail_above_cur;
		end if;

		l_needToDelete := false;
		for l_need_to_del_rec in l_need_to_del_cur loop
			l_assignment_id := l_need_to_del_rec.assignment_id;
			POS_SBD_TBL_PKG.del_row_pos_acnt_summ_req (
                	  p_assignment_id => l_assignment_id
                	, x_status        => x_status
               		, x_exception_msg => x_exception_msg
                	);
			l_needToDelete := true;
		end loop;

		if l_needToDelete = true then
	        	POS_SBD_TBL_PKG.del_row_pos_acnt_addr_req (
                                  p_assignment_request_id => l_assignment_request_id
                                , x_status        => x_status
                                , x_exception_msg => x_exception_msg
                                );
		end if;
  	end loop;

  	l_step := 10;

  	POS_SBD_TBL_PKG.del_row_pos_acnt_gen_req (
		  p_account_request_id  => p_account_request_id
		, x_status        => x_status
		, x_exception_msg => x_exception_msg
		);

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End remove_account ');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20016, 'Failure at step ' || l_step || Sqlerrm, true);
END remove_account;

PROCEDURE supplier_create_account (
  p_mapping_id in NUMBER
, p_request_type in varchar2
, p_address_request_id in number
, p_party_site_id in number
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_SUPPLIER in VARCHAR2
, x_account_request_id	  out nocopy NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

 	l_step NUMBER;
 	l_temp_ext_bank_account_id number;

 	l_party_id HZ_PARTIES.party_id%TYPE;

 	CURSOR l_dup_account_req_cur is
	select account_request_id from pos_acnt_gen_req req, iby_temp_ext_bank_accts iby
        WHERE iby.temp_ext_bank_acct_id = req.temp_ext_bank_acct_id
        AND req.mapping_id = p_mapping_id
	AND ( (iby.bank_id = p_bank_id and p_bank_id is not null and iby.bank_id is not null) OR
	      (iby.bank_number = p_bank_number and p_bank_number is not null and iby.bank_number is not null)
	    )
	AND ( (iby.branch_id = p_branch_id and p_branch_id is not null and iby.branch_id is not null) OR
	      (iby.branch_number = p_branch_number and p_branch_number is not null
	       and iby.branch_number is not null)
	    )
	AND (iby.bank_account_num = p_bank_account_number OR iby.bank_account_name = p_bank_account_name)
	AND iby.currency_code = p_currency_code
	AND iby.country_code = p_country_code;

 	l_dup_account_request_id POS_ACNT_GEN_REQ.account_request_id%TYPE;

 	CURSOR l_party_id_cur is
	select party_id, vendor_id from pos_supplier_mappings
	where mapping_id = p_mapping_id;
	l_vendor_id po_vendors.vendor_id%TYPE;

        l_itemtype    wf_items.item_type%TYPE;
        l_itemkey     wf_items.item_key%TYPE;

BEGIN
  	l_step := 0;
  	x_status := 'E';
   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin supplier_create_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_mapping_id ' || p_mapping_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_request_type ' || p_request_type);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_address_request_id ' || p_address_request_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_site_id ' || p_party_site_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_id ' || p_bank_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_id ' || p_branch_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_name ' || p_bank_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_name ' || p_branch_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_number ' || p_bank_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_number ' || p_branch_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_number ' || p_bank_account_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_name ' || p_bank_account_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_currency_code ' || p_currency_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_country_code ' || p_country_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_iban ' || p_iban);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_check_digits ' || p_check_digits);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
	END IF;

  	-- Check if there exists a similar account request.
  	open l_dup_account_req_cur;
  	fetch l_dup_account_req_cur into l_dup_account_request_id;
  	if l_dup_account_req_cur%FOUND then
 		x_exception_msg := 'Similar Bank Account Request already exists';
		raise_application_error(-20017, 'Similar Bank Account Request already exists', true);
  	end if;
  	close l_dup_account_req_cur;

	l_step := 1;
	-- Find the party id for the mapping id.

  	open l_party_id_cur;
  	fetch l_party_id_cur into l_party_id, l_vendor_id;
  	if l_party_id_cur%NOTFOUND then
  		l_party_id := null;
  	end if;
  	close l_party_id_cur;

  	l_step := 2;

	-- Create a row in IBY_TEMP_EXT_BANK_ACCTS
  	POS_SBD_IBY_PKG.create_iby_temp_account (
  	  p_party_id => l_party_id
  	, p_status => 'NEW'
  	, p_owner_primary_flag => 'Y'
  	, p_payment_factor_flag => 'N'
  	, p_BANK_ID => p_bank_id
  	, p_BANK_NAME => p_bank_name
  	, p_BANK_NAME_ALT => p_bank_name_alt
  	, p_BANK_NUMBER => p_bank_number
  	, p_BANK_INSTITUTION => p_bank_institution
  	, p_BANK_ADDRESS1 => p_bank_address1
  	, p_BANK_ADDRESS2 => p_bank_address2
  	, p_BANK_ADDRESS3 => p_bank_address3
  	, p_BANK_ADDRESS4 => p_bank_address4
  	, p_BANK_CITY => p_bank_city
  	, p_BANK_COUNTY => p_bank_county
  	, p_BANK_STATE => p_bank_state
  	, p_BANK_ZIP => p_bank_zip
 	, p_BANK_PROVINCE => p_bank_province
  	, p_BANK_COUNTRY => p_country_code
  	, p_BRANCH_ID => p_branch_id
  	, p_BRANCH_NAME => p_branch_name
  	, p_BRANCH_NAME_ALT => p_branch_name_alt
  	, p_BRANCH_NUMBER => p_branch_number
  	, p_BRANCH_TYPE => p_branch_type
  	, p_RFC_IDENTIFIER => p_rfc_identifier
  	, p_BIC => p_bic
  	, p_BRANCH_ADDRESS1 => p_branch_address1
  	, p_BRANCH_ADDRESS2 => p_branch_address2
  	, p_BRANCH_ADDRESS3 => p_branch_address3
  	, p_BRANCH_ADDRESS4 => p_branch_address4
  	, p_BRANCH_CITY => p_branch_city
  	, p_BRANCH_COUNTY => p_branch_county
  	, p_BRANCH_STATE => p_branch_state
 	, p_BRANCH_ZIP => p_branch_zip
  	, p_BRANCH_PROVINCE => p_branch_province
  	, p_BRANCH_COUNTRY => p_country_code
  	, p_EXT_BANK_ACCOUNT_ID => p_ext_bank_account_id
  	, p_bank_account_number => p_bank_account_number
  	, p_bank_account_name =>  p_bank_account_name
  	, p_bank_account_name_alt => p_bank_account_name_alt
  	, p_check_digits =>  p_check_digits
  	, p_iban => p_iban
  	, p_currency_code => p_currency_code
  	, p_country_code => p_country_code
  	, p_FOREIGN_PAYMENT_USE_FLAG => p_FOREIGN_PAYMENT_USE_FLAG
  	, p_bank_account_type => p_bank_account_type
  	, p_account_description => p_account_description
  	, p_end_date => p_end_date
  	, p_start_date => nvl(p_start_date, sysdate)
  	, p_agency_location_code => p_agency_location_code
  	, p_account_suffix => p_account_suffix
  	, p_EXCHANGE_RATE_AGREEMENT_NUM => p_EXCHANGE_RATE_AGREEMENT_NUM
  	, P_EXCHANGE_RATE_AGREEMENT_TYPE => P_EXCHANGE_RATE_AGREEMENT_TYPE
  	, p_EXCHANGE_RATE => p_EXCHANGE_RATE
  	, p_NOTES => p_NOTES_FROM_SUPPLIER
  	, p_NOTE_ALT => null -- Note to Buyer
  	, x_temp_ext_bank_account_id => l_temp_ext_bank_account_id
  	, x_status        => x_status
  	, x_exception_msg => x_exception_msg
  	);

  	l_step := 3;

  	-- Create a row in POS_ACNT_GEN_REQ
  	POS_SBD_TBL_PKG.insert_row_pos_acnt_gen_req (
  	  p_mapping_id => p_mapping_id
  	, p_temp_ext_bank_account_id => l_temp_ext_bank_account_id
  	, p_ext_bank_account_id => p_ext_bank_account_id
  	, x_account_request_id => x_account_request_id
  	, x_status        => x_status
  	, x_exception_msg => x_exception_msg
  	);

  	l_step := 4;

	-- Assign the account to the supplier.
  	POS_SBD_PKG.supplier_update_assignment(
	  p_assignment_id          => null
	, p_assignment_request_id  => null
	, p_object_version_number  => null
	, p_account_request_id	   => x_account_request_id
	, p_ext_bank_account_id    => p_ext_bank_account_id
	, p_request_type           => p_request_type
	, p_mapping_id             => p_mapping_id
	, p_party_site_id          => p_party_site_id
	, p_address_request_id     => p_address_request_id
	, p_priority               => null
	, p_start_date             => sysdate
	, p_end_date               => null
	, x_status        => x_status
	, x_exception_msg => x_exception_msg
	);

	-- Send all the notifications.
	if l_vendor_id is not null then

		pos_spm_wf_pkg1.notify_account_create
		  (p_vendor_id           => l_vendor_id,
		   p_bank_name           => p_bank_name,
		   p_bank_account_number => p_bank_account_number,
		   x_itemtype      	 => l_itemtype,
		   x_itemkey       	 => l_itemkey);
	end if;

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End supplier_create_account ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_account_request_id ' || x_account_request_id);
	END IF;
EXCEPTION
    WHEN OTHERS THEN
      X_STATUS  :='E';
      raise_application_error(-20018,'Failure at step ' || l_step || Sqlerrm, true);
END supplier_create_account;

/* This procedure edits an account as a supplier
 *
 */

procedure supplier_update_account (
  p_mapping_id in NUMBER
, p_account_request_id in number
, p_object_version_number in number
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_SUPPLIER in VARCHAR2
, x_account_request_id	  out nocopy NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
 	l_step number;
 	l_party_id HZ_PARTIES.party_id%TYPE;
	l_status iby_temp_ext_bank_accts.status%TYPE;
	l_vendor_id po_vendors.vendor_id%TYPE;

 	CURSOR l_party_id_cur is
	select party_id, vendor_id from pos_supplier_mappings
	where mapping_id = p_mapping_id;

 	l_temp_ext_bank_account_id pos_acnt_gen_req.temp_ext_bank_acct_id%TYPE;
 	l_object_version_number pos_acnt_gen_req.object_version_number%TYPE;

 	CURSOR l_account_request_id_cur is
	select req.temp_ext_bank_acct_id, iby.note_alt, req.object_version_number, iby.status
	from pos_acnt_gen_req req, iby_temp_ext_bank_accts iby
	where req.account_request_id = p_account_request_id
	and req.temp_ext_bank_acct_id = iby.temp_ext_bank_acct_id for update nowait;

        l_itemtype    wf_items.item_type%TYPE;
        l_itemkey     wf_items.item_key%TYPE;
	l_account_request_id_rec l_account_request_id_cur%ROWTYPE;
BEGIN

	l_step := 0;
	x_status := 'E';

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin supplier_update_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_mapping_id ' || p_mapping_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_id ' || p_bank_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_id ' || p_branch_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_name ' || p_bank_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_name ' || p_branch_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_number ' || p_bank_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_number ' || p_branch_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_number ' || p_bank_account_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_name ' || p_bank_account_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_currency_code ' || p_currency_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_country_code ' || p_country_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_iban ' || p_iban);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_check_digits ' || p_check_digits);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);

	END IF;


 	open l_party_id_cur;
 	fetch l_party_id_cur into l_party_id, l_vendor_id;
 	if l_party_id_cur%NOTFOUND then
  		l_party_id := null;
 	end if;
 	close l_party_id_cur;

 	l_step := 1;

	if p_account_request_id is not null then
		-- Update the existing request.
		l_step := 2;

		open l_account_request_id_cur;
		fetch l_account_request_id_cur into l_account_request_id_rec;

		l_object_version_number := l_account_request_id_rec.object_version_number;
		l_status := l_account_request_id_rec.status;

  		-- Verify no one else has changed the row.
  		if l_object_version_number <> p_object_version_number then
			close l_account_request_id_cur;
			x_exception_msg := 'The bank account has been updated.';
			raise_application_error(-20019, x_exception_msg, TRUE);
  		end if;

		if l_status = 'VERIFICATION_FAILED' then
			l_status := 'CORRECTED';
		end if;

		l_step := 3;

		-- Update the row in IBY_TEMP_EXT_BANK_ACCTS
		POS_SBD_IBY_PKG.update_iby_temp_account (
  		  p_temp_ext_bank_acct_id => l_account_request_id_rec.temp_ext_bank_acct_id
  		, p_party_id => l_party_id
  		, p_status => l_status
  		, p_owner_primary_flag => 'Y'
  		, p_payment_factor_flag => 'N'
  		, p_BANK_ID => p_bank_id
  		, p_BANK_NAME => p_bank_name
  		, p_BANK_NAME_ALT => p_bank_name_alt
  		, p_BANK_NUMBER => p_bank_number
  		, p_BANK_INSTITUTION => p_bank_institution
  		, p_BANK_ADDRESS1 => p_bank_address1
  		, p_BANK_ADDRESS2 => p_bank_address2
  		, p_BANK_ADDRESS3 => p_bank_address3
  		, p_BANK_ADDRESS4 => p_bank_address4
 		, p_BANK_CITY => p_bank_city
  		, p_BANK_COUNTY => p_bank_county
  		, p_BANK_STATE => p_bank_state
  		, p_BANK_ZIP => p_bank_zip
  		, p_BANK_PROVINCE => p_bank_province
 		, p_BANK_COUNTRY => p_country_code
  		, p_BRANCH_ID => p_branch_id
  		, p_BRANCH_NAME => p_branch_name
  		, p_BRANCH_NAME_ALT => p_branch_name_alt
 		, p_BRANCH_NUMBER => p_branch_number
  		, p_BRANCH_TYPE => p_branch_type
  		, p_RFC_IDENTIFIER => p_rfc_identifier
  		, p_BIC => p_bic
  		, p_BRANCH_ADDRESS1 => p_branch_address1
  		, p_BRANCH_ADDRESS2 => p_branch_address2
  		, p_BRANCH_ADDRESS3 => p_branch_address3
  		, p_BRANCH_ADDRESS4 => p_branch_address4
  		, p_BRANCH_CITY => p_branch_city
  		, p_BRANCH_COUNTY => p_branch_county
  		, p_BRANCH_STATE => p_branch_state
  		, p_BRANCH_ZIP => p_branch_zip
  		, p_BRANCH_PROVINCE => p_branch_province
  		, p_BRANCH_COUNTRY => p_country_code
  		, p_EXT_BANK_ACCOUNT_ID => p_ext_bank_account_id
  		, p_bank_account_number => p_bank_account_number
  		, p_bank_account_name =>  p_bank_account_name
  		, p_bank_account_name_alt => p_bank_account_name_alt
  		, p_check_digits =>  p_check_digits
  		, p_iban => p_iban
  		, p_currency_code => p_currency_code
  		, p_country_code => p_country_code
  		, p_FOREIGN_PAYMENT_USE_FLAG => p_FOREIGN_PAYMENT_USE_FLAG
  		, p_bank_account_type => p_bank_account_type
  		, p_account_description => p_account_description
  		, p_end_date => p_end_date
  		, p_start_date => p_start_date
  		, p_agency_location_code => p_agency_location_code
  		, p_account_suffix => p_account_suffix
  		, p_EXCHANGE_RATE_AGREEMENT_NUM => p_EXCHANGE_RATE_AGREEMENT_NUM
  		, P_EXCHANGE_RATE_AGREEMENT_TYPE => P_EXCHANGE_RATE_AGREEMENT_TYPE
  		, p_EXCHANGE_RATE => p_EXCHANGE_RATE
  		, p_NOTES => p_NOTES_FROM_SUPPLIER
  		, p_NOTE_ALT => l_account_request_id_rec.note_alt
  		, x_status        => x_status
  		, x_exception_msg => x_exception_msg
  		);

		close l_account_request_id_cur;

	else
  		l_step := 4;

		if p_ext_bank_account_id is not null then
			l_status := 'CHANGE_PENDING';
		else
			l_status := 'NEW';
		end if;

  		-- Create a row in IBY_TEMP_EXT_BANK_ACCTS
  		POS_SBD_IBY_PKG.create_iby_temp_account (
  		  p_party_id => l_party_id
  		, p_status => l_status
  		, p_owner_primary_flag => 'Y'
  		, p_payment_factor_flag => 'N'
  		, p_BANK_ID => p_bank_id
  		, p_BANK_NAME => p_bank_name
  		, p_BANK_NAME_ALT => p_bank_name_alt
  		, p_BANK_NUMBER => p_bank_number
  		, p_BANK_INSTITUTION => p_bank_institution
  		, p_BANK_ADDRESS1 => p_bank_address1
  		, p_BANK_ADDRESS2 => p_bank_address2
  		, p_BANK_ADDRESS3 => p_bank_address3
  		, p_BANK_ADDRESS4 => p_bank_address4
  		, p_BANK_CITY => p_bank_city
  		, p_BANK_COUNTY => p_bank_county
  		, p_BANK_STATE => p_bank_state
  		, p_BANK_ZIP => p_bank_zip
  		, p_BANK_PROVINCE => p_bank_province
  		, p_BANK_COUNTRY => p_country_code
  		, p_BRANCH_ID => p_branch_id
  		, p_BRANCH_NAME => p_branch_name
  		, p_BRANCH_NAME_ALT => p_branch_name_alt
  		, p_BRANCH_NUMBER => p_branch_number
 		, p_BRANCH_TYPE => p_branch_type
  		, p_RFC_IDENTIFIER => p_rfc_identifier
  		, p_BIC => p_bic
  		, p_BRANCH_ADDRESS1 => p_branch_address1
  		, p_BRANCH_ADDRESS2 => p_branch_address2
  		, p_BRANCH_ADDRESS3 => p_branch_address3
  		, p_BRANCH_ADDRESS4 => p_branch_address4
  		, p_BRANCH_CITY => p_branch_city
  		, p_BRANCH_COUNTY => p_branch_county
  		, p_BRANCH_STATE => p_branch_state
  		, p_BRANCH_ZIP => p_branch_zip
  		, p_BRANCH_PROVINCE => p_branch_province
  		, p_BRANCH_COUNTRY => p_country_code
  		, p_EXT_BANK_ACCOUNT_ID => p_ext_bank_account_id
 		, p_bank_account_number => p_bank_account_number
  		, p_bank_account_name =>  p_bank_account_name
  		, p_bank_account_name_alt => p_bank_account_name_alt
  		, p_check_digits =>  p_check_digits
  		, p_iban => p_iban
  		, p_currency_code => p_currency_code
  		, p_country_code => p_country_code
  		, p_FOREIGN_PAYMENT_USE_FLAG => p_FOREIGN_PAYMENT_USE_FLAG
  		, p_bank_account_type => p_bank_account_type
  		, p_account_description => p_account_description
  		, p_end_date => p_end_date
  		, p_start_date => p_start_date
  		, p_agency_location_code => p_agency_location_code
  		, p_account_suffix => p_account_suffix
  		, p_EXCHANGE_RATE_AGREEMENT_NUM => p_EXCHANGE_RATE_AGREEMENT_NUM
  		, P_EXCHANGE_RATE_AGREEMENT_TYPE => P_EXCHANGE_RATE_AGREEMENT_TYPE
  		, p_EXCHANGE_RATE => p_EXCHANGE_RATE
  		, p_NOTES => p_NOTES_FROM_SUPPLIER
  		, p_NOTE_ALT => null
 		, x_temp_ext_bank_account_id => l_temp_ext_bank_account_id
  		, x_status        => x_status
  		, x_exception_msg => x_exception_msg
  		);

  		l_step := 5;

		-- Create a row in POS_ACNT_GEN_REQ
  		POS_SBD_TBL_PKG.insert_row_pos_acnt_gen_req (
  		  p_mapping_id => p_mapping_id
  		, p_temp_ext_bank_account_id => l_temp_ext_bank_account_id
  		, p_ext_bank_account_id => p_ext_bank_account_id
  		, x_account_request_id => x_account_request_id
  		, x_status        => x_status
  		, x_exception_msg => x_exception_msg
  		);

		-- update all the records in POS_ACNT_ADDR_SUMM_REQ with the account id
		update pos_acnt_addr_summ_req
		set account_request_id = x_account_request_id
		where ext_bank_account_id = p_ext_bank_account_id;

 	end if;

	-- Send all the notifications.
	if l_vendor_id is not null then

		pos_spm_wf_pkg1.notify_account_update
		  (p_vendor_id           => l_vendor_id,
		   p_bank_name           => p_bank_name,
		   p_bank_account_number => p_bank_account_number,
		   p_currency_code       => p_currency_code,
		   p_bank_account_name   => p_bank_account_name,
		   x_itemtype      	 => l_itemtype,
		   x_itemkey       	 => l_itemkey);
	end if;


	l_step := 6;

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End supplier_update_account ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_account_request_id ' || x_account_request_id);
	END IF;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20020, 'Failure at step ' || l_step || Sqlerrm, true);
END supplier_update_account;


PROCEDURE buyer_prenote_account (
  p_party_id in NUMBER
, p_account_request_id in number
, p_object_version_number in number
, p_vendor_site_id in number
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_BUYER in VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

 	l_temp_ext_bank_account_id number;

 	l_notes_from_supplier iby_temp_ext_bank_accts.note%TYPE;
	CURSOR l_account_request_cur is
	select req.temp_ext_bank_acct_id, req.object_version_number, iby.note, iby.status,
	iby.ext_bank_account_id, iby.bank_id, iby.branch_id
	from pos_acnt_gen_req req, iby_temp_ext_bank_accts iby
	where account_request_id = p_account_request_id
	and iby.temp_ext_bank_acct_id = req.temp_ext_bank_acct_id;
	l_account_request_rec l_account_request_cur%ROWTYPE;

 	l_object_version_number POS_ACNT_GEN_REQ.object_version_number%TYPE;
 	l_step number;
      	l_account_status iby_temp_ext_bank_accts.status%TYPE;
      	l_bank_id iby_temp_ext_bank_accts.bank_id%TYPE;
      	l_branch_id iby_temp_ext_bank_accts.branch_id%TYPE;
      	l_ext_bank_account_id iby_temp_ext_bank_accts.ext_bank_account_id%TYPE;

        l_itemtype    wf_items.item_type%TYPE;
        l_itemkey     wf_items.item_key%TYPE;
        CURSOR l_vendor_cur is
	select vendor_id from pos_supplier_mappings where party_id = p_party_id;
	l_vendor_id po_vendors.vendor_id%TYPE;

BEGIN

	l_step := 0;
   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin buyer_prenote_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_id ' || p_party_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_id ' || p_bank_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_id ' || p_branch_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_name ' || p_bank_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_name ' || p_branch_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_number ' || p_bank_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_number ' || p_branch_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_number ' || p_bank_account_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_name ' || p_bank_account_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_currency_code ' || p_currency_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_country_code ' || p_country_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_iban ' || p_iban);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_check_digits ' || p_check_digits);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);

	END IF;


	-- Update the iby request tables.
  	open l_account_request_cur;
  	fetch l_account_request_cur into l_account_request_rec;
	close l_account_request_cur;

	l_account_status := l_account_request_rec.status;
  	l_temp_ext_bank_account_id := l_account_request_rec.temp_ext_bank_acct_id;
	l_object_version_number := l_account_request_rec.object_version_number;
	l_notes_from_supplier := l_account_request_rec.note;

	if l_account_status <> 'NEW' then
		l_bank_id := l_account_request_rec.bank_id;
		l_branch_id := l_account_request_rec.branch_id;
		l_ext_bank_account_id := l_account_request_rec.ext_bank_account_id;
	else
		l_bank_id := p_bank_id;
		l_branch_id := p_branch_id;
		l_ext_bank_account_id := p_ext_bank_account_id;
	end if;

	l_step := 1;

  	if (l_object_version_number = p_object_version_number) then

		l_step := 2;

  		-- Update the row in IBY_TEMP_EXT_BANK_ACCTS
  		POS_SBD_IBY_PKG.update_iby_temp_account (
  		  p_temp_ext_bank_acct_id => l_temp_ext_bank_account_id
  		, p_party_id => p_party_id
  		, p_status => 'IN_VERIFICATION'
  		, p_owner_primary_flag => 'Y'
  		, p_payment_factor_flag => 'N'
  		, p_BANK_ID => l_bank_id
  		, p_BANK_NAME => p_bank_name
  		, p_BANK_NAME_ALT => p_bank_name_alt
  		, p_BANK_NUMBER => p_bank_number
  		, p_BANK_INSTITUTION => p_bank_institution
  		, p_BANK_ADDRESS1 => p_bank_address1
  		, p_BANK_ADDRESS2 => p_bank_address2
  		, p_BANK_ADDRESS3 => p_bank_address3
  		, p_BANK_ADDRESS4 => p_bank_address4
  		, p_BANK_CITY => p_bank_city
  		, p_BANK_COUNTY => p_bank_county
  		, p_BANK_STATE => p_bank_state
  		, p_BANK_ZIP => p_bank_zip
  		, p_BANK_PROVINCE => p_bank_province
  		, p_BANK_COUNTRY => p_country_code
  		, p_BRANCH_ID => l_branch_id
  		, p_BRANCH_NAME => p_branch_name
  		, p_BRANCH_NAME_ALT => p_branch_name_alt
 		, p_BRANCH_NUMBER => p_branch_number
  		, p_BRANCH_TYPE => p_branch_type
  		, p_RFC_IDENTIFIER => p_rfc_identifier
  		, p_BIC => p_bic
  		, p_BRANCH_ADDRESS1 => p_branch_address1
  		, p_BRANCH_ADDRESS2 => p_branch_address2
  		, p_BRANCH_ADDRESS3 => p_branch_address3
  		, p_BRANCH_ADDRESS4 => p_branch_address4
  		, p_BRANCH_CITY => p_branch_city
  		, p_BRANCH_COUNTY => p_branch_county
  		, p_BRANCH_STATE => p_branch_state
  		, p_BRANCH_ZIP => p_branch_zip
  		, p_BRANCH_PROVINCE => p_branch_province
  		, p_BRANCH_COUNTRY => p_country_code
  		, p_EXT_BANK_ACCOUNT_ID => l_ext_bank_account_id
  		, p_bank_account_number => p_bank_account_number
  		, p_bank_account_name =>  p_bank_account_name
  		, p_bank_account_name_alt => p_bank_account_name_alt
  		, p_check_digits =>  p_check_digits
  		, p_iban => p_iban
  		, p_currency_code => p_currency_code
  		, p_country_code => p_country_code
  		, p_FOREIGN_PAYMENT_USE_FLAG => p_FOREIGN_PAYMENT_USE_FLAG
  		, p_bank_account_type => p_bank_account_type
  		, p_account_description => p_account_description
  		, p_end_date => p_end_date
  		, p_start_date => p_start_date
  		, p_agency_location_code => p_agency_location_code
  		, p_account_suffix => p_account_suffix
  		, p_EXCHANGE_RATE_AGREEMENT_NUM => p_EXCHANGE_RATE_AGREEMENT_NUM
  		, P_EXCHANGE_RATE_AGREEMENT_TYPE => P_EXCHANGE_RATE_AGREEMENT_TYPE
  		, p_EXCHANGE_RATE => p_EXCHANGE_RATE
  		, p_NOTES => l_NOTES_FROM_SUPPLIER
  		, p_NOTE_ALT => p_NOTES_FROM_BUYER -- Note from buyer
  		, x_status        => x_status
  		, x_exception_msg => x_exception_msg
  		);


		l_step := 3;
  		POS_SBD_IBY_PKG.prenote_iby_temp_account (
    	  	  p_temp_ext_bank_account_id => l_temp_ext_bank_account_id
    		, p_vendor_site_id => p_vendor_site_id
   		, x_status        => x_status
    		, x_exception_msg => x_exception_msg
  		);

		-- Send the notifications.
		open l_vendor_cur;
  		fetch l_vendor_cur into l_vendor_id;
  		close l_vendor_cur;
		pos_spm_wf_pkg1.notify_sup_on_acct_action
		  (p_bank_account_number => p_bank_account_number,
		   p_vendor_id           => l_vendor_id,
		   p_bank_name           => p_bank_name,
		   p_request_status      => 'IN_VERIFICATION',
		   p_note                => p_notes_from_buyer,
		   x_itemtype            => l_itemtype,
		   x_itemkey             => l_itemkey
		   );
	end if;

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End buyer_prenote_account ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20030, x_exception_msg || Sqlerrm, true);
END buyer_prenote_account;


PROCEDURE buyer_approve_account (
  p_party_id in NUMBER
, p_account_request_id in number
, p_object_version_number in number
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_BUYER in VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
 	l_temp_ext_bank_account_id number;

 	l_notes_from_supplier iby_temp_ext_bank_accts.note%TYPE;
 	CURSOR l_account_request_id_cur is
	select req.temp_ext_bank_acct_id, req.object_version_number, iby.note
	from pos_acnt_gen_req req, iby_temp_ext_bank_accts iby
	where account_request_id = p_account_request_id
	and iby.temp_ext_bank_acct_id = req.temp_ext_bank_acct_id for update nowait;

 	l_object_version_number POS_ACNT_GEN_REQ.object_version_number%TYPE;

 	l_step number;

        l_itemtype    wf_items.item_type%TYPE;
        l_itemkey     wf_items.item_key%TYPE;
        CURSOR l_vendor_cur is
	select vendor_id from pos_supplier_mappings where party_id = p_party_id;
	l_vendor_id po_vendors.vendor_id%TYPE;

BEGIN

	l_step := 0;

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin buyer_approve_account ');
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_id ' || p_party_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_id ' || p_bank_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_id ' || p_branch_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_name ' || p_bank_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_name ' || p_branch_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_number ' || p_bank_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_branch_number ' || p_branch_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_number ' || p_bank_account_number);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_bank_account_name ' || p_bank_account_name);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_currency_code ' || p_currency_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_country_code ' || p_country_code);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_iban ' || p_iban);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_check_digits ' || p_check_digits);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);
		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_object_version_number ' || p_object_version_number);
	END IF;

	-- Update the iby request tables.
  	open l_account_request_id_cur;
  	fetch l_account_request_id_cur
  	 into l_temp_ext_bank_account_id, l_object_version_number, l_notes_from_supplier;
  	close l_account_request_id_cur;

	l_step := 1;

  	if (l_object_version_number = p_object_version_number) then

		l_step := 2;

	  	-- Update the row in IBY_TEMP_EXT_BANK_ACCTS
		POS_SBD_IBY_PKG.update_iby_temp_account (
		  p_temp_ext_bank_acct_id => l_temp_ext_bank_account_id
  		, p_party_id => p_party_id
  		, p_status => 'APPROVED'
 		, p_owner_primary_flag => 'Y'
  		, p_payment_factor_flag => 'N'
  		, p_BANK_ID => p_bank_id
  		, p_BANK_NAME => p_bank_name
  		, p_BANK_NAME_ALT => p_bank_name_alt
  		, p_BANK_NUMBER => p_bank_number
  		, p_BANK_INSTITUTION => p_bank_institution
  		, p_BANK_ADDRESS1 => p_bank_address1
  		, p_BANK_ADDRESS2 => p_bank_address2
  		, p_BANK_ADDRESS3 => p_bank_address3
  		, p_BANK_ADDRESS4 => p_bank_address4
  		, p_BANK_CITY => p_bank_city
  		, p_BANK_COUNTY => p_bank_county
  		, p_BANK_STATE => p_bank_state
  		, p_BANK_ZIP => p_bank_zip
  		, p_BANK_PROVINCE => p_bank_province
  		, p_BANK_COUNTRY => p_country_code
  		, p_BRANCH_ID => p_branch_id
  		, p_BRANCH_NAME => p_branch_name
  		, p_BRANCH_NAME_ALT => p_branch_name_alt
  		, p_BRANCH_NUMBER => p_branch_number
  		, p_BRANCH_TYPE => p_branch_type
  		, p_RFC_IDENTIFIER => p_rfc_identifier
  		, p_BIC => p_bic
  		, p_BRANCH_ADDRESS1 => p_branch_address1
  		, p_BRANCH_ADDRESS2 => p_branch_address2
  		, p_BRANCH_ADDRESS3 => p_branch_address3
  		, p_BRANCH_ADDRESS4 => p_branch_address4
  		, p_BRANCH_CITY => p_branch_city
  		, p_BRANCH_COUNTY => p_branch_county
  		, p_BRANCH_STATE => p_branch_state
  		, p_BRANCH_ZIP => p_branch_zip
  		, p_BRANCH_PROVINCE => p_branch_province
  		, p_BRANCH_COUNTRY => p_country_code
  		, p_EXT_BANK_ACCOUNT_ID => p_ext_bank_account_id
  		, p_bank_account_number => p_bank_account_number
  		, p_bank_account_name =>  p_bank_account_name
  		, p_bank_account_name_alt => p_bank_account_name_alt
  		, p_check_digits =>  p_check_digits
  		, p_iban => p_iban
  		, p_currency_code => p_currency_code
  		, p_country_code => p_country_code
  		, p_FOREIGN_PAYMENT_USE_FLAG => p_FOREIGN_PAYMENT_USE_FLAG
  		, p_bank_account_type => p_bank_account_type
  		, p_account_description => p_account_description
  		, p_end_date => p_end_date
  		, p_start_date => p_start_date
  		, p_agency_location_code => p_agency_location_code
  		, p_account_suffix => p_account_suffix
  		, p_EXCHANGE_RATE_AGREEMENT_NUM => p_EXCHANGE_RATE_AGREEMENT_NUM
  		, P_EXCHANGE_RATE_AGREEMENT_TYPE => P_EXCHANGE_RATE_AGREEMENT_TYPE
  		, p_EXCHANGE_RATE => p_EXCHANGE_RATE
  		, p_NOTES => l_NOTES_FROM_SUPPLIER
  		, p_NOTE_ALT => p_NOTES_FROM_BUYER -- Note from buyer
  		, x_status        => x_status
  		, x_exception_msg => x_exception_msg
  		);

		l_step := 3;

  		POS_SBD_IBY_PKG.approve_iby_temp_account (
    		  p_temp_ext_bank_account_id => l_temp_ext_bank_account_id
    		, x_status        => x_status
    		, x_exception_msg => x_exception_msg
  		);

		l_step := 4;

		POS_SBD_IBY_PKG.remove_iby_temp_account
		(
		  p_iby_temp_ext_bank_account_id => l_temp_ext_bank_account_id
		, x_status        => x_status
		, x_exception_msg => x_exception_msg
		);

		l_step := 5;
		POS_SBD_TBL_PKG.del_row_pos_acnt_gen_req (
		  p_account_request_id    => p_account_request_id
		, x_status        => x_status
		, x_exception_msg => x_exception_msg
		);

		l_step := 7;

		update pos_acnt_addr_summ_req
		set account_request_id = null,
		last_update_date = sysdate,
       	 	last_updated_by = fnd_global.user_id,
       		last_update_login = fnd_global.login_id
		where account_request_id = p_account_request_id;

		-- Notify the Supplier User
		open l_vendor_cur;
  		fetch l_vendor_cur into l_vendor_id;
  		close l_vendor_cur;
		pos_spm_wf_pkg1.notify_sup_on_acct_action
		  (p_bank_account_number => p_bank_account_number,
		   p_vendor_id           => l_vendor_id,
		   p_bank_name           => p_bank_name,
		   p_request_status      => 'APPROVED',
		   p_note                => p_NOTES_FROM_BUYER,
		   x_itemtype            => l_itemtype,
		   x_itemkey             => l_itemkey
		   );

  	end if;

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End buyer_approve_account ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20021, x_exception_msg || Sqlerrm, true);
END buyer_approve_account;


/* This procedure rejects the assignment request
 *
 */
PROCEDURE buyer_reject_assignment (
  p_party_id in NUMBER
, p_assignment_request_id in number
, p_object_version_number in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

	l_step number;

	cursor l_addr_summ_req_cur is
	select assignment_id from pos_acnt_addr_summ_req
	where assignment_request_id = p_assignment_request_id for update nowait;

	l_addr_summ_req_rec l_addr_summ_req_cur%ROWTYPE;

BEGIN

	l_step := 0;

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin buyer_reject_assignment ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_assignment_request_id ' || p_assignment_request_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_id ' || p_party_id);
	END IF;

  	-- Remove all the rows in the POS_ACNT_ADDR_SUMM_REQ
  	for l_addr_summ_req_rec in l_addr_summ_req_cur loop

		l_step := 2;
		POS_SBD_TBL_PKG.del_row_pos_acnt_summ_req (
		  p_assignment_id => l_addr_summ_req_rec.assignment_id
		, x_status        => x_status
		, x_exception_msg => x_exception_msg);

	end loop;

	l_step := 2;
  	-- Remove the rows in the POS_ACNT_ADDR_REQ
  	POS_SBD_TBL_PKG.del_row_pos_acnt_addr_req (
  	  p_assignment_request_id => p_assignment_request_id
  	, x_status        => x_status
  	, x_exception_msg => x_exception_msg
  	);

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End buyer_reject_assignment ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      raise_application_error(-20022,'Failure at step ' || l_step || Sqlerrm, true);
END buyer_reject_assignment;


/* This procedure approves the assignment request
 *
 */
PROCEDURE buyer_approve_assignment (
  p_party_id in NUMBER
, p_assignment_request_id in number
, p_object_version_number in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)

IS
	l_step number;

	l_result_rec              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
	l_payee_rec               IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_Rec_Type;
	l_pay_instr_rec           IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
	l_pay_assign_rec          IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;

	cursor l_acnt_req_cur is
	select * from pos_acnt_addr_req
	where assignment_request_id = p_assignment_request_id
	and object_version_number = p_object_version_number for update nowait;
	l_acnt_req_rec l_acnt_req_cur%ROWTYPE;

	l_object_version_number number;

	l_request_type POS_ACNT_ADDR_REQ.request_type%TYPE;
	l_request_status POS_ACNT_ADDR_REQ.request_status%TYPE;

	cursor l_acnt_req_summ_cur is
	select * from pos_acnt_addr_summ_req
	where assignment_request_id = p_assignment_request_id
	order by priority for update nowait;
	l_acnt_req_summ_rec l_acnt_req_summ_cur%ROWTYPE;

	l_assignment_status POS_ACNT_ADDR_SUMM_REQ.assignment_status%TYPE;
	l_ext_bank_account_id POS_ACNT_ADDR_SUMM_REQ.ext_bank_account_id%TYPE;
	l_assignment_id POS_ACNT_ADDR_SUMM_REQ.assignment_id%TYPE;
	l_party_site_id HZ_PARTY_SITES.party_site_id%TYPE;
	l_address_request_id POS_ACNT_ADDR_REQ.address_request_id%TYPE;
	l_end_date POS_ACNT_ADDR_SUMM_REQ.end_date%TYPE;
	l_start_date POS_ACNT_ADDR_SUMM_REQ.start_date%TYPE;
	l_priority POS_ACNT_ADDR_SUMM_REQ.priority%TYPE;
	l_payee_assignment_id number;
	l_msg_count number;

BEGIN
	l_step := 0;
	x_status := 'E';

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin buyer_approve_assignment ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_assignment_request_id ' || p_assignment_request_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_id ' || p_party_id);
	END IF;


  	open l_acnt_req_cur;
  	fetch l_acnt_req_cur into l_acnt_req_rec;

   	if l_acnt_req_cur%NOTFOUND then
 		close l_acnt_req_cur;
		return;
   	end if;

	l_step := 1;

   	l_request_type := l_acnt_req_rec.request_type;
   	l_object_version_number := l_acnt_req_rec.object_version_number;
   	l_party_site_id := l_acnt_req_rec.party_site_id;
   	l_address_request_id := l_acnt_req_rec.address_request_id;
   	l_request_status := l_acnt_req_rec.request_status;

  	close l_acnt_req_cur;


	l_step := 2;

  	for l_acnt_req_summ_rec in l_acnt_req_summ_cur loop

		l_step := 3;

		l_assignment_status := l_acnt_req_summ_rec.assignment_status;
		l_ext_bank_account_id := l_acnt_req_summ_rec.ext_bank_account_id;
		l_assignment_id := l_acnt_req_summ_rec.assignment_id;
		l_end_date := l_acnt_req_summ_rec.end_date;
   		l_start_date := l_acnt_req_summ_rec.start_date;
   		l_priority := l_acnt_req_summ_rec.priority;

	   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Assignment Status ' || l_assignment_status);
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_assignment_id ' || l_assignment_id);
		END IF;

        	l_payee_rec.Payment_Function := 'PAYABLES_DISB';
        	l_payee_rec.Party_id := p_party_id;
        	l_payee_rec.Party_Site_id := l_party_site_id;
        	l_payee_rec.org_Id := null;
        	l_payee_rec.Supplier_Site_id := null;
        	l_payee_rec.Org_Type := null;

        	-- Instrument Record.
        	l_pay_instr_rec.Instrument_Type := 'BANKACCOUNT';
        	l_pay_instr_rec.Instrument_Id := l_ext_bank_account_id;

       		-- Assignment Record.
        	l_pay_assign_rec.Instrument := l_pay_instr_rec;
        	l_pay_assign_rec.Priority := l_priority;
       		l_pay_assign_rec.Start_Date := l_start_date;
        	l_pay_assign_rec.End_Date := l_end_date;


		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Calling Set_Payee_Instr_Assignment ');
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Party_id ' || l_payee_rec.Party_id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Payment_Function ' || l_payee_rec.Payment_Function);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Party_Site_id ' || l_payee_rec.Party_Site_id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Supplier_Site_id ' || l_payee_rec.Supplier_Site_id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Org_id ' || l_payee_rec.org_id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_payee_rec.Org_Type ' || l_payee_rec.Org_Type);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_instr_rec.Instrument_Type ' || l_pay_instr_rec.Instrument_Type);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_instr_rec.Instrument_Id ' || l_pay_instr_rec.Instrument_Id);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_assign_rec.Priority ' || l_pay_assign_rec.Priority);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_assign_rec.Start_Date ' || l_pay_assign_rec.Start_Date );
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_pay_assign_rec.End_Date ' || l_pay_assign_rec.End_Date);
		END IF;

		l_step := 4;

        	IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
          	 p_api_version      => 1.0,
          	 p_init_msg_list    => FND_API.G_FALSE,
          	 p_commit           => FND_API.G_FALSE,
          	 x_return_status    => x_status,
          	 x_msg_count        => l_msg_count,
          	 x_msg_data         => x_exception_msg,
          	 p_payee            => l_payee_rec,
          	 p_assignment_attribs => l_pay_assign_rec,
          	 x_assign_id        => l_payee_assignment_id,
          	 x_response         => l_result_rec
        	);

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' After Set_Payee_Instr_Assignment ');
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_return_status ' || x_status);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_count ' || l_msg_count);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_msg_data ' || x_exception_msg);
			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_assign_id ' || l_payee_assignment_id);
		END IF;

		if l_payee_assignment_id is null OR x_status is null OR x_status <> 'S' then
		l_step := 5;
		raise_application_error(-20029, 'IBY Failed to create assignment ' || x_exception_msg, true);
		end if;

		-- Delete the row in POS_ACNT_ADDR_SUMM_REQ
		POS_SBD_TBL_PKG.del_row_pos_acnt_summ_req (
                	  p_assignment_id => l_assignment_id
                	, x_status        => x_status
               		, x_exception_msg => x_exception_msg
                	);
  	end loop;

  	-- update the record in POS_ACNT_ADDR_REQ to Approved.
	l_step := 6;

	POS_SBD_TBL_PKG.del_row_pos_acnt_addr_req (
        	  p_assignment_request_id => p_assignment_request_id
              	, x_status        => x_status
                , x_exception_msg => x_exception_msg);

   	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End buyer_approve_assignment ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20023, x_exception_msg || Sqlerrm, true);
END buyer_approve_assignment;

/* This procedure adds an account assignment on supplier's request.
 *
 */
PROCEDURE supplier_add_account (
  p_mapping_id             IN NUMBER
, p_account_request_id	   IN NUMBER
, p_ext_bank_account_id    IN NUMBER
, p_party_site_id          IN NUMBER
, p_address_request_id     IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

	l_step number;
	l_request_type POS_ACNT_ADDR_REQ.request_type%TYPE;

	l_number number;

	cursor assign_exists_cur is
	select 1 from pos_acnt_addr_summ_req poss, pos_acnt_addr_req req
	where poss.assignment_request_id = req.assignment_request_id
	and req.mapping_id = p_mapping_id
	and ( (poss.account_request_id = p_account_request_id
		and poss.account_request_id is not null and p_account_request_id is not null) OR
	    (ext_bank_account_id = p_ext_bank_account_id
		and ext_bank_account_id is not null and p_ext_bank_account_id is not null))
	and req.request_status = 'PENDING'
	and ( (req.party_site_id is null and req.address_request_id is null and p_party_site_id is null
		and p_address_request_id is null) OR
	      (req.party_site_id = p_party_site_id
		and req.party_site_id is not null and p_party_site_id is not null) OR
	      (req.address_request_id = p_address_request_id
		and req.address_request_id is not null and p_address_request_id is not null)
	    )
	and rownum = 1

	UNION ALL

	select 1 from iby_pmt_instr_uses_all uses, iby_external_payees_all payee, pos_supplier_mappings pmap
	where uses.instrument_type = 'BANKACCOUNT'
	and payee.ext_payee_id = uses.ext_pmt_party_id
	and payee.org_id is null
	and payee.supplier_site_id is null
	and ((payee.party_site_id = p_party_site_id
		and payee.party_site_id is not null and p_party_site_id is not null) OR
	     (payee.party_site_id is null and p_party_site_id is null and p_address_request_id is null))
	and payee.payment_function = 'PAYABLES_DISB'
	and (uses.instrument_id = p_ext_bank_account_id
		and uses.instrument_id is not null and p_ext_bank_account_id is not null)
	and payee.payee_party_id = pmap.party_id
	and pmap.mapping_id = p_mapping_id
	and rownum = 1;
BEGIN

	l_step := 0;
	x_status := 'E';

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin supplier_add_account ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_request_type ' || l_request_type);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_mapping_id ' || p_mapping_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_site_id ' || p_party_site_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_address_request_id ' || p_address_request_id);
	END IF;

	-- Check if the account assignment already exists.
	-- In that case no need to add the account.
	open assign_exists_cur;
	fetch assign_exists_cur into l_number;
	if assign_exists_cur%FOUND then
		x_status := 'S';
		close assign_exists_cur;
		return;
	end if;
	close assign_exists_cur;

	l_step := 1;

	if p_address_request_id is null AND p_party_site_id is null then
		l_request_type := 'SUPPLIER';
	else
		l_request_type := 'ADDRESS';
	end if;

	POS_SBD_PKG.supplier_update_assignment(
	  p_assignment_id          => null
	, p_assignment_request_id  => null
	, p_object_version_number  => null
	, p_account_request_id	   => p_account_request_id
	, p_ext_bank_account_id    => p_ext_bank_account_id
	, p_request_type           => l_request_type
	, p_mapping_id             => p_mapping_id
	, p_party_site_id          => p_party_site_id
	, p_address_request_id     => p_address_request_id
	, p_priority               => null
	, p_start_date             => sysdate
	, p_end_date               => null
	, x_status        => x_status
	, x_exception_msg => x_exception_msg
	);

	l_step := '3';

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End supplier_add_account ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' x_status ' || x_status);
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step;
      raise_application_error(-20025, x_exception_msg || Sqlerrm, true);
END supplier_add_account;


/* This procedure creates/update the account assignment on supplier's request.
 *
 */
PROCEDURE supplier_update_assignment (
  p_assignment_id          IN NUMBER
, p_assignment_request_id  IN NUMBER
, p_object_version_number  IN NUMBER
, p_account_request_id	   IN NUMBER
, p_ext_bank_account_id    IN NUMBER
, p_request_type           IN VARCHAR2
, p_mapping_id             IN NUMBER
, p_party_site_id          IN NUMBER
, p_address_request_id     IN NUMBER
, p_priority               IN NUMBER
, p_start_date             IN DATE
, p_end_date               IN DATE
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

	l_step NUMBER;
	l_assignment_status pos_acnt_addr_summ_req.assignment_status%TYPE;

	l_start_date pos_acnt_addr_summ_req.start_date%TYPE;
	l_end_date pos_acnt_addr_summ_req.end_date%TYPE;
	l_priority pos_acnt_addr_summ_req.priority%TYPE;
	l_f_priority pos_acnt_addr_summ_req.priority%TYPE;
	l_assignment_request_id pos_acnt_addr_summ_req.assignment_request_id%TYPE;
	l_assignment_id pos_acnt_addr_summ_req.assignment_id%TYPE;
	l_c_assignment_id pos_acnt_addr_summ_req.assignment_id%TYPE;
	l_snapshot_created varchar2(1);

	cursor l_supplier_assign_cur is

	select uses.order_of_preference, uses.start_date, uses.end_date
	from iby_pmt_instr_uses_all uses, iby_external_payees_all payee,
	iby_ext_bank_accounts act, pos_supplier_mappings pmap
	where uses.instrument_type = 'BANKACCOUNT'
	and payee.ext_payee_id = uses.ext_pmt_party_id
	and payee.org_id is null
	and payee.supplier_site_id is null
	and payee.party_site_id is null
	and payee.payment_function = 'PAYABLES_DISB'
	and uses.instrument_id = act.ext_bank_account_id
	and payee.payee_party_id = pmap.party_id
	and pmap.mapping_id = p_mapping_id
	and sysdate between NVL(act.start_date,sysdate) AND NVL(act.end_date,sysdate)
	and act.ext_bank_account_id = p_ext_bank_account_id;

	cursor l_exist_assign_req_cur is
	select assignment_id from pos_acnt_addr_summ_req req
	where assignment_request_id = l_assignment_request_id
	and ((ext_bank_account_id = p_ext_bank_account_id and ext_bank_account_id is not null and p_ext_bank_account_id is not null) OR
	(account_request_id = p_account_request_id and account_request_id is not null and p_account_request_id is not null and p_ext_bank_account_id is null));

	cursor l_address_assign_cur is

	select uses.order_of_preference, uses.start_date, uses.end_date
	from iby_pmt_instr_uses_all uses, iby_external_payees_all payee,
	iby_ext_bank_accounts act, pos_supplier_mappings pmap
	where uses.instrument_type = 'BANKACCOUNT'
	and payee.ext_payee_id = uses.ext_pmt_party_id
	and payee.org_id is null
	and payee.supplier_site_id is null
	and payee.party_site_id = p_party_site_id
	and payee.payment_function = 'PAYABLES_DISB'
	and uses.instrument_id = act.ext_bank_account_id
	and payee.payee_party_id = pmap.party_id
	and pmap.mapping_id = p_mapping_id
	and sysdate between NVL(act.start_date,sysdate) AND NVL(act.end_date,sysdate)
	and act.ext_bank_account_id = p_ext_bank_account_id;

	cursor l_supplier_req_cur is
	select assignment_request_id from pos_acnt_addr_req
	where request_type = 'SUPPLIER'
	and mapping_id = p_mapping_id
	and request_status = 'PENDING'
	and party_site_id is null
	and address_request_id is null;

	cursor l_address_req_cur is
	select assignment_request_id from pos_acnt_addr_req
	where request_type = 'ADDRESS'
	and mapping_id = p_mapping_id
	and request_status = 'PENDING'
	and ( (address_request_id = p_address_request_id and address_request_id is not null and p_address_request_id is not null)
	OR (party_site_id = p_party_site_id and party_site_id is not null and p_party_site_id is not null));

	cursor l_assign_iby_cur is
	select uses.order_of_preference, uses.start_date, uses.end_date, uses.instrument_id, req.account_request_id
	from iby_pmt_instr_uses_all uses, iby_external_payees_all payee,
	iby_ext_bank_accounts act, pos_supplier_mappings pmap, pos_acnt_gen_req req
	where uses.instrument_type = 'BANKACCOUNT'
	and payee.ext_payee_id = uses.ext_pmt_party_id
	and payee.org_id is null
	and ((payee.party_site_id = p_party_site_id
	and p_party_site_id is not null and payee.party_site_id is not null) OR
	     (p_party_site_id is null and payee.party_site_id is null))
	and uses.instrument_id = act.ext_bank_account_id
	and payee.payee_party_id = pmap.party_id
	and payee.payment_function = 'PAYABLES_DISB'
	and pmap.mapping_id = p_mapping_id
	and payee.supplier_site_id is null
	and sysdate between NVL(act.start_date,sysdate) AND NVL(act.end_date,sysdate)
	and req.ext_bank_account_id (+) = act.ext_bank_account_id
	and req.mapping_id(+) = p_mapping_id;


	cursor l_max_priority_cur is
	select max(summ.priority)
	from pos_acnt_addr_summ_req summ, pos_acnt_addr_req req
	where req.mapping_id = p_mapping_id
	and req.assignment_request_id = summ.assignment_request_id
	and ((req.party_site_id = p_party_site_id and req.party_site_id is
	 not null and p_party_site_id is not null)
	 OR (req.party_site_id is null and p_party_site_id is null))
	and ((req.address_request_id = p_address_request_id
	and req.address_request_id is not null and p_address_request_id is not null)
	OR (req.address_request_id is null and p_address_request_id is null))
	and req.request_status = 'PENDING';

BEGIN

	l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin supplier_update_assignment ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_ext_bank_account_id ' || p_ext_bank_account_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_request_type ' || p_request_type);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_mapping_id ' || p_mapping_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_party_site_id ' || p_party_site_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_address_request_id ' || p_address_request_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_assignment_id ' || p_assignment_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_assignment_request_id ' || p_assignment_request_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_priority ' || p_priority);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_start_date ' || p_start_date);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_end_date ' || p_end_date);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_object_version_number ' || p_object_version_number);
	END IF;

	if p_assignment_request_id is null then
		l_step := 1;

		if p_request_type = 'SUPPLIER' then
			l_step := 2;
			open l_supplier_req_cur;
			fetch l_supplier_req_cur into l_assignment_request_id;
			close l_supplier_req_cur;
		else
			l_step := 3;
			open l_address_req_cur;
			fetch l_address_req_cur into l_assignment_request_id;
			close l_address_req_cur;
		end if;

		l_step := 4;

		if l_assignment_request_id is null then

			l_step := 5;

			POS_SBD_TBL_PKG.insert_row_pos_acnt_addr_req (
		 	  p_mapping_id	   => p_mapping_id
			, p_request_type   => p_request_type
			, p_party_site_id  => p_party_site_id
			, p_address_request_id => p_address_request_id
			, x_assignment_request_id => l_assignment_request_id
			, x_status        => x_status
			, x_exception_msg => x_exception_msg
			);
			l_snapshot_created := 'Y';

			l_step := 6;
			if (p_party_site_id is not null and p_request_type = 'ADDRESS') OR
				p_request_type = 'SUPPLIER' then

				for l_assign_iby_rec in l_assign_iby_cur loop
					l_step := 7;
					POS_SBD_TBL_PKG.insert_row_pos_acnt_summ_req (
					  p_assignment_request_id  => l_assignment_request_id
					, p_ext_bank_account_id    => l_assign_iby_rec.instrument_id
					, p_account_request_id     => l_assign_iby_rec.account_request_id
					, p_start_date             => l_assign_iby_rec.start_date
					, p_end_date               => l_assign_iby_rec.end_date
					, p_priority               => l_assign_iby_rec.order_of_preference
					, p_assignment_status      => 'CURRENT'
					, x_assignment_id	   => l_c_assignment_id
					, x_status        	   => x_status
					, x_exception_msg          => x_exception_msg);
				end loop;
			end if;
		else
			l_snapshot_created := 'N';

		end if;

	else
		l_step := 8;
		l_assignment_request_id := p_assignment_request_id;
	end if;

	l_step := 9;

	l_f_priority := 1;

	if p_priority is not null then

		l_f_priority := p_priority;

	else
		open l_max_priority_cur;
		fetch l_max_priority_cur into l_f_priority;
		if l_max_priority_cur%NOTFOUND then
			l_f_priority := 1;
		else
			if l_f_priority is null then
				l_f_priority := 1;
			else
				l_f_priority := l_f_priority + 1;
			end if;
		end if;
		close l_max_priority_cur;
	end if;

	if p_ext_bank_account_id is not null then
		l_step := 10;
		if p_request_type = 'SUPPLIER' then
			l_step := 11;
			if p_party_site_id is not null OR p_address_request_id is not null then
				return;
			end if;

			open l_supplier_assign_cur;
			fetch l_supplier_assign_cur into l_priority, l_start_date, l_end_date;
			l_step := 12;
			if l_supplier_assign_cur%NOTFOUND THEN
				l_assignment_status := 'NEW';
			else
				if (
			(
			(p_start_date is not null and l_start_date is not null and
			 trim(l_start_date) <> trim(p_start_date)) OR
 			(p_start_date is not null and l_start_date is null) OR
			(p_start_date is null and l_start_date is not null)
			) OR
			(
			(p_end_date is not null and l_end_date is not null and
			 trim(l_end_date) <> trim(p_end_date)) OR
 			(p_end_date is not null and l_end_date is null) OR
			(p_end_date is null and l_end_date is not null)
			) OR
			(l_priority <> l_f_priority)) then

					l_assignment_status := 'UPDATE';
				else
					l_assignment_status := 'CURRENT';
				end if;
			end if;

			close l_supplier_assign_cur;
		end if;

		l_step := 13;
		if p_request_type = 'ADDRESS' then

			l_step := 14;
			if p_party_site_id is null AND p_address_request_id is null then
				return;
			end if;

			l_step :=15;
			if p_party_site_id is not null then
				l_step := 7;
				open l_address_assign_cur;
				fetch l_address_assign_cur into l_priority, l_start_date, l_end_date;
				l_step := 8;
				if l_address_assign_cur%NOTFOUND THEN
					l_assignment_status := 'NEW';
				else

				if (
			(
			(p_start_date is not null and l_start_date is not null and
			 trim(l_start_date) <> trim(p_start_date) ) OR
 			(p_start_date is not null and l_start_date is null) OR
			(p_start_date is null and l_start_date is not null)
			) OR
			(
			(p_end_date is not null and l_end_date is not null and
			trim(l_end_date) <> trim(p_end_date)) OR
 			(p_end_date is not null and l_end_date is null) OR
			(p_end_date is null and l_end_date is not null)
			) OR
			(l_priority <> l_f_priority)) then

						l_assignment_status := 'UPDATE';
					else
						l_assignment_status := 'CURRENT';
					end if;
				end if;
				close l_address_assign_cur;
			else
				l_step := 9;
				if p_address_request_id is not null then
					l_assignment_status := 'NEW';
				end if;
			end if;

		end if;
	else
		l_step := 10;
		l_assignment_status := 'NEW';
	end if;
	l_step := 11;


	-- Now find the assignment if not provided.
	if p_assignment_id is null then
        	open l_exist_assign_req_cur;
        	fetch l_exist_assign_req_cur into l_assignment_id;
        	close l_exist_assign_req_cur;
	else
		l_assignment_id := p_assignment_id;
	end if;

	if l_assignment_id is not null then
		l_step := 19;
		POS_SBD_TBL_PKG.update_row_pos_acnt_summ_req (
		  p_assignment_id	   => l_assignment_id
		, p_assignment_request_id  => l_assignment_request_id
		, p_ext_bank_account_id    => p_ext_bank_account_id
		, p_account_request_id     => p_account_request_id
		, p_start_date             => p_start_date
		, p_end_date               => p_end_date
		, p_priority               => l_f_priority
		, p_assignment_status      => l_assignment_status
		, x_status        	   => x_status
		, x_exception_msg          => x_exception_msg
		);

	else
		l_step := 20;
		POS_SBD_TBL_PKG.insert_row_pos_acnt_summ_req (
		  p_assignment_request_id  => l_assignment_request_id
		, p_ext_bank_account_id    => p_ext_bank_account_id
		, p_account_request_id     => p_account_request_id
		, p_start_date             => p_start_date
		, p_end_date               => p_end_date
		, p_priority               => l_f_priority
		, p_assignment_status      => l_assignment_status
		, x_assignment_id	   => l_assignment_id
		, x_status        	   => x_status
		, x_exception_msg          => x_exception_msg
		);

	end if;

	l_step := 21;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End supplier_update_assignment ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20026, x_exception_msg, true);
END supplier_update_assignment;

/*
 * The accounts which can be rejected are NEW, CHANGE_PENDING, IN_VERIFICATION and CORRECTED
 */
PROCEDURE buyer_reject_account (
  p_account_request_id in NUMBER
, p_object_version_number in number
, p_note_from_buyer in varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS


	cursor l_account_request_cur is
	select temp.status, req.object_version_number, req.temp_ext_bank_acct_id, pmap.vendor_id,
	temp.bank_account_num, temp.bank_name
	from pos_acnt_gen_req req, iby_temp_ext_bank_accts temp, pos_supplier_mappings pmap
	where req.account_request_id = p_account_request_id
	and temp.temp_ext_bank_acct_id = req.temp_ext_bank_acct_id
	and pmap.mapping_id = req.mapping_id;

	l_account_request_rec l_account_request_cur%ROWTYPE;

	l_step number;
	l_status iby_temp_ext_bank_accts.status%TYPE;
	l_object_version_number pos_acnt_gen_req.object_version_number%TYPE;
	l_temp_ext_bank_acct_id iby_temp_ext_bank_accts.temp_ext_bank_acct_id%TYPE;


        l_itemtype    wf_items.item_type%TYPE;
        l_itemkey     wf_items.item_key%TYPE;

	l_bank_account_number iby_temp_ext_bank_accts.bank_account_num%TYPE;
	l_bank_name iby_temp_ext_bank_accts.bank_name%TYPE;
	l_vendor_id po_vendors.vendor_id%TYPE;
	l_ntf_status iby_temp_ext_bank_accts.status%TYPE;

BEGIN

	x_status := 'E';
	l_step := 0;


	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Begin buyer_reject_account ');
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_account_request_id ' || p_account_request_id);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_object_version_number ' || p_object_version_number);
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' p_note_from_buyer ' || p_note_from_buyer);
	END IF;

	open l_account_request_cur;
	fetch l_account_request_cur into l_account_request_rec;
		if l_account_request_cur%NOTFOUND then
			close l_account_request_cur;
			return;
		end if;

		l_status := l_account_request_rec.status;
		l_object_version_number := l_account_request_rec.object_version_number;
		l_temp_ext_bank_acct_id := l_account_request_rec.temp_ext_bank_acct_id;
		l_bank_account_number := l_account_request_rec.bank_account_num;
		l_bank_name := l_account_request_rec.bank_name;
		l_vendor_id := l_account_request_rec.vendor_id;

	close l_account_request_cur;

	l_step := 1;

	if l_status = 'NEW' then
		l_step := 2;

		POS_SBD_PKG.buyer_remove_account (
		  p_account_request_id => p_account_request_id
		, p_object_version_number  => p_object_version_number
		, x_status        => x_status
		, x_exception_msg => x_exception_msg
		);
		l_ntf_status := 'REJECTED';

	end if;

	if l_status = 'IN_VERIFICATION' OR l_status = 'CORRECTED' then
		l_step := 3;
		update iby_temp_ext_bank_accts
		set status = 'VERIFICATION_FAILED', note_alt = p_note_from_buyer
		where temp_ext_bank_acct_id = l_temp_ext_bank_acct_id;
		l_ntf_status := 'VERIFICATION_FAILED';
	end if;

	if l_status = 'CHANGE_PENDING' then

		l_step := 4;
		POS_SBD_IBY_PKG.remove_iby_temp_account
		(
		  p_iby_temp_ext_bank_account_id => l_temp_ext_bank_acct_id
		, x_status        => x_status
		, x_exception_msg => x_exception_msg
		);

		l_step := 5;
		POS_SBD_TBL_PKG.del_row_pos_acnt_gen_req (
		  p_account_request_id    => p_account_request_id
		, x_status        => x_status
		, x_exception_msg => x_exception_msg
		);

		update pos_acnt_addr_summ_req
		set account_request_id = null
		where account_request_id = p_account_request_id;

		l_ntf_status := 'REJECTED';

	end if;

	-- Send the notifications.
	pos_spm_wf_pkg1.notify_sup_on_acct_action
		  (p_bank_account_number => l_bank_account_number,
		   p_vendor_id           => l_vendor_id,
		   p_bank_name           => l_bank_name,
		   p_request_status      => l_ntf_status,
		   p_note                => p_note_from_buyer,
		   x_itemtype            => l_itemtype,
		   x_itemkey             => l_itemkey
		   );

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End buyer_reject_account ');
	END IF;

	x_status := 'S';

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20027, x_exception_msg, true);
END buyer_reject_account;

PROCEDURE update_payment_pref(
  p_payment_preference_id     IN NUMBER
, p_party_id                  IN NUMBER
, p_party_site_id             IN NUMBER
, p_payment_currency_code     IN VARCHAR2
, p_invoice_currency_code     IN VARCHAR2
, p_payment_method            IN VARCHAR2
, p_notification_method       IN VARCHAR2
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step NUMBER;

cursor l_current_payment_cur is
select payment_preference_id from pos_acnt_pay_pref
where party_id = p_party_id
and party_site_id = p_party_site_id;

l_payment_preference_id pos_acnt_pay_pref.payment_preference_id%TYPE;
l_notification_method POS_ACNT_PAY_PREF.notification_method%TYPE;

BEGIN

-- Change the notification preference method
if p_notification_method is not null AND p_notification_method = 'NONE' then
 l_notification_method := null;
else
 l_notification_method := p_notification_method;
end if;

l_step := 0;
-- If payment_preference_id is null then make an attempt to find one

if p_payment_preference_id is null then
	open l_current_payment_cur;
	fetch  l_current_payment_cur into l_payment_preference_id;
	close l_current_payment_cur;
else
	l_payment_preference_id := p_payment_preference_id;
end if;

l_step := 1;

if l_payment_preference_id is null then

l_step := 2;

  select POS_ACNT_PAY_PREF_S.nextval into l_payment_preference_id from dual;
-- Create a row

l_step:= 3;

  insert into POS_ACNT_PAY_PREF (
     payment_preference_id
   , party_id
   , party_site_id
   , creation_date
   , created_by
   , last_update_date
   , last_updated_by
   , last_update_login
   , object_version_number
   , payment_method
   , notification_method
   , payment_currency_code
   , invoice_currency_code
  )
  values
  (
    l_payment_preference_id
  , p_party_id
  , p_party_site_id
  , sysdate -- creation_date
  , fnd_global.user_id -- created_by
  , sysdate -- last_update_date
  , fnd_global.user_id -- last_updated_by
  , fnd_global.login_id -- last_update_login
  , 1
  , p_payment_method
  , l_notification_method
  , p_payment_currency_code
  , p_invoice_currency_code
  );

else

l_step := 4;
-- Update the row
    update pos_acnt_pay_pref set
     last_update_date = sysdate
   , last_updated_by = fnd_global.user_id
   , last_update_login  = fnd_global.login_id
   , payment_currency_code = p_payment_currency_code
   , invoice_currency_code = p_invoice_currency_code
   , notification_method = p_notification_method
   , payment_method = p_payment_method
   where payment_preference_id = l_payment_preference_id;

end if;

x_status := 'S';

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20028, x_exception_msg, true);
END update_payment_pref;

/* This procedure removes the account assignment request if all are current.
 *
 */
PROCEDURE supplier_reset_assignment(
  p_mapping_id             IN NUMBER
, p_party_site_id          IN NUMBER
, p_address_request_id     IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS

l_step number;
l_assignment_request_id number;
l_assignment_id number;

cursor l_is_all_current is
select addr.assignment_request_id from pos_acnt_addr_req addr
where addr.mapping_id = p_mapping_id
and (
(addr.request_type = 'SUPPLIER' and p_address_request_id is null and p_address_request_id is null) OR
(addr.request_type = 'ADDRESS' and addr.party_site_id = p_party_site_id and p_party_site_id is not null and addr.party_site_id is not null) OR
(addr.request_type = 'ADDRESS' and addr.address_request_id = p_address_request_id and p_address_request_id is not null and addr.address_request_id is not null)
)
and addr.REQUEST_STATUS = 'PENDING'
and not exists (select 1 from pos_acnt_addr_summ_req summ
		where addr.assignment_request_id = summ.assignment_request_id
		and summ.assignment_status <> ('CURRENT')
		and rownum = 1);

cursor l_assignment_id_cur is
select assignment_id from pos_acnt_addr_summ_req
where assignment_request_id = l_assignment_request_id;

l_assignment_id_rec l_assignment_id_cur%ROWTYPE;

BEGIN
	l_step := 0;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Start supplier_reset_assignment ');
	END IF;

	open l_is_all_current;
	fetch  l_is_all_current into l_assignment_request_id;
	l_step := 1;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_assignment_request_id ' || l_assignment_request_id);
	END IF;

	if l_is_all_current%FOUND then

		l_step := 2;
		for l_assignment_id_rec in l_assignment_id_cur loop

		l_step := 3;
  		l_assignment_id := l_assignment_id_rec.assignment_id;

		IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      			FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' l_assignment_id ' || l_assignment_id);
		END IF;

      		POS_SBD_TBL_PKG.del_row_pos_acnt_summ_req (
		   p_assignment_id => l_assignment_id
		 , x_status        => x_status
		 , x_exception_msg => x_exception_msg
		 );

		end loop;
		l_step := 4;

		POS_SBD_TBL_PKG.del_row_pos_acnt_addr_req (
	  	   p_assignment_request_id => l_assignment_request_id
		 , x_status        => x_status
		 , x_exception_msg => x_exception_msg
		 );

	end if;
	close l_is_all_current;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End supplier_reset_assignment ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20024, x_exception_msg, true);
END supplier_reset_assignment;


PROCEDURE sbd_handle_address_apv(
  p_address_request_id     IN NUMBER
, p_party_site_id          IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
)
IS
l_step number;

BEGIN

	l_step := 0;
	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' Start supplier_reset_assignment ');
	END IF;

	if p_address_request_id is null OR p_party_site_id is null then
		raise_application_error(-20032, 'Null values passed to sbd_handle_address_apv', true);
	end if;

	x_status := 'S';
	l_step := 1;

	update pos_acnt_addr_req
	set party_site_id = p_party_site_id, address_request_id = null
	where address_request_id = p_address_request_id;

	l_step := 2;

	IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      		FND_LOG.string(fnd_log.level_statement, g_log_module_name,
			' End supplier_reset_assignment ');
	END IF;

EXCEPTION

    WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure at step ' || l_step || Sqlerrm;
      raise_application_error(-20031, x_exception_msg, true);
END sbd_handle_address_apv;

/*Added for bug#16230242*/

procedure checkDupSupBankAcct( p_mapping_id in NUMBER
, p_BANK_ID in NUMBER
, p_BRANCH_ID in NUMBER
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2)
IS
	l_end_date DATE;
	l_start_date DATE;
	l_ext_bank_account_id IBY_TEMP_EXT_BANK_ACCTS.EXT_BANK_ACCOUNT_ID%TYPE;
    l_party_id           ap_suppliers.party_id%TYPE;
    l_supplier_name      ap_suppliers.vendor_name%TYPE;
    l_supplier_number    ap_suppliers.segment1%TYPE;
    l_msg_count NUMBER;
    l_msg_data varchar(2000);
   	l_record_type IBY_FNDCPT_COMMON_PUB.Result_rec_type;




	CURSOR c_supplier(p_acct_id NUMBER) IS
       SELECT owners.account_owner_party_id
           FROM iby_pmt_instr_uses_all instrument,
                IBY_ACCOUNT_OWNERS owners,
                iby_external_payees_all payees
           WHERE
           owners.primary_flag = 'Y' AND
           owners.ext_bank_account_id = p_acct_id AND
           owners.ext_bank_account_id = instrument.instrument_id AND
           payees.ext_payee_id = instrument.ext_pmt_party_id AND
           payees.payee_party_id = owners.account_owner_party_id;


begin
	if p_BANK_ID is not null and p_BRANCH_ID is not null and
	   p_EXT_BANK_ACCOUNT_ID is null
	   then
		IBY_EXT_BANKACCT_PUB.check_ext_acct_exist(
			    p_api_version       => 1.0,
    			p_init_msg_list     => FND_API.G_FALSE,
			    p_bank_id	    => p_BANK_ID,
    			p_branch_id         => p_BRANCH_ID,
        		p_acct_number       => p_bank_account_number,
        		p_acct_name         => p_bank_account_name,
        		p_currency          => p_currency_code,
			    p_country_code	    => p_country_code,
    			x_acct_id           => l_EXT_BANK_ACCOUNT_ID,
        		x_start_date        => l_start_date,
       			x_end_date          => l_end_date,
        		x_return_status     => x_status,
    			x_msg_count         => l_msg_count,
    			x_msg_data          => l_msg_data,
    			x_response          => l_record_type);

		if l_ext_bank_account_id is not null then
       			fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT');
				    fnd_msg_pub.add;
				OPEN c_supplier(l_ext_bank_account_id);
				FETCH c_supplier INTO l_party_id;
				 IF l_party_id IS NOT NULL THEN
			    	SELECT vendor_name, segment1
			    	INTO l_supplier_name, l_supplier_number
				    FROM ap_suppliers
				    WHERE party_id = l_party_id;
				   fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT_SUPPLIER');
				   fnd_message.set_Token('SUPPLIER',l_supplier_name);
				   fnd_message.set_Token('SUPPLIERNUMBER',l_supplier_number);
				   fnd_msg_pub.add;
                 END IF;
                CLOSE c_supplier;
               X_STATUS := fnd_api.g_ret_sts_error;
               RAISE fnd_api.g_exc_error;
		     end if;
	     end if;

		 EXCEPTION

       WHEN OTHERS THEN
      X_STATUS  :='E';
      x_exception_msg := 'Failure in checkDupSupBankAcct ' || Sqlerrm;
      raise_application_error(-20031, x_exception_msg, true);

END checkDupSupBankAcct;

END POS_SBD_PKG;

/
