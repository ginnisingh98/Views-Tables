--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_REMIT_COLL_OCCUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_REMIT_COLL_OCCUR" AS
/* $Header: jlbrratb.pls 120.14.12010000.3 2010/04/14 06:36:43 mkandula ship $*/

PROCEDURE remit_collection (P_BORDERO_ID  IN NUMBER,
                            P_USER_ID     IN NUMBER,
                            P_PROC_STATUS IN OUT NOCOPY NUMBER) IS
PL_SELECTION_CONTROL_ID   NUMBER(38);
PL_SELECT_ACCOUNT_ID      NUMBER(38);
PL_CS_SELECTION_STATUS    VARCHAR2(30);
var_selection_control_chk NUMBER;
var_selection_control     NUMBER;
var_bordero_status_chk    VARCHAR2(30);
var_bordero_type          VARCHAR2(30);
l_set_of_books_id         NUMBER;
l_currency_code           VARCHAR2(30);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(80);
l_mesg                    VARCHAR2(1000);
l_return_status           VARCHAR2(30);
x_cash_receipt_id         NUMBER;
l_occurrence_id           NUMBER;  -- SLA Uptake - Bug#4301543
l_event_id                NUMBER;  -- SLA Uptake - Bug#4301543
l_occ                     NUMBER;
l_org_id                  NUMBER;

  CURSOR  check1 IS
          SELECT  bordero_status, selection_control_id,bordero_type
          FROM    jl_br_ar_borderos
          WHERE   bordero_id = P_BORDERO_ID
                  AND bordero_status in ('SELECTED', 'FORMATTED')
          FOR UPDATE NOWAIT;

  CURSOR  check2 IS
          SELECT  selection_control_id
          FROM    jl_br_ar_select_controls
          WHERE   selection_control_id = var_selection_control
          FOR UPDATE;

  /* Cursor PS is used to read documents from bordero which were not remitted */

  /* CE uptake - Bug#2932986
  cursor PS is
    select PS.PAYMENT_SCHEDULE_ID,  DC.DOCUMENT_ID,
           DC.PORTFOLIO_CODE,       PS.GLOBAL_ATTRIBUTE10,
           DC.FACTORING_AMOUNT,     DC.BANK_INSTRUCTION_CODE1,
           PS.AMOUNT_DUE_REMAINING, DC.BANK_INSTRUCTION_CODE2,
           DC.NUM_DAYS_INSTRUCTION, PS.DUE_DATE,
           DC.BANK_CHARGE_AMOUNT,   DC.RECEIPT_METHOD_ID,
           jlbo.BANK_NUMBER,
           jlbo.BANK_OCCURRENCE_CODE,
           jlbo.BANK_OCCURRENCE_TYPE,
           b.OUTPUT_FORMAT,
           JLBRRMA.BANK_CHARGES_CCID,
           JLBRRMA.COLL_ENDORSEMENT_CCID,
           JLBRRMA.BILLS_COLLECTION_CCID,
           JLBRRMA.OTHER_CREDITS_CCID,
           JLBRRMA.FACTORING_DOCS_CCID,
           JLBRRMA.CALCULATED_INTEREST_CCID,
           JLBRRMA.INTEREST_WRITEOFF_CCID,
           RMA.CASH_CCID,
           RMA.EARNED_CCID,
           RMA.ON_ACCOUNT_CCID,
           RMA.UNAPPLIED_CCID,
           RMA.UNEARNED_CCID,
           RMA.UNIDENTIFIED_CCID,
           JLBRRMA.ABATEMENT_WRITEOFF_CCID,
           JLBRRMA.ABATEMENT_REVENUE_CCID,
           JLBRRMA.INTEREST_REVENUE_CCID,
           JLBRRMA.CALCULATED_INTEREST_RECTRX_ID,
           JLBRRMA.INTEREST_WRITEOFF_RECTRX_ID,
           JLBRRMA.INTEREST_REVENUE_RECTRX_ID,
           JLBRRMA.ABATEMENT_WRITEOFF_RECTRX_ID,
           JLBRRMA.ABATEMENT_REVENUE_RECTRX_ID,
           CSC.GL_DATE
    from   AR_PAYMENT_SCHEDULES_ALL PS, JL_BR_AR_COLLECTION_DOCS_ALL DC,
           JL_BR_AR_BORDEROS B,
           AR_RECEIPT_METHOD_ACCOUNTS_ALL RMA,
           JL_BR_AR_SELECT_ACCOUNTS_ALL CSC,
           JL_BR_AR_REC_MET_ACCTS_EXT_ALL JLBRRMA,
           AP_BANK_ACCOUNTS_ALL apba,
           AP_BANK_BRANCHES apbb,
           JL_BR_AR_BANK_OCCURRENCES jlbo
    where  DC.PAYMENT_SCHEDULE_ID = PS.PAYMENT_SCHEDULE_ID
    and    PS.STATUS              = 'OP'
    and    B.BORDERO_STATUS       = 'SELECTED'
    and    DC.DOCUMENT_STATUS     = 'SELECTED'
    and    B.BORDERO_ID           = DC.BORDERO_ID
    and    DC.BORDERO_ID          = P_BORDERO_ID
    and    CSC.SELECT_ACCOUNT_ID     = B.SELECT_ACCOUNT_ID
    and    JLBRRMA.RECEIPT_METHOD_ID = DC.RECEIPT_METHOD_ID
    and    JLBRRMA.BANK_ACCOUNT_ID   = B.BANK_ACCOUNT_ID
    and    RMA.RECEIPT_METHOD_ID     = DC.RECEIPT_METHOD_ID
    and    RMA.BANK_ACCOUNT_ID       = B.BANK_ACCOUNT_ID
    and    apba.BANK_ACCOUNT_ID       =b.bank_account_id
    and    apba.bank_branch_id = apbb.bank_branch_id
    and    jlbo.BANK_NUMBER = apbb.bank_number
    and    jlbo.STD_OCCURRENCE_CODE = 'REMITTANCE'
    and    jlbo.BANK_OCCURRENCE_TYPE = 'REMITTANCE_OCCURRENCE';
*/


  cursor PS is
    select PS.PAYMENT_SCHEDULE_ID,  DC.DOCUMENT_ID,
           DC.PORTFOLIO_CODE,       PS.GLOBAL_ATTRIBUTE10,
           DC.FACTORING_AMOUNT,     DC.BANK_INSTRUCTION_CODE1,
           PS.AMOUNT_DUE_REMAINING, DC.BANK_INSTRUCTION_CODE2,
           DC.NUM_DAYS_INSTRUCTION, PS.DUE_DATE,
           DC.BANK_CHARGE_AMOUNT,   DC.RECEIPT_METHOD_ID,
           --jlbo.BANK_NUMBER,
           jlbo.bank_party_id,
           jlbo.BANK_OCCURRENCE_CODE,
           jlbo.BANK_OCCURRENCE_TYPE,
           b.OUTPUT_FORMAT,
           JLBRRMA.BANK_CHARGES_CCID,
           JLBRRMA.COLL_ENDORSEMENT_CCID,
           JLBRRMA.BILLS_COLLECTION_CCID,
           JLBRRMA.OTHER_CREDITS_CCID,
           JLBRRMA.FACTORING_DOCS_CCID,
           JLBRRMA.CALCULATED_INTEREST_CCID,
           JLBRRMA.INTEREST_WRITEOFF_CCID,
           JLBRRMA.BILLS_DISCOUNT_CCID,
           JLBRRMA.DISC_ENDORSEMENT_CCID,
           JLBRRMA.DISCOUNTED_BILLS_CCID,
           JLBRRMA.FACTORING_INTEREST_CCID,
           RMA.CASH_CCID,
           RMA.EARNED_CCID,
           RMA.ON_ACCOUNT_CCID,
           RMA.UNAPPLIED_CCID,
           RMA.UNEARNED_CCID,
           RMA.UNIDENTIFIED_CCID,
           JLBRRMA.ABATEMENT_WRITEOFF_CCID,
           JLBRRMA.ABATEMENT_REVENUE_CCID,
           JLBRRMA.INTEREST_REVENUE_CCID,
           JLBRRMA.CALCULATED_INTEREST_RECTRX_ID,
           JLBRRMA.INTEREST_WRITEOFF_RECTRX_ID,
           JLBRRMA.INTEREST_REVENUE_RECTRX_ID,
           JLBRRMA.ABATEMENT_WRITEOFF_RECTRX_ID,
           JLBRRMA.ABATEMENT_REVENUE_RECTRX_ID,
           CSC.GL_DATE,
           CeBankAccount.bank_account_id,
           DC.org_id,
           PS.CUSTOMER_ID
    from   AR_PAYMENT_SCHEDULES_ALL PS, JL_BR_AR_COLLECTION_DOCS_ALL DC,
           JL_BR_AR_BORDEROS B,
           AR_RECEIPT_METHOD_ACCOUNTS_ALL RMA,
           JL_BR_AR_SELECT_ACCOUNTS_ALL CSC,
           JL_BR_AR_REC_MET_ACCTS_EXT_ALL JLBRRMA,
           JL_BR_AR_BANK_OCCURRENCES jlbo,
           CE_BANK_ACCOUNTS CeBankAccount,
           CE_BANK_ACCT_USES_ALL CeBankAcctUse,
           HZ_PARTIES  HzPartyBank
    Where  b.bank_acct_use_id = CeBankAcctUse.bank_acct_use_id
           And CeBankAccount.bank_account_id = CeBankAcctUse.bank_account_id
           And CeBankAccount.BANK_ID =  HzPartyBank.PARTY_ID
           --And HzPartyBank.COUNTRY = 'BR'
           And DC.PAYMENT_SCHEDULE_ID = PS.PAYMENT_SCHEDULE_ID
           And PS.STATUS              = 'OP'
           And B.BORDERO_STATUS       = 'SELECTED'
           And DC.DOCUMENT_STATUS     = 'SELECTED'
           And B.BORDERO_ID           = DC.BORDERO_ID
           And DC.BORDERO_ID          = P_BORDERO_ID
           And CSC.SELECT_ACCOUNT_ID     = B.SELECT_ACCOUNT_ID
           And JLBRRMA.RECEIPT_METHOD_ID = DC.RECEIPT_METHOD_ID
           And JLBRRMA.BANK_ACCT_USE_ID  = B.BANK_ACCT_USE_ID
           And RMA.RECEIPT_METHOD_ID     = DC.RECEIPT_METHOD_ID
           And RMA.REMIT_BANK_ACCT_USE_ID = B.BANK_ACCT_USE_ID
           And jlbo.BANK_PARTY_ID      = HzPartyBank.party_id
           And jlbo.STD_OCCURRENCE_CODE = 'REMITTANCE'
           And jlbo.BANK_OCCURRENCE_TYPE = 'REMITTANCE_OCCURRENCE';


    CURSOR_PS    PS%rowtype;
    l_ps_rec     ar_payment_schedules%rowtype;

