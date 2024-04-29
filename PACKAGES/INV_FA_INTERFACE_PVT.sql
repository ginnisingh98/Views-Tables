--------------------------------------------------------
--  DDL for Package INV_FA_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_FA_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: INVFAAPS.pls 120.1 2005/05/25 17:14:04 appldev  $ */



    -- Name
    --    FUNCTION Get_IC_CCID
    --
    -- Purpose
    --    This procedure gets the Code_Combination_Id from the po_req_distributions_all
    --    table to support the Intercompany AP Invoices created thru Internal Sales Orders to
    --    Interface into FA
    -- Input parameters
    --    p_inv_dist_id   IN    NUMBER    corresponds to ap_invoice_distributions_all.invoice_distribution_id
    --    p_inv_cc_id     IN    NUMBER    corresponds to ap_invoice_distributions_all.DIST_CODE_COMBINATION_ID
    --    p_line_type     IN    VARCHAR2   corresponds to ap_invoice_distributions_all.LINE_TYPE_LOOKUP_CODE
    -- Output Parameters
    --    p_cc_id - Code combination Id from po_req_distributions_all if
    --    Single/Multiple distributions exist for the requisition with same charge Account's.
    --    Else returns p_inv_cc_id

FUNCTION Get_IC_CCID(p_inv_dist_id             IN    NUMBER,
                     p_inv_cc_id               IN    NUMBER,
                     p_line_type               IN    VARCHAR2 )
RETURN NUMBER;



    -- Name
    --    FUNCTION Get_REF_CCID
    --
    -- Purpose
    --    This procedure gets the Code_Combination_Id from the po_req_distributions_all
    --    table to support the Intercompany AP Invoices created thru Internal Sales Orders to
    --    Interface into FA
    -- Input parameters
    --    p_inv_ref_id    IN    VARCHAR2   corresponds to ap_expense_report_lines_all.reference_1
    --    p_inv_cc_id     IN    NUMBER     corresponds to ap_expense_report_lines_all.CODE_COMBINATION_ID
    --    p_line_type     IN    VARCHAR2   corresponds to ap_expense_report_lines_all.LINE_TYPE_LOOKUP_CODE
    -- Output Parameters
    --    p_cc_id - Code combination Id from po_req_distributions_all if
    --    Single/Multiple distributions exist for the requisition with same charge Account's.
    --    Else returns p_inv_cc_id

FUNCTION Get_REF_CCID(p_inv_ref_id             IN    VARCHAR2,
                      p_inv_cc_id              IN    NUMBER,
                      p_line_type              IN    VARCHAR2 )
RETURN NUMBER;



END INV_FA_INTERFACE_PVT;

 

/
