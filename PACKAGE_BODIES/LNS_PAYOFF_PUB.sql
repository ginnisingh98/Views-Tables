--------------------------------------------------------
--  DDL for Package Body LNS_PAYOFF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_PAYOFF_PUB" AS
/* $Header: LNS_PAYOFF_B.pls 120.5.12010000.2 2008/12/22 10:45:41 gparuchu ship $ */

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------
 G_DEBUG_COUNT                       NUMBER := 0;
 G_DEBUG                             BOOLEAN := FALSE;
 G_FILE_NAME   CONSTANT VARCHAR2(30) := 'LNS_PAYOFF_B.pls';

 G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'LNS_PAYOFF_PUB';

 --------------------------------------------
 -- internal package routines
 --------------------------------------------

procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin

    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

end;



/*=========================================================================
|| PUBLIC PROCEDURE processPayoff
||
|| DESCRIPTION
||
|| Overview:  this function will attempt to payoff the remaining invoices
||             on a given loan and create final invoices for the
||             remaining principal and any additional interest
||             and pay those off as well
||            if all goes right, then the loan_status will be set = 'PAIDOFF'
||
|| Parameter: p_loan_id = loan id
||            p_payoff_date = date loan will be paid off
||            p_cash_receipt_ids = table of receipts and amounts to payoff the loan
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value:
||
|| KNOWN ISSUES
||
|| NOTES
||      1. calculate the payoff as of p_payoff_date
||      2. create payoff document(s) in receivables
||      3. getLoanInvoices (should return newly created documents) (payoff_date = null)
||      4. check if sum of receipts covers the remaining loan amount
||      5. apply cash
||      6. if success then update loan_stats = 'PAIDOFF'
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10/06/2004 1:51PM     raverma           Created
 *=======================================================================*/
procedure processPayoff(p_api_version      IN NUMBER
                       ,p_init_msg_list    IN VARCHAR2
                       ,p_loan_id          in number
                       ,p_payoff_date      in date
                       ,p_cash_receipt_ids in LNS_PAYOFF_PUB.CASH_RECEIPT_TBL
                       ,x_return_status    OUT NOCOPY VARCHAR2
                       ,x_msg_count        OUT NOCOPY NUMBER
                       ,x_msg_data         OUT NOCOPY VARCHAR2)
is
    l_api_name                      varchar2(25);
    l_api_version_number            number;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_payoff_tbl2                   LNS_FINANCIALS.PAYOFF_TBL2;
    l_loan_details                  LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_invoices_tbl                  LNS_PAYOFF_PUB.INVOICE_DETAILS_TBL;
    l_cash_receipt_ids              LNS_PAYOFF_PUB.CASH_RECEIPT_TBL;
    l_add_cash_receipt_ids          LNS_PAYOFF_PUB.CASH_RECEIPT_TBL;  -- for unapplied crs on last interest document only
    l_bill_headers_tbl              LNS_BILLING_BATCH_PUB.BILL_HEADERS_TBL;  -- for invoice creation
    l_bill_lines_tbl                LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;    -- for invoice creation
    l_cm_line_tbl                   AR_CREDIT_MEMO_API_PUB.Cm_Line_Tbl_Type_Cover%type;
    l_total_payoff_amount           number;
    l_total_receipts_amount         number;
    l_object_version                number;
    l_amount_to_apply               number;
    i                               number;
    j                               number;
    s                               number;
    l_receipt_amount_remaining      number;
    l_invoice_amount_remaining      number;
    l_found                         varchar2(1);
    l_cash_receipts_count           number;
    l_rec_application_id            number;
    l_cash_receipt_id               number;
    l_customer_trx_id               number;
    l_interest_trx_id               number;
    l_principal_trx_id              number;
    l_fee_trx_id                    number;
    l_app_pay_sched_id              number;     -- applied payment_schedule_id
    l_amount_applied                number;
    l_currency_code                 varchar2(10);
    l_new_interest                  number;
    l_final_balance                 number;
    l_loan_currency                 varchar2(10);
    l_receipt_amount                number;  -- in loan currency
    l_receipt_number                varchar2(30);
    l_receipt_currency_orig         varchar2(30);
    l_rec_exchange_rate             number;       -- rac exchg
    l_rec_exchange_date             date;         -- rac exchg
    l_rec_exchange_rate_type        varchar2(30); -- rac exchg
    b_recalculate_interest          boolean;
    l_loan_exchange_rate            number;       -- loan exchg
    l_loan_exchange_date            date;         -- loan exchg
    l_loan_exchange_rate_type       varchar2(30); -- loan exchg
    l_phase                         varchar2(30);
    l_receipt_amount_from           number;  -- in receipt currency
    l_trans_to_receipt_rate         number;
    l_bool_match                    boolean;

    l_loan_header_rec               LNS_LOAN_HEADER_PUB.loan_header_rec_type;  -- to update the loan header

    cursor c_receipt_number(p_cash_receipt_id number) is
    select receipt_number, currency_code
      from ar_cash_receipts
     where cash_receipt_id = p_cash_receipt_id;

    cursor c_loans_obj_vers(p_loan_id number) is
    select OBJECT_VERSION_NUMBER
      from lns_loan_headers
     where loan_id = p_loan_id;

    CURSOR loans_cur (p_loan_id number) IS
        select
               head.Loan_currency
              ,nvl(head.exchange_rate, 1)
              ,head.exchange_date
              ,head.exchange_rate_type
              ,head.current_phase
          from LNS_LOAN_HEADERS head
        where  head.loan_id = p_loan_id and
               head.loan_status in ('ACTIVE', 'DELINQUENT', 'DEFAULT');

    -- this cursor retrieves any applications to
    -- final interest document INTEREST ONLY
    cursor c_applications(p_loan_id number) is
        select rap.receivable_application_id
              ,rap.cash_receipt_id
              ,rap.amount_applied       -- this is in loan / transacation currency
              ,trx.customer_trx_id
              ,trx.payment_schedule_id
              ,rac.receipt_number
              ,rac.currency_code
              ,rac.exchange_rate
              ,rac.exchange_date
              ,rac.exchange_rate_type
              ,lam.interest_trx_id      -- get this in order to create new interest document
              ,lam.principal_trx_id
              ,lam.fee_trx_id
          from ar_receivable_applications rap
              ,ar_cash_receipts           rac
              ,lns_amortization_scheds    lam
              ,ar_payment_schedules       trx
         where rap.cash_receipt_id = rac.cash_receipt_id
           and rap.applied_customer_trx_id = trx.customer_trx_id
           and trx.customer_trx_id = lam.interest_trx_id
           and lam.payment_number = LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id)
           and lam.reversed_flag = 'N'
           and lam.reamortization_amount is null
           and lam.parent_amortization_id is null
           and lam.loan_id = p_loan_id
           and rap.display = 'Y'
           and rap.status = 'APP';

      cursor c_fees(p_loan_id number)
      is
      select sched.fee_amount
             ,fees.fee_name
             ,sched.fee_installment
        from lns_fee_schedules sched
            ,lns_fees          fees
       where sched.loan_id = p_loan_id
         and sched.fee_id = fees.fee_id
         and sched.active_flag = 'Y'
         and sched.billed_flag = 'N';

       l_fee_amount      number;
       l_fee_name        varchar2(50);
       l_fee_installment number;
       l_sob_currency    varchar2(30);

    cursor c_sob_currency is
    SELECT sb.currency_code
      FROM lns_system_options so,
           gl_sets_of_books sb
     WHERE sb.set_of_books_id = so.set_of_books_id;

