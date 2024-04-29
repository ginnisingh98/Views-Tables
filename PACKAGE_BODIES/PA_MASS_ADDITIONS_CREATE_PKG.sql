--------------------------------------------------------
--  DDL for Package Body PA_MASS_ADDITIONS_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MASS_ADDITIONS_CREATE_PKG" AS
/* $Header: PAMASSAB.pls 120.16.12000000.2 2007/07/31 07:38:00 karbalak ship $ */

    G_api_version   CONSTANT number         := 1.0 ;
    G_pkg_name	    CONSTANT varchar2(45)   := 'PA_Mass_Additions_Create_Pkg' ;
    G_file_name     CONSTANT varchar2(45)   := 'PAMASSAB.pls';
    G_debug_mode    varchar2(1) ;

     /* ===========================================*
     ** Declare PLSQL Bulk variables
     ** We are declaring T and L variables.
     ** T variables are the cursor fetched variables
     ** L Variables are the filtered list.
     ** ===========================================*/
     flag_no_eiIDTab       pa_utils.IdTabTyp;
     flag_no_lineNumTab    pa_utils.IdTabTyp;

     l_descriptionTab      pa_utils.Char150TabTyp ;
     l_XalccidTab          pa_utils.IdTabTyp;
     l_accTypeTab          pa_utils.Char1TabTyp ;
     l_SiAssetsFlagTab     pa_utils.Char1TabTyp ;
     l_poDistIdTab         pa_utils.IdTabTyp ;
     l_assetsCatIDTab      pa_utils.IdTabTyp ;
     l_ManufacturerTab     pa_utils.Char30TabTyp ;
     l_SerialNumberTab     pa_utils.Char150TabTyp ;
     l_ModelNumberTab      pa_utils.Char150TabTyp ;
     l_BookTypCdTab        pa_utils.Char30TabTyp ;
     l_eiDateTab           pa_utils.DateTabTyp ;
     l_FACostTab           pa_utils.AmtTabTyp  ;
     l_PayUnitTab          pa_utils.AmtTabTyp  ;
     l_FAUnitTab           pa_utils.AmtTabTyp  ;
     l_assignedToTab       pa_utils.IdTabTyp ;
     l_payCostTab          pa_utils.AmtTabTyp ;
     l_vendorNumberTab     pa_utils.Char30TabTyp ;
     l_vendorIdTab         pa_utils.IdTabTyp ;
     l_PoNumberTab         pa_utils.Char30TabTyp ;
     l_TxnDateTab          pa_utils.DateTabTyp ;
     l_TxnCreatedByTab     pa_utils.IdTabTyp ;
     l_TxnUpdatedByTab     pa_utils.IdTabTyp ;
     l_invoiceIdTab        pa_utils.IdTabTyp ;
     l_payBatchNameTab     pa_utils.Char150TabTyp ;
     l_DistLineNumberTab   pa_utils.IdTabTyp ;
     l_GlDateTab           pa_utils.DateTabTyp ;
     l_invDistIdTab        pa_utils.IdTabTyp ;
     l_parentInvDstIdTab   pa_utils.IdTabTyp ;
     l_linetypeLcdTab      pa_utils.Char25TabTyp ;
     l_eiIDTab             pa_utils.IdTabTyp;
     l_warrantyNumberTab   pa_utils.Char20TabTyp ;
     l_InvLineNumberTab    pa_utils.IdTabTyp ;
     l_PayCcidTab          pa_utils.IdTabTyp ;
     l_InvoiceNumberTab    pa_utils.Char150TabTyp ;
     l_lineNumTab          pa_utils.IdTabTyp;
     l_cdlEventIDTab       pa_utils.IdTabTyp;
     l_cdlQtyTab           pa_utils.AmtTabTyp ;
     l_ledgercatcdtab      pa_utils.Char30TabTyp ;
     l_ledgerIdTab         pa_utils.IdTabTyp;
     l_ATrackFlagTab       pa_utils.Char1TabTyp ;

     t_SiAssetsFlagTab     pa_utils.Char1TabTyp ;
     -- =====
     -- Bug : 5352018 R12.PJ:XB6:QA:APL:MASS ADDI CREATE PICKS UP ADJ FOR INV WHEN TRAC AS ASSET  DISA
     -- ====
     t_ATrackFlagTab       pa_utils.Char1TabTyp ;
     t_eiIDTab             pa_utils.IdTabTyp;
     t_eiDateTab           pa_utils.DateTabTyp ;
     t_GlDateTab           pa_utils.DateTabTyp ;
     t_lineNumTab          pa_utils.IdTabTyp;
     t_DocHeaderIdTab      pa_utils.IdTabTyp;
     t_DocDistIdTab        pa_utils.IdTabTyp;
     t_DocPaymentIdTab     pa_utils.IdTabTyp;
     t_DocLineNumberTab    pa_utils.IdTabTyp;
     t_DocTypeTab          pa_utils.Char30TabTyp ;
     t_DocDistTypeTab      pa_utils.Char30TabTyp ;
     t_transSourceTab      pa_utils.Char30TabTyp ;
     t_descriptionTab      pa_utils.Char150TabTyp ;
     t_acctRawCostTab      pa_utils.AmtTabTyp     ;
     t_NZAdjFlagTab        pa_utils.Char1TabTyp ;
     t_adjEiIdTab          pa_utils.IdTabTyp;
     t_trFmEiIdTab         pa_utils.IdTabTyp;
     t_vendorIdTab         pa_utils.IdTabTyp ;
     t_vendorNumberTab     pa_utils.Char30TabTyp ;
     t_TxnDateTab          pa_utils.DateTabTyp ;
     t_TxnCreatedByTab     pa_utils.IdTabTyp ;
     t_TxnUpdatedByTab     pa_utils.IdTabTyp ;
     t_invoiceIdTab        pa_utils.IdTabTyp ;
     t_sourceTab           pa_utils.Char25TabTyp ;
     t_InvoiceNumberTab    pa_utils.Char150TabTyp ;
     t_warrantyNumberTab   pa_utils.Char20TabTyp ;
     t_ManufacturerTab     pa_utils.Char30TabTyp ;
     t_SerialNumberTab     pa_utils.Char150TabTyp ;
     t_ModelNumberTab      pa_utils.Char150TabTyp ;
     t_linetypeLcdTab      pa_utils.Char25TabTyp ;
     t_poDistIdTab         pa_utils.IdTabTyp ;
     t_RelatedIdTab        pa_utils.IdTabTyp ;
     t_DistLineNumberTab   pa_utils.IdTabTyp ;
     t_invDistIdTab        pa_utils.IdTabTyp ;
     t_DistCcidTab         pa_utils.IdTabTyp ;
     t_InvLineNumberTab    pa_utils.IdTabTyp ;
     t_RvrAssetsFlagTab    pa_utils.Char1TabTyp ;
     t_SrcAssetsFlagTab    pa_utils.Char1TabTyp ;
     t_parentInvDstIdTab   pa_utils.IdTabTyp ;
     t_apAssetsFlagTab     pa_utils.Char1TabTyp ;
     t_DstMatchTypeTab     pa_utils.Char25TabTyp ;
     t_cdlEventIDTab       pa_utils.IdTabTyp;
     t_cdlQtyTab           pa_utils.AmtTabTyp ;
     t_XalccidTab          pa_utils.IdTabTyp;
     t_accTypeTab          pa_utils.Char1TabTyp ;
     t_payBatchNameTab     pa_utils.Char150TabTyp ;
     t_ledgercatcdtab      pa_utils.Char30TabTyp ;
     t_ledgerIdTab         pa_utils.IdTabTyp;

     t_invOrgIDTab         pa_utils.IdTabTyp;
     /*
     ** Identify the account is assets type account.
     */
     Cursor c_assets_account(p_ccid in number) is
      select 1
       from gl_code_combinations
      where code_combination_id = p_ccid
        and account_type        = 'A' ;

     Cursor c_assets_tracking_flagA ( p_related_id NUMBER) is
            select assets_tracking_flag
	      from ap_invoice_distributions_all
	     where invoice_distribution_id =  p_related_id
	       and invoice_distribution_id <> related_id
	       and assets_tracking_flag = 'Y' ;

     Cursor c_assets_tracking_flagB ( p_charge_appl_to_dist_id NUMBER) is
            select assets_tracking_flag
	      from ap_invoice_distributions_all
	     where invoice_distribution_id =  p_charge_appl_to_dist_id
	       and assets_tracking_flag = 'Y' ;
   /*
   ** Initialize the Plsql bulk variables.
   */
   PROCEDURE InitPlSQLTab ;

   /*
   ** Write_to_log : generate debug messages in the log file.
   */
   PROCEDURE write_to_log( LOG_LEVEL IN NUMBER,
                           MODULE    IN VARCHAR2,
			   MESSAGE   IN VARCHAR2);
   --
   -- Procedure: Insert_Receipts
   -- Purpose  : Generate receipt adjustments for assets generations.
   --
   PROCEDURE  Insert_Receipts(
                           P_acctg_date                IN    DATE,
                           P_ledger_id                 IN    number,
                           P_user_id                   IN    number,
                           P_request_id                IN    number,
                           P_bt_code                   IN    varchar2,
                           P_primary_accounting_method IN    varchar2,
                           P_calling_sequence          IN    varchar2 DEFAULT NULL) ;
   --
   -- Procedure: Insert_Mass
   -- Purpose  : Generate assets for project adjustments
   --
   PROCEDURE  Insert_Mass( p_api_version               IN  number,
                           p_init_msg_list	       IN  varchar2 default FND_API.G_FALSE,
			   p_commit	    	       IN  varchar2 default FND_API.G_FALSE,
			   p_validation_level	       IN  number   default FND_API.G_VALID_LEVEL_FULL,
                           x_return_status	       OUT NOCOPY varchar2,
	                   x_msg_count		       OUT NOCOPY number,
	                   x_msg_data		       OUT NOCOPY varchar2,
			   x_count                     OUT NOCOPY number,
                           P_acctg_date                IN  DATE,
                           P_ledger_id                 IN  number,
                           P_user_id                   IN  number,
                           P_request_id                IN  number,
                           P_bt_code                   IN  varchar2,
                           P_primary_accounting_method IN  varchar2,
                           P_calling_sequence          IN  varchar2 DEFAULT NULL) IS
    --
    lrec	         number ;
    l_No_count           number ;
    l_ignore_cdl         varchar2(1) ;
    l_assets_category_id number ;
    l_po_order_type_lcd  varchar2(25) ;
    l_po_ccid            number ;
    l_assigned_to        number ;
    l_po_number          Varchar2(20) ;
    l_dummy              number ;

    l_current_calling_sequence   varchar2(2000);
    l_debug_info                 varchar2(2000);
    l_request_id                 number;
    l_count                      number;
    l_api_name         CONSTANT  varchar2(100) := 'PA INSERT_MASS';
    l_msg_count        number ;
    l_msg_data         varchar2(2000) ;
    l_return_status    varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;
    l_assets_tracking_flag varchar2(1) ;
    --
    -- Bug 5532231 R12.PJ:XB3:QA:APL:PREPARE MASS ADDITIONS SHOWS DUPLICATE ROWS
    -- line type lookup code is populated null for item type lines.
    -- as suggested to assets (siddiqu)
    --
    cursor c_apinv is
    select ei.expenditure_item_id,
    	   ei.expenditure_item_date ,
           cdl.line_num,
           ei.document_header_id,
           ei.document_distribution_id,
           ei.document_payment_id,
           ei.document_line_number,
           ei.document_type,
           ei.document_distribution_type,
           ei.transaction_source,
           rtrim(SUBSTRB(eic.expenditure_comment,1,80)) description,
	   (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)) acct_raw_cost,
           --cdl.acct_raw_cost				acct_raw_cost,
	   cdl.gl_date,
	   cdl.acct_event_id,
           cdl.quantity,
           ei.net_zero_adjustment_flag,
           ei.adjusted_expenditure_item_id,
           ei.transferred_from_exp_item_id,
           ei.vendor_id,
           rtrim(POV.segment1)  vendor_number,
           apb.batch_name,
           api.invoice_date,
           api.created_by       invoice_created_by,
           api.last_updated_by  invoice_updated_by,
           api.invoice_id	invoice_id,
           api.source,
           rtrim(api.invoice_num) invoice_num,
           apil.warranty_number,
           apil.manufacturer,
           apil.serial_number,
           apil.model_number,
           decode(apd.line_type_lookup_code,  'ITEM', 'PA-ADJ', apd.line_type_lookup_code) line_type_lookup_code,
           apd.po_distribution_id,
           apd.related_id,
           apd.distribution_line_number,
           apd.invoice_distribution_id,
           apd.dist_code_combination_id,
           apd.invoice_line_number ,
           decode(cdl.reversed_flag, NULL, NULL,
                      ( select cdl2.si_assets_addition_flag
                        from pa_cost_distribution_lines_all cdl2
                       where cdl2.expenditure_item_id = cdl.expenditure_item_id
                         and cdl2.line_num_reversed   = cdl.line_num ) ) reversed_assets_flag,
           decode(cdl.line_num_reversed, NULL, NULL,
                      ( select cdl2.si_assets_addition_flag
                        from pa_cost_distribution_lines_all cdl2
                       where cdl2.expenditure_item_id = cdl.expenditure_item_id
                         and cdl2.line_num            = cdl.line_num_reversed ) ) source_assets_flag,
           DECODE(apd.line_type_lookup_code,
                  'ITEM',   decode( apd.corrected_invoice_dist_id,
                                    NULL,apd.invoice_distribution_id,
                                    apd.corrected_invoice_dist_id),
                  'ACCRUAL',decode(apd.corrected_invoice_dist_id,
                                   NULL, apd.invoice_distribution_id,
                                   apd.corrected_invoice_dist_id),
                  'IPV',    apd.related_id,
                  'ERV',    apd.related_id, apd.charge_applicable_to_dist_id) parent_invoice_dist_id,
           apd.assets_addition_flag            ap_assets_addition_flag,
           apd.dist_match_type,
           glcc.account_type ,
           xal.code_combination_id,
	   algt.ledger_category_code,
	   algt.ledger_id,
	   fsp.inventory_organization_id,
	   apd.assets_tracking_flag
     from  pa_expenditure_items 	ei,
           pa_expenditure_comments  	eic,
           pa_cost_distribution_lines 	cdl,
           ap_invoices                	api,
           ap_batches_all               apb,
           ap_invoice_lines           	apil,
           ap_invoice_distributions   	apd,
	   financials_system_params_all fsp,
           po_vendors                 	pov,
           xla_distribution_links       xdl,
           xla_ae_headers               xah,
	   ap_alc_ledger_gt             algt,
           xla_ae_lines                 xal,
	   ap_acct_class_code_gt        aagt,
           gl_code_combinations         glcc,
           --
           -- bug:4778189 - cross charge projects related transactions didn't generate assets.
	   --
	   pa_projects_all              p,
	   pa_project_types_all         pt
    where  ei.expenditure_item_id       = cdl.expenditure_item_id
      and  cdl.expenditure_item_id      = eic.expenditure_item_id (+)
      and  cdl.line_num                 = eic.line_number (+)
      and  ei.transaction_source in ('AP INVOICE' , 'AP EXPENSE', 'AP NRTAX', 'AP VARIANCE', 'AP ERV', /* Bug 5284323 */
                                     'INTERPROJECT_AP_INVOICES','INTERCOMPANY_AP_INVOICES')
      and  cdl.gl_date                  <= P_acctg_date
      and  cdl.line_type                = 'R'
      and  cdl.transfer_status_code     = 'A'
      and  cdl.si_assets_addition_flag  = 'T'
      and  cdl.project_id               = p.project_id
      and  p.project_type               = pt.project_type
      -- Bug : 5368600
      and  p.org_id                     = pt.org_id
      and  pt.project_type_class_code   <> 'CAPITAL'
      and  ei.document_header_id        = api.invoice_id
      and  ei.document_distribution_id  = apd.invoice_distribution_id
      and  ei.document_line_number      = apd.invoice_line_number
      and  apil.invoice_id              = api.invoice_id
      and  api.org_id                   = fsp.org_id
      and  apil.line_number             = apd.invoice_line_number
      and  api.batch_id                 = apb.batch_id(+)
      and  apd.posted_flag              = 'Y'
      and  api.vendor_id                = pov.vendor_id
      and  apd.set_of_books_id          = P_ledger_id
      -- 5911379: Modified the join
      AND  xah.application_id 	        = 275
      and  xah.event_id       	        = cdl.acct_event_id
      AND  xah.balance_type_code        = 'A'
      and  xah.accounting_entry_status_code = 'F'
      and  xal.application_id 	        = xah.application_id
      AND  xal.ae_header_id             = xah.ae_header_id
      and  xal.accounting_class_code    = aagt.accounting_class_code
      and  xdl.event_id       	        = xah.event_id
      AND  xdl.ae_header_id             = xal.ae_header_id
      AND  xdl.ae_line_num              = xal.ae_line_num
      and  xdl.application_id 	        = xal.application_id
      and  xdl.source_distribution_id_num_1 = ei.expenditure_item_id
      and  xdl.source_distribution_id_num_2 = cdl.line_num
      and  xah.ledger_id                = algt.ledger_id
      and  decode(algt.org_id, -99, algt.org_id, cdl.org_id) =
           decode(algt.org_id, -99, -99, algt.org_id)
      and  glcc.code_combination_id     = xal.code_combination_id
      -- 5911379: ends
     ORDER BY ei.document_distribution_id, ei.expenditure_item_id, cdl.line_num  ;

   BEGIN
       l_current_calling_sequence := P_calling_sequence||'->'||
                    'Insert_Mass';
       l_count := 1000;

       fnd_profile.get('PA_DEBUG_MODE',G_debug_mode);
       G_debug_mode := NVL(G_debug_mode, 'N');

       write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', '*** 10 : ORACLE PROJECTS INSERT MASS PROCESSING ***') ;
       -- Standrad call to check API compatibility.
       IF NOT FND_API.Compatible_API_Call( G_api_version,
    				           p_api_version,
    				           'INSERT_MASS',
    					   G_pkg_name) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF ;

       -- Initialize message list if p_init_msg_list is set to TRUE
       --
       IF FND_API.to_boolean( p_init_msg_list) THEN
          FND_MSG_PUB.initialize ;
       END IF ;
       -- Initialize API return status to success.
       --
       l_return_status  := FND_API.G_RET_STS_SUCCESS ;
       write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'INSERT MASS Processing begins.') ;

       write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Calling Insert_Receipts processing.') ;


       Insert_Receipts( P_acctg_date    ,
                        P_ledger_id     ,
                        P_user_id       ,
                        P_request_id    ,
                        P_bt_code       ,
                        P_primary_accounting_method ,
                        P_calling_sequence ) ;

       write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Insert Mass Main Loop Begins Here.') ;

       OPEN c_apinv ;

       LOOP

	 write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Main Loop Iteration Begins' ) ;
	 write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Initialize Plsql variables' ) ;
         InitPlSQLTab ;

         write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Fetching records from cursor c_apinv.') ;
         fetch c_apinv
               bulk collect into t_eiIDTab,
	       t_eiDateTab,
	       t_lineNumTab,
	       t_DocHeaderIdTab,
	       t_DocDistIdTab,
	       t_DocPaymentIdTab,
	       t_DocLineNumberTab,
	       t_DocTypeTab,
	       t_DocDistTypeTab,
	       t_transSourceTab,
	       t_descriptionTab,
	       t_acctRawCostTab,
	       t_GlDateTab,
               t_cdlEventIDTab,
               t_cdlQtyTab,
	       t_NZAdjFlagTab,
	       t_adjEiIdTab,
	       t_trFmEiIdTab,
	       t_vendorIdTab,
	       t_vendorNumberTab,
               t_payBatchNameTab,
	       t_TxnDateTab,
	       t_TxnCreatedByTab,
	       t_TxnUpdatedByTab,
	       t_invoiceIdTab,
	       t_sourceTab,
	       t_InvoiceNumberTab,
	       t_warrantyNumberTab,
	       t_ManufacturerTab,
	       t_SerialNumberTab,
	       t_ModelNumberTab,
	       t_linetypeLcdTab,
	       t_poDistIdTab,
	       t_RelatedIdTab,
	       t_DistLineNumberTab,
	       t_invDistIdTab,
	       t_DistCcidTab,
	       t_InvLineNumberTab,
	       t_RvrAssetsFlagTab,
	       t_SrcAssetsFlagTab,
	       t_parentInvDstIdTab,
	       t_apAssetsFlagTab,
	       t_DstMatchTypeTab,
               t_accTypeTab,
               t_XalccidTab,
	       t_ledgercatcdTab,
	       t_ledgeridTab,
	       t_invOrgIDTab,
	       t_ATrackFlagTab
         limit l_count ;

         IF t_eiIDTab.count = 0 THEN
            CLOSE c_apinv ;
            write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Exiting from main loop') ;
            EXIT ;
         END IF ;

         lRec          := 0   ;
         l_No_count    := 0   ;

         FOR indx in 1..t_eiIDTab.count LOOP

           l_ignore_cdl  := 'N' ;

           write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Expenditure Item ID:'||t_eiIDTab(indx)) ;
	   write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL Line Number:'||t_lineNumTab(indx)) ;
	   write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','t_cdlEventIDTab:'||t_cdlEventIDTab(indx) ) ;

           IF ( t_RvrAssetsFlagTab(indx) is NULL and t_SrcAssetsFlagTab(indx) is NULL ) THEN
              -- Latest CDL..
              --
	      l_ignore_cdl := 'N' ;
           ELSIF ( NVL(t_RvrAssetsFlagTab(indx), 'N')  <> 'Y' and NVL(t_SrcAssetsFlagTab(indx), 'N')  <> 'Y' ) THEN
	      write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','Reversing and reversed cdls are ignored' ) ;
	      l_ignore_cdl := 'Y' ;
	   END IF ;

	   -- =====
	   -- Bug : 5352018 R12.PJ:XB6:QA:APL:MASS ADDI CREATE PICKS UP ADJ FOR INV WHEN TRAC AS ASSET  DISA
	   -- ====

	   -- ====
	   -- BUG:5120276 R12.PJ:XB3:QA:APL:MASS ADDTIONS CREATE PROCESS PICKS UP ONLY PROJECT ADJUSTMENTS
	   -- ====

	   IF t_linetypeLcdTab(indx)  in ( 'ITEM', 'ACCRUAL', 'PA-ADJ') THEN
	      IF  t_ATrackFlagTab(indx) = 'N' THEN
	          write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL ignored because ap distribution not eligible' ) ;
		   l_ignore_cdl := 'Y' ;
	      END IF ;
	   ELSE
	      l_assets_tracking_flag := 'N' ;
	      open  c_assets_tracking_flagA ( t_RelatedIdTab(indx)) ;
	      fetch c_assets_tracking_flagA into l_assets_tracking_flag ;
	      close c_assets_tracking_flagA ;
	      IF ( NVL(l_assets_tracking_flag,'N') <>  'Y') THEN
	          write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL c_assets_tracking_flagA returns N for related ID '|| t_RelatedIdTab(indx) ) ;
	         open  c_assets_tracking_flagB ( t_parentInvDstIdTab(indx))  ;
	         fetch c_assets_tracking_flagB into l_assets_tracking_flag ;
	         close c_assets_tracking_flagB ;
	      END IF ;

	      IF l_assets_tracking_flag <> 'Y' THEN
	          write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL c_assets_tracking_flagA and B returns N  ' ) ;
		   l_ignore_cdl := 'Y' ;
	           t_ATrackFlagTab(indx) := 'N' ;
	      ELSE
	           write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL c_assets_tracking_flagA and B returns Y  ' ) ;
		   l_ignore_cdl := 'N' ;
	           t_ATrackFlagTab(indx) := 'Y' ;
	      END IF ;
	   END IF ;

           --IF t_apAssetsFlagTab(indx) = 'N' THEN
	    --  write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL ignored because ap distribution not eligible' ) ;
            -- l_ignore_cdl := 'Y' ;
           --END IF ;

           l_dummy := 0 ;

           IF t_sourceTab(indx) <> 'Intercompany' and
              --t_poDistIdTab(indx) is NULL and
              t_accTypeTab(indx) <> 'A' THEN

              l_ignore_cdl  := 'Y' ;
	      write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL does not belong to assets account.' ) ;

           END IF ;

           IF t_accTypeTab(indx) <> 'A' THEN

              l_ignore_cdl  := 'Y' ;
	      write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL does not belong to assets account.' ) ;

           END IF ;
	   --
	   -- AP interfaced regular distribution lines
	   -- We need to generate assets for CDLs adjustments.
	   --
           IF t_adjEiIdTab(indx)  is NULL and
	      t_TrFmEiIdTab(indx) is NULL THEN

	      IF t_LineNumTab(indx) = 1   THEN
	         l_ignore_cdl := 'Y' ;
	      END IF ;

	   END IF ;

	   --
	   -- l_ignore_cdl = 'N' identifies that CDL is valid for assets generations
	   --

	   IF l_ignore_cdl  = 'N' THEN

	      IF t_poDistIdTab(indx) is not NULL THEN
	         write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass',
		                                       'Getting asset_category_id for po distribution:'||t_poDistIdTab(indx));
                 select mtlsi.asset_category_id,
                        polt.order_type_lookup_code,
                        decode(pod.accrue_on_receipt_flag, 'Y', pod.code_combination_id, NULL ),
                        pod.deliver_to_person_id,
                        rtrim(upper(poh.segment1))
                   into l_assets_category_id,
                        l_po_order_type_lcd,
                        l_po_ccid,
                        l_assigned_to,
                        l_po_number
                   from po_distributions_all         pod,
                        po_headers                   poh,
                        po_lines_all                 pol,
                        po_line_types_b              polt,
                        mtl_system_items             mtlsi
                  where pod.po_distribution_id   = t_PoDistIdTab(indx)
                    and pod.po_header_id         = poh.po_header_id
                    and pod.po_line_id           = pol.po_line_id
                    and pol.line_type_id         = polt.line_type_id
                    and pol.item_id              = mtlsi.inventory_item_id(+)
		    and t_invOrgIDTab(indx)      = mtlsi.organization_id (+) ;

	          write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass',
		                                       'Asset_category_id for po distribution:'||l_assets_category_id);
              ELSE
                 l_assets_category_id := NULL ;
                 l_po_order_type_lcd  := NULL ;
                 l_po_ccid            := NULL ;
                 l_assigned_to        := NULL ;
                 l_po_number          := NULL ;
	      END IF ;
	      -- t_poDistIdTab(indx) is not NULL

              lRec                     := lRec+1 ;
              l_descriptionTab(lRec)   := t_descriptionTab(indx) ;
              l_ManufacturerTab(lRec)  := t_ManufacturerTab(indx) ;
              l_SerialNumberTab(lrec)  := t_SerialNumberTab(indx) ;
              l_ModelNumberTab(lrec)   := t_ModelNumberTab(indx) ;
	      l_BookTypCdTab(lrec)     := P_bt_code ;
              l_eiDateTab(lrec)        := t_eiDateTab(indx) ;
	      l_FACostTab(lrec)        := t_acctRawCostTab(indx) ;
	      -- Bug 5532231 R12.PJ:XB3:QA:APL:PREPARE MASS ADDITIONS SHOWS DUPLICATE ROWS
              l_PayUnitTab(lrec)       := 1 ;
              l_FAUnitTab(lrec)        := 1;

              l_assignedToTab(lrec)    := l_assigned_to ;
	      l_PoNumberTab(lrec)      := l_po_number ;
              l_assetsCatIDTab(lRec)   := l_assets_category_id ;

              l_payCostTab(lrec)       := t_acctRawCostTab(indx) ;
	      l_vendorNumberTab(lrec)  := t_vendorNumberTab(indx) ;
	      l_vendorIdTab(lrec)      := t_vendorIdTab(indx) ;
	      l_TxnDateTab(lrec)       := t_TxnDateTab(indx) ;
	      l_TxnCreatedByTab(lrec)  := t_TxnCreatedByTab(indx) ;
	      l_TxnUpdatedByTab(lrec)  := t_TxnUpdatedByTab(indx) ;
	      l_invoiceIdTab(lrec)     := t_invoiceIdTab(indx) ;
	      l_payBatchNameTab(lrec)  := t_payBatchNameTab(indx) ;
	      l_InvLineNumberTab(lrec) := t_InvLineNumberTab(indx) ;
              l_DistLineNumberTab(lrec):= t_DistLineNumberTab(indx) ;
              l_GlDateTab(lrec)        := t_GlDateTab(indx) ;
              l_InvoiceNumberTab(lrec) := t_InvoiceNumberTab(indx) ;
	      l_invDistIdtab(lrec)     := t_invDistIdtab(indx) ;
	      l_parentInvDstIdTab(lrec):= t_parentInvDstIdTab(indx) ;
              l_poDistIdTab(lRec)      := t_poDistIdTab(indx) ;
	      l_eiIDtab(lrec)          := t_eiIDtab(indx) ;
              l_lineNumTab(lrec)       := t_lineNumTab(indx) ;
	      l_warrantyNumberTab(lrec):= t_warrantyNumberTab(indx) ;
	      l_linetypeLcdtab(lrec)   := t_linetypeLcdtab(indx) ;
              l_cdlEventIDTab(lrec)    := t_cdlEventIDTab(indx) ;
              l_cdlQtyTab(lrec)        := t_cdlQtyTab(indx) ;
              l_payBatchNameTab(lrec)  := t_payBatchNameTab(indx) ;
	      l_ledgercatcdTab(lrec)   := t_ledgercatcdTab(indx) ;
	      l_ledgerIdTab(lrec)      := t_ledgerIdTab(indx) ;

              IF t_sourceTab(indx) = 'Intercompany' THEN
	         write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Intercompany Invoice' ) ;
	         l_PayCcidTab(lrec) := Inv_Fa_Interface_Pvt.Get_Ic_Ccid
	                            ( l_invDistIdTab(lrec),
			              t_DistCcidTab(indx),
				      l_linetypeLcdtab(lrec) ) ;
	      ELSE
	        l_payCCIDTab(lrec) := t_XalccidTab(indx) ;
	      END IF ;
	      write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Code combination ID:'|| l_payCCIDTab(lrec) ) ;
	   END IF ; -- l_ignore_cdl = 'N'

	   write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Ignore CDL flag value:'||l_ignore_cdl ) ;
	   IF l_ignore_cdl = 'Y' THEN
              l_No_count                     := l_No_count + 1;
              Flag_no_eiIDTab(l_No_count)    := t_eiIDtab(indx) ;
              Flag_no_lineNumTab(l_No_count) := t_lineNumTab(indx) ;
	   END IF ;

         END LOOP ; -- For loop end

         -- Mark the cdls as assets addition not required for the list of
         -- cdls identified by the Flag_no_lineNumTab and Flag_no_eiIdTab.
         IF Flag_no_eiIDTab.COUNT > 0 THEN

	    write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'Count of cdls ignored:'||Flag_no_eiIDTab.COUNT ) ;
            FORALL i in Flag_no_eiIDTab.FIRST..Flag_no_eiIDTab.LAST
               UPDATE pa_cost_distribution_lines
                  SET si_assets_addition_flag = 'N',
                      program_update_date     = SYSDATE,
                      program_application_id  = FND_GLOBAL.prog_appl_id,
                      program_id              = FND_GLOBAL.conc_program_id,
                      request_id              = p_request_id
                WHERE si_assets_addition_flag = 'T'
                  AND expenditure_item_id     =  Flag_no_eiIDTab(i)
                  AND line_num                = Flag_no_lineNumTab(i);
         END IF ;

         IF l_eiIDtab.count > 0 THEN
	    write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'FA_MASS_ADDITIONS_GT Count:'||l_eiIDtab.count) ;

            FORALL i in l_eiIDtab.FIRST..l_eiIDtab.LAST
               INSERT INTO FA_MASS_ADDITIONS_GT(
                           mass_addition_id,
                           description,
                           asset_category_id,
                           manufacturer_name,
                           serial_number,
                           model_number,
                           book_type_code,
                           transaction_date,
                           fixed_assets_cost,
                           payables_units,
                           fixed_assets_units,
                           payables_cost,
                           payables_code_combination_id,
                           assigned_to,
                           feeder_system_name,
                           create_batch_date,
                           create_batch_id,
                           last_update_date,
                           last_updated_by,
                           invoice_date,
                           invoice_created_by,
                           invoice_updated_by,
                           invoice_id,
                           invoice_number,
                           invoice_distribution_id,
                           invoice_line_number,
                           ap_distribution_line_number,
                           merge_invoice_number,
                           merge_vendor_number,
                           vendor_number,
                           po_vendor_id,
                           po_number,
                           payables_batch_name,
                           accounting_date,
                           created_by,
                           creation_date,
                           last_update_login,
                           parent_invoice_dist_id,
                           ledger_id,
                           ledger_category_code,
                           warranty_number,
                           line_type_lookup_code,
                           po_distribution_id,
                           expenditure_item_id,
                           line_num,
                           line_status ,
                           posting_status,
                           queue_name,
		           asset_number,
                           tag_number,
                           depreciate_flag,
                           parent_mass_addition_id,
                           parent_asset_id,
                           split_merged_code,
                           inventorial,
                           date_placed_in_service,
                           transaction_type_code,
                           expense_code_combination_id,
                           location_id,
                           reviewer_comments,
                           post_batch_id,
                           add_to_asset_id,
                           amortize_flag,
                           new_master_flag,
                           asset_key_ccid,
                           asset_type,
                           deprn_reserve,
                           ytd_deprn,
                           beginning_nbv,
                           salvage_value)
               SELECT  fa_mass_additions_s.nextval,
                           l_descriptionTab(i),
                           l_assetsCatIDTab(i) ,
	                   l_ManufacturerTab(i),
                           l_SerialNumberTab(i),
                           l_ModelNumberTab(i),
	                   l_BookTypCdTab(i) ,
	                   l_eiDateTab(i),
                           l_payCostTab(i),
                           l_PayUnitTab(i),
                           l_FAUnitTab(i),
                           l_payCostTab(i),
	                   l_payCCIDTab(i),
                           l_assignedToTab(i) ,
                           'ORACLE PROJECTS',
                           trunc(SYSDATE)	Create_batch_date,
                           P_request_id   	create_batch_id,
                           trunc(SYSDATE)    last_update_date,
                           p_user_id		last_update_by,
	                   l_TxnDateTab(i) ,
	                   l_TxnCreatedByTab(i),
	                   l_TxnUpdatedByTab(i),
	                   l_invoiceIdTab(i) ,
                           l_InvoiceNumberTab(i),
	                   l_invDistIdtab(i)  ,
	                   l_InvLineNumberTab(i),
                           l_DistLineNumberTab(i),
                           l_InvoiceNumberTab(i),
	                   l_vendorNumberTab(i),
	                   l_vendorNumberTab(i),
	                   l_vendorIdTab(i),
	                   l_PoNumberTab(i),
                           l_payBatchNameTab(i), --	Payables Batch Name,
                           l_GlDateTab(i) ,
                           p_user_id,	-- Created by
                           trunc(SYSDATE),	-- creation date
                           p_user_id, 	-- lst update login
	                   l_parentInvDstIdTab(i),
                           l_ledgerIdTab(i),
			   l_ledgercatcdTab(i) ,
	                   l_warrantyNumberTab(i),
	                   l_linetypeLcdtab(i),
                           l_poDistIdTab(i),
	                   l_eiIDtab(i),
                           l_lineNumTab(lrec) ,
	                   'NEW',
	                   'NEW',
	                   'NEW',
	                   NULL, 	-- assets_number
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL,
	                   NULL -- Salvage Value
                     FROM dual ;

               X_count := SQL%ROWCOUNT;

         END IF ; --IF l_eiIDtab.count > 0 THEN

       END LOOP ;
   --
       x_msg_count     := l_msg_count ;
       x_msg_data      := l_msg_data  ;
       x_return_status := l_return_status ;
    EXCEPTION
       WHEN OTHERS THEN
            --
	    write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass', 'When Others:'||SQLERRM ) ;
            APP_EXCEPTION.RAISE_EXCEPTION;
            --
    END Insert_Mass;

    -- Procedure will Insert Discount related to distributions that are tracked
    -- as asset in FA_MASS_ADDITIONS_GT table
    --
    PROCEDURE  Insert_Discounts(p_api_version          IN    number,
                               p_init_msg_list	       IN    varchar2 default FND_API.G_FALSE,
			       p_commit	    	       IN    varchar2 default FND_API.G_FALSE,
			       p_validation_level      IN    number   default FND_API.G_VALID_LEVEL_FULL,
                               x_return_status	       OUT   NOCOPY varchar2,
	                       x_msg_count	       OUT   NOCOPY number,
	                       x_msg_data	       OUT   NOCOPY varchar2,
			       x_count                 OUT   NOCOPY number,
                               P_acctg_date            IN    DATE,
                               P_ledger_id             IN    number,
                               P_user_id               IN    number,
                               P_request_id            IN    number,
                               P_bt_code               IN    varchar2,
                               P_primary_accounting_method IN    varchar2,
                               P_calling_sequence          IN    varchar2 DEFAULT NULL) IS
    --
    l_current_calling_sequence   varchar2(2000);
    l_debug_info                 varchar2(2000);
    l_request_id                 number;
    l_count                      number;
    l_api_name           CONSTANT  varchar2(100) := 'INSERT_DISCOUNTS';
    lrec	         number ;
    l_No_count           number ;
    l_ignore_cdl         varchar2(1) ;
    l_assets_category_id number ;
    l_po_order_type_lcd  varchar2(25) ;
    l_po_ccid            number ;
    l_assigned_to        number ;
    l_po_number          varchar2(20) ;
    l_dummy              number ;

    l_msg_count        number ;
    l_msg_data         varchar2(2000) ;
    l_return_status    varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;
    l_assets_tracking_flag varchar2(1) ;
    --
    -- Bug 5532231 R12.PJ:XB3:QA:APL:PREPARE MASS ADDITIONS SHOWS DUPLICATE ROWS
    -- line type lookup code was changed to DISCOUNTS
    --
    cursor c_apinv is
    select ei.expenditure_item_id,
    	   ei.expenditure_item_date ,
           cdl.line_num,
           ei.document_header_id,
           ei.document_distribution_id,
           ei.document_payment_id,
           ei.document_line_number,
           ei.document_type,
           ei.document_distribution_type,
           ei.transaction_source,
           RTRIM(SUBSTRB(eic.expenditure_comment,1,80)) description,
	   (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)) acct_raw_cost,
           --cdl.acct_raw_cost				acct_raw_cost,
	   cdl.gl_date,
	   cdl.acct_event_id,
           cdl.quantity,
           ei.net_zero_adjustment_flag,
           ei.adjusted_expenditure_item_id,
           ei.transferred_from_exp_item_id,
           ei.vendor_id,
           rtrim(POV.segment1)  vendor_number,
           apb.batch_name,
           api.invoice_date,
           cdl.created_by       invoice_created_by,
           ei.last_updated_by   invoice_updated_by,
           api.invoice_id	invoice_id,
           api.source,
           rtrim(api.invoice_num) invoice_num,
           apil.warranty_number,
           apil.manufacturer,
           apil.serial_number,
           apil.model_number,
	   apd.line_type_lookup_code line_type_lookup_code,
           apd.po_distribution_id,
           apd.related_id,
           apd.distribution_line_number,
           apd.invoice_distribution_id,
           apd.dist_code_combination_id,
           apd.invoice_line_number,
           decode(cdl.reversed_flag, NULL, NULL,
                      ( select cdl2.si_assets_addition_flag
                        from pa_cost_distribution_lines_all cdl2
                       where cdl2.expenditure_item_id = cdl.expenditure_item_id
                         and cdl2.line_num_reversed   = cdl.line_num ) ) reversed_assets_flag,
           decode(cdl.line_num_reversed, NULL, NULL,
                      ( select cdl2.si_assets_addition_flag
                        from pa_cost_distribution_lines_all cdl2
                       where cdl2.expenditure_item_id = cdl.expenditure_item_id
                         and cdl2.line_num            = cdl.line_num_reversed ) ) source_assets_flag,
           DECODE(apd.line_type_lookup_code,
                      'ITEM',   decode(apd.corrected_invoice_dist_id,
                                           NULL, apd.invoice_distribution_id,
                                                 apd.corrected_invoice_dist_id),
                      'ACCRUAL',decode(apd.corrected_invoice_dist_id,
                                           NULL, apd.invoice_distribution_id,
                                           apd.corrected_invoice_dist_id),
                                apd.charge_applicable_to_dist_id  ) parent_invoice_dist_id,
           apip.assets_addition_flag            ap_assets_addition_flag,
           apd.dist_match_type,
           glcc.account_type ,
           xal.code_combination_id,
	   algt.ledger_category_code,
	   algt.ledger_id,
	   fsp.inventory_organization_id,
	   apd.assets_tracking_flag
     from  pa_expenditure_items 	ei,
           pa_expenditure_comments  	eic,
           pa_cost_distribution_lines 	cdl,
           ap_invoices                	api,
           ap_invoice_lines           	apil,
           ap_invoice_distributions   	apd,
	   financials_system_params_all fsp,
	   ap_invoice_payments          apip,
           ap_batches_all               apb,
           po_vendors                 	pov,
           xla_distribution_links       xdl,
           xla_ae_headers               xah,
           xla_ae_lines                 xal,
	   ap_alc_ledger_gt             algt,
	   ap_acct_class_code_gt        aagt,
           gl_code_combinations         glcc,
	   pa_projects_all              p,
	   pa_project_types_all         pt
    where  ei.expenditure_item_id       = cdl.expenditure_item_id
      and  cdl.expenditure_item_id      = eic.expenditure_item_id (+)
      and  cdl.line_num                 = eic.line_number (+)
      and  ei.transaction_source in ('AP DISCOUNTS')
      and  cdl.gl_date                  <= P_acctg_date
      and  cdl.line_type                = 'R'
      and  cdl.transfer_status_code     = 'A'
      and  cdl.si_assets_addition_flag  = 'T'
      and  cdl.project_id               = p.project_id
      and  p.project_type               = pt.project_type
      and  p.org_id                     = pt.org_id
      and  pt.project_type_class_code   <> 'CAPITAL'
      and  ei.document_header_id        = api.invoice_id
      and  ei.document_distribution_id  = apd.invoice_distribution_id
      and  ei.document_line_number      = apd.invoice_line_number
      and  apil.invoice_id              = api.invoice_id
      and  api.org_id                   = fsp.org_id
      and  apil.line_number             = apd.invoice_line_number
      and  API.batch_id                 = apb.batch_id(+)
      and  apd.posted_flag              = 'Y'
      --and  apd.cash_posted_flag       = 'Y'
      --and  apd.assets_addition_flag     = 'Y'
      and  api.vendor_id                = pov.vendor_id
      and  ei.document_payment_id       = apip.invoice_payment_id
      and  apip.accounting_date        <= P_acctg_date
      and  apip.set_of_books_id         = P_ledger_id
      AND  xah.application_id 	        = 275
      -- 5911379: Modified the join
      and  xdl.application_id 	        = xah.application_id
      and  xah.event_id       	        = cdl.acct_event_id
      AND  xah.balance_type_code        = 'A'
      and  xah.accounting_entry_status_code = 'F'
      and  xal.application_id 	        = xah.application_id
      AND  xal.ae_header_id             = xah.ae_header_id
      and  xal.accounting_class_code    = aagt.accounting_class_code
      and  xdl.event_id       	        = xah.event_id
      AND  xdl.ae_header_id             = xal.ae_header_id
      AND  xdl.ae_line_num              = xal.ae_line_num
      and  xdl.application_id 	        = xal.application_id
      and  xdl.source_distribution_id_num_1 = ei.expenditure_item_id
      and  xdl.source_distribution_id_num_2 = cdl.line_num
      AND  xah.ledger_id                = algt.ledger_id
      and  decode(algt.org_id, -99, algt.org_id, cdl.org_id) =
           decode(algt.org_id, -99, -99, algt.org_id)
      and  glcc.code_combination_id      = xal.code_combination_id
      -- 5911379: ends
     order by ei.document_distribution_id, ei.expenditure_item_id, cdl.line_num  ;

    BEGIN
	    l_current_calling_sequence := P_calling_sequence||'->'||
			    'Insert_Discounts';
	    l_count := 1000;

	    fnd_profile.get('PA_DEBUG_MODE',G_debug_mode);
	    G_debug_mode := NVL(G_debug_mode, 'N');

	    -- Standrad call to check API compatibility.
	    IF NOT FND_API.Compatible_API_Call( G_api_version,
						p_api_version,
    					'INSERT_DISCOUNTS',
    					G_pkg_name) THEN

	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	    END IF ;

	    -- Initialize message list if p_init_msg_list is set to TRUE
	    --
	    IF FND_API.to_boolean( p_init_msg_list) THEN

	       FND_MSG_PUB.initialize ;

	    END IF ;

	    -- Initialize API return status to success.
	    --
	    l_return_status  := FND_API.G_RET_STS_SUCCESS ;
	    write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Begin discount processing.') ;

	    write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Begin Main LOOP.') ;
	    open c_apinv ;

	    LOOP
	      write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Init PLSQL Tab variables.') ;
	      initPLSQLTab ;
	      l_No_count  := 0 ;
	      lrec        := 0 ;
	      fetch c_apinv
	      bulk collect into t_eiIDTab,
		     t_eiDateTab,
		     t_lineNumTab,
		     t_DocHeaderIdTab,
		     t_DocDistIdTab,
		     t_DocPaymentIdTab,
		     t_DocLineNumberTab,
		     t_DocTypeTab,
		     t_DocDistTypeTab,
		     t_transSourceTab,
		     t_descriptionTab,
		     t_acctRawCostTab,
		     t_GlDateTab,
		     t_cdlEventIDTab,
		     t_cdlQtyTab,
		     t_NZAdjFlagTab,
		     t_adjEiIdTab,
		     t_trFmEiIdTab,
		     t_vendorIdTab,
		     t_vendorNumberTab,
		     t_payBatchNameTab,
		     t_TxnDateTab,
		     t_TxnCreatedByTab,
		     t_TxnUpdatedByTab,
		     t_invoiceIdTab,
		     t_sourceTab,
		     t_InvoiceNumberTab,
		     t_warrantyNumberTab,
		     t_ManufacturerTab,
		     t_SerialNumberTab,
		     t_ModelNumberTab,
		     t_linetypeLcdTab,
		     t_poDistIdTab,
		     t_RelatedIdTab,
		     t_DistLineNumberTab,
		     t_invDistIdTab,
		     t_DistCcidTab,
		     t_InvLineNumberTab,
		     t_RvrAssetsFlagTab,
		     t_SrcAssetsFlagTab,
		     t_parentInvDstIdTab,
		     t_apAssetsFlagTab,
		     t_DstMatchTypeTab,
		     t_accTypeTab,
		     t_XalccidTab,
		     t_ledgercatcdTab,
		     t_ledgerIdTab ,
		     t_InvOrgIDTab,
		     t_ATrackFlagTab
	      limit l_count ;

	      IF t_eiIDTab.count = 0 THEN
		 close c_apinv ;
	         write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Leaving main LOOP.') ;
		 exit ;
	      END IF ;

	      lRec:= 0 ;

	      FOR indx in 1..t_eiIDTab.count LOOP
	           l_ignore_cdl := 'N' ;
	           write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Exp Item ID:'||t_eiIDTab(indx)) ;
	           write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'CDL Line num:'||t_lineNumTab(indx)) ;

		   IF t_RvrAssetsFlagTab(indx) is NULL  and t_SrcAssetsFlagTab(indx) is NULL  THEN
		      l_ignore_cdl := 'N' ;
		   ELSIF NVL(t_RvrAssetsFlagTab(indx), 'N') <> 'Y' and
		         NVL(t_SrcAssetsFlagTab(indx), 'N') <> 'Y' THEN
		      l_ignore_cdl := 'Y' ;
		   END IF ;

	           -- =====
	           -- Bug : 5352018 R12.PJ:XB6:QA:APL:MASS ADDI CREATE PICKS UP ADJ FOR INV WHEN TRAC AS ASSET  DISA
	           -- ====
	           -- ====
	           -- BUG:5120276 R12.PJ:XB3:QA:APL:MASS ADDTIONS CREATE PROCESS PICKS UP ONLY PROJECT ADJUSTMENTS
	           -- ====
		   -- Bug : 5532231 Discounts for tax line was not proceseed.
		   --

	           IF t_linetypeLcdTab(indx) in ( 'ITEM', 'ACCRUAL', 'DISCOUNT') THEN
	              IF  t_ATrackFlagTab(indx) = 'N' THEN
	                  write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL ignored because ap distribution not eligible' ) ;
		          l_ignore_cdl := 'Y' ;
	              END IF ;
	           ELSE
	              l_assets_tracking_flag := 'N' ;
	              open  c_assets_tracking_flagA ( t_RelatedIdTab(indx)) ;
	              fetch c_assets_tracking_flagA into l_assets_tracking_flag ;
	              close c_assets_tracking_flagA ;
	              IF ( NVL(l_assets_tracking_flag,'N') <>  'Y') THEN
	                 write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL c_assets_tracking_flagA returns N ') ;
	                 open  c_assets_tracking_flagB ( t_parentInvDstIdTab(indx)) ;
	                 fetch c_assets_tracking_flagB into l_assets_tracking_flag ;
	                 close c_assets_tracking_flagB ;
	              END IF ;

	              IF l_assets_tracking_flag <> 'Y' THEN
	                 write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL c_assets_tracking_flagA  and B returns N ') ;
		         l_ignore_cdl := 'Y' ;
	                 t_ATrackFlagTab(indx) := 'N' ;
	              ELSE
	                 write_to_log(FND_LOG.LEVEL_STATEMENT, '10:PA Insert_mass','CDL c_assets_tracking_flagA  or  B returns Y ') ;
		         l_ignore_cdl := 'N' ;
	                 t_ATrackFlagTab(indx) := 'Y' ;
	              END IF ;
	           END IF ;
		   -- 5532231 R12.PJ:XB3:QA:APL:PREPARE MASS ADDITIONS SHOWS DUPLICATE ROWS
		   t_linetypeLcdTab(indx) := 'DISCOUNT' ;

		   IF t_ATrackFlagTab(indx) = 'N' THEN
		      l_ignore_cdl := 'Y' ;
		   END IF ;

		   --IF t_apAssetsFlagTab(indx) = 'N' THEN
		   --   l_ignore_cdl := 'Y' ;
		   --END IF ;

	           write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Invoice Source:'||t_sourceTab(indx)) ;
	           write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Account Type  :'||t_accTypeTab(indx)) ;

		   IF t_accTypeTab(indx) <> 'A' THEN
		      l_ignore_cdl  := 'Y' ;
		   END IF ;

		   IF t_adjEiIdTab(indx)  is NULL and
		      t_TrFmEiIdTab(indx) is NULL THEN

			   IF t_LineNumTab(indx) = 1  THEN
			      l_ignore_cdl := 'Y' ;
			   END IF ;

	           END IF ;
	           write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Ignore CDL    :'||l_ignore_cdl) ;

		   IF l_ignore_cdl  = 'N' THEN

			   IF t_poDistIdTab(indx) is not NULL THEN
	                      write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'PO DistributionID:'||t_poDistIdTab(indx));
			      SELECT mtlsi.asset_category_id,
				     polt.order_type_lookup_code,
				     decode(pod.accrue_on_receipt_flag, 'Y', pod.code_combination_id, NULL ),
				     pod.deliver_to_person_id,
				     rtrim(upper(poh.segment1))
				into l_assets_category_id,
				     l_po_order_type_lcd,
				     l_po_ccid,
				     l_assigned_to,
				     l_po_number
				FROM po_distributions_all         pod,
				     po_headers                   poh,
				     po_lines_all                 pol,
				     po_line_types_b              polt,
				     mtl_system_items             mtlsi
			       WHERE pod.po_distribution_id   = t_PoDistIdTab(indx)
				 AND pod.po_header_id         = poh.po_header_id
				 AND pod.po_line_id           = pol.po_line_id
				 AND pol.line_type_id         = polt.line_type_id
				 AND pol.item_id              = mtlsi.inventory_item_id(+)
				 AND t_InvOrgIDTab(indx)      = mtlsi.organization_id (+) ;

	                        write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS',
		                         'Asset_category_id for po distribution:'||l_assets_category_id);
			  ELSE
			       l_assets_category_id := NULL ;
			       l_po_order_type_lcd  := NULL ;
			       l_po_ccid            := NULL ;
			       l_assigned_to        := NULL ;
			       l_po_number          := NULL ;
			  END IF ; -- t_poDistIdTab(indx) is not NULL
			  lRec                        := lRec+1 ;
			  l_descriptionTab(lRec)   := t_descriptionTab(indx) ;
			  l_ManufacturerTab(lRec)  := t_ManufacturerTab(indx) ;
			  l_SerialNumberTab(lrec)  := t_SerialNumberTab(indx) ;
			  l_ModelNumberTab(lrec)   := t_ModelNumberTab(indx) ;
			  l_eiDateTab(lrec)        := t_eiDateTab(indx) ;
			  l_FACostTab(lrec)        := t_acctRawCostTab(indx) ;
			  -- -- Bug 5532231 R12.PJ:XB3:QA:APL:PREPARE MASS ADDITIONS SHOWS DUPLICATE ROWS
			  --
			  l_PayUnitTab(lrec)       := 1 ;
			  l_FAUnitTab(lrec)        := 1 ;
			  l_assignedToTab(lrec)    := l_assigned_to ;
			  l_assetsCatIDTab(lRec)   := l_assets_category_id ;
			  l_BookTypCdTab(lrec)     := P_bt_code ;
			  l_PoNumberTab(lrec)      := l_po_number ;
			  l_payCostTab(lrec)       := t_acctRawCostTab(indx) ;
			  l_vendorNumberTab(lrec)  := t_vendorNumberTab(indx) ;
			  l_vendorIdTab(lrec)      := t_vendorIdTab(indx) ;
			  l_TxnDateTab(lrec)       := t_TxnDateTab(indx) ;
			  l_TxnCreatedByTab(lrec)  := t_TxnCreatedByTab(indx) ;
			  l_TxnUpdatedByTab(lrec)  := t_TxnUpdatedByTab(indx) ;
			  l_invoiceIdTab(lrec)     := t_invoiceIdTab(indx) ;
			  l_InvLineNumberTab(lrec) := t_InvLineNumberTab(indx) ;
			  l_DistLineNumberTab(lrec):= t_DistLineNumberTab(indx) ;
			  l_GlDateTab(lrec)        := t_GlDateTab(indx) ;
			  l_InvoiceNumberTab(lrec) := t_InvoiceNumberTab(indx) ;
			  l_invDistIdtab(lrec)     := t_invDistIdtab(indx) ;
			  l_parentInvDstIdTab(lrec):= t_parentInvDstIdTab(indx) ;
			  l_poDistIdTab(lRec)      := t_poDistIdTab(indx) ;
			  l_eiIDtab(lrec)          := t_eiIDtab(indx) ;
			  l_lineNumTab(lrec)       := t_lineNumTab(indx) ;
			  l_warrantyNumberTab(lrec):= t_warrantyNumberTab(indx) ;
			  l_linetypeLcdtab(lrec)   := t_linetypeLcdtab(indx) ;
			  l_cdlEventIDTab(lrec)    := t_cdlEventIDTab(indx) ;
			  l_payBatchNameTab(lrec)  := t_payBatchNameTab(indx) ;
			  l_ledgerCatCdTab(lrec)   := t_ledgercatcdTab(indx) ;
			  l_ledgeridTab(lrec)        := t_ledgeridTab(indx) ;

			  IF t_sourceTab(indx) =  'Intercompany' THEN
			     l_PayCcidTab(lrec) := Inv_Fa_Interface_Pvt.Get_Ic_Ccid
						    ( l_invDistIdTab(lrec),
						      t_DistCcidTab(indx),
						      l_linetypeLcdtab(lrec)) ;
			  ELSE
				l_payCCIDTab(lrec) := t_XalccidTab(indx) ;
			  END IF ;
		   END IF ;    -- l_ignore_cdl = 'N'

		   IF l_ignore_cdl = 'Y' THEN
		      l_No_count                     := l_No_count + 1;
		      Flag_no_eiIDTab(l_No_count)    := t_eiIDtab(indx) ;
		      Flag_no_lineNumTab(l_No_count) := t_lineNumTab(indx) ;
		   END IF ;
              END LOOP ; -- Index for fetch

	      IF Flag_no_eiIDTab.COUNT > 0 THEN
	           write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'Flag_no_eiIDTab.COUNT:'||Flag_no_eiIDTab.COUNT) ;

		   FORALL i in Flag_no_eiIDTab.FIRST..Flag_no_eiIDTab.LAST
			  UPDATE pa_cost_distribution_lines
			     SET si_assets_addition_flag = 'N',
				 program_update_date     = SYSDATE,
				 program_application_id  = FND_GLOBAL.prog_appl_id,
				 program_id              = FND_GLOBAL.conc_program_id,
				 request_id              = p_request_id
			   WHERE si_assets_addition_flag in ('T', 'O')
			     AND expenditure_item_id =  Flag_no_eiIDTab(i)
			     AND line_num            =  Flag_no_lineNumTab(i);
	      END IF ;

              IF l_eiIDtab.count > 0 THEN
	         write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'eiIDTab.COUNT:'||l_eiIDTab.COUNT) ;

		    FORALL i in l_eiIDtab.FIRST..l_eiIDtab.LAST
		      INSERT INTO FA_MASS_ADDITIONS_GT(
				    mass_addition_id,
				    description,
				    asset_category_id,
				    manufacturer_name,
				    serial_number,
				    model_number,
				    book_type_code,
				    transaction_date,
				    fixed_assets_cost,
				    payables_units,
				    fixed_assets_units,
				    payables_cost,
				    payables_code_combination_id,
				    assigned_to,
				    feeder_system_name,
				    create_batch_date,
				    create_batch_id,
				    last_update_date,
				    last_updated_by,
				    invoice_date,
				    invoice_created_by,
				    invoice_updated_by,
				    invoice_id,
				    invoice_number,
				    invoice_distribution_id,
				    invoice_line_number,
				    ap_distribution_line_number,
				    merge_invoice_number,
				    merge_vendor_number,
				    vendor_number,
				    po_vendor_id,
				    po_number,
				    payables_batch_name,
				    accounting_date,
				    created_by,
				    creation_date,
				    last_update_login,
				    parent_invoice_dist_id,
				    ledger_id,
				    ledger_category_code,
				    warranty_number,
				    line_type_lookup_code,
				    po_distribution_id,
				    expenditure_item_id,
				    line_num,
				    line_status ,
				    posting_status,
				    queue_name,
				    inventorial,
				    asset_number,
				    tag_number,
				    depreciate_flag,
				    parent_mass_addition_id,
				    parent_asset_id,
				    split_merged_code,
				    date_placed_in_service,
				    transaction_type_code,
				    expense_code_combination_id,
				    location_id,
				    reviewer_comments,
				    post_batch_id,
				    add_to_asset_id,
				    amortize_flag,
				    new_master_flag,
				    asset_key_ccid,
				    asset_type,
				    deprn_reserve,
				    ytd_deprn,
				    beginning_nbv,
				    salvage_value
				    )
		      SELECT  fa_mass_additions_s.nextval,
			      l_descriptionTab(i),
			      l_assetsCatIDTab(i),
			      l_ManufacturerTab(i),
			      l_SerialNumberTab(i),
			      l_ModelNumberTab(i),
			      l_BookTypCdTab(i) ,
			      l_eiDateTab(i),
			      l_payCostTab(i),
			      l_PayUnitTab(i),
			      l_FAUnitTab(i),
			      l_payCostTab(i),
			      l_payCCIDTab(i),
			      l_assignedToTab(i) ,
			      'ORACLE PROJECTS',
			      trunc(SYSDATE)	Create_batch_date,
			      P_request_id   	create_batch_id,
			      trunc(SYSDATE)    last_update_date,
			      p_user_id		last_update_by,
			      l_TxnDateTab(i) ,
			      l_TxnCreatedByTab(i),
			      l_TxnUpdatedByTab(i),
			      l_invoiceIdTab(i) ,
			      l_InvoiceNumberTab(i),
			      l_invDistIdtab(i)  ,
			      l_InvLineNumberTab(i),
			      l_DistLineNumberTab(i),
			      l_InvoiceNumberTab(i),
			      l_vendorNumberTab(i),
			      l_vendorNumberTab(i),
			      l_vendorIdTab(i),
			      l_PoNumberTab(i),
			      l_payBatchNameTab(i), --	Payables Batch Name,
			      l_GlDateTab(i) ,
			      p_user_id,	-- Created by
			      trunc(SYSDATE),	-- creation date
			      p_user_id, 	-- lst update login
			      l_parentInvDstIdTab(i),
			      l_ledgerIdTab(i) ,
			      l_ledgercatcdTab(i) ,
			      l_warrantyNumberTab(i),
			      'DISCOUNT' ,                    --l_linetypeLcdtab(i),
			      l_poDistIdTab(i),
			      l_eiIDtab(i),
			      l_lineNumTab(lrec) ,
			      'NEW',
			      'NEW',
			      'NEW',
			      'Yes',    --inventorial,
			      NULL, 	-- assets_number
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL -- Salvage Value
			from DUAL ;

                    X_count := NVL(x_count,0) + SQL%ROWCOUNT;
              END IF ; -- end of  l_eiIDtab.count
            END LOOP ; -- main loop

	    x_msg_count     := l_msg_count ;
	    x_msg_data      := l_msg_data  ;
	    x_return_status := l_return_status ;
    EXCEPTION
      WHEN OTHERS THEN
	   write_to_log(FND_LOG.LEVEL_STATEMENT, '40:INSERT_DISCOUNTS', 'EXCEPTION:'||SQLERRM) ;
           l_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
           APP_EXCEPTION.RAISE_EXCEPTION;
    END Insert_Discounts;

    -- Start of comments
    -- -----------------
    -- API Name		: update_mass
    -- Type		: update the si_assets_addition_flag on CDLS
    -- Pre Reqs		: None
    -- Function		: This API tieback assets generated transactions.
    -- Calling API      : Ap_Mass_Additions_Create_Pkg
    -- End of comments
    -- ----------------
    --
    -- Code hook called from AP mass addition Program.
    --
    PROCEDURE update_mass (p_api_version      IN number,
                           p_init_msg_list    IN varchar2 default FND_API.G_FALSE,
                           p_commit           IN varchar2 default FND_API.G_FALSE,
                           p_validation_level IN number   default FND_API.G_VALID_LEVEL_FULL,
                           x_return_status    OUT NOCOPY  varchar2,
                           x_msg_count        OUT NOCOPY  number,
                           x_msg_data         OUT NOCOPY  varchar2,
                           p_request_id       IN number  ) is

     l_msg_count       number ;
     l_msg_data        varchar2(2000) ;
     l_return_status   varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;

   BEGIN

        fnd_profile.get('PA_DEBUG_MODE',G_debug_mode);
        G_debug_mode := NVL(G_debug_mode, 'N');

    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    'UPDATE_MASS',
    					    G_pkg_name) THEN

    	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    	END IF ;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	--
    	IF FND_API.to_boolean( p_init_msg_list) THEN

    	   FND_MSG_PUB.initialize ;

    	END IF ;

    	-- Initialize API return status to success.
    	--
    	l_return_status  := FND_API.G_RET_STS_SUCCESS ;

        IF (g_debug_mode = 'Y') THEN
	    write_to_log(FND_LOG.LEVEL_STATEMENT,'50:UPDATE_MASS','UPDATE MASS Processing begins.') ;
        END IF;

        -- Successfully assets generated transactions
        --
        UPDATE pa_cost_distribution_lines
         SET si_assets_addition_flag = 'Y',
             program_update_date     = SYSDATE,
             program_application_id  = FND_GLOBAL.prog_appl_id,
             program_id              = FND_GLOBAL.conc_program_id,
             request_id              = p_request_id
         where si_assets_addition_flag = ('T')
           AND (expenditure_item_id, line_num ) in
                    (SELECT expenditure_item_id, line_num
                       FROM fa_mass_additions_gt
                      WHERE line_status  = 'PROCESSED') ;

        IF (g_debug_mode = 'Y') THEN
	    write_to_log(FND_LOG.LEVEL_STATEMENT,'50:UPDATE_MASS','UPDATE MASS Record processed:'||SQL%ROWCOUNT );
        END IF;

        -- Flag the transactions where we do not need assets generations
        -- Waiting for FA team Feedback and the condition...????
        --
        -- Rejected assets generated transactions
        --
        UPDATE pa_cost_distribution_lines
         SET si_assets_addition_flag = 'N',
             program_update_date     = SYSDATE,
             program_application_id  = FND_GLOBAL.prog_appl_id,
             program_id              = FND_GLOBAL.conc_program_id,
             request_id              = p_request_id
         where si_assets_addition_flag = ('T')
           AND (expenditure_item_id, line_num ) in
                    (SELECT expenditure_item_id, line_num
                       FROM fa_mass_additions_gt
                      WHERE line_status  = 'REJECTED') ;

        IF (g_debug_mode = 'Y') THEN
	    write_to_log(FND_LOG.LEVEL_STATEMENT,'50:UPDATE_MASS', 'UPDATE MASS Record processed with N-status:'||SQL%ROWCOUNT);
        END IF;

        x_msg_count     := l_msg_count ;
        x_msg_data      := l_msg_data  ;
        x_return_status := l_return_status ;
   END update_mass ;
   --
   --
   -- =====================================================
   PROCEDURE  Insert_Receipts(
                           P_acctg_date                IN    DATE,
                           P_ledger_id                 IN    number,
                           P_user_id                   IN    number,
                           P_request_id                IN    number,
                           P_bt_code                   IN    varchar2,
                           P_primary_accounting_method IN    varchar2,
                           P_calling_sequence          IN    varchar2 DEFAULT NULL) IS
    --
    l_current_calling_sequence   varchar2(2000);
    l_debug_info                 varchar2(2000);
    l_request_id                 number;
    l_count                      number;
    l_api_name         CONSTANT  varchar2(100) := 'INSERT_MASS';
    lrec	          number ;
    l_No_count           number ;
    l_ignore_cdl         varchar2(1) ;
    l_assets_category_id number ;
    l_po_order_type_lcd  varchar2(25) ;
    l_po_ccid            number ;
    l_assigned_to        number ;
    l_po_number          Varchar2(20) ;
    l_dummy              number ;

    --

    cursor c_apinv is
    select ei.expenditure_item_id,
    	   ei.expenditure_item_date ,
           cdl.line_num,
           ei.document_header_id,
           ei.document_distribution_id,
           ei.document_payment_id,
           ei.document_line_number,
           ei.document_type,
           ei.document_distribution_type,
           ei.transaction_source,
           RTRIM(SUBSTRB(eic.expenditure_comment,1,80)) description,
	   (NVL(XDL.unrounded_accounted_dr,0) - NVL(XDL.unrounded_accounted_cr,0)) acct_raw_cost,
           --cdl.acct_raw_cost				acct_raw_cost,
	   cdl.gl_date,
	   cdl.acct_event_id,
           cdl.quantity,
           ei.net_zero_adjustment_flag,
           ei.adjusted_expenditure_item_id,
           ei.transferred_from_exp_item_id,
           ei.vendor_id,
           rtrim(POV.segment1)  vendor_number,
           NULL, --Batch_name
           rcvtxn.transaction_date,
           rcvtxn.created_by       txn_created_by,
           rcvtxn.last_updated_by  txn_updated_by,
           NULL	                invoice_id,
           NULL,                --api.source,
           NULL,                --rtrim(api.invoice_num) invoice_num,
           NULL,                --warranty_number,
           NULL,                --manufacturer,
           NULL,                --serial_number,
           NULL,                --model_number,
           'ACCRUAL',           --line_type_lookup_code,
           rcvtxn.po_distribution_id,
           NULL,                --apd.related_id,
           NULL,                --distribution_line_number,
           NULL,                --apd.invoice_distribution_id,
           NULL,                --dist_code_combination_id,
           NULL,                --apd.invoice_line_number
           decode(cdl.reversed_flag, NULL, NULL,
                      ( select cdl2.si_assets_addition_flag
                        from pa_cost_distribution_lines_all cdl2
                       where cdl2.expenditure_item_id = cdl.expenditure_item_id
                         and cdl2.line_num_reversed   = cdl.line_num ) ) reversed_assets_flag,
           decode(cdl.line_num_reversed, NULL, NULL,
                      ( select cdl2.si_assets_addition_flag
                        from pa_cost_distribution_lines_all cdl2
                       where cdl2.expenditure_item_id = cdl.expenditure_item_id
                         and cdl2.line_num            = cdl.line_num_reversed ) ) source_assets_flag,
            NULL parent_invoice_dist_id,
            'Y'  txn_assets_addition_flag,
            glcc.account_type ,
            xal.code_combination_id,
	    algt.ledger_category_code,
	    algt.ledger_id,
	    fsp.inventory_organization_id
     from  pa_cost_distribution_lines 	cdl,
           xla_ae_headers               xah,
	   xla_ae_lines                 xal,
	   xla_distribution_links       xdl,
           pa_expenditure_items 	ei,
           pa_expenditure_comments  	eic,
           rcv_transactions             rcvtxn ,
	   po_distributions             pod,
	   financials_system_params_all fsp,
           po_vendors                 	pov,
           ap_alc_ledger_gt             algt,
           ap_acct_class_code_gt        aagt,
           gl_code_combinations         glcc,
	   pa_projects_all              p,
	   pa_project_types_all         pt
    where  ei.expenditure_item_id       = cdl.expenditure_item_id
      and  cdl.expenditure_item_id      = eic.expenditure_item_id (+)
      and  cdl.line_num                 = eic.line_number (+)
      and  ei.transaction_source in ('PO RECEIPT',
                                     'PO RECEIPT NRTAX',
				     'PO RECEIPT NRTAX PRICE ADJ',
                                     'PO RECEIPT PRICE ADJ')
      and  cdl.gl_date                  <= P_acctg_date
      and  cdl.line_type                = 'R'
      and  cdl.transfer_status_code     = 'A'
      and  cdl.si_assets_addition_flag  = 'T'
      and  cdl.project_id               = p.project_id
      and  p.project_type               = pt.project_type
      -- Bug : 5368600
      and  p.org_id                     = pt.org_id
      and  pt.project_type_class_code   <> 'CAPITAL'
      and  ei.document_distribution_id  = rcvtxn.transaction_id
      and  pod.po_distribution_id       = rcvtxn.po_distribution_id
      and  pod.org_id                   = fsp.org_id
      and  ei.vendor_id                 = pov.vendor_id
      -- 5911379: Modified the join
      and  xdl.application_id 	        = xah.application_id
      AND  xah.application_id 	        = 275
      and  xah.event_id       	        = cdl.acct_event_id
      AND  xah.balance_type_code        = 'A'
      and  xah.accounting_entry_status_code = 'F'
      and  xal.application_id 	        = xah.application_id
      AND  xal.ae_header_id             = xah.ae_header_id
      and  xal.accounting_class_code    = aagt.accounting_class_code
      and  xdl.event_id       	        = xah.event_id
      AND  xdl.ae_header_id             = xal.ae_header_id
      AND  xdl.ae_line_num              = xal.ae_line_num
      and  xdl.application_id 	        = xal.application_id
      and  xdl.source_distribution_id_num_1 = ei.expenditure_item_id
      and  xdl.source_distribution_id_num_2 = cdl.line_num
      and  pod.set_of_books_id          = p_ledger_id
      AND  xah.ledger_id                = algt.ledger_id
      and  decode(algt.org_id, -99, algt.org_id, cdl.org_id) =
           decode(algt.org_id, -99, -99, algt.org_id)
      -- 5911379: ends
      and  glcc.code_combination_id     = xal.code_combination_id
     order by ei.document_distribution_id, ei.expenditure_item_id, cdl.line_num  ;

   BEGIN
      l_current_calling_sequence := P_calling_sequence||'->'||
                    'Insert_Mass';
      l_count := 1000;
      write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
                                            'Inside Insert Receipt procedure.') ;
      OPEN c_apinv ;

      LOOP
            write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
                                            'Main Loop Begins here.') ;
	    InitPlSQLTab ;

	    fetch c_apinv
	    bulk collect into t_eiIDTab,
		     t_eiDateTab,
		     t_lineNumTab,
		     t_DocHeaderIdTab,
		     t_DocDistIdTab,
		     t_DocPaymentIdTab,
		     t_DocLineNumberTab,
		     t_DocTypeTab,
		     t_DocDistTypeTab,
		     t_transSourceTab,
		     t_descriptionTab,
		     t_acctRawCostTab,
		     t_GlDateTab,
		     t_cdlEventIDTab,
		     t_CdlQtyTab,
		     t_NZAdjFlagTab,
		     t_adjEiIdTab,
		     t_trFmEiIdTab,
		     t_vendorIdTab,
		     t_vendorNumberTab,
		     t_payBatchNameTab,
		     t_TxnDateTab,
		     t_TxnCreatedByTab,
		     t_TxnUpdatedByTab,
		     t_invoiceIdTab,
		     t_sourceTab,
		     t_InvoiceNumberTab,
		     t_warrantyNumberTab,
		     t_ManufacturerTab,
		     t_SerialNumberTab,
		     t_ModelNumberTab,
		     t_linetypeLcdTab,
		     t_poDistIdTab,
		     t_RelatedIdTab,
		     t_DistLineNumberTab,
		     t_invDistIdTab,
		     t_DistCcidTab,
		     t_InvLineNumberTab,
		     t_RvrAssetsFlagTab,
		     t_SrcAssetsFlagTab,
		     t_parentInvDstIdTab,
		     t_apAssetsFlagTab,
		     --t_DstMatchTypeTab,
		     t_accTypeTab,
		     t_XalccidTab,
		     t_ledgercatcdTab,
		     t_ledgerIdTab,
		     t_invOrgIDTab
	    limit l_count ;

	    IF t_eiIDTab.count = 0 THEN
	       CLOSE c_apinv ;
               write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
	                                             'Exiting Main Loop.') ;
	       EXIT ;
	    END IF ;

	    lRec          := 0   ;
	    l_No_count    := 0   ;

	    FOR indx in 1..t_eiIDTab.count LOOP
		    l_ignore_cdl  := 'N' ;
		    write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
							  'Exp Item ID:'|| t_eiIDTab(indx) ) ;
		    write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
							  'line Number:'|| t_lineNumTab(indx) ) ;
		    write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
							  'Account Type:'|| t_accTypeTab(indx) ) ;

		    IF t_RvrAssetsFlagTab(indx) is NULL  and t_SrcAssetsFlagTab(indx) is NULL  THEN
		       l_ignore_cdl := 'N' ;
		    ELSIF NVL(t_RvrAssetsFlagTab(indx), 'N')  <> 'Y' and
		       NVL(t_SrcAssetsFlagTab(indx), 'N')  <> 'Y' THEN
		       l_ignore_cdl := 'Y' ;
		    END IF ;

		    IF t_accTypeTab(indx) <> 'A' THEN
		       l_ignore_cdl  := 'Y' ;
		    END IF ;

	            IF l_ignore_cdl  = 'N' THEN

			   IF t_poDistIdTab(indx) is not NULL THEN
			      write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
									  'PO Dist ID  :'|| t_poDistIdTab(indx) ) ;

			      SELECT mtlsi.asset_category_id,
				     polt.order_type_lookup_code,
				     decode(pod.accrue_on_receipt_flag, 'Y', pod.code_combination_id, NULL ),
				     pod.deliver_to_person_id,
				     rtrim(upper(poh.segment1))
				INTO l_assets_category_id,
				     l_po_order_type_lcd,
				     l_po_ccid,
				     l_assigned_to,
				     l_po_number
				FROM po_distributions_all         pod,
				     po_headers_all               poh,
				     po_lines_all                 pol,
				     po_line_types_b              polt,
				     mtl_system_items             mtlsi
			       WHERE pod.po_distribution_id   = t_PoDistIdTab(indx)
				 AND pod.po_header_id         = poh.po_header_id
				 AND pod.po_line_id           = pol.po_line_id
				 AND pol.line_type_id         = polt.line_type_id
				 AND pol.item_id              = mtlsi.inventory_item_id(+)
				 AND t_InvOrgIDTab(indx)      = mtlsi.organization_id (+) ;

	                       write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
		                      'Asset_category_id for po distribution:'||l_assets_category_id);
			   ELSE
			       l_assets_category_id := NULL ;
			       l_po_order_type_lcd  := NULL ;
			       l_po_ccid            := NULL ;
			       l_assigned_to        := NULL ;
			       l_po_number          := NULL ;
			   END IF ; -- t_poDistIdTab(indx) is not NULL

			   lRec                     := lRec+1 ;
			   l_descriptionTab(lRec)   := t_descriptionTab(indx) ;
			   l_ManufacturerTab(lRec)  := t_ManufacturerTab(indx) ;
			   l_SerialNumberTab(lrec)  := t_SerialNumberTab(indx) ;
			   l_ModelNumberTab(lrec)   := t_ModelNumberTab(indx) ;
			   l_BookTypCdTab(lrec)     := P_bt_code ;
			   l_eiDateTab(lrec)        := t_eiDateTab(indx) ;
			   l_FACostTab(lrec)        := t_acctRawCostTab(indx) ;
			   -- Bug 5532231 R12.PJ:XB3:QA:APL:PREPARE MASS ADDITIONS SHOWS DUPLICATE ROWS
			   l_PayUnitTab(lrec)       :=  1 ;
			   l_FAUnitTab(lrec)        := 1 ;
			   l_assignedToTab(lrec)    := l_assigned_to ;
			   l_PoNumberTab(lrec)      := l_po_number ;
			   l_assetsCatIDTab(lRec)   := l_assets_category_id ;
			   l_payCostTab(lrec)       := t_acctRawCostTab(indx) ;
			   l_vendorNumberTab(lrec)  := t_vendorNumberTab(indx) ;
			   l_vendorIdTab(lrec)      := t_vendorIdTab(indx) ;
			   l_TxnDateTab(lrec)       := t_TxnDateTab(indx) ;
			   l_TxnCreatedByTab(lrec)  := t_TxnCreatedByTab(indx) ;
			   l_TxnUpdatedByTab(lrec)  := t_TxnUpdatedByTab(indx) ;
			   l_invoiceIdTab(lrec)     := t_invoiceIdTab(indx) ;
			   l_payBatchNameTab(lrec)  := t_payBatchNameTab(indx) ;
			   l_InvLineNumberTab(lrec) := t_InvLineNumberTab(indx) ;
			   l_DistLineNumberTab(lrec):= t_DistLineNumberTab(indx) ;
			   l_GlDateTab(lrec)        := t_GlDateTab(indx) ;
			   l_InvoiceNumberTab(lrec) := t_InvoiceNumberTab(indx) ;
			   l_invDistIdtab(lrec)     := t_invDistIdtab(indx) ;
			   l_parentInvDstIdTab(lrec):= t_parentInvDstIdTab(indx) ;
			   l_poDistIdTab(lRec)      := t_poDistIdTab(indx) ;
			   l_eiIDtab(lrec)          := t_eiIDtab(indx) ;
			   l_lineNumTab(lrec)       := t_lineNumTab(indx) ;
			   l_warrantyNumberTab(lrec):= t_warrantyNumberTab(indx) ;
			   l_linetypeLcdtab(lrec)   := t_linetypeLcdtab(indx) ;
			   l_cdlEventIDTab(lrec)    := t_cdlEventIDTab(indx) ;
			   l_payBatchNameTab(lrec)  := t_payBatchNameTab(indx) ;
			   l_payCCIDTab(lrec)       := t_XalccidTab(indx) ;
			   l_ledgercatcdTab(lrec)   := t_ledgercatcdTab(indx) ;
			   l_ledgeridTab(lrec)      := t_ledgeridTab(indx) ;

                           write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
			                                         'Payable CCID:'||l_payCCIDTab(lrec) ) ;
	            END IF ; -- l_ignore_cdl = 'N'

		    IF l_ignore_cdl = 'Y' THEN
			   l_No_count                     := l_No_count + 1;
			   Flag_no_eiIDTab(l_No_count)    := t_eiIDtab(indx) ;
			   Flag_no_lineNumTab(l_No_count) := t_lineNumTab(indx) ;
		    END IF ;
            END LOOP ; -- Index for fetch

            -- Mark the cdls as assets addition not required for the list of
	    -- cdls identified by the Flag_no_lineNumTab and Flag_no_eiIdTab.
	    IF Flag_no_eiIDTab.COUNT > 0 THEN
	      write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
	                                            'Flag_no_eiIDTab.COUNT:'||Flag_no_eiIDTab.COUNT ) ;

	       FORALL i in Flag_no_eiIDTab.FIRST..Flag_no_eiIDTab.LAST
		  UPDATE pa_cost_distribution_lines
		     SET si_assets_addition_flag = 'N',
			 program_update_date     = SYSDATE,
			 program_application_id  = FND_GLOBAL.prog_appl_id,
			 program_id              = FND_GLOBAL.conc_program_id,
			 request_id              = p_request_id
		   WHERE si_assets_addition_flag in ('T')
		     AND expenditure_item_id =  Flag_no_eiIDTab(i)
		     AND line_num            = Flag_no_lineNumTab(i);
	    END IF ;

	    IF l_eiIDtab.count > 0 THEN
	      write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
	                                            'l_eiIDtab.count:'||l_eiIDtab.count) ;
		    FORALL i in l_eiIDtab.FIRST..l_eiIDtab.LAST
		      INSERT INTO FA_MASS_ADDITIONS_GT(
				    mass_addition_id,
				    description,
				    asset_category_id,
				    manufacturer_name,
				    serial_number,
				    model_number,
				    book_type_code,
				    transaction_date,
				    fixed_assets_cost,
				    payables_units,
				    fixed_assets_units,
				    payables_cost,
				    payables_code_combination_id,
				    assigned_to,
				    feeder_system_name,
				    create_batch_date,
				    create_batch_id,
				    last_update_date,
				    last_updated_by,
				    invoice_date,
				    invoice_created_by,
				    invoice_updated_by,
				    invoice_id,
				    invoice_number,
				    invoice_distribution_id,
				    invoice_line_number,
				    ap_distribution_line_number,
				    merge_invoice_number,
				    merge_vendor_number,
				    vendor_number,
				    po_vendor_id,
				    po_number,
				    payables_batch_name,
				    accounting_date,
				    created_by,
				    creation_date,
				    last_update_login,
				    parent_invoice_dist_id,
				    ledger_id,
				    ledger_category_code,
				    warranty_number,
				    line_type_lookup_code,
				    po_distribution_id,
				    expenditure_item_id,
				    line_num,
				    line_status ,
				    posting_status,
				    queue_name,
				    asset_number,
				    tag_number,
				    depreciate_flag,
				    parent_mass_addition_id,
				    parent_asset_id,
				    split_merged_code,
				    inventorial,
				    date_placed_in_service,
				    transaction_type_code,
				    expense_code_combination_id,
				    location_id,
				    reviewer_comments,
				    post_batch_id,
				    add_to_asset_id,
				    amortize_flag,
				    new_master_flag,
				    asset_key_ccid,
				    asset_type,
				    deprn_reserve,
				    ytd_deprn,
				    beginning_nbv,
				    salvage_value)
		      SELECT  fa_mass_additions_s.nextval,
			      l_descriptionTab(i),
			      l_assetsCatIDTab(i) ,
			      l_ManufacturerTab(i),
			      l_SerialNumberTab(i),
			      l_ModelNumberTab(i),
			      l_BookTypCdTab(i) ,
			      l_eiDateTab(i),
			      l_payCostTab(i),
			      l_PayUnitTab(i),
			      l_FAUnitTab(i),
			      l_payCostTab(i),
			      l_payCCIDTab(i),
			      l_assignedToTab(i) ,
			      'ORACLE PROJECTS',
			      trunc(SYSDATE)	Create_batch_date,
			      P_request_id   	create_batch_id,
			      trunc(SYSDATE)    last_update_date,
			      p_user_id		last_update_by,
			      l_TxnDateTab(i) ,
			      l_TxnCreatedByTab(i),
			      l_TxnUpdatedByTab(i),
			      l_invoiceIdTab(i) ,
			      l_InvoiceNumberTab(i),
			      l_invDistIdtab(i)  ,
			      l_InvLineNumberTab(i),
			      l_DistLineNumberTab(i),
			      l_InvoiceNumberTab(i),
			      l_vendorNumberTab(i),
			      l_vendorNumberTab(i),
			      l_vendorIdTab(i),
			      l_PoNumberTab(i),
			      l_payBatchNameTab(i), --Payables Batch Name,
			      l_GlDateTab(i) ,
			      p_user_id,	-- Created by
			      trunc(SYSDATE),	-- creation date
			      p_user_id, 	-- lst update login
			      l_parentInvDstIdTab(i),
			      l_ledgeridTab(i) ,
			      l_ledgerCatcdTab(i),
			      l_warrantyNumberTab(i),
			      l_linetypeLcdtab(i),
			      l_poDistIdTab(i),
			      l_eiIDtab(i),
			      l_lineNumTab(lrec) ,
			      'NEW',
			      'NEW',
			      'NEW',
			      NULL, 	-- assets_number
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL,
			      NULL -- Salvage Value
			from DUAL ;
		      write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
		                                            'Inserting MRC Records...') ;
	    END IF ; -- end of  l_eiIDtab.count
      END LOOP ;
      write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT',
                                          'End of Receipt Insert') ;
    --
   EXCEPTION
     WHEN OTHERS THEN
      write_to_log(FND_LOG.LEVEL_STATEMENT, '50:PA INSERT_RECEIPT', SQLERRM) ;
    APP_EXCEPTION.RAISE_EXCEPTION;
    --
    END Insert_Receipts;

   /*
   ** Initialize the Plsql bulk variables.
   */
   PROCEDURE InitPlSQLTab IS
   BEGIN
        /*
	** Initialize T Tabs
	*/
	t_eiIDtab.DELETE ;
	t_eiDatetab.DELETE ;
	t_lineNumtab.DELETE ;
	t_DocHeaderIdtab.DELETE ;
        t_DocDistIdtab.DELETE ;
	t_DocPaymentIdtab.DELETE ;
	t_DocLineNumbertab.DELETE ;
	t_DocTypetab.DELETE ;
	t_DocDistTypetab.DELETE ;
	t_transSourcetab.DELETE ;
	t_descriptiontab.DELETE ;
	t_acctRawCosttab.DELETE ;
	t_NZAdjFlagtab.DELETE ;
	t_adjEiIdtab.DELETE ;
        t_trFmEiIdtab.DELETE ;
	t_vendorIdtab.DELETE ;
	t_vendorNumbertab.DELETE ;
	t_TxnDatetab.DELETE ;
	t_TxnCreatedByTab.DELETE ;
	t_TxnUpdatedByTab.DELETE ;
	t_invoiceIdtab.DELETE ;
	t_sourcetab.DELETE ;
	t_InvoiceNumbertab.DELETE ;
	t_warrantyNumberTab.DELETE ;
	t_Manufacturertab.DELETE ;
	t_SerialNumbertab.DELETE ;
	t_ModelNumbertab.DELETE ;
	t_linetypeLcdtab.DELETE ;
	t_poDistIdtab.DELETE ;
	t_RelatedIdtab.DELETE ;
	t_DistLineNumbertab.DELETE ;
	t_invDistIdtab.DELETE ;
	t_DistCcidtab.DELETE ;
	t_InvLineNumbertab.DELETE ;
	t_RvrAssetsFlagtab.DELETE ;
	t_SrcAssetsFlagtab.DELETE ;
	t_parentInvDstIdtab.DELETE ;
	t_apAssetsFlagTab.DELETE ;
	t_DstMatchTypetab.DELETE ;
        t_GlDateTab.DELETE ;
        t_cdlEventIDTab.Delete ;
        t_cdlQtyTab.DELETE ;
        t_SiAssetsFlagTab.delete ;
	-- =====
	-- Bug : 5352018 R12.PJ:XB6:QA:APL:MASS ADDI CREATE PICKS UP ADJ FOR INV WHEN TRAC AS ASSET  DISA
	-- ====
	t_ATrackFlagTab.delete ;
        t_payBatchNameTab.delete ;
        Flag_no_eiIDTab.DELETE ;
        Flag_no_lineNumTab.DELETE ;

	t_invOrgIDTab.DELETE ;

        /*
	** Initialize L Tabs
	*/
        l_SiAssetsFlagTab.delete ;
	l_descriptionTab.Delete ;
	l_poDistIdTab.Delete ;
	l_assetsCatIDTab.Delete ;
	l_ManufacturerTab.Delete ;
	l_SerialNumberTab.Delete ;
	l_ModelNumberTab.Delete ;
	l_BookTypCdTab.Delete ;
	l_eiDateTab.Delete ;
	l_FACostTab.Delete ;
	l_PayUnitTab.Delete ;
	l_FAUnitTab.Delete ;
	l_assignedToTab.Delete ;
	l_payCostTab.Delete ;
	l_vendorNumberTab.Delete ;
	l_vendorIdTab.Delete ;
	l_PoNumberTab.Delete ;
	l_TxnDateTab.Delete ;
	l_TxnCreatedByTab.Delete ;
	l_TxnUpdatedByTab.Delete ;
	l_invoiceIdTab.Delete ;
	l_payBatchNameTab.Delete ;
	l_DistLineNumberTab.Delete ;
	l_GlDateTab.Delete ;
	l_invDistIdTab.Delete ;
	l_parentInvDstIdTab.Delete ;
	l_linetypeLcdTab.Delete ;
	l_eiIDTab.Delete ;
	l_warrantyNumberTab.Delete ;
	l_InvLineNumberTab.Delete ;
	l_PayCcidTab.Delete ;
        l_cdlEventIDTab.Delete ;
        l_cdlQtyTab.DELETE ;
        l_payBatchNameTab.delete ;

        l_XalccidTab.DELETE ;
        l_accTypeTab.DELETE ;
        t_XalccidTab.DELETE ;
        t_accTypeTab.DELETE ;

	l_ledgeridtab.delete ;
	l_ledgercatcdTab.delete ;
	l_ATrackFlagTab.delete ;

	t_ledgeridtab.delete ;
	t_ledgercatcdTab.delete ;
   END InitPlSQLTab ;

   PROCEDURE write_to_log( LOG_LEVEL IN NUMBER,
                           MODULE    IN VARCHAR2,
			   MESSAGE   IN VARCHAR2) is
   begin
       IF (g_debug_mode = 'Y') THEN
          if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             --FND_LOG.string(log_level,module, message);
             FND_LOG.string( fnd_log.level_procedure,module, message);
          end if ;

      END IF;

   end write_to_log ;
   --
END PA_Mass_Additions_Create_Pkg;

/
