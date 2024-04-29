--------------------------------------------------------
--  DDL for Package AR_AI_INTEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_AI_INTEG_PKG" AUTHID CURRENT_USER AS
/*$Header: ARXINTEGS.pls 120.2.12010000.2 2009/02/05 08:12:32 rsamanta noship $*/
PROCEDURE DEFAULT_ATTRIBUTES (  p_org_id IN NUMBER,
                                p_bill_to_customer_account_id IN NUMBER,
                                p_ship_to_customer_account_id IN NUMBER,
                                p_currency_code IN VARCHAR2,
                                x_bill_to_address_id OUT NOCOPY VARCHAR2,
                                x_ship_to_address_id OUT NOCOPY VARCHAR2,
                                x_payment_term_id OUT NOCOPY NUMBER,
                                x_conversion_type OUT NOCOPY VARCHAR2,
                                x_conversion_date OUT NOCOPY DATE,
                                x_conversion_rate OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data OUT NOCOPY    VARCHAR2);

END;



/
