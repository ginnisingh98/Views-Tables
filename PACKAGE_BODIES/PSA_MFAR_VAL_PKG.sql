--------------------------------------------------------
--  DDL for Package Body PSA_MFAR_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MFAR_VAL_PKG" AS
/* $Header: PSAMFVLB.pls 120.10 2006/09/13 14:09:08 agovil ship $ */

/* Procedure to Validate the Transaction Header */
--===========================FND_LOG.START=====================================
g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFVLB.PSA_MFAR_VAL_PKG.';
--===========================FND_LOG.END=======================================

PROCEDURE AR_MFAR_VALIDATE_TRX_HEADER(
                   X_TRANSACTION_TYPE_ID	           Number,
			       X_TRANSACTION_CLASS		           varchar2,
			       X_TRX_COMMITMENT_NUMBER		       varchar2,
			       X_TRANSACTION_RULES_FLAG		       varchar2,
			       X_INVOICE_RULE_ID	               Number,
                   X_RECEIPT_METHOD_ID                 Number,
			       X_SET_OF_BOOKS_ID		           Number,
                   X_BASE_CURRENCY_CODE                varchar2
				) IS


l_trx_type_validate 	varchar2(1);
l_base_currency		varchar2(15);
l_accounting_method     varchar2(30);
-- error handling variables
l_error_api_name                varchar2(2000);
l_return_status                 varchar2(1);
l_msg_count                     number;
l_msg_data                      varchar2(2000);
l_msg_index_out                 number;
-- l_api_name                      varchar2(30)    := 'PSP_PAYTRN';
l_subline_message               varchar2(200);
l_payment_method	        varchar2(30);
l_trx_type_check            varchar2(1) ;
-- ========================= FND LOG ===========================
l_full_path VARCHAR2(100) := g_path || 'AR_MFAR_VALIDATE_TRX_HEADER';
-- ========================= FND LOG ===========================
BEGIN
FND_MSG_PUB.Initialize;

if (arp_global.sysparam.accounting_method <> 'ACCRUAL' ) then
return;
end if;

SELECT 'X' into l_trx_type_check
from psa_trx_types_ALL a, ra_cust_trx_types_all b
where a.psa_trx_type_id = X_TRANSACTION_TYPE_ID
AND   a.psa_trx_type_id = b.cust_trx_type_id ;

-- EXCEPTION
 --   WHEN NO_DATA_FOUND THEN

  --  FND_MESSAGE.set_name('AR','AR_NO_TRX_TYPE_IN_RA_INTERFACE_LINES');
 --   APP_EXCEPTION.raise_exception;
 --   RAISE;
 --  END;

if l_trx_type_check is not null  then

 /* ------------------------------------------------------------------------------+
 |    If the transaction Class  is of  Gurantee,Credit Memo or Charge Back        |
 |    then stop the Validation  and Raise error Else continue further validation  |
 +--------------------------------------------------------------------------------*/

       if
       X_TRANSACTION_CLASS = 'GUAR' then
       FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CLASS_GUAR');
       -- ========================= FND LOG ===========================
       psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
       -- ========================= FND LOG ===========================
       APP_EXCEPTION.RAISE_EXCEPTION;
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;

       elsif
       X_TRANSACTION_CLASS = 'CM' then
       FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CLASS_CM');
       -- ========================= FND LOG ===========================
       psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
       -- ========================= FND LOG ===========================
       APP_EXCEPTION.RAISE_EXCEPTION;
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;

       elsif
       X_TRANSACTION_CLASS = 'CB' then
       FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CLASS_CB');
       -- ========================= FND LOG ===========================
       psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
       -- ========================= FND LOG ===========================
       APP_EXCEPTION.RAISE_EXCEPTION;
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;
       end if;

/* ------------------------------------------------------------------------+
 |    If the Transaction Currency is not the same as the GL Functional     |
 |    Currency exit validation with an error . Otherwise this transaction  |
 |    will be qualified as MFAR transaction                                                          |
 +-------------------------------------------------------------------------*/

    select  sob.currency_code
   into l_base_currency
   from GL_SETS_OF_BOOKS sob,AR_SYSTEM_PARAMETERS_ALL sp
   where sob.set_of_books_id = X_SET_OF_BOOKS_ID
   and sob.set_of_books_id = sp.set_of_books_id
   and  rownum < 2 ;

   if (l_base_currency <> X_BASE_CURRENCY_CODE)  then
     FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CURRENCY_CODE');
     -- ========================= FND LOG ===========================
     psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
     -- ========================= FND LOG ===========================
     APP_EXCEPTION.RAISE_EXCEPTION;
     fnd_msg_pub.add;
     RAISE FND_API.G_EXC_ERROR;
     end if;


