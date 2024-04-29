--------------------------------------------------------
--  DDL for Package OE_RMA_QUERY_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RMA_QUERY_PRICE" AUTHID CURRENT_USER as
/* $Header: oexrlqps.pls 115.0 99/07/16 08:29:26 porting ship $ */

  FUNCTION GET_PRICE_ADJUSTMENTS_TOTAL(
	P_HEADER_ID         IN	NUMBER,
	P_LINE_ID	    IN	NUMBER,
        P_REF_ORD_HEADER_ID IN  NUMBER DEFAULT NULL
	)
	RETURN NUMBER;

  PROCEDURE GET_PRICE_INFO (
	P_LINE_ID		IN	NUMBER,
	P_PRICE_LIST_ID		OUT	NUMBER,
	P_TERMS_ID		OUT 	NUMBER,
	P_ROUNDING_FACTOR	OUT	NUMBER
	);

  PROCEDURE GET_PRICING(
		L_PRICING_CONTEXT		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE1		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE2		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE3		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE4		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE5		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE6		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE7		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE8		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE9		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE10		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE11		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE12		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE13		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE14		OUT 	VARCHAR2,
		L_PRICING_ATTRIBUTE15		OUT 	VARCHAR2,
		L_LINK_TO_LINE_ID		IN	NUMBER
		);

END OE_RMA_QUERY_PRICE;

 

/