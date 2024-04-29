--------------------------------------------------------
--  DDL for Package Body FVFCATT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCATT1" as
 /* $Header: FVFCAT1B.pls 115.13 2002/03/06 14:11:19 pkm ship   $ */
Procedure Main 	(errbuf out varchar2,
		    retcode out varchar2) IS
v_count	number;
v_sob	number;
v_sob_name Varchar2(100);
v_message	varchar2(500);

begin
		-- Obtain set of books id before inserting into table.

      		v_sob := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
      		v_sob_name := FND_PROFILE.VALUE('GL_SET_OF_BKS_NAME');

	        SELECT  count(*)
		INTO	v_count
		FROM	fv_facts_attributes
		WHERE	set_of_books_id =v_sob;

		IF v_count > 0
		THEN
        	null;
                errbuf := 'Table already seeded for Set of Books: '||v_sob_name;
                retcode := -1;
	ELSE

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
	'1010',							-- facct account number
	'1010',							-- ussgl account number
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
	'X',							-- govt non govt flag
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'1110',							-- facct account number
	'1110',							-- ussgl account number
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
	'N',							-- govt non govt flag
	'N',							-- exch non exch flag
	'Y',							-- cust non cust flag
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
	'1120',							-- facct account number
	'1120',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,				-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,				-- last updated by
	FND_GLOBAL.USER_ID				-- last updated login
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
	'1130',							-- facct account number
	'1130',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1190',							-- facct account number
	'1190',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1195',							-- facct account number
	'1195',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1200',							-- facct account number
	'1200',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1310',							-- facct account number
	'1310',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1319',							-- facct account number
	'1319',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1320',							-- facct account number
	'1320',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1325',							-- facct account number
	'1325',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1329',							-- facct account number
	'1329',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1330',							-- facct account number
	'1330',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'F',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'1335',							-- facct account number
	'1335',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1340',							-- facct account number
	'1340',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1349',							-- facct account number
	'1349',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1350',							-- facct account number
	'1350',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1359',							-- facct account number
	'1359',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1360',							-- facct account number
	'1360',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1369',							-- facct account number
	'1369',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1399',							-- facct account number
	'1399',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1410',							-- facct account number
	'1410',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1450',							-- facct account number
	'1450',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1511',							-- facct account number
	'1511',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1512',							-- facct account number
	'1512',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1513',							-- facct account number
	'1513',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1521',							-- facct account number
	'1521',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1522',							-- facct account number
	'1522',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1523',							-- facct account number
	'1523',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1524',							-- facct account number
	'1524',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1525',							-- facct account number
	'1525',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1526',							-- facct account number
	'1526',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1527',							-- facct account number
	'1527',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1529',							-- facct account number
	'1529',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1531',							-- facct account number
	'1531',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1532',							-- facct account number
	'1532',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1541',							-- facct account number
	'1541',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1542',							-- facct account number
	'1542',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1549',							-- facct account number
	'1549',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1551',							-- facct account number
	'1551',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1559',							-- facct account number
	'1559',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1561',							-- facct account number
	'1561',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1569',							-- facct account number
	'1569',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1571',							-- facct account number
	'1571',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1572',							-- facct account number
	'1572',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1591',							-- facct account number
	'1591',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1599',							-- facct account number
	'1599',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1610',							-- facct account number
	'1610',							-- ussgl account number
	'S',							-- balance type
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
	'N',							-- cust non cust flag
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
	'1611',							-- facct account number
	'1611',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1612',							-- facct account number
	'1612',							-- sgl acct number
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
	'N',							-- cust non cust flag
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
	'1613',							-- facct account number
	'1613',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1620',							-- facct account number
	'1620',							-- ussgl account number
	'S',							-- balance type
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
	'N',							-- cust non cust flag
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
	'1621',							-- facct account number
	'1621',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1622',							-- facct account number
	'1622',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1623',							-- facct account number
	'1623',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

