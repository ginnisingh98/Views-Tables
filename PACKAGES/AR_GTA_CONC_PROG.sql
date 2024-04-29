--------------------------------------------------------
--  DDL for Package AR_GTA_CONC_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_CONC_PROG" AUTHID CURRENT_USER AS
----$Header: ARGCCPGS.pls 120.0.12010000.3 2010/01/19 07:11:23 choli noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                      Redwood Shores, California, USA                      |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :                                                               |
--|      ARCCPGS.pls                                                         |
--|                                                                           |
--|  DESCRIPTION:                                                             |
--|      This package is the a collection of procedures which                 |
--|      called by concurrent programs                                        |
--|                                                                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|      20-APR-2005: Jim Zheng       Create                                  |
--|      08-MAY-2005: Qiang Li                                                |
--|      20-MAY-2005: Jogen Hu        add Import_GT_invoices                  |
--|                                   Transfer_Invoices_to_GT                 |
--|                                   Transfer_Trxs_from_workbench            |
--|      13-Jun-2005: Donghai Wang    add procedure Discrepancy_Report        |
--|                                   and Item_Export                         |
--|      01-Jul-2005: Jim Zheng       Update after code review,               |
--|                                   chang parameter type.                   |
--|      28-Sep-2005: Jogen Hu        change Transfer_Invoices_to_GT          |
--|      18-Oct-2005: Donghai Wang    Update 'Transrfer_Invoices_To_GT'       |
--|                                   procedure to adjust order of            |
--|                                   paramerts                               |
--|      30-Nov-2005: Qiang Li        change set_of_books_id to ledger_id in  |
--|                                   purge program                           |
--|      18-Jun-2007: Yanping Wang    Modify g_module_prefix to use small case|
--|                                   of ar                                  |
--|      20-Jul-2009: Yao Zhang       Add procedure Consolidate_Invoices      |
--|      25-Jul-2009: Allen Yang      Add procedure Run_Consolidation_Mapping |
--|      08-Aug-2009: Yao Zhang      Fix bug#8770356, add parameter org_id to |
--|                                  procedure consolidate_invoices           |
--|      16-Aug-2009: Allen Yang     Add procedures Populate_Invoice_Type     |
--|                                  and Populate_Invoice_Type_Header to      |
--|                                  do data migration from 12.0 to 12.1.X    |
--+===========================================================================+

--Declare global variable for package name
g_module_prefix VARCHAR2(100) := 'ar.plsql.AR_GTA_CONC_PROC';

