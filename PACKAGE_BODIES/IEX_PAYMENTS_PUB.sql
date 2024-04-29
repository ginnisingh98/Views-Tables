--------------------------------------------------------
--  DDL for Package Body IEX_PAYMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PAYMENTS_PUB" as
/* $Header: iexpypyb.pls 120.15.12010000.2 2008/08/29 13:53:38 gnramasa ship $ */

PG_DEBUG NUMBER; -- := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_APP_ID   CONSTANT NUMBER := 695;
G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_PAYMENTS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpypyb.pls';
G_LOGIN_ID NUMBER; --  := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID NUMBER; --  := FND_GLOBAL.Conc_Program_Id;
G_USER_ID NUMBER; -- := FND_GLOBAL.User_Id;
G_REQUEST_ID NUMBER; --  := FND_GLOBAL.Conc_Request_Id;
G_ONLINE_CCPAY varchar2(5) := NVL(fnd_profile.value('IEX_ONLINE_CCPAY'),'N'); -- Fix a bug 5897567


procedure validate_input(
	P_PMT_REC			IN	IEX_PAYMENTS_PUB.PMT_REC_TYPE,
	P_PMTDTLS_TBL			IN	IEX_PAYMENTS_PUB.PMTDTLS_TBL_TYPE,
	P_PMTINSTR_REC			IN	IEX_PAYMENTS_PUB.PMTINSTR_REC_TYPE)

is
	l_count		number; --  := P_PMTDTLS_TBL.COUNT;
	l_amount	number;
begin
	l_count		:= P_PMTDTLS_TBL.COUNT;
	/* validate payment target */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: Validating P_PMT_REC.PAYMENT_TARGET');
	iex_debug_pub.LogMessage('validate_input: P_PMT_REC.PAYMENT_TARGET = ' || P_PMT_REC.PAYMENT_TARGET);
END IF;
	if P_PMT_REC.PAYMENT_TARGET is null or
	   (P_PMT_REC.PAYMENT_TARGET <> 'ACCOUNTS' and
	   P_PMT_REC.PAYMENT_TARGET <> 'INVOICES' and
	   P_PMT_REC.PAYMENT_TARGET <> 'CNSLD' and
	   P_PMT_REC.PAYMENT_TARGET <> 'CONTRACTS')
	then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: P_PMT_REC.PAYMENT_TARGET failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMT_REC.PAYMENT_TARGET');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate total_amount */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: Validating P_PMT_REC.TOTAL_AMOUNT');
	iex_debug_pub.LogMessage('validate_input: P_PMT_REC.TOTAL_AMOUNT = ' || P_PMT_REC.TOTAL_AMOUNT);
END IF;
	if P_PMT_REC.TOTAL_AMOUNT is null or P_PMT_REC.TOTAL_AMOUNT <= 0
	then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: P_PMT_REC.TOTAL_AMOUNT failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMT_REC.TOTAL_AMOUNT');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate currency */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: Validating P_PMT_REC.CURRENCY_CODE');
	iex_debug_pub.LogMessage('validate_input: P_PMT_REC.CURRENCY_CODE = ' || P_PMT_REC.CURRENCY_CODE);
END IF;
	if P_PMT_REC.CURRENCY_CODE is null
	then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: P_PMT_REC.CURRENCY_CODE failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMT_REC.CURRENCY_CODE');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate exchange_rate_type */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: P_PMT_REC.PAYMENT_TARGET = ' || P_PMT_REC.PAYMENT_TARGET);
END IF;
	if P_PMT_REC.PAYMENT_TARGET = 'ACCOUNTS' or P_PMT_REC.PAYMENT_TARGET = 'INVOICES'
	then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: Validating P_PMT_REC.EXCHANGE_RATE_TYPE');
		iex_debug_pub.LogMessage('validate_input: P_PMT_REC.EXCHANGE_RATE_TYPE = ' || P_PMT_REC.EXCHANGE_RATE_TYPE);
END IF;
		if P_PMT_REC.EXCHANGE_RATE_TYPE is null
		then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: P_PMT_REC.EXCHANGE_RATE_TYPE failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMT_REC.EXCHANGE_RATE_TYPE');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: Validating P_PMT_REC.EXCHANGE_DATE');
		iex_debug_pub.LogMessage('validate_input: P_PMT_REC.EXCHANGE_DATE = ' || P_PMT_REC.EXCHANGE_DATE);
END IF;
		if P_PMT_REC.EXCHANGE_DATE is null
		then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: P_PMT_REC.EXCHANGE_DATE failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMT_REC.EXCHANGE_DATE');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;

	if P_PMT_REC.PAYMENT_TARGET = 'CNSLD' or P_PMT_REC.PAYMENT_TARGET = 'CONTRACTS'	 then
		/* validate payee_id */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: Validating P_PMT_REC.PAYEE_ID');
		iex_debug_pub.LogMessage('validate_input: P_PMT_REC.PAYEE_ID = ' || P_PMT_REC.PAYEE_ID);
END IF;
		if P_PMT_REC.PAYEE_ID is null
		then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: P_PMT_REC.PAYEE_ID failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMT_REC.PAYEE_ID');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;

	/* validate payment details */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL.COUNT');
	iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL.COUNT = ' || P_PMTDTLS_TBL.COUNT);
END IF;
	if l_count = 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL.COUNT failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL.COUNT');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: Validating payment details');
END IF;
	FOR i IN 1..l_count LOOP
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: Details record ' || i);
		iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL(i).AMOUNT');
		iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).AMOUNT = ' || P_PMTDTLS_TBL(i).AMOUNT);
END IF;
		if P_PMTDTLS_TBL(i).AMOUNT is null or P_PMTDTLS_TBL(i).AMOUNT <= 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).AMOUNT failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL(' || i || ').AMOUNT');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
		l_amount := l_amount + P_PMTDTLS_TBL(i).AMOUNT;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID');
		iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID = ' || P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID);
END IF;
		if P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID failed validation');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL(' || i || ').CUST_ACCOUNT_ID');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;

		if P_PMT_REC.PAYMENT_TARGET = 'ACCOUNTS' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL(i).CUST_SITE_USE_ID');
			iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID = ' || P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID);
END IF;
			if P_PMTDTLS_TBL(i).CUST_SITE_USE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CUST_SITE_USE_ID failed validation');
END IF;
				FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
				FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
				FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL(' || i || ').CUST_SITE_USE_ID');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			end if;
		elsif P_PMT_REC.PAYMENT_TARGET = 'INVOICES' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL(i).CUST_SITE_USE_ID');
			iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CUST_SITE_USE_ID = ' || P_PMTDTLS_TBL(i).CUST_SITE_USE_ID);
END IF;
			if P_PMTDTLS_TBL(i).CUST_SITE_USE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CUST_SITE_USE_ID failed validation');
END IF;
				FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
				FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
				FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL(' || i || ').CUST_SITE_USE_ID');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID');
			iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID = ' || P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID);
END IF;
			if P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID failed validation');
END IF;
				FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
				FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
				FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL(' || i || ').PAYMENT_SCHEDULE_ID');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			end if;
		elsif P_PMT_REC.PAYMENT_TARGET = 'CNSLD' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID');
			iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID = ' || P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID);
END IF;
			if P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID failed validation');
END IF;
				FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
				FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
				FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL(' || i || ').CNSLD_INVOICE_ID');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			end if;
		elsif P_PMT_REC.PAYMENT_TARGET = 'CONTRACTS' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: Validating P_PMTDTLS_TBL(i).CONTRACT_ID');
			iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CONTRACT_ID = ' || P_PMTDTLS_TBL(i).CONTRACT_ID);
END IF;
			if P_PMTDTLS_TBL(i).CONTRACT_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage('validate_input: P_PMTDTLS_TBL(i).CONTRACT_ID failed validation');
END IF;
				FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
				FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
				FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTDTLS_TBL(' || i || ').CONTRACT_ID');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			end if;
		end if;
	END LOOP;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: Validating P_PMT_REC.TOTAL_AMOUNT and sum of P_PMTDTLS_TBL(i).AMOUNT');
	iex_debug_pub.LogMessage('validate_input: l_amount = ' || l_amount);
	iex_debug_pub.LogMessage('validate_input: P_PMT_REC.TOTAL_AMOUNT = ' ||P_PMT_REC.TOTAL_AMOUNT);
END IF;
	if l_amount <> P_PMT_REC.TOTAL_AMOUNT then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: l_amount <> P_PMT_REC.TOTAL_AMOUNT failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMT_REC.TOTAL_AMOUNT');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	/* validate payment instrument */
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('validate_input: Validating P_PMTINSTR_REC.USE_INSTRUMENT');
	iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.USE_INSTRUMENT = ' || P_PMTINSTR_REC.USE_INSTRUMENT);
END IF;
	if P_PMTINSTR_REC.USE_INSTRUMENT is null or
	   (P_PMTINSTR_REC.USE_INSTRUMENT <> 'CC' and
	   P_PMTINSTR_REC.USE_INSTRUMENT <> 'BA')
	then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.USE_INSTRUMENT failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTINSTR_REC.USE_INSTRUMENT');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

/* -- begin - uptake funds capture  changes - varangan
	if P_PMTINSTR_REC.USE_INSTRUMENT = 'CC' then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('validate_input: Validating CC data');
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM = ' || P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM);
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.CREDITCARDINSTR.CC_TYPE = ' || P_PMTINSTR_REC.CREDITCARDINSTR.CC_TYPE);
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE = ' || P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE);
        END IF;
		if P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM is null or
	   	   P_PMTINSTR_REC.CREDITCARDINSTR.CC_TYPE is null or
	   	   P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE is null
		then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: CC instrument failed validation');
        END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTINSTR_REC.CREDITCARDINSTR');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	elsif P_PMTINSTR_REC.USE_INSTRUMENT = 'BA' then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage('validate_input: Validating BA data');
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID = ' || P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID);
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM = ' || P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM);
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_TYPE = ' || P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_TYPE);
		iex_debug_pub.LogMessage('validate_input: P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_HOLDERNAME = ' || P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_HOLDERNAME);
        END IF;
		if P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID is null or
	   	   P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM is null or
	   	   P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_TYPE is null or
	   	   P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_HOLDERNAME is null
		then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('validate_input: BA instrument failed validation');
            END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
			FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.CREATE_PAYMENT');
			FND_MESSAGE.SET_TOKEN('API_PARAMETER', 'P_PMTINSTR_REC.BANKACCTINSTR');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if; */

end;

function get_fun_currency return varchar2 is
	l_return_status                  VARCHAR2(1);
	l_msg_count                      NUMBER;
    	l_msg_data                       VARCHAR2(32767);
    	l_fun_currency		     VARCHAR2(15);
begin
	-- get functional currency
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('get_fun_currency: Begin');
END IF;
	IEX_CURRENCY_PVT.GET_FUNCT_CURR(p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit => FND_API.G_FALSE,
		P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_functional_currency => l_fun_currency);

	-- check for errors
	IF l_return_status<>'S' THEN
		null;
	END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('get_fun_currency: l_fun_currency = ' || l_fun_currency);
END IF;
	return l_fun_currency;
end;

PROCEDURE GET_PAYER_INFO(P_PAYER_PARTY_REL_ID	IN	NUMBER,
			P_PAYER_PARTY_ORG_ID	IN	NUMBER,
			P_PAYER_PARTY_PER_ID	IN	NUMBER,
			X_NOTE_PAYER_TYPE	OUT NOCOPY	VARCHAR2,
			X_NOTE_PAYER_NUM_ID	OUT NOCOPY	NUMBER,
			X_PAYER_NUM_ID		OUT NOCOPY	NUMBER,
			X_PAYER_ID		OUT NOCOPY	VARCHAR2,
			X_PAYER_NAME		OUT NOCOPY	VARCHAR2)
IS
	CURSOR get_payer_name_crs(p_party_id number) IS
        select PARTY_NAME
		from hz_parties
		where party_id = p_party_id;

BEGIN

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('GET_PAYER_INFO: Begin of GET_PAYER_INFO');
	iex_debug_pub.LogMessage('GET_PAYER_INFO: PAYER_PARTY_REL_ID = ' || P_PAYER_PARTY_REL_ID);
	iex_debug_pub.LogMessage('GET_PAYER_INFO: PAYER_PARTY_ORG_ID = ' || P_PAYER_PARTY_ORG_ID);
	iex_debug_pub.LogMessage('GET_PAYER_INFO: PAYER_PARTY_PER_ID = ' || P_PAYER_PARTY_PER_ID);
END IF;

	if P_PAYER_PARTY_REL_ID is not null and
	   P_PAYER_PARTY_ORG_ID is not null and
	   P_PAYER_PARTY_PER_ID is not null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('GET_PAYER_INFO: First case');
END IF;
			X_NOTE_PAYER_NUM_ID := P_PAYER_PARTY_REL_ID;
			X_NOTE_PAYER_TYPE := 'PARTY_RELATIONSHIP';
			X_PAYER_NUM_ID := P_PAYER_PARTY_ORG_ID;
	else
	   if P_PAYER_PARTY_REL_ID is null and
			P_PAYER_PARTY_ORG_ID is not null and
			P_PAYER_PARTY_PER_ID is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage('GET_PAYER_INFO: Second case');
END IF;
				X_NOTE_PAYER_NUM_ID := P_PAYER_PARTY_ORG_ID;
				X_NOTE_PAYER_TYPE := 'PARTY_ORGANIZATION';
				X_PAYER_NUM_ID := P_PAYER_PARTY_ORG_ID;
	   elsif P_PAYER_PARTY_REL_ID is null and
			P_PAYER_PARTY_ORG_ID is null and
			P_PAYER_PARTY_PER_ID is not null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage('Third case');
END IF;
				X_NOTE_PAYER_NUM_ID := P_PAYER_PARTY_PER_ID;
				X_NOTE_PAYER_TYPE := 'PARTY_PERSON';
				X_PAYER_NUM_ID := P_PAYER_PARTY_PER_ID;
	   else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage('GET_PAYER_INFO: Neither');
END IF;
			FND_MESSAGE.SET_NAME('IEX','IEX_WRONG_PARTY');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
	   end if;
	end if;

	X_PAYER_ID := to_char(X_PAYER_NUM_ID);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('GET_PAYER_INFO: NOTE_PAYER_NUM_ID = ' || X_NOTE_PAYER_NUM_ID);
	iex_debug_pub.LogMessage('GET_PAYER_INFO: NOTE_PAYER_TYPE = ' || X_NOTE_PAYER_TYPE);
	iex_debug_pub.LogMessage('GET_PAYER_INFO: PAYER_NUM_ID = ' || X_PAYER_NUM_ID);
	iex_debug_pub.LogMessage('GET_PAYER_INFO: PAYER_ID = ' || X_PAYER_ID);
END IF;

	OPEN get_payer_name_crs(X_PAYER_NUM_ID);
	FETCH get_payer_name_crs INTO X_PAYER_NAME;

	if get_payer_name_crs%NOTFOUND then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('No party');
