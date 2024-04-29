--------------------------------------------------------
--  DDL for Package Body JAI_RCV_RRSL_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_RRSL_TRIGGER_PKG" AS
/* $Header: jai_rcv_rrsl_t.plb 120.0 2005/09/01 12:37:22 rallamse noship $ */

/*  REM +======================================================================+
  REM NAME          ARIU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_RCV_RRSL_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_RCV_RRSL_ARIU_T1
  REM
  REM +======================================================================+
  */
  PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  BEGIN
    pv_return_code := jai_constants.successful ;
--added the below by Sanjikum for Bug#4035297

--IF jai_cmn_utils_pkg.check_jai_exists(p_calling_object => 'JA_IN_SUB_LEDGER_TRG',
--                               p_set_of_books_id => pr_new.set_of_books_id) = FALSE THEN
--  RETURN;
-- END IF;



/*------------------------------------------------------------------------------------------
 FILENAME: ja_in_sub_ledger_trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1         29-Nov-2004   Sanjikum for 4035297. Version 115.1
                        Commented the WHEN condition and added the call to jai_cmn_utils_pkg.check_jai_exists

                  Dependency Due to this Bug:-
                  The current trigger becomes dependent on the function jai_cmn_utils_pkg.check_jai_exists version 115.0.

2.       08-Jun-2005   This Object is Modified to refer to New DB Entry names in place of Old
                       DB as required for CASE COMPLAINCE. Version  116.1

3 . 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
Of File                           On Bug/Patchset    Dependent On

ja_in_sub_ledger_trg.sql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.1              4035297        IN60105D2+4033992  ja_in_util_pkg_s.sql  115.0     Sanjikum 29-Nov-2004  Call to this function.
                                                     ja_in_util_pkg_s.sql  115.0   Sanjikum

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


   IF pv_action = jai_constants.INSERTING THEN   --1
      INSERT INTO JAI_RCV_SUBLED_ENTRIES(SUBLED_ENTRY_ID,LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   RCV_TRANSACTION_ID,
                   CURRENCY_CODE,
                   ACTUAL_FLAG,
                   JE_SOURCE_NAME,
                   JE_CATEGORY_NAME,
                   SET_OF_BOOKS_ID,
                   ACCOUNTING_DATE,
                   CODE_COMBINATION_ID,
                   ACCOUNTED_DR,
                   ACCOUNTED_CR,
                   ENCUMBRANCE_TYPE_ID,
                   ENTERED_DR,
                   ENTERED_CR,
                   BUDGET_VERSION_ID,
                   CURRENCY_CONVERSION_DATE,
                   USER_CURRENCY_CONVERSION_TYPE,
                   CURRENCY_CONVERSION_RATE,
                   TRANSACTION_DATE,
                   PERIOD_NAME,
                   CHART_OF_ACCOUNTS_ID,
                   FUNCTIONAL_CURRENCY_CODE,
                   DATE_CREATED_IN_GL,
                   JE_BATCH_NAME,
                   JE_BATCH_DESCRIPTION,
                   JE_HEADER_NAME,
                   JE_LINE_DESCRIPTION,
                   REVERSE_JOURNAL_FLAG,
                   REVERSAL_PERIOD_NAME,
                   ATTRIBUTE_CATEGORY,
                   ATTRIBUTE1,
                   ATTRIBUTE2,
                   ATTRIBUTE3,
                   ATTRIBUTE4,
                   ATTRIBUTE5,
                   ATTRIBUTE6,
                   ATTRIBUTE7,
                   ATTRIBUTE8,
                   ATTRIBUTE9,
                   ATTRIBUTE10,
                   ATTRIBUTE11,
                   ATTRIBUTE12,
                   ATTRIBUTE13,
                   ATTRIBUTE14,
                   ATTRIBUTE15,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   --SUBLEDGER_DOC_SEQUENCE_ID,
                   --SUBLEDGER_DOC_SEQUENCE_VALUE,
                   USSGL_TRANSACTION_CODE,
                   REFERENCE1,
                   REFERENCE2,
                   REFERENCE3,
                   REFERENCE4,
                   REFERENCE5,
                   REFERENCE6,
                   REFERENCE7,
                   REFERENCE8,
                   REFERENCE9,
                   REFERENCE10,
                   SOURCE_DOC_QUANTITY,
                   FROM_TYPE
       )
      VALUES( JAI_RCV_SUBLED_ENTRIES_S.nextval,
                   pr_new.LAST_UPDATE_DATE,
                   pr_new.LAST_UPDATED_BY,
                   pr_new.CREATION_DATE,
                   pr_new.CREATED_BY,
                   pr_new.LAST_UPDATE_LOGIN,
                   pr_new.RCV_TRANSACTION_ID,
                   pr_new.CURRENCY_CODE,
                   pr_new.ACTUAL_FLAG,
                   pr_new.JE_SOURCE_NAME,
                   pr_new.JE_CATEGORY_NAME,
                   pr_new.SET_OF_BOOKS_ID,
                   pr_new.ACCOUNTING_DATE,
                   pr_new.CODE_COMBINATION_ID,
                   pr_new.ACCOUNTED_DR,
                   pr_new.ACCOUNTED_CR,
                   pr_new.ENCUMBRANCE_TYPE_ID,
                   pr_new.ENTERED_DR,
                   pr_new.ENTERED_CR,
                   pr_new.BUDGET_VERSION_ID,
                   pr_new.CURRENCY_CONVERSION_DATE,
                   pr_new.USER_CURRENCY_CONVERSION_TYPE,
                   pr_new.CURRENCY_CONVERSION_RATE,
                   pr_new.TRANSACTION_DATE,
                   pr_new.PERIOD_NAME,
                   pr_new.CHART_OF_ACCOUNTS_ID,
                   pr_new.FUNCTIONAL_CURRENCY_CODE,
                   pr_new.DATE_CREATED_IN_GL,
                   pr_new.JE_BATCH_NAME,
                   pr_new.JE_BATCH_DESCRIPTION,
                   pr_new.JE_HEADER_NAME,
                   pr_new.JE_LINE_DESCRIPTION,
                   pr_new.REVERSE_JOURNAL_FLAG,
                   pr_new.REVERSAL_PERIOD_NAME,
                   pr_new.ATTRIBUTE_CATEGORY,
                   pr_new.ATTRIBUTE1,
                   pr_new.ATTRIBUTE2,
                   pr_new.ATTRIBUTE3,
                   pr_new.ATTRIBUTE4,
                   pr_new.ATTRIBUTE5,
                   pr_new.ATTRIBUTE6,
                   pr_new.ATTRIBUTE7,
                   pr_new.ATTRIBUTE8,
                   pr_new.ATTRIBUTE9,
                   pr_new.ATTRIBUTE10,
                   pr_new.ATTRIBUTE11,
                   pr_new.ATTRIBUTE12,
                   pr_new.ATTRIBUTE13,
                   pr_new.ATTRIBUTE14,
                   pr_new.ATTRIBUTE15,
                   pr_new.REQUEST_ID,
                   pr_new.PROGRAM_APPLICATION_ID,
                   pr_new.PROGRAM_ID,
                   pr_new.PROGRAM_UPDATE_DATE,
                   --pr_new.SUBLEDGER_DOC_SEQUENCE_ID,
                   --pr_new.SUBLEDGER_DOC_SEQUENCE_VALUE,
                   pr_new.USSGL_TRANSACTION_CODE,
                   pr_new.REFERENCE1,
                   pr_new.REFERENCE2,
                   pr_new.REFERENCE3,
                   pr_new.REFERENCE4,
                   pr_new.REFERENCE5,
                   pr_new.REFERENCE6,
                   pr_new.REFERENCE7,
                   pr_new.REFERENCE8,
                   pr_new.REFERENCE9,
                   pr_new.REFERENCE10,
                   pr_new.SOURCE_DOC_QUANTITY,
                   'A'
                   );
   ELSIF pv_action = jai_constants.UPDATING THEN

        UPDATE  JAI_RCV_SUBLED_ENTRIES
        SET     LAST_UPDATE_DATE                = pr_new.LAST_UPDATE_DATE,
    LAST_UPDATED_BY                 = pr_new.LAST_UPDATED_BY,
    CREATION_DATE       = pr_new.CREATION_DATE,
    CREATED_BY      = pr_new.CREATED_BY,
    LAST_UPDATE_LOGIN     = pr_new.LAST_UPDATE_LOGIN,
    RCV_TRANSACTION_ID    = pr_new.RCV_TRANSACTION_ID,
    CURRENCY_CODE       = pr_new.CURRENCY_CODE,
    ACTUAL_FLAG       = pr_new.ACTUAL_FLAG,
    JE_SOURCE_NAME      = pr_new.JE_SOURCE_NAME,
    JE_CATEGORY_NAME    = pr_new.JE_CATEGORY_NAME,
    SET_OF_BOOKS_ID     = pr_new.SET_OF_BOOKS_ID,
    ACCOUNTING_DATE           = pr_new.ACCOUNTING_DATE,
    CODE_COMBINATION_ID     = pr_new.CODE_COMBINATION_ID,
    ACCOUNTED_DR      = pr_new.ACCOUNTED_DR,
    ACCOUNTED_CR      = pr_new.ACCOUNTED_CR,
    ENCUMBRANCE_TYPE_ID   = pr_new.ENCUMBRANCE_TYPE_ID,
    ENTERED_DR      = pr_new.ENTERED_DR,
    ENTERED_CR      = pr_new.ENTERED_CR,
    BUDGET_VERSION_ID   = pr_new.BUDGET_VERSION_ID,
    CURRENCY_CONVERSION_DATE  = pr_new.CURRENCY_CONVERSION_DATE,
    USER_CURRENCY_CONVERSION_TYPE = pr_new.USER_CURRENCY_CONVERSION_TYPE,
    CURRENCY_CONVERSION_RATE  = pr_new.CURRENCY_CONVERSION_RATE,
    TRANSACTION_DATE    = pr_new.TRANSACTION_DATE,
    PERIOD_NAME     = pr_new.PERIOD_NAME,
    CHART_OF_ACCOUNTS_ID    = pr_new.CHART_OF_ACCOUNTS_ID,
    FUNCTIONAL_CURRENCY_CODE  = pr_new.FUNCTIONAL_CURRENCY_CODE,
    DATE_CREATED_IN_GL    = pr_new.DATE_CREATED_IN_GL,
    JE_BATCH_NAME     = pr_new.JE_BATCH_NAME,
    JE_BATCH_DESCRIPTION    = pr_new.JE_BATCH_DESCRIPTION,
    JE_HEADER_NAME      = pr_new.JE_HEADER_NAME,
    JE_LINE_DESCRIPTION   = pr_new.JE_LINE_DESCRIPTION,
    REVERSE_JOURNAL_FLAG    = pr_new.REVERSE_JOURNAL_FLAG,
    REVERSAL_PERIOD_NAME    = pr_new.REVERSAL_PERIOD_NAME,
    ATTRIBUTE_CATEGORY    = pr_new.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1      = pr_new.ATTRIBUTE1,
    ATTRIBUTE2      = pr_new.ATTRIBUTE2,
    ATTRIBUTE3      = pr_new.ATTRIBUTE3,
    ATTRIBUTE4      = pr_new.ATTRIBUTE4,
    ATTRIBUTE5      = pr_new.ATTRIBUTE5,
    ATTRIBUTE6      = pr_new.ATTRIBUTE6,
    ATTRIBUTE7      = pr_new.ATTRIBUTE7,
    ATTRIBUTE8      = pr_new.ATTRIBUTE8,
    ATTRIBUTE9      = pr_new.ATTRIBUTE9,
    ATTRIBUTE10     = pr_new.ATTRIBUTE10,
    ATTRIBUTE11     = pr_new.ATTRIBUTE11,
    ATTRIBUTE12     = pr_new.ATTRIBUTE12,
    ATTRIBUTE13     = pr_new.ATTRIBUTE13,
    ATTRIBUTE14     = pr_new.ATTRIBUTE14,
    ATTRIBUTE15     = pr_new.ATTRIBUTE15,
    REQUEST_ID      = pr_new.REQUEST_ID,
    PROGRAM_APPLICATION_ID    = pr_new.PROGRAM_APPLICATION_ID,
    PROGRAM_ID      = pr_new.PROGRAM_ID,
    PROGRAM_UPDATE_DATE   = pr_new.PROGRAM_UPDATE_DATE,
    --SUBLEDGER_DOC_SEQUENCE_ID = pr_new.SUBLEDGER_DOC_SEQUENCE_ID,
    --SUBLEDGER_DOC_SEQUENCE_VALUE  = pr_new.SUBLEDGER_DOC_SEQUENCE_VALUE,
    USSGL_TRANSACTION_CODE    = pr_new.USSGL_TRANSACTION_CODE,
    REFERENCE1      = pr_new.REFERENCE1,
    REFERENCE2      = pr_new.REFERENCE2,
    REFERENCE3      = pr_new.REFERENCE3,
    REFERENCE4      = pr_new.REFERENCE4,
    REFERENCE5      = pr_new.REFERENCE5,
    REFERENCE6      = pr_new.REFERENCE6,
    REFERENCE7      = pr_new.REFERENCE7,
    REFERENCE8      = pr_new.REFERENCE8,
    REFERENCE9      = pr_new.REFERENCE9,
    REFERENCE10     = pr_new.REFERENCE10,
    SOURCE_DOC_QUANTITY   = pr_new.SOURCE_DOC_QUANTITY
        WHERE   from_type           = 'A'
        AND     rcv_transaction_id        = pr_old.rcv_transaction_id
        AND     ((entered_dr IS NULL AND entered_cr = pr_old.entered_cr) OR
                (entered_cr IS NULL AND entered_dr  = pr_old.entered_dr));


   END IF;             --1
  END ARIU_T1 ;

END JAI_RCV_RRSL_TRIGGER_PKG ;

/
