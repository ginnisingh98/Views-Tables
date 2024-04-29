--------------------------------------------------------
--  DDL for Package XDP_DRC_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_DRC_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: XDPDRCPS.pls 120.1 2005/06/15 22:54:01 appldev  $ */


 PROCEDURE Process_DRC_Order(
 	P_WORKITEM_ID 		IN  NUMBER,
 	P_TASK_PARAMETER 	IN XDP_TYPES.ORDER_PARAMETER_LIST,
	x_SDP_ORDER_ID		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2);

END XDP_DRC_UTIL_PVT;

 

/
