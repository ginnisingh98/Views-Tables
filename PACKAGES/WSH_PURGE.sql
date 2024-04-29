--------------------------------------------------------
--  DDL for Package WSH_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PURGE" AUTHID CURRENT_USER AS
/* $Header: WSHPURGS.pls 120.1 2005/06/20 22:51:33 appldev noship $ */

TYPE Trip_ID_Rec_Type is RECORD (
  trip_id   NUMBER,
  trip_name VARCHAR2(30),
  purge_set_type      VARCHAR2(30)
);

TYPE Trip_ID_Tbl_Type IS Table of Trip_ID_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Delivery_ID_Rec_Type is RECORD (
  delivery_id   NUMBER,
  delivery_name  VARCHAR2(30),
  purge_set_type      VARCHAR2(30)
);

TYPE Delivery_ID_Tbl_Type IS Table of Delivery_ID_Rec_Type INDEX BY BINARY_INTEGER ;

TYPE Trip_Stop_ID_Rec_Type is RECORD (
  stop_id   NUMBER
  );

TYPE Trip_Stop_ID_Tbl_Type IS Table of Trip_Stop_ID_Rec_Type INDEX BY BINARY_INTEGER ;

TYPE Del_Leg_ID_Rec_Type is RECORD (
  delivery_leg_id   NUMBER
);

TYPE Del_Leg_ID_Tbl_Type IS Table of Del_Leg_ID_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Del_Detail_ID_Rec_Type is RECORD (
  delivery_detail_id   NUMBER
  );

TYPE Del_Detail_ID_Tbl_Type IS Table of Del_Detail_ID_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Container_ID_Rec_Type is RECORD (
  container_id   NUMBER,
  purge_set_type VARCHAR2(30)
);

TYPE Container_ID_Tbl_Type IS Table of Container_ID_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Trip_moves_Rec_Type is RECORD (
  move_id NUMBER,
  trip_id NUMBER
);

TYPE Trip_moves_Tbl_Type IS Table of Trip_moves_Rec_Type INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------
--
-- Procedure:   Process_Purge
-- Parameters:	errbuf	 Parameter for the Concurrent Program to get the error.
--		retcode	 Parameter for the Concurrent Program to get the return code
--		p_execution_mode  Specifies whether to Purge Data or View Purge Set
--		p_source_system	 Only the delivery details belonging to this Source System
--				 would be considered eligible for Purge
--		p_ship_from_org	 Only the deliveries belonging to this Ship From Org
--				 would be considered eligible for Purge
--		p_order_number_from  Only the delivery details having source_header_number
--				     greater than Order Number From would be considered eligible for Purge
--		p_order_number_to  Only the delivery details having source_header_number
--				   less than Order Number To would be considered eligible for Purge
--		p_order_type  Only the delivery details belonging to this Order Type
--			      would be considered eligible for Purge
--		p_ship_date_from  Only the deliveries having initial_pickup_date greater
--				  than Ship Date From would be considered eligible for Purge
--		p_ship_date_to  Only the deliveries having initial_pickup_date less than
--				Ship Date To would be considered eligible for Purge
--		p_delete_beyond_x_ship_days  Only the deliveries having initial_pickup_date less
--					     than the specified date would be considered eligible for Purge
--		p_purge_intransit_trips	Decides whether to purge In Transit Trips or not
--		p_delete_empty_records	Decides whether to delete empty record or not.
--					The empty records can be Empty Trips, Orphaned Empty Deliveries,
--					Delivery with Empty containers, Empty Containers
--		p_create_date_from	Only Empty records having creation_date greater than this
--					date would be purged
--		p_create_date_to	Only Empty records having creation_date less than this
--					date would be purged
--		p_del_beyond_creation_days	Only Empty records having creation_date less than
--						this date would be purged
--		p_sort_per_criteria	Sorts the report output according to Trip,
--					Delivery or Order Number
--		p_print_detail	If "Detail with LPN", the report would contain the parameters / summary
--				page and all detail pages with Trips, Deliveries and
--				Sales Orders with Container data eligible to purge or purged.
--				If "Detail", the report would contain the parameters / summary
--				page and all detail pages with Trips, Deliveries and
--				Sales Orders data eligible to purge or purged.
--				If "Summary", the report would contain only the parameters / summary page.

