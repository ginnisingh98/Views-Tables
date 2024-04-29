--------------------------------------------------------
--  DDL for Package Body FTE_LANE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_LANE_PKG" AS
/* $Header: FTELANEB.pls 120.5 2005/08/19 00:16:32 pkaliyam noship $ */
  ------------------------------------------------------------------------- --
  --                                                                        --
  -- NAME:        FTE_LANE_PKG                                              --
  -- TYPE:        PACKAGE BODY                                              --
  -- FUNCTIONS:		GET_NEXT_SCHEDULE_ID				    --
  --			GET_NEXT_PRC_PARAMETER_ID			    --
  --			GET_SCHEDULE					    --
  -- 			GET_LANE_ID					    --
  --			GET_NEXT_LANE_COMMODITY_ID			    --
  --			GET_NEXT_LANE_SERVICE_ID			    --
  -- 			GET_NEXT_LANE_ID				    --
  --			VERIFY_OVERLAPPING_DATE				    --
  --			FIND_TYPE					    --
  --			CHECK_EXISTING_LOAD				    --
  -- PROCEDURES:	CHECK_LANES					    --
  --			DELETE_ROW					    --
  --		 	UPDATE_LANE_FLAGS				    --
  --		 	INSERT_LANE_TABLES				    --
  --		 	INSERT_SCHEDULES				    --
  --			INSERT_PRC_PARAMETERS				    --
  --			UPDATE_LANE_RATE_CHART				    --
  --                    UPDATE_PRC_PARAMETER                                --
  ------------------------------------------------------------------------- --

  G_PKG_NAME         CONSTANT  VARCHAR2(50) := 'FTE_LANE_PKG';

  TYPE LANE_ID_TBL IS TABLE OF FTE_LANES.LANE_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE LANE_NUMBER_TBL IS TABLE OF FTE_LANES.LANE_NUMBER%TYPE INDEX BY BINARY_INTEGER;
  TYPE CARRIER_ID_TBL IS TABLE OF FTE_LANES.CARRIER_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE ORIGIN_ID_TBL IS TABLE OF FTE_LANES.ORIGIN_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE DESTINATION_ID_TBL IS TABLE OF FTE_LANES.DESTINATION_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE MODE_OF_TRANS_TBL IS TABLE OF FTE_LANES.MODE_OF_TRANSPORTATION_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE TRANSIT_TIME_TBL IS TABLE OF FTE_LANES.TRANSIT_TIME%TYPE INDEX BY BINARY_INTEGER;
  TYPE TRANSIT_TIME_UOM_TBL IS TABLE OF FTE_LANES.TRANSIT_TIME_UOM%TYPE INDEX BY BINARY_INTEGER;
  TYPE SPECIAL_HANDLING_TBL IS TABLE OF FTE_LANES.SPECIAL_HANDLING%TYPE INDEX BY BINARY_INTEGER;
  TYPE ADDITIONAL_INSTRUCTIONS_TBL IS TABLE OF FTE_LANES.ADDITIONAL_INSTRUCTIONS%TYPE INDEX BY BINARY_INTEGER;
  TYPE COMM_FC_CLASS_TBL IS TABLE OF FTE_LANES.COMM_FC_CLASS_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE COMM_CATG_ID_TBL IS TABLE OF FTE_LANES.COMMODITY_CATG_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE EQUIP_TYPE_CODE_TBL IS TABLE OF FTE_LANES.EQUIPMENT_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE SERVICE_TYPE_CODE_TBL IS TABLE OF FTE_LANES.SERVICE_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE DISTANCE_TBL IS TABLE OF FTE_LANES.DISTANCE%TYPE INDEX BY BINARY_INTEGER;
  TYPE DISTANCE_UOM_TBL IS TABLE OF FTE_LANES.DISTANCE_UOM%TYPE INDEX BY BINARY_INTEGER;
  TYPE PRICELIST_VIEW_FLAG_TBL IS TABLE OF FTE_LANES.PRICELIST_VIEW_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE BASIS_TBL IS TABLE OF FTE_LANES.BASIS%TYPE INDEX BY BINARY_INTEGER;
  TYPE EFFECTIVE_DATE_TBL IS TABLE OF FTE_LANES.EFFECTIVE_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE EXPIRY_DATE_TBL IS TABLE OF FTE_LANES.EXPIRY_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE EDITABLE_FLAG_TBL IS TABLE OF FTE_LANES.EDITABLE_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE LANE_TYPE_TBL IS TABLE OF FTE_LANES.LANE_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE TARIFF_NAME_TBL IS TABLE OF FTE_LANES.TARIFF_NAME%TYPE INDEX BY BINARY_INTEGER;
  TYPE LIST_HEADER_ID_TBL IS TABLE OF FTE_LANE_RATE_CHARTS.LIST_HEADER_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE START_DATE_ACTIVE_TBL IS TABLE OF FTE_LANE_RATE_CHARTS.START_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;
  TYPE END_DATE_ACTIVE_TBL IS TABLE OF FTE_LANE_RATE_CHARTS.END_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LANE_COMMODITY_ID_TBL IS TABLE OF FTE_LANE_COMMODITIES.LANE_COMMODITY_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE LANE_SERVICE_ID_TBL IS TABLE OF FTE_LANE_SERVICES.LANE_SERVICE_ID%TYPE INDEX BY BINARY_INTEGER;

  TYPE VESSEL_NAME_TBL IS TABLE OF FTE_SCHEDULES.VESSEL_NAME%TYPE INDEX BY BINARY_INTEGER;
  TYPE VESSEL_TYPE_TBL IS TABLE OF FTE_SCHEDULES.VESSEL_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE VOYAGE_NUMBER_TBL IS TABLE OF FTE_SCHEDULES.VOYAGE_NUMBER%TYPE INDEX BY BINARY_INTEGER;
  TYPE ARRIVAL_DATE_INDICATOR_TBL IS TABLE OF FTE_SCHEDULES.ARRIVAL_DATE_INDICATOR%TYPE INDEX BY BINARY_INTEGER;
  TYPE SCH_TRANSIT_TIME_TBL IS TABLE OF FTE_SCHEDULES.TRANSIT_TIME%TYPE INDEX BY BINARY_INTEGER;
  TYPE PORT_OF_LOADING_TBL IS TABLE OF FTE_SCHEDULES.PORT_OF_LOADING%TYPE INDEX BY BINARY_INTEGER;
  TYPE PORT_OF_DISCHARGE_TBL IS TABLE OF FTE_SCHEDULES.PORT_OF_DISCHARGE%TYPE INDEX BY BINARY_INTEGER;
  TYPE FREQUENCY_TYPE_TBL IS TABLE OF FTE_SCHEDULES.FREQUENCY_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE FREQUENCY_TBL IS TABLE OF FTE_SCHEDULES.FREQUENCY%TYPE INDEX BY BINARY_INTEGER;
  TYPE FREQUENCY_ARRIVAL_TBL IS TABLE OF FTE_SCHEDULES.FREQUENCY_ARRIVAL%TYPE INDEX BY BINARY_INTEGER;
  TYPE DEPARTURE_TIME_TBL IS TABLE OF FTE_SCHEDULES.DEPARTURE_TIME%TYPE INDEX BY BINARY_INTEGER;
  TYPE ARRIVAL_TIME_TBL IS TABLE OF FTE_SCHEDULES.ARRIVAL_TIME%TYPE INDEX BY BINARY_INTEGER;
  TYPE DEPARTURE_DATE_TBL IS TABLE OF FTE_SCHEDULES.DEPARTURE_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE ARRIVAL_DATE_TBL IS TABLE OF FTE_SCHEDULES.ARRIVAL_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE SCH_EFFECTIVE_DATE_TBL IS TABLE OF FTE_SCHEDULES.EFFECTIVE_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE SCH_EXPIRY_DATE_TBL IS TABLE OF FTE_SCHEDULES.EXPIRY_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE SCH_TRANSIT_TIME_UOM_TBL IS TABLE OF FTE_SCHEDULES.TRANSIT_TIME_UOM%TYPE INDEX BY BINARY_INTEGER;
  TYPE SCH_LANE_ID_TBL IS TABLE OF FTE_SCHEDULES.LANE_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE SCHEDULES_ID_TBL IS TABLE OF FTE_SCHEDULES.SCHEDULES_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE SCH_LANE_NUMBER_TBL IS TABLE OF FTE_SCHEDULES.LANE_NUMBER%TYPE INDEX BY BINARY_INTEGER;

  TYPE VALUE_FROM_TBL IS TABLE OF FTE_PRC_PARAMETERS.VALUE_FROM%TYPE INDEX BY BINARY_INTEGER;
  TYPE VALUE_TO_TBL IS TABLE OF FTE_PRC_PARAMETERS.VALUE_TO%TYPE INDEX BY BINARY_INTEGER;
  TYPE UOM_CODE_TBL IS TABLE OF FTE_PRC_PARAMETERS.UOM_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE CURRENCY_CODE_TBL IS TABLE OF FTE_PRC_PARAMETERS.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE PRC_LANE_ID_TBL IS TABLE OF FTE_PRC_PARAMETERS.LANE_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE PARAMETER_INS_ID_TBL IS TABLE OF FTE_PRC_PARAMETERS.PARAMETER_INSTANCE_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE PARAMETER_ID_TBL IS TABLE OF FTE_PRC_PARAMETERS.PARAMETER_ID%TYPE INDEX BY BINARY_INTEGER;

  --------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_SCHEDULE_ID
  --
  -- Purpose: get the next schedule id based on the sequence
  --
  -- Returns schedule id, -1 if not found, -2 if other errors
  --------------------------------------------------------------------------
  FUNCTION GET_NEXT_SCHEDULE_ID RETURN NUMBER IS
  l_id NUMBER;
  BEGIN
    SELECT fte_schedules_s.nextval
      INTO l_id
      FROM dual;
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_NEXT_SCHEDULE_ID;

  --------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_PRC_PARAMETER_ID
  --
  -- Purpose: get the next schedule id based on the sequence
  --
  -- Returns schedule id, -1 if not found, -2 if other errors
  --------------------------------------------------------------------------
  FUNCTION GET_NEXT_PRC_PARAMETER_ID RETURN NUMBER IS
  l_id NUMBER;
  BEGIN
    SELECT fte_prc_parameters_s.nextval
      INTO l_id
      FROM dual;
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_NEXT_PRC_PARAMETER_ID;

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
			p_voyage	IN 	VARCHAR2) RETURN NUMBER IS

  l_id	NUMBER;
  BEGIN
    SELECT schedules_id
      INTO l_id
      FROM fte_schedules
      WHERE lane_id = p_lane_id
	AND voyage_number = p_voyage
 	AND nvl(editable_flag,'Y') = 'Y';
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_SCHEDULE;


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
  FUNCTION GET_LANE_ID(p_lane_number	IN	VARCHAR2,
		       p_carrier_id	IN	NUMBER) RETURN NUMBER IS
  l_lane_id	NUMBER := -1;
  BEGIN
    SELECT lane_id
      INTO l_lane_id
      FROM fte_lanes
      WHERE lane_number = p_lane_number
	AND carrier_id = p_carrier_id
        AND editable_flag <> 'D';
    RETURN l_lane_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_LANE_ID;

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
			x_error_msg  	OUT NOCOPY VARCHAR2) IS

  CURSOR lane_number IS
  SELECT l.lane_number
  FROM   fte_lanes l, fte_lane_rate_charts c
  WHERE  c.lane_id = l.lane_id
  AND    c.list_header_id = p_pricelist_id
  AND    l.editable_flag <> 'D';

  l_lanes          STRINGARRAY;
  i                NUMBER;

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.CHECK_LANES';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List Header ID', p_pricelist_id);
    END IF;

    x_status := -1;

    OPEN lane_number;
    FETCH lane_number BULK COLLECT INTO l_lanes;
    i := lane_number%ROWCOUNT;
    CLOSE lane_number;

    IF ( i > 0 ) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_RC_ASSIGNED_TO_LN');
      FOR j IN 1..l_lanes.COUNT LOOP
	x_error_msg := x_error_msg ||' '|| FTE_UTIL_PKG.GET_MSG('FTE_LANE_NUMBER') || ' '|| l_lanes(j);
      END LOOP;
      x_status := 2;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	         		 p_msg   	=> x_error_msg,
	         		 p_category    => 'F');

    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION WHEN OTHERS THEN
    IF (lane_number%ISOPEN) THEN
      CLOSE lane_number;
    END IF;
    x_error_msg := sqlerrm;
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
               		       p_msg   		=> x_error_msg,
               		       p_category       => 'O');
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    x_status := 2;
  END Check_Lanes;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_LANE_COMMODITY_ID
  --
  -- Purpose: get the next squence number for commodity
  --
  -- Returns lane commodity sequence
  ---------------------------------------------------------------------------
  FUNCTION GET_NEXT_LANE_COMMODITY_ID RETURN NUMBER IS
  l_id	NUMBER := -1;
  BEGIN
    SELECT fte_lane_commodities_s.nextval
      INTO l_id
      FROM dual;
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_NEXT_LANE_COMMODITY_ID;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_LANE_SERVICE_ID
  --
  -- Purpose: get the next squence number for service
  --
  -- Returns lane service squence
  ---------------------------------------------------------------------------
  FUNCTION GET_NEXT_LANE_SERVICE_ID RETURN NUMBER IS
  l_id	NUMBER := -1;
  BEGIN
    SELECT fte_lane_services_s.nextval
      INTO l_id
      FROM dual;
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_NEXT_LANE_SERVICE_ID;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_NEXT_LANE_ID
  --
  -- Purpose: get the next lane squence number
  --
  -- Returns lane squence
  ---------------------------------------------------------------------------
  FUNCTION GET_NEXT_LANE_ID RETURN NUMBER IS
  l_id	NUMBER := -1;
  BEGIN
    SELECT fte_lanes_s.nextval
      INTO l_id
      FROM dual;
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_NEXT_LANE_ID;

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
				   x_error_msg	OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VERIFY_OVERLAPPING_DATE';
  l_number_of_chart       NUMBER;
  l_start_date_active     DATE;
  l_end_date_active       DATE;

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate Chart Name', p_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane ID', p_lane_id);
    END IF;

    x_status := -1;

    BEGIN
      SELECT lb.start_date_active, lb.end_date_active
      INTO   l_start_date_active, l_end_date_active
      FROM   qp_list_headers_tl ll, qp_list_headers_b lb
      WHERE  ll.list_header_id = lb.list_header_id
      AND    ll.name = p_name
      AND    ll.language = userenv('LANG');

      IF (l_start_date_active IS NULL AND l_end_date_active IS NULL) THEN
	SELECT count(list_header_id)
	  INTO l_number_of_chart
	  FROM fte_lane_rate_charts
	 WHERE lane_id = p_lane_id;

        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

	IF (l_number_of_chart = 0) THEN
          RETURN false;
	ELSE
	  RETURN true;
	END IF;
      END IF;

      IF (l_start_date_active IS NULL) THEN
        SELECT count(list_header_id)
        INTO   l_number_of_chart
        FROM   fte_lane_rate_charts
        WHERE  lane_id = p_lane_id
        AND    ((nvl(start_date_active, l_end_date_active) <= l_end_date_active));
      ELSIF (l_end_date_active IS NULL) THEN
        SELECT count(list_header_id)
        INTO   l_number_of_chart
        FROM   fte_lane_rate_charts
        WHERE  lane_id = p_lane_id
        AND    ((nvl(end_date_active, l_start_date_active) >= l_start_date_active));
      ELSE
        SELECT count(list_header_id)
        INTO   l_number_of_chart
        FROM   fte_lane_rate_charts
        WHERE  lane_id = p_lane_id
        AND    ((nvl(start_date_active, l_start_date_active) <= l_start_date_active AND nvl(end_date_active, l_end_date_active) >= l_start_date_active)
        OR      (nvl(start_date_active, l_start_date_active) <= l_end_date_active AND nvl(end_date_active, l_end_date_active) >= l_end_date_active)
        OR      (nvl(end_date_active, l_start_date_active) >= l_start_date_active AND nvl(start_date_active, l_end_date_active) <= l_end_date_active));
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN false;
      WHEN OTHERS THEN
        x_error_msg := sqlerrm;
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
				   p_msg	=> x_error_msg,
				   p_category    => '0');
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
        RETURN FALSE;
    END;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Query result', l_number_of_chart);
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

    IF (l_number_of_chart = 0) THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN FALSE;
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
				 p_msg	=> x_error_msg,
				 p_category    => '0');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN FALSE;
  END VERIFY_OVERLAPPING_DATE;

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
		     x_error_msg	OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  l_result 	VARCHAR2(10);
  l_numfetch	NUMBER;
  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.FIND_TYPE';
  CURSOR GET_SERVICE (p_lane_id IN NUMBER, p_value IN VARCHAR2) IS
      SELECT 'true'
        FROM fte_lane_services
       WHERE service_code = p_value
	 AND lane_id = p_lane_id;

  CURSOR GET_COMMODITY (p_lane_id IN NUMBER, p_value IN VARCHAR2) IS
      SELECT 'true'
    	FROM fte_lane_commodities
       WHERE commodity_catg_id = TO_NUMBER(p_value)
	 AND lane_id = p_lane_id;

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value', p_value);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane ID', p_lane_id);
    END IF;

    x_status := -1;

    IF (p_type = 'SERVICE_LEVEL') THEN
      OPEN GET_SERVICE(p_lane_id, p_value);
      FETCH GET_SERVICE INTO l_result;
      l_numfetch := SQL%ROWCOUNT;
      CLOSE GET_SERVICE;
    ELSIF (p_type = 'COMMODITY') THEN
      OPEN GET_COMMODITY(p_lane_id, p_value);
      FETCH GET_COMMODITY INTO l_result;
      l_numfetch := SQL%ROWCOUNT;
      CLOSE GET_COMMODITY;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

    IF (l_numfetch = 0) THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_SERVICE%ISOPEN) THEN
	CLOSE GET_SERVICE;
      END IF;
      IF (GET_COMMODITY%ISOPEN) THEN
	CLOSE GET_COMMODITY;
      END IF;

      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
				 p_msg		=> x_error_msg,
				 p_category     => '0',
				 p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN FALSE;
  END FIND_TYPE;

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
		       		x_error_msg  	OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.CHECK_EXISTING_LOAD';
  l_result 	NUMBER;
  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'ID', p_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Table', p_table);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Code', p_code);
    END IF;

    x_status := -1;

    IF (p_table = 'FTE_LANE_RATE_CHARTS') THEN
      SELECT count(lane_id)
	INTO l_result
	FROM fte_lane_rate_charts
       WHERE lane_id = p_id
	 AND list_header_id = TO_NUMBER(p_code);
    ELSIF (p_table = 'FTE_LANE_COMMODITIES') THEN
      SELECT count(lane_id)
	INTO l_result
	FROM fte_lane_commodities
       WHERE lane_id = p_id
	 AND commodity_catg_id = TO_NUMBER(p_code);
    ELSIF (p_table = 'FTE_LANE_SERVICES') THEN
      SELECT count(lane_id)
	INTO l_result
	FROM fte_lane_services
       WHERE lane_id = p_id
	 AND service_code = p_code;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    IF (l_result > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN FALSE;
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
				 p_msg   	=> x_error_msg,
				 p_category    => '0',
				 p_line_number => p_line_number);
      x_status := 2;
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN TRUE;
  END CHECK_EXISTING_LOAD;

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
		       x_error_msg  OUT NOCOPY	VARCHAR2) IS
  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.DELETE_ROW';
  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'ID', p_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Table', p_table);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Code', p_code);
    END IF;

    x_status := -1;

    IF (p_table = 'FTE_LANE_RATE_CHARTS') THEN
      DELETE from fte_lane_rate_charts
       WHERE lane_id = p_id
	 AND list_header_id = TO_NUMBER(p_code);
    ELSIF (p_table = 'FTE_LANE_COMMODITIES') THEN
      DELETE from fte_lane_commodities
       WHERE lane_id = p_id
	 AND commodity_catg_id = TO_NUMBER(p_code);
    ELSIF (p_table = 'FTE_LANE_SERVICES') THEN
      DELETE from fte_lane_services
       WHERE lane_id = p_id
	 AND service_code = p_code;
    ELSIF (p_table = 'FTE_LANES') THEN
      UPDATE fte_lanes
	 SET editable_flag = 'D',
             lane_number = p_id || '-DELETED by USER',  -- might just leave the lane number as it
	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
       WHERE lane_id = p_id;
    ELSIF (p_table = 'FTE_PRC_PARAMETERS') THEN
      IF (p_code IS NULL) THEN
        DELETE from fte_prc_parameters
         WHERE parameter_instance_id = p_id;
      ELSE
        DELETE from fte_prc_parameters
         WHERE lane_id = p_id
	   AND parameter_id = TO_NUMBER(p_code);
      END IF;
    ELSIF (p_table = 'FTE_SCHEDULES') THEN

      UPDATE FTE_SCHEDULES
         SET EDITABLE_FLAG = 'D',
	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
       WHERE SCHEDULES_ID = p_id
         AND NVL(EDITABLE_FLAG,'Y') = 'Y';
    ELSE
      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_INVALID_TABLE');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	         		 p_msg   	=> x_error_msg,
	         		 p_category    => 'O',
				 p_line_number	=> p_line_number);

      x_status := 1;
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
				 p_msg   	=> x_error_msg,
				 p_category    => '0',
				 p_line_number	=> p_line_number);
      x_status := 2;
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
  END DELETE_ROW;

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
			      x_error_msg OUT NOCOPY	VARCHAR2) IS

  l_return 	STRINGARRAY := STRINGARRAY();
  l_flag	VARCHAR2(1) := 'N';
  l_code	VARCHAR2(100);
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.UPDATE_LANE_FLAGS';
  CURSOR Get_Commodity_Type (p_lane_id 	IN	NUMBER)
  IS
    SELECT TO_CHAR(commodity_catg_id)
      FROM fte_lane_commodities
     WHERE lane_id = p_lane_id;

  CURSOR Get_Service_Code (p_lane_id 	IN	NUMBER)
  IS
    SELECT service_code
      FROM fte_lane_services
     WHERE lane_id = p_lane_id;

  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane ID', p_lane_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value', p_value);
    END IF;

    x_status := -1;

    IF (p_type = 'SERVICE_LEVEL') THEN
      OPEN Get_Service_Code(p_lane_id => p_lane_id);
      FETCH Get_Service_Code
      BULK COLLECT INTO l_return;
      CLOSE Get_Service_Code;
    ELSIF (p_type = 'COMMODITY_TYPE') THEN
      OPEN Get_Commodity_Type(p_lane_id => p_lane_id);
      FETCH Get_Commodity_Type
      BULK COLLECT INTO l_return;
      CLOSE Get_Commodity_Type;
    ELSIF (p_type <> 'SCHEDULE') THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_INVALID_TYPE');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name  => l_module_name,
	         		 p_msg		=> x_error_msg,
	         		 p_category     => 'O');

      x_status := 1;
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (l_return.COUNT = 1) THEN
      l_flag := 'Y';
      l_code := l_return(1);
    ELSIF (l_return.COUNT > 1) THEN
      l_flag := 'Y';
    END IF;

    IF (p_type = 'SERVICE_LEVEL') THEN
      UPDATE fte_lanes
	 SET service_type_code = l_code,
	     service_detail_flag = l_flag,
	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
       WHERE lane_id = p_lane_id;
    ELSIF (p_type = 'COMMODITY_TYPE') THEN
      UPDATE fte_lanes
	 SET commodity_catg_id = TO_NUMBER(l_code),
 	     commodity_detail_flag = l_flag,
	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
       WHERE lane_id = p_lane_id;
    ELSE -- schedule
      UPDATE fte_lanes
	 SET schedules_flag = p_value,
	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
       WHERE lane_id = p_lane_id;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_SERVICE_CODE%ISOPEN) THEN
	CLOSE GET_SERVICE_CODE;
      END IF;
      IF (GET_COMMODITY_TYPE%ISOPEN) THEN
	CLOSE GET_COMMODITY_TYPE;
      END IF;
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		 p_msg   	=> x_error_msg,
	               		 p_category    => 'O');
      x_status := 1;
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
  END UPDATE_LANE_FLAGS;

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
			     x_error_msg		OUT NOCOPY VARCHAR2) IS

  l_vessel_name	 	VESSEL_NAME_TBL;
  l_vessel_type 	VESSEL_TYPE_TBL;
  l_voyage_number 	VOYAGE_NUMBER_TBL;
  l_arrival_date_ind	ARRIVAL_DATE_INDICATOR_TBL;
  l_transit_time	SCH_TRANSIT_TIME_TBL;
  l_port_of_loading	PORT_OF_LOADING_TBL;
  l_port_of_discharge	PORT_OF_DISCHARGE_TBL;
  l_frequency_type 	FREQUENCY_TYPE_TBL;
  l_frequency		FREQUENCY_TBL;
  l_frequency_arrival	FREQUENCY_ARRIVAL_TBL;
  l_departure_time	DEPARTURE_TIME_TBL;
  l_arrival_time	ARRIVAL_TIME_TBL;
  l_departure_date	DEPARTURE_DATE_TBL;
  l_arrival_date	ARRIVAL_DATE_TBL;
  l_effective_date 	SCH_EFFECTIVE_DATE_TBL;
  l_expiry_date	 	SCH_EXPIRY_DATE_TBL;
  l_transit_time_uom	SCH_TRANSIT_TIME_UOM_TBL;
  l_lane_id		SCH_LANE_ID_TBL;
  l_schedules_id	SCHEDULES_ID_TBL;
  l_lane_number		SCH_LANE_NUMBER_TBL;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.INSERT_SCHEDULES';

  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of Schedules', p_schedule_tbl.COUNT);
    END IF;

    x_status := -1;

    IF (p_schedule_tbl.COUNT > 0) THEN
      FOR i in p_schedule_tbl.FIRST..p_schedule_tbl.LAST LOOP
        l_vessel_name(i) 	:=	p_schedule_tbl(i).vessel_name;
        l_vessel_type(i) 	:=	p_schedule_tbl(i).vessel_type;
        l_voyage_number(i) 	:=	p_schedule_tbl(i).voyage_number;
        l_arrival_date_ind(i) 	:=	p_schedule_tbl(i).arrival_date_indicator;
        l_transit_time(i) 	:=	p_schedule_tbl(i).transit_time;
        l_port_of_loading(i) 	:=	p_schedule_tbl(i).port_of_loading;
        l_port_of_discharge(i) 	:=	p_schedule_tbl(i).port_of_discharge;
        l_frequency_type(i) 	:=	p_schedule_tbl(i).frequency_type;
        l_frequency(i) 		:=	p_schedule_tbl(i).frequency;
        l_frequency_arrival(i) 	:=	p_schedule_tbl(i).frequency_arrival;
        l_departure_time(i) 	:=	p_schedule_tbl(i).departure_time;
        l_arrival_time(i) 	:=	p_schedule_tbl(i).arrival_time;
        l_departure_date(i) 	:=	p_schedule_tbl(i).departure_date;
        l_arrival_date(i) 	:=	p_schedule_tbl(i).arrival_date;
        l_effective_date(i) 	:=	p_schedule_tbl(i).effective_date;
        l_expiry_date(i) 	:=	p_schedule_tbl(i).expiry_date;
        l_transit_time_uom(i) 	:=	p_schedule_tbl(i).transit_time_uom;
        l_lane_id(i) 		:=	p_schedule_tbl(i).lane_id;
        l_schedules_id(i) 	:=	p_schedule_tbl(i).schedules_id;
        l_lane_number(i)	:= 	p_schedule_tbl(i).lane_number;
      END LOOP;

      BEGIN
        FORALL i in p_schedule_tbl.FIRST..p_schedule_tbl.LAST
          INSERT INTO FTE_SCHEDULES(LANE_ID,
	  			    SCHEDULES_ID,
				    VESSEL_NAME,
				    VESSEL_TYPE,
				    VOYAGE_NUMBER,
				    ARRIVAL_DATE_INDICATOR,
				    TRANSIT_TIME,
				    PORT_OF_LOADING,
				    PORT_OF_DISCHARGE,
				    FREQUENCY_TYPE,
				    FREQUENCY,
				    FREQUENCY_ARRIVAL,
				    DEPARTURE_TIME,
				    ARRIVAL_TIME,
				    DEPARTURE_DATE,
				    ARRIVAL_DATE,
				    EFFECTIVE_DATE,
				    EXPIRY_DATE,
				    TRANSIT_TIME_UOM,
				    LANE_NUMBER,
		       		    CREATED_BY,
			    	    CREATION_DATE,
			     	    LAST_UPDATED_BY,
		 		    LAST_UPDATE_DATE,
		     		    LAST_UPDATE_LOGIN)
                            VALUES (l_lane_id(i),
		     		    l_schedules_id(i),
		     		    l_vessel_name(i),
		     		    l_vessel_type(i),
				    l_voyage_number(i),
				    l_arrival_date_ind(i),
				    l_transit_time(i),
 				    l_port_of_loading(i),
				    l_port_of_discharge(i),
				    l_frequency_type(i),
				    l_frequency(i),
				    l_frequency_arrival(i),
				    l_departure_time(i),
				    l_arrival_time(i),
				    l_departure_date(i),
				    l_arrival_date(i),
				    l_effective_date(i),
				    l_expiry_date(i),
				    l_transit_time_uom(i),
				    l_lane_number(i),
				    FND_GLOBAL.USER_ID,
		     		    SYSDATE,
		     		    FND_GLOBAL.USER_ID,
		    		    SYSDATE,
		     		    FND_GLOBAL.USER_ID);

	--+
        -- For Generating Output file
        --+

        FOR i in l_voyage_number.FIRST..l_voyage_number.LAST LOOP

            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
		                       p_msg	     => l_voyage_number(i),
			               p_category    => NULL);
        END LOOP;

      END;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		 p_msg   	=> x_error_msg,
	               		 p_category    => 'O');
      x_status := 1;
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
  END INSERT_SCHEDULES;


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
			       x_status			OUT NOCOPY NUMBER,
			       x_error_msg		OUT NOCOPY VARCHAR2) IS

  l_lane_id 		LANE_ID_TBL;
  l_lane_number		LANE_NUMBER_TBL;
  l_carrier_id		CARRIER_ID_TBL;
  l_origin_id		ORIGIN_ID_TBL;
  l_dest_id		DESTINATION_ID_TBL;
  l_mode_of_trans	MODE_OF_TRANS_TBL;
  l_transit_time	TRANSIT_TIME_TBL;
  l_transit_time_uom	TRANSIT_TIME_UOM_TBL;
  l_special_handling	SPECIAL_HANDLING_TBL;
  l_additional_instructions	ADDITIONAL_INSTRUCTIONS_TBL;
  l_comm_fc_class_code	COMM_FC_CLASS_TBL;
  l_comm_catg_id	COMM_CATG_ID_TBL;
  l_equip_type_code	EQUIP_TYPE_CODE_TBL;
  l_service_type_code	SERVICE_TYPE_CODE_TBL;
  l_distance		DISTANCE_TBL;
  l_distance_uom	DISTANCE_UOM_TBL;
  l_pricelist_view_flag	PRICELIST_VIEW_FLAG_TBL;
  l_basis		BASIS_TBL;
  l_effective_date	EFFECTIVE_DATE_TBL;
  l_expiry_date		EXPIRY_DATE_TBL;
  l_editable_flag	EDITABLE_FLAG_TBL;
  l_lane_type		LANE_TYPE_TBL;
  l_tariff_name		TARIFF_NAME_TBL;

  l_lrc_lane_id		LANE_ID_TBL;
  l_list_header_id	LIST_HEADER_ID_TBL;
  l_start_date_active	START_DATE_ACTIVE_TBL;
  l_end_date_active	END_DATE_ACTIVE_TBL;

  l_lc_lane_id		LANE_ID_TBL;
  l_lane_commodity_id	LANE_COMMODITY_ID_TBL;
  l_lc_basis		BASIS_TBL;
  l_lc_comm_catg_id	COMM_CATG_ID_TBL;

  l_ls_lane_id		LANE_ID_TBL;
  l_lane_service_id	LANE_SERVICE_ID_TBL;
  l_service_code	SERVICE_TYPE_CODE_TBL;
  l_count		NUMBER;
  l_lane_id_number	NUMBER;
  l_update		BOOLEAN := FALSE;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.INSERT_LANE_TABLES';

  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of Lanes', p_lane_tbl.COUNT);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of Lane rate charts', p_lane_rate_chart_tbl.COUNT);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of Lane commodities', p_lane_commodity_tbl.COUNT);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of Lane services', p_lane_service_tbl.COUNT);
    END IF;

    x_status := -1;

    IF (p_lane_tbl.COUNT > 0) THEN
      FOR i in p_lane_tbl.FIRST..p_lane_tbl.LAST LOOP
        IF (p_lane_tbl(i).action = 'UPDATE') THEN
	  l_update := TRUE;
          UPDATE FTE_LANES
	     SET COMM_FC_CLASS_CODE = p_lane_tbl(i).comm_fc_class_code,
		 ORIGIN_ID = nvl(p_lane_tbl(i).origin_id, ORIGIN_ID),
		 DESTINATION_ID = nvl(p_lane_tbl(i).destination_id, DESTINATION_ID),
		 LANE_TYPE = nvl(p_lane_tbl(i).lane_type, lane_type),
	         PRICELIST_VIEW_FLAG = p_lane_tbl(i).pricelist_view_flag,
	         BASIS = p_lane_tbl(i).basis,
	         EFFECTIVE_DATE = p_lane_tbl(i).effective_date,
	         EXPIRY_DATE = p_lane_tbl(i).expiry_date,
	         LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	         LAST_UPDATE_DATE = sysdate,
	         LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
  	   WHERE lane_id = p_lane_tbl(i).lane_id;
   	  p_lane_tbl.DELETE(i);
        ELSIF (p_lane_tbl(i).action = 'DELETE') THEN
	  p_lane_tbl.DELETE(i);
        ELSE
  	  l_count := l_lane_id.COUNT+1;
	  l_lane_id(l_count) 		:= p_lane_tbl(i).lane_id;
	  l_lane_number(l_count) 	:= p_lane_tbl(i).lane_number;
  	  l_carrier_id(l_count)		:= p_lane_tbl(i).carrier_id;
	  l_origin_id(l_count)		:= p_lane_tbl(i).origin_id;
	  l_dest_id(l_count)		:= p_lane_tbl(i).destination_id;
	  l_mode_of_trans(l_count)	:= p_lane_tbl(i).mode_of_transportation_code;
	  l_transit_time(l_count)	:= p_lane_tbl(i).transit_time;
	  l_transit_time_uom(l_count)	:= p_lane_tbl(i).transit_time_uom;
	  l_special_handling(l_count)	:= p_lane_tbl(i).special_handling;
	  l_additional_instructions(l_count) := p_lane_tbl(i).additional_instructions;
	  l_comm_fc_class_code(l_count)	:= p_lane_tbl(i).comm_fc_class_code;
	  l_comm_catg_id(l_count)	:= p_lane_tbl(i).commodity_catg_id;
	  l_equip_type_code(l_count)	:= p_lane_tbl(i).equipment_type_code;
	  l_service_type_code(l_count)	:= p_lane_tbl(i).service_type_code;
	  l_distance(l_count)		:= p_lane_tbl(i).distance;
	  l_distance_uom(l_count)	:= p_lane_tbl(i).distance_uom;
	  l_pricelist_view_flag(l_count):= p_lane_tbl(i).pricelist_view_flag;
	  l_basis(l_count)		:= p_lane_tbl(i).basis;
	  l_effective_date(l_count)	:= p_lane_tbl(i).effective_date;
	  l_expiry_date(l_count)	:= p_lane_tbl(i).expiry_date;
	  l_editable_flag(l_count)	:= p_lane_tbl(i).editable_flag;
	  l_lane_type(l_count)		:= p_lane_tbl(i).lane_type;
	  l_tariff_name(l_count)	:= p_lane_tbl(i).tariff_name;
        END IF;
      END LOOP;

      IF (NOT l_update) THEN
        BEGIN
          FORALL i in l_lane_id.FIRST..l_lane_id.LAST
            INSERT INTO FTE_LANES (LANE_ID,
	  		           LANE_NUMBER,
		 	           OWNER_ID,
			           CARRIER_ID,
			           ORIGIN_ID,
   			           DESTINATION_ID,
 			           MODE_OF_TRANSPORTATION_CODE,
			           TRANSIT_TIME,
			           TRANSIT_TIME_UOM,
		 	           SPECIAL_HANDLING,
			           ADDITIONAL_INSTRUCTIONS,
			           COMMODITY_DETAIL_FLAG,
			           EQUIPMENT_DETAIL_FLAG,
			           SERVICE_DETAIL_FLAG,
			           COMM_FC_CLASS_CODE,
			           COMMODITY_CATG_ID,
			           EQUIPMENT_TYPE_CODE,
			           SERVICE_TYPE_CODE,
			           DISTANCE,
		 	           DISTANCE_UOM,
			           SCHEDULES_FLAG,
			           PRICELIST_VIEW_FLAG,
			           BASIS,
			           EFFECTIVE_DATE,
		 	           EXPIRY_DATE,
			           EDITABLE_FLAG,
			           CREATED_BY,
			           CREATION_DATE,
			           LAST_UPDATED_BY,
			           LAST_UPDATE_DATE,
			           LAST_UPDATE_LOGIN,
			           LANE_TYPE,
			           TARIFF_NAME)
                           VALUES (l_lane_id(i),
			           l_lane_number(i),
			           -1,
			           l_carrier_id(i),
			           l_origin_id(i),
			           l_dest_id(i),
			           l_mode_of_trans(i),
			           l_transit_time(i),
			           l_transit_time_uom(i),
			           l_special_handling(i),
			           l_additional_instructions(i),
			           'N',
			           'N',
			           'N',
			           l_comm_fc_class_code(i),
			           l_comm_catg_id(i),
			           l_equip_type_code(i),
	 		           l_service_type_code(i),
			           l_distance(i),
			           l_distance_uom(i),
			           'N',
			           l_pricelist_view_flag(i),
			           l_basis(i),
			           l_effective_date(i),
			           l_expiry_date(i),
			           l_editable_flag(i),
			           FND_GLOBAL.USER_ID,
			           SYSDATE,
			           FND_GLOBAL.USER_ID,
			           SYSDATE,
			           FND_GLOBAL.USER_ID,
			           l_lane_type(i),
			           l_tariff_name(i));
        EXCEPTION
          WHEN OTHERS THEN
	    x_error_msg := sqlerrm;
	    FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting lanes]');
	    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		       p_msg  	      => x_error_msg,
	               		       p_category    => 'O');
            x_status := 1;
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	    p_lane_tbl.DELETE;
	    p_lane_rate_chart_tbl.DELETE;
	    p_lane_commodity_tbl.DELETE;
	    p_lane_service_tbl.DELETE;
            RETURN;
        END; -- FINISH INSERTING lanes

        --+
        -- For Generating Output file
        --+
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
			           p_msg_name	 => 'FTE_LANES_LOADED',
			           p_category	 => NULL);

        FOR i in l_lane_number.FIRST..l_lane_number.LAST LOOP

            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
		                       p_msg	     => l_lane_number(i),
			               p_category    => NULL);

        END LOOP;

      END IF;
    END IF;

    IF (p_lane_rate_chart_tbl.COUNT > 0) THEN
      FOR i in p_lane_rate_chart_tbl.FIRST..p_lane_rate_chart_tbl.LAST LOOP
        l_lrc_lane_id(i) := p_lane_rate_chart_tbl(i).lane_id;
        l_list_header_id(i) := p_lane_rate_chart_tbl(i).list_header_id;
        l_end_date_active(i) := p_lane_rate_chart_tbl(i).end_date_active;
        l_start_date_active(i) := p_lane_rate_chart_tbl(i).start_date_active;
      END LOOP;

      BEGIN
        FORALL i in p_lane_rate_chart_tbl.FIRST..p_lane_rate_chart_tbl.LAST
          INSERT INTO FTE_LANE_RATE_CHARTS (LANE_ID,
	  			   	    LIST_HEADER_ID,
		 			    END_DATE_ACTIVE,
					    START_DATE_ACTIVE,
			       		    CREATED_BY,
			    		    CREATION_DATE,
			     		    LAST_UPDATED_BY,
			     		    LAST_UPDATE_DATE,
			     		    LAST_UPDATE_LOGIN)
                       		    VALUES (l_lrc_lane_id(i),
			     		    l_list_header_id(i),
			     		    l_end_date_active(i),
			     		    l_start_date_active(i),
			     		    FND_GLOBAL.USER_ID,
			     		    SYSDATE,
			     		    FND_GLOBAL.USER_ID,
			     		    SYSDATE,
			     		    FND_GLOBAL.USER_ID);
          --+
          -- Remove the hold from fte_lanes
          -- for these rate charts.
          --+
       IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
             FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Updating lane_type of fte_lanes... ');
       END IF;
       FORALL i in l_lrc_lane_id.FIRST..l_lrc_lane_id.LAST
          UPDATE fte_lanes
          SET lane_type = NULL,
              LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
          WHERE lane_id = l_lrc_lane_id(i);

      EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	  x_status := -1;
        WHEN OTHERS THEN
	  x_error_msg := sqlerrm;
  	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting lane rate charts]');
	  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	                 	     p_msg   	    => x_error_msg,
	                 	     p_category    => 'O');
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  p_lane_tbl.DELETE;
	  p_lane_rate_chart_tbl.DELETE;
	  p_lane_commodity_tbl.DELETE;
	  p_lane_service_tbl.DELETE;
	  x_status := 1;
	  RETURN;
      END; --FINISH INSERTING lane rate charts
    END IF;

    IF (p_lane_commodity_tbl.COUNT > 0) THEN
      FOR i in p_lane_commodity_tbl.FIRST..p_lane_commodity_tbl.LAST LOOP
        l_lc_lane_id(i) := p_lane_commodity_tbl(i).lane_id;
        l_lane_commodity_id(i) := p_lane_commodity_tbl(i).lane_commodity_id;
        l_lc_basis(i) := p_lane_commodity_tbl(i).basis;
        l_lc_comm_catg_id(i) := p_lane_commodity_tbl(i).commodity_catg_id;
      END LOOP;

      BEGIN
        FORALL i in p_lane_commodity_tbl.FIRST..p_lane_commodity_tbl.LAST
          INSERT INTO FTE_LANE_COMMODITIES (LANE_ID,
				 	    LANE_COMMODITY_ID,
					    BASIS,
					    COMMODITY_CATG_ID,
			       		    CREATED_BY,
			    		    CREATION_DATE,
			     		    LAST_UPDATED_BY,
			     		    LAST_UPDATE_DATE,
			     		    LAST_UPDATE_LOGIN)
                       		    VALUES (l_lc_lane_id(i),
			     		    l_lane_commodity_id(i),
			     		    l_lc_basis(i),
			     		    l_lc_comm_catg_id(i),
			     		    FND_GLOBAL.USER_ID,
			     		    SYSDATE,
			     		    FND_GLOBAL.USER_ID,
			     		    SYSDATE,
			     		    FND_GLOBAL.USER_ID);
      EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	  x_status := -1;
        WHEN OTHERS THEN
	  x_error_msg := sqlerrm;
  	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting lane commodities]');
	  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	                 	     p_msg   	    => x_error_msg,
	                 	     p_category    => 'O');
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  p_lane_tbl.DELETE;
	  p_lane_rate_chart_tbl.DELETE;
	  p_lane_commodity_tbl.DELETE;
	  p_lane_service_tbl.DELETE;
	  x_status := 1;
	  RETURN;
      END; --FINISH INSERTING lane commodities
    END IF;

    IF (p_lane_service_tbl.COUNT > 0) THEN
      FOR i in p_lane_service_tbl.FIRST..p_lane_service_tbl.LAST LOOP
        l_ls_lane_id(i) := p_lane_service_tbl(i).lane_id;
        l_lane_service_id(i) := p_lane_service_tbl(i).lane_service_id;
        l_service_code(i) := p_lane_service_tbl(i).service_code;
      END LOOP;

      BEGIN
        FORALL i in p_lane_service_tbl.FIRST..p_lane_service_tbl.LAST
          INSERT INTO FTE_LANE_SERVICES (LANE_ID,
	 			         LANE_SERVICE_ID,
				         SERVICE_CODE,
			       	         CREATED_BY,
			    	         CREATION_DATE,
			     	         LAST_UPDATED_BY,
			     	         LAST_UPDATE_DATE,
			     	         LAST_UPDATE_LOGIN)
                       	         VALUES (l_ls_lane_id(i),
			                 l_lane_service_id(i),
			     	         l_service_code(i),
			     	         FND_GLOBAL.USER_ID,
			     	         SYSDATE,
			     	         FND_GLOBAL.USER_ID,
			     	         SYSDATE,
			     	         FND_GLOBAL.USER_ID);
      EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	  x_status := -1;
        WHEN OTHERS THEN
	  x_error_msg := sqlerrm;
  	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting lane services]');
	  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	                 	     p_msg   	    => x_error_msg,
	                 	     p_category    => 'O');
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  p_lane_tbl.DELETE;
	  p_lane_rate_chart_tbl.DELETE;
	  p_lane_commodity_tbl.DELETE;
	  p_lane_service_tbl.DELETE;
	  x_status := 1;
	  RETURN;
      END; --FINISH INSERTING lane services
    END IF;

    IF (p_lane_tbl.COUNT > 0) THEN
      FOR i in p_lane_tbl.FIRST..p_lane_tbl.LAST LOOP
        -- update the service detail flag after add
        UPDATE_LANE_FLAGS(p_type	=> 'SERVICE_LEVEL',
	 		  p_lane_id	=> p_lane_tbl(i).lane_id,
			  x_status	=> x_status,
			  x_error_msg 	=> x_error_msg);
        -- update the commodity detail flag after add
        UPDATE_LANE_FLAGS(p_type	=> 'COMMODITY_TYPE',
			  p_lane_id	=> p_lane_tbl(i).lane_id,
			  x_status	=> x_status,
			  x_error_msg 	=> x_error_msg);
      END LOOP;
    END IF;

    p_lane_tbl.DELETE;
    p_lane_rate_chart_tbl.DELETE;
    p_lane_commodity_tbl.DELETE;
    p_lane_service_tbl.DELETE;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	                    	 p_msg   	=> x_error_msg,
	                 	 p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      p_lane_tbl.DELETE;
      p_lane_rate_chart_tbl.DELETE;
      p_lane_commodity_tbl.DELETE;
      p_lane_service_tbl.DELETE;
      RETURN;
  END INSERT_LANE_TABLES;

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
			     	  x_error_msg		OUT NOCOPY VARCHAR2) IS

  l_value_from			VALUE_FROM_TBL;
  l_value_to			VALUE_TO_TBL;
  l_uom_code			UOM_CODE_TBL;
  l_currency_code		CURRENCY_CODE_TBL;
  l_parameter_instance_id	PARAMETER_INS_ID_TBL;
  l_lane_id			PRC_LANE_ID_TBL;
  l_parameter_id		PARAMETER_ID_TBL;


  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.INSERT_PRC_PARAMETERS';

  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of pricing parameters', p_prc_parameter_tbl.COUNT);
    END IF;

    x_status := -1;

    IF (p_prc_parameter_tbl.COUNT > 0) THEN
      FOR i in p_prc_parameter_tbl.FIRST..p_prc_parameter_tbl.LAST LOOP
        l_value_from(i) 	:=	p_prc_parameter_tbl(i).value_from;
        l_value_to(i) 		:=	p_prc_parameter_tbl(i).value_to;
        l_uom_code(i)	 	:=	p_prc_parameter_tbl(i).uom_code;
        l_currency_code(i) 	:=	p_prc_parameter_tbl(i).currency_code;
        l_parameter_instance_id(i) :=	p_prc_parameter_tbl(i).parameter_instance_id;
        l_lane_id(i)	 	:=	p_prc_parameter_tbl(i).lane_id;
        l_parameter_id(i) 	:=	p_prc_parameter_tbl(i).parameter_id;
      END LOOP;

      BEGIN
        FORALL i in p_prc_parameter_tbl.FIRST..p_prc_parameter_tbl.LAST
          INSERT INTO FTE_PRC_PARAMETERS (LANE_ID,
	 			       	  PARAMETER_ID,
				       	  PARAMETER_INSTANCE_ID,
				       	  VALUE_FROM,
				       	  VALUE_TO,
				       	  UOM_CODE,
  				       	  CURRENCY_CODE,
		       		       	  CREATED_BY,
			    	       	  CREATION_DATE,
			     	       	  LAST_UPDATED_BY,
		 		       	  LAST_UPDATE_DATE,
		     		       	  LAST_UPDATE_LOGIN)
                       	  	  VALUES (l_lane_id(i),
		     		  	  l_parameter_id(i),
					  l_parameter_instance_id(i),
					  l_value_from(i),
					  l_value_to(i),
					  l_uom_code(i),
					  l_currency_code(i),
				  	  FND_GLOBAL.USER_ID,
		     		  	  SYSDATE,
		     		  	  FND_GLOBAL.USER_ID,
		    		  	  SYSDATE,
		     		  	  FND_GLOBAL.USER_ID);

      END;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		 p_msg   	=> x_error_msg,
	               		 p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END INSERT_PRC_PARAMETERS;

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
				    x_error_msg		OUT NOCOPY VARCHAR2)IS
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.UPDATE_LANE_RATE_CHART';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List Header ID', p_list_header_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Start Date', p_start_date);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'End Date', p_end_date);
    END IF;

    x_status := -1;

    UPDATE fte_lane_rate_charts
       SET START_DATE_ACTIVE = p_start_date,
           END_DATE_ACTIVE = p_end_date,
	   LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	   LAST_UPDATE_DATE = sysdate,
	   LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
     WHERE LIST_HEADER_ID = p_list_header_id;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		 p_msg   	=> x_error_msg,
	               		 p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END UPDATE_LANE_RATE_CHART;

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
				  x_error_msg		OUT NOCOPY VARCHAR2)IS

  l_value_from	fte_prc_parameters.value_from%TYPE;
  l_value_to	fte_prc_parameters.value_to%TYPE;
  l_uom_code	fte_prc_parameters.uom_code%TYPE;
  l_currency_code fte_prc_parameters.currency_code%TYPE;
  l_parameter_instance_id fte_prc_parameters.parameter_instance_id%TYPE;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.UPDATE_PRC_PARAMETERS';

  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    l_value_from := p_prc_parameter_tbl(p_prc_parameter_tbl.COUNT).value_from;
    l_value_to   := p_prc_parameter_tbl(p_prc_parameter_tbl.COUNT).value_to;
    l_uom_code   := p_prc_parameter_tbl(p_prc_parameter_tbl.COUNT).uom_code;
    l_currency_code := p_prc_parameter_tbl(p_prc_parameter_tbl.COUNT).currency_code;
    l_parameter_instance_id := p_prc_parameter_tbl(p_prc_parameter_tbl.COUNT).parameter_instance_id;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value from', l_value_from);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value to', l_value_to);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Uom code', l_uom_code);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currecy code', l_currency_code);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Parameter code', l_parameter_instance_id);
    END IF;

    x_status := -1;

    UPDATE fte_prc_parameters
       SET value_from = l_value_from,
	   value_to = l_value_to,
  	   uom_code = l_uom_code,
           currency_code = l_currency_code,
	   LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	   LAST_UPDATE_DATE = sysdate,
	   LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
     WHERE parameter_instance_id = l_parameter_instance_id;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		 p_msg   	=> x_error_msg,
	               		 p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END UPDATE_PRC_PARAMETER;

END FTE_LANE_PKG;

/
