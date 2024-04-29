--------------------------------------------------------
--  DDL for Package Body LNS_LOAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_LOAN_PUB" as
/* $Header: LNS_LOAN_PUBP_B.pls 120.11.12010000.6 2010/02/24 01:58:19 mbolli ship $ */

 /*========================================================================
 | PUBLIC PROCEDURE SELECT_WF_PROCESS
 |
 | DESCRIPTION
 |      This process selects the process to run.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_PARAM1                    IN          Standard in parameter
 |      X_PARAM2                    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2006           GBELLARY          Created
 | 17-Apr-2007           MBOLLI            Modified- Bug#5923205
 |
 *=======================================================================*/


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                CONSTANT VARCHAR2(30):= 'LNS_LOAN_PUB';
    G_LOG_ENABLED             varchar2(5);
    G_MSG_LEVEL               NUMBER;
    g_org_id                  number;
    g_errors_rec              Loan_create_errors_type := Loan_create_errors_type();
    g_error_count             number := 0;

    CURSOR Csr_Product_values (p_product_id IN NUMBER) IS
       SELECT loan_type.loan_type_id loan_type_id
             ,loan_type.loan_class_code loan_class_code
             ,loan_type.loan_type_name loan_type_name
             ,loan_type.multiple_funding_flag multiple_funding_flag
             ,loan_type.open_to_term_flag open_to_term_flag
             ,loan_type.credit_review_flag credit_review_flag
             ,loan_product.loan_product_id loan_product_id
             ,loan_product.loan_product_name loan_product_name
             ,loan_product.loan_term loan_term
             ,loan_product.loan_term_period loan_term_period
             ,loan_product.max_loan_term max_loan_term
             ,loan_product.max_loan_term_period max_loan_term_period
             ,loan_product.loan_currency loan_currency
             ,loan_product.requested_amount requested_amount
             ,loan_product.max_requested_amount max_requested_amount
             ,loan_product.index_rate_id index_rate_id
             ,loan_product.rate_type rate_type
             ,loan_product.spread spread
             ,loan_product.floor_rate floor_rate
             ,loan_product.ceiling_rate ceiling_rate
             ,loan_product.interest_compounding_freq interest_compounding_freq
             ,loan_product.loan_payment_frequency loan_payment_frequency
             ,loan_product.loan_subtype loan_subtype
             ,loan_product.collateral_percent collateral_percent
             ,loan_product.allow_interest_only_flag allow_interest_only_flag
             ,loan_product.reamortize_over_payment reamortize_over_payment
             ,loan_product.org_id org_id
             ,loan_product.legal_entity_id legal_entity_id
             ,loan_product.rate_change_frequency rate_change_frequency
             ,loan_type.payment_application_order payment_application_order
             ,loan_type.pmt_appl_order_scope pmt_appl_order_scope
             ,loan_product.open_floor_rate open_floor_rate
             ,loan_product.open_ceiling_rate open_ceiling_rate
             ,loan_product.reamortize_under_payment reamortize_under_payment
             ,loan_product.percent_increase percent_increase
             ,loan_product.percent_increase_life percent_increase_life
             ,loan_product.open_percent_increase open_percent_increase
             ,loan_product.open_percent_increase_life open_percent_increase_life
             ,loan_product.open_spread open_spread
             ,loan_product.credit_review_type credit_review_type
             ,loan_product.guarantor_review_type guarantor_review_type
	         ,loan_product.party_type party_type
             ,loan_product.open_loan_term open_loan_term
             ,loan_product.open_loan_term_period open_loan_term_period
             ,loan_product.open_max_loan_term open_max_loan_term
             ,loan_product.open_max_loan_term_period open_max_loan_term_period
             ,loan_product.interest_calculation_method CALCULATION_METHOD
             ,loan_product.day_count_method day_count_method
             ,loan_product.FORGIVENESS_FLAG
             ,loan_product.FORGIVENESS_PERCENT
       FROM   lns_loan_types loan_type
             ,lns_loan_products loan_product
       WHERE  loan_product.loan_product_id = p_product_id
       AND    loan_type.loan_type_id = loan_product.loan_type_id
       AND    loan_type.status = 'COMPLETE'
       AND    loan_type.start_date_active <= sysdate
       AND    (loan_type.end_date_active is null OR
               loan_type.end_date_active >= sysdate)
       AND    loan_product.status = 'COMPLETE'
       AND    loan_product.start_date_active <= sysdate
       AND    (loan_product.end_date_active is null OR
               loan_product.end_date_active >= sysdate);

    l_product_rec Csr_Product_values%ROWTYPE;

    CURSOR Csr_override_flags (p_product_id IN NUMBER) IS
       SELECT  LEGAL_ENTITY_ID_TBL.flag LEGAL_ENTITY_ID_OVR
              ,LOAN_TERM_TBL.flag LOAN_TERM_OVR
              ,LOAN_TERM_PERIOD_TBL.flag LOAN_TERM_PERIOD_OVR
              ,INDEX_RATE_ID_TBL.flag INDEX_RATE_ID_OVR
              ,RATE_TYPE_TBL.flag RATE_TYPE_OVR
              ,INTEREST_COMPOUNDING_FREQ_TBL.flag INTEREST_COMPOUNDING_FREQ_OVR
              ,OPEN_SPREAD_TBL.flag OPEN_SPREAD_OVR
              ,OPEN_FLOOR_RATE_TBL.flag OPEN_FLOOR_RATE_OVR
              ,OPEN_CEILING_RATE_TBL.flag OPEN_CEILING_RATE_OVR
              ,OPEN_PERCENT_INCREASE_TBL.flag OPEN_PERCENT_INCREASE_OVR
              ,OPEN_PERCENT_INCREASE_LIFE_TBL.flag OPEN_PERCENT_INCREASE_LIFE_OVR
              ,SPREAD_TBL.flag SPREAD_OVR
              ,FLOOR_RATE_TBL.flag FLOOR_RATE_OVR
              ,CEILING_RATE_TBL.flag CEILING_RATE_OVR
              ,PERCENT_INCREASE_TBL.flag PERCENT_INCREASE_OVR
              ,PERCENT_INCREASE_LIFE_TBL.flag PERCENT_INCREASE_LIFE_OVR
              ,LOAN_PAYMENT_FREQUENCY_TBL.flag LOAN_PAYMENT_FREQ_OVR
              ,LOAN_SUBTYPE_TBL.flag LOAN_SUBTYPE_OVR
              ,REAMORTIZE_OVER_PAYMENT_TBL.flag REAMORTIZE_OVER_PAYMENT_OVR
              ,DAY_COUNT_METHOD_TBL.flag DAY_COUNT_METHOD_OVR
              ,CALCULATION_METHOD_TBL.flag CALCULATION_METHOD_OVR
              ,RATE_CHANGE_FREQUENCY_TBL.flag RATE_CHANGE_FREQUENCY_OVR
              ,COLLATERAL_PERCENT_TBL.flag COLLATERAL_PERCENT_OVR
              ,FORGIVENESS_FLAG_TBL.flag FORGIVENESS_FLAG_OVR
              ,FORGIVENESS_PERCENT_TBL.flag FORGIVENESS_PERCENT_OVR
        FROM  (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'LEGAL_ENTITY_ID'
              ) LEGAL_ENTITY_ID_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'LOAN_TERM'
              ) LOAN_TERM_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'LOAN_TERM_PERIOD'
              ) LOAN_TERM_PERIOD_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'INDEX_RATE_ID'
              ) INDEX_RATE_ID_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'RATE_TYPE'
              ) RATE_TYPE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'INTEREST_COMPOUNDING_FREQ'
              ) INTEREST_COMPOUNDING_FREQ_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'OPEN_SPREAD'
              ) OPEN_SPREAD_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'OPEN_FLOOR_RATE'
              ) OPEN_FLOOR_RATE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'OPEN_CEILING_RATE'
              ) OPEN_CEILING_RATE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'OPEN_PERCENT_INCREASE'
              ) OPEN_PERCENT_INCREASE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'OPEN_PERCENT_INCREASE_LIFE'
              ) OPEN_PERCENT_INCREASE_LIFE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'SPREAD'
              ) SPREAD_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'FLOOR_RATE'
              ) FLOOR_RATE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'CEILING_RATE'
              ) CEILING_RATE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'PERCENT_INCREASE'
              ) PERCENT_INCREASE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'PERCENT_INCREASE_LIFE'
              ) PERCENT_INCREASE_LIFE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'LOAN_PAYMENT_FREQUENCY'
              ) LOAN_PAYMENT_FREQUENCY_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'LOAN_SUBTYPE'
              ) LOAN_SUBTYPE_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'REAMORTIZE_OVER_PAYMENT'
              ) REAMORTIZE_OVER_PAYMENT_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'DAY_COUNT_METHOD'
              ) DAY_COUNT_METHOD_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'INTEREST_CALCULATION_METHOD'
              ) CALCULATION_METHOD_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'RATE_CHANGE_FREQUENCY'
              ) RATE_CHANGE_FREQUENCY_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'COLLATERAL_PERCENT'
              ) COLLATERAL_PERCENT_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'FORGIVENESS_FLAG'
              ) FORGIVENESS_FLAG_TBL,
              (SELECT DECODE(COUNT(*),0,'Y','N') flag
               FROM   LNS_LOAN_PRODUCT_FLAGS
               WHERE loan_product_id = p_product_id
               AND READONLY_COLUMN_NAME = 'FORGIVENESS_PERCENT'
              ) FORGIVENESS_PERCENT_TBL;

    l_override_rec Csr_override_flags%ROWTYPE;

    PROCEDURE validate_loan_header_details(P_Loan_Details_Rec  IN OUT NOCOPY LNS_LOAN_PUB.Loan_Details_Rec_Type
                                           ,p_loan_cust_sched_tbl   IN OUT NOCOPY LNS_LOAN_PUB.loan_cust_sched_tbl_type
                                           ,x_return_status OUT nocopy VARCHAR2
                                           ,x_msg_count OUT nocopy NUMBER
                                           ,x_msg_data OUT nocopy VARCHAR2);

    PROCEDURE validate_participants(p_loan_part_tbl IN OUT NOCOPY LNS_LOAN_PUB.LOAN_PART_TBL_TYPE
                                    ,x_return_status OUT nocopy VARCHAR2
                                    ,x_msg_count OUT nocopy NUMBER
                                    ,x_msg_data OUT nocopy VARCHAR2);

    PROCEDURE validate_loan_lines(P_Loan_Details_Rec IN OUT NOCOPY LNS_LOAN_PUB.Loan_Details_Rec_Type
                                ,p_loan_lines_tbl IN OUT nocopy LNS_LOAN_PUB.loan_lines_tbl_type
                                ,x_return_status OUT nocopy VARCHAR2
                                ,x_msg_count OUT nocopy NUMBER
                                ,x_msg_data OUT nocopy VARCHAR2);

    PROCEDURE validate_rate_sched(P_Loan_Details_Rec IN OUT NOCOPY LNS_LOAN_PUB.Loan_Details_Rec_Type
                                ,p_loan_rates_tbl IN OUT nocopy LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE
                                ,p_phase IN VARCHAR2
                                ,x_return_status OUT nocopy VARCHAR2
                                ,x_msg_count OUT nocopy NUMBER
                                ,x_msg_data OUT nocopy VARCHAR2);

    procedure synchRateSchedule(p_rate_tbl IN OUT NOCOPY LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE, p_num_installments in number);

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




PROCEDURE validate_loan_header_details(P_Loan_Details_Rec  IN OUT NOCOPY LNS_LOAN_PUB.Loan_Details_Rec_Type
                                       ,p_loan_cust_sched_tbl   IN OUT NOCOPY LNS_LOAN_PUB.loan_cust_sched_tbl_type
                                       ,x_return_status OUT nocopy VARCHAR2
                                       ,x_msg_count OUT nocopy NUMBER
                                       ,x_msg_data OUT nocopy VARCHAR2)
IS

    l_api_name constant VARCHAR2(30) := 'VALIDATE_LOAN_HEADER_DETAILS';
    l_dummy VARCHAR2(30);
    l_exchange_required VARCHAR2(1);
    l_functional_currency gl_sets_of_books.currency_code%TYPE;
    l_borrower_valid boolean;
    l_cust_acct_valid boolean;
    l_contact_rel_party_id lns_loan_headers_all.contact_rel_party_id%TYPE;
    l_contact_pers_party_id lns_loan_headers_all.contact_pers_party_id%TYPE;
    l_valid_contact_rel VARCHAR2(1) := 'N';
    l_valid_contact_pers VARCHAR2(1) := 'N';