begin
    l_api_name           := 'processPayoff';
    l_api_version_number := 1;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Standard Start of API savepoint
    SAVEPOINT processPayoff;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    -- --------------------------------------------------------------------
    -- initialize any variables here
    l_cash_receipt_ids           := p_cash_receipt_ids;
    l_cash_receipts_count        := p_cash_receipt_ids.count;
    l_total_payoff_amount        := 0;
    l_total_receipts_amount      := 0;
    l_receipt_amount             := 0;
    l_amount_to_apply            := 0;
    l_new_interest               := 0;
    l_receipt_amount_remaining   := 0;
    l_invoice_amount_remaining   := 0;
    i                            := 0;
    s                            := 0;
    b_recalculate_interest       := true;
    l_final_balance              := -1;  --this is for final balance check

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - receipts passed ' || l_cash_receipts_count);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Payoff loanID ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Payoff date ' || p_payoff_date);
    open loans_cur(p_loan_id);
    fetch loans_cur into
            l_loan_currency
           ,l_loan_exchange_rate
           ,l_loan_exchange_date
           ,l_loan_exchange_rate_type
           ,l_phase;
    close loans_cur;

    open c_sob_currency;
    fetch c_sob_currency into l_sob_currency;
    close c_sob_currency;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - LOAN CURRENCY ' || l_loan_currency);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_exchange_rate ' || l_loan_exchange_rate);

