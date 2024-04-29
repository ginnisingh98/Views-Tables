--------------------------------------------------------
--  DDL for Package RCV_SEEDEVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SEEDEVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVVRUTS.pls 120.1.12010000.3 2008/11/10 14:47:45 mpuranik ship $ */

-- Receiving Event Types. The event types are also seeded in the
-- RCV_ACCOUNTING_EVENT_TYPES table.
RECEIVE                         CONSTANT  NUMBER  := 1;
DELIVER                         CONSTANT  NUMBER  := 2;
CORRECT                         CONSTANT  NUMBER  := 3;
MATCH                           CONSTANT  NUMBER  := 4;
RETURN_TO_RECEIVING             CONSTANT  NUMBER  := 5;
RETURN_TO_VENDOR                CONSTANT  NUMBER  := 6;
ADJUST_RECEIVE                  CONSTANT  NUMBER  := 7;
ADJUST_DELIVER                  CONSTANT  NUMBER  := 8;
LOGICAL_RECEIVE                 CONSTANT  NUMBER  := 9;
LOGICAL_RETURN_TO_VENDOR        CONSTANT  NUMBER  := 10;
INTERCOMPANY_INVOICE            CONSTANT  NUMBER  := 11;
INTERCOMPANY_REVERSAL           CONSTANT  NUMBER  := 12;
ENCUMBRANCE_REVERSAL            CONSTANT  NUMBER  := 13;

-- Record Type to Store Accounting Event information.
TYPE rcv_event_rec_type is RECORD
(
           event_type_id                NUMBER,
           event_source                 VARCHAR2(25),
           rcv_transaction_id           NUMBER          := NULL,
           direct_delivery_flag         VARCHAR2(1)     := 'N',
           inv_distribution_id          NUMBER          := NULL,
           transaction_date             DATE            := sysdate,
           po_header_id                 NUMBER          := NULL,
           po_release_id                NUMBER          := NULL,
           po_line_id                   NUMBER          := NULL,
           po_line_location_id          NUMBER          := NULL,
           po_distribution_id           NUMBER          := NULL,
           trx_flow_header_id           NUMBER          := NULL,
	   set_of_books_id		NUMBER		:= NULL,
           org_id                       NUMBER          := NULL,
           transfer_org_id              NUMBER          := NULL,
           organization_id              NUMBER          := NULL,
           transfer_organization_id     NUMBER          := NULL,
           item_id                      NUMBER          := NULL,
           unit_price                   NUMBER          := NULL,
           unit_nr_tax                  NUMBER          := NULL,
           unit_rec_tax                 NUMBER          := NULL,
           prior_unit_price             NUMBER          := NULL,
           prior_nr_tax                 NUMBER          := NULL,
           prior_rec_tax                NUMBER          := NULL,
           intercompany_pricing_option  NUMBER          := 1,
           service_flag                 VARCHAR2(1)     := 'N',
           transaction_amount           NUMBER          := NULL,
           currency_code                VARCHAR2(15)    := NULL,
           currency_conversion_type     VARCHAR2(30)    := NULL,
           currency_conversion_rate     NUMBER          := 1,
           currency_conversion_date     DATE            := sysdate,
           intercompany_price           NUMBER          := NULL,
	   intercompany_curr_code	VARCHAR2(15)	:= NULL,
           transaction_uom              VARCHAR2(25)    := NULL,
	   trx_uom_code			VARCHAR2(3)	:= NULL,
           transaction_quantity         NUMBER          := NULL,
           primary_uom                  VARCHAR2(25)    := NULL,
           primary_quantity             NUMBER          := NULL,
	   source_doc_uom		VARCHAR2(25)	:= NULL,
	   source_doc_quantity		NUMBER		:= NULL,
           destination_type_code        VARCHAR2(25)    := NULL,
           cross_ou_flag                VARCHAR2(1)     := 'N',
           procurement_org_flag         VARCHAR2(1)     := 'N',
           ship_to_org_flag             VARCHAR2(1)     := 'N',
           drop_ship_flag               NUMBER          := 0,
           debit_account_id             NUMBER          := NULL,
           credit_account_id            NUMBER          := NULL,
           intercompany_cogs_account_id NUMBER          := NULL,
            /* Support for Landed Cost Management */
	   lcm_account_id               NUMBER          := NULL,
	   unit_landed_cost             NUMBER          := NULL
);

