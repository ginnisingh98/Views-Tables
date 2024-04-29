--------------------------------------------------------
--  DDL for Package Body LNS_IMPORT_LOAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_IMPORT_LOAN_PUB" as
/* $Header: LNS_IMPORT_LOAN_B.pls 120.0.12010000.2 2009/05/22 14:15:50 scherkas noship $ */


 /*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    g_pkg_name constant VARCHAR2(30) := 'LNS_IMPORT_LOAN_PUB';
    g_log_enabled           VARCHAR2(5);
    g_msg_level             NUMBER;
    g_errors_rec            Loan_create_errors_type := Loan_create_errors_type();
    g_error_count           number := 0;

  PROCEDURE validate_pay_history(P_Loan_Details_Rec IN OUT nocopy lns_import_loan_pub.loan_details_rec_type
                                ,P_PAY_HIST_TBL IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.PAYMENT_HIST_TBL_TYPE
                                , x_return_status OUT nocopy VARCHAR2
                                , x_msg_count OUT nocopy NUMBER
                                , x_msg_data OUT nocopy VARCHAR2);

 /*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2006           GBELLARY          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);

    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



/*========================================================================
 | PRIVATE PROCEDURE LogErrors
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      This procedure builds the error message and stores it (alongwith
 |      other columns in LNS_LOAN_API_ERRORS_GT) in g_errors_rec.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2006           GBELLARY          Created
 |
 *=======================================================================*/
Procedure LogErrors( p_message_name IN VARCHAR2
                     ,p_line_number IN NUMBER DEFAULT NULL
                     ,p_token1 IN VARCHAR2 DEFAULT NULL
		             ,p_token2 IN VARCHAR2 DEFAULT NULL
		             ,p_token3 IN VARCHAR2 DEFAULT NULL)
IS
    l_text LNS_LOAN_API_ERRORS_GT.MESSAGE_TEXT%TYPE;

BEGIN

   fnd_message.set_name('LNS', p_message_name);

   if p_token1 is NOT NULL THEN
        fnd_message.set_token('TOKEN1',p_token1);
   end if;

   IF p_token2 is NOT NULL THEN
        fnd_message.set_token('TOKEN2',p_token2);
   END IF;

   IF p_token3 is NOT NULL THEN
        fnd_message.set_token('TOKEN3',p_token3);
   END IF;

   FND_MSG_PUB.Add;
   l_text := substrb(fnd_message.get,1,2000);
   g_error_count := g_error_count+1;
   g_errors_rec.extend(1);
   g_errors_rec(g_error_count).ERROR_NUMBER := g_error_count;
   g_errors_rec(g_error_count).MESSAGE_NAME := p_message_name;
   g_errors_rec(g_error_count).MESSAGE_TEXT := l_text;
   g_errors_rec(g_error_count).LINE_NUMBER  := p_line_number;
   LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || p_message_name || '(' || p_token1 || ',' || p_token2 || ',' || p_token3 || ') - ' || l_text);

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



PROCEDURE validate_pay_history(P_Loan_Details_Rec IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.Loan_Details_Rec_Type
                                ,P_PAY_HIST_TBL IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.PAYMENT_HIST_TBL_TYPE
                                , x_return_status OUT nocopy VARCHAR2
                                , x_msg_count OUT nocopy NUMBER
                                , x_msg_data OUT nocopy VARCHAR2)
IS
    l_api_name constant VARCHAR2(30) := 'VALIDATE_PAY_HISTORY';
    i                   NUMBER;
    j                   NUMBER;
    l_temp              LNS_IMPORT_LOAN_PUB.PAYMENT_HIST_REC_TYPE;
    l_tem_pay_hist_tbl  LNS_IMPORT_LOAN_PUB.PAYMENT_HIST_TBL_TYPE;

BEGIN
    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' +');

    P_Loan_Details_Rec.next_payment_due_date := P_Loan_Details_Rec.first_payment_date;

    l_tem_pay_hist_tbl := P_PAY_HIST_TBL;
    FOR i IN 1 .. l_tem_pay_hist_tbl.COUNT LOOP

        logmessage(fnd_log.level_statement, 'Payment record ' || i);
        logmessage(fnd_log.level_statement, 'PAYMENT_NUMBER = ' || l_tem_pay_hist_tbl(i).PAYMENT_NUMBER);
        logmessage(fnd_log.level_statement, 'DUE_DATE = ' || l_tem_pay_hist_tbl(i).DUE_DATE);
        logmessage(fnd_log.level_statement, 'BILLED_PRIN = ' || l_tem_pay_hist_tbl(i).BILLED_PRIN);
        logmessage(fnd_log.level_statement, 'BILLED_INT = ' || l_tem_pay_hist_tbl(i).BILLED_INT);
        logmessage(fnd_log.level_statement, 'BILLED_FEE = ' || l_tem_pay_hist_tbl(i).BILLED_FEE);
        logmessage(fnd_log.level_statement, 'SOURCE = ' || l_tem_pay_hist_tbl(i).SOURCE);
        logmessage(fnd_log.level_statement, 'PAID_PRIN = ' || l_tem_pay_hist_tbl(i).PAID_PRIN);
        logmessage(fnd_log.level_statement, 'PAID_INT = ' || l_tem_pay_hist_tbl(i).PAID_INT);
        logmessage(fnd_log.level_statement, 'PAID_FEE = ' || l_tem_pay_hist_tbl(i).PAID_FEE);
        logmessage(fnd_log.level_statement, 'PAID_DATE = ' || l_tem_pay_hist_tbl(i).PAID_DATE);
        logmessage(fnd_log.level_statement, 'RC_ID = ' || l_tem_pay_hist_tbl(i).RC_ID);
        logmessage(fnd_log.level_statement, 'RC_METHOD_ID = ' || l_tem_pay_hist_tbl(i).RC_METHOD_ID);

        if l_tem_pay_hist_tbl(i).PAYMENT_NUMBER is null then
            logerrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                        p_token1 => 'P_PAY_HIST_TBL(' || i || ').PAYMENT_NUMBER');
        end if;

        if l_tem_pay_hist_tbl(i).PAYMENT_NUMBER < 0 then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').PAYMENT_NUMBER'
                        , p_token2 => l_tem_pay_hist_tbl(i).PAYMENT_NUMBER);
        end if;

        if l_tem_pay_hist_tbl(i).DUE_DATE is null then
            logerrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                        p_token1 => 'P_PAY_HIST_TBL(' || i || ').DUE_DATE');
        end if;

        if l_tem_pay_hist_tbl(i).DUE_DATE < P_Loan_Details_Rec.loan_start_date then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').DUE_DATE'
                        , p_token2 => l_tem_pay_hist_tbl(i).DUE_DATE);
        end if;

        if l_tem_pay_hist_tbl(i).SOURCE is null then
            l_tem_pay_hist_tbl(i).SOURCE := 'SCHEDULED';
        end if;

        if l_tem_pay_hist_tbl(i).BILLED_PRIN is null then
            l_tem_pay_hist_tbl(i).BILLED_PRIN := 0;
        end if;

        if l_tem_pay_hist_tbl(i).BILLED_INT is null then
            l_tem_pay_hist_tbl(i).BILLED_INT := 0;
        end if;

        if l_tem_pay_hist_tbl(i).BILLED_FEE is null then
            l_tem_pay_hist_tbl(i).BILLED_FEE := 0;
        end if;

        if l_tem_pay_hist_tbl(i).BILLED_PRIN < 0 then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').BILLED_PRIN'
                        , p_token2 => l_tem_pay_hist_tbl(i).BILLED_PRIN);
        end if;

        if l_tem_pay_hist_tbl(i).BILLED_INT < 0 then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').BILLED_INT'
                        , p_token2 => l_tem_pay_hist_tbl(i).BILLED_INT);
        end if;

        if l_tem_pay_hist_tbl(i).BILLED_FEE < 0 then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').BILLED_FEE'
                        , p_token2 => l_tem_pay_hist_tbl(i).BILLED_FEE);
        end if;

        if l_tem_pay_hist_tbl(i).SOURCE <> 'SCHEDULED' then
            if l_tem_pay_hist_tbl(i).BILLED_INT > 0 then
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                            , p_token1 => 'P_PAY_HIST_TBL(' || i || ').BILLED_INT'
                            , p_token2 => l_tem_pay_hist_tbl(i).BILLED_INT);
            elsif l_tem_pay_hist_tbl(i).BILLED_FEE > 0 then
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                            , p_token1 => 'P_PAY_HIST_TBL(' || i || ').BILLED_FEE'
                            , p_token2 => l_tem_pay_hist_tbl(i).BILLED_FEE);
            end if;
        end if;

        if l_tem_pay_hist_tbl(i).PAID_PRIN is null then
            l_tem_pay_hist_tbl(i).PAID_PRIN := 0;
        end if;

        if l_tem_pay_hist_tbl(i).PAID_INT is null then
            l_tem_pay_hist_tbl(i).PAID_INT := 0;
        end if;

        if l_tem_pay_hist_tbl(i).PAID_FEE is null then
            l_tem_pay_hist_tbl(i).PAID_FEE := 0;
        end if;

        if l_tem_pay_hist_tbl(i).PAID_PRIN < 0 then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').PAID_PRIN'
                        , p_token2 => l_tem_pay_hist_tbl(i).PAID_PRIN);
        end if;

        if l_tem_pay_hist_tbl(i).PAID_INT < 0 then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').PAID_INT'
                        , p_token2 => l_tem_pay_hist_tbl(i).PAID_INT);
        end if;

        if l_tem_pay_hist_tbl(i).PAID_FEE < 0 then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').PAID_FEE'
                        , p_token2 => l_tem_pay_hist_tbl(i).PAID_FEE);
        end if;

        if l_tem_pay_hist_tbl(i).PAID_DATE is null then
            l_tem_pay_hist_tbl(i).PAID_DATE := l_tem_pay_hist_tbl(i).DUE_DATE;
        end if;

        if l_tem_pay_hist_tbl(i).PAID_DATE < l_tem_pay_hist_tbl(i).DUE_DATE then
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_PAY_HIST_TBL(' || i || ').PAID_DATE'
                        , p_token2 => l_tem_pay_hist_tbl(i).PAID_DATE);
        end if;

        IF l_tem_pay_hist_tbl(i).RC_ID IS NULL and
           (l_tem_pay_hist_tbl(i).PAID_PRIN + l_tem_pay_hist_tbl(i).PAID_INT + l_tem_pay_hist_tbl(i).PAID_FEE) > 0
        THEN
            IF l_tem_pay_hist_tbl(i).RC_METHOD_ID IS NULL THEN
                logerrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                            p_token1 => 'P_PAY_HIST_TBL(' || i || ').RC_METHOD_ID');
            END IF;
        END IF;

        if l_tem_pay_hist_tbl(i).SOURCE = 'SCHEDULED' and
           l_tem_pay_hist_tbl(i).DUE_DATE > P_Loan_Details_Rec.next_payment_due_date then
            P_Loan_Details_Rec.next_payment_due_date := l_tem_pay_hist_tbl(i).DUE_DATE;
        end if;

    END LOOP;

    -- sort table
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Sorting by payment number...');
    for i in REVERSE 1..l_tem_pay_hist_tbl.count loop
        for j in 1..(i-1) loop
            if l_tem_pay_hist_tbl(j).PAYMENT_NUMBER > l_tem_pay_hist_tbl(j+1).PAYMENT_NUMBER or
               (l_tem_pay_hist_tbl(j).PAYMENT_NUMBER = l_tem_pay_hist_tbl(j+1).PAYMENT_NUMBER and
                l_tem_pay_hist_tbl(j).SOURCE <> 'SCHEDULED' and l_tem_pay_hist_tbl(j+1).SOURCE = 'SCHEDULED') then

                l_temp := l_tem_pay_hist_tbl(j);
                l_tem_pay_hist_tbl(j) := l_tem_pay_hist_tbl(j+1);
                l_tem_pay_hist_tbl(j+1) := l_temp;

            elsif l_tem_pay_hist_tbl(j).PAYMENT_NUMBER = l_tem_pay_hist_tbl(j+1).PAYMENT_NUMBER and
                l_tem_pay_hist_tbl(j).SOURCE = 'SCHEDULED' and l_tem_pay_hist_tbl(j+1).SOURCE = 'SCHEDULED' then

                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                            , p_token1 => 'P_PAY_HIST_TBL(' || (j+1) || ').SOURCE'
                            , p_token2 => l_tem_pay_hist_tbl(j+1).SOURCE);

            end if;
        end loop;
    end loop;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Done sorting.');

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    P_PAY_HIST_TBL := l_tem_pay_hist_tbl;

    -- END OF BODY OF API
    x_return_status := fnd_api.g_ret_sts_success;

    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' -');

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count,   p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count,   p_data => x_msg_data);
    WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        logerrors('Exception at '||g_pkg_name || '.' || l_api_name ||' is '||sqlerrm);
        x_msg_count := 1;
        x_msg_data := sqlerrm;

