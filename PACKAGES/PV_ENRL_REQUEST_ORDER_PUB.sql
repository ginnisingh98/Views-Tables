--------------------------------------------------------
--  DDL for Package PV_ENRL_REQUEST_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENRL_REQUEST_ORDER_PUB" AUTHID CURRENT_USER AS
/* $Header: pvxperos.pls 115.3 2003/08/27 00:47:48 speddu ship $ */

--  Start of Comments
--  API name    PV_ENRL_REQUEST_ORDER_PUB
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


FUNCTION get_Invoice_Balance
( p_order_header_id IN NUMBER
) RETURN NUMBER;


FUNCTION Get_payment_type
(  p_order_header_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE get_invoice_balance(
     p_order_header_id  IN  NUMBER
    ,x_invoice_balance   OUT NOCOPY NUMBER
    ,x_invoice_currency OUT NOCOPY VARCHAR2
);


PROCEDURE get_invoice_details(
     p_order_line_id  IN  VARCHAR2
    ,x_invoice_balance   OUT NOCOPY NUMBER
    ,x_invoice_currency OUT NOCOPY VARCHAR2
    ,x_invoice_number OUT NOCOPY VARCHAR2
);


END PV_ENRL_REQUEST_ORDER_PUB;

 

/