/* ------------------------------------------------------------------------+
 |    If the Payment Method  is of Automatic  then exit  validation        |
 |    with an error . Otherwise this transaction will be qualified as MFAR |
 |    transaction                                                          |
 +-------------------------------------------------------------------------*/
/*
if (X_RECEIPT_METHOD_ID is not null ) then
     select a.creation_method_code into l_payment_method
     from AR_RECEIPT_CLASSES a,AR_RECEIPT_METHODS b
     where a.RECEIPT_CLASS_ID = b.RECEIPT_CLASS_ID
     and  b.receipt_method_id = X_RECEIPT_METHOD_ID;

    if (l_payment_method = 'AUTOMATIC') then
          FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_PAYMENT_METHOD');
           APP_EXCEPTION.RAISE_EXCEPTION;
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
          end if;
end if;
*/
/* ------------------------------------------------------------------------+
 |    If Invoice has Rules  applied then exit the validation                |
 |     Else continue further validation                                     |
 +-------------------------------------------------------------------------*/


       if (X_INVOICE_RULE_ID is not null) then
        FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_TRX_RULES');
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
        -- ========================= FND LOG ===========================
        APP_EXCEPTION.RAISE_EXCEPTION;
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
        end if;

/* ------------------------------------------------------------------------+
 |    If Invoice has commitments  then exit the validation                  |
 |     Else continue further validation                                     |
 +-------------------------------------------------------------------------*/

       if X_TRX_COMMITMENT_NUMBER is not null then
        FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_COMMITMENT_NO');
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
        -- ========================= FND LOG ===========================
        APP_EXCEPTION.RAISE_EXCEPTION;
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
        end if;

  return;
  end if;

  EXCEPTION
  WHEN NO_DATA_FOUND or TOO_MANY_ROWS then
  return;
  WHEN OTHERS then
       -- ========================= FND LOG ===========================
       psa_utils.debug_unexpected_msg(l_full_path);
       -- ========================= FND LOG ===========================
  RAISE;
end AR_MFAR_VALIDATE_TRX_HEADER;

/* Procedure to validate a Credit Memo */

PROCEDURE AR_MFAR_CM_VAL_CHECK(X_TRX_ID                     number,
                               X_SET_OF_BOOKS_ID                Number,
                          X_BASE_CURRENCY_CODE                  varchar2
                                ) IS

l_trx_number_validate           varchar2(1);
-- error handling variables
l_error_api_name                varchar2(2000);
l_return_status                 varchar2(1);
l_msg_count                     number;
l_msg_data                      varchar2(2000);
l_msg_index_out                 number;
-- l_api_name                      varchar2(30)    := 'PSP_PAYTRN';
l_subline_message               varchar2(200);
l_profile_val                   varchar2(240);
l_base_currency                 varchar2(15);
l_accounting_method             varchar2(30);
l_trx_type_check                varchar2(1);
-- ========================= FND LOG ===========================
l_full_path VARCHAR2(100) := g_path || 'AR_MFAR_CM_VAL_CHECK';
-- ========================= FND LOG ===========================

BEGIN

FND_MSG_PUB.Initialize;

if (arp_global.sysparam.accounting_method <> 'ACCRUAL' )
then
return;
end if;

SELECT 'X' into l_trx_type_check
from psa_trx_types_ALL a, ra_customer_trx_all b
where a.psa_trx_type_id = b.cust_trx_type_id
and b.customer_trx_id = X_TRX_ID ;

if l_trx_type_check is not null  then

