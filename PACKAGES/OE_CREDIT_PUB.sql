--------------------------------------------------------
--  DDL for Package OE_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPCRCS.pls 120.0.12010000.1 2008/07/25 07:52:34 appldev ship $ */

-- Mainline Function that will read an Order Header and Determine if should be checked,
-- Consumes available Credit and applies a credit hold if Appropriate

PROCEDURE Check_Available_Credit
(   p_header_id			IN 	NUMBER		:= FND_API.G_MISS_NUM
,   p_calling_action		IN	VARCHAR2	:= 'BOOKING'
,   p_msg_count			OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_msg_data			OUT NOCOPY /* file.sql.39 change */   	VARCHAR2
,   p_result_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2    -- Pass or Fail Credit Check
,   p_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

-- Function to Determine if the Order is Subject to Credit Check

PROCEDURE Check_Order
(   p_header_rec		IN  	OE_Order_PUB.Header_Rec_Type
,   p_calling_action		IN    	VARCHAR2	:= 'BOOKING'
,   p_check_order_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_credit_rule_out		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_credit_check_lvl_out	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_overall_credit_limit	OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_trx_credit_limit		OUT NOCOPY /* file.sql.39 change */   	NUMBER
,   p_return_status		OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);

-- Function to Determine Credit Exposure

PROCEDURE Check_Exposure
(   p_header_rec		IN  	OE_Order_PUB.Header_Rec_Type
,   p_credit_check_rule_id	IN    	NUMBER	:= FND_API.G_MISS_NUM
,   p_credit_level              IN      VARCHAR2
,   p_total_exposure		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_return_status		OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);

-- bug 1830389, new procedures introduced for line level Credit Checking.
PROCEDURE Check_Available_Credit_Line
(   p_header_id		IN 	NUMBER	:= FND_API.G_MISS_NUM
,   p_invoice_to_org_id  IN   NUMBER    := FND_API.G_MISS_NUM
,   p_calling_action	IN	VARCHAR2	:= 'BOOKING'
,   p_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_msg_data			OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
,   p_result_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2   -- Pass or Fail Credit Check
,   p_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

-- Function to Determine if the Order is Subject to Credit Check

PROCEDURE Check_Order_Line
(   p_header_rec	          IN  	OE_Order_PUB.Header_Rec_Type
,   p_invoice_to_org_id       IN   NUMBER
,   p_customer_id             IN NUMBER
,   p_calling_action		IN  	VARCHAR2	:= 'BOOKING'
,   p_check_order_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_credit_rule_out		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_credit_check_lvl_out	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_overall_credit_limit	OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_trx_credit_limit		OUT NOCOPY /* file.sql.39 change */ 	NUMBER
,   p_return_status		     OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);

-- Function to Determine Credit Exposure

PROCEDURE Check_Exposure_Line
(   p_header_rec             IN  OE_Order_PUB.Header_Rec_Type
,   p_invoice_to_org_id      IN   NUMBER
,   p_customer_id            IN  NUMBER
,   p_credit_check_rule_id   IN  NUMBER
,   p_credit_level           IN  VARCHAR2
,   p_total_exposure         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   p_return_status		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

END OE_Credit_PUB;

/
