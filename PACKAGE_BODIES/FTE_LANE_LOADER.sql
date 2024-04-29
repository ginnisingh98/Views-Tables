--------------------------------------------------------
--  DDL for Package Body FTE_LANE_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_LANE_LOADER" AS
/* $Header: FTELNLDB.pls 120.1 2005/08/19 00:16:13 pkaliyam noship $ */
 -------------------------------------------------------------------------- --
 --                                                                         --
 -- NAME:        FTE_LANE_LOADER                                            --
 -- TYPE:        PACKAGE BODY                                               --
 -- DESCRIPTION: Contains Lane and Schedule loader functions for Bulk Loader--
 --                                                                         --
 -- PROCEDURES and FUNCTIONS:						    --
 --		 FUNCTION 	GET_NEXT_SCHEDULE_ID			    --
 --				GET_SCHEDULE				    --
 --		 PROCEDURE 	PROCESS_DATA				    --
 --		 		PROCESS_SERVICE				    --
 -- 		 		PROCESS_SERVICE_RATING_SETUP		    --
 --				PROCESS_SCHEDULE			    --
 -------------------------------------------------------------------------- --

  G_PKG_NAME         CONSTANT  VARCHAR2(50) := 'FTE_LANE_LOADER';
  g_lane_tbl		FTE_LANE_PKG.lane_tbl;
  g_lane_rate_chart_tbl	FTE_LANE_PKG.lane_rate_chart_tbl;
  g_lane_service_tbl	FTE_LANE_PKG.lane_service_tbl;
  g_lane_commodity_tbl	FTE_LANE_PKG.lane_commodity_tbl;
  g_schedule_tbl	FTE_LANE_PKG.schedule_tbl;
  g_prc_parameter_tbl	FTE_LANE_PKG.prc_parameter_tbl;

  g_lane_function 	VARCHAR2(100);
  g_deficit_wt		BOOLEAN := FALSE;  -- if it's DEFICIT_WT
  g_first 		BOOLEAN := TRUE;   -- if it's New Lane
  g_pre_lane_number	VARCHAR2(200);

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_DATA
  --
  -- Purpose: Call appropriate process function according to the type.
  --
  -- IN parameters:
  --	1. p_type:		type of the block (Service, Schedule, Service_rating_setup)
  --	2. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	3. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE PROCESS_DATA (p_type	IN	VARCHAR2,
			  p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			  p_block_data		IN	FTE_BULKLOAD_PKG.block_data_tbl,
			  p_line_number	IN	NUMBER,
			  x_status	OUT	NOCOPY 	NUMBER,
			  x_error_msg	OUT	NOCOPY 	VARCHAR2) IS
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_DATA';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (p_type = 'SCHEDULE') THEN
      PROCESS_SCHEDULE(p_block_header	=> p_block_header,
		       p_block_data	=> p_block_data,
		       p_line_number	=> p_line_number,
		       x_status		=> x_status,
		       x_error_msg 	=> x_error_msg);
    ELSIF (p_type = 'SERVICE') THEN
      PROCESS_SERVICE(p_block_header	=> p_block_header,
		      p_block_data	=> p_block_data,
		      p_line_number	=> p_line_number,
		      x_status		=> x_status,
		      x_error_msg 	=> x_error_msg);
    ELSE
      PROCESS_SERVICE_RATING_SETUP(p_block_header	=> p_block_header,
		       		   p_block_data		=> p_block_data,
			  	   p_line_number 	=> p_line_number,
		 	  	   x_status		=> x_status,
		 	  	   x_error_msg 		=> x_error_msg);
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_DATA;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_SERVICE
  --
  -- Purpose: process the lines in p_table for service
  --
  -- IN parameters:
  --	1. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	2. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE PROCESS_SERVICE (p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			     p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			     p_line_number 	IN	NUMBER,
			     x_status		OUT	NOCOPY 	NUMBER,
			     x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values	FTE_BULKLOAD_PKG.data_values_tbl;
  l_action	VARCHAR2(20);
  l_type	VARCHAR2(100);
  l_find_lane	BOOLEAN := false;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_SERVICE';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);
    x_status := -1;

    --verify the column name

    FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys		=> p_block_header,
				        p_type		=> 'SERVICE',
					p_line_number	=> p_line_number+1,
				        x_status	=> x_status,
				        x_error_msg	=> x_error_msg);
    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP

      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_SERVICE(p_values		=> l_values,
					  p_line_number 	=> p_line_number+i+1,
			 		  p_type		=> l_type,
					  p_action		=> l_action,
					  p_lane_tbl		=> g_lane_tbl,
					  p_lane_rate_chart_tbl => g_lane_rate_chart_tbl,
					  p_lane_service_tbl	=> g_lane_service_tbl,
					  p_lane_commodity_tbl	=> g_lane_commodity_tbl,
			 		  x_status		=> x_status,
			 		  x_error_msg		=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;

      IF (l_action = 'DELETE') THEN
	IF (l_type = 'SERVICE') THEN
  	  FTE_LANE_PKG.DELETE_ROW(p_id		=> g_lane_tbl(g_lane_tbl.COUNT).lane_id,
				  p_table	=> 'FTE_LANES',
				  p_code	=> NULL,
				  p_line_number	=> p_line_number+i+1,
		   		  x_status	=> x_status,
		   		  x_error_msg	=> x_error_msg);
          IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          END IF;

 	  g_lane_tbl(g_lane_tbl.COUNT).lane_id := 0;  -- set to 0 so the next component line can be skipped
	ELSIF (l_type = 'RATE_CHART' AND g_lane_tbl(g_lane_tbl.COUNT).lane_id <> 0) THEN
  	  FTE_LANE_PKG.DELETE_ROW(p_id		=> g_lane_rate_chart_tbl(g_lane_rate_chart_tbl.COUNT).lane_id,
				  p_table	=> 'FTE_LANE_RATE_CHARTS',
				  p_code	=> to_char(g_lane_rate_chart_tbl(g_lane_rate_chart_tbl.COUNT).list_header_id),
				  p_line_number	=> p_line_number+i+1,
		   		  x_status	=> x_status,
		   		  x_error_msg	=> x_error_msg);

          IF (x_status <> -1) THEN
	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          END IF;

	  FTE_LANE_PKG.UPDATE_LANE_FLAGS(p_type		=> l_type,
					 p_lane_id	=> g_lane_rate_chart_tbl(g_lane_rate_chart_tbl.COUNT).lane_id,
					 x_status	=> x_status,
					 x_error_msg	=> x_error_msg);

          IF (x_status <> -1) THEN
	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          END IF;

	  g_lane_rate_chart_tbl.DELETE(g_lane_rate_chart_tbl.COUNT);
	ELSIF (l_type = 'SERVICE_TYPE' AND g_lane_tbl(g_lane_tbl.COUNT).lane_id <> 0) THEN
	  l_find_lane := FTE_LANE_PKG.FIND_TYPE(p_type		=> 'SERVICE_LEVEL',
					     	p_value		=> g_lane_service_tbl(g_lane_service_tbl.COUNT).service_code,
				     		p_lane_id	=> g_lane_tbl(g_lane_tbl.COUNT).lane_id,
						p_line_number	=> p_line_number+i+1,
				     		x_status	=> x_status,
				     		x_error_msg 	=> x_error_msg);

          IF (x_status <> -1) THEN
	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          END IF;

	  IF (l_find_lane) THEN
  	    FTE_LANE_PKG.DELETE_ROW(p_id	=> g_lane_tbl(g_lane_tbl.COUNT).lane_id,
				    p_table	=> 'FTE_LANE_SERVICES',
				    p_code	=> g_lane_service_tbl(g_lane_service_tbl.COUNT).service_code,
 				    p_line_number	=> p_line_number+i+1,
		   		    x_status	=> x_status,
 	 	   		    x_error_msg	=> x_error_msg);
            IF (x_status <> -1) THEN
              FTE_UTIL_PKG.Exit_Debug(l_module_name);
	      RETURN;
            END IF;

	    FTE_LANE_PKG.UPDATE_LANE_FLAGS(p_type	=> l_type,
					   p_lane_id	=> g_lane_tbl(g_lane_tbl.COUNT).lane_id,
					   x_status	=> x_status,
					   x_error_msg	=> x_error_msg);

            IF (x_status <> -1) THEN
	      FTE_UTIL_PKG.Exit_Debug(l_module_name);
	      RETURN;
            END IF;

	  END IF;

	  g_lane_service_tbl.DELETE(g_lane_service_tbl.COUNT);
	ELSIF (l_type = 'COMMODITY_TYPE' AND g_lane_tbl(g_lane_tbl.COUNT).lane_id <> 0) THEN
	  l_find_lane := FTE_LANE_PKG.FIND_TYPE(p_type		=> 'COMMODITY',
				     		p_value		=> TO_CHAR(g_lane_commodity_tbl(g_lane_commodity_tbl.COUNT).commodity_catg_id),
				     		p_lane_id	=> g_lane_tbl(g_lane_tbl.COUNT).lane_id,
						p_line_number	=> p_line_number+i+1,
				     		x_status	=> x_status,
				     		x_error_msg 	=> x_error_msg);

          IF (x_status <> -1) THEN
	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          END IF;

	  IF (l_find_lane) THEN
  	    FTE_LANE_PKG.DELETE_ROW(p_id	=> g_lane_tbl(g_lane_tbl.COUNT).lane_id,
				    p_table	=> 'FTE_LANE_COMMODITIES',
				    p_code	=> to_char(g_lane_commodity_tbl(g_lane_commodity_tbl.COUNT).commodity_catg_id),
				    p_line_number	=> p_line_number+i+1,
		   		    x_status	=> x_status,
		   		    x_error_msg	=> x_error_msg);
            IF (x_status <> -1) THEN
	      RETURN;
            END IF;

	    FTE_LANE_PKG.UPDATE_LANE_FLAGS(p_type	=> l_type,
					   p_lane_id	=> g_lane_tbl(g_lane_tbl.COUNT).lane_id,
					   x_status	=> x_status,
					   x_error_msg	=> x_error_msg);

            IF (x_status <> -1) THEN
	      FTE_UTIL_PKG.Exit_Debug(l_module_name);
	      RETURN;
            END IF;

	  END IF;
	  g_lane_commodity_tbl.DELETE(g_lane_commodity_tbl.COUNT);
	END IF;

      END IF;
    END LOOP;

    FTE_LANE_LOADER.SUBMIT_LANE(x_status	=> x_status,
				x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

/*    IF (x_status = -1) THEN
      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Commiting for Service load');
      END IF;
      commit;
    END IF;
*/
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_SERVICE;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_SERVICE_RATING_SETUP
  --
  -- Purpose: process the lines in p_table for service_rating_setup
  --
  -- IN parameters:
  --	1. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	2. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE PROCESS_SERVICE_RATING_SETUP (p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			  		  p_block_data		IN	FTE_BULKLOAD_PKG.block_data_tbl,
				    	  p_line_number IN	NUMBER,
				   	  x_status	OUT	NOCOPY 	NUMBER,
			 	   	  x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_action		VARCHAR2(100);
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_SERVICE_RATING_SETUP';
  l_lane_number		VARCHAR2(200);

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);
    x_status := -1;
    --verify the column name

    FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys		=> p_block_header,
				        p_type		=> 'SERVICE_RATING_SETUP',
					p_line_number	=> p_line_number+1,
				        x_status	=> x_status,
				        x_error_msg	=> x_error_msg);
    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values 	:= p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_SERVICE_RATING_SETUP(p_values			=> l_values,
				 		       p_line_number		=> p_line_number+i+1,
						       p_pre_lane_number	=> g_pre_lane_number,
						       p_prc_parameter_tbl 	=> g_prc_parameter_tbl,
						       p_deficit_wt		=> g_deficit_wt,
						       p_lane_function		=> g_lane_function,
						       p_lane_number		=> l_lane_number,
				 		       p_action			=> l_action,
						       x_status			=> x_status,
						       x_error_msg		=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
	RETURN;
      END IF;

      IF (l_action = 'DELETE') THEN
        IF (g_deficit_wt) THEN
	  FTE_LANE_PKG.DELETE_ROW(p_id		=> g_prc_parameter_tbl(g_prc_parameter_tbl.COUNT).lane_id,
				  p_table	=> 'FTE_PRC_PARAMETERS',
				  p_code	=> TO_CHAR(g_prc_parameter_tbl(g_prc_parameter_tbl.COUNT).parameter_id),
				  p_line_number	=> p_line_number+i+1,
		   		  x_status	=> x_status,
		   		  x_error_msg	=> x_error_msg);

        ELSIF (g_prc_parameter_tbl(g_prc_parameter_tbl.COUNT).parameter_instance_id <> -1) THEN
	  FTE_LANE_PKG.DELETE_ROW(p_id		=> g_prc_parameter_tbl(g_prc_parameter_tbl.COUNT).parameter_instance_id,
				  p_table	=> 'FTE_PRC_PARAMETERS',
				  p_code	=> NULL,
				  p_line_number	=> p_line_number+i+1,
		   		  x_status	=> x_status,
		   		  x_error_msg	=> x_error_msg);

        END IF;
      END IF;

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
	RETURN;
      END IF;

      IF (l_action = 'ADD') THEN
        IF (g_deficit_wt AND g_first) THEN
	  FTE_LANE_PKG.DELETE_ROW(p_id		=> g_prc_parameter_tbl(g_prc_parameter_tbl.COUNT).lane_id,
				  p_table	=> 'FTE_PRC_PARAMETERS',
				  p_code	=> TO_CHAR(g_prc_parameter_tbl(g_prc_parameter_tbl.COUNT).parameter_id),
				  p_line_number	=> p_line_number+i+1,
		   		  x_status	=> x_status,
		   		  x_error_msg	=> x_error_msg);

          IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          END IF;

        END IF;

	FTE_LANE_PKG.INSERT_PRC_PARAMETERS(p_prc_parameter_tbl	=> g_prc_parameter_tbl,
					   x_status	=> x_status,
					   x_error_msg	=> x_error_msg);

      ELSIF (l_action = 'UPDATE') THEN
	FTE_LANE_PKG.UPDATE_PRC_PARAMETER(p_prc_parameter_tbl	=> g_prc_parameter_tbl,
					   x_status	=> x_status,
					   x_error_msg	=> x_error_msg);
      END IF;

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
	RETURN;
      END IF;

      IF (l_lane_number <> nvl(g_pre_lane_number, l_lane_number || l_lane_number)) THEN
        g_first := TRUE;
        g_pre_lane_number := l_lane_number;

      ELSIF (g_deficit_wt AND g_first) THEN
        g_first := FALSE;
      END IF;

      g_prc_parameter_tbl.DELETE(g_prc_parameter_tbl.COUNT);
    END LOOP;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_SERVICE_RATING_SETUP;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_SCHEDULE
  --
  -- Purpose: process the lines in p_table for schedule
  --
  -- IN parameters:
  --	1. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	2. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE PROCESS_SCHEDULE (p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			      p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			      p_line_number	IN	NUMBER,
			      x_status		OUT	NOCOPY 	NUMBER,
			      x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_rows 		NUMBER := -1;
  l_old_schedule_id	NUMBER := -1;
  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_action      	VARCHAR2(100);
  l_voyage         	VARCHAR2(200);
  l_data_keys		STRINGARRAY := STRINGARRAY();
  l_data_values		STRINGARRAY := STRINGARRAY();
  l_lane_id		NUMBER;

  l_header_printed     BOOLEAN := false;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_SCHEDULE';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);
    x_status := -1;
    --verify the column name

    FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys		=> p_block_header,
				        p_type		=> 'SCHEDULE',
					p_line_number	=> p_line_number+1,
				        x_status	=> x_status,
				        x_error_msg	=> x_error_msg);
    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values 	:= p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_SCHEDULE(p_values		=> l_values,
				           p_line_number	=> p_line_number+i+1,
				           p_schedule_tbl	=> g_schedule_tbl,
				           p_action		=> l_action,
				           x_status		=> x_status,
				           x_error_msg		=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;

      IF (l_action = 'ADD') THEN

        IF (l_header_printed = false) THEN
             FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                                        p_msg_name    => 'FTE_SHCEDULES_LOADED',
                                        p_category    => NULL);
             l_header_printed := true;
        END IF;

        FTE_LANE_PKG.INSERT_SCHEDULES(p_schedule_tbl	=> g_schedule_tbl,
				      x_status		=> x_status,
				      x_error_msg	=> x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN;
        END IF;

        FTE_LANE_PKG.UPDATE_LANE_FLAGS(p_type		=> 'SCHEDULE',
			   	       p_lane_id	=> g_schedule_tbl(g_schedule_tbl.COUNT).lane_id,
				       p_value		=> 'Y',
				       x_status		=> x_status,
				       x_error_msg	=> x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN;
        END IF;

--      ELSIF (l_action = 'SYNC') THEN
-- need to figure out about update later

      ELSIF (l_action = 'DELETE') THEN
        -- Delete a schedule and modify a lane
        FTE_LANE_PKG.DELETE_ROW(p_id	=> g_schedule_tbl(g_schedule_tbl.COUNT).schedules_id,
				p_table	=> 'FTE_SCHEDULES',
				p_code 	=> g_schedule_tbl(g_schedule_tbl.COUNT).voyage_number,
				p_line_number	=> p_line_number+i+1,
				x_status => x_status,
				x_error_msg => x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN;
        END IF;

	-- to change Schedules_flag for the lane
	l_lane_id := g_schedule_tbl(g_schedule_tbl.COUNT).lane_id;
	SELECT COUNT(schedules_id)
	  INTO l_rows
	  FROM FTE_SCHEDULES
         WHERE LANE_ID = l_lane_id
	   AND NVL(EDITABLE_FLAG,'Y') = 'Y';

 	IF (l_rows = 0) THEN
          FTE_LANE_PKG.UPDATE_LANE_FLAGS(p_type		=> 'SCHEDULE',
			   	         p_lane_id	=> g_schedule_tbl(g_schedule_tbl.COUNT).lane_id,
				         p_value	=> 'N',
				         x_status	=> x_status,
				         x_error_msg	=> x_error_msg);

    	  IF (x_status <> -1) THEN
      	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  	    RETURN;
  	  END IF;

	END IF;
      END IF;
      g_schedule_tbl.DELETE(g_schedule_tbl.COUNT);
    END LOOP;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_SCHEDULE;

  ----------------------------------------------------------------------
  -- PROCEDURE SUBMIT_LANE
  --
  -- Purpose: insert all pl/sql tables into fte_lane_* tables
  ----------------------------------------------------------------------

  PROCEDURE SUBMIT_LANE(x_status	OUT NOCOPY 	NUMBER,
			x_error_msg	OUT NOCOPY 	VARCHAR2) IS
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.SUBMIT_LANE';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);
    x_status := -1;

  -- have to check if the lanes that has no commodity have to have basis
    FTE_LANE_PKG.INSERT_LANE_TABLES(p_lane_tbl			=> g_lane_tbl,
				    p_lane_rate_chart_tbl	=> g_lane_rate_chart_tbl,
				    p_lane_commodity_tbl	=> g_lane_commodity_tbl,
				    p_lane_service_tbl		=> g_lane_service_tbl,
				    x_status			=> x_status,
				    x_error_msg			=> x_error_msg);
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END SUBMIT_LANE;

END FTE_LANE_LOADER;

/