begin
  --mo_global.set_policy_context('S',3812);
  select org_id into l_org_id from jl_br_ar_borderos_all
  where bordero_id = p_bordero_id;
  mo_global.set_policy_context('S',l_org_id);
  P_PROC_STATUS := 0;
  SELECT g.set_of_books_id, g.currency_code
  INTO l_set_of_books_id, l_currency_code
  FROM gl_sets_of_books g, ar_system_parameters a
  where g.set_of_books_id = a.set_of_books_id
    and rownum=1;


  OPEN check1;
  LOOP
    FETCH check1 INTO var_bordero_status_chk, var_selection_control,var_bordero_type;
    EXIT WHEN check1%NOTFOUND;

    OPEN check2;
    LOOP
      FETCH check2 INTO var_selection_control_chk;
      EXIT WHEN check2%NOTFOUND;

      IF var_bordero_type = 'COLLECTION' THEN
        open PS;
        loop
          fetch PS into CURSOR_PS;
          exit when PS%notfound;

        /* Generate remittance occurrence to the document */

          -- SLA Uptake - Bug#4301543
          select JL_BR_AR_OCCURRENCE_DOCS_S.NEXTVAL
            into l_occurrence_id
            from dual;

        -- CE uptake - Bug#2932986
          insert into JL_BR_AR_OCCURRENCE_DOCS_ALL
                   (OCCURRENCE_ID,
                    DOCUMENT_ID,
                    BANK_OCCURRENCE_CODE,
                    --BANK_NUMBER,
                    BANK_PARTY_ID,
                    BANK_OCCURRENCE_TYPE,
                    OCCURRENCE_DATE,
                    OCCURRENCE_STATUS,
                    ORIGINAL_REMITTANCE_MEDIA,
                    REMITTANCE_MEDIA,
                    SELECTION_DATE,
                    BORDERO_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CREATION_DATE,
                    CREATED_BY,
                    PORTFOLIO_CODE,
                    TRADE_NOTE_NUMBER,
                    DUE_DATE,
                    DOCUMENT_AMOUNT,
                    BANK_INSTRUCTION_CODE1,
                    BANK_INSTRUCTION_CODE2,
                    NUM_DAYS_INSTRUCTION,
                    INTEREST_PERCENT,
                    INTEREST_PERIOD,
                    INTEREST_AMOUNT,
                    GRACE_DAYS,
                    DISCOUNT_LIMIT_DATE,
                    DISCOUNT_AMOUNT,
                    CUSTOMER_ID,
                    SITE_USE_ID,
                    ABATEMENT_AMOUNT,
                    FLAG_POST_GL,
                    GL_DATE,
                    ENDORSEMENT_CREDIT_CCID,
                    ENDORSEMENT_DEBIT_CCID,
                    ENDORSEMENT_DEBIT_AMOUNT,
                    ENDORSEMENT_CREDIT_AMOUNT,
                    BANK_CHARGES_CREDIT_CCID,
                    BANK_CHARGES_DEBIT_CCID,
                    BANK_CHARGES_DEBIT_AMOUNT,
                    BANK_CHARGES_CREDIT_AMOUNT,
                    ORG_ID)
            select
                    l_occurrence_id,              -- SLA Uptake - Bug#4301543
                    CURSOR_PS.DOCUMENT_ID,
                    CURSOR_PS.BANK_OCCURRENCE_CODE,
                    --CURSOR_PS.BANK_NUMBER,
                    CURSOR_PS.BANK_PARTY_ID,
                    CURSOR_PS.BANK_OCCURRENCE_TYPE,
                    SYSDATE,
                    'CONFIRMED',
                    CURSOR_PS.OUTPUT_FORMAT,
                    CURSOR_PS.OUTPUT_FORMAT,
                    null,
                    P_BORDERO_ID,
                    SYSDATE,
                    P_USER_ID,
                    P_USER_ID,
                    SYSDATE,
                    P_USER_ID,
                    CURSOR_PS.PORTFOLIO_CODE,
                    CURSOR_PS.GLOBAL_ATTRIBUTE10,
                    CURSOR_PS.DUE_DATE,
                    CURSOR_PS.AMOUNT_DUE_REMAINING,
                    CURSOR_PS.BANK_INSTRUCTION_CODE1,
                    CURSOR_PS.BANK_INSTRUCTION_CODE2,
                    CURSOR_PS.NUM_DAYS_INSTRUCTION,
                    fnd_number.canonical_to_number(nvl(CT.GLOBAL_ATTRIBUTE2,'')), /* Bug 2724399 */
                    nvl(CT.GLOBAL_ATTRIBUTE3,''),
                    fnd_number.canonical_to_number(nvl(CT.GLOBAL_ATTRIBUTE2,'')), /* Bug 2724399 */
                     nvl(CT.GLOBAL_ATTRIBUTE5,''),
                    nvl(T.DISCOUNT_DAYS,0) + CURSOR_PS.DUE_DATE,
                    nvl(CURSOR_PS.FACTORING_AMOUNT,0),
                    CT.BILL_TO_CUSTOMER_ID,
                    CT.BILL_TO_SITE_USE_ID,
                    0,
                    'N',
                    CURSOR_PS.GL_DATE,
                    CURSOR_PS.COLL_ENDORSEMENT_CCID,
                    CURSOR_PS.BILLS_COLLECTION_CCID,
                    CURSOR_PS.AMOUNT_DUE_REMAINING,
                    CURSOR_PS.AMOUNT_DUE_REMAINING,
                    decode(CURSOR_PS.BANK_CHARGE_AMOUNT,'','',0,'', CURSOR_PS.CASH_CCID),
                    decode(CURSOR_PS.BANK_CHARGE_AMOUNT,'','',0,'',CURSOR_PS.BANK_CHARGES_CCID),
                    CURSOR_PS.BANK_CHARGE_AMOUNT,
                    CURSOR_PS.BANK_CHARGE_AMOUNT,
                    CURSOR_PS.org_id
            from    RA_CUSTOMER_TRX CT, RA_TERMS_LINES_DISCOUNTS T,
                    AR_PAYMENT_SCHEDULES_ALL PS
            where   CT.CUSTOMER_TRX_ID   =  PS.CUSTOMER_TRX_ID
            and     T.TERM_ID(+)         =  PS.TERM_ID
            and     T.SEQUENCE_NUM(+)    =  PS.TERMS_SEQUENCE_NUMBER
            and     PS.PAYMENT_SCHEDULE_ID = CURSOR_PS.PAYMENT_SCHEDULE_ID;