-- open validate_trx_number_csr;
-- fetch validate_trx_number_csr into l_trx_number_validate ;
 -- if validate_trx_number_csr%NOTFOUND then
 --    FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_RECORD');
 --    fnd_msg_pub.add;
 --    close validate_trx_number_csr;
 --    return;

       select sob.currency_code
       into l_base_currency
       from GL_SETS_OF_BOOKS sob,AR_SYSTEM_PARAMETERS_ALL sp
       where sob.set_of_books_id = X_SET_OF_BOOKS_ID
       and sob.set_of_books_id = sp.set_of_books_id
       and rownum < 2 ;

       if (l_base_currency <> X_BASE_CURRENCY_CODE)  then
       FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CURRENCY_CODE');
       -- ========================= FND LOG ===========================
       psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
       -- ========================= FND LOG ===========================
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;
       end if;

       l_profile_val := fnd_profile.value('AR_USE_INV_ACCT_FOR_CM_FLAG');
     --  dbms_output.put_line(l_value);

/* Bug Fix 1534215
-- modified by SIS
      if (l_profile_val <> 'Y' ) then
      FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_PROFILE_VAL');
      fnd_msg_pub.add;
      RAISE FND_API.G_UNEXPECTED_EXC_ERROR
      end if;
*/

      if (l_profile_val <> 'Y' ) then
      FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_PROFILE_VAL');
      -- ========================= FND LOG ===========================
      psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
      -- ========================= FND LOG ===========================
      APP_EXCEPTION.RAISE_EXCEPTION;
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
      end if;
--   else
   return;
  end if;

  EXCEPTION
  WHEN NO_DATA_FOUND or TOO_MANY_ROWS then
  return;
  WHEN OTHERS then
       -- ========================= FND LOG ===========================
       psa_utils.debug_unexpected_msg(l_full_path);
       -- ========================= FND LOG ===========================
  RAISE;
end AR_MFAR_CM_VAL_CHECK;

/* Procedure to validate a Transaction ,Receipt or an Adjustment */

FUNCTION AR_MFAR_VALIDATE_CHECK(
X_SOURCE_ID             in      Number,
X_SOURCE_TYPE           in      varchar2,
X_SET_OF_BOOKS_ID       in      Number)
RETURN varchar2  IS

l_trx_type		varchar2(1);
l_accounting_method     varchar2(30);
l_return_status          varchar2(1);
l_validate_trx           varchar2(1);
l_validate_adj           varchar2(1);
l_app_cust_trx_id        number;
-- ========================= FND LOG ===========================
l_full_path VARCHAR2(100) := g_path || 'AR_MFAR_VALIDATE_CHECK';
-- ========================= FND LOG ===========================
Begin

l_return_status := 'N' ;
FND_MSG_PUB.Initialize;

-- Commented for enabling cash basis accounting
--
-- if (arp_global.sysparam.accounting_method <> 'ACCRUAL' )
-- then
-- return(l_return_status);
-- end if;

 if X_SOURCE_TYPE = 'TRX' then

    SELECT 'X' into l_validate_trx
    from psa_trx_types_ALL a, ra_customer_trx_all b
    where a.psa_trx_type_id = b.cust_trx_type_id
    and customer_trx_id = X_SOURCE_ID  ;

        if l_validate_trx is not null then
        l_return_status := 'Y' ;
        return(l_return_status);

        else
        return(l_return_status);
        end if;

elsif X_SOURCE_TYPE = 'ADJ' then

    SELECT 'X' into l_validate_adj
    from psa_trx_types_ALL a, ra_customer_trx_all b,
    ar_adjustments_all c
    where  b.customer_trx_id = c.customer_trx_id
    and a.psa_trx_type_id = b.cust_trx_type_id
    and c.adjustment_id  = X_SOURCE_ID  ;

        if l_validate_adj is not null then
        l_return_status := 'Y' ;
        return(l_return_status);

        else
        return(l_return_status);
        end if;

elsif X_SOURCE_TYPE = 'RCT' then
    select applied_customer_trx_id
    into l_app_cust_trx_id
    from ar_receivable_applications_all
    where receivable_application_id = X_SOURCE_ID;

    return  AR_MFAR_VALIDATE_CHECK( l_app_cust_trx_id,'TRX', X_SET_OF_BOOKS_ID  );

end if;

 EXCEPTION
  WHEN NO_DATA_FOUND or TOO_MANY_ROWS then
  l_return_status := 'N';
  return(l_return_status);
  WHEN OTHERS then
  -- ========================= FND LOG ===========================
  psa_utils.debug_unexpected_msg(l_full_path);
  -- ========================= FND LOG ===========================
  RAISE;

end AR_MFAR_VALIDATE_CHECK;

