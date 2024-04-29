--------------------------------------------------------
--  DDL for Package OE_VERIFY_PAYMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VERIFY_PAYMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPVPMS.pls 120.6.12010000.2 2008/10/17 11:30:13 cpati ship $ */

-- Called By Booking, Pre Ship or Purchase Release Processing.
-- Also called by the Delayed requests logged due to Order or
-- Line level attribute changes.
--
--  Checks if Electronic Payment is associated to the Order.
--  IF Yes THEN
--    Calls OE_Verify_Payment_PUB.Payment_Request Authorization
--  ELSE
--    Calls OE_Credit_PUB.OE_Check_Available_Credit for Credit
--	 Limit Checking

G_credit_check_rule    VARCHAR(50);   --ER#7479609
G_init_calling_action    VARCHAR(50);   --ER#7479609

PROCEDURE Verify_Payment
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_calling_action  IN   VARCHAR2 DEFAULT NULL -- BOOKING or SHIPPING or NULL
,  p_delayed_request IN   VARCHAR2 DEFAULT NULL -- Identifies if this call is from a delayed request
--R12 CVV2
--comm rej,  p_reject_on_auth_failure IN VARCHAR2 DEFAULT NULL
--comm rej,  p_reject_on_risk_failure IN VARCHAR2 DEFAULT NULL
,  p_risk_eval_flag  IN VARCHAR2 DEFAULT NULL --'Y' bug	6805953
--R12 CVV2
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

-- Function to find out Rule to be applied for Verify Payment

FUNCTION Which_Rule
(  p_header_id  IN  NUMBER)
RETURN VARCHAR2 ;

-- Function returns 'Y' if the rule identified by calling action
-- has been defined at the Order Type setup else returns 'N'.

FUNCTION Check_Rule_Defined
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_calling_action  IN   VARCHAR2 )
RETURN 	VARCHAR2 ;

-- Returns 'Y' if the Order is being paid using a Credit Card

FUNCTION Is_Electronic_Payment
(  p_header_rec  IN  OE_Order_PUB.Header_Rec_Type )
RETURN 	VARCHAR2 ;

-- Returns 'Y' if there is specific Credit Card Hold applied on the order.

PROCEDURE Hold_Exists
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_hold_id         IN   NUMBER    -- Seeded Id of Hold to be applied
,  p_hold_exists     OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- 'Y' or 'N'
);

-- Releases Verification Holds on the Order. Flag electronic
-- payment hold identifies the type of hold to release.

PROCEDURE Release_Verify_Hold
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_epayment_hold   IN   VARCHAR2  -- Pass 'Y' if E Payment Holds to remove
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

-- Applies a Credit Checking, CC Auth Failure Hold OR CC Risk
-- Hold based on the Hold Id Passed as Input Parameter.

PROCEDURE Apply_Verify_Hold
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_hold_id         IN   NUMBER    -- Seeded Id of Hold to be applied
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

-- Main Procedure called for all Electronic Payment Processing.

PROCEDURE Payment_Request
(  p_header_rec        IN   OE_Order_PUB.Header_Rec_Type  -- Order Header Record
,  p_trxn_type         IN   VARCHAR2  -- E Payment Transaction Type
,  p_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_result_out        OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- PASS, FAIL, RISK
,  p_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

-- Returns 'Y' if iPayment is Installed else returns 'N'.

FUNCTION Check_Ipayment_Installed
RETURN VARCHAR2;

-- Authorizes a Credit Card Payment Request for an Order.

PROCEDURE Authorize_Payment
(  p_header_rec        IN   OE_Order_PUB.Header_Rec_Type -- Header Record Type
,  p_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_result_out        OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- PASS, FAIL, RISK
,  p_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

-- Returns
-- 1. Last Authorization Transactions Associated to the Order
-- 2. Authorization Transaction currently associated to the Order
-- 3. The Order Total of Outbound Lines
-- 4. Flag to indicate if Reauthorization is required or Not
-- 5. Flag to indicate if the Current Transaction is Automatic or Manual

PROCEDURE Check_Reauthorize_Order
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type  -- Order Header Record
,  p_void_trxn_id    OUT NOCOPY /* file.sql.39 change */  NUMBER    -- ID of Trxn to be voided
,  p_outbound_total  OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Total of outbound lines in the order
,  p_reauthorize_out OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Reauthorize or not 'Y', 'N'
);

-- Returns FALSE if one of the Attributes required for Auhtorization is missing

FUNCTION Validate_Required_Attributes
(  p_header_rec  IN  OE_Order_Pub.Header_Rec_Type ) -- Order Header Record
RETURN BOOLEAN;

-- Returns Primary Payment Method for the Customer

FUNCTION Get_Primary_Pay_Method
(  p_header_rec  IN  OE_Order_PUB.Header_Rec_Type -- Header Record Type
) RETURN NUMBER;

-- Returns Payment Method Details for a given Receipt Method Id

PROCEDURE Get_Pay_Method_Info
(  p_pay_method_id   IN   NUMBER   -- Method ID
,  p_pay_method_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2 -- Method Name
,  p_merchant_id     OUT NOCOPY /* file.sql.39 change */  NUMBER   -- Merchant ID associated to Method
);

-- Voids an uncaptured authorization transaction.

PROCEDURE Void_Payment
(  p_void_trxn_id      IN   NUMBER    -- Id of Transaction to be voided
,  p_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
,  p_void_supported    OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Void Supported ('Y') or Not ('N')
);

-- Returns 'Y' if Authorization Trxn has already been captured else returns 'N'

FUNCTION Check_Trxn_Captured
(  p_trxn_id    IN  NUMBER)
RETURN VARCHAR2 ;

-- Returns 'Y' if this authorization was taken through iPayment else 'N'.

PROCEDURE Fetch_Authorization_Trxn
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type -- Order Header Record
,  p_trxn_id         OUT NOCOPY /* file.sql.39 change */  NUMBER     -- iPayment Transaction ID
,  p_automatic_auth  OUT NOCOPY /* file.sql.39 change */  VARCHAR2   -- 'Y' or 'N'
);

