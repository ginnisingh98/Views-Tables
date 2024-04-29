--------------------------------------------------------
--  DDL for Package Body FVFCSGL1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCSGL1" as
/* $Header: FVFCUG1B.pls 115.11 2002/06/17 00:41:46 ksriniva ship $ */
Procedure Main 	(errbuf out varchar2,
		    retcode out varchar2) IS
v_count	number;
v_sob	number;
v_sob_name Varchar2(100);
begin
		-- Verify that the table is not already seeded for an specific set_of_books
		-- Removed, since US SGL Accounts doest not have set of books.

      		/* v_sob := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
      		v_sob_name := FND_PROFILE.VALUE('GL_SET_OF_BKS_NAME');*/

		SELECT  count(*)
		INTO	v_count
		FROM	fv_facts_ussgl_accounts;

		IF v_count > 0
		THEN
        	null;
            	errbuf := 'Table already seeded. Can not run the same process twice, unless the existing records are deleted.';
            	retcode := -1;
ELSE

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1010',					-- ussgl account number
	'Fund Balance With Treasury',		-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'Y',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1110',					-- ussgl account number
	'Undeposited Collections',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1120',					-- ussgl account number
	'Imprest Funds',			-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1130',					-- ussgl account number
	'Funds Held by the Public',		-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1190',					-- ussgl account number
	'Other Cash',				-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1195',					-- ussgl account number
	'Other Monetary Assets',		-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1200',					-- ussgl account number
	'Foreign Currency',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1310',					-- ussgl account number
	'Accounts Receivable',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1319',					-- ussgl account number
	'Allowance for Loss on Accounts Receivable',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1320',					-- ussgl account number
	'Employment Benefit Contributions Receivable',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1325',					-- ussgl account number
	'Taxes Receivable',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1329',					-- ussgl account number
	'Allowance for Loss on Taxes Receivable',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1330',					-- ussgl account number
	'Receivable for Transfers of Currently Invested Balances',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'Y',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1335',					-- ussgl account number
	'Expenditure Transfers Receivable',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1340',					-- ussgl account number
	'Interest Receivable',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1349',					-- ussgl account number
	'Allowance for Loss on Interest Receivable',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1350',					-- ussgl account number
	'Loans Receivable',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1359',					-- ussgl account number
	'Allowance for Loss on Loans Receivable',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1360',					-- ussgl account number
	'Penalties, Fines and Administrative Fees Receivable',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID                      -- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1369',					-- ussgl account number
	'Allowance for Loss on Penalties, Fines and Administrative Fees Receivable',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1399',					-- ussgl account number
	'Allowance for Subsidy',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1410',					-- ussgl account number
	'Advances to Others',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1450',					-- ussgl account number
	'Prepayments',				-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1511',					-- ussgl account number
	'Operating Materials and Supplies Held for Use',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1512',					-- ussgl account number
	'Operating Materials and Supplies Held in Reserve for Future Use',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1513',					-- ussgl account number
	'Operating Materials and Supplies - Excess, Unserviceable and Obsolete',	 -- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1514',					-- ussgl account number
	'Operating Materials and Supplies Held for Repair',	 -- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1519',					-- ussgl account number
	'Operating Materials and Supplies - Allowance',	 -- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1521',					-- ussgl account number
	'Inventory Purchased for Resale',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1522',					-- ussgl account number
	'Inventory Held in Reserve fo Future Sale',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1523',					-- ussgl account number
	'Inventory Held for Repair',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1524',					-- ussgl account number
	'Inventory - Excess, Obsolete and Unserviceable',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1525',					-- ussgl account number
	'Inventory, Raw Materials',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1526',					-- ussgl account number
	'Inventory - Work-in-Process',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1527',					-- ussgl account number
	'Inventory - Finished Goods',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1529',					-- ussgl account number
	'Inventory - Allowance',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1531',					-- ussgl account number
	'Seized Monetary Instruments',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1532',					-- ussgl account number
	'Seized Cash Deposited',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1541',					-- ussgl account number
	'Forfeited Property Held for Sale',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1542',					-- ussgl account number
	'Forfeited Property Held for Donation or Use',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1549',					-- ussgl account number
	'Forfeited Property - Allowance',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1551',					-- ussgl account number
	'Foreclosed Property',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1559',					-- ussgl account number
	'Foreclosed Property - Allowance',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1561',					-- ussgl account number
	'Commodities Held Under Price Support and Stabilization Support Programs',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1569',					-- ussgl account number
	'Commodities - Allowance',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1571',					-- ussgl account number
	'Stockpile Materials Held in Reserve',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1572',					-- ussgl account number
	'Stockpile Materials Held for Sale',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1591',					-- ussgl account number
	'Other Related Property',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1599',					-- ussgl account number
	'Other Related Property - Allowance',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1610',					-- ussgl account number
	'Investment in U.S. Treasury Securities Issued by Public Debt',	-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1611',					-- ussgl account number
	'Discount on  U.S. Treasury Securities Issued by Public Debt',	-- description
	'C',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1612',					-- ussgl account number
	'Premium on U.S. Treasury Securities Issued by Public Debt',	-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1613',					-- ussgl account number
	'Amortization of Discount and Premium on U.S. Treasury Securities Issued by Public Debt',	-- description
	'E',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1618',					-- ussgl account number
	'Market Adjustment - Investments',	 -- description
	'E',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1620',					-- ussgl account number
	'Investment in Securities Other than Public Debt Securities',	-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1621',					-- ussgl account number
	'Discount on Securities Other than Public Debt Securities',	-- description
	'C',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1622',					-- ussgl account number
	'Premium on Securities Other than Public Debt Securities',	-- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1623',					-- ussgl account number
	'Amoritization of Premium and Discount on Securities Other than Public Debt Securities',	-- description
	'E',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1630',					-- ussgl account number
	'Investments in U.S. Treasury Zero Coupon Bonds Issued by Public Debt',	 -- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1631',					-- ussgl account number
	'Discount on U.S. Treasury Zero Coupon Bonds Issued by Public Debt',	 -- description
	'C',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1633',					-- ussgl account number
	'Amortization of Discount on U.S. Treasury Zero Coupon Bonds Issue by Public Debt',	 -- description
	'D',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1638',					-- ussgl account number
	'Market Adjustment - Investments in U.S. Treasury Zero Coupon Bonds',	 -- description
	'E',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1639',					-- ussgl account number
	'Contra Market Adjustment - Investments in U.S. Treasury Zero Coupon Bonds',	 -- description
	'E',					-- natural balance
	'3',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);

INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1690',					-- ussgl account number
	'Other Investments',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1711',					-- ussgl account number
	'Land and Land Rights',			-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1712',					-- ussgl account number
	'Improvements to Land',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1719',					-- ussgl account number
	'Accumulated Depreciation on Improvements to Land',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1720',					-- ussgl account number
	'Construction-in-Progress',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1730',					-- ussgl account number
	'Buildings, Improvements and Renovations',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1739',					-- ussgl account number
	'Accumulated Depreciation on Buildings, Improvements and Renovations',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1740',					-- ussgl account number
	'Other Structures and Facilities',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1749',					-- ussgl account number
	'Accumulated Depreciation on Other Structures and Facilities',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1750',					-- ussgl account number
	'Equipment',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1759',					-- ussgl account number
	'Accumulated Depreciation on Equipment',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1810',					-- ussgl account number
	'Assets Under Capital Lease',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1819',					-- ussgl account number
	'Accumulated Depreciation on Assets Under Capital Lease',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1820',					-- ussgl account number
	'Leasehold Improvements',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1829',					-- ussgl account number
	'Accumulated Amortization on Leasehold Improvements',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1830',					-- ussgl account number
	'Internal Use Software',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1832',					-- ussgl account number
	'Internal Use Software in Development',	 -- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);


INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1839',					-- ussgl account number
	'Accumulated Amortization on Internal Use Software',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1840',					-- ussgl account number
	'Other Natural Resources',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1849',					-- ussgl account number
	'Allowance for Depletion',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1890',					-- ussgl account number
	'Other General Property, Plant and Equipment',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1920',					-- ussgl account number
	'Unrequisitioned Authorized Appropriations',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1921',					-- ussgl account number
	'Receivable Appropriations',		-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('1990',					-- ussgl account number
	'Other Assets',				-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2110',					-- ussgl account number
	'Accounts Payable',			-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2120',					-- ussgl account number
	'Disbursement in Transit',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2130',					-- ussgl account number
	'Contract Holdbacks',			-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2140',					-- ussgl account number
	'Accrued Interest Payable',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2150',					-- ussgl account number
	'Payable for Transfers of Currently Invested Balances',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'Y',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2155',					-- ussgl account number
	'Expenditure Transfers Payable',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2160',					-- ussgl account number
	'Entitlement Benefits Due and Payable',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2170',					-- ussgl account number
	'Subsidy Payable to Financing Account',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2179',					-- ussgl account number
	'Contra Liability for Subsidy Payable to Financing Account ',	-- description
	'D',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2180',					-- ussgl account number
	'Loan Guarantee Liability',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2190',					-- ussgl account number
	'Other Accrued Liabilities',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2210',					-- ussgl account number
	'Accrued Funded Payroll and Leave',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2211',					-- ussgl account number
	'Witholdings Payable',			-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2213',					-- ussgl account number
	'Employer Contributions and Payroll Taxes Payable',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2215',					-- ussgl account number
	'Other Post-Employment Benefits Due and Payable',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2216',					-- ussgl account number
	'Pension Benefits Due and Payable to Beneficiaries',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2217',					-- ussgl account number
	'Benefit Premiums Payable to Carriers',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2218',					-- ussgl account number
	'Life Insurance Benefits Due and Payable to Beneficiaries',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2220',					-- ussgl account number
	'Unfunded Leave',			-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2225',					-- ussgl account number
	'Unfunded FECA Liability',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2290',					-- ussgl account number
	'Other Unfunded Employment Related Liability',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2310',					-- ussgl account number
	'Advances from Others',			-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2320',					-- ussgl account number
	'Deferred Credits',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2400',					-- ussgl account number
	'Liability for Deposit Funds, Clearing Accounts and Undeposited Collections',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2510',					-- ussgl account number
	'Principal Payable to Treasury',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2520',					-- ussgl account number
	'Principal Payable to the Federal Financing Bank',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2530',					-- ussgl account number
	'Securities Issued by Federal Agencies Under General and Special Financing Authority, Net',	-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2540',					-- ussgl account number
	'Participation Certificates',		-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
INSERT INTO FV_FACTS_USSGL_ACCOUNTS ( USSGL_ACCOUNT,
				 DESCRIPTION,
				 NATURAL_BALANCE,
				 REPORTING_TYPE,
				 TOTAL_RESOURCE_BE_FLAG,
				 TOTAL_RESOURCE_DC_FLAG,
				 RESOURCE_STATUS_BE_FLAG,
				 RESOURCE_STATUS_DC_FLAG,
				 YE_ANTICIPATED_FLAG,
				 YE_RESOURCE_EQUITY_FLAG,
				 YE_RESOURCE_EQUITY_BE_FLAG,
				 FUND_BALANCE_ACCOUNT_FLAG,
				 YE_GENERAL_FLAG,
				 YE_NEG_RECEIVABLES_FLAG,
				 YE_NEG_PAYABLES_FLAG,
				 DISBURSEMENTS_FLAG,
				 COLLECTIONS_FLAG,
			  	 USSGL_ENABLED_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES ('2590',					-- ussgl account number
	'Other Debt',			-- description
	'C',					-- natural balance
	'1',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'N',					-- disbursement flag
	'N',					-- collections flag
	'Y',					-- ussgl enabled flag
	sysdate,				-- creation_date
	FND_GLOBAL.USER_ID,			-- created by
	sysdate,				-- last update date
	FND_GLOBAL.USER_ID,			-- last updated by
	FND_GLOBAL.USER_ID			-- last updated login
);
end if;
Exception
   When Others Then
   errbuf := substr(SQLERRM,1,225);
   retcode := -1;
END;
End;

/
