--------------------------------------------------------
--  DDL for Package LNS_IMPORT_LOAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_IMPORT_LOAN_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_IMPORT_LOAN_S.pls 120.0.12010000.2 2009/05/22 14:28:14 scherkas noship $ */
/*#
 * Start of Comments
 * Package name     : LNS_IMPORT_LOAN_PUB
 * Purpose          Import a loan
 * History          :
*/
-- * @rep:scope public
-- * @rep:product LNS
-- * @rep:displayname Import Loan
-- * @rep:lifecycle active
-- * @rep:compatibility S
-- * @rep:category BUSINESS_ENTITY LOAN

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

    -- Loan header record
    TYPE Loan_Details_Rec_Type IS RECORD (

        -- common attributes
        product_id                  NUMBER(15)  -- FK to lns_loan_products.product_id; mandatory
        ,loan_number                VARCHAR2(20) -- if profile LNS_GENERATE_LOAN_NUMBER = 'Y'- will be set by api; otherwise mandatory
        ,loan_description           VARCHAR2(250) -- Free Form Text; optional
        ,loan_assigned_to           NUMBER(15) -- FK to jtf_rs_resource_extns.resource_id; mandatory
        ,legal_entity_id            NUMBER(15) -- FK to xle_entity_profiles.legal_entity_id; mandatory if product's legal_entity_id is null
--        ,requested_amount           NUMBER -- Loan requested amount; mandatory for direct loans
        ,loan_application_date      DATE -- Loan application date; optional; if null will be defaulted to loan_start_date
        ,exchange_rate_type         VARCHAR2(30) -- FK to gl_daily_conversion_types; mandatory if product's currency is different from functional currency
        ,exchange_rate              NUMBER -- exchange_rate for USER exchange_rate_type
        ,exchange_date              DATE -- exchange_date; mandatory if exchange_rate_type is not null
        ,loan_purpose_code          VARCHAR2(30) -- FK to lns_lookups.lookup_code; lookup_type = 'LOAN_PURPOSE'; mandatory
        ,loan_subtype               VARCHAR2(30) -- FK to lns_lookups.lookup_code; lookup_type = 'LOAN_SUBTYPE'; mandatory
        ,credit_review_flag         VARCHAR2(1) -- 'Y' or 'N' or null; optional
        ,trx_type_id                NUMBER(15) -- principal trx type; FK to ar_lookups.lookup_code; lookup_type = 'INV/CM'; mandatory
        ,collateral_percent         NUMBER -- collateral_percent; optional
        ,CUSTOM_PAYMENTS_FLAG       VARCHAR2(1) -- valid values: null or N or Y; optional
        ,FORGIVENESS_FLAG           VARCHAR2(1) -- enable forgiveness: valid values: Y and N; optional; if null will be defaulted from product_id
        ,FORGIVENESS_PERCENT        NUMBER  -- forgiveness percent; valid values from 0 to 100; optional; if null will be defaulted from product_id
        ,loan_approval_date         DATE  -- loan approval date; mandatory
        ,loan_approved_by           NUMBER  -- loan approval by; mandatory
        ,LEGACY_REFERENCE           VARCHAR2(20)  -- legacy reference; mandatory

        -- do not pass these parameters; will be returned by api
        ,org_id                     NUMBER  -- do not pass; will be returned by api
        ,loan_type_id               NUMBER -- do not pass; will be returned by api
        ,loan_class_code            VARCHAR2(30) -- do not pass; will be returned by api
        ,loan_currency              VARCHAR2(15) -- do not pass; will be returned by api
        ,maturity_date              DATE  -- do not pass; will be returned by api
        ,NEXT_PAYMENT_DUE_DATE      DATE  -- do not pass; will be returned by api

        -- primary borrower attributes
        ,primary_borrower_party_id  NUMBER(15) -- FK to hz_parties.party_id; Note: Status should be 'A'; mandatory
        ,cust_account_id            NUMBER(15) -- FK to hz_cust_accounts_all.cust_account_id; Note: Status should be 'A'; mandatory
        ,bill_to_acct_site_id       NUMBER(15) -- FK to hz_cust_acct_sites_all; mandatory
        ,contact_rel_party_id       NUMBER(15) -- FK to hz_relationships.party_id; optional
        ,CONTACT_PERS_PARTY_ID      NUMBER(15) -- FK to hz_parties.party_id; Note: Status should be 'A'; optional

        -- common term attributes
        ,RATE_TYPE                  VARCHAR2(30)  -- FK to lns_lookups.lookup_code; lookup_type = 'RATE_TYPE'; optional; if null will be defaulted from product_id
        ,INDEX_RATE_ID              NUMBER -- FK to lns_int_rate_headers.interest_rate_id; optional; if null will be defaulted from product_id
        ,DAY_COUNT_METHOD           VARCHAR2(50) -- days count method; FK to lns_lookups.lookup_code; lookup_type = 'DAY_COUNT_METHOD'; optional; if null will be defaulted from product_id
        ,LOAN_PAYMENT_FREQUENCY     VARCHAR2(30) -- loan/interest payment frequency; FK to lns_lookups.lookup_code; lookup_type = 'FREQUENCY'; optional; if null will be defaulted from product_id
        ,CALCULATION_METHOD         VARCHAR2(30)  -- interest calculation method: SIMPLE or COMPOUND; optional; if null will be defaulted from product_id
        ,INTEREST_COMPOUNDING_FREQ  VARCHAR2(30)  -- FK to lns_lookups.lookup_code; lookup_type = 'INTEREST_COMPOUNDING_FREQ'; optional; if null will be defaulted from product_id
        ,PAYMENT_CALC_METHOD        VARCHAR2(30)  -- FK to lns_lookups.lookup_code; lookup_type = 'PAYMENT_CALCULATION_METHOD'; optional; if null will be defaulted to EQUAL_PAYMENT
        ,CUSTOM_CALC_METHOD         VARCHAR2(30)  -- FK to lns_lookups.lookup_code; lookup_type = CUSTOM_CALCULATION_METHOD; mandatory if CUSTOM_PAYMENTS_FLAG = Y
        ,ORIG_PAY_CALC_METHOD       VARCHAR2(30)  -- FK to lns_lookups.lookup_code; lookup_type = PAYMENT_CALCULATION_METHOD; optional
        ,PENAL_INT_RATE             NUMBER -- penal interest rate; if null will be defaulted to 0
        ,PENAL_INT_GRACE_DAYS       NUMBER -- penal interest grace days; if null will be defaulted to 0
        ,LOCK_DATE                  DATE  -- rate lock date; optional; optional
        ,LOCK_EXP_DATE              DATE  -- rate lock experation date; optional

        -- 'term phase' term attributes
        ,loan_term                  NUMBER -- term phase term; optional; if null will be defaulted from product_id
        ,loan_term_period           VARCHAR2(30) -- FK to lns_lookups.lookup_code; lookup_type = 'PERIOD'; optional; if null will be defaulted from product_id
        ,balloon_payment_type       VARCHAR2(30) -- FK to lns_lookups.lookup_code; lookup_type = 'BALLOON_PAYMENT_TYPE'; optional; if null will be defaulted to TERM
        ,balloon_payment_amount     NUMBER -- balloon amount for term phase; mandatory if balloon_payment_type = 'AMOUNT'; if null will be defaulted to 0
        ,balloon_term               NUMBER -- balloon term for term phase; mandatory if balloon_payment_type = 'TERM'; if null will be defaulted to loan_term
        ,loan_start_date            DATE -- term phase start date; mandatory; if null will be defaulted to sysdate
        ,FIRST_PAYMENT_DATE         DATE -- term phase loan/interest first payment date; mandatory; if null will be defaulted to loan_start_date+1 payment_period
        ,PRIN_FIRST_PAY_DATE        DATE    -- term phase principal first payment date; used with PAYMENT_CALC_METHOD = SEPARATE_SCHEDULES; if null will be defaulted to FIRST_PAYMENT_DATE
        ,PRIN_PAYMENT_FREQUENCY     VARCHAR2(30)  -- term phase principal payment freq; used with PAYMENT_CALC_METHOD = SEPARATE_SCHEDULES; if null will be defaulted to LOAN_PAYMENT_FREQUENCY
        ,floor_rate                 NUMBER  -- term phase floor rate; optional; only applies when RATE_TYPE = FLOATING
        ,ceiling_rate               NUMBER  -- term phase ceiling rate; optional; only applies when RATE_TYPE = FLOATING
        ,percent_increase           NUMBER  -- term phase max sequential rate percent increase; optional; only applies when RATE_TYPE = FLOATING
        ,percent_increase_life      NUMBER  -- term phase max rate percent increase for life of the loan; optional; only applies when RATE_TYPE = FLOATING

        -- Terms for Payment attributes
        ,REAMORTIZE_OVER_PAYMENT    VARCHAR2(1)  -- reamortize overpayment flag; optional; valid values: Y or N or null;
        ,DELINQUENCY_THRESHOLD_AMOUNT NUMBER  -- delinquency amount; optional; if null will be defaulted by api;
        ,PAYMENT_APPLICATION_ORDER  VARCHAR2(30) -- payment application order; optional; if null will be defaulted from loan_type_id
        ,PMT_APPL_ORDER_SCOPE       VARCHAR2(30) -- payment application scope; optional; if null will be defaulted from loan_type_id

        -- additional optional attributes
        ,ATTRIBUTE_CATEGORY         VARCHAR2(30)    -- optional
        ,ATTRIBUTE1                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE2                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE3                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE4                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE5                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE6                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE7                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE8                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE9                 VARCHAR2(150)    -- optional
        ,ATTRIBUTE10                VARCHAR2(150)    -- optional
        ,ATTRIBUTE11                VARCHAR2(150)    -- optional
        ,ATTRIBUTE12                VARCHAR2(150)    -- optional
        ,ATTRIBUTE13                VARCHAR2(150)    -- optional
        ,ATTRIBUTE14                VARCHAR2(150)    -- optional
        ,ATTRIBUTE15                VARCHAR2(150)    -- optional
        ,ATTRIBUTE16                VARCHAR2(150)    -- optional
        ,ATTRIBUTE17                VARCHAR2(150)    -- optional
        ,ATTRIBUTE18                VARCHAR2(150)    -- optional
        ,ATTRIBUTE19                VARCHAR2(150)    -- optional
        ,ATTRIBUTE20                VARCHAR2(150)    -- optional
        );
    -- loan lines
    TYPE Loan_Lines_Rec_Type IS RECORD (
        REFERENCE_NUMBER VARCHAR2(60) -- reference number; mandatory
        ,REFERENCE_DESCRIPTION  VARCHAR2(250) -- Free form Text; optional
        ,AMOUNT NUMBER -- line amount; mandatory
    );
    TYPE Loan_Lines_Tbl_Type IS TABLE OF Loan_Lines_Rec_Type INDEX BY BINARY_INTEGER;

      -- loan participants
    TYPE LOAN_PART_REC_TYPE IS RECORD (
        HZ_PARTY_ID NUMBER(15)  -- FK to hz_parties.party_id; Note: Status should be 'A'; mandatory
        ,LOAN_PARTICIPANT_TYPE VARCHAR2(30)  -- FK to lns_lookups.lookup_code; lookup_type = 'LNS_PARTICIPANT_TYPE' and lookup_code <> 'PRIMARY_BORROWER'; mandatory
        ,START_DATE_ACTIVE DATE  -- optional
        ,END_DATE_ACTIVE DATE -- optional
        ,CUST_ACCOUNT_ID NUMBER(15) -- FK to hz_cust_accounts_all.cust_account_id; Note: Status should be 'A'; mandatory
        ,BILL_TO_ACCT_SITE_ID NUMBER(15) -- FK to hz_cust_acct_sites_all; mandatory
        ,CONTACT_PERS_PARTY_ID NUMBER(15) -- FK to hz_parties.party_id; Note: Status should be 'A'; optional
        ,CONTACT_REL_PARTY_ID NUMBER(15) -- FK to hz_relationships.party_id; optional
    );
    TYPE LOAN_PART_TBL_TYPE IS TABLE OF LOAN_PART_REC_TYPE INDEX BY BINARY_INTEGER;

    -- loan rate schedule
    TYPE LOAN_RATES_REC_TYPE IS RECORD (
        INDEX_RATE                  NUMBER  -- index interest rate for this rate record; mandatory
        ,SPREAD                     NUMBER  -- interest rate spread for this rate record; optional
        ,INDEX_DATE                 DATE    -- optional; if passed INDEX_RATE will be defaulted from this date
        ,BEGIN_INSTALLMENT_NUMBER   NUMBER  -- BEGIN_INSTALLMENT_NUMBER for this rate record; mandatory
        ,END_INSTALLMENT_NUMBER     NUMBER -- END_INSTALLMENT_NUMBER for this rate record; mandatory
        ,INTEREST_ONLY_FLAG         VARCHAR2(1)  -- 'Y' or 'N' or null; optional
    );
    TYPE LOAN_RATES_TBL_TYPE IS TABLE OF LOAN_RATES_REC_TYPE INDEX BY BINARY_INTEGER;

    -- custom schedule
    TYPE LOAN_CUST_SCHED_REC_TYPE IS RECORD (
        PAYMENT_NUMBER NUMBER  -- payment number; mandatory
        ,DUE_DATE DATE  -- payment due date; mandatory
        ,PRINCIPAL_AMOUNT NUMBER -- principal amount; mandatory
        ,INTEREST_AMOUNT NUMBER --interest amount; mandatory
        ,LOCK_PRIN  VARCHAR2(1) -- lock principal flag; if null will be set to Y
        ,LOCK_INT   VARCHAR2(1) -- lock interest flag; if null will be set to Y
    );
    TYPE LOAN_CUST_SCHED_TBL_TYPE IS TABLE OF LOAN_CUST_SCHED_REC_TYPE INDEX BY BINARY_INTEGER;

    -- accounting
    type distribution_rec is record(
        LINE_TYPE              VARCHAR2(30)  -- mandatory
        ,ACCOUNT_NAME           VARCHAR2(30)  -- mandatory
        ,CODE_COMBINATION_ID    NUMBER  -- mandatory
        ,ACCOUNT_TYPE           VARCHAR2(30)  -- mandatory
        ,DISTRIBUTION_PERCENT   NUMBER  -- mandatory
        ,DISTRIBUTION_AMOUNT    NUMBER  -- mandatory
        ,DISTRIBUTION_TYPE      VARCHAR2(30)  -- mandatory
    );
    type distribution_tbl is table of distribution_rec index by binary_integer;

    -- billing/payment history
    TYPE PAYMENT_HIST_REC_TYPE IS RECORD (
        PAYMENT_NUMBER                NUMBER
        ,DUE_DATE                     DATE
        ,BILLED_PRIN                  NUMBER
        ,BILLED_INT                   NUMBER
        ,BILLED_FEE                   NUMBER
        ,SOURCE                       VARCHAR2(30)
        ,PAID_PRIN                    NUMBER
        ,PAID_INT                     NUMBER
        ,PAID_FEE                     NUMBER
        ,PAID_DATE                    DATE
        ,RC_ID                        NUMBER
        ,RC_METHOD_ID                 NUMBER
    );
    TYPE PAYMENT_HIST_TBL_TYPE IS TABLE OF PAYMENT_HIST_REC_TYPE INDEX BY BINARY_INTEGER;

    TYPE Loan_create_errors_type IS TABLE OF LNS_LOAN_CREATE_ERRORS_GT%ROWTYPE;