/* Bug 2435404 : Transaction number is being passed as a paremeter for this routine.
   This will fail with 'too_many_rows_ exception is there is more than one transaction with same number.
   PSA.pll will be modified to route ra_customer_trx_id instead of Transaction number */

/* Function to check for the validation of Receipt Header */
FUNCTION AR_MFAR_RECEIPT_CHECK(
X_RECEIPT_ID             in      Number,
X_RECEIPT_METHOD_ID	in       varchar2,
X_TRANSACTION_ID           in      number)
RETURN   varchar2 IS

l_return_status         varchar2(1);
l_trx_type	        varchar2(1);
l_confirm_flag          varchar2(1);
l_remit_flag            varchar2(1);
l_rct_check             varchar2(1);
l_inv_currency_code     varchar2(15);
l_rct_currency_code     varchar2(15);
l_org_id		number(15);
-- ========================= FND LOG ===========================
l_full_path VARCHAR2(100) := g_path || 'AR_MFAR_RECEIPT_CHECK';
-- ========================= FND LOG ===========================
begin

l_return_status := 'N';

FND_MSG_PUB.Initialize;
-- Get the org_id  -- Bug 2374853

fnd_profile.get('ORG_ID',l_org_id);

SELECT 'X' into l_rct_check
from psa_trx_types_ALL a, ra_customer_trx_ALL b
-- ar_cash_receipts_ALL c,ar_receivable_applications_ALL d
-- where b.customer_trx_id = d.applied_customer_trx_id
-- and c.cash_receipt_id = d.cash_receipt_id
-- and
where  a.psa_trx_type_id = b.cust_trx_type_id
and b.customer_trx_id = X_TRANSACTION_ID ;

if l_rct_check is not null then

-- Commented for enabling cash basis accounting
--
--  if (arp_global.sysparam.accounting_method <> 'ACCRUAL' )
--  then
--  FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_ACCOUNTING_METHOD');
--  fnd_msg_pub.add;
--  APP_EXCEPTION.RAISE_EXCEPTION;
--  RAISE FND_API.G_EXC_ERROR;
--    end if;

-- Modified this sql to include org_id
-- Bug 2374853

    Select Invoice_currency_code into l_inv_currency_code
    from ra_customer_trx_all
    where customer_trx_id = X_TRANSACTION_ID and
          org_id = l_org_id;


    select currency_code into l_rct_currency_code
    from ar_cash_receipts_all
    where cash_receipt_id = X_RECEIPT_ID ;

    if (l_inv_currency_code <> l_rct_currency_code ) then
    FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CURRENCY_CODE');
    -- ========================= FND LOG ===========================
    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
    -- ========================= FND LOG ===========================
    -- FND_MESSAGE.SHOW ;
    APP_EXCEPTION.RAISE_EXCEPTION;
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
    end if;

        select a.REMIT_FLAG,a.confirm_flag into
        l_remit_flag,l_confirm_flag
        from AR_RECEIPT_CLASSES a,AR_RECEIPT_METHODS b
        where a.RECEIPT_CLASS_ID = b.RECEIPT_CLASS_ID
        and  b.receipt_method_id = X_RECEIPT_METHOD_ID ;

        if    (l_remit_flag = 'Y') then
               FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_REMIT_CODE');
               -- ========================= FND LOG ===========================
               psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
               -- ========================= FND LOG ===========================
               APP_EXCEPTION.RAISE_EXCEPTION;
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
        elsif  l_remit_flag = 'N'  then
                 if l_confirm_flag = 'Y' then
                    FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CONFIRM_CODE');
                    -- ========================= FND LOG ===========================
                    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
                    -- ========================= FND LOG ===========================
                    APP_EXCEPTION.RAISE_EXCEPTION;
                    fnd_msg_pub.add;
                    RAISE FND_API.G_EXC_ERROR;
                 elsif  l_confirm_flag = 'N'  then
                    l_return_status := 'Y' ;
                    return(l_return_status);
                 end if;

        end if;
   else
   l_return_status := 'Y' ;
   return(l_return_status);
  end if;

  EXCEPTION
  WHEN NO_DATA_FOUND or TOO_MANY_ROWS then
  l_return_status := 'N';
  return(l_return_status);
  WHEN OTHERS then
       -- ========================= FND LOG ===========================
       psa_utils.debug_unexpected_msg(l_full_path);
       -- ========================= FND LOG ===========================
  RAISE;