-- Fetches the Current Authorization Transaction for the Order

PROCEDURE Fetch_Current_Auth
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type -- Order Header Record
,  p_line_id         IN NUMBER DEFAULT NULL
,  p_auth_code       IN VARCHAR2 DEFAULT NULL
,  p_auth_date       IN DATE DEFAULT NULL
,  p_trxn_id         OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Transaction ID
,  p_tangible_id     OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Unique Tangible ID
);

-- Fetches the Last Authorization Transaction for the Order

PROCEDURE Fetch_Last_Auth
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type -- Order Header Record
,  p_trxn_id         OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Transaction ID
,  p_tangible_id     OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Unique Tangible ID
,  p_auth_code       OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- CC Approval Code
,  p_trxn_date       OUT NOCOPY /* file.sql.39 change */  DATE      -- CC Approval Date
,  p_amount          OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Authorized Amount
);


-- Updates Order Header with Authorized Amount, Authorization Code and Date

PROCEDURE Update_Authorization_Info
(  p_header_id        IN   NUMBER    -- Order Header ID
,  p_auth_amount      IN   NUMBER    -- Authorized Amount
,  p_auth_code        IN   VARCHAR2  -- Authorization Code
,  p_auth_date        IN   DATE      -- Authorization Date
,  p_msg_count        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_msg_data	      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_return_status    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

-- Function to find out Total Amount Captured for the Order

FUNCTION Captured_Amount_Total
(  p_header_id  IN  NUMBER)
RETURN NUMBER ;

PROCEDURE Authorize_MultiPayments
(  p_header_rec          IN   OE_Order_PUB.Header_Rec_Type  -- Order Header Record
,  p_line_id             IN   NUMBER DEFAULT null --bug3524209
,  p_calling_action      IN   VARCHAR2
--comm rej,   p_reject_on_auth_failure IN VARCHAR2 DEFAULT NULL --R12 CC Encryption
--comm rej,   p_reject_on_risk_failure IN VARCHAR2 DEFAULT NULL
,   p_risk_eval_flag	     IN VARCHAR2 DEFAULT NULL --bug 6805953 'Y'
,  p_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_result_out          OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- PASS, FAIL, RISK
,  p_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

PROCEDURE Release_Verify_Line_Hold
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_line_id         IN   NUMBER    -- Unique Order Line Id
,  p_epayment_hold   IN   VARCHAR2  -- Pass 'Y' if E Payment Holds to remove
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

-- Applies a Credit Checking, CC Auth Failure Hold OR CC Risk
-- Hold based on the Hold Id Passed as Input Parameter.

PROCEDURE Apply_Verify_Line_Hold
(  p_header_id       IN   NUMBER    -- Unique Order Header Id
,  p_line_id         IN   NUMBER    -- Unique Order Line Id
,  p_hold_id         IN   NUMBER    -- Seeded Id of Hold to be applied
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER    -- Message Count
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Messages
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2  -- Success or Failure
);

--Added this function for the bug 3571485
FUNCTION Get_Format_Mask(p_currency_code IN VARCHAR2)
RETURN  VARCHAR2;

--pnpl start
--Moved the declaration of these two functions to the spec.
FUNCTION Get_Line_Total
( p_line_id		  IN 	NUMBER
, p_header_id		  IN	NUMBER
, p_currency_code	  IN	VARCHAR2
, p_level		  IN	VARCHAR2
, p_amount_type           IN    VARCHAR2 DEFAULT NULL --pnpl
, p_to_exclude_commitment IN    VARCHAR2 DEFAULT 'Y' --bug3225795
) RETURN NUMBER;

--This function also needs to be modified later to consider partial invoicing
FUNCTION Outbound_Order_Total
( p_header_id             IN NUMBER
, p_to_exclude_commitment IN VARCHAR2 DEFAULT 'Y'
, p_total_type            IN VARCHAR2 DEFAULT NULL --pnpl
) RETURN NUMBER;
--pnpl end

PROCEDURE Create_New_Payment_Trxn
(  p_trxn_extension_id          IN      NUMBER
,  p_org_id                     IN      NUMBER
,  p_site_use_id                IN      NUMBER
,  p_line_id			IN      NUMBER DEFAULT NULL
,  p_instrument_security_code   IN      VARCHAR2 DEFAULT NULL --bug 5028932
,  x_trxn_extension_id          OUT     NOCOPY NUMBER
,  x_msg_count                  OUT     NOCOPY  NUMBER
,  x_msg_data                   OUT     NOCOPY  VARCHAR2
,  x_return_status              OUT     NOCOPY  VARCHAR2
);


END OE_Verify_Payment_PUB;

/