BEGIN
    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' +');

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan_Details_Rec:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'product_id = ' || P_Loan_Details_Rec.product_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_number = ' || P_Loan_Details_Rec.loan_number);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_description = ' || P_Loan_Details_Rec.loan_description);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_assigned_to = ' || P_Loan_Details_Rec.loan_assigned_to);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'legal_entity_id = ' || P_Loan_Details_Rec.legal_entity_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'requested_amount = ' || P_Loan_Details_Rec.requested_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_application_date = ' || P_Loan_Details_Rec.loan_application_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'exchange_rate_type = ' || P_Loan_Details_Rec.exchange_rate_type);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'exchange_rate = ' || P_Loan_Details_Rec.exchange_rate);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'exchange_date = ' || P_Loan_Details_Rec.exchange_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_purpose_code = ' || P_Loan_Details_Rec.loan_purpose_code);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_subtype = ' || P_Loan_Details_Rec.loan_subtype);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'credit_review_flag = ' || P_Loan_Details_Rec.credit_review_flag);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'trx_type_id = ' || P_Loan_Details_Rec.trx_type_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'collateral_percent = ' || P_Loan_Details_Rec.collateral_percent);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOM_PAYMENTS_FLAG = ' || P_Loan_Details_Rec.CUSTOM_PAYMENTS_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_FLAG = ' || P_Loan_Details_Rec.FORGIVENESS_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_PERCENT = ' || P_Loan_Details_Rec.FORGIVENESS_PERCENT);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'primary_borrower_party_id = ' || P_Loan_Details_Rec.primary_borrower_party_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'cust_account_id = ' || P_Loan_Details_Rec.cust_account_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'bill_to_acct_site_id = ' || P_Loan_Details_Rec.bill_to_acct_site_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'contact_rel_party_id = ' || P_Loan_Details_Rec.contact_rel_party_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CONTACT_PERS_PARTY_ID = ' || P_Loan_Details_Rec.CONTACT_PERS_PARTY_ID);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RATE_TYPE = ' || P_Loan_Details_Rec.RATE_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'index_rate_id = ' || P_Loan_Details_Rec.index_rate_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DAY_COUNT_METHOD = ' || P_Loan_Details_Rec.DAY_COUNT_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_payment_frequency = ' || P_Loan_Details_Rec.loan_payment_frequency);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CALCULATION_METHOD = ' || P_Loan_Details_Rec.CALCULATION_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INTEREST_COMPOUNDING_FREQ = ' || P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_CALC_METHOD = ' || P_Loan_Details_Rec.PAYMENT_CALC_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CUSTOM_CALC_METHOD = ' || P_Loan_Details_Rec.CUSTOM_CALC_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ORIG_PAY_CALC_METHOD = ' || P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PENAL_INT_RATE = ' || P_Loan_Details_Rec.PENAL_INT_RATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PENAL_INT_GRACE_DAYS = ' || P_Loan_Details_Rec.PENAL_INT_GRACE_DAYS);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOCK_DATE = ' || P_Loan_Details_Rec.LOCK_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOCK_EXP_DATE = ' || P_Loan_Details_Rec.LOCK_EXP_DATE);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'REAMORTIZE_OVER_PAYMENT = ' || P_Loan_Details_Rec.REAMORTIZE_OVER_PAYMENT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DELINQUENCY_THRESHOLD_AMOUNT = ' || P_Loan_Details_Rec.DELINQUENCY_THRESHOLD_AMOUNT);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_APPLICATION_ORDER = ' || P_Loan_Details_Rec.PAYMENT_APPLICATION_ORDER);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_term = ' || P_Loan_Details_Rec.loan_term);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_term_period = ' || P_Loan_Details_Rec.loan_term_period);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'balloon_payment_type = ' || P_Loan_Details_Rec.balloon_payment_type);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'balloon_payment_amount = ' || P_Loan_Details_Rec.balloon_payment_amount);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'balloon_term = ' || P_Loan_Details_Rec.balloon_term);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_start_date = ' || P_Loan_Details_Rec.loan_start_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FIRST_PAYMENT_DATE = ' || P_Loan_Details_Rec.FIRST_PAYMENT_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIN_FIRST_PAY_DATE = ' || P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIN_PAYMENT_FREQUENCY = ' || P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'floor_rate = ' || P_Loan_Details_Rec.floor_rate);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ceiling_rate = ' || P_Loan_Details_Rec.ceiling_rate);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'percent_increase = ' || P_Loan_Details_Rec.percent_increase);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'percent_increase_life = ' || P_Loan_Details_Rec.percent_increase_life);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_term = ' || P_Loan_Details_Rec.open_loan_term);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_term_period = ' || P_Loan_Details_Rec.open_loan_term_period);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_start_date = ' || P_Loan_Details_Rec.open_loan_start_date);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_to_term_event = ' || P_Loan_Details_Rec.open_to_term_event);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_floor_rate = ' || P_Loan_Details_Rec.open_floor_rate);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_ceiling_rate = ' || P_Loan_Details_Rec.open_ceiling_rate);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_percent_increase = ' || P_Loan_Details_Rec.open_percent_increase);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_percent_increase_life = ' || P_Loan_Details_Rec.open_percent_increase_life);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE_CATEGORY = ' || P_Loan_Details_Rec.ATTRIBUTE_CATEGORY);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE1 = ' || P_Loan_Details_Rec.ATTRIBUTE1);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE2 = ' || P_Loan_Details_Rec.ATTRIBUTE2);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE3 = ' || P_Loan_Details_Rec.ATTRIBUTE3);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE4 = ' || P_Loan_Details_Rec.ATTRIBUTE4);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE5 = ' || P_Loan_Details_Rec.ATTRIBUTE5);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE6 = ' || P_Loan_Details_Rec.ATTRIBUTE6);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE7 = ' || P_Loan_Details_Rec.ATTRIBUTE7);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE8 = ' || P_Loan_Details_Rec.ATTRIBUTE8);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE9 = ' || P_Loan_Details_Rec.ATTRIBUTE9);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE10 = ' || P_Loan_Details_Rec.ATTRIBUTE10);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE11 = ' || P_Loan_Details_Rec.ATTRIBUTE11);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE12 = ' || P_Loan_Details_Rec.ATTRIBUTE12);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE13 = ' || P_Loan_Details_Rec.ATTRIBUTE13);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE14 = ' || P_Loan_Details_Rec.ATTRIBUTE14);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE15 = ' || P_Loan_Details_Rec.ATTRIBUTE15);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE16 = ' || P_Loan_Details_Rec.ATTRIBUTE16);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE17 = ' || P_Loan_Details_Rec.ATTRIBUTE17);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE18 = ' || P_Loan_Details_Rec.ATTRIBUTE18);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE19 = ' || P_Loan_Details_Rec.ATTRIBUTE19);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ATTRIBUTE20 = ' || P_Loan_Details_Rec.ATTRIBUTE20);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating loan_assigned_to...');

    -- Validate loan_assigned_to
    IF P_Loan_Details_Rec.loan_assigned_to IS NULL THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.loan_assigned_to');
    ELSE
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   jtf_rs_resource_extns res
            WHERE  res.resource_id = P_Loan_Details_Rec.loan_assigned_to
            AND    res.category = 'EMPLOYEE'
                AND    res.start_date_active <= SYSDATE
                AND    (res.end_date_active is null or res.end_date_active >= SYSDATE);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.loan_assigned_to'
                    ,p_token2=>P_Loan_Details_Rec.loan_assigned_to);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating legal_entity_id...');

    -- Validate Legal Entity Id
    P_Loan_Details_Rec.legal_entity_id :=
                CASE l_override_rec.legal_entity_id_ovr
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.legal_entity_id, l_product_rec.legal_entity_id)
                ELSE l_product_rec.legal_entity_id
                END;

    IF P_Loan_Details_Rec.legal_entity_id IS NULL THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.legal_entity_id');
    ELSIF P_Loan_Details_Rec.legal_entity_id IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   xle_entity_profiles xep
            WHERE  xep.legal_entity_id = P_Loan_Details_Rec.legal_entity_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.legal_entity_id'
                    ,p_token2=>P_Loan_Details_Rec.legal_entity_id);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating requested_amount...');

    -- Validate Requested Amount
    P_Loan_Details_Rec.requested_amount :=
                CASE l_product_rec.loan_class_code
                WHEN 'DIRECT' THEN  nvl(P_Loan_Details_Rec.requested_amount, l_product_rec.requested_amount)
                WHEN 'ERS' THEN 0
                END;

    IF l_product_rec.loan_class_code <> 'ERS' AND
        (P_Loan_Details_Rec.requested_amount is null OR
        P_Loan_Details_Rec.requested_amount = 0 OR
        P_Loan_Details_Rec.requested_amount < nvl(l_product_rec.requested_amount, P_Loan_Details_Rec.requested_amount) OR
        P_Loan_Details_Rec.requested_amount > nvl(l_product_rec.max_requested_amount, P_Loan_Details_Rec.requested_amount))
    THEN
            LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_BETWEEN'
                    ,p_token1=>'P_Loan_Details_Rec.requested_amount'
                    ,p_token2=>l_product_rec.max_requested_amount
                    ,p_token3=>l_product_rec.requested_amount);
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating loan_purpose_code...');

    -- Validate Loan Purpose Code
    if P_Loan_Details_Rec.loan_purpose_code is null then
        P_Loan_Details_Rec.loan_purpose_code := 'OTHER';
    end if;

    IF P_Loan_Details_Rec.loan_purpose_code IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   lns_lookups llk
            WHERE  llk.lookup_code = P_Loan_Details_Rec.loan_purpose_code
            AND    llk.lookup_type = 'LOAN_PURPOSE';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.loan_purpose_code'
                    ,p_token2=>P_Loan_Details_Rec.loan_purpose_code);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating credit_review_flag...');

    if P_Loan_Details_Rec.credit_review_flag is null then
        P_Loan_Details_Rec.credit_review_flag := l_product_rec.credit_review_flag;
    end if;

    -- Validate Credit Review Flag
    IF P_Loan_Details_Rec.credit_review_flag IS NOT NULL
        AND P_Loan_Details_Rec.credit_review_flag NOT IN ('Y','N')
    THEN
        LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                ,p_token1=>'P_Loan_Details_Rec.credit_review_flag'
                ,p_token2=>P_Loan_Details_Rec.credit_review_flag);
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating currency...');

    -- Validate Currency
    SELECT glsob.currency_code
            INTO l_functional_currency
    FROM gl_sets_of_books glsob,
            lns_system_options_all lso
    WHERE glsob.set_of_books_id = lso.set_of_books_id
    AND lso.org_id = l_product_rec.org_id;

    IF l_functional_currency <> l_product_rec.loan_currency THEN
        l_exchange_required := 'Y';
    END IF;

    IF l_exchange_required = 'Y' THEN

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating exchange_rate_type and exchange_date...');
        IF P_Loan_Details_Rec.exchange_rate_type IS NULL THEN
            LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_Loan_Details_Rec.exchange_rate_type');
        ELSE
            BEGIN
                SELECT 'Y'
                INTO l_dummy
                FROM gl_daily_conversion_types gdct
                WHERE gdct.conversion_type = P_Loan_Details_Rec.exchange_rate_type;

            EXCEPTION
            WHEN no_data_found THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.exchange_rate_type'
                        ,p_token2=>P_Loan_Details_Rec.exchange_rate_type);
            END;
        END IF;

        IF P_Loan_Details_Rec.exchange_date IS NULL THEN
            LogErrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',   p_token1 => 'P_Loan_Details_Rec.exchange_date');
        END IF;

        IF UPPER(P_Loan_Details_Rec.exchange_rate_type) = 'USER' THEN
            IF P_Loan_Details_Rec.exchange_rate IS NULL THEN
                LogErrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',   p_token1 => 'P_Loan_Details_Rec.exchange_rate');
            END IF;
        ELSE
            P_Loan_Details_Rec.exchange_rate := LNS_UTILITY_PUB.CONVERTRATE(l_functional_currency
                                                                        ,l_product_rec.loan_currency
                                                                        ,P_Loan_Details_Rec.exchange_date
                                                                        ,P_Loan_Details_Rec.exchange_rate_type
                                                                        );
            IF P_Loan_Details_Rec.exchange_rate IS NULL THEN
                LogErrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_Loan_Details_Rec.exchange_date'
                        , p_token2 => P_Loan_Details_Rec.exchange_rate);

            END IF;
        END IF; -- End of exchange_rate_type is equal to USER
    END IF;  -- End of l_exchange_required

    -- Validate Trx Type Id
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating trx_type_id...');

    -- If ERS and value is null log error
    IF P_Loan_Details_Rec.trx_type_id IS NULL AND l_product_rec.loan_class_code = 'ERS' THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.trx_type_id');
    ELSIF P_Loan_Details_Rec.trx_type_id IS NOT NULL AND l_product_rec.loan_class_code = 'ERS' THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   ar_lookups alk
                ,RA_CUST_TRX_TYPES_ALL rtyp
            WHERE  rtyp.CUST_TRX_TYPE_ID = P_Loan_Details_Rec.trx_type_id
            AND    alk.lookup_code = rtyp.type
            AND    alk.lookup_type = 'INV/CM';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.trx_type_id'
                    ,p_token2=>P_Loan_Details_Rec.trx_type_id);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating loan_subtype...');

    P_Loan_Details_Rec.loan_subtype :=
                CASE l_override_rec.loan_subtype_ovr
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.loan_subtype, l_product_rec.loan_subtype)
                ELSE l_product_rec.loan_subtype
                END;

    -- Validate Loan Sub Type
    IF P_Loan_Details_Rec.loan_subtype IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   lns_lookups llk
            WHERE  llk.lookup_code = P_Loan_Details_Rec.loan_subtype
            AND    llk.lookup_type = 'LOAN_SUBTYPE';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.loan_subtype'
                    ,p_token2=>P_Loan_Details_Rec.loan_subtype);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating collateral_percent...');

    P_Loan_Details_Rec.collateral_percent :=
                CASE l_override_rec.COLLATERAL_PERCENT_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.collateral_percent, l_product_rec.collateral_percent)
                ELSE l_product_rec.collateral_percent
                END;

    -- Validate Collateral Percent
    IF (P_Loan_Details_Rec.loan_subtype = 'SECURED' AND P_Loan_Details_Rec.collateral_percent IS NULL) THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.collateral_percent');
    ELSIF P_Loan_Details_Rec.loan_subtype = 'SECURED' AND
            (P_Loan_Details_Rec.collateral_percent <= 0 OR P_Loan_Details_Rec.collateral_percent > 100)
    THEN
        LogErrors(p_message_name=>'LNS_LCREATE_INVALID_COLLPERC');
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating loan_term_period...');

    -- Validate Loan Term Period
    if P_Loan_Details_Rec.loan_term_period is null then
        P_Loan_Details_Rec.loan_term_period := l_product_rec.loan_term_period;
    end if;

    IF P_Loan_Details_Rec.loan_term_period IS NULL THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.loan_term_period');
    ELSE
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   lns_lookups llk
            WHERE  llk.lookup_code = P_Loan_Details_Rec.loan_term_period
            AND    llk.lookup_type = 'PERIOD';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.loan_term_period'
                    ,p_token2=>P_Loan_Details_Rec.loan_term_period);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating loan_term...');

    -- Validate Loan Term
    if P_Loan_Details_Rec.loan_term is null then
        P_Loan_Details_Rec.loan_term := l_product_rec.loan_term;
    end if;

    IF P_Loan_Details_Rec.loan_term is NOT NULL THEN
            IF ((P_Loan_Details_Rec.loan_term > 999) OR
                (P_Loan_Details_Rec.loan_term < 0) OR
                (round(P_Loan_Details_Rec.loan_term) <> P_Loan_Details_Rec.loan_term))
            THEN
                    LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_BETWEEN'
                        ,p_token1=>'P_Loan_Details_Rec.loan_term = '||P_Loan_Details_Rec.loan_term||' should be a whole number and '
                        ,p_token2=>' 0 '
                        ,p_token3=>' 999 '
                    );
            END IF;
    ELSIF P_Loan_Details_Rec.loan_term is NOT NULL
            AND P_Loan_Details_Rec.loan_term_period is NOT NULL
            AND l_product_rec.max_loan_term is NOT NULL
            AND ((LNS_FIN_UTILS.intervalsinperiod(P_Loan_Details_Rec.loan_term
                                    ,P_Loan_Details_Rec.loan_term_period
                                    ,'DAYS')
            <  LNS_FIN_UTILS.intervalsinperiod(l_product_rec.loan_term
                                    ,l_product_rec.loan_term_period
                                    ,'DAYS')) OR
            (LNS_FIN_UTILS.intervalsinperiod(P_Loan_Details_Rec.loan_term
                                    ,P_Loan_Details_Rec.loan_term_period
                                    ,'DAYS')
            >  LNS_FIN_UTILS.intervalsinperiod(l_product_rec.max_loan_term
                                    ,l_product_rec.max_loan_term_period
                                    ,'DAYS')))
    THEN
            LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_BETWEEN'
                    ,p_token1 => '(P_Loan_Details_Rec.loan_term P_Loan_Details_Rec.loan_term_period)'
                    ,p_token2=>l_product_rec.loan_term || ' ' || l_product_rec.loan_term_period
                    ,p_token3=>l_product_rec.max_loan_term || ' ' || l_product_rec.max_loan_term_period);
    ELSIF P_Loan_Details_Rec.loan_term is NOT NULL
            AND P_Loan_Details_Rec.loan_term_period is NOT NULL
            AND l_product_rec.max_loan_term is NULL
            AND (LNS_FIN_UTILS.intervalsinperiod(P_Loan_Details_Rec.loan_term
                                    ,P_Loan_Details_Rec.loan_term_period
                                    ,'DAYS')
            <  LNS_FIN_UTILS.intervalsinperiod(l_product_rec.loan_term
                                    ,l_product_rec.loan_term_period
                                    ,'DAYS'))
    THEN
            LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_GREATER'
            ,p_token1=>'(P_Loan_Details_Rec.loan_term P_Loan_Details_Rec.loan_term_period)'
            ,p_token2=>l_product_rec.loan_term || ' ' || l_product_rec.loan_term_period);
    ELSIF P_Loan_Details_Rec.loan_term is NULL
    THEN
            LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_Loan_Details_Rec.loan_term');
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating balloon_payment_type...');

    -- Validate Payment Type
    if P_Loan_Details_Rec.balloon_payment_type is null then
        P_Loan_Details_Rec.balloon_payment_type := 'TERM';
    end if;

    BEGIN
        SELECT 'Y'
        INTO   l_dummy
        FROM   lns_lookups llk
        WHERE  llk.lookup_code = P_Loan_Details_Rec.balloon_payment_type
        AND    llk.lookup_type = 'BALLOON_PAYMENT_TYPE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                ,p_token1=>'P_Loan_Details_Rec.balloon_payment_type'
                ,p_token2=>P_Loan_Details_Rec.balloon_payment_type);
    END;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating balloon_term/balloon_payment_amount...');

    -- Validate Balloon Payment Amount / Balloon Term
    if P_Loan_Details_Rec.balloon_payment_amount is null then
        P_Loan_Details_Rec.balloon_payment_amount := 0;
    end if;

    if P_Loan_Details_Rec.balloon_term is null then
        P_Loan_Details_Rec.balloon_term := P_Loan_Details_Rec.loan_term;
    end if;

    IF (P_Loan_Details_Rec.balloon_payment_type = 'TERM' AND P_Loan_Details_Rec.balloon_term IS NULL) THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_Loan_Details_Rec.balloon_term');

    ELSIF (P_Loan_Details_Rec.balloon_payment_type = 'TERM' AND P_Loan_Details_Rec.balloon_term IS NOT NULL) THEN
        IF ((P_Loan_Details_Rec.balloon_term > 999) OR
            (P_Loan_Details_Rec.balloon_term < 0) OR
            (round(P_Loan_Details_Rec.balloon_term) <> P_Loan_Details_Rec.balloon_term))
        THEN
            LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_BETWEEN'
                    ,p_token1=>'P_Loan_Details_Rec.balloon_term = '||P_Loan_Details_Rec.balloon_term||' should be a whole number and '
                    ,p_token2=>' 0 '
                    ,p_token3=>' 999 '
            );
        ELSIF (P_Loan_Details_Rec.loan_term > P_Loan_Details_Rec.balloon_term) THEN
            LogErrors(p_message_name=>'LNS_LOAN_TERM_INVALID'
                ,p_token1=>'P_Loan_Details_Rec.loan_term = '||P_Loan_Details_Rec.loan_term
                ,p_token2=>'P_Loan_Details_Rec.balloon_term = '||P_Loan_Details_Rec.balloon_term);
        END IF;
    ELSIF (P_Loan_Details_Rec.balloon_payment_type = 'AMOUNT' AND P_Loan_Details_Rec.balloon_payment_amount IS NULL) THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.balloon_payment_amount');

    ELSIF (P_Loan_Details_Rec.balloon_payment_type = 'AMOUNT' AND P_Loan_Details_Rec.balloon_payment_amount IS NOT NULL) THEN

        IF(P_Loan_Details_Rec.balloon_payment_amount > P_Loan_Details_Rec.requested_amount) THEN
            LogErrors(p_message_name=>'LNS_BALLOON_AMOUNT_INVALID'
                ,p_token1=>'P_Loan_Details_Rec.balloon_payment_amount = '||P_Loan_Details_Rec.balloon_payment_amount
                ,p_token2=>'P_Loan_Details_Rec.requested_amount = '||P_Loan_Details_Rec.requested_amount);
        END IF;
    END IF;

    l_borrower_valid   := FALSE;
    l_cust_acct_valid  := FALSE;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating primary_borrower_party_id...');

    -- Validate primary_borrower_party_id
    IF P_Loan_Details_Rec.primary_borrower_party_id IS NULL THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.primary_borrower_party_id');
    ELSE
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   hz_parties hzp
            WHERE  hzp.party_id = P_Loan_Details_Rec.primary_borrower_party_id
            AND    hzp.party_type = l_product_rec.party_type
            AND    hzp.status = 'A';
            l_borrower_valid := TRUE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.primary_borrower_party_id'
                    ,p_token2=>P_Loan_Details_Rec.primary_borrower_party_id);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating cust_account_id...');

    -- Validate cust_account_id
    IF l_borrower_valid THEN

        IF P_Loan_Details_Rec.cust_account_id IS NULL THEN
            LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_Loan_Details_Rec.cust_account_id');
        ELSE
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_cust_accounts_all hzca
                WHERE  hzca.cust_account_id = P_Loan_Details_Rec.cust_account_id
                AND    hzca.party_id = P_Loan_Details_Rec.primary_borrower_party_id
                AND    hzca.status = 'A';
                l_cust_acct_valid := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.cust_account_id'
                        ,p_token2=>P_Loan_Details_Rec.cust_account_id);
            END;
        END IF;

    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating bill_to_acct_site_id...');

    -- Validate bill_to_acct_site_id
    IF l_cust_acct_valid THEN

        IF P_Loan_Details_Rec.bill_to_acct_site_id IS NULL THEN
            LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_Loan_Details_Rec.bill_to_acct_site_id');
        ELSE
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_cust_accounts_all account,
                hz_cust_site_uses acc_site_use,
                hz_cust_acct_sites_all acct_site
                WHERE  account.cust_account_id = acct_site.cust_account_id
                AND    acc_site_use.cust_acct_site_id = acct_site.cust_acct_site_id
                AND    acc_site_use.site_use_code = 'BILL_TO'
                AND    acct_site.cust_acct_site_id = P_Loan_Details_Rec.bill_to_acct_site_id
                AND    acct_site.cust_account_id = P_Loan_Details_Rec.cust_account_id
                AND    acc_site_use.status = 'A';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.bill_to_acct_site_id'
                        ,p_token2=>P_Loan_Details_Rec.bill_to_acct_site_id);
            END;
        END IF;

    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating contact_rel_party_id...');

    IF l_borrower_valid THEN

        IF P_Loan_Details_Rec.contact_rel_party_id IS NOT NULL THEN
            BEGIN
                SELECT
                    p.party_id INTO l_contact_pers_party_id
                FROM
                    hz_relationships rel,
                    hz_parties p,
                    hz_parties o,
                    hz_parties rel_party,
                    ar_lookups lkup,
                    hz_relationship_types rel_type,
                    hz_contact_points con_phone
                WHERE   o.party_type = 'ORGANIZATION'
                    AND p.party_type = 'PERSON'
                    AND rel.subject_id = p.party_id
                    AND rel.object_id  = o.party_id
                    AND rel.relationship_code = rel_type.forward_rel_code
                    AND rel_type.create_party_flag = 'Y'
                    AND rel_type.subject_type = 'PERSON'
                    AND rel_type.object_type = 'ORGANIZATION'
                    AND rel.relationship_type = rel_type.relationship_type
                    AND rel_type.role = lkup.lookup_code
                    AND lkup.lookup_type = 'HZ_RELATIONSHIP_ROLE'
                    AND rel.party_id = rel_party.party_id
                    AND rel.status = 'A'
                    AND rel_party.status = 'A'
                    AND p.status = 'A'
                    AND con_phone.owner_table_name(+) = 'HZ_PARTIES'
                    AND con_phone.owner_table_id(+) = rel.party_id
                    AND con_phone.primary_flag(+) = 'Y'
                    AND con_phone.status(+) = 'A'
                    AND con_phone.contact_point_type(+) = 'PHONE'
                    AND rel.party_id = P_Loan_Details_Rec.contact_rel_party_id;
                    l_valid_contact_rel := 'Y';
            EXCEPTION
                WHEN no_data_found THEN
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                          p_token1 => 'L_LOAN_DTL_REC.contact_rel_party_id',
                          p_token2 => P_Loan_Details_Rec.contact_rel_party_id);
            END;
        END IF;

        IF l_valid_contact_rel = 'Y' THEN
            IF P_Loan_Details_Rec.contact_pers_party_id IS NULL THEN
                P_Loan_Details_Rec.contact_pers_party_id := l_contact_pers_party_id;
                l_valid_contact_pers := 'Y';
            ELSIF l_contact_pers_party_id = P_Loan_Details_Rec.contact_pers_party_id THEN
                l_valid_contact_pers := 'Y';
            END IF;
        END IF;

        IF ((P_Loan_Details_Rec.contact_pers_party_id IS NOT NULL) AND (l_valid_contact_pers <> 'Y')) THEN
            BEGIN
                SELECT
                    rel.party_id INTO l_contact_rel_party_id
                FROM
                    hz_relationships rel,
                    hz_parties p,
                    hz_parties o,
                    hz_parties rel_party,
                    ar_lookups lkup,
                    hz_relationship_types rel_type,
                    hz_contact_points con_phone
                WHERE   o.party_type = 'ORGANIZATION'
                    AND p.party_type = 'PERSON'
                    AND rel.subject_id = p.party_id
                    AND rel.object_id  = o.party_id
                    AND rel.relationship_code = rel_type.forward_rel_code
                    AND rel_type.create_party_flag = 'Y'
                    AND rel_type.subject_type = 'PERSON'
                    AND rel_type.object_type = 'ORGANIZATION'
                    AND rel.relationship_type = rel_type.relationship_type
                    AND rel_type.role = lkup.lookup_code
                    AND lkup.lookup_type = 'HZ_RELATIONSHIP_ROLE'
                    AND rel.party_id = rel_party.party_id
                    AND rel.status = 'A'
                    AND rel_party.status = 'A'
                    AND p.status = 'A'
                    AND con_phone.owner_table_name(+) = 'HZ_PARTIES'
                    AND con_phone.owner_table_id(+) = rel.party_id
                    AND con_phone.primary_flag(+) = 'Y'
                    AND con_phone.status(+) = 'A'
                    AND con_phone.contact_point_type(+) = 'PHONE'
                    AND p.party_id = P_Loan_Details_Rec.contact_pers_party_id;
                    l_valid_contact_pers := 'Y';
            EXCEPTION
                WHEN no_data_found THEN
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                          p_token1 => 'P_Loan_Details_Rec.contact_pers_party_id',
                          p_token2 => P_Loan_Details_Rec.contact_pers_party_id);
            END;
        END IF;

        IF l_valid_contact_pers = 'Y' THEN
            IF  P_Loan_Details_Rec.contact_rel_party_id IS NULL THEN
                l_contact_rel_party_id := P_Loan_Details_Rec.contact_rel_party_id;
                l_valid_contact_rel := 'Y';
            ELSIF l_contact_rel_party_id = P_Loan_Details_Rec.contact_rel_party_id THEN
                l_valid_contact_rel := 'Y';
            END IF;
        END IF;

        -- Only if bothe Contact (rel and Person) are not NULL and individually both are correct but incorrect when combined
        IF (((P_Loan_Details_Rec.contact_rel_party_id IS NOT NULL) AND (P_Loan_Details_Rec.contact_pers_party_id IS NOT NULL)) AND
            ((l_valid_contact_rel <> 'Y') OR (l_valid_contact_pers <> 'Y'))) THEN
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                      p_token1 => 'P_Loan_Details_Rec.contact_pers_party_id',
                      p_token2 => P_Loan_Details_Rec.contact_pers_party_id);
        END IF;

    END IF; -- If the l_borrower_valid

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating RATE_TYPE...');

    P_Loan_Details_Rec.RATE_TYPE :=
                CASE l_override_rec.RATE_TYPE_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.RATE_TYPE, l_product_rec.RATE_TYPE)
                ELSE l_product_rec.RATE_TYPE
                END;

    IF P_Loan_Details_Rec.RATE_TYPE IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO l_dummy
            FROM lns_lookups llk
            WHERE llk.lookup_code = P_Loan_Details_Rec.RATE_TYPE
            AND llk.lookup_type = 'RATE_TYPE'
            AND enabled_flag = 'Y';

        EXCEPTION
            WHEN no_data_found THEN
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                        p_token1 => 'P_Loan_Details_Rec.rate_type and ',
                        p_token2 => P_Loan_Details_Rec.rate_type);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating index_rate_id...');

    -- Validate Index Rate Id
    P_Loan_Details_Rec.index_rate_id :=
                CASE l_override_rec.index_rate_id_ovr
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.index_rate_id, l_product_rec.index_rate_id)
                ELSE l_product_rec.index_rate_id
                END;

    IF P_Loan_Details_Rec.index_rate_id IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   lns_int_rate_headers lirh
            WHERE  lirh.interest_rate_id = P_Loan_Details_Rec.index_rate_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.index_rate_id'
                    ,p_token2=>P_Loan_Details_Rec.index_rate_id);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating loan_payment_frequency...');

    -- Validate loan_payment_frequency
    P_Loan_Details_Rec.loan_payment_frequency :=
                CASE l_override_rec.loan_payment_freq_ovr
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.loan_payment_frequency, l_product_rec.loan_payment_frequency)
                ELSE l_product_rec.loan_payment_frequency
                END;

    IF P_Loan_Details_Rec.loan_payment_frequency IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   lns_lookups llk
            WHERE  llk.lookup_code = P_Loan_Details_Rec.loan_payment_frequency
            AND    llk.lookup_type = 'FREQUENCY';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.loan_payment_frequency'
                    ,p_token2=>P_Loan_Details_Rec.loan_payment_frequency);
        END;
    END IF;

    LogMessage(fnd_log.level_statement,   'Validating Day Count Method...');

    -- Validate Day Count Method
    P_Loan_Details_Rec.day_count_method :=
                CASE l_override_rec.day_count_method_ovr
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.day_count_method, l_product_rec.day_count_method)
                ELSE l_product_rec.day_count_method
                END;

    IF P_Loan_Details_Rec.day_count_method IS NOT NULL THEN
            BEGIN
                SELECT 'Y'
                INTO l_dummy
                FROM lns_lookups llk
                WHERE llk.lookup_code = P_Loan_Details_Rec.day_count_method
                AND llk.lookup_type = 'DAY_COUNT_METHOD'
                AND enabled_flag = 'Y';
            EXCEPTION
                WHEN no_data_found THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.day_count_method'
                        ,p_token2=>P_Loan_Details_Rec.day_count_method);
            END;
    END IF;

    logmessage(fnd_log.level_statement,   'Validating PAYMENT_CALC_METHOD');

    IF P_Loan_Details_Rec.PAYMENT_CALC_METHOD IS NULL THEN
        P_Loan_Details_Rec.PAYMENT_CALC_METHOD := 'EQUAL_PAYMENT';
        logmessage(fnd_log.level_statement,   'Defaulting PAYMENT_CALC_METHOD to ' || P_Loan_Details_Rec.PAYMENT_CALC_METHOD);
    ELSE
        BEGIN
            SELECT 'Y'
            INTO l_dummy
            FROM lns_lookups llk
            WHERE llk.lookup_code = P_Loan_Details_Rec.PAYMENT_CALC_METHOD
            AND llk.lookup_type = 'PAYMENT_CALCULATION_METHOD';

        EXCEPTION
            WHEN no_data_found THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.PAYMENT_CALC_METHOD'
                        ,p_token2=>P_Loan_Details_Rec.PAYMENT_CALC_METHOD);
        END;
    END IF;

    LogMessage(fnd_log.level_statement,   'Validating CALCULATION_METHOD...');

    -- Validate CALCULATION_METHOD
    P_Loan_Details_Rec.CALCULATION_METHOD :=
                CASE l_override_rec.calculation_method_ovr
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.CALCULATION_METHOD, l_product_rec.CALCULATION_METHOD)
                ELSE l_product_rec.CALCULATION_METHOD
                END;

    IF P_Loan_Details_Rec.CALCULATION_METHOD IS NOT NULL THEN
            BEGIN
                SELECT 'Y'
                INTO l_dummy
                FROM lns_lookups llk
                WHERE llk.lookup_code = P_Loan_Details_Rec.CALCULATION_METHOD
                AND llk.lookup_type = 'INTEREST_CALCULATION_METHOD';
            EXCEPTION
                WHEN no_data_found THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.CALCULATION_METHOD'
                        ,p_token2=>P_Loan_Details_Rec.CALCULATION_METHOD);
            END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating INTEREST_COMPOUNDING_FREQ...');

    -- Validate INTEREST_COMPOUNDING_FREQ
    P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ :=
                CASE l_override_rec.INTEREST_COMPOUNDING_FREQ_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ, l_product_rec.INTEREST_COMPOUNDING_FREQ)
                ELSE l_product_rec.INTEREST_COMPOUNDING_FREQ
                END;

    IF P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ IS NOT NULL THEN
        BEGIN
            SELECT 'Y'
            INTO l_dummy
            FROM lns_lookups llk
            WHERE llk.lookup_code = P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ
            AND llk.lookup_type = 'FREQUENCY';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ'
                    ,p_token2=>P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ);
        END;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating custom_payments_flag...');

    IF P_Loan_Details_Rec.custom_payments_flag is null then
        P_Loan_Details_Rec.custom_payments_flag := 'N';
    end if;

    if P_Loan_Details_Rec.custom_payments_flag <> 'Y' and P_Loan_Details_Rec.custom_payments_flag <> 'N' then
        LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                ,p_token1=>'P_Loan_Details_Rec.custom_payments_flag'
                ,p_token2=>P_Loan_Details_Rec.custom_payments_flag);
    end if;

    IF P_Loan_Details_Rec.custom_payments_flag = 'Y' THEN

        IF p_loan_cust_sched_tbl.COUNT = 0 THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'p_loan_cust_sched_tbl.COUNT'
                    ,p_token2=>p_loan_cust_sched_tbl.COUNT);
        END IF;

        logmessage(fnd_log.level_statement,   'Validating CUSTOM_CALC_METHOD...');

        IF P_Loan_Details_Rec.CUSTOM_CALC_METHOD is null THEN
            P_Loan_Details_Rec.CUSTOM_CALC_METHOD := 'NONE';
            logmessage(fnd_log.level_statement,   'Defaulting CUSTOM_CALC_METHOD to ' || P_Loan_Details_Rec.CUSTOM_CALC_METHOD);
        ELSE
            BEGIN
                SELECT 'Y'
                INTO l_dummy
                FROM lns_lookups llk
                WHERE llk.lookup_code = P_Loan_Details_Rec.CUSTOM_CALC_METHOD
                AND llk.lookup_type = 'CUSTOM_CALCULATION_METHOD';

            EXCEPTION
                WHEN no_data_found THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.CUSTOM_CALC_METHOD'
                        ,p_token2=>P_Loan_Details_Rec.CUSTOM_CALC_METHOD);
            END;
        END IF;

        logmessage(fnd_log.level_statement,   'Validating ORIG_PAY_CALC_METHOD');

        IF P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD IS NULL THEN
            P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD := P_Loan_Details_Rec.PAYMENT_CALC_METHOD;
            logmessage(fnd_log.level_statement,   'Defaulting ORIG_PAY_CALC_METHOD to ' || P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD);
        ELSE
            BEGIN
                SELECT 'Y'
                INTO l_dummy
                FROM lns_lookups llk
                WHERE llk.lookup_code = P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD
                AND llk.lookup_type = 'PAYMENT_CALCULATION_METHOD';

            EXCEPTION
                WHEN no_data_found THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD'
                        ,p_token2=>P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD);
            END;
        END IF;
    ELSE
        P_Loan_Details_Rec.CUSTOM_CALC_METHOD := null;
        P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD := null;
    END IF;

    IF P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD = 'CUSTOM' THEN
        P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD := null;
        logmessage(fnd_log.level_statement,   'Defaulting ORIG_PAY_CALC_METHOD to ' || P_Loan_Details_Rec.ORIG_PAY_CALC_METHOD);
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating PENAL_INT_RATE...');

    IF P_Loan_Details_Rec.PENAL_INT_RATE is null or P_Loan_Details_Rec.PENAL_INT_RATE < 0 THEN
        P_Loan_Details_Rec.PENAL_INT_RATE := 0;
        logmessage(fnd_log.level_statement,   'Defaulting PENAL_INT_RATE to ' || P_Loan_Details_Rec.PENAL_INT_RATE);
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating PENAL_INT_GRACE_DAYS...');

    IF P_Loan_Details_Rec.PENAL_INT_GRACE_DAYS is null or P_Loan_Details_Rec.PENAL_INT_GRACE_DAYS < 0 THEN
        P_Loan_Details_Rec.PENAL_INT_GRACE_DAYS := 0;
        logmessage(fnd_log.level_statement,   'Defaulting PENAL_INT_GRACE_DAYS to ' || P_Loan_Details_Rec.PENAL_INT_GRACE_DAYS);
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating FORGIVENESS_FLAG...');

    P_Loan_Details_Rec.FORGIVENESS_FLAG :=
                CASE l_override_rec.FORGIVENESS_FLAG_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.FORGIVENESS_FLAG, l_product_rec.FORGIVENESS_FLAG)
                ELSE l_product_rec.FORGIVENESS_FLAG
                END;

    IF P_Loan_Details_Rec.FORGIVENESS_FLAG IS NOT NULL THEN
        if P_Loan_Details_Rec.FORGIVENESS_FLAG <> 'Y' and P_Loan_Details_Rec.FORGIVENESS_FLAG <> 'N' then
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.FORGIVENESS_FLAG'
                    ,p_token2=>P_Loan_Details_Rec.FORGIVENESS_FLAG);
        end if;
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating FORGIVENESS_PERCENT...');

    P_Loan_Details_Rec.FORGIVENESS_PERCENT :=
                CASE l_override_rec.FORGIVENESS_PERCENT_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.FORGIVENESS_PERCENT, l_product_rec.FORGIVENESS_PERCENT)
                ELSE l_product_rec.FORGIVENESS_PERCENT
                END;

    IF P_Loan_Details_Rec.FORGIVENESS_PERCENT IS NOT NULL THEN
        if P_Loan_Details_Rec.FORGIVENESS_PERCENT < 0 or P_Loan_Details_Rec.FORGIVENESS_PERCENT > 100 then
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.FORGIVENESS_PERCENT'
                    ,p_token2=>P_Loan_Details_Rec.FORGIVENESS_PERCENT);
        end if;
    END IF;

    P_Loan_Details_Rec.reamortize_over_payment :=
                CASE l_override_rec.REAMORTIZE_OVER_PAYMENT_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.reamortize_over_payment, l_product_rec.reamortize_over_payment)
                ELSE l_product_rec.reamortize_over_payment
                END;

    if l_product_rec.multiple_funding_flag = 'Y' then

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating open_loan_term_period...');

        -- Validate Open Loan Term Period
        if P_Loan_Details_Rec.open_loan_term_period is null THEN
            P_Loan_Details_Rec.open_loan_term_period := l_product_rec.open_loan_term_period;
        end if;

        IF P_Loan_Details_Rec.open_loan_term_period IS NULL THEN
            LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_Loan_Details_Rec.open_loan_term_period');
        ELSE
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   lns_lookups llk
                WHERE  llk.lookup_code = P_Loan_Details_Rec.open_loan_term_period
                AND    llk.lookup_type = 'PERIOD';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.open_loan_term_period'
                        ,p_token2=>P_Loan_Details_Rec.open_loan_term_period);
            END;

        END IF;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating open_loan_term...');

        -- Validate Open Loan Term
        IF P_Loan_Details_Rec.open_loan_term is NOT NULL THEN
                IF ((P_Loan_Details_Rec.open_loan_term > 999 ) OR
                    (P_Loan_Details_Rec.open_loan_term < 0) OR
                    (round(P_Loan_Details_Rec.open_loan_term) <> P_Loan_Details_Rec.open_loan_term))
                THEN
                    LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_BETWEEN'
                            ,p_token1=>'P_Loan_Details_Rec.open_loan_term = '||P_Loan_Details_Rec.open_loan_term||' should be a whole number and '
                            ,p_token2=>' 0 '
                            ,p_token3=>' 999 '
                        );
                END IF;
        ELSIF P_Loan_Details_Rec.open_loan_term is NOT NULL
                AND P_Loan_Details_Rec.open_loan_term_period is NOT NULL
                AND l_product_rec.open_max_loan_term is NOT NULL
                AND ((LNS_FIN_UTILS.intervalsinperiod(P_Loan_Details_Rec.open_loan_term
                                        ,P_Loan_Details_Rec.open_loan_term_period
                                        ,'DAYS')
            <  LNS_FIN_UTILS.intervalsinperiod(l_product_rec.open_loan_term
                                        ,l_product_rec.open_loan_term_period
                                        ,'DAYS')) OR
                (LNS_FIN_UTILS.intervalsinperiod(P_Loan_Details_Rec.open_loan_term
                                        ,P_Loan_Details_Rec.open_loan_term_period
                                        ,'DAYS')
            >  LNS_FIN_UTILS.intervalsinperiod(l_product_rec.open_max_loan_term
                                        ,l_product_rec.open_max_loan_term_period
                                        ,'DAYS')))
        THEN
                LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_BETWEEN'
                        ,p_token1=>'(P_Loan_Details_Rec.open_loan_term P_Loan_Details_Rec.open_loan_term_period)'
                        ,p_token2=>l_product_rec.open_loan_term || ' ' || l_product_rec.open_loan_term_period
                        ,p_token3=>l_product_rec.open_max_loan_term || ' ' || l_product_rec.open_max_loan_term_period);
        ELSIF P_Loan_Details_Rec.open_loan_term is NOT NULL
                AND P_Loan_Details_Rec.open_loan_term_period is NOT NULL
                AND l_product_rec.open_max_loan_term is NULL
                AND (LNS_FIN_UTILS.intervalsinperiod(P_Loan_Details_Rec.open_loan_term
                                        ,P_Loan_Details_Rec.open_loan_term_period
                                        ,'DAYS')
            <  LNS_FIN_UTILS.intervalsinperiod(l_product_rec.open_loan_term
                                        ,l_product_rec.open_loan_term_period
                                        ,'DAYS'))
        THEN
                LogErrors(p_message_name=>'LNS_LCREATE_ATTR_NOT_GREATER'
                            ,p_token1=>'(P_Loan_Details_Rec.open_loan_term P_Loan_Details_Rec.open_loan_term_period)'
                            ,p_token2=>l_product_rec.open_loan_term || ' ' || l_product_rec.open_loan_term_period);
        ELSIF  P_Loan_Details_Rec.open_loan_term is NULL THEN
                LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_Loan_Details_Rec.open_loan_term');
        END IF;

        LogMessage(fnd_log.level_statement,   'Validating Loan Open Start Date');

        IF P_Loan_Details_Rec.open_loan_start_date IS NULL THEN
            P_Loan_Details_Rec.open_loan_start_date := sysdate;
        END IF;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating open_to_term_event...');

        -- Validate Open To Term Event
        if P_Loan_Details_Rec.open_to_term_event is null then
            P_Loan_Details_Rec.open_to_term_event := 'AUTO_FINAL_DISBURSEMENT';
        end if;

        IF P_Loan_Details_Rec.open_to_term_event IS NOT NULL THEN
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   lns_lookups llk
                WHERE  llk.lookup_code = P_Loan_Details_Rec.open_to_term_event
                AND    llk.lookup_type = 'OPEN_TO_TERM_EVENT';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.open_to_term_event'
                        ,p_token2=>P_Loan_Details_Rec.open_to_term_event);
            END;
        END IF;

        P_Loan_Details_Rec.open_first_payment_date :=
            lns_fin_utils.getNextDate(p_date => P_Loan_Details_Rec.open_loan_start_date
                                    ,p_interval_type => P_Loan_Details_Rec.loan_payment_frequency
                                    ,p_direction => 1);

        P_Loan_Details_Rec.open_maturity_date :=
            lns_fin_utils.getMaturityDate(
                    p_term => P_Loan_Details_Rec.open_loan_term,
                    p_term_period => P_Loan_Details_Rec.open_loan_term_period,
                    p_frequency => P_Loan_Details_Rec.loan_payment_frequency,
                    p_start_date => P_Loan_Details_Rec.open_loan_start_date);

        P_Loan_Details_Rec.open_payment_frequency := P_Loan_Details_Rec.loan_payment_frequency;

        P_Loan_Details_Rec.open_floor_rate :=
                CASE l_override_rec.OPEN_FLOOR_RATE_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.open_floor_rate, l_product_rec.open_floor_rate)
                ELSE l_product_rec.open_floor_rate
                END;

        P_Loan_Details_Rec.open_ceiling_rate :=
                CASE l_override_rec.OPEN_CEILING_RATE_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.open_ceiling_rate, l_product_rec.open_ceiling_rate)
                ELSE l_product_rec.open_ceiling_rate
                END;

        P_Loan_Details_Rec.open_percent_increase :=
                CASE l_override_rec.OPEN_PERCENT_INCREASE_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.open_percent_increase, l_product_rec.open_percent_increase)
                ELSE l_product_rec.open_percent_increase
                END;

        P_Loan_Details_Rec.open_percent_increase_life :=
                CASE l_override_rec.OPEN_PERCENT_INCREASE_LIFE_OVR
                WHEN 'Y' THEN nvl(P_Loan_Details_Rec.open_percent_increase_life, l_product_rec.open_percent_increase_life)
                ELSE l_product_rec.open_percent_increase_life
                END;

        P_Loan_Details_Rec.loan_start_date := P_Loan_Details_Rec.open_maturity_date;

        LogMessage(fnd_log.level_statement,   'Validating Loan Application Date');

        IF P_Loan_Details_Rec.loan_application_date IS NULL THEN
            P_Loan_Details_Rec.loan_application_date := P_Loan_Details_Rec.open_loan_start_date;
        END IF;

    ELSE

        P_Loan_Details_Rec.open_loan_term_period := null;
        P_Loan_Details_Rec.open_loan_term := null;
        P_Loan_Details_Rec.open_loan_start_date := null;
        P_Loan_Details_Rec.open_to_term_event := null;
        P_Loan_Details_Rec.open_first_payment_date := null;
        P_Loan_Details_Rec.open_maturity_date := null;
        P_Loan_Details_Rec.open_payment_frequency := null;
        P_Loan_Details_Rec.open_floor_rate := null;
        P_Loan_Details_Rec.open_ceiling_rate := null;
        P_Loan_Details_Rec.open_percent_increase := null;
        P_Loan_Details_Rec.open_percent_increase_life := null;

        LogMessage(fnd_log.level_statement,   'Validating Loan Start Date');

        IF P_Loan_Details_Rec.loan_start_date IS NULL THEN
            P_Loan_Details_Rec.loan_start_date := sysdate;
        END IF;

        LogMessage(fnd_log.level_statement,   'Validating Loan Application Date');

        IF P_Loan_Details_Rec.loan_application_date IS NULL THEN
            P_Loan_Details_Rec.loan_application_date := P_Loan_Details_Rec.loan_start_date;
        END IF;

    END IF;

    P_Loan_Details_Rec.maturity_date :=
        lns_fin_utils.getMaturityDate(
            p_term => P_Loan_Details_Rec.loan_term,
            p_term_period => P_Loan_Details_Rec.loan_term_period,
            p_frequency => P_Loan_Details_Rec.loan_payment_frequency,
            p_start_date => P_Loan_Details_Rec.loan_start_date
        );

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating first_payment_date...');

    IF P_Loan_Details_Rec.first_payment_date IS NOT NULL THEN
        IF (P_Loan_Details_Rec.first_payment_date < P_Loan_Details_Rec.loan_start_date) THEN
            LogErrors(p_message_name => 'LNS_PAYMENT_START_DATE_ERROR2');
        ELSIF (P_Loan_Details_Rec.first_payment_date > P_Loan_Details_Rec.maturity_date) THEN
            LogErrors(p_message_name => 'LNS_PAYMENT_START_DATE_ERROR1');
        END IF;
    ELSE
        P_Loan_Details_Rec.first_payment_date := lns_fin_utils.getNextDate(p_date=> P_Loan_Details_Rec.loan_start_date
                                                    ,p_interval_type => P_Loan_Details_Rec.loan_payment_frequency
                                                    ,p_direction => 1);
    END IF;

    IF P_Loan_Details_Rec.PAYMENT_CALC_METHOD = 'SEPARATE_SCHEDULES' THEN

        logmessage(fnd_log.level_statement,   'Validating PRIN_FIRST_PAY_DATE');

        IF P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE IS NULL THEN
            P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE := P_Loan_Details_Rec.first_payment_date;
            logmessage(fnd_log.level_statement,   'Defaulting PRIN_FIRST_PAY_DATE to ' || P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE);
        ELSE
            IF (P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE < P_Loan_Details_Rec.loan_start_date) THEN
                logerrors(p_message_name => 'LNS_PAYMENT_START_DATE_ERROR2');
            ELSIF (P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE > P_Loan_Details_Rec.maturity_date) THEN
                logerrors(p_message_name => 'LNS_PAYMENT_START_DATE_ERROR1');
            END IF;
        END IF;

        logmessage(fnd_log.level_statement,   'Validating PRIN_PAYMENT_FREQUENCY');

        IF P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY IS NULL THEN
            P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY := P_Loan_Details_Rec.loan_payment_frequency;
            logmessage(fnd_log.level_statement,   'Defaulting PRIN_PAYMENT_FREQUENCY to ' || P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY);
        ELSE
            BEGIN
                SELECT 'Y'
                INTO l_dummy
                FROM lns_lookups llk
                WHERE llk.lookup_code = P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY
                AND llk.lookup_type = 'FREQUENCY';

            EXCEPTION
                WHEN no_data_found THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY'
                        ,p_token2=>P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY);
            END;
        END IF;

    END IF;

    P_Loan_Details_Rec.floor_rate :=
            CASE l_override_rec.FLOOR_RATE_OVR
            WHEN 'Y' THEN nvl(P_Loan_Details_Rec.floor_rate, l_product_rec.floor_rate)
            ELSE l_product_rec.floor_rate
            END;

    P_Loan_Details_Rec.ceiling_rate :=
            CASE l_override_rec.CEILING_RATE_OVR
            WHEN 'Y' THEN nvl(P_Loan_Details_Rec.ceiling_rate, l_product_rec.ceiling_rate)
            ELSE l_product_rec.ceiling_rate
            END;

    P_Loan_Details_Rec.percent_increase :=
            CASE l_override_rec.PERCENT_INCREASE_OVR
            WHEN 'Y' THEN nvl(P_Loan_Details_Rec.percent_increase, l_product_rec.percent_increase)
            ELSE l_product_rec.percent_increase
            END;

    P_Loan_Details_Rec.percent_increase_life :=
            CASE l_override_rec.PERCENT_INCREASE_LIFE_OVR
            WHEN 'Y' THEN nvl(P_Loan_Details_Rec.percent_increase_life, l_product_rec.percent_increase_life)
            ELSE l_product_rec.percent_increase_life
            END;



    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

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

