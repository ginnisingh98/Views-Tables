--------------------------------------------------------
--  DDL for Package CST_REVENUECOGSMATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_REVENUECOGSMATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTRCMVS.pls 120.4.12010000.4 2009/08/25 01:21:51 hyu ship $ */

-- COGS Event Types
-- These will also be seeded lookups in mfg_lookups
SO_ISSUE                    CONSTANT NUMBER := 1;
RMA_RECEIPT                 CONSTANT NUMBER := 2;
COGS_RECOGNITION_EVENT      CONSTANT NUMBER := 3;
COGS_REC_PERCENT_ADJUSTMENT CONSTANT NUMBER := 4;
COGS_REC_QTY_ADJUSTMENT     CONSTANT NUMBER := 5;
RMA_RECEIPT_PLACEHOLDER     CONSTANT NUMBER := 6;

-- Accounting Line Types for COGS and Deferred COGS
COGS_LINE_TYPE              CONSTANT NUMBER := 35;
DEF_COGS_LINE_TYPE          CONSTANT NUMBER := 36;

-- Other constants
C_max_bulk_fetch_size       CONSTANT NUMBER := 1000;

-- Table of Numbers used to store NUMBER columns that are passed
-- around during event processing.
TYPE number_table IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

-- Table used to store DATE columns
TYPE date_table IS TABLE OF DATE
  INDEX BY BINARY_INTEGER;

-- Table used to store FLAG columns
TYPE flag_table IS TABLE OF VARCHAR2(1)
  INDEX BY BINARY_INTEGER;

-- Table used to store VARCHAR2(15) columns
TYPE char15_table IS TABLE OF VARCHAR2(15)
  INDEX BY BINARY_INTEGER;

