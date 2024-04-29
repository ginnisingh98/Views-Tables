--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_XFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_XFER" as
/* $Header: PAXITCAB.pls 120.4.12010000.5 2010/01/13 16:33:54 dlella ship $ */

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /*  bug 2958951 */
-- Private procedure

-- ==========================================================================
-- = PRIVATE PROCEDURE Get_Trans_Currency_Info
-- ==========================================================================
PROCEDURE Get_Trans_Currency_Info (l_curr_code IN varchar2, l_mau out NOCOPY number, --File.Sql.39 bug 4440895
                               l_sp out NOCOPY number, l_ep out NOCOPY number) IS --File.Sql.39 bug 4440895
BEGIN

    SELECT FC.Minimum_Accountable_Unit,
           FC.Precision,
           FC.Extended_Precision
      INTO l_mau,
           l_sp,
           l_ep
      FROM FND_CURRENCIES FC
     WHERE FC.Currency_Code = l_curr_code;

END Get_Trans_Currency_Info;

/**
  Cr_Single_RND_Entries will apply the same logic of Receivable on Invoice
  Line to reach the line amount,Write-Off/IC Receivable in accounting
  currency and compute the possible rounding in accounting entries,and
  insert proper distribution entries in RA interface distribution. Then
  perform the update of invoice line with the computed line amount,Write-
  off/Revenue Rounding amt in accounting currency.
**/

PROCEDURE  Cr_Single_RND_Entries ( P_Batch_Src            IN  VARCHAR2,
                                   P_Interface_attr1      IN  VARCHAR2,
                                   P_Interface_attr2      IN  VARCHAR2,
                                   P_Interface_attr3      IN  VARCHAR2,
                                   P_Interface_attr4      IN  VARCHAR2,
                                   P_Interface_attr5      IN  VARCHAR2,
                                   P_Interface_attr6      IN  VARCHAR2,
                                   P_Interface_attr7      IN  VARCHAR2,
                                   P_Interface_attr8      IN  VARCHAR2,
                                   P_Func_currency_code   IN  VARCHAR2,
                                   P_Inv_currency_code    IN  VARCHAR2,
                                   P_Single_Acct_Ccid     IN  NUMBER,
                                   P_RND_ccid             IN  NUMBER,
                                   P_Inv_line_amt         IN  NUMBER,
                                   P_Proj_line_amt        IN  NUMBER,
                                   P_Project_id           IN  NUMBER,
                                   P_Conv_rate            IN  NUMBER,
                                   P_Draft_inv_num        IN  NUMBER,
                                   X_Acct_amt            OUT  NOCOPY NUMBER ) --File.Sql.39 bug 4440895
AS
  l_rate            NUMBER;
  l_func_line       NUMBER;
  l_mau             NUMBER;
  l_sp              NUMBER;
  l_ep              NUMBER;
  l_rnd_amt         NUMBER;

  /* Shared services changes: local variable to store org ID from org context */
  l_org_id          NUMBER;
BEGIN

/** If  Project Functional Currency is same as invoice currency,
    Then, no rounding issues will occur .
**/
  If  P_Func_currency_code = P_Inv_currency_code
  Then

/** Update the lines Acct amount same as project currency amount **/

    UPDATE  PA_DRAFT_INVOICE_ITEMS
/* MCB2 change
    SET     ACCT_AMOUNT                 = AMOUNT,
*/
    SET     ACCT_AMOUNT                 = PROJFUNC_BILL_AMOUNT,
            ROUNDING_AMOUNT             = 0
    Where   PROJECT_ID                  = P_PROJECT_ID
    and     DRAFT_INVOICE_NUM           = P_DRAFT_INV_NUM
    and     LINE_NUM         = TO_NUMBER(RTRIM(LTRIM(P_Interface_attr6)));

    X_Acct_amt  := 0;

/** Return to the calling program **/
    Return;
  End if;

  l_rate := P_Conv_rate;

/** Get the currency info - minimum accountable unit,
                            standard precision,
                            extended precision for invoice currency.
**/
  get_trans_currency_info(
         L_CURR_CODE   => P_Func_currency_code,
         L_MAU         => l_mau,
         L_SP          => l_sp,
         L_EP          => l_ep );

/** Compute Line Amount in accounting currency
    from invoice currency.
**/

  l_func_line := round(l_rate * P_Inv_line_amt,l_sp);
  /*  l_rnd_amt   := P_Proj_line_amt - l_func_line;  bug 4074354 */
  l_rnd_amt   := l_func_line - P_Proj_line_amt;

/** Shared services changes: get org id from org context, and
    insert it into table RA_INTERFACE_DISTRIBUTIONS as ORG_ID.
**/
   l_org_id := MO_GLOBAL.get_current_org_id;

/**
  Insert Single Account rounding amount in Interface Distribution
**/
 IF l_rnd_amt  <> 0
 THEN
  INSERT INTO RA_INTERFACE_DISTRIBUTIONS
  ( ACCOUNT_CLASS, ACCTD_AMOUNT,AMOUNT,PERCENT,
    CODE_COMBINATION_ID, INTERFACE_LINE_ATTRIBUTE1,
    INTERFACE_LINE_ATTRIBUTE2, INTERFACE_LINE_ATTRIBUTE3,
    INTERFACE_LINE_ATTRIBUTE4, INTERFACE_LINE_ATTRIBUTE5,
    INTERFACE_LINE_ATTRIBUTE6, INTERFACE_LINE_ATTRIBUTE7,
    INTERFACE_LINE_ATTRIBUTE8,INTERFACE_LINE_CONTEXT,
    CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG # 2244810 */
    ORG_ID)
    VALUES ('REV', l_rnd_amt ,0,NULL,P_Single_Acct_Ccid, P_Interface_attr1,
            P_Interface_attr2, P_Interface_attr3,
            P_Interface_attr4, P_Interface_attr5,
            P_Interface_attr6, P_Interface_attr7,
            P_Interface_attr8, P_Batch_Src,
            FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID, /* Bug # 2244810 */
            l_org_id);
   INSERT INTO RA_INTERFACE_DISTRIBUTIONS
   (  ACCOUNT_CLASS, ACCTD_AMOUNT,AMOUNT,PERCENT,
      CODE_COMBINATION_ID, INTERFACE_LINE_ATTRIBUTE1,
      INTERFACE_LINE_ATTRIBUTE2, INTERFACE_LINE_ATTRIBUTE3,
      INTERFACE_LINE_ATTRIBUTE4, INTERFACE_LINE_ATTRIBUTE5,
      INTERFACE_LINE_ATTRIBUTE6, INTERFACE_LINE_ATTRIBUTE7,
      INTERFACE_LINE_ATTRIBUTE8,INTERFACE_LINE_CONTEXT,
      CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG # 2244810 */
      ORG_ID)
   VALUES ('REV',(-1)*( l_rnd_amt ),0,NULL,P_RND_ccid,
            P_Interface_attr1,
            P_Interface_attr2, P_Interface_attr3,
            P_Interface_attr4, P_Interface_attr5,
            P_Interface_attr6, P_Interface_attr7,
            'RND', P_Batch_Src,
            FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID, /* Bug # 2244810 */
            l_org_id);

  END IF;

/** Update Invoice line with line amount,rounding amount
**/

    UPDATE  PA_DRAFT_INVOICE_ITEMS
    SET     ACCT_AMOUNT     =  l_func_line,
            ROUNDING_AMOUNT =  l_rnd_amt
    Where   PROJECT_ID               = P_PROJECT_ID
    and     DRAFT_INVOICE_NUM        = P_DRAFT_INV_NUM
    and     LINE_NUM         = TO_NUMBER(RTRIM(LTRIM(P_Interface_attr6)));

    X_Acct_amt := l_func_line;

EXCEPTION
    When Others
    Then
         Raise;


END Cr_Single_RND_Entries;

/**
  Create_RND_Entries will apply the same logic of Receivable on Invoice
  Line to reach the line amount,UBR and UER in accounting currency and
  compute the possible rounding in accounting entries,and insert proper
  distribution entries in RA interface distribution. Then perform the
  update of invoice line with the computed line amount,UBR,UER in acco
  unting currency.
**/

PROCEDURE  Create_RND_Entries ( P_Batch_Src            IN  VARCHAR2,
                                P_Interface_attr1      IN  VARCHAR2,
                                P_Interface_attr2      IN  VARCHAR2,
                                P_Interface_attr3      IN  VARCHAR2,
                                P_Interface_attr4      IN  VARCHAR2,
                                P_Interface_attr5      IN  VARCHAR2,
                                P_Interface_attr6      IN  VARCHAR2,
                                P_Interface_attr7      IN  VARCHAR2,
                                P_Func_currency_code   IN  VARCHAR2,
                                P_Inv_currency_code    IN  VARCHAR2,
                                P_Inv_rate_type        IN  VARCHAR2,
                                P_Inv_rate_date        IN  DATE,
                                P_Inv_exchange_rate    IN  NUMBER,
                                P_UBR_ccid             IN  NUMBER,
                                P_UER_ccid             IN  NUMBER,
                                P_RND_ccid             IN  NUMBER,
                                P_Inv_line_amt         IN  NUMBER,
                                P_Prj_ubr_amt          IN  NUMBER,
                                P_Prj_uer_amt          IN  NUMBER,
                                P_Inv_ubr_amt          IN  NUMBER,
                                P_Inv_uer_amt          IN  NUMBER,
                                P_Project_id           IN  NUMBER,
                                P_Conv_rate            IN  NUMBER,
                                P_Draft_inv_num        IN  NUMBER )
