--------------------------------------------------------
--  DDL for Package AR_INTEREST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INTEREST_HEADERS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARIIINVS.pls 120.1 2006/03/09 22:52:28 hyu noship $ */

FUNCTION get_header_amount
(p_interest_header_id IN NUMBER)
RETURN NUMBER;

PROCEDURE Lock_header
(P_INTEREST_HEADER_ID               IN  NUMBER,
 P_INTEREST_BATCH_ID                IN  NUMBER,
 P_CUSTOMER_ID                      IN  NUMBER,
 P_CUSTOMER_SITE_USE_ID             IN  NUMBER,
 P_HEADER_TYPE                      IN  VARCHAR2,
 P_CURRENCY_CODE                    IN  VARCHAR2,
 P_LATE_CHARGE_CALCULATION_TRX      IN  VARCHAR2,
 P_CREDIT_ITEMS_FLAG                IN  VARCHAR2,
 P_DISPUTED_TRANSACTIONS_FLAG       IN  VARCHAR2,
 P_PAYMENT_GRACE_DAYS               IN  NUMBER,
 P_LATE_CHARGE_TERM_ID              IN  NUMBER,
 P_INTEREST_PERIOD_DAYS             IN  NUMBER,
 P_INTEREST_CALCULATION_PERIOD      IN  VARCHAR2,
 P_CHARGE_ON_FINANCE_CHARGE_FLG     IN  VARCHAR2,
 P_HOLD_CHARGED_INVOICES_FLAG       IN  VARCHAR2,
 P_MESSAGE_TEXT_ID                  IN  NUMBER,
 P_MULTIPLE_INTEREST_RATES_FLAG     IN  VARCHAR2,
 P_CHARGE_BEGIN_DATE                IN  DATE,
 P_CUST_ACCT_PROFILE_AMT_ID         IN  NUMBER,
 P_EXCHANGE_RATE                    IN  NUMBER,
 P_EXCHANGE_RATE_TYPE               IN  VARCHAR2,
 P_MIN_FC_INVOICE_OVERDUE_TYPE      IN  VARCHAR2,
 P_MIN_FC_INVOICE_AMOUNT            IN  NUMBER,
 P_MIN_FC_INVOICE_PERCENT           IN  NUMBER,
 P_MIN_FC_BALANCE_OVERDUE_TYPE     IN  VARCHAR2,
 P_MIN_FC_BALANCE_AMOUNT            IN  NUMBER,
 P_MIN_FC_BALANCE_PERCENT           IN  NUMBER,
 P_MIN_INTEREST_CHARGE              IN  NUMBER,
 P_MAX_INTEREST_CHARGE              IN  NUMBER,
 P_INTEREST_TYPE                    IN  VARCHAR2,
 P_INTEREST_RATE                    IN  NUMBER,
 P_INTEREST_FIXED_AMOUNT            IN  NUMBER,
 P_INTEREST_SCHEDULE_ID             IN  NUMBER,
 P_PENALTY_TYPE                     IN  VARCHAR2,
 P_PENALTY_RATE                     IN  NUMBER,
 P_PENALTY_FIXED_AMOUNT             IN  NUMBER,
 P_PENALTY_SCHEDULE_ID              IN  NUMBER,
 P_LAST_ACCRUE_CHARGE_DATE          IN  DATE,
 P_CUSTOMER_PROFILE_ID              IN  NUMBER,
 P_COLLECTOR_ID                     IN  NUMBER,
 P_LEGAL_ENTITY_ID                  IN  NUMBER,
 P_LAST_UPDATE_DATE                 IN  DATE,
 P_LAST_UPDATED_BY                  IN  NUMBER,
 P_LAST_UPDATE_LOGIN                IN  NUMBER,
 P_CREATED_BY                       IN  NUMBER,
 P_CREATION_DATE                    IN  DATE,
 P_ORG_ID                           IN  NUMBER,
 P_PROCESS_MESSAGE                  IN  VARCHAR2,
 P_PROCESS_STATUS                   IN  VARCHAR2,
 P_CUST_TRX_TYPE_ID                 IN  NUMBER,
 P_OBJECT_VERSION_NUMBER            IN  NUMBER,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2);

PROCEDURE validate_header
(p_action              IN VARCHAR2,
 p_old_rec             IN ar_interest_headers%ROWTYPE,
 p_new_rec             IN ar_interest_headers%ROWTYPE,
 p_updated_by_program  IN VARCHAR2 DEFAULT 'ARIINR',
 x_return_status   IN OUT NOCOPY VARCHAR2);



PROCEDURE update_header
(p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false,
 P_INTEREST_HEADER_ID        IN  NUMBER,
 P_PROCESS_MESSAGE           IN  VARCHAR2,
 P_PROCESS_STATUS            IN  VARCHAR2,
 p_updated_by_program        IN VARCHAR2 DEFAULT 'ARIINR',
 x_object_version_number     IN OUT NOCOPY NUMBER,
 x_return_status             OUT NOCOPY  VARCHAR2,
 x_msg_count                 OUT NOCOPY  NUMBER,
 x_msg_data                  OUT NOCOPY  VARCHAR2);

PROCEDURE Delete_header
(p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
 p_interest_header_id    IN NUMBER,
 x_object_version_number IN NUMBER,
 x_return_status         OUT NOCOPY  VARCHAR2,
 x_msg_count             OUT NOCOPY  NUMBER,
 x_msg_data              OUT NOCOPY  VARCHAR2);

END AR_INTEREST_HEADERS_PKG;

 

/
