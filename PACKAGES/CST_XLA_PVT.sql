--------------------------------------------------------
--  DDL for Package CST_XLA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_XLA_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVXLAS.pls 120.7.12010000.2 2010/02/18 01:21:33 ipineda ship $ */
TYPE t_cst_inv_event_info IS RECORD
(
  TRANSACTION_ID   NUMBER,
  ORGANIZATION_ID  NUMBER,
  TXN_SRC_TYPE_ID  NUMBER,
  EVENT_TYPE_CODE  VARCHAR2(30)
);
TYPE t_cst_inv_events IS TABLE OF t_cst_inv_event_info INDEX BY BINARY_INTEGER;

--------------------------------------------------
-- Type to store Inventory Transaction information
-- to generate an SLA event
--------------------------------------------------
TYPE t_xla_inv_trx_info IS RECORD
(
  TRANSACTION_DATE       DATE,
  TRANSACTION_ID         NUMBER,
  TXN_TYPE_ID            NUMBER,
  TXN_SRC_TYPE_ID        NUMBER,
  TXN_ACTION_ID          NUMBER,
  FOB_POINT              NUMBER,
  ATTRIBUTE              VARCHAR2(30),
  TXN_ORGANIZATION_ID    NUMBER,
  TXFR_ORGANIZATION_ID   NUMBER,
  TP                     VARCHAR2(1),
  ENCUMBRANCE_FLAG       VARCHAR2(1),
  PRIMARY_QUANTITY       NUMBER
);

--------------------------------------------------
-- Type to store Receiving Transaction information
-- to generate an SLA event
--------------------------------------------------

TYPE t_xla_rcv_trx_info IS RECORD
 (
  TRANSACTION_DATE       DATE,
  TRANSACTION_ID         NUMBER,
  ACCT_EVENT_ID          NUMBER,
  ACCT_EVENT_TYPE_ID     NUMBER,
  ATTRIBUTE              VARCHAR2(25),
  INV_ORGANIZATION_ID    NUMBER,
  OPERATING_UNIT         NUMBER,
  LEDGER_ID              NUMBER,
  ENCUMBRANCE_FLAG       VARCHAR2(1),
  TRANSACTION_NUMBER     VARCHAR2(240)
);

--------------------------------------------
-- Type to store WIP Transaction information
-- to generate an SLA event
--------------------------------------------
TYPE t_xla_wip_trx_info IS RECORD
 (
  TRANSACTION_DATE       DATE,
  TRANSACTION_ID         NUMBER,
  TXN_TYPE_ID            NUMBER,
  WIP_RESOURCE_ID        NUMBER,
  WIP_BASIS_TYPE_ID      NUMBER,
  ATTRIBUTE              VARCHAR2(30),
  INV_ORGANIZATION_ID    NUMBER
);

  /*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                            |
 |    blueprint_SLA_hook_wrap                                                 |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This is a wrapper call to blueprint_sla_hook when this is being         |
 |    called from one of the bulk insert statements since the function        |
 |     blueprint_sla_hook has out parameters, this wrapper should not         |
 |    be modified or customized                                               |
 |							                                                              |
 | PARAMETERS:                                                                |
 |       INPUT:                                                               |
 |       -p_wrap_txn_id     Transaction ID                                    |
 |       -p_wrap_tb_source       String identifying the source table of the   |
 |                             transaction that is calling the hook, the two  |
 |                             possible values are:                           |
 |                             "MMT" for transaction belonging to table       |
 |                              MTL_MATERIAL_TRANSACTIONS                     |
 |                             "WT"  for transactions belonging to table      |
 |                              WIP_TRANSACTIONS                              |
 | CALLED FROM							                                                  |
 |	 CST_XLA_PVT.CreateBulk_WIPXLAEvent                                       |
 |   CST_XLA.PVT.Create_WIPUpdateXLAEvent                                     |
 |   CST_XLA.Create_CostUpdateXLAEvent                                        |
 |	                                                                          |
 | RETURN VALUES                                                              |
 |       integer    1   Create SLA events in blue print org for this txn      |
 |                 -1   Error in the hook                                     |
 |                  0 or any other number                                     |
 |                      Do not create SLA events in blue print org for this   |
 |                      transaction  (Default)                                |
 | HISTORY                                                                    |
 |    	 04-Jan-2010   Ivan Pineda   Created                                  |
 *----------------------------------------------------------------------------*/
 FUNCTION   blueprint_sla_hook_wrap(p_wrap_txn_id	                   NUMBER,
                                    p_wrap_tb_source                  VARCHAR2)
RETURN integer;