AS

  l_rate            NUMBER;
  l_func_UBR        NUMBER;
  l_func_UER        NUMBER;
  l_func_line       NUMBER;
  l_rnd_UBR         NUMBER;
  l_rnd_UER         NUMBER;
  l_mau             NUMBER;
  l_sp              NUMBER;
  l_ep              NUMBER;

  /* Shared services changes: local variable to store org ID from org context */
  l_org_id          NUMBER;
BEGIN
/** If  Project Functional Currency is same as invoice currency,
    Then, no rounding issues will occur .
**/

  If  P_Func_currency_code = P_Inv_currency_code
  Then

/** Update the lines Acct amount same as project currency amount **/

    UPDATE  PA_DRAFT_INVOICE_ITEMS
/* MCB2 change
    SET     ACCT_AMOUNT                 = AMOUNT,
*/
    SET     ACCT_AMOUNT                 = PROJFUNC_BILL_AMOUNT,
            ROUNDING_AMOUNT             = 0,
            UNBILLED_ROUNDING_AMOUNT_DR = 0,
            UNEARNED_ROUNDING_AMOUNT_CR = 0
    Where   PROJECT_ID                  = P_PROJECT_ID
    and     DRAFT_INVOICE_NUM           = P_DRAFT_INV_NUM
    and     LINE_NUM         = TO_NUMBER(RTRIM(LTRIM(P_Interface_attr6)));

/** Return to the calling program **/
    Return;
  End if;

  l_rate := P_Conv_rate;

/** Get the currency info - minimum accountable unit,
                            standard precision,
                            extended precision for invoice currency.
**/
  get_trans_currency_info(
         L_CURR_CODE   => P_Func_currency_code,
         L_MAU         => l_mau,
         L_SP          => l_sp,
         L_EP          => l_ep );

/** Compute UBR,Line Amount ,UER in accounting currency
    from invoice currency.
**/

  l_func_UBR  := round(l_rate * P_Inv_ubr_amt,l_sp);
  l_func_line := round(l_rate * P_Inv_line_amt,l_sp);
  l_func_UER  := l_func_line - l_func_UBR;
  l_rnd_UBR   := P_Prj_ubr_amt - l_func_UBR;
  l_rnd_UER   := P_Prj_uer_amt - l_func_UER;

/** Shared services changes: get org id from org context, and
    insert it into table RA_INTERFACE_DISTRIBUTIONS as ORG_ID.
**/
  l_org_id := MO_GLOBAL.get_current_org_id;

/**
  Insert UBR rounding amount in Interface Distribution
**/
/**
  Shared services changes: Insert the org ID
**/
 IF l_rnd_UBR  <> 0
 THEN
  INSERT INTO RA_INTERFACE_DISTRIBUTIONS
  ( ACCOUNT_CLASS, ACCTD_AMOUNT,AMOUNT,PERCENT,
    CODE_COMBINATION_ID, INTERFACE_LINE_ATTRIBUTE1,
    INTERFACE_LINE_ATTRIBUTE2, INTERFACE_LINE_ATTRIBUTE3,
    INTERFACE_LINE_ATTRIBUTE4, INTERFACE_LINE_ATTRIBUTE5,
    INTERFACE_LINE_ATTRIBUTE6, INTERFACE_LINE_ATTRIBUTE7,
    INTERFACE_LINE_ATTRIBUTE8,INTERFACE_LINE_CONTEXT,
    CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG # 2244810 */
    ORG_ID)
    VALUES ('REV', l_rnd_UBR,0,NULL,P_UBR_ccid, P_Interface_attr1,
            P_Interface_attr2, P_Interface_attr3,
            P_Interface_attr4, P_Interface_attr5,
            P_Interface_attr6, P_Interface_attr7,
            'UBR', P_Batch_Src,
            FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
            l_org_id);
 END IF;


/**
  Insert UER rounding amount in Interface Distribution
**/
/**
  Shared services changes: Insert the org ID
**/
 IF l_rnd_UER  <> 0
 THEN
  INSERT INTO RA_INTERFACE_DISTRIBUTIONS
  ( ACCOUNT_CLASS, ACCTD_AMOUNT,AMOUNT,PERCENT,
    CODE_COMBINATION_ID, INTERFACE_LINE_ATTRIBUTE1,
    INTERFACE_LINE_ATTRIBUTE2, INTERFACE_LINE_ATTRIBUTE3,
    INTERFACE_LINE_ATTRIBUTE4, INTERFACE_LINE_ATTRIBUTE5,
    INTERFACE_LINE_ATTRIBUTE6, INTERFACE_LINE_ATTRIBUTE7,
    INTERFACE_LINE_ATTRIBUTE8,INTERFACE_LINE_CONTEXT,
    CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,  /* BUG # 2244810 */
    ORG_ID)
    VALUES ('REV', l_rnd_UER,0,NULL,P_UER_ccid, P_Interface_attr1,
            P_Interface_attr2, P_Interface_attr3,
            P_Interface_attr4, P_Interface_attr5,
            P_Interface_attr6, P_Interface_attr7,
            'UER', P_Batch_Src,
            FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
            l_org_id);
 END IF;

/**
  Shared services changes: Insert the org ID
**/
 IF (l_rnd_UBR + l_rnd_UER)  <> 0
 THEN
   INSERT INTO RA_INTERFACE_DISTRIBUTIONS
   (  ACCOUNT_CLASS, ACCTD_AMOUNT,AMOUNT,PERCENT,
      CODE_COMBINATION_ID, INTERFACE_LINE_ATTRIBUTE1,
      INTERFACE_LINE_ATTRIBUTE2, INTERFACE_LINE_ATTRIBUTE3,
      INTERFACE_LINE_ATTRIBUTE4, INTERFACE_LINE_ATTRIBUTE5,
      INTERFACE_LINE_ATTRIBUTE6, INTERFACE_LINE_ATTRIBUTE7,
      INTERFACE_LINE_ATTRIBUTE8,INTERFACE_LINE_CONTEXT,
      CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,  /* BUG # 2244810 */
      ORG_ID)
   VALUES ('REV',(-1)*( l_rnd_UBR + l_rnd_UER),0,NULL,P_RND_ccid,
            P_Interface_attr1,
            P_Interface_attr2, P_Interface_attr3,
            P_Interface_attr4, P_Interface_attr5,
            P_Interface_attr6, P_Interface_attr7,
            'RND', P_Batch_Src,
            FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
            l_org_id);
  END IF;

/** Update Invoice line with line amount,rounding amount,UBR Rounding
    ,UER rounding amount in accounting currency.
**/

    UPDATE  PA_DRAFT_INVOICE_ITEMS
    SET     ACCT_AMOUNT     =  l_func_line,
/* MCB2 change
            ROUNDING_AMOUNT =  l_func_line - AMOUNT,
*/
            ROUNDING_AMOUNT =  l_func_line - PROJFUNC_BILL_AMOUNT,
            UNBILLED_ROUNDING_AMOUNT_DR = (-1)*l_rnd_UBR,
            UNEARNED_ROUNDING_AMOUNT_CR = l_rnd_UER
    Where   PROJECT_ID               = P_PROJECT_ID
    and     DRAFT_INVOICE_NUM        = P_DRAFT_INV_NUM
    and     LINE_NUM         = TO_NUMBER(RTRIM(LTRIM(P_Interface_attr6)));

EXCEPTION
    When Others
    Then
         Raise;


END Create_RND_Entries;

/**
  This procedure will compute the gl entries for an invoice line,and
  insert the entries in Receivable Interface distribution table.
**/

PROCEDURE  Ins_Dist_Lines(P_Transfer_Mode       IN  VARCHAR2,
                          P_Project_Id          IN  NUMBER,
                          P_Project_Num         IN  VARCHAR2,
                          P_Inv_Num             IN  NUMBER,
                          P_Inv_Curr            IN  VARCHAR2,
                          P_Proj_Func_Cur       IN  VARCHAR2,
                          P_WO_Ccid             IN  NUMBER,
                          P_UBR_Ccid            IN  NUMBER,
                          P_UER_Ccid            IN  NUMBER,
                          P_REC_Ccid            IN  NUMBER,
                          P_RND_Ccid            IN  NUMBER,
                          P_UNB_ret_Ccid        IN  NUMBER,
                          P_Reason_Code         IN  VARCHAR2,
                          P_Batch_Src           IN  VARCHAR2,
                          P_Trx_Num             IN  VARCHAR2,
                          P_Conv_Rate           IN  NUMBER,
                          P_Retn_Acct_Flag      IN  VARCHAR2)