END validate_loan_header_details;




PROCEDURE validate_participants(p_loan_part_tbl IN OUT NOCOPY LNS_LOAN_PUB.loan_part_tbl_type
                                ,x_return_status OUT nocopy VARCHAR2
                                ,x_msg_count OUT nocopy NUMBER
                                ,x_msg_data OUT nocopy VARCHAR2)
IS
    l_api_name constant VARCHAR2(30) := 'VALIDATE_PARTICIPANTS';
    l_dummy VARCHAR2(1);
    l_borrower_valid boolean;
    l_cust_acct_valid boolean;
    l_contact_rel_party_id lns_loan_headers_all.contact_rel_party_id%TYPE;
    l_contact_pers_party_id lns_loan_headers_all.contact_pers_party_id%TYPE;
    l_valid_contact_rel VARCHAR2(1) := 'N';
    l_valid_contact_pers VARCHAR2(1) := 'N';

BEGIN
    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' +');

    FOR l_count IN 1 .. p_loan_part_tbl.COUNT
    LOOP

        l_borrower_valid   := FALSE;
        l_cust_acct_valid  := FALSE;

        logmessage(fnd_log.level_statement, 'Participant ' || l_count);
        logmessage(fnd_log.level_statement, 'HZ_PARTY_ID = ' || p_loan_part_tbl(l_count).HZ_PARTY_ID);
        logmessage(fnd_log.level_statement, 'LOAN_PARTICIPANT_TYPE = ' || p_loan_part_tbl(l_count).LOAN_PARTICIPANT_TYPE);
        logmessage(fnd_log.level_statement, 'START_DATE_ACTIVE = ' || p_loan_part_tbl(l_count).START_DATE_ACTIVE);
        logmessage(fnd_log.level_statement, 'END_DATE_ACTIVE = ' || p_loan_part_tbl(l_count).END_DATE_ACTIVE);
        logmessage(fnd_log.level_statement, 'CUST_ACCOUNT_ID = ' || p_loan_part_tbl(l_count).CUST_ACCOUNT_ID);
        logmessage(fnd_log.level_statement, 'BILL_TO_ACCT_SITE_ID = ' || p_loan_part_tbl(l_count).BILL_TO_ACCT_SITE_ID);
        logmessage(fnd_log.level_statement, 'CONTACT_PERS_PARTY_ID = ' || p_loan_part_tbl(l_count).CONTACT_PERS_PARTY_ID);
        logmessage(fnd_log.level_statement, 'CONTACT_REL_PARTY_ID = ' || p_loan_part_tbl(l_count).CONTACT_REL_PARTY_ID);

        IF p_loan_part_tbl(l_count).loan_participant_type IS NULL THEN
            LogErrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                      p_token1 => 'P_LOAN_PART_TBL(l_count).loan_participant_type');
        ELSE
            BEGIN
                SELECT 'Y'
                INTO l_dummy
                FROM lns_lookups llk
                WHERE llk.lookup_code = p_loan_part_tbl(l_count).loan_participant_type
                AND llk.lookup_type = 'LNS_PARTICIPANT_TYPE'
                AND enabled_flag = 'Y'
                AND lookup_code <> 'PRIMARY_BORROWER';
            EXCEPTION
            WHEN no_data_found THEN
                LogErrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_LOAN_PART_TBL(l_count).loan_participant_type'
                        , p_token2 => p_loan_part_tbl(l_count).loan_participant_type);
            END;
        END IF;

        LogMessage(fnd_log.level_statement,   'Validating Participant table PartyId');

        -- Validate Particpant HZ_PARTY_ID
        IF p_loan_part_tbl(l_count).hz_party_id IS NULL THEN
            LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                    ,p_token1=>'P_LOAN_PART_TBL(l_count).hz_party_id');
        ELSE
            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   hz_parties hzp
                WHERE  hzp.party_id = p_loan_part_tbl(l_count).hz_party_id
                AND    hzp.status = 'A';
                l_borrower_valid := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        , p_token1 => 'P_LOAN_PART_TBL(l_count).hz_party_id'
                        , p_token2 => p_loan_part_tbl(l_count).hz_party_id);
            END;
        END IF;

        logmessage(fnd_log.level_statement,   'Validating Participant table Customer Account Id');

        -- Validate cust_account_id
        IF l_borrower_valid THEN

            IF p_loan_part_tbl(l_count).cust_account_id IS NULL THEN
                LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                        ,p_token1=>'P_Loan_Details_Rec.cust_account_id');
            ELSE
                BEGIN
                    SELECT 'Y'
                    INTO   l_dummy
                    FROM   hz_cust_accounts_all hzca
                    WHERE  hzca.cust_account_id = p_loan_part_tbl(l_count).cust_account_id
                    AND    hzca.party_id = p_loan_part_tbl(l_count).hz_party_id
                    AND    hzca.status = 'A';
                    l_cust_acct_valid := TRUE;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                            , p_token1 => 'P_LOAN_PART_TBL(l_count).cust_account_id'
                            , p_token2 => p_loan_part_tbl(l_count).cust_account_id);
                END;
            END IF;

        END IF;

        logmessage(fnd_log.level_statement,   'Validating Participant table Bill To Account Site ID');

        -- Validate bill_to_acct_site_id
        IF l_cust_acct_valid THEN

            IF p_loan_part_tbl(l_count).bill_to_acct_site_id IS NULL THEN
                LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                        ,p_token1=>'P_LOAN_PART_TBL(l_count).bill_to_acct_site_id');
            ELSE
                BEGIN
                    SELECT 'Y'
                    INTO   l_dummy
                    FROM   hz_cust_accounts_all account,
                    hz_cust_site_uses acc_site_use,
                    hz_cust_acct_sites_all acct_site
                    WHERE  account.cust_account_id = acct_site.cust_account_id
                    AND    acc_site_use.cust_acct_site_id = acct_site.cust_acct_site_id
                    AND    acc_site_use.site_use_code = 'BILL_TO'
                    AND    acct_site.cust_acct_site_id = p_loan_part_tbl(l_count).bill_to_acct_site_id
                    AND    acct_site.cust_account_id = p_loan_part_tbl(l_count).cust_account_id
                    AND    acc_site_use.status = 'A';
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                            ,p_token1=>'P_LOAN_PART_TBL(l_count).bill_to_acct_site_id'
                            ,p_token2=>p_loan_part_tbl(l_count).bill_to_acct_site_id);
                END;
            END IF;

        END IF;

        logmessage(fnd_log.level_statement,   'Validating Participant table Contact Person Party ID');

        IF l_borrower_valid THEN

            IF P_LOAN_PART_TBL(l_count).contact_rel_party_id IS NOT NULL THEN
                BEGIN
                    SELECT
                        p.party_id INTO l_contact_pers_party_id
                    FROM
                        hz_relationships rel,
                        hz_parties p,
                        hz_parties o,
                        hz_parties rel_party,
                        ar_lookups lkup,
                        hz_relationship_types rel_type,
                        hz_contact_points con_phone
                    WHERE   o.party_type = 'ORGANIZATION'
                        AND p.party_type = 'PERSON'
                        AND rel.subject_id = p.party_id
                        AND rel.object_id  = o.party_id
                        AND rel.relationship_code = rel_type.forward_rel_code
                        AND rel_type.create_party_flag = 'Y'
                        AND rel_type.subject_type = 'PERSON'
                        AND rel_type.object_type = 'ORGANIZATION'
                        AND rel.relationship_type = rel_type.relationship_type
                        AND rel_type.role = lkup.lookup_code
                        AND lkup.lookup_type = 'HZ_RELATIONSHIP_ROLE'
                        AND rel.party_id = rel_party.party_id
                        AND rel.status = 'A'
                        AND rel_party.status = 'A'
                        AND p.status = 'A'
                        AND con_phone.owner_table_name(+) = 'HZ_PARTIES'
                        AND con_phone.owner_table_id(+) = rel.party_id
                        AND con_phone.primary_flag(+) = 'Y'
                        AND con_phone.status(+) = 'A'
                        AND con_phone.contact_point_type(+) = 'PHONE'
                        AND rel.party_id = P_LOAN_PART_TBL(l_count).contact_rel_party_id;
                        l_valid_contact_rel := 'Y';
                EXCEPTION
                    WHEN no_data_found THEN
                    logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                              p_token1 => 'P_LOAN_PART_TBL(l_count).contact_rel_party_id',
                              p_token2 => P_LOAN_PART_TBL(l_count).contact_rel_party_id);
                END;
            END IF;

            IF l_valid_contact_rel = 'Y' THEN
                IF P_LOAN_PART_TBL(l_count).contact_pers_party_id IS NULL THEN
                    P_LOAN_PART_TBL(l_count).contact_pers_party_id := l_contact_pers_party_id;
                    l_valid_contact_pers := 'Y';
                ELSIF l_contact_pers_party_id = P_LOAN_PART_TBL(l_count).contact_pers_party_id THEN
                    l_valid_contact_pers := 'Y';
                END IF;
            END IF;

            IF ((P_LOAN_PART_TBL(l_count).contact_pers_party_id IS NOT NULL) AND (l_valid_contact_pers <> 'Y')) THEN
                BEGIN
                    SELECT
                        rel.party_id INTO l_contact_rel_party_id
                    FROM
                        hz_relationships rel,
                        hz_parties p,
                        hz_parties o,
                        hz_parties rel_party,
                        ar_lookups lkup,
                        hz_relationship_types rel_type,
                        hz_contact_points con_phone
                    WHERE   o.party_type = 'ORGANIZATION'
                        AND p.party_type = 'PERSON'
                        AND rel.subject_id = p.party_id
                        AND rel.object_id  = o.party_id
                        AND rel.relationship_code = rel_type.forward_rel_code
                        AND rel_type.create_party_flag = 'Y'
                        AND rel_type.subject_type = 'PERSON'
                        AND rel_type.object_type = 'ORGANIZATION'
                        AND rel.relationship_type = rel_type.relationship_type
                        AND rel_type.role = lkup.lookup_code
                        AND lkup.lookup_type = 'HZ_RELATIONSHIP_ROLE'
                        AND rel.party_id = rel_party.party_id
                        AND rel.status = 'A'
                        AND rel_party.status = 'A'
                        AND p.status = 'A'
                        AND con_phone.owner_table_name(+) = 'HZ_PARTIES'
                        AND con_phone.owner_table_id(+) = rel.party_id
                        AND con_phone.primary_flag(+) = 'Y'
                        AND con_phone.status(+) = 'A'
                        AND con_phone.contact_point_type(+) = 'PHONE'
                        AND p.party_id = P_LOAN_PART_TBL(l_count).contact_pers_party_id;
                        l_valid_contact_pers := 'Y';
                EXCEPTION
                    WHEN no_data_found THEN
                    logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                              p_token1 => 'P_LOAN_PART_TBL(l_count).contact_pers_party_id',
                              p_token2 => P_LOAN_PART_TBL(l_count).contact_pers_party_id);
                END;
            END IF;

            IF l_valid_contact_pers = 'Y' THEN
                IF  P_LOAN_PART_TBL(l_count).contact_rel_party_id IS NULL THEN
                    l_contact_rel_party_id := P_LOAN_PART_TBL(l_count).contact_rel_party_id;
                    l_valid_contact_rel := 'Y';
                ELSIF l_contact_rel_party_id = P_LOAN_PART_TBL(l_count).contact_rel_party_id THEN
                    l_valid_contact_rel := 'Y';
                END IF;
            END IF;

            -- Only if bothe Contact (rel and Person) are not NULL and individually both are correct but incorrect when combined
            IF (((P_LOAN_PART_TBL(l_count).contact_rel_party_id IS NOT NULL) AND (P_LOAN_PART_TBL(l_count).contact_pers_party_id IS NOT NULL)) AND ((l_valid_contact_rel <> 'Y') OR (l_valid_contact_pers <> 'Y'))) THEN
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                          p_token1 => 'P_LOAN_PART_TBL(l_count).contact_pers_party_id and ',
                          p_token2 => P_LOAN_PART_TBL(l_count).contact_pers_party_id);
            END IF;

        END IF; -- If the l_borrower_valid

    END LOOP;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

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