--------------------------------------------------------------------------------------
--      API name        : Create_RCVXLAEvent
--      Type            : Private
--      Function        : To seed accounting event in SLA by calling an SLA API with
--                        required parameters
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--				                      p_trx_info              IN t_xla_rcv_trx_info
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           : The API is called from the Receiving Transactions Processor
--                        (RCVVACCB.pls)
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Create_RCVXLAEvent  (
            p_api_version       IN          NUMBER,
	    p_init_msg_list     IN          VARCHAR2,
	    p_commit            IN          VARCHAR2,
	    p_validation_level  IN          NUMBER,
	    x_return_status     OUT NOCOPY  VARCHAR2,
	    x_msg_count         OUT NOCOPY  NUMBER,
	    x_msg_data          OUT NOCOPY  VARCHAR2,

	    p_trx_info          IN          t_xla_rcv_trx_info

	    );

--------------------------------------------------------------------------------------
--      API name        : Create_INVXLAEvent
--      Type            : Private
--      Function        : To seed accounting event in SLA by calling an SLA API with
--                        required parameters
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--                              p_trx_info              IN t_xla_inv_trx_info
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           : The API is called from Cost Processors (Std - inltcp.lpc,
--                        Avg - CSTACINB.pls, FIFO/LIFO - CSTLCINB.pls)
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Create_INVXLAEvent  (
            p_api_version       IN          NUMBER,
	    p_init_msg_list     IN          VARCHAR2,
	    p_commit            IN          VARCHAR2,
	    p_validation_level  IN          NUMBER,
	    x_return_status     OUT NOCOPY  VARCHAR2,
	    x_msg_count         OUT NOCOPY  NUMBER,
	    x_msg_data          OUT NOCOPY  VARCHAR2,

	    p_trx_info          IN          t_xla_inv_trx_info

	    );

--------------------------------------------------------------------------------------
--      API name        : Create_WIPXLAEvent
--      Type            : Private
--      Function        : To seed accounting event in SLA by calling an SLA API with
--                        required parameters
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--                              p_trx_info              IN t_xla_wip_trx_info
--
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Create_WIPXLAEvent  (
            p_api_version       IN          NUMBER,
	    p_init_msg_list     IN          VARCHAR2,
	    p_commit            IN          VARCHAR2,
	    p_validation_level  IN          NUMBER,
	    x_return_status     OUT NOCOPY  VARCHAR2,
	    x_msg_count         OUT NOCOPY  NUMBER,
	    x_msg_data          OUT NOCOPY  VARCHAR2,

	    p_trx_info          IN          t_xla_wip_trx_info

	    );

--------------------------------------------------------------------------------------
--      API name        : CreateBulk_WIPXLAEvent
--      Type            : Private
--      Function        : To create WIP accounting events in bulk for a
--                        WIP transaction group and Organization
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--			        p_wcti_group_id         IN NUMBER
--				p_organization_id       IN NUMBER
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
--                        The API takes a WCTI group_id and creates events
--                        for all the transactions within that group
--                        Called from cmlwrx.lpc, cmlwsx.lpc
-- End of comments
--------------------------------------------------------------------------------------
PROCEDURE CreateBulk_WIPXLAEvent (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_wcti_group_id     IN          NUMBER,
            p_organization_id   IN          NUMBER );


--------------------------------------------------------------------------------------
--      API name        : Create_CostUpdateXLAEvent
--      Type            : Private
--      Function        : To create Standard Cost Update accounting events in bulk
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--			                        p_update_id         IN NUMBER
--				                      p_organization_id       IN NUMBER
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
--                        The API takes a Standard Cost Update ID and organization_id
--                        and creates all events associated with it.
--                        Called from cmlicu.lpc
-- End of comments
--------------------------------------------------------------------------------------
PROCEDURE Create_CostUpdateXLAEvent (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_update_id         IN          NUMBER,
            p_organization_id   IN          NUMBER );
--------------------------------------------------------------------------------------
--      API name        : Create_WIPUpdateXLAEvent
--      Type            : Private
--      Function        : To create WIP Cost Update accounting events in bulk
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER
--                              p_init_msg_list         IN VARCHAR2
--                              p_commit                IN VARCHAR2
--                              p_validation_level      IN NUMBER
--                              p_update_id         IN NUMBER
--                              p_organization_id       IN NUMBER
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--      Version :
--                        Initial version       1.0
--      Notes           :
--                        The API takes a WIP Cost Update ID and organization_id
--                        and creates all events associated with it.
--                        Called from cmlwcu.lpc
-- End of comments
--------------------------------------------------------------------------------------
PROCEDURE Create_WIPUpdateXLAEvent (
            p_api_version       IN          NUMBER,
            p_init_msg_list     IN          VARCHAR2,
            p_commit            IN          VARCHAR2,
            p_validation_level  IN          NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_msg_count         OUT NOCOPY  NUMBER,
            x_msg_data          OUT NOCOPY  VARCHAR2,

            p_update_id         IN          NUMBER,
            p_organization_id   IN          NUMBER );

------------------------
-- CST Security Policy
------------------------
FUNCTION standard_policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION MO_POLICY
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION INV_ORG_POLICY
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2;


END CST_XLA_PVT;

/
