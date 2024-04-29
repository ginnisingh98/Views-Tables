--------------------------------------------------------
--  DDL for Package RCV_CREATEACCOUNTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_CREATEACCOUNTING_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVVACCS.pls 120.2.12010000.2 2008/11/10 14:39:44 mpuranik ship $ */

-- Table Type definitions
TYPE RCV_AE_REC_TYPE IS RECORD (
  ACCOUNTING_EVENT_ID		NUMBER,
  EVENT_TYPE_ID                 NUMBER,
  RCV_TRANSACTION_ID            NUMBER,
  GLOBAL_PROC_FLAG              VARCHAR2(1),
  DOC_NUMBER                    VARCHAR2(20),
  DOC_HEADER_ID                 NUMBER,
  DOC_DISTRIBUTION_ID           NUMBER,
  ITEM_DESCRIPTION              VARCHAR2(240),
  ORG_ID                        NUMBER,
  ORGANIZATION_ID               NUMBER,
  SET_OF_BOOKS_ID               NUMBER,
  ACTUAL_FLAG                	VARCHAR2(1),
  UNIT_PRICE                    NUMBER,
  PRIOR_UNIT_PRICE              NUMBER,
  TRANSACTION_AMOUNT       	NUMBER,
  PRIMARY_QUANTITY           	NUMBER,
  ACCOUNTED_DR               	NUMBER,
  ACCOUNTED_CR               	NUMBER,
  ENTERED_CR                 	NUMBER,
  ENTERED_DR                 	NUMBER,
  NR_TAX                     	NUMBER,
  REC_TAX                    	NUMBER,
  ACCOUNTED_REC_TAX          	NUMBER,
  ACCOUNTED_NR_TAX           	NUMBER,
  ENTERED_REC_TAX           	NUMBER,
  ENTERED_NR_TAX             	NUMBER,
  CURRENCY_CODE              	VARCHAR2(15),
  CURRENCY_CONVERSION_RATE      NUMBER,
  CURRENCY_CONVERSION_DATE      DATE,
  CURRENCY_CONVERSION_TYPE      VARCHAR2(30),
  TRANSACTION_DATE              DATE,
  DEBIT_ACCOUNT                 NUMBER,
  CREDIT_ACCOUNT                NUMBER,
  DEBIT_LINE_TYPE               VARCHAR2(30),
  CREDIT_LINE_TYPE              VARCHAR2(30),
  PROCUREMENT_ORG_FLAG       	VARCHAR2(1),
  INVENTORY_ITEM_ID             NUMBER,
  USSGL_TRANSACTION_CODE        VARCHAR2(32),
  GL_GROUP_ID			NUMBER,
  CREATED_BY			NUMBER,
  LAST_UPDATED_BY		NUMBER,
  LAST_UPDATE_LOGIN             NUMBER,
  REQUEST_ID			NUMBER,
  PROGRAM_APPLICATION_ID        NUMBER,
  PROGRAM_ID                    NUMBER,
  /* Support for Landed Cost Management */
  LDD_COST_ABS_ENTERED          NUMBER,
  LDD_COST_ABS_ACCOUNTED        NUMBER,
  LCM_ACCOUNT_ID                NUMBER,
  UNIT_LANDED_COST              NUMBER
);

-- Miscellaneous GL Information for Journal Import Process
TYPE RCV_AE_GLINFO_REC_TYPE IS RECORD (
  APPLICATION_ID             	NUMBER,
  PERIOD_NAME                	VARCHAR2(15),
  CHART_OF_ACCOUNTS_ID      	NUMBER,
  SET_OF_BOOKS_ID            	NUMBER,
  CURRENCY_CODE              	VARCHAR2(15),
  CURRENCY_PRECISION         	NUMBER,
  MIN_ACCT_UNIT              	NUMBER,
  USER_JE_SOURCE_NAME        	VARCHAR2(25),
  USER_JE_CATEGORY_NAME     	VARCHAR2(25),
  ENCUMBRANCE_TYPE_ID        	NUMBER,
  PURCH_ENCUMBRANCE_FLAG     	VARCHAR2(1)
);

-- Currency Information
TYPE RCV_CURR_REC_TYPE IS RECORD (
  DOCUMENT_CURRENCY          	VARCHAR2(15),
  FUNCTIONAL_CURRENCY        	VARCHAR2(15),
  MIN_ACCT_UNIT_DOC	      	NUMBER,
  MIN_ACCT_UNIT_FUNC         	NUMBER,
  PRECISION_DOC			NUMBER,
  PRECISION_FUNC             	NUMBER,
  CURRENCY_CONVERSION_TYPE      VARCHAR2(30),
  CURRENCY_CONVERSION_RATE      NUMBER,
  CURRENCY_CONVERSION_DATE      DATE
);