/*
    -- if loan status is not valid, exit
    l_loan_details  := lns_financials.getLoanDetails(p_loan_id        => p_loan_id
                                                    ,p_based_on_terms => 'CURRENT'
                                                    ,p_phase          => l_phase);

    lns_financials.validatePayoff(p_loan_details   => l_loan_details
                                 ,p_payoff_date    => p_payoff_date
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => l_msg_count
                                 ,x_msg_data       => l_msg_data);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calculating Payoff ');
    lns_financials.calculatePayoff(p_api_version    => 1.0
                                  ,p_init_msg_list  => p_init_msg_list
                                  ,p_loan_id        => p_loan_id
                                  ,p_payoff_date    => p_payoff_date
                                  ,x_payoff_tbl     => l_payoff_tbl2
                                  ,x_return_status  => l_return_status
                                  ,x_msg_count      => l_msg_count
                                  ,x_msg_data       => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CALCULATE_PAYOFF_ERROR');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --2. create payoff document(s) in receivables
    -- build the header for the loan document(s) to be created
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Building Invoice header/lines');
    l_bill_headers_tbl(1).HEADER_ID := 101;
    l_bill_headers_tbl(1).LOAN_ID := p_loan_id;
    l_bill_headers_tbl(1).ASSOC_PAYMENT_NUM := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id);
    l_bill_headers_tbl(1).DUE_DATE := p_payoff_date;

    -- now build the lines for the loan document(s) to be created
    for i in 1..l_payoff_tbl2.count
    loop
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - purpose ' || l_payoff_tbl2(i).payoff_purpose);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - amount ' || l_payoff_tbl2(i).unbilled_amount);

      if l_payoff_tbl2(i).unbilled_amount > 0 and l_payoff_tbl2(i).payoff_purpose <> 'FEE' then
        s := s + 1;
        l_bill_lines_tbl(s).LINE_ID := i;
        l_bill_lines_tbl(s).HEADER_ID := 101;
        l_bill_lines_tbl(s).LINE_AMOUNT := l_payoff_tbl2(i).unbilled_amount;
        l_bill_lines_tbl(s).LINE_TYPE := l_payoff_tbl2(i).PAYOFF_PURPOSE;
        --l_BILL_LINES_TBL(1).LINE_DESC := 'Extra principal';

      elsif l_payoff_tbl2(i).unbilled_amount > 0 and l_payoff_tbl2(i).payoff_purpose = 'FEE' then

          open c_fees(p_loan_id);
          loop
            s := s + 1;
          fetch c_fees into
                l_fee_amount, l_fee_name, l_fee_installment;
          exit when c_fees%notfound;
                l_bill_lines_tbl(s).LINE_ID     := i;
                l_bill_lines_tbl(s).HEADER_ID   := 101;
                l_bill_lines_tbl(s).LINE_AMOUNT := l_fee_amount;
                l_bill_lines_tbl(s).LINE_TYPE   := l_payoff_tbl2(i).payoff_purpose;
                l_bill_lines_tbl(s).LINE_DESC   := l_fee_name;
                --l_invoices_tbl(i).INSTALLMENT_NUMBER := l_fee_installment;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - fee found');
           end loop;
           close c_fees;

      elsif l_payoff_tbl2(i).unbilled_amount < 0 and l_payoff_tbl2(i).payoff_purpose = 'INT' then

        -- we have an interest credit due we will credit out the interest on the last amortization
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - interest credit is due');
        -- 1. check to see if documents have been paid,
        --  unapply all cash from receivable applications
        open c_applications(p_loan_id);
        loop
        fetch c_applications
         into l_rec_application_id
             ,l_cash_receipt_id
             ,l_amount_applied
             ,l_customer_trx_id
             ,l_app_pay_sched_id
             ,l_receipt_number
             ,l_currency_code
             ,l_rec_exchange_rate
             ,l_rec_exchange_date
             ,l_rec_exchange_rate_type
             ,l_interest_trx_id
             ,l_principal_trx_id
             ,l_fee_trx_id;

        exit when c_applications%notfound;

            -- 2. if so, unapply all cash_receipts from document
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - unapplying cash from pay_sched_id: ' || l_rec_application_id);
            ar_receipt_api_pub.unapply(p_api_version               => 1.0
                                      ,p_init_msg_list             => p_init_msg_list
                                      ,p_commit                    => FND_API.G_FALSE
                                      ,p_receivable_application_id => l_rec_application_id
                                      ,x_return_status             => l_return_status
                                      ,x_msg_count                 => l_msg_count
                                      ,x_msg_data                  => l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                FND_MESSAGE.SET_NAME('LNS', 'LNS_UNAPPLY_CASH_ERROR');
                FND_MESSAGE.SET_TOKEN('PARAMETER', 'RECEIPT_NUMBER');
                FND_MESSAGE.SET_TOKEN('VALUE', l_receipt_number);
                FND_MSG_PUB.Add;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;


            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - unapplied cash successfully');
            -- 2a. keep unapplied cash_receipts in memory to use for payoff
            -- bug #4191794
            -- if this cash receipt_id exists in the set of selected cash receipts then
            -- we will have to add it back to existing cash_receipt_id
            l_bool_match := false;
            for j in 1..l_cash_receipt_ids.count loop
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - check existing cr_id: ' || l_cash_receipt_ids(j).cash_receipt_id);
                if l_cash_receipt_id = l_cash_receipt_ids(j).cash_receipt_id then
                    l_cash_receipt_ids(j).receipt_amount  := l_cash_receipt_ids(j).receipt_amount + l_amount_applied;
                    l_bool_match := true;
                    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - matched existing cr_id: ' || l_cash_receipt_ids(j).cash_receipt_id);
                    exit;
                end if;
            end loop;

            if not l_bool_match then
                    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - receipts count is: ' || l_cash_receipts_count);
                    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - adding applied cr_id: ' || l_cash_receipt_id);
                    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - cr_id amount: ' || l_amount_applied);
                    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - cr_id currency: ' || l_loan_currency);
                    l_cash_receipts_count := l_cash_receipts_count + 1;
                    l_cash_receipt_ids(l_cash_receipts_count).CASH_RECEIPT_ID  := l_cash_receipt_id;
                    l_cash_receipt_ids(l_cash_receipts_count).RECEIPT_AMOUNT   := l_amount_applied;
                    l_cash_receipt_ids(l_cash_receipts_count).RECEIPT_CURRENCY := l_loan_currency;

                    if l_currency_code <> l_loan_currency then
                         l_cash_receipt_ids(l_cash_receipts_count).EXCHANGE_RATE      := l_rec_exchange_rate;
                         l_cash_receipt_ids(l_cash_receipts_count).EXCHANGE_DATE      := l_rec_exchange_date;
                         l_cash_receipt_ids(l_cash_receipts_count).EXCHANGE_RATE_TYPE := l_rec_exchange_rate_type;
                    end if;
             end if;
             logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - added cash rec id ' || l_cash_receipt_id);
             logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - added cash amount ' || l_amount_applied || ' ' || l_currency_code);

        end loop; --end unapplication loop

        -- 3. credit document
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - crediting final interest document');
        /*=======================================================================*/
        LNS_BILLING_BATCH_PUB.CREDIT_AMORTIZATION_PARTIAL(P_API_VERSION       => 1.0
                                                         ,P_INIT_MSG_LIST     => p_init_msg_list
                                                         ,P_COMMIT            => FND_API.G_FALSE
                                                         ,P_VALIDATION_LEVEL  => FND_API.G_VALID_LEVEL_FULL
                                                         ,P_LOAN_ID           => p_loan_id
                                                         ,P_LINE_TYPE         => 'INT'
                                                         ,X_RETURN_STATUS     => l_return_status
                                                         ,X_MSG_COUNT         => l_msg_count
                                                         ,X_MSG_DATA          => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CREDIT_MEMO_ERROR');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        -- 4. create new interest and principal document for difference
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - RECALCULATING INTEREST');
        if b_recalculate_interest then
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - l_interest_trx_Id: ' || l_interest_trx_Id);
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - l_customer_trx_id: ' || l_customer_trx_id);

            if l_interest_trx_id = l_customer_trx_id then
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - RECALCULATED INTEREST DUE: ' || l_new_interest);

                -- over interest charge had previous applications
                select amount_due_original + l_payoff_tbl2(i).unbilled_amount
                  into l_new_interest
                  from ar_payment_schedules
                 where payment_schedule_id = l_app_pay_sched_id;

            else
                -- over interest charge had no previous applications
                select interest_amount + l_payoff_tbl2(i).unbilled_amount
                  into l_new_interest
                  from lns_amortization_scheds
                 where loan_id = p_loan_id
                   and reamortization_amount is null
                   and parent_amortization_id is null
                   --and reversed_flag = 'N'
                   and payment_number = LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id);

            end if;
            b_recalculate_interest := false;
        end if;

        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - RECALCULATED INTEREST DUE: ' || l_new_interest);

        -- we will only create a new interest document IF there is an interest amount due
        if l_new_interest > 0 then
            s := s + 1;
            l_bill_lines_tbl(s).LINE_ID := i;
            l_bill_lines_tbl(s).HEADER_ID := 101;
            l_bill_lines_tbl(s).LINE_AMOUNT := l_new_interest;
            l_bill_lines_tbl(s).LINE_TYPE := l_payoff_tbl2(i).PAYOFF_PURPOSE;
        end if;

      end if;

    end loop;

    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - billing lines' || l_bill_lines_tbl.count);
    if l_bill_lines_tbl.count >= 1 then

        -- we have at least 1 invoice to create with amount > 0
        -- must pass false for commit here or else payoff documents will exist in receivables
        lns_billing_batch_pub.create_offcycle_bills(p_api_version           => 1.0
                                                   ,p_init_msg_list         => p_init_msg_list
                                                   ,p_commit                => FND_API.G_FALSE
                                                   ,p_validation_level      => 100
                                                   ,p_bill_headers_tbl      => l_bill_headers_tbl
                                                   ,p_bill_lines_tbl        => l_bill_lines_tbl
                                                   ,x_return_status         => l_return_status
                                                   ,x_msg_count             => l_msg_count
                                                   ,x_msg_data              => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVOICE_CREATION_ERROR');
            FND_MSG_PUB.Add;
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

     end if;

    --3. getLoanInvoices (should return newly created documents)
    -- pass payoff_date = null to avoid recalculating payoff amounts
    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - getting loan invoices');
    lns_payoff_pub.getLoanInvoices(p_api_version    => 1
                                  ,p_init_msg_list  => p_init_msg_list
                                  ,p_loan_ID        => p_loan_id
                                  ,p_payoff_date    => null
                                  ,x_invoices_tbl   => l_invoices_tbl
                                  ,x_return_status  => l_return_status
                                  ,x_msg_count      => l_msg_count
                                  ,x_msg_data       => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVOICE_SUMMARY_ERROR');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - # of unpaid invoices to process = ' || l_invoices_tbl.count);

    --4. check if sum of receipts covers the remaining loan amount
    --   if we need to do multi-currency, the receipt amounts should be
    --   converted to loan_currency before making comparison
    -- check if any of the receipts have been applied to any of the invoices
    for k in 1..l_invoices_tbl.count
    loop
         l_total_payoff_amount := l_total_payoff_amount + l_invoices_tbl(k).REMAINING_AMOUNT;
    end loop;

    for j in 1..l_cash_receipt_ids.count
    loop

        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - receipt currency: ' || l_cash_receipt_ids(j).receipt_currency);
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - receipt amount: ' || l_cash_receipt_ids(j).receipt_amount);
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - xchg rate: ' || l_cash_receipt_ids(j).exchange_rate);

        open c_receipt_number(l_cash_receipt_ids(j).cash_receipt_id);
        fetch c_receipt_number into l_receipt_number, l_receipt_currency_orig;
        close c_receipt_number ;

        l_cash_receipt_ids(j).original_currency := l_receipt_currency_orig;
        l_cash_receipt_ids(j).receipt_number    := l_receipt_number;
        l_total_receipts_amount := l_total_receipts_amount + l_cash_receipt_ids(j).receipt_amount;

    end loop;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - cash receipts to process: ' || l_cash_receipt_ids.count);
    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - total receipts: ' || l_total_receipts_amount);
    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - total payoff amount: ' || l_total_payoff_amount);

    if l_total_receipts_amount < l_total_payoff_amount then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_PAYOFF_SHORT_CASH');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    --5. apply cash
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - step 5');
    for k in 1..l_invoices_tbl.count
    loop
        -- find the first cash receipt that has not been applied previously to the invoice
        -- if the amount of the receipt is > invoice then move on
        --  else find the next receipt that has not been applied previously to the invoice
        j := 1;
        l_invoice_amount_remaining := l_invoices_tbl(k).REMAINING_AMOUNT;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' --------- next invoice ----------');
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - payment_schedule_id: ' || l_invoices_tbl(k).payment_schedule_id );
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - invoice remaining amount: ' || l_invoices_tbl(k).REMAINING_AMOUNT);

        --l_receipt_amount_remaining := l_cash_receipt_ids(j).RECEIPT_AMOUNT;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - receipt amount: # ' || j || ' =' ||l_cash_receipt_ids(j).RECEIPT_AMOUNT);

        while l_invoices_tbl(k).REMAINING_AMOUNT > 0
        loop
            -- skip the receipts already exhausted
            loop
              exit when l_cash_receipt_ids(j).RECEIPT_AMOUNT > 0;
              j := j + 1;
            end loop;
            l_receipt_amount_remaining := l_cash_receipt_ids(j).RECEIPT_AMOUNT;
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - receipt amount remaining: ' || j || '# =' ||l_receipt_amount_remaining);

            Begin
             select 'X'
              into l_found
              from ar_receivable_applications rap
             where rap.cash_receipt_id = l_cash_receipt_ids(j).cash_receipt_id
               and rap.applied_payment_schedule_id = l_invoices_tbl(k).payment_schedule_id
               and rap.display = 'Y'
               and rap.status = 'APP';
             exception
                when no_data_found then
                  null;
                --when too_many_rows then
                --    FND_MESSAGE.set_name ('AR', 'AR_RW_PAID_INVOICE_TWICE' );
                --    APP_EXCEPTION.raise_exception;
            end;

            if l_found = 'X' then
                if j = l_cash_receipt_ids.count  then
                    -- we have gone thru all the cash receipts and there is not enough
                    -- open receipts in the list to cover this invoice
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_ALL_RECEIPTS_EXHAUSTED');
                    FND_MSG_PUB.Add;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                end if;

            else
                -- receipt has not been previously applied to invoice
                -- determine amount to apply
                if l_receipt_amount_remaining > l_invoice_amount_remaining then
                    l_amount_to_apply  := l_invoice_amount_remaining;
                else
                    l_amount_to_apply  := l_receipt_amount_remaining;
                end if;

                if l_cash_receipt_ids(j).original_currency = l_cash_receipt_ids(j).receipt_currency then
                            l_trans_to_receipt_rate := null;
                            l_receipt_amount_from  := null;
                else
                    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - receipt currency orig: ' || l_cash_receipt_ids(j).original_currency || ' receipt currency passed: ' || l_cash_receipt_ids(j).receipt_currency);
                    if l_cash_receipt_ids(j).exchange_rate is not null then
                        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - using receipt exchange rate ' || l_cash_receipt_ids(j).exchange_rate);
                        l_trans_to_receipt_rate := l_cash_receipt_ids(j).exchange_rate;
                    else
                        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - using loan exchange rate ' || l_loan_exchange_rate);
                        l_trans_to_receipt_rate := l_loan_exchange_rate;
                    end if;
                    l_receipt_amount_from := l_amount_to_apply * l_trans_to_receipt_rate;
                end if;

                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - applying cash : ' || l_amount_to_apply);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - applying cash from: ' || l_receipt_amount_from);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - exchange rate: ' || l_trans_to_receipt_rate);

                lns_payoff_pub.apply_receipt(p_cash_receipt_id        => l_cash_receipt_ids(j).CASH_RECEIPT_ID
                                            ,p_payment_schedule_id    => l_invoices_tbl(k).payment_schedule_id
                                            ,p_apply_amount           => l_amount_to_apply  -- in loan currency
                                            ,p_apply_date             => p_payoff_date
                                            ,p_apply_amount_from      => l_receipt_amount_from -- in receipt currency
                                            ,p_trans_to_receipt_rate  => l_trans_to_receipt_rate
                                            ,x_return_status          => l_return_status
                                            ,x_msg_count              => l_msg_count
                                            ,x_msg_data               => l_msg_data);

                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - apply cash status: ' || l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_APPLY_CASH_ERROR');
                    FND_MESSAGE.SET_TOKEN('PARAMETER', 'RECEIPT_NUMBER');
                    FND_MESSAGE.SET_TOKEN('VALUE', l_cash_receipt_ids(j).receipt_number);
                    FND_MSG_PUB.Add;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_invoice_amount_remaining           := l_invoice_amount_remaining - l_amount_to_apply;
                l_receipt_amount_remaining           := l_receipt_amount_remaining - l_amount_to_apply;
                l_invoices_tbl(k).REMAINING_AMOUNT   := l_invoices_tbl(k).REMAINING_AMOUNT - l_amount_to_apply;
                l_cash_receipt_ids(j).RECEIPT_AMOUNT := l_cash_receipt_ids(j).RECEIPT_AMOUNT - l_amount_to_apply;
                l_amount_to_apply := 0;

                l_found := null;
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_invoice_amount_remaining : ' || l_invoice_amount_remaining);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_receipt_amount_remaining : ' || l_receipt_amount_remaining);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_invoices_tbl(k).REMAINING_AMOUNT : ' || l_invoices_tbl(k).REMAINING_AMOUNT);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_cash_receipt_ids(j).RECEIPT_AMOUNT : ' || l_cash_receipt_ids(j).RECEIPT_AMOUNT);
            end if;
            j := j + 1;

        end loop;

    end loop;
    -- end of step 5

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calling LNS_BILLING_BATCH_PUB.processPaidLoans');
   LNS_BILLING_BATCH_PUB.PROCESS_PAID_LOANS(P_API_VERSION   => 1.0
                                           ,P_INIT_MSG_LIST => FND_API.G_FALSE
                                           ,P_COMMIT        => FND_API.G_FALSE
                                           ,P_VALIDATION_LEVEL => 100
                                           ,P_LOAN_ID       => p_loan_id
                                           ,P_PAYOFF_DATE   => p_payoff_date
                                           ,x_return_status => l_return_status
                                           ,x_msg_count     => l_msg_count
                                           ,x_msg_data      => l_msg_data);
   LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - LNS_BILLING_BATCH_PUB.processPaidLoans return status: ' || l_return_status);
   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            COMMIT WORK;
   else
            RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- one last check on the final balance before we mark the loan as
   -- PAID OFF
   /*
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - Getting final balance');
   begin
    -- changes as per scherkas 11-16-2005
    select total_principal_balance into  l_final_balance
      from LNS_PAYMENTS_SUMMARY_V
     where loan_id = p_loan_id;
    Exception
        when no_data_found then
            null;
   end;
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - final balance: ' || l_final_balance);

   if l_final_balance = 0 then
        open c_loans_obj_vers(p_loan_id);
        fetch c_loans_obj_vers into l_object_version;
        close c_loans_obj_vers;

        --6. if success then update loan_stats = 'PAIDOFF'
        --LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - get_object_version' || l_object_version);
        l_loan_header_rec.loan_id          := p_loan_id;
        l_loan_header_rec.LOAN_STATUS      := 'PAIDOFF';
        l_loan_header_rec.SECONDARY_STATUS := null;


        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - Updating loan header info w following values:');
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - LOAN_STATUS: ' || l_loan_header_rec.LOAN_STATUS);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - get_object_version' || l_object_version);
        --l_loan_header_rec.object_version := l_object_version;

        LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_object_version,
                                        P_LOAN_HEADER_REC       => l_loan_header_rec,
                                        P_INIT_MSG_LIST         => FND_API.G_FALSE,
                                        X_RETURN_STATUS         => l_return_status,
                                        X_MSG_COUNT             => l_msg_count,
                                        X_MSG_DATA              => l_msg_data);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPDATE_HEADER_ERROR');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

            update lns_fee_schedules
               set billed_flag = 'Y'
              where loan_id = p_loan_id
               and active_flag = 'Y'
               and billed_flag = 'N'
               and object_version_number = object_version_number + 1;

        Else
            --FND_MESSAGE.SET_NAME('LNS', 'LNS_PAYOFF_SUCCESS');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - updating fee assignments');
            -- end date the active fees on the loan as FDD section 4.1.3
            update lns_fee_assignments
               set end_date_active = p_payoff_date
             where loan_id = p_loan_id
               and (end_date_active is null OR end_date_active > p_payoff_date);

            COMMIT WORK;

        END IF;

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - header update status: ' || l_return_status);

   else
        FND_MESSAGE.SET_NAME('LNS', 'LNS_FINAL_BALANCE_ERROR');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
   end if;
*/
   -- ---------------------------------------------------------------------
   -- End of API body
   --

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO processPayoff;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO processPayoff;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO processPayoff;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end processPayoff;