AS
   CURSOR get_single_line
   IS
    SELECT I.AMOUNT AR_AMOUNT,
           I.INTERFACE_LINE_ATTRIBUTE1 attr1,
           I.INTERFACE_LINE_ATTRIBUTE2 attr2,
           I.INTERFACE_LINE_ATTRIBUTE3 attr3,
           I.INTERFACE_LINE_ATTRIBUTE4 attr4,
           I.INTERFACE_LINE_ATTRIBUTE5 attr5,
           I.INTERFACE_LINE_ATTRIBUTE6 attr6,
           I.INTERFACE_LINE_ATTRIBUTE7 attr7,
           decode(P_Transfer_Mode,'INTERCOMPANY','ICREV','WO') attr8,
/* MCB2 change
           DII.AMOUNT Proj_line_amt,
*/
           DII.PROJFUNC_BILL_AMOUNT Proj_line_amt,
           Decode(P_Transfer_Mode,'INTERCOMPANY',
           DII.CC_REV_CODE_COMBINATION_ID,P_WO_Ccid) rev_ccid
     FROM  RA_INTERFACE_LINES I,
           PA_DRAFT_INVOICE_ITEMS DII
     WHERE I.INTERFACE_LINE_ATTRIBUTE1||'' = P_Project_Num
     AND   rtrim(ltrim(I.INTERFACE_LINE_ATTRIBUTE2))  =
           rtrim(ltrim(to_char(P_Inv_Num)))
     -- AND   I.INTERFACE_LINE_CONTEXT           = P_Batch_Src -- Performance Bug 2695303
     AND   I.BATCH_SOURCE_NAME                = P_Batch_Src
     AND   I.TRX_NUMBER                       = P_Trx_Num
     AND   DII.PROJECT_ID                     = P_Project_Id
     AND   DII.DRAFT_INVOICE_NUM              = P_Inv_Num
     AND   DII.LINE_NUM
           = to_number(TRUNC(I.INTERFACE_LINE_ATTRIBUTE6));


  CURSOR get_acct_info
  IS
    SELECT  I.AMOUNT  AR_AMOUNT,
            I.INTERFACE_LINE_ATTRIBUTE1  ATTR1,
            I.INTERFACE_LINE_ATTRIBUTE2  ATTR2,
            I.INTERFACE_LINE_ATTRIBUTE3  ATTR3,
            I.INTERFACE_LINE_ATTRIBUTE4  ATTR4,
            I.INTERFACE_LINE_ATTRIBUTE5  ATTR5,
            I.INTERFACE_LINE_ATTRIBUTE6  ATTR6,
            I.INTERFACE_LINE_ATTRIBUTE7  ATTR7,
            I.CONVERSION_RATE  CRATE,
            I.CONVERSION_DATE  CDATE,
            I.CONVERSION_TYPE  CTYPE
    FROM    RA_INTERFACE_LINES I
    WHERE   I.INTERFACE_LINE_ATTRIBUTE1||''  = P_Project_Num
    AND     rtrim(ltrim(I.INTERFACE_LINE_ATTRIBUTE2))      =
                rtrim(ltrim(to_char(P_Inv_Num)))
    -- AND   I.INTERFACE_LINE_CONTEXT           = P_Batch_Src -- Performance Bug 2695303
    AND   I.BATCH_SOURCE_NAME                = P_Batch_Src
    AND     I.TRX_NUMBER                     = P_Trx_Num ;

    /*Commented for bug 1858443. Added for bug 1529404
    AND     I.BATCH_SOURCE_NAME = (SELECT RBS.NAME FROM
                                   RA_BATCH_SOURCES RBS,PA_IMPLEMENTATIONS IMP
                                   WHERE RBS.BATCH_SOURCE_ID
                                                    =IMP.INVOICE_BATCH_SOURCE_ID);
*/

/* Added for bug 1633776. Removed abs from PRJ_UBR and PRJ_UER and multiplied
 (-1) with PRJ_UBR. */


/* Retention Enahancement : Added the column invoice line type  to identify the Regular line  and
                            unbilled retention line */


    Cursor get_line_info ( l_ar_amt    NUMBER,
                           l_line_num  VARCHAR2)
    Is
           SELECT  DECODE(P_Proj_Func_Cur,P_Inv_Curr,(-1)*(DII.UNBILLED_RECEIVABLE_DR),
/* MCB2 change
                   DECODE((-1)*(DII.UNBILLED_RECEIVABLE_DR),DII.AMOUNT,l_ar_amt,
                   PA_CURRENCY.round_trans_currency_amt((l_ar_amt/DII.AMOUNT)*
*/
                   DECODE((-1)*(DII.UNBILLED_RECEIVABLE_DR),DII.PROJFUNC_BILL_AMOUNT,l_ar_amt,
                   PA_CURRENCY.round_trans_currency_amt((l_ar_amt/DII.PROJFUNC_BILL_AMOUNT)*
                   (-1)*(DII.UNBILLED_RECEIVABLE_DR),P_Inv_Curr))) INV_UBR,
                   (-1)*(nvl(DII.UNBILLED_RECEIVABLE_DR,0)) PRJ_UBR,
                   (nvl(DII.UNEARNED_REVENUE_CR,0)) PRJ_UER,
                   dii.invoice_line_type,                               /* Retention Enhancement */
                   dii.projfunc_bill_amount,
                   dii.inv_amount
           FROM    PA_DRAFT_INVOICE_ITEMS DII
           WHERE   DII.PROJECT_ID        = P_Project_Id
           AND     DII.DRAFT_INVOICE_NUM = P_Inv_Num
           AND     DII.LINE_NUM          = to_number(l_line_num);

  l_inv_uer       NUMBER;
  l_acct_amt      NUMBER;


  /* Retention Enhancement : Variable for store the AR_amount(inv_amount) */

   l_ar_amount    NUMBER;

   l_min_line     NUMBER;  /*Added for bug 7665769 */

  /* Shared services changes: local variable to store org ID from org context */
   l_org_id       NUMBER;

BEGIN

