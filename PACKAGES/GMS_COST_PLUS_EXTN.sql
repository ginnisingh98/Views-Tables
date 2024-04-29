--------------------------------------------------------
--  DDL for Package GMS_COST_PLUS_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_COST_PLUS_EXTN" AUTHID CURRENT_USER as
/* $Header: gmscpexs.pls 120.2 2005/10/23 05:11:32 rshaik noship $  */

  PROCEDURE get_award_ind_rate_sch_rev_id(x_award_id        IN     Number,
					  x_task_id        IN     Number,  -- Bug 2097676: Multiple IDC Build
                                          x_exp_item_date   IN     Date,
                                          x_rate_sch_rev_id IN OUT NOCOPY Number,
                                          x_status          IN OUT NOCOPY Number,
                                          x_stage           IN OUT NOCOPY Number);

  --- PRAGMA RESTRICT_REFERENCES(get_award_ind_rate_sch_rev_id, WNDS, WNPS); /* commented as per 3786374 */

  FUNCTION get_award_cmt_compiled_set_id
          ( x_task_id               IN NUMBER,
            x_expenditure_item_date IN DATE,
            p_expenditure_type      IN VARCHAR2, --Bug 3003584
            x_organization_id       IN NUMBER,
            x_schedule_type         IN VARCHAR2,
            x_award_id              IN NUMBER)
  RETURN NUMBER;
  --- PRAGMA RESTRICT_REFERENCES(get_award_cmt_compiled_set_id, WNDS, WNPS);  /* commented as per 3786374 */

-- Bug : 2557041 - Added p_mode parameter , This parameter is used to
--		   restrict creation of burden adjustments in check funds mode

  -- R12 Funds Management Uptake : Added p_partial_flag parameter to fail packet having exceptional
  -- records based on the FULL/PARTIAL MODE.
  FUNCTION update_bc_pkt_burden_raw_cost(x_packet_id    IN NUMBER,
                                         p_mode         IN VARCHAR2,
					 p_partial_flag IN VARCHAR2 DEFAULT 'N') return boolean;
  -- returns TRUE if success, FALSE if failure;

  FUNCTION update_source_burden_raw_cost(x_packet_id in number, p_mode varchar2, p_partial_flag varchar2) return boolean;
  -- returns TRUE if success, FALSE if failure;

-- Added for Bug:1331903
  FUNCTION get_award_compiled_set_id(	x_doc_type in VARCHAR2,
					x_distribution_id in NUMBER,
					x_distribution_line_number in NUMBER default NULL ) RETURN number ;

  FUNCTION get_burdenable_raw_cost(	x_doc_type in VARCHAR2,
					x_distribution_id in NUMBER,
					x_distribution_line_number in NUMBER default NULL ) RETURN number;

  Function is_spon_project(x_project_id IN NUMBER ) RETURN number;

   FUNCTION award_cmt_compiled_set_id
                        (       x_document_header_id          IN NUMBER,
                                x_document_distribution_id    IN NUMBER,
                                x_task_id                     IN NUMBER,
                                x_document_type               IN VARCHAR2,
                                x_expenditure_item_date       IN DATE,
                                p_expenditure_type	      IN VARCHAR2,--Bug 3003584
                                x_organization_id             IN NUMBER,
                                x_schedule_type               IN VARCHAR2,
                                x_award_id                    IN NUMBER)

                        RETURN NUMBER ;


-- ********************************************************************************
-- BUG: 1808115 - AP prepayment apply/unapply missing award and Award distribution
-- Following code is fixing the burden aspect of the new award distribution.
-- ********************************************************************************

	PROCEDURE CALC_prepayment_burden( X_AP_REC	ap_invoice_distributions_all%ROWTYPE ,
								  X_adl_rec	gms_award_distributions%ROWTYPE ) ;

-----------------------------------------------------------------------------------------------
-- This procedure is used to update top_task_id and parent_resource_id for interface programs
-- Bug 2143160
-----------------------------------------------------------------------------------------------
         Procedure update_top_tsk_par_res (x_packet_id   IN      NUMBER);

-- ------------------------------------------------------------------------------------------------
-- Update expenditure_category and revenue category on gms_bc_packets because of change in RLMI API.
-- Update person_id,job_id,vendor_id columns on gms_bc_packets.
-- This is done before setup_rlmi is called Bug 2143160
-- ------------------------------------------------------------------------------------------------
		PROCEDURE update_exp_rev_cat (x_packet_id IN NUMBER);

-- ------------------------------------------------------------------------------------------------
-- Following function is used to check if the transaction source allows burdening
-- Function called in update_bc_pkt_burden_raw_cost and calc_exp_burden
-- -----------------------------------------------------------------------------------------------
FUNCTION burden_allowed(p_transaction_source VARCHAR2) RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES(burden_allowed, WNDS, WNPS);

END GMS_COST_PLUS_EXTN;

 

/