/*=========================================================================
|| PUBLIC PROCEDURE getLoanInvoices
||
|| DESCRIPTION
||
|| Overview:  this function will return the invoices with a remaining balance
||               for the loan
||
|| Parameter: p_loan_id = loan id
||            p_payoff_date = include to be created payoff documents
||            x_invoices_tbl = table of invoices
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value:
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10/06/2004 1:51PM     raverma           Created
|| 1/28/2005             raverma           add late Fees processing
 *=======================================================================*/
procedure getLoanInvoices(p_api_version    IN NUMBER
                         ,p_init_msg_list  IN VARCHAR2
                         ,p_loan_id        in number
                         ,p_payoff_date    in date
                         ,x_invoices_tbl   OUT NOCOPY LNS_PAYOFF_PUB.INVOICE_DETAILS_TBL
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER
                         ,x_msg_data       OUT NOCOPY VARCHAR2)

is

    cursor c_loanInvoices(p_loan_id number)
    is
    select  ps.customer_trx_id
           ,payment_schedule_id
           ,payment_number
           ,trx_number
           ,tty.name
           ,amount_due_remaining
           ,am.due_date
           ,lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', decode(ps.customer_trx_id, principal_trx_Id, 'PRIN', interest_trx_id, 'INT', fee_trx_id, 'FEE')) line_type
      from lns_amortization_scheds am
          ,ar_payment_schedules ps
          ,ra_cust_trx_types tty
      where (am.principal_trx_id = ps.customer_trx_id OR
             am.interest_trx_id = ps.customer_trx_id OR
             am.fee_trx_id = ps.customer_trx_id)  and
         ps.cust_trx_type_id = tty.cust_trx_type_id and
         ps.amount_due_remaining > 0 and
         am.reamortization_amount is null and
         am.reversed_flag <> 'Y' and
         am.loan_id = p_loan_id
     order by payment_number, line_type;

     cursor c_loanInfo(p_loan_id number) is
     select loan_number
           ,LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id)
       from lns_loan_headers
      where loan_id = p_loan_id;

     cursor c_lastInterestAmount(p_loan_id number)
     is
     select interest_amount
       from lns_amortization_scheds
      where loan_id = p_loan_id
        and reversed_flag <> 'Y'
        and reamortization_amount is null
        and payment_number = LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id);

     cursor c_fees(p_loan_id number)
     is
     select sched.fee_amount
           ,fees.fee_name
           ,sched.fee_installment
       from lns_fee_schedules sched
           ,lns_fees          fees
      where sched.loan_id = p_loan_id
        and sched.fee_id = fees.fee_id
        and sched.active_flag = 'Y'
        and sched.billed_flag = 'N';

    l_api_name            varchar2(25);
    l_api_version_number  number;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(32767);

    l_invoices_tbl        LNS_PAYOFF_PUB.INVOICE_DETAILS_TBL;
    l_payoff_tbl2         LNS_FINANCIALS.PAYOFF_TBL2;
    i                     number;
    l_cust_trx_id         number;
    l_payment_schedule_id number;
    l_invoice_number      varchar2(60);
    l_installment         number;
    l_trans_type          varchar2(20);
    l_remaining_amt       number;
    l_due_date            date;
    l_purpose             varchar2(30);
    l_billed_flag         varchar2(1);
    l_document_type       varchar2(20);
    l_last_interest       number;
    l_credit_name         varchar2(30);
    l_fee_amount          number;
    l_fee_name            varchar2(50);
    l_fee_installment     number;

