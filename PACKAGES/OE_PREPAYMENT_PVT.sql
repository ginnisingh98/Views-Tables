--------------------------------------------------------
--  DDL for Package OE_PREPAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PREPAYMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVPPYS.pls 120.9.12010000.2 2009/04/28 06:20:52 cpati ship $ */

g_process_pmt_req_logged	VARCHAR2(1) := 'N';

/*--------------------------------------------------------------------------
Function Calculate_Pending_Amount
Returns the pending amount to be processed
Note that the threshold factor has been included here
/*--------------------------------------------------------------------------

FUNCTION Calculate_Pending_Amount
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type)
RETURN NUMBER;

/*--------------------------------------------------------------------------
Procedure Create_Receipt
This procedure calls AR API to create a new receipt for the amount specified.
This procedure is called from OE_PrePayment_PVT.Process_Payment.
----------------------------------------------------------------------------*/
PROCEDURE Create_Receipt
(  p_header_rec      			IN   OE_Order_PUB.Header_Rec_Type
,  p_amount          			IN   NUMBER
,  p_receipt_method_id			IN   NUMBER
,  p_bank_acct_id			IN   NUMBER
,  p_bank_acct_uses_id			IN   NUMBER
,  p_trxn_extension_id			IN   NUMBER  --R12 CC Encryption
,  p_payment_set_id			IN   OUT NOCOPY NUMBER
,  p_receipt_number                     IN   OUT NOCOPY VARCHAR2  -- bug 4724845
,  p_payment_number                     IN   OE_PAYMENTS.PAYMENT_NUMBER%TYPE DEFAULT NULL --7559372
,  x_payment_response_error_code	OUT  NOCOPY VARCHAR2
,  p_approval_code			IN   OUT  NOCOPY VARCHAR2
,  x_msg_count       			OUT  NOCOPY NUMBER
,  x_msg_data        			OUT  NOCOPY VARCHAR2
,  x_return_status   			OUT  NOCOPY VARCHAR2
,  x_result_out      			OUT  NOCOPY VARCHAR2
);

/*--------------------------------------------------------------------------
Procedure Refund_Request
This procedure calls AR API to submit refund request for the amount specified.
----------------------------------------------------------------------------*/
PROCEDURE Refund_Request
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_amount          IN   NUMBER
,  p_payment_set_id  IN   NUMBER
,  x_msg_count       OUT  NOCOPY NUMBER
,  x_msg_data        OUT  NOCOPY VARCHAR2
,  x_return_status   OUT  NOCOPY VARCHAR2
,  x_result_out      OUT  NOCOPY VARCHAR2
);

/*--------------------------------------------------------------------------
Procedure Process_PrePayment_Order
This is the main procedure to process prepayment for prepaid orders .
----------------------------------------------------------------------------*/
PROCEDURE Process_PrePayment_Order
(  p_header_rec      		IN   OE_Order_PUB.Header_Rec_Type
,  p_calling_action  		IN   VARCHAR2
,  p_delayed_request 		IN   VARCHAR2
,  x_msg_count       		OUT  NOCOPY NUMBER
,  x_msg_data        		OUT  NOCOPY VARCHAR2
,  x_return_status   		OUT  NOCOPY VARCHAR2
);

PROCEDURE Any_Prepayment_Hold_Exists
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_hold_exists     OUT  NOCOPY VARCHAR2  -- 'Y' or 'N'
);

PROCEDURE Release_prepayment_hold
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_msg_count       OUT  NOCOPY NUMBER    -- Message Count
,  p_msg_data        OUT  NOCOPY VARCHAR2  -- Messages
,  p_return_status   OUT  NOCOPY VARCHAR2  -- Success or Failure
);


PROCEDURE Apply_prepayment_hold
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_hold_id         IN   NUMBER    -- Seeded Id of Hold to be applied
,  p_msg_count       IN OUT  NOCOPY NUMBER    -- Message Count
,  p_msg_data        IN OUT  NOCOPY VARCHAR2  -- Messages
,  p_return_status   OUT  NOCOPY VARCHAR2  -- Success or Failure
);

PROCEDURE Release_Payment_Hold
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_hold_id	     IN   NUMBER
,  p_msg_count       OUT  NOCOPY NUMBER    -- Message Count
,  p_msg_data        OUT  NOCOPY VARCHAR2  -- Messages
,  p_return_status   OUT  NOCOPY VARCHAR2  -- Success or Failure
);

FUNCTION Get_Format_Mask(p_currency_code IN VARCHAR2)
RETURN  VARCHAR2;

