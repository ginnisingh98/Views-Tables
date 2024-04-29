--------------------------------------------------------
--  DDL for Package GMS_PA_COSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_PA_COSTING_PKG" AUTHID CURRENT_USER AS
-- $Header: gmspafcs.pls 120.7 2006/07/28 12:42:12 cmishra noship $

g_debug_context		varchar2(1) := NULL;
g_packet_id		number := to_number(null);
g_set_of_books_id	number := to_number(null);
g_request_id		number := to_number(null);
g_txn_source            varchar2(30) := NULL;
g_error_stage		varchar2(200);
g_batch_name            varchar2(30) := null;
g_txn_xface_id          number;

--=============================================================================
-- Procedure Fundscheck_CDL:  Fundschecking procedure which is called from
--                            Projects Costing processes.
--
-- Input Parameters :
--     Request ID of the calling Costing process.
--
-- Output Parameters :
--     return_status : 0 if successful, else a non-zero numeric value.
--     error_code    : Error code of the failure
--     error_stage   : Stage where error occured.
--=============================================================================

Procedure FundsCheck_CDL (p_request_id	   IN  NUMBER,
                           p_return_status OUT NOCOPY NUMBER,
                           p_error_code    OUT NOCOPY VARCHAR2,
                           p_error_stage   OUT NOCOPY NUMBER);

--=============================================================================
--  Procedure : fundscheck_tieback
--  Purpose   : Tieback status  of CDL's that were Grants funds checked during
--              Costing.
--
--  Parameters  and meaning.
--  -----------------------
--  p_request_id    : Request_id of the costing process being run.
--  p_return_status : Return status is 0 for success and -1 for failure.
--  p_error_code    : Error Code for the failure.
--  p_error_stage   : Stage where the failure occured.
--=============================================================================
Procedure FundsCheck_TieBack (p_request_id    IN  NUMBER,
                              p_return_status OUT NOCOPY NUMBER,
                              p_error_code    OUT NOCOPY VARCHAR2,
                              p_error_stage   OUT NOCOPY NUMBER);

--=============================================================================
--  Procedure : Net_zero_adls
--  Purpose   : Adls creation logic for the dummy additional exp created
--              to correct the accounting adjustments.
--              These are new zero transactions.
--
--  Parameters  and meaning.
--  -----------------------
--  p_transaction_source    : Transaction source for supplier cost interface.
--  p_batch                 : Batch name for transaction source.
--  p_status                : return status                  .
--  P_xface_id              : Transaction interface ID.
--=============================================================================
 procedure Net_zero_adls( p_transaction_source IN VARCHAR2,
                          p_batch              IN VARCHAR2,
                          P_xface_id           IN NUMBER,
                          p_status             IN OUT NOCOPY VARCHAR2 ) ;

--=============================================================================
--   Procedure : Fundscheck_Supplier_Cost
--   Purpose   : Funds Check supplier invoice distributions being interfaced to
--               projects against an award budget.
--
--   Parameters  and meaning.
--   -----------------------
--   p_transaction_source : Transaction source of the record being processed.
--   p_current_batch      : Current interface batch being processed.
--   p_txn_interface_id   : Transaction Identifier.
--   p_request_id         : Request_id of the interface process.
--   p_status             : Execution status of the procedure.
--                          FND_API.G_RET_STS_SUCCESS for success and
--                          FND_API.G_RET_STS_UNEXP_ERROR for unexpected error.
--=============================================================================
PROCEDURE Fundscheck_Supplier_Cost(p_transaction_source IN VARCHAR2,
                                   p_txn_interface_id   IN NUMBER ,
                                   p_request_id 	IN NUMBER,
                                   p_status             IN OUT NOCOPY VARCHAR2);

--=============================================================================
--  Procedure : Tieback_Interface
--  Purpose   : Tieback grants related transactions during interface of supplier
--              invoice to projects.
--
--  Parameters  and meaning.
--  -----------------------
--  p_request_id   : Request_id of the interface process.
--  p_status       : Execution status of the procedure.
--                   FND_API.G_RET_STS_SUCCESS for success and
--                   FND_API.G_RET_STS_UNEXP_ERROR for unexpected error.
--=============================================================================
PROCEDURE Tieback_Interface(p_request_id         IN NUMBER,
                            p_status             IN OUT NOCOPY VARCHAR2
                           );

