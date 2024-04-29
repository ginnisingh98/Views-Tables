--------------------------------------------------------
--  DDL for Package OE_PREPAYMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PREPAYMENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPPYS.pls 120.3 2005/10/14 15:27:36 lkxu noship $ */

G_DO_PREPAYMENT		VARCHAR2(1) := NULL;
G_OM_H_INSTALLED	VARCHAR2(1) := NULL;

TYPE  Payment_Term_Rec_Type IS RECORD
(   payment_term_id         NUMBER          :=  FND_API.G_MISS_NUM
  , is_prepaid_order        VARCHAR2(1)     := NULL
);

TYPE Payment_Term_Tbl_Type IS TABLE OF Payment_Term_Rec_Type
    INDEX BY BINARY_INTEGER;

G_Payment_Term_Rec	Payment_Term_Rec_Type;
G_Payment_Term_Tbl	Payment_Term_Tbl_Type;

-- This procedure is used by the validation template PREPAY defined for processing constraints
PROCEDURE Is_Prepaid(p_application_id               IN NUMBER,
                     p_entity_short_name            in VARCHAR2,
                     p_validation_entity_short_name in VARCHAR2,
                     p_validation_tmplt_short_name  in VARCHAR2,
                     p_record_set_tmplt_short_name  in VARCHAR2,
                     p_scope                        in VARCHAR2,
p_result OUT NOCOPY NUMBER );


-- This procedure returns the prepayment attributes info given the header_id
PROCEDURE Get_PrePayment_Info
( p_header_id        IN   NUMBER
, x_payment_set_id OUT NOCOPY NUMBER

, x_prepaid_amount OUT NOCOPY NUMBER

);

-- This procedure is used by the  concurrent program Process Pending Payments
PROCEDURE PendProcessPayments_Conc_Prog
( errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER
  ,p_operating_unit		IN NUMBER --MOAC Changes
  ,p_ppp_hold                   IN  VARCHAR2
  ,p_epay_failure_hold          IN  VARCHAR2
  ,p_epay_server_failure_hold   IN  VARCHAR2
  ,p_payment_authorization_hold IN  VARCHAR2
  ,p_order_type_id              IN  NUMBER
  ,p_order_number_from          IN  NUMBER
  ,p_order_number_to            IN  NUMBER
  ,p_customer_number_from       IN  VARCHAR2
  ,p_customer_number_to         IN  VARCHAR2
  ,p_debug_level                IN  NUMBER
  ,p_customer_class_code        IN  VARCHAR2
  ,p_credit_card_number         IN  VARCHAR2
  ,p_credit_card_type           IN  VARCHAR2
  ,p_bill_to_org_id             IN  NUMBER
  ,p_booked_date_since          IN  VARCHAR2
);

/*-------------------------------------------------------------------
Function Is_Prepaid_Order
Returns 'Y' if the Order is being paid using a Credit Card AND
               the payment term is of prepayment type.
---------------------------------------------------------------------*/
FUNCTION Is_Prepaid_Order
(  p_header_rec  IN  OE_Order_PUB.Header_Rec_Type )
RETURN  VARCHAR2;

-- overloading the function so that it also takes header_id.
FUNCTION Is_Prepaid_Order
(  p_header_id  IN  NUMBER )
RETURN  VARCHAR2;

FUNCTION IS_MULTIPLE_PAYMENTS_ENABLED RETURN BOOLEAN;

FUNCTION Is_MultiPayments_Order
(  p_header_id  IN  NUMBER )
RETURN  VARCHAR2;

Procedure UPLOAD_COMMITMENT(
                             p_line_id in number,
                             p_action in varchar2,
                            x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2);

FUNCTION get_downpayment_amount( p_header_id in number,
                                  p_term_id in number := NULL,
                                  p_curr_code in varchar2 := NULL,
                                  p_order_total in number := NULL)
return number;

-- This procedure is used by the validation template TPREPAY defined for processing constraint used by PAYMENT_TERM
PROCEDURE Is_Prepaid_for_payment_term(p_application_id               IN NUMBER,
                     p_entity_short_name            in VARCHAR2,
                     p_validation_entity_short_name in VARCHAR2,
                     p_validation_tmplt_short_name  in VARCHAR2,
                     p_record_set_tmplt_short_name  in VARCHAR2,
                     p_scope                        in VARCHAR2,
                     p_result OUT NOCOPY NUMBER );

--pnpl start
FUNCTION Get_Installment_Options(p_org_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

FUNCTION Is_Pay_Now_Line (p_line_id IN NUMBER) RETURN BOOLEAN;
--pnpl end


END OE_Prepayment_UTIL;

 

/