--- New account seeded for Enhancement 1541559

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
	'1630',							-- facct account number
	'1630',							-- ussgl account number
	'S',							-- balance type
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
	'N',							-- cust non cust flag
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
	'1631',							-- facct account number
	'1631',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1633',							-- facct account number
	'1633',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1638',							-- facct account number
	'1638',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1639',							-- facct account number
	'1639',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

--   New seeding End

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
	'1690',							-- facct account number
	'1690',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1711',							-- facct account number
	'1711',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1712',							-- facct account number
	'1712',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1719',							-- facct account number
	'1719',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1720',							-- facct account number
	'1720',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1730',							-- facct account number
	'1730',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1739',							-- facct account number
	'1739',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1740',							-- facct account number
	'1740',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1749',							-- facct account number
	'1749',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1750',							-- facct account number
	'1750',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1759',							-- facct account number
	'1759',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1810',							-- facct account number
	'1810',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1819',							-- facct account number
	'1819',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1820',							-- facct account number
	'1820',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1829',							-- facct account number
	'1829',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1830',							-- facct account number
	'1830',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1839',							-- facct account number
	'1839',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1840',							-- facct account number
	'1840',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1849',							-- facct account number
	'1849',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1890',							-- facct account number
	'1890',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1920',							-- facct account number
	'1920',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'1921',							-- facct account number
	'1921',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'1990',							-- facct account number
	'1990',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2110',							-- facct account number
	'2110',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'2120',							-- facct account number
	'2120',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2130',							-- facct account number
	'2130',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2140',							-- facct account number
	'2140',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2150',							-- facct account number
	'2150',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'F',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'F',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'2155',							-- facct account number
	'2155',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2160',							-- facct account number
	'2160',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2170',							-- facct account number
	'2170',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2179',							-- facct account number
	'2179',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2180',							-- facct account number
	'2180',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2190',							-- facct account number
	'2190',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2210',							-- facct account number
	'2210',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2211',							-- facct account number
	'2211',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2213',							-- facct account number
	'2213',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2215',							-- facct account number
	'2215',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2216',							-- facct account number
	'2216',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2217',							-- facct account number
	'2217',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2218',							-- facct account number
	'2218',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2220',							-- facct account number
	'2220',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2225',							-- facct account number
	'2225',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2290',							-- facct account number
	'2290',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2310',							-- facct account number
	'2310',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2320',							-- facct account number
	'2320',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2400',							-- facct account number
	'2400',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2510',							-- facct account number
	'2510',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2520',							-- facct account number
	'2520',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2530',							-- facct account number
	'2530',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2540',							-- facct account number
	'2540',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2590',							-- facct account number
	'2590',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2610',							-- facct account number
	'2610',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2620',							-- facct account number
	'2620',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2630',							-- facct account number
	'2630',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2650',							-- facct account number
	'2650',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2690',							-- facct account number
	'2690',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2910',							-- facct account number
	'2910',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2920',							-- facct account number
	'2920',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2940',							-- facct account number
	'2940',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2950',							-- facct account number
	'2950',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2960',							-- facct account number
	'2960',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'2970',							-- facct account number
	'2970',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'2980',							-- facct account number
	'2980',							-- ussgl account number
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
	'Y',							-- cust non cust flag
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
	'4032',							-- facct account number
	'4032',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
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
	'N',							-- cust non cust flag
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
	'4034',							-- facct account number
	'4034',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4042',							-- facct account number
	'4042',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
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
	'N',							-- cust non cust flag
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
	'4044',							-- facct account number
	'4044',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4047',							-- facct account number
	'4047',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4060',							-- facct account number
	'4060',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4070',							-- facct account number
	'4070',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4111',							-- facct account number
	'4111',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4112',							-- facct account number
	'4112',							-- sgl acct number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4114',							-- facct account number
	'4114',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4115',							-- facct account number
	'4115',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4116',							-- facct account number
	'4116',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4117',							-- facct account number
	'4117',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4118',							-- facct account number
	'4118',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4119',							-- facct account number
	'4119',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'Y',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'Y',							-- advance flag
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
	'4120',							-- facct account number
	'4120',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4121',							-- facct account number
	'4121',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4125',							-- facct account number
	'4125',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data for Enhancement 1541559

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
	'4126',							-- facct account number
	'4126',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4127',							-- facct account number
	'4127',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4128',							-- facct account number
	'4128',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4129',							-- facct account number
	'4129',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- End of Enhancement 1541559

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
	'4131',							-- facct account number
	'4131',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4132',							-- facct account number
	'4132',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4133',							-- facct account number
	'4133',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4135',							-- facct account number
	'4135',							-- ussgl account number
	'E',							-- balance type
	'C',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data added for Enhancement 1541559

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
	'4136',							-- facct account number
	'4136',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4137',							-- facct account number
	'4137',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data end for Enhancement 1541559

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
	'4138',							-- facct account number
	'4138',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4139',							-- facct account number
	'4139',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
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
	'N',							-- cust non cust flag
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
	'4141',							-- facct account number
	'4141',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'Y',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4142',							-- facct account number
	'4142',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'Y',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4143',							-- facct account number
	'4143',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'Y',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4145',							-- facct account number
	'4145',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'Y',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);