-- Table used to store VARCHAR2(3) columns
TYPE char3_table IS TABLE OF VARCHAR2(3)
  INDEX BY BINARY_INTEGER;


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Match_RevenueCOGS This API is the outer wrapper for the concurrent     --
--                    request that matches COGS to revenue for OM lines.   --
--                    It is run in four phases, each followed by a         --
--                    commit:                                              --
--                    1) Record any sales order issues and RMA receipts    --
--                       that have not yet been inserted into CRCML and    --
--                       CCE.                                              --
--                    2) Process incoming revenue events and insert        --
--                       revenue recognition per period by OM line into    --
--                       CRRL.                                             --
--                    3) Compare CRRL to CCE (via CRCML) and create new    --
--                       COGS recognition events where they don't match.   --
--                    4) Cost all of the Cogs Recogntion Events that were  --
--                       just created in bulk.                             --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--                                                                         --
--  P_LOW_DATE         Lower bound for the date range.                     --
--  P_HIGH_DATE        Upper bound for the date range.                     --
--  P_PHASE            Set to a number, this parameter indicates that only --
--                     that phase # should be run.  Otherwise all phases   --
--                     should be run.                                      --
--                                                                         --
-- HISTORY:                                                                --
--    04/20/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Match_RevenueCogs(
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_dummy_out             OUT NOCOPY  NUMBER,
                p_api_version           IN          NUMBER,
                p_phase                 IN          NUMBER,
                p_ledger_id             IN          NUMBER DEFAULT NULL,--BUG#5726230
                p_low_date              IN          VARCHAR2,
                p_high_date             IN          VARCHAR2,
                p_neg_req_id            IN          NUMBER DEFAULT NULL--HYU
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_SoIssues   This procedure handles the insertion of sales order  --
--                    issue transactions in batch into the matching data   --
--                    model.  Most sales orders will be inserted into the  --
--                    matching data model by the Cost Processor. Any that  --
--                    are not processed at that time (e.g. - OPM orgs)     --
--                    will be inserted here.                               --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  WHO columns                                                            --
--                                                                         --
-- HISTORY:                                                                --
--    04/22/05     Bryan Kuntz      Created using cursor                   --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Insert_SoIssues(
                x_return_status   OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_RmaReceipts  This procedure handles the insertion of RMA        --
--                      receipt transactions in batch into the matching    --
--                      data model.  Most RMA receipts will be inserted    --
--                      by the Cost Processor.  This bulk procedure will   --
--                      pick up the rest.                                  --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  WHO columns                                                            --
--                                                                         --
-- HISTORY:                                                                --
--    05/06/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Insert_RmaReceipts(
                x_return_status   OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Create_CogsRecognitionEvents                                           --
--       This procedure is the main procedure for phase 3 of the program   --
--       to Match COGS to Revenue. It compares the latest Revenue % with   --
--       the latest COGS percentage and, where different, creates new      --
--       COGS recognition events to bring the COGS percentage up to date.  --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  WHO columns                                                            --
--                                                                         --
-- HISTORY:                                                                --
--    04/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Create_CogsRecognitionEvents(
                x_return_status   OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER,
                p_ledger_id       IN   NUMBER DEFAULT NULL  --BUG#5726230
               ,p_neg_req_id      IN   NUMBER DEFAULT NULL  --BUG#7387575
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_OneSoIssue    This procedure is very similar to the             --
--             Insert_SoIssues() procedure above.  It differs in that the  --
--             above procedure handles bulk inserts and is called during   --
--             one of the phases of the concurrent request, while this     --
--             version inserts one sales order at a time into the data     --
--             model, and is called from the Cost Processor.               --
--                                                                         --
--             This procedure should only get called for issues out of     --
--             asset subinventories.                                       --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_COGS_OM_LINE_ID    Line_ID of the sales order issue from OM table    --
--  P_COGS_ACCT_ID       GL Code Combination for the COGS account          --
--  P_DEF_COGS_ACCT_ID   GCC for the deferred COGS account                 --
--  P_MMT_TXN_ID         Transaction ID from MMT table                     --
--  P_ORGANIZATION_ID    Organization ID                                   --
--  P_ITEM_ID            Inventory Item ID                                 --
--  P_TRANSACTION_DATE   Event Date                                        --
--  P_COGS_GROUP_ID      Cost Group ID                                     --
--  P_QUANTITY           Sales Order Issue Quantity as a POSITIVE value    --
--                                                                         --
-- HISTORY:                                                                --
--    05/13/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Insert_OneSoIssue(
                p_api_version           IN          NUMBER,
                p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN          VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_request_id            IN  NUMBER,
                p_pgm_app_id            IN  NUMBER,
                p_pgm_id                IN  NUMBER,
                x_return_status         OUT NOCOPY  VARCHAR2,
                p_cogs_om_line_id       IN  NUMBER,
                p_cogs_acct_id          IN  NUMBER,
                p_def_cogs_acct_id      IN  NUMBER,
                p_mmt_txn_id            IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_transaction_date      IN  DATE,
                p_cost_group_id         IN  NUMBER,
                p_quantity              IN  NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_OneRmaReceipt   This procedure is very similar to the           --
--           Insert_RmaReceipts() procedure above.  It differs in that the --
--           above procedure handles bulk inserts and is called during one --
--           of the phases of the concurrent request, while this version   --
--           inserts one RMA receipt at a time into the data model, and is --
--           called from the Cost Processor.                               --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_RMA_OM_LINE_ID     Line_ID of the RMA from OM table                  --
--  P_COGS_OM_LINE_ID    Line_ID of the Original Sales Order Issue         --
--                       referrred to by this RMA Receipt.                 --
--  P_MMT_TXN_ID         Transaction ID from MMT table                     --
--  P_ORGANIZATION_ID    Organization ID                                   --
--  P_ITEM_ID            Inventory Item ID                                 --
--  P_TRANSACTION_DATE   Event Date                                        --
--  P_QUANTITY           Event Quantity                                    --
--  X_COGS_PERCENTAGE    Returns the % at which this RMA will be applied   --
--                       to COGS.                                          --
--                                                                         --
-- HISTORY:                                                                --
--    05/13/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Insert_OneRmaReceipt(
                p_api_version           IN          NUMBER,
                p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN          VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_request_id            IN  NUMBER,
                p_pgm_app_id            IN  NUMBER,
                p_pgm_id                IN  NUMBER,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_rma_om_line_id        IN  NUMBER,
                p_cogs_om_line_id       IN  NUMBER,
                p_mmt_txn_id            IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_transaction_date      IN  DATE,
                p_quantity              IN  NUMBER,
                x_event_id              OUT NOCOPY  NUMBER,
                x_cogs_percentage       OUT NOCOPY  NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Record_SoIssueCost                                                     --
--           This procedure is called by the distribution processors to    --
--           record the outgoing cost of the item at the time of the sales --
--           order issue.  The logic is standard across cost methods so    --
--           it can be called for all perpetual and PAC types.             --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_COGS_OM_LINE_ID    OM Line_ID of the Sales Order issue               --
--  P_PAC_COST_TYPE_ID   Periodic Cost Type, Leave NULL for perpetual      --
--  P_UNIT_MATERIAL_COST                                                   --
--  P_UNIT_MOH_COST                                                        --
--  P_UNIT_RESOURCE_COST                                                   --
--  P_UNIT_OP_COST                                                         --
--  P_UNIT_OVERHEAD_COST                                                   --
--  P_UNIT_COST                                                            --
--  P_TXN_QUANTITY                                                         --
--                                                                         --
-- HISTORY:                                                                --
--    05/16/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Record_SoIssueCost(
                p_api_version           IN  NUMBER,
                p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_request_id            IN  NUMBER,
                p_pgm_app_id            IN  NUMBER,
                p_pgm_id                IN  NUMBER,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_cogs_om_line_id       IN  NUMBER,
                p_pac_cost_type_id      IN  NUMBER,
                p_unit_material_cost    IN  NUMBER,
                p_unit_moh_cost         IN  NUMBER,
                p_unit_resource_cost    IN  NUMBER,
                p_unit_op_cost          IN  NUMBER,
                p_unit_overhead_cost    IN  NUMBER,
                p_unit_cost             IN  NUMBER,
                p_txn_quantity          IN  NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_RmaReceipt                                                     --
--           This procedure is called by the distribution processors for   --
--           all perpetual cost methods to create the accounting entries   --
--           for RMAs that are linked to forward flow sales orders with    --
--           COGS deferral.                                                --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_RMA_OM_LINE_ID     OM Line ID of the RMA Receipt                     --
--  P_COGS_OM_LINE_ID    OM Line_ID of the Sales Order Issue, not the RMA  --
--  P_COST_TYPE_ID       Cost Type if Periodic, Cost Method if perpetual   --
--  P_TXN_QUANTITY       RMA Receipt quantity                              --
--  P_COGS_PERCENTAGE    Latest COGS Percentage reported for this OM line  --
--                                                                         --
-- HISTORY:                                                                --
--    05/16/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Process_RmaReceipt(
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_rma_om_line_id        IN  NUMBER,
                p_cogs_om_line_id       IN  NUMBER,
                p_cost_type_id          IN  NUMBER,
                p_txn_quantity          IN  NUMBER,
                p_cogs_percentage       IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_transaction_id        IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_sob_id                IN  NUMBER,
                p_txn_date              IN  DATE,
                p_txn_src_id            IN  NUMBER,
                p_src_type_id           IN  NUMBER,
                p_pri_curr              IN  VARCHAR2,
                p_alt_curr              IN  VARCHAR2,
                p_conv_date             IN  DATE,
                p_conv_rate             IN  NUMBER,
                p_conv_type             IN  VARCHAR2,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_req_id                IN  NUMBER,
                p_prg_appl_id           IN  NUMBER,
                p_prg_id                IN  NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_CogsRecognitionTxn                                             --
--           This procedure is called by the distribution processors for   --
--           all perpetual cost methods to create the accounting entries   --
--           for COGS Recognition Events.                                  --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_COGS_OM_LINE_ID    OM Line_ID of the Sales Order issue               --
--  All other parameters are pretty standard for Cost Processing           --
--                                                                         --
-- HISTORY:                                                                --
--    05/17/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Process_CogsRecognitionTxn(
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_cogs_om_line_id       IN  NUMBER,
                p_transaction_id        IN  NUMBER,
                p_txn_quantity          IN  NUMBER,
                p_organization_id       IN  NUMBER,
                p_item_id               IN  NUMBER,
                p_sob_id                IN  NUMBER,
                p_txn_date              IN  DATE,
                p_txn_src_id            IN  NUMBER,
                p_src_type_id           IN  NUMBER,
                p_pri_curr              IN  VARCHAR2,
                p_alt_curr              IN  VARCHAR2,
                p_conv_date             IN  DATE,
                p_conv_rate             IN  NUMBER,
                p_conv_type             IN  VARCHAR2,
                p_user_id               IN  NUMBER,
                p_login_id              IN  NUMBER,
                p_req_id                IN  NUMBER,
                p_prg_appl_id           IN  NUMBER,
                p_prg_id                IN  NUMBER
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Cost_BulkCogsRecTxns                                                   --
--           This procedure is called in phase 4 of the concurrent request --
--           to create the accounting distributions for all of the COGS    --
--           Recognition Events that were created during this run of the   --
--           concurrent request.                                           --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--     Standard return status and Who columns                              --
--                                                                         --
-- HISTORY:                                                                --
--    05/17/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Cost_BulkCogsRecTxns(
                x_return_status         OUT NOCOPY  VARCHAR2,
                p_request_id      IN   NUMBER,
                p_user_id         IN   NUMBER,
                p_login_id        IN   NUMBER,
                p_pgm_app_id      IN   NUMBER,
                p_pgm_id          IN   NUMBER,
                p_ledger_id       IN   NUMBER DEFAULT NULL   --BUG5726230
               ,p_neg_req_id      IN   NUMBER DEFAULT NULL   --BUG7387575
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_PacSoIssue    This is the PAC version of Insert_OneSoIssue().   --
--             It creates a new row in CRCML for the given OM Line ID and  --
--             PAC cost type ID.  The purpose is to record the SO issue    --
--             cost so that future related events (e.g. COGS Recognition)  --
--             can query this row and create accting with these amounts.   --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_TRANSACTION_ID     MMT Transaction ID                                --
--  P_LAYER_ID           PAC Cost Layer ID (CPIC, CPICD)                   --
--  P_COST_TYPE_ID       PAC Cost Type ID                                  --
--  P_COST_GROUP_ID      PAC Cost Group ID                                 --
--                                                                         --
-- HISTORY:                                                                --
--    06/27/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Insert_PacSoIssue(
                p_api_version      IN  NUMBER,
                p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    OUT NOCOPY VARCHAR2,
                x_msg_count        OUT NOCOPY NUMBER,
                x_msg_data         OUT NOCOPY VARCHAR2,
                p_transaction_id   IN  NUMBER,
                p_layer_id         IN  NUMBER,
                p_cost_type_id     IN  NUMBER,
                p_cost_group_id    IN  NUMBER,
                p_user_id          IN  NUMBER,
                p_login_id         IN  NUMBER,
                p_request_id       IN  NUMBER,
                p_pgm_app_id       IN  NUMBER,
                p_pgm_id           IN  NUMBER
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_PacRmaReceipt  The PAC equivalent of Process_OneRmaRecipt()    --
--            This procedure creates the distributions for RMAs that refer --
--            to an original sales order for which COGS was deferred.  It  --
--            creates credits to Deferred COGS and COGS as appropriate.    --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_AE_TXN_REC       Transaction Record used throughout PAC processor    --
--  P_AE_CURR_REC      Currency Record used throughout PAC processor       --
--  P_DR_FLAG          Debit = True / Credit = False                       --
--  P_COGS_OM_LINE_ID  OM Line ID of the sales order to which this RMA refers
--  L_AE_LINE_TBL      Table where the distributions are built             --
--                                                                         --
-- HISTORY:                                                                --
--    06/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Process_PacRmaReceipt(
                p_ae_txn_rec       IN  CSTPALTY.cst_ae_txn_rec_type,
                p_ae_curr_rec      IN  CSTPALTY.cst_ae_curr_rec_type,
                p_dr_flag          IN  BOOLEAN,
                p_cogs_om_line_id  IN  NUMBER,
                l_ae_line_tbl      IN OUT NOCOPY      CSTPALTY.cst_ae_line_tbl_type,
                x_ae_err_rec       OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Process_PacCogsRecTxn  PAC equivalent of Process_CogsRecognitionTxn()  --
--            This procedure is called from the PAC distribution processor --
--            to create the accounting entries for COGS Recognition events --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_AE_TXN_REC       Transaction Record used throughout PAC processor    --
--  P_AE_CURR_REC      Currency Record used throughout PAC processor       --
--  L_AE_LINE_TBL      Table where the distributions are built             --
--                                                                         --
-- HISTORY:                                                                --
--    06/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Process_PacCogsRecTxn(
                p_ae_txn_rec       IN  CSTPALTY.cst_ae_txn_rec_type,
                p_ae_curr_rec      IN  CSTPALTY.cst_ae_curr_rec_type,
                l_ae_line_tbl      IN OUT NOCOPY      CSTPALTY.cst_ae_line_tbl_type,
                x_ae_err_rec       OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Print_MessageStack                                                     --
--           This procedure is called from Match_RevenueCogs() to spit out --
--           the contents of the message stack to the log file.            --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--     none                                                                --
--                                                                         --
-- HISTORY:                                                                --
--    05/17/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Print_MessageStack;

 /*
    In the procedure definitions, there will be notes like "Only used in perpetual" and "Only used in PAC"
    This is due because the same three procedures will be used for both the Perpetual and Periodic
    Revenue/COGS Matching Report.  Therefore, instead of writing the three procedures twice with slightly
    different paramenters, the 3 procedures will be written with a common set of parameters and the specific
    concurrent program will take care of setting them apporpriately
 */

 /*===========================================================================*/
 --      API name        : Generate_DefCOGSXml
 --      Type            : Private
 --      Function        : Generate XML Data for Deferred COGS Report
 --                        Report
 --      Pre-reqs        : None.
 --      Parameters      :
 --      in              : p_cost_method           in number
 --			 : p_ledger_id		   in number	 (Only used in perpetual)
 --			 : p_pac_legal_entity	   in number     (Only used in PAC)
 --                      : p_pac_cost_type	   in number     (Only used in PAC)
 --			 : p_pac_cost_group	   in number     (Only used in PAC)
 --                      : p_period_name 	   in varchar2
 --                      : p_sales_order_date_low  in varchar2
 --                      : p_sales_order_date_high in varchar2
 --			 : p_all_lines		   in varchar2
 --                      : p_api_version           in number
 --
 --      out             :
 --                      : errcode                 OUT varchar2
 --                      : errno                   OUT number
 --
 --      Version         : Current version         1.0
 --                      : Initial version         1.0
 --      History         : 6/24/2005	David Gottlieb	Created
 --      Notes           : This Procedure is called by the Deferred COGS Report
 --                        This is the wrapper procedure that calls the other
 --                        procedures to generate XML data according to report parameters.
 -- End of comments
 /*===========================================================================*/

 procedure Generate_DefCOGSXml (
   errcode			out nocopy	varchar2,
   err_code 			out nocopy      number,
   p_cost_method		in 		number,
   p_ledger_id			in 		number,
   p_pac_legal_entity		in 		number,
   p_pac_cost_type	  	in 		number,
   p_pac_cost_group		in 		number,
   p_period_name 	  	in 		varchar2,
   p_sales_order_date_low	in		varchar2,
   p_sales_order_date_high 	in 		varchar2,
   p_all_lines			in 		varchar2,
   p_api_version           	in 		number);

 /*===========================================================================*/
 --      API name        : add_parameters
 --      Type            : Private
 --      Function        : Generate XML data for Parameters and append it to
 --                        output
 --      Pre-reqs        : None.
 --      Parameters      :
 --      in              : p_api_version           in number
 --                      : p_init_msg_list         in varchar2
 --                      : p_validation_level      in number
 --			 : p_cost_method           in number
 --  			 : p_operating_unit	   in number
 --			 : p_ledger_id		   in number
 --			 : p_pac_legal_entity	   in number
 --                      : p_pac_cost_type	   in number
 --			 : p_pac_cost_group        in number
 --                      : p_period_name 	   in varchar2
 --                      : p_sales_order_date_low  in varchar2
 --                      : p_sales_order_date_high in varchar2
 --			 : p_all_lines		   in varchar2
 --
 --      out             :
 --                      : x_return_status         out nocopy varchar2
 --                      : x_msg_count             out nocopy number
 --                      : x_msg_data              out nocopy varchar2
 --
 --      in out          :
 --                      : x_xml_doc               in out nocopy clob
 --
 --      Version         : Current version         1.0
 --                      : Initial version         1.0
 --      History         : 6/24/2005	David Gottlieb	Created
 --      Notes           : This Procedure is called by Generate_DefCOSXml
 --                        procedure. The procedure generates XML data for the
 --                        report parameters and appends it to the report
 --                        output.
 -- End of comments
 /*===========================================================================*/

 procedure Add_Parameters (
   p_api_version           in              number,
   p_init_msg_list         in              varchar2,
   p_validation_level      in              number,
   x_return_status         out nocopy      varchar2,
   x_msg_count             out nocopy      number,
   x_msg_data              out nocopy      varchar2,
   i_cost_method           in              number,
   i_operating_unit	   in		   number,
   i_ledger_id		   in		   number,
   i_pac_legal_entity	   in 		   number,
   i_pac_cost_type	   in		   number,
   i_pac_cost_group	   in		   number,
   i_period_name           in              varchar2,
   i_sales_order_date_low  in              varchar2,
   i_sales_order_date_high in              varchar2,
   i_all_lines		   in		   varchar2,
   x_xml_doc               in out nocopy   clob);

 /*===========================================================================*/
 --      API name        : Add_DefCOGSData
 --      Type            : Private
 --      Function        : Generate XML data from sql query and append it to
 --                        output
 --      Pre-reqs        : None.
 --      Parameters      :
 --      in              : p_api_version           in number
 --                      : p_init_msg_list         in varchar2
 --                      : p_validation_level      in number
 --			 : i_cost_method           in number
 --			 : i_operating_unit	   in number
 --			 : i_ledger_id		   in number
 -- 			 : i_pac_legal_entity	   in number
 --   			 : i_pac_cost_type	   in number
 --			 : i_pac_cost_group	   in number
 --                      : i_period_name 	   in varchar2
 --                      : i_sales_order_date_low  in date
 --                      : i_sales_order_date_high in date
 --                      : i_set_of_books_id	   in number
 --			 : i_all_lines		   in varchar2
 --
 --      out             : x_return_status         out nocopy varchar2
 --                      : x_msg_count             out nocopy number
 --                      : x_msg_data              out nocopy varchar2
 --
 --      in out          : x_xml_doc               in out nocopy clob
 --
 --      Version         : Current version         1.0
 --                      : Initial version         1.0
 --      History         : 6/24/2005	David Gottlieb	Created
 --      Notes           : This Procedure is called by Generate_DefCOGSXml
 --                        procedure. The procedure generates XML data from
 --                        sql query and appends it to the report output.
 -- End of comments
 /*===========================================================================*/

 procedure Add_DefCOGSData (
   p_api_version           in              number,
   p_init_msg_list         in              varchar2,
   p_validation_level      in              number,
   x_return_status         out nocopy      varchar2,
   x_msg_count             out nocopy      number,
   x_msg_data              out nocopy      varchar2,
   i_cost_method           in              number,
   i_operating_unit	   in		   number,
   i_ledger_id		   in		   number,
   i_pac_legal_entity      in		   number,
   i_pac_cost_type	   in 		   number,
   i_pac_cost_group	   in		   number,
   i_period_name           in              varchar2,
   i_sales_order_date_low  in              date,
   i_sales_order_date_high in              date,
   i_all_lines             in              varchar2,
   x_xml_doc               in out nocopy   clob);


------------------------------------------------
-- Master ordonnancer for multi thread execution
------------------------------------------------
PROCEDURE ordonnancer
(errbuf         OUT  NOCOPY   VARCHAR2
,retcode        OUT  NOCOPY   VARCHAR2
,p_batch_size   IN   NUMBER  DEFAULT 1000
,p_nb_worker    IN   NUMBER  DEFAULT 4
,p_api_version  IN   NUMBER
,p_phase        IN   NUMBER
,p_low_date     IN   VARCHAR2
,p_high_date    IN   VARCHAR2
,p_ledger_id    IN   NUMBER  DEFAULT NULL);


END CST_RevenueCogsMatch_PVT;

/
