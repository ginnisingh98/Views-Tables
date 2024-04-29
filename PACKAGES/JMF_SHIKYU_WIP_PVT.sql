--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_WIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_WIP_PVT" AUTHID CURRENT_USER AS
-- $Header: JMFVSKWS.pls 120.0 2005/07/05 15:35 rajkrish noship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFWSHKS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains WIP related calls that the Interlock          |
--|   accesses when processing SHIKYU transactions                        |
--| HISTORY                                                               |
--|     05/09/2005 pseshadr       Created                                 |
--+========================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Process_WIP_Job       PUBLIC
-- PARAMETERS: p_action              Action
--                                   'C'- Create new job
--                                   'D'- Delete Job
--                                   'U'- Update Job
--                                   'R'- Assembly Return
--            x_return_status         Return Status
-- COMMENT   : This procedure populates data in the interface table
--             to process the WIP job. The WIP load procedure is invoked
--             which creates the WIP job.
--========================================================================
PROCEDURE Process_WIP_Job
( p_action                 IN  VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_need_by_date           IN  DATE
, p_quantity               IN  NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
);
--========================================================================
-- PROCEDURE : Compute_Start_Date    PUBLIC
-- PARAMETERS:
--             p_need_by_Date      Need By Date
--             p_item_id           Item
--             p_organization      Organization
--             p_quantity          Quantity
-- COMMENT   : This procedure computes the planned start date for the WIP job
--             based on the need_by_date
--========================================================================
PROCEDURE Compute_Start_Date
( p_need_by_date             IN   DATE
, p_item_id                  IN   NUMBER
, p_oem_organization         IN   NUMBER
, p_tp_organization          IN   NUMBER
, p_quantity                 IN   NUMBER
, x_start_date               OUT NOCOPY  DATE
);

--========================================================================
-- FUNCTION : Get_Component_Quantity    PUBLIC
-- PARAMETERS:
--             p_item_id           Item
--             p_organization_id   Organization
-- COMMENT   : This procedure computes the quantity of the component
--             as defined in the BOM in primary UOM
--========================================================================
FUNCTION Get_Component_Quantity
( p_item_id                  IN   NUMBER
, p_organization_id          IN   NUMBER
, p_subcontract_po_shipment_id IN NUMBER
) RETURN NUMBER;

END JMF_SHIKYU_WIP_PVT;

 

/
