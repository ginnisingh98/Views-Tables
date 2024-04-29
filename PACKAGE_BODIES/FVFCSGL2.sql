--------------------------------------------------------
--  DDL for Package Body FVFCSGL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCSGL2" as
/* $Header: FVFCUG2B.pls 115.17 2002/03/29 12:03:31 pkm ship   $ */
Procedure Main 	(errbuf out varchar2,
		    retcode out varchar2) IS
v_count	number;
v_sob	number;
v_sob_name Varchar2(100);
begin
	-- Removed as US SGL Accounts does not have set of books.
	/*
	     	v_sob := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
      		v_sob_name := FND_PROFILE.VALUE('GL_SET_OF_BKS_NAME');
	*/

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
				 LAST_UPDATE_LOGIN )
VALUES ('2610',					-- ussgl account number
	'Actuarial Pension Liability',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2620',					-- ussgl account number
	'Actuarial Health Insurance Liability',	-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2630',					-- ussgl account number
	'Actuarial Life Insuracne Liability',	-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2650',					-- ussgl account number
	'Actuarial FECA Liability',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2690',					-- ussgl account number
	'Other Actuarial Liabilities',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2910',					-- ussgl account number
	'Prior Liens Outstanding on Acquired Collateral',	-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2920',					-- ussgl account number
	'Contingent Liabilities',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2940',					-- ussgl account number
	'Capital Lease Liability',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2950',					-- ussgl account number
	'Liability for Subsidy Related to Undisbursed Loans',	-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2960',					-- ussgl account number
	'Accounts Payable From Canceled Appropriations',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2970',					-- ussgl account number
	'Resources Payable to Treasury',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2980',					-- ussgl account number
	'Custodial Liability',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2990',					-- ussgl account number
	'Other Liabilities',			-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('2995',					-- ussgl account number
	'Estimated Cleanup Cost Liability',			-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3100',					-- ussgl account number
	'Unexpended Appropriations',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3101',					-- ussgl account number
	'Unexpended Appropriations - Appropriations Received',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3102',					-- ussgl account number
	'Unexpended Appropriations - Transfers-In',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3103',					-- ussgl account number
	'Unexpended Appropriations - Transfers-Out',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3105',					-- ussgl account number
	'Appropriated Capital Funding Canceled Payables',	-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3106',					-- ussgl account number
	'Unexpended Appropriations - Adjustments',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3107',					-- ussgl account number
	'Unexpended Appropriations - Used',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3109',					-- ussgl account number
	'Unexpended Appropriations - Prior Period Adjustment',		-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('3310',					-- ussgl account number
	'Cumulative Result of Operations',	-- description
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4032',					-- ussgl account number
	'Anticipated Contract Authority',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4034',					-- ussgl account number
	'Anticipated Adjustments to Contract Authority',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4042',					-- ussgl account number
	'Estimated Borrowing Authority - Indefinite',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4044',					-- ussgl account number
	'Anticipated Reductions to Borrowing Authority',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
			         )
VALUES ('4047',					-- ussgl account number
	'Anticipated Transfer to Treasury',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4060',					-- ussgl account number
	'Anticipated Collections from Non-Federal Sources',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'D',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'C',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4070',					-- ussgl account number
	'Anticipated Collections from Federal Sources',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'D',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'C',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4111',					-- ussgl account number
	'Debt Liquidation Appropriations',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4112',					-- ussgl account number
	'Deficiency Appropriations',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4114',					-- ussgl account number
	'Appropriated Trust or Special Fund Receipts',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4115',					-- ussgl account number
	'Loan Subsidy Appropriation - Definite - Current',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4116',					-- ussgl account number
	'Entitlement Loan Subsidy Appropriation - Indefinite',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4117',					-- ussgl account number
	'Loan Administrative Expense Appropriation - Definite - Current',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4118',					-- ussgl account number
	'Re-estimated Loan Subsidy Appropriation - Indefinite - Permanent',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4119',					-- ussgl account number
	'Other Appropriation Realized',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4120',					-- ussgl account number
	'Appropriations Anticipated - Indefinite',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4121',					-- ussgl account number
	'Loan Subsidy Appropriation - Indefinite - Current',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4125',					-- ussgl account number
	'Loan Modification Adjustment Transfer Appropriation',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4126',					-- ussgl account number
	'Amounts Appropriated from Specific Treasury-Managed Trust Fund TAFS-Receivable',   -- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4127',					-- ussgl account number
	'Amounts Appropriated from Specific Treasury-Managed Trust Fund TAFS-Payable',   -- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4128',					-- ussgl account number
	'Amounts Appropriated from Specific Treasury-Managed Trust Fund TAFS-Transfers-In',   -- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4129',					-- ussgl account number
	'Amounts Appropriated from Specific Treasury-Managed Trust Fund TAFS-Transfers-Out',   -- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4131',					-- ussgl account number
	'Current-Year Contract Authority Realized - Definite',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'Y',					-- ye general flag
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
				 LAST_UPDATE_LOGIN
				 )
VALUES ('4132',					-- ussgl account number
	'Current-Year Contract Authority Realized - Indefinite',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'Y',					-- ye general flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4133',					-- ussgl account number
	'Actual Adjustment to Contract',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4135',					-- ussgl account number
	'Contract Authority Liquidated',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'Y',					-- ye general flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4136',					-- ussgl account number
	'Contract Authority To Be Liquidated by Trust Funds',   -- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4137',					-- ussgl account number
	'Transfers of Contract Authority',   -- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4138',					-- ussgl account number
	'Appropriation to Liquidate Contract Authority',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
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
				 LAST_UPDATE_LOGIN )
VALUES ('4139',					-- ussgl account number
	'Contract Authority Carried Forward',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'B',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'B',					-- ye resource/equity begin/end flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4141',					-- ussgl account number
	'Current-Year Borrowing Authority Realized - Definite',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'Y',					-- ye general flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4142',					-- ussgl account number
	'Current-Year Borrowing Authority Realized - Indefinite',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4143',					-- ussgl account number
	'Actual Reductions to Borrowing Authority',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4145',					-- ussgl account number
	'Borrowing Authority Converted to Cash',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
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
				 LAST_UPDATE_LOGIN )
VALUES ('4146',					-- ussgl account number
	'Actual Repayments of Debt, Current-Year Authority',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4147',					-- ussgl account number
	'Actual Repayments of Debt, Prior-Year Balances',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4148',					-- ussgl account number
	'Resources Realized from Borrowing Authority',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
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
				 LAST_UPDATE_LOGIN )
VALUES ('4149',					-- ussgl account number
	'Borrowing Authority Carried Forward',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'B',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'R',					-- ye resource/equity flag
	'B',					-- ye resource/equity begin/end flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4150',					-- ussgl account number
	'Reappropriations',			-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4151',					-- ussgl account number
	'Actual Capital Transfers to the General Fund of the Treasury, Current-Year Authority',			-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4152',					-- ussgl account number
	'Actual Capital Transfers to the General Fund of the Treasury, Prior-Year Balances',			-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4157',					-- ussgl account number
	'Authority Made Available from Receipt or Appropriation Balances Previously Precluded from Obligation' , -- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4158',					-- ussgl account number
	'Authority Made Available from Offsetting Collection Balances Previously Precluded from Obligation',  -- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4160',					-- ussgl account number
	'Anticipated Transfer - Current - Year Authority',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4165',					-- ussgl account number
	'Allocations of Authority-Anticipated from Investment Balances',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4166',					-- ussgl account number
	'Allocations of Realized Authority - To Be Transferred From Invested Balances',  --description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4167',					-- ussgl account number
	'Allocations of Realized Authority-Transferred From Invested Balances',  --description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4170',					-- ussgl account number
	'Transfers - Current-Year Authority',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4175',					-- ussgl account number
	'Allocation Transfers of Current-Year Authority for Non-Invested Accounts',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4176',					-- ussgl account number
	'Allocation Transfers of Prior-Year Balances',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4180',					-- ussgl account number
	'Anticipated Transfer - Prior-Year Balances',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4190',					-- ussgl account number
	'Transfers - Prior-Year Balances',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4195',					-- ussgl account number
	'Transfer of Obligated Balances',		-- description
	'E',					-- natural balance
	'2',					-- reporting type
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
				 LAST_UPDATE_LOGIN )
VALUES ('4201',					-- ussgl account number
	'Total Actual Resources - Collected',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'B',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4210',					-- ussgl account number
	'Anticipated Reimbursements and Other Income',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'D',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'C',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4215',					-- ussgl account number
	'Anticipated Appropriation Trust Fund Expenditure Transfers',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4221',					-- ussgl account number
	'Unfilled Customer Orders Without Advance',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4222',					-- ussgl account number
	'Unfilled Customer Orders With Advance',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4225',					-- ussgl account number
	'Appropriation Trust Fund Expenditure Transfers - Receivable',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4251',					-- ussgl account number
	'Reimbursements and Other Income Earned - Receivable',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4252',					-- ussgl account number
	'Reimbursements and Other Income Earned - Collected',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4255',					-- ussgl account number
	'Approprition Trust Fund Expenditure Transfers - Collected',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4260',					-- ussgl account number
	'Actual Collections of ''Government-Type'' Fees',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4261',					-- ussgl account number
	'Actual Collection of Business-Type Fees',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4262',					-- ussgl account number
	'Actual Collection of Loan Principal',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4263',					-- ussgl account number
	'Actual Collection of Loan Interest',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4264',					-- ussgl account number
	'Actual Collection of Rent',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4265',					-- ussgl account number
	'Actual Collection from Sale of Foreclosed Property',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4266',					-- ussgl account number
	'Other Actual Business-Type Collections from Non-Federal Sources',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4267',					-- ussgl account number
	'Other Actual ''Governmental-Type'' Collections from Non-Federal Sources',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4271',					-- ussgl account number
	'Actual Program Fund Subsidy Collected - Definite - Current',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4272',					-- ussgl account number
	'Actual Program Fund Subsidy Collected - Indefinite - Permanent',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4273',					-- ussgl account number
	'Interest Collected from Treasury',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4274',					-- ussgl account number
	'Actual Program Fund Subsidy Collected - Indefinite - Current',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4275',					-- ussgl account number
	'Actual Collections from Liquidating',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4276',					-- ussgl account number
	'Actual Collections from Financing',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4277',					-- ussgl account number
	'Other Actual Collections - Federal',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4281',					-- ussgl account number
	'Actual Program Fund Subsidy Receivable - Definite - Current',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4282',					-- ussgl account number
	'Actual Program Fund Subsidy Receivable - Indefinite - Permanent', -- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4283',					-- ussgl account number
	'Interest Receivable from Treasury',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4284',					-- ussgl account number
	'Actual Program Fund Subsidy Receivable - Indefinite - Current',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4285',					-- ussgl account number
	'Receivable from the Liquidating Fund',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4286',					-- ussgl account number
	'Receivable from the Financing Fund',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4287',					-- ussgl account number
	'Other Federal Receivables',		-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4310',					-- ussgl account number
	'Anticipated Recoveries of Prior-Year Obligations',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'D',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'C',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4350',					-- ussgl account number
	'Canceled Authority',			-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4391',					-- ussgl account number
	'Adjustment to Indefinite No-Year Authority',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4392',					-- ussgl account number
	'Rescissions - Current-Year',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4393',					-- ussgl account number
	'Rescissions - Prior-Year',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4394',					-- ussgl account number
	'Receipts Not Available for Obligation Upon Collection',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4395',					-- ussgl account number
	'Authority Unavailable Pursuant to Public Law - Temporary',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4396',					-- ussgl account number
	'Authority Permanently Not Available Pursuant to Public Law',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4397',					-- ussgl account number
	'Receipts and Appropriations Temporarily Precluded from Obligation',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4398',					-- ussgl account number
	'Offsetting Collections Temporarily Precluded from Obligation',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	' ',					-- resource status begin//end flag
	' ',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4420',					-- ussgl account number
	'Unapportioned Authority - Pending Rescission',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4430',					-- ussgl account number
	'Unapportioned Authority - OMB Deferral',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4450',					-- ussgl account number
	'Unapportioned Authority',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4510',					-- ussgl account number
	'Apportionments',			-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4590',					-- ussgl account number
	'Apportionments Unavailable - Anticipated Resources',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
	'Y',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4610',					-- ussgl account number
	'Allotments - Realized Resources',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4620',					-- ussgl account number
	'Unobligated Funds Not Subject to Apportionment',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4630',					-- ussgl account number
	'Funds Not Available for Commitment/Obligation',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4650',					-- ussgl account number
	'Allotments - Expired Authority',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4700',					-- ussgl account number
	'Commitments',				-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4801',					-- ussgl account number
	'Undelivered Orders-Obligations, Unpaid',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'B',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	'S',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4802',					-- ussgl account number
	'Undelivered Orders-Obligations, Prepaid/Advanced',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'B',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	'S',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	'E',					-- ye resource/equity flag
	'E',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'Y',					-- disbursement flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4831',					-- ussgl account number
	'Undelivered Orders-Obligations Transferred, Unpaid',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
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
				 LAST_UPDATE_LOGIN )
VALUES ('4832',					-- ussgl account number
	'Undelivered Orders-Obligations Transferred,Prepaid/Advanced',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
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
				 LAST_UPDATE_LOGIN )
VALUES ('4871',					-- ussgl account number
	'Downward Adjustments of Prior-Year Unpaid Undelivered Orders-Obligations,Recoveries',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4872',					-- ussgl account number
	'Downward Adjustments of Prior-Year Prepaid/Advanced Undelivered Orders-Obligations, Refunds Collected',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4881',					-- ussgl account number
	'Upward Adjustments of Prior-Year Undelivered Orders-Obligations, Unpaid',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4882',					-- ussgl account number
	'Upward Adjustments of Prior-Year Undelivered Orders-Obligations,Prepaid/Advanced',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'Y',					-- disbursement flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4901',					-- ussgl account number
	'Delivered Orders-Obligations, Unpaid',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	'B',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
	'S',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4902',					-- ussgl account number
	'Delivered Orders-Obligations,Paid',		-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'Y',					-- disbursement flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4931',					-- ussgl account number
	'Delivered Orders Obligations Transferred,Unpaid',	-- description
	'E',					-- natural balance
	'2',					-- reporting type
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
				 LAST_UPDATE_LOGIN )
VALUES ('4971',					-- ussgl account number
	'Downward Adjustments of Prior-Year Unpaid Delivered Orders-Obligations, Recoveries',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4972',					-- ussgl account number
	'Downward Adjustments of Prior-Year Paid Delivered Orders-Obligations, Refunds Collected',	-- description
	'D',					-- natural balance
	'2',					-- reporting type
	'E',					-- total resource begin/end flag
	'E',					-- total resource debit/credit flag
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
	'Y',					-- collections flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4981',					-- ussgl account number
	'Upward Adjustments of Prior-Year Delivered Orders-Obligations, Unpaid' ,	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('4982',					-- ussgl account number
	'Upward Adjustments of Prior-Year Delivered Orders-Obligations,Paid',	-- description
	'C',					-- natural balance
	'2',					-- reporting type
	' ',					-- total resource begin/end flag
	' ',					-- total resource debit/credit flag
	'E',					-- resource status begin//end flag
	'E',					-- resource status debit/credit flag
	'N',					-- ye end anticipated flag
	' ',					-- ye resource/equity flag
	' ',					-- ye resource/equity begin/end flag
	'N',					-- fund balance account flag
	'N',					-- ye general flag
	'N',					-- ye negative receivables flag
	'N',					-- ye negative payables flag
	'Y',					-- disbursement flag
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
				 LAST_UPDATE_LOGIN )
VALUES ('5100',					-- ussgl account number
	'Revenue from Goods Sold',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5109',					-- ussgl account number
	'Contra Revenue for Goods Sold',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5200',					-- ussgl account number
	'Revenue from Services Provided',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5209',					-- ussgl account number
	'Contra Revenue for Services Provided',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5310',					-- ussgl account number
	'Interest Revenue',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5319',					-- ussgl account number
	'Contra Revenue for Interest',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5320',					-- ussgl account number
	'Penalties, Fines and Administrative Fees Revenue',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5329',					-- ussgl account number
	'Contra Revenue for Penalties, Fines and Administrative Fees',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5400',					-- ussgl account number
	'Benefit Program Revenue',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5409',					-- ussgl account number
	'Contra Revenue for Benefit Program Revenue',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5500',					-- ussgl account number
	'Insurance and Guarantee Premium Revenue', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5509',					-- ussgl account number
	'Contra Revenue for Insurance and Guarantee Premium Revenue',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5600',					-- ussgl account number
	'Donated Revenue - Financial Resources',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5609',					-- ussgl account number
	'Contra Revenue for Donations - Financial Resources',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5610',					-- ussgl account number
	'Donated Revenue - Nonfinancial Resources', 	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5619',					-- ussgl account number
	'Contra Donated Revenue - Nonfinancial Resources', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5700',					-- ussgl account number
	'Expended Appropriations',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5720',					-- ussgl account number
	'Financing Sources Transferred in Without Reimbursement', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5730',					-- ussgl account number
	'Financing Sources Transferred Out Without Reimbursement', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5740',					-- ussgl account number
	'Appropriated Earnmarked Receipts Transferred in', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5745',					-- ussgl account number
	'Appropriated Earnmarked Receipts Trasnferred Out', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5750',					-- ussgl account number
	'Expenditure Financing Sources - Transfers-In',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5755',					-- ussgl account number
	'Nonexpenditure Financing Sources - Transfers-In',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5760',					-- ussgl account number
	'Expenditure Financing Sources - Transfers-Out',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5765',					-- ussgl account number
	'Nonexpenditure Financing Sources - Transfers-Out',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5780',					-- ussgl account number
	'Imputed Financing Sources',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5790',					-- ussgl account number
	'Other Financing Sources',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5799',					-- ussgl account number
	'Adjustment of Appropriations Used',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5800',					-- ussgl account number
	'Tax Revenue Collected',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5801',					-- ussgl account number
	'Tax Revenue Accrual Adjustment',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5809',					-- ussgl account number
	'Contra Revenue for Taxes',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5890',					-- ussgl account number
	'Tax Revenue Refunds',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5900',					-- ussgl account number
	'Other Revenue',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5909',					-- ussgl account number
	'Contra Revenue for Other Revenue',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5990',					-- ussgl account number
	'Collections for Others',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('5991',					-- ussgl account number
	'Accrued Collections for Others',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6100',					-- ussgl account number
	'Operating Expenses/Program',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6190',					-- ussgl account number
	'Contra Bad Debt Expense - Incurred for Others', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6199',					-- ussgl account number
	'Adjustment to Subsidy Expense',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6310',					-- ussgl account number
	'Interest Expenses on Borrowing from Treasury',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6320',					-- ussgl account number
	'Interest Expenses on Securities',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6330',					-- ussgl account number
	'Other Interest Expenses',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6400',					-- ussgl account number
	'Benefit Expense',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6500',					-- ussgl account number
	'Cost of Goods Sold',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6600',					-- ussgl account number
	'Applied Overhead',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6610',					-- ussgl account number
	'Cost Capitalization Offset',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6710',					-- ussgl account number
	'Depreciation, Amortization and Depletion',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6720',					-- ussgl account number
	'Bad Debt Expense',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6730',					-- ussgl account number
	'Imputed Costs',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6790',					-- ussgl account number
	'Other Expenses Not Requiring Budgetary Resources', -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6800',					-- ussgl account number
	'Future Funded Expenses',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6850',					-- ussgl account number
	'Employer Contributions to Employee Benefit Programs Not Requiring Current Year Budget Authority (Unobligated)'  ,   -- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('6900',					-- ussgl account number
	'Nonproduction Costs',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7110',					-- ussgl account number
	'Gains on Disposition of Assets',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7180',					-- ussgl account number
	'Unrealized Gains - Investments',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7190',					-- ussgl account number
	'Other Gains',				-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7210',					-- ussgl account number
	'Losses on Disposition of Assets',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7280',					-- ussgl account number
	'Unrealized Losses-Investments',				-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7290',					-- ussgl account number
	'Other Losses',				-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7300',					-- ussgl account number
	'Extraordinary Items',			-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7400',					-- ussgl account number
	'Prior Period Adjustments',		-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7500',					-- ussgl account number
	'Distribution of Income - Dividend',	-- description
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
				 LAST_UPDATE_LOGIN )
VALUES ('7600',					-- ussgl account number
	'Changes in Actuarial Liability',	-- description
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

-- Start Bug 2212263

UPDATE fv_facts_ussgl_accounts
SET edck12_balance_type='E'
WHERE disbursements_flag='Y' OR collections_flag='Y';

UPDATE fv_facts_ussgl_accounts
SET edck12_balance_type='S'
WHERE (disbursements_flag='Y' OR collections_flag='Y') AND
ussgl_account IN ('4802','4222');

-- End Bug 2212263

Exception
   When Others Then
   errbuf := substr(SQLERRM,1,225);
   retcode := -1;
END;
End;

/
