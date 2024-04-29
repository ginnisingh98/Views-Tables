--------------------------------------------------------
--  DDL for Package CST_DIAGNOSTICS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_DIAGNOSTICS_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTDIAGS.pls 120.0.12000000.1 2007/07/11 13:42:22 rrshah noship $ */

 /*---------------------------------------------------------------------------
|  FUNCTION     :   TEMP_PO_TAX
|  DESCRIPTION  :   Calculates po tax
----------------------------------------------------------------------------*/
FUNCTION TEMP_PO_TAX(i_txn_id in  number) RETURN NUMBER;

/*---------------------------------------------------------------------------
|  PROCEDURE    :   TEMP_PO_RATE
|  DESCRIPTION  :   Calculates po_rate.
----------------------------------------------------------------------------*/

FUNCTION TEMP_PO_RATE(i_txn_id in  number) RETURN NUMBER;

/*---------------------------------------------------------------------------
|  PROCEDURE    :   Check_Orphaned
|  DESCRIPTION  :   Checks the orphaned transactions for a WIP flow schedule
|                   Completion transaction.
----------------------------------------------------------------------------*/
PROCEDURE  Check_Orphaned (
TXN_ID         IN NUMBER,
L_ORG_ID       IN NUMBER);

/*---------------------------------------------------------------------------
|  PROCEDURE    :   Get_Stuck_Txn_Info
|  DESCRIPTION  :   Checks for the bottle neck transactions for Actual costing
|                   Organizations.
----------------------------------------------------------------------------*/
PROCEDURE   Get_Stuck_Txn_Info;

/*---------------------------------------------------------------------------
|  FUNCTION     :   Cost_Cutoff_Date
|  DESCRIPTION  :   Checks for the Cost Cut-Off date for the organizations
|                   for customers on and above release 11.5.7.
---------------------------------------------------------------------------*/

FUNCTION Cost_Cutoff_Date( P_ORG_ID IN NUMBER) RETURN DATE;

/*---------------------------------------------------------------------------
|  PROCEDURE    :   Check_Transactions_MMT
|  DESCRIPTION  :   Spools the transactions of MMT and checks for
|                   the reason why costing is stuck for the transactions.
---------------------------------------------------------------------------*/
PROCEDURE Check_Transactions_MMT
( ORGANIZATION_ID       NUMBER);

END cst_diagnostics_pkg;

 

/
