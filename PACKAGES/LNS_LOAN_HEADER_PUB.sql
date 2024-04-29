--------------------------------------------------------
--  DDL for Package LNS_LOAN_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_LOAN_HEADER_PUB" AUTHID CURRENT_USER AS
/*$Header: LNS_LNHDR_PUBP_S.pls 120.8.12010000.4 2010/03/19 08:41:04 gparuchu ship $ */

TYPE loan_header_rec_type IS RECORD(
 LOAN_ID                         NUMBER,
 ORG_ID                          NUMBER,
 LOAN_NUMBER             	 VARCHAR2(60),
 LOAN_DESCRIPTION		 VARCHAR2(250),
 LOAN_APPLICATION_DATE           DATE,
 END_DATE                        DATE,
 INITIAL_LOAN_BALANCE            NUMBER,
 LAST_PAYMENT_DATE               DATE,
 LAST_PAYMENT_AMOUNT             NUMBER,
 LOAN_TERM                       NUMBER,
 LOAN_TERM_PERIOD                VARCHAR2(30),
 AMORTIZED_TERM                  NUMBER,
 AMORTIZED_TERM_PERIOD           VARCHAR2(30),
 LOAN_STATUS	  	         VARCHAR2(30),
 LOAN_ASSIGNED_TO                NUMBER,
 LOAN_CURRENCY                   VARCHAR2(15),
 LOAN_CLASS_CODE                 VARCHAR2(30),
 LOAN_TYPE                       VARCHAR2(30),
 LOAN_SUBTYPE                    VARCHAR2(30),
 LOAN_PURPOSE_CODE               VARCHAR2(30),
 CUST_ACCOUNT_ID                 NUMBER,
 BILL_TO_ACCT_SITE_ID            NUMBER,
 LOAN_MATURITY_DATE              DATE,
 LOAN_START_DATE                 DATE,
 LOAN_CLOSING_DATE               DATE,
 REFERENCE_ID	                 NUMBER,
 REFERENCE_NUMBER                VARCHAR2(60),
 REFERENCE_DESCRIPTION           VARCHAR2(250),
 REFERENCE_AMOUNT                NUMBER,
 PRODUCT_FLAG                    VARCHAR2(1),
 PRIMARY_BORROWER_ID             NUMBER,
 PRODUCT_ID                      NUMBER,
 REQUESTED_AMOUNT                NUMBER,
 FUNDED_AMOUNT                   NUMBER,
 LOAN_APPROVAL_DATE              DATE,
 LOAN_APPROVED_BY                NUMBER,
 ATTRIBUTE_CATEGORY              VARCHAR2(30),
 ATTRIBUTE1                      VARCHAR2(150),
 ATTRIBUTE2                      VARCHAR2(150),
 ATTRIBUTE3                      VARCHAR2(150),
 ATTRIBUTE4                      VARCHAR2(150),
 ATTRIBUTE5                      VARCHAR2(150),
 ATTRIBUTE6                      VARCHAR2(150),
 ATTRIBUTE7                      VARCHAR2(150),
 ATTRIBUTE8                      VARCHAR2(150),
 ATTRIBUTE9                      VARCHAR2(150),
 ATTRIBUTE10                     VARCHAR2(150),
 ATTRIBUTE11                     VARCHAR2(150),
 ATTRIBUTE12                     VARCHAR2(150),
 ATTRIBUTE13                     VARCHAR2(150),
 ATTRIBUTE14                     VARCHAR2(150),
 ATTRIBUTE15                     VARCHAR2(150),
 ATTRIBUTE16                     VARCHAR2(150),
 ATTRIBUTE17                     VARCHAR2(150),
 ATTRIBUTE18                     VARCHAR2(150),
 ATTRIBUTE19                     VARCHAR2(150),
 ATTRIBUTE20                     VARCHAR2(150),
 LAST_BILLED_DATE                DATE,
 CUSTOM_PAYMENTS_FLAG            VARCHAR2(1),
 BILLED_FLAG                     VARCHAR2(1),
 REFERENCE_NAME		         VARCHAR2(60),
 REFERENCE_TYPE		         VARCHAR2(30),
 REFERENCE_TYPE_ID		 NUMBER,
 USSGL_TRANSACTION_CODE	         VARCHAR2(30),
 GL_DATE		         DATE,
 REC_ADJUSTMENT_NUMBER           VARCHAR2(20),
 CONTACT_REL_PARTY_ID            NUMBER,
 CONTACT_PERS_PARTY_ID           NUMBER,
 CREDIT_REVIEW_FLAG	  	 VARCHAR2(1),
 EXCHANGE_RATE_TYPE		 VARCHAR2(30),
 EXCHANGE_DATE			 DATE,
 EXCHANGE_RATE			 NUMBER,
 COLLATERAL_PERCENT		 NUMBER,
 LAST_PAYMENT_NUMBER             NUMBER,
 LAST_AMORTIZATION_ID            NUMBER,
 LEGAL_ENTITY_ID                 NUMBER,
 OPEN_TO_TERM_FLAG               VARCHAR2(1),
 MULTIPLE_FUNDING_FLAG           VARCHAR2(1),
 LOAN_TYPE_ID                    NUMBER,
 SECONDARY_STATUS                VARCHAR2(30),
 OPEN_TO_TERM_EVENT              VARCHAR2(30),
 BALLOON_PAYMENT_TYPE            VARCHAR2(30),
 BALLOON_PAYMENT_AMOUNT          NUMBER,
 CURRENT_PHASE                   VARCHAR2(30),
 OPEN_LOAN_START_DATE            DATE,
 OPEN_LOAN_TERM                  NUMBER,
 OPEN_LOAN_TERM_PERIOD           VARCHAR2(30),
 OPEN_MATURITY_DATE              DATE,
 FUNDS_RESERVED_FLAG             VARCHAR2(1),
 FUNDS_CHECK_DATE                DATE,
 SUBSIDY_RATE	                 NUMBER,
 APPLICATION_ID			 NUMBER,
 CREATED_BY_MODULE		 VARCHAR2(150),
 PARTY_TYPE			 	 VARCHAR2(30),
 FORGIVENESS_FLAG	  	 VARCHAR2(1),
 FORGIVENESS_PERCENT	 NUMBER,
 DISABLE_BILLING_FLAG	  	 VARCHAR2(1),
 ADD_REQUESTED_AMOUNT		 NUMBER
);
-------------------------------------------------------------------------

PROCEDURE create_loan (
    p_init_msg_list    IN         VARCHAR2,
    p_loan_header_rec  IN         LOAN_HEADER_REC_TYPE,
    x_loan_id          OUT NOCOPY NUMBER,
    x_loan_number      OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_loan (
    p_init_msg_list         IN            VARCHAR2,
    p_loan_header_rec       IN            LOAN_HEADER_REC_TYPE,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE validate_loan (
    p_init_msg_list         IN            VARCHAR2,
    p_loan_header_rec       IN            LOAN_HEADER_REC_TYPE,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE get_loan_header_rec (
    p_init_msg_list   IN         VARCHAR2,
    p_loan_id         IN         NUMBER,
    x_loan_header_rec OUT        NOCOPY LOAN_HEADER_REC_TYPE,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
);

END LNS_LOAN_HEADER_PUB;

/