END validate_pay_history;



/*========================================================================
| PUBLIC PROCEDURE IMPORT_LOAN
|
| DESCRIPTION
|      This procedure imports single loan.
|
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
|
| CALLS PROCEDURES/FUNCTIONS (local to this package body)
|      None
|
| PARAMETERS
|      p_msg_level     IN      Debug msg level
|      p_msg           IN      Debug msg itself
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
| 07-17-2007            scherkas          Created
|
*=======================================================================*/

PROCEDURE IMPORT_LOAN(
    P_API_VERSION		    IN     NUMBER,
    P_INIT_MSG_LIST		    IN     VARCHAR2,
    P_COMMIT			    IN     VARCHAR2,
    P_VALIDATION_LEVEL	    IN     NUMBER,
    P_Loan_Details_Rec      IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.Loan_Details_Rec_Type,  -- mandatory
    P_Loan_Lines_Tbl        IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.Loan_Lines_Tbl_Type,  -- mandatory
    P_LOAN_PART_TBL         IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.LOAN_PART_TBL_TYPE,  -- optional
    P_LOAN_RATES_TBL        IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.LOAN_RATES_TBL_TYPE,  -- mandatory
    p_loan_cust_sched_tbl   IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.loan_cust_sched_tbl_type,  -- optional
    p_distribution_tbl      IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.distribution_tbl,  -- optional
    P_PAY_HIST_TBL          IN OUT NOCOPY  LNS_IMPORT_LOAN_PUB.PAYMENT_HIST_TBL_TYPE,
    X_LOAN_ID               OUT    NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT    NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT    NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT    NOCOPY  VARCHAR2)
IS

    /*-----------------------------------------------------------------------+
    | Local Variable Declarations and initializations                       |
    +-----------------------------------------------------------------------*/
    l_api_name constant VARCHAR2(30) := 'IMPORT_LOAN';
    l_api_version constant NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_loan_id               NUMBER;
    l_loan_number           VARCHAR2(60);
    l_index                 number := 0;
    l_indexNo               number := 1;
    l_msg                   varchar2(4000) := null;
    l_dummy                 VARCHAR2(30);
    l_term_id               NUMBER;
    l_version_number        NUMBER;
    l_lines_count           number;
    l_paid_total            NUMBER;
    l_cr_id                 NUMBER;
    l_principal_trx_id      NUMBER;
    l_interest_trx_id       NUMBER;
    l_fee_trx_id            NUMBER;
    i                       number;
    l_funded_amount         number;

    l_LOAN_DTL_REC          LNS_LOAN_PUB.Loan_Details_Rec_Type;
    l_LOAN_LINES_TBL        LNS_LOAN_PUB.Loan_Lines_Tbl_Type;
    l_LOAN_PART_TBL         LNS_LOAN_PUB.LOAN_PART_TBL_TYPE;
    l_LOAN_RATES_TBL        LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE;
    l_term_rec              lns_terms_pub.loan_term_rec_type;
    l_bill_headers_tbl      lns_billing_batch_pub.bill_headers_tbl;
    l_bill_lines_tbl        lns_billing_batch_pub.bill_lines_tbl;
    l_loan_header_rec       LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_OPEN_RATES_TBL        LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE;
    l_loan_cust_sched_tbl   LNS_LOAN_PUB.loan_cust_sched_tbl_type;
    l_LOAN_RATES_REC        LNS_IMPORT_LOAN_PUB.LOAN_RATES_REC_TYPE;
    l_distribution_tbl      lns_distributions_pub.distribution_tbl;

    /*-----------------------------------------------------------------------+
    | Cursor Declarations                                                   |
    +-----------------------------------------------------------------------*/

    CURSOR c_get_rate_sch_info(termId NUMBER) IS
        SELECT
            begin_installment_number,
            end_installment_number,
            index_date,
            index_rate,
            spread,
            INTEREST_ONLY_FLAG
        FROM lns_rate_schedules
        WHERE end_date_active IS NULL
            AND term_id = termId
            AND PHASE = 'TERM'
        order by begin_installment_number;

