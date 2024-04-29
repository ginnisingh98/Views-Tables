--------------------------------------------------------
--  DDL for Package Body FTE_PARCEL_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_PARCEL_LOADER" AS
/* $Header: FTEPCLDB.pls 120.2 2005/08/25 06:18:35 pkaliyam noship $ */
 -----------------------------------------------------------------------------
 --                                                                         --
 -- NAME:        FTE_PARCEL_LOADER                                          --
 -- TYPE:        PACKAGE BODY                                               --
 -- DESCRIPTION: Contains Parcel Loader functions for Bulk Loader 	    --
 --                                                                         --
 -- PROCEDURES and FUNCTIONS:						    --
 --	 PROCEDURE 	GET_POSTAL_PART					    --
 --			OBSOLETE_PREVIOUS_DATA				    --
 --			CREATE_DEST_ZONES_LANES				    --
 --			PROCESS_DATA					    --
 --			PROCESS_RATING_ZONE_CHART			    --
 --			PROCESS_RATING_SETUP				    --
 --			PROCESS_ORIGIN					    --
 --			PROCESS_DESTINATION				    --
 -----------------------------------------------------------------------------

  G_PKG_NAME         	CONSTANT  	VARCHAR2(50) := 'FTE_PARCEL_LOADER';

  g_chart_info		STRINGARRAY;  -- rating zone chart info STRINGARRAY
  g_origin_zone		FTE_BULKLOAD_PKG.data_values_tbl;  -- origin zone info STRINGARRAY
  g_dest_zones		FTE_BULKLOAD_PKG.block_data_tbl;  -- table of STRINGARRAY of destination zone info
  g_last_service_type	VARCHAR2(200) := NULL;

  -- table of STRINGARRAY with first item on string array being the service level,
  -- if null, then that STRINGARRAY follows the last STRINGARRAY with first item not null.
  g_setup_info		FTE_BULKLOAD_PKG.array_tbl;
  g_dest_indexes	FTE_BULKLOAD_PKG.array_tbl;
  g_dest_id		NUMBER := 1;

  -- table of STRINGARRAY with first item being destination name and the rest being the values
  -- of a row of service columns in destination block
  g_dest_info		FTE_BULKLOAD_PKG.array_tbl;
  g_service_columns	STRINGARRAY := STRINGARRAY();  -- STRINGARRAY of the column names of the service columns in destination block

  g_postal_from		VARCHAR2(100);
  g_postal_to		VARCHAR2(100);

  ----------------------------------------------------------------------------
  -- PROCEDURE GET_POSTAL_PART
  --
  -- Purpose: parse the postal code into from and to
  --
  -- IN parameters:
  --	1. p_postal:	postal code in format of (*-*, *..*, *)
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE GET_POSTAL_PART(p_postal	IN	VARCHAR2) IS
  BEGIN
    g_postal_from := '';
    g_postal_to   := '';

    IF (INSTR(p_postal, '-') > 0) THEN  -- separator -
      g_postal_from := SUBSTR(p_postal, 1, INSTR(p_postal, '-')-1);
      g_postal_to   := SUBSTR(p_postal, INSTR(p_postal, '-')+1, LENGTH(p_postal));
    ELSIF (INSTR(p_postal, '.') > 0) THEN  -- separator ..
      g_postal_from := SUBSTR(p_postal, 1, INSTR(p_postal, '-')-1);
      g_postal_to   := SUBSTR(p_postal, INSTR(p_postal, '-')+2, LENGTH(p_postal));
    ELSE
      g_postal_from := p_postal;
      g_postal_to   := p_postal;
    END IF;

    g_postal_from := TRIM(' ' FROM g_postal_from);
    g_postal_to   := TRIM(' ' FROM g_postal_to);
  END GET_POSTAL_PART;

  ----------------------------------------------------------------------------
  -- PROCEDURE OBSOLETE_PREVIOUS_DATA
  --
  -- Purpose: remove or enddate old data if zone name exist
  --
  -- IN parameters:
  --	1. p_zone_name:	zone name to be matched
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  --
  -- FTE_LANES      	- Change Expiry_Date to new Effective_Date -1
  -- FTE_PRC_PARAMETERS - No change
  -- WSH_REGIONS    	- No change
  -- WSH_REGIONS_TL     - Change Zone Name
  -- WSH_ZONE_REGIONS   - No change
  ----------------------------------------------------------------------------
  PROCEDURE OBSOLETE_PREVIOUS_DATA(p_zone_name	IN	VARCHAR2,
				   x_status	OUT	NOCOPY NUMBER,
				   x_error_msg	OUT	NOCOPY VARCHAR2) IS
  l_start_date  VARCHAR2(100) := g_chart_info(8);
  l_expiry_date DATE;
  l_action	VARCHAR2(20);

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.OBSOLETE_PREVIOUS_DATA';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Zone Name', p_zone_name);
    END IF;

    IF (l_start_date IS NULL) THEN
      l_expiry_date := SYSDATE - 1;
    ELSE
       BEGIN
           l_expiry_date := TO_DATE(l_start_date, FTE_BULKLOAD_PKG.G_DATE_FORMAT3) - 1;
       EXCEPTION
	   WHEN OTHERS THEN
           BEGIN
	       l_expiry_date := TO_DATE(l_expiry_date,'MM/DD/YYYY') - 1;
	       l_expiry_date := TO_CHAR(l_expiry_date);
	   EXCEPTION
	      WHEN OTHERS THEN
		 x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INCORRECT_DATE',
						     p_tokens => STRINGARRAY('DATE'),
						     p_values => STRINGARRAY(l_expiry_date));

                 FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
					    p_msg => x_error_msg,
					    p_category	=> 'D',
					    p_line_number => 0);
                 FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
                 x_status := 1;
                 RETURN;
	   END;
       END;

    END IF;

    BEGIN
      -- check if there are previously loaded parcel lanes
      SELECT 'UPDATE'
	INTO l_action
        FROM fte_lanes
        WHERE lane_number like p_zone_name||'%'
          AND editable_flag = 'N'
	  AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	RETURN;
    END;

    -- if there are previoiusly loaded parcel lanes,
    -- check whether they need to be deleted or not

    BEGIN
      SELECT 'DELETE'
	INTO l_action
        FROM fte_lanes
        WHERE lane_number like p_zone_name||'%'
          AND editable_flag = 'N'
          AND nvl(effective_date, SYSDATE) > l_expiry_date
	  AND rownum = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        -- Update the Expiry_Date of the previously loaded lanes
        -- to the previous date of the effective date of new lanes

        -- Update EXPIRY_DATE of the previously loaded Parcel Lanes
        UPDATE fte_lanes
          SET expiry_date = l_expiry_date,
              lane_number = lane_id||'-PARCEL',
              last_update_date = SYSDATE
          WHERE lane_number like p_zone_name||'%'
            AND editable_flag = 'N';

        -- Update Zone Name of the previously loaded Zones
        UPDATE wsh_regions_tl t
          SET t.zone = t.region_id||'-PARCEL'
          WHERE t.zone like p_zone_name||'%'
            AND t.region_id IN (SELECT region_id FROM wsh_regions
                	    WHERE region_id=t.region_id AND region_type=11);

        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    END;

    -- mark the lanes to be deleted
    -- and reuse the zone
    BEGIN
      UPDATE fte_lanes
        SET editable_flag = 'D',
            lane_number = lane_id||'-PARCEL',
            last_update_date = SYSDATE
        WHERE lane_number like p_zone_name||'%'
          AND editable_flag = 'N';

      -- Delete all the entries for the Zones from WSH_ZONE_REGIONS
      DELETE wsh_zone_regions
        WHERE parent_region_id in (SELECT region_id FROM wsh_regions_v
                		   WHERE zone like p_zone_name||'%' AND region_type = 11);

    END;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
				 p_msg 		=> x_error_msg,
				 p_category	=> 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END OBSOLETE_PREVIOUS_DATA;

  ----------------------------------------------------------------------------
  -- PROCEDURE  PROCESS_ZONES_AND_LANES
  --
  -- Purpose: make the zones and lanes
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  --
  ----------------------------------------------------------------------------
  PROCEDURE PROCESS_ZONES_AND_LANES(x_status		OUT	NOCOPY NUMBER,
				    x_error_msg		OUT	NOCOPY VARCHAR2) IS

  l_dest_values		STRINGARRAY;
  l_basis		VARCHAR2(10) := 'WEIGHT';
  l_lane_table		FTE_BULKLOAD_PKG.block_data_tbl;
  l_rate_table		FTE_BULKLOAD_PKG.block_data_tbl;
  l_lane_data		FTE_BULKLOAD_PKG.data_values_tbl;
  l_service_data	FTE_BULKLOAD_PKG.data_values_tbl;
  l_rate_data		FTE_BULKLOAD_PKG.data_values_tbl;
  l_setup_data		FTE_BULKLOAD_PKG.data_values_tbl;
  l_lane_header		FTE_BULKLOAD_PKG.block_header_tbl;
  l_rate_header		FTE_BULKLOAD_PKG.block_header_tbl;
  l_zone_header		FTE_BULKLOAD_PKG.block_header_tbl;
  l_index		NUMBER;

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_ZONES_AND_LANES';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    FOR i IN 1..FTE_VALIDATION_PKG.SERVICE.COUNT LOOP
      l_lane_data(FTE_VALIDATION_PKG.SERVICE(i)) := null;
      l_service_data(FTE_VALIDATION_PKG.SERVICE(i)) := null;
      l_rate_data(FTE_VALIDATION_PKG.SERVICE(i)) := null;
      l_lane_header(FTE_VALIDATION_PKG.SERVICE(i)) := i;
    END LOOP;

    FOR i IN 1..FTE_VALIDATION_PKG.SERVICE_RATING_SETUP.COUNT LOOP
      l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(i)) := null;
      l_rate_header(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(i)) := i;
    END LOOP;

    FOR i IN 1..FTE_VALIDATION_PKG.ZONE.COUNT LOOP
      l_zone_header(FTE_VALIDATION_PKG.ZONE(i)) := i;
    END LOOP;

    g_dest_zones(g_dest_zones.COUNT+1) := g_origin_zone;

    FTE_REGION_ZONE_LOADER.PROCESS_ZONE(p_block_header		=> l_zone_header,
				        p_block_data 		=> g_dest_zones,
				 	p_line_number  		=> NULL,
				 	p_region_type  		=> '11',
				 	x_status		=> x_status,
				 	x_error_msg		=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    FOR i IN 1..g_dest_info.COUNT LOOP
      l_dest_values := g_dest_info(i);

      FOR j IN 1..g_service_columns.COUNT LOOP

        IF (l_dest_values(j+1) IS NOT NULL) THEN
          -- BASIS is always WEIGHT
          -- Except when the Service Type is for Letter

	  IF (INSTR(UPPER(g_service_columns(j)), 'LETTER') > 0) THEN
	    l_basis := 'CONTAINER';
	  END IF;

          l_lane_data(FTE_VALIDATION_PKG.SERVICE(2)) := 'SERVICE';
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(1)) := 'ADD';
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(4)) := l_dest_values(1)||'-'||g_dest_id;
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(11)) := g_origin_zone(FTE_VALIDATION_PKG.ZONE(2));
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(17)) := l_dest_values(1);
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(5)) := g_chart_info(2);
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(21)) := l_basis;
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(23)) := g_chart_info(6);
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(3)) := g_chart_info(4);
          l_lane_data('EDITABLE_FLAG') := 'N';
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(32)) := g_chart_info(8);
          l_lane_data(FTE_VALIDATION_PKG.SERVICE(33)) := g_chart_info(9);

	  g_dest_id := g_dest_id + 1;

          l_service_data(FTE_VALIDATION_PKG.SERVICE(2)) := 'SERVICE_LEVEL';
          l_service_data(FTE_VALIDATION_PKG.SERVICE(1)) := 'ADD';
          l_service_data(FTE_VALIDATION_PKG.SERVICE(19)) := g_service_columns(j);

          l_rate_data(FTE_VALIDATION_PKG.SERVICE(2)) := 'RATE_CHART';
          l_rate_data(FTE_VALIDATION_PKG.SERVICE(1)) := 'ADD';
          l_rate_data(FTE_VALIDATION_PKG.SERVICE(22)) := g_chart_info(5) || l_dest_values(j+1);

	  l_lane_table(l_lane_table.COUNT+1) := l_lane_data;
	  l_lane_table(l_lane_table.COUNT+1) := l_service_data;
	  l_lane_table(l_lane_table.COUNT+1) := l_rate_data;

	  FOR k IN 1..g_setup_info.COUNT LOOP

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
	      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'service', g_setup_info(k)(1));
 	      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'service columns', g_service_columns(j));
	    END IF;

	    IF (g_setup_info(k)(1) IS NOT NULL AND g_setup_info(k)(1) = g_service_columns(j)) THEN

              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(1)) := 'SYNC';
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(2)) := g_chart_info(4);
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(3)) := l_lane_data(FTE_VALIDATION_PKG.SERVICE(4));
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(4)) := g_setup_info(k)(2);
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(5)) := g_setup_info(k)(3);
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(6)) := g_setup_info(k)(4);
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(7)) := g_setup_info(k)(5);
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(8)) := g_setup_info(k)(6);
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(9)) := g_setup_info(k)(7);
              l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(10)) := g_setup_info(k)(8);

	      l_rate_table(l_rate_table.COUNT+1) := l_setup_data;

	      l_index := k + 1;

	      -- looping through the table after the service is found and before the next service
	      WHILE (l_index <= g_setup_info.COUNT AND g_setup_info(l_index)(1) IS NULL) LOOP
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(1)) := 'SYNC';
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(2)) := g_chart_info(4);
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(3)) := l_lane_data(FTE_VALIDATION_PKG.SERVICE(4));
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(4)) := g_setup_info(l_index)(2);
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(5)) := g_setup_info(l_index)(3);
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(6)) := g_setup_info(l_index)(4);
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(7)) := g_setup_info(l_index)(5);
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(8)) := g_setup_info(l_index)(6);
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(9)) := g_setup_info(l_index)(7);
          	l_setup_data(FTE_VALIDATION_PKG.SERVICE_RATING_SETUP(10)) := g_setup_info(l_index)(8);

		l_rate_table(l_rate_table.COUNT+1) := l_setup_data;
		l_index := l_index + 1;
	      END LOOP;
	    END IF;
          END LOOP;
	END IF;
      END LOOP;
    END LOOP;

    FTE_LANE_LOADER.PROCESS_SERVICE(p_block_header	=> l_lane_header,
				    p_block_data	=> l_lane_table,
				    p_line_number 	=> NULL,
				    x_status		=> x_status,
				    x_error_msg		=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    FTE_LANE_LOADER.PROCESS_SERVICE_RATING_SETUP(p_block_header	=> l_rate_header,
						 p_block_data	=> l_rate_table,
				       		 p_line_number 	=> NULL,
				     		 x_status	=> x_status,
				     		 x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_ZONES_AND_LANES;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_DATA
  --
  -- Purpose: Call appropriate process function according to the type.
  --
  -- IN parameters:
  --	1. p_type:		type of the block (Rating zone chart, rating setup, orign, destination)
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

    IF (p_type = 'RATING_ZONE_CHART') THEN
      PROCESS_RATING_ZONE_CHART(p_block_header	=> p_block_header,
				p_block_data	=> p_block_data,
				p_line_number	=> p_line_number,
				x_status	=> x_status,
				x_error_msg	=> x_error_msg);
    ELSIF (p_type = 'RATING_SETUP') THEN
      PROCESS_RATING_SETUP(p_block_header	=> p_block_header,
			   p_block_data		=> p_block_data,
			   p_line_number	=> p_line_number,
			   x_status		=> x_status,
			   x_error_msg		=> x_error_msg);
    ELSIF (p_type = 'ORIGIN') THEN
      PROCESS_ORIGIN(p_block_header	=> p_block_header,
		     p_block_data	=> p_block_data,
		     p_line_number	=> p_line_number,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);
    ELSE
      PROCESS_DESTINATION(p_block_data	=> p_block_data,
			  p_line_number	=> p_line_number,
			  x_status	=> x_status,
			  x_error_msg	=> x_error_msg);
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_DATA;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_RATING_ZONE_CHART
  --
  -- Purpose: process the lines in p_table for rating zone chart
  --
  -- IN parameters:
  --	1. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	2. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_RATING_ZONE_CHART(p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			  	      p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			  	      p_line_number	IN	NUMBER,
			  	      x_status		OUT	NOCOPY 	NUMBER,
			  	      x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values	FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_RATING_ZONE_CHART';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    --verify the column name
    FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys		=> p_block_header,
				        p_type		=> 'RATING_ZONE_CHART',
					p_line_number	=> p_line_number+1,
				        x_status	=> x_status,
				        x_error_msg	=> x_error_msg);
    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_RATING_ZONE_CHART(p_values		=> l_values,
					   	    p_line_number 	=> p_line_number+i+1,
				       		    p_chart_info	=> g_chart_info,
				       		    x_status		=> x_status,
				       		    x_error_msg		=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;

    END LOOP;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_RATING_ZONE_CHART;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_RATING_SETUP
  --
  -- Purpose: process the lines in p_table for rating setup
  --
  -- IN parameters:
  --	1. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	2. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_RATING_SETUP(p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			  	 p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			  	 p_line_number	IN	NUMBER,
			  	 x_status	OUT	NOCOPY 	NUMBER,
			  	 x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values	FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_RATING_SETUP';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    --verify the column name
    FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys		=> p_block_header,
 				        p_type		=> 'RATING_SETUP',
					p_line_number	=> p_line_number+1,
				        x_status	=> x_status,
				        x_error_msg	=> x_error_msg);
    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_RATING_SETUP(p_values			=> l_values,
					       p_line_number 		=> p_line_number+i+1,
				  	       p_setup_info		=> g_setup_info,
					       p_last_service_type	=> g_last_service_type,
				  	       x_status			=> x_status,
				  	       x_error_msg		=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
       	RETURN;
      END IF;

    END LOOP;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_RATING_SETUP;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_ORIGIN
  --
  -- Purpose: process the lines in p_table for origin
  --
  -- IN parameters:
  --	1. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	2. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_ORIGIN(p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			   p_block_data		IN	FTE_BULKLOAD_PKG.block_data_tbl,
			   p_line_number	IN	NUMBER,
			   x_status		OUT	NOCOPY 	NUMBER,
			   x_error_msg		OUT	NOCOPY 	VARCHAR2) IS

  l_origin_postal	VARCHAR2(200);
  l_origin_country	VARCHAR2(200);
  l_origin_state	VARCHAR2(200);
  l_origin_city		VARCHAR2(200);
  l_origin_postal_from 	VARCHAR2(100);
  l_origin_postal_to	VARCHAR2(100);
  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_origin		STRINGARRAY;

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_ORIGIN';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    --verify the column name
    FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys		=> p_block_header,
				       p_type		=> 'ORIGIN',
					p_line_number	=> p_line_number+1,
				       x_status		=> x_status,
				       x_error_msg	=> x_error_msg);
    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_ORIGIN(p_values	=> l_values,
					 p_line_number 	=> p_line_number+i+1,
					 p_origin	=> l_origin,
					 x_status	=> x_status,
					 x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
       	RETURN;
      END IF;

      l_origin_postal := l_origin(1);
      l_origin_country := l_origin(2);
      l_origin_state := l_origin(3);
      l_origin_city := l_origin(4);

      GET_POSTAL_PART(p_postal => l_origin_postal);

      l_origin_postal_from := g_postal_from;
      l_origin_postal_to   := g_postal_to;

      g_origin_zone(FTE_VALIDATION_PKG.ZONE(1)) := 'ADD';
      g_origin_zone(FTE_VALIDATION_PKG.ZONE(2)) := g_chart_info(1) || '-' || l_origin_postal_from;
      g_origin_zone(FTE_VALIDATION_PKG.ZONE(5)) := l_origin_city;
      g_origin_zone(FTE_VALIDATION_PKG.ZONE(4)) := l_origin_state;
      g_origin_zone(FTE_VALIDATION_PKG.ZONE(3)) := l_origin_country;
      g_origin_zone(FTE_VALIDATION_PKG.ZONE(6)) := l_origin_postal_from;
      g_origin_zone(FTE_VALIDATION_PKG.ZONE(7)) := l_origin_postal_to;

      -- enhancement for patchset I : hjpark on 12/13/2002
      -- make the previously loaded data obsolete, if any

      OBSOLETE_PREVIOUS_DATA(p_zone_name	=> g_chart_info(1) || '-' || l_origin_postal_from,
			     x_status		=> x_status,
			     x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
       	RETURN;
      END IF;

    END LOOP;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_ORIGIN;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_DESTINATION
  --
  -- Purpose: process the lines in p_table for destination
  --
  -- IN parameters:
  --	1. p_table:		pl/sql table of STRINGARRAY containing the block information
  --	2. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_DESTINATION(p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			        p_line_number	IN	NUMBER,
			        x_status	OUT	NOCOPY 	NUMBER,
			        x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_dest_postal		VARCHAR2(200);
  l_dest_country	VARCHAR2(200);
  l_dest_state		VARCHAR2(200);
  l_dest_city		VARCHAR2(200);
  l_dest_postal_from	VARCHAR2(100);
  l_dest_postal_to	VARCHAR2(100);
  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_dest_zone_name	VARCHAR2(200);
  l_services		service_array := service_array(); -- name of the services
  l_service_count	NUMBER := 0; -- number of services
  l_name_value		VARCHAR2(2000);
  l_dest_values		STRINGARRAY := STRINGARRAY();
  l_exists		BOOLEAN := FALSE;
  l_dest		STRINGARRAY := STRINGARRAY();
  l_count		NUMBER;

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_DESTINATION';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    --+
    -- Do not verify the column name for destination since it's dynamic
    -- find out the mapping for column number to service columns
    --+
    FOR i IN 1..FTE_BULKLOAD_PKG.g_block_header_index.COUNT LOOP

       IF (FTE_BULKLOAD_PKG.g_block_header_index(i) NOT IN ('POSTAL_CODE_RANGE', 'COUNTRY', 'STATE', 'CITY')) THEN
	--+
	-- If not those column names, then it's a service. Map it
        --+
	l_service_count := l_service_count + 1;
	l_services.EXTEND;
       	l_services(l_service_count) := i;
	g_service_columns.EXTEND;
	g_service_columns(g_service_columns.COUNT) := FTE_BULKLOAD_PKG.g_block_header_index(i);

      END IF;

    END LOOP;

    --+
    -- process the body of the block
    --+
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP

      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_DESTINATION(p_values		=> l_values,
				   	      p_line_number 	=> p_line_number+i+1,
					      p_price_prefix	=> g_chart_info(5),
					      p_carrier_id	=> TO_NUMBER(g_chart_info(7)),
					      p_origin_zone	=> g_origin_zone,
				 	      p_service_count	=> l_service_count,
				 	      p_services	=> l_services,
					      p_dest		=> l_dest,
					      x_status		=> x_status,
				 	      x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	RETURN;
      END IF;

      l_dest_postal := l_dest(1);
      l_dest_country := l_dest(2);
      l_dest_state := l_dest(3);
      l_dest_city := l_dest(4);

      GET_POSTAL_PART(p_postal => l_dest_postal);

      l_dest_postal_from := g_postal_from;
      l_dest_postal_to   := g_postal_to;

      l_dest_zone_name := g_origin_zone(FTE_VALIDATION_PKG.ZONE(2));

      IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LogFile(l_module_name,'l_dest_zone_name',l_dest_zone_name);
      END IF;

      l_name_value := null;

      FOR i IN 1..l_service_count LOOP
        l_name_value := l_name_value || '-' || l_values(FTE_BULKLOAD_PKG.g_block_header_index(l_services(i)));
      END LOOP;

      FOR i in 1..g_dest_indexes.COUNT LOOP
	IF (g_dest_indexes(i)(1) = l_name_value) THEN
	  l_dest_zone_name := l_dest_zone_name || '-' || g_dest_indexes(i)(2);
	END IF;
      END LOOP;

      IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LogFile(l_module_name,'l_name_value',l_name_value);
          FTE_UTIL_PKG.WRITE_LogFile(l_module_name,'l_dest_zone_name',l_dest_zone_name);
      END IF;

      --+
      -- l_name_value was not found in the g_dest_indexes table
      --+
      IF (l_dest_zone_name = g_origin_zone(FTE_VALIDATION_PKG.ZONE(2))) THEN
	g_dest_indexes(g_dest_indexes.COUNT+1) := STRINGARRAY(l_name_value, g_dest_id);
	l_dest_zone_name := l_dest_zone_name || '-' || g_dest_id;
	g_dest_id := g_dest_id + 1;
      END IF;

      l_exists := FALSE;

      FOR i IN 1..g_dest_info.COUNT LOOP
	IF (g_dest_info(i)(1) = l_dest_zone_name) THEN
	  l_exists := TRUE;
	  EXIT;
	END IF;
      END LOOP;

      IF (NOT l_exists) THEN
	l_dest_values := STRINGARRAY();
	l_dest_values.EXTEND;
	l_dest_values(l_dest_values.COUNT) := l_dest_zone_name;

	FOR i IN 1..l_service_count LOOP
	  l_dest_values.EXTEND;
	  l_dest_values(l_dest_values.COUNT) := l_values(FTE_BULKLOAD_PKG.g_block_header_index(l_services(i)));
	END LOOP;
	g_dest_info(g_dest_info.COUNT+1) := l_dest_values;

      END IF;

      l_count := g_dest_zones.COUNT+1;
      g_dest_zones(l_count)(FTE_VALIDATION_PKG.ZONE(1)) := 'ADD';
      g_dest_zones(l_count)(FTE_VALIDATION_PKG.ZONE(2)) := l_dest_zone_name;
      g_dest_zones(l_count)(FTE_VALIDATION_PKG.ZONE(5)) := l_dest_city;
      g_dest_zones(l_count)(FTE_VALIDATION_PKG.ZONE(4)) := l_dest_state;
      g_dest_zones(l_count)(FTE_VALIDATION_PKG.ZONE(3)) := l_dest_country;
      g_dest_zones(l_count)(FTE_VALIDATION_PKG.ZONE(6)) := l_dest_postal_from;
      g_dest_zones(l_count)(FTE_VALIDATION_PKG.ZONE(7)) := l_dest_postal_to;

    END LOOP;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg   	=> sqlerrm,
	               		  p_category    => 'O',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
  END PROCESS_DESTINATION;

END FTE_PARCEL_LOADER;

/