--==========================================================================
--  PROCEDURE NAME:
--
--    Transfer_AR_Transactions                     Public
--
--  DESCRIPTION:
--
--      This procedure is the main program for transfer program.
--
--  PARAMETERS:
--      In:  p_transfer_id         Transfer rule id
--           p_customer_num_from   Customer number from
--           p_customer_num_to     Customer number to
--           p_customer_name_from  Customer name from
--           p_customer_name_to    Customer name to
--           p_gl_period           GL period
--           p_gl_date_from        GL date from
--           p_gl_date_to          GL date to
--           p_trx_batch_from      Batch number from
--           p_trx_batch_to        Batch number to
--           p_trx_number_from     Trx number from
--           p_trx_number_to       Trx number to
--           p_trx_date_from       Trx date from
--           p_trx_date_to         Trx date to
--           p_doc_num_from        Doc number from
--           p_doc_num_to          Doc number to
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--      GTA-TRANSFER-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           05-MAY-2005: Jim.Zheng  Created
--
--===========================================================================
PROCEDURE transfer_ar_transactions
(errbuf               OUT NOCOPY VARCHAR2
,retcode              OUT NOCOPY VARCHAR2
,p_transfer_id        IN         VARCHAR2
,p_customer_num_from  IN         VARCHAR2
,p_customer_num_to    IN         VARCHAR2
,p_customer_name_from IN         VARCHAR2
,p_customer_name_to   IN         VARCHAR2
,p_gl_period          IN         VARCHAR2
,p_gl_date_from       IN         VARCHAR2
,p_gl_date_to         IN         VARCHAR2
,p_trx_batch_from     IN         VARCHAR2
,p_trx_batch_to       IN         VARCHAR2
,p_trx_number_from    IN         VARCHAR2
,p_trx_number_to      IN         VARCHAR2
,p_trx_date_from      IN         VARCHAR2
,p_trx_date_to        IN         VARCHAR2
,p_doc_num_from       IN         NUMBER
,p_doc_num_to         IN         NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Purge_Invoice                     Public
--
--  DESCRIPTION:
--
--      This procedure is the main program for purge program,
--      it search eligible records in GTA invoice tables first,
--      if find any, then invoke corresponding table handlers to
--      remove these records from db.
--
--  PARAMETERS:
--      In:  p_set_of_books_id     Accounting book identifier
--           p_customer_name       Customer name
--           p_gl_date_from        GL date low range
--           p_gl_date_to          GL date high range
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--      GTA-PURGE-PROGRAM-TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li   Created.
--           30-Nov-2005: Qiang Li  change set_of_books_id to ledger_id
--
--===========================================================================
PROCEDURE purge_invoice
(errbuf            OUT NOCOPY VARCHAR2
,retcode           OUT NOCOPY VARCHAR2
,p_ledger_id       IN         NUMBER
,p_customer_name   IN         VARCHAR2
,p_gl_date_from    IN         VARCHAR2
,p_gl_date_to      IN         VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Run_AR_GT_Mapping                     Public
--
--  DESCRIPTION:
--
--      This Concurrent program Generate Mapping Report Data
--
--  PARAMETERS:
--      In:  p_fp_tax_reg_num      First Party Tax Registration Number
--           p_trx_source          Transaction source,GT or AR
--           P_Customer_Id         Customer id
--           p_gt_inv_num_from     GT Invoice Number low range
--           p_gt_inv_num_to       GT Invoice Number high range
--           p_gt_inv_date_from    GT Invoice Date low range
--           p_gt_inv_date_to      GT Invoice Date high range
--           p_ar_inv_num_from     AR Invoice Number low range
--           p_ar_inv_num_to       AR Invoice Number high range
--           p_ar_inv_date_from    AR Invoice Date low range
--           p_ar_inv_date_to      AR Invoice Date high range
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           8-MAY-2005: Qiang Li   Created.
--           27-Sep-2005:Qiang Li   Add a new parameter fp_tax_reg_number.
--
--===========================================================================
PROCEDURE run_ar_gt_mapping
(errbuf             OUT NOCOPY VARCHAR2
,retcode            OUT NOCOPY VARCHAR2
,p_fp_tax_reg_num   IN         VARCHAR2
,p_trx_source       IN         NUMBER
,p_customer_id      IN         VARCHAR2
,p_gt_inv_num_from  IN         VARCHAR2
,p_gt_inv_num_to    IN         VARCHAR2
,p_gt_inv_date_from IN         VARCHAR2
,p_gt_inv_date_to   IN         VARCHAR2
,p_ar_inv_num_from  IN         VARCHAR2
,p_ar_inv_num_to    IN         VARCHAR2
,p_ar_inv_date_from IN         VARCHAR2
,p_ar_inv_date_to   IN         VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Import_GT_Invoices                     Public
--
--  DESCRIPTION:
--
--     This procedure is program of SRS concurrent for import
--     flat file exported from Golden Tax system
--
--  PARAMETERS:
--      In:
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           20-MAY-2005: Jogen Hu   Created
--
--===========================================================================
PROCEDURE import_gt_invoices
(errbuf  OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Transfer_Invoices_to_GT                   Public
--
--  DESCRIPTION:
--
--     This procedure is a SRS concurrent program which exports GTA
--     invoices to the flat file Its output will be printed on concurrent
--     output and will be save as flat file by users.
--
--  PARAMETERS:
--      In:    p_regeneration               IN                 VARCHAR2
--             p_new_batch_dummy            IN                 VARCHAR2
--             p_regeneration_dummy         IN                 VARCHAR2
--             p_fp_tax_reg_num             IN                 VARCHAR2
--             p_transfer_rule_id           IN                 NUMBER
--             p_batch_number               IN                 VARCHAR2
--             p_customer_id_from_number    IN                 NUMBER
--             p_customer_id_from_name      IN                 NUMBER
--             p_cust_id_from_taxpayer      IN                 NUMBER
--             p_ar_trx_num_from            IN                 VARCHAR2
--             p_ar_trx_num_to              IN                 VARCHAR2
--             p_ar_trx_date_from           IN                 VARCHAR2
--             p_ar_trx_date_to             IN                 VARCHAR2
--             p_ar_trx_gl_date_from        IN                 VARCHAR2
--             p_ar_trx_gl_date_to          IN                 VARCHAR2
--             p_ar_trx_batch_from          IN                 VARCHAR2
--             p_ar_trx_batch_to            IN                 VARCHAR2
--             p_trx_class                  IN                 VARCHAR2
--             p_batch_id                   IN                 VARCHAR2
--	       p_invoice_type               IN                 VARCHAR2
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           20-MAY-2005: Jogen Hu   Created
--           28-Sep-2005: Jogen Hu   add a parameter
--                            p_fp_tax_reg_num          IN         VARCHAR2
--           18-Oct-2005: Donghai Wang move the parameter 'p_fp_tax_reg_num'
--                                     behind the parameter 'p_regeneration_dummy'
--===========================================================================
PROCEDURE transfer_invoices_to_gt
(errbuf                    OUT NOCOPY VARCHAR2
,retcode                   OUT NOCOPY VARCHAR2
,p_regeneration            IN         VARCHAR2
,p_new_batch_dummy         IN         VARCHAR2
,p_regeneration_dummy      IN         VARCHAR2
,p_fp_tax_reg_num          IN         VARCHAR2
,p_transfer_rule_id        IN         NUMBER
,p_batch_number            IN         VARCHAR2
,p_customer_id_from_number IN         NUMBER
,p_customer_id_from_name   IN         NUMBER
,p_cust_id_from_taxpayer   IN         NUMBER
,p_ar_trx_num_from         IN         VARCHAR2
,p_ar_trx_num_to           IN         VARCHAR2
,p_ar_trx_date_from        IN         VARCHAR2
,p_ar_trx_date_to          IN         VARCHAR2
,p_ar_trx_gl_date_from     IN         VARCHAR2
,p_ar_trx_gl_date_to       IN         VARCHAR2
,p_ar_trx_batch_from       IN         VARCHAR2
,p_ar_trx_batch_to         IN         VARCHAR2
,p_trx_class               IN         VARCHAR2
,p_batch_id                IN         VARCHAR2
,p_invoice_type            IN         VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoices_from_Workbench                  Public
--
--  DESCRIPTION:
--
--     This procedure is a SRS concurrent program which exports VAT
--     invoices from GTA to flat file and is invoked in workbench
--
--  PARAMETERS:
--      In:    p_org_id               IN                NUMBER
--             p_generator_ID         IN                NUMBER
--             p_batch_number         IN                VARCHAR2
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           20-MAY-2005: Jogen Hu   Created
--
--==========================================================================
PROCEDURE transfer_trxs_from_workbench
(errbuf         OUT NOCOPY VARCHAR2
,retcode        OUT NOCOPY VARCHAR2
,p_org_id       IN         NUMBER
,p_generator_id IN         NUMBER
,p_batch_number IN         VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Discrepancy_Report                 Public
--
--  DESCRIPTION:
--
--     This procedure is called by concurren program 'Golden Tax
--     Discrepancy Report' to generte discrepancy report.
--
--  PARAMETERS:
--      In:    p_gta_batch_num_from   GTA invoice batch number low range
--             p_gta_batch_num_to     GTA invoice batch number high range
--             p_ar_transaction_type  AR transaction type
--             p_cust_num_from        Customer number low range
--             p_cust_num_to          Customer number high range
--             p_cust_name_id         Identifier of customer
--             p_gl_period            GL period name
--             p_gl_date_from         GL date low range
--             p_gl_date_to           GL date high range
--             p_ar_trx_batch_from    AR transaction batch name low range
--             p_ar_trx_batch_to      AR transaction batch name high range
--             P_ar_trx_num_from      AR transaction number low range
--             P_ar_trx_num_to        AR transaction number high range
--             p_ar_trx_date_from     AR transaction date low range
--             p_ar_trx_date_to       AR transaction date high range
--             p_ar_doc_num_from      AR document sequnce number low range
--             p_ar_doc_num_to        AR document sequnce number high range
--             p_original_curr_code   Original currency code
--             p_primary_sales        Identifier of primary salesperson
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Created
--
--==========================================================================
PROCEDURE discrepancy_report
(errbuf                OUT NOCOPY VARCHAR2
,retcode               OUT NOCOPY VARCHAR2
,p_gta_batch_num_from  IN         VARCHAR2
,p_gta_batch_num_to    IN         VARCHAR2
,p_ar_transaction_type IN         NUMBER
,p_cust_num_from       IN         VARCHAR2
,p_cust_num_to         IN         VARCHAR2
,p_cust_name_id        IN         NUMBER
,p_gl_period           IN         VARCHAR2
,p_gl_date_from        IN         VARCHAR2
,p_gl_date_to          IN         VARCHAR2
,p_ar_trx_batch_from   IN         VARCHAR2
,p_ar_trx_batch_to     IN         VARCHAR2
,p_ar_trx_num_from     IN         VARCHAR2
,p_ar_trx_num_to       IN         VARCHAR2
,p_ar_trx_date_from    IN         VARCHAR2
,p_ar_trx_date_to      IN         VARCHAR2
,p_ar_doc_num_from     IN         VARCHAR2
,p_ar_doc_num_to       IN         VARCHAR2
,p_original_curr_code  IN         VARCHAR2
,p_primary_sales       IN         NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Item_Export                     Public
--
--  DESCRIPTION:
--
--     This procedure is to export item information to a flat file
--
--  PARAMETERS:
--      In:    p_master_org_id              Identifier of INV master organization
--             p_item_num_from              Item number low range
--             p_item_num_to                Item number high range
--             p_category_set_id            Identifier of item category set
--             p_category_structure_id      Structure id of item category
--             p_item_category_from         Item category low range
--             p_item_category_to           Item category high range
--             p_item_name_source Source    to deciede where item name is gotten
--             p_dummy                      Dummy parameter
--             p_cross_reference_type       Cross reference
--             p_item_status                Status of an item
--             p_creation_date_from         Item creation date low range
--             p_creation_date_to           Item creation date high range
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           13-Jun-2005: Donghai Wang  Created
--
--==========================================================================
PROCEDURE item_export
(errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY VARCHAR2
,p_master_org_id         IN         NUMBER
,p_item_num_from         IN         VARCHAR2
,p_item_num_to           IN         VARCHAR2
,p_category_set_id       IN         NUMBER
,p_category_structure_id IN         NUMBER
,p_item_category_from    IN         VARCHAR2
,p_item_category_to      IN         VARCHAR2
,p_item_name_source      IN         VARCHAR2
,p_dummy                 IN         VARCHAR2
,p_cross_reference_type  IN         VARCHAR2
,p_item_status           IN         VARCHAR2
,p_creation_date_from    IN         VARCHAR2
,p_creation_date_to      IN         VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Transfer_Customers_To_GT                     Public
--
--  DESCRIPTION:
--
--     This procedure convert AR customers information into a flat file
--
--  PARAMETERS:
--      In:    p_customer_num_from             IN         VARCHAR2
--             p_customer_num_to               IN         VARCHAR2
--             p_customer_name_from            IN         VARCHAR2
--             p_customer_name_to              IN         VARCHAR2
--             p_taxpayee_id                   IN         VARCHAR2
--             p_creation_date_from            IN         VARCHAR2
--             p_creation_date_to              IN         VARCHAR2
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--          20-MAY-2005: Jim.Zheng   Created.
--          26_Jun-005   Jim Zheng   update , chanage the Date parameter to Varchar2
--==========================================================================
PROCEDURE transfer_customers_to_gt
(errbuf               OUT NOCOPY VARCHAR2
,retcode              OUT NOCOPY VARCHAR2
,p_customer_num_from  IN         VARCHAR2
,p_customer_num_to    IN         VARCHAR2
,p_customer_name_from IN         VARCHAR2
,p_customer_name_to   IN         VARCHAR2
--,p_taxpayee_id        IN         VARCHAR2
,p_creation_date_from IN         VARCHAR2
,p_creation_date_to   IN         VARCHAR2
);
--=============================================================================
-- PROCEDURE NAME:
--                Consolidate_Invoices
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION: This is the entrance procedure to merge invoice.
--
-- PARAMETERS:
-- p_same_pri_same_dis IN VARCHAR2 same price and same discoout
-- p_same_pri_diff_dis IN	VARCHAR2 same price with different discount
-- p_diff_pri          IN VARCHAR2 different price
-- p_sales_list_flag   IN VARCHAR2 salese_list_flag
-- p_consolidation_id    IN NUMBER   consolidation id
--
-- HISTORY:
--                 30-Jun-2009 : Yao Zhang Create
--                 08-Aug-2009 : Yao Zhang modified for bug#8770356
--=============================================================================
PROCEDURE Consolidate_Invoices
(errbuf         OUT NOCOPY VARCHAR2
,retcode        OUT NOCOPY VARCHAR2
,p_consolidation_id    IN NUMBER
,p_same_pri_same_dis IN VARCHAR2
,p_same_pri_diff_dis IN	VARCHAR2
,p_diff_pri          IN VARCHAR2
,p_sales_list_flag   IN VARCHAR2
,p_org_id            IN NUMBER --Yao Zhang add for bug#8770356
);

--=============================================================================
-- PROCEDURE NAME:
--                Run_Consolidation_Mapping
-- TYPE:
--                PUBLIC
--
-- DESCRIPTION: This is the entrance procedure for invoice consolidation
--              mapping report.
--
-- PARAMETERS:
-- IN :    p_gl_period              GL period
--         p_customer_num_from      customer number from
--         p_customer_num_to        customer number to
--         p_customer_name_from     customer name from
--         p_customer_name_to       customer name to
--         p_consol_trx_num_from    consolidated invoice number from
--         p_consol_trx_num_to      consolidated invoice number to
--         p_invoice_type           invoice type
--
-- HISTORY:
--                 25-Jul-2009 :    Allen Yang Created
--=============================================================================
PROCEDURE Run_Consolidation_Mapping
(errbuf         OUT NOCOPY VARCHAR2
,retcode        OUT NOCOPY VARCHAR2
,p_gl_period            IN VARCHAR2
,p_customer_num_from    IN VARCHAR2
,p_customer_num_to      IN VARCHAR2
,p_customer_name_from   IN VARCHAR2
,p_customer_name_to     IN VARCHAR2
,p_consol_trx_num_from  IN VARCHAR2
,p_consol_trx_num_to    IN VARCHAR2
,p_invoice_type         IN VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type                     Public
--
--  DESCRIPTION:
--
--     In R12.1.1, there were 2 sql files need be manually run to migrate the
--     setup and transaction data from GTA 12.0 to GTA 12.1.
--     In R12.1.2, we convert this two sql into concurrent programs which
--     can be run by user from UI.
--     This procedure is to populate data to INVOICE_TYPE column for
--     Transfer Rule and System Option tables.
--
--  PARAMETERS:
--      In:
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           16-Aug-2009: Allen Yang   Created
--
--===========================================================================
PROCEDURE Populate_Invoice_Type
(errbuf  OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Invoice_Type_Header                     Public
--
--  DESCRIPTION:
--
--     In R12.1.1, there were 2 sql files need be manually run to migrate the
--     setup and transaction data from GTA 12.0 to GTA 12.1.
--     In R12.1.2, we convert this two sql into concurrent programs which
--     can be run by user from UI.
--     This procedure is to populate data to INVOICE_TYPE column for
--     GTA Invoice Header table.
--  PARAMETERS:
--      In:
--
--     Out:  errbuf
--           retcode
--
--  DESIGN REFERENCES:
--     GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--           16-Aug-2009: Allen Yang   Created
--
--===========================================================================
PROCEDURE Populate_Invoice_Type_Header
(errbuf  OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY VARCHAR2
);

END AR_GTA_CONC_PROG;

/
