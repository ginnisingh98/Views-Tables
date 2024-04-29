--------------------------------------------------------
--  DDL for Package Body FVFCATT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCATT2" as
/* $Header: FVFCAT2B.pls 115.15 2002/03/06 14:11:43 pkm ship   $ */

Procedure Main 	(errbuf out varchar2,
		    retcode out varchar2) IS
v_count	number;
v_sob	number;
v_sob_name Varchar2(100);
begin
		-- Verify that the table is not already seeded for an specific set_of_books

      		v_sob := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
      		v_sob_name := FND_PROFILE.VALUE('GL_SET_OF_BKS_NAME');

INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'2990',							-- facct account number
	'2990',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'2995',							-- facct account number
	'2995',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'3100',							-- facct account number
	'3100',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'3105',							-- facct account number
	'3105',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'3310',							-- facct account number
	'3310',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5100',							-- facct account number
	'5100',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'X',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5109',							-- facct account number
	'5109',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'X',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5200',							-- facct account number
	'5200',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'X',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5209',							-- facct account number
	'5209',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'X',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5310',							-- facct account number
	'5310',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5319',							-- facct account number
	'5319',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5320',							-- facct account number
	'5320',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5329',							-- facct account number
	'5329',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5400',							-- facct account number
	'5400',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5409',							-- facct account number
	'5409',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5500',							-- facct account number
	'5500',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'X',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5509',							-- facct account number
	'5509',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'X',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5600',							-- facct account number
	'5600',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'T',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5609',							-- facct account number
	'5609',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'T',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5610',							-- facct account number
	'5610',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'T',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5619',							-- facct account number
	'5619',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'T',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5700',							-- facct account number
	'5700',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5720',							-- facct account number
	'5720',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5730',							-- facct account number
	'5730',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5740',							-- facct account number
	'5740',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5745',							-- facct account number
	'5745',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5750',							-- facct account number
	'5750',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5755',							-- facct account number
	'5755',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5760',							-- facct account number
	'5760',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5765',							-- facct account number
	'5765',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5780',							-- facct account number
	'5780',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5790',							-- facct account number
	'5790',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5799',							-- facct account number
	'5799',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5800',							-- facct account number
	'5800',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'T',							-- exch non exch flag
	'Y',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5801',							-- facct account number
	'5801',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'T',							-- exch non exch flag
	'Y',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5809',							-- facct account number
	'5809',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'T',							-- exch non exch flag
	'Y',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5890',							-- facct account number
	'5890',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'T',							-- exch non exch flag
	'Y',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5900',							-- facct account number
	'5900',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5909',							-- facct account number
	'5909',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5990',							-- facct account number
	'5990',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'5991',							-- facct account number
	'5991',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6100',							-- facct account number
	'6100',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6190',							-- facct account number
	'6190',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6199',							-- facct account number
	'6199',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6310',							-- facct account number
	'6310',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6320',							-- facct account number
	'6320',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6330',							-- facct account number
	'6330',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'Y',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6400',							-- facct account number
	'6400',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6500',							-- facct account number
	'6500',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6600',							-- facct account number
	'6600',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6710',							-- facct account number
	'6710',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6720',							-- facct account number
	'6720',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6730',							-- facct account number
	'6730',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6790',							-- facct account number
	'6790',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6800',							-- facct account number
	'6800',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6850',							-- facct account number
	'6850',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'6900',							-- facct account number
	'6900',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7110',							-- facct account number
	'7110',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7180',							-- facct account number
	'7180',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7190',							-- facct account number
	'7190',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7210',							-- facct account number
	'7210',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7280',							-- facct account number
	'7280',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7290',							-- facct account number
	'7290',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7300',							-- facct account number
	'7300',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7400',							-- facct account number
	'7400',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7500',							-- facct account number
	'7500',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'Y',							-- govt not govt
	'Y',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_ATTRIBUTES	 (SET_OF_BOOKS_ID,
				 SGL_ATTRIBUTES_ID,
				 FACTS_ACCT_NUMBER,
				 USSGL_ACCT_NUMBER,
				 BALANCE_TYPE,
				 AUTHORITY_TYPE,
				 DEFINITE_INDEFINITE_FLAG,
				 LEGISLATIVE_INDICATOR,
				 PUBLIC_LAW_CODE,
				 APPORTIONMENT_CATEGORY,
				 REIMBURSEABLE_FLAG,
				 AVAILABILITY_TIME,
				 TRANSACTION_PARTNER,
				 BORROWING_SOURCE,
				 BEA_CATEGORY,
				 DEFICIENCY_FLAG,
			  	 FUNCTION_FLAG,
				 GOVT_NON_GOVT,
				 EXCH_NON_EXCH,
				 CUST_NON_CUST,
				 BUDGET_SUBFUNCTION,
				 ADVANCE_FLAG,
				 TRANSFER_FLAG,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_ATTRIBUTES_S.NEXTVAL,				-- SGL_ATTRIBUTES_ID
	'7600',							-- facct account number
	'7600',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'N',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust
	'Y',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

Exception
   When Others Then
   errbuf := substr(SQLERRM,1,225);
   retcode := -1;
END;
End;

/