-- Description: This procedure is called by the concurrent program. The procedure has the following structure
--		calls Get_Purge_Set - To get the valid entities to be purged
--		calls Purge_Entities - To purge data in Shipping/FTE tables
--		calls Generate_Report - To generate the report through XML publisher
-----------------------------------------------------------------------------
PROCEDURE Process_Purge(	errbuf   OUT NOCOPY VARCHAR2,
				retcode  OUT NOCOPY VARCHAR2,
				p_execution_mode varchar2,
				p_source_system varchar2,
				p_ship_from_org number,
				p_order_number_from varchar2,
				p_source_system_dummy varchar2,
				p_order_number_to varchar2,
				p_dummy_order varchar2,
				p_order_type number,
				p_ship_date_from varchar2,
				p_ship_date_to varchar2,
				p_dummy_ship_date varchar2,
				p_delete_beyond_x_ship_days number,
				p_dummy_x_ship_days varchar2,
				p_purge_intransit_trips varchar2,
				p_delete_empty_records varchar2,
				p_create_date_from varchar2,
				p_create_date_to varchar2,
				p_dummy_create_date varchar2,
				p_del_beyond_creation_days number,
				p_dummy_x_create_days varchar2,
				p_sort_per_criteria varchar2,
				p_print_detail varchar2
			);

/*-----------------------------------------------------------------------------
Procedure:  Get_Purge_Set
Parameters: p_source_system Only the delivery details belonging to this Source System
            would be considered eligible for Purge
            p_ship_from_org Only the deliveries belonging to this Ship From Org
            would be considered eligible for Purge
            p_order_number_from Only the delivery details having source_header_number
            greater than Order Number From would be considered eligible for Purge
            p_order_number_to Only the delivery details having source_header_number
            less than Order Number To would be considered eligible for Purge
            p_order_type Only the delivery details belonging to this Order Type
            would be considered eligible for Purge
            p_ship_date_from Only the deliveries having initial_pickup_date greater
            than Ship Date From would be considered eligible for Purge
            p_ship_date_to  Only the deliveries having initial_pickup_date less than
            Ship Date To would be considered eligible for Purge
            p_delete_beyond_x_ship_days  Only the deliveries having initial_pickup_date greater
            than the specified date would be considered eligible for Purge
            p_purge_intransit_trips Decides whether to purge In Transit Trips or not
            p_delete_empty_records Decides whether to delete empty record or not.
            The empty records can be Empty Trips, Orphaned Empty Deliveries,
            Delivery with Empty containers, Empty Containers
            p_create_date_from Only Empty records having creation_date greater than this
            date would be purged
            p_create_date_to Only Empty records having creation_date less than this
            date would be purged
            p_del_beyond_creation_days Only Empty records having creation_date greater than
            this date would be purged
            x_tbl_trip_purge_set - pl/sql table of trip id's eligible for purge
            x_tbl_delivery_purge_set -  pl/sql table of delivery id's eligible for purge
            x_tbl_del_details_purge_set - pl/sql table of delivery detail id's eligible for purge
            x_tbl_del_legs_purge_set - pl/sql table of delivery leg id's eligible for purge
            x_tbl_trip_stops_purge_set - pl/sql table of trip stop id's eligible for purge
            x_tbl_containers_purge_set - pl/sql table of container id's eligible for purge
            x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API gets all the Shipping Data from the view WSH_PURGE_SET_V
             and puts it into the plsql tables for respective entities after validating it
             with the user given parameters
==============================================================================
Input: Parameters as given in the FDD.
Output: Table of Record Types for Trips, Stops, Legs,
        Deliveries, Containers, Details
================================================================================
Logic: i) Build Trip SQL for purge set types:
          NON_EMPTY - Complete Shipping Entities

      ii) Build Delivery SQL for purge set type:
          EMPTYDELS - Orphaned empty deliveries without any details

          only Delete Empty Records, creation date from, to and delete beyond
          x creation days will be honoured.

     iii) Execute the Trip ,Delivery and Container dynamically built SQLs and populate the
          Table of record types for trip,delivery and containers.

	  Add Trip IDs for purge set types :
	  EMPTYTRIPS - Orphaned Trips without any deliveries assigned to them

      iv) For NON_EMPTY purge sets get the deliveries for all
          trips and add delivery ids to the purge set for deliveries.

       v) For a given trip get all the stops and create a stops purge set.

      vi) For a given delivery get all the delivery legs and details and create
          a purge set.

     vii) From NON_EMPTY get all the container ids(wdd.container_flag='Y') and
          populate them in container purge set
-----------------------------------------------------------------------------*/
PROCEDURE Get_Purge_Set(	p_source_system varchar2,
				p_ship_from_org number,
				p_order_number_from varchar2,
				p_order_number_to varchar2,
				p_order_type number,
				p_ship_date_from varchar2,
				p_ship_date_to varchar2,
				p_delete_beyond_x_ship_days number,
				p_purge_intransit_trips varchar2,
				p_delete_empty_records varchar2,
				p_create_date_from varchar2,
				p_create_date_to varchar2,
				p_del_beyond_creation_days number,
				x_tbl_trip_purge_set OUT  NOCOPY Trip_ID_Tbl_Type ,
				x_tbl_delivery_purge_set OUT  NOCOPY Delivery_ID_Tbl_Type,
				x_tbl_del_details_purge_set OUT  NOCOPY Del_Detail_ID_Tbl_Type,
				x_tbl_del_legs_purge_set OUT  NOCOPY Del_Leg_ID_Tbl_Type,
				x_tbl_trip_stops_purge_set OUT  NOCOPY Trip_Stop_ID_Tbl_Type,
				x_tbl_containers_purge_set OUT  NOCOPY Container_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2

			);