end AR_MFAR_RECEIPT_CHECK ;

/* Procedure to check for the validation of Quick Cash */
PROCEDURE ar_mfar_quickcash (x_receipt_method_id number) is
l_confirm_flag          varchar2(1);
l_remit_flag            varchar2(1);
-- ========================= FND LOG ===========================
l_full_path VARCHAR2(100) := g_path || 'ar_mfar_quickcash';
-- ========================= FND LOG ===========================
begin
 FND_MSG_PUB.Initialize;
        SELECT
	 a.REMIT_FLAG,
	 a.confirm_flag
        INTO
         l_remit_flag,
	 l_confirm_flag
        FROM
         AR_RECEIPT_CLASSES a,
	 AR_RECEIPT_METHODS b
        WHERE
	 a.RECEIPT_CLASS_ID = b.RECEIPT_CLASS_ID AND
         b.receipt_method_id = X_RECEIPT_METHOD_ID ;

        if    (l_remit_flag = 'Y') then
               FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_REMIT_CODE');
               -- ========================= FND LOG ===========================
               psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
               -- ========================= FND LOG ===========================
               APP_EXCEPTION.RAISE_EXCEPTION;
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
        elsif  l_remit_flag = 'N'  then
                 if l_confirm_flag = 'Y' then
                    FND_MESSAGE.SET_NAME('PSA','PSA_INVALID_CONFIRM_CODE');
                    -- ========================= FND LOG ===========================
                    psa_utils.debug_other_msg(g_error_level,l_full_path,FALSE);
                    -- ========================= FND LOG ===========================
                    APP_EXCEPTION.RAISE_EXCEPTION;
                    fnd_msg_pub.add;
                    RAISE FND_API.G_EXC_ERROR;
                 elsif  l_confirm_flag = 'N'  then
               null;  --   l_return_status := 'Y' ;
--                    return(l_return_status);
                 end if;
        end if;
EXCEPTION
 when OTHERS then
      -- ========================= FND LOG ===========================
      psa_utils.debug_unexpected_msg(l_full_path);
      -- ========================= FND LOG ===========================
      RAISE;

END ar_mfar_quickcash;

/* Procedure to validate the Lockbox Functionality in Multifund */

FUNCTION AR_LOCKBOX_VALIDATION
RETURN varchar2  IS
l_return_status     varchar2(1) ;
l_currency_check    varchar2(1) ;
l_base_currency     varchar2(15);
l_payment_method_check  varchar2(1) ;
-- it_id                   item ;
l_set_of_books_id	gl_sets_of_books.set_of_books_id%type;
-- ========================= FND LOG ===========================
l_full_path VARCHAR2(100) := g_path || 'AR_LOCKBOX_VALIDATION';
-- ========================= FND LOG ===========================

begin
l_return_status := 'N' ;
  -- FND_PROFILE.GET('GL_SET_OF_BKS_ID', l_set_of_books_id);

  -- Bug 1632998

   l_set_of_books_id := PSA_MFAR_UTILS.get_ar_sob_id ;
--   it_id := FIND_ITEM('LBSUB.PB_SUBMIT') ;
 begin
  select  sob.currency_code
   into l_base_currency
   from GL_SETS_OF_BOOKS sob,AR_SYSTEM_PARAMETERS_ALL sp
   where sob.set_of_books_id = l_set_of_books_id
   and sob.set_of_books_id = sp.set_of_books_id
   and  rownum < 2 ;

   Select 'X'
   into l_currency_check
   from AR_INTERIM_CASH_RECEIPTS_ALL a
   WHERE a.currency_code <> l_base_currency
   and rownum < 2 ;

   IF l_currency_check is not null THEN
   l_return_status := 'Y' ;
   return(l_return_status);
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND or TOO_MANY_ROWS then
 -- return(l_return_status);
 null;
  WHEN OTHERS then
       -- ========================= FND LOG ===========================
       psa_utils.debug_unexpected_msg(l_full_path);
       -- ========================= FND LOG ===========================
       RAISE;
  END ;

  BEGIN
     select 'X'
     into l_payment_method_check
     from AR_RECEIPT_CLASSES a,AR_RECEIPT_METHODS b,
     AR_INTERIM_CASH_RECEIPTS_ALL c
     where a.RECEIPT_CLASS_ID = b.RECEIPT_CLASS_ID
     and  b.receipt_method_id = c.RECEIPT_METHOD_ID
     and  a.remit_flag = 'Y'
     and rownum < 2 ;

    if  l_payment_method_check is not null then
        l_return_status := 'X' ;
        return(l_return_status);
    end if;
  EXCEPTION
  WHEN NO_DATA_FOUND or TOO_MANY_ROWS then
  return(l_return_status);
  WHEN OTHERS then
       -- ========================= FND LOG ===========================
       psa_utils.debug_unexpected_msg(l_full_path);
       -- ========================= FND LOG ===========================
       RAISE;
