--------------------------------------------------------
--  DDL for Package CST_RECEIPTACCRUALPEREND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_RECEIPTACCRUALPEREND_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVRAPS.pls 120.5.12010000.2 2008/08/08 14:27:09 mpuranik ship $ */

-----------------------------------------------------------------------------
-- Record type for System_setup information
-----------------------------------------------------------------------------
/* Bug6987381 : Added Org_id */
TYPE cst_sys_setup_rec_type IS RECORD (
        set_of_books_id                 NUMBER(15),
        chart_of_accounts_id            NUMBER(15),
        functional_currency_code        VARCHAR2(15),
        purch_encumbrance_flag          VARCHAR2(1),
        period_name                     VARCHAR2(15),
        accrual_effect_date             DATE,
        accrual_cutoff_date             DATE,
        period_end_date                 DATE,
        transaction_date                DATE,
        user_je_source_name             VARCHAR2(25),
        user_je_category_name           VARCHAR2(25),
	org_id                          NUMBER(15)
        );

-----------------------------------------------------------------------------
-- Record type for period end accrual information
-----------------------------------------------------------------------------
TYPE cst_accrual_info_rec_type IS RECORD (
        rcv_acc_event_id                NUMBER,
        actual_flag                     VARCHAR2(1),
        currency_code                   VARCHAR2(15),
        code_combination_id             NUMBER,
        entered_dr                      NUMBER,
        entered_cr                      NUMBER,
        accounted_dr                    NUMBER,
        accounted_cr                    NUMBER,
        currency_conversion_date        DATE,
        user_currency_conversion_type   VARCHAR2(30),
        currency_conversion_rate        NUMBER,
        po_header_id                    NUMBER,
        distribution_id                 NUMBER,
        po_number                       VARCHAR2(25),
        source_doc_quantity             NUMBER,
        entered_rec_tax                 NUMBER,
        entered_nr_tax                  NUMBER,
        accounted_rec_tax               NUMBER,
        accounted_nr_tax                NUMBER,
        accrual_method_flag             VARCHAR2(1),
        accounting_line_type            VARCHAR2(25),
        parent_rcv_acc_event_id         NUMBER
        );

-----------------------------------------------------------------------------
-- Table types for RCV_RECEIVING_SUB_LEDGER
-----------------------------------------------------------------------------
TYPE rcv_acc_event_id_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE pnt_rcv_acc_event_id_tbl_type IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE actual_flag_tbl_type          IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE currency_code_tbl_type        IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
TYPE code_combination_id_tbl_type  IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE entered_dr_tbl_type           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE entered_cr_tbl_type           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE accounted_dr_tbl_type         IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE accounted_cr_tbl_type         IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE curr_conversion_date_tbl_type IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
TYPE user_curr_conversion_tbl_type IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
TYPE curr_conversion_rate_tbl_type IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE po_header_id_tbl_type         IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE shipment_id_tbl_type          IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE distribution_id_tbl_type      IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE po_number_tbl_type            IS TABLE OF VARCHAR2(25)  INDEX BY BINARY_INTEGER;
TYPE source_doc_quantity_tbl_type  IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE entered_rec_tax_tbl_type      IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE entered_nr_tax_tbl_type       IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE accounted_rec_tax_tbl_type    IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE accounted_nr_tax_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE accrual_method_flag_tbl_type  IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE accounting_line_type_tbl_type IS TABLE OF VARCHAR2(25)  INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------
-- Table types for RCV_ACCOUNTING_EVENTS
-----------------------------------------------------------------------------
TYPE rae_event_id_tbl_type         IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_event_type_id_tbl_type    IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_inv_org_id_tbl_type       IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_po_number_tbl_type        IS TABLE OF VARCHAR2(25)  INDEX BY BINARY_INTEGER;
TYPE rae_distribution_id_tbl_type  IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_qty_received_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_qty_invoiced_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_unit_pice_tbl_type        IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_txn_qty_tbl_type          IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_txn_amount_tbl_type       IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_currency_code_tbl_type    IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
TYPE rae_cur_conv_type_tbl_type    IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
TYPE rae_cur_conv_rate_tbl_type    IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE rae_cur_conv_date_tbl_type    IS TABLE OF DATE          INDEX BY BINARY_INTEGER;