--commented below code for bug 9468277.
  /*      select occurrence_id into l_occ from jl_br_ar_occurrence_docs_all
        where document_id = cursor_ps.document_id; */

          -- SLA Uptake - Bug#4301543
          JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists (
                         p_event_type_code       => 'REMIT_COLL_DOC'               ,
                         p_event_date            => SYSDATE                        ,
                         p_document_id           => CURSOR_PS.DOCUMENT_ID          ,
                         p_gl_date               => CURSOR_PS.GL_DATE              ,
                         p_occurrence_id         => l_occurrence_id                ,
                         p_bank_occurrence_type  => CURSOR_PS.BANK_OCCURRENCE_TYPE ,
                         p_bank_occurrence_code  => CURSOR_PS.BANK_OCCURRENCE_CODE ,
                         p_std_occurrence_code   => 'REMITTANCE'                   ,
                         p_bordero_type          => var_bordero_type               ,
                         p_endorsement_amt       => CURSOR_PS.AMOUNT_DUE_REMAINING ,
                         p_bank_charges_amt      => CURSOR_PS.BANK_CHARGE_AMOUNT   ,
                         p_factoring_charges_amt => NULL                           ,
                         p_event_id              => l_event_id
                        );

             UPDATE JL_BR_AR_OCCURRENCE_DOCS_ALL
                SET event_id =l_event_id
              WHERE occurrence_id = l_occurrence_id;
          -- End SLA Uptake - Bug#4301543

        /* Update collection flag to WRITE_OFF */