END IF;
		CLOSE get_payer_name_crs;
		FND_MESSAGE.SET_NAME('IEX','IEX_WRONG_PARTY');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;
	CLOSE get_payer_name_crs;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage('GET_PAYER_INFO: PAYER_NAME = ' || X_PAYER_NAME);
END IF;
END;

procedure get_ar_payment_method(p_payment_type in varchar2,
				x_payment_method out NOCOPY varchar2,
				x_payment_method_id out NOCOPY number)
is
    l_api_name                  CONSTANT VARCHAR2(30) := 'GET_AR_PAYMENT_METHOD';

begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Start of API');
END IF;
	x_payment_method := null;
	x_payment_method_id := null;

	if p_payment_type = 'CC' then

		x_payment_method := fnd_profile.value('IEX_CCARD_REMITTANCE');
		if x_payment_method is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': failed to get CC remittance');
END IF;
			FND_MESSAGE.SET_NAME('IEX', 'IEX_NO_CC_REMITTANCE');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
		x_payment_method_id := to_number(x_payment_method);

	elsif p_payment_type = 'BA' then

		x_payment_method := fnd_profile.value('IEX_EFT_REMITTANCE');
		if x_payment_method is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': failed to get BA remittance');
END IF;
			FND_MESSAGE.SET_NAME('IEX', 'IEX_NO_EFT_REMITTANCE');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
		x_payment_method_id := to_number(x_payment_method);

	end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': x_payment_method = ' || x_payment_method);
	iex_debug_pub.LogMessage(l_api_name || ': x_payment_method_id = ' || x_payment_method_id);
	iex_debug_pub.LogMessage(l_api_name || ': End of API');
END IF;
end;

procedure create_ar_cc_bank_account(p_cust_account_id in number,
				    p_cc_number in varchar2,
				    p_cc_exp_date in date,
				    p_cc_holder_name in varchar2,
				    p_currency in varchar2,
				    p_party_id in number,
				    x_bank_account_id out NOCOPY number,
				    x_bank_account_uses_id out NOCOPY number,
				    x_branch_id out NOCOPY number)
is
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_AR_CC_BANK_ACCOUNT';
begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Start of API');
END IF;
	x_bank_account_id := null;
	x_bank_account_uses_id := null;
	x_branch_id := 1;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	--iex_debug_pub.LogMessage(l_api_name || ': CC number = ' || p_cc_number);
	iex_debug_pub.LogMessage(l_api_name || ': CC exp date = ' || p_cc_exp_date);
	iex_debug_pub.LogMessage(l_api_name || ': CC holder name = ' || p_cc_holder_name);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Creating cc bank account for cust_account_id ' || p_cust_account_id);
END IF;
/* obsoleted ar pkg ..fixed a bug 5130923
	arp_bank_pkg.process_cust_bank_account(
		p_trx_date           => trunc(sysdate),
		p_currency_code      => p_currency,
		p_cust_id            => p_cust_account_id,
		p_credit_card_num    => p_cc_number,
		p_exp_date           => p_cc_exp_date,
		p_acct_name          => p_cc_holder_name,
		p_bank_account_id    => x_bank_account_id,
		p_bank_account_uses_id => x_bank_account_uses_id,
		p_owning_party_id      => p_party_id,
		p_bank_branch_id       => x_branch_id,
		p_account_type         => 'BANK',
		p_payment_instrument   => 'CREDIT_CARD');      */


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(l_api_name || ': Successfully created cc bank account');
	iex_debug_pub.LogMessage(l_api_name || ': CC bank_account_id = ' || x_bank_account_id);
	iex_debug_pub.LogMessage(l_api_name || ': CC bank_account_uses_id = ' || x_bank_account_uses_id);
	iex_debug_pub.LogMessage(l_api_name || ': CC bank_branch_id = ' || x_branch_id);
	iex_debug_pub.LogMessage(l_api_name || ': End of API');
END IF;
end;

procedure create_ar_ba_bank_account(p_cust_account_id in number,
				    p_ba_routing_number in varchar,
				    p_ba_number in varchar2,
				    p_ba_type in varchar2,
				    p_ba_holder_name in varchar2,
				    p_currency in varchar2,
				    p_party_id in number,
				    x_bank_account_id out NOCOPY number,
				    x_bank_account_uses_id out NOCOPY number,
				    x_branch_id out NOCOPY number)
is
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_AR_BA_BANK_ACCOUNT';
begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Start of API');
END IF;
	x_bank_account_id := null;
	x_bank_account_uses_id := null;
	x_branch_id := null;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': BA routing = ' || p_ba_routing_number);
	iex_debug_pub.LogMessage(l_api_name || ': BA number = ' || p_ba_number);
	iex_debug_pub.LogMessage(l_api_name || ': BA type = ' || p_ba_type);
	iex_debug_pub.LogMessage(l_api_name || ': BA holder name = ' || p_ba_holder_name);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Validating routing number...');
END IF;

/* obsoleted ar pkg ..fixed a bug 5130923
	if ARP_BANK_DIRECTORY.is_routing_number_valid(p_routing_number => p_ba_routing_number) = 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage('Invalid routing number');
END IF;
		FND_MESSAGE.SET_NAME('IEX', 'IEX_INVALID_ROUTING_NUM');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;
*/


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Creating/selecting bank branch...');
END IF;

/* obsoleted ar pkg ..fixed a bug 5130923
	arp_bank_pkg.get_bank_branch_id(p_routing_number => p_ba_routing_number,
        				x_branch_party_id => x_branch_id);
*/

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': branch_id = ' || x_branch_id);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Creating ba bank account for cust_account_id ' || p_cust_account_id);
END IF;

/* obsoleted ar pkg ..fixed a bug 5130923
	arp_bank_pkg.process_cust_bank_account(
		p_trx_date           => trunc(sysdate),
	        p_currency_code      => p_currency,
	        p_cust_id            => p_cust_account_id,
	        p_credit_card_num    => p_ba_number,  				-- from account number on UI
	        p_exp_date           => null,
	        p_acct_name          => p_ba_holder_name, 			-- from holder name on UI
	        p_bank_account_id    => x_bank_account_id,
	        p_bank_account_uses_id => x_bank_account_uses_id,
	        p_owning_party_id      => p_party_id,
	        p_bank_branch_id       => x_branch_id, 				-- create branch with routing number from UI
	        p_account_type         => p_ba_type,  				-- from bank account type on UI
	        p_payment_instrument   => 'BANK_ACCOUNT');
*/


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage(l_api_name || ': Successfully created ba bank account');
	iex_debug_pub.LogMessage(l_api_name || ': BA bank_account_id = ' || x_bank_account_id);
	iex_debug_pub.LogMessage(l_api_name || ': BA bank_account_uses_id = ' || x_bank_account_uses_id);
	iex_debug_pub.LogMessage(l_api_name || ': BA bank_branch_id = ' || x_branch_id);
	iex_debug_pub.LogMessage(l_api_name || ': End of API');
END IF;
end;

PROCEDURE CREATE_AR_PAYMENT(
    P_API_VERSION		    	IN      NUMBER,
    P_INIT_MSG_LIST		    	IN      VARCHAR2,
    P_COMMIT                    	IN      VARCHAR2,
    P_VALIDATION_LEVEL	    		IN      NUMBER,
    X_RETURN_STATUS		    	OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 	OUT NOCOPY    NUMBER,
    X_MSG_DATA	    	    		OUT NOCOPY    VARCHAR2,
    P_PMT_REC			        IN	IEX_PAYMENTS_PUB.PMT_REC_TYPE,
    P_PMTDTLS_TBL			IN	IEX_PAYMENTS_PUB.PMTDTLS_TBL_TYPE,
    P_PMTINSTR_REC			IN	IEX_PAYMENTS_PUB.PMTINSTR_REC_TYPE,
    P_PMT_METHOD            IN NUMBER, -- Included by varangan for profile bug#4558547
    X_PMTRESP_REC			OUT NOCOPY	IEX_PAYMENTS_PUB.PMTRESP_REC_TYPE)
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_AR_PAYMENT';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(32767);

    TYPE cr_id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_cust_bank_acc_id			NUMBER;
    l_bank_account_uses_id		NUMBER;
    l_branch_id                 	NUMBER;
    l_cr_id_tab			        cr_id_tab;
    l_rowid                     	VARCHAR2(100);
    l_payment_id                	NUMBER := null;
    l_cr_id                     	NUMBER;
    i                           	NUMBER;
    j                           	NUMBER;
    l_del_pay_ref_id		    	NUMBER;
    l_pay_receipt_ref_id	    	NUMBER;
    l_ar_pay_method1		    	VARCHAR2(100);
    l_ar_pay_method			NUMBER;
    l_cr_number			        NUMBER;
    l_cr_number1			VARCHAR2(80);
    l_del_id			        NUMBER;
    l_note_payer_id			NUMBER;
    l_payer_num_id			NUMBER;
    l_payer_id			        VARCHAR2(80);
    l_payer_name			HZ_PARTIES.PARTY_NAME%TYPE;  --Changed the datatype for bug#5652085 by ehuh 2/28/07
    l_note_payer_type		    	VARCHAR2(100);
    l_context_tab			IEX_NOTES_PVT.CONTEXTS_TBL_TYPE;
    l_fun_currency			VARCHAR2(80);
    l_template_id			NUMBER;
    l_request_id   			number;
    l_autofulfill			varchar2(1);
    l_note_type			        varchar2(30);
    l_source_object_id			NUMBER;
    l_source_object_code		varchar2(20);

    l_call_payment_processor            varchar2(5);

    -- generate new payment
    CURSOR pay_genid_crs IS
    select IEX_PAYMENTS_S.NEXTVAL from dual;

    -- generate new del_pay_xref
    CURSOR dpx_genid_crs IS
    select IEX_DEL_PAY_XREF_S.NEXTVAL from dual;

    -- generate new pay_receipt
    CURSOR pad_genid_crs IS
    select IEX_PAY_RECEIPT_XREF_S.NEXTVAL from dual;

    -- generate new receipt number
    CURSOR rc_genid_crs IS
    select IEX_RECEIPT_NUMBER_S.NEXTVAL from dual;

    -- get del_id from iex_delinquencies table
    CURSOR get_delid_crs(p_payment_schedule_id number) IS
    select delinquency_id
    from iex_delinquencies
    where payment_schedule_id = p_payment_schedule_id;

