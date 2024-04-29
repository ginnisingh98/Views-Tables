--------------------------------------------------------
--  DDL for Package GMS_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_FUNDS_CONTROL_PKG" AUTHID CURRENT_USER AS
-- $Header: gmsfcfcs.pls 120.11 2007/03/13 12:18:42 cmishra ship $
  -- Everest Funds Checker Main Routine

  -- R12 Funds Management Uptake : AP/PO/REQ will no longer be saving data before
  -- firing fundscheck hence existing logic is modified such that code which needs access
  -- to AP/PO/REQ tables gets fired from main session and insert/update code gets fired in
  -- autonomous mode. Added below variables for new logic.

  TYPE t_set_of_books_id_type  IS TABLE OF gms_bc_packets.set_of_books_id%type INDEX BY BINARY_INTEGER;
  TYPE t_je_source_name_type   IS TABLE OF gms_bc_packets.je_source_name%type INDEX BY BINARY_INTEGER;
  TYPE t_je_category_name_type IS TABLE OF gms_bc_packets.je_category_name%type INDEX BY BINARY_INTEGER;
  TYPE t_actual_flag_type      IS TABLE OF gms_bc_packets.actual_flag%type INDEX BY BINARY_INTEGER;
  TYPE t_project_id_type       IS TABLE OF gms_bc_packets.project_id%type INDEX BY BINARY_INTEGER;
  TYPE t_task_id_type          IS TABLE OF gms_bc_packets.task_id%type INDEX BY BINARY_INTEGER;
  TYPE t_award_id_type         IS TABLE OF gms_bc_packets.award_id%type INDEX BY BINARY_INTEGER;
  TYPE t_result_code_type      IS TABLE OF gms_bc_packets.result_code%type INDEX BY BINARY_INTEGER;
  TYPE t_entered_dr_type       IS TABLE OF gms_bc_packets.entered_dr%type INDEX BY BINARY_INTEGER;
  TYPE t_entered_cr_type       IS TABLE OF gms_bc_packets.entered_cr%type INDEX BY BINARY_INTEGER;
  TYPE t_etype_type            IS TABLE OF gms_bc_packets.expenditure_type%type INDEX BY BINARY_INTEGER;
  TYPE t_exp_org_id_type       IS TABLE OF gms_bc_packets.expenditure_organization_id%type INDEX BY BINARY_INTEGER;
  TYPE t_exp_item_date_type    IS TABLE OF gms_bc_packets.expenditure_item_date%type INDEX BY BINARY_INTEGER;
  TYPE t_document_type_type    IS TABLE OF gms_bc_packets.document_type%type INDEX BY BINARY_INTEGER;
  TYPE t_doc_header_id_type    IS TABLE OF gms_bc_packets.document_header_id%type INDEX BY BINARY_INTEGER;
  TYPE t_doc_dist_id_type      IS TABLE OF gms_bc_packets.document_distribution_id%type INDEX BY BINARY_INTEGER;
  TYPE t_vendor_id_type        IS TABLE OF gms_bc_packets.vendor_id%type INDEX BY BINARY_INTEGER;
  TYPE t_exp_category_type     IS TABLE OF gms_bc_packets.expenditure_category%type INDEX BY BINARY_INTEGER;
  TYPE t_revenue_category_type IS TABLE OF gms_bc_packets.revenue_category%type INDEX BY BINARY_INTEGER;
  TYPE t_ind_cmp_set_id_type   IS TABLE OF gms_bc_packets.ind_compiled_set_id%type INDEX BY BINARY_INTEGER;
  TYPE t_reference6_type        IS TABLE OF po_bc_distributions.reference6%type INDEX BY BINARY_INTEGER;
  TYPE t_reference13_type       IS TABLE OF po_bc_distributions.reference13%type INDEX BY BINARY_INTEGER;
  Type t_po_rate_type           IS TABLE OF po_distributions_all.rate%type INDEX BY BINARY_INTEGER; -- Bug 5614467

  --R12 AP Lines Uptake enhancement : Forward porting bug 4450291
  TYPE t_brc_type               IS TABLE OF gms_bc_packets.burdenable_raw_cost%type INDEX BY BINARY_INTEGER;
  TYPE t_doc_dist_line_num_type IS TABLE OF ap_invoice_distributions_all.distribution_line_number%type INDEX BY BINARY_INTEGER;
  TYPE t_invoice_type_code_type IS TABLE OF ap_invoices_all.invoice_type_lookup_code%type INDEX BY BINARY_INTEGER;
  TYPE t_inv_source_type        IS TABLE OF ap_invoices_all.source%type INDEX BY BINARY_INTEGER;
  TYPE t_source_event_id_type   IS TABLE OF gms_bc_packets.source_event_id%type INDEX BY BINARY_INTEGER;
  TYPE t_event_type_code_type   IS TABLE OF po_bc_distributions.event_type_code%type INDEX BY BINARY_INTEGER;
  TYPE t_main_or_backing_type   IS TABLE OF po_bc_distributions.main_or_backing_code%type INDEX BY BINARY_INTEGER;
  TYPE t_parent_reversal_id_type  IS TABLE OF ap_invoice_distributions_all.parent_reversal_id%type INDEX BY BINARY_INTEGER; -- Bug 5369296