BEGIN

    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT import_loan;
    logmessage(fnd_log.level_statement,   'Savepoint is established');

    -- Standard call to check for call compatibility

    IF NOT fnd_api.compatible_api_call(l_api_version,   p_api_version,   l_api_name,   g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := fnd_api.g_ret_sts_success;

    -- START OF BODY OF API

    -- Initialize Collections and Variables
    g_errors_rec.delete;
    g_error_count := 0;

    logmessage(fnd_log.level_statement, 'Validating product...');
    BEGIN
        SELECT 'Y'
        INTO   l_dummy
        from lns_loan_types loan_type,
        lns_loan_products_all loan_product
        where loan_product.loan_product_id = P_Loan_Details_Rec.product_id AND
        loan_type.loan_type_id = loan_product.loan_type_id AND
        loan_type.loan_class_code = 'ERS';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                    p_token1 => 'P_Loan_Details_Rec.product_id',
                    p_token2 => P_Loan_Details_Rec.product_id);
            RAISE fnd_api.g_exc_error;
    END;

    logmessage(fnd_log.level_statement, 'Preparing P_Loan_Details_Rec data...');

    -- common attributes
    l_LOAN_DTL_REC.product_id := P_Loan_Details_Rec.product_id;
    l_LOAN_DTL_REC.LOAN_NUMBER := P_Loan_Details_Rec.LOAN_NUMBER;
    l_LOAN_DTL_REC.LOAN_DESCRIPTION := P_Loan_Details_Rec.LOAN_DESCRIPTION;
    l_LOAN_DTL_REC.LOAN_ASSIGNED_TO := P_Loan_Details_Rec.LOAN_ASSIGNED_TO;
    l_LOAN_DTL_REC.legal_entity_id := P_Loan_Details_Rec.legal_entity_id;
    l_LOAN_DTL_REC.requested_amount := null;
    l_LOAN_DTL_REC.LOAN_APPLICATION_DATE := P_Loan_Details_Rec.LOAN_APPLICATION_DATE;
    l_LOAN_DTL_REC.EXCHANGE_RATE_TYPE := P_Loan_Details_Rec.EXCHANGE_RATE_TYPE;
    l_LOAN_DTL_REC.EXCHANGE_DATE := P_Loan_Details_Rec.EXCHANGE_DATE;
    l_LOAN_DTL_REC.EXCHANGE_RATE := P_Loan_Details_Rec.EXCHANGE_RATE;
    l_LOAN_DTL_REC.LOAN_PURPOSE_CODE := P_Loan_Details_Rec.LOAN_PURPOSE_CODE;
    l_LOAN_DTL_REC.LOAN_SUBTYPE := P_Loan_Details_Rec.LOAN_SUBTYPE;
    l_LOAN_DTL_REC.credit_review_flag := P_Loan_Details_Rec.credit_review_flag;
    l_LOAN_DTL_REC.trx_type_id := P_Loan_Details_Rec.trx_type_id;
    l_LOAN_DTL_REC.COLLATERAL_PERCENT := P_Loan_Details_Rec.COLLATERAL_PERCENT;
    l_LOAN_DTL_REC.CUSTOM_PAYMENTS_FLAG := P_Loan_Details_Rec.CUSTOM_PAYMENTS_FLAG;
    l_LOAN_DTL_REC.FORGIVENESS_FLAG := P_Loan_Details_Rec.FORGIVENESS_FLAG;
    l_LOAN_DTL_REC.FORGIVENESS_PERCENT := P_Loan_Details_Rec.FORGIVENESS_PERCENT;

    -- primary borrower attributes
    l_LOAN_DTL_REC.primary_borrower_party_id := P_Loan_Details_Rec.primary_borrower_party_id;
    l_LOAN_DTL_REC.CUST_ACCOUNT_ID := P_Loan_Details_Rec.CUST_ACCOUNT_ID;
    l_LOAN_DTL_REC.BILL_TO_ACCT_SITE_ID := P_Loan_Details_Rec.BILL_TO_ACCT_SITE_ID;
    l_LOAN_DTL_REC.contact_rel_party_id := P_Loan_Details_Rec.contact_rel_party_id;
    l_LOAN_DTL_REC.CONTACT_PERS_PARTY_ID := P_Loan_Details_Rec.CONTACT_PERS_PARTY_ID;

    -- common term attributes
    l_LOAN_DTL_REC.RATE_TYPE := P_Loan_Details_Rec.RATE_TYPE;
    l_LOAN_DTL_REC.INDEX_RATE_ID := P_Loan_Details_Rec.INDEX_RATE_ID;
    l_LOAN_DTL_REC.DAY_COUNT_METHOD := P_Loan_Details_Rec.DAY_COUNT_METHOD;
    l_LOAN_DTL_REC.LOAN_PAYMENT_FREQUENCY := P_Loan_Details_Rec.LOAN_PAYMENT_FREQUENCY;
    l_LOAN_DTL_REC.CALCULATION_METHOD := P_Loan_Details_Rec.CALCULATION_METHOD;
    l_LOAN_DTL_REC.INTEREST_COMPOUNDING_FREQ := P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ;
    l_LOAN_DTL_REC.PAYMENT_CALC_METHOD := P_Loan_Details_Rec.PAYMENT_CALC_METHOD;
    l_LOAN_DTL_REC.CUSTOM_CALC_METHOD := P_Loan_Details_Rec.CUSTOM_CALC_METHOD;
    l_LOAN_DTL_REC.ORIG_PAY_CALC_METHOD := P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD;
    l_LOAN_DTL_REC.PENAL_INT_RATE := P_Loan_Details_Rec.PENAL_INT_RATE;
    l_LOAN_DTL_REC.PENAL_INT_GRACE_DAYS := P_Loan_Details_Rec.PENAL_INT_GRACE_DAYS;
    l_LOAN_DTL_REC.LOCK_DATE := P_Loan_Details_Rec.LOCK_DATE;
    l_LOAN_DTL_REC.LOCK_EXP_DATE := P_Loan_Details_Rec.LOCK_EXP_DATE;

    -- 'term phase' term attributes
    l_LOAN_DTL_REC.LOAN_TERM := P_Loan_Details_Rec.LOAN_TERM;
    l_LOAN_DTL_REC.LOAN_TERM_PERIOD := P_Loan_Details_Rec.LOAN_TERM_PERIOD;
    l_LOAN_DTL_REC.balloon_payment_type := P_Loan_Details_Rec.balloon_payment_type;
    l_LOAN_DTL_REC.balloon_payment_amount := P_Loan_Details_Rec.balloon_payment_amount;
    l_LOAN_DTL_REC.balloon_term := P_Loan_Details_Rec.balloon_term;
    l_LOAN_DTL_REC.LOAN_START_DATE := P_Loan_Details_Rec.LOAN_START_DATE;
    l_LOAN_DTL_REC.FIRST_PAYMENT_DATE := P_Loan_Details_Rec.FIRST_PAYMENT_DATE;
    l_LOAN_DTL_REC.PRIN_FIRST_PAY_DATE := P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE;
    l_LOAN_DTL_REC.PRIN_PAYMENT_FREQUENCY := P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY;
    l_LOAN_DTL_REC.floor_rate := P_Loan_Details_Rec.floor_rate;
    l_LOAN_DTL_REC.ceiling_rate := P_Loan_Details_Rec.ceiling_rate;
    l_LOAN_DTL_REC.percent_increase := P_Loan_Details_Rec.percent_increase;
    l_LOAN_DTL_REC.percent_increase_life := P_Loan_Details_Rec.percent_increase_life;

    -- dont pass any of open phase parameters

    -- Terms for Payment attributes
    l_LOAN_DTL_REC.REAMORTIZE_OVER_PAYMENT := P_Loan_Details_Rec.REAMORTIZE_OVER_PAYMENT;
    l_LOAN_DTL_REC.DELINQUENCY_THRESHOLD_AMOUNT := P_Loan_Details_Rec.DELINQUENCY_THRESHOLD_AMOUNT;
    l_LOAN_DTL_REC.PAYMENT_APPLICATION_ORDER := P_Loan_Details_Rec.PAYMENT_APPLICATION_ORDER;
    l_LOAN_DTL_REC.PMT_APPL_ORDER_SCOPE := P_Loan_Details_Rec.PMT_APPL_ORDER_SCOPE;

    -- additional optional attributes
    l_LOAN_DTL_REC.ATTRIBUTE_CATEGORY := P_Loan_Details_Rec.ATTRIBUTE_CATEGORY;
    l_LOAN_DTL_REC.ATTRIBUTE1 := P_Loan_Details_Rec.ATTRIBUTE1;
    l_LOAN_DTL_REC.ATTRIBUTE2 := P_Loan_Details_Rec.ATTRIBUTE2;
    l_LOAN_DTL_REC.ATTRIBUTE3 := P_Loan_Details_Rec.ATTRIBUTE3;
    l_LOAN_DTL_REC.ATTRIBUTE4 := P_Loan_Details_Rec.ATTRIBUTE4;
    l_LOAN_DTL_REC.ATTRIBUTE5 := P_Loan_Details_Rec.ATTRIBUTE5;
    l_LOAN_DTL_REC.ATTRIBUTE6 := P_Loan_Details_Rec.ATTRIBUTE6;
    l_LOAN_DTL_REC.ATTRIBUTE7 := P_Loan_Details_Rec.ATTRIBUTE7;
    l_LOAN_DTL_REC.ATTRIBUTE8 := P_Loan_Details_Rec.ATTRIBUTE8;
    l_LOAN_DTL_REC.ATTRIBUTE9 := P_Loan_Details_Rec.ATTRIBUTE9;
    l_LOAN_DTL_REC.ATTRIBUTE10 := P_Loan_Details_Rec.ATTRIBUTE10;
    l_LOAN_DTL_REC.ATTRIBUTE11 := P_Loan_Details_Rec.ATTRIBUTE11;
    l_LOAN_DTL_REC.ATTRIBUTE12 := P_Loan_Details_Rec.ATTRIBUTE12;
    l_LOAN_DTL_REC.ATTRIBUTE13 := P_Loan_Details_Rec.ATTRIBUTE13;
    l_LOAN_DTL_REC.ATTRIBUTE14 := P_Loan_Details_Rec.ATTRIBUTE14;
    l_LOAN_DTL_REC.ATTRIBUTE15 := P_Loan_Details_Rec.ATTRIBUTE15;
    l_LOAN_DTL_REC.ATTRIBUTE16 := P_Loan_Details_Rec.ATTRIBUTE16;
    l_LOAN_DTL_REC.ATTRIBUTE17 := P_Loan_Details_Rec.ATTRIBUTE17;
    l_LOAN_DTL_REC.ATTRIBUTE18 := P_Loan_Details_Rec.ATTRIBUTE18;
    l_LOAN_DTL_REC.ATTRIBUTE19 := P_Loan_Details_Rec.ATTRIBUTE19;
    l_LOAN_DTL_REC.ATTRIBUTE20 := P_Loan_Details_Rec.ATTRIBUTE20;

    -- copy loan lines
    logmessage(fnd_log.level_statement, 'Preparing p_loan_lines_tbl data...');
    l_funded_amount := 0;
    FOR i IN 1 .. p_loan_lines_tbl.count LOOP

        l_LOAN_LINES_TBL(i).line_number := i;
        l_LOAN_LINES_TBL(i).payment_schedule_id := -1;
        l_LOAN_LINES_TBL(i).requested_amount := P_LOAN_LINES_TBL(i).amount;
        l_LOAN_LINES_TBL(i).REFERENCE_DESCRIPTION := P_LOAN_LINES_TBL(i).REFERENCE_DESCRIPTION;
        l_LOAN_LINES_TBL(i).REFERENCE_NUMBER := P_LOAN_LINES_TBL(i).REFERENCE_NUMBER;
        l_funded_amount := l_funded_amount + l_LOAN_LINES_TBL(i).requested_amount;

    END LOOP;

    -- copy loan participants
    logmessage(fnd_log.level_statement, 'Preparing p_loan_part_tbl data...');
    FOR i IN 1 .. p_loan_part_tbl.count LOOP

        l_LOAN_PART_TBL(i).HZ_PARTY_ID := P_LOAN_PART_TBL(i).HZ_PARTY_ID;
        l_LOAN_PART_TBL(i).LOAN_PARTICIPANT_TYPE := P_LOAN_PART_TBL(i).LOAN_PARTICIPANT_TYPE;
        l_LOAN_PART_TBL(i).START_DATE_ACTIVE := P_LOAN_PART_TBL(i).START_DATE_ACTIVE;
        l_LOAN_PART_TBL(i).END_DATE_ACTIVE := P_LOAN_PART_TBL(i).END_DATE_ACTIVE;
        l_LOAN_PART_TBL(i).CUST_ACCOUNT_ID := P_LOAN_PART_TBL(i).CUST_ACCOUNT_ID;
        l_LOAN_PART_TBL(i).BILL_TO_ACCT_SITE_ID := P_LOAN_PART_TBL(i).BILL_TO_ACCT_SITE_ID;
        l_LOAN_PART_TBL(i).CONTACT_PERS_PARTY_ID := P_LOAN_PART_TBL(i).CONTACT_PERS_PARTY_ID;
        l_LOAN_PART_TBL(i).CONTACT_REL_PARTY_ID := P_LOAN_PART_TBL(i).CONTACT_REL_PARTY_ID;

    END LOOP;

    -- copy rate schedule
    logmessage(fnd_log.level_statement, 'Preparing p_loan_rates_tbl data...');
    FOR i IN 1 .. p_loan_rates_tbl.count LOOP

        l_LOAN_RATES_TBL(i).INDEX_RATE := p_loan_rates_tbl(i).INDEX_RATE;
        l_LOAN_RATES_TBL(i).SPREAD := p_loan_rates_tbl(i).SPREAD;
        l_LOAN_RATES_TBL(i).INDEX_DATE := p_loan_rates_tbl(i).INDEX_DATE;
        l_LOAN_RATES_TBL(i).BEGIN_INSTALLMENT_NUMBER := p_loan_rates_tbl(i).BEGIN_INSTALLMENT_NUMBER;
        l_LOAN_RATES_TBL(i).END_INSTALLMENT_NUMBER := p_loan_rates_tbl(i).END_INSTALLMENT_NUMBER;
        l_LOAN_RATES_TBL(i).INTEREST_ONLY_FLAG := p_loan_rates_tbl(i).INTEREST_ONLY_FLAG;

    END LOOP;

    -- copy custom schedule
    logmessage(fnd_log.level_statement, 'Preparing p_loan_cust_sched_tbl data...');
    FOR i IN 1 .. p_loan_cust_sched_tbl.count LOOP

        l_loan_cust_sched_tbl(i).PAYMENT_NUMBER := p_loan_cust_sched_tbl(i).PAYMENT_NUMBER;
        l_loan_cust_sched_tbl(i).DUE_DATE := p_loan_cust_sched_tbl(i).DUE_DATE;
        l_loan_cust_sched_tbl(i).PRINCIPAL_AMOUNT := p_loan_cust_sched_tbl(i).PRINCIPAL_AMOUNT;
        l_loan_cust_sched_tbl(i).INTEREST_AMOUNT := p_loan_cust_sched_tbl(i).INTEREST_AMOUNT;
        l_loan_cust_sched_tbl(i).LOCK_PRIN := p_loan_cust_sched_tbl(i).LOCK_PRIN;
        l_loan_cust_sched_tbl(i).LOCK_INT := p_loan_cust_sched_tbl(i).LOCK_INT;

    END LOOP;

    logmessage(fnd_log.level_statement, 'Calling LNS_LOAN_PUB.CREATE_LOAN...');
    LNS_LOAN_PUB.CREATE_LOAN(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_FALSE,
            P_COMMIT		        => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_Loan_Details_Rec      => l_LOAN_DTL_REC,
            P_Loan_Lines_Tbl        => l_LOAN_LINES_TBL,
            P_LOAN_PART_TBL         => l_LOAN_PART_TBL,
            P_OPEN_RATES_TBL        => l_OPEN_RATES_TBL,
            P_TERM_RATES_TBL        => l_LOAN_RATES_TBL,
            p_loan_cust_sched_tbl   => l_loan_cust_sched_tbl,
            P_Application_id        => 206,
            P_Created_by_module     => g_pkg_name || '.' || l_api_name,
            X_LOAN_ID               => l_loan_id,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT		        => l_msg_count,
            X_MSG_DATA	    	    => l_msg_data);

    IF l_return_status <> 'S' THEN
         RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.level_unexpected,   'Loan object created successfully. New loan_id = ' || l_loan_id);

    -- copy loan details data back
    -- common attributes
    P_Loan_Details_Rec.product_id := l_LOAN_DTL_REC.product_id;
    P_Loan_Details_Rec.LOAN_NUMBER := l_LOAN_DTL_REC.LOAN_NUMBER;
    P_Loan_Details_Rec.LOAN_DESCRIPTION := l_LOAN_DTL_REC.LOAN_DESCRIPTION;
    P_Loan_Details_Rec.LOAN_ASSIGNED_TO := l_LOAN_DTL_REC.LOAN_ASSIGNED_TO;
    P_Loan_Details_Rec.legal_entity_id := l_LOAN_DTL_REC.legal_entity_id;
