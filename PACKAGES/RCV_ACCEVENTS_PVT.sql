--------------------------------------------------------
--  DDL for Package RCV_ACCEVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ACCEVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVVRAES.pls 120.1 2005/08/19 12:44:14 visrivas noship $ */

-- Start of comments
--	API name 	: Create_ReceivingEvents
--	Type		: Private
--	Function	: To seed accounting events for receiving transactions.
--	Pre-reqs	:
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--					Default = FND_API.G_FALSE
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--	Version	:
--			  Initial version 	1.0
--
--	Notes		: This API creates all accounting events for receiving transactions
-- 			  in RCV_ACCOUNTING_EVENTS. For online accruals, it also generates
--			  the accounting entries for the event.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_ReceivingEvents(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_commit               	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_validation_level     	IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_rcv_transaction_id 	IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2 := FND_API.G_FALSE
);

-- Start of comments
--      API name        : Create_AdjustEvents
--      Type            : Private
--      Function        : To seed accounting events for retroactive price adjustments.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_po_header_id          IN NUMBER       Required
--                              p_po_release_id         IN NUMBER       Optional
--                              p_po_line_id            IN NUMBER       Optional
--                              p_po_line_location_id   IN NUMBER       Required
--                              p_old_po_price          IN NUMBER       Required
--                              p_new_po_price          IN NUMBER       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API creates all accounting events for retroactive price adjustments
--                        in RCV_ACCOUNTING_EVENTS. For online accruals, it also generates
--                        the accounting entries for the event.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_AdjustEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_po_header_id          IN      NUMBER,
                p_po_release_id         IN      NUMBER,
                p_po_line_id            IN      NUMBER DEFAULT NULL,
                p_po_line_location_id   IN      NUMBER,
                p_old_po_price          IN      NUMBER,
                p_new_po_price          IN      NUMBER

);

-- Start of comments
--      API name        : Create_ICEvents
--      Type            : Private
--      Function        : To seed Intercompany events for period end AP line matches.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_invoice_distribution_id IN NUMBER     Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count                     OUT     NUMBER
--                              x_msg_data                      OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API creates inter-company accounting events for
--			  global procurement scenarios with period-end accruals.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_ICEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_invoice_distribution_id       IN      NUMBER
);

-- Start of comments
--      API name        : Create_ReceiveEvents
--      Type            : Private
--      Function        : To seed accounting events for RECEIVE transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API creates all accounting events for RECEIVE
--                        transactions in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_ReceiveEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2 := FND_API.G_FALSE
);

-- Start of comments
--      API name        : Create_DeliverEvents
--      Type            : Private
--      Function        : To seed accounting events for DELIVER transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for DELIVER
--                        transactions in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_DeliverEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2 := FND_API.G_FALSE
);

-- Start of comments
--      API name        : Create_RTREvents
--      Type            : Private
--      Function        : To seed accounting events for RETURN TO RECEIVING transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO RECEIVING
--                        transactions in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Create_RTREvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2 := FND_API.G_FALSE
);

-- Start of comments
--      API name        : Create_RTVEvents
--      Type            : Private
--      Function        : To seed accounting events for RETURN TO VENDOR transactions.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--                              p_direct_delivery_flag  IN VARCHAR2     Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--
--
--      Notes           : This API creates all accounting events for RETURN TO VENDOR
--                        transactions in RCV_ACCOUNTING_EVENTS.
--
-- End of comments
PROCEDURE Create_RTVEvents(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                p_rcv_transaction_id    IN NUMBER,
                p_direct_delivery_flag  IN VARCHAR2 := FND_API.G_FALSE
);

-- Start of comments
--      API name        : Get_InvTransactionInfo
--      Type            : Private
--      Pre-reqs        :
--      Function        : To return the transfer price and distribution account in
--                        global procurement and drop shipment scenarios.
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER       Required
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_intercompany_pricing_option   OUT     BOOLEAN
--                              x_currency_code         OUT     VARCHAR2
--                              x_currency_conversion_rate OUT  NUMBER
--                              x_currency_conversion_date OUT  DATE
--                              x_currency_conversion_type OUT  VARCHAR2(30)
--                              x_distribution_acct_id  OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--      Notes           :
--      This API is called by the receiving transaction processor for Deliver, RTR
--      and Corrections to Deliver/RTR transactions, to determine if the price to be
--      stamped on MMTT is the PO price or the transfer price. This API returns a
--      flag to indicate if transfer price is to be used. If this flag is set to 'Y',
--      the transfer price and the corresponding currency code are returned. The
--      transfer price is returned in the transaction UOM.
--      If the returned transfer price flag is 'N', the Receiving transaction
--      Processor should stamp the PO price as usual.
--
--      This API also returns the distribution account for External Drop Shipments
--      when the new accounting flag is checked. If the returned distribution account
--      is -1, the Receiving transaction processor should stamp the MMTT transaction
--      with the Receiving Inspection account as usual.
--      Otherwise, it should stamp the returned Clearing Account.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_InvTransactionInfo(
          p_api_version               IN      NUMBER,
          p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
          p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
          p_validation_level          IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
          x_return_status             OUT NOCOPY     VARCHAR2,
          x_msg_count                 OUT NOCOPY     NUMBER,
          x_msg_data                  OUT NOCOPY     VARCHAR2,

          p_rcv_transaction_id        IN             NUMBER,

          x_intercompany_pricing_option OUT NOCOPY   NUMBER,
          x_transfer_price            OUT NOCOPY     NUMBER,
          x_currency_code             OUT NOCOPY     VARCHAR2,
          x_currency_conversion_rate  OUT NOCOPY     NUMBER,
          x_currency_conversion_date  OUT NOCOPY     DATE,
          x_currency_conversion_type  OUT NOCOPY     VARCHAR2,
          x_distribution_acct_id      OUT NOCOPY     NUMBER);

END RCV_AccEvents_PVT;

 

/