BEGIN

  /* AR processing */
  BEGIN
        SAVEPOINT CREATE_AR_PAYMENT_PVT1;

   	-- Standard call to check for call compatibility
   	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  	END IF;

   	-- Initialize message list if p_init_msg_list is set to TRUE
   	IF FND_API.To_Boolean(p_init_msg_list) THEN
   		FND_MSG_PUB.initialize;
   	END IF;

   	-- Initialize API return status to success
   	l_return_status := FND_API.G_RET_STS_SUCCESS;

   	-- START OF BODY OF API
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': Start of API');
	END IF;

        -- Fix a bug 5897567 02/21/07 by Ehuh
        if G_ONLINE_CCPAY = 'Y' then l_call_payment_processor := FND_API.G_TRUE;
        else
            l_call_payment_processor := FND_API.G_FALSE;
        end if;


	/* validate all input parameters */
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': Before validate_input');
	END IF;

	validate_input(P_PMT_REC => P_PMT_REC,
			P_PMTDTLS_TBL => P_PMTDTLS_TBL,
			P_PMTINSTR_REC => P_PMTINSTR_REC);

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': After validate_input');
	END IF;

	/* validate payer parties and get payer info */
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': Before GET_PAYER_INFO');
	END IF;
	GET_PAYER_INFO(P_PAYER_PARTY_REL_ID => P_PMT_REC.PAYER_PARTY_REL_ID,
			P_PAYER_PARTY_ORG_ID => P_PMT_REC.PAYER_PARTY_ORG_ID,
			P_PAYER_PARTY_PER_ID => P_PMT_REC.PAYER_PARTY_PER_ID,
			X_NOTE_PAYER_TYPE => l_note_payer_type,
			X_NOTE_PAYER_NUM_ID => l_note_payer_id,
			X_PAYER_NUM_ID => l_payer_num_id,
			X_PAYER_ID => l_payer_id,
			X_PAYER_NAME => l_payer_name);

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': After GET_PAYER_INFO');
	    iex_debug_pub.LogMessage(l_api_name || ': GET_PAYER_INFO returns:');
	    iex_debug_pub.LogMessage(l_api_name || ': l_note_payer_type = ' || l_note_payer_type);
	    iex_debug_pub.LogMessage(l_api_name || ': l_note_payer_id = ' || l_note_payer_id);
	    iex_debug_pub.LogMessage(l_api_name || ': l_payer_num_id = ' || l_payer_num_id);
	    iex_debug_pub.LogMessage(l_api_name || ': l_payer_id = ' || l_payer_id);
	    iex_debug_pub.LogMessage(l_api_name || ': l_payer_name = ' || l_payer_name);
	END IF;

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': Creating IEX payment record...');
   	end if ;

    	-- generate new payment id
    	OPEN pay_genid_crs;
	FETCH pay_genid_crs INTO l_payment_id;
	CLOSE pay_genid_crs;

    	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	    iex_debug_pub.LogMessage(l_api_name || ': New payment_id = ' || l_payment_id);
	    iex_debug_pub.LogMessage(l_api_name || ': Before IEX_PAYMENTS_PKG.Insert_Row');
    	END IF;

	IEX_PAYMENTS_PKG.Insert_Row(
        	X_ROWID => l_rowid,
        	P_PAYMENT_ID => l_payment_id,
        	P_OBJECT_VERSION_NUMBER => 1.0,
        	P_PROGRAM_ID => 695,
	    	P_LAST_UPDATE_DATE => sysdate,
        	P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
	    	P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
        	P_CREATION_DATE => sysdate,
        	P_CREATED_BY => FND_GLOBAL.User_Id,
        	P_PAYMENT_METHOD_ID => null,
       		P_PAYMENT_METHOD => P_PMTINSTR_REC.USE_INSTRUMENT,
        	P_IPAYMENT_TRANS_ID => null,
        	P_IPAYMENT_STATUS => null,
        	P_PAY_SVR_CONFIRMATION => null,
        	P_CAMPAIGN_SCHED_ID => P_PMT_REC.CAMPAIGN_SCHED_ID,
        	p_TANGIBLE_ID => null,
        	p_PAYEE_ID => null,
        	p_RESOURCE_ID => P_PMT_REC.RESOURCE_ID,
        	P_ATTRIBUTE_CATEGORY => P_PMT_REC.ATTRIBUTES.ATTRIBUTE_CATEGORY,
        	P_ATTRIBUTE1 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE1,
        	P_ATTRIBUTE2 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE2,
        	P_ATTRIBUTE3 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE3,
        	P_ATTRIBUTE4 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE4,
        	P_ATTRIBUTE5 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE5,
        	P_ATTRIBUTE6 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE6,
        	P_ATTRIBUTE7 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE7,
        	P_ATTRIBUTE8 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE8,
        	P_ATTRIBUTE9 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE9,
        	P_ATTRIBUTE10 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE10,
        	P_ATTRIBUTE11 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE11,
        	P_ATTRIBUTE12 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE12,
        	P_ATTRIBUTE13 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE13,
        	P_ATTRIBUTE14 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE14,
        	P_ATTRIBUTE15 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE15);

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	   iex_debug_pub.LogMessage(l_api_name || ': After IEX_PAYMENTS_PKG.Insert_Row');
        End if ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	   iex_debug_pub.LogMessage(l_api_name || ': After') ;
        END IF;
   	X_PMTRESP_REC.PAYMENT_ID := l_payment_id;

    	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(l_api_name || ': l_payment_id=' || l_payment_id);
    	END IF;

	l_fun_currency := get_fun_currency;
	IF P_PMT_REC.PAYMENT_TARGET = 'ACCOUNTS' THEN



	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	       iex_debug_pub.LogMessage(l_api_name || ': Payment target ACCOUNTS');
            END IF;

	    -- run thru table of details, create bank accounts then create cash/apply receipts via AR APIs
	    FOR i IN 1..P_PMTDTLS_TBL.COUNT LOOP

            	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(l_api_name || ': processing payment details; loop ' || i);
            	END IF;

	        --Determine the Payment Instrument type that is used.
            	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		      iex_debug_pub.LogMessage(l_api_name || ': Payment instrument is ' || P_PMTINSTR_REC.USE_INSTRUMENT);
            	END IF;

        /*-- Begin - varangan - profile bug#4558547
          	get_ar_payment_method(p_payment_type => P_PMTINSTR_REC.USE_INSTRUMENT,
	    	      x_payment_method => l_ar_pay_method1,
	    	      x_payment_method_id => l_ar_pay_method);
        --   End- varangan - profile bug#4558547 */


	    /* commented for uptake funds transfer  --varangan
        	IF P_PMTINSTR_REC.USE_INSTRUMENT = 'CC' THEN

		    create_ar_cc_bank_account(p_cust_account_id => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
			p_cc_number => P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM,
			p_cc_exp_date => P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE,
			p_cc_holder_name => P_PMTINSTR_REC.CREDITCARDINSTR.CC_HOLDERNAME,
			p_currency => P_PMT_REC.CURRENCY_CODE,
			p_party_id => l_payer_id,
			x_bank_account_id => l_cust_bank_acc_id,
			x_bank_account_uses_id => l_bank_account_uses_id,
			x_branch_id => l_branch_id);

	        ELSIF P_PMTINSTR_REC.USE_INSTRUMENT = 'BA' THEN

		    create_ar_ba_bank_account(p_cust_account_id => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
			p_ba_routing_number => P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID,
			p_ba_number => P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM,
			p_ba_type => P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_TYPE,
			p_ba_holder_name => P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_HOLDERNAME,
			p_currency => P_PMT_REC.CURRENCY_CODE,
			p_party_id => l_payer_id,
			x_bank_account_id => l_cust_bank_acc_id,
			x_bank_account_uses_id => l_bank_account_uses_id,
			x_branch_id => l_branch_id);

            	END IF;
            commented for uptake funds transfer  --varangan */

	    	-- generate new cash receipt number
	    	OPEN rc_genid_crs;
	    	FETCH rc_genid_crs INTO l_cr_number;
	    	CLOSE rc_genid_crs;

	   	l_cr_number1 := 'IEX_' || to_char(l_cr_number);
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': New cr id = ' || l_cr_number1);
		    iex_debug_pub.LogMessage(l_api_name || ': Before AR_RECEIPT_API_PUB.CREATE_CASH');
		END IF;

		-- create cash receipts
		if l_fun_currency = P_PMT_REC.CURRENCY_CODE then
			/*AR_RECEIPT_API_PUB.CREATE_CASH(
			    P_API_VERSION => 1.0,
			    P_INIT_MSG_LIST => FND_API.G_FALSE,
			    P_COMMIT => FND_API.G_FALSE,
			    P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
			    P_AMOUNT => P_PMTDTLS_TBL(i).AMOUNT,
			    P_RECEIPT_METHOD_ID => l_ar_pay_method,
			    P_RECEIPT_NUMBER => l_cr_number1,
			    P_CUSTOMER_ID => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
			    P_CUSTOMER_SITE_USE_ID => P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
			    P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
			    P_CR_ID => L_CR_ID,
			    X_RETURN_STATUS => L_RETURN_STATUS,
			    X_MSG_COUNT => L_MSG_COUNT,
			    X_MSG_DATA => L_MSG_DATA);
            */


			AR_RECEIPT_API_PUB.CREATE_APPLY_ON_ACC(
			    P_API_VERSION => 1.0,
			    P_INIT_MSG_LIST => FND_API.G_FALSE,
			    P_COMMIT => FND_API.G_FALSE,
			    P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
			    P_AMOUNT => P_PMTDTLS_TBL(i).AMOUNT,
			    P_RECEIPT_METHOD_ID => P_PMT_METHOD , -- l_ar_pay_method, commented for profile bug#4558547
			    P_RECEIPT_NUMBER => l_cr_number1,
			    P_CUSTOMER_ID => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
			    P_CUSTOMER_SITE_USE_ID => P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
			    P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
			    P_CR_ID => L_CR_ID,
                            p_application_ref_num => NULL,
                            p_secondary_application_ref_id => NULL,
                            p_customer_reference => NULL,
                            p_customer_reason => NULL,
                            p_call_payment_processor => l_call_payment_processor, -- Fix a bug 5897567 02/06/07 by Ehuh
			    X_RETURN_STATUS => L_RETURN_STATUS,
			    X_MSG_COUNT => L_MSG_COUNT,
			    X_MSG_DATA => L_MSG_DATA,
			    -- Begin -- varangan --Bug4528444 -- included for payments uptake
                            p_payment_trxn_extension_id => P_PMTDTLS_TBL(i).TRX_EXTN_ID);
			    -- End -- varangan -- Bug4528444 --included for payments uptake
		else
            /*
			AR_RECEIPT_API_PUB.CREATE_CASH(
			    P_API_VERSION => 1.0,
			    P_INIT_MSG_LIST => FND_API.G_FALSE,
			    P_COMMIT => FND_API.G_FALSE,
			    P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
			    P_EXCHANGE_RATE_TYPE => P_PMT_REC.EXCHANGE_RATE_TYPE,
			    P_EXCHANGE_RATE_DATE => P_PMT_REC.EXCHANGE_DATE,
			    P_AMOUNT => P_PMTDTLS_TBL(i).AMOUNT,
			    P_RECEIPT_METHOD_ID => l_ar_pay_method,
			    P_RECEIPT_NUMBER => l_cr_number1,
			    P_CUSTOMER_ID => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
			    P_CUSTOMER_SITE_USE_ID => P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
			    P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
                    	    P_CR_ID => L_CR_ID,
			    X_RETURN_STATUS => L_RETURN_STATUS,
			    X_MSG_COUNT => L_MSG_COUNT,
			    X_MSG_DATA => L_MSG_DATA);
            */



			AR_RECEIPT_API_PUB.CREATE_APPLY_ON_ACC(
			    P_API_VERSION => 1.0,
			    P_INIT_MSG_LIST => FND_API.G_FALSE,
			    P_COMMIT => FND_API.G_FALSE,
			    P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
			    P_EXCHANGE_RATE_TYPE => P_PMT_REC.EXCHANGE_RATE_TYPE,
			    P_EXCHANGE_RATE_DATE => P_PMT_REC.EXCHANGE_DATE,
			    P_AMOUNT => P_PMTDTLS_TBL(i).AMOUNT,
			    P_RECEIPT_METHOD_ID => P_PMT_METHOD,  --l_ar_pay_method, commented for profile bug#4558547
			    P_RECEIPT_NUMBER => l_cr_number1,
			    P_CUSTOMER_ID => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
			    P_CUSTOMER_SITE_USE_ID => P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
			    P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
           	            P_CR_ID => L_CR_ID,
                            p_application_ref_num => NULL,
                            p_secondary_application_ref_id => NULL,
                            p_customer_reference => NULL,
                            p_customer_reason => NULL,
                            p_call_payment_processor => l_call_payment_processor, -- Fix a bug 5897567 02/06/07 by Ehuh
			    X_RETURN_STATUS => L_RETURN_STATUS,
			    X_MSG_COUNT => L_MSG_COUNT,
			    X_MSG_DATA => L_MSG_DATA,
			    -- Begin -- varangan --Bug4528444 -- included for payments uptake
                            p_payment_trxn_extension_id => P_PMTDTLS_TBL(i).TRX_EXTN_ID);
   			    -- End -- varangan --Bug4528444 -- included for payments uptake

		end if;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': After AR_RECEIPT_API_PUB.CREATE_CASH');
		    iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
		    iex_debug_pub.LogMessage(l_api_name || ': New cash_receipt_id = ' || l_cr_id);
		END IF;

		-- check for errors
		IF l_return_status<>'S' THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': AR_RECEIPT_API_PUB.CREATE_CASH failed');
	        END IF;

                 x_return_status :=l_return_status;
  	         X_MSG_DATA:= L_MSG_DATA;
  	         X_MSG_COUNT := L_MSG_COUNT;

		    FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_CREATE_CR');
		    FND_MSG_PUB.Add;
		    return; --RAISE FND_API.G_EXC_ERROR;
		END IF;


        /*
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': Before AR_RECEIPT_API_PUB.APPLY_ON_ACCOUNT');
		END IF;

		-- apply on_account
		AR_RECEIPT_API_PUB.APPLY_ON_ACCOUNT(
			P_API_VERSION => 1.0,
			P_INIT_MSG_LIST => FND_API.G_FALSE,
			P_COMMIT => FND_API.G_FALSE,
			X_RETURN_STATUS => L_RETURN_STATUS,
			X_MSG_COUNT => L_MSG_COUNT,
			X_MSG_DATA => L_MSG_DATA,
			P_RECEIPT_NUMBER => l_cr_number1);
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': After AR_RECEIPT_API_PUB.APPLY_ON_ACCOUNT');
		    iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
		END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': AR_RECEIPT_API_PUB.APPLY_ON_ACCOUNT failed');
		    END IF;

		    FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_APPLY_ACC');
		    FND_MSG_PUB.Add;
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
        */

		-- generate new pay_receipt id
		OPEN pad_genid_crs;
		FETCH pad_genid_crs INTO l_pay_receipt_ref_id;
		CLOSE pad_genid_crs;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': New pay_receipt_ref_id = ' || l_pay_receipt_ref_id);
		    iex_debug_pub.LogMessage(l_api_name || ': Before call to IEX_PAY_RECEIPT_XREF_PKG.INSERT_ROW');
		END IF;

		IEX_PAY_RECEIPT_XREF_PKG.INSERT_ROW(
			X_ROWID => l_rowid,
			P_PAY_RECEIPT_XREF_ID => l_pay_receipt_ref_id,
			P_LAST_UPDATE_DATE => sysdate,
			P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
			P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
			P_CREATION_DATE => sysdate,
			P_CREATED_BY => FND_GLOBAL.User_Id,
			P_PROGRAM_ID => 695,
			P_OBJECT_VERSION_NUMBER => 1.0,
			P_PAYMENT_ID => l_payment_id,
			P_CASH_RECEIPT_ID => l_cr_id);

            	l_cr_id_tab(i) := l_cr_id;

            	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': After call to IEX_PAY_RECEIPT_XREF_PKG.INSERT_ROW');
            	End if ;
	    END LOOP;

	ELSIF P_PMT_REC.PAYMENT_TARGET = 'INVOICES' THEN


	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Payment target INVOICES');
            END IF;

	    --Determine the Payment Instrument type that is used.
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Payment instrument is ' || P_PMTINSTR_REC.USE_INSTRUMENT);
	    END IF;


	/* Begin - varangan - profile bug#4558547
         get_ar_payment_method(p_payment_type => P_PMTINSTR_REC.USE_INSTRUMENT,
	        x_payment_method => l_ar_pay_method1,
	    	x_payment_method_id => l_ar_pay_method);
	    End - varangan - profile bug#4558547	*/


	-- begin - uptake funds capture - varangan
     /*   IF P_PMTINSTR_REC.USE_INSTRUMENT = 'CC' THEN

		create_ar_cc_bank_account(p_cust_account_id => P_PMTDTLS_TBL(1).CUST_ACCOUNT_ID,
		    p_cc_number => P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM,
		    p_cc_exp_date => P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE,
		    p_cc_holder_name => P_PMTINSTR_REC.CREDITCARDINSTR.CC_HOLDERNAME,
		    p_currency => P_PMT_REC.CURRENCY_CODE,
		    p_party_id => l_payer_id,
		    x_bank_account_id => l_cust_bank_acc_id,
		    x_bank_account_uses_id => l_bank_account_uses_id,
		    x_branch_id => l_branch_id);

	    ELSIF P_PMTINSTR_REC.USE_INSTRUMENT = 'BA' THEN

		create_ar_ba_bank_account(p_cust_account_id => P_PMTDTLS_TBL(1).CUST_ACCOUNT_ID,
		    p_ba_routing_number => P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID,
		    p_ba_number => P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM,
		    p_ba_type => P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_TYPE,
		    p_ba_holder_name => P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_HOLDERNAME,
		    p_currency => P_PMT_REC.CURRENCY_CODE,
		    p_party_id => l_payer_id,
		    x_bank_account_id => l_cust_bank_acc_id,
		    x_bank_account_uses_id => l_bank_account_uses_id,
		    x_branch_id => l_branch_id);

	    END IF; */
   	-- end - uptake funds capture - varangan

      -- Start bug 6717279 gnramasa 25-Aug-08
      --FOR i IN 1..P_PMTDTLS_TBL.COUNT LOOP  -- to fix a bug 5128910


	    -- generate new cash receipt number
	    OPEN rc_genid_crs;
	    FETCH rc_genid_crs INTO l_cr_number;
	    CLOSE rc_genid_crs;

	    l_cr_number1 := 'IEX_' || to_char(l_cr_number);

	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': New cr id = ' || l_cr_number1);
		iex_debug_pub.LogMessage(l_api_name || ': Before AR_RECEIPT_API_PUB.CREATE_CASH');
	    END IF;

	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage('Creating Cash Receipt and Applying for the First Payment Schedule....');
              iex_debug_pub.logmessage('Pmt Schedule id =>' || P_PMTDTLS_TBL(1).PAYMENT_SCHEDULE_ID || ' Amount => ' || P_PMTDTLS_TBL(1).AMOUNT );
          End If ;

	    if l_fun_currency = P_PMT_REC.CURRENCY_CODE then
               --if P_PMTDTLS_TBL(i).currency_code = P_PMT_REC.CURRENCY_CODE then