/** Shared services changes: get org id from org context, and
    insert it into table RA_INTERFACE_DISTRIBUTIONS as ORG_ID.
**/
  l_org_id := MO_GLOBAL.get_current_org_id;

 /* For Write-off of Regular Invoice and InterCompany Invoice,the entry
    type is same i.e. only two accounts are involved - Write-off/IC Revenue
    account and Recivable/IC Receivable account . */

  IF ( P_Reason_Code = 'PA_WRITE_OFF'
  OR   P_Transfer_Mode = 'INTERCOMPANY' )
  THEN
    FOR get_woff_line_rec IN get_single_line
    LOOP

      /* Create Rounding Entries for Write-Off Invoice */
           Cr_Single_RND_Entries ( P_Batch_Src  => P_Batch_Src,
                                   P_Interface_attr1  =>get_woff_line_rec.attr1,
                                   P_Interface_attr2  =>get_woff_line_rec.attr2,
                                   P_Interface_attr3  =>get_woff_line_rec.attr3,
                                   P_Interface_attr4  =>get_woff_line_rec.attr4,
                                   P_Interface_attr5  =>get_woff_line_rec.attr5,
                                   P_Interface_attr6  =>get_woff_line_rec.attr6,
                                   P_Interface_attr7  =>get_woff_line_rec.attr7,
                                   P_Interface_attr8  =>get_woff_line_rec.attr8,
                                   P_Func_currency_code =>P_Proj_Func_Cur,
                                   P_Inv_currency_code  =>P_Inv_curr,
                                   P_Single_Acct_Ccid
                                                 =>get_woff_line_rec.rev_ccid,
                                   P_RND_ccid    => P_RND_Ccid,
                                   P_Inv_line_amt=> get_woff_line_rec.AR_AMOUNT,
                                   P_Proj_line_amt
                                             => get_woff_line_rec.Proj_Line_amt,
                                   P_Project_id => P_Project_Id,
                                   P_Conv_rate  => P_Conv_rate,
                                   P_Draft_inv_num => P_Inv_Num,
                                   X_Acct_amt      => l_acct_amt);

 /* Insert the Write-off/Intercompany accounting */
 /* Shared services changes: Insert the org ID */
      INSERT INTO RA_Interface_Distributions
      (
       Account_Class, Amount, Percent, Code_Combination_ID,
       Interface_Line_Attribute1, Interface_Line_Attribute2,
       Interface_Line_Attribute3, Interface_Line_Attribute4,
       Interface_Line_Attribute5, Interface_Line_Attribute6,
       Interface_Line_Attribute7, Interface_Line_Attribute8,
       Interface_Line_Context,Acctd_Amount,
       CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG # 2244810 */
       ORG_ID
        )
       values( 'REV',
              get_woff_line_rec.AR_AMOUNT,
              NULL,
              get_woff_line_rec.rev_ccid,
              get_woff_line_rec.ATTR1,
              get_woff_line_rec.ATTR2,
              get_woff_line_rec.ATTR3,
              get_woff_line_rec.ATTR4,
              get_woff_line_rec.ATTR5,
              get_woff_line_rec.ATTR6,
              get_woff_line_rec.ATTR7,
              get_woff_line_rec.ATTR8,
              P_Batch_Src,
              decode(l_acct_amt,0,get_woff_line_rec.Proj_Line_amt,l_acct_amt),
              FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
              l_org_id);
     END LOOP;

    ELSE
        FOR cur_get_acct_info IN get_acct_info
        LOOP

           /* Retention Enhancement : Storing the AR amount and line amount */



             l_ar_amount    := cur_get_acct_info.ar_amount;


            FOR cur_get_line_info IN get_line_info( cur_get_acct_info.AR_AMOUNT,
                                                     cur_get_acct_info.ATTR6 )
            LOOP


          /* Retention Enhancement : If Retention accounting flag is 'Y' in the project setup
             and invoice line type = 'RETENTION' then insert new line in ra_interface_distribution table
             for the unbill retention account.    */


           IF ((P_Retn_Acct_Flag = 'Y')  AND  (cur_get_line_info.invoice_line_type = 'RETENTION')) THEN



           /* Retention Enhnancement : Creating  Rounding Entries for Retention */
           Cr_Single_RND_Entries ( P_Batch_Src            => P_Batch_Src,
                                   P_Interface_attr1      => cur_get_acct_info.attr1,
                                   P_Interface_attr2      => cur_get_acct_info.attr2,
                                   P_Interface_attr3      => cur_get_acct_info.attr3,
                                   P_Interface_attr4      => cur_get_acct_info.attr4,
                                   P_Interface_attr5      => cur_get_acct_info.attr5,
                                   P_Interface_attr6      => cur_get_acct_info.attr6,
                                   P_Interface_attr7      => cur_get_acct_info.attr7,
                                   P_Interface_attr8      => 'UNB-RET',
                                   P_Func_currency_code   => P_Proj_Func_Cur,
                                   P_Inv_currency_code    => P_Inv_curr,
                                   P_Single_Acct_Ccid     => P_UNB_ret_Ccid,
                                   P_RND_ccid             => P_RND_Ccid,
                                   P_Inv_line_amt         => l_ar_amount,
                                   P_Proj_line_amt        => cur_get_line_info.projfunc_bill_amount,
                                   P_Project_id           => P_Project_Id,
                                   P_Conv_rate            => P_Conv_rate,
                                   P_Draft_inv_num        => P_Inv_Num,
                                   X_Acct_amt             => l_acct_amt);

                 /* Shared services changes: Insert the org ID */
                 INSERT INTO RA_Interface_Distributions
                 (
                   Account_Class, Amount, Percent, Code_Combination_ID,
                   Interface_Line_Attribute1, Interface_Line_Attribute2,
                   Interface_Line_Attribute3, Interface_Line_Attribute4,
                   Interface_Line_Attribute5, Interface_Line_Attribute6,
                   Interface_Line_Attribute7, Interface_Line_Attribute8,
                   Interface_Line_Context,Acctd_amount,
                   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG # 2244810 */
                   ORG_ID
                   )
                  VALUES ('REV',
                          l_ar_amount,
                          NULL,
                          P_UNB_ret_Ccid,
                          cur_get_acct_info.ATTR1,
                          cur_get_acct_info.ATTR2,
                          cur_get_acct_info.ATTR3,
                          cur_get_acct_info.ATTR4,
                          cur_get_acct_info.ATTR5,
                          cur_get_acct_info.ATTR6,
                          cur_get_acct_info.ATTR7,
                          'UNB-RET',
                          P_Batch_Src,
                          decode(l_acct_amt,0, cur_get_line_info.projfunc_bill_amount, l_acct_amt),
                          FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
                          l_org_id);


             ELSE



                 l_inv_uer := cur_get_acct_info.AR_AMOUNT
                              -nvl(cur_get_line_info.INV_UBR,0);



                /* Insert UBR entry for each lines */
                /* Shared services changes: Insert the org ID */
               IF (nvl(cur_get_line_info.INV_UBR,0) <> 0 or PA_BILLING.GETINVOICENZ = 'Y') /* Added Additonal condition for BUG 8666892  */
                THEN
                 INSERT INTO RA_Interface_Distributions
                 (
                   Account_Class, Amount, Percent, Code_Combination_ID,
                   Interface_Line_Attribute1, Interface_Line_Attribute2,
                   Interface_Line_Attribute3, Interface_Line_Attribute4,
                   Interface_Line_Attribute5, Interface_Line_Attribute6,
                   Interface_Line_Attribute7, Interface_Line_Attribute8,
                   Interface_Line_Context,Acctd_amount,
                   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG #2244810 */
                   ORG_ID
                   )
                   VALUES ('REV',
                          cur_get_line_info.INV_UBR,
                          NULL,
                          P_UBR_Ccid,
                          cur_get_acct_info.ATTR1,
                          cur_get_acct_info.ATTR2,
                          cur_get_acct_info.ATTR3,
                          cur_get_acct_info.ATTR4,
                          cur_get_acct_info.ATTR5,
                          cur_get_acct_info.ATTR6,
                          cur_get_acct_info.ATTR7,
                          'UBR',
                          P_Batch_Src,
                          cur_get_line_info.PRJ_UBR,
                          FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
                          l_org_id);
                END IF;



                /* Insert UER entry for each lines */
                /* Shared services changes: Insert the org ID */
                IF (l_inv_uer <> 0 or PA_BILLING.GETINVOICENZ = 'Y') /* Added Additonal condition for BUG 8666892  */
                THEN
                  INSERT INTO RA_Interface_Distributions
                  (
                   Account_Class, Amount, Percent, Code_Combination_ID,
                   Interface_Line_Attribute1, Interface_Line_Attribute2,
                   Interface_Line_Attribute3, Interface_Line_Attribute4,
                   Interface_Line_Attribute5, Interface_Line_Attribute6,
                   Interface_Line_Attribute7, Interface_Line_Attribute8,
                   Interface_Line_Context,Acctd_Amount,
                   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG #2244810 */
                   ORG_ID
                   )
                  VALUES ('REV',
                          l_inv_uer,
                          NULL,
                          P_UER_Ccid,
                          cur_get_acct_info.ATTR1,
                          cur_get_acct_info.ATTR2,
                          cur_get_acct_info.ATTR3,
                          cur_get_acct_info.ATTR4,
                          cur_get_acct_info.ATTR5,
                          cur_get_acct_info.ATTR6,
                          cur_get_acct_info.ATTR7,
                          'UER',
                          P_Batch_Src,
                          cur_get_line_info.PRJ_UER,
                          FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
                          l_org_id);

                 END IF;

                 Create_RND_Entries
                    (
                     P_Batch_Src          => P_Batch_Src,
                     P_Interface_attr1    => cur_get_acct_info.ATTR1,
                     P_Interface_attr2    => cur_get_acct_info.ATTR2,
                     P_Interface_attr3    => cur_get_acct_info.ATTR3,
                     P_Interface_attr4    => cur_get_acct_info.ATTR4,
                     P_Interface_attr5    => cur_get_acct_info.ATTR5,
                     P_Interface_attr6    => cur_get_acct_info.ATTR6,
                     P_Interface_attr7    => cur_get_acct_info.ATTR7,
                     P_Func_currency_code => P_Proj_Func_Cur,
                     P_Inv_currency_code  => P_Inv_Curr,
                     P_Inv_rate_type      => cur_get_acct_info.CTYPE,
                     P_Inv_rate_date      => cur_get_acct_info.CDATE,
                     P_Inv_exchange_rate  => cur_get_acct_info.CRATE,
                     P_UBR_ccid           => P_UBR_Ccid,
                     P_UER_ccid           => P_UER_Ccid,
                     P_RND_ccid           => P_RND_Ccid,
                     P_Inv_line_amt       => cur_get_acct_info.AR_AMOUNT,
/*		     P_Prj_ubr_amt        => abs(cur_get_line_info.PRJ_UBR),
		     P_Prj_uer_amt        => abs(cur_get_line_info.PRJ_UER),
Removed abs added in bug 1633776 as fix for bug 2032231 */
		     P_Prj_ubr_amt        => cur_get_line_info.PRJ_UBR,
	             P_Prj_uer_amt        => cur_get_line_info.PRJ_UER,
                     P_Inv_ubr_amt        => cur_get_line_info.INV_UBR,
                     P_Inv_uer_amt        => l_inv_uer,
                     P_Project_id         => P_Project_Id,
                     P_Conv_rate          => P_Conv_Rate,
                     P_Draft_inv_num      =>
                          to_number(rtrim(ltrim(cur_get_acct_info.ATTR2))));


            END IF ;             /* P_Retn_Acct_Flag = 'Y and invoice_line_type = 'RETENTION' */


            END LOOP;
        END LOOP;
      END IF;


