--------------------------------------------------------
--  DDL for Package IGC_LEDGER_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_LEDGER_UTILS" AUTHID CURRENT_USER AS
/* $Header: IGCLUTLS.pls 120.2.12000000.1 2007/10/25 09:20:06 mbremkum noship $ */

/* To check Dual budgetary is enabled for Contract Commitments
*/
FUNCTION is_cc_dual_bc_enabled
                (p_ledger_id  NUMBER) RETURN VARCHAR2;

/*To check Dual budgetary is enabled for Purchase Order
*/
FUNCTION is_po_dual_bc_enabled
                (p_ledger_id  NUMBER) RETURN VARCHAR2;

-- To check Dual budgetary is enabled for either PO or CC
FUNCTION is_dual_bc_enabled
                (p_ledger_id  NUMBER
                ) RETURN VARCHAR2;


/*To check Dual budgetary is enabled for either PO or CC.
Mainly used to pass secondary ledger Id as parameter
*/
FUNCTION is_dual_bc_enabled
                (p_ledger_id IN NUMBER
                , p_ledger_category IN VARCHAR2) RETURN VARCHAR2;

/* Get CBC Ledger Id for Primary Ledger.
*/
PROCEDURE get_cbc_ledger
                (p_primary_ledger_id  IN NUMBER,
                 p_cbc_ledger_id OUT NOCOPY NUMBER,
                 p_cbc_ledger_Name OUT NOCOPY VARCHAR2);

END IGC_LEDGER_UTILS;

 

/