return(l_return_status);
END ;
end AR_LOCKBOX_VALIDATION ;

/* Procedure to check the Auto Invoice Validation */

PROCEDURE ar_mfar_autoinv_trx_header(l_request_id  IN NUMBER) is

begin
/* ------------------------------------------------------------------------+
 |   If l_request_id is not null then check for the following              |
 |   check for the transaction type of the Interface_line                  |
 |   If the transaction type is of non MFAR or null exit the program       |
 |   If the transaction type is of MFAR then continue further validation   |
 +-------------------------------------------------------------------------*/


/* ------------------------------------------------------------------------+
 |    If the transaction type is of MFAR then continue further validation  |
 +-------------------------------------------------------------------------*/

/* ------------------------------------------------------------------------+
 |    If the accounting method is of CASH  then exit validation            |
 |    If the accounting method is not the CASH then continue               |
 +-------------------------------------------------------------------------*/

 /* ------------------------------------------------------------------------------+
 |    If the transaction Class  is of  Gurantee,Credit Memo or Charge Back        |
 |    then Insert the error into Errors Table. Else continue further validation   |
 +--------------------------------------------------------------------------------*/
 if (arp_global.sysparam.accounting_method <> 'ACCRUAL' )
  then
  return;
 end if;

 -- Added Hint to improve performance   Bug # 2503680

	INSERT INTO RA_INTERFACE_ERRORS
        (INTERFACE_LINE_ID,
         MESSAGE_TEXT)
    SELECT  /*+ ORDERED */  nvl(L.INTERFACE_LINE_ID,0 ) ,
		DECODE(B.TYPE ,'GUAR','Commitments Can not be Multi Fund Transactions Type',
                        'CB' ,'Multi Fund TRansactions Can not be Charged Back' ,
                        'CM' , 'On-Account Credit Can not use Multi Fund Transaction types')
	FROM   ra_interface_lines_gt L,
           ra_cust_trx_types_all B,
           psa_trx_types_all C
	  WHERE  L.REQUEST_ID = l_request_id
	  AND  L.cust_trx_type_id = B.cust_trx_type_id
	  AND    B.TYPE in ('GUAR', 'CB', 'CM')
	  AND   B.cust_trx_type_id = C.psa_trx_type_id;



 /* ------------------------------------------------------------------------+
 |    If Invoice has Rules  applied then exit the validation                |
 |     Else continue further validation                                     |
 +-------------------------------------------------------------------------*/

  INSERT INTO RA_INTERFACE_ERRORS
           (INTERFACE_LINE_ID,
            MESSAGE_TEXT)
          SELECT L.INTERFACE_LINE_ID,
		  'Can not Assign Rules to Multi Fund Transactions'
	    	FROM RA_INTERFACE_LINES_GT L
	       WHERE L.REQUEST_ID = l_request_id
	       AND  ( L.INVOICING_RULE_ID IS NOT NULL
           OR   L.INVOICING_RULE_NAME IS NOT NULL )
           AND   exists
          (SELECT  'X' FROM RA_CUST_TRX_TYPES_ALL B,
           PSA_TRX_TYPES_ALL C
           WHERE B.CUST_TRX_TYPE_ID = C.PSA_TRX_TYPE_ID
           AND   B.CUST_TRX_TYPE_ID = L.CUST_TRX_TYPE_ID ) ;