/*Added the select statement for bug 7665769 */
      SELECT min(to_number(rtrim(ltrim(I.Interface_Line_Attribute6))))
        INTO l_min_line
        FROM ra_interface_lines I
	WHERE rtrim(ltrim(I.Interface_Line_Attribute2)) = rtrim(ltrim(to_char(P_Inv_Num)))
	  AND I.Interface_Line_Attribute1 = P_Project_Num
	  AND I.BATCH_SOURCE_NAME = P_Batch_Src
          AND I.TRX_NUMBER  = P_Trx_Num;

      /* Insert the Receivable Accounting for the Invoice */
      /* Shared services changes: Insert the org ID */
      INSERT INTO RA_Interface_Distributions
      (
      Account_Class, Amount, Percent, Code_Combination_ID,
      Interface_Line_Attribute1, Interface_Line_Attribute2,
      Interface_Line_Attribute3, Interface_Line_Attribute4,
      Interface_Line_Attribute5, Interface_Line_Attribute6,
      Interface_Line_Attribute7, Interface_Line_Attribute8,
      Interface_Line_Context,
      CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN, /* BUG # 2244810 */
      ORG_ID
      )
      SELECT 'REC',
             NULL,
             100,
             P_REC_Ccid,
             I.Interface_Line_Attribute1,
             I.Interface_Line_Attribute2,
             I.Interface_Line_Attribute3,
             I.Interface_Line_Attribute4,
             I.Interface_Line_Attribute5,
             I.Interface_Line_Attribute6,
             I.Interface_Line_Attribute7,
             NULL,
             P_Batch_Src,
             FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,
             l_org_id
      FROM   RA_Interface_lines I
      WHERE  rtrim(ltrim(I.Interface_Line_Attribute2)) =
             rtrim(ltrim(to_char(P_Inv_Num)))
      AND    to_number(rtrim(ltrim(I.Interface_Line_Attribute6))) = l_min_line  --Modified the condition for bug 7665769
      AND    I.Interface_Line_Attribute1 = P_Project_Num
      -- AND    I.INTERFACE_LINE_CONTEXT    = P_Batch_Src -- Performance Bug 2695303
      AND    I.BATCH_SOURCE_NAME    = P_Batch_Src
      AND    I.TRX_NUMBER                = P_Trx_Num;

EXCEPTION
  WHEN OTHERS
  THEN
       RAISE;

END Ins_Dist_Lines;


/* This overloaded function was added to provide for compilation of older
        version of files like patopt.lpc. In these older versions, call to procedure
        Convert_Amt is made with older, different signature. This procedure is not
        supposed to be called, hence the body consists of code to raise and exception
        if called. -- bug 2615572*/

PROCEDURE Convert_Amt ( P_Project_Id      IN NUMBER,
                        P_Project_Num     IN VARCHAR2,
                        P_Request_Id      IN NUMBER,
                        P_Proj_Func_Cur   IN VARCHAR2,
                        P_Batch_Src       IN VARCHAR2,
                        P_WO_Ccid         IN NUMBER,
                        P_UBR_Ccid        IN NUMBER,
                        P_UER_Ccid        IN NUMBER,
                        P_REC_Ccid        IN NUMBER,
                        P_RND_Ccid        IN NUMBER,
                        P_Transfer_Mode   IN VARCHAR2)
AS
BEGIN
        RAISE NO_DATA_FOUND;

        EXCEPTION
                WHEN OTHERS THEN
                        RAISE;
END Convert_Amt;



PROCEDURE Convert_Amt ( P_Project_Id      IN NUMBER,
                        P_Project_Num     IN VARCHAR2,
                        P_Request_Id      IN NUMBER,
                        P_Proj_Func_Cur   IN VARCHAR2,
                        P_Batch_Src       IN VARCHAR2,
                        P_WO_Ccid         IN NUMBER,
                        P_UBR_Ccid        IN NUMBER,
                        P_UER_Ccid        IN NUMBER,
                        P_REC_Ccid        IN NUMBER,
                        P_RND_Ccid        IN NUMBER,
                        P_UNB_ret_Ccid    IN   NUMBER,
                        P_Transfer_Mode   IN VARCHAR2,
                        P_Retn_Acct_Flag  IN VARCHAR2)
AS
 CURSOR get_invoice_info
 IS
      SELECT  ORG_DI.DRAFT_INVOICE_NUM cm_inv_num,
              INT_LINE.currency_code invoice_currency_code,
              ORG_DI.DRAFT_INVOICE_NUM_CREDITED orig_inv_num,
              0 CUST_TRX_ID,
              'N' CM_CAN_FLAG,
              ORG_DI.RA_INVOICE_NUMBER CM_TRX_NUM,
              /*  INT_LINE.reason_code REASON_CODE,  Changed for
                   credit memo reason*/
              DECODE(ORG_DI.Draft_Invoice_Num_Credited, NULL, '',
                    DECODE(NVL(ORG_DI.Write_Off_Flag, 'N'), 'N',
                    'PA_CREDIT_MEMO', 'PA_WRITE_OFF')) REASON_CODE,
              /*  INT_LINE.Interface_Line_Context SOURCE, Commented for bug 3502647 */
              INT_LINE.BATCH_SOURCE_NAME SOURCE, /* Added for bug 3502647 */
              ORG_DI.PROJFUNC_INVTRANS_RATE_DATE exchg_date,
              ORG_DI.PROJFUNC_INVTRANS_RATE_TYPE exchg_type,
              ORG_DI.INV_CURRENCY_CODE inv_curr_code,
              INT_LINE.CONVERSION_RATE exchg_rate
      FROM    ra_interface_lines INT_LINE,
              pa_draft_invoices ORG_DI
      WHERE   INT_LINE.interface_line_attribute1||'' = P_Project_Num
      AND     ORG_DI.request_id                      = P_Request_Id
      AND     ltrim(rtrim(INT_LINE.interface_line_attribute2))
                         = ltrim(rtrim(to_char(ORG_DI.Draft_invoice_num)))
      AND     ORG_DI.project_id                      = P_Project_Id
      AND     ORG_DI.DRAFT_INVOICE_NUM_CREDITED is NULL
      AND     INT_LINE.BATCH_SOURCE_NAME             = P_Batch_Src
      AND     INT_LINE.TRX_NUMBER                    = ORG_DI.RA_INVOICE_NUMBER
      UNION
      SELECT  CM_DI.DRAFT_INVOICE_NUM cm_inv_num,
              INT_LINE.currency_code invoice_currency_code,
              CM_DI.DRAFT_INVOICE_NUM_CREDITED orig_inv_num,
              nvl(ORG_DI.SYSTEM_REFERENCE,0) CUST_TRX_ID,
              nvl(ORG_DI.CANCELED_FLAG,'N') CM_CAN_FLAG,
              CM_DI.RA_INVOICE_NUMBER CM_TRX_NUM,
              /*  INT_LINE.reason_code REASON_CODE,  changed for credit memo
                 reason*/
              DECODE(CM_DI.Draft_Invoice_Num_Credited, NULL, '',
                    DECODE(NVL(CM_DI.Write_Off_Flag, 'N'), 'N',
                    'PA_CREDIT_MEMO', 'PA_WRITE_OFF')) REASON_CODE,
              /*  INT_LINE.Interface_Line_Context SOURCE, Commented for bug 3502647 */
              INT_LINE.BATCH_SOURCE_NAME SOURCE, /* Added for bug 3502647 */
              CM_DI.PROJFUNC_INVTRANS_RATE_DATE exchg_date,
              CM_DI.PROJFUNC_INVTRANS_RATE_TYPE exchg_type,
              CM_DI.INV_CURRENCY_CODE inv_curr_code,
              INT_LINE.CONVERSION_RATE exchg_rate
      FROM    ra_interface_lines INT_LINE,
              pa_draft_invoices CM_DI,
              pa_draft_invoices ORG_DI,
              ra_customer_trx   TRX,
              ra_batch_sources  SOURCE
      WHERE   INT_LINE.interface_line_attribute1  = P_Project_Num
      AND     CM_DI.request_id                    = P_Request_Id
      AND     ltrim(rtrim(INT_LINE.interface_line_attribute2))
                         = ltrim(rtrim(to_char(CM_DI.Draft_invoice_num)))
      AND     CM_DI.project_id                    = P_Project_Id
      AND     CM_DI.PROJECT_ID                    = ORG_DI.PROJECT_ID
      AND     CM_DI.DRAFT_INVOICE_NUM_CREDITED    = ORG_DI.DRAFT_INVOICE_NUM
      AND     CM_DI.DRAFT_INVOICE_NUM_CREDITED is NOT NULL
      AND     ORG_DI.SYSTEM_REFERENCE             = TRX.CUSTOMER_TRX_ID
      AND     TRX.BATCH_SOURCE_ID                 = SOURCE.BATCH_SOURCE_ID
      AND     INT_LINE.Batch_Source_Name          = SOURCE.NAME
      AND     INT_LINE.TRX_NUMBER                 = CM_DI.RA_INVOICE_NUMBER
      AND     INT_LINE.BATCH_SOURCE_NAME          = P_Batch_Src;  /* 2366742 */


  CM_CAN_FLAG           PA_DRAFT_INVOICES.CANCELED_FLAG%TYPE;
  PA_ORIG_INV_AMT       NUMBER;
  PA_CM_INV_AMT         NUMBER;
  AR_ORIG_INV_AMT       NUMBER;
  CM_INV_CONV_AMT       NUMBER;
  PA_CM_INTERFACE_AMT   RA_INTERFACE_LINES.AMOUNT%TYPE;
  ROUND_OFF_AMT         NUMBER;
  L_MAX_LINE            RA_INTERFACE_LINES.INTERFACE_LINE_ATTRIBUTE6%TYPE;
  l_rate                NUMBER;
 PA_EXCHG_TYPE         PA_DRAFT_INVOICES.INV_RATE_TYPE%TYPE;/* bug 2142736*/