/*-----------------------------------------------------------------------------

Procedure:	Purge_Entities
Parameters:	p_tbl_trip_purge_set - pl/sql table of trip id's eligible for purge
 		p_tbl_delivery_purge_set -  pl/sql table of delivery id's eligible for purge
 		p_tbl_del_details_purge_set -  pl/sql table of delivery detail id's eligible for purge
 		p_tbl_del_legs_purge_set - pl/sql table of delivery leg id's eligible for purge
 		p_tbl_trip_stops_purge_set - pl/sql table of trip stop id's eligible for purge
 		p_tbl_containers_purge_set  pl/sql - table of container id's eligible for purge
		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description:	This API calls the individual APIs to delete the data in
		Shipping and Transportation tables
=============================================================================
   Input: Table of Record Types for Trips, Stops, Legs, Deliveries, Containers, Details
   Output: Return Status - success or failure
==============================================================================
   Logic: i) Call Purge_Delivery_Details
         ii) Call Purge_Containers
        iii) Call Purge_Delivery_Legs
         iv) Call Purge_Trip_Stops
          v) Call Purge_Deliveries
         vi) Call Purge_Trips
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Entities(	p_tbl_trip_purge_set Trip_ID_Tbl_Type ,
				p_tbl_delivery_purge_set Delivery_ID_Tbl_Type,
				p_tbl_del_details_purge_set Del_Detail_ID_Tbl_Type,
				p_tbl_del_legs_purge_set Del_Leg_ID_Tbl_Type,
				p_tbl_trip_stops_purge_set Trip_Stop_ID_Tbl_Type,
				p_tbl_containers_purge_set Container_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			);

/*-----------------------------------------------------------------------------
Procedure: Purge_Trips
Parameters: p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
	    x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description:	This API delete the data in Shipping and Transportation
		related to trip
==============================================================================
Input: Table of Record Types for Trips
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
WSH_EXCEPTIONS, WSH_FREIGHT_COSTS, WSH_DOCUMENT_INSTANCES,WSH_TRIPS
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Trips(		p_tbl_trip_purge_set Trip_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
		     );

/*-----------------------------------------------------------------------------
Procedure:   Purge_Deliveries
Parameters:  p_tbl_delivery_purge_set pl/sql table of delivery id's eligible for purge
             x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
related to delivery
=============================================================================+
Input: Table of Record Types for Deliveries
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          WSH_EXCEPTIONS, WSH_TRANSACTIONS_HISTORY, WSH_DOCUMENT_INSTANCES,
          WSH_FREIGHT_COSTS

	  If FTE is installed,
             FTE_SHIPMENT_STATUS_DETAILS, FTE_SHIPMENT_STATUS_EXCEPTIONS,
             FTE_MESSAGE_PARTNER, FTE_MESSAGE_CONTACT, FTE_MESSAGE_LOCATION,
             FTE_DELIVERY_PROOF, FTE_SHIPMENT_STATUS_HEADERS

          If ITM Screening is done,
             WSH_ITM_RESPONSE_LINES, WSH_ITM_RESPONSE_HEADERS, WSH_ITM_REQUEST_CONTROL,
             WSH_INBOUND_TXN_HISTORY
	  and finally WSH_NEW_DELIVERIES.
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Deliveries(	p_tbl_delivery_purge_set Delivery_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			);

/*-----------------------------------------------------------------------------
Procedure:   Purge_Trip_Stops
Parameters:  p_tbl_trip_stop_purge_set  pl/sql table of trip stop id's
             eligible for purge
             x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
related to trip stop
==============================================================================
Input: Table of Record Types for Trip Stops
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          WSH_EXCEPTIONS, WSH_FREIGHT_COSTS, WSH_TRIP_STOPS
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Trip_Stops(	p_tbl_trip_stop_purge_set Trip_Stop_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			);

/*-----------------------------------------------------------------------------
Procedure:   Purge_Delivery_Legs
Parameters:  p_tbl_del_leg_purge_set pl/sql table of delivery leg id's eligible for purge
             x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
             related to delivery leg
==============================================================================
   Input: Table of Record Types for Delivery Legs
   Output: Return Status - success or failure
==============================================================================
   Logic: i) Delete records from the following tables:
             WSH_FREIGHT_COSTS, WSH_DOCUMENT_INSTANCES, WSH_DELIVERY_LEG_ACTIVITIES,
             WSH_DELIVERY_LEG_DETAILS, WSH_DELIVERY_LEGS

             If FTE is installed,
             FTE_INVOICE_LINES, FTE_INVOICE_HISTORY, FTE_INVOICE_HEADERS,
             FTE_FAILURE_REASONS
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Delivery_Legs(	p_tbl_del_leg_purge_set Del_Leg_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			);

/*-----------------------------------------------------------------------------
Procedure:  Purge_Delivery_Details
Parameters: p_tbl_del_detail_purge_set pl/sql table of delivery detail id's
	    eligible for purge
            x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
             related to delivery detail
=============================================================================
Input: Table of Record Types for Delivery Details
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          WSH_FREIGHT_COSTS, WSH_SERIAL_NUMBERS, WSH_EXCEPTIONS,
          wsh_delivery_assignments_v, WSH_DELIVERY_DETAILS
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Delivery_Details(p_tbl_del_detail_purge_set Del_Detail_ID_Tbl_Type,
				 x_return_status OUT  NOCOPY VARCHAR2
				);

/*-----------------------------------------------------------------------------
Procedure: Purge_Containers
Parameters: p_tbl_containers_purge_set pl/sql table of container id's eligible for purge
            x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API calls the WMS API to delete the data in WMS
             related to Containers
==============================================================================
Input: Table of Record Types for Container Ids
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          wsh_delivery_assignments_v, WSH_DELIVERY_DETAILS
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Containers(	p_tbl_containers_purge_set Container_ID_Tbl_Type,
			x_return_status OUT  NOCOPY VARCHAR2
		    );

-----------------------------------------------------------------------------
--
-- Procedure:   Generate_Purge_Report
-- Parameters:  p_execution_mode  Specifies whether to Purge Data or View Purge Set
--		p_source_system	 Only the delivery details belonging to this Source System
--				 would be considered eligible for Purge
--		p_ship_from_org	 Only the deliveries belonging to this Ship From Org
--				 would be considered eligible for Purge
--		p_order_number_from  Only the delivery details having source_header_number
--				     greater than Order Number From would be considered eligible for Purge
--		p_order_number_to  Only the delivery details having source_header_number
--				   less than Order Number To would be considered eligible for Purge
--		p_order_type  Only the delivery details belonging to this Order Type
--			      would be considered eligible for Purge
--		p_ship_date_from  Only the deliveries having initial_pickup_date greater
--				  than Ship Date From would be considered eligible for Purge
--		p_ship_date_to  Only the deliveries having initial_pickup_date less than
--				Ship Date To would be considered eligible for Purge
--		p_delete_beyond_x_ship_days  Only the deliveries having initial_pickup_date greater
--					     than the specified date would be considered eligible for Purge
--		p_purge_intransit_trips	Decides whether to purge In Transit Trips or not
--		p_delete_empty_records	Decides whether to delete empty record or not.
--					The empty records can be Empty Trips, Orphaned Empty Deliveries,
--					Delivery with Empty containers, Empty Containers
--		p_create_date_from	Only Empty records having creation_date greater than this
--					date would be purged
--		p_create_date_to	Only Empty records having creation_date less than this
--					date would be purged
--		p_del_beyond_creation_days	Only Empty records having creation_date greater than
--						this date would be purged
--		p_sort_per_criteria	Sorts the report output according to Trip,
--					Delivery or Order Number
--		p_print_detail	If Low, the report would contain the parameters / summary
--				page and all detail pages with Trips, Deliveries and
--				Sales Orders data eligible to purge or purged.
--				If No, the report would contain only the parameters / summary page.
--		p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		p_tbl_delivery_purge_set  pl/sql table of delivery id's eligible for purge
--		p_tbl_delivery_purge_set  pl/sql table of container ids's eligible for purge
--		p_count_legs  count of delivery legs to be purged/eligible to be purged
--		p_count_stops count of trip stops to be purged/eligible to be purged
--		p_count_details count of delivery details to be purged/eligible to be purged
--		p_count_containers count of containers to be purged/eligible to be purged
--		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:	This API generates the XML and writes it in output file
--		of the concurrent program to be used by the XML Publisher
--		to generate the XML report
-----------------------------------------------------------------------------
PROCEDURE Generate_Purge_Report(p_execution_mode varchar2,
				p_source_system varchar2,
				p_ship_from_org number,
				p_order_number_from varchar2,
				p_order_number_to varchar2,
				p_order_type number,
				p_ship_date_from varchar2,
				p_ship_date_to varchar2,
				p_delete_beyond_x_ship_days number,
				p_purge_intransit_trips varchar2,
				p_delete_empty_records varchar2,
				p_create_date_from varchar2,
				p_create_date_to varchar2,
				p_del_beyond_creation_days number,
				p_sort_per_criteria varchar2,
				p_print_detail varchar2,
				p_tbl_trip_purge_set   Trip_ID_Tbl_Type ,
				p_tbl_delivery_purge_set    Delivery_ID_Tbl_Type,
				p_tbl_container_purge_set Container_ID_Tbl_Type,
				p_count_legs NUMBER,
				p_count_stops NUMBER,
				p_count_details NUMBER,
				p_count_containers NUMBER,
				x_return_status OUT  NOCOPY VARCHAR2

			);

-----------------------------------------------------------------------------
--
-- Procedure:   Purge_Workflow
-- Parameters:  p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		p_tbl_delivery_purge_set  pl/sql table of delivery id's eligible for purge
--		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:	This API deletes the workflows for Trip and Delivery.
-----------------------------------------------------------------------------
PROCEDURE Purge_Workflow(p_tbl_trip_purge_set   Trip_ID_Tbl_Type ,
			 p_tbl_delivery_purge_set    Delivery_ID_Tbl_Type,
			 x_return_status OUT  NOCOPY VARCHAR2);

-----------------------------------------------------------------------------
--
-- Procedure:   Validate_Trips
-- Parameters:  p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		x_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		after validating all the LPNs belonging to the trip with WMS API
--		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:	This API call the WMS LPN Purge API for each LPN
--		belonging to the trip. The WMS LPN Purge API returns TRUE or FALSE
--		depending whether the LPN is eligible to purge or not.
--		If WMS LPN Purge API returns FALSE even for one LPN for a trip
--		then the trip and its entire contents are marked as in-eligible
--		for purge
--		This API also checks whether the trip is a part of valid Continuous
--		Move(CM). A valid CM is one in which all the the trips are eligible
--		for purge. If not then the Trip is not eligible to be purged.
--		This API also checks whether the trip is a part of valid MDC
--		configuration. A valid MDC configurationis one in which all
--		the the trips are eligible for purge. If not then the Trip is
--		not eligible to be purged.
-----------------------------------------------------------------------------
PROCEDURE Validate_Trips(	p_tbl_trip_purge_set Trip_ID_Tbl_Type ,
				x_tbl_trip_purge_set OUT  NOCOPY Trip_ID_Tbl_Type ,
				x_return_status OUT  NOCOPY VARCHAR2);

END WSH_PURGE;

 

/
