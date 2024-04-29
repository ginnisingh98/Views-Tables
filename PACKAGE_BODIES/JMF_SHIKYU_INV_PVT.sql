--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_INV_PVT" AS
-- $Header: JMFVSKIB.pls 120.10.12010000.2 2009/04/20 11:35:04 rrajkule ship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFVSKIB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains INV related calls that the Interlock          |
--|   accesses when processing SHIKYU transactions                        |
--| HISTORY                                                               |
--|     05/09/2005 pseshadr       Created                                 |
--|     07/08/2005 vchu           Fixed GSCC error File.Pkg.21.           |
--|                               Removed the Init procedure, since GSCC  |
--|                               checker requires directly comparing     |
--|                               FND_LOG.G_CURRENT_RUNTIME_LEVEL to      |
--|                               constants for different levels.         |
--|     10/24/2005 vmutyala       Bug:-4670527, Made some changes         |
--|                               to Process_Transaction procedure        |
--|     01/26/2006 vchu           Bug 4964675.  Populate                  |
--|                               transaction_source_id column of         |
--|                               mtl_transactions_interface with         |
--|                               wip_entity_id for WIP Component Issue   |
--|                               and Return.                             |
--|     03/07/2006 vchu           Fixed the WIP Component Issue           |
--|                               transactions by multiplying the         |
--|                               quantity to be issued by -1.  Quantity  |
--|                               should be relative to the inventory.    |
--|     03/09/2006 vchu           Bug 4869546.  Shortened the transaction |
--|                               source name for MISC Issue and Receipt  |
--|                               to 'Process SHIKYU RCV Trxns' because   |
--|                               of bug 5086940.                         |
--|                               Also, stamped wip_entity_type to be 1   |
--|                               only if the transaction is WIP related, |
--|                               otherwise wip_entity_type should be     |
--|                               NULL, such as for MISC Issue and MISC   |
--|                               Receipt.                                |
--|     03/10/2006 vchu           Removed commented code.                 |
--|     03/21/2006 vchu           Changed the source name for MISC Issue  |
--|                               and Receipt back to 'Process SHIKYU     |
--|                               Receiving Transactions' since INV has   |
--|                               fixed bug 5086940                       |
--|     03/22/2006 vchu           Added a check in Process_Transaction to |
--|                               set x_return_status to                  |
--|                               FND_API.G_RET_STS_ERROR if the return   |
--|                               status from                             |
--|                               INV_TXN_MANAGER_PUB.Process_Transactions|
--|                               is NULL                                 |
--|     06/16/2006 vchu           Fixed Bug 5337725: Modified the         |
--|                               Process_Transaction procedure to get    |
--|                               the locator used to supply component to |
--|                               WIP, and then pass it to the            |
--|                               mtl_transactions_interface table, if    |
--|                               the transaction is WIP Component Issue  |
--|                               or WIP Component Return.                |
--+=======================================================================+

--=============================================
-- CONSTANTS
--=============================================
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_INV_PVT';
G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'jmf.plsql.' || G_PKG_NAME || '.';

--=============================================
-- GLOBAL VARIABLES
--=============================================

--=============================================
-- PROCEDURES AND FUNCTIONS
--=============================================

--========================================================================
-- PROCEDURE : Process_Misc_Rcpt     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--             x_return_status              Return Status
-- COMMENT   : This procedure invokes the Process_Transaction
--             with the appropriate transaction type to process
--             the Misc. rcpt transaction into Inventory.
--========================================================================
PROCEDURE Process_Misc_Rcpt
( p_subcontract_po_shipment_id IN  NUMBER
, p_osa_quantity               IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Process_Misc_Rcpt';

l_osa_item_id NUMBER;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT OSA_ITEM_ID
  INTO l_osa_item_id
  FROM JMF_SUBCONTRACT_ORDERS
  WHERE SUBCONTRACT_PO_SHIPMENT_ID = p_subcontract_po_shipment_id
  AND ROWNUM = 1;

  Process_Transaction
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_quantity                   => p_osa_quantity
  , p_item_id                    => l_osa_item_id
  , p_transaction_type_id        => 42
  , p_transaction_action_id      => 27
  , p_uom                        => p_uom
  , x_return_status              => x_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.No Date Found'
                    , 'Exception - Subcontracting Purchase Order Shipment : '
                    || p_subcontract_po_shipment_id);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;

END Process_Misc_Rcpt;

