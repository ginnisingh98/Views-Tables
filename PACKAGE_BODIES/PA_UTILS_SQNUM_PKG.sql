--------------------------------------------------------
--  DDL for Package Body PA_UTILS_SQNUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UTILS_SQNUM_PKG" as
/* $Header: PAXGSQNB.pls 120.1.12000000.2 2008/09/27 09:27:50 bifernan ship $ */

  /*----------------------------------------------------------+
   | get_unique_proj_num : a procedure to get a unique number |
   |            for the automatic project number.             |
   |                                                          |
   |    unique_number :  contains the returned unique number. |
   |    x_status      :  contains the returned status.        |
   |                                                          |
   |            x_status = 0         if it is successful.     |
   |                     = 1         if no data found.        |
   |                     = sqlcode   otherwise                |
   |    Bug fix : 438413 - Next number should actually be the |
   |              next number that is to be used, not the last|
   |              number used, as is currently stored in the  |
   |              table. The next number will now be stored.  |
   |              tsaifee  01/24/97                           |
   +----------------------------------------------------------*/
  PROCEDURE get_unique_proj_num(x_table_name       IN      VARCHAR2,
				user_id		 IN	   NUMBER,
                                unique_number    IN OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
				x_status	 IN OUT    NOCOPY NUMBER) is --File.Sql.39 bug 4440895
    uniqueid NUMBER;
    -- Commented by Sachin. Bug 3517177
--    PL_DUMMY PA_UNIQUE_IDENTIFIER_CONTROL.NEXT_UNIQUE_IDENTIFIER%TYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;   -- Added by Sachin. Bug 3517177

  BEGIN

    x_status := 0;

--  tsaifee 01/24/97 : First select the number from the table
--  then increment and update it.

--    LOCK TABLE PA_UNIQUE_IDENTIFIER_CONTROL IN SHARE UPDATE MODE;
 /* Commented by sachin. Bug 3517177
    SELECT  NEXT_UNIQUE_IDENTIFIER
    INTO    PL_DUMMY
    FROM    PA_UNIQUE_IDENTIFIER_CONTROL
    WHERE   TABLE_NAME = x_table_name
    AND     NEXT_UNIQUE_IDENTIFIER IS NOT NULL
    FOR UPDATE OF NEXT_UNIQUE_IDENTIFIER;
 */
    SELECT  NEXT_UNIQUE_IDENTIFIER
    INTO    uniqueid
    FROM    PA_UNIQUE_IDENTIFIER_CONTROL
    WHERE   TABLE_NAME = x_table_name
    AND     NEXT_UNIQUE_IDENTIFIER IS NOT NULL
    FOR UPDATE OF NEXT_UNIQUE_IDENTIFIER;

    UPDATE  PA_UNIQUE_IDENTIFIER_CONTROL
    SET     NEXT_UNIQUE_IDENTIFIER = NEXT_UNIQUE_IDENTIFIER + 1,
            LAST_UPDATED_BY        = user_id,
            LAST_UPDATE_DATE       = trunc(SYSDATE)
    WHERE   TABLE_NAME             = x_table_name
    AND     NEXT_UNIQUE_IDENTIFIER IS NOT NULL;

    unique_number := uniqueid;
  Commit;   -- Added by Sachin. Bug 3517177

  EXCEPTION

    when NO_DATA_FOUND then
	x_status := 1;
         rollback; --Added by Sachin. Bug 3517177

    WHEN OTHERS then
  	x_status := SQLCODE;
        rollback; --Added by Sachin. Bug 3517177

  END get_unique_proj_num;

  /*----------------------------------------------------------+
   | get_unique_invoice_num : a procedure to get a unique     |
   |            number for the automatic project number.      |
   |                                                          |
   |    unique_number :  contains the returned unique number. |
   |    x_status      :  contains the returned status.        |
   |                                                          |
   |            x_status = 0         if it is successful.     |
   |                     = 1         if no data found.        |
   |                     = sqlcode   otherwise                |
   |    Bug fix : 438413 - Next number should actually be the |
   |              next number that is to be used, not the last|
   |              number used, as is currently stored in the  |
   |              table. The next number will now be stored.  |
   |              tsaifee  01/24/97                           |
   +----------------------------------------------------------*/
  PROCEDURE get_unique_invoice_num(invoice_category IN      VARCHAR2,
                                   user_id          IN        NUMBER,
                                   unique_number    IN OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_status         IN OUT    NOCOPY NUMBER) is --File.Sql.39 bug 4440895
    uniqueid NUMBER;
    PL_DUMMY PA_IMPLEMENTATIONS.NEXT_AUTOMATIC_INVOICE_NUMBER%TYPE;

  BEGIN

    x_status := 0;

