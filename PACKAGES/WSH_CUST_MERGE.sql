--------------------------------------------------------
--  DDL for Package WSH_CUST_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CUST_MERGE" AUTHID CURRENT_USER as
/* $Header: WSHCMRGS.pls 120.0.12000000.1 2007/01/16 05:42:50 appldev ship $ */

--
--
--  Procedure:		Merge
--  Description:	New code to merge customer and site information
--                      throughout WSH.  This is the main procedure for
--                      customer merge for WSH, which calls all other internal
--                      procedures for customer merge based on the functional
--                      areas.
--  Usage:		Called by TCA's Customer Merge.

PROCEDURE Merge(Req_Id IN NUMBER, Set_Num IN NUMBER, Process_Mode IN VARCHAR2 );

END WSH_CUST_MERGE;


 

/
