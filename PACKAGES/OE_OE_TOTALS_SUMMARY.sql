--------------------------------------------------------
--  DDL for Package OE_OE_TOTALS_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_TOTALS_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: OEXVTOTS.pls 120.0.12000000.1 2007/01/16 22:12:54 appldev ship $ */

G_TAX_VALUE            NUMBER :=0;
G_TOTAL_EXTENDED_PRICE NUMBER :=0;

/* Recurring totals */
G_REC_TAX_VALUE            NUMBER :=0;
G_REC_TOTAL_EXTENDED_PRICE NUMBER :=0;

TYPE rec_charges_rec_type IS RECORD
(
charge_periodicity_code            VARCHAR2(3),
charge_periodicity_desc            VARCHAR2(100),
charge_periodicity_meaning         VARCHAR2(100),
rec_subtotal                       NUMBER,
rec_tax                            NUMBER,
rec_charges                        NUMBER,
rec_total                          NUMBER
);

TYPE rec_charges_tbl_type IS TABLE OF rec_charges_rec_type
INDEX BY BINARY_INTEGER;

g_rec_charges_tbl_type    rec_charges_tbl_type;
/* Recurring totals */


--  Function : PRICE_ADJUSTMENTS

FUNCTION PRICE_ADJUSTMENTS
(
  p_header_id  IN NUMBER
)
RETURN NUMBER;


FUNCTION LINE_PRICE_ADJ_ORDER_MODIFIER
(
  x_header_id IN NUMBER,
  x_line_id  IN NUMBER,
  x_list_line_id  IN NUMBER
)
RETURN NUMBER;


FUNCTION LINE_EXT_ADJ_ORDER_MODIFIER
(
  x_header_id IN NUMBER,
  x_line_id  IN NUMBER,
  x_list_line_id  IN NUMBER
)
RETURN NUMBER;

FUNCTION LINE_PRICE_ADJUSTMENTS
(
  x_line_id  IN NUMBER
)
RETURN NUMBER;

FUNCTION CHARGES
(
 p_header_id  IN NUMBER
)
RETURN NUMBER;


FUNCTION LINE_CHARGES
(
 p_header_id  IN NUMBER ,
 p_line_id    IN NUMBER
)
RETURN NUMBER;

FUNCTION TAXES
(
 p_header_id  IN NUMBER
)
RETURN NUMBER;

FUNCTION ORDER_SUBTOTALS
(
 p_header_id  IN NUMBER
)
RETURN NUMBER;

FUNCTION LINE_TOTAL
(
  p_header_id  IN NUMBER    ,
  p_line_id    IN NUMBER   ,
  p_line_number   IN NUMBER,
  p_shipment_number   IN NUMBER default null
)
RETURN NUMBER;

/* bug - 1480491 */
FUNCTION SERVICE_TOTAL
(
  p_header_id  IN NUMBER    ,
  p_line_number   IN NUMBER,
  p_service_number   IN NUMBER
)
RETURN NUMBER;
/* bug - 1480491 */

PROCEDURE GLOBAL_TOTALS
(
 p_header_id    IN NUMBER
);

FUNCTION CONFIG_TOTALS
(
 p_line_id     IN NUMBER
)
RETURN NUMBER;

FUNCTION TOTAL_ORDERED_QTY
(
 p_header_id     IN NUMBER,
 p_line_number   IN NUMBER
)
RETURN NUMBER;

PROCEDURE ORDER_TOTALS
  (
  p_header_id     IN  NUMBER,
p_subtotal OUT NOCOPY NUMBER,

p_discount OUT NOCOPY NUMBER,

p_charges OUT NOCOPY NUMBER,

p_tax OUT NOCOPY NUMBER

  );

FUNCTION PRT_ORDER_TOTAL
( p_header_id		IN NUMBER)
RETURN NUMBER;

FUNCTION OUTBOUND_ORDER_TOTAL
(
 p_header_id     		IN NUMBER,
 p_to_exclude_commitment	IN VARCHAR2 DEFAULT NULL, -- bug 4013565
 p_total_type			IN VARCHAR2 DEFAULT NULL, -- bug 4013565
  p_all_lines                    IN VARCHAR2 DEFAULT NULL
)
RETURN NUMBER;