--  tsaifee 01/24/97 : First select the number from the table
--  then increment and update it.
--  Commented due to bug#634122 by Arindam

--  LOCK TABLE PA_IMPLEMENTATIONS IN SHARE UPDATE MODE;


    SELECT  decode(invoice_category, 'EXTERNAL-INVOICE',NEXT_AUTOMATIC_INVOICE_NUMBER,
                                     CC_NEXT_AUTOMATIC_INVOICE_NUM)
    INTO    PL_DUMMY
    FROM    PA_IMPLEMENTATIONS
    FOR UPDATE OF NEXT_AUTOMATIC_INVOICE_NUMBER,CC_NEXT_AUTOMATIC_INVOICE_NUM;

    SELECT  decode(invoice_category, 'EXTERNAL-INVOICE',NEXT_AUTOMATIC_INVOICE_NUMBER,
                                    CC_NEXT_AUTOMATIC_INVOICE_NUM)
    INTO    uniqueid
    FROM    PA_IMPLEMENTATIONS;

    UPDATE  PA_IMPLEMENTATIONS
    SET     NEXT_AUTOMATIC_INVOICE_NUMBER = decode(invoice_category,
                                                     'EXTERNAL-INVOICE',NEXT_AUTOMATIC_INVOICE_NUMBER + 1,
                                                     NEXT_AUTOMATIC_INVOICE_NUMBER),
         CC_NEXT_AUTOMATIC_INVOICE_NUM = decode(invoice_category,
                                                     'EXTERNAL-INVOICE',CC_NEXT_AUTOMATIC_INVOICE_NUM ,
                                                     CC_NEXT_AUTOMATIC_INVOICE_NUM+1),
            LAST_UPDATED_BY        = user_id,
            LAST_UPDATE_DATE       = trunc(SYSDATE);

    unique_number := uniqueid;

  EXCEPTION
/* Commented out for bug 1327836 as error is not handled in PAXVIACB.pls.If this
commnt is removed please handle the error at PAXVIACB.pls

    when NO_DATA_FOUND then
        x_status := 1;

    WHEN OTHERS then
        x_status := SQLCODE; */

/* Commented the above exception handling part and added the following
   lines as part of fix for bug# 1327836*/

    WHEN OTHERS then
		raise;

  END get_unique_invoice_num;

  --Bug 7335526. Added code to revert the project number in
  /*--------------------------------------------------------------+
  | revert_unique_proj_num : A procedure to revert a unique       |
  |            number for the automatic project number if project |
  |            creation errors out.                               |
  |    p_unique_number :  contains the unique number which should |
  |                       be reverted.                            |
  +---------------------------------------------------------------*/
  PROCEDURE revert_unique_proj_num(p_table_name       IN      VARCHAR2,
                                   p_user_id          IN      NUMBER,
                                   p_unique_number    IN      NUMBER) is

    PRAGMA AUTONOMOUS_TRANSACTION;   -- Added by Sachin. Bug 3517177

  BEGIN

    UPDATE  PA_UNIQUE_IDENTIFIER_CONTROL
    SET     NEXT_UNIQUE_IDENTIFIER = p_unique_number,
            LAST_UPDATED_BY        = p_user_id,
            LAST_UPDATE_DATE       = trunc(SYSDATE)
    WHERE   TABLE_NAME             = p_table_name
    AND     NEXT_UNIQUE_IDENTIFIER IS NOT NULL
    AND     NEXT_UNIQUE_IDENTIFIER = p_unique_number + 1 ;

    Commit;


  END;

END PA_UTILS_SQNUM_PKG;

/
