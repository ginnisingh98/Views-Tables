--------------------------------------------------------
--  DDL for Package FTE_LANE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_LANE_PKG" AUTHID CURRENT_USER AS
/* $Header: FTELANES.pls 120.1 2005/06/28 22:48:37 pkaliyam noship $ */

  TYPE lane_rec IS RECORD (
       action			VARCHAR2(10),
       carrier_id		fte_lanes.carrier_id%TYPE,
       lane_id			fte_lanes.lane_id%TYPE,
       origin_id		fte_lanes.origin_id%TYPE,
       destination_id		fte_lanes.destination_id%TYPE,
       distance			fte_lanes.distance%TYPE,
       distance_uom		fte_lanes.distance_uom%TYPE,
       transit_time		fte_lanes.transit_time%TYPE,
       transit_time_uom		fte_lanes.transit_time_uom%TYPE,
       basis			fte_lanes.basis%TYPE,
       comm_fc_class_code	fte_lanes.comm_fc_class_code%TYPE,
       effective_date		fte_lanes.effective_date%TYPE,
       expiry_date		fte_lanes.expiry_date%TYPE,
       pricelist_view_flag	fte_lanes.pricelist_view_flag%TYPE,
       editable_flag		fte_lanes.editable_flag%TYPE,
       lane_number		fte_lanes.lane_number%TYPE,
       mode_of_transportation_code  fte_lanes.mode_of_transportation_code%TYPE,
       additional_instructions	fte_lanes.additional_instructions%TYPE,
       special_handling		fte_lanes.special_handling%TYPE,
       lane_type		fte_lanes.lane_type%TYPE,
       tariff_name		fte_lanes.tariff_name%TYPE,
       service_type_code	fte_lanes.service_type_code%TYPE,
       commodity_catg_id	fte_lanes.commodity_catg_id%TYPE,
       equipment_type_code	fte_lanes.equipment_type_code%TYPE,
       container_all_flag	BOOLEAN,
       basis_flag		BOOLEAN,
       line_number		NUMBER);

  TYPE lane_tbl IS TABLE OF
       lane_rec
       INDEX BY BINARY_INTEGER;

  TYPE lane_rate_chart_rec IS RECORD (
       lane_id			fte_lane_rate_charts.lane_id%TYPE,
       list_header_id		fte_lane_rate_charts.list_header_id%TYPE,
       start_date_active	fte_lane_rate_charts.start_date_active%TYPE,
       end_date_active		fte_lane_rate_charts.end_date_active%TYPE);

  TYPE lane_rate_chart_tbl IS TABLE OF
       lane_rate_chart_rec
       INDEX BY BINARY_INTEGER;

  TYPE lane_commodity_rec IS RECORD (
       commodity_catg_id	fte_lane_commodities.commodity_catg_id%TYPE,
       basis			fte_lane_commodities.basis%TYPE,
       lane_id			fte_lane_commodities.lane_id%TYPE,
       lane_commodity_id	fte_lane_commodities.lane_commodity_id%TYPE,
       basis_flag		BOOLEAN);

  TYPE lane_commodity_tbl IS TABLE OF
       lane_commodity_rec
       INDEX BY BINARY_INTEGER;

  TYPE lane_service_rec IS RECORD (
       service_code	fte_lane_services.service_code%TYPE,
       lane_id		fte_lane_services.lane_id%TYPE,
       lane_service_id	fte_lane_services.lane_service_id%TYPE);

  TYPE lane_service_tbl IS TABLE OF
       lane_service_rec
       INDEX BY BINARY_INTEGER;

  TYPE schedule_rec IS RECORD (
       vessel_name		fte_schedules.vessel_name%TYPE,
       vessel_type		fte_schedules.vessel_type%TYPE,
       voyage_number		fte_schedules.voyage_number%TYPE,
       arrival_date_indicator	fte_schedules.arrival_date_indicator%TYPE,
       transit_time		fte_schedules.transit_time%TYPE,
       port_of_loading		fte_schedules.port_of_loading%TYPE,
       port_of_discharge	fte_schedules.port_of_discharge%TYPE,
       frequency_type		fte_schedules.frequency_type%TYPE,
       frequency		fte_schedules.frequency%TYPE,
       frequency_arrival	fte_schedules.frequency_arrival%TYPE,
       departure_time		fte_schedules.departure_time%TYPE,
       arrival_time		fte_schedules.arrival_time%TYPE,
       departure_date		fte_schedules.departure_date%TYPE,
       arrival_date		fte_schedules.arrival_date%TYPE,
       effective_date		fte_schedules.effective_date%TYPE,
       expiry_date		fte_schedules.expiry_date%TYPE,
       transit_time_uom		fte_schedules.transit_time_uom%TYPE,
       lane_id			fte_schedules.lane_id%TYPE,
       schedules_id		fte_schedules.schedules_id%TYPE,
       lane_number		fte_schedules.lane_number%TYPE);

  TYPE schedule_tbl IS TABLE OF
       fte_schedules%ROWTYPE
       INDEX BY BINARY_INTEGER;

  TYPE prc_parameter_rec IS RECORD (
       value_from		fte_prc_parameters.value_from%TYPE,
       value_to			fte_prc_parameters.value_to%TYPE,
       uom_code			fte_prc_parameters.uom_code%TYPE,
       currency_code		fte_prc_parameters.currency_code%TYPE,
       parameter_instance_id	fte_prc_parameters.parameter_instance_id%TYPE,
       lane_id			fte_prc_parameters.lane_id%TYPE,
       parameter_id		fte_prc_parameters.parameter_id%TYPE);

  TYPE prc_parameter_tbl IS TABLE OF
       prc_parameter_rec
       INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_LANE_ID
  --
  -- Purpose: get a lane id for the lane number and carrier id
  --
  -- IN parameters:
  --	1. p_lane_number:	unique lane identification name
  --	2. p_carrier_id:	carrier id
  --
  -- Returns a number, -1 for no lane id, else the lane id for the lane number and carrier
  ---------------------------------------------------------------------------
  FUNCTION GET_LANE_ID (p_lane_number	IN 	VARCHAR2,
			p_carrier_id	IN	NUMBER) RETURN NUMBER;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_LANE_ID
  --
  -- Purpose: get the next lane squence number
  --
  -- Returns lane squence
  ---------------------------------------------------------------------------
  FUNCTION GET_NEXT_LANE_ID RETURN NUMBER;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_LANE_COMMODITY_ID
  --
  -- Purpose: get the next squence number for commodity
  --
  -- Returns lane commodity sequence
  ---------------------------------------------------------------------------
  FUNCTION GET_NEXT_LANE_COMMODITY_ID RETURN NUMBER;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_LANE_SERVICE_ID
  --
  -- Purpose: get the next squence number for service
  --
  -- Returns lane service squence
  ---------------------------------------------------------------------------
  FUNCTION GET_NEXT_LANE_SERVICE_ID RETURN NUMBER;

  --------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_SCHEDULE_ID
  --
  -- Purpose: get the next schedule id based on the sequence
  --
  -- Returns schedule id, -1 if not found, -2 if other errors
  --------------------------------------------------------------------------
  FUNCTION GET_NEXT_SCHEDULE_ID RETURN NUMBER;

  --------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_PRC_PARAMETER_ID
  --
  -- Purpose: get the next schedule id based on the sequence
  --
  -- Returns schedule id, -1 if not found, -2 if other errors
  --------------------------------------------------------------------------
  FUNCTION GET_NEXT_PRC_PARAMETER_ID RETURN NUMBER;

  --------------------------------------------------------------------------
  -- FUNCTION GET_SCHEDULE
  --
  -- Purpose: get the schedule id based on the lane id and voyage
  --
  -- IN parameters:
  --	1. p_lane_id:	lane id to be searched
  --	2. p_voyage:	voyage
  --
  -- Returns the schedule id. < 0 if errors
  --------------------------------------------------------------------------
  FUNCTION GET_SCHEDULE(p_lane_id	IN	NUMBER,
			p_voyage	IN	VARCHAR2) RETURN NUMBER;

  ------------------------------------------------------------------------
  -- PROCEDURE DELETE_ROW
  --
  -- Purpose: delete a row in the fte_* tables
  --
  -- IN parameters:
  --  	1. p_id:	id to used for delete
  --	2. p_table:	table to delete from
  --	3. p_code:	codes to use for matching
  --
  -- OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  ------------------------------------------------------------------------
  PROCEDURE DELETE_ROW(p_id	IN	NUMBER,
		       p_table	IN	VARCHAR2,
		       p_code	IN	VARCHAR2,
		       p_line_number IN NUMBER,
		       x_status	OUT NOCOPY	NUMBER,
		       x_error_msg  OUT NOCOPY	VARCHAR2);

  -------------------------------------------------------------------------
  --  PROCEDURE UPDATE_LANE_FLAGS
  --
  --  Purpose:  update the service detail, commodity detail, and schedules flag of the lane
  --
  --  IN parameters:
  --	1. p_type:	type of the update
  --	2. p_lane_id:	lane id to be updated
  --	3. p_value:	value to set the flag to for schedule
  --
  --  OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  -------------------------------------------------------------------------
  PROCEDURE UPDATE_LANE_FLAGS(p_type	IN	VARCHAR2,
			      p_lane_id	IN	NUMBER,
			      p_value	IN	VARCHAR2 DEFAULT 'N',
			      x_status	OUT NOCOPY	NUMBER,
			      x_error_msg OUT NOCOPY	VARCHAR2);

  -------------------------------------------------------------------------
  --  PROCEDURE UPDATE_LANE_RATE_CHART
  --
  --  Purpose: update lane rate chart's dates
  --
  --  IN parameters:
  --	1. p_list_header_id:	the rate chart to update in fte_lane_rate_charts
  --	2. p_start_date:	start date
  --	3. p_end_date:		end date
  --
  --  OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  -------------------------------------------------------------------------
  PROCEDURE UPDATE_LANE_RATE_CHART (p_list_header_id	IN	NUMBER,
				    p_start_date	IN	DATE,
				    p_end_date		IN	DATE,
				    x_status		OUT NOCOPY NUMBER,
				    x_error_msg		OUT NOCOPY VARCHAR2);


  ------------------------------------------------------------------
  -- FUNCTION VERIFY_OVERLAPPING_DATE
  --
  -- Purpose: verify if the rate chart being added has any date conflict with the ones already attached
  --
  -- IN parameters:
  --	1. p_name:	name of the rate chart
  --	2. p_lane_id:	lane id
  --
  -- OUT parameters:
  --	1. x_status:	error status, -1 if no error
  --	2. x_error_msg: error message if any
  --
  -- RETURN true if some other chart date overlap, false if no overlap
  ------------------------------------------------------------------
  FUNCTION VERIFY_OVERLAPPING_DATE(p_name	IN	VARCHAR2,
				   p_lane_id	IN	NUMBER,
				   x_status	OUT NOCOPY NUMBER,
				   x_error_msg	OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  ------------------------------------------------------------------
  -- FUNCTION FIND_TYPE
  --
  -- Purpose: find if the lane service or lane commodity already have the service level or commodity
  --
  -- IN parameters:
  --	1. p_type:	SERVICE_LEVEL or COMMODITY
  --	2. p_value:	value to be found
  --	3. p_lane_id:	lane id
  --
  -- OUT parameters:
  --	1. x_status:	error status, -1 if no error
  --	2. x_error_msg: error message if any
  --
  -- RETURN true if type is found
  ------------------------------------------------------------------
  FUNCTION FIND_TYPE(p_type	IN	VARCHAR2,
		     p_value	IN	VARCHAR2,
		     p_lane_id	IN	NUMBER,
		     p_line_number IN 	NUMBER,
		     x_status	OUT NOCOPY NUMBER,
		     x_error_msg	OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  -------------------------------------------------------------------------
  --  PROCEDURE INSERT_LANE_TABLES
  --
  --  Purpose: insert all lane tables
  --
  --  IN parameters:
  --	1. p_lane_tbl:		lane pl/sql table
  --	2. p_lane_rate_chart_tbl: lane rate chart pl/sql table
  --	3. p_lane_commodity_tbl: lane commodity pl/sql table
  --	4. p_lane_service_tbl:	lane service pl/sql table
  --
  --  OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  -------------------------------------------------------------------------
  PROCEDURE INSERT_LANE_TABLES(p_lane_tbl		IN OUT NOCOPY lane_tbl,
			       p_lane_rate_chart_tbl	IN OUT NOCOPY lane_rate_chart_tbl,
			       p_lane_commodity_tbl	IN OUT NOCOPY lane_commodity_tbl,
			       p_lane_service_tbl	IN OUT NOCOPY lane_service_tbl,
			       x_status		OUT NOCOPY NUMBER,
			       x_error_msg	OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  --  PROCEDURE INSERT_SCHEDULES
  --
  --  Purpose: insert schedules
  --
  --  IN parameters:
  --	1. p_schedule_tbl:	schedules pl/sql table
  --
  --  OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  -------------------------------------------------------------------------
  PROCEDURE INSERT_SCHEDULES(p_schedule_tbl		IN OUT NOCOPY schedule_tbl,
			     x_status			OUT NOCOPY NUMBER,
			     x_error_msg		OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  --
  -- PROCEDURE: Check_Lanes
  -- Purpose: check if the rate chart has lanes attatched to it or not
  --
  -- IN Parameter:
  --	1. p_pricelist_id:	list header id
  --
  -- OUT Parameters:
  --	1. x_status:	status, -1 if no lanes attached, 2 otherwise
  --	2. x_error_msg:	error message if any
  --
  --  Returns -1 if there are no lanes attached to the
  --                rate chart, 2 otherwise.
  -------------------------------------------------------------------------------
  PROCEDURE Check_Lanes(p_pricelist_id  IN     NUMBER,
                        x_status	OUT NOCOPY NUMBER,
			x_error_msg  	OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  --  PROCEDURE INSERT_PRC_PARAMETERS
  --
  --  Purpose: insert the prc parameter row
  --
  --  IN parameters:
  --	1. p_prc_parameter_tbl:	pricing parameter pl/sql table
  --
  --  OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  -------------------------------------------------------------------------
  PROCEDURE INSERT_PRC_PARAMETERS(p_prc_parameter_tbl	IN OUT NOCOPY prc_parameter_tbl,
			      	  x_status		OUT NOCOPY NUMBER,
			     	  x_error_msg		OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  --  PROCEDURE UPDATE_PRC_PARAMETER
  --
  --  Purpose: update pricing parameter line
  --
  --  IN parameters:
  --	1. p_prc_parameter_tbl:	pricing parameter pl/sql table
  --
  --  OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  -------------------------------------------------------------------------
  PROCEDURE UPDATE_PRC_PARAMETER( p_prc_parameter_tbl	IN	prc_parameter_tbl,
				  x_status		OUT NOCOPY NUMBER,
				  x_error_msg		OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------
  -- FUNCTION CHECK_EXISTING_LOAD
  --
  -- Purpose: check existing entries in the fte_* tables
  --
  -- IN parameters:
  --  	1. p_id:	id to used for validating
  --	2. p_table:	table to validate
  --	3. p_code:	codes to use for matching
  --
  -- OUT parameters:
  --	1. x_status:	status of the error -1 when no error
  --	2. x_error_msg:	error msg if any errors
  ------------------------------------------------------------------------
  FUNCTION CHECK_EXISTING_LOAD( p_id		IN	NUMBER,
		       	        p_table		IN	VARCHAR2,
		       		p_code		IN	VARCHAR2,
		       		p_line_number 	IN 	NUMBER,
		       		x_status	OUT NOCOPY NUMBER,
		       		x_error_msg  	OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END FTE_LANE_PKG;

 

/