-- New procedure for pack J multiple payments project.
PROCEDURE Process_Payments
(  p_header_id                  IN   NUMBER
,  p_line_id                    IN   NUMBER DEFAULT null --bug3524209
,  p_calling_action             IN   VARCHAR2
,  p_amount			IN   NUMBER
,  p_delayed_request           	IN   VARCHAR2
--R12 CVV2
--comm rej,  p_reject_on_auth_failure IN VARCHAR2 DEFAULT NULL
--comm rej,  p_reject_on_risk_failure IN VARCHAR2 DEFAULT NULL
,  p_risk_eval_flag  IN VARCHAR2 DEFAULT  NULL --bug 6805953 'Y'
--R12 CVV2
,  p_process_prepayment         IN   VARCHAR2 DEFAULT 'Y'
,  p_process_authorization      IN   VARCHAR2 DEFAULT 'Y'
,  x_msg_count                 	OUT  NOCOPY NUMBER
,  x_msg_data                  	OUT  NOCOPY VARCHAR2
,  x_return_status             	OUT  NOCOPY VARCHAR2
);
--R12 CC Encryption
Procedure Delete_Payments
( p_line_id IN NUMBER
, p_header_id IN NUMBER
, p_invoice_to_org_id IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT  NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
);
--R12 CC Encryption
procedure Split_Payment
(p_line_id           	IN   NUMBER
,p_header_id		IN   NUMBER
,p_split_from_line_id	IN   NUMBER
,x_return_status      	OUT  NOCOPY VARCHAR2
,x_msg_count          	OUT  NOCOPY NUMBER
,x_msg_data           	OUT  NOCOPY VARCHAR2
 );

PROCEDURE Process_Payment_Assurance
(p_api_version_number	IN	NUMBER
,p_line_id		IN	NUMBER
,p_activity_id		IN	NUMBER
,p_exists_prepay        IN      VARCHAR2 DEFAULT 'Y' --pnpl
,x_result_out		OUT NOCOPY VARCHAR2
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY VARCHAR2
,x_msg_data		OUT NOCOPY VARCHAR2
);

Procedure Print_Payment_Receipt(p_header_id in Number,
                                x_result_out out NOCOPY /* file.sql.39 change */ varchar2,
                                x_return_status out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE Update_Hdr_Payment(p_header_id in number,
                             p_action in varchar2 := NULL,
                             p_line_id in number := NULL,
                            x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2);

/*--------------------------------------------------------------------------
Procedure Create_Refund
This procedure calls AR Refund Wrapper API for multiple payments project.
----------------------------------------------------------------------------*/
PROCEDURE Create_Refund
(  p_header_rec        IN   OE_Order_PUB.Header_Rec_Type
,  p_refund_amount     IN   NUMBER
,  p_payment_set_id    IN   NUMBER
,  p_bank_account_id   IN   NUMBER
,  p_receipt_method_id IN   NUMBER
,  x_return_status     OUT  NOCOPY VARCHAR2
);

PROCEDURE Process_Payment_Refund
(  p_header_rec        IN   OE_Order_PUB.Header_Rec_Type
,  x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
,  x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

PROCEDURE Any_Payment_Hold_Exists
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_line_id         IN   NUMBER  DEFAULT NULL --pnpl
,  p_hold_exists     OUT  NOCOPY VARCHAR2  -- 'Y' or 'N'
);

PROCEDURE Update_Payment_Numbers(p_header_id in number,
                             p_line_id in number := NULL,
                            x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2);

PROCEDURE Delete_Payment_Hold
(p_line_id           	IN   NUMBER
,p_header_id		IN   NUMBER
,p_hold_type 		IN   VARCHAR2
,x_return_status      	OUT  NOCOPY VARCHAR2
,x_msg_count          	OUT  NOCOPY NUMBER
,x_msg_data           	OUT  NOCOPY VARCHAR2
);

--pnpl start
TYPE pay_now_total_rec IS RECORD
(line_id                  NUMBER(15) DEFAULT NULL
,pay_now_line_amount      NUMBER DEFAULT NULL
,pay_now_freight_amount   NUMBER DEFAULT NULL
,pay_now_tax_amount       NUMBER DEFAULT NULL
,pay_now_total            NUMBER DEFAULT NULL
,term_id       		  ra_terms.term_id%type DEFAULT NULL
,currency_code  	  fnd_currencies.currency_code%type DEFAULT NULL
);

TYPE pay_now_total_tbl IS TABLE of pay_now_total_rec
   INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------------------
-- New procedure Get_First_Installment added for Pay Now Pay Later project to fetch and calculate first installment amount from AR tables.
------------------------------------------------------------------------------------------
PROCEDURE Get_First_Installment
(p_currency_code                IN fnd_currencies.currency_code%TYPE
,p_x_due_now_total_detail_tbl  	IN OUT NOCOPY AR_VIEW_TERM_GRP.amounts_table
,x_due_now_total_summary_rec 	OUT NOCOPY AR_VIEW_TERM_GRP.summary_amounts_rec
,x_return_status   	        OUT NOCOPY VARCHAR2
,x_msg_count       		OUT NOCOPY NUMBER
,x_msg_data        		OUT NOCOPY VARCHAR2
);


----------------------------------------------------------------------------------------------------
-- New procedure to get pay now amounts for a sales order
----------------------------------------------------------------------------------------------------
PROCEDURE Get_Pay_Now_Amounts
(p_header_id 		IN NUMBER DEFAULT NULL
,p_line_id		IN NUMBER DEFAULT NULL
,p_exc_inv_lines        IN VARCHAR2 DEFAULT NULL
,x_pay_now_subtotal 	OUT NOCOPY NUMBER
,x_pay_now_tax   	OUT NOCOPY NUMBER
,x_pay_now_charges  	OUT NOCOPY NUMBER
,x_pay_now_total        OUT NOCOPY NUMBER
,x_pay_now_commitment   OUT NOCOPY NUMBER
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data		OUT NOCOPY VARCHAR2
,x_return_status        OUT NOCOPY VARCHAR2
);

--pnpl end

END OE_PrePayment_PVT ;


/
