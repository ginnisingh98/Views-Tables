--------------------------------------------------------
--  DDL for Package CHV_CUM_PERIODS_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_CUM_PERIODS_S1" AUTHID CURRENT_USER as
/* $Header: CHVPRCQS.pls 115.1 2002/11/23 04:10:23 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:		CHV_CUM_PERIODS_S1

  DESCRIPTION:		Holds procedures for dynamic cum calc.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		NONE

  OWNER:		KPOWELL

  PROCEDURES/FUNCTIONS:


===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:
  PARAMETERS:
  DESIGN REFERENCES:
  ALGORITHM:
  NOTES:
  OPEN ISSUES:
  CLOSED ISSUES:
  CHANGE HISTORY:
===========================================================================*/
PROCEDURE test_get_cum_qty_received;

PROCEDURE get_cum_qty_received (X_vendor_id IN NUMBER,
                                X_vendor_site_id IN NUMBER,
                                X_item_id IN NUMBER,
                                X_organization_id IN NUMBER,
                                X_rtv_transactions_included IN VARCHAR2,
                                X_cum_period_start IN DATE,
                                X_cum_period_end IN DATE,
                                X_purchasing_unit_of_measure IN VARCHAR2,
                                X_qty_received_primary IN OUT NOCOPY NUMBER,
                                X_qty_received_purchasing IN OUT NOCOPY NUMBER);
END CHV_CUM_PERIODS_S1;

 

/
