--------------------------------------------------------
--  DDL for Package GMS_BUDGET_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BUDGET_BALANCE" AUTHID CURRENT_USER AS
-- $Header: gmsfcups.pls 115.7 2003/01/02 15:56:56 rshaik ship $
-- Everest Funds Checker Main Routine

 Procedure update_gms_balance(x_project_id	IN  number,
   			    x_award_id		IN  number,
				x_mode          IN  varchar2,
			    ERRBUF	  	OUT NOCOPY varchar2,
		   	    RETCODE	  	OUT NOCOPY varchar2);

  --Bug 2721095 : The following function is introduced to calculate PO's quantity billed
  --              based on input parameters.

  FUNCTION get_po_qty_invoiced (p_po_distribution_id IN NUMBER,
                                p_po_quantity_billed NUMBER,
                                p_recalc VARCHAR2 ) RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (get_po_qty_invoiced, WNDS);

END gms_budget_balance;

 

/