BEGIN
  FOR cur_get_inv_info IN get_invoice_info
  LOOP
-- -----------------------------------------------------------------------
-- This Has been Commented out for R11.5 Bill in any Currency Project
-- For Bill in any Currency We assume that The User Would not be Changing
-- Currency and Conversion Attributes in AR
-- -----------------------------------------------------------------------
--     IF   ((cur_get_inv_info.orig_inv_num is not null)
--     AND  (cur_get_inv_info.invoice_currency_code <> P_Proj_Func_Cur))
--     THEN
--
--       IF  cur_get_inv_info.CM_CAN_FLAG = 'Y'
--       -- Only Cancelled Case
--       THEN
--
--     /* In case of Cancellation, Update the line amount of the invoice line
--         with the line amount of the original invoice line amount in AR */
--
--          UPDATE RA_INTERFACE_LINES L
--          SET    (L.AMOUNT,L.UNIT_SELLING_PRICE)
--                         = ( SELECT sign(L.AMOUNT)*TRX.EXTENDED_AMOUNT,
--                             sign(L.UNIT_SELLING_PRICE) *TRX.EXTENDED_AMOUNT
--                             from   RA_CUSTOMER_TRX_LINES TRX
--                             Where  TRX.CUSTOMER_TRX_ID
--                                  = cur_get_inv_info.CUST_TRX_ID
--                             and    ltrim(rtrim(TRX.INTERFACE_LINE_ATTRIBUTE6))
--                                    = ltrim(rtrim(L.INTERFACE_LINE_ATTRIBUTE6)))
--           WHERE  L.INTERFACE_LINE_ATTRIBUTE1 = P_Project_Num
--           AND    rtrim(ltrim(L.INTERFACE_LINE_ATTRIBUTE2))
--                      = ltrim(rtrim(to_char(cur_get_inv_info.cm_inv_num)))
--           AND    L.INTERFACE_LINE_CONTEXT    = cur_get_inv_info.SOURCE
--           AND    L.TRX_NUMBER                = cur_get_inv_info.CM_TRX_NUM;
--
--        ELSE
--        -- Only Credit memo
--
--          /* Calculate the Original Invoice Amount in PA */
--           SELECT SUM(DII.AMOUNT)
--           INTO   PA_ORIG_INV_AMT
--           FROM   PA_DRAFT_INVOICE_ITEMS DII
--           WHERE  DII.PROJECT_ID        = P_Project_Id
--           AND    DII.DRAFT_INVOICE_NUM = cur_get_inv_info.orig_inv_num;
--
--          /* Calculate the original Invoice amount in AR */
--           SELECT SUM(TRX_LINES.EXTENDED_AMOUNT)
--           INTO   AR_ORIG_INV_AMT
--           FROM   RA_CUSTOMER_TRX_LINES_ALL TRX_LINES
--           WHERE  TRX_LINES.CUSTOMER_TRX_ID
--                                       = cur_get_inv_info.CUST_TRX_ID
--           AND    TRX_LINES.INTERFACE_LINE_ATTRIBUTE1 = P_Project_Num
--           AND    rtrim(ltrim(TRX_LINES.INTERFACE_LINE_ATTRIBUTE2))
--                  = to_char(cur_get_inv_info.orig_inv_num)
--           AND    TRX_LINES.INTERFACE_LINE_ATTRIBUTE1 IS NOT NULL
--           AND    TRX_LINES.INTERFACE_LINE_ATTRIBUTE2 IS NOT NULL
--           AND    TRX_LINES.INTERFACE_LINE_ATTRIBUTE3 IS NOT NULL
--           AND    TRX_LINES.INTERFACE_LINE_ATTRIBUTE4 IS NOT NULL
--           AND    TRX_LINES.INTERFACE_LINE_ATTRIBUTE5 IS NOT NULL
--           AND    TRX_LINES.INTERFACE_LINE_ATTRIBUTE6 IS NOT NULL;
--
--          /* Calculate the Invoice Amount of the Crediting Invoice */
--           SELECT SUM(DII.AMOUNT)
--           INTO   PA_CM_INV_AMT
--           FROM   PA_DRAFT_INVOICE_ITEMS DII
--           WHERE  DII.PROJECT_ID        = P_Project_Id
--           AND    DII.DRAFT_INVOICE_NUM = cur_get_inv_info.cm_inv_num;
--
--           /* Calculate the prorated value of the crediting Invoice */
--           CM_INV_CONV_AMT:= PA_CM_INV_AMT * (AR_ORIG_INV_AMT/PA_ORIG_INV_AMT);
--
--           /* Update the amount of the crediting Invoice in AR interface
--              table */
--           UPDATE RA_INTERFACE_LINES
--           SET    AMOUNT   = PA_CURRENCY.round_trans_currency_amt(AMOUNT
--                                *(AR_ORIG_INV_AMT/PA_ORIG_INV_AMT) ,
--                                      cur_get_inv_info.invoice_currency_code),
--                  UNIT_SELLING_PRICE = PA_CURRENCY.round_trans_currency_amt(
--                           UNIT_SELLING_PRICE *(AR_ORIG_INV_AMT/PA_ORIG_INV_AMT)
--                               ,cur_get_inv_info.invoice_currency_code)
--           WHERE  INTERFACE_LINE_ATTRIBUTE1   = P_Project_Num
--           AND    rtrim(ltrim(INTERFACE_LINE_ATTRIBUTE2))
--                                      = to_char(cur_get_inv_info.cm_inv_num)
--           AND    BATCH_SOURCE_NAME           = cur_get_inv_info.SOURCE
--         AND    TRX_NUMBER                  = cur_get_inv_info.CM_TRX_NUM;
--
--
--           /* Calculate the converted invoice amount */
--           SELECT SUM(L.AMOUNT),
--                  MAX(L.INTERFACE_LINE_ATTRIBUTE6)
--           INTO   PA_CM_INTERFACE_AMT,
--                  L_MAX_LINE
--           FROM   RA_INTERFACE_LINES L
--           WHERE  L.INTERFACE_LINE_ATTRIBUTE1 = P_Project_Num
--           AND    ltrim(rtrim(L.INTERFACE_LINE_ATTRIBUTE2))
--                         = to_char(cur_get_inv_info.cm_inv_num)
--           AND    L.BATCH_SOURCE_NAME         = cur_get_inv_info.SOURCE
--           AND    L.TRX_NUMBER                = cur_get_inv_info.CM_TRX_NUM;
--
--
--         /* Calculate the round off error amount */
--           ROUND_OFF_AMT := CM_INV_CONV_AMT- PA_CM_INTERFACE_AMT;
--
--           /* Adjust the round off error amount with the maximum invoice
--              line */
--           UPDATE RA_INTERFACE_LINES A
--           SET   A.AMOUNT = A.AMOUNT + ROUND_OFF_AMT,
--                 A.UNIT_SELLING_PRICE = A.UNIT_SELLING_PRICE + ROUND_OFF_AMT
--           WHERE A.INTERFACE_LINE_ATTRIBUTE1 = P_Project_Num
--           AND   ltrim(rtrim(A.INTERFACE_LINE_ATTRIBUTE2))
--                     = to_char(cur_get_inv_info.cm_inv_num)
--           AND   A.INTERFACE_LINE_ATTRIBUTE6 = L_MAX_LINE
--           AND   A.BATCH_SOURCE_NAME         = cur_get_inv_info.SOURCE
--           AND   A.TRX_NUMBER                = cur_get_inv_info.CM_TRX_NUM;
--
--      END IF; /* Cancellation */
--   END IF; /* Currency Check */
   /* Get the rate from invoice currency to functional currency
      If Invoice rate type is not 'User'then get the conversion rate
      else use the user rate.
   */

  l_rate := NULL;
  PA_EXCHG_TYPE := cur_get_inv_info.exchg_type;/*Added for bug 2142736*/
  If  cur_get_inv_info.inv_curr_code <> P_Proj_Func_Cur
  Then
    If  cur_get_inv_info.exchg_type <> 'User'
    Then
      l_rate := GL_CURRENCY_API.get_rate (
                X_FROM_CURRENCY   => cur_get_inv_info.inv_curr_code,
                X_TO_CURRENCY     => P_Proj_Func_Cur,
                X_CONVERSION_TYPE => cur_get_inv_info.exchg_type,
                X_CONVERSION_DATE => cur_get_inv_info.exchg_date );
    Else
    /*Added for bug 2142736*/
     IF cur_get_inv_info.exchg_rate is not null
      then
         l_rate := cur_get_inv_info.exchg_rate;
     ELSE
       IF  cur_get_inv_info.CM_CAN_FLAG = 'Y'
	THEN
             SELECT SUM(DII.AMOUNT) /SUM(DII.INV_AMOUNT)
              INTO   l_rate
             FROM   PA_DRAFT_INVOICE_ITEMS DII
             WHERE  DII.PROJECT_ID        = P_Project_Id
             AND    DII.DRAFT_INVOICE_NUM = cur_get_inv_info.cm_inv_num;

	     PA_EXCHG_TYPE :='User';
        END IF;
     END IF;
     /*End of bug 2142736*/
    End If;
  End if;