--========================================================================
-- PROCEDURE : Process_Misc_Issue     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--            x_return_status               Return Status
-- COMMENT   : This procedure invokes the Process_Transaction
--             with the appropriate transaction type to process
--             the Misc. issue transaction into Inventory.
--========================================================================
PROCEDURE Process_Misc_Issue
( p_subcontract_po_shipment_id IN  NUMBER
, p_osa_quantity               IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Process_Misc_Rcpt';

l_osa_item_id NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT OSA_ITEM_ID
  INTO l_osa_item_id
  FROM JMF_SUBCONTRACT_ORDERS
  WHERE SUBCONTRACT_PO_SHIPMENT_ID = p_subcontract_po_shipment_id
  AND ROWNUM = 1;

  Process_Transaction
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_quantity                   => p_osa_quantity
  , p_item_id                    => l_osa_item_id
  , p_transaction_type_id        => 32
  , p_transaction_action_id      => 1
  , p_uom                        => p_uom
  , x_return_status              => x_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.No Date Found'
                    , 'Exception - Subcontracting Purchase Order Shipment : '
                    || p_subcontract_po_shipment_id);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Process_Misc_Issue;

--========================================================================
-- PROCEDURE : Process_WIP_Completion     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--            x_return_status               Return Status
-- COMMENT   : This procedure invokes the Process_Transaction
--             with the appropriate transaction type to process
--             the WIP completion transaction into Inventory.
--========================================================================
PROCEDURE Process_WIP_Completion
( p_subcontract_po_shipment_id IN  NUMBER
, p_osa_quantity               IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Process_WIP_Completion';

l_osa_item_id NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT OSA_ITEM_ID
  INTO l_osa_item_id
  FROM JMF_SUBCONTRACT_ORDERS
  WHERE SUBCONTRACT_PO_SHIPMENT_ID = p_subcontract_po_shipment_id
  AND ROWNUM = 1;

  Process_Transaction
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_quantity                   => p_osa_quantity
  , p_item_id                    => l_osa_item_id
  , p_transaction_type_id        => 44
  , p_transaction_action_id      => 31
  , p_uom                        => p_uom
  , x_return_status              => x_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.No Date Found'
                    , 'Exception - Subcontracting Purchase Order Shipment : '
                    || p_subcontract_po_shipment_id);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Process_WIP_Completion;

--========================================================================
-- PROCEDURE : Process_WIP_Assy_Return     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--            x_return_status               Return Status
-- COMMENT   : This procedure invokes the Process_Transaction
--             with the appropriate transaction type to process
--             the WIP Assembly return transaction into Inventory.
--========================================================================
PROCEDURE Process_WIP_Assy_Return
( p_subcontract_po_shipment_id IN  NUMBER
, p_osa_quantity               IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Process_WIP_Assy_Return';

l_osa_item_id NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT OSA_ITEM_ID
  INTO l_osa_item_id
  FROM JMF_SUBCONTRACT_ORDERS
  WHERE SUBCONTRACT_PO_SHIPMENT_ID = p_subcontract_po_shipment_id
  AND ROWNUM = 1;

  Process_Transaction
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_quantity                   => p_osa_quantity
  , p_item_id                    => l_osa_item_id
  , p_transaction_type_id        => 17
  , p_transaction_action_id      => 32
  , p_uom                        => p_uom
  , x_return_status              => x_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_MODULE_PREFIX || l_api_name || '.No Date Found'
                    , 'Exception - Subcontracting Purchase Order Shipment : '
                    || p_subcontract_po_shipment_id);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Process_WIP_Assy_Return;

--========================================================================
-- PROCEDURE : Process_WIP_Component_Return     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--             p_component_id               SUbcontract assembly component
--            x_return_status               Return Status
-- COMMENT   : This procedure invokes the Process_Transaction
--             with the appropriate transaction type to process
--             the WIP Component_Return transaction into Inventory.
--========================================================================
PROCEDURE Process_WIP_Component_Return
( p_subcontract_po_shipment_id IN  NUMBER
, p_quantity                   IN  NUMBER
, p_component_id               IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Process_WIP_Component_Return';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Process_Transaction
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_quantity                   => p_quantity
  , p_item_id                    => p_component_id
  , p_transaction_type_id        => 43
  , p_transaction_action_id      => 27
  , p_uom                        => p_uom
  , x_return_status              => x_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Process_WIP_Component_Return;

--========================================================================
-- PROCEDURE : Process_WIP_Component_Issue     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--             p_component_id               SUbcontract assembly component
--             x_return_status               Return Status
-- COMMENT   : This procedure invokes the Process_Transaction
--             with the appropriate transaction type to process
--             the WIP Component Issue transaction into Inventory.
--========================================================================
PROCEDURE Process_WIP_Component_Issue
( p_subcontract_po_shipment_id IN  NUMBER
, p_quantity                   IN  NUMBER
, p_component_id               IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'Process_WIP_Component_Issue';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  , NULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Process_Transaction
  ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
  , p_quantity                   => p_quantity * -1
  , p_item_id                    => p_component_id
  , p_transaction_type_id        => 35
  , p_transaction_action_id      => 1
  , p_uom                        => p_uom
  , x_return_status              => x_return_status
  );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.end'
                  , NULL);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
    END IF;