/*        update AR_PAYMENT_SCHEDULES
        set    GLOBAL_ATTRIBUTE11 = 'Y',
               GLOBAL_ATTRIBUTE9 = 'BANK'
        where  PAYMENT_SCHEDULE_ID = CURSOR_PS.PAYMENT_SCHEDULE_ID;
*/
        mo_global.set_policy_context('S',cursor_ps.org_id);
       begin
        arp_ps_pkg.fetch_p(CURSOR_PS.PAYMENT_SCHEDULE_ID, l_ps_rec);
        arp_ps_pkg.lock_p(CURSOR_PS.PAYMENT_SCHEDULE_ID);
        l_ps_rec.GLOBAL_ATTRIBUTE11 := 'Y';
        l_ps_rec.GLOBAL_ATTRIBUTE9  := 'BANK';
        arp_ps_pkg.update_p(l_ps_rec, CURSOR_PS.PAYMENT_SCHEDULE_ID);
       exception
         when others then
         null;
       end;

        /* Update status to FORMATTED and update bank accounts */
        update JL_BR_AR_COLLECTION_DOCS_ALL
        set DOCUMENT_STATUS = 'FORMATTED',
            CASH_CCID = cursor_ps.CASH_CCID,
            BANK_CHARGES_CCID = cursor_ps.BANK_CHARGES_CCID,
            COLL_ENDORSEMENTS_CCID = cursor_ps.COLL_ENDORSEMENT_CCID,
            BILLS_COLLECTION_CCID = cursor_ps.BILLS_COLLECTION_CCID,
            CALCULATED_INTEREST_CCID = cursor_ps.CALCULATED_INTEREST_CCID,
            INTEREST_WRITEOFF_CCID = cursor_ps.INTEREST_WRITEOFF_CCID,
            ABATEMENT_WRITEOFF_CCID = cursor_ps.ABATEMENT_WRITEOFF_CCID,
            ABATEMENT_REVENUE_CCID = cursor_ps.ABATEMENT_REVENUE_CCID,
            INTEREST_REVENUE_CCID = cursor_ps.INTEREST_REVENUE_CCID,
            CALCULATED_INTEREST_RECTRX_ID = cursor_ps.CALCULATED_INTEREST_RECTRX_ID,
            INTEREST_WRITEOFF_RECTRX_ID = cursor_ps.INTEREST_WRITEOFF_RECTRX_ID,
            INTEREST_REVENUE_RECTRX_ID = cursor_ps.INTEREST_REVENUE_RECTRX_ID,
            ABATEMENT_WRITEOFF_RECTRX_ID = cursor_ps.ABATEMENT_WRITEOFF_RECTRX_ID,
            ABATE_REVENUE_RECTRX_ID       = cursor_ps.ABATEMENT_REVENUE_RECTRX_ID
        where  DOCUMENT_ID = CURSOR_PS.DOCUMENT_ID;

      end loop;
      close PS;
      ELSIF var_bordero_type = 'FACTORING' THEN -- Change made for factoring remittance batch
        open PS;
        LOOP
        FETCH PS into CURSOR_PS;
        exit when PS%notfound;

          Ar_receipt_api_pub.create_cash
        ( p_api_version => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_currency_code => l_currency_code,
          p_amount => cursor_ps.amount_due_remaining,
          p_receipt_number => cursor_ps.document_id,
          p_receipt_date => sysdate,
          p_gl_date => sysdate,
          p_customer_id => cursor_ps.customer_id,
          p_remittance_bank_account_id => cursor_ps.bank_account_id,
          p_receipt_method_id => cursor_ps.receipt_method_id,
          p_called_from => 'JLBRRATB',
          p_cr_id => x_cash_receipt_id);