--    P_Loan_Details_Rec.requested_amount := null;
    P_Loan_Details_Rec.LOAN_APPLICATION_DATE := l_LOAN_DTL_REC.LOAN_APPLICATION_DATE;
    P_Loan_Details_Rec.EXCHANGE_RATE_TYPE := l_LOAN_DTL_REC.EXCHANGE_RATE_TYPE;
    P_Loan_Details_Rec.EXCHANGE_DATE := l_LOAN_DTL_REC.EXCHANGE_DATE;
    P_Loan_Details_Rec.EXCHANGE_RATE := l_LOAN_DTL_REC.EXCHANGE_RATE;
    P_Loan_Details_Rec.LOAN_PURPOSE_CODE := l_LOAN_DTL_REC.LOAN_PURPOSE_CODE;
    P_Loan_Details_Rec.LOAN_SUBTYPE := l_LOAN_DTL_REC.LOAN_SUBTYPE;
    P_Loan_Details_Rec.credit_review_flag := l_LOAN_DTL_REC.credit_review_flag;
    P_Loan_Details_Rec.trx_type_id := l_LOAN_DTL_REC.trx_type_id;
    P_Loan_Details_Rec.COLLATERAL_PERCENT := l_LOAN_DTL_REC.COLLATERAL_PERCENT;
    P_Loan_Details_Rec.CUSTOM_PAYMENTS_FLAG := l_LOAN_DTL_REC.CUSTOM_PAYMENTS_FLAG;
    P_Loan_Details_Rec.FORGIVENESS_FLAG := l_LOAN_DTL_REC.FORGIVENESS_FLAG;
    P_Loan_Details_Rec.FORGIVENESS_PERCENT := l_LOAN_DTL_REC.FORGIVENESS_PERCENT;

    -- primary borrower attributes
    P_Loan_Details_Rec.primary_borrower_party_id := l_LOAN_DTL_REC.primary_borrower_party_id;
    P_Loan_Details_Rec.CUST_ACCOUNT_ID := l_LOAN_DTL_REC.CUST_ACCOUNT_ID;
    P_Loan_Details_Rec.BILL_TO_ACCT_SITE_ID := l_LOAN_DTL_REC.BILL_TO_ACCT_SITE_ID;
    P_Loan_Details_Rec.contact_rel_party_id := l_LOAN_DTL_REC.contact_rel_party_id;
    P_Loan_Details_Rec.CONTACT_PERS_PARTY_ID := l_LOAN_DTL_REC.CONTACT_PERS_PARTY_ID;

    -- common term attributes
    P_Loan_Details_Rec.RATE_TYPE := l_LOAN_DTL_REC.RATE_TYPE;
    P_Loan_Details_Rec.INDEX_RATE_ID := l_LOAN_DTL_REC.INDEX_RATE_ID;
    P_Loan_Details_Rec.DAY_COUNT_METHOD := l_LOAN_DTL_REC.DAY_COUNT_METHOD;
    P_Loan_Details_Rec.LOAN_PAYMENT_FREQUENCY := l_LOAN_DTL_REC.LOAN_PAYMENT_FREQUENCY;
    P_Loan_Details_Rec.CALCULATION_METHOD := l_LOAN_DTL_REC.CALCULATION_METHOD;
    P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ := l_LOAN_DTL_REC.INTEREST_COMPOUNDING_FREQ;
    P_Loan_Details_Rec.PAYMENT_CALC_METHOD := l_LOAN_DTL_REC.PAYMENT_CALC_METHOD;
    P_Loan_Details_Rec.CUSTOM_CALC_METHOD := l_LOAN_DTL_REC.CUSTOM_CALC_METHOD;
    P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD := l_LOAN_DTL_REC.ORIG_PAY_CALC_METHOD;
    P_Loan_Details_Rec.PENAL_INT_RATE := l_LOAN_DTL_REC.PENAL_INT_RATE;
    P_Loan_Details_Rec.PENAL_INT_GRACE_DAYS := l_LOAN_DTL_REC.PENAL_INT_GRACE_DAYS;
    P_Loan_Details_Rec.LOCK_DATE := l_LOAN_DTL_REC.LOCK_DATE;
    P_Loan_Details_Rec.LOCK_EXP_DATE := l_LOAN_DTL_REC.LOCK_EXP_DATE;

    -- 'term phase' term attributes
    P_Loan_Details_Rec.LOAN_TERM := l_LOAN_DTL_REC.LOAN_TERM;
    P_Loan_Details_Rec.LOAN_TERM_PERIOD := l_LOAN_DTL_REC.LOAN_TERM_PERIOD;
    P_Loan_Details_Rec.balloon_payment_type := l_LOAN_DTL_REC.balloon_payment_type;
    P_Loan_Details_Rec.balloon_payment_amount := l_LOAN_DTL_REC.balloon_payment_amount;
    P_Loan_Details_Rec.balloon_term := l_LOAN_DTL_REC.balloon_term;
    P_Loan_Details_Rec.LOAN_START_DATE := l_LOAN_DTL_REC.LOAN_START_DATE;
    P_Loan_Details_Rec.FIRST_PAYMENT_DATE := l_LOAN_DTL_REC.FIRST_PAYMENT_DATE;
    P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE := l_LOAN_DTL_REC.PRIN_FIRST_PAY_DATE;
    P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY := l_LOAN_DTL_REC.PRIN_PAYMENT_FREQUENCY;
    P_Loan_Details_Rec.floor_rate := l_LOAN_DTL_REC.floor_rate;
    P_Loan_Details_Rec.ceiling_rate := l_LOAN_DTL_REC.ceiling_rate;
    P_Loan_Details_Rec.percent_increase := l_LOAN_DTL_REC.percent_increase;
    P_Loan_Details_Rec.percent_increase_life := l_LOAN_DTL_REC.percent_increase_life;

    -- Terms for Payment attributes
    P_Loan_Details_Rec.REAMORTIZE_OVER_PAYMENT := l_LOAN_DTL_REC.REAMORTIZE_OVER_PAYMENT;
    P_Loan_Details_Rec.DELINQUENCY_THRESHOLD_AMOUNT := l_LOAN_DTL_REC.DELINQUENCY_THRESHOLD_AMOUNT;
    P_Loan_Details_Rec.PAYMENT_APPLICATION_ORDER := l_LOAN_DTL_REC.PAYMENT_APPLICATION_ORDER;
    P_Loan_Details_Rec.PMT_APPL_ORDER_SCOPE := l_LOAN_DTL_REC.PMT_APPL_ORDER_SCOPE;

    -- others
    P_Loan_Details_Rec.org_id := l_LOAN_DTL_REC.org_id;
    P_Loan_Details_Rec.loan_type_id := l_LOAN_DTL_REC.loan_type_id;
    P_Loan_Details_Rec.loan_class_code := l_LOAN_DTL_REC.loan_class_code;
    P_Loan_Details_Rec.loan_currency := l_LOAN_DTL_REC.loan_currency;
    P_Loan_Details_Rec.maturity_date := l_LOAN_DTL_REC.maturity_date;

    -- copy participants data back
    FOR i IN 1 .. l_loan_part_tbl.count LOOP
        p_LOAN_PART_TBL(i).HZ_PARTY_ID := l_LOAN_PART_TBL(i).HZ_PARTY_ID;
        p_LOAN_PART_TBL(i).LOAN_PARTICIPANT_TYPE := l_LOAN_PART_TBL(i).LOAN_PARTICIPANT_TYPE;
        p_LOAN_PART_TBL(i).START_DATE_ACTIVE := l_LOAN_PART_TBL(i).START_DATE_ACTIVE;
        p_LOAN_PART_TBL(i).END_DATE_ACTIVE := l_LOAN_PART_TBL(i).END_DATE_ACTIVE;
        p_LOAN_PART_TBL(i).CUST_ACCOUNT_ID := l_LOAN_PART_TBL(i).CUST_ACCOUNT_ID;
        p_LOAN_PART_TBL(i).BILL_TO_ACCT_SITE_ID := l_LOAN_PART_TBL(i).BILL_TO_ACCT_SITE_ID;
        p_LOAN_PART_TBL(i).CONTACT_PERS_PARTY_ID := l_LOAN_PART_TBL(i).CONTACT_PERS_PARTY_ID;
        p_LOAN_PART_TBL(i).CONTACT_REL_PARTY_ID := l_LOAN_PART_TBL(i).CONTACT_REL_PARTY_ID;
    END LOOP;

    -- copy rate schedule data back
    FOR i IN 1 .. l_loan_rates_tbl.count LOOP
        p_LOAN_RATES_TBL(i).INDEX_RATE := l_loan_rates_tbl(i).INDEX_RATE;
        p_LOAN_RATES_TBL(i).SPREAD := l_loan_rates_tbl(i).SPREAD;
        p_LOAN_RATES_TBL(i).INDEX_DATE := l_loan_rates_tbl(i).INDEX_DATE;
        p_LOAN_RATES_TBL(i).BEGIN_INSTALLMENT_NUMBER := l_loan_rates_tbl(i).BEGIN_INSTALLMENT_NUMBER;
        p_LOAN_RATES_TBL(i).END_INSTALLMENT_NUMBER := l_loan_rates_tbl(i).END_INSTALLMENT_NUMBER;
        p_LOAN_RATES_TBL(i).INTEREST_ONLY_FLAG := l_loan_rates_tbl(i).INTEREST_ONLY_FLAG;
    END LOOP;

    -- copy custom schedule data back
    FOR i IN 1 .. l_loan_cust_sched_tbl.count LOOP

        p_loan_cust_sched_tbl(i).PAYMENT_NUMBER := l_loan_cust_sched_tbl(i).PAYMENT_NUMBER;
        p_loan_cust_sched_tbl(i).DUE_DATE := l_loan_cust_sched_tbl(i).DUE_DATE;
        p_loan_cust_sched_tbl(i).PRINCIPAL_AMOUNT := l_loan_cust_sched_tbl(i).PRINCIPAL_AMOUNT;
        p_loan_cust_sched_tbl(i).INTEREST_AMOUNT := l_loan_cust_sched_tbl(i).INTEREST_AMOUNT;
        p_loan_cust_sched_tbl(i).LOCK_PRIN := l_loan_cust_sched_tbl(i).LOCK_PRIN;
        p_loan_cust_sched_tbl(i).LOCK_INT := l_loan_cust_sched_tbl(i).LOCK_INT;

    END LOOP;

    logmessage(fnd_log.level_statement,   'Validating Loan Approved Date...');

    IF P_Loan_Details_Rec.loan_approval_date IS NULL THEN
        logerrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                p_token1 => 'P_Loan_Details_Rec.loan_approval_date');
    ELSE
        IF ((P_Loan_Details_Rec.loan_approval_date < P_Loan_Details_Rec.loan_start_date) OR
            (P_Loan_Details_Rec.loan_approval_date > P_Loan_Details_Rec.maturity_date))
        THEN
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                        p_token1 => 'P_Loan_Details_Rec.loan_approval_date',
                        p_token2 => P_Loan_Details_Rec.loan_approval_date);
        END IF;
    END IF;

    logmessage(fnd_log.level_statement,   'Validating Loan Approved By...');

    IF P_Loan_Details_Rec.loan_approved_by IS NULL THEN
        logerrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                p_token1 => 'P_Loan_Details_Rec.loan_approved_by');
    ELSE
        BEGIN

            SELECT
                    'Y' INTO l_dummy
            FROM
                    jtf_rs_role_relations rel ,
                    jtf_rs_roles_b rol
            WHERE
                    rel.role_id = rol.role_id
                    and rel.delete_flag <> 'Y'
                    and rol.role_type_code = 'LOANS'
                    and rol.role_code = 'LOAN_MGR'
                    and rol.active_flag = 'Y'
                    and rol.manager_flag = 'Y'
                    and rel.role_resource_id = P_Loan_Details_Rec.loan_approved_by;
        EXCEPTION
            WHEN no_data_found THEN
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                        p_token1 => 'P_Loan_Details_Rec.loan_approved_by',
                        p_token2 => P_Loan_Details_Rec.loan_approved_by);
        END;
    END IF;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    -- store accounting
    for i in 1..p_distribution_tbl.count loop
        l_distribution_tbl(i).DISTRIBUTION_ID := null;
        l_distribution_tbl(i).LOAN_ID := l_loan_id;
        l_distribution_tbl(i).LINE_TYPE := p_distribution_tbl(i).LINE_TYPE;
        l_distribution_tbl(i).ACCOUNT_NAME := p_distribution_tbl(i).ACCOUNT_NAME;
        l_distribution_tbl(i).CODE_COMBINATION_ID := p_distribution_tbl(i).CODE_COMBINATION_ID;
        l_distribution_tbl(i).ACCOUNT_TYPE := p_distribution_tbl(i).ACCOUNT_TYPE;
        l_distribution_tbl(i).DISTRIBUTION_PERCENT := p_distribution_tbl(i).DISTRIBUTION_PERCENT;
        l_distribution_tbl(i).DISTRIBUTION_AMOUNT := p_distribution_tbl(i).DISTRIBUTION_AMOUNT;
        l_distribution_tbl(i).DISTRIBUTION_TYPE := p_distribution_tbl(i).DISTRIBUTION_TYPE;
    end loop;

    LNS_DISTRIBUTIONS_PUB.createDistrForImport(
        p_api_version       => 1.0,
        p_init_msg_list     => FND_API.G_FALSE,
        p_commit            => FND_API.G_FALSE,
        p_loan_id	        => l_loan_id,
        x_distribution_tbl  => l_distribution_tbl,
        x_return_status     => l_return_status,
        x_msg_count 	    => l_msg_count,
        x_msg_data	        => l_msg_data);

    IF l_return_status <> 'S' THEN
        fnd_message.set_name('LNS', 'LNS_DISTRIBUTION_INVALID');
        fnd_msg_pub.ADD;
        logmessage(fnd_log.level_unexpected,   fnd_msg_pub.GET(p_encoded => 'F'));
        RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.level_unexpected, 'Distributions created successfully');

    -- generate and store agreement report
    LNS_REP_UTILS.STORE_LOAN_AGREEMENT(l_loan_id);
    logmessage(fnd_log.level_unexpected, 'Agreement report created successfully');

    logmessage(fnd_log.LEVEL_STATEMENT,   'Updating Loan object...');
    SELECT object_version_number, loan_number
    INTO l_version_number, l_loan_number
    FROM lns_loan_headers_all
    WHERE loan_id = l_loan_id;

    l_loan_header_rec.loan_id := l_loan_id;
    l_loan_header_rec.LOAN_APPROVAL_DATE := P_Loan_Details_Rec.loan_approval_date;
    l_loan_header_rec.LOAN_APPROVED_BY := P_Loan_Details_Rec.loan_approved_by;
    l_loan_header_rec.loan_status := 'ACTIVE';
    l_loan_header_rec.secondary_status := FND_API.G_MISS_CHAR;
    l_loan_header_rec.funded_amount := l_funded_amount;

    LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version_number,
                                    P_LOAN_HEADER_REC => l_loan_header_rec,
                                    P_INIT_MSG_LIST => FND_API.G_FALSE,
                                    X_RETURN_STATUS => l_return_status,
                                    X_MSG_COUNT => l_msg_count,
                                    X_MSG_DATA => l_msg_data);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_return_status: ' || l_return_status);

    IF l_return_status <> 'S' THEN
        logerrors(p_message_name => 'LNS_UPD_LOAN_FAIL');
        RAISE fnd_api.g_exc_error;
    END IF;
    logmessage(fnd_log.level_unexpected,   'Loan object updated successfully');

    logmessage(fnd_log.level_unexpected,   'Calling validate_pay_history...');
    validate_pay_history(P_Loan_Details_Rec
                        ,P_PAY_HIST_TBL
                        , l_return_status
                        , l_msg_count
                        , l_msg_data);

    IF l_return_status <> 'S' THEN
        logmessage(fnd_log.level_unexpected,   'Validation failed in module - validate_pay_history()');
        RAISE fnd_api.g_exc_error;
    END IF;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    FOR l_count IN 1 .. P_PAY_HIST_TBL.COUNT LOOP

        IF P_PAY_HIST_TBL(l_count).BILLED_PRIN  > 0 or
           P_PAY_HIST_TBL(l_count).BILLED_INT > 0 or
           P_PAY_HIST_TBL(l_count).BILLED_FEE > 0
        THEN

            l_bill_headers_tbl.delete;
            l_bill_lines_tbl.delete;

            logmessage(fnd_log.level_statement,   'Creating bill ' || P_PAY_HIST_TBL(l_count).PAYMENT_NUMBER || ' ' || P_PAY_HIST_TBL(l_count).SOURCE || '...');
            l_bill_headers_tbl(1).header_id := 101;
            l_bill_headers_tbl(1).loan_id := l_loan_id;
            l_bill_headers_tbl(1).assoc_payment_num := P_PAY_HIST_TBL(l_count).PAYMENT_NUMBER;
            l_bill_headers_tbl(1).due_date := P_PAY_HIST_TBL(l_count).DUE_DATE;

            l_lines_count := 0;

            IF(P_PAY_HIST_TBL(l_count).BILLED_PRIN > 0) THEN
                l_lines_count := l_lines_count + 1;
                l_bill_lines_tbl(l_lines_count).line_id := 100 + l_lines_count;
                l_bill_lines_tbl(l_lines_count).header_id := l_bill_headers_tbl(1).header_id;
                l_bill_lines_tbl(l_lines_count).line_amount := P_PAY_HIST_TBL(l_count).BILLED_PRIN;
                l_bill_lines_tbl(l_lines_count).line_type := 'PRIN';
                l_bill_lines_tbl(l_lines_count).line_desc := P_Loan_Details_Rec.legacy_reference;
                logmessage(fnd_log.level_statement, 'Principal = ' || l_bill_lines_tbl(l_lines_count).line_amount);
            END IF;

            IF(P_PAY_HIST_TBL(l_count).BILLED_INT > 0) THEN
                l_lines_count := l_lines_count + 1;
                l_bill_lines_tbl(l_lines_count).line_id := 100 + l_lines_count;
                l_bill_lines_tbl(l_lines_count).header_id := l_bill_headers_tbl(1).header_id;
                l_bill_lines_tbl(l_lines_count).line_amount := P_PAY_HIST_TBL(l_count).BILLED_INT;
                l_bill_lines_tbl(l_lines_count).line_type := 'INT';
                l_bill_lines_tbl(l_lines_count).line_desc := P_Loan_Details_Rec.legacy_reference;
                logmessage(fnd_log.level_statement, 'Interest = ' || l_bill_lines_tbl(l_lines_count).line_amount);
            END IF;

            IF(P_PAY_HIST_TBL(l_count).BILLED_FEE > 0) THEN
                l_lines_count := l_lines_count + 1;
                l_bill_lines_tbl(l_lines_count).line_id := 100 + l_lines_count;
                l_bill_lines_tbl(l_lines_count).header_id := l_bill_headers_tbl(1).header_id;
                l_bill_lines_tbl(l_lines_count).line_amount := P_PAY_HIST_TBL(l_count).BILLED_FEE;
                l_bill_lines_tbl(l_lines_count).line_type := 'FEE';
                l_bill_lines_tbl(l_lines_count).line_desc := P_Loan_Details_Rec.legacy_reference;
                logmessage(fnd_log.level_statement, 'Fees = ' || l_bill_lines_tbl(l_lines_count).line_amount);
            END IF;

            LNS_BILLING_BATCH_PUB.CREATE_OFFCYCLE_BILLS(
                P_API_VERSION		    => 1.0,
                P_INIT_MSG_LIST		    => FND_API.G_FALSE,
                P_COMMIT			    => FND_API.G_FALSE,
                P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
                P_BILL_HEADERS_TBL      => l_BILL_HEADERS_TBL,
                P_BILL_LINES_TBL        => l_BILL_LINES_TBL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

            IF l_return_status <> 'S' THEN
                RAISE fnd_api.g_exc_error;
            END IF;

            logmessage(fnd_log.level_unexpected, 'Bill ' || P_PAY_HIST_TBL(l_count).PAYMENT_NUMBER || ' created successfully');

            if P_PAY_HIST_TBL(l_count).SOURCE = 'SCHEDULED' then

                UPDATE lns_amortization_scheds
                SET parent_amortization_id = NULL,
                REAMORTIZE_TO_INSTALLMENT = -1     -- marking this record as IMPORTED (-1); for original installments this field is always null
                WHERE amortization_schedule_id =
                (SELECT last_amortization_id
                FROM lns_loan_headers_all
                WHERE loan_id = l_loan_id);
                logmessage(fnd_log.level_statement,   'Updated lns_amortization_scheds');

            else

                UPDATE lns_amortization_scheds
                SET REAMORTIZE_TO_INSTALLMENT = -1     -- marking this record as IMPORTED (-1); for original installments this field is always null
                WHERE amortization_schedule_id =
                (SELECT last_amortization_id
                FROM lns_loan_headers_all
                WHERE loan_id = l_loan_id);
                logmessage(fnd_log.level_statement,   'Updated lns_amortization_scheds');

            end if;

            l_paid_total := P_PAY_HIST_TBL(l_count).PAID_PRIN + P_PAY_HIST_TBL(l_count).PAID_INT + P_PAY_HIST_TBL(l_count).PAID_FEE;

            if l_paid_total > 0 then

                if P_PAY_HIST_TBL(l_count).RC_ID is null then

                    logmessage(fnd_log.level_statement,   'Creating cash receipt...');
                    AR_RECEIPT_API_PUB.CREATE_CASH(
                                P_API_VERSION => 1.0,
                                P_INIT_MSG_LIST => FND_API.G_FALSE,
                                P_COMMIT => FND_API.G_FALSE,
                                P_CURRENCY_CODE => P_Loan_Details_Rec.LOAN_CURRENCY,
                                P_EXCHANGE_RATE_TYPE => P_Loan_Details_Rec.EXCHANGE_RATE_TYPE,
                                P_EXCHANGE_RATE => P_Loan_Details_Rec.EXCHANGE_RATE,
                                P_EXCHANGE_RATE_DATE => P_Loan_Details_Rec.EXCHANGE_DATE,
                                P_AMOUNT => l_paid_total,
                                P_RECEIPT_DATE => P_PAY_HIST_TBL(l_count).PAID_DATE,
                                P_RECEIPT_METHOD_ID => P_PAY_HIST_TBL(l_count).RC_METHOD_ID,
                                P_RECEIPT_NUMBER => P_Loan_Details_Rec.LEGACY_REFERENCE || ' - '|| l_loan_number,
                                P_CUSTOMER_ID => P_Loan_Details_Rec.CUST_ACCOUNT_ID,
                                P_CR_ID => l_cr_id,
                                X_RETURN_STATUS => L_RETURN_STATUS,
                                X_MSG_COUNT => L_MSG_COUNT,
                                X_MSG_DATA => L_MSG_DATA);

                    IF l_return_status <> 'S' THEN
                        RAISE fnd_api.g_exc_error;
                    END IF;

                    logmessage(fnd_log.level_unexpected,   'Cash receipt created successfully; id = ' || l_cr_id);
                ELSE
                    l_cr_id := P_PAY_HIST_TBL(l_count).RC_ID;
                    logmessage(fnd_log.level_statement,   'Using passed cash receipt id = ' || l_cr_id);
                END IF;

                SELECT principal_trx_id,
                interest_trx_id,
                fee_trx_id
                INTO l_principal_trx_id,
                l_interest_trx_id,
                l_fee_trx_id
                FROM lns_amortization_scheds
                WHERE amortization_schedule_id =
                (SELECT last_amortization_id
                FROM lns_loan_headers_all
                WHERE loan_id = l_loan_id);

                -- applying cash receipt
                IF(P_PAY_HIST_TBL(l_count).BILLED_PRIN  > 0 AND
                   P_PAY_HIST_TBL(l_count).PAID_PRIN > 0 AND
                   l_principal_trx_id IS NOT NULL) THEN

                    logmessage(fnd_log.level_statement,   'Paying principal amount ' || P_PAY_HIST_TBL(l_count).PAID_PRIN ||' for transactionId ' || l_principal_trx_id);
                    AR_RECEIPT_API_PUB.APPLY(P_API_VERSION                 => 1.0
                                            ,P_INIT_MSG_LIST               => FND_API.G_FALSE
                                            ,P_COMMIT                      => FND_API.G_FALSE
                                            ,X_RETURN_STATUS               => l_return_status
                                            ,X_MSG_COUNT                   => l_msg_count
                                            ,X_MSG_DATA                    => l_msg_data
                                            ,p_cash_receipt_id             => l_cr_id
                                            ,p_customer_trx_id             => l_PRINCIPAL_TRX_ID
                                            ,p_apply_date                  => P_PAY_HIST_TBL(l_count).PAID_DATE
                                            --,p_apply_gl_date               => l_apply_date + nvl(g_day_togl_after_dd, 0)
                                            ,p_amount_applied              => P_PAY_HIST_TBL(l_count).PAID_PRIN
                                            --,p_amount_applied_from         => l_receipt_amount_from
                                            --,p_trans_to_receipt_rate       => l_trans_to_receipt_rate
                                            );

                    IF l_return_status <> 'S' THEN
                        fnd_message.set_name('LNS',   'LNS_APPL_CR_FAIL');
                        fnd_msg_pub.ADD;
                        logmessage(fnd_log.level_unexpected,   fnd_msg_pub.GET(p_encoded => 'F'));
                        RAISE fnd_api.g_exc_error;
                    END IF;

                    logmessage(fnd_log.level_unexpected,   'Principal paid successfully');

                END IF;

                IF(P_PAY_HIST_TBL(l_count).BILLED_INT > 0 AND
                   P_PAY_HIST_TBL(l_count).PAID_INT > 0 AND
                   l_interest_trx_id IS NOT NULL) THEN

                    logmessage(fnd_log.level_statement,   'Paying interest amount ' || P_PAY_HIST_TBL(l_count).PAID_INT || ' with transactionid ' || l_interest_trx_id);

                    AR_RECEIPT_API_PUB.APPLY(P_API_VERSION                 => 1.0
                                            ,P_INIT_MSG_LIST               => FND_API.G_FALSE
                                            ,P_COMMIT                      => FND_API.G_FALSE
                                            ,X_RETURN_STATUS               => l_return_status
                                            ,X_MSG_COUNT                   => l_msg_count
                                            ,X_MSG_DATA                    => l_msg_data
                                            ,p_cash_receipt_id             => l_cr_id
                                            ,p_customer_trx_id             => l_INTEREST_TRX_ID
                                            ,p_apply_date                  => P_PAY_HIST_TBL(l_count).PAID_DATE
                                            --,p_apply_gl_date               => l_apply_date + nvl(g_day_togl_after_dd, 0)
                                            ,p_amount_applied              => P_PAY_HIST_TBL(l_count).PAID_INT
                                            --,p_amount_applied_from         => l_receipt_amount_from
                                            --,p_trans_to_receipt_rate       => l_trans_to_receipt_rate
                                            );

                    IF l_return_status <> 'S' THEN
                        fnd_message.set_name('LNS',   'LNS_APPL_CR_FAIL');
                        fnd_msg_pub.ADD;
                        logmessage(fnd_log.level_unexpected,   fnd_msg_pub.GET(p_encoded => 'F'));
                        RAISE fnd_api.g_exc_error;
                    END IF;

                    logmessage(fnd_log.level_unexpected,   'Interest paid successfully');

                END IF;

                IF(P_PAY_HIST_TBL(l_count).BILLED_FEE > 0 AND
                   P_PAY_HIST_TBL(l_count).PAID_FEE > 0 AND
                   l_fee_trx_id IS NOT NULL) THEN

                    logmessage(fnd_log.level_statement,   'Paying fee amount ' || P_PAY_HIST_TBL(l_count).PAID_FEE || ' with transactionid ' || l_fee_trx_id);

                    AR_RECEIPT_API_PUB.APPLY(P_API_VERSION                 => 1.0
                                        ,P_INIT_MSG_LIST               => FND_API.G_FALSE
                                        ,P_COMMIT                      => FND_API.G_FALSE
                                        ,X_RETURN_STATUS               => l_return_status
                                        ,X_MSG_COUNT                   => l_msg_count
                                        ,X_MSG_DATA                    => l_msg_data
                                        ,p_cash_receipt_id             => l_cr_id
                                        ,p_customer_trx_id             => l_FEE_TRX_ID
                                        ,p_apply_date                  => P_PAY_HIST_TBL(l_count).PAID_DATE
                                        --,p_apply_gl_date               => l_apply_date + nvl(g_day_togl_after_dd, 0)
                                        ,p_amount_applied              => P_PAY_HIST_TBL(l_count).PAID_FEE
                                        --,p_amount_applied_from         => l_receipt_amount_from
                                        --,p_trans_to_receipt_rate       => l_trans_to_receipt_rate
                                        );

                    IF l_return_status <> 'S' THEN
                        fnd_message.set_name('LNS',   'LNS_APPL_CR_FAIL');
                        fnd_msg_pub.ADD;
                        logmessage(fnd_log.level_unexpected,   fnd_msg_pub.GET(p_encoded => 'F'));
                        RAISE fnd_api.g_exc_error;
                    END IF;

                    logmessage(fnd_log.level_unexpected,   'Fee paid successfully');

                END IF;

            END IF;  --if l_paid_total > 0 then

        END IF; -- IF P_PAY_HIST_TBL(l_count).BILLED_PRIN  > 0 or...

    END LOOP;

    -- updating lns_terms
    SELECT object_version_number, term_id
    INTO l_version_number, l_term_id
    FROM lns_terms
    WHERE loan_id = l_loan_id;

    l_term_rec.term_id := l_term_id;
    l_term_rec.loan_id := l_loan_id;
    l_term_rec.next_payment_due_date := P_Loan_Details_Rec.next_payment_due_date;

    lns_terms_pub.update_term(p_object_version_number => l_version_number
                            , p_init_msg_list => fnd_api.g_false
                            , p_loan_term_rec => l_term_rec
                            , x_return_status => l_return_status
                            , x_msg_count => l_msg_count
                            , x_msg_data => l_msg_data);

    IF l_return_status <> 'S' THEN
        --        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Failed to update term object.');
        fnd_message.set_name('LNS',   'LNS_IMRT_FAIL_UPD_TERM');
        fnd_msg_pub.ADD;
        logmessage(fnd_log.level_unexpected,   fnd_msg_pub.GET(p_encoded => 'F'));
        RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.level_unexpected,   'Term object updated successfully');

    -- if rate_type = 'FLOATING', run UPDATE_LOAN_FLOATING_RATE
    if P_Loan_Details_Rec.RATE_TYPE = 'FLOATING' then

        logmessage(fnd_log.level_statement,   'Updating floating rate schedule...');
        LNS_INDEX_RATES_PUB.UPDATE_LOAN_FLOATING_RATE(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_FALSE,
            P_COMMIT		        => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID               => l_loan_id,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        logmessage(fnd_log.LEVEL_UNEXPECTED,   'Floating rate schedule updated successfully');

        -- fetching new rate schedule
        p_LOAN_RATES_TBL.delete;
        i := 0;
        open c_get_rate_sch_info(l_term_id);
        LOOP

            fetch c_get_rate_sch_info into
                l_LOAN_RATES_REC.BEGIN_INSTALLMENT_NUMBER,
                l_LOAN_RATES_REC.END_INSTALLMENT_NUMBER,
                l_LOAN_RATES_REC.INDEX_DATE,
                l_LOAN_RATES_REC.INDEX_RATE,
                l_LOAN_RATES_REC.SPREAD,
                l_LOAN_RATES_REC.INTEREST_ONLY_FLAG;
            exit when c_get_rate_sch_info%NOTFOUND;

            i := i + 1;
            p_LOAN_RATES_TBL(i) := l_LOAN_RATES_REC;

        END LOOP;
        close c_get_rate_sch_info;

    end if;

    IF p_commit = fnd_api.g_true THEN
        COMMIT WORK;
        logmessage(fnd_log.level_statement,   'Commited');
    END IF;

    x_loan_id := l_loan_id;

    -- END OF BODY OF API
    x_return_status := fnd_api.g_ret_sts_success;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        --InsertErrors;
        ROLLBACK TO import_loan;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
        X_RETURN_STATUS := 'E';
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END IMPORT_LOAN;



BEGIN
    G_LOG_ENABLED := 'N';
    G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

END;

/