FUNCTION OUTBOUND_ORDER_SUBTOTAL
(
 p_header_id     		IN NUMBER
)
RETURN NUMBER;

Function Get_Order_Amount
(p_header_id In Number
)
Return Number;


-- This function is used to calculate the discount percentage for the line
-- items in a sales order. This uses the unit selling price and the unit
-- list price to calculate the discount
-- Input: unit_list_price, unit_selling_price   Output: discount percent
-- Called from: OE_PRN_ORDER_LINES_V view

FUNCTION GET_DISCOUNT(p_unit_list_price IN number,p_unit_selling_price IN NUMBER)
RETURN NUMBER;

/* Recurring totals */

PROCEDURE GLOBAL_REC_TOTALS
(
 p_header_id                  IN   NUMBER,
 p_charge_periodicity_code    IN   VARCHAR2
);

FUNCTION REC_TAXES
(
 p_header_id  IN NUMBER
)
RETURN NUMBER;

FUNCTION REC_ORDER_SUBTOTALS
(
 p_header_id  IN NUMBER
)
RETURN NUMBER;


FUNCTION REC_CHARGES
(
 p_header_id  IN NUMBER,
 p_charge_periodicity_code    IN   VARCHAR2
)
RETURN NUMBER;

FUNCTION REC_PRICE_ADJUSTMENTS
(
 p_header_id  IN NUMBER,
 p_charge_periodicity_code    IN   VARCHAR2
)
RETURN NUMBER;


PROCEDURE REC_ORDER_TOTALS
(
p_header_id     IN  NUMBER,
p_charge_periodicity_code IN VARCHAR2,
x_subtotal OUT NOCOPY NUMBER,
x_discount OUT NOCOPY NUMBER,
x_charges OUT NOCOPY NUMBER,
x_tax OUT NOCOPY NUMBER ,
x_total OUT NOCOPY NUMBER
  );

PROCEDURE GET_RECURRING_TOTALS
(
p_header_id       IN  NUMBER,
x_rec_charges_tbl  IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type);

PROCEDURE GET_UI_RECURRING_TOTALS
(
p_header_id       IN  NUMBER,
x_rec_charges_tbl  IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type);

PROCEDURE GET_MODEL_RECURRING_TOTALS
(
p_header_id       IN  NUMBER,
p_line_id         IN  NUMBER,
p_line_number     IN  NUMBER,
x_rec_charges_tbl  IN OUT NOCOPY OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type);

/* Recurring totals */

--rc pviprana start
/*Record structure to store the recurring amounts for an order level modifier in the View Adjustments window*/
TYPE recurring_amount_rec_type IS RECORD
   (
    charge_periodicity_code            VARCHAR2(3),
    charge_periodicity_meaning         VARCHAR2(25),
    recurring_amount                   NUMBER
    );

TYPE recurring_amounts_tbl_type IS TABLE OF recurring_amount_rec_type
   INDEX BY BINARY_INTEGER;

PROCEDURE SET_ADJ_RECURRING_AMOUNTS
        (p_header_id IN NUMBER DEFAULT NULL,
	 p_price_adjustment_id NUMBER DEFAULT NULL);

PROCEDURE GET_ADJ_RECURRING_AMOUNTS
	(x_recurring_amounts_tbl  IN OUT NOCOPY /* file.sql.39 change */ Recurring_Amounts_Tbl_Type);

--rc pviprana end
--rc preview/print
FUNCTION PRN_REC_SUBTOTALS
(
 p_header_id               IN      NUMBER,
 p_charge_periodicity_code IN      VARCHAR2
)
RETURN NUMBER;

FUNCTION PRN_REC_TAXES
(
 p_header_id               IN      NUMBER,
 p_charge_periodicity_code IN      VARCHAR2
)
RETURN NUMBER;

FUNCTION PRN_REC_TOTALS
(
 p_header_id               IN      NUMBER,
 p_charge_periodicity_code IN      VARCHAR2
)
RETURN NUMBER;

END OE_OE_TOTALS_SUMMARY;

 

/
