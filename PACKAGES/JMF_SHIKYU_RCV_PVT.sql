--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_RCV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_RCV_PVT" AUTHID CURRENT_USER AS
--$Header: JMFVSKVS.pls 120.3 2006/10/11 15:02:07 vmutyala noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :           JMFVSKVS.pls                                        |
--|                                                                           |
--|  DESCRIPTION:         Specification file of the Process Receiving         |
--|                       Transactions package.                               |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    10-JUN-2005        jizheng   Created.                                  |
--|    15-JUN-2005        THE2      Add locator_id process logic              |
--|    27-JUN-2005        THE2      Add project_id process logic              |
--|    27-JUN-2005        VMUTYALA  Add from_subinventory and from_locator_id |
--|                                 process logic                             |
--|    27-JUN-2005        THE2      Add replenish_order_line_id process logic |
--|                                                                           |
--|    11/10/2006         vmutyala  Bug 5592230 adding parameter              |
--|                                 p_vendor_site_id to the procedure         |
--|                                 process_rcv_header                        |
--+===========================================================================+

--========================================================================
-- PROCEDURE : process_rcv_header           PUBLIC
-- PARAMETERS: p_vendor_id          IN            NUMBER
--             p_ship_to_org_id     IN            NUMBER
--             x_rcv_header_id      OUT NOCOPY    NUMBER
--             x_group_id           OUT NOCOPY    NUMBER

-- COMMENT   : This procedure inserts records in rev_header_interface for auto_receive
--========================================================================
PROCEDURE  Process_Rcv_Header
( p_vendor_id         IN         NUMBER
, p_vendor_site_id    IN         NUMBER
, p_ship_to_org_id    IN         NUMBER
, x_rcv_header_id     OUT NOCOPY NUMBER
, x_group_id          OUT NOCOPY NUMBER
);

--========================================================================
-- PROCEDURE : process_rcv_trx              PUBLIC
-- PARAMETERS: p_rcv_header_id              IN    NUMBER
--             p_group_id                   IN    NUMBER
--             p_quantity                   IN    NUMBER
--             p_unit_of_measure            IN    VARCHAR2
--             p_po_header_id               IN    NUMBER
--             p_po_line_id                 IN    NUMBER
--             p_po_line_location_id        IN    NUMBER
--             p_po_distribution_id         IN    NUMBER
--             p_subinventory               IN    VARCHAR2
--             p_transaction_type           IN    VARCHAR2
--             p_auto_transact_code         IN    VARCHAR2
--             p_parent_transaction_id      IN    NUMBER

-- COMMENT   : This procedure inserts records in rev_transactions_interface for auto_receive
--========================================================================
PROCEDURE Process_Rcv_Trx
( p_rcv_header_id            IN NUMBER
, p_group_id                 IN NUMBER
, p_quantity                 IN NUMBER
, p_unit_of_measure          IN VARCHAR2
, p_po_header_id             IN NUMBER
, p_po_line_id               IN NUMBER
, p_subinventory             IN VARCHAR2 DEFAULT NULL
, p_transaction_type         IN VARCHAR2
, p_auto_transact_code       IN VARCHAR2 DEFAULT NULL
, p_parent_transaction_id    IN NUMBER
, p_po_line_location_id      IN NUMBER
, p_locator_id               IN NUMBER DEFAULT NULL
, p_project_id               IN NUMBER DEFAULT NULL
, p_from_subinventory        IN VARCHAR2 DEFAULT NULL
, p_from_locator_id          IN NUMBER DEFAULT NULL
, p_replenish_order_line_id  IN NUMBER DEFAULT NULL
);

G_MODULE_PREFIX      VARCHAR2(100) := 'JMF.plsql.JMF_SHIKYU_RCV_PVT.';

END JMF_SHIKYU_RCV_PVT;

 

/