-- Seed data for enhancement 1541559

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
	'4146',							-- facct account number
	'4146',							-- ussgl account number
	'E',							-- balance type
	'B',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed Data End for enhancement 1541559

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
	'4147',							-- facct account number
	'4147',							-- ussgl account number
	'E',							-- balance type
	'B',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4148',							-- facct account number
	'4148',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
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
	'N',							-- cust non cust flag
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
	'4149',							-- facct account number
	'4149',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'Y',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4150',							-- facct account number
	'4150',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data added for Enhancement 1541559

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
	'4151',							-- facct account number
	'4151',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4152',							-- facct account number
	'4152',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4157',							-- facct account number
	'4157',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4158',							-- facct account number
	'4158',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

--- Seed data end for Enhancement 1541559


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
	'4160',							-- facct account number
	'4160',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
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
	'N',							-- cust non cust flag
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
	'4165',							-- facct account number
	'4165',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data added for Enhancement 1541559

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
	'4166',							-- facct account number
	'4166',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4167',							-- facct account number
	'4167',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
-- Seed data end for enhancement 1541559
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
	'4170',							-- facct account number
	'4170',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4175',							-- facct account number
	'4175',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4176',							-- facct account number
	'4176',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4180',							-- facct account number
	'4180',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4190',							-- facct account number
	'4190',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4195',							-- facct account number
	'4195',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4201',							-- facct account number
	'4201',							-- ussgl account number
	'S',							-- balance type
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
	'N',							-- cust non cust flag
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
	'4210',							-- facct account number
	'4210',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4215',							-- facct account number
	'4215',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4221',							-- facct account number
	'4221',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'E',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'Y',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4222',							-- facct account number
	'4222',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'E',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'Y',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4225',							-- facct account number
	'4225',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4251',							-- facct account number
	'4251',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'E',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'Y',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4252',							-- facct account number
	'4252',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'E',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'Y',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4255',							-- facct account number
	'4255',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data added for Enhancement 1541559

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
	'4260',							-- facct account number
	'4260',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- seed data ended for enhancement 1541559

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
	'4261',							-- facct account number
	'4261',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4262',							-- facct account number
	'4262',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4263',							-- facct account number
	'4263',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4264',							-- facct account number
	'4264',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4265',							-- facct account number
	'4265',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4266',							-- facct account number
	'4266',							-- ussgl account number
	'E',							-- balance type
	'S',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data added for Enhancement 1541559
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
	'4267',							-- facct account number
	'4267',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data Ended for Enhancement 1541559

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
	'4271',							-- facct account number
	'4271',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4272',							-- facct account number
	'4272',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4273',							-- facct account number
	'4273',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4274',							-- facct account number
	'4274',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4275',							-- facct account number
	'4275',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4276',							-- facct account number
	'4276',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4277',							-- facct account number
	'4277',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4281',							-- facct account number
	'4281',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4282',							-- facct account number
	'4282',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4283',							-- facct account number
	'4283',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4284',							-- facct account number
	'4284',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4285',							-- facct account number
	'4285',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4286',							-- facct account number
	'4286',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4287',							-- facct account number
	'4287',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4310',							-- facct account number
	'4310',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4350',							-- facct account number
	'4350',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4391',							-- facct account number
	'4391',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4392',							-- facct account number
	'4392',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'Y',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4393',							-- facct account number
	'4393',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'Y',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