/*-----------------------------------------------------------------------------------------------

  Function   : gms_fck
  Purpose    : Fundschecking transaction against award budget
		Parameters  and meaning.
		-----------------------
		x_sobid 	: Set of books id
                x_packetid	: The packet, sent for funds check
                x_mode   	: R = Reserve,C= Check Funds,S= Sumbit(Budget),B = Baselining(Budget)
                x_partial      	: Partial = Y, Full = N
                x_user_id     	: Not used in grants
               	x_user_resp_id 	: Not used in grants
               	x_execute      	: Not used in grants


-----------------------------------------------------------------------------------------------*/
  FUNCTION gms_fck(
		   x_sobid                IN  NUMBER,
                   x_packetid             IN  NUMBER,
                   x_mode                 IN  VARCHAR2 DEFAULT 'C',
   	           x_override             IN  VARCHAR2 DEFAULT 'N',
		   x_partial              IN  VARCHAR2 DEFAULT 'N',
   	           x_user_id              IN  NUMBER DEFAULT NULL,
                   x_user_resp_id      	  IN  NUMBER DEFAULT NULL,
		   x_execute	  	  IN  VARCHAR2 DEFAULT 'N',
		   x_return_code	  IN OUT NOCOPY varchar2,
		   x_e_code		  OUT NOCOPY VARCHAR2,
	           x_e_stage		  OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

/*-----------------------------------------------------------------------------------------------

  Procedure  : gms_gl_return_code
  Purpose    : procedure to return the OGM fundscheck result to GL fundschecker glx_fck
		Parameters  and meaning.
		------------------------
                x_packetid		: The packet, sent for funds check
                x_mode   		: R = Reserve,C= Check Funds,S= Sumbit(Budget),B = Baselining(Budget)
		x_gl_return_code	: gl return code which is used to generate the status code in Grants
		x_gms_return_code	: gms return code calculated after fund check.
		x_gms_partial_flag	: Partial = Y, Full = N

-----------------------------------------------------------------------------------------------*/
Procedure gms_gl_return_code (
                                                x_packet_id                     IN number,
                                                x_mode                          in varchar2,
                                                x_gl_return_code                IN OUT NOCOPY VARCHAR2,
                                                x_gms_return_code               IN VARCHAR2,
                                                x_gms_partial_flag              IN VARCHAR2,
                                                x_er_code                       IN OUT NOCOPY VARCHAR2,
                                                x_er_stage                      IN OUT NOCOPY VARCHAR2 );


/* -----------------------------------------------------------------------------------------------
   This function is used to calculate resource list member id while copying adls when REQ ->PO
   -> AP
-------------------------------------------------------------------------------------------------- */

Procedure setup_rlmi (
    x_packet_id               IN       NUMBER,
   x_mode                     IN       VARCHAR2,
   x_err_code                 OUT NOCOPY      NUMBER,
   x_err_buff                 OUT NOCOPY      VARCHAR2 );

/* -----------------------------------------------------------------------------------------------

   Procedure : delete_pending_txns
   Purpose   : This procedure will delete pending records in gms_bc_packets associated with a
               request that has been terminated.
	       After deleting the records from gms_bc_packets, corresponding request_id entry will
               be deleted from gms_concurrency_control table.

-------------------------------------------------------------------------------------------------- */

Procedure delete_pending_txns
(x_err_code                 OUT NOCOPY      NUMBER,
 x_err_buff                 OUT NOCOPY      VARCHAR2 );

/* -----------------------------------------------------------------------------------------------
   Function  : sponsored_project
   Purpose   : Returns 'Y' if project parameter passed is sponsored, else returns 'N'
-------------------------------------------------------------------------------------------------- */
FUNCTION sponsored_project(p_project_id IN NUMBER)
RETURN VARCHAR2;

 PRAGMA RESTRICT_REFERENCES(sponsored_project, WNDS);
-----------------------------------------------------------------------------------------------+

  -- R12 Fundscheck Management uptake: AP/PO/REQ will no longer be saving data before
  -- firing fundscheck hence existing logic is modified such that code which needs access
  -- to AP/PO/REQ tables gets fired from main session and the insert/update code gets fired in
  -- autonomous mode.
  -- Introduced new procedure to insert data into gms_bc_packets based on data
  -- in gl_bc_packets and AP,PO,REQ transaction tables.This procedure is fired from GL
  -- main budgetory control API.

  PROCEDURE COPY_GL_PKT_TO_GMS_PKT (p_application_id      IN NUMBER,
                                    p_mode                IN  VARCHAR2 DEFAULT 'C',
				    p_partial_flag        IN  VARCHAR2 DEFAULT 'N',
                                    x_return_code         OUT NOCOPY VARCHAR2 ) ;

  -- R12 Funds Management Uptake : This tieback procedure is called from PSA_BC_XLA_PVT.Budgetary_control
  -- if SLA accounting fails.This API will mark the gms_bc_packet records to failed status.

  PROCEDURE TIEBACK_FAILED_ACCT_STATUS (p_bc_mode IN  VARCHAR2 DEFAULT 'C');

END GMS_FUNDS_CONTROL_PKG;

/
