--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_PO_PVT" AUTHID CURRENT_USER AS
-- $Header: JMFVSKPS.pls 120.0.12010000.1 2008/07/21 09:23:49 appldev ship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFPSHKS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains PO related calls that the Interlock           |
--|   accesses when processing SHIKYU transactions                        |
--| HISTORY                                                               |
--|     05/09/2005 pseshadr       Created                                 |
--+========================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Process_Replenishment_PO       PUBLIC
-- PARAMETERS: p_action              Action
--                                   'C'- Create new job
--                                   'D'- Delete Job
--                                   'U'- Update Job
--            x_return_status         Return Status
-- COMMENT   : This procedure populates data in the interface table
--             and creates a replenishment SO for the subcontracting
--             order shipment line
--========================================================================
PROCEDURE Process_Replenishment_PO
( p_action                 IN  VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_quantity               IN  NUMBER
, p_item_id                IN  NUMBER
, x_po_line_location_id    OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
);

END JMF_SHIKYU_PO_PVT;

/