END validate_participants;




PROCEDURE validate_loan_lines(P_Loan_Details_Rec IN OUT NOCOPY LNS_LOAN_PUB.Loan_Details_Rec_Type
                              ,p_loan_lines_tbl IN OUT nocopy LNS_LOAN_PUB.loan_lines_tbl_type
                              ,x_return_status OUT nocopy VARCHAR2
                              ,x_msg_count OUT nocopy NUMBER
                              ,x_msg_data OUT nocopy VARCHAR2)
IS
    l_api_name constant VARCHAR2(30) := 'VALIDATE_LOAN_LINES';
    l_dummy VARCHAR2(1);
BEGIN

    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' +');

    FOR l_count IN 1 .. p_loan_lines_tbl.COUNT
    LOOP

        logmessage(fnd_log.level_statement,   'Validating Loan Line Amount...');

        IF p_loan_lines_tbl(l_count).requested_amount IS NULL THEN
            logerrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                      p_token1 => 'P_LOAN_LINES_TBL(l_count).requested_amount');
        ELSIF p_loan_lines_tbl(l_count).requested_amount <= 0 THEN
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE'
                    , p_token1 => 'P_LOAN_LINES_TBL(l_count).amount'
                    , p_token2 => p_loan_lines_tbl(l_count).requested_amount);
        END IF;

        if p_loan_lines_tbl(l_count).payment_schedule_id <> -1 then  -- let go imported loan

            BEGIN
                logmessage(fnd_log.level_statement,   'Validating payment_schedule_id...');

                select pmt_sch.customer_trx_id
                ,pmt_sch.trx_number
                ,pmt_sch.amount_due_remaining
                ,pmt_sch.terms_sequence_number
                INTO p_loan_lines_tbl(l_count).customer_trx_id
                ,p_loan_lines_tbl(l_count).REFERENCE_NUMBER
                ,p_loan_lines_tbl(l_count).remaining_balance
                ,p_loan_lines_tbl(l_count).installment_number
                FROM
                ar_payment_schedules_all pmt_sch,
                hz_cust_accounts account,
                RA_CUST_TRX_TYPES trx_type,
                ar_lookups trx_type_lkup,
                ar_lookups trx_class_lkup
                WHERE
                pmt_sch.class in ('INV','DM') and
                pmt_sch.status = 'OP' and
                pmt_sch.amount_due_remaining > 0 and
                pmt_sch.cust_trx_type_id = trx_type.CUST_TRX_TYPE_ID and
                trx_type_lkup.lookup_type = 'INV/CM' and
                trx_type_lkup.lookup_code = trx_type.type and
                trx_class_lkup.lookup_type = 'INV/CM' and
                trx_class_lkup.lookup_code = pmt_sch.class and
                pmt_sch.customer_id = account.cust_account_id and
                account.party_id = P_Loan_Details_Rec.primary_borrower_party_id and
                pmt_sch.INVOICE_CURRENCY_CODE = l_product_rec.loan_currency and
                pmt_sch.payment_schedule_id = p_loan_lines_tbl(l_count).payment_schedule_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_token1=>'p_loan_lines_tbl(l_count).payment_schedule_id'
                        ,p_token2=>p_loan_lines_tbl(l_count).payment_schedule_id);
            END;

            IF p_loan_lines_tbl(l_count).requested_amount > p_loan_lines_tbl(l_count).remaining_balance THEN

                LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                        ,p_line_number => p_loan_lines_tbl(l_count).line_number
                        ,p_token1=>'p_loan_lines_tbl(l_count).requested_amount'
                        ,p_token2=>p_loan_lines_tbl(l_count).requested_amount);
            END IF;
        else
            p_loan_lines_tbl(l_count).payment_schedule_id := to_number('-'||l_count);
        end if;

        if p_loan_lines_tbl(l_count).customer_trx_id is null then
            p_loan_lines_tbl(l_count).customer_trx_id := to_number('-'||l_count);
        end if;

        if p_loan_lines_tbl(l_count).remaining_balance is null then
            p_loan_lines_tbl(l_count).remaining_balance := 0;
        end if;

        if p_loan_lines_tbl(l_count).installment_number is null then
            p_loan_lines_tbl(l_count).installment_number := 1;
        end if;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Loan Line ' || l_count);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'line_number = ' || p_loan_lines_tbl(l_count).line_number);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'requested_amount = ' || p_loan_lines_tbl(l_count).requested_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'REFERENCE_DESCRIPTION = ' || p_loan_lines_tbl(l_count).REFERENCE_DESCRIPTION);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'REFERENCE_NUMBER = ' || p_loan_lines_tbl(l_count).REFERENCE_NUMBER);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'payment_schedule_id = ' || p_loan_lines_tbl(l_count).payment_schedule_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'customer_trx_id = ' || p_loan_lines_tbl(l_count).customer_trx_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'remaining_balance = ' || p_loan_lines_tbl(l_count).remaining_balance);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'installment_number = ' || p_loan_lines_tbl(l_count).installment_number);

    END LOOP;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

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