-- Table type to store a table of Accounting event records
TYPE rcv_event_tbl_type is TABLE OF rcv_event_rec_type
INDEX BY BINARY_INTEGER;


--      API name        : Seed_RAEEvent
--      Type            : Private
--      Function        : To seed accounting event in RCV_ACCOUNTING_EVENTS.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_event_source          IN VARCHAR2     Required
--                              p_event_type_id         IN NUMBER       Required
--                              p_rcv_transaction_id    IN NUMBER       Optional
--				p_inv_distribution_id	IN NUMBER	Optional
--                              p_po_distribution_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--                              p_cross_ou_flag         IN VARCHAR2	Optional
--					Default = 'N'
--                              p_procurement_org_flag  IN VARCHAR2	Optional
--                                      Default = 'Y'
--				p_drop_ship_flag	IN NUMBER	Optional
--                                      Default = 'Y'
--                              p_org_id                IN NUMBER	Required
--                              p_organization_id       IN NUMBER	Required
--                              p_transfer_org_id       IN NUMBER	Optional
--                              p_transfer_organization_id IN NUMBER	Optional
--                              p_transaction_forward_flow_rec  mtl_transaction_flow_rec_type,
--                              p_transaction_reverse_flow_rec  mtl_transaction_flow_rec_type,
--                              p_transaction_flow_rec  IN mtl_transaction_flow_rec_type
--                              p_unit_price            IN NUMBER	Required
--                              p_prior_unit_price      IN NUMBER	Optional
--                              p_lcm_flag              IN VARCHAR2
--
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_rcv_event             OUT     RCV_SeedEvents_PVT.rcv_event_tbl_type;
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API is used to seed events in RCV_ACCOUNTING_EVENTS table.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Seed_RAEEvent(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 	:= FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 	:= FND_API.G_FALSE,
                p_validation_level      IN     		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_event_source          IN      	VARCHAR2,
                p_event_type_id         IN      	NUMBER,
                p_rcv_transaction_id    IN 		NUMBER		:= NULL,
                p_inv_distribution_id   IN 		NUMBER 		:= NULL,
		p_po_distribution_id	IN 		NUMBER,
                p_direct_delivery_flag  IN 		VARCHAR2	:= 'N',
                p_cross_ou_flag         IN 		VARCHAR2	:= 'N',
                p_procurement_org_flag  IN 		VARCHAR2	:= 'Y',
		p_ship_to_org_flag	IN 		VARCHAR2	:= 'Y',
		p_drop_ship_flag	IN 		NUMBER		:= 3,
                p_org_id                IN 		NUMBER,
                p_organization_id       IN 		NUMBER 		:= NULL,
		p_transfer_org_id	IN 		NUMBER 		:= NULL,
		p_transfer_organization_id	IN 	NUMBER 		:= NULL,
                p_trx_flow_header_id    IN 		NUMBER 		:= NULL,
                p_transaction_forward_flow_rec  	INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type	:= NULL,
                p_transaction_reverse_flow_rec  	INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type	:= NULL,
                p_unit_price            IN 		NUMBER,
                p_prior_unit_price      IN 		NUMBER		:= NULL,
                /* Support for Landed Cost Management */
                p_lcm_flag              IN 		VARCHAR2,
                x_rcv_event             OUT NOCOPY 	RCV_SeedEvents_PVT.rcv_event_rec_type

);

-- Start of comments
--      API name        : Get_TransactionAmount
--      Type            : Private
--      Function        : Returns the transaction amount. Used for service line types.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_transaction_amount    OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the transaction amount. It should only be called for service line types.
--
-- End of comments
PROCEDURE Get_TransactionAmount(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event             IN 		RCV_SeedEvents_PVT.rcv_event_rec_type,
	  	x_transaction_amount	OUT NOCOPY	NUMBER
);