fnd_file.put_line(FND_FILE.lOG,'After creating the receipt'||to_char(x_cash_receipt_id)||'return status'||l_return_status||'message '||l_msg_data||'message count'||to_char(l_msg_count));
          /* Generate remittance occurrence to the document */
          LOOP

            l_mesg := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
            IF  l_mesg IS NULL THEN
              EXIT;
            ELSE
              fnd_file.put_line(FND_FILE.lOG,'After creating the receipt'||to_char(x_cash_receipt_id)||'return status'||l_return_status||'message count'||to_char(l_msg_count)||'message '||l_mesg);
            END IF;

          END LOOP;

          -- SLA Uptake - Bug#4301543
          select JL_BR_AR_OCCURRENCE_DOCS_S.NEXTVAL
            into l_occurrence_id
            from dual;


          INSERT INTO JL_BR_AR_OCCURRENCE_DOCS_ALL
                   (OCCURRENCE_ID,
                    DOCUMENT_ID,
                    BANK_OCCURRENCE_CODE,
                    --BANK_NUMBER,
                    BANK_PARTY_ID,
                    BANK_OCCURRENCE_TYPE,
                    OCCURRENCE_DATE,
                    OCCURRENCE_STATUS,
                    ORIGINAL_REMITTANCE_MEDIA,
                    REMITTANCE_MEDIA,
                    SELECTION_DATE,
                    BORDERO_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CREATION_DATE,
                    CREATED_BY,
                    PORTFOLIO_CODE,
                    TRADE_NOTE_NUMBER,
                    DUE_DATE,
                    DOCUMENT_AMOUNT,
                    BANK_INSTRUCTION_CODE1,
                    BANK_INSTRUCTION_CODE2,
                    NUM_DAYS_INSTRUCTION,
                    INTEREST_PERCENT,
                    INTEREST_PERIOD,
                    INTEREST_AMOUNT,
                    GRACE_DAYS,
                    DISCOUNT_LIMIT_DATE,
                    DISCOUNT_AMOUNT,
                    CUSTOMER_ID,
                    SITE_USE_ID,
                    ABATEMENT_AMOUNT,
                    FLAG_POST_GL,
                    GL_DATE,
                    ENDORSEMENT_CREDIT_CCID,
                    ENDORSEMENT_DEBIT_CCID,
                    ENDORSEMENT_DEBIT_AMOUNT,
                    ENDORSEMENT_CREDIT_AMOUNT,
                    BANK_CHARGES_CREDIT_CCID,
                    BANK_CHARGES_DEBIT_CCID,
                    BANK_CHARGES_DEBIT_AMOUNT,
                    BANK_CHARGES_CREDIT_AMOUNT,
                    FACTOR_INTEREST_CREDIT_CCID,
                    FACTOR_INTEREST_DEBIT_CCID,
                    FACTOR_INTEREST_DEBIT_AMOUNT,
                    FACTOR_INTEREST_CREDIT_AMOUNT,
					ORG_ID)
            select
                    l_occurrence_id,              -- SLA Uptake - Bug#4301543
                    CURSOR_PS.DOCUMENT_ID,
                    CURSOR_PS.BANK_OCCURRENCE_CODE,
                    --CURSOR_PS.BANK_NUMBER,
                    CURSOR_PS.BANK_PARTY_ID,
                    CURSOR_PS.BANK_OCCURRENCE_TYPE,
                    SYSDATE,
                    'CONFIRMED',
                    CURSOR_PS.OUTPUT_FORMAT,
                    CURSOR_PS.OUTPUT_FORMAT,
                    null,
                    P_BORDERO_ID,
                    SYSDATE,
                    P_USER_ID,
                    P_USER_ID,
                    SYSDATE,
                    P_USER_ID,
                    CURSOR_PS.PORTFOLIO_CODE,
                    CURSOR_PS.GLOBAL_ATTRIBUTE10,
                    CURSOR_PS.DUE_DATE,
                    CURSOR_PS.AMOUNT_DUE_REMAINING,
                    CURSOR_PS.BANK_INSTRUCTION_CODE1,
                    CURSOR_PS.BANK_INSTRUCTION_CODE2,
                    CURSOR_PS.NUM_DAYS_INSTRUCTION,
                    fnd_number.canonical_to_number(nvl(CT.GLOBAL_ATTRIBUTE2,'')),  -- Bug 3107496
                    nvl(CT.GLOBAL_ATTRIBUTE3,''),
                    fnd_number.canonical_to_number(nvl(CT.GLOBAL_ATTRIBUTE2,'')),  -- Bug 3107496
                     nvl(CT.GLOBAL_ATTRIBUTE5,''),
                    nvl(T.DISCOUNT_DAYS,0) + CURSOR_PS.DUE_DATE,
                    nvl(CURSOR_PS.FACTORING_AMOUNT,0),
                    CT.BILL_TO_CUSTOMER_ID,
                    CT.BILL_TO_SITE_USE_ID,
                    0,
                    'N',
                    CURSOR_PS.GL_DATE,
				 --	Bug#8302889 in factoring
                 -- CURSOR_PS.BILLS_DISCOUNT_CCID,
                    CURSOR_PS.DISC_ENDORSEMENT_CCID,
					CURSOR_PS.BILLS_DISCOUNT_CCID,
                    CURSOR_PS.AMOUNT_DUE_REMAINING,
                    CURSOR_PS.AMOUNT_DUE_REMAINING,
                    decode(CURSOR_PS.BANK_CHARGE_AMOUNT,'','',0,'', CURSOR_PS.CASH_CCID),
                    decode(CURSOR_PS.BANK_CHARGE_AMOUNT,'','',0,'',CURSOR_PS.BANK_CHARGES_CCID),
					CURSOR_PS.BANK_CHARGE_AMOUNT,
                    CURSOR_PS.BANK_CHARGE_AMOUNT,
                    decode(CURSOR_PS.FACTORING_AMOUNT,'','',0,'', CURSOR_PS.CASH_CCID),
                    decode(CURSOR_PS.FACTORING_AMOUNT,'','',0,'',CURSOR_PS.FACTORING_INTEREST_CCID),
                    CURSOR_PS.FACTORING_AMOUNT,
                    CURSOR_PS.FACTORING_AMOUNT,
                    CURSOR_PS.ORG_ID
            from    RA_CUSTOMER_TRX CT, RA_TERMS_LINES_DISCOUNTS T,
                    AR_PAYMENT_SCHEDULES PS
            where   CT.CUSTOMER_TRX_ID   =  PS.CUSTOMER_TRX_ID
            and     T.TERM_ID(+)         =  PS.TERM_ID
            and     T.SEQUENCE_NUM(+)    =  PS.TERMS_SEQUENCE_NUMBER
            and     PS.PAYMENT_SCHEDULE_ID = CURSOR_PS.PAYMENT_SCHEDULE_ID;

          -- SLA Uptake - Bug#4301543
          JL_BR_AR_BANK_ACCT_PKG.Create_Event_Dists (
                         p_event_type_code       => 'REMIT_FACT_DOC'               ,
                         p_event_date            => SYSDATE                        ,
                         p_document_id           => CURSOR_PS.DOCUMENT_ID          ,
                         p_gl_date               => CURSOR_PS.GL_DATE              ,
                         p_occurrence_id         => l_occurrence_id                ,
                         p_bank_occurrence_type  => CURSOR_PS.BANK_OCCURRENCE_TYPE ,
                         p_bank_occurrence_code  => CURSOR_PS.BANK_OCCURRENCE_CODE ,
                         p_std_occurrence_code   => 'REMITTANCE'                   ,
                         p_bordero_type          => var_bordero_type               ,
                         p_endorsement_amt       => CURSOR_PS.AMOUNT_DUE_REMAINING ,
                         p_bank_charges_amt      => CURSOR_PS.BANK_CHARGE_AMOUNT   ,
                         p_factoring_charges_amt => CURSOR_PS.FACTORING_AMOUNT     ,
                         p_event_id              => l_event_id
                        );

             UPDATE JL_BR_AR_OCCURRENCE_DOCS_ALL
                SET event_id =l_event_id
              WHERE occurrence_id = l_occurrence_id;
          -- End SLA Uptake - Bug#4301543

            arp_ps_pkg.fetch_p(CURSOR_PS.PAYMENT_SCHEDULE_ID, l_ps_rec);
            arp_ps_pkg.lock_p(CURSOR_PS.PAYMENT_SCHEDULE_ID);
            l_ps_rec.GLOBAL_ATTRIBUTE11 := 'Y';
            l_ps_rec.GLOBAL_ATTRIBUTE9  := 'BANK';
            arp_ps_pkg.update_p(l_ps_rec, CURSOR_PS.PAYMENT_SCHEDULE_ID);

        /* Update status to FORMATTED and update bank accounts */
           update JL_BR_AR_COLLECTION_DOCS_ALL
           set DOCUMENT_STATUS = 'FORMATTED',
             CASH_CCID = cursor_ps.CASH_CCID,
             BANK_CHARGES_CCID = cursor_ps.BANK_CHARGES_CCID,
             COLL_ENDORSEMENTS_CCID = cursor_ps.DISC_ENDORSEMENT_CCID,
             BILLS_COLLECTION_CCID = cursor_ps.BILLS_DISCOUNT_CCID,
             CALCULATED_INTEREST_CCID = cursor_ps.CALCULATED_INTEREST_CCID,
             INTEREST_WRITEOFF_CCID = cursor_ps.INTEREST_WRITEOFF_CCID,
             ABATEMENT_WRITEOFF_CCID = cursor_ps.ABATEMENT_WRITEOFF_CCID,
             ABATEMENT_REVENUE_CCID = cursor_ps.ABATEMENT_REVENUE_CCID,
             INTEREST_REVENUE_CCID = cursor_ps.INTEREST_REVENUE_CCID,
             CALCULATED_INTEREST_RECTRX_ID = cursor_ps.CALCULATED_INTEREST_RECTRX_ID,
             INTEREST_WRITEOFF_RECTRX_ID = cursor_ps.INTEREST_WRITEOFF_RECTRX_ID,            INTEREST_REVENUE_RECTRX_ID = cursor_ps.INTEREST_REVENUE_RECTRX_ID,
             ABATEMENT_WRITEOFF_RECTRX_ID = cursor_ps.ABATEMENT_WRITEOFF_RECTRX_ID,
             ABATE_REVENUE_RECTRX_ID       = cursor_ps.ABATEMENT_REVENUE_RECTRX_ID,
             CASH_RECEIPT_ID = x_cash_receipt_id
           where  DOCUMENT_ID = CURSOR_PS.DOCUMENT_ID;

      END LOOP;
      Close PS;
     END IF;

      select CS.SELECTION_STATUS,
             B.SELECTION_CONTROL_ID,
             B.SELECT_ACCOUNT_ID
      into   PL_CS_SELECTION_STATUS,
    	     PL_SELECTION_CONTROL_ID,
             PL_SELECT_ACCOUNT_ID
      from   JL_BR_AR_SELECT_CONTROLS_ALL CS,
             JL_BR_AR_BORDEROS B
      where  CS.SELECTION_CONTROL_ID = B.SELECTION_CONTROL_ID
      and    B.BORDERO_ID = P_BORDERO_ID;

      if PL_CS_SELECTION_STATUS = 'SELECTED'
      then
        /* Update status to FORMATTED */
        update JL_BR_AR_SELECT_CONTROLS
        set    SELECTION_STATUS = 'FORMATTED',
               REMITTANCE_DATE     = SYSDATE
        where  SELECTION_CONTROL_ID = PL_SELECTION_CONTROL_ID;
        update JL_BR_AR_SELECT_ACCOUNTS
        set    FORMAT_DATE= SYSDATE,
               REMITTANCE_DATE = SYSDATE
        where  SELECT_ACCOUNT_ID = PL_SELECT_ACCOUNT_ID;
      else
        /* Update remittance date */
        update JL_BR_AR_SELECT_CONTROLS
        set    REMITTANCE_DATE     = SYSDATE
        where  SELECTION_CONTROL_ID = PL_SELECTION_CONTROL_ID;
        update JL_BR_AR_SELECT_ACCOUNTS
        set    REMITTANCE_DATE =  SYSDATE
        where  SELECT_ACCOUNT_ID = PL_SELECT_ACCOUNT_ID;
      end if;

        /* Update status to FORMATTED */
      update JL_BR_AR_BORDEROS
      set    BORDERO_STATUS = 'FORMATTED',
    	 REMITTANCE_DATE   = SYSDATE
      where  BORDERO_ID = P_BORDERO_ID;

   BEGIN
      insert into JL_BR_AR_REMIT_BORDEROS_ALL
         (FORMAT_REQUEST_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY,
          BORDERO_ID,
          OUTPUT_PROGRAM_ID,
		  ORG_ID)
      select
          fnd_global.conc_request_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id,
          sysdate,
          fnd_global.user_id,
          bordero_id,
          output_program_id,
          org_id
      from jl_br_ar_borderos_all
      where bordero_id = P_BORDERO_ID;
   EXCEPTION
       WHEN OTHERS THEN
       null;
   end;


      P_PROC_STATUS := 1;
    END LOOP;
    CLOSE check2;

  END LOOP;
  CLOSE check1;
  COMMIT;