begin

    l_api_name           := 'getLoanInvoices';
    l_api_version_number := 1;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Standard Start of API savepoint
    SAVEPOINT getLoanInvoices;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    -- --------------------------------------------------------------------
    i := 0;

    open c_loanInvoices(p_loan_id);
    LOOP
        i := i + 1;
    FETCH c_loanInvoices INTO
             l_cust_trx_id
            ,l_payment_schedule_id
            ,l_installment
            ,l_invoice_number
            ,l_trans_type
            ,l_remaining_amt
            ,l_due_date
            ,l_purpose;

    EXIT WHEN c_loanInvoices%NOTFOUND;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - installment #: ' || l_installment);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_cust_trx_id: ' || l_cust_trx_id);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_remaining_amt: ' || l_remaining_amt);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_due_date: ' || l_due_date);
        l_invoices_tbl(i).CUST_TRX_ID        := l_cust_trx_id;
        l_invoices_tbl(i).PAYMENT_SCHEDULE_ID:= l_payment_schedule_id;
        l_invoices_tbl(i).INSTALLMENT_NUMBER := l_installment;
        l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
        l_invoices_tbl(i).TRANSACTION_TYPE   := l_trans_type;
        l_invoices_tbl(i).REMAINING_AMOUNT   := l_remaining_amt;
        l_invoices_tbl(i).DUE_DATE           := l_due_date;
        l_invoices_tbl(i).PURPOSE            := l_purpose;
        l_invoices_tbl(i).BILLED_FLAG        := 'Y';

    END LOOP;
    close c_loanInvoices;
    -- get the additional records "to be created"
    if p_payoff_date is not null then
         logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - getting addition TO BE CREATED documents');
         --dbms_output.put_line('calculating payoof amounts');
         lns_financials.calculatePayoff(p_api_version    => 1.0
                                       ,p_init_msg_list  => p_init_msg_list
                                       ,p_loan_id        => p_loan_id
                                       ,p_payoff_date    => p_payoff_date
                                       ,x_payoff_tbl     => l_payoff_tbl2
                                       ,x_return_status  => l_return_status
                                       ,x_msg_count      => l_msg_count
                                       ,x_msg_data       => l_msg_data);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            --FND_MESSAGE.SET_NAME('LNS', 'LNS_UPDATE_HEADER_ERROR');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;

          logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - payoff tbl count ' || l_payoff_tbl2.count);

          open c_loanInfo(p_loan_id);
          fetch c_loanInfo into l_invoice_number, l_installment;
          close c_loanInfo;

          for k in 1..l_payoff_tbl2.count
          loop

          logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || l_payoff_tbl2(k).payoff_purpose);
          logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || l_payoff_tbl2(k).unbilled_amount);

          i := l_invoices_tbl.count;
             if l_payoff_tbl2(k).unbilled_amount > 0 and l_payoff_tbl2(k).PAYOFF_PURPOSE <>  'FEE' then
                i := i + 1;
                l_invoices_tbl(i).CUST_TRX_ID        := null;
                l_invoices_tbl(i).INSTALLMENT_NUMBER := l_installment;
                l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
                l_invoices_tbl(i).TRANSACTION_TYPE   := lns_utility_pub.getDocumentName(l_payoff_tbl2(k).PAYOFF_PURPOSE);
                l_invoices_tbl(i).REMAINING_AMOUNT   := l_payoff_tbl2(k).unbilled_amount;
                l_invoices_tbl(i).DUE_DATE           := p_payoff_date;
                l_invoices_tbl(i).PURPOSE            := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', l_payoff_tbl2(k).PAYOFF_PURPOSE);
                l_invoices_tbl(i).BILLED_FLAG        := 'N';


              elsif l_payoff_tbl2(k).unbilled_amount < 0 and l_payoff_tbl2(k).PAYOFF_PURPOSE = 'INT' then

               logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - getting last interest documents ');
               i := l_invoices_tbl.count;
               -- find the last interest installment we will create a credit memo in that amount
                -- and we will create an invoice of INT type with
                open  c_lastInterestAmount(p_loan_id);
                fetch c_lastInterestAmount into l_last_interest;
                close c_lastInterestAmount;

                select meaning into l_credit_name
                from ar_lookups
                where lookup_type = 'INV/CM'
                  and lookup_code = 'CM';

                -- interest document (credit)
                i := i + 1;
                l_invoices_tbl(i).CUST_TRX_ID        := null;
                l_invoices_tbl(i).INSTALLMENT_NUMBER := l_installment;
                l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
                l_invoices_tbl(i).DUE_DATE           := p_payoff_date;
                l_invoices_tbl(i).TRANSACTION_TYPE   := l_credit_name;
                l_invoices_tbl(i).REMAINING_AMOUNT   := - l_last_interest;
                l_invoices_tbl(i).PURPOSE            := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', l_payoff_tbl2(k).PAYOFF_PURPOSE);
                l_invoices_tbl(i).BILLED_FLAG        := 'N';

                if l_last_interest + l_payoff_tbl2(k).unbilled_amount > 0 then
                    -- new interest document
                    i := i + 1;
                    l_invoices_tbl(i).CUST_TRX_ID        := null;
                    l_invoices_tbl(i).INSTALLMENT_NUMBER := l_installment;
                    l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
                    l_invoices_tbl(i).DUE_DATE           := p_payoff_date;
                    l_invoices_tbl(i).TRANSACTION_TYPE   := lns_utility_pub.getDocumentName(l_payoff_tbl2(k).PAYOFF_PURPOSE);
                    l_invoices_tbl(i).REMAINING_AMOUNT   := l_last_interest + l_payoff_tbl2(k).unbilled_amount;
                    l_invoices_tbl(i).PURPOSE            := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', l_payoff_tbl2(k).PAYOFF_PURPOSE);
                    l_invoices_tbl(i).BILLED_FLAG        := 'N';
                end if;

              end if;

          end loop;

          logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - getting last fees ');
          i := l_invoices_tbl.count;
          open c_fees(p_loan_id);
          loop
                i := i + 1;
                fetch c_fees into
                l_fee_amount, l_fee_name, l_fee_installment;

          exit when c_fees%notfound;
                l_invoices_tbl(i).CUST_TRX_ID        := null;
                l_invoices_tbl(i).INSTALLMENT_NUMBER := l_fee_installment;
                l_invoices_tbl(i).INVOICE_NUMBER     := l_invoice_number;
                l_invoices_tbl(i).DUE_DATE           := p_payoff_date;
                l_invoices_tbl(i).TRANSACTION_TYPE   := lns_utility_pub.getDocumentName('FEE');
                l_invoices_tbl(i).REMAINING_AMOUNT   := l_fee_amount;
                l_invoices_tbl(i).PURPOSE            := lns_utility_pub.get_lookup_meaning('PAYMENT_APPLICATION_TYPE', 'FEE');
                l_invoices_tbl(i).BILLED_FLAG        := 'N';
                 logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || ' - fee found');
          end loop;
          close c_fees;

    end if;

    x_invoices_tbl := l_invoices_tbl;
    -- --------------------------------------------------------------------
    -- End of API body
    --

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO getLoanInvoices;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO getLoanInvoices;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO getLoanInvoices;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end getLoanInvoices;