/* ------------------------------------------------------------------------+
 |    If the Transaction Currency is not the same as the GL Functional     |
 |    Currency exit validation with an error . Otherwise this transaction  |
 |    will be qualified as MFAR transaction                                |
 +-------------------------------------------------------------------------*/

    INSERT INTO RA_INTERFACE_ERRORS
           (INTERFACE_LINE_ID,
            MESSAGE_TEXT)
          SELECT nvl(L.INTERFACE_LINE_ID,0) ,
          'Transaction Currency Should be Equal to the GL Functional Currency'
          FROM RA_INTERFACE_LINES_GT L
          WHERE L.REQUEST_ID = l_request_id
	      AND  exists
            (SELECT  'X' FROM RA_CUST_TRX_TYPES_ALL B,
             PSA_TRX_TYPES_ALL C
             WHERE B.CUST_TRX_TYPE_ID = C.PSA_TRX_TYPE_ID
             AND   B.CUST_TRX_TYPE_ID = L.CUST_TRX_TYPE_ID )
          AND  not exists
            (select 'X'
             from GL_SETS_OF_BOOKS sob,AR_SYSTEM_PARAMETERS_ALL sp
             where sob.set_of_books_id = L.SET_OF_BOOKS_ID
             and sob.set_of_books_id = sp.set_of_books_id
             and sob.currency_code = L.currency_code
             and  rownum < 2 );


/* ------------------------------------------------------------------------+
 |    If the Payment Method  is of Automatic  then exit  validation        |
 |    with an error . Otherwise this transaction will be qualified as MFAR |
 |    transaction                                                          |
 +-------------------------------------------------------------------------*/
/*
      INSERT INTO RA_INTERFACE_ERRORS
           (INTERFACE_LINE_ID,
            MESSAGE_TEXT )
      SELECT nvl(L.INTERFACE_LINE_ID,0) ,
		'Can not Mark Multi Fund Transactions for Automatic Receipts '
	  FROM RA_INTERFACE_LINES_GT L
	  WHERE L.REQUEST_ID = l_request_id
	  AND   exists
            (SELECT  'X' FROM RA_CUST_TRX_TYPES_ALL B,
             PSA_TRX_TYPES_ALL C
             WHERE B.CUST_TRX_TYPE_ID = C.PSA_TRX_TYPE_ID
             AND   B.CUST_TRX_TYPE_ID = L.CUST_TRX_TYPE_ID )
      AND   exists
	 	         (SELECT  'X'
		          FROM
		          AR_RECEIPT_CLASSES A,
		          AR_RECEIPT_METHODS B
		          WHERE
		          A.RECEIPT_CLASS_ID = B.RECEIPT_CLASS_ID
                  AND (B.RECEIPT_METHOD_ID = L.RECEIPT_METHOD_ID
                    OR B.NAME = L.RECEIPT_METHOD_NAME)
         	      AND  A.CREATION_METHOD_CODE = 'AUTOMATIC' ) ;
*/
/* ------------------------------------------------------------------------+
 |    If the Invoice is having commitments then exit  validation           |
 |    with an error . Otherwise this transaction will be qualified as MFAR |
 |    transaction                                                          |
 +-------------------------------------------------------------------------*/

   INSERT INTO RA_INTERFACE_ERRORS
           (INTERFACE_LINE_ID,
            MESSAGE_TEXT)
          SELECT nvl(L.INTERFACE_LINE_ID,0) ,
		  'Can not Assign Commitments to Multi Fund Transactions'
	      FROM RA_INTERFACE_LINES_GT L
	 WHERE  L.REQUEST_ID = l_request_id
         AND   exists
          (SELECT  'X' FROM RA_CUST_TRX_TYPES_ALL B,
           PSA_TRX_TYPES_ALL C
           WHERE B.CUST_TRX_TYPE_ID = C.PSA_TRX_TYPE_ID
           AND    B.TYPE = 'INV'
           AND    L.REFERENCE_LINE_ID is not null
           AND   B.CUST_TRX_TYPE_ID = L.CUST_TRX_TYPE_ID ) ;

