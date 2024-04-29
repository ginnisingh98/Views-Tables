--------------------------------------------------------
--  DDL for Package XDP_ORDER_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ORDER_SYNC" AUTHID CURRENT_USER AS
/* $Header: XDPSORDS.pls 120.1 2005/06/09 00:31:32 appldev  $ */

PROCEDURE Execute_Order_SYNC(
 	P_Order_ID 	IN  NUMBER,
	x_return_code	OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2);


End XDP_ORDER_SYNC;

 

/
