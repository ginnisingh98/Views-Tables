--------------------------------------------------------
--  DDL for Package GMF_INTERNAL_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_INTERNAL_ORDERS" AUTHID CURRENT_USER AS
/* $Header: GMFINORS.pls 115.1 2003/10/13 17:39:57 sschinch noship $ */

	FUNCTION  GET_INTERNAL_ORDER_STS(preq_line_id NUMBER,
    				    	 pentry_type VARCHAR2) RETURN VARCHAR2;

   	PROCEDURE GET_TRANSFER_PRICE(	p_ship_ou_id		IN NUMBER
   					,p_recv_ou_id		IN NUMBER
   					,p_trans_um		IN VARCHAR2
   					,p_inv_item_id		IN NUMBER
   					,p_trans_id		IN NUMBER
   					,p_currency_code	IN VARCHAR2
   					,p_trans_date		IN DATE
					,p_inv_org_id		IN NUMBER
      					,x_return_status 	OUT NOCOPY VARCHAR2
   					,x_transfer_price 	OUT NOCOPY NUMBER);


END GMF_INTERNAL_ORDERS;

 

/
