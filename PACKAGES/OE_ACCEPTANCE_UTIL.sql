--------------------------------------------------------
--  DDL for Package OE_ACCEPTANCE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ACCEPTANCE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUACCS.pls 120.4.12010000.2 2009/04/15 12:56:52 srsunkar ship $ */

--Table of records to capture changed lines so that contingencies can be defaulted for all these lines at the time of saving
--extending the record structure for batch_source_id, cust_trx_type_id, invoice_to_customer so that we can bulk insert into AR temp table
TYPE line_index_Rec IS RECORD
(   line_id         NUMBER
  , line_index      NUMBER
);

TYPE line_index_Tbl       IS TABLE OF line_index_Rec INDEX BY BINARY_INTEGER;

TYPE NUMBER_TYPE          IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE VARCHAR1_TYPE        IS TABLE OF VARCHAR(1)     INDEX BY BINARY_INTEGER;

G_line_index_Rec          line_index_Rec;
G_line_index_Tbl          line_index_Tbl;
G_line_id_tbl             number_type;
G_header_id_tbl           number_type;
G_line_type_id_tbl        number_type;
G_sold_to_org_id_tbl      number_type;
G_invoice_to_org_id_tbl   number_type;
G_inventory_item_id_tbl   number_type;
G_org_id_tbl              number_type;
G_batch_source_id_tbl     number_type;
G_cust_trx_type_id_tbl    number_type;
G_invoice_to_customer_tbl number_type;
G_invoice_to_site_tbl     number_type;
G_shippable_flag_tbl      varchar1_type;
G_accounting_rule_id_tbl     number_type;
--For Bug#8262992
G_ship_to_org_id_tbl       number_type;
G_ship_to_customer_tbl     number_type;
G_ship_to_site_tbl         number_type;

--This procedure will register all the changed lines
PROCEDURE Register_Changed_Lines(
  p_line_id           IN  NUMBER
, p_header_id         IN  NUMBER
, p_line_type_id      IN  NUMBER
, p_sold_to_org_id    IN  NUMBER
, p_invoice_to_org_id IN  NUMBER
, p_inventory_item_id IN  NUMBER
, p_shippable_flag    IN  VARCHAR2
, p_org_id            IN  NUMBER
, p_accounting_rule_id IN NUMBER
, p_operation         IN  VARCHAR2
, p_ship_to_org_id      IN NUMBER  DEFAULT NULL --For bug#8262992
);

--This procedure will delete the changed lines table once the lines are processed
PROCEDURE Delete_Changed_Lines_Tbl;

--Function returns batch_source_ID and name for the given batch_source_name.
FUNCTION Get_batch_source_ID (p_batch_source_name VARCHAR2) RETURN NUMBER;

--This procedure is called to default acceptance attributes for standard lines, PTO, ATO models.
--Acceptance attributes are not defaulted for internal order lines, retrobill lines, return lines,
--child lines( under ATO, PTO), and service lines.
PROCEDURE Default_Contingency_Attributes;

--This procedure is called to default acceptance details for service line if the parent is already accepted
PROCEDURE Default_Parent_Accept_Details
( p_line_rec IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type);

--This procedure is called to get contingency attributes of a given line.
PROCEDURE Get_Contingency_attributes
(p_line_rec                 IN OE_ORDER_PUB.Line_Rec_Type
,X_contingency_id           OUT NOCOPY NUMBER
,X_revrec_event_code        OUT NOCOPY VARCHAR2
,X_revrec_expiration_days   OUT NOCOPY NUMBER);

--Function returns TRUE if pre-billing acceptance is enabled for the given line.
Function Pre_billing_acceptance_on (p_line_rec IN OE_Order_PUB.Line_Rec_Type) RETURN BOOLEAN;

-- Over Loaded
Function Pre_billing_acceptance_on (p_line_id IN NUMBER) RETURN BOOLEAN;

--Function returns TRUE if post-billing acceptance is enabled for the given line.
Function Post_billing_acceptance_on (p_line_rec IN OE_Order_PUB.Line_Rec_Type) RETURN BOOLEAN;

-- Over Loaded
Function Post_billing_acceptance_on (p_line_id IN NUMBER) RETURN BOOLEAN;

--This function checks if acceptance is allowed for the given line.
Function Customer_acceptance_eligible (p_line_rec IN OE_Order_PUB.Line_Rec_Type) RETURN BOOLEAN;

-- Over Loaded
Function Customer_acceptance_eligible (p_line_id IN NUMBER) RETURN BOOLEAN;

--Function returns 'ACCEPTED'/'REJECTED'/'NOT_ACCEPTED'
Function Acceptance_status(p_line_rec IN OE_Order_PUB.Line_Rec_Type) RETURN VARCHAR2;

-- Over Loaded
Function Acceptance_Status(p_line_id IN NUMBER) RETURN VARCHAR2;

END OE_ACCEPTANCE_UTIL;

/
