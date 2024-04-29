--------------------------------------------------------
--  DDL for Package LNS_TERMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_TERMS_PUB" AUTHID CURRENT_USER AS
/*$Header: LNS_TERMS_PUBP_S.pls 120.5.12010000.8 2010/03/19 08:43:19 gparuchu ship $ */

TYPE loan_term_rec_type IS RECORD(
    TERM_ID                                  NUMBER,
    LOAN_ID                                  NUMBER,
    DAY_COUNT_METHOD                         VARCHAR2(50),
    BASED_ON_BALANCE                         VARCHAR2(30),
    FIRST_RATE_CHANGE_DATE                   DATE,
    NEXT_RATE_CHANGE_DATE                    DATE,
    PERCENT_INCREASE                         NUMBER,
    PERCENT_INCREASE_TERM                    VARCHAR2(30),
    PAYMENT_APPLICATION_ORDER                VARCHAR2(30),
    PREPAY_PENALTY_FLAG                      VARCHAR2(1),
    PREPAY_PENALTY_DATE                      DATE,
    CEILING_RATE                             NUMBER,
    FLOOR_RATE                               NUMBER,
    DELINQUENCY_THRESHOLD_NUMBER             NUMBER,
    DELINQUENCY_THRESHOLD_AMOUNT             NUMBER,
    CALCULATION_METHOD                       VARCHAR2(30),
    REAMORTIZE_UNDER_PAYMENT                 VARCHAR2(1),
    REAMORTIZE_OVER_PAYMENT                  VARCHAR2(1),
    REAMORTIZE_WITH_INTEREST                 VARCHAR2(1),
    LOAN_PAYMENT_FREQUENCY                   VARCHAR2(30),
    INTEREST_COMPOUNDING_FREQ                VARCHAR2(30),
    AMORTIZATION_FREQUENCY                   VARCHAR2(30),
    NUMBER_GRACE_DAYS                        NUMBER,
    RATE_TYPE                                VARCHAR2(30),
    INDEX_NAME                               VARCHAR2(50),
    ADJUSTMENT_FREQUENCY                     NUMBER,
    ADJUSTMENT_FREQUENCY_TYPE                VARCHAR2(30),
    FIXED_RATE_PERIOD                        NUMBER,
    FIXED_RATE_PERIOD_TYPE                   VARCHAR2(30),
    FIRST_PAYMENT_DATE    		     DATE,
    NEXT_PAYMENT_DUE_DATE		     DATE,
    OPEN_FIRST_PAYMENT_DATE                  DATE,
    OPEN_PAYMENT_FREQUENCY                   VARCHAR2(30),
    OPEN_NEXT_PAYMENT_DATE                   DATE,
    LOCK_IN_DATE                             DATE,
    LOCK_TO_DATE                             DATE,
    RATE_CHANGE_FREQUENCY                    VARCHAR2(30),
    INDEX_RATE_ID                            NUMBER,
    PERCENT_INCREASE_LIFE                    NUMBER,
    FIRST_PERCENT_INCREASE                   NUMBER,
    OPEN_PERCENT_INCREASE                    NUMBER,
    OPEN_PERCENT_INCREASE_LIFE               NUMBER,
    OPEN_FIRST_PERCENT_INCREASE              NUMBER,
    PMT_APPL_ORDER_SCOPE                     VARCHAR2(30),
    OPEN_CEILING_RATE                        NUMBER,
    OPEN_FLOOR_RATE                          NUMBER,
    OPEN_INDEX_DATE                          DATE,
    TERM_INDEX_DATE                          DATE,
    OPEN_PROJECTED_RATE                      NUMBER,
    TERM_PROJECTED_RATE                      NUMBER,
    PAYMENT_CALC_METHOD                      VARCHAR2(30),
    CUSTOM_CALC_METHOD                       VARCHAR2(30),
    ORIG_PAY_CALC_METHOD                     VARCHAR2(30),
    PRIN_FIRST_PAY_DATE		             DATE,
    PRIN_PAYMENT_FREQUENCY                   VARCHAR2(30),
    PENAL_INT_RATE                           NUMBER,
    PENAL_INT_GRACE_DAYS                     NUMBER,
    CALC_ADD_INT_UNPAID_PRIN		     VARCHAR2(1),
    CALC_ADD_INT_UNPAID_INT		     VARCHAR2(1),
    REAMORTIZE_ON_FUNDING		     VARCHAR2(30)
);
-------------------------------------------------------------------------

PROCEDURE create_term (
    p_init_msg_list    IN         VARCHAR2,
    p_loan_term_rec    IN         loan_term_rec_type,
    x_term_id          OUT NOCOPY NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_term (
    p_init_msg_list         IN            VARCHAR2,
    p_loan_term_rec         IN            loan_term_rec_type,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE validate_term (
    p_init_msg_list         IN            VARCHAR2,
    p_loan_term_rec         IN            loan_term_rec_type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE get_loan_term_rec (
    p_init_msg_list   IN         VARCHAR2,
    p_term_id         IN         NUMBER,
    x_loan_term_rec   OUT NOCOPY loan_term_rec_type,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE default_delinquency_amount (
    p_term_id               IN NUMBER,
    p_loan_id               IN NUMBER,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         IN OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE validate_rate_schedule(p_loan_id       IN NUMBER
                                ,x_return_status IN OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY    NUMBER
                                ,x_msg_data      OUT NOCOPY    VARCHAR2
);

PROCEDURE calculate_delinquency_amount(p_loan_id       IN NUMBER,
				       p_delinq_amt    IN OUT NOCOPY NUMBER,
                       x_return_status IN OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
				       x_msg_data      OUT NOCOPY VARCHAR2
);


END LNS_TERMS_PUB;

/