END remit_collection;


PROCEDURE remit_occurrence (P_BORDERO_ID  IN     NUMBER,
                            P_PROC_STATUS IN OUT NOCOPY NUMBER) is
  PL_SELECTION_CONTROL_ID   number;
  PL_SELECT_ACCOUNT_ID      number;
  PL_CS_SELECTION_STATUS    varchar2(30);
  var_bordero_status_chk    VARCHAR2(30);
  var_selection_control     NUMBER;
  var_selection_control_chk NUMBER;

  CURSOR  check1 IS
          SELECT  bordero_status, selection_control_id
          FROM    jl_br_ar_borderos_all
          WHERE   bordero_id = P_BORDERO_ID
                  AND bordero_status in ('SELECTED', 'FORMATTED')
          FOR UPDATE NOWAIT;

  CURSOR  check2 IS
          SELECT  selection_control_id
          FROM    jl_br_ar_select_controls_all
          WHERE   selection_control_id = var_selection_control
          FOR UPDATE;

  /* This cursor is used to read documents from Borderos that
	was not formated */
  cursor OC is
    select OD.OCCURRENCE_ID, BO.STD_OCCURRENCE_CODE, OD.DOCUMENT_ID
    from   JL_BR_AR_OCCURRENCE_DOCS_ALL OD,
           JL_BR_AR_BORDEROS B,
           JL_BR_AR_BANK_OCCURRENCES BO
    where  OD.OCCURRENCE_STATUS = 'SELECTED'
    and    B.BORDERO_STATUS = 'SELECTED'
    and    B.BORDERO_ID = OD.BORDERO_ID
    and    OD.BORDERO_ID = P_BORDERO_ID
    and    BO.BANK_OCCURRENCE_CODE = OD.BANK_OCCURRENCE_CODE
    --and  BO.BANK_NUMBER = OD.BANK_NUMBER;
    and    BO.BANK_PARTY_ID = OD.BANK_PARTY_ID;

    l_ps_id       ar_payment_schedules.payment_schedule_id%TYPE;
    l_ps_rec      ar_payment_schedules%ROWTYPE;