--commented for bug6717179
	       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': P_PMTDTLS_TBL(1).TRX_TO_CR_RATE = ' || P_PMTDTLS_TBL(1).TRX_TO_CR_RATE);
	        END IF;
		if P_PMTDTLS_TBL(1).TRX_TO_CR_RATE = 1 then
		-- create cash receipt
            /*
		    AR_RECEIPT_API_PUB.CREATE_CASH(
		    P_API_VERSION => 1.0,
		    P_INIT_MSG_LIST => FND_API.G_FALSE,
		    P_COMMIT => FND_API.G_FALSE,
		    P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
		    P_AMOUNT => P_PMT_REC.TOTAL_AMOUNT,
		    P_RECEIPT_METHOD_ID => l_ar_pay_method,
		    P_RECEIPT_NUMBER => l_cr_number1,
		    P_CUSTOMER_ID => P_PMTDTLS_TBL(1).CUST_ACCOUNT_ID,
		    P_CUSTOMER_SITE_USE_ID => P_PMTDTLS_TBL(1).CUST_SITE_USE_ID,
		    P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
		    P_CR_ID => l_cr_id,
		    X_RETURN_STATUS => L_RETURN_STATUS,
		    X_MSG_COUNT => L_MSG_COUNT,
		    X_MSG_DATA => L_MSG_DATA);

            */


		    AR_RECEIPT_API_PUB.CREATE_AND_APPLY(
		        P_API_VERSION => 1.0,
		        P_INIT_MSG_LIST => FND_API.G_FALSE,
		        P_COMMIT => FND_API.G_FALSE,
		        P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
		        P_AMOUNT => P_PMT_REC.TOTAL_AMOUNT, --P_PMTDTLS_TBL(i).AMOUNT, -- P_PMT_REC.TOTAL_AMOUNT,
		        P_RECEIPT_METHOD_ID =>P_PMT_METHOD, -- l_ar_pay_method, for profile bug#4558547
		        P_RECEIPT_NUMBER => l_cr_number1,
		        P_CUSTOMER_ID => P_PMT_REC.CUST_ACCOUNT_ID, --P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
		        P_CUSTOMER_SITE_USE_ID => P_PMT_REC.CUST_SITE_USE_ID,  --P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
		        P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
		        P_CR_ID => l_cr_id,
		        p_applied_payment_schedule_id => P_PMTDTLS_TBL(1).PAYMENT_SCHEDULE_ID, --P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID,
		        p_amount_applied => P_PMTDTLS_TBL(1).AMOUNT, --P_PMTDTLS_TBL(i).AMOUNT,
                        p_call_payment_processor => l_call_payment_processor, -- Fix a bug 5897567 02/06/07 by Ehuh
		        X_RETURN_STATUS => L_RETURN_STATUS,
		        X_MSG_COUNT => L_MSG_COUNT,
		        X_MSG_DATA => L_MSG_DATA,
			-- Begin -- varangan --Bug4528444 -- included for payments uptake
                        p_payment_trxn_extension_id =>P_PMTDTLS_TBL(1).TRX_EXTN_ID
   			-- End -- varangan --Bug4528444 -- included for payments uptake
                        );
              else

                    AR_RECEIPT_API_PUB.CREATE_AND_APPLY(
                        P_API_VERSION => 1.0,
                        P_INIT_MSG_LIST => FND_API.G_FALSE,
                        P_COMMIT => FND_API.G_FALSE,
                        P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
                        P_AMOUNT => P_PMT_REC.TOTAL_AMOUNT, --P_PMTDTLS_TBL(i).AMOUNT, -- P_PMT_REC.TOTAL_AMOUNT,
                        P_RECEIPT_METHOD_ID =>P_PMT_METHOD, -- l_ar_pay_method, for profile bug#4558547
                        P_RECEIPT_NUMBER => l_cr_number1,
                        P_CUSTOMER_ID => P_PMT_REC.CUST_ACCOUNT_ID, --P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
                        P_CUSTOMER_SITE_USE_ID => P_PMT_REC.CUST_SITE_USE_ID,  --P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
                        P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
                        P_CR_ID => l_cr_id,
                        p_applied_payment_schedule_id => P_PMTDTLS_TBL(1).PAYMENT_SCHEDULE_ID, --P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID,
			p_amount_applied => P_PMTDTLS_TBL(1).AMOUNT / P_PMTDTLS_TBL(1).TRX_TO_CR_RATE, --added by gnramasa bug 6717279
                        p_amount_applied_from  => P_PMTDTLS_TBL(1).AMOUNT,  --P_PMTDTLS_TBL(i).AMOUNT,
			p_trans_to_receipt_rate => P_PMTDTLS_TBL(1).TRX_TO_CR_RATE,  --added by gnramasa bug 6717279
                        p_call_payment_processor => l_call_payment_processor, -- Fix a bug 5897567 02/06/07 by Ehuh
                        X_RETURN_STATUS => L_RETURN_STATUS,
                        X_MSG_COUNT => L_MSG_COUNT,
                        X_MSG_DATA => L_MSG_DATA,
                        -- Begin -- varangan --Bug4528444 -- included for payments uptake
                        p_payment_trxn_extension_id =>P_PMTDTLS_TBL(1).TRX_EXTN_ID
                        -- End -- varangan --Bug4528444 -- included for payments uptake
                        );
              end if;


	    else
		    -- create cash receipt
            /*
		    AR_RECEIPT_API_PUB.CREATE_CASH(
		        P_API_VERSION => 1.0,
		        P_INIT_MSG_LIST => FND_API.G_FALSE,
		        P_COMMIT => FND_API.G_FALSE,
		        P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
		        P_EXCHANGE_RATE_TYPE => P_PMT_REC.EXCHANGE_RATE_TYPE,
		        P_EXCHANGE_RATE_DATE => P_PMT_REC.EXCHANGE_DATE,
		        P_AMOUNT => P_PMT_REC.TOTAL_AMOUNT,
		        P_RECEIPT_METHOD_ID => l_ar_pay_method,
		        P_RECEIPT_NUMBER => l_cr_number1,
		        P_CUSTOMER_ID => P_PMTDTLS_TBL(1).CUST_ACCOUNT_ID,
		        P_CUSTOMER_SITE_USE_ID => P_PMTDTLS_TBL(1).CUST_SITE_USE_ID,
		        P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
		        P_CR_ID => l_cr_id,
		        X_RETURN_STATUS => L_RETURN_STATUS,
		        X_MSG_COUNT => L_MSG_COUNT,
		        X_MSG_DATA => L_MSG_DATA);
            */

		if P_PMTDTLS_TBL(1).TRX_TO_CR_RATE = 1 then
		    AR_RECEIPT_API_PUB.CREATE_AND_APPLY(
		        P_API_VERSION => 1.0,
		        P_INIT_MSG_LIST => FND_API.G_FALSE,
		        P_COMMIT => FND_API.G_FALSE,
		        P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
		        P_EXCHANGE_RATE_TYPE => P_PMT_REC.EXCHANGE_RATE_TYPE,
		        P_EXCHANGE_RATE_DATE => P_PMT_REC.EXCHANGE_DATE,
		        P_AMOUNT => P_PMT_REC.TOTAL_AMOUNT, --P_PMTDTLS_TBL(i).AMOUNT, -- P_PMT_REC.TOTAL_AMOUNT,
		        P_RECEIPT_METHOD_ID => P_PMT_METHOD, --l_ar_pay_method, for profile bug#4558547
		        P_RECEIPT_NUMBER => l_cr_number1,
		        P_CUSTOMER_ID => P_PMT_REC.CUST_ACCOUNT_ID, --P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
		        P_CUSTOMER_SITE_USE_ID => P_PMT_REC.CUST_SITE_USE_ID,  --P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
		        P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
		        P_CR_ID => l_cr_id,
			p_applied_payment_schedule_id => P_PMTDTLS_TBL(1).PAYMENT_SCHEDULE_ID, --P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID,
			p_amount_applied => P_PMTDTLS_TBL(1).AMOUNT, --P_PMTDTLS_TBL(i).AMOUNT,
                        p_call_payment_processor => l_call_payment_processor, -- Fix a bug 5897567 02/06/07 by Ehuh
		        X_RETURN_STATUS => L_RETURN_STATUS,
		        X_MSG_COUNT => L_MSG_COUNT,
		        X_MSG_DATA => L_MSG_DATA,
			 -- Begin -- varangan --Bug4528444 -- included for payments uptake
                        p_payment_trxn_extension_id => P_PMTDTLS_TBL(1).TRX_EXTN_ID
                        -- End -- varangan --Bug4528444 -- included for payments uptake
                      );
		else
			AR_RECEIPT_API_PUB.CREATE_AND_APPLY(
		        P_API_VERSION => 1.0,
		        P_INIT_MSG_LIST => FND_API.G_FALSE,
		        P_COMMIT => FND_API.G_FALSE,
		        P_CURRENCY_CODE => P_PMT_REC.CURRENCY_CODE,
		        P_EXCHANGE_RATE_TYPE => P_PMT_REC.EXCHANGE_RATE_TYPE,
		        P_EXCHANGE_RATE_DATE => P_PMT_REC.EXCHANGE_DATE,
		        P_AMOUNT => P_PMT_REC.TOTAL_AMOUNT, --P_PMTDTLS_TBL(i).AMOUNT, -- P_PMT_REC.TOTAL_AMOUNT,
		        P_RECEIPT_METHOD_ID => P_PMT_METHOD, --l_ar_pay_method, for profile bug#4558547
		        P_RECEIPT_NUMBER => l_cr_number1,
		        P_CUSTOMER_ID => P_PMT_REC.CUST_ACCOUNT_ID, --P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
		        P_CUSTOMER_SITE_USE_ID => P_PMT_REC.CUST_SITE_USE_ID,  --P_PMTDTLS_TBL(i).CUST_SITE_USE_ID,
		        P_CUSTOMER_BANK_ACCOUNT_ID => L_CUST_BANK_ACC_ID,
		        P_CR_ID => l_cr_id,
			p_applied_payment_schedule_id => P_PMTDTLS_TBL(1).PAYMENT_SCHEDULE_ID, --P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID,
			p_amount_applied => P_PMTDTLS_TBL(1).AMOUNT / P_PMTDTLS_TBL(1).TRX_TO_CR_RATE, --P_PMTDTLS_TBL(1).AMOUNT, --P_PMTDTLS_TBL(i).AMOUNT,
                        p_call_payment_processor => l_call_payment_processor, -- Fix a bug 5897567 02/06/07 by Ehuh
			p_amount_applied_from => P_PMTDTLS_TBL(1).AMOUNT, --added by gnramasa bug 6717279
			p_trans_to_receipt_rate => P_PMTDTLS_TBL(1).TRX_TO_CR_RATE,  --added by gnramasa bug 6717279
		        X_RETURN_STATUS => L_RETURN_STATUS,
		        X_MSG_COUNT => L_MSG_COUNT,
		        X_MSG_DATA => L_MSG_DATA,
			 -- Begin -- varangan --Bug4528444 -- included for payments uptake
                        p_payment_trxn_extension_id => P_PMTDTLS_TBL(1).TRX_EXTN_ID
                        -- End -- varangan --Bug4528444 -- included for payments uptake
                      );
		end if;


	    end if;


	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': After AR_RECEIPT_API_PUB.CREATE_CASH');
		iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
		iex_debug_pub.LogMessage(l_api_name || ': New cash_receipt_id = ' || l_cr_id);
	    END IF;

	    -- check for errors
	    IF l_return_status<>'S' THEN

	     x_return_status :=l_return_status;
  	     X_MSG_DATA:= L_MSG_DATA;
  	     X_MSG_COUNT := L_MSG_COUNT;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': AR_RECEIPT_API_PUB.CREATE_CASH failed');
		END IF;
		FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_CREATE_CR');
		FND_MSG_PUB.Add;
		return;
	    END IF;

	    OPEN get_delid_crs(P_PMTDTLS_TBL(1).PAYMENT_SCHEDULE_ID);
	    FETCH get_delid_crs INTO l_del_id;
	    CLOSE get_delid_crs;

		if l_del_id is not null then
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Delinquency found. Going to insert row into IEX_DEL_PAY_XREF table');
   		    END IF;

		    -- generate new del_payment_ref id
		    OPEN dpx_genid_crs;
		    FETCH dpx_genid_crs INTO l_del_pay_ref_id;
		    CLOSE dpx_genid_crs;

		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Before IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
   		    END IF;

		    IEX_DEL_PAY_XREF_PKG.INSERT_ROW(
			X_ROWID => l_rowid,
			P_DEL_PAY_ID => l_del_pay_ref_id,
			P_LAST_UPDATE_DATE => sysdate,
			P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
			P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
			P_CREATION_DATE => sysdate,
			P_CREATED_BY => FND_GLOBAL.User_Id,
			P_PROGRAM_ID => 695,
			P_OBJECT_VERSION_NUMBER => 1.0,
			P_DELINQUENCY_ID => l_del_id,
			P_PAYMENT_ID => l_payment_id);

		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': After call to IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
		    END IF;
		else
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Delinquency not found.');
		    END IF;
		end if;

	    -- generate new pay_receipt_ref id
	    OPEN pad_genid_crs;
	    FETCH pad_genid_crs INTO l_pay_receipt_ref_id;
	    CLOSE pad_genid_crs;

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': New pay_receipt_ref_id = ' || l_pay_receipt_ref_id);
		iex_debug_pub.LogMessage(l_api_name || ': Before IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
	    END IF;

	    IEX_PAY_RECEIPT_XREF_PKG.Insert_Row(
            	X_ROWID => l_rowid,
            	P_PAY_RECEIPT_XREF_ID => l_pay_receipt_ref_id,
                P_LAST_UPDATE_DATE => sysdate,
            	P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
            	P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            	P_CREATION_DATE => sysdate,
            	P_CREATED_BY => FND_GLOBAL.User_Id,
            	P_PROGRAM_ID => 695,
            	P_OBJECT_VERSION_NUMBER => 1.0,
            	P_PAYMENT_ID => l_payment_id,
            	P_CASH_RECEIPT_ID => l_cr_id);

	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': After IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
            END IF;

	    l_cr_id_tab(1) := l_cr_id;

	    -- run thru table of details and apply via AR APIs
	    -- bug 4868943 FOR i IN 2..P_PMTDTLS_TBL.COUNT LOOP
	    -- move this loop to the above to make payment multiple (bug 5128910) FOR i IN 1..P_PMTDTLS_TBL.COUNT LOOP

	FOR i IN 2..P_PMTDTLS_TBL.COUNT LOOP
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': processing payment details; loop ' || i);
		    iex_debug_pub.LogMessage(l_api_name || ': Before AR_RECEIPT_API_PUB.APPLY');
		END IF;

		-- apply on invoices
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': P_PMTDTLS_TBL(i).TRX_TO_CR_RATE = ' || P_PMTDTLS_TBL(i).TRX_TO_CR_RATE);
		END IF;