/* ------------------------------------------------------------------------+
 |    If the Profile Option Use Invoice Accounting for Credit Memos is not |
 |    set to yes then  exit  validation with an error .                    |
 |     Otherwise this transaction will be qualified as MFAR                |
 |    transaction                                                          |
 +-------------------------------------------------------------------------*/

   -- Bug 2571462 : Added Join between ra_cust_trx_types_all and psa_trx_types_all
   -- This will supersede bug 2503680

     INSERT INTO RA_INTERFACE_ERRORS
           (INTERFACE_LINE_ID,
            MESSAGE_TEXT)
          SELECT nvl(L.INTERFACE_LINE_ID,0) ,
		  'Credit Memo Profile Option must use Invoice Accounting for Multi Fund Transactions'
	      FROM RA_INTERFACE_LINES_GT L
 	 WHERE  L.REQUEST_ID = l_request_id
           AND    exists
          (SELECT  'X' FROM RA_CUST_TRX_TYPES_ALL B,
           PSA_TRX_TYPES_ALL C
           WHERE fnd_profile.value('AR_USE_INV_ACCT_FOR_CM_FLAG') <> 'Y'
           AND    B.TYPE = 'CM'
           AND    L.REFERENCE_LINE_ID is not null
           AND   B.CUST_TRX_TYPE_ID = L.CUST_TRX_TYPE_ID
	   AND   b.cust_trx_type_id = c.psa_trx_type_id);

end  ar_mfar_autoinv_trx_header ;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    ar_mfar_flag                                                           |
 |    RETURN VARCHAR2                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This Fuction returs YES for MFAR and NO otherwise                      |
+===========================================================================*/

FUNCTION ar_mfar_flag
    RETURN VARCHAR2 is
BEGIN
RETURN 'YES';
END ar_mfar_flag;


/*===============================================================
  Function to validate a Miscellaneous Receipt.
  A Miscellaneous Receipt is of Type Multi-fund if
        --> The Receivable Activity is flagged as Multi-Fund type from Setup form

  For a Multi-Fund type Misc Receipt, the Payment Method should
  not require Confirmation / Remittance. If these validations are
  not met, ERROR is raised during WHEN-VALIDATE-RECORD of Misc. receipts header.
  ==================================================================*/

    FUNCTION MISC_RCT_VAL
    (       p_cash_receipt_id       IN      NUMBER,
	    p_receipt_method_id     IN      NUMBER,
	    p_receivables_trx_id    IN      NUMBER
	    ) RETURN VARCHAR2 is


		  CURSOR c_conf_remit IS
		     SELECT
		       confirm_flag,
		       remit_flag
		       FROM
		       ar_receipt_classes rc,
		       ar_receipt_methods rm
		       WHERE
		       rc.receipt_class_id = rm.receipt_class_id AND
		       rm.receipt_method_id = p_receipt_method_id;


		  CURSOR c_rec_activity IS
		     SELECT
		       'Y'
		       FROM
		       psa_receivables_trx_all psart,
		       ar_receivables_trx_all rt
		       WHERE
		       psart.psa_receivables_trx_id = p_receivables_trx_id
		       AND
		       psart.psa_receivables_trx_id = rt.receivables_trx_id;

		  l_conf_flag   ar_receipt_classes.confirm_flag%TYPE;
		  l_remit_flag ar_receipt_classes.remit_flag%TYPE;
		  l_mf_type VARCHAR2(1) := NULL;
		  l_return_flag VARCHAR2(1);
		  mf_rct_invalid EXCEPTION;
                  -- ========================= FND LOG ===========================
                  l_full_path VARCHAR2(100) := g_path || 'MISC_RCT_VAL';
                  -- ========================= FND LOG ===========================

    BEGIN

       FND_MSG_PUB.Initialize;


       IF NOT c_rec_activity%isopen THEN
	  OPEN  c_rec_activity;
	  FETCH c_rec_activity INTO l_mf_type;
	  CLOSE c_rec_activity;
       END IF;

       IF l_mf_type IS NOT NULL THEN

	       l_return_flag := 'Y';

	ELSE
	  l_return_flag := 'N';

       END IF;

       RETURN l_return_flag;

    EXCEPTION

       WHEN mf_rct_invalid THEN
	  RETURN l_return_flag;

	FND_MESSAGE.SET_NAME('PSA','PSA_MF_MISC_INVALID');
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_msg(g_excep_level,l_full_path,FALSE);
        -- ========================= FND LOG ===========================
        APP_EXCEPTION.RAISE_EXCEPTION;
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;

       WHEN OTHERS THEN
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path, 'Other exception');
          psa_utils.debug_other_string(g_excep_level,l_full_path, SQLCODE || SQLERRM);
	  psa_utils.debug_unexpected_msg(l_full_path);
          -- ========================= FND LOG ===========================
	  RAISE;


    END;


end PSA_MFAR_VAL_PKG;

/