begin
  P_PROC_STATUS := 0;
  OPEN check1;
  LOOP
    FETCH check1 INTO var_bordero_status_chk, var_selection_control;
    EXIT WHEN check1%NOTFOUND;

    OPEN check2;
    LOOP
      FETCH check2 INTO var_selection_control_chk;
      EXIT WHEN check2%NOTFOUND;

        for TMP in  OC loop
          /* Update occurrence  status to CONFIRMED */
          update JL_BR_AR_OCCURRENCE_DOCS_ALL
          set    OCCURRENCE_STATUS = 'CONFIRMED'
          where  OCCURRENCE_ID  = TMP.OCCURRENCE_ID;
          if TMP.STD_OCCURRENCE_CODE = 'PROTEST' then
/*            update AR_PAYMENT_SCHEDULES
            set GLOBAL_ATTRIBUTE9 = 'REGISTRY'
            where PAYMENT_SCHEDULE_ID = (select PAYMENT_SCHEDULE_ID
              from JL_BR_AR_COLLECTION_DOCS
              where DOCUMENT_ID = TMP.DOCUMENT_ID);
*/

/* Replace Update by AR's Table Handlers. Bug # 2249731  */
            SELECT payment_schedule_id
            INTO   l_ps_id
            FROM   jl_br_ar_collection_docs
            WHERE  document_id = TMP.DOCUMENT_ID;

            arp_ps_pkg.fetch_p(l_ps_id, l_ps_rec);
            arp_ps_pkg.lock_p(l_ps_id);
            l_ps_rec.GLOBAL_ATTRIBUTE9  := 'REGISTRY';
            arp_ps_pkg.update_p(l_ps_rec, l_ps_id);

          /* Following elsif added for Bug 865082 */
          elsif TMP.STD_OCCURRENCE_CODE = 'WRITE_OFF_REQUISITION' then
/*	    UPDATE ar_payment_schedules
	    SET	selected_for_receipt_batch_id = NULL,
		global_attribute9 = 'MANUAL_RECEIPT',
		global_attribute11 = 'N'
            where PAYMENT_SCHEDULE_ID = (select PAYMENT_SCHEDULE_ID
              from JL_BR_AR_COLLECTION_DOCS
              where DOCUMENT_ID = TMP.DOCUMENT_ID);
*/