--
--=============================================================================
--  Function : grants_implemented
--  Purpose  : Function checks if grants is implemented for the OU. If so,
--             return 'Y' else return 'N'
--=============================================================================
FUNCTION grants_implemented return VARCHAR2;
--
--
-- Variable declarations

TYPE tt_project_id	              is table of gms_bc_packets.project_id%TYPE;
TYPE tt_award_id	              is table of gms_bc_packets.award_id%TYPE;
TYPE tt_task_id	                      is table of gms_bc_packets.task_id%TYPE;
TYPE tt_expenditure_type	      is table of gms_bc_packets.expenditure_type%TYPE;
TYPE tt_expenditure_item_date	      is table of gms_bc_packets.expenditure_item_date%TYPE;
TYPE tt_actual_flag	              is table of gms_bc_packets.actual_flag%TYPE;
TYPE tt_status_code	              is table of gms_bc_packets.status_code%TYPE;
TYPE tt_last_update_date	      is table of gms_bc_packets.last_update_date%TYPE;
TYPE tt_last_updated_by	              is table of gms_bc_packets.last_updated_by%TYPE;
TYPE tt_created_by	              is table of gms_bc_packets.created_by%TYPE;
TYPE tt_creation_date	              is table of gms_bc_packets.creation_date%TYPE;
TYPE tt_last_update_login	      is table of gms_bc_packets.last_update_login%TYPE;
TYPE tt_je_category_name	      is table of gms_bc_packets.je_category_name%TYPE;
TYPE tt_je_source_name	              is table of gms_bc_packets.je_source_name%TYPE;
TYPE tt_transfered_flag	              is table of gms_bc_packets.transfered_flag%TYPE;
TYPE tt_document_type	              is table of gms_bc_packets.document_type%TYPE;
TYPE tt_expenditure_organization_id   is table of gms_bc_packets.expenditure_organization_id%TYPE;
TYPE tt_document_header_id	      is table of gms_bc_packets.document_header_id%TYPE;
TYPE tt_document_distribution_id      is table of gms_bc_packets.document_distribution_id%TYPE;
TYPE tt_entered_dr	              is table of gms_bc_packets.entered_dr%TYPE;
TYPE tt_entered_cr	              is table of gms_bc_packets.entered_cr%TYPE;
TYPE tt_status_flag	              is table of gms_bc_packets.status_flag%TYPE;
TYPE tt_bc_packet_id	              is table of gms_bc_packets.bc_packet_id%TYPE;
TYPE tt_request_id	              is table of gms_bc_packets.request_id%TYPE;
TYPE tt_ind_compiled_set_id	      is table of gms_bc_packets.ind_compiled_set_id%TYPE;
TYPE tt_person_id	              is table of gms_bc_packets.person_id%TYPE;
TYPE tt_job_id	                      is table of gms_bc_packets.job_id%TYPE;
TYPE tt_expenditure_category	      is table of gms_bc_packets.expenditure_category%TYPE;
TYPE tt_revenue_category	      is table of gms_bc_packets.revenue_category%TYPE;
TYPE tt_adjusted_document_header_id   is table of gms_bc_packets.adjusted_document_header_id%TYPE;
TYPE tt_award_set_id	              is table of gms_bc_packets.award_set_id%TYPE;
TYPE tt_transaction_source	      is table of gms_bc_packets.transaction_source%TYPE;
TYPE tt_burdenable_raw_cost           is table of gms_award_distributions.burdenable_raw_cost%TYPE;
TYPE tt_acct_raw_cost                 is table of pa_transaction_interface_all.acct_raw_cost%TYPE;
TYPE tt_line_type_lookup              is table of ap_invoice_distributions_all.line_type_lookup_code%TYPE;
TYPE tt_invoice_type_lookup           is table of ap_invoices_all.invoice_type_lookup_code%TYPE;

