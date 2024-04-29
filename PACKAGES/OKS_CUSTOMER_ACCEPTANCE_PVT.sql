--------------------------------------------------------
--  DDL for Package OKS_CUSTOMER_ACCEPTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CUSTOMER_ACCEPTANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSVCUSS.pls 120.6.12000000.1 2007/01/16 22:16:17 appldev ship $ */

FUNCTION get_contract_amount
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_subtotal
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_tax
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_accept_clause
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_decline_clause
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_vendor
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_customer
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_party
(
 p_chr_id              IN NUMBER
) RETURN NUMBER;

FUNCTION get_contract_organization
(
 p_chr_id              IN NUMBER
) RETURN NUMBER;

FUNCTION get_contract_salesrep_email
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_cust_account_id
(
 p_chr_id              IN NUMBER
) RETURN NUMBER;

FUNCTION get_req_ass_email_subject
(
p_chr_id              IN NUMBER
) RETURN VARCHAR2;

FUNCTION duration_unit_and_period
(
 p_start_date         IN DATE,
 p_end_date           IN DATE
) RETURN VARCHAR2;

FUNCTION get_credit_card_dtls
(
 p_trxn_extension_id   IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_credit_card_cvv2
(
 p_trxn_extension_id   IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_contract_currency_tip
(
 p_chr_id              IN NUMBER
) RETURN VARCHAR2;

PROCEDURE decline_contract
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_chr_id               IN NUMBER,
 p_reason_code          IN VARCHAR2,
 p_decline_reason       IN VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
);

PROCEDURE accept_contract
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_chr_id               IN NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
);

PROCEDURE update_payment_details
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_chr_id               IN NUMBER,
 p_payment_type         IN VARCHAR2,
 p_payment_details      IN VARCHAR2,
 p_party_id             IN NUMBER,
 p_cust_account_id      IN NUMBER,
 p_card_number          IN VARCHAR2 DEFAULT NULL,
 p_expiration_month     IN VARCHAR2 DEFAULT NULL,
 p_expiration_year      IN VARCHAR2 DEFAULT NULL,
 p_cvv_code             IN VARCHAR2 DEFAULT NULL,
 p_instr_assignment_id  IN NUMBER DEFAULT NULL,
 p_old_txn_entension_id IN NUMBER DEFAULT NULL,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
);

PROCEDURE send_email
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_chr_id               IN NUMBER,
 p_send_to              IN VARCHAR2,
 p_cc_to                IN VARCHAR2,
 p_subject              IN VARCHAR2,
 p_text                 IN VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
);

PROCEDURE get_valid_payments
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_chr_id               IN NUMBER,
 x_valid_payments       OUT NOCOPY VARCHAR2,
 x_default_payment      OUT NOCOPY VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
);

PROCEDURE process_credit_card
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_commit               IN VARCHAR2  DEFAULT FND_API.G_FALSE,
 p_order_id             IN NUMBER,
 p_party_id             IN NUMBER,
 p_cust_account_id      IN NUMBER,
 p_card_number          IN VARCHAR2 DEFAULT NULL,
 p_expiration_date      IN DATE DEFAULT NULL,
 p_billing_address_id   IN NUMBER DEFAULT NULL,
 p_cvv_code             IN VARCHAR2 DEFAULT NULL,
 p_instr_assignment_id  IN NUMBER DEFAULT NULL,
 p_old_txn_entension_id IN NUMBER DEFAULT NULL,
 x_new_txn_entension_id OUT NOCOPY NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
);

PROCEDURE get_contract_salesrep_details
(
 p_chr_id             IN       NUMBER,
 x_salesrep_email     OUT NOCOPY VARCHAR2,
 x_salesrep_username  OUT NOCOPY VARCHAR2,
 x_return_status      OUT NOCOPY VARCHAR2,
 x_msg_data           OUT NOCOPY VARCHAR2,
 x_msg_count          OUT NOCOPY NUMBER
);

PROCEDURE delete_transaction_extension
(
 p_chr_id             IN  NUMBER,
 p_commit             IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
 x_return_status      OUT NOCOPY VARCHAR2,
 x_msg_data           OUT NOCOPY VARCHAR2,
 x_msg_count          OUT NOCOPY NUMBER
);

END OKS_CUSTOMER_ACCEPTANCE_PVT;

 

/
