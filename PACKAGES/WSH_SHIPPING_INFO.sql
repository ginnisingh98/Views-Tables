--------------------------------------------------------
--  DDL for Package WSH_SHIPPING_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPPING_INFO" AUTHID CURRENT_USER as
/* $Header: WSHSHINS.pls 120.1 2006/12/09 00:13:32 rlanka noship $ */

--
-- Package type declarations
--

TYPE Tracking_Info_Rec_Typ IS RECORD (
		delivery_status		VARCHAR2(30),
		trip_name		VARCHAR2(30),
		location_name		VARCHAR2(190),
		actual_arrival_date	DATE,
		actual_departure_date	DATE,
		ship_method_code	VARCHAR2(30),
		bill_of_lading		VARCHAR2(50),
                carrier_name            HZ_PARTIES.PARTY_NAME%TYPE -- Bug 5697730
	);

TYPE Tracking_Info_Tab_Typ IS TABLE OF Tracking_Info_Rec_Typ
INDEX BY BINARY_INTEGER;


--
-- Tracking_Info_Rec_Typ details
-- delivery_status -> 'UNSHIPPED', 'IN-TRANSIT' or 'DELIVERED'
-- trip_name -> name of the trip the delivery is on
-- location_name -> location of delivery
-- actual arrival/departure dates - dates at the location
-- ship_method_code -> freight carrier code
-- bill_of_lading -> bill of lading contract between shipper
--		     and carrier for the trip
--

--
--  Procedure:		Track_Shipment
--  Parameters:		p_delivery_name - Name of Delivery to track
--			p_tracking_number_dd - Tracking Number of Delivery
--			                       Line
--			p_mode - 'FULL' or 'CURRENT'
--			         'FULL' Gives complete tracking information
--			         'CURRENT' Provides simple tracking information
--			         a) If the delivery is not shipped, initial
--			            trip/location information is provided
--			         b) If the delivery is shipped, it provides
--			            the current shipment information
--				 c) If the delivery has been delivered, it
--			            provides the final trip/location information
--			            when delivered to the customer
--			x_tracking_details - Record of all the tracking
--			                     details for a shipment
--			x_return_status - Status of procedure call
--			                  - FND_API.G_RET_STS_SUCCESS
--			                  - FND_API.G_RET_STS_ERROR
--  Description:	This procedure will provide tracking information
--			for a shipment
--

  PROCEDURE Track_Shipment
		(p_delivery_name	IN   VARCHAR2 DEFAULT NULL,
		 p_tracking_number_dd	IN   VARCHAR2 DEFAULT NULL,
		 p_mode			IN   VARCHAR2,
		 x_tracking_details	OUT NOCOPY   Tracking_Info_Tab_Typ,
		 x_return_status	OUT NOCOPY   VARCHAR2
		);


END WSH_SHIPPING_INFO;

/
