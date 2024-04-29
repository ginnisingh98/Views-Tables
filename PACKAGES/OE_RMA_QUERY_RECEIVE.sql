--------------------------------------------------------
--  DDL for Package OE_RMA_QUERY_RECEIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RMA_QUERY_RECEIVE" AUTHID CURRENT_USER as
/* $Header: oexrlqrs.pls 115.0 99/07/16 08:29:31 porting ship $ */

  PROCEDURE VALIDATE_WAREHOUSE (
	P_WAREHOUSE_ID		IN OUT	NUMBER,
	P_INVENTORY_ITEM_ID	IN	NUMBER
	);

END OE_RMA_QUERY_RECEIVE;

 

/
