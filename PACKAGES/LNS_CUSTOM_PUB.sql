--------------------------------------------------------
--  DDL for Package LNS_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_CUSTOM_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_CUST_PUBP_S.pls 120.0.12010000.6 2010/03/17 14:47:45 scherkas ship $ */

TYPE custom_sched_type IS RECORD(CUSTOM_SCHEDULE_ID     NUMBER
                                ,LOAN_ID                NUMBER
                                ,PAYMENT_NUMBER         NUMBER
                                ,DUE_DATE               DATE
                                ,PERIOD_START_DATE      DATE
                                ,PERIOD_END_DATE        DATE
                                ,PRINCIPAL_AMOUNT       NUMBER
                                ,INTEREST_AMOUNT        NUMBER
                                ,NORMAL_INT_AMOUNT      NUMBER
                                ,ADD_PRIN_INT_AMOUNT    NUMBER
                                ,ADD_INT_INT_AMOUNT     NUMBER
                                ,PENAL_INT_AMOUNT       NUMBER
                                ,PRINCIPAL_BALANCE      NUMBER
                                ,FEE_AMOUNT             NUMBER
                                ,OTHER_AMOUNT           NUMBER
                                ,OBJECT_VERSION_NUMBER  NUMBER
                                ,ATTRIBUTE_CATEGORY     VARCHAR2(30)
                                ,ATTRIBUTE1             VARCHAR2(150)
                                ,ATTRIBUTE2             VARCHAR2(150)
                                ,ATTRIBUTE3             VARCHAR2(150)
                                ,ATTRIBUTE4             VARCHAR2(150)
                                ,ATTRIBUTE5             VARCHAR2(150)
                                ,ATTRIBUTE6             VARCHAR2(150)
                                ,ATTRIBUTE7             VARCHAR2(150)
                                ,ATTRIBUTE8             VARCHAR2(150)
                                ,ATTRIBUTE9             VARCHAR2(150)
                                ,ATTRIBUTE10            VARCHAR2(150)
                                ,ATTRIBUTE11            VARCHAR2(150)
                                ,ATTRIBUTE12            VARCHAR2(150)
                                ,ATTRIBUTE13            VARCHAR2(150)
                                ,ATTRIBUTE14            VARCHAR2(150)
                                ,ATTRIBUTE15            VARCHAR2(150)
                                ,ATTRIBUTE16            VARCHAR2(150)
                                ,ATTRIBUTE17            VARCHAR2(150)
                                ,ATTRIBUTE18            VARCHAR2(150)
                                ,ATTRIBUTE19            VARCHAR2(150)
                                ,ATTRIBUTE20            VARCHAR2(150)
                                ,CURRENT_TERM_PAYMENT   NUMBER
                                ,INSTALLMENT_BEGIN_BALANCE NUMBER
                                ,INSTALLMENT_END_BALANCE NUMBER
                                ,PRINCIPAL_PAID_TODATE  NUMBER
                                ,INTEREST_PAID_TODATE   NUMBER
                                ,INTEREST_RATE          NUMBER
                                ,UNPAID_PRIN            NUMBER
                                ,UNPAID_INT             NUMBER
                                ,LOCK_PRIN              VARCHAR2(1)
                                ,LOCK_INT               VARCHAR2(1)
                                ,ACTION                 VARCHAR2(1)
                                ,FUNDED_AMOUNT          NUMBER
                                ,NORMAL_INT_DETAILS     VARCHAR2(2000)
                                ,ADD_PRIN_INT_DETAILS   VARCHAR2(2000)
                                ,ADD_INT_INT_DETAILS    VARCHAR2(2000)
                                ,PENAL_INT_DETAILS      VARCHAR2(2000)
                                ,DISBURSEMENT_AMOUNT    NUMBER
                                ,PERIOD                 VARCHAR2(200));

 Type custom_tbl is table of custom_sched_type index by binary_integer;

TYPE LOAN_DETAILS_REC IS RECORD(LOAN_ID                      NUMBER       -- loan id
                                ,AMORTIZATION_FREQUENCY      VARCHAR2(30)
                                ,PAYMENT_FREQUENCY           VARCHAR2(30)
                                ,LOAN_START_DATE             DATE
                                ,FUNDED_AMOUNT               NUMBER
                                ,requested_amount            NUMBER
                                ,REMAINING_BALANCE           NUMBER
                                ,UNPAID_PRINCIPAL            NUMBER
                                ,UNPAID_INTEREST             NUMBER
                                ,UNBILLED_PRINCIPAL          NUMBER
                                ,BILLED_PRINCIPAL            NUMBER
                                ,MATURITY_DATE               DATE
                                ,LAST_INSTALLMENT_BILLED     NUMBER
                                ,DAY_COUNT_METHOD            VARCHAR2(30)
                                ,CUSTOM_SCHEDULE             VARCHAR2(1)  -- Y/N for custom payment schedule
                                ,LOAN_STATUS                 VARCHAR2(30) -- loan status
                                ,LOAN_CURRENCY               VARCHAR2(15) -- loan currency
                                ,CURRENCY_PRECISION          NUMBER     -- currency precision
                                ,PAYMENT_CALC_METHOD         VARCHAR2(30)  -- payment calc method: equal payment, equal principal
                                ,CALCULATION_METHOD          VARCHAR2(30)  -- interest calc method: simple, compound
                                ,INTEREST_COMPOUNDING_FREQ   VARCHAR2(30)
                                ,LAST_DUE_DATE               DATE
                                ,CUSTOM_CALC_METHOD          VARCHAR2(30)
                                ,ORIG_PAY_CALC_METHOD        VARCHAR2(30)
                                ,RATE_TYPE                     VARCHAR2(30) -- fixed or variable
                                ,TERM_CEILING_RATE             NUMBER       -- term ceiling rate
                                ,TERM_FLOOR_RATE               NUMBER       -- term floor rate
                                ,TERM_FIRST_PERCENT_INCREASE   NUMBER       -- term first percentage increase
                                ,TERM_ADJ_PERCENT_INCREASE     NUMBER       -- term percentage increase btwn adjustments
                                ,TERM_LIFE_PERCENT_INCREASE    NUMBER       -- term lifetime max adjustment for interest
                                ,TERM_INDEX_RATE_ID            NUMBER       -- index_rate_id
                                ,INITIAL_INTEREST_RATE         NUMBER
                                ,LAST_INTEREST_RATE            NUMBER
                                ,FIRST_RATE_CHANGE_DATE        DATE
                                ,NEXT_RATE_CHANGE_DATE         DATE
                                ,TERM_PROJECTED_INTEREST_RATE  NUMBER  -- term projected interest rate
                                ,PENAL_INT_RATE                NUMBER
                                ,PENAL_INT_GRACE_DAYS          NUMBER
                                ,REAMORTIZE_ON_FUNDING         VARCHAR2(30));


procedure resetCustomSchedule(p_loan_id        IN number
                             ,p_init_msg_list  IN VARCHAR2
                             ,p_commit         IN VARCHAR2
                             ,p_update_header  IN boolean
                             ,x_return_status  OUT NOCOPY VARCHAR2
                             ,x_msg_count      OUT NOCOPY NUMBER
                             ,x_msg_data       OUT NOCOPY VARCHAR2);

procedure createCustomSchedule(p_custom_tbl     IN CUSTOM_TBL
                              ,p_loan_id        IN number
                              ,p_init_msg_list  IN VARCHAR2
                              ,p_commit         IN VARCHAR2
                              ,x_return_status  OUT NOCOPY VARCHAR2
                              ,x_msg_count      OUT NOCOPY NUMBER
                              ,x_msg_data       OUT NOCOPY VARCHAR2
                              ,X_INVALID_INSTALLMENT_NUM OUT NOCOPY NUMBER);