/*Changed cur_get_inv_info.exchg_type to PA_EXCHG_TYPE*/

  Update PA_DRAFT_INVOICES
  set    ACCTD_CURR_CODE  = P_Proj_Func_Cur,
         ACCTD_RATE_TYPE  = decode(cur_get_inv_info.inv_curr_code,
                            P_Proj_Func_Cur,NULL,PA_EXCHG_TYPE),
         ACCTD_RATE_DATE  = decode(cur_get_inv_info.inv_curr_code,
                            P_Proj_Func_Cur,NULL,cur_get_inv_info.exchg_date),
         ACCTD_EXCHG_RATE = decode(cur_get_inv_info.inv_curr_code,
                            P_Proj_Func_Cur,NULL,l_rate)
  Where  project_id       = P_Project_Id
  And    draft_invoice_num= cur_get_inv_info.cm_inv_num;


 /* Retention Changes : Adding the unbilled retention code combination Id */


   /* Insert the accounting entry for UBR/UER/WO/IC */
   Ins_Dist_lines(P_Transfer_Mode,
                  P_Project_Id,
                  P_Project_Num,
                  cur_get_inv_info.cm_inv_num,
                  cur_get_inv_info.invoice_currency_code,
                  P_Proj_Func_Cur,
                  P_WO_Ccid,
                  P_UBR_Ccid,
                  P_UER_Ccid,
                  P_REC_Ccid,
                  P_RND_Ccid,
                  P_UNB_ret_Ccid,
                  cur_get_inv_info.REASON_CODE,
                  cur_get_inv_info.SOURCE,
                  cur_get_inv_info.CM_TRX_NUM,
                  l_rate,
                  P_Retn_Acct_Flag);

    END LOOP;

  EXCEPTION
    WHEN OTHERS  THEN
     RAISE;
END Convert_Amt;

