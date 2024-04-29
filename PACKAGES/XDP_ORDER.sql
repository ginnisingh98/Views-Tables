--------------------------------------------------------
--  DDL for Package XDP_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ORDER" AUTHID CURRENT_USER  AS
/* $Header: XDPORDRS.pls 120.1 2005/06/09 00:23:58 appldev  $ */
-- PL/SQL Specification
-- Datastructure Definitions
-- Global variable
G_external_order_reference  VARCHAR2(70); -- will hold order number and version
 -- API specifications
 /* API for upstream ordering system to submit a service activation order */
 PROCEDURE Process_Order(
 	P_ORDER_HEADER 		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
 	P_ORDER_LINE_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
	P_ORDER_ID		   OUT NOCOPY NUMBER,
 	RETURN_CODE 		   OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	   OUT NOCOPY VARCHAR2);
END XDP_ORDER;

 

/
