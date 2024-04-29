--------------------------------------------------------
--  DDL for Package OE_COMMITMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_COMMITMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCMTS.pls 115.11 2004/05/27 17:08:13 jisingh ship $ */

G_Do_commitment_Sequencing	NUMBER := FND_API.G_MISS_NUM;

procedure evaluate_commitment(
   p_commitment_id	IN NUMBER
  ,p_header_id		IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

  ,p_unit_selling_price	In   Number default 0
 );

FUNCTION Get_Allocate_Tax_Freight
(  p_line_rec 		IN	OE_ORDER_PUB.line_rec_type
) RETURN VARCHAR2;

FUNCTION Get_Line_Total
(  p_line_rec 		IN	OE_ORDER_PUB.line_rec_type
) RETURN NUMBER;

--bug 3560198
procedure calculate_commitment(
  p_request_rec         IN OE_Order_PUB.request_rec_type
, x_return_status OUT NOCOPY VARCHAR2

);

procedure update_commitment(
  p_line_id		IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

FUNCTION get_commitment_applied_amount(
 p_header_id		IN NUMBER
,p_line_id		IN NUMBER
,p_commitment_id        IN NUMBER
) RETURN NUMBER;

FUNCTION Do_Commitment_Sequencing RETURN BOOLEAN;

procedure update_commitment_applied(
  p_line_id		IN NUMBER
, p_amount		IN NUMBER
, p_header_id		IN NUMBER
, p_commitment_id	IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

END OE_commitment_pvt;

 

/