/*#
 * Imports a loan
 * @param p_api_version API Version Number
 * @param P_INIT_MSG_LIST Init message stack flag
 * @param p_commit Commit flag
 * @param P_VALIDATION_LEVEL Validation level
 * @param P_Loan_Details_Rec Loan Details required to create a loan
 * @param P_Loan_Lines_Tbl Loan Lines required for ERS loan
 * @param P_LOAN_PART_TBL Table of additional loan participants
 * @param P_LOAN_RATES_TBL Rate schedule for term phase
 * @param p_loan_cust_sched_tbl Custom amortization schedule
 * @param p_distribution_tbl Table of distribution records
 * @param P_PAY_HIST_TBL Table of payment history
 * @param X_loan_id Loan Id if the loan creates successfully
 * @param X_return_status API return status
 * @param X_msg_count Number of error messages
 * @param X_MSG_DATA API return errors
*/
-- * @rep:scope internal
-- * @rep:displayname Import Loan
-- * @rep:lifecycle active
-- * @rep:compatibility S

/*========================================================================
 | PUBLIC PROCEDURE IMPORT_LOAN
 |
 | DESCRIPTION
 |      This procedure imports single loan.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_Loan_Details_Rec      IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.Loan_Details_Rec_Type  -- mandatory
 |      P_Loan_Lines_Tbl        IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.Loan_Lines_Tbl_Type  -- mandatory
 |      P_LOAN_PART_TBL         IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.LOAN_PART_TBL_TYPE  -- optional
 |      P_LOAN_RATES_TBL        IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.LOAN_RATES_TBL_TYPE  -- mandatory
 |      p_loan_cust_sched_tbl   IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.loan_cust_sched_tbl_type  -- optional
 |      p_distribution_tbl      IN OUT NOCOPY LNS_IMPORT_LOAN_PUB.distribution_tbl  -- optional
 |      P_PAY_HIST_TBL          IN OUT NOCOPY  LNS_IMPORT_LOAN_PUB.PAYMENT_HIST_TBL_TYPE
 |      X_LOAN_ID               OUT    NOCOPY  NUMBER,
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-20-2009            scherkas          Created for bug 6936893
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
    X_MSG_DATA	    	    OUT    NOCOPY  VARCHAR2);



END LNS_IMPORT_LOAN_PUB;

/
