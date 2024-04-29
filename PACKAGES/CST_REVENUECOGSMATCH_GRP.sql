--------------------------------------------------------
--  DDL for Package CST_REVENUECOGSMATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_REVENUECOGSMATCH_GRP" AUTHID CURRENT_USER AS
/* $Header: CSTRCMGS.pls 120.0.12010000.1 2008/07/24 17:23:39 appldev ship $ */



-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Receive_CloseLineEvent  The Order Management module will call this     --
--                          procedure during line closure when they need   --
--                          to notify Costing of a revenue line ID that    --
--                          will not be invoiced in AR.  By calling this   --
--                          procedure they are essentially telling Costing --
--                          that revenue is recognized at 100% for this    --
--                          order line.                                    --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- STANDARD PARAMETERS                                                     --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- API SPECIFIC PARAMETERS                                                 --
--  P_REVENUE_EVENT_LINE_ID  Order Line ID for which COGS will be matched  --
--                           against, but for which there was no invoicing --
--  P_EVENT_DATE             Date that the order line is closed            --
--  P_OU_ID                  Operating Unit ID                             --
--  P_INVENTORY_ITEM_ID      Inventory Item ID                             --
--                                                                         --
-- HISTORY:                                                                --
--    04/28/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Receive_CloseLineEvent(
                p_api_version           IN          NUMBER,
                p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN          VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_revenue_event_line_id IN          NUMBER,
                p_event_date            IN          DATE,
                p_ou_id                 IN          NUMBER,
                p_inventory_item_id     IN          NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Return_PeriodStatuses   Oracle Receivables will call this procedure    --
--                          whenever they attempt to reopen one of their   --
--                          accounting periods for a given set of books.   --
--                          This procedure will check the Costing period   --
--                          for all of the organizations that belong to    --
--                          that set of books.  If any are closed, it will --
--                          indicate this upon return.                     --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- STANDARD PARAMETERS                                                     --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- API SPECIFIC PARAMETERS                                                 --
--  P_SET_OF_BOOKS_ID         Set of Books Unique Identifier               --
--  P_EFFECTIVE_PERIOD_NUM    Period Year * 10000 + Period Num             --
--  X_CLOSED_CST_PERIODS      'Y' if any of the organizations in the set   --
--                            of books passed in have a closed period,     --
--                            'N' otherwise                                --
--                                                                         --
-- HISTORY:                                                                --
--    05/09/05     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Return_PeriodStatuses(
                p_api_version           IN          NUMBER,
                p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN          VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY  VARCHAR2,
                x_msg_count             OUT NOCOPY  NUMBER,
                x_msg_data              OUT NOCOPY  VARCHAR2,
                p_set_of_books_id       IN          NUMBER,
                p_effective_period_num  IN          NUMBER,
                x_closed_cst_periods    OUT NOCOPY  VARCHAR2
);

END CST_RevenueCogsMatch_GRP;

/