END Process_WIP_Component_Issue;


--========================================================================
-- PROCEDURE : Process_Transaction     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--             p_item_id                    SUbcontract assembly component
--             p_transaction_type_id        Transaction Type
--             p_transaction_action_id      Transaction Action
--            x_return_status               Return Status
-- COMMENT   : This procedure inserts records in inventory interface
--             tables and invokes the Inventory TM to insert into MMT
--========================================================================
PROCEDURE Process_Transaction
( p_subcontract_po_shipment_id IN  NUMBER
, p_quantity                   IN  NUMBER
, p_item_id                    IN  NUMBER
, p_transaction_type_id        IN  NUMBER
, p_transaction_action_id      IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS
  TYPE l_onhand_rec_Typ IS RECORD
  ( subinventory_code            VARCHAR2(25)
  , primary_transaction_quantity NUMBER
  , inventory_item_id            NUMBER
  , organization_id              NUMBER
  , date_received                DATE
  , insert_flag                  VARCHAR2(1)
  );

  l_onhand_rec        l_onhand_rec_Typ;
  l_header_id         NUMBER;
  l_line_id           NUMBER;
  l_source_header_id  NUMBER;
  l_source_line_id    NUMBER;
  l_organization_id   NUMBER;
  l_subinventory_code VARCHAR2(10);
  l_operation_seq     NUMBER;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_trans_count       NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_primary_uom       VARCHAR2(3);
  l_primary_quantity  NUMBER;
  l_status            NUMBER;

 /* vmutyala added the following local variables for Bug 4670527*/
  l_wip_entity_id            NUMBER;        -- will be inserted into mtl_transactions_interface as transaction_source_id
  l_transaction_quantity     NUMBER;
  l_distribution_account_id  NUMBER;

  -- Added for the fix of bug 4869546
  l_transaction_source_name  VARCHAR2(80);

  l_wip_entity_type          NUMBER;
  l_locator_id               NUMBER;

BEGIN
  SELECT tp_organization_id
  INTO   l_organization_id
  FROM   jmf_subcontract_orders
  WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id;

  l_primary_uom:= JMF_SHIKYU_UTIL.Get_Primary_UOM_Code
                    ( p_item_id , l_organization_id);

  IF p_uom <> l_primary_uom
  THEN
    l_primary_quantity := INV_CONVERT.inv_um_convert
                          ( item_id             => p_item_id
                          , precision           => 5
                          , from_quantity       => p_quantity
                          , from_unit           => p_uom
                          , to_unit             => l_primary_uom
                          , from_name           => null
                          , to_name             => null
                          );
   ELSE
      l_primary_quantity := p_quantity;
   END IF;

  -- Bug 4964675
  -- If transaction is WIP Component Issue or Return
  IF p_transaction_type_id IN (35, 43)
  THEN

    -- Bug 5337725: Get the locator used to supply component to WIP,
    -- and pass it to the mtl_Transactions_interface table
    SELECT wro.supply_subinventory,
           wro.supply_locator_id
    INTO   l_subinventory_code,
           l_locator_id
    FROM   wip_requirement_operations wro,
           jmf_subcontract_orders jso
    WHERE  wro.wip_entity_id = jso.wip_entity_id
    AND    wro.inventory_item_id = p_item_id
    AND    wro.organization_id = jso.tp_organization_id
    AND    jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id;

  ELSE

    SELECT DEFAULT_PULL_SUPPLY_SUBINV
    INTO   l_subinventory_code
    FROM   WIP_PARAMETERS
    WHERE  ORGANIZATION_ID = l_organization_id;

    SELECT wro.supply_locator_id
    INTO l_locator_id
    FROM WIP_REQUIREMENT_OPERATIONS wro,
           jmf_subcontract_orders jso
    WHERE wro.wip_entity_id = jso.wip_entity_id
    AND   wro.organization_id = jso.tp_organization_id
    AND   wro.ORGANIZATION_ID = l_organization_id
    AND   jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id
    AND   rownum = 1;

  END IF;

   /* vmutyala added the following code to ensure that transaction quantity is
      negative for Misc. issue transaction, WIP Assembly return, Bug 4670527 */
   IF (p_transaction_type_id IN (32, 17) AND l_primary_quantity > 0) THEN
	l_transaction_quantity := -l_primary_quantity;
	l_primary_quantity := -l_primary_quantity;
    ELSE
	l_transaction_quantity := l_primary_quantity;
    END IF;

   /* vmutyala added the following code to fetch distribution account and insert
      into mtl_Transactions_interface Bug 4670527 */
   IF p_transaction_type_id IN (42, 32)
    THEN
       JMF_SHIKYU_UTIL.Get_Shikyu_Offset_Account(p_subcontract_po_shipment_id,l_distribution_account_id);
   ELSE
       l_distribution_account_id  := NULL;
   END IF;

   /* vmutyala added the following code to fetch wip entity id and insert as
      transaction_source_id into mtl_Transactions_interface for Bug 4670527 */

   -- Bug 4964675
   -- Added transaction types 35 and 43 for WIP Component Issue or Return

   l_wip_entity_id := NULL;
   l_wip_entity_type := NULL;

   IF P_transaction_type_id IN (17, 44, 35, 43)
    THEN
    SELECT wdj.wip_entity_id
    INTO   l_wip_entity_id
    FROM   wip_discrete_jobs wdj
       ,   jmf_subcontract_orders jso
    WHERE  jso.wip_entity_id = wdj.wip_entity_id
    AND    jso.tp_organization_id = wdj.organization_id
    AND    wdj.organization_id = l_organization_id
    AND   jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id;

    -- Populate the wip_entity_type to be 1, if the transaction is WIP
    -- related
    l_wip_entity_type := 1;

   END IF;

   -- Bug 4869546
   -- Added the following logic to stamp the correct transaction source name

   -- If transaction is Misc. Issue or Misc. Receipt
   IF P_transaction_type_id IN (32, 42)
   THEN

     -- Shortened the transaction source name because of bug 5086940
     l_transaction_source_name := 'Process Receiving Transactions';  /*Bug 8360852 - Removed the word Shikyu from source name*/

   -- If transaction is WIP Component Issue or Return
   ELSIF P_transaction_type_id IN (17, 44, 35, 43)
   THEN

     l_transaction_source_name := NULL;

   ELSE

     l_transaction_source_name := 'SHIKYU Interlock';

   END IF;

   SELECT mtl_material_transactions_s.nextval
   INTO   l_header_id
   FROM   sys.dual;

  /* vmutyala added the following code to initialize l_source_line_id,
     l_source_header_id before insert for Bug 4670527 */

   l_source_line_id   := 1;
   l_source_header_id := 1;

  /* vmutyala changed the following insert statement to add FINAL_COMPLETION_FLAG,
     DISTRIBUTION_ACCOUNT_ID, transaction_source_id for insertion Bug 4670527 */

  INSERT INTO mtl_Transactions_interface
  ( source_code
  , source_line_id
  , source_header_id
  , process_flag
  , transaction_mode
  , inventory_item_id
  , organization_id
  , subinventory_code
  , transaction_quantity
  , transaction_uom
  , transaction_date
  , transaction_source_name
  , transaction_type_id
  , wip_entity_type
  , operation_seq_num
  , primary_quantity
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , transaction_header_id
  , validation_required
  , FINAL_COMPLETION_FLAG
  , DISTRIBUTION_ACCOUNT_ID
  , transaction_source_id
  , locator_id
  )
  VALUES
  ( p_subcontract_po_shipment_id
  , l_source_line_id
  , l_source_header_id
  , 1
  , 2 -- concurrent processing
  , p_item_id
  , l_organization_id
  , l_subinventory_code
  , l_transaction_quantity
  , p_uom
  , sysdate
  , l_transaction_source_name
  , p_Transaction_type_id
  , l_wip_entity_type
  , 1
  , l_primary_quantity
  , sysdate
  , FND_GLOBAL.user_id
  , sysdate
  , FND_GLOBAL.user_id
  , l_header_id
  , 2
  , 'N'
  , l_distribution_account_id
  , l_wip_entity_id
  , l_locator_id
  );

  l_status := INV_TXN_MANAGER_PUB.Process_Transactions
  ( p_api_version        => 1.0
  , p_header_id          => l_header_id
  , x_return_status      => l_return_status
  , x_msg_count          => l_msg_count
  , x_msg_data           => l_msg_data
  , x_trans_count        => l_trans_count
  );

  IF l_return_status IS NULL
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    x_return_status := l_return_status;
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
     FND_MESSAGE.Set_Name('JMF', 'JMF_SHK_INV_PROCESS_FAIL');
     FND_MSG_PUB.Add;
  END IF;

END Process_Transaction;

END JMF_SHIKYU_INV_PVT;

/
