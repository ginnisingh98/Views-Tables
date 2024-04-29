--------------------------------------------------------
--  DDL for Package RCV_ACCRUALACCOUNTING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ACCRUALACCOUNTING_GRP" AUTHID CURRENT_USER AS
/* $Header: RCVGCSTS.pls 120.1 2005/08/19 12:41:23 visrivas noship $ */

TYPE number_tbl IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

-- Start of comments
--	API name 	: Create_AccountingEvents
--	Type		: Group
--	Function	: To seed accounting events for receiving transactions,
--			  retroactive price adjustments and global procurement.
--	Pre-reqs	:
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--
--				p_source_type		IN VARCHAR2	Required
--				Valid values : "RECEIVING", "RETROPRICE"
--
--				The following parameters are required for a source type
--				of "RECEIVING"
--                              p_rcv_transaction_id    IN NUMBER       Optional
--                              p_direct_delivery_flag  IN VARCHAR2     Optional
--
--                              The following parameters are required for a source type
--                              of "RETROPRICE"
--                              p_po_header_id    	IN NUMBER       Optional
--                              p_po_release_id    	IN NUMBER       Optional
--                              p_po_line_id    	IN NUMBER       Optional
--                              p_po_line_location_id   IN NUMBER       Optional
--                		p_old_po_price          IN NUMBER	Optional
--                		p_new_po_price          IN NUMBER	Optional
--
--                              The following parameters have been obsoleted. AP will call
--				the Create_InterCompanyEvents to seed IC events.
--				p_invoice_distribution_id 	IN 	NUMBER Optional
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--	Version	:
--			  Initial version 	1.0
--
--	Notes		: This API creates all Receiving related accounting events in
-- 			  RCV_ACCOUNTING_EVENTS. For online accruals, it also generates
--			  the accounting entries for the event.
--			  This API is called from :
--			  1. The Receiving Transaction Processor for each transaction in
--			     RCV_Transactions.
--			  2. The PO Approvals Process for retroactive price changes.
--			  Depending on the calling process, there are three valid source types:
--                              'RECEIVING' when called by Receiving
--                              'RETROPRICE' when called by PO for retroactive price changes
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_AccountingEvents(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_commit               	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_validation_level     	IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_source_type       	IN	VARCHAR2, /*RECEIVING, RETROPRICE */

	/* The following parameters are only required for source type of Receiving */
	        p_rcv_transaction_id 	IN NUMBER DEFAULT NULL,
		p_direct_delivery_flag  IN VARCHAR2 DEFAULT NULL,

	/* The following parameters are only required for source type of RetroPrice*/
	        p_po_header_id		IN	NUMBER DEFAULT NULL,
	        p_po_release_id		IN	NUMBER DEFAULT NULL,
	        p_po_line_id		IN 	NUMBER DEFAULT NULL,
		p_po_line_location_id	IN	NUMBER DEFAULT NULL,
	        p_old_po_price    	IN 	NUMBER DEFAULT NULL,
	        p_new_po_price         	IN	NUMBER DEFAULT NULL,

        /* The following parameter has been obsoleted. AP will instead call the
	   Create_IntercompanyEvents to seed IC events. */
	        p_invoice_distribution_id	IN	NUMBER DEFAULT NULL
);
-----------------------------------------------------------------------------
-- This API is the same as the above except that it takes in an
-- additional p_gl_group_id parameter. The API would just call the above
-- API and is created in the interim for patching ease. It should be removed
-- before R12 release
------------------------------------------------------------------------------
PROCEDURE Create_AccountingEvents(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_commit               	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_validation_level     	IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_source_type       	IN	VARCHAR2,

	        p_rcv_transaction_id 	IN NUMBER DEFAULT NULL,
		p_direct_delivery_flag  IN VARCHAR2 DEFAULT NULL,
		p_gl_group_id		IN NUMBER ,

	        p_po_header_id		IN	NUMBER DEFAULT NULL,
	        p_po_release_id		IN	NUMBER DEFAULT NULL,
	        p_po_line_id		IN 	NUMBER DEFAULT NULL,
		p_po_line_location_id	IN	NUMBER DEFAULT NULL,
	        p_old_po_price    	IN 	NUMBER DEFAULT NULL,
	        p_new_po_price         	IN	NUMBER DEFAULT NULL,

	        p_invoice_distribution_id	IN	NUMBER DEFAULT NULL
);