-- Start of comments
--      API name        : Get_Quantity
--      Type            : Private
--      Function        : Returns the quantity in source doc UOM. Used for encumbrance
--                        reversal events. We should only encumber upto quantity
--                        ordered. If quantity received is greater than quantity
--                        ordered, we should not encumber for the excess.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_source_doc_quantity  OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the transaction quantity. It should
--                        only be called for non-service line types.
--
-- End of comments
PROCEDURE Get_Quantity(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event             IN 		RCV_SeedEvents_PVT.rcv_event_rec_type,
                x_source_doc_quantity  OUT NOCOPY 	NUMBER
);

-- Start of comments
--      API name        : Get_UnitPrice
--      Type            : Private
--      Function        : Returns the Unit Price. Used for non-service line types.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_intercompany_pricing_option   OUT     NUMBER
--                              x_unit_price            OUT     NUMBER
--                              x_unit_landed_cost      out     NUMBER
--                              x_currency_code         OUT     VARCHAR2(3)
--                              x_incr_transfer_price   OUT     NUMBER
--                              x_incr_currency_code    OUT     VARCHAR2(15)
--
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the unit price. It should only be called for non service line types.
--
-- End of comments
PROCEDURE Get_UnitPrice(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event             IN 		RCV_SeedEvents_PVT.rcv_event_rec_type,
		p_asset_item_pricing_option   IN 	NUMBER,
		p_expense_item_pricing_option IN	NUMBER,
                /* Support for Landed Cost Management */
		p_lcm_flag              IN  VARCHAR2 := 'N',
                x_intercompany_pricing_option   OUT NOCOPY      NUMBER,
                x_unit_price            OUT NOCOPY      NUMBER,
                /* Support for Landed Cost Management */
                x_unit_landed_cost      OUT NOCOPY      NUMBER,
                x_currency_code         OUT NOCOPY      VARCHAR2,
		x_incr_transfer_price   OUT NOCOPY      NUMBER,
                x_incr_currency_code    OUT NOCOPY      VARCHAR2
);

-- Start of comments
--      API name        : Get_UnitTax
--      Type            : Private
--      Function        : Returns the recoverable and non-recoverable tax.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_unit_nr_tax           OUT     NUMBER
--                              x_unit_rec_tax          OUT     NUMBER
--                              x_prior_nr_tax          OUT     NUMBER
--                              x_prior_rec_tax         OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API returns the tax information.
--
-- End of comments
PROCEDURE Get_UnitTax(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_event             IN 		RCV_SeedEvents_PVT.rcv_event_rec_type,
                x_unit_nr_tax           OUT NOCOPY      NUMBER,
                x_unit_rec_tax          OUT NOCOPY      NUMBER,
                x_prior_nr_tax          OUT NOCOPY      NUMBER,
                x_prior_rec_tax         OUT NOCOPY      NUMBER
);