-----------------------------------------------------------------------------------
-- Start of Comments
--      API name        : Create_AccountingEntry
--      Type            : Private
--      Pre-reqs        :
--      Function        : To create the accounting entries for an accounting event
--                        in RCV_RECEIVING_SUBLEDGER and post the entries to GL
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_accounting_event_id   IN NUMBER       Required
--                              p_lcm_flag              IN VARCHAR2       Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           :
--                        This API is called by RCV_AccEvents_GRP.Create_AccoutingEvent
--                        to create the distributions in the sub ledger table,
--                        RCV_RECEIVING_SUB_LEDGER, corresponding to the event that is
--                        seeded in RCV_ACCOUNTING_EVENTS. The entries are also posted
--                        to the GL interface table, GL_INTERFACE.
-- End of Comments
---------------------------------------------------------------------------------------
PROCEDURE Create_AccountingEntry(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_accounting_event_id   IN 	NUMBER,
                /* Support for Landed Cost Management */
                p_lcm_flag              IN 	VARCHAR2 := 'N'
);

----------------------------------------------------------------------------------
-- API Name         : Get_AccountingLineType
-- Type             : Private
-- Function         : The API returns the Accounting Line Type for an accounting
--                    event. It returns the line types for both Credit and Debit
--                    lines.
-- Parameters       :
-- IN               : p_event_type_id     : Event Type (RCV_SeedEvent_PVT)
--                    p_parent_txn_type   : Transaction Type of the Parent of the
--                                          current event
--                    p_proc_org_flag     : Whether the Organization where accounting
--                                          event occured is facing the supplier
--                    p_one_time_item_flag: Whether the item associated with the
--                                          event is a one-time item
--                    p_destination_type  : Destination_Type_Code for the Event
--                                          ('Inventory', 'Shop Floor', 'Expense')
--                    p_global_proc_flag  : Whether event has been created in a
--                                          global procurement scenario
-- OUT              : x_debit_line_type   : Accounting Line Type for Debit
--                    x_credit_line_type  : Accounting Line Type for Credit
----------------------------------------------------------------------------------
PROCEDURE Get_AccountingLineType(
                p_api_version         IN NUMBER,
                p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	        x_return_status	      OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY 	VARCHAR2,
                p_event_type_id       IN 		NUMBER,
                p_parent_txn_type     IN 		VARCHAR2,
                p_proc_org_flag       IN 		VARCHAR2,
                p_one_time_item_flag  IN 		VARCHAR2,
                p_destination_type    IN 		VARCHAR2,
                p_global_proc_flag    IN 		VARCHAR2,
                x_debit_line_type     OUT NOCOPY 	VARCHAR2,
                x_credit_line_type    OUT NOCOPY	VARCHAR2
);


----------------------------------------------------------------------------------
-- API Name         : Insert_SubLedgerLines
-- Type             : Private
-- Function         : The API inserts an entry in RCV_RECEIVING_SUB_LEDGER
--                    depending on information passed in P_RCV_AE_LINE and
--                    P_GLINFO structures
-- Parameters       :
-- IN               : P_RCV_AE_LINE : Structure containing the accounting information
--                                    (Credit/Debit) for an event
--                    P_GLINFO      : Structure containing the GL Information
--                                    for the event
-- OUT              :
----------------------------------------------------------------------------------
PROCEDURE Insert_SubLedgerLines(
                p_api_version         IN NUMBER,
                p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	        x_return_status	      OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                p_rcv_ae_line         IN  RCV_AE_REC_TYPE,
                p_glinfo              IN  RCV_AE_GLINFO_REC_TYPE
);

----------------------------------------------------------------------------------
-- API Name         : Get_GLInformation
-- Type             : Private
-- Function         : The Function returns information from GL tables
--                    into a structure of type RCV_AE_GLINFO_REC_TYPE. This
--                    information is generated for each event since events
--                    could possibly be in different Operating Units, Sets of Books
-- Parameters       :
-- IN               : p_event_date: Event Date
--                    p_event_doc_num : Document Number for the Event (PO Number)
--                    p_event_type_id : Event Type ID (RCV_SeedEvents_PVT lists
--                    all such events
--                    p_set_of_books_id:Set of Books ID
-- OUT              :
----------------------------------------------------------------------------------

PROCEDURE Get_GLInformation(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_event_date            IN  DATE,
                p_event_doc_num         IN  VARCHAR2,
                p_event_type_id         IN  NUMBER,
                p_set_of_books_id       IN  NUMBER,
                x_gl_information        OUT NOCOPY RCV_AE_GLINFO_REC_TYPE
);
END RCV_CreateAccounting_PVT;

/
