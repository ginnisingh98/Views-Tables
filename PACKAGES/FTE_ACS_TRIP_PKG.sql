--------------------------------------------------------
--  DDL for Package FTE_ACS_TRIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_ACS_TRIP_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEACSTS.pls 120.2 2005/07/15 04:07:36 alksharm noship $ */

--
-- ----------------------------------------------------------------------
-- Procedure:   CARRIER_SEL_CREATE_TRIP
--
-- Parameters:  p_delivery_id               Delivery ID
--              p_carrier_sel_result_rec    WSH_FTE_INTEGRATION.WSH_CS_RESULT_REC_TYPE
--              x_trip_id                   Trip Id
--              x_trip_name                 Trip Name
--              x_return_message            Return Message
--              x_return_status             Return Status
--
-- COMMENT   : This procedure is called from Process Carrier Selection API
--             in order to create trip for deliveries not assigned to trips
--
--             It performs the following steps:
--             01. Create trip.
--             02. Create Pick Up and Drop Off Stops for trip created above
--             03. Assign delivery to trip
--
--  ----------------------------------------------------------------------
PROCEDURE CARRIER_SEL_CREATE_TRIP( p_delivery_id               IN  NUMBER,
                                   --p_initial_pickup_loc_id     IN  NUMBER,
                                   --p_ultimate_dropoff_loc_id   IN  NUMBER,
                                   --p_initial_pickup_date       IN  DATE,
                                   --p_ultimate_dropoff_date     IN  DATE,
                                   p_carrier_sel_result_rec    IN WSH_FTE_INTEGRATION.WSH_CS_RESULT_REC_TYPE,
                                   x_trip_id                   OUT NOCOPY NUMBER,
                                   x_trip_name                 OUT NOCOPY VARCHAR2,
                                   x_return_message            OUT NOCOPY VARCHAR2,
                                   x_return_status             OUT NOCOPY VARCHAR2);


--
-- ----------------------------------------------------------------------
-- Procedure:   GET_RANKED_RESULTS
--
-- Parameters:  p_rule_id		    Rule ID
--		x_routing_results	    Ranked list of carriers,mode and service levels
--              x_return_status             Return Status
--
-- COMMENT   :  The procedure queries FTE_SEL_RESULT_ASSIGNMENTS to return results for the given
--              rule id. The API returns does not return multileg results.
--  ----------------------------------------------------------------------
PROCEDURE GET_RANKED_RESULTS(  p_rule_id 	  IN NUMBER,
			       x_routing_results  OUT NOCOPY  FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
			       x_return_status      OUT NOCOPY VARCHAR2);

END FTE_ACS_TRIP_PKG;

 

/