TYPE accrual_index_tbl_type        IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE encum_index_tbl_type          IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
/*Bug6987381*/
TYPE rae_pnt_event_id_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------
-- PL/SQL tables for RCV_RECEIVING_SUB_LEDGER
-----------------------------------------------------------------------------
g_rcv_acc_event_id_tbl             RCV_ACC_EVENT_ID_TBL_TYPE;
g_pnt_rcv_acc_event_id_tbl         PNT_RCV_ACC_EVENT_ID_TBL_TYPE;
g_actual_flag_tbl                  ACTUAL_FLAG_TBL_TYPE;
g_currency_code_tbl                CURRENCY_CODE_TBL_TYPE;
g_code_combination_id_tbl          CODE_COMBINATION_ID_TBL_TYPE;
g_entered_dr_tbl                   ENTERED_DR_TBL_TYPE;
g_entered_cr_tbl                   ENTERED_CR_TBL_TYPE;
g_accounted_dr_tbl                 ACCOUNTED_DR_TBL_TYPE;
g_accounted_cr_tbl                 ACCOUNTED_CR_TBL_TYPE;
g_curr_conversion_date_tbl         CURR_CONVERSION_DATE_TBL_TYPE;
g_user_curr_conversion_tbl         USER_CURR_CONVERSION_TBL_TYPE;
g_curr_conversion_rate_tbl         CURR_CONVERSION_RATE_TBL_TYPE;
g_po_header_id_tbl                 PO_HEADER_ID_TBL_TYPE;
g_shipment_id_tbl                  SHIPMENT_ID_TBL_TYPE;
g_distribution_id_tbl              DISTRIBUTION_ID_TBL_TYPE;
g_po_number_tbl                    PO_NUMBER_TBL_TYPE;
g_source_doc_quantity_tbl          SOURCE_DOC_QUANTITY_TBL_TYPE;
g_entered_rec_tax_tbl              ENTERED_REC_TAX_TBL_TYPE;
g_entered_nr_tax_tbl               ENTERED_NR_TAX_TBL_TYPE;
g_accounted_rec_tax_tbl            ACCOUNTED_REC_TAX_TBL_TYPE;
g_accounted_nr_tax_tbl             ACCOUNTED_NR_TAX_TBL_TYPE;
g_accrual_method_flag_tbl          ACCRUAL_METHOD_FLAG_TBL_TYPE;
g_accounting_line_type_tbl         ACCOUNTING_LINE_TYPE_TBL_TYPE;

-----------------------------------------------------------------------------
-- List of distribution_id, for which Accrued flag has to be set to 'Y'
-- The table will be populated by CST_PerEndAccruals_PVT.Create_PerEndAccruals
-----------------------------------------------------------------------------
g_accrued_dist_id_tbl              DISTRIBUTION_ID_TBL_TYPE;

-----------------------------------------------------------------------------
-- PL/SQL tables for RCV_ACCOUNTING_EVENTS
-----------------------------------------------------------------------------
g_rae_event_id_tbl                 RAE_EVENT_ID_TBL_TYPE;
g_rae_event_type_id_tbl            RAE_EVENT_TYPE_ID_TBL_TYPE;
g_rae_distribution_id_tbl          RAE_DISTRIBUTION_ID_TBL_TYPE;
g_rae_inv_org_id_tbl               RAE_INV_ORG_ID_TBL_TYPE;
g_rae_po_number_tbl                RAE_PO_NUMBER_TBL_TYPE;
g_rae_qty_received_tbl             RAE_QTY_RECEIVED_TBL_TYPE;
g_rae_qty_invoiced_tbl             RAE_QTY_INVOICED_TBL_TYPE;
g_rae_unit_pice_tbl                RAE_UNIT_PICE_TBL_TYPE;
g_rae_txn_qty_tbl                  RAE_TXN_QTY_TBL_TYPE;
g_rae_txn_amount_tbl               RAE_TXN_AMOUNT_TBL_TYPE;
g_rae_currency_code_tbl            RAE_CURRENCY_CODE_TBL_TYPE;
g_rae_cur_conv_type_tbl            RAE_CUR_CONV_TYPE_TBL_TYPE;
g_rae_cur_conv_rate_tbl            RAE_CUR_CONV_RATE_TBL_TYPE;
g_rae_cur_conv_date_tbl            RAE_CUR_CONV_DATE_TBL_TYPE;
/*Bug6987381*/
g_rae_pnt_event_id_tbl             RAE_PNT_EVENT_ID_TBL_TYPE;
-----------------------------------------------------------------------------
-- PL/SQL tables, which works as index tables for accounting_event_id PL/SQL table
-----------------------------------------------------------------------------
g_accrual_index_tbl                ACCRUAL_INDEX_TBL_TYPE;
g_encum_index_tbl                  ENCUM_INDEX_TBL_TYPE;