--REL12 : AP lines uptake enhancement : Added below plsql tables
TYPE tt_invoice_id                    is table of ap_invoices_all.invoice_id%TYPE;
TYPE tt_invoice_distribution_id       is table of ap_invoice_distributions_all.invoice_distribution_id%TYPE;
TYPE tt_sys_ref4                      IS table of pa_transaction_interface_all.cdl_system_reference4%TYPE;
TYPE tt_bud_task_id                   is table of gms_bc_packets.bud_task_id%TYPE;
TYPE tt_txn_interface_id              is table of pa_transaction_interface_all.txn_interface_id%TYPE;
Type tt_nz_adj_flag                   is table of pa_transaction_interface_all.net_zero_adjustment_flag%TYPE ;
--

   cursor get_xface_cur is
   select xface.interface_id, -- Bug 5389130
          xface.txn_interface_id,
          xface.transaction_source,
          apinv.invoice_id,
          apinv.invoice_distribution_id , -- REL12 : Ap lines uptake
	  xface.cdl_system_reference4 ,   -- REL12 : Ap lines uptake
          apinv.project_id,
          apinv.task_id,
	  adl.award_id,
          adl.ind_compiled_set_id,
          adl.burdenable_raw_cost,
	  adl.bud_task_id,
	  xface.expenditure_type,
          xface.expenditure_item_date,
          apinv.expenditure_organization_id,
          apinv.line_type_lookup_code,
          api.invoice_type_lookup_code,
          xface.acct_raw_cost,
          api.vendor_id,
          pet.expenditure_category,
          pet.revenue_category_code,
	  xface.adjusted_expenditure_item_id --REL12 : Ap lines uptake
          , xface.net_zero_adjustment_flag
	  , adl.fc_status -- R12 AP lines uptake : Prepayment changes
     from ap_invoice_distributions apinv,
          pa_transaction_interface xface,
          gms_award_distributions adl,
          ap_invoices  api,
          pa_expenditure_types	pet
    where xface.transaction_source = G_txn_source
      and xface.txn_interface_id = G_txn_xface_id
      and xface.cdl_system_reference2 = apinv.invoice_id
      and xface.cdl_system_reference5 = apinv.invoice_distribution_id --REL12 : Ap lines uptake
      and apinv.invoice_id = adl.invoice_id
      and apinv.distribution_line_number = adl.distribution_line_number
      and apinv.invoice_id = api.invoice_id
      and apinv.award_id = adl.award_set_id
      and apinv.expenditure_type = pet.expenditure_type
      and nvl(apinv.pa_addition_flag, 'X') <> 'T'
      and adl.document_type = 'AP'
      and adl.adl_status = 'A';

   --REL12 : AP lines uptake enhancement
   -- Cursor to fetch pa_transaction_interface_all records having same invoice_id ,invoice_distribution_id
   -- and invoice_payment_id. These records correspond to adjusted/non adjusted expenditure items
   -- associated with original invoice distribution.

   cursor c_txn_details (p_sys_ref2 VARCHAR2,
                         p_sys_ref5 VARCHAR2,
			 p_sys_ref4 VARCHAR2,
			 p_interface_id NUMBER) IS
   select xface.txn_interface_id,
          xface.transaction_source,
          to_number(xface.cdl_system_reference2),
          to_number(xface.cdl_system_reference5),
	  xface.cdl_system_reference4,
          xface.project_id,
          xface.task_id,
          adl.award_id,
          adl.ind_compiled_set_id,
          adl.burdenable_raw_cost,
	  adl.bud_task_id,
          xface.expenditure_type,
          xface.expenditure_item_date,
          NVL(xface.override_to_organization_id,xface.org_id) expenditure_organization_id,
          xface.acct_raw_cost,
          pet.expenditure_category,
          pet.revenue_category_code,
	  xface.adjusted_expenditure_item_id  ,
          xface.net_zero_adjustment_flag
     from pa_transaction_interface xface,
          gms_award_distributions adl,
          pa_expenditure_types	pet
    where xface.transaction_source = G_txn_source
      and xface.cdl_system_reference2  = p_sys_ref2
      and xface.cdl_system_reference5  = p_sys_ref5
      and (xface.cdl_system_reference4 = p_sys_ref4 OR p_sys_ref4 IS NULL)
      and xface.interface_id = p_interface_id
      and xface.TRANSACTION_STATUS_CODE = 'P'
      and adl.expenditure_item_id = xface.adjusted_expenditure_item_id
      and adl.adl_line_num = (SELECT max(adl1.adl_line_num)
                                FROM gms_award_distributions adl1
			       WHERE adl1.expenditure_item_id = adl.expenditure_item_id
			         AND adl1.award_id= adl.award_id
				 AND adl1.adl_status = 'A'
				 AND adl1.document_type = 'EXP')
      and xface.expenditure_type = pet.expenditure_type
      and adl.document_type = 'EXP'
    ORDER BY  adl.award_id,
              xface.project_id,
	      xface.task_id;

END gms_pa_costing_pkg;

 

/
