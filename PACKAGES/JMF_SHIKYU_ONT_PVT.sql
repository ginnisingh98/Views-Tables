--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_ONT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_ONT_PVT" AUTHID CURRENT_USER AS
-- $Header: JMFVSKOS.pls 120.2 2006/02/15 16:38 vchu noship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFOSHKS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains ONT related calls that the Interlock          |
--|   accesses when processing SHIKYU transactions                        |
--| HISTORY                                                               |
--|     05/09/2005 pseshadr       Created                                 |
--|     10/17/2005 vchu           Modified signatures for                 |
--|                               Calculate_Ship_Date and                 |
--|                               Process_Replenishment_SO to fix an      |
--|                               issue with calculation of scheduled     |
--|                               ship dates.                             |
--|     02/15/2006 vchu           Added Calculate_Ship_Date to the        |
--|                               specification.                          |
--+=======================================================================+


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Calculate_Ship_Date    PUBLIC
-- PARAMETERS:
--             p_subcontract_po_shipment_id  Subcontracting Order Shipment ID
--             p_component_item_id           SHIKYU Component to be shipped
--             p_oem_organization_id         OEM Organization
--             p_tp_organization_id          TP Organization
--             p_need_by_date                Need By Date of the corresponding
--                                           Replenishment PO Shipment
--             x_ship_date                   Ship Date calculated to meet the
--                                           passed in Need_By_Date
-- COMMENT   : This procedure computes the scheduled ship date for the component
--             based on the WIP start date and item lead times.
--========================================================================
PROCEDURE Calculate_Ship_Date
( p_subcontract_po_shipment_id IN  NUMBER
, p_component_item_id          IN  NUMBER
, p_oem_organization_id        IN  NUMBER
, p_tp_organization_id         IN  NUMBER
, p_quantity                   IN  NUMBER
, p_need_by_date               IN  DATE
, x_ship_date                  OUT NOCOPY DATE
);

--========================================================================
-- PROCEDURE : Process_Replenishment_SO       PUBLIC
-- PARAMETERS: p_action              Action
--                                   'C'- Create new job
--                                   'D'- Delete Job
--                                   'U'- Update Job
--            x_return_status         Return Status
-- COMMENT   : This procedure populates data in the interface table
--             and creates a replenishment SO for the subcontracting
--             order shipment line
--========================================================================
PROCEDURE Process_Replenishment_SO
( p_action                     IN  VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_quantity                   IN  NUMBER
, p_item_id                    IN  NUMBER
, p_replen_po_shipment_id      IN  NUMBER
, p_oem_organization_id        IN  NUMBER
, p_tp_organization_id         IN  NUMBER
, x_order_line_id              OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
);

END JMF_SHIKYU_ONT_PVT;

 

/