END;



PROCEDURE validate_rate_sched(P_Loan_Details_Rec IN OUT NOCOPY LNS_LOAN_PUB.Loan_Details_Rec_Type
                                ,p_loan_rates_tbl IN OUT nocopy LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE
                                ,p_phase IN VARCHAR2
                                ,x_return_status OUT nocopy VARCHAR2
                                ,x_msg_count OUT nocopy NUMBER
                                ,x_msg_data OUT nocopy VARCHAR2)
IS
    l_api_name constant VARCHAR2(30) := 'validate_rate_sched';
    l_return_status VARCHAR2(1);
    l_dummy VARCHAR2(1);
    l_num_temp NUMBER;
    l_current_int_rate NUMBER;
    l_spread NUMBER;
    l_floor_rate NUMBER;
    l_ceiling_rate NUMBER;
    l_index_date DATE;

BEGIN
    -- Initialize API return status to success
    l_return_status := fnd_api.g_ret_sts_success;

    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' +');

    if p_phase = 'TERM' then
        l_floor_rate := P_Loan_Details_Rec.floor_rate;
        l_ceiling_rate := P_Loan_Details_Rec.ceiling_rate;
        l_index_date := P_Loan_Details_Rec.loan_start_date;
    else
        l_floor_rate := P_Loan_Details_Rec.open_floor_rate;
        l_ceiling_rate := P_Loan_Details_Rec.open_ceiling_rate;
        l_index_date := P_Loan_Details_Rec.open_loan_start_date;
    end if;

    if p_loan_rates_tbl.COUNT = 0 then
        p_loan_rates_tbl(1).INDEX_DATE := l_index_date;
        p_loan_rates_tbl(1).BEGIN_INSTALLMENT_NUMBER := 1;
        p_loan_rates_tbl(1).END_INSTALLMENT_NUMBER := -1;
    end if;

    logmessage(fnd_log.level_unexpected,   'Validating Rate Schedule...');
    FOR l_count IN 1 .. p_loan_rates_tbl.COUNT
    LOOP

        logmessage(fnd_log.level_statement,   'Rate Record ' || l_count);
        logmessage(fnd_log.level_statement,   'INDEX_RATE = ' || p_loan_rates_tbl(l_count).INDEX_RATE);
        logmessage(fnd_log.level_statement,   'SPREAD = ' || p_loan_rates_tbl(l_count).SPREAD);
        logmessage(fnd_log.level_statement,   'INDEX_DATE = ' || p_loan_rates_tbl(l_count).INDEX_DATE);
        logmessage(fnd_log.level_statement,   'BEGIN_INSTALLMENT_NUMBER = ' || p_loan_rates_tbl(l_count).BEGIN_INSTALLMENT_NUMBER);
        logmessage(fnd_log.level_statement,   'END_INSTALLMENT_NUMBER = ' || p_loan_rates_tbl(l_count).END_INSTALLMENT_NUMBER);
        logmessage(fnd_log.level_statement,   'INTEREST_ONLY_FLAG = ' || p_loan_rates_tbl(l_count).INTEREST_ONLY_FLAG);

        logmessage(fnd_log.level_statement,   'Validating Index Date');

        IF (p_loan_rates_tbl(l_count).index_date IS NOT NULL AND P_Loan_Details_Rec.INDEX_RATE_ID IS NOT NULL) THEN

            BEGIN
                SELECT line.interest_rate
                INTO l_num_temp
                FROM lns_int_rate_headers hdr,
                lns_int_rate_lines line
                WHERE hdr.interest_rate_id = line.interest_rate_id
                AND(p_loan_rates_tbl(l_count).index_date BETWEEN line.start_date_active
                AND line.end_date_active)
                AND hdr.interest_rate_id = P_Loan_Details_Rec.INDEX_RATE_ID;

                p_loan_rates_tbl(l_count).index_rate := l_num_temp;

            EXCEPTION
                WHEN others THEN
                    logmessage(fnd_log.level_procedure,   'Index Rate incorrect');
            END;
        END IF;

        logmessage(fnd_log.level_statement,   'Validating Index Rate');

        IF p_loan_rates_tbl(l_count).index_rate IS NULL THEN
            logerrors(p_message_name => 'LNS_LCREATE_NULL_VALUE',
                      p_token1 => 'p_loan_rates_tbl(' || l_count || ').index_rate');
        END IF;

        logmessage(fnd_log.level_statement,   'Validating spread');

        if p_phase = 'TERM' then
            p_loan_rates_tbl(l_Count).spread :=
                    CASE l_override_rec.spread_ovr
                    WHEN 'Y' THEN nvl(p_loan_rates_tbl(l_Count).spread, l_product_rec.spread)
                    ELSE l_product_rec.spread
                    END;
        else
            p_loan_rates_tbl(l_Count).spread :=
                    CASE l_override_rec.OPEN_SPREAD_OVR
                    WHEN 'Y' THEN nvl(p_loan_rates_tbl(l_Count).spread, l_product_rec.open_spread)
                    ELSE l_product_rec.open_spread
                    END;
        end if;

        IF p_loan_rates_tbl(l_count).spread IS NULL THEN
            p_loan_rates_tbl(l_count).spread := 0;
        END IF;

        logmessage(fnd_log.level_statement,   'Validating current_int_rate');

        l_current_int_rate := p_loan_rates_tbl(l_count).index_rate + p_loan_rates_tbl(l_count).spread;

        IF (l_current_int_rate < nvl(l_floor_rate, l_current_int_rate)) OR
           (l_current_int_rate > nvl(l_ceiling_rate, l_current_int_rate)) OR
           (l_current_int_rate < 0) OR (l_current_int_rate > 100)
        THEN
            logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                      p_token1 => 'p_loan_rates_tbl(l_count).index_rate',
                      p_token2 => p_loan_rates_tbl(l_count).index_rate);
        END IF;

        logmessage(fnd_log.level_statement,   'Validating Interest Only Flag');

        IF p_loan_rates_tbl(l_count).interest_only_flag IS NOT NULL THEN
            IF p_loan_rates_tbl(l_count).interest_only_flag <> 'Y' AND
               p_loan_rates_tbl(l_count).interest_only_flag <> 'N'
            THEN
                logerrors(p_message_name => 'LNS_LCREATE_INVALID_ATTRIBUTE',
                      p_token1 => 'p_loan_rates_tbl(l_count).interest_only_flag',
                      p_token2 => p_loan_rates_tbl(l_count).interest_only_flag);
            END IF;
        ELSE
            p_loan_rates_tbl(l_count).interest_only_flag := 'N';
        END IF;

        if l_product_rec.allow_interest_only_flag = 'N' and p_loan_rates_tbl(l_count).interest_only_flag = 'Y' then
            p_loan_rates_tbl(l_count).interest_only_flag := 'N';
        end if;

    END LOOP;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

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

END;




/*
This procedure synchs rate schedule with new number of installments in memory only, no changes to db
*/
procedure synchRateSchedule(p_rate_tbl IN OUT NOCOPY LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE, p_num_installments in number)

is

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_RATE_ID                       number;
    l_BEGIN_INSTALLMENT             number;
    l_END_INSTALLMENT               number;
    i                               number;
    l_rate_tbl                      LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

begin

    logmessage(fnd_log.level_statement, 'Synching rate schedule...');
    logmessage(fnd_log.level_statement, 'p_num_installments: ' || p_num_installments);

    l_rate_tbl := p_rate_tbl;

    -- finding right rate row and update it
    for i in REVERSE 1..l_rate_tbl.count loop

        l_BEGIN_INSTALLMENT := l_rate_tbl(i).BEGIN_INSTALLMENT_NUMBER;
        l_END_INSTALLMENT := l_rate_tbl(i).END_INSTALLMENT_NUMBER;

        logmessage(fnd_log.level_statement, i || ': ' || l_BEGIN_INSTALLMENT || ' - ' || l_END_INSTALLMENT);

        if p_num_installments > l_END_INSTALLMENT then

            logmessage(fnd_log.level_statement, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || p_num_installments);
            l_rate_tbl(i).END_INSTALLMENT_NUMBER := p_num_installments;

            exit;

        elsif p_num_installments >= l_BEGIN_INSTALLMENT and p_num_installments <= l_END_INSTALLMENT then

            logmessage(fnd_log.level_statement, 'Updating this row - set END_INSTALLMENT_NUMBER = ' || p_num_installments);
            l_rate_tbl(i).END_INSTALLMENT_NUMBER := p_num_installments;

            exit;

        elsif p_num_installments < l_BEGIN_INSTALLMENT then

            logmessage(fnd_log.level_statement, 'Deleting this row');
            l_rate_tbl.delete(i);

        end if;

    END LOOP;

    p_rate_tbl := l_rate_tbl;
    logmessage(fnd_log.level_statement, 'Done synching');

end;



PROCEDURE create_FEE_ASSIGNMENT(P_LOAN_ID IN NUMBER
                                ,x_return_status OUT nocopy VARCHAR2
                                ,x_msg_count OUT nocopy NUMBER
                                ,x_msg_data OUT nocopy VARCHAR2)
