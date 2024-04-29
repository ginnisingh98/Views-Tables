--------------------------------------------------------
--  DDL for Package Body OE_RMA_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RMA_TOTAL" as
/* $Header: oexrtotb.pls 115.0 99/07/16 08:30:11 porting ship $ */


  /*
  ** Used by running total API
  */
  PROCEDURE SELECT_SUMMARY (
			P_HEADER_ID 	IN OUT	NUMBER,
			P_TOTAL		IN OUT  NUMBER,
			P_TOTAL_RTOT_DB IN OUT  NUMBER ) IS

  BEGIN

    SELECT NVL(SUM(L.SELLING_PRICE *
	           (NVL(ORDERED_QUANTITY, 0)
                     - NVL(L.CANCELLED_QUANTITY,0))), 0)
    INTO   P_TOTAL
    FROM   SO_LINES L
    WHERE  L.HEADER_ID = P_HEADER_ID;

    P_TOTAL_RTOT_DB := P_TOTAL;


  END;

END OE_RMA_TOTAL;

/