/*========================================================================
 | PRIVATE PROCEDURE APPLY_RECEIPT
 |
 | DESCRIPTION
 |      This procedure applies cash receipt to invoice.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      CREATE_SINGLE_OFFCYCLE_BILL
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      P_CASH_RECEIPT_ID   IN      Cash receipt to apply
 |      P_TRX_ID            IN      Apply receipt to this trx
 |      P_TRX_LINE_ID       IN      Apply receipt to this trx line
 |      P_APPLY_AMOUNT      IN      Apply amount
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPLY_RECEIPT(P_CASH_RECEIPT_ID         IN  NUMBER
                       ,P_PAYMENT_SCHEDULE_ID     IN  NUMBER
                       ,P_APPLY_AMOUNT            IN  NUMBER
                       ,P_APPLY_DATE              IN  DATE
                       ,p_apply_amount_from       IN  NUMBER
                       ,p_trans_to_receipt_rate   IN  NUMBER
                       ,x_return_status           OUT NOCOPY VARCHAR2
                       ,x_msg_count               OUT NOCOPY NUMBER
                       ,x_msg_data                OUT NOCOPY VARCHAR2)

IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      VARCHAR2(30);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_receipt_rem_amount            number;
    g_day_togl_after_dd             number;
    l_apply_date                    date;
    l_due_date                      date;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR receipt_cur(P_RECEIPT_ID number) IS
        select ABS(AMOUNT_DUE_REMAINING)
        from ar_payment_schedules
        where CASH_RECEIPT_ID = P_RECEIPT_ID
        and status = 'OP'
        and class = 'PMT';

    cursor c_due_date(p_payment_schedule_id number) is
    select due_date
      from ar_payment_schedules
     where payment_schedule_id = p_payment_schedule_id;


BEGIN

    l_api_name           := 'apply_receipt';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Standard Start of API savepoint
    SAVEPOINT APPLY_RECEIPT;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    -- --------------------------------------------------------------------
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Applying cash receipt ' || P_CASH_RECEIPT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' P_PS_ID: ' || P_PAYMENT_SCHEDULE_ID);
    --LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'P_TRX_LINE_ID: ' || P_TRX_LINE_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' P_APPLY_AMOUNT: ' || P_APPLY_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' P_APPLY_AMOUNT_FROM: ' || P_APPLY_AMOUNT_FROM);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' p_trans_to_receipt_rate: ' || p_trans_to_receipt_rate);

    /* verify input data */
    if P_CASH_RECEIPT_ID is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CR_NOT_SET');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_APPLY_AMOUNT is null or P_APPLY_AMOUNT <= 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_AMOUNT_NOT_SET');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* verifying requested qpply amount */
    open receipt_cur(P_CASH_RECEIPT_ID);
    fetch receipt_cur into l_receipt_rem_amount;

    if receipt_cur%NOTFOUND then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_CR_FOUND');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    close receipt_cur;
    /*
    if l_receipt_rem_amount < P_APPLY_AMOUNT then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_CR_FUNDS');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;
     */
    select
        DAYS_TOGL_AFTER_DUE_DATE
    into g_day_togl_after_dd
    FROM LNS_SYSTEM_OPTIONS
    WHERE ORG_ID =  MO_GLOBAL.GET_CURRENT_ORG_ID() ;

    open c_due_date(P_PAYMENT_SCHEDULE_ID);
    fetch c_due_date into l_due_date;
    close c_due_date;

    if l_due_date > p_apply_date then
        l_apply_date := l_due_Date;
    else
        l_apply_date := p_apply_date;
    end if;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' due_date: ' || l_due_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' apply_date: ' || l_apply_date);

    /* Applying cash receipt to invoice */
    AR_RECEIPT_API_PUB.APPLY(P_API_VERSION                 => 1.0
                            ,P_INIT_MSG_LIST               => FND_API.G_FALSE
                            ,P_COMMIT                      => FND_API.G_FALSE
                            ,X_RETURN_STATUS               => L_RETURN_STATUS
                            ,X_MSG_COUNT                   => L_MSG_COUNT
                            ,X_MSG_DATA                    => L_MSG_DATA
                            ,p_cash_receipt_id             => P_CASH_RECEIPT_ID
                            ,p_applied_payment_schedule_id => P_PAYMENT_SCHEDULE_ID
                            ,p_apply_date                  => l_apply_date
                            ,p_apply_gl_date               => l_apply_date + g_day_togl_after_dd
                            ,p_amount_applied              => P_APPLY_AMOUNT
                            ,p_amount_applied_from         => p_apply_amount_from
                            ,p_trans_to_receipt_rate       => p_trans_to_receipt_rate);

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' return_status: ' || l_return_status);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' msg_data: ' || substr(l_msg_data,1,225));

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_APPL_CR_FAIL');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        null;
        --LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Successfully applied cash receipt to trx ' || P_TRX_ID || ' line ' || P_TRX_LINE_ID);
    END IF;
    -- END OF BODY OF API

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO APPLY_RECEIPT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO APPLY_RECEIPT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO APPLY_RECEIPT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
END;