-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Convert_UOM     This function updates the record type variable         --
--                  that is passed to it. It inserts the UOM into the      --
--                  primary_uom field, then it updates the primary_        --
--                  quantity with the transaction_quantity converted to    --
--                  the new UOM and it updates the unit_price by           --
--                  converting it with the new UOM.                        --
--                                                                         --
--                  Because there are already other modules under PO_TOP   --
--                  that use the inv_convert package, we can safely use    --
--                  it here without introducing new dependencies on that   --
--                  product.                                               --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  P_EVENT_REC        Record storing an RCV Accounting Event (RAE)        --
--  X_TRANSACTION_QTY  Transaction quantity converted from source doc qty  --
--  X_PRIMARY_UOM      Converted UOM                                       --
--  X_PRIMARY_QTY      Primary quantity converted from source doc qty      --
--  X_TRX_UOM_CODE     Transaction UOM                                     --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- HISTORY:                                                                --
--    06/26/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Convert_UOM (
  P_API_VERSION        IN          NUMBER,
  P_INIT_MSG_LIST      IN          VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT             IN          VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL   IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  P_EVENT_REC          IN          RCV_SeedEvents_PVT.rcv_event_rec_type,
  X_TRANSACTION_QTY    OUT NOCOPY  NUMBER,
  X_PRIMARY_UOM        OUT NOCOPY  MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE,
  X_PRIMARY_QTY        OUT NOCOPY  NUMBER,
  X_TRX_UOM_CODE       OUT NOCOPY  VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Get_Currency    This procedure returns the currency_conversion         --
--                  parameters, conversion rate, date and type             --
--
--                  It is being coded for the purpose of providing the     --
--                  currency conversion parameters for Global Procurement  --
--                  and true drop shipment scenario, but may be used as a  --
--                  generic API to return currency conversion rates for    --
--                  Receiving transactions.                                --
--                                                                         --
--                  Logic:                                                 --
--                  If supplier facing org, if match to po use POD.rate    --
--                                          else                           --
--                                          rcv_transactions.curr_conv_rate--
--                  Else                                                   --
--                  Get the conversion type                                --
--                  Determine currency conversion rate                     --
--                                                                         --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_RCV_EVENT        Record storing an RCV Accounting Event (RAE)        --
--  X_CURRENCY_CODE                                                        --
--  X_CURRENCY_CONVERSION_RATE                                             --
--  X_CURRENCY_CONVERSION_TYPE                                             --
--  X_CURRENCY_CONVERSION_TYPE                                             --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- HISTORY:                                                                --
--    08/02/03     Anju Gupta     Created                                  --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Get_Currency(
  P_API_VERSION        		IN          NUMBER,
  P_INIT_MSG_LIST      		IN          VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT             		IN          VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL   		IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  X_RETURN_STATUS               OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY  NUMBER,
  X_MSG_DATA                    OUT NOCOPY  VARCHAR2,

  P_RCV_EVENT                   IN          RCV_SeedEvents_PVT.rcv_event_rec_type,
  X_CURRENCY_CODE               OUT NOCOPY  VARCHAR2,
  X_CURRENCY_CONVERSION_RATE    OUT NOCOPY  NUMBER,
  X_CURRENCY_CONVERSION_DATE    OUT NOCOPY  DATE,
  X_CURRENCY_CONVERSION_TYPE    OUT NOCOPY  VARCHAR2
);

-- Start of comments
--      API name        : Get_Account
--      Type            : Private
--      Function        : To get the credit and debit accounts for each event.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_event             IN RCV_SeedEvents_PVT.rcv_event_rec_type       Required
--                              p_transaction_forward_flow_rec  mtl_transaction_flow_rec_type,
--                              p_transaction_reverse_flow_rec  mtl_transaction_flow_rec_type,
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_credit_acct_id        OUT     NUMBER
--                              x_debit_acct_id         OUT     NUMBER
--                              x_ic_cogs_acct_id       OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO VENDOR transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Get_Accounts(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_rcv_event             IN 		RCV_SeedEvents_PVT.rcv_event_rec_type,
                p_transaction_forward_flow_rec  	INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type,
                p_transaction_reverse_flow_rec  	INV_TRANSACTION_FLOW_PUB.mtl_transaction_flow_rec_type,
                /* Support for Landed Cost Management */
                p_lcm_flag              IN VARCHAR2,
                x_credit_acct_id        OUT NOCOPY      NUMBER,
                x_debit_acct_id         OUT NOCOPY      NUMBER,
                x_ic_cogs_acct_id       OUT NOCOPY      NUMBER,
                x_lcm_acct_id       OUT NOCOPY      NUMBER
);



-- Start of comments
--      API name        : Get_HookAccount
--      Type            : Private
--      Function        : Call account hook to  allow customer to override default account.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--				p_rcv_transaction_id    IN NUMBER	Required
--				p_accounting_line_type	IN VARCHAR2	Required
--				p_org_id		IN NUMBER	Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_distribution_acct_id  OUT 	NUMBER
--
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO VENDOR transactions
--                        in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Get_HookAccount(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

		p_rcv_transaction_id	IN		NUMBER,
		p_accounting_line_type	IN		VARCHAR2,
		p_org_id		IN		NUMBER,
                x_distribution_acct_id  OUT NOCOPY      NUMBER
);



-- Start of comments
--      API name        : Insert_RAEEvents
--      Type            : Private
--      Function        : To insert events into the Receiving Accounting Events table.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_events_tbl        IN RCV_SeedEvents_PVT.rcv_event_tbl_type       Required
--                              p_lcm_flag              IN VARCHAR2 := 'N' Optional
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API inserts all events for a given receiving transaction
--                        into RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Insert_RAEEvents(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_rcv_events_tbl        IN 		RCV_SeedEvents_PVT.rcv_event_tbl_type,
                /* Support for Landed Cost Management */
                p_lcm_flag              IN VARCHAR2 := 'N');

-- Start of comments
--      API name        : Check_EncumbranceFlag
--      Type            : Private
--      Function        : Checks to see if encumbrance entries need to be created.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_sob_id            IN      NUMBER  Required
--
--                              x_encumbrance_flag      OUT     VARCHAR2(1)
--                              x_ussgl_option          OUT     VARCHAR2(1)
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API checks to see if encumbrance entries need to
--                        be created.
--
-- End of comments
PROCEDURE Check_EncumbranceFlag(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_sob_id            IN      	NUMBER,

                x_encumbrance_flag      OUT NOCOPY      VARCHAR2,
		x_ussgl_option		OUT NOCOPY      VARCHAR2

);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Insert_MMTEvents  This API takes a PL/SQL table as input that has one  --
--                    entry for each RAE event. It loops through the table --
--                    and calls Create_MMTRecord to create logical MMT     --
--                    transactions as appropriate for each event.          --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  P_RCV_EVENTS_TBL   Collection of events of type rcv_event_rec_type     --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--                                                                         --
-- HISTORY:                                                                --
--    7/21/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE Insert_MMTEvents (
  P_API_VERSION        IN          NUMBER,
  P_INIT_MSG_LIST      IN          VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT             IN          VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL   IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  P_RCV_EVENTS_TBL     IN          RCV_SeedEvents_PVT.rcv_event_tbl_type
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  Create_MMTRecord  This API takes an RAE record along with the          --
--                    parameters listed above and converts them into a     --
--                    single MMT record which will be used in a subsequent --
--                    function to make the physical insert into MMT        --
--                                                                         --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  P_VALIDATION_LEVEL Specify the level of validation on the inputs       --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--  P_RCV_EVENT        Represents a single RAE, used to build the MMT entry--
--  P_TXN_TYPE_ID      Txn Type ID of the new MMT row being created        --
--  P_INTERCOMPANY_PRICE  The calling fcn must determine how to populate   --
--                     this based on the txn type and on the OU's position --
--                     in the txn flow. It will represent the transfer     --
--                     price between this OU and an adjacent one.          --
--  P_INTERCOMPANY_CURR_CODE This parameter represents the currency code   --
--                     of the intercompany price.                          --
--  P_ACCT_ID          Used to populate MMT.distribution_account_id        --
--  P_SIGN             Used to set the signs (+/-) of the primary quantity --
--                     and the transaction quantity                        --
--  P_PARENT_TXN_FLAG  1 - Indicates that this is the parent transaction   --
--  P_TRANSFER_ORGANIZATION_ID The calling function should pass the        --
--                     organization from the next event.                   --
--  X_INV_TRX          Returns the record that will be inserted into MMT   --
--                                                                         --
-- HISTORY:                                                                --
--    7/21/03     Bryan Kuntz      Created                                --
-- End of comments                                                         --
-----------------------------------------------------------------------------
PROCEDURE Create_MMTRecord(
                p_api_version           IN      	NUMBER,
                p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_rcv_event             IN      	RCV_SeedEvents_PVT.rcv_event_rec_type,
                p_txn_type_id           IN      	NUMBER,
                p_intercompany_price    IN      	NUMBER,
		p_intercompany_curr_code IN		VARCHAR2,
                p_acct_id               IN      	NUMBER,
                p_sign                  IN      	NUMBER,
                p_parent_txn_flag       IN      	NUMBER,
                p_transfer_organization_id IN           NUMBER,
                x_inv_trx               OUT NOCOPY      INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_rec_type
);


END RCV_SeedEvents_PVT;

/
