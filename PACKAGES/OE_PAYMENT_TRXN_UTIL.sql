--------------------------------------------------------
--  DDL for Package OE_PAYMENT_TRXN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PAYMENT_TRXN_UTIL" AUTHID CURRENT_USER AS
/*$Header: OEXUPTXS.pls 120.6.12010000.3 2008/11/25 14:27:56 sgoli ship $*/

g_CC_Security_Code_Use VARCHAR2(20); --Verify the length!
g_old_bill_to_site NUMBER := null;

Procedure Create_Payment_Trxn(	p_header_id		IN NUMBER,
				P_line_id		IN NUMBER,
				p_cust_id		IN NUMBER,
				P_site_use_id		IN NUMBER,
				P_payment_trx_id	IN NUMBER,
				P_payment_type_code	IN VARCHAR2,
				p_payment_number	IN NUMBER, --Newly added
				P_card_number		IN VARCHAR2 DEFAULT NULL,
				p_card_code		IN VARCHAR2 DEFAULT NULL,
				P_card_holder_name	IN VARCHAR2 DEFAULT NULL,
				P_exp_date		IN VARCHAR2 DEFAULT NULL,
				P_instrument_security_code IN VARCHAR2 DEFAULT NULL,
				P_credit_card_approval_code	IN VARCHAR2 DEFAULT NULL,
				P_credit_card_approval_date	IN DATE DEFAULT NULL,
				p_instrument_id		IN NUMBER DEFAULT NULL,
				p_instrument_assignment_id IN NUMBER DEFAULT NULL,
				p_receipt_method_id	IN NUMBER,
				p_update_card_flag	IN VARCHAR2 DEFAULT 'N',
				P_x_trxn_extension_id	IN OUT NOCOPY NUMBER,
				X_return_status		OUT NOCOPY VARCHAR2,
				X_msg_count		OUT NOCOPY NUMBER,
				X_msg_data		OUT NOCOPY VARCHAR2);

Procedure Update_Payment_Trxn(	p_header_id		IN NUMBER,
				P_line_id		IN NUMBER,
				p_cust_id		IN NUMBER,
				P_site_use_id		IN NUMBER,
				p_payment_trx_id	IN NUMBER,
				p_payment_type_code	IN VARCHAR2,
				p_payment_number	IN NUMBER, --New
				p_card_number		IN VARCHAR2,
				P_card_code	IN VARCHAR2,
				p_card_holder_name	IN VARCHAR2,
				p_exp_date		IN DATE,
				p_instrument_security_code IN VARCHAR2,
				--Bug 7460481 starts
				P_credit_card_approval_code	IN VARCHAR2 DEFAULT NULL,
				P_credit_card_approval_date	IN DATE DEFAULT NULL,
				--Bug 7460481 ends
				p_instrument_id		IN NUMBER DEFAULT NULL,
				p_instrument_assignment_id IN NUMBER DEFAULT NULL,
				p_receipt_method_id	IN NUMBER,
				p_update_card_flag	IN VARCHAR2 DEFAULT 'N',
				p_trxn_extension_id	IN OUT NOCOPY NUMBER, --bug 4885313
				X_return_status		OUT NOCOPY  VARCHAR2,
				X_msg_count		OUT NOCOPY NUMBER,
				X_msg_data		OUT NOCOPY VARCHAR2);

Procedure Copy_Payment_Trxn(	p_header_id		IN NUMBER,
				P_line_id		IN NUMBER,
				p_cust_id		IN NUMBER,
				P_site_use_id		IN NUMBER,
				p_trxn_extension_id	IN NUMBER,
				x_trxn_extension_id	OUT NOCOPY NUMBER,
				X_return_status		OUT NOCOPY VARCHAR2,
				X_msg_count		OUT NOCOPY NUMBER,
				X_msg_data		OUT NOCOPY VARCHAR2);

Procedure Get_Payment_Trxn_Info(p_header_id			IN NUMBER,
				P_trxn_extension_id		IN NUMBER,
				P_payment_type_code		IN VARCHAR2,
				X_credit_card_number		OUT NOCOPY VARCHAR2,
				X_credit_card_holder_name	OUT NOCOPY VARCHAR2,
				X_credit_card_expiration_date	OUT NOCOPY VARCHAR2,
				X_credit_card_code		OUT NOCOPY VARCHAR2,
				X_credit_card_approval_code	OUT NOCOPY VARCHAR2,
				X_credit_card_approval_date	OUT NOCOPY VARCHAR2,
				X_bank_account_number		OUT NOCOPY VARCHAR2,
				--X_check_number		OUT NOCOPY VARCHAR2,
				X_instrument_security_code	OUT NOCOPY VARCHAR2,
				X_instrument_id			OUT NOCOPY NUMBER,
				X_instrument_assignment_id	OUT NOCOPY NUMBER,
				X_return_status			OUT NOCOPY VARCHAR2,
				X_msg_count			OUT NOCOPY NUMBER,
				X_msg_data			OUT NOCOPY VARCHAR2);
PROCEDURE Delete_Payment_Trxn
(
 p_header_id	    IN NUMBER,
 p_line_id	    IN NUMBER,
 p_payment_number   IN NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2,
 p_trxn_extension_id        IN   NUMBER,
 P_site_use_id	    IN NUMBER
 );


FUNCTION Get_CC_Security_Code_Use RETURN VARCHAR2;
FUNCTION Get_Settled_Flag(p_Trxn_Extension_Id Number) RETURN VARCHAR2;


END OE_PAYMENT_TRXN_UTIL;

/