-- Seed data added for enhancement 1541559
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
	'4394',							-- facct account number
	'4394',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'Y',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data ended for enhancement 1541559

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
	'4395',							-- facct account number
	'4395',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4396',							-- facct account number
	'4396',							-- ussgl account number
	'E',							-- balance type
	'P',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'Y',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

-- Seed data added for Enhancement 1541559

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
	'4397',							-- facct account number
	'4397',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4398',							-- facct account number
	'4398',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'Y',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
-- Seed dadat ended for enhancement 1541559

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
	'4420',							-- facct account number
	'4420',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4430',							-- facct account number
	'4430',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4450',							-- facct account number
	'4450',							-- ussgl account number
	'S',							-- balance type
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
	'Y',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4510',							-- facct account number
	'4510',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'N',							-- apportionmnet category
	'N',							-- reimburseable flag
	'Y',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'Y',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4590',							-- facct account number
	'4590',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4610',							-- facct account number
	'4610',							-- ussgl account number
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
	'Y',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4620',							-- facct account number
	'4620',							-- ussgl account number
	'S',							-- balance type
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
	'Y',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4630',							-- facct account number
	'4630',							-- ussgl account number
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
	'Y',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4650',							-- facct account number
	'4650',							-- ussgl account number
	'S',							-- balance type
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
	'N',							-- cust non cust flag
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
	'4700',							-- facct account number
	'4700',							-- ussgl account number
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
	'Y',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4801',							-- facct account number
	'4801',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4802',							-- facct account number
	'4802',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4831',							-- facct account number
	'4831',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4832',							-- facct account number
	'4832',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4871',							-- facct account number
	'4871',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4872',							-- facct account number
	'4872',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4881',							-- facct account number
	'4881',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4882',							-- facct account number
	'4882',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4901',							-- facct account number
	'4901',							-- ussgl account number
	'S',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4902',							-- facct account number
	'4902',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4931',							-- facct account number
	'4931',							-- ussgl account number
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
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'Y',							-- transfer flag
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
	'4971',							-- facct account number
	'4971',							-- ussgl account number
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
	'N',							-- cust non cust flag
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
	'4972',							-- facct account number
	'4972',							-- ussgl account number
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
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4981',							-- facct account number
	'4981',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'N',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
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
	'4982',							-- facct account number
	'4982',							-- ussgl account number
	'E',							-- balance type
	'N',							-- authority type
	'N',							-- definie indefinite flag
	'N',							-- legislative indicator
	'N',							-- public law code
	'Y',							-- apportionmnet category
	'Y',							-- reimburseable flag
	'N',							-- availability time
	'N',							-- transaction partner
	'N',							-- borrowing source
	'Y',							-- bea category
	'N',							-- deficiency flag
	'N',							-- function flag
	'X',							-- govt not govt
	'N',							-- exch non exch flag
	'N',							-- cust non cust flag
	'N',							-- budget subfunction
	'N',							-- advance flag
	'N',							-- transfer flag
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
end if;
Exception
   When Others Then
   errbuf := substr(SQLERRM,1,225);
   retcode := -1;
END;
End;

/