procedure updateCustomSchedule(p_custom_tbl     IN CUSTOM_TBL
                              ,p_loan_id        IN number
                              ,p_init_msg_list  IN VARCHAR2
                              ,p_commit         IN VARCHAR2
                              ,x_return_status  OUT NOCOPY VARCHAR2
                              ,x_msg_count      OUT NOCOPY NUMBER
                              ,x_msg_data       OUT NOCOPY VARCHAR2
                              ,X_INVALID_INSTALLMENT_NUM OUT NOCOPY NUMBER);

procedure createCustomSched(P_CUSTOM_REC        IN CUSTOM_SCHED_TYPE
                           ,x_custom_sched_id  OUT NOCOPY NUMBER
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2);

procedure updateCustomSched(P_CUSTOM_REC IN CUSTOM_SCHED_TYPE
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2);

procedure validateCustomTable(p_cust_tbl          in CUSTOM_TBL
                             ,p_loan_id          in number
                             ,p_create_flag      in boolean
                             ,x_installment      OUT NOCOPY NUMBER
                             ,x_return_status    OUT NOCOPY VARCHAR2
                             ,x_msg_count        OUT NOCOPY NUMBER
                             ,x_msg_data         OUT NOCOPY VARCHAR2);

procedure validateCustomRow(p_custom_rec in CUSTOM_SCHED_TYPE
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2);

-- This procedure recalculates custom schedule
procedure recalcCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_AMORT_METHOD      IN              VARCHAR2,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        P_CUSTOM_TBL        IN OUT NOCOPY   LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);

-- This procedure loads custom schedule from db
procedure loadCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        X_AMORT_METHOD      OUT NOCOPY      VARCHAR2,
        X_CUSTOM_TBL        OUT NOCOPY      LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);

-- This procedure saves custom schedule into db
procedure saveCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_AMORT_METHOD      IN              VARCHAR2,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        P_CUSTOM_TBL        IN OUT NOCOPY   LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);

-- This procedure switches from standard schedule to custom schedule in one shot
-- Conditions: loan status is INCOMPLETE and loan has not been customized yet
procedure customizeSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);

-- This procedure switches back from custom schedule to standard schedule in one shot
-- Conditions: loan status is INCOMPLETE and loan has been already customized
procedure uncustomizeSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_ST_AMORT_METHOD   IN              VARCHAR2,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);

-- This procedure recalculates custom schedule with shifting all subsequent due dates on a single due date change
procedure shiftCustomSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        P_OLD_DUE_DATE      IN              DATE,
        P_NEW_DUE_DATE      IN              DATE,
        P_AMORT_METHOD      IN              VARCHAR2,
        P_BASED_ON_TERMS    IN              VARCHAR2,
        P_CUSTOM_TBL        IN OUT NOCOPY   LNS_CUSTOM_PUB.CUSTOM_TBL,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);


-- This procedure rebuilds the custom schedule and delete rows whose dueDate > maturityDate
-- Conditions: loan status is INCOMPLETE
procedure reBuildCustomdSchedule(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_LOAN_ID           IN              NUMBER,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);


-- This procedure builds custom payment schedule and returns LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL table
function buildCustomPaySchedule(P_LOAN_ID IN NUMBER) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;

-- added for bug 7716548
-- This procedure adds installment to custom schedule only if it does not already exist
procedure addMissingInstallment(
        P_API_VERSION		IN              NUMBER,
        P_INIT_MSG_LIST		IN              VARCHAR2,
        P_COMMIT			IN              VARCHAR2,
        P_VALIDATION_LEVEL	IN              NUMBER,
        P_INSTALLMENT_REC   IN              LNS_CUSTOM_PUB.custom_sched_type,
        X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
        X_MSG_COUNT			OUT NOCOPY      NUMBER,
        X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);

END LNS_CUSTOM_PUB;

/
