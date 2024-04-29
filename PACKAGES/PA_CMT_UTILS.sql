--------------------------------------------------------
--  DDL for Package PA_CMT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CMT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAXCMTUS.pls 120.9 2007/10/19 11:23:30 rthumma ship $ */

/* Added for bug#6408874 */
g_po_distr_id           number  ;
g_rcpt_qty              number  ;
g_qty_ordered           number;
g_qty_cancel            number;
g_qty_billed            number;
g_module                varchar2(255);
g_pa_quantity           NUMBER;
g_inv_source            VARCHAR2(255);
g_line_type_lookup_code VARCHAR2(255);
/* Added for bug#6408874 */

function get_rcpt_qty(p_po_dist in number,
                      p_qty_ordered in number,
                      p_qty_cancel in number,
                      p_qty_billed in number,
                      p_module in varchar2,
                      --Pa.M Added below parameters
                      p_po_line_id in number,
                      p_project_id in number,
                      p_task_id in number,
                      p_ccid in number,
       		      p_pa_quantity in number,   -- Bug 3556021
                      p_inv_source  IN VARCHAR2, -- Bug 3556021
                      p_line_type_lookup_code IN VARCHAR2, -- Bug 3556021
                      p_matching_basis IN VARCHAR2 DEFAULT NULL, -- Bug 3642604
                      p_nrtax_amt IN NUMBER DEFAULT NULL,  -- Bug 3642604
		      P_CASH_BASIS_ACCTG in varchar2 DEFAULT 'N', /* Bug 4905552 */
                      p_accrue_on_receipt_flag  IN varchar2 default NULL /* Bug 5014034 */
                     ) return number;

function get_inv_cmt(p_po_dist in number,
                     p_denom_amt_flag in varchar2,
                     p_pa_add_flag in varchar2,
                     p_var_amt in number,
                     p_ccid   in number,
                     p_module in varchar2,
                     p_invoice_id       in number DEFAULT NULL ,        /* Added for Bug 3394153 */
                     p_dist_line_num    in number DEFAULT NULL ,        /* Added for Bug 3394153 */
                     p_inv_dist_id      in number DEFAULT NULL,		  /* Added for Bug 3394153 */
     	     	 P_CASH_BASIS_ACCTG in varchar2	DEFAULT 'N'			  /* Bug 4905552 */
				 ) return number;

/* Bug:4914006  R12.PJ:XB3:QA:APL:PREPAYMENT COMMITMENT AMOUNT NOT REDUCED AFTER   */
function get_inv_cmt(p_po_dist in number,
                     p_denom_amt_flag in varchar2,
                     p_pa_add_flag in varchar2,
                     p_var_amt in number,
                     p_ccid   in number,
                     p_module in varchar2,
                     p_invoice_id       in number DEFAULT NULL,        /* Added for Bug 3394153 */
                     p_dist_line_num    in number DEFAULT NULL,        /* Added for Bug 3394153 */
                     p_inv_dist_id      in number DEFAULT NULL,
                     p_accrue_on_rcpt_flag in varchar2,
                     p_po_line_id in number,
                     p_forqty     in varchar2,
                     p_cost       in number,
                     p_project_id in number,
                     p_dist_type  in varchar2,
                     p_pa_quantity in number,  -- Bug 3556021
                     p_inv_source  in varchar2,  -- Bug 3556021
      	     	     P_CASH_BASIS_ACCTG in varchar2	DEFAULT 'N',		  /* Bug 4905552 */
		     p_inv_type    in varchar2,
		     p_hist_flag   in varchar2,
		     p_prepay_amt_remaining in number
				 ) return number;


   TYPE CommCostRecord is RECORD (
        Project_Id             NUmBER,
        Task_Id                NUMBER,
        Po_Line_Id             NUMBER,
        CommCosts              NUMBER);

   TYPE CommCostTabTyp is TABLE of CommCostRecord INDEX BY BINARY_INTEGER;
   G_CommCostTab      CommCostTabTyp;

--R12 changes for AP LINES uptake
function get_inv_var(p_inv_dist in number,
                     p_denom_amt_flag in varchar2,
                     p_amt_var in number,
                     p_qty_var in number
                    ) return number; -- Bug 3556021

--G_CASH_BASIS_ACCTG varchar2(1); -- Global variable to capture if cash basis accounting is impletented.


--bug:4610727 determine outstanding qty on ap distribution.

function get_apdist_qty( p_inv_dist_id    in NUMBER,
                         p_invoice_id     in NUMBER,
	                 p_cost           in NUMBER,
			 p_quantity       in NUMBER,
			 p_calling_module in varchar2,
			 p_denom_amt_flag in varchar2,
    	     	 P_CASH_BASIS_ACCTG in varchar2	DEFAULT 'N'		  /* Bug 4905552 */
			 ) return number ;

--bug:4610727 determine outstanding amount on ap distribution.

function get_apdist_amt( p_inv_dist_id    in NUMBER,
                         p_invoice_id     in NUMBER,
                         p_cost           in NUMBER,
		         p_denom_amt_flag in varchar2,
			 p_calling_module in varchar2,
    	     	 P_CASH_BASIS_ACCTG in varchar2	DEFAULT 'N'			  /* Bug 4905552 */
			 ) return number ;

/*Added for Bug 5946201*/
 Function is_eIB_item (p_po_dist_id IN  number)
 return varchar2;

END PA_CMT_UTILS;

/