-- Start of comments
--	API name 	: Create_InterCompanyEvents
--	Type		: Group
--	Function	: To seed accounting Intercompany events for period end accruals.
--			  When Invoice is matched to PO and validated, IC events will be
--			  seeded for Global Procurement scenarios.
--	Pre-reqs	:
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--
--				p_invoice_dist_id_tbl 	IN 	NUMBER_TBL Required
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--	Version	:
--			  Initial version 	1.0
--
--	Notes		: This API seeds Intercompany events for period end accruals.
--			  When Invoice is matched to PO and validated, AP will call this
--			  this API for period end accruals. If Invoice is for a global
--			  procurement scenario, this API will seed Intercompany events in
-- 			  RCV_ACCOUNTING_EVENTS. The intercompany invoicing program will
--			  later use these events to create intercompany invoices.
--
--			  This API is called from :
--			  1. Accounts Payables during Invoice Validation phase for period
--			     end accruals.
-- Start of comments
PROCEDURE Create_InterCompanyEvents(
	        p_api_version          	IN	NUMBER,
	        p_init_msg_list        	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_commit               	IN	VARCHAR2 := FND_API.G_FALSE,
	        p_validation_level     	IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

	        p_invoice_dist_id_tbl	IN	NUMBER_TBL
);




--	API name 	: Get_InvTransactionInfo
--	Type		: Private
--	Pre-reqs	:
--	Function	: To return the transfer price and distribution account in
--			  global procurement and drop shipment scenarios.
--	Parameters	:
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
--				x_intercompany_pricing_option   OUT	VARCHAR2(1)
--				x_currency_code		OUT 	VARCHAR2(15)
--				x_currency_conversion_rate OUT  NUMBER
--				x_currency_conversion_date OUT  DATE
--                              x_currency_conversion_type OUT  VARCHAR2(30)
--				x_distribution_acct_id	OUT 	NUMBER
--	Version	:
--			  Initial version 	1.0
--
--      Notes           :
-- 	This API is called by the receiving transaction processor for Deliver, RTR
-- 	and Corrections to Deliver/RTR transactions, to determine if the price to be
-- 	stamped on MMTT is the PO price or the transfer price. This API returns a
-- 	flag to indicate if transfer price is to be used. If the intercompany_pricing_option
--	is set to 2, the transfer price and the corresponding currency code,
-- 	currency conversion rate, date and type are returned.
-- 	The transfer price is returned in the transaction UOM.
-- 	If the returned intercompany_pricing_option is 1, the Receiving transaction
-- 	Processor should stamp the PO price as usual.
--
-- 	This API also returns the distribution account for External Drop Shipments
-- 	when the new accounting flag is checked. If the returned distribution account
-- 	is -1, the Receiving transaction processor should stamp the MMTT transaction
-- 	with the Receiving Inspection account as usual.
-- 	Otherwise, it should stamp the returned Clearing Account.
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

          p_rcv_transaction_id        IN      	     NUMBER,

          x_intercompany_pricing_option       OUT NOCOPY     NUMBER,
          x_transfer_price	      OUT NOCOPY     NUMBER,
	  x_currency_code	      OUT NOCOPY     VARCHAR2,
	  x_currency_conversion_rate  OUT NOCOPY     NUMBER,
	  x_currency_conversion_date  OUT NOCOPY     DATE,
	  x_currency_conversion_type  OUT NOCOPY     VARCHAR2,
	  x_distribution_acct_id      OUT NOCOPY     NUMBER
);


END RCV_AccrualAccounting_GRP;

 

/
