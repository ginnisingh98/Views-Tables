--------------------------------------------------------
--  DDL for Package Body CE_CP_OA_XTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CP_OA_XTR_PKG" AS
/* $Header: cecputlb.pls 120.3 2006/01/31 11:19:19 svali ship $ */

FUNCTION FIND_COMPANY_CODE(X_bank_account_id NUMBER) RETURN VARCHAR2 IS
  result XTR_BANK_ACCOUNTS.party_code%TYPE;
BEGIN

  BEGIN
    SELECT party_code
    INTO   result
    FROM   XTR_BANK_ACCOUNTS
    WHERE  nvl(ap_bank_account_id, dummy_bank_account_id) = X_bank_account_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      result := null;
  END;

  return result;

END FIND_COMPANY_CODE;

PROCEDURE XTR_GEN_EXPOSURES(
		X_bank_account_id 	IN	VARCHAR2,
		X_account_number	IN	VARCHAR2,
		X_amount		IN	VARCHAR2,
		X_base_amount		IN	VARCHAR2,
		X_currency_code		IN	VARCHAR2,
		X_rate			IN	VARCHAR2,
		X_exposure_type		IN	VARCHAR2,
		X_portfolio_code	IN	VARCHAR2,
		X_trx_date		IN	DATE,
		X_comments		IN	VARCHAR2,
		X_user_id		IN	VARCHAR2) IS
  rec   XTR_EXPOSURE_TRANSACTIONS%rowtype;
  error1	boolean;
  error2	boolean;
  error3	boolean;
  error4	boolean;
BEGIN
  rec.account_no := X_account_number;
  rec.amount := to_number(X_amount);
  if (rec.amount >= 0) then
    rec.action_code := 'REC';
  else
    rec.action_code := 'PAY';
  end if;
  rec.amount := abs(rec.amount);
  rec.amount_hce := to_number(X_base_amount);
  rec.currency := X_currency_code;
  if (X_rate is not null) then
    rec.avg_rate := to_number(X_rate);
  end if;
  rec.company_code := find_company_code(to_number(X_bank_account_id));
  rec.created_by := to_number(X_user_id);
  rec.created_on := sysdate;
  rec.deal_type := 'EXP';
  rec.deal_subtype := 'FIRM';
  rec.exposure_type := X_exposure_type;
  rec.portfolio_code := X_portfolio_code;
  rec.settle_action_reqd := 'N';
  rec.value_date := X_trx_date;
  rec.internal_comments := X_comments;
  rec.purchasing_module := 'N';
  rec.cash_position_exposure := 'Y';

  XTR_EXP_TRANSFERS_PKG.transfer_exp_deals(rec, 'FORM', error1, error2, error3,
 	 error4);

END XTR_GEN_EXPOSURES;

FUNCTION INCLUDE_INDIC(
		X_WS_ID		IN	NUMBER,
		X_SRC_TYPE	IN	VARCHAR2)	RETURN	VARCHAR2 IS
  l_indic	VARCHAR2(1);
BEGIN

  BEGIN
    SELECT indicative_flag
    INTO   l_indic
    FROM   CE_CP_WORKSHEET_LINES
    WHERE  worksheet_header_id = X_WS_ID
    AND    source_type = X_SRC_TYPE
    AND    (trx_type is null OR trx_type = 'EXP');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_indic := 'N';
    WHEN OTHERS THEN
	NULL;
  END;

  RETURN l_indic;

END INCLUDE_INDIC;

PROCEDURE SUBMIT_GEN_PRIOR_DAY(
		X_WS_ID		IN	NUMBER,
		X_AS_OF_DATE	IN	VARCHAR2) IS
  l_request_id	NUMBER;
BEGIN

  l_request_id := FND_REQUEST.submit_request(
		'CE', 'CECPPRIB', '', '', NULL,
		to_char(X_WS_ID), X_AS_OF_DATE, 'N', '', '',
		FND_GLOBAL.local_chr(0), '', '', '', '',
		'','','','','','','','','','',
		'','','','','','','','','','',
		'','','','','','','','','','',
		'','','','','','','','','','',
		'','','','','','','','','','',
		'','','','','','','','','','',
		'','','','','','','','','','',
		'','','','','','','','','','',
		'','','','','','','','','','');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_CP_OA_XTR_PKG.submit_gen_prior_day');
    RAISE;

END SUBMIT_GEN_PRIOR_DAY;


PROCEDURE update_projected_balances(
			p_bank_account_id NUMBER,
			p_balance_date DATE,
			p_balance_amount NUMBER)
IS
BEGIN
	DELETE FROM ce_projected_balances
	WHERE bank_account_id=p_bank_account_id
	AND balance_date=p_balance_date;

	INSERT INTO ce_projected_balances
		(projected_balance_id,
		 bank_Account_id,
		 balance_date,
		 projected_balance,
		 last_update_date,
		 last_updated_by,
		 creation_date,
		 created_by,
		 last_update_login,
		 object_version_number)
	VALUES (ce_projected_Balances_s.nextval,
		p_bank_account_id,
		p_balance_date,
		p_balance_amount,
		sysdate,
		NVL(FND_GLOBAL.user_id,-1),
		sysdate,
		NVL(FND_GLOBAL.user_id,-1),
		NVL(FND_GLOBAL.user_id,-1),
		1);

END update_projected_balances;

END CE_CP_OA_XTR_PKG;

/