/*=========================================================================
|| PUBLIC FUNCTION getConvertedReceiptAmount
||
|| DESCRIPTION
||
|| Overview:  This function returns the receipt balance amount in loan currency
||               for the loan
||
|| Parameter: p_receipt_id = cash_receipt_id
||            p_loan_id = loan id
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: Converted receipt balance amount in loan currency
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10/20/2004            karamach          Created
 *=======================================================================*/
FUNCTION getConvertedReceiptAmount(p_receipt_id in number, p_loan_id in number) return NUMBER
IS

    Cursor getReceiptCurrencyBalance(p_recpt_id number) is
    select CR.CURRENCY_CODE RECEIPT_CURRENCY_CODE,
    (select SUM(DECODE(app.status,'UNAPP',NVL(app.amount_applied,0),0)) amt from AR_RECEIVABLE_APPLICATIONS app where app.cash_receipt_id = CR.CASH_RECEIPT_ID) RECEIPT_CURRENCY_AMOUNT,
           CR.EXCHANGE_RATE_TYPE,
           CR.EXCHANGE_DATE,
           CR.EXCHANGE_RATE
    from AR_CASH_RECEIPTS CR
    where CR.cash_receipt_id = p_recpt_id;

    Cursor getLoanCurrencyConversion(p_loanId number) is
    select loan.loan_currency LOAN_CURRENCY_CODE
    from LNS_LOAN_HEADERS_ALL loan
    where loan.loan_id = p_loanId;

    --receipt_currency_code        varchar2(3);
    --loan_currency_code         varchar2(3);
    receipt_currency_amount      number;
    loan_currency_amount         number;

    l_loan_currency_code         varchar2(15);
    l_loan_exchange_rate_type    varchar2(30);
    l_loan_exchange_rate         number;
    l_loan_exchange_date         date;
    l_sob_currency_code          varchar2(15);

    l_rec_currency_code          varchar2(15);
    l_rec_exchange_rate_type     varchar2(30);
    l_rec_exchange_date          date;
    l_rec_exchange_rate          number;

    l_return                     number;

    cursor c_loan_exchange_info(p_loan_id number) is
    select lnh.exchange_rate_type
          ,lnh.exchange_rate
          ,lnh.exchange_date
          ,lnh.loan_currency
      from lns_loan_headers lnh
     where loan_id = p_loan_id;

    cursor c_sob_currency is
    SELECT sb.currency_code
      FROM lns_system_options so,
           gl_sets_of_books sb
     WHERE sb.set_of_books_id = so.set_of_books_id;

