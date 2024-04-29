--------------------------------------------------------
--  DDL for Package OE_TOTALS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_TOTALS_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXGTOTS.pls 120.0 2005/05/31 23:49:14 appldev noship $ */


--  Start of Comments
--  API name    Get_Order_Total
--  Type        Group
--  Function: The API to return Order/Line totals for (Line amount/Tax /Charges)
--  For Order level total, the Header_id should be passed in and Line_id
--  should be null. For line level totals, both should be passed in with values.
--
--  Pre-reqs
--
--  Parameters
--              p_header_id                     IN  NUMBER
--              p_line_id                       IN  NUMBER
--              p_total_type                    IN  NUMBER possible values are
--                                      ('ALL','LINES','CHARGES','TAXES')
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
FUNCTION Get_Order_Total
(   p_header_id                     IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_total_type                    IN  VARCHAR2 := 'ALL'
) RETURN NUMBER;

FUNCTION Get_Rec_Order_Total
(   p_header_id                     IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_charge_periodicity_code       IN  VARCHAR2
,   p_total_type                    IN  VARCHAR2 := 'ALL'
) RETURN NUMBER;

PROCEDURE GET_RECURRING_TOTALS
(
p_header_id       IN  NUMBER,
x_rec_charges_tbl  IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type);

--Pay Now Pay Later project
--group API which returns the pay now portion of an order or an order line. The pay now portion is broken up into subtotal, tax, charges and pay now total.
FUNCTION Get_PayNow_Total
( p_header_id    IN  NUMBER
, p_line_id      IN  NUMBER
, p_total_type   IN  VARCHAR2 := NULL
) RETURN NUMBER;


END OE_Totals_GRP;

 

/
