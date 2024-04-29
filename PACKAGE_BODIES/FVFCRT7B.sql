--------------------------------------------------------
--  DDL for Package Body FVFCRT7B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCRT7B" as
/* $Header: FVFCRT7B.pls 115.7 2002/06/17 00:41:37 ksriniva ship $ */
Procedure Main 	(errbuf out varchar2,
		    retcode out varchar2)  IS
v_count	number;
v_sob	number;
v_sob_name Varchar2(100);
begin
		-- Verify that the table is not already seeded for an specific set_of_books

      		v_sob := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
      		v_sob_name := FND_PROFILE.VALUE('GL_SET_OF_BKS_NAME');

		SELECT  count(*)
		INTO	v_count
		FROM	fv_facts_rt7_codes
		WHERE	set_of_books_id =v_sob;

IF v_count > 0
	THEN
	null;
        /* errbuf := 'Table already seeded for Set of Books: '||v_sob_name; */
	fv_utility.debug_mesg ('Table already seeded for Set of Books: '||v_sob_name);
ELSE
INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),		-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,					-- RT7 header id
	'911',								-- Authorization code
	' ',								-- RT7 borrowing source
	'Investments Purchased at a Discount - Unrealized Discount', 	-- Transaction Type
	'O',								-- RT7 authority type
	sysdate,							-- creation_date
	FND_GLOBAL.USER_ID,						-- created by
	sysdate,							-- last update date
	FND_GLOBAL.USER_ID,						-- last updated by
	FND_GLOBAL.USER_ID						-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1611',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1621',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,				-- RT7 header id
	'921',							-- Authorization code
	' ',							-- RT7 borrowing source
	'Funds Held Outside the Treasury - Imprest Funds', 	-- Transaction Type
	'O',							-- RT7 authority type
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1120',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1130',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);


INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,				-- RT7 header id
	'931',							-- Authorization code
	' ',							-- RT7 borrowing source
	'Investments Purchased at a Discount - Unamortized Premium and Discount', -- Transaction Type
	'O',							-- RT7 authority type
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1611',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1612',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1613',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,				-- RT7 header id
	'941',							-- Authorization code
	' ',							-- RT7 borrowing source
	'Unfunded Contract Authority',				-- Transaction Type
	'C',							-- RT7 authority type
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4032',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4034',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4131',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4132',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4133',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4135',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4138',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'B',							-- Begin/End flag
	'4139',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,				-- RT7 header id
	'951',							-- Authorization code
	'T',							-- RT7 borrowing source
	'Authority to Borrow from the Treasury',		-- Transaction Type
	'B',							-- RT7 authority type
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4042',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4044',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4141',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4142',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4143',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4145',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4148',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'B',							-- Begin/End flag
	'4149',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,				-- RT7 header id
	'962',							-- Authorization code
	'P',							-- RT7 borrowing source
	'Authority to Borrow from the Public',		 	-- Transaction Type
	'B',							-- RT7 authority type
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4042',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4044',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4141',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4142',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4143',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4145',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'4148',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'B',							-- Begin/End flag
	'4149',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,				-- RT7 header id
	'971',							-- Authorization code
	' ',							-- RT7 borrowing source
	'Investments in Public Debt Securities',	 	-- Transaction Type
	'O',							-- RT7 authority type
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);
INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1610',							-- USSGL Account
	'N',							-- Transaction Partner
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_CODES	 (SET_OF_BOOKS_ID,
				 RT7_CODE_ID,
				 RT7_CODE,
				 RT7_BORROWING_SOURCE,
				 RT7_CODE_DESCRIPTION,
				 RT7_AUTHORITY_TYPE,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_CODES_S.NEXTVAL,				-- RT7 header id
	'972',							-- Authorization code
	' ',							-- RT7 borrowing source
	'Investments in Agency Securities',			-- Transaction Type
	'O',							-- RT7 authority type
	sysdate,						-- creation_date
	FND_GLOBAL.USER_ID,					-- created by
	sysdate,						-- last update date
	FND_GLOBAL.USER_ID,					-- last updated by
	FND_GLOBAL.USER_ID					-- last updated login
);

INSERT INTO FV_FACTS_RT7_ACCOUNTS	 (SET_OF_BOOKS_ID,
				 RT7_ACCOUNT_ID,
				 RT7_CODE_ID,
				 RT7_BE_FLAG,
				 RT7_USSGL_ACCOUNT,
				 RT7_TRANSACTION_PARTNER,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN)
VALUES (TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')),	-- sob
	FV_FACTS_RT7_ACCOUNTS_S.NEXTVAL,			-- RT7 DETAIL id
	FV_FACTS_RT7_CODES_S.CURRVAL,				-- RT7 HEADER ID
	'E',							-- Begin/End flag
	'1620',							-- USSGL Account
	'F',							-- Transaction Partner
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