BEGIN

open getReceiptCurrencyBalance(p_receipt_id);
--fetch getReceiptCurrencyBalance into receipt_currency_code,receipt_currency_amount;
fetch getReceiptCurrencyBalance into
                 l_rec_currency_code
                ,receipt_currency_amount
                ,l_rec_exchange_rate_type
                ,l_rec_exchange_date
                ,l_rec_exchange_rate;
close getReceiptCurrencyBalance;

open c_loan_exchange_info(p_loan_id);
fetch c_loan_exchange_info into
         l_loan_exchange_rate_type
        ,l_loan_exchange_rate
        ,l_loan_exchange_date
        ,l_loan_currency_code;
close c_loan_exchange_info;

if (l_rec_currency_code is null or receipt_currency_amount is null or l_loan_currency_code is null) then
        return 0;
elsif (l_rec_currency_code  = l_loan_currency_code) then
        return receipt_currency_amount;
else -- rec currency <> loan currency
    open c_sob_currency;
        fetch c_sob_currency into l_sob_currency_code;
    close c_sob_currency;

    if l_rec_currency_code = l_sob_currency_code then
        l_return := receipt_currency_amount / l_loan_exchange_rate;

    else -- rec_currency <> loan_currency <> sob currency
         -- this is not valid unless user enters the conversion rate/date/type on payoff UI
         -- that is the approach AR takes
        l_return := 0;
    end if;

    return l_return;

end if;

END getConvertedReceiptAmount;

END LNS_PAYOFF_PUB;

/