-----------------------------------------------------------------------------
-- Global counter, stores no. of rows in PL/SQL tables for
-- RCV_RECEIVING_SUB_LEDGER
-----------------------------------------------------------------------------
g_counter                          NUMBER;


-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Start_Process
--   Type            : Private
--   Function        : Starting point for Receipt Accruals - Period End
--                     Concurrent Program.
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_min_accrual_amount   NUMBER       Required
--     p_vendor_id        NUMBER       Required
--     p_struct_num       NUMBER       Required
--     p_category_id      NUMBER       Required
--     p_period_name      VARCHAR2     Required
--
--   OUT             :
--     errbuf             VARCHAR2
--     retcode            NUMBER
--
--   Version : Current version       1.0
--
-- End of comments
-----------------------------------------------------------------------------
PROCEDURE Start_Process
(
    errbuf                          OUT     NOCOPY VARCHAR2,
    retcode                         OUT     NOCOPY NUMBER,

    p_min_accrual_amount            IN      NUMBER,
    p_vendor_id                     IN      NUMBER,
    p_struct_num                    IN      NUMBER,
    p_category_id                   IN      NUMBER,
    p_period_name                   IN      VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Seed_RcvAccountingEvents
--   Type            : Private
--   Function        : The procedure created events in RCV_ACCOUNTING_EVENTS
--                     table.
--                     The procedure generates data for RAE and creates PL/SQL
--                     table, which will be used for bulk inserting the data
--                     in RCV_ACCOUNTING_EVENTS.
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_commit           VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_sys_setup_rec    CST_SYS_SETUP_REC_TYPE Required
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--
--   Version : Current version       1.0
--
-- End of comments
-----------------------------------------------------------------------------
PROCEDURE Seed_RcvAccountingEvents
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Create_AccrualAccount
--   Type            : Private
--   Function        : The procedure fetches data from temp table
--                     CST_PER_END_ACCRUALS_TEMP, and populates PL/SQL tables
--                     with the corresponding accrual info for the tables
--                     RCV_RECEIVING_SUB_LEDGER
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_commit           VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_sys_setup_rec    CST_SYS_SETUP_REC_TYPE Required
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--
--   Version : Current version       1.0
--
-- End of comments
-----------------------------------------------------------------------------
PROCEDURE Create_AccrualAccount
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Insert_Account
--   Type            : Private
--   Function        : The procedure adds a new row to the PL/SQL tables for
--                     each accrual_info_rec record.
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_commit           VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_accrual_info_rec CST_ACCRUAL_INFO_REC_TYPE  Required
--     p_sys_setup_rec    CST_SYS_SETUP_REC_TYPE     Required
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--
--   Version : Current version       1.0
--
-- End of comments
-----------------------------------------------------------------------------
PROCEDURE Insert_Account
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_accrual_info_rec              IN      CST_ACCRUAL_INFO_REC_TYPE,
    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Insert_AccrualSubLedger
--   Type            : Private
--   Function        : Insert accounting entries in RCV_RECEIVING_SUB_LEDGER
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_commit           VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_sys_setup_rec    CST_SYS_SETUP_REC_TYPE     Required
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--
--   Version : Current version       1.0
--
-- End of comments
-----------------------------------------------------------------------------
PROCEDURE Insert_AccrualSubLedger
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_sys_setup_rec                 IN      CST_SYS_SETUP_REC_TYPE
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Get_SystemSetup
--   Type            : Private
--   Function        : Get system set-up information e.g. set_of_books,
--                     functional_currency, chart_of_accounts,
--                     purchase_encumbrance_flag etc
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_period_name      VARCHAR2     Required
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--     x_sys_setup_rec    CST_SYS_SETUP_REC_TYPE
--
--   Version : Current version       1.0
--
-- End of comments
-----------------------------------------------------------------------------
PROCEDURE Get_SystemSetup
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,

    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_period_name                   IN      VARCHAR2,
    x_sys_setup_rec                 OUT     NOCOPY CST_SYS_SETUP_REC_TYPE
);

END CST_ReceiptAccrualPerEnd_PVT;

/
