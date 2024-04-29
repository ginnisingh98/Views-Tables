--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_INV_PVT" AUTHID CURRENT_USER AS
-- $Header: JMFVSKIS.pls 120.1 2005/07/12 17:32 vchu noship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFISHKS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains INV related calls that the Interlock          |
--|   accesses when processing SHIKYU transactions                        |
--| HISTORY                                                               |
--|     05/09/2005 pseshadr       Created                                 |
--+========================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Process_Misc_Rcpt     PUBLIC
-- PARAMETERS: p_subcontract_po_shipment_id OSA PO Shipment Id
--             p_quantity                   Quantity
--            x_return_status               Return Status
-- COMMENT   : This procedure invokes the Process_Transaction
--             with the appropriate transaction type to process
--             the Misc. rcpt transaction into Inventory.
--========================================================================
PROCEDURE Process_Misc_Rcpt
( p_subcontract_po_shipment_id IN  NUMBER
, p_osa_quantity               IN  NUMBER
, p_uom                        IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
);

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
);

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
);

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
);

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
);

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
);

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
);

END JMF_SHIKYU_INV_PVT;

 

/