IS

    CURSOR loan_prod_fee ( c_loan_id NUMBER ) IS
    select LNS_FEE_ASSIGNMENTS_S.NEXTVAL FEE_ASSIGNMENT_ID,
        LnsLoanHeaders.LOAN_ID,
        LnsFees.FEE_ID,
        --decode(LnsFees.RATE_TYPE,'VARIABLE', lns_fee_engine.calculateFee(LnsFees.FEE_ID,LnsLoanHeaders.LOAN_ID) ,LnsFees.FEE) FEE,
	LnsFees.FEE,
        LnsFees.FEE_TYPE,
        LnsFees.FEE_BASIS,
        LnsFees.NUMBER_GRACE_DAYS,
        LnsFees.COLLECTED_THIRD_PARTY_FLAG,
        LnsFees.RATE_TYPE,
        decode(LnsFees.BILLING_OPTION,'ORIGINATION',0,
	    'SUBMIT_FOR_APPROVAL',0,
	    'TERM_CONVERSION',0,
            'BILL_WITH_INSTALLMENT',1,
            (decode(LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT(LnsLoanHeaders.LOAN_ID) ,
                -1 , 0 , LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT(LnsLoanHeaders.LOAN_ID)) + 1 )
        ) BEGIN_INSTALLMENT_NUMBER,
        decode(LnsFees.BILLING_OPTION,'ORIGINATION',0,
	    'SUBMIT_FOR_APPROVAL',0,
	    'TERM_CONVERSION',0,
            'BILL_WITH_INSTALLMENT',1,
            lns_fin_utils.getnumberinstallments(LnsLoanHeaders.LOAN_ID)) END_INSTALLMENT_NUMBER,

        NULL NUMBER_OF_PAYMENTS,
        LnsFees.BILLING_OPTION,
        NULL CREATED_BY,
        NULL CREATION_DATE,
        NULL LAST_UPDATED_BY,
        NULL LAST_UPDATE_DATE,
        NULL LAST_UPDATE_LOGIN,
        1 OBJECT_VERSION_NUMBER,
        sysdate START_DATE_ACTIVE,
        NULL END_DATE_ACTIVE,
        NULL DISB_HEADER_ID,
        LnsLoanProductLines.MANDATORY_FLAG,
	NULL OPEN_PHASE_FLAG,
	NULL PHASE
    FROM LNS_FEES LnsFees ,
    LNS_LOAN_HEADERS LnsLoanHeaders ,
    LNS_LOAN_PRODUCT_LINES LnsLoanProductLines
    WHERE LnsLoanHeaders.LOAN_ID = c_loan_id
    AND LnsLoanHeaders.PRODUCT_ID = LnsLoanProductLines.LOAN_PRODUCT_ID
    AND LnsLoanProductLines.LOAN_PRODUCT_LINE_TYPE = 'FEE'
    AND LnsLoanProductLines.LINE_REFERENCE_ID = LnsFees.FEE_ID ;

    CURSOR fee_account_lines ( c_fee_id NUMBER ) IS
        SELECT  LINE_TYPE, ACCOUNT_NAME, CODE_COMBINATION_ID, ACCOUNT_TYPE, DISTRIBUTION_PERCENT, DISTRIBUTION_TYPE
        FROM LNS_DEFAULT_DISTRIBS
        WHERE ACCOUNT_NAME = 'FEE_RECEIVABLE' OR FEE_ID = c_fee_id ;

    CURSOR current_loan_status ( c_loan_id NUMBER ) IS
        SELECT LOAN_STATUS , CURRENT_PHASE
        FROM LNS_LOAN_HEADERS LnsLoanHeaders
        WHERE LnsLoanHeaders.LOAN_ID = c_loan_id ;


    CURSOR loan_fee_exists ( c_loan_id NUMBER ) IS
        SELECT 'Y'
        FROM DUAL
        WHERE
        EXISTS
        (SELECT NULL FROM LNS_FEE_ASSIGNMENTS LnsFeeAssignments
        WHERE LnsFeeAssignments.LOAN_ID = c_loan_id)
        OR EXISTS
        (SELECT NULL FROM LNS_LOAN_HISTORIES_H
        WHERE TABLE_NAME = 'LNS_FEE_ASSIGNMENTS' AND LOAN_ID = c_loan_id) ;

    l_fee_assignment_rec    LNS_FEE_ASSIGNMENT_PUB.fee_assignment_rec_type ;
    l_fee_assignment_id     NUMBER ;
    l_loan_status           LNS_LOAN_HEADERS.LOAN_STATUS%TYPE ;
    l_loan_current_phase    LNS_LOAN_HEADERS.CURRENT_PHASE%TYPE ;
    l_loan_fee_exists       VARCHAR2(1) ;

    l_line_type             LNS_DEFAULT_DISTRIBS.LINE_TYPE%TYPE ;
    l_account_name          LNS_DEFAULT_DISTRIBS.ACCOUNT_NAME%TYPE ;
    l_code_combination_id   LNS_DEFAULT_DISTRIBS.CODE_COMBINATION_ID%TYPE ;
    l_account_type          LNS_DEFAULT_DISTRIBS.ACCOUNT_TYPE%TYPE ;
    l_distribution_percent  LNS_DEFAULT_DISTRIBS.DISTRIBUTION_PERCENT%TYPE ;
    l_distribution_type     LNS_DEFAULT_DISTRIBS.DISTRIBUTION_TYPE%TYPE ;

    l_return_status         VARCHAR2(1) ;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_api_name constant VARCHAR2(30) := 'create_FEE_ASSIGNMENT';

BEGIN

    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' +');

    logmessage(fnd_log.level_statement, 'Before opening cursor current_loan_status');
    OPEN current_loan_status(P_LOAN_ID) ;
    FETCH current_loan_status INTO l_loan_status ,l_loan_Current_phase ;

    logmessage(fnd_log.level_statement, 'l_loan_status = ' || l_loan_status);
    logmessage(fnd_log.level_statement, 'l_loan_Current_phase = ' || l_loan_Current_phase);

    /* If the loan current phase is not open or loan status is not Incomplete for Term loan , no fees assignment required  */
    IF( NOT ( ( l_loan_status='INCOMPLETE' AND l_loan_current_phase = 'TERM' ) OR ( l_loan_current_phase = 'OPEN' ) ) ) THEN
	        RETURN;
    END IF;

    logmessage(fnd_log.level_statement, 'Before opening cursor loan_fee_exists');
    OPEN loan_fee_exists(P_LOAN_ID) ;
    FETCH loan_fee_exists INTO l_loan_fee_exists ;

    logmessage(fnd_log.level_statement, 'l_loan_fee_exists = ' || l_loan_fee_exists);

    /* If the loan fee count is not zero and there are already fees assigned to loan, no fees assignment required  */
    IF( l_loan_fee_exists = 'Y' ) THEN
	        RETURN;
    END IF;

    logmessage(fnd_log.level_statement, 'Before opening cursor loan_prod_fee');
    OPEN loan_prod_fee(P_LOAN_ID) ;

    LOOP

        FETCH loan_prod_fee INTO l_fee_assignment_rec;
        EXIT WHEN loan_prod_fee%NOTFOUND;

        l_fee_assignment_id := l_fee_assignment_rec.fee_assignment_id ;

        logmessage(fnd_log.level_statement, 'l_fee_assignment_id = ' || l_fee_assignment_id);
        logmessage(fnd_log.level_statement, 'Before call to do_create_FEE_ASSIGNMENT proc for fee ' || l_fee_assignment_rec.FEE_ID);

     IF (l_loan_Current_phase = 'OPEN'
          AND  (  (l_fee_assignment_rec.FEE_TYPE = 'EVENT_ORIGINATION')
		      OR ( l_fee_assignment_rec.FEE_TYPE = 'EVENT_FUNDING')
	  	   )
	) THEN

	l_fee_assignment_rec.phase := 'OPEN';
     ELSE
	l_fee_assignment_rec.phase := 'TERM';
     END IF;

        LNS_FEE_ASSIGNMENT_PUB.create_fee_assignment('T',
                                        l_fee_assignment_rec,
                                        l_fee_assignment_id,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data);

        logmessage(fnd_log.level_statement, 'l_return_status = ' || l_return_status);
        IF l_return_status <> 'S' THEN
	        RAISE FND_API.G_EXC_ERROR;
        END IF;

        logmessage(fnd_log.level_statement, 'Before opening cursor fee_account_lines');
        OPEN fee_account_lines(l_fee_assignment_rec.fee_id) ;

        LOOP

            FETCH fee_account_lines INTO l_line_type, l_account_name, l_code_combination_id, l_account_type, l_distribution_percent, l_distribution_type;
            EXIT WHEN fee_account_lines%NOTFOUND ;

            logmessage(fnd_log.level_statement, 'l_line_type = ' || l_line_type);
            logmessage(fnd_log.level_statement, 'l_account_name = ' || l_account_name);
            logmessage(fnd_log.level_statement, 'l_code_combination_id = ' || l_code_combination_id);
            logmessage(fnd_log.level_statement, 'l_account_type = ' || l_account_type);
            logmessage(fnd_log.level_statement, 'l_distribution_percent = ' || l_distribution_percent);
            logmessage(fnd_log.level_statement, 'l_distribution_type = ' || l_distribution_type);

            logmessage(fnd_log.level_statement, 'Inserting into lns_distributions...');
            Insert into lns_distributions
                        (DISTRIBUTION_ID
                        ,LOAN_ID
                        ,LINE_TYPE
                        ,ACCOUNT_NAME
                        ,CODE_COMBINATION_ID
                        ,ACCOUNT_TYPE
                        ,DISTRIBUTION_PERCENT
                        ,DISTRIBUTION_TYPE
                        ,FEE_ID
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,OBJECT_VERSION_NUMBER )
                        values
                        (LNS_DISTRIBUTIONS_S.nextval
                        ,p_loan_id
                        ,l_line_type
                        ,l_account_name
                        ,l_code_combination_id
                        ,l_account_type
                        ,l_distribution_percent
                        ,l_distribution_type
                        ,l_fee_assignment_rec.fee_id
                        ,lns_utility_pub.creation_date
                        ,lns_utility_pub.created_by
                        ,lns_utility_pub.last_update_date
                        ,lns_utility_pub.last_updated_by
                        ,1) ;
            logmessage(fnd_log.level_statement, 'Done');

        END LOOP ;

        CLOSE fee_account_lines ;

    END LOOP ;

    x_return_status := fnd_api.g_ret_sts_success;
    logmessage(fnd_log.level_procedure,   g_pkg_name || '.' || l_api_name || ' -');

EXCEPTION
    WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_count => x_msg_count,   p_data => x_msg_data);
END create_FEE_ASSIGNMENT;




PROCEDURE CREATE_LOAN(
    P_API_VERSION           IN         NUMBER,
    P_INIT_MSG_LIST		    IN         VARCHAR2,
    P_COMMIT                IN         VARCHAR2,
    P_VALIDATION_LEVEL	    IN         NUMBER,
    P_Loan_Details_Rec      IN OUT NOCOPY LNS_LOAN_PUB.Loan_Details_Rec_Type,  -- mandatory
    P_Loan_Lines_Tbl        IN OUT NOCOPY LNS_LOAN_PUB.Loan_Lines_Tbl_Type,  --only for ERS loan
    P_LOAN_PART_TBL         IN OUT NOCOPY LNS_LOAN_PUB.LOAN_PART_TBL_TYPE,  -- optional
    P_OPEN_RATES_TBL        IN OUT NOCOPY LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE,  -- optional
    P_TERM_RATES_TBL        IN OUT NOCOPY LNS_LOAN_PUB.LOAN_RATES_TBL_TYPE,  -- optional
    p_loan_cust_sched_tbl   IN OUT NOCOPY LNS_LOAN_PUB.loan_cust_sched_tbl_type,  -- optional
    P_Application_id        IN         NUMBER,
    P_Created_by_module     IN         VARCHAR2,
    X_LOAN_ID               OUT NOCOPY NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY VARCHAR2)
IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'CREATE_LOAN';
    l_api_version                   CONSTANT NUMBER := 1.0;

    product_not_found EXCEPTION;
    error_while_insert EXCEPTION;
    l_generate_loan_number VARCHAR2(1);
    l_loan_id number(15);
    l_loan_number VARCHAR2(60);
    l_header_insert_success VARCHAR2(1);
    l_participant_id NUMBER(15);
    l_part_insert_success VARCHAR2(1);
    l_term_id NUMBER(15);
    l_term_insert_success VARCHAR2(1);
    l_object_version_number NUMBER(15);
    l_ers_requested_amount NUMBER;
    l_term_update_success VARCHAR2(1);
    l_count NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
    l_end_installment_number NUMBER;
    l_pay_in_arrears_bool       boolean;
    l_prin_pay_in_arrears_bool  boolean;

    l_loan_rec                LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_term_rec                LNS_TERMS_PUB.loan_term_rec_type;
    l_rate_open_rec           lns_rate_schedules%ROWTYPE;
    l_participant_rec         LNS_PARTICIPANTS_PUB.loan_participant_rec_type;
    l_custom_tbl              lns_custom_pub.custom_tbl;
    l_payment_tbl             LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    SAVEPOINT CREATE_LOAN;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Initialize Collections and Variables
    g_errors_rec.delete;
    g_error_count := 0;

    -- Get the product values
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating product_id...');
    IF P_Loan_Details_Rec.product_id is NULL THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.product_id');
        -- If Product not found dont bother with further processing
        raise product_not_found;
    ELSE
        OPEN Csr_Product_values(P_Loan_Details_Rec.product_id);
        FETCH Csr_Product_values
        INTO  l_product_rec;
        IF Csr_Product_values%NOTFOUND THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
                    ,p_token1=>'P_Loan_Details_Rec.product_id'
                    ,p_token2=>P_Loan_Details_Rec.product_id);
            CLOSE Csr_Product_values;
            raise product_not_found;
        END IF;
        CLOSE Csr_Product_values;

        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Product defaults:');
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_type_id = ' || l_product_rec.loan_type_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_class_code = ' || l_product_rec.loan_class_code);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_type_name = ' || l_product_rec.loan_type_name);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'multiple_funding_flag = ' || l_product_rec.multiple_funding_flag);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_to_term_flag = ' || l_product_rec.open_to_term_flag);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'credit_review_flag = ' || l_product_rec.credit_review_flag);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_product_id = ' || l_product_rec.loan_product_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_product_name = ' || l_product_rec.loan_product_name);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_term = ' || l_product_rec.loan_term);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_term_period = ' || l_product_rec.loan_term_period);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'max_loan_term = ' || l_product_rec.max_loan_term);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'max_loan_term_period = ' || l_product_rec.max_loan_term_period);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_currency = ' || l_product_rec.loan_currency);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'requested_amount = ' || l_product_rec.requested_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'max_requested_amount = ' || l_product_rec.max_requested_amount);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'index_rate_id = ' || l_product_rec.index_rate_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'rate_type = ' || l_product_rec.rate_type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'spread = ' || l_product_rec.spread);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'floor_rate = ' || l_product_rec.floor_rate);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'ceiling_rate = ' || l_product_rec.ceiling_rate);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'interest_compounding_freq = ' || l_product_rec.interest_compounding_freq);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_payment_frequency = ' || l_product_rec.loan_payment_frequency);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_subtype = ' || l_product_rec.loan_subtype);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'collateral_percent = ' || l_product_rec.collateral_percent);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'allow_interest_only_flag = ' || l_product_rec.allow_interest_only_flag);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'reamortize_over_payment = ' || l_product_rec.reamortize_over_payment);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'org_id = ' || l_product_rec.org_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'legal_entity_id = ' || l_product_rec.legal_entity_id);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'rate_change_frequency = ' || l_product_rec.rate_change_frequency);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'payment_application_order = ' || l_product_rec.payment_application_order);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'pmt_appl_order_scope = ' || l_product_rec.pmt_appl_order_scope);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_floor_rate = ' || l_product_rec.open_floor_rate);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_ceiling_rate = ' || l_product_rec.open_ceiling_rate);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'reamortize_under_payment = ' || l_product_rec.reamortize_under_payment);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'percent_increase = ' || l_product_rec.percent_increase);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'percent_increase_life = ' || l_product_rec.percent_increase_life);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_percent_increase = ' || l_product_rec.open_percent_increase);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_percent_increase_life = ' || l_product_rec.open_percent_increase_life);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_spread = ' || l_product_rec.open_spread);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'credit_review_type = ' || l_product_rec.credit_review_type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'guarantor_review_type = ' || l_product_rec.guarantor_review_type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'party_type = ' || l_product_rec.party_type);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_term = ' || l_product_rec.open_loan_term);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_term_period = ' || l_product_rec.open_loan_term_period);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_max_loan_term = ' || l_product_rec.open_max_loan_term);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_max_loan_term_period = ' || l_product_rec.open_max_loan_term_period);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CALCULATION_METHOD = ' || l_product_rec.CALCULATION_METHOD);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'day_count_method = ' || l_product_rec.day_count_method);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_FLAG = ' || l_product_rec.FORGIVENESS_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_PERCENT = ' || l_product_rec.FORGIVENESS_PERCENT);
    END IF;

    -- Get Override Allowed Flags
    OPEN Csr_override_flags(P_Loan_Details_Rec.product_id);
    FETCH Csr_override_flags
    into  l_override_rec;
    CLOSE Csr_override_flags;

    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Override flags:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LEGAL_ENTITY_ID_OVR = ' || l_override_rec.LEGAL_ENTITY_ID_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_TERM_OVR = ' || l_override_rec.LOAN_TERM_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_TERM_PERIOD_OVR = ' || l_override_rec.LOAN_TERM_PERIOD_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INDEX_RATE_ID_OVR = ' || l_override_rec.INDEX_RATE_ID_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RATE_TYPE_OVR = ' || l_override_rec.RATE_TYPE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'INTEREST_COMPOUNDING_FREQ_OVR = ' || l_override_rec.INTEREST_COMPOUNDING_FREQ_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_SPREAD_OVR = ' || l_override_rec.OPEN_SPREAD_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_FLOOR_RATE_OVR = ' || l_override_rec.OPEN_FLOOR_RATE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_CEILING_RATE_OVR = ' || l_override_rec.OPEN_CEILING_RATE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_PERCENT_INCREASE_OVR = ' || l_override_rec.OPEN_PERCENT_INCREASE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'OPEN_PERCENT_INCREASE_LIFE_OVR = ' || l_override_rec.OPEN_PERCENT_INCREASE_LIFE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'SPREAD_OVR = ' || l_override_rec.SPREAD_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FLOOR_RATE_OVR = ' || l_override_rec.FLOOR_RATE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CEILING_RATE_OVR = ' || l_override_rec.CEILING_RATE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PERCENT_INCREASE_OVR = ' || l_override_rec.PERCENT_INCREASE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PERCENT_INCREASE_LIFE_OVR = ' || l_override_rec.PERCENT_INCREASE_LIFE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_PAYMENT_FREQ_OVR = ' || l_override_rec.LOAN_PAYMENT_FREQ_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOAN_SUBTYPE_OVR = ' || l_override_rec.LOAN_SUBTYPE_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'REAMORTIZE_OVER_PAYMENT_OVR = ' || l_override_rec.REAMORTIZE_OVER_PAYMENT_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DAY_COUNT_METHOD_OVR = ' || l_override_rec.DAY_COUNT_METHOD_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'CALCULATION_METHOD_OVR = ' || l_override_rec.CALCULATION_METHOD_OVR);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'RATE_CHANGE_FREQUENCY_OVR = ' || l_override_rec.RATE_CHANGE_FREQUENCY_OVR);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating P_Created_by_module...');
    -- Validate P_Created_by_module
    IF P_Created_by_module IS NULL THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Created_by_module');
    END IF;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating P_Application_id...');
    -- Validate P_Application_id
    IF P_Application_id IS NULL THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Application_id');
    END IF;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    -- validating loan details
    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    validate_loan_header_details(P_Loan_Details_Rec
                                ,p_loan_cust_sched_tbl
                                ,l_return_status
                                ,l_msg_count
                                ,l_msg_data);

    IF l_return_status <> 'S' THEN
        logmessage(fnd_log.level_unexpected,   'Validation failed in module - validate_loan_header_details()');
        RAISE fnd_api.g_exc_error;
    END IF;

    -- validating loan participants
    IF p_loan_part_tbl.COUNT > 0 THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        validate_participants(p_loan_part_tbl
                            , l_return_status
                            , l_msg_count
                            , l_msg_data);
        IF l_return_status <> 'S' THEN
            logmessage(fnd_log.level_unexpected,   'Validation failed in module - validate_participants()');
            RAISE fnd_api.g_exc_error;
        END IF;
    END IF;

    -- add PRIMARY_BORROWER to participants table
    l_count := p_loan_part_tbl.count + 1;

    p_loan_part_tbl(l_count).HZ_PARTY_ID := P_Loan_Details_Rec.primary_borrower_party_id;
    p_loan_part_tbl(l_count).LOAN_PARTICIPANT_TYPE := 'PRIMARY_BORROWER';
    p_loan_part_tbl(l_count).START_DATE_ACTIVE := P_Loan_Details_Rec.loan_start_date;
    p_loan_part_tbl(l_count).END_DATE_ACTIVE := null;
    p_loan_part_tbl(l_count).CUST_ACCOUNT_ID := P_Loan_Details_Rec.cust_account_id;
    p_loan_part_tbl(l_count).BILL_TO_ACCT_SITE_ID := P_Loan_Details_Rec.bill_to_acct_site_id;
    p_loan_part_tbl(l_count).CONTACT_PERS_PARTY_ID := P_Loan_Details_Rec.contact_pers_party_id;
    p_loan_part_tbl(l_count).CONTACT_REL_PARTY_ID := P_Loan_Details_Rec.contact_rel_party_id;

    IF l_product_rec.loan_class_code = 'ERS' THEN
        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        IF p_loan_lines_tbl.COUNT > 0 THEN
            validate_loan_lines(P_Loan_Details_Rec
                                ,p_loan_lines_tbl
                                ,l_return_status
                                ,l_msg_count
                                ,l_msg_data);
            IF l_return_status <> 'S' THEN
                logmessage(fnd_log.level_unexpected,   'Validation failed in module - validate_loan_lines()');
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;
        -- ELSE invoices will be derived by ers rule
    END IF;

    if l_product_rec.multiple_funding_flag = 'Y' then
        -- validate open rate schedule
        LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
        validate_rate_sched(P_Loan_Details_Rec
                            ,p_open_rates_tbl
                            ,'OPEN'
                            ,l_return_status
                            ,l_msg_count
                            ,l_msg_data);
        IF l_return_status <> 'S' THEN
            logmessage(fnd_log.level_unexpected,   'Validation failed in module - open validate_rate_sched()');
            RAISE fnd_api.g_exc_error;
        END IF;
    end if;

    -- validate term rate schedule
    LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    validate_rate_sched(P_Loan_Details_Rec
                        ,p_term_rates_tbl
                        ,'TERM'
                        ,l_return_status
                        ,l_msg_count
                        ,l_msg_data);
    IF l_return_status <> 'S' THEN
        logmessage(fnd_log.level_unexpected,   'Validation failed in module - term validate_rate_sched()');
        RAISE fnd_api.g_exc_error;
    END IF;


    -- loan record
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Setting l_loan_rec record...');

    select LNS_LOAN_HEADERS_S.nextval
    into   l_loan_rec.loan_id
    from dual;
    l_loan_rec.product_id := P_Loan_Details_Rec.product_id;

    -- Validate Loan Number
    -- If Profile not set to Autogenerate make Loan Number Mandatory.
    l_generate_loan_number := fnd_profile.value('LNS_GENERATE_LOAN_NUMBER');
    IF l_generate_loan_number IS NULL THEN
        l_generate_loan_number := 'N';
    END IF;
    IF P_Loan_Details_Rec.loan_number is NULL AND l_generate_loan_number = 'N' THEN
        LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
                ,p_token1=>'P_Loan_Details_Rec.loan_number');
    END IF;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_generate_loan_number = ' || l_generate_loan_number);

    IF l_generate_loan_number = 'Y' THEN
        select 'L' || LNS_LOAN_NUMBER_S.nextval
        into   P_Loan_Details_Rec.loan_number
        from   dual;
    END IF;
    l_loan_rec.loan_number := P_Loan_Details_Rec.loan_number;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_loan_rec.loan_number = ' || l_loan_rec.loan_number);

    l_loan_rec.loan_description := P_Loan_Details_Rec.loan_description;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_description = ' || l_loan_rec.loan_description);

    l_loan_rec.requested_amount := P_Loan_Details_Rec.requested_amount;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'requested_amount = ' || l_loan_rec.requested_amount);

    l_loan_rec.loan_start_date := P_Loan_Details_Rec.loan_start_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_start_date = ' || l_loan_rec.loan_start_date);

    l_loan_rec.loan_term := P_Loan_Details_Rec.loan_term;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_term = ' || l_loan_rec.loan_term);

    l_loan_rec.loan_term_period := P_Loan_Details_Rec.loan_term_period;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_term_period = ' || l_loan_rec.loan_term_period);

    l_loan_rec.balloon_payment_type := P_Loan_Details_Rec.balloon_payment_type;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'balloon_payment_type = ' || l_loan_rec.balloon_payment_type);

    l_loan_rec.balloon_payment_amount := P_Loan_Details_Rec.balloon_payment_amount;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'balloon_payment_amount = ' || l_loan_rec.balloon_payment_amount);

    l_loan_rec.amortized_term := P_Loan_Details_Rec.balloon_term;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'amortized_term = ' || l_loan_rec.amortized_term);

    l_loan_rec.amortized_term_period := P_Loan_Details_Rec.loan_term_period;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'amortized_term_period = ' || l_loan_rec.amortized_term_period);

    l_loan_rec.loan_maturity_date := P_Loan_Details_Rec.maturity_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_maturity_date = ' || l_loan_rec.loan_maturity_date);

    l_loan_rec.legal_entity_id := P_Loan_Details_Rec.legal_entity_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'legal_entity_id = ' || l_loan_rec.legal_entity_id);

    P_Loan_Details_Rec.org_id := l_product_rec.org_id;
    l_loan_rec.org_id := P_Loan_Details_Rec.org_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'org_id = ' || l_loan_rec.org_id);

    P_Loan_Details_Rec.loan_type_id := l_product_rec.loan_type_id;
    l_loan_rec.loan_type_id := P_Loan_Details_Rec.loan_type_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_type_id = ' || l_loan_rec.loan_type_id);

    P_Loan_Details_Rec.loan_class_code := l_product_rec.loan_class_code;
    l_loan_rec.loan_class_code := P_Loan_Details_Rec.loan_class_code;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_class_code = ' || l_loan_rec.loan_class_code);

    l_loan_rec.loan_subtype := P_Loan_Details_Rec.loan_subtype;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_subtype = ' || l_loan_rec.loan_subtype);

    l_loan_rec.loan_application_date := P_Loan_Details_Rec.loan_application_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_application_date = ' || l_loan_rec.loan_application_date);

    l_loan_rec.gl_date := P_Loan_Details_Rec.loan_start_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'gl_date = ' || l_loan_rec.gl_date);

    l_loan_rec.loan_assigned_to := P_Loan_Details_Rec.loan_assigned_to;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_assigned_to = ' || l_loan_rec.loan_assigned_to);

    l_loan_rec.loan_status := 'INCOMPLETE';
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_status = ' || l_loan_rec.loan_status);

    l_loan_rec.party_type  := l_product_rec.party_type;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'party_type = ' || l_loan_rec.party_type);

    l_loan_rec.primary_borrower_id := P_Loan_Details_Rec.primary_borrower_party_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'primary_borrower_id = ' || l_loan_rec.primary_borrower_id);

    l_loan_rec.cust_account_id := P_Loan_Details_Rec.cust_account_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'cust_account_id = ' || l_loan_rec.cust_account_id);

    l_loan_rec.bill_to_acct_site_id := P_Loan_Details_Rec.bill_to_acct_site_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'bill_to_acct_site_id = ' || l_loan_rec.bill_to_acct_site_id);

    l_loan_rec.contact_pers_party_id := P_Loan_Details_Rec.contact_pers_party_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'contact_pers_party_id = ' || l_loan_rec.contact_pers_party_id);

    l_loan_rec.contact_rel_party_id := P_Loan_Details_Rec.contact_rel_party_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'contact_rel_party_id = ' || l_loan_rec.contact_rel_party_id);

    l_loan_rec.credit_review_flag := P_Loan_Details_Rec.credit_review_flag;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'credit_review_flag = ' || l_loan_rec.credit_review_flag);

    l_loan_rec.loan_purpose_code := P_Loan_Details_Rec.loan_purpose_code;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_purpose_code = ' || l_loan_rec.loan_purpose_code);

    l_loan_rec.collateral_percent := P_Loan_Details_Rec.collateral_percent;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'collateral_percent = ' || l_loan_rec.collateral_percent);

    l_loan_rec.reference_type_id :=
                CASE l_product_rec.loan_class_code
                WHEN 'ERS' THEN P_Loan_Details_Rec.trx_type_id
                ELSE  NULL
                END;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'reference_type_id = ' || l_loan_rec.reference_type_id);

    l_loan_rec.current_phase :=
                CASE l_loan_rec.multiple_funding_flag
                WHEN 'Y' THEN 'OPEN'
                ELSE 'TERM'
                END;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'current_phase = ' || l_loan_rec.current_phase);

    P_Loan_Details_Rec.loan_currency := l_product_rec.loan_currency;
    l_loan_rec.loan_currency := P_Loan_Details_Rec.loan_currency;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_currency = ' || l_loan_rec.loan_currency);

    l_loan_rec.exchange_rate_type := P_Loan_Details_Rec.exchange_rate_type;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'exchange_rate_type = ' || l_loan_rec.exchange_rate_type);

    l_loan_rec.exchange_date := P_Loan_Details_Rec.exchange_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'exchange_date = ' || l_loan_rec.exchange_date);

    l_loan_rec.exchange_rate := P_Loan_Details_Rec.exchange_rate;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'exchange_rate = ' || l_loan_rec.exchange_rate);

    l_loan_rec.FORGIVENESS_FLAG := P_Loan_Details_Rec.FORGIVENESS_FLAG;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_FLAG = ' || l_loan_rec.FORGIVENESS_FLAG);

    l_loan_rec.FORGIVENESS_PERCENT := P_Loan_Details_Rec.FORGIVENESS_PERCENT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'FORGIVENESS_PERCENT = ' || l_loan_rec.FORGIVENESS_PERCENT);

    l_loan_rec.multiple_funding_flag := nvl(l_product_rec.multiple_funding_flag, 'N');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'multiple_funding_flag = ' || l_loan_rec.multiple_funding_flag);

    l_loan_rec.open_loan_start_date := P_Loan_Details_Rec.open_loan_start_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_start_date = ' || l_loan_rec.open_loan_start_date);

    l_loan_rec.open_loan_term := P_Loan_Details_Rec.open_loan_term;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_term = ' || l_loan_rec.open_loan_term);

    l_loan_rec.open_loan_term_period := P_Loan_Details_Rec.open_loan_term_period;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_loan_term_period = ' || l_loan_rec.open_loan_term_period);

    l_loan_rec.open_maturity_date :=  P_Loan_Details_Rec.open_maturity_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_maturity_date = ' || l_loan_rec.open_maturity_date);

    l_loan_rec.open_to_term_flag := nvl(l_product_rec.open_to_term_flag, 'N');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_to_term_flag = ' || l_loan_rec.open_to_term_flag);

    l_loan_rec.open_to_term_event := P_Loan_Details_Rec.open_to_term_event;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_to_term_event = ' || l_loan_rec.open_to_term_event);

    l_loan_rec.created_by_module := P_created_by_module;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'created_by_module = ' || l_loan_rec.created_by_module);

    l_loan_rec.application_id  := P_application_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'application_id = ' || l_loan_rec.application_id);

    l_loan_rec.attribute_category := P_Loan_Details_Rec.attribute_category;
    l_loan_rec.attribute1 := P_Loan_Details_Rec.attribute1;
    l_loan_rec.attribute2 := P_Loan_Details_Rec.attribute2;
    l_loan_rec.attribute3 := P_Loan_Details_Rec.attribute3;
    l_loan_rec.attribute4 := P_Loan_Details_Rec.attribute4;
    l_loan_rec.attribute5 := P_Loan_Details_Rec.attribute5;
    l_loan_rec.attribute6 := P_Loan_Details_Rec.attribute6;
    l_loan_rec.attribute7 := P_Loan_Details_Rec.attribute7;
    l_loan_rec.attribute8 := P_Loan_Details_Rec.attribute8;
    l_loan_rec.attribute9 := P_Loan_Details_Rec.attribute9;
    l_loan_rec.attribute10 := P_Loan_Details_Rec.attribute10;
    l_loan_rec.attribute11 := P_Loan_Details_Rec.attribute11;
    l_loan_rec.attribute12 := P_Loan_Details_Rec.attribute12;
    l_loan_rec.attribute13 := P_Loan_Details_Rec.attribute13;
    l_loan_rec.attribute14 := P_Loan_Details_Rec.attribute14;
    l_loan_rec.attribute15 := P_Loan_Details_Rec.attribute15;
    l_loan_rec.attribute16 := P_Loan_Details_Rec.attribute16;
    l_loan_rec.attribute17 := P_Loan_Details_Rec.attribute17;
    l_loan_rec.attribute18 := P_Loan_Details_Rec.attribute18;
    l_loan_rec.attribute19 := P_Loan_Details_Rec.attribute19;
    l_loan_rec.attribute20 := P_Loan_Details_Rec.attribute20;


    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Setting l_term_rec record...');

    -- term record
    l_term_rec.loan_id := l_loan_rec.loan_id;

    select LNS_TERMS_S.nextval
    into   l_term_rec.term_id
    from dual;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'term_id = ' || l_term_rec.term_id);

    l_term_rec.rate_type := P_Loan_Details_Rec.RATE_TYPE;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'rate_type = ' || l_term_rec.rate_type);

    l_term_rec.index_rate_id := P_Loan_Details_Rec.index_rate_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'index_rate_id = ' || l_term_rec.index_rate_id);

    l_term_rec.calculation_method := P_Loan_Details_Rec.CALCULATION_METHOD;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'calculation_method = ' || l_term_rec.calculation_method);

    l_term_rec.day_count_method := P_Loan_Details_Rec.day_count_method;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'day_count_method = ' || l_term_rec.day_count_method);

    l_term_rec.loan_payment_frequency := P_Loan_Details_Rec.loan_payment_frequency;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'loan_payment_frequency = ' || l_term_rec.loan_payment_frequency);

    l_term_rec.PAYMENT_CALC_METHOD := P_Loan_Details_Rec.PAYMENT_CALC_METHOD;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PAYMENT_CALC_METHOD = ' || l_term_rec.PAYMENT_CALC_METHOD);

    l_term_rec.amortization_frequency := l_term_rec.loan_payment_frequency;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'amortization_frequency = ' || l_term_rec.amortization_frequency);

    l_term_rec.interest_compounding_freq := P_Loan_Details_Rec.INTEREST_COMPOUNDING_FREQ;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'interest_compounding_freq = ' || l_term_rec.interest_compounding_freq);

    l_term_rec.first_payment_date := P_Loan_Details_Rec.first_payment_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'first_payment_date = ' || l_term_rec.first_payment_date);

    l_term_rec.PRIN_FIRST_PAY_DATE := P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIN_FIRST_PAY_DATE = ' || l_term_rec.PRIN_FIRST_PAY_DATE);

    l_term_rec.PRIN_PAYMENT_FREQUENCY := P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'PRIN_PAYMENT_FREQUENCY = ' || l_term_rec.PRIN_PAYMENT_FREQUENCY);

    l_term_rec.floor_rate := P_Loan_Details_Rec.floor_rate;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'floor_rate = ' || l_term_rec.floor_rate);

    l_term_rec.ceiling_rate := P_Loan_Details_Rec.ceiling_rate;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'ceiling_rate = ' || l_term_rec.ceiling_rate);

    l_term_rec.percent_increase := P_Loan_Details_Rec.percent_increase;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'percent_increase = ' || l_term_rec.percent_increase);

    l_term_rec.percent_increase_life := P_Loan_Details_Rec.percent_increase_life;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'percent_increase_life = ' || l_term_rec.percent_increase_life);

    l_term_rec.open_first_payment_date := P_Loan_Details_Rec.open_first_payment_date;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_first_payment_date = ' || l_term_rec.open_first_payment_date);

    l_term_rec.open_payment_frequency := P_Loan_Details_Rec.open_payment_frequency;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_payment_frequency = ' || l_term_rec.open_payment_frequency);

    l_term_rec.open_floor_rate := P_Loan_Details_Rec.open_floor_rate;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_floor_rate = ' || l_term_rec.open_floor_rate);

    l_term_rec.open_ceiling_rate := P_Loan_Details_Rec.open_ceiling_rate;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_ceiling_rate = ' || l_term_rec.open_ceiling_rate);

    l_term_rec.open_percent_increase := P_Loan_Details_Rec.open_percent_increase;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_percent_increase = ' || l_term_rec.open_percent_increase);

    l_term_rec.open_percent_increase_life := P_Loan_Details_Rec.open_percent_increase_life;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'open_percent_increase_life = ' || l_term_rec.open_percent_increase_life);

    l_term_rec.based_on_balance := 'PRIN';

    l_term_rec.reamortize_over_payment := P_Loan_Details_Rec.reamortize_over_payment;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'reamortize_over_payment = ' || l_term_rec.reamortize_over_payment);

    l_term_rec.reamortize_under_payment := l_product_rec.reamortize_under_payment;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'reamortize_under_payment = ' || l_term_rec.reamortize_under_payment);

    l_term_rec.DELINQUENCY_THRESHOLD_AMOUNT := P_Loan_Details_Rec.DELINQUENCY_THRESHOLD_AMOUNT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'DELINQUENCY_THRESHOLD_AMOUNT = ' || l_term_rec.DELINQUENCY_THRESHOLD_AMOUNT);

    l_term_rec.payment_application_order := nvl(P_Loan_Details_Rec.payment_application_order, l_product_rec.payment_application_order);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'payment_application_order = ' || l_term_rec.payment_application_order);

    l_term_rec.pmt_appl_order_scope := nvl(P_Loan_Details_Rec.pmt_appl_order_scope, l_product_rec.pmt_appl_order_scope);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'pmt_appl_order_scope = ' || l_term_rec.pmt_appl_order_scope);

    l_term_rec.LOCK_IN_DATE := P_Loan_Details_Rec.LOCK_DATE;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOCK_IN_DATE = ' || l_term_rec.LOCK_IN_DATE);

    l_term_rec.LOCK_TO_DATE := P_Loan_Details_Rec.LOCK_EXP_DATE;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'LOCK_TO_DATE = ' || l_term_rec.LOCK_TO_DATE);

    if l_product_rec.multiple_funding_flag = 'Y' then

        if trunc(P_Loan_Details_Rec.open_first_payment_date) <> trunc(P_Loan_Details_Rec.open_loan_start_date) then
            l_pay_in_arrears_bool := true;
        else
            l_pay_in_arrears_bool := false;
        end if;

        l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                p_loan_start_date     => P_Loan_Details_Rec.open_loan_start_date
                                ,p_loan_maturity_date => P_Loan_Details_Rec.open_maturity_date
                                ,p_first_pay_date     => P_Loan_Details_Rec.open_first_payment_date
                                ,p_num_intervals      => null
                                ,p_interval_type      => P_Loan_Details_Rec.loan_payment_frequency
                                ,p_pay_in_arrears     => l_pay_in_arrears_bool);

        l_end_installment_number := l_payment_tbl.count;
        logmessage(fnd_log.level_statement, 'Open l_end_installment_number = ' || l_end_installment_number);

        logmessage(fnd_log.level_statement, 'Synchronizing Open Rate Schedule...');
        synchRateSchedule(p_open_rates_tbl, l_end_installment_number);

    end if;

    IF P_Loan_Details_Rec.custom_payments_flag = 'Y' AND p_loan_cust_sched_tbl.COUNT > 0 THEN
        l_end_installment_number := p_loan_cust_sched_tbl.COUNT;
    ELSE
        IF P_Loan_Details_Rec.PAYMENT_CALC_METHOD = 'SEPARATE_SCHEDULES' THEN

            if trunc(P_Loan_Details_Rec.first_payment_date) <> trunc(P_Loan_Details_Rec.loan_start_date) then
                l_pay_in_arrears_bool := true;
            else
                l_pay_in_arrears_bool := false;
            end if;

            if trunc(P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE) <> trunc(P_Loan_Details_Rec.loan_start_date) then
                l_prin_pay_in_arrears_bool := true;
            else
                l_prin_pay_in_arrears_bool := false;
            end if;

            l_payment_tbl := LNS_FIN_UTILS.buildSIPPaymentSchedule(
                                    p_loan_start_date      => P_Loan_Details_Rec.loan_start_date
                                    ,p_loan_maturity_date  => P_Loan_Details_Rec.maturity_date
                                    ,p_int_first_pay_date  => P_Loan_Details_Rec.first_payment_date
                                    ,p_int_num_intervals   => null
                                    ,p_int_interval_type   => P_Loan_Details_Rec.loan_payment_frequency
                                    ,p_int_pay_in_arrears  => l_pay_in_arrears_bool
                                    ,p_prin_first_pay_date => P_Loan_Details_Rec.PRIN_FIRST_PAY_DATE
                                    ,p_prin_num_intervals  => null
                                    ,p_prin_interval_type  => P_Loan_Details_Rec.PRIN_PAYMENT_FREQUENCY
                                    ,p_prin_pay_in_arrears => l_prin_pay_in_arrears_bool);

            l_end_installment_number := l_payment_tbl.count;

        ELSE

            if trunc(P_Loan_Details_Rec.first_payment_date) <> trunc(P_Loan_Details_Rec.loan_start_date) then
                l_pay_in_arrears_bool := true;
            else
                l_pay_in_arrears_bool := false;
            end if;

            l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(
                                    p_loan_start_date     => P_Loan_Details_Rec.loan_start_date
                                    ,p_loan_maturity_date => P_Loan_Details_Rec.maturity_date
                                    ,p_first_pay_date     => P_Loan_Details_Rec.first_payment_date
                                    ,p_num_intervals      => null
                                    ,p_interval_type      => P_Loan_Details_Rec.loan_payment_frequency
                                    ,p_pay_in_arrears     => l_pay_in_arrears_bool);

            l_end_installment_number := l_payment_tbl.count;

        END IF;
    END IF;

    logmessage(fnd_log.level_statement, 'Term l_end_installment_number = ' || l_end_installment_number);
    logmessage(fnd_log.level_statement, 'Synchronizing Term Rate Schedule...');
    synchRateSchedule(p_term_rates_tbl, l_end_installment_number);

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    -- 1) Insert Loan Header
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_LOAN_HEADER_PUB.create_loan...');
    LNS_LOAN_HEADER_PUB.create_loan (
            p_init_msg_list   => 'T'
            ,p_loan_header_rec => l_loan_rec
            ,x_loan_id         => l_loan_id
            ,x_loan_number     => l_loan_number
            ,x_return_status   => l_header_insert_success
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data
    );
    IF l_header_insert_success <> 'S' THEN
        LogErrors(p_message_name=>'LNS_LCREATE_INS_ERR_HEADER'
                ,p_token1 => l_msg_data);
    END IF;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.level_unexpected,   'Loan object created successfully');
    logmessage(fnd_log.level_unexpected,   'New loan_id: ' || l_loan_id);

    -- 2) Create participant records
    FOR l_count IN 1 .. p_loan_part_tbl.COUNT
    LOOP
        l_participant_rec.loan_id := l_loan_rec.loan_id;
        l_participant_rec.hz_party_id := p_loan_part_tbl(l_count).hz_party_id;
        l_participant_rec.loan_participant_type := p_loan_part_tbl(l_count).loan_participant_type;
        l_participant_rec.start_date_active := p_loan_part_tbl(l_count).start_date_active;
        l_participant_rec.end_date_active := p_loan_part_tbl(l_count).end_date_active;
        l_participant_rec.cust_account_id := p_loan_part_tbl(l_count).cust_account_id;
        l_participant_rec.bill_to_acct_site_id := p_loan_part_tbl(l_count).bill_to_acct_site_id;
        l_participant_rec.contact_rel_party_id := p_loan_part_tbl(l_count).contact_rel_party_id;
        l_participant_rec.contact_pers_party_id := p_loan_part_tbl(l_count).contact_pers_party_id;

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_PARTICIPANTS_PUB.createParticipant...');
        LNS_PARTICIPANTS_PUB.createParticipant (
                p_init_msg_list        => 'T'
                ,p_validation_level     => FND_API.G_VALID_LEVEL_NONE
                ,p_loan_participant_rec => l_participant_rec
                ,x_participant_id       => l_participant_id
                ,x_return_status        => l_part_insert_success
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data
        );
        IF l_part_insert_success <> 'S' THEN
                LogErrors(p_message_name=>'LNS_LCREATE_INS_ERR_PART'
                    ,p_token1      =>l_msg_data);
        ELSE
            logmessage(fnd_log.level_statement,   'Participant object created successfully');
            logmessage(fnd_log.level_statement,   'New participant_id: ' || l_participant_id);
        END IF;
    END LOOP;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.level_unexpected,   'All participant objects created successfully');

    -- 3) Create loan lines records
    IF l_product_rec.loan_class_code = 'ERS' THEN

        l_ers_requested_amount := 0;
        IF P_Loan_Lines_Tbl.COUNT <> 0 THEN
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Inserting records into LNS_LOAN_LINES...');

            FOR l_count IN 1 .. p_loan_lines_tbl.COUNT LOOP

                INSERT INTO LNS_LOAN_LINES
                (
                    LOAN_LINE_ID
                    ,LOAN_ID
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,OBJECT_VERSION_NUMBER
                    ,REFERENCE_TYPE
                    ,REFERENCE_ID
                    ,REFERENCE_NUMBER
                    ,REFERENCE_DESCRIPTION
                    ,REFERENCE_AMOUNT
                    ,REQUESTED_AMOUNT
                    ,PAYMENT_SCHEDULE_ID
                    ,INSTALLMENT_NUMBER
                    )
                VALUES
                (
                    LNS_LOAN_LINE_S.nextval
                    ,l_loan_rec.loan_id
                    ,sysdate
                    ,lns_utility_pub.created_by
                    ,sysdate
                    ,lns_utility_pub.created_by
                    ,1
                    ,'RECEIVABLE'
                    ,p_loan_lines_tbl(l_count).customer_trx_id --v_customer_trx_id(i)
                    ,p_loan_lines_tbl(l_count).REFERENCE_NUMBER  --v_reference_number(i)
                    ,p_loan_lines_tbl(l_count).REFERENCE_DESCRIPTION  --v_DESCRIPTION(i)
                    ,p_loan_lines_tbl(l_count).remaining_balance  --v_remaining_balance(i)
                    ,p_loan_lines_tbl(l_count).requested_amount  --v_requested_amount(i)
                    ,p_loan_lines_tbl(l_count).payment_schedule_id  --v_PAYMENT_SCHEDULE_ID(i)
                    ,p_loan_lines_tbl(l_count).installment_number  --v_installment_number(i)
                );

                l_ers_requested_amount := l_ers_requested_amount + p_loan_lines_tbl(l_count).requested_amount;

            END LOOP;
            logmessage(fnd_log.LEVEL_UNEXPECTED,   'All loan lines created successfully');

        ELSIF P_Loan_Lines_Tbl.COUNT = 0 THEN
            l_ers_requested_amount :=  LNS_LOAN_LINE_PUB.GET_RULES_DERIVED_ERS_AMOUNT(
                    p_loan_id                => l_loan_rec.loan_id
                    ,p_primary_borrower_id    => l_loan_rec.primary_borrower_id
                    ,p_currency_code          => l_loan_rec.loan_currency
                    ,p_org_id         	      => l_loan_rec.org_id
                    ,p_loan_product_id	      => P_Loan_Details_Rec.product_id
            );
            logmessage(fnd_log.LEVEL_UNEXPECTED,   'All loan lines inherited successfully');
        END IF;

        IF l_ers_requested_amount = 0 THEN
            LogErrors(p_message_name=>'LNS_LCREATE_ERR_LINE_DERIVE');
        ELSE
            LogMessage(FND_LOG.LEVEL_STATEMENT, 'Updating lns_loan_headers_all with requested_amount = ' || l_ers_requested_amount);
            UPDATE lns_loan_headers_all
            SET requested_amount = l_ers_requested_amount
                ,object_version_number = 2
            WHERE  loan_id = l_loan_rec.loan_id;
        END IF;

    END IF;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    -- 4) Create Term Record
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_TERMS_PUB.create_term...');
    LNS_TERMS_PUB.create_term (
            p_init_msg_list        => 'T'
            ,p_loan_term_rec        => l_term_rec
            ,x_term_id              => l_term_id
            ,x_return_status        => l_term_insert_success
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data
    );
    IF l_term_insert_success <> 'S' THEN
            LogErrors(p_message_name=>'LNS_LCREATE_INS_ERR_TERM'
                ,p_token1      =>l_msg_data);
    END IF;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.LEVEL_UNEXPECTED,   'Loan term object created successfully');

    -- 5) Create Term Rate Schedule Records
    FOR l_count IN 1 .. P_TERM_RATES_TBL.COUNT
    LOOP
        BEGIN
            insert into LNS_RATE_SCHEDULES
                (RATE_ID
                ,TERM_ID
                ,INDEX_RATE
                ,SPREAD
                ,CURRENT_INTEREST_RATE
                ,START_DATE_ACTIVE
                ,END_DATE_ACTIVE
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
                ,OBJECT_VERSION_NUMBER
                ,INDEX_DATE
                ,BEGIN_INSTALLMENT_NUMBER
                ,END_INSTALLMENT_NUMBER
                ,INTEREST_ONLY_FLAG
                ,PHASE
                ,FLOATING_FLAG)
            VALUES
                (LNS_RATE_SCHEDULES_S.nextval
                ,l_term_rec.term_id
                ,P_TERM_RATES_TBL(l_Count).INDEX_RATE
                ,nvl(P_TERM_RATES_TBL(l_Count).SPREAD, 0)
                ,(P_TERM_RATES_TBL(l_Count).INDEX_RATE + nvl(P_TERM_RATES_TBL(l_Count).SPREAD, 0))
                ,sysdate
                ,null
                ,lns_utility_pub.created_by
                ,sysdate
                ,lns_utility_pub.last_updated_by
                ,sysdate
                ,lns_utility_pub.LAST_UPDATE_LOGIN
                ,1
                ,P_TERM_RATES_TBL(l_Count).INDEX_DATE
                ,P_TERM_RATES_TBL(l_Count).BEGIN_INSTALLMENT_NUMBER
                ,P_TERM_RATES_TBL(l_Count).END_INSTALLMENT_NUMBER
                ,P_TERM_RATES_TBL(l_Count).INTEREST_ONLY_FLAG
                ,'TERM'
                ,null);
        EXCEPTION
            WHEN OTHERS THEN
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
                LogErrors(p_message_name=>'LNS_LCREATE_INS_ERR_TERMRATE'
                            ,p_token1      => sqlerrm);
        END;
    END LOOP;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.LEVEL_UNEXPECTED,   'Term rate schedule created successfully');

    -- 6) Create Open Rate Schedule Records
    IF l_product_rec.multiple_funding_flag = 'Y' THEN
        FOR l_count IN 1 .. P_OPEN_RATES_TBL.COUNT
        LOOP
            BEGIN
                insert into LNS_RATE_SCHEDULES
                    (RATE_ID
                    ,TERM_ID
                    ,INDEX_RATE
                    ,SPREAD
                    ,CURRENT_INTEREST_RATE
                    ,START_DATE_ACTIVE
                    ,END_DATE_ACTIVE
                    ,CREATED_BY
                    ,CREATION_DATE
                    ,LAST_UPDATED_BY
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATE_LOGIN
                    ,OBJECT_VERSION_NUMBER
                    ,INDEX_DATE
                    ,BEGIN_INSTALLMENT_NUMBER
                    ,END_INSTALLMENT_NUMBER
                    ,INTEREST_ONLY_FLAG
                    ,PHASE
                    ,FLOATING_FLAG)
                VALUES
                    (LNS_RATE_SCHEDULES_S.nextval
                    ,l_term_rec.term_id
                    ,P_OPEN_RATES_TBL(l_Count).INDEX_RATE
                    ,nvl(P_OPEN_RATES_TBL(l_Count).SPREAD, 0)
                    ,(P_OPEN_RATES_TBL(l_Count).INDEX_RATE + nvl(P_OPEN_RATES_TBL(l_Count).SPREAD, 0))
                    ,sysdate
                    ,null
                    ,lns_utility_pub.created_by
                    ,sysdate
                    ,lns_utility_pub.last_updated_by
                    ,sysdate
                    ,lns_utility_pub.LAST_UPDATE_LOGIN
                    ,1
                    ,P_OPEN_RATES_TBL(l_Count).INDEX_DATE
                    ,P_OPEN_RATES_TBL(l_Count).BEGIN_INSTALLMENT_NUMBER
                    ,P_OPEN_RATES_TBL(l_Count).END_INSTALLMENT_NUMBER
                    ,P_OPEN_RATES_TBL(l_Count).INTEREST_ONLY_FLAG
                    ,'OPEN'
                    ,null);
            EXCEPTION
                WHEN OTHERS THEN
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
                    LogErrors(p_message_name=>'LNS_LCREATE_INS_ERR_TERMRATE'
                                ,p_token1      => sqlerrm);
            END;
        END LOOP;

        IF g_error_count > 0 THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        logmessage(fnd_log.LEVEL_UNEXPECTED,   'Open rate schedule created successfully');

    END IF;

    -- 7). Creating custom schedule if it exists

    IF P_Loan_Details_Rec.custom_payments_flag = 'Y' AND p_loan_cust_sched_tbl.COUNT > 0 THEN

        logmessage(fnd_log.level_statement,   'Creating custom schedule...');

        /* Looping thru custom schedule and build table */
        FOR l_count IN 1 .. p_loan_cust_sched_tbl.COUNT
        LOOP

            l_custom_tbl(l_count).loan_id := l_loan_id;
            l_custom_tbl(l_count).payment_number := p_loan_cust_sched_tbl(l_count).payment_number;
            l_custom_tbl(l_count).due_date := p_loan_cust_sched_tbl(l_count).due_date;
            l_custom_tbl(l_count).principal_amount := p_loan_cust_sched_tbl(l_count).principal_amount;
            l_custom_tbl(l_count).interest_amount := p_loan_cust_sched_tbl(l_count).interest_amount;
            l_custom_tbl(l_count).LOCK_PRIN := p_loan_cust_sched_tbl(l_count).LOCK_PRIN;
            l_custom_tbl(l_count).LOCK_INT := p_loan_cust_sched_tbl(l_count).LOCK_INT;
            l_custom_tbl(l_count).ACTION := 'I';

        END LOOP;

        -- added for bug 6961781
        LNS_CUSTOM_PUB.saveCustomSchedule(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT		        => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID               => l_loan_id,
            P_BASED_ON_TERMS        => 'ORIGINAL',
            P_AMORT_METHOD          => l_term_rec.CUSTOM_CALC_METHOD,
            P_CUSTOM_TBL            => l_custom_tbl,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        logmessage(fnd_log.LEVEL_UNEXPECTED,   'Custom schedule created successfully');

    END IF;

    -- 8) Update rate schedule if rate type is floating
    if P_Loan_Details_Rec.RATE_TYPE = 'FLOATING' and P_Created_by_module <> 'LNS_IMPORT_LOAN_PUB.IMPORT_LOAN' then

        logmessage(fnd_log.level_statement,   'Updating floating rate schedule...');
        LNS_INDEX_RATES_PUB.UPDATE_LOAN_FLOATING_RATE(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_TRUE,
            P_COMMIT		        => FND_API.G_FALSE,
            P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
            P_LOAN_ID               => l_loan_rec.loan_id,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data);

        IF l_return_status <> 'S' THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        logmessage(fnd_log.LEVEL_UNEXPECTED,   'Floating rate schedule updated successfully');

    end if;

    -- 9) Set default delinquency amount
    IF P_Loan_Details_Rec.delinquency_threshold_amount IS NULL THEN

        l_object_version_number := 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_TERMS_PUB.default_delinquency_amount...');
        LNS_TERMS_PUB.default_delinquency_amount (
                p_term_id              => l_term_id
                ,p_loan_id              => l_loan_rec.loan_id
                ,p_object_version_number=> l_object_version_number
                ,x_return_status        => l_term_update_success
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data
        );
        IF l_term_update_success <> 'S' THEN
            LogErrors(p_message_name=>'LNS_LCREATE_UPD_ERR_TERM'
                    ,p_token1      =>l_msg_data);
        END IF;

        logmessage(fnd_log.LEVEL_UNEXPECTED,   'Default delinquency amount updated successfully');

    END IF;

    IF g_error_count > 0 THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    -- 10) Default fees from the product
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling create_FEE_ASSIGNMENT...');
    create_FEE_ASSIGNMENT(P_LOAN_ID             => l_loan_rec.loan_id
                        ,x_return_status        => l_return_status
                        ,x_msg_count            => l_msg_count
                        ,x_msg_data             => l_msg_data);
    IF l_return_status <> 'S' THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    logmessage(fnd_log.LEVEL_UNEXPECTED,   'Default fees created successfully');

    IF p_commit = fnd_api.g_true THEN
        COMMIT WORK;
        logmessage(fnd_log.level_statement,   'Commited');
    END IF;

    X_RETURN_STATUS := 'S';
    X_MSG_COUNT := 0;
    X_LOAN_ID := l_loan_id;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'New loan_id = ' || X_LOAN_ID);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

    EXCEPTION
        WHEN product_not_found  THEN
            ROLLBACK TO CREATE_LOAN;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
            X_RETURN_STATUS := 'E';
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN error_while_insert  THEN
            ROLLBACK TO CREATE_LOAN;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
            X_RETURN_STATUS := 'E';
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS THEN
            ROLLBACK TO CREATE_LOAN;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
            X_RETURN_STATUS := 'E';
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END CREATE_LOAN;



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
END LNS_LOAN_PUB;

/