--/* bug 4868943
		if P_PMTDTLS_TBL(i).TRX_TO_CR_RATE = 1 then

		    AR_RECEIPT_API_PUB.APPLY(
			P_API_VERSION => 1.0,
			P_INIT_MSG_LIST => FND_API.G_FALSE,
			P_COMMIT => FND_API.G_FALSE,
			X_RETURN_STATUS => L_RETURN_STATUS,
			X_MSG_COUNT => L_MSG_COUNT,
			X_MSG_DATA => L_MSG_DATA,
			P_RECEIPT_NUMBER => l_cr_number1,
			p_applied_payment_schedule_id => P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID,
			p_amount_applied => P_PMTDTLS_TBL(i).AMOUNT);

		else

		    if P_PMTDTLS_TBL(i).TRX_TO_CR_RATE <> 0 then
			AR_RECEIPT_API_PUB.APPLY(
			    P_API_VERSION => 1.0,
			    P_INIT_MSG_LIST => FND_API.G_FALSE,
			    P_COMMIT => FND_API.G_FALSE,
			    X_RETURN_STATUS => L_RETURN_STATUS,
			    X_MSG_COUNT => L_MSG_COUNT,
			    X_MSG_DATA => L_MSG_DATA,
			    P_RECEIPT_NUMBER => l_cr_number1,
			    p_applied_payment_schedule_id => P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID,
			    p_amount_applied => P_PMTDTLS_TBL(i).AMOUNT / P_PMTDTLS_TBL(i).TRX_TO_CR_RATE,
			    p_trans_to_receipt_rate => P_PMTDTLS_TBL(i).TRX_TO_CR_RATE,
			    p_amount_applied_from => P_PMTDTLS_TBL(i).AMOUNT);

		    else
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			    iex_debug_pub.LogMessage(l_api_name || ': because P_PMTDTLS_TBL(i).TRX_TO_CR_RATE = 0 we failed');
			END IF;

                        x_return_status :=l_return_status;
  	                X_MSG_DATA:= L_MSG_DATA;

			FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_APPLY_APP');
			FND_MSG_PUB.Add;
			return; -- RAISE FND_API.G_EXC_ERROR;
		    end if;
		end if;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': After AR_RECEIPT_API_PUB.APPLY');
		    iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
		END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		    X_RETURN_STATUS:=l_return_status;
		    X_MSG_DATA:= L_MSG_DATA;

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': AR_RECEIPT_API_PUB.APPLY failed');
		    END IF;

		    FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_APPLY_APP');
		    FND_MSG_PUB.Add;
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
--*/

		OPEN get_delid_crs(P_PMTDTLS_TBL(i).PAYMENT_SCHEDULE_ID);
		FETCH get_delid_crs INTO l_del_id;
		CLOSE get_delid_crs;

		if l_del_id is not null then
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Delinquency found. Going to insert row into IEX_DEL_PAY_XREF table');
   		    END IF;

		    -- generate new del_payment_ref id
		    OPEN dpx_genid_crs;
		    FETCH dpx_genid_crs INTO l_del_pay_ref_id;
		    CLOSE dpx_genid_crs;

		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Before IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
   		    END IF;

		    IEX_DEL_PAY_XREF_PKG.INSERT_ROW(
			X_ROWID => l_rowid,
			P_DEL_PAY_ID => l_del_pay_ref_id,
			P_LAST_UPDATE_DATE => sysdate,
			P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
			P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
			P_CREATION_DATE => sysdate,
			P_CREATED_BY => FND_GLOBAL.User_Id,
			P_PROGRAM_ID => 695,
			P_OBJECT_VERSION_NUMBER => 1.0,
			P_DELINQUENCY_ID => l_del_id,
			P_PAYMENT_ID => l_payment_id);

		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': After call to IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
		    END IF;
		else
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Delinquency not found.');
		    END IF;
		end if;
	    END LOOP;

	    /*
	    -- generate new pay_receipt_ref id
	    OPEN pad_genid_crs;
	    FETCH pad_genid_crs INTO l_pay_receipt_ref_id;
	    CLOSE pad_genid_crs;

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': New pay_receipt_ref_id = ' || l_pay_receipt_ref_id);
		iex_debug_pub.LogMessage(l_api_name || ': Before IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
	    END IF;

	    IEX_PAY_RECEIPT_XREF_PKG.Insert_Row(
            	X_ROWID => l_rowid,
            	P_PAY_RECEIPT_XREF_ID => l_pay_receipt_ref_id,
                P_LAST_UPDATE_DATE => sysdate,
            	P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
            	P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            	P_CREATION_DATE => sysdate,
            	P_CREATED_BY => FND_GLOBAL.User_Id,
            	P_PROGRAM_ID => 695,
            	P_OBJECT_VERSION_NUMBER => 1.0,
            	P_PAYMENT_ID => l_payment_id,
            	P_CASH_RECEIPT_ID => l_cr_id);



	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': After IEX_DEL_PAY_XREF_PKG.INSERT_ROW');
         END IF;

	*/
       --END LOOP;


	END IF;


	/* commit AR processing */
    	COMMIT WORK;



    	FND_MESSAGE.SET_NAME('IEX', 'IEX_AR_SUCCESS');
    	FND_MSG_PUB.Add;

    	x_return_status := FND_API.G_RET_STS_SUCCESS;
commit;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
    	    ROLLBACK TO CREATE_AR_PAYMENT_PVT1;
    	      If X_RETURN_STATUS is Null Then
    	        x_return_status := FND_API.G_RET_STS_ERROR;
  	          End If;
	        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	    ROLLBACK TO CREATE_AR_PAYMENT_PVT1;
	        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	WHEN OTHERS THEN
	    ROLLBACK TO CREATE_AR_PAYMENT_PVT1;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
        	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	    END IF;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    END;

    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
  	return;
    end if;

    /* creating note */
    BEGIN
	SAVEPOINT CREATE_PAYMENT_PVT2;

	l_note_type := fnd_profile.value('AST_NOTES_DEFAULT_TYPE');
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ':  l_note_type = ' ||  l_note_type);
	END IF;

	/* if note is passed - insert it */
	if P_PMT_REC.NOTE is not null and l_note_type is not null then
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Note is not null');
	    END IF;

	    IF P_PMT_REC.PAYMENT_TARGET = 'ACCOUNTS' or P_PMT_REC.PAYMENT_TARGET = 'INVOICES' THEN

		i := 1;
		/* adding parties into note context */
		l_context_tab(i).context_type := 'PARTY';
		l_context_tab(i).context_id := l_note_payer_id;
		i := i + 1;
		if l_note_payer_type = 'PARTY_RELATIONSHIP' then
		    l_context_tab(i).context_type := 'PARTY';
		    l_context_tab(i).context_id := P_PMT_REC.PAYER_PARTY_ORG_ID;
		    i := i + 1;
		    l_context_tab(i).context_type := 'PARTY';
		    l_context_tab(i).context_id := P_PMT_REC.PAYER_PARTY_PER_ID;
		    i := i + 1;
		end if;

		FOR j IN 1..l_cr_id_tab.COUNT LOOP
		    /* adding account to note context */
		    l_context_tab(i).context_type := 'IEX_ACCOUNT';
		    l_context_tab(i).context_id := P_PMTDTLS_TBL(j).CUST_ACCOUNT_ID;
		    i := i + 1;

		    /* adding bill-to to note context */
		    l_context_tab(i).context_type := 'IEX_BILLTO';
		    l_context_tab(i).context_id := P_PMTDTLS_TBL(j).CUST_SITE_USE_ID;
		    i := i + 1;

		    /* adding payments to note context */
		    if j = 1 then
			l_source_object_id := l_cr_id_tab(j);
			l_source_object_code := 'IEX_PAYMENT';
		    else
			l_context_tab(i).context_type := 'IEX_PAYMENT';
			l_context_tab(i).context_id := l_cr_id_tab(j);
			i := i + 1;
		    end if;
		END LOOP;

		/* adding invoice psa to note context */
		if P_PMT_REC.PAYMENT_TARGET = 'INVOICES' then
		    /* adding psa to note context */
		    FOR j IN 1..P_PMTDTLS_TBL.COUNT LOOP
			l_context_tab(i).context_type := 'IEX_INVOICES';
			l_context_tab(i).context_id := P_PMTDTLS_TBL(j).PAYMENT_SCHEDULE_ID;
			i := i + 1;
		    END LOOP;
		end if;

		-- for debug purpose only
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': l_source_object_id = ' || l_source_object_id);
		    iex_debug_pub.LogMessage(l_api_name || ': l_source_object_code = ' || l_source_object_code);
		END IF;

		FOR i IN 1..l_context_tab.COUNT LOOP
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': l_context_tab(' || i || ').context_type = ' || l_context_tab(i).context_type);
			iex_debug_pub.LogMessage(l_api_name || ': l_context_tab(' || i || ').context_id = ' || l_context_tab(i).context_id);
		    END IF;
		END LOOP;

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		     iex_debug_pub.LogMessage(l_api_name || ': Before call to IEX_NOTES_PVT.Create_Note');
            	END IF;

		IEX_NOTES_PVT.Create_Note(
		    P_API_VERSION => l_api_version,
		    P_INIT_MSG_LIST => FND_API.G_FALSE,
		    P_COMMIT => FND_API.G_FALSE,
		    P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
		    X_RETURN_STATUS => l_return_status,
		    X_MSG_COUNT => l_msg_count,
		    X_MSG_DATA => l_msg_data,
		    p_source_object_id => l_source_object_id,
		    p_source_object_code => l_source_object_code,
		    p_note_type => l_note_type,
		    p_notes	=> P_PMT_REC.NOTE,
		    p_contexts_tbl => l_context_tab,
		    x_note_id => X_PMTRESP_REC.NOTE_ID);

		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    iex_debug_pub.LogMessage(l_api_name || ': After call to IEX_NOTES_PVT.Create_Note');
		    iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
            	END IF;

		-- check for errors
		IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': IEX_NOTES_PVT.Create_Note failed');
   		    END IF;
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
	    END IF;
	End if;

	/* commit note creation */
    	COMMIT WORK;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
    	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(
	    p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count,
	    p_data => x_msg_data);

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO CREATE_PAYMENT_PVT2;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    ROLLBACK TO CREATE_PAYMENT_PVT2;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	WHEN OTHERS THEN
	    ROLLBACK TO CREATE_PAYMENT_PVT2;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	    END IF;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    END;
END ;

PROCEDURE CREATE_OKL_PAYMENT(
   	P_API_VERSION		    	IN      NUMBER,
   	P_INIT_MSG_LIST		    	IN      VARCHAR2,
   	P_COMMIT                    	IN      VARCHAR2,
   	P_VALIDATION_LEVEL	    	IN      NUMBER,
   	X_RETURN_STATUS		    	OUT NOCOPY    VARCHAR2,
   	X_MSG_COUNT                 	OUT NOCOPY    NUMBER,
   	X_MSG_DATA	    	    	OUT NOCOPY    VARCHAR2,
	P_PMT_REC			IN	IEX_PAYMENTS_PUB.PMT_REC_TYPE,
	P_PMTDTLS_TBL			IN	IEX_PAYMENTS_PUB.PMTDTLS_TBL_TYPE,
	P_PMTINSTR_REC			IN	IEX_PAYMENTS_PUB.PMTINSTR_REC_TYPE,
	X_PMTRESP_REC			OUT NOCOPY	IEX_PAYMENTS_PUB.PMTRESP_REC_TYPE)
IS
    	l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_OKL_PAYMENT';
    	l_api_version               CONSTANT NUMBER := 1.0;
   	l_return_status             VARCHAR2(1);
    	l_msg_count                 NUMBER;
   	l_msg_data                  VARCHAR2(32767);

   	-- iPayment capture types


   	/*  Begin - Bug428444 -- varangan -- remove this comment while implementing OKL payment in R12 codeline

	l_payee_rec                 iby_payment_adapter_pub.payee_rec_type;
   	l_payer_rec                 iby_payment_adapter_pub.payer_rec_type;
   	l_pmtinstr_rec              iby_payment_adapter_pub.pmtinstr_rec_type;
   	l_tangible_rec              iby_payment_adapter_pub.tangible_rec_type;
   	l_pmtreqtrxn_rec            iby_payment_adapter_pub.pmtreqtrxn_rec_type;
   	l_reqresp_rec               iby_payment_adapter_pub.reqresp_rec_type;
   	l_RiskInfo_rec		    IBY_Payment_Adapter_Pub.RiskInfo_rec_type;
	l_capturetrxn_rec	    IBY_Payment_Adapter_Pub.CaptureTrxn_rec_type;
	l_capresp_rec		    IBY_Payment_Adapter_Pub.CaptureResp_rec_type;

	-- iPayment instrument types
	l_pmtInstrRec               IBY_INSTRREG_PUB.PmtInstr_rec_type;

	TYPE pay_okl_cnsld_id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE pay_okl_contract_id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	l_pay_okl_cnsld_id_tab		pay_okl_cnsld_id_tab;
	l_pay_okl_contract_id_tab	pay_okl_contract_id_tab;
   	l_instr_id                  	NUMBER;     -- cc_id/ba_id
   	l_rowid                     	VARCHAR2(100);
   	l_payment_id                	NUMBER;
   	i                           	NUMBER;
   	j                           	NUMBER;
	l_tangible_id			NUMBER;
	l_ar_pay_method1		VARCHAR2(100);
	l_ar_pay_method			NUMBER;
	l_note_payer_id			NUMBER;
	l_payer_num_id			NUMBER;
	l_payer_id			VARCHAR2(80);
	l_payer_name			HZ_PARTIES.PARTY_NAME%TYPE;  --Changed the datatype for bug#5652085 by ehuh 2/28/07
	l_note_payer_type		VARCHAR2(100);
	l_context_tab			IEX_NOTES_PVT.CONTEXTS_TBL_TYPE;
	l_pay_okl_ref_id		NUMBER;
	l_template_id			NUMBER;
   	l_request_id   			number;
    	l_autofulfill			varchar2(1);
    	l_disable_ipayment		varchar2(1);
    	l_note_type			varchar2(30);
    	l_source_object_id		NUMBER;
    	l_source_object_code		varchar2(20);

   	-- generate new payment
   	CURSOR pay_genid_crs IS
   	select IEX_PAYMENTS_S.NEXTVAL from dual;

   	-- generate new tangible id
   	CURSOR tang_genid_crs IS
   	select IEX_IPAYMENT_TANGIBLE_S.NEXTVAL from dual;

   	-- generate new pay_okl_xref id
   	CURSOR pox_genid_crs IS
   	select iex_pay_okl_xref_s.NEXTVAL from dual;

	CURSOR get_baid_crs(p_BANKID VARCHAR2,
			    p_BANKACCOUNTID VARCHAR2,
			    p_PAYER_ID VARCHAR2) IS
		select INSTRID
		from iby_bankacct_v
		where
		BANKID = p_BANKID and
		BANKACCOUNTID = p_BANKACCOUNTID and
		OWNERID = p_PAYER_ID;

	CURSOR get_ccid_crs(p_CCNUMBER VARCHAR2,
			    p_PAYER_ID VARCHAR2) IS
		select INSTRID
		from iby_creditcard_v
		where
		CCNUMBER = p_CCNUMBER and
		OWNERID = p_PAYER_ID;

		-- End - Bug428444 -- varangan -- remove this comment while implementing OKL payment in R12 codeline */

