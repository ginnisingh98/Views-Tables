--------------------------------------------------------
--  DDL for Package FTE_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_VALIDATION_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEVALDS.pls 120.2 2005/06/28 23:50:23 pkaliyam noship $ */


/***********************************************************************************/

  TL_BASE_RATES 	CONSTANT STRINGARRAY := STRINGARRAY('ACTION','CARRIER_NAME',
    'RATE_CHART_NAME','CURRENCY','RATE_BASIS','RATE_BASIS_UOM','DISTANCE_TYPE',
    'SERVICE_LEVEL', 'VEHICLE_TYPE', 'RATE', 'MINIMUM_CHARGE', 'START_DATE', 'END_DATE');

  SERVICE 		CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','TYPE','CARRIER_NAME',
    'SERVICE_NUMBER','MODE_OF_TRANSPORTATION','ORIGIN_COUNTRY','ORIGIN_STATE',
    'ORIGIN_CITY','ORIGIN_POSTAL_CODE_FROM','ORIGIN_POSTAL_CODE_TO',
    'ORIGIN_ZONE','DESTINATION_COUNTRY','DESTINATION_STATE',
    'DESTINATION_CITY','DESTINATION_POSTAL_CODE_FROM',
    'DESTINATION_POSTAL_CODE_TO','DESTINATION_ZONE','COMMODITY_CLASS',
    'SERVICE_LEVEL','COMMODITY_TYPE','BASIS',
    'RATE_CHART_NAME','RATE_CHART_VIEW_FLAG','PORT_OF_LOADING',
    'PORT_OF_DISCHARGE','DISTANCE','DISTANCE_UOM','TRANSIT_TIME',
    'TRANSIT_TIME_UOM','SPECIAL_HANDLING','ADDITIONAL_INSTRUCTIONS',
    'START_DATE','END_DATE');

  SERVICE_RATING_SETUP 	CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','CARRIER_NAME','SERVICE_NUMBER','TYPE','SUBTYPE','NAME',
    'VALUE_FROM','VALUE_TO','UOM','CURRENCY');

  SCHEDULE 		CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','CARRIER_NAME','SERVICE_NUMBER','VESSEL_TYPE','VESSEL_NAME',
    'VOYAGE_NUMBER','DEPARTURE_DATE','DEPARTURE_TIME','ARRIVAL_DATE',
    'ARRIVAL_TIME','ARRIVAL_DATE_INDICATOR','FREQUENCY_TYPE','FREQUENCY',
    'TRANSIT_TIME','TRANSIT_TIME_UOM','PORT_OF_LOADING','PORT_OF_DISCHARGE',
    'START_DATE','END_DATE');

  RATE_CHART		CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','CARRIER_NAME','RATE_CHART_NAME','CURRENCY','START_DATE',
    'END_DATE','DESCRIPTION','REPLACED_RATE_CHART');

  RATE_LINE 		CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','LINE_NUMBER','DESCRIPTION','RATE','UOM','RATE_BREAK_TYPE',
    'VOLUME_TYPE','RATE_TYPE');

  RATE_BREAK 		CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','LINE_NUMBER','LOWER_LIMIT','UPPER_LIMIT','RATE', 'RATE_TYPE');

  RATING_ATTRIBUTE	CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','LINE_NUMBER','ATTRIBUTE','ATTRIBUTE_VALUE');

  CHARGES_DISCOUNTS 	CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','CARRIER_NAME','CHARGES_DISCOUNTS_NAME','CURRENCY',
    'START_DATE','END_DATE','DESCRIPTION');

  ADJUSTED_RATE_CHART	CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','RATE_CHART_NAME', 'TARIFF_NAME');

  CHARGES_DISCOUNTS_LINE 	CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','LINE_NUMBER','DESCRIPTION','TYPE','SUBTYPE','UOM',
    'RATE_PER_UOM','PERCENTAGE','FIXED_RATE');

  RATING_ZONE_CHART 	CONSTANT STRINGARRAY := STRINGARRAY (
    'NAME_PREFIX','MODE_OF_TRANSPORTATION','CARRIER_NAME',
    'RATE_CHART_PREFIX', 'RATE_CHART_VIEW_FLAG', 'START_DATE', 'END_DATE');

  RATING_SETUP 	CONSTANT STRINGARRAY := STRINGARRAY(
    'SERVICE_LEVEL','TYPE','SUBTYPE','NAME','VALUE_FROM','VALUE_TO','UOM',
    'CURRENCY');

  ORIGIN	CONSTANT STRINGARRAY := STRINGARRAY(
    'POSTAL_CODE_RANGE','COUNTRY','STATE','CITY');

  REGION		CONSTANT STRINGARRAY := STRINGARRAY (
    'ACTION','COUNTRY','COUNTRY_CODE','STATE','STATE_CODE','CITY',
    'CITY_CODE','POSTAL_CODE_FROM','POSTAL_CODE_TO');

  ZONE			CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','ZONE_NAME','COUNTRY','STATE','CITY','POSTAL_CODE_FROM',
    'POSTAL_CODE_TO');

  TL_SERVICES 		CONSTANT STRINGARRAY := STRINGARRAY(
    'ACTION','CARRIER_NAME','SERVICE_NUMBER', 'ORIGIN_COUNTRY','ORIGIN_STATE',
    'ORIGIN_CITY','ORIGIN_POSTAL_CODE_FROM','ORIGIN_POSTAL_CODE_TO',
    'ORIGIN_ZONE','DESTINATION_COUNTRY','DESTINATION_STATE',
    'DESTINATION_CITY','DESTINATION_POSTAL_CODE_FROM',
    'DESTINATION_POSTAL_CODE_TO','DESTINATION_ZONE','SERVICE_START_DATE',
    'SERVICE_END_DATE','RATE_CHART_NAME','SERVICE_LEVEL');

  TL_SURCHARGES 	CONSTANT STRINGARRAY := STRINGARRAY(
      'ACTION','TYPE','CARRIER_NAME','SERVICE_LEVEL','CURRENCY','START_DATE','END_DATE',
      'NUMBER_OF_FREE_STOPS','FIRST_ADD_STOP_OFF_CHARGES','SECOND_ADD_STOP_OFF_CHARGES',
      'THIRD_ADD_STOP_OFF_CHARGES','FOURTH_ADD_STOP_OFF_CHARGES','FIFTH_ADD_STOP_OFF_CHARGES',
      'ADDITIONAL_STOP_CHARGES','OUT_OF_ROUTE_CHARGES','OUT_OF_ROUTE_CHARGE_BASIS_UOM',
      'BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES','UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS',
      'HANDLING_CHARGES','MINIMUM_HANDLING_CHARGES','LOADING_CHARGES','MINIMUM_LOADING_CHARGES',
      'ASSISTED_LOADING_CHARGES','MINIMUM_ASSISTED_LOADING_CHARGES','UNLOADING_CHARGES',
      'MINIMUM_UNLOADING_CHARGES','ASSISTED_UNLOADING_CHARGES','MINIMUM_ASSISTED_UNLOADING_CHARGES',
      'WEEKDAY_LAYOVER_CHARGES','DISTANCE_UOM_FOR_WEEKEND_LAYOVER_CHARGES',
      'WEEKEND_LAYOVER_DISTANCE_BREAK', 'CHARGES','CONTINUOUS_MOVE_DISCOUNT_PERCENTAGE',
      'COUNTRY','STATE','CITY','POSTAL_CODE_FROM','POSTAL_CODE_TO','SURCHARGES');

  FACILITY_CHARGES	CONSTANT STRINGARRAY := STRINGARRAY(
      'ACTION','FACILITY_RATE_CHART_NAME','START_DATE','END_DATE','CURRENCY',
      'BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES','UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS',
      'HANDLING_CHARGES', 'MINIMUM_HANDLING_CHARGES','LOADING_CHARGES','MINIMUM_LOADING_CHARGES',
      'UNLOADING_CHARGES', 'MINIMUM_UNLOADING_CHARGES','ASSISTED_LOADING_CHARGES',
      'MINIMUM_ASSISTED_LOADING_CHARGES', 'ASSISTED_UNLOADING_CHARGES',
      'MINIMUM_ASSISTED_UNLOADING_CHARGES');

  g_debug_set            BOOLEAN := TRUE;
  g_debug_on             BOOLEAN := TRUE;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_COLUMNS
  --
  -- Purpose: check if the columns read is valid
  --
  -- IN parameters:
  --	1. p_keys:	columns STRINGARRAY
  --	2. p_type:	type of the block
  --	3. p_line_number: line number
  --
  -- OUT parameters:
  --	1. x_status:		status, -1 if no error(1 wrong number, 2 wrong column, 3 no such type)
  --	2. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_COLUMNS (p_keys		IN	FTE_BULKLOAD_PKG.block_header_tbl,
			      p_type		IN	VARCHAR2,
			      p_line_number	IN 	NUMBER,
			      x_status		OUT NOCOPY	NUMBER,
			      x_error_msg	OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_RATING_ZONE_CHART
  --
  -- Purpose: does validation for one line in rating zone chart block
  --
  -- IN parameters:
  --	1. p_values:	  pl/sql table of the rating zone chart line
  --	2. p_line_number: line number of current line
  --
  -- OUT parameters:
  --	1. p_chart_info: 	a STRINGARRAY that contains name_prefix, mode_of_trans, carrier_name,
  --				carrier_id, price_prefix, view_flag, start_date, and end_date
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATING_ZONE_CHART(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
				       p_line_number	IN		NUMBER,
				       p_chart_info	OUT NOCOPY	STRINGARRAY,
				       x_status		OUT NOCOPY	NUMBER,
				       x_error_msg	OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_RATING_SETUP
  --
  -- Purpose: does validation for one line in rating setup block
  --
  -- IN parameters:
  --	1. p_values:	pl/sql table of rating setup line
  --	2. p_line_number: line number of current line
  --
  -- OUT parameters:
  --	1. p_setup_info:	table of service information
  --	2. p_last_service_type:	last line's service type
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATING_SETUP(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
				  p_line_number		IN		NUMBER,
				  p_setup_info		IN OUT NOCOPY	FTE_BULKLOAD_PKG.array_tbl,
				  p_last_service_type	IN OUT NOCOPY	VARCHAR2,
				  x_status		OUT NOCOPY	NUMBER,
				  x_error_msg		OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_ORIGIN
  --
  -- Purpose: does validation for one line in origin block
  --
  -- IN parameters:
  --	1. p_values:	pl/sql table of origin line
  --	2. p_line_number: line number of current line
  --
  -- OUT parameters:
  --	1. p_origin:		STRINGARRAY of origin_postal, origin_country, origin_state, and origin_city
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_ORIGIN(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
			    p_line_number	IN		NUMBER,
			    p_origin		OUT NOCOPY	STRINGARRAY,
			    x_status		OUT NOCOPY	NUMBER,
			    x_error_msg		OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_DESTINATION
  --
  -- Purpose: does validation for one line in destination block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table of destination line
  --	2. p_line_number: 	line number of current line
  --	3. p_price_prefix:	price prefix
  --	4. p_carrier_id:	carrier id
  --	5. p_origin_zone:	pl/sql table of origin zone info
  --	6. p_service_count:	number of service columns
  --	7. p_services:		service column names
  --
  -- OUT parameters:
  --	1. p_dest:		STRINGARRAY of dest_postal, dest_country, dest_state, and dest_city
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_DESTINATION(p_values		IN OUT NOCOPY	FTE_BULKLOAD_PKG.data_values_tbl,
				 p_line_number		IN		NUMBER,
				 p_price_prefix		IN		VARCHAR2,
				 p_carrier_id		IN		NUMBER,
				 p_origin_zone		IN		FTE_BULKLOAD_PKG.data_values_tbl,
				 p_service_count	IN OUT NOCOPY	NUMBER,
				 p_services		IN OUT NOCOPY	FTE_PARCEL_LOADER.service_array,
				 p_dest			OUT NOCOPY	STRINGARRAY,
				 x_status		OUT NOCOPY	NUMBER,
				 x_error_msg		OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_SERVICE
  --
  -- Purpose: does validation for a line in service block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table of the service line
  --	2. p_line_number: 	line number of current line
  --
  -- OUT parameters:
  --	1. p_type:		type value of the line
  --	2. p_action:		action value of the line
  --	3. p_lane_tbl:		pl/sql table for lane
  --	4. p_lane_rate_chart_tbl: pl/sql table for lane rate chart
  --	5. p_lane_service_tbl:	pl/sql table for lane service
  --	6. p_lane_commodity_tbl: pl/sql table for lane commodity
  --	7. x_status:		status of the processing, -1 means no error
  --	8. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_SERVICE(p_values			IN		FTE_BULKLOAD_PKG.data_values_tbl,
			     p_line_number		IN		NUMBER,
			     p_type			OUT NOCOPY	VARCHAR2,
			     p_action			OUT NOCOPY	VARCHAR2,
			     p_lane_tbl			IN OUT NOCOPY	FTE_LANE_PKG.lane_tbl,
			     p_lane_rate_chart_tbl 	IN OUT NOCOPY	FTE_LANE_PKG.lane_rate_chart_tbl,
			     p_lane_service_tbl		IN OUT NOCOPY	FTE_LANE_PKG.lane_service_tbl,
			     p_lane_commodity_tbl 	IN OUT NOCOPY	FTE_LANE_PKG.lane_commodity_tbl,
			     x_status			OUT NOCOPY	NUMBER,
			     x_error_msg		OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_SERVICE_RATING_SETUP
  --
  -- Purpose: does validation for one line in service rating setup block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table for the service rating setup line
  --	2. p_line_number: 	line number of current line
  --   	3. p_pre_lane_number:	previous lane's line number
  --
  -- OUT parameters:
  --	1. p_prc_parameter_tbl: pl/sql table for pricing parameter
  --	2. p_deficit_wt:	deficit weight parameter
  --	3. p_lane_function:	lane function
  --	4. p_lane_number:	lane number
  --	5. p_action:		action value of the line
  --	6. x_status:		status of the processing, -1 means no error
  --	7. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_SERVICE_RATING_SETUP(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
					  p_line_number		IN		NUMBER,
					  p_pre_lane_number	IN		VARCHAR2,
					  p_prc_parameter_tbl	IN OUT NOCOPY	FTE_LANE_PKG.prc_parameter_tbl,
					  p_deficit_wt		IN OUT NOCOPY	BOOLEAN,
					  p_lane_function	IN OUT NOCOPY	VARCHAR2,
					  p_lane_number		OUT NOCOPY	VARCHAR2,
					  p_action		OUT NOCOPY	VARCHAR2,
					  x_status		OUT NOCOPY	NUMBER,
					  x_error_msg		OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_SCHEDULE
  --
  -- Purpose: does validation for one line in schedule block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table for schedule line
  --	2. p_line_number: 	line number of current line
  --
  -- OUT parameters:
  --	1. p_schedule_tbl:	pl/sql table for schedules
  --	2. p_action:		action value of the line
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_SCHEDULE(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
			      p_line_number	IN		NUMBER,
			      p_schedule_tbl	IN OUT NOCOPY	FTE_LANE_PKG.schedule_tbl,
			      p_action		OUT NOCOPY	VARCHAR2,
			      x_status		OUT NOCOPY	NUMBER,
			      x_error_msg	OUT NOCOPY	VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATE_CHART
  --
  -- Purpose: Validate the data corresponding to this Line Header, and
  --          store the data in temporary tables for later insertion into
  --          p_list_header_tbl
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the rate chart line
  --	2. p_line_number:	line number
  --	3. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --	4. p_process_id		process id for the loading, default null and assigned later
  --
  -- Out Parameters
  --    1. p_qp_list_header_tbl: 	pl/sql table for the list header information
  --	2. p_qp_qualifier_tbl:	pl/sql table for the qualifiers
  --	3. p_action:		action of the line
  --	4. p_carrier_id:	carrier id
  --	4. x_status:		status of the processing, -1 means no error
  --	5. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATE_CHART(p_values     		IN    		FTE_BULKLOAD_PKG.data_values_tbl,
				p_line_number		IN		NUMBER,
				p_validate 		IN 		BOOLEAN DEFAULT TRUE,
				p_process_id 		IN		NUMBER default null,
                                p_qp_list_header_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_list_header_tbl,
				p_qp_qualifier_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_qualifier_tbl,
				p_action		OUT NOCOPY	VARCHAR2,
				p_carrier_id		OUT NOCOPY	NUMBER,
                                x_status     		OUT NOCOPY  	NUMBER,
                                x_error_msg  		OUT NOCOPY  	VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATE_LINE
  --
  -- Purpose: Validate the data corresponding to this Rate Chart Line, and
  --          store the data in temporary tables for later insertion into
  --          QP_INTERFACE_LIST_LINES and QP_INTERFACE_LIST_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the rate line line
  --	2. p_line_number:	line number
  --	3. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- Out Parameters
  --    1. p_qp_list_line_tbl: 	pl/sql table for the list line information
  --	2. p_qp_pricing_attrib_tbl:	pl/sql table for the attributes
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATE_LINE(p_values     		IN    		FTE_BULKLOAD_PKG.data_values_tbl,
			       p_line_number		IN		NUMBER,
			       p_validate 		IN 		BOOLEAN DEFAULT TRUE,
                               p_qp_list_line_tbl	IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_list_line_tbl,
			       p_qp_pricing_attrib_tbl	IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
	                       x_status     		OUT NOCOPY  	NUMBER,
                               x_error_msg  		OUT NOCOPY  	VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATE_BREAK
  --
  -- Purpose: Validate the data corresponding to this price break, and store
  --          the data in temporary tables for later insertion into
  --          QP_INTERFACE_LIST_LINES and QP_INTERFACE_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the rate break line
  --	2. p_line_number:	line number
  --	3. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- Out Parameters
  --    1. p_qp_list_line_tbl: 	pl/sql table for the list line information
  --	2. p_qp_pricing_attrib_tbl:	pl/sql table for the attributes
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATE_BREAK(p_values     		IN    		FTE_BULKLOAD_PKG.data_values_tbl,
				p_line_number		IN		NUMBER,
			        p_validate 		IN 		BOOLEAN DEFAULT TRUE,
                                p_qp_list_line_tbl	IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_list_line_tbl,
				p_qp_pricing_attrib_tbl	IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
	                        x_status     		OUT NOCOPY  	NUMBER,
                                x_error_msg  		OUT NOCOPY  	VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATING_ATTRIBUTE
  --
  -- Purpose: Validate the data corresponding to this pricing attribute, and
  --          store the data in temporary tables for later insertion into
  --          QP_INTERFACE_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for rating attribute line
  --	2. p_line_number:	line number
  --
  -- Out Parameters
  --	1. p_qp_pricing_attrib_tbl:	pl/sql table for the attributes
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATING_ATTRIBUTE(p_values     	IN    		FTE_BULKLOAD_PKG.data_values_tbl,
				      p_line_number	IN		NUMBER,
				      p_qp_pricing_attrib_tbl	IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
	                      	      x_status     	OUT NOCOPY  	NUMBER,
                                      x_error_msg  	OUT NOCOPY  	VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_ADJUSTED_RATE_CHART
  --
  -- Purpose: Validate the data corresponding to this Qualifier, and
  --          store the data in temporary tables for later insertion into
  --          QP_INTERFACE_QUALIFIERS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for adjusted rate chart line
  --	2. p_line_number:	line number
  --	3. p_carrier_id:	carrier id from the header
  --
  -- Out Parameters
  --	1. p_qp_qualifier_tbl:	pl/sql table for the attributes
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_ADJUSTED_RATE_CHART(p_values     	IN    		FTE_BULKLOAD_PKG.data_values_tbl,
			 		 p_line_number	IN		NUMBER,
					 p_carrier_id	IN		NUMBER,
			       		 p_qp_qualifier_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_qualifier_tbl,
	                       		 x_status     	OUT NOCOPY  	NUMBER,
                               		 x_error_msg  	OUT NOCOPY  	VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_QUALIFIER
  --
  -- Purpose: Add a qualifier to the qp_interface_qualifiers table for the
  --          a rate chart.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the qualifier line
  --	2. p_line_number:	line number
  --
  -- Out Parameters
  --	1. p_qp_qualifier_tbl:	pl/sql table for the attributes
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_QUALIFIER(p_values     	IN    		FTE_BULKLOAD_PKG.data_values_tbl,
			       p_line_number	IN		NUMBER,
			       p_qp_qualifier_tbl IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_qualifier_tbl,
	                       x_status     	OUT NOCOPY  	NUMBER,
                               x_error_msg  	OUT NOCOPY  	VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE: ADD_ATTRIBUTE
  --
  -- Purpose: Store a pricing attribute in the temporary attribute tables for
  --          later insertion into QP_INTERFACE_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_pricing_attribute: The pricing attribute
  --    2. p_attr_value_from: 	The value of the pricing attribute
  --	3. p_attr_value_to:
  --    4. p_line_number: 	The line number for this pricing attribute.
  --	5. p_comp_operator:	comparison operator
  --	6. p_qp_pricing_attrib_tbl:	pl/sql table for pricing attributes
  --
  -- Out Parameters
  --    1. x_status:	status, -1 when no errors
  --	2. x_error_msg:	error message if any
  -----------------------------------------------------------------------------
  PROCEDURE ADD_ATTRIBUTE(p_pricing_attribute   IN   VARCHAR2,
                          p_attr_value_from     IN   VARCHAR2,
                          p_attr_value_to       IN   VARCHAR2,
                          p_line_number         IN   VARCHAR2,
                          p_context             IN   VARCHAR2,
                          p_comp_operator       IN   VARCHAR2,
			  p_qp_pricing_attrib_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
                          x_status              OUT  NOCOPY  NUMBER,
			  x_error_msg		OUT  NOCOPY  VARCHAR2);

  -----------------------------------------------------------------------------
  -- FUNCTION  Validate_Service_Level
  --
  -- Purpose    Validate that the carrier with id <p_carrier_id> has been set
  --            up to handle the service level <p_service_level>
  --
  -- IN Parameters
  --    1. p_carrier_id:  	The carrier id
  --	2. p_carrier_name:	carrier name
  --    3. p_service_level:	service level to validate
  --	4. p_line_number:	line number
  --
  -- OUT Parameters
  --	1. x_status:	error status, -1 if no errors
  --	2. x_error_msg:	error message if any
  --
  -- Returns:
  -- 	service code
  -----------------------------------------------------------------------------
  FUNCTION VALIDATE_SERVICE_LEVEL(p_carrier_id    IN  NUMBER,
                                  p_carrier_name  IN  VARCHAR2,
                                  p_service_level IN  VARCHAR2,
				  p_line_number	  IN  NUMBER,
                                  x_status        OUT NOCOPY NUMBER,
                                  x_error_msg     OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_ACTION
  --
  -- Purpose: check if the action is valid
  --
  -- IN parameters:
  --	1. p_action:		action value
  --	2. p_type:		block type
  --	3. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. x_status:		status, -1 if no error
  --	2. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_ACTION(p_action		IN OUT 	NOCOPY VARCHAR2,
                            p_type		IN	VARCHAR2,
                            p_line_number	IN	NUMBER,
                            x_status		OUT NOCOPY NUMBER,
                            x_error_msg		OUT NOCOPY VARCHAR2);


  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_TL_SERVICE
  --
  -- Purpose: does validation for a line in tl service block
  --
  -- IN parameters:
  --	1. p_values:		FTE_BULKLOAD_PKG.data_values_tbl
  --	2. p_line_number: line number of current line
  --
  -- OUT parameters:
  --	1. p_type:		type value of the line
  --	2. p_action:		action value of the line
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_TL_SERVICE(p_values		IN   		FTE_BULKLOAD_PKG.data_values_tbl,
                                p_line_number	        IN	    	NUMBER,
                                p_type		        OUT NOCOPY	VARCHAR2,
                                p_action	        OUT NOCOPY	VARCHAR2,
                                p_lane_tbl	    	IN OUT	NOCOPY	FTE_LANE_PKG.lane_tbl,
                                p_lane_service_tbl	IN OUT	NOCOPY	FTE_LANE_PKG.lane_service_tbl,
                                p_lane_rate_chart_tbl 	IN OUT	NOCOPY	FTE_LANE_PKG.lane_rate_chart_tbl,
                                x_status	        OUT NOCOPY	NUMBER,
                                x_error_msg		OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_LANE_NUMBER
  --
  -- Purpose: check if the lane number is valid
  --
  -- IN parameters:
  --	1. p_lane_number:	lane number value
  --	2. p_carrier_id:	carrier id
  --	3. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. p_lane_id:		lane id of the lane number if exists in the table
  --	2. x_status:		status, -1 if no error
  --	3. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_LANE_NUMBER(p_lane_number	IN 	VARCHAR2,
				 p_carrier_id	IN	NUMBER,
				 p_line_number	IN	NUMBER,
				 p_lane_id	OUT NOCOPY NUMBER,
				 x_status	OUT NOCOPY NUMBER,
				 x_error_msg	OUT NOCOPY VARCHAR2);

    --_______________________________________________________________________________________--
    --
    -- PROCEDURE VALIDATE_ZONE
    --
    -- Purpose: does validation for one line in zone block
    --
    -- IN parameters:
    --  1. p_columns:   STRINGARRAY of the column names
    --  2. p_values:    STRINGARRAY of the line values
    --  3. p_line_number: line number of current line
    --  4. p_region_type: region type for the zone (10, 11 etc)
    --
    -- OUT parameters:
    --  1. p_action:    action value of the line
    --  2. p_zone_name: zone name value of the line
    --  3. p_country:   country value of the line
    --  4. p_zone_id:   zone id, not -1 if zone exists
    --  5. p_region_rec: record to store region info
    --  6. p_region_id: region id, not -1 if already exists
    --  7. x_status:    status of the processing, -1 means no error
    --  8. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE VALIDATE_ZONE(p_values            IN          FTE_BULKLOAD_PKG.data_values_tbl,
                            p_line_number       IN          NUMBER,
                            p_region_type       IN          VARCHAR2,
                            p_action            OUT NOCOPY  VARCHAR2,
                            p_zone_name         OUT NOCOPY  VARCHAR2,
                            p_country           OUT NOCOPY  VARCHAR2,
                            p_zone_id           OUT NOCOPY  NUMBER,
                            p_region_rec        OUT NOCOPY  WSH_REGIONS_SEARCH_PKG.region_rec,
                            p_region_id         OUT NOCOPY  NUMBER,
                            x_status            OUT NOCOPY  NUMBER,
                            x_error_msg         OUT NOCOPY  VARCHAR2);
END FTE_VALIDATION_PKG;

 

/