/* Replace Update by AR's Table Handlers. Bug # 2249731  */

            SELECT payment_schedule_id
            INTO   l_ps_id
            FROM   jl_br_ar_collection_docs
            WHERE  document_id = TMP.DOCUMENT_ID;

            arp_ps_pkg.fetch_p(l_ps_id, l_ps_rec);
            arp_ps_pkg.lock_p(l_ps_id);
            l_ps_rec.selected_for_receipt_batch_id  := NULL;
            l_ps_rec.GLOBAL_ATTRIBUTE9  := 'MANUAL_RECEIPT';
            l_ps_rec.GLOBAL_ATTRIBUTE11  := 'N';
            arp_ps_pkg.update_p(l_ps_rec, l_ps_id);

          end if;
        end loop;
        select B.SELECTION_CONTROL_ID,
      	 B.SELECT_ACCOUNT_ID,
               CS.SELECTION_STATUS
        into   PL_SELECTION_CONTROL_ID,
      	       PL_SELECT_ACCOUNT_ID,
               PL_CS_SELECTION_STATUS
        from   JL_BR_AR_BORDEROS_ALL B, JL_BR_AR_SELECT_CONTROLS_ALL CS
        where  B.BORDERO_ID = P_BORDERO_ID
        and    CS.SELECTION_CONTROL_ID = B.SELECTION_CONTROL_ID;
        /* Update bordero status to FORMATTED */
        update JL_BR_AR_BORDEROS_ALL
        set    BORDERO_STATUS  = 'FORMATTED',
               REMITTANCE_DATE = SYSDATE
        where  BORDERO_ID = P_BORDERO_ID;

        if PL_CS_SELECTION_STATUS = 'SELECTED'
        then
        /* Update selection status to FORMATTED */
          update JL_BR_AR_SELECT_CONTROLS_ALL
          set    SELECTION_STATUS = 'FORMATTED',
                 GENERATION_DATE  = SYSDATE,
                 REMITTANCE_DATE  = SYSDATE
          where  SELECTION_CONTROL_ID = PL_SELECTION_CONTROL_ID;
          update JL_BR_AR_SELECT_ACCOUNTS
          set    FORMAT_DATE = SYSDATE,
                 REMITTANCE_DATE = SYSDATE
          where  SELECT_ACCOUNT_ID = PL_SELECT_ACCOUNT_ID;
        else
          /* Update remittance date */
          update JL_BR_AR_SELECT_CONTROLS_ALL
          set    REMITTANCE_DATE  = SYSDATE
          where  SELECTION_CONTROL_ID = PL_SELECTION_CONTROL_ID;
          update JL_BR_AR_SELECT_ACCOUNTS
          set    REMITTANCE_DATE = SYSDATE
          where  SELECT_ACCOUNT_ID = PL_SELECT_ACCOUNT_ID;
        end if;

        insert into JL_BR_AR_REMIT_BORDEROS_ALL
         (FORMAT_REQUEST_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY,
          BORDERO_ID,
          OUTPUT_PROGRAM_ID,
	  ORG_ID)
        select
          fnd_global.conc_request_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id,
          sysdate,
          fnd_global.user_id,
          bordero_id,
          output_program_id,
          mo_global.get_current_org_id
        from jl_br_ar_borderos
        where bordero_id = P_BORDERO_ID;


      P_PROC_STATUS := 1;
    END LOOP;
    CLOSE check2;

  END LOOP;
  CLOSE check1;
  COMMIT;

END remit_occurrence;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_acct_line_type_name                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This function is required to be called in occurrence view, where it     |
 |   passes the meaning of the lookup code which is passed as the parameter, |
 |   to the view column ACCT_LINE_TYPE_NAME which is required to be shown    |
 |   in SLA forms to name the account line.                                  |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |   none                                                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |   none                                                                    |
 |                                                                           |
 | USAGE NOTES:                                                              |
 |   Begin                                                                   |
 |     x := JL_BR_AR_REMIT_COLL_OCCUR.get_acct_line_type_name;               |
 |   End;                                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-Apr-00  Santosh Vaze          Created                              |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_acct_line_type_name(code VARCHAR2) RETURN VARCHAR2 IS
name		VARCHAR2(100);
BEGIN

  BEGIN
    SELECT meaning
    INTO   name
    FROM   fnd_lookups
    WHERE  lookup_code = code
    AND    lookup_type = 'JLBR_AR_SLA_ACCT_LINE_TYPE';
  EXCEPTION
    WHEN OTHERS THEN
           name := NULL;
  END;
  RETURN ( name );
END get_acct_line_type_name;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_trx_class_name                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This function is required to be called in bank transfer view, where it  |
 |   passes the meaning of the lookup code to the view column TRX_CLASS_NAME |
 |   which is required to be shown in SLA forms to name the transaction class|
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |   none                                                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |   none                                                                    |
 |                                                                           |
 | USAGE NOTES:                                                              |
 |   Begin                                                                   |
 |     x := JL_BR_AR_REMIT_COLL_OCCUR.get_trx_class_name;                    |
 |   End;                                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-Apr-00  Santosh Vaze          Created                              |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_trx_class_name(trx_class VARCHAR2) RETURN VARCHAR2 IS
name		VARCHAR2(100);
BEGIN

  BEGIN
    SELECT meaning
    INTO   name
    FROM   fnd_lookups
    WHERE  lookup_code = trx_class
    AND    lookup_type = 'JLBR_AR_SLA_TRX_CLASS';
  EXCEPTION
    WHEN OTHERS THEN
           name := NULL;
  END;
  RETURN ( name );
END get_trx_class_name;

END JL_BR_AR_REMIT_COLL_OCCUR;

/