BEGIN

 NUll; -- Remove it while coding OKL payment flow

 /*  Begin - Bug428444 -- varangan -- remove this comment while implementing OKL payment in R12 codeline


  -- First part of API: standard checking, iPayment processing
  BEGIN
  --   First part of API savepoint
    SAVEPOINT CREATE_OKL_PAYMENT_PVT1;

   	-- Standard call to check for call compatibility
   	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;

   	-- Initialize message list if p_init_msg_list is set to TRUE
   	IF FND_API.To_Boolean(p_init_msg_list) THEN
   		FND_MSG_PUB.initialize;
   	END IF;

   	-- Initialize API return status to success
   	l_return_status := FND_API.G_RET_STS_SUCCESS;

   	-- START OF BODY OF API
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Start of CREATE_PAYMENT');
END IF;

	-- validate all input parameters
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Before validate_input');
END IF;
	validate_input(P_PMT_REC => P_PMT_REC,
			P_PMTDTLS_TBL => P_PMTDTLS_TBL,
			P_PMTINSTR_REC => P_PMTINSTR_REC);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': After validate_input');
END IF;

	-- validate payer parties and get payer info
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Before GET_PAYER_INFO');
END IF;
	GET_PAYER_INFO(P_PAYER_PARTY_REL_ID => P_PMT_REC.PAYER_PARTY_REL_ID,
		P_PAYER_PARTY_ORG_ID => P_PMT_REC.PAYER_PARTY_ORG_ID,
		P_PAYER_PARTY_PER_ID => P_PMT_REC.PAYER_PARTY_PER_ID,
		X_NOTE_PAYER_TYPE => l_note_payer_type,
		X_NOTE_PAYER_NUM_ID => l_note_payer_id,
		X_PAYER_NUM_ID => l_payer_num_id,
		X_PAYER_ID => l_payer_id,
		X_PAYER_NAME => l_payer_name);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': After GET_PAYER_INFO');
	iex_debug_pub.LogMessage(l_api_name || ': GET_PAYER_INFO returns:');
	iex_debug_pub.LogMessage(l_api_name || ': l_note_payer_type = ' || l_note_payer_type);
	iex_debug_pub.LogMessage(l_api_name || ': l_note_payer_id = ' || l_note_payer_id);
	iex_debug_pub.LogMessage(l_api_name || ': l_payer_num_id = ' || l_payer_num_id);
	iex_debug_pub.LogMessage(l_api_name || ': l_payer_id = ' || l_payer_id);
	iex_debug_pub.LogMessage(l_api_name || ': l_payer_name = ' || l_payer_name);
END IF;

	l_disable_ipayment := fnd_profile.value('IEX_DISABLE_IPAYMENT');
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': l_disable_ipayment = ' || l_disable_ipayment);
END IF;

	if l_disable_ipayment is null or (l_disable_ipayment is not null and l_disable_ipayment = 'N') then

	--Determine the Payment Instrument type that is used.
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Determine instrument');
END IF;
	IF P_PMTINSTR_REC.USE_INSTRUMENT = 'CC' THEN

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Instrument is CC');
END IF;

	    	l_ar_pay_method1 := fnd_profile.value('IEX_CCARD_REMITTANCE');
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': CC remittance = ' || l_ar_pay_method1);
END IF;
		if l_ar_pay_method1 is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': failed to get CC remittance');
END IF;
			FND_MESSAGE.SET_NAME('IEX', 'IEX_NO_CC_REMITTANCE');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
		l_ar_pay_method := to_number(l_ar_pay_method1);

		-- first check for existance of instrument. if does not exist add instrument
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Search for CC');
END IF;
		OPEN get_ccid_crs(IBY_INSTRREG_PUB.encode(P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM), l_payer_id);
		FETCH get_ccid_crs INTO l_instr_id;
		CLOSE get_ccid_crs;

		if l_instr_id is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': CC is not found');
			iex_debug_pub.LogMessage(l_api_name || ': Going to insert new cc');
END IF;

			l_pmtInstrRec.InstrumentType := 'CREDITCARD';
			l_pmtInstrRec.CreditCardInstr.FINAME := P_PMTINSTR_REC.CREDITCARDINSTR.FINAME;
			l_pmtInstrRec.CreditCardInstr.CC_TYPE := P_PMTINSTR_REC.CREDITCARDINSTR.CC_TYPE;
			l_pmtInstrRec.CreditCardInstr.CC_NUM := P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM;
			l_pmtInstrRec.CreditCardInstr.CC_EXPDATE := P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE;
			l_pmtInstrRec.CreditCardInstr.CC_HOLDERNAME := P_PMTINSTR_REC.CREDITCARDINSTR.CC_HOLDERNAME;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Before ORAINSTRADD call');
END IF;
--Begin-fix bug #4479607-07072005-jypark-comment invalid api call to fix compile error
--			IBY_INSTRREG_PUB.ORAINSTRADD
--			(
--				p_api_version => 1.0,
--				p_init_msg_list => FND_API.G_FALSE,
--				p_commit => FND_API.G_FALSE,
--				x_return_status => l_return_status,
--				x_msg_count => l_msg_count,
--				x_msg_data => l_msg_data,
--				p_payer_id => l_payer_id,
--				p_pmtInstrRec => l_pmtInstrRec,
--				x_instr_id => l_instr_id);
--
--End-fix bug #4479607-07072005-jypark-comment invalid api call to fix compile error
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': After ORAINSTRADD call');
			iex_debug_pub.LogMessage(l_api_name || ': l_return_status = ' || l_return_status);
END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(l_api_name || ': IBY_INSTRREG_PUB.ORAINSTRADD failed');
END IF;
				FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_INSERT_INSTR');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': CC is found; id = ' || l_instr_id);
			iex_debug_pub.LogMessage(l_api_name || ': Exp date is different');
			iex_debug_pub.LogMessage(l_api_name || ': Going to modify new cc');
END IF;

			l_pmtInstrRec.InstrumentType := 'CREDITCARD';
			l_pmtInstrRec.CreditCardInstr.INSTR_ID := l_instr_id;
			l_pmtInstrRec.CreditCardInstr.FINAME := P_PMTINSTR_REC.CREDITCARDINSTR.FINAME;
			l_pmtInstrRec.CreditCardInstr.CC_EXPDATE := P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE;
			l_pmtInstrRec.CreditCardInstr.CC_HOLDERNAME := P_PMTINSTR_REC.CREDITCARDINSTR.CC_HOLDERNAME;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Before ORAINSTRMOD call');
END IF;
			IBY_INSTRREG_PUB.ORAINSTRMOD
			(
				p_api_version => 1.0,
				p_init_msg_list => FND_API.G_FALSE,
				p_commit => FND_API.G_FALSE,
				x_return_status => l_return_status,
				x_msg_count => l_msg_count,
				x_msg_data => l_msg_data,
				p_payer_id => l_payer_id,
				p_pmtInstrRec => l_pmtInstrRec,
			    -- Begin -- varangan --Bug4528444 -- payments uptake
				p_validation_level => FND_API.G_VALID_LEVEL_FULL
				    --, x_result => l_result_rec  -- temporarily commenting, since IBY code is in progress
   			    -- End -- varangan --Bug4528444 --  payments uptake
			);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': After ORAINSTRMOD call');
			iex_debug_pub.LogMessage('l_return_status = ' || l_return_status);
END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(l_api_name || ': IBY_INSTRREG_PUB.ORAINSTRMOD failed');
END IF;
				FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_UPDATE_INSTR');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		end if;

		l_pmtreqtrxn_rec.PmtMode := 'ONLINE';
		l_pmtreqtrxn_rec.auth_type := 'AUTHONLY';
		l_pmtinstr_rec.PmtInstr_ID := l_instr_id;


		--  l_pmtinstr_rec.CreditCardInstr.FINAME := P_PMTINSTR_REC.CREDITCARDINSTR.FINAME;
    	--	l_pmtinstr_rec.CreditCardInstr.cc_type := P_PMTINSTR_REC.CREDITCARDINSTR.CC_TYPE;
    	--	l_pmtinstr_rec.CreditCardInstr.cc_num := P_PMTINSTR_REC.CREDITCARDINSTR.CC_NUM;
    	--	l_pmtinstr_rec.CreditCardInstr.cc_expdate := P_PMTINSTR_REC.CREDITCARDINSTR.CC_EXPDATE;
		--  l_pmtinstr_rec.CreditCardInstr.CC_HOLDERNAME := P_PMTINSTR_REC.CREDITCARDINSTR.CC_HOLDERNAME;


	ELSIF P_PMTINSTR_REC.USE_INSTRUMENT = 'BA' THEN

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Instrument is BA');
END IF;

		l_ar_pay_method1 := fnd_profile.value('IEX_EFT_REMITTANCE');
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': BA remittance = ' || l_ar_pay_method1);
END IF;
		if l_ar_pay_method1 is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': failed to get BA remittance');
END IF;
			FND_MESSAGE.SET_NAME('IEX', 'IEX_NO_EFT_REMITTANCE');
			FND_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		end if;
		l_ar_pay_method := to_number(l_ar_pay_method1);

	    	-- first check for existance of instrument. if does not exist add instrument
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Search for BA');
END IF;
		OPEN get_baid_crs(P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID,
						IBY_INSTRREG_PUB.encode(P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM),
						l_payer_id);
		FETCH get_baid_crs INTO l_instr_id;
		CLOSE get_baid_crs;

		if l_instr_id is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': BA is not found');
			iex_debug_pub.LogMessage(l_api_name || ': Going to insert new ba');
END IF;

			l_pmtInstrRec.InstrumentType := 'BANKACCOUNT';
			l_pmtInstrRec.BankAcctInstr.FIName := P_PMTINSTR_REC.BANKACCTINSTR.FINAME;
			l_pmtInstrRec.BankAcctInstr.Bank_Id := P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID;
			l_pmtInstrRec.BankAcctInstr.Branch_Id := P_PMTINSTR_REC.BANKACCTINSTR.BRANCH_ID;
			l_pmtInstrRec.BankAcctInstr.BankAcct_Type := P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_TYPE;
			l_pmtInstrRec.BankAcctInstr.BankAcct_Num := P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM;
			l_pmtInstrRec.BankAcctInstr.BankAcct_HolderName := P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_HOLDERNAME;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Before ORAINSTRADD call');
END IF;
--Begin-fix bug #4479607-07072005-jypark-comment invalid api call to fix compile error
--			IBY_INSTRREG_PUB.ORAINSTRADD(
--				p_api_version => 1.0,
--				p_init_msg_list => FND_API.G_FALSE,
--				p_commit => FND_API.G_FALSE,
--				x_return_status => l_return_status,
--				x_msg_count => l_msg_count,
--				x_msg_data => l_msg_data,
--				p_payer_id => l_payer_id,
--				p_pmtInstrRec => l_pmtInstrRec,
--				x_instr_id => l_instr_id);
--End-fix bug #4479607-07072005-jypark-comment invalid api call to fix compile error

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': After ORAINSTRADD call');
			iex_debug_pub.LogMessage('l_return_status = ' || l_return_status);
END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(l_api_name || ': IBY_INSTRREG_PUB.ORAINSTRADD failed');
END IF;
				FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_INSERT_INSTR');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': BA is found; id = ' || l_instr_id);
END IF;
		end if;

		l_pmtreqtrxn_rec.PmtMode := 'OFFLINE';
		l_pmtreqtrxn_rec.Settlement_Date := sysdate + 100;
		l_pmtreqtrxn_rec.Check_Flag := 'true';
		l_pmtinstr_rec.PmtInstr_ID := l_instr_id;


	--	l_pmtinstr_rec.BankAcctInstr.FIName := P_PMTINSTR_REC.BANKACCTINSTR.FINAME;
	--	l_pmtinstr_rec.BankAcctInstr.Bank_Id := P_PMTINSTR_REC.BANKACCTINSTR.BANK_ID;
	--	l_pmtinstr_rec.BankAcctInstr.Branch_Id := P_PMTINSTR_REC.BANKACCTINSTR.BRANCH_ID;
	--	l_pmtinstr_rec.BankAcctInstr.BankAcct_Type := P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_TYPE;
	--	l_pmtinstr_rec.BankAcctInstr.BankAcct_Num := P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_NUM;
	--	l_pmtinstr_rec.BankAcctInstr.BankAcct_HolderName := P_PMTINSTR_REC.BANKACCTINSTR.BANKACCT_HOLDERNAME;

	END IF;

	l_payee_rec.Payee_ID := P_PMT_REC.PAYEE_ID;
	l_payer_rec.Payer_ID := l_payer_id;
	--l_payer_rec.Payer_Name := l_payer_name;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Payee_ID =' || l_payee_rec.Payee_ID);
	iex_debug_pub.LogMessage(l_api_name || ': Payer_ID =' || l_payer_rec.Payer_ID);
END IF;

    	OPEN tang_genid_crs;
    	FETCH tang_genid_crs INTO l_tangible_id;
    	CLOSE tang_genid_crs;

    	l_tangible_rec.tangible_id := 'IEX_' || to_char(l_tangible_id);
    	l_tangible_rec.tangible_amount := P_PMT_REC.TOTAL_AMOUNT;
    	l_tangible_rec.currency_code := P_PMT_REC.CURRENCY_CODE;
    	l_tangible_rec.RefInfo := 'IEX_' || to_char(l_tangible_id);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': PmtInstr_ID =' || l_pmtinstr_rec.PmtInstr_ID);
	iex_debug_pub.LogMessage(l_api_name || ': tangible_id = ' || l_tangible_rec.tangible_id);
	iex_debug_pub.LogMessage(l_api_name || ': tangible_amount = ' || l_tangible_rec.tangible_amount);
	iex_debug_pub.LogMessage(l_api_name || ': currency_code = ' || l_tangible_rec.currency_code);
	iex_debug_pub.LogMessage(l_api_name || ': RefInfo = ' || l_tangible_rec.RefInfo);
END IF;

	if P_PMTINSTR_REC.USE_INSTRUMENT = 'CC' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Going to auth CC...');
		iex_debug_pub.LogMessage(l_api_name || ': G_APP_ID = ' || G_APP_ID);
END IF;

    		-- call iPayment API to authorize payment
    		IBY_Payment_Adapter_Pub.OraPmtReq(
			p_api_version   => p_Api_Version,
			p_init_msg_list => FND_API.G_FALSE,
			p_commit    => FND_API.G_FALSE,
			p_ecapp_id  => 695,
			p_payee_rec => l_payee_rec,
			p_payer_rec => l_Payer_rec,
			p_pmtinstr_rec  => l_pmtinstr_rec,
			p_tangible_rec  => l_tangible_rec,
			p_pmtreqtrxn_rec => l_pmtreqtrxn_rec,
			p_riskinfo_rec  => l_RiskInfo_rec,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data  => l_msg_data,
			x_reqresp_rec => l_reqresp_rec);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': CC authorization returns:');
		iex_debug_pub.LogMessage(l_api_name || ': l_return_status=' || l_return_status || '; l_msg_count=' || l_msg_count);
		iex_debug_pub.LogMessage(l_api_name || ': status = ' || l_reqresp_rec.response.status);
		iex_debug_pub.LogMessage(l_api_name || ': ErrCode = ' || l_reqresp_rec.response.ErrCode);
		iex_debug_pub.LogMessage(l_api_name || ': ErrMessage = ' || l_reqresp_rec.response.ErrMessage);
		iex_debug_pub.LogMessage(l_api_name || ': NLS_LANG = ' || l_reqresp_rec.response.NLS_LANG);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_id = ' || l_reqresp_rec.trxn_id);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_type = ' || l_reqresp_rec.trxn_type);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_date = ' || l_reqresp_rec.trxn_date);
		iex_debug_pub.LogMessage(l_api_name || ': AuthCode = ' || l_reqresp_rec.AuthCode);
		iex_debug_pub.LogMessage(l_api_name || ': ErrorLocation = ' || l_reqresp_rec.ErrorLocation);
		iex_debug_pub.LogMessage(l_api_name || ': BEPErrCode = ' || l_reqresp_rec.BEPErrCode);
		iex_debug_pub.LogMessage(l_api_name || ': BEPErrMessage = ' || l_reqresp_rec.BEPErrMessage);
		iex_debug_pub.LogMessage(l_api_name || ': AuxMsg = ' || l_reqresp_rec.AuxMsg);
		iex_debug_pub.LogMessage(l_api_name || ': RefCode = ' || l_reqresp_rec.RefCode);
END IF;

    		-- check for iPayment errors
    		IF l_return_status<>'S' THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': IBY_Payment_Adapter_Pub.OraPmtReq failed');
END IF;
			FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_AUTH_PAYMENT');
    			FND_MESSAGE.SET_TOKEN('STATUS', l_reqresp_rec.response.status);
    			FND_MESSAGE.SET_TOKEN('ERR_LOC', l_reqresp_rec.ErrorLocation);
    			FND_MESSAGE.SET_TOKEN('ERR_CODE', l_capresp_rec.response.ErrCode);
    			FND_MESSAGE.SET_TOKEN('ERR_MSG', l_reqresp_rec.response.ErrMessage);
    			FND_MESSAGE.SET_TOKEN('BEP_ERR_CODE', l_reqresp_rec.BEPErrCode);
    			FND_MESSAGE.SET_TOKEN('BEP_ERR_MSG', l_capresp_rec.BEPErrMessage);
    			FND_MSG_PUB.initialize;
			FND_MSG_PUB.Add;
        		RAISE FND_API.G_EXC_ERROR;
    		END IF;

		l_capturetrxn_rec.Trxn_ID := l_reqresp_rec.trxn_id;
		l_capturetrxn_rec.PmtMode := 'ONLINE';
		l_capturetrxn_rec.Currency := l_tangible_rec.currency_code;
		l_capturetrxn_rec.Price := l_tangible_rec.tangible_amount;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Going to capture CC payment...');
END IF;
		IBY_Payment_Adapter_Pub.OraPmtCapture (
			p_api_version   => 1.0,
			p_init_msg_list => FND_API.G_FALSE,
			p_commit    => FND_API.G_FALSE,
			p_ecapp_id  => 695,
			p_capturetrxn_rec => l_capturetrxn_rec,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data  => l_msg_data,
			x_capresp_rec => l_capresp_rec);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': CC capture returns:');
		iex_debug_pub.LogMessage(l_api_name || ': l_return_status=' || l_return_status || '; l_msg_count=' || l_msg_count);
		iex_debug_pub.LogMessage(l_api_name || ': status = ' || l_capresp_rec.response.status);
		iex_debug_pub.LogMessage(l_api_name || ': ErrCode = ' || l_capresp_rec.response.ErrCode);
		iex_debug_pub.LogMessage(l_api_name || ': ErrMessage = ' || l_capresp_rec.response.ErrMessage);
		iex_debug_pub.LogMessage(l_api_name || ': NLS_LANG = ' || l_capresp_rec.response.NLS_LANG);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_id = ' || l_capresp_rec.trxn_id);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_type = ' || l_capresp_rec.trxn_type);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_date = ' || l_capresp_rec.trxn_date);
		iex_debug_pub.LogMessage(l_api_name || ': RefCode = ' || l_capresp_rec.RefCode);
		iex_debug_pub.LogMessage(l_api_name || ': ErrorLocation = ' || l_capresp_rec.ErrorLocation);
		iex_debug_pub.LogMessage(l_api_name || ': BEPErrCode = ' || l_capresp_rec.BEPErrCode);
		iex_debug_pub.LogMessage(l_api_name || ': BEPErrMessage = ' || l_capresp_rec.BEPErrMessage);
END IF;

    		-- check for iPayment errors
    		IF l_return_status<>'S' THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': IBY_Payment_Adapter_Pub.OraPmtCapture failed');
END IF;
			FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_CAPTURE_PAYMENT');
    			FND_MESSAGE.SET_TOKEN('STATUS', l_reqresp_rec.response.status);
    			FND_MESSAGE.SET_TOKEN('ERR_LOC', l_reqresp_rec.ErrorLocation);
    			FND_MESSAGE.SET_TOKEN('ERR_CODE', l_capresp_rec.response.ErrCode);
    			FND_MESSAGE.SET_TOKEN('ERR_MSG', l_reqresp_rec.response.ErrMessage);
    			FND_MESSAGE.SET_TOKEN('BEP_ERR_CODE', l_reqresp_rec.BEPErrCode);
    			FND_MESSAGE.SET_TOKEN('BEP_ERR_MSG', l_capresp_rec.BEPErrMessage);
    			FND_MSG_PUB.initialize;
			FND_MSG_PUB.Add;
        		RAISE FND_API.G_EXC_ERROR;
    		END IF;
	elsif P_PMTINSTR_REC.USE_INSTRUMENT = 'BA' then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Going to process BA payment...');
END IF;

    		-- call iPayment API to process BA payment
    		IBY_Payment_Adapter_Pub.OraPmtReq(
			p_api_version   => p_Api_Version,
			p_init_msg_list => FND_API.G_FALSE,
			p_commit    => FND_API.G_FALSE,
			p_ecapp_id  => 695,
			p_payee_rec => l_payee_rec,
			p_payer_rec => l_Payer_rec,
			p_pmtinstr_rec  => l_pmtinstr_rec,
			p_tangible_rec  => l_tangible_rec,
			p_pmtreqtrxn_rec => l_pmtreqtrxn_rec,
			p_riskinfo_rec  => l_RiskInfo_rec,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data  => l_msg_data,
			x_reqresp_rec => l_reqresp_rec);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': BA capture returns:');
		iex_debug_pub.LogMessage(l_api_name || ': l_return_status=' || l_return_status || '; l_msg_count=' || l_msg_count);
		iex_debug_pub.LogMessage(l_api_name || ': status = ' || l_reqresp_rec.response.status);
		iex_debug_pub.LogMessage(l_api_name || ': ErrCode = ' || l_reqresp_rec.response.ErrCode);
		iex_debug_pub.LogMessage(l_api_name || ': ErrMessage = ' || l_reqresp_rec.response.ErrMessage);
		iex_debug_pub.LogMessage(l_api_name || ': NLS_LANG = ' || l_reqresp_rec.response.NLS_LANG);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_id = ' || l_reqresp_rec.trxn_id);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_type = ' || l_reqresp_rec.trxn_type);
		iex_debug_pub.LogMessage(l_api_name || ': trxn_date = ' || l_reqresp_rec.trxn_date);
		iex_debug_pub.LogMessage(l_api_name || ': AuthCode = ' || l_reqresp_rec.AuthCode);
		iex_debug_pub.LogMessage(l_api_name || ': ErrorLocation = ' || l_reqresp_rec.ErrorLocation);
		iex_debug_pub.LogMessage(l_api_name || ': BEPErrMessage = ' || l_reqresp_rec.BEPErrMessage);
		iex_debug_pub.LogMessage(l_api_name || ': AuxMsg = ' || l_reqresp_rec.AuxMsg);
		iex_debug_pub.LogMessage(l_api_name || ': RefCode = ' || l_reqresp_rec.RefCode);
END IF;

    		-- check for iPayment errors
    		IF l_return_status<>'S' THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': IBY_Payment_Adapter_Pub.OraPmtReq failed');
END IF;
			FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_CAPTURE_PAYMENT');
    			FND_MESSAGE.SET_TOKEN('STATUS', l_reqresp_rec.response.status);
    			FND_MESSAGE.SET_TOKEN('ERR_LOC', l_reqresp_rec.ErrorLocation);
    			FND_MESSAGE.SET_TOKEN('ERR_CODE', l_capresp_rec.response.ErrCode);
    			FND_MESSAGE.SET_TOKEN('ERR_MSG', l_reqresp_rec.response.ErrMessage);
    			FND_MESSAGE.SET_TOKEN('BEP_ERR_CODE', l_reqresp_rec.BEPErrCode);
    			FND_MESSAGE.SET_TOKEN('BEP_ERR_MSG', l_capresp_rec.BEPErrMessage);
    			FND_MSG_PUB.initialize;
			FND_MSG_PUB.Add;
        		RAISE FND_API.G_EXC_ERROR;
    		END IF;
	end if;


--	l_pmtinstr_rec.PmtInstr_ID := 11111;
--	l_reqresp_rec.trxn_id := 12345;
--	l_reqresp_rec.Trxn_Type := 1;
--	l_reqresp_rec.Trxn_Date := sysdate;
--	l_reqresp_rec.AuthCode := 'test';
--	l_reqresp_rec.response.status := 1;


	else -- iPayment processing is disabled
		l_pmtinstr_rec.PmtInstr_ID := null;
		l_reqresp_rec.trxn_id := null;
		l_reqresp_rec.Trxn_Type := null;
		l_reqresp_rec.Trxn_Date := null;
		l_reqresp_rec.AuthCode := 'No iPayment processing';
		l_reqresp_rec.response.status := null;
		l_tangible_rec.tangible_id := 'No iPayment processing';
		l_payee_rec.Payee_ID := 'No iPayment processing';
		l_ar_pay_method := to_number(fnd_profile.value('IEX_CCARD_REMITTANCE'));
	end if;

	X_PMTRESP_REC.INSTRUMENT_ID := l_pmtinstr_rec.PmtInstr_ID;
	X_PMTRESP_REC.INSTRUMENT_TYPE := P_PMTINSTR_REC.USE_INSTRUMENT;
	X_PMTRESP_REC.TRXN_ID := l_reqresp_rec.trxn_id;
	X_PMTRESP_REC.TRXN_TYPE := l_reqresp_rec.Trxn_Type;
	X_PMTRESP_REC.TRXN_DATE := l_reqresp_rec.Trxn_Date;
	X_PMTRESP_REC.AUTHCODE := l_reqresp_rec.AuthCode;
	X_PMTRESP_REC.PAYEE_ID := l_payee_rec.Payee_ID;
	X_PMTRESP_REC.TANGIBLE_ID := l_tangible_rec.tangible_id;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': Return data:');
	iex_debug_pub.LogMessage(l_api_name || ': INSTRUMENT_ID = ' || X_PMTRESP_REC.INSTRUMENT_ID);
	iex_debug_pub.LogMessage(l_api_name || ': INSTRUMENT_TYPE = ' || X_PMTRESP_REC.INSTRUMENT_TYPE);
	iex_debug_pub.LogMessage(l_api_name || ': TRXN_ID = ' || X_PMTRESP_REC.TRXN_ID);
	iex_debug_pub.LogMessage(l_api_name || ': TRXN_TYPE = ' || X_PMTRESP_REC.TRXN_TYPE);
	iex_debug_pub.LogMessage(l_api_name || ': TRXN_DATE = ' || X_PMTRESP_REC.TRXN_DATE);
	iex_debug_pub.LogMessage(l_api_name || ': AUTHCODE = ' || X_PMTRESP_REC.AUTHCODE);
	iex_debug_pub.LogMessage(l_api_name || ': PAYEE_ID = ' || X_PMTRESP_REC.PAYEE_ID);
	iex_debug_pub.LogMessage(l_api_name || ': TANGIBLE_ID = ' || X_PMTRESP_REC.TANGIBLE_ID);
END IF;

       	COMMIT WORK;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
  	return;
  end if;

  -- Continue: creating IEX payment record
  BEGIN
    	SAVEPOINT CREATE_OKL_PAYMENT_PVT1;

    	-- generate new payment id
    	OPEN pay_genid_crs;
	FETCH pay_genid_crs INTO l_payment_id;
	CLOSE pay_genid_crs;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(l_api_name || ': New payment_id = ' || l_payment_id);
	iex_debug_pub.LogMessage(l_api_name || ': Before IEX_PAYMENTS_PKG.Insert_Row');
END IF;
    	IEX_PAYMENTS_PKG.Insert_Row(
        	X_ROWID => l_rowid,
        	P_PAYMENT_ID => l_payment_id,
        	P_OBJECT_VERSION_NUMBER => 1.0,
        	P_PROGRAM_ID => 695,
	        P_LAST_UPDATE_DATE => sysdate,
        	P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
	        P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
        	P_CREATION_DATE => sysdate,
        	P_CREATED_BY => FND_GLOBAL.User_Id,
        	P_PAYMENT_METHOD_ID => l_pmtinstr_rec.PmtInstr_ID,
       	 	P_PAYMENT_METHOD => P_PMTINSTR_REC.USE_INSTRUMENT,
        	P_IPAYMENT_TRANS_ID => l_reqresp_rec.trxn_id,
        	P_IPAYMENT_STATUS => l_reqresp_rec.response.status,
        	P_PAY_SVR_CONFIRMATION => l_reqresp_rec.AuthCode,
        	P_CAMPAIGN_SCHED_ID => P_PMT_REC.CAMPAIGN_SCHED_ID,
        	p_TANGIBLE_ID => l_tangible_rec.tangible_id,
        	p_PAYEE_ID => l_payee_rec.Payee_ID,
        	p_RESOURCE_ID => P_PMT_REC.RESOURCE_ID,
        	P_ATTRIBUTE_CATEGORY => P_PMT_REC.ATTRIBUTES.ATTRIBUTE_CATEGORY,
        	P_ATTRIBUTE1 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE1,
        	P_ATTRIBUTE2 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE2,
        	P_ATTRIBUTE3 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE3,
        	P_ATTRIBUTE4 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE4,
        	P_ATTRIBUTE5 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE5,
        	P_ATTRIBUTE6 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE6,
        	P_ATTRIBUTE7 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE7,
        	P_ATTRIBUTE8 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE8,
        	P_ATTRIBUTE9 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE9,
        	P_ATTRIBUTE10 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE10,
        	P_ATTRIBUTE11 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE11,
        	P_ATTRIBUTE12 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE12,
        	P_ATTRIBUTE13 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE13,
        	P_ATTRIBUTE14 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE14,
        	P_ATTRIBUTE15 => P_PMT_REC.ATTRIBUTES.ATTRIBUTE15);

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(l_api_name || ': After IEX_PAYMENTS_PKG.Insert_Row');
    END IF;
   	X_PMTRESP_REC.PAYMENT_ID := l_payment_id;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(l_api_name || ': l_payment_id=' || l_payment_id);
    END IF;

	-- commit first part of API: made iPayment money transfer and created IEX payment record with iPayment info
       	COMMIT WORK;
	FND_MESSAGE.SET_NAME('IEX', 'IEX_IPAY_SUCCESS');
	FND_MSG_PUB.Add;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT1;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
  	return;
  end if;

  -- Second part of API: OKL processing
  BEGIN
    	--Second part of API savepoint
    	SAVEPOINT CREATE_OKL_PAYMENT_PVT2;

	--l_fun_currency := get_fun_currency;
	IF P_PMT_REC.PAYMENT_TARGET = 'CNSLD' THEN

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Payment target CNSLD');
END IF;

		-- run thru table of details and call OKL payment API
		FOR i IN 1..P_PMTDTLS_TBL.COUNT LOOP

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': Details record ' || i);
			iex_debug_pub.LogMessage(l_api_name || ': Input for OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS:');
			iex_debug_pub.LogMessage(l_api_name || ': p_customer_id = ' || P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID);
			iex_debug_pub.LogMessage(l_api_name || ': p_invoice_id = ' || P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID);
			iex_debug_pub.LogMessage(l_api_name || ': p_payment_method_id = ' || l_ar_pay_method);
			iex_debug_pub.LogMessage(l_api_name || ': p_payment_ref_number = ' || 'IEX_' || l_payment_id);
			iex_debug_pub.LogMessage(l_api_name || ': p_payment_amount = ' || P_PMTDTLS_TBL(i).AMOUNT);
			iex_debug_pub.LogMessage(l_api_name || ': p_currency_code = ' || P_PMT_REC.CURRENCY_CODE);
			iex_debug_pub.LogMessage(l_api_name || ': p_payment_date = ' || sysdate);
			iex_debug_pub.LogMessage(l_api_name || ': Before OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS');
END IF;
  			OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS(
     				p_api_version => 1.0,
     				p_init_msg_list => FND_API.G_FALSE,
     				p_customer_id => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
     				p_invoice_id => P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID,
     				p_payment_method_id => l_ar_pay_method,
     				p_payment_ref_number => 'IEX_OKL_' || l_payment_id,
     				p_payment_amount => P_PMTDTLS_TBL(i).AMOUNT,
     				p_currency_code => P_PMT_REC.CURRENCY_CODE,
     				p_payment_date => sysdate,
     				x_payment_id => l_pay_okl_cnsld_id_tab(i),
     				x_return_status => L_RETURN_STATUS,
     				x_msg_count => L_MSG_COUNT,
     				x_msg_data  => L_MSG_DATA);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': After OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS');
			iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				iex_debug_pub.LogMessage(l_api_name || ': OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS failed');
END IF;
				FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_PAY_OKL_CNSLD');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

        		-- generate new pay_okl_ref id
        		OPEN pox_genid_crs;
			FETCH pox_genid_crs INTO l_pay_okl_ref_id;
			CLOSE pox_genid_crs;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(l_api_name || ': New pay_okl_ref_id = ' || l_pay_okl_ref_id);
			iex_debug_pub.LogMessage(l_api_name || ': Before IEX_PAY_OKL_XREF_PKG.INSERT_ROW');
END IF;

        		IEX_PAY_OKL_XREF_PKG.Insert_Row(
            			X_ROWID => l_rowid,
            			P_PAY_OKL_XREF_ID => l_pay_okl_ref_id,
            			P_LAST_UPDATE_DATE => sysdate,
            			P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
            			P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            			P_CREATION_DATE => sysdate,
            			P_CREATED_BY => FND_GLOBAL.User_Id,
            			P_PROGRAM_ID => 695,
            			P_OBJECT_VERSION_NUMBER => 1.0,
            			P_PAYMENT_ID => l_payment_id,
            			P_CNSLD_INVOICE_ID => P_PMTDTLS_TBL(i).CNSLD_INVOICE_ID,
            			P_CONTRACT_ID => null,
            			P_OKL_PAYMENT_ID => l_pay_okl_cnsld_id_tab(i));

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': After IEX_PAY_OKL_XREF_PKG.INSERT_ROW');
            END IF;

		END LOOP;

	ELSIF P_PMT_REC.PAYMENT_TARGET = 'CONTRACTS' THEN

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(l_api_name || ': Payment target CONTRACTS');
END IF;

		-- run thru table of details and call OKL payment API
		FOR i IN 1..P_PMTDTLS_TBL.COUNT LOOP

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': Details record ' || i);
			     iex_debug_pub.LogMessage(l_api_name || ': Before OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS');
            END IF;
  			OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS(
     				p_api_version => 1.0,
     				p_init_msg_list => FND_API.G_FALSE,
     				p_customer_id => P_PMTDTLS_TBL(i).CUST_ACCOUNT_ID,
     				p_contract_id => P_PMTDTLS_TBL(i).CONTRACT_ID,
     				p_payment_method_id => l_ar_pay_method,
     				p_payment_ref_number => 'IEX_OKL_' || l_payment_id,
     				p_payment_amount => P_PMTDTLS_TBL(i).AMOUNT,
     				p_currency_code => P_PMT_REC.CURRENCY_CODE,
     				p_payment_date => sysdate,
     				x_payment_id => l_pay_okl_contract_id_tab(i),
     				x_return_status => L_RETURN_STATUS,
     				x_msg_count => L_MSG_COUNT,
     				x_msg_data  => L_MSG_DATA);

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': After OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS');
			     iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
            END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				    iex_debug_pub.LogMessage(l_api_name || ': OKL_PAYMENT_PUB.CREATE_INTERNAL_TRANS failed');
                END IF;
				FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_PAY_OKL_CONTRACT');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

        		-- generate new pay_okl_ref id
        		OPEN pox_genid_crs;
			FETCH pox_genid_crs INTO l_pay_okl_ref_id;
			CLOSE pox_genid_crs;

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': New pay_okl_ref_id = ' || l_pay_okl_ref_id);
			     iex_debug_pub.LogMessage(l_api_name || ': Before IEX_PAY_OKL_XREF_PKG.INSERT_ROW');
            END IF;

        		IEX_PAY_OKL_XREF_PKG.Insert_Row(
            			X_ROWID => l_rowid,
            			P_PAY_OKL_XREF_ID => l_pay_okl_ref_id,
            			P_LAST_UPDATE_DATE => sysdate,
            			P_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
            			P_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            			P_CREATION_DATE => sysdate,
            			P_CREATED_BY => FND_GLOBAL.User_Id,
            			P_PROGRAM_ID => 695,
            			P_OBJECT_VERSION_NUMBER => 1.0,
            			P_PAYMENT_ID => l_payment_id,
            			p_CNSLD_INVOICE_ID => null,
            			P_CONTRACT_ID => P_PMTDTLS_TBL(i).CONTRACT_ID,
            			p_OKL_PAYMENT_ID => l_pay_okl_contract_id_tab(i));

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': After IEX_PAY_OKL_XREF_PKG.INSERT_ROW');
            END IF;

		END LOOP;

	END IF;

	-- commit second part of API: AR/OKL processing
    COMMIT WORK;

    FND_MESSAGE.SET_NAME('IEX', 'IEX_OKL_SUCCESS');
	FND_MSG_PUB.Add;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
  	return;
  end if;

  -- Third part of API: creating note
  BEGIN
    	-- Third part of API savepoint
    	SAVEPOINT CREATE_OKL_PAYMENT_PVT3;

	l_note_type := fnd_profile.value('AST_NOTES_DEFAULT_TYPE');
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.LogMessage(l_api_name || ':  l_note_type = ' ||  l_note_type);
    END IF;

	-- if note is passed - insert it
	if P_PMT_REC.NOTE is not null and l_note_type is not null then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		  iex_debug_pub.LogMessage(l_api_name || ': Note is not null');
        END IF;

		IF P_PMT_REC.PAYMENT_TARGET = 'CNSLD' or P_PMT_REC.PAYMENT_TARGET = 'CONTRACTS' THEN

			i := 1;
			-- adding parties into note context
			l_context_tab(i).context_type := 'PARTY';
			l_context_tab(i).context_id := l_note_payer_id;
			i := i + 1;
			if l_note_payer_type = 'PARTY_RELATIONSHIP' then
				l_context_tab(i).context_type := 'PARTY';
				l_context_tab(i).context_id := P_PMT_REC.PAYER_PARTY_ORG_ID;
				i := i + 1;
				l_context_tab(i).context_type := 'PARTY';
				l_context_tab(i).context_id := P_PMT_REC.PAYER_PARTY_PER_ID;
				i := i + 1;
			end if;

			FOR j IN 1..P_PMTDTLS_TBL.COUNT LOOP
				-- adding account to note context
				l_context_tab(i).context_type := 'IEX_ACCOUNT';
				l_context_tab(i).context_id := P_PMTDTLS_TBL(j).CUST_ACCOUNT_ID;
				i := i + 1;

				-- adding bill-to to note context
				l_context_tab(i).context_type := 'IEX_BILLTO';
				l_context_tab(i).context_id := P_PMTDTLS_TBL(j).CUST_SITE_USE_ID;
				i := i + 1;

				-- adding contracts/cnsld invoices to note context
				IF P_PMT_REC.PAYMENT_TARGET = 'CNSLD' THEN
					if j = 1 then
						l_source_object_id := P_PMTDTLS_TBL(j).CNSLD_INVOICE_ID;
						l_source_object_code := 'IEX_CNSLD';
					else
						l_context_tab(i).context_type := 'IEX_CNSLD';
						l_context_tab(i).context_id := P_PMTDTLS_TBL(j).CNSLD_INVOICE_ID;
						i := i + 1;
					end if;
				ELSIF P_PMT_REC.PAYMENT_TARGET = 'CONTRACTS' THEN
					if j = 1 then
						l_source_object_id := P_PMTDTLS_TBL(j).CONTRACT_ID;
						l_source_object_code := 'IEX_K_HEADER';
					else
						l_context_tab(i).context_type := 'IEX_K_HEADER';
						l_context_tab(i).context_id := P_PMTDTLS_TBL(j).CONTRACT_ID;
						i := i + 1;
					end if;
				END IF;

			END LOOP;

			-- for debug purpose only
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': l_source_object_id = ' || l_source_object_id);
			     iex_debug_pub.LogMessage(l_api_name || ': l_source_object_code = ' || l_source_object_code);
            END IF;
            FOR i IN 1..l_context_tab.COUNT LOOP
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				    iex_debug_pub.LogMessage(l_api_name || ': l_context_tab(' || i || ').context_type = ' || l_context_tab(i).context_type);
				    iex_debug_pub.LogMessage(l_api_name || ': l_context_tab(' || i || ').context_id = ' || l_context_tab(i).context_id);
                END IF;
			END LOOP;

			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': Before call to IEX_NOTES_PVT.Create_Note');
            END IF;
			IEX_NOTES_PVT.Create_Note(
				P_API_VERSION => l_api_version,
				P_INIT_MSG_LIST => FND_API.G_FALSE,
				P_COMMIT => FND_API.G_FALSE,
				P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
				X_RETURN_STATUS => l_return_status,
				X_MSG_COUNT => l_msg_count,
				X_MSG_DATA => l_msg_data,
				p_source_object_id => l_source_object_id,
				p_source_object_code => l_source_object_code,
				p_note_type => l_note_type,
				p_notes	=> P_PMT_REC.NOTE,
				p_contexts_tbl => l_context_tab,
				x_note_id => X_PMTRESP_REC.NOTE_ID);
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			     iex_debug_pub.LogMessage(l_api_name || ': After call to IEX_NOTES_PVT.Create_Note');
			     iex_debug_pub.LogMessage(l_api_name || ': Status = ' || L_RETURN_STATUS);
            END IF;

			-- check for errors
			IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
				IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				    iex_debug_pub.LogMessage(l_api_name || ': IEX_NOTES_PVT.Create_Note failed');
                END IF;
				RAISE FND_API.G_EXC_ERROR;
			END IF;

		END IF;
	end if;

	-- commit third part of API: note creation
       	COMMIT WORK;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
    	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT3;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT3;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_OKL_PAYMENT_PVT3;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END;


 -- End - Bug428444 -- varangan -- remove this comment while implementing OKL payment in R12 codeline */

