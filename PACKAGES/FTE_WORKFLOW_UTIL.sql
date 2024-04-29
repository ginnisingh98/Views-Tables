--------------------------------------------------------
--  DDL for Package FTE_WORKFLOW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_WORKFLOW_UTIL" AUTHID CURRENT_USER AS
/* $Header: FTEWKFUS.pls 120.1 2005/06/29 11:43:25 vphalak noship $ */

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Trip_Select_Service_Init
--
-- PARAMETERS: p_trip_id               Trip Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a trip and calls the procedures which
--             raises the Service Selection Initiation for the trip and
--             Select Service event for all the deliveries assigned to the trip.
--========================================================================
PROCEDURE Trip_Select_Service_Init(
            p_trip_id           IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Trip_Cancel_Service
--
-- PARAMETERS: p_trip_id               Trip Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a trip and calls the procedures which
--             raises the Cancel Service event for all the deliveries
--             assigned to the trip.
--========================================================================
PROCEDURE Trip_Cancel_Service(
            p_trip_id           IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Dleg_Select_Service
--
-- PARAMETERS: p_dleg_id               Delivery Leg Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a delivery leg and calls the procedures which
--             raises the Select Service Event for the delivery and Select Service
--             Initiation event for the trip to which the delivery is assigned.
--========================================================================
PROCEDURE Dleg_Select_Service(
            p_dleg_id           IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : Dleg_Cancel_Service
--
-- PARAMETERS: p_dleg_id               Delivery Leg Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a delivery leg and calls the procedure which
--             raises the Cancel Service Event for the delivery.
--========================================================================
PROCEDURE Dleg_Cancel_Service(
            p_dleg_id           IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2);


--========================================================================
-- PROCEDURE : Single_Trip_Sel_Ser_Init
--
-- PARAMETERS: p_trip_id               Trip Id
--             x_return_status         Return status
--
-- COMMENT   : This procedure accepts a trip id and raises the Select Service
--             Initiated event for the trip.
--========================================================================

END FTE_WORKFLOW_UTIL;

 

/
