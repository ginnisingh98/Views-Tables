--------------------------------------------------------
--  DDL for Package Body CSTACDLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTACDLS" AS
/* $Header: CSTACDLB.pls 115.2 2002/11/08 00:49:21 awwang ship $ */

PROCEDURE DELETE_SUMMARY_DETAILS(
 i_org_id               IN      NUMBER,
 i_del_period_id        IN      NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2)

IS

	l_stmt_num		NUMBER;

 BEGIN

	l_stmt_num := 10;

	DELETE FROM MTL_PER_CLOSE_DTLS
	WHERE
	ORGANIZATION_ID		=	I_ORG_ID	AND
	ACCT_PERIOD_ID		=	I_DEL_PERIOD_ID;

	l_stmt_num := 20;

	DELETE FROM MTL_PERIOD_SUMMARY
	WHERE
	ORGANIZATION_ID         =       I_ORG_ID        AND
        ACCT_PERIOD_ID          =       I_DEL_PERIOD_ID;

	commit;


   EXCEPTION

        WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := 'CSTACDLS:' || to_char(l_stmt_num) || substr(SQLERRM,1,150);

        rollback;

END DELETE_SUMMARY_DETAILS;

END CSTACDLS;

/
