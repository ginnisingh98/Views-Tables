--------------------------------------------------------
--  DDL for Package ASO_PAYMENT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PAYMENT_INT" AUTHID CURRENT_USER as
/* $Header: asoipays.pls 120.4.12010000.2 2010/05/28 08:38:18 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_PAYMENT_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Record Type:
-- CC_TRXN_REC_TPYE
-- CC_TRXN_OUT  _REC_TYPE

TYPE CC_Trxn_Rec_Type IS RECORD
(
     merchant_id                   VARCHAR2(80),
     credit_card_code              VARCHAR2(80),
	credit_card_num               VARCHAR2(80),
	credit_card_expiration_date   DATE,
     credit_card_holder_name       VARCHAR2(80),
	invoice_to_address1           VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_address2           VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_address3           VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_address4           VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_city               VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_county             VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_state              VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_country            VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
	invoice_to_PostalCode         VARCHAR2(40)    :=  FND_API.G_MISS_CHAR,
	tangible_id                   VARCHAR2(80),
	tangible_amount               NUMBER,
	currency_code                 VARCHAR2(80),
	pmt_mode                      VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
	Settlement_date			DATE            :=  FND_API.G_MISS_DATE,
	check_flag                    VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
	auth_type                     VARCHAR2(80),
	RefInfo                       VARCHAR2(80),
     cvv2                          VARCHAR2(10)    :=  FND_API.G_MISS_CHAR
);

G_MISS_CC_Trxn_Rec_Type	CC_Trxn_Rec_Type;


TYPE CC_Trxn_Out_Rec_Type IS RECORD
(
	status                        NUMBER,
	err_code                      VARCHAR2(80),
	err_message                   VARCHAR2(255),
	NLS_LANG                      VARCHAR2(80),
	trxn_id                       NUMBER,
	trxn_date                     DATE,
	auth_code                     VARCHAR2(80),
	err_location                  NUMBER,
	bep_err_code                  VARCHAR2(80),
	bep_err_message               VARCHAR2(255)
);

G_MISS_CC_Trxn_Out_Rec_Type CC_Trxn_Out_Rec_Type;



FUNCTION Get_payment_term_id( p_qte_header_id     NUMBER,
                              p_qte_line_id       NUMBER
                            )
RETURN NUMBER;

PROCEDURE create_iby_payment(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             db_payment_rec  IN         aso_quote_pub.payment_rec_type := aso_quote_pub.G_MISS_PAYMENT_REC,
                             p_payer         IN         IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
                             x_payment_rec   OUT NOCOPY aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2);


PROCEDURE create_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_payment_rec   OUT NOCOPY aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2);

PROCEDURE update_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_payment_rec   OUT NOCOPY aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2);

PROCEDURE delete_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2);

PROCEDURE PURGE_ASO_PAYMENTS_DATA; -- Code added for Bug 9746746

End ASO_PAYMENT_INT;


/