PROCEDURE Check_Invoice_acct_setup ( P_Func_code          IN  VARCHAR2,
                                     P_ou_retn_acct_flag  IN  VARCHAR2,
                                     X_Status             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
  l_dummy     Varchar2(1);
BEGIN

/* Retention Enhancement :
   Ou level Retention Flag enabled  : If any auto accounting function transaction es disabled then
                                      error out.
   Ou level Retention Flag disabled : If any auto accounting function transaction is disabled other
                                      than the Unbilled Retention account then error out.
*/

/* This setups are valid only for invoice accounts
   It is not valid for revenue accounts like Realized Gains and Losses
   added where clause for patchset K */


IF  (P_ou_retn_acct_flag = 'Y') THEN


    SELECT  'x'
    INTO    l_dummy
    FROM    PA_FUNCTION_TRANSACTIONS
    WHERE   FUNCTION_CODE     = P_Func_code
     AND    function_transaction_code NOT IN ('RLZD-GAIN', 'RLZD-LOSS')
    AND     nvl(ENABLED_FLAG,'N') = 'N'
    AND     rownum    = 1;

ELSIF (P_ou_retn_acct_flag = 'N') THEN


    SELECT  'x'
    INTO    l_dummy
    FROM    PA_FUNCTION_TRANSACTIONS
    WHERE   FUNCTION_CODE     = P_Func_code
/*    AND    function_transaction_code NOT IN ('UNB-RET','RLZD_GAIN', 'RLZD_LOSS')  */
    AND    function_transaction_code NOT IN ('UNB-RET','RLZD-GAIN', 'RLZD-LOSS')
    AND     nvl(ENABLED_FLAG,'N') = 'N'
    AND     rownum    = 1;

    --AND     FUNCTION_TRANSACTION_CODE <> 'UNB-RET'
END IF;


  X_Status   := 'Y';

EXCEPTION
  When NO_DATA_FOUND
  Then
       X_Status   := 'N';
  When Others
  Then
       raise;

END Check_Invoice_acct_setup;


/* Retention Enhancement : Added the new param P_ou_retn_acct_flag and P_UNB_ret_ccid */


PROCEDURE Check_ccid ( P_Rec_ccid          IN  NUMBER,
                       P_UBR_ccid          IN  NUMBER,
                       P_UER_ccid          IN  NUMBER,
                       P_WO_ccid           IN  NUMBER,
                       P_RND_ccid          IN  NUMBER,
                       P_ou_retn_acct_flag IN  VARCHAR2,
                       P_UNB_ret_ccid      IN  NUMBER,
                       X_Status            OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS
  l_dummy     VARCHAR2(1);
BEGIN

  SELECT 'x'
  INTO   l_dummy
  FROM   gl_code_combinations
  WHERE  code_combination_id = P_Rec_ccid;


/****
    P_UBR_ccid, P_UER_ccid, P_WO_ccid will return null for Intercompany.

***/

  if (P_UBR_ccid is not null) then
     SELECT 'x'
     INTO   l_dummy
     FROM   gl_code_combinations
     WHERE  code_combination_id = P_UBR_ccid;
  end if;

  if (P_UER_ccid is not null) then
     SELECT 'x'
     INTO   l_dummy
     FROM   gl_code_combinations
     WHERE  code_combination_id = P_UER_ccid;
  end if;


  if (P_WO_ccid is not null) then
     SELECT 'x'
     INTO   l_dummy
     FROM   gl_code_combinations
     WHERE  code_combination_id = P_WO_ccid;
  end if;


  SELECT 'x'
  INTO   l_dummy
  FROM   gl_code_combinations
  WHERE  code_combination_id = P_RND_ccid;


  /* Retention Enhancement : Validating the unbilled retention cc id */


  IF (P_ou_retn_acct_flag = 'Y') and (P_UNB_ret_ccid IS NOT NULL) THEN

   SELECT  'x'
     INTO  l_dummy
     FROM  gl_code_combinations
    WHERE  code_combination_id = P_UNB_ret_ccid;

  END IF;


  X_Status  := 'N';

EXCEPTION

  When NO_DATA_FOUND
  Then
       X_Status := 'Y';

  When Others
  Then
       Raise;

END Check_ccid;

PROCEDURE get_reject_reason ( P_reject_code    IN var_arr_30,
                              P_num_rec        IN NUMBER,
                              X_reject_reason OUT NOCOPY var_arr_80) --File.Sql.39 bug 4440895
AS
 cursor get_reason ( l_rej_code in varchar2)
 is
   select nvl(meaning ,l_rej_code)
   from   pa_lookups
   where  lookup_type = 'TRANSFER REJECTION CODE'
   and    lookup_code = l_rej_code;

 i         NUMBER;
 l_reason  VARCHAR2(80);
 l_reject_code VARCHAR2(30):= NULL;
 l_reject_res  VARCHAR2(80):= NULL;

BEGIN
  for i in 1..P_num_rec
  loop
    X_reject_reason(i) := NULL;
    if (P_reject_code(i) is not null)
    then
     if ((P_reject_code(i) <> l_reject_code)
     or  (l_reject_code is NULL))
     then
        open get_reason ( P_reject_code(i));
        fetch get_reason into l_reason;
        close get_reason;
        X_reject_reason(i) := l_reason;
        l_reject_code      := P_reject_code(i);
        l_reject_res       := l_reason;
     else
        X_reject_reason(i) := l_reject_res;
     end if;
    end if;
  end loop;

END get_reject_reason;

/*===============================================================+
 | To get the AR Trx Type, instead of using the Invoice_Org_Type |
 | from PA_Implementations, use HR_Organization_Information      |
 | table. There should be a rec for the org in this table        |
 | satisfying the conditions detailed below. Org-Reorg changes.  |
 | Also, use Proj_Org_Structure_version_id, Proj_Org_Structure_id|
 | and Proj_Start_Org_id                                         |
 +===============================================================*/
  /* Added P_trans_type for bug 8687883*/
PROCEDURE  GET_TRX_CRMEMO_TYPES (P_business_group_id            IN   NUMBER,
                                 P_carrying_out_org_id          IN   NUMBER,
                                 P_proj_org_struct_version_id   IN   NUMBER,
			                           p_basic_language               IN   VARCHAR2,
			                           p_trans_date		                IN   DATE,
                                 P_trans_type                   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 P_crmo_trx_type                OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 P_error_status                 OUT  NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                 P_error_message                OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

     org_flag     BOOLEAN :=false;
     pl_org_id    NUMBER :=0;

-- Cursor is used to select organization sort by level
-- Removed business group id check from CONNECT BY AND START WITH clause

/* Modifications have been made to the cursor cur_org for BUG#1493157
 SELECT p_carrying_out_org_id from dual
 union all   has been added to select the start organization into the cursor
along with the other organizations that are selected from the connect By query.
The second part of select has been modified so as to select organization_id_parent inplace of organization_id_child */

CURSOR cur_org IS
                  SELECT p_carrying_out_org_id from dual
                  union all
                  SELECT struct.organization_id_parent organization_id
                      FROM per_org_structure_elements struct
                           CONNECT BY PRIOR
                         struct.organization_id_parent = struct.organization_id_child
/*                                 AND struct.business_group_id = p_business_group_id      */
                                 AND struct.org_structure_version_id + 0 =
                                      p_proj_org_struct_version_id
                                   START WITH struct.organization_id_child
                                   = p_carrying_out_org_id+0
/*                                AND struct.business_group_id = p_business_group_id    */
                    AND struct.org_structure_version_id + 0 = p_proj_org_struct_version_id;


-- Cursor is used to select trx type, credit memo type from AR
-- Removed Business Group id check from WHERE clause

CURSOR cur_trx_types(ip_org_id NUMBER) IS
       SELECT TO_CHAR (type.cust_trx_type_id) cust_trx_type_id,
                           TO_CHAR (type.credit_memo_type_id) credit_memo_type
                    FROM   ra_cust_trx_types type,
                           hr_all_organization_units org,
                           hr_all_organization_units_tl org_tl
                    WHERE org_tl.organization_id = org.organization_id
                     AND  org_tl.language = p_basic_language
                     AND  org.organization_id = ip_org_id
/*                     AND  org.business_group_id = p_business_group_id   */
                     AND  type.type = 'INV'
                     AND  trim(type.name) = trim(substrb(org_tl.organization_id ||org_tl.name,1,17)) /*Modified for bug 6021078 */ /*Modified for bug 9213496*/
                     AND NVL(p_trans_date,SYSDATE) BETWEEN type.start_date AND NVL (type.end_date, NVL(p_trans_date,SYSDATE)) /* Modified for bug 8687883*/
                     AND EXISTS (
                                SELECT 'x'
                                FROM    hr_organization_information  orginfo
                                WHERE   orginfo.organization_id = ip_org_id
                                AND     orginfo.org_information_context = 'CLASS'
                                AND     orginfo.org_information1 = 'PA_INVOICE_ORG'
                                AND     orginfo.org_information2 = 'Y' );

     trx_types_rec    cur_trx_types%ROWTYPE;  /* record declare */

BEGIN
      OPEN  cur_org;  /* open cursor */

       LOOP           /*  OUTER Loop starts   */

       FETCH cur_org INTO pl_org_id;

       EXIT WHEN cur_org%NOTFOUND OR org_flag;  /* exit if no data found or trx found */

        OPEN cur_trx_types(pl_org_id);

         LOOP   /* Inner Loop */

         FETCH cur_trx_types INTO trx_types_rec;
         EXIT WHEN cur_trx_types%NOTFOUND;

         p_trans_type := trx_types_rec.cust_trx_type_id; /* assign trx type ID to OUT variable */
         p_crmo_trx_type := trx_types_rec.credit_memo_type; /* Assign credit-memo ID to OUT variable */
         org_flag := true;  /* Flag set to exit from loop(s) */
         exit;  /* Exit from inner Loop */

         END LOOP;   /* Inner Loop ends */


        CLOSE cur_trx_types;

         IF org_flag THEN   /* If flag is true exit from OUTER loop */

                 exit;

         END IF;

       END LOOP;    /*  Outer Loop Ends   */
         CLOSE cur_org;

      IF NOT org_flag THEN   /* If the flag is false */
      --          assign pa_imp values

                  BEGIN
                     SELECT description into p_error_message
                     FROM pa_lookups
                     WHERE lookup_type='AR TRANSACTION TYPE MISSING' AND
                           lookup_code ='AR_TRX_TYPE_NOT_FOUND';

               EXCEPTION
                WHEN NO_DATA_FOUND THEN
       p_error_message := 'AR transaction type or credit memo type not defined for this organization.';
                     p_error_status := 1;

                     /* ATG CHANGES */

                       P_trans_type      := null;
                       P_crmo_trx_type   := null;


                WHEN OTHERS THEN
                        p_error_message := sqlerrm;
                        p_error_status := 1;

                    /* ATG CHANGES */

                           P_trans_type      := null;
                           P_crmo_trx_type   := null;


                 END;

      END IF;

END GET_TRX_CRMEMO_TYPES;

/*===============================================================+
 | This procedure checks for Internal customers. if exists,      |
 | then checks whether the transaction type are defined.         |
 +===============================================================*/
PROCEDURE  CHECK_TRXTYPE_INTERNAL (
                                 P_proj_id          IN   NUMBER,
                                 P_trans_type       IN   VARCHAR2,
                                 P_crmo_trx_type    IN   VARCHAR2,
                                 P_reject_mesg      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 P_error_status     OUT  NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                 P_error_message    OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
     int_ctr    NUMBER :=0;
BEGIN
    SELECT count(*) into int_ctr
    FROM PA_Project_Customers
    WHERE Project_ID = P_proj_id
    AND   NVL(Bill_Another_Project_Flag,'N') = 'Y';

    if (int_ctr > 0) THEN
        if (P_crmo_trx_type = '0' OR P_trans_type = '0') THEN
           P_reject_mesg := 'NO_INV_TYPE';
        else
           P_reject_mesg := NULL;
        end if;
    else
           P_reject_mesg := NULL;
    end if;

    EXCEPTION
         WHEN OTHERS THEN
               P_reject_mesg := 'NO_INV_TYPE';
               P_error_message := sqlerrm;
               P_error_status := 1;

END CHECK_TRXTYPE_INTERNAL;

/* This procedure is added for bug 2958951 */
PROCEDURE GET_GL_DATE_PERIOD (P_inv_date         IN  DATE DEFAULT SYSDATE,
                              P_ar_install_flag  IN  VARCHAR2,
                              P_gl_date          OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                              P_gl_period_name   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              P_pa_date          OUT NOCOPY DATE, /* Added for bug 4202647*/ --File.Sql.39 bug 4440895
                              P_pa_period_name   OUT NOCOPY VARCHAR2, /* Added for bug 4202647*/ --File.Sql.39 bug 4440895
                              P_error_stage      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              P_error_msg_code   OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

     l_inv_date           DATE ;
     l_pa_date            pa_cost_distribution_lines_all.pa_date%TYPE ;
     l_pa_period_name     pa_cost_distribution_lines_all.pa_period_name%TYPE;
     l_gl_period_name     pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;
     l_gl_date            pa_cost_distribution_lines_all.pa_date%TYPE;
     l_calling_module     VARCHAR2(30);
     l_return_status      NUMBER ;
     l_error_stage        NUMBER ;
     l_stage              VARCHAR2(30) ;
     l_error_code         VARCHAR2(30) := NULL;
     l_exception_msg      VARCHAR2(80) := NULL ;

     l_pa_gl_app_id NUMBER := 8721 ;
     l_ar_app_id    NUMBER := 222;
     l_app_id       NUMBER := NULL ;
     l_sob_id       NUMBER;

 BEGIN
     l_stage := 'Inside get_gl_date';
     IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: '||l_stage);
     END IF;

     IF P_ar_install_flag = 'I' THEN
        l_stage := 'AR is installed';
        l_calling_module := 'AR_INSTALLED_INVOICE';
        l_app_id := l_ar_app_id;
        IF g1_debug_mode  = 'Y' THEN
           PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: '||l_stage);
        END IF;
     ELSE
        l_stage := 'AR is not installed';
        l_calling_module := 'AR_NOT_INSTALLED_INVOICE';
        l_app_id := l_pa_gl_app_id;
        IF g1_debug_mode  = 'Y' THEN
           PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: '||l_stage);
        END IF;
     END IF;

     l_inv_date := p_inv_date;
     l_stage := 'About to get ou period info';
     IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: '||l_stage);
     END IF;

     PA_UTILS2.get_OU_period_information
                   (p_reference_date        => l_inv_date,
                    p_calling_module        => l_calling_module,
                    x_pa_date               => l_pa_date,
                    x_pa_period_name        => l_pa_period_name,
                    x_gl_date               => l_gl_date,
                    x_gl_period_name        => l_gl_period_name,
                    x_return_status         => l_return_status,
                    x_error_code            => l_error_code,
                    x_error_stage           => l_error_stage
                   );

     l_stage := 'After get_ou_period';
     IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: '||l_stage);
     END IF;

     IF l_error_code IS NOT NULL THEN

           l_stage := 'Error code of get OU period';
           IF g1_debug_mode  = 'Y' THEN
              PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: '||l_stage);
              PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: Error Code: '||l_error_code);
              PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: Error Stage: '||l_error_stage);
           END IF;

/* Added if for bug 3183174 */
           IF l_error_code = 'NO_PRVDR_GL_DATE' AND P_ar_install_flag = 'I' THEN
	      l_error_code := 'NO_AR_PERIOD';
	   END IF;
     END IF;

     l_stage := 'All Done successfully';
     IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('GET_GL_DATE_PERIOD: '||l_stage);
     END IF;

     p_gl_date          := l_gl_date;
     p_gl_period_name   := l_gl_period_name;
     p_pa_date          := l_pa_date;
     p_pa_period_name   := l_pa_period_name;
     p_error_msg_code   := l_error_code;
     p_error_stage      := l_stage;

EXCEPTION
    WHEN OTHERS THEN
         p_error_Stage      := l_stage;
         p_error_msg_code   := l_error_code;

        /* ATG Changes */

         P_gl_date          := null;
         P_gl_period_name   := null;
         P_pa_date          := null;
         P_pa_period_name   := null;

         RAISE;
END get_gl_date_period;

END PA_INVOICE_XFER;

/
