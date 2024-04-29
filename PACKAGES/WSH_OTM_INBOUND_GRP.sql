--------------------------------------------------------
--  DDL for Package WSH_OTM_INBOUND_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OTM_INBOUND_GRP" AUTHID CURRENT_USER as
/* $Header: WSHOTMIS.pls 120.0.12010000.1 2008/07/29 06:16:17 appldev ship $ */

--***************************************************************************--
--========================================================================
-- PROCEDURE : initiate_planned_shipment   Called by the WSH Inbound BPEL Process
--
-- PARAMETERS: p_int_trip_info       Table of trip records to process into the interface table
--                                   The trip record is a nested object containing
--                                   Stop, releases, Legs and Freight Costs
--             x_output_request_id   Concurrent request_id of the instance launched for WSHOTMRL
--             x_msg_count           Number of messages
--             x_msg_data            Message Data
--             x_return_status       Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Takes a table of trip records to process
--             Processes the trip and children stops, releases and legs
--             and inserts into the WSH Interface tables
--             Then launches the WSHOTMRL concurrent program
--========================================================================

PROCEDURE initiate_planned_shipment(    p_int_trip_info          IN   WSH_OTM_TRIP_TAB,
                                        x_output_request_id      OUT  NOCOPY NUMBER,
                                        x_return_status          OUT  NOCOPY VARCHAR2,
                                        x_msg_count              OUT  NOCOPY NUMBER,
                                        x_msg_data               OUT  NOCOPY VARCHAR2);

END WSH_OTM_INBOUND_GRP;


/
