--------------------------------------------------------
--  DDL for Package OE_RMA_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RMA_TOTAL" AUTHID CURRENT_USER as
/* $Header: oexrtots.pls 115.0 99/07/16 08:30:14 porting ship $ */

  PROCEDURE SELECT_SUMMARY (
			P_HEADER_ID 	IN OUT	NUMBER,
			P_TOTAL		IN OUT  NUMBER,
			P_TOTAL_RTOT_DB IN OUT  NUMBER
			);

END OE_RMA_TOTAL;

 

/