END;

PROCEDURE CREATE_PAYMENT(
   	P_API_VERSION		    	IN      NUMBER,
   	P_INIT_MSG_LIST		    	IN      VARCHAR2,
   	P_COMMIT                    	IN      VARCHAR2,
   	P_VALIDATION_LEVEL	    	IN      NUMBER,
   	X_RETURN_STATUS		    	OUT NOCOPY    VARCHAR2,
   	X_MSG_COUNT                 	OUT NOCOPY    NUMBER,
   	X_MSG_DATA	    	    	OUT NOCOPY    VARCHAR2,
	P_PMT_REC			    IN	IEX_PAYMENTS_PUB.PMT_REC_TYPE,
	P_PMTDTLS_TBL			IN	IEX_PAYMENTS_PUB.PMTDTLS_TBL_TYPE,
	P_PMTINSTR_REC			IN	IEX_PAYMENTS_PUB.PMTINSTR_REC_TYPE,
	P_PMT_METHOD            IN NUMBER, -- Included by varangan for profile bug#4558547
	X_PMTRESP_REC			OUT NOCOPY	IEX_PAYMENTS_PUB.PMTRESP_REC_TYPE ) IS

BEGIN

    IF P_PMT_REC.PAYMENT_TARGET = 'ACCOUNTS' or P_PMT_REC.PAYMENT_TARGET = 'INVOICES' THEN

        /* If its AR payment call CREATE_AR_PAYMENT */
        CREATE_AR_PAYMENT(
   	        P_API_VERSION => P_API_VERSION,
   	        P_INIT_MSG_LIST	=> P_INIT_MSG_LIST,
   	        P_COMMIT => P_COMMIT,
   	        P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
   	        X_RETURN_STATUS	=> X_RETURN_STATUS,
   	        X_MSG_COUNT => X_MSG_COUNT,
   	        X_MSG_DATA => X_MSG_DATA,
	        P_PMT_REC => P_PMT_REC,
	        P_PMTDTLS_TBL => P_PMTDTLS_TBL,
	        P_PMTINSTR_REC => P_PMTINSTR_REC,
	        P_PMT_METHOD => P_PMT_METHOD, -- Included by varangan for profile bug#4558547
	        X_PMTRESP_REC => X_PMTRESP_REC);
    ELSE
         x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* -- Begin -- Commenting out for Payments Uptake
           -- Varangan- 4528444
           -- since OKL not yet designed payments uptake in R12

          -- If its OKL payment call CREATE_OKL_PAYMENT
           CREATE_OKL_PAYMENT(
   	        P_API_VERSION => P_API_VERSION,
   	        P_INIT_MSG_LIST	=> P_INIT_MSG_LIST,
   	        P_COMMIT => P_COMMIT,
   	        P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
   	        X_RETURN_STATUS	=> X_RETURN_STATUS,
   	        X_MSG_COUNT => X_MSG_COUNT,
   	        X_MSG_DATA => X_MSG_DATA,
	        P_PMT_REC => P_PMT_REC,
	        P_PMTDTLS_TBL => P_PMTDTLS_TBL,
	        P_PMTINSTR_REC => P_PMTINSTR_REC,
	        X_PMTRESP_REC => X_PMTRESP_REC);

         -- End -- Commenting out for Payments Uptake */
     END IF;
END;
begin
  PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LOGIN_ID  := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID  := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID  := FND_GLOBAL.User_Id;
  G_REQUEST_ID  := FND_GLOBAL.Conc_Request_Id;
END ;

/
