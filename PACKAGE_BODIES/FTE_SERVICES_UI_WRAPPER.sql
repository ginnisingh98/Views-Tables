--------------------------------------------------------
--  DDL for Package Body FTE_SERVICES_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_SERVICES_UI_WRAPPER" AS
/* $Header: FTEUIWPB.pls 120.7 2005/08/22 03:49:50 pkaliyam noship $ */
 -------------------------------------------------------------------------- --
 --                                                                         --
 -- NAME:        FTE_SERVICES_UI_WRAPPER                                    --
 -- TYPE:        PACKAGE BODY                                               --
 -- DESCRIPTION: Contains wrapper procedures for UI loader		    --
 --                                                                         --
 -------------------------------------------------------------------------- --

  G_PKG_NAME         CONSTANT  VARCHAR2(50) := 'FTE_SERVICES_UI_WRAPPER';

  --------------------------------------------------------
  -- PROCEDURE RATE_CHART_WRAPPER
  --
  -- Purpose: convert UI data into pl/sql tables and insert into the database
  --
  -- IN parameters:
  --	1. p_header_table:	header info table
  --	2. p_line_table:	line info table
  --	3. p_break_table:	break info table
  -- 	4. p_chart_type:	the chart type (RC or MOD)
  --
  -- OUT parameters:
  -- 	1. x_status:	status, -1 means no error
  --	2. x_error_msg:	error message if any
  --------------------------------------------------------
  PROCEDURE RATE_CHART_WRAPPER( p_header_table 	IN rate_chart_header_table,
			        p_line_table 	IN rate_chart_line_table,
			        p_break_table 	IN rate_chart_break_table,
				p_chart_type	IN VARCHAR2,
			        x_status	OUT NOCOPY NUMBER,
			        x_error_msg	OUT NOCOPY VARCHAR2) IS

  l_block_header 		FTE_BULKLOAD_PKG.block_header_tbl;
  l_block_data   		FTE_BULKLOAD_PKG.block_data_tbl;
  l_aj_block_data   		FTE_BULKLOAD_PKG.block_data_tbl;
  l_line_block_data   		FTE_BULKLOAD_PKG.block_data_tbl;
  l_break_block_data   		FTE_BULKLOAD_PKG.block_data_tbl;
  l_offset			NUMBER := 0;
  l_count			NUMBER := 0;
  l_break_count			NUMBER := 0;
  l_line_number			NUMBER := 0;
  l_context			VARCHAR2(20) := 'LOGISTICS';

  BEGIN

    x_status := -1;

    IF ( WSH_DEBUG_SV.is_debug_enabled ) THEN
        FTE_UTIL_PKG.Init_Debug(1);
    END IF;

    FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
    FTE_RATE_CHART_PKG.RESET_ALL;

    FOR i IN p_header_table.FIRST..p_header_table.LAST LOOP

      l_block_data(1)('ACTION') 		:= 'UPDATE';
      l_block_data(1)('CARRIER_ID') 		:= p_header_table(i).carrier_id;
      l_block_data(1)('CURRENCY') 		:= p_header_table(i).currency_code;
      l_block_data(1)('START_DATE') 		:= to_char(p_header_table(i).start_date_active, FTE_BULKLOAD_PKG.G_DATE_FORMAT);
      l_block_data(1)('END_DATE') 		:= to_char(p_header_table(i).end_date_active, FTE_BULKLOAD_PKG.G_DATE_FORMAT);
      l_block_data(1)('DESCRIPTION') 		:= p_header_table(i).description;
      l_block_data(1)('REPLACED_RATE_CHART') 	:= '';
      l_block_data(1)('LIST_HEADER_ID')		:= p_header_table(i).list_header_id;

      IF ('RC' = p_chart_type) THEN
        l_block_data(1)('RATE_CHART_NAME') 	:= p_header_table(i).chart_name;
      ELSE
        l_block_data(1)('CHARGES_DISCOUNTS_NAME') := p_header_table(i).chart_name;
      END IF;

      g_list_header_id 			:= p_header_table(i).list_header_id;

      IF ('RC' = p_chart_type) THEN
        FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header	=> l_block_header,
					      	 p_block_data	=> l_block_data,
					      	 p_line_number	=> NULL,
					      	 p_validate_column	=> FALSE,
						 p_validate	=> FALSE,
					     	 x_status	=> x_status,
					     	 x_error_msg	=> x_error_msg);
      ELSE
	FTE_RATE_CHART_LOADER.PROCESS_CHARGES_DISCOUNTS(p_block_header	=> l_block_header,
						     	p_block_data	=> l_block_data,
						     	p_line_number	=> NULL,
					      	 	p_validate_column	=> FALSE,
						   	p_validate	=> FALSE,
						     	x_status	=> x_status,
						     	x_error_msg	=> x_error_msg);
      END IF;

      IF (x_status <> -1) THEN
        FTE_RATE_CHART_PKG.RESET_ALL;
        FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
        RETURN;
      END IF;

      FOR j IN p_line_table.FIRST..p_line_table.LAST LOOP
	l_count := l_count+1;
	l_line_number := l_count + l_break_count;
	l_line_block_data(j)('ACTION')		:= 'ADD';
	l_line_block_data(j)('LINE_NUMBER')	:= l_line_number;
	l_line_block_data(j)('DESCRIPTION')	:= p_line_table(j).description;
	l_line_block_data(j)('UOM')		:= p_line_table(j).rate_basis_uom;

	IF ('RC' = p_chart_type) THEN
  	  l_line_block_data(j)('RATE')			:= p_line_table(j).rate;
  	  l_line_block_data(j)('RATE_BREAK_TYPE')	:= p_line_table(j).break_type;
  	  l_line_block_data(j)('VOLUME_TYPE')		:= 'TOTAL_QUANTITY';
  	  l_line_block_data(j)('RATE_TYPE')		:= p_line_table(j).rate_type;
 	ELSE
  	  l_line_block_data(j)('TYPE')			:= p_line_table(j).type;
  	  l_line_block_data(j)('SUBTYPE')		:= p_line_table(j).subtype;
	  IF (p_line_table(j).rate_type = 'PER_UOM') THEN
    	    l_line_block_data(j)('RATE_PER_UOM')	:= p_line_table(j).rate;
	  ELSIF (p_line_table(j).rate_type = '%') THEN
  	    l_line_block_data(j)('PERCENTAGE')		:= p_line_table(j).rate;
      	  ELSE
  	    l_line_block_data(j)('FIXED_RATE')		:= p_line_table(j).rate;
	  END IF;
	END IF;

	IF ('RC' = p_chart_type) THEN
  	  FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE (p_block_header	=> l_block_header,
					           p_block_data		=> l_line_block_data,
						   p_line_number	=> NULL,
					      	   p_validate_column	=> FALSE,
						   p_validate		=> FALSE,
						   x_status		=> x_status,
						   x_error_msg		=> x_error_msg);
	ELSE
  	  FTE_RATE_CHART_LOADER.PROCESS_CHARGES_DISCOUNTS_LINE (p_block_header	=> l_block_header,
					        	     	p_block_data	=> l_line_block_data,
							     	p_line_number	=> NULL,
					     		 	p_validate_column	=> FALSE,
						   		p_validate	=> FALSE,
							     	x_status	=> x_status,
							     	x_error_msg	=> x_error_msg);
	END IF;

        IF (x_status <> -1) THEN
          FTE_RATE_CHART_PKG.RESET_ALL;
          FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
          RETURN;
        END IF;

	IF (p_line_table(j).break_type IS NOT NULL) THEN
	  l_break_block_data.DELETE;
	  FOR k IN p_break_table.FIRST..p_break_table.LAST LOOP
	    IF (p_break_table(k).break_header_index = p_line_table(j).line_num) THEN
  	      l_break_count := l_break_count + 1;
	      l_break_block_data(l_break_block_data.COUNT+1)('ACTION')		:= 'ADD';
	      l_break_block_data(l_break_block_data.COUNT)('LINE_NUMBER')	:= l_count+l_break_count;
	      l_break_block_data(l_break_block_data.COUNT)('LOWER_LIMIT')	:= p_break_table(k).lower;
	      l_break_block_data(l_break_block_data.COUNT)('UPPER_LIMIT')	:= p_break_table(k).upper;
	      l_break_block_data(l_break_block_data.COUNT)('RATE')		:= p_break_table(k).rate;
	      l_break_block_data(l_break_block_data.COUNT)('RATE_TYPE')		:= p_break_table(k).rate_type;
	    END IF;
	  END LOOP;
	  FTE_RATE_CHART_LOADER.PROCESS_RATE_BREAK(p_block_header	=> l_block_header,
					           p_block_data		=> l_break_block_data,
						   p_line_number	=> NULL,
					      	   p_validate_column	=> FALSE,
						   p_validate		=> FALSE,
						   x_status		=> x_status,
						   x_error_msg		=> x_error_msg);
          IF (x_status <> -1) THEN
            FTE_RATE_CHART_PKG.RESET_ALL;
            FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
            RETURN;
          END IF;

	END IF;

      	IF (p_line_table(j).origin_id IS NOT NULL) THEN
	  FTE_RATE_CHART_LOADER.ADD_ATTRIBUTE(p_pricing_attribute  => 'ORIGIN_ZONE',
                      			      p_attr_value_from    => p_line_table(j).origin_id,
                 			      p_line_number        => l_line_number,
                			      x_status             => x_status,
					      x_error_msg	   => x_error_msg);
        END IF;

        IF (x_status <> -1) THEN
          FTE_RATE_CHART_PKG.RESET_ALL;
          FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
          RETURN;
        END IF;

      	IF (p_line_table(j).dest_id IS NOT NULL) THEN
	  FTE_RATE_CHART_LOADER.ADD_ATTRIBUTE(p_pricing_attribute  => 'DESTINATION_ZONE',
                			      p_attr_value_from    => p_line_table(j).dest_id,
              				      p_line_number        => l_line_number,
                			      x_status             => x_status,
					      x_error_msg	   => x_error_msg);
        END IF;

        IF (x_status <> -1) THEN
          FTE_RATE_CHART_PKG.RESET_ALL;
          FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
          RETURN;
        END IF;

        IF (p_line_table(j).catg_id IS NOT NULL) THEN
          FTE_RATE_CHART_LOADER.ADD_ATTRIBUTE(p_pricing_attribute  => 'COMMODITY',
                			      p_attr_value_from    => p_line_table(j).catg_id,
                			      p_line_number        => l_line_number,
                			      x_status             => x_status,
					      x_error_msg	   => x_error_msg);
  	END IF;

        IF (x_status <> -1) THEN
          FTE_RATE_CHART_PKG.RESET_ALL;
          FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
          RETURN;
        END IF;

      	IF (p_line_table(j).service_code IS NOT NULL) THEN
          FTE_RATE_CHART_LOADER.ADD_ATTRIBUTE(p_pricing_attribute  => 'SERVICE_LEVEL',
               				      p_attr_value_from    => p_line_table(j).service_code,
                			      p_line_number        => l_line_number,
                			      x_status             => x_status,
					      x_error_msg	   => x_error_msg);
	END IF;

        IF (x_status <> -1) THEN
          FTE_RATE_CHART_PKG.RESET_ALL;
          FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
          RETURN;
        END IF;

        IF (p_line_table(j).multi_flag IS NOT NULL) THEN
          FTE_RATE_CHART_LOADER.ADD_ATTRIBUTE(p_pricing_attribute  => 'PARCEL_MULTIPIECE_FLAG',
                			      p_attr_value_from    => p_line_table(j).multi_flag,
                			      p_line_number        => l_line_number,
                			      x_status             => x_status,
					      x_error_msg	   => x_error_msg);
      	END IF;

        IF (x_status <> -1) THEN
          FTE_RATE_CHART_PKG.RESET_ALL;
          FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
          RETURN;
        END IF;

        l_line_block_data.DELETE;
        l_break_block_data.DELETE;
      END LOOP;

      l_block_data.DELETE;
    END LOOP;

    FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS(
		x_status		=>  	x_status,
		x_error_msg		=>  	x_error_msg);

    FTE_RATE_CHART_PKG.RESET_ALL;
    FTE_RATE_CHART_LOADER.INIT_QP_TABLES;

    IF (x_status = -1) THEN
      commit;
    ELSE
      rollback;
    END IF;

    FTE_RATE_CHART_PKG.RESET_ALL;
    FTE_RATE_CHART_LOADER.INIT_QP_TABLES;
  END RATE_CHART_WRAPPER;


  --------------------------------------------------------
  -- PROCEDURE TL_SURCHARGE_WRAPPER
  --
  -- Purpose: convert UI data into pl/sql tables and insert into the database
  --
  -- IN parameters:
  --	1. p_header_table:	header info table
  --	2. p_tl_line_table:	line info table
  --	3. p_break_table:	break info table
  --
  -- OUT parameters:
  -- 	1. x_status:	status, -1 means no error
  --	2. x_error_msg:	error message if any
  --------------------------------------------------------
  PROCEDURE TL_SURCHARGE_WRAPPER( p_header_table	IN	rate_chart_header_table,
				  p_tl_line_table 	IN	tl_line_table,
			          p_break_table 	IN 	rate_chart_break_table,
				  p_action		IN	VARCHAR2,
			          x_status	OUT NOCOPY NUMBER,
			          x_error_msg	OUT NOCOPY VARCHAR2)  IS

  l_block_header 		FTE_BULKLOAD_PKG.block_header_tbl;
  l_block_data   		FTE_BULKLOAD_PKG.block_data_tbl;

  BEGIN
    x_status := -1;
    IF ( WSH_DEBUG_SV.is_debug_enabled ) THEN
        FTE_UTIL_PKG.Init_Debug(1);
    END IF;

    l_block_data(1)('ACTION')		:= p_action;
    l_block_data(1)('TYPE')		:= 'C';
    l_block_data(1)('CARRIER_ID')	:= p_header_table(p_header_table.FIRST).carrier_id;
    l_block_data(1)('SERVICE_CODE')	:= p_header_table(p_header_table.FIRST).service_level;
    l_block_data(1)('CURRENCY')		:= p_header_table(p_header_table.FIRST).currency_code;
    l_block_data(1)('START_DATE')	:= to_char(p_header_table(p_header_table.FIRST).start_date_active, FTE_BULKLOAD_PKG.G_DATE_FORMAT);
    l_block_data(1)('END_DATE')		:= to_char(p_header_table(p_header_table.FIRST).end_date_active, FTE_BULKLOAD_PKG.G_DATE_FORMAT);

    FOR i IN p_tl_line_table.FIRST..p_tl_line_table.LAST LOOP
      IF (p_tl_line_table(i).type = 'C_ORIGIN_SURCHRG') THEN
	l_block_data(l_block_data.COUNT+1)('ACTION')	:= 'ADD';
	l_block_data(l_block_data.COUNT)('TYPE')	:= 'O';
	l_block_data(l_block_data.COUNT)('REGION_CODE')	:= p_tl_line_table(i).region_code;
	l_block_data(l_block_data.COUNT)('SURCHARGES')	:= p_tl_line_table(i).charge;
      ELSIF (p_tl_line_table(i).type = 'C_DESTINATION_SURCHRG') THEN
	l_block_data(l_block_data.COUNT+1)('ACTION')	:= 'ADD';
	l_block_data(l_block_data.COUNT)('TYPE')	:= 'D';
	l_block_data(l_block_data.COUNT)('REGION_CODE')	:= p_tl_line_table(i).region_code;
	l_block_data(l_block_data.COUNT)('SURCHARGES')	:= p_tl_line_table(i).charge;
      ELSIF (p_tl_line_table(i).type = 'C_FUEL_CHRG') THEN
	l_block_data(l_block_data.COUNT+1)('ACTION')	:= 'ADD';
	l_block_data(l_block_data.COUNT)('TYPE')	:= 'F';
	l_block_data(l_block_data.COUNT)('SURCHARGES')	:= p_tl_line_table(i).charge;
      ELSIF (p_tl_line_table(i).type = 'C_STOP_OFF_CHRG') THEN
    	l_block_data(1)('NUMBER_OF_FREE_STOPS')		:= p_tl_line_table(i).free_stops;
    	l_block_data(1)('FIRST_ADD_STOP_OFF_CHARGES')	:= p_tl_line_table(i).first_stop;
    	l_block_data(1)('SECOND_ADD_STOP_OFF_CHARGES')	:= p_tl_line_table(i).second_stop;
    	l_block_data(1)('THIRD_ADD_STOP_OFF_CHARGES')	:= p_tl_line_table(i).third_stop;
    	l_block_data(1)('FOURTH_ADD_STOP_OFF_CHARGES')	:= p_tl_line_table(i).fourth_stop;
    	l_block_data(1)('FIFTH_ADD_STOP_OFF_CHARGES')	:= p_tl_line_table(i).fifth_stop;
    	l_block_data(1)('ADDITIONAL_STOP_CHARGES')	:= p_tl_line_table(i).add_stops;
      ELSIF (p_tl_line_table(i).type = 'C_OUT_OF_ROUTE_CHRG') THEN
	l_block_data(1)('OUT_OF_ROUTE_CHARGES')		:= p_tl_line_table(i).charge;
    	l_block_data(1)('OUT_OF_ROUTE_CHARGE_BASIS_UOM'):= p_tl_line_table(i).basis_uom_code;
      ELSIF (p_tl_line_table(i).type = 'C_HANDLING_WEIGHT_CHRG') THEN
	l_block_data(1)('HANDLING_CHARGES')		:= p_tl_line_table(i).charge;
	l_block_data(1)('MINIMUM_HANDLING_CHARGES')	:= p_tl_line_table(i).min_charge;
       	l_block_data(1)('BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES')		:= p_tl_line_table(i).basis;
       	l_block_data(1)('UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS')	:= p_tl_line_table(i).basis_uom_code;
      ELSIF (p_tl_line_table(i).type = 'C_LOADING_WEIGHT_CHRG') THEN
	l_block_data(1)('LOADING_CHARGES')		:= p_tl_line_table(i).charge;
	l_block_data(1)('MINIMUM_LOADING_CHARGES')	:= p_tl_line_table(i).min_charge;
       	l_block_data(1)('BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES')		:= p_tl_line_table(i).basis;
       	l_block_data(1)('UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS')	:= p_tl_line_table(i).basis_uom_code;
      ELSIF (p_tl_line_table(i).type = 'C_AST_LOADING_WEIGHT_CHRG') THEN
	l_block_data(1)('ASSISTED_LOADING_CHARGES')		:= p_tl_line_table(i).charge;
	l_block_data(1)('MINIMUM_ASSISTED_LOADING_CHARGES')	:= p_tl_line_table(i).min_charge;
       	l_block_data(1)('BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES')		:= p_tl_line_table(i).basis;
       	l_block_data(1)('UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS')	:= p_tl_line_table(i).basis_uom_code;
      ELSIF (p_tl_line_table(i).type = 'C_UNLOADING_WEIGHT_CHRG') THEN
	l_block_data(1)('UNLOADING_CHARGES')		:= p_tl_line_table(i).charge;
	l_block_data(1)('MINIMUM_UNLOADING_CHARGES')	:= p_tl_line_table(i).min_charge;
       	l_block_data(1)('BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES')		:= p_tl_line_table(i).basis;
       	l_block_data(1)('UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS')	:= p_tl_line_table(i).basis_uom_code;
      ELSIF (p_tl_line_table(i).type = 'C_AST_UNLOADING_WEIGHT_CHRG') THEN
	l_block_data(1)('ASSISTED_UNLOADING_CHARGES')		:= p_tl_line_table(i).charge;
	l_block_data(1)('MINIMUM_ASSISTED_UNLOADING_CHARGES')	:= p_tl_line_table(i).min_charge;
       	l_block_data(1)('BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES')		:= p_tl_line_table(i).basis;
       	l_block_data(1)('UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS')	:= p_tl_line_table(i).basis_uom_code;
      ELSIF (p_tl_line_table(i).type = 'C_CONTINUOUS_MOVE_DISCOUNT') THEN
	l_block_data(1)('CONTINUOUS_MOVE_DISCOUNT_PERCENTAGE')	:= p_tl_line_table(i).charge;
      ELSIF (p_tl_line_table(i).type = 'C_WEEKDAY_LAYOVER_CHRG') THEN
	l_block_data(1)('WEEKDAY_LAYOVER_CHARGES')		:= p_tl_line_table(i).charge;
      ELSIF (p_tl_line_table(i).type = 'C_WEEKEND_LAYOVER_CHRG') THEN
	FOR j IN p_break_table.FIRST..p_break_table.LAST LOOP
	  l_block_data(l_block_data.COUNT+1)('ACTION')	:= 'ADD';
	  l_block_data(l_block_data.COUNT)('TYPE')	:= 'B';
	  l_block_data(l_block_data.COUNT)('DISTANCE_UOM_FOR_WEEKEND_LAYOVER_CHARGES')	:= p_tl_line_table(i).basis_uom_code;
	  l_block_data(l_block_data.COUNT)('WEEKEND_LAYOVER_DISTANCE_BREAK')	:= p_break_table(j).upper;
	  l_block_data(l_block_data.COUNT)('CHARGES') 	:= p_break_table(j).rate;
	END LOOP;
      END IF;

    END LOOP;

    FTE_TL_LOADER.PROCESS_TL_SURCHARGES(p_block_header  => l_block_header,
                                  	p_block_data    => l_block_data,
                                  	p_line_number   => NULL,
					p_doValidate    => FALSE,
                                  	x_status        => x_status,
                                  	x_error_msg     => x_error_msg);

    l_block_data.DELETE;

    FTE_TL_LOADER.RESET_ALL;

    IF (x_status = -1) THEN
      commit;
    ELSE
      rollback;
    END IF;

  END TL_SURCHARGE_WRAPPER;


  --------------------------------------------------------
  -- PROCEDURE EDIT_TL_SERVICES
  --
  -- Purpose: convert UI data into pl/sql tables and insert into the database
  --
  -- IN parameters:
  --	1. p_init_msg_list:
  --	2. p_transaction_type:
  --	3. p_lane_table:		lane table info
  -- 	4. p_rate_chart_header_table:	rate chart header info
  --	5. p_rate_chart_line_table:	rate chart line info
  --
  -- OUT parameters:
  -- 	1. x_status:
  --	2. x_error_msg:
  --------------------------------------------------------
  PROCEDURE Edit_TL_Services(P_INIT_MSG_LIST  			IN  		VARCHAR2,
			     P_TRANSACTION_TYPE  		IN		VARCHAR2,
			     P_LANE_TABLE			IN		lane_table,
			     P_RATE_CHART_HEADER_TABLE 		IN   		rate_chart_header_table,
			     P_RATE_CHART_LINE_TABLE		IN		rate_chart_line_table,
			     X_STATUS				OUT NOCOPY		NUMBER,
			     X_ERROR_MSG			OUT NOCOPY		VARCHAR2) IS

  l_lane_tbl			FTE_LANE_PKG.lane_tbl;
  l_lane_rate_chart_tbl		FTE_LANE_PKG.lane_rate_chart_tbl;
  l_lane_commodity_tbl		FTE_LANE_PKG.lane_commodity_tbl;
  l_lane_service_tbl		FTE_LANE_PKG.lane_service_tbl;

  l_lane_id			NUMBER;

  l_block_header       		FTE_BULKLOAD_PKG.block_header_tbl;
  l_rate_line_data     		FTE_BULKLOAD_PKG.block_data_tbl;
  l_postal_code_from		VARCHAR2(30) := NULL;
  l_postal_code_to		VARCHAR2(30) := NULL;
  l_postal_code_from_num	NUMBER := NULL;
  l_postal_code_to_num		NUMBER := NULL;

  l_action			VARCHAR2(10);

  BEGIN
    x_status := -1;

    IF ( WSH_DEBUG_SV.is_debug_enabled ) THEN
        FTE_UTIL_PKG.Init_Debug(1);
    END IF;

    FOR i IN P_LANE_TABLE.FIRST..P_LANE_TABLE.LAST LOOP

      IF (p_lane_table(i).LANE_ID IS NOT NULL) THEN
        l_lane_id := p_lane_table(i).LANE_ID;
      ELSE
	l_lane_id := FTE_LANE_PKG.GET_NEXT_LANE_ID;
      END IF;

      IF (P_TRANSACTION_TYPE = 'CREATE') THEN
	l_lane_tbl(i).action := 'ADD';

	l_action := 'ADD';

      ELSE
	l_action := 'UPDATE';
	l_lane_tbl(i).action := 'UPDATE';

      END IF;

      l_lane_tbl(i).lane_id 		:= l_lane_id;
      l_lane_tbl(i).carrier_id 		:= P_LANE_TABLE(i).carrier_id;
      l_lane_tbl(i).origin_id 		:= P_LANE_TABLE(i).origin_id;
      l_lane_tbl(i).destination_id 	:= P_LANE_TABLE(i).destination_id;
      l_lane_tbl(i).effective_date 	:= P_LANE_TABLE(i).START_DATE_ACTIVE;
      l_lane_tbl(i).expiry_date 	:= P_LANE_TABLE(i).END_DATE_ACTIVE;
      l_lane_tbl(i).pricelist_view_flag := 'Y';
      l_lane_tbl(i).editable_flag 	:= 'N';
      l_lane_tbl(i).lane_number 	:= P_LANE_TABLE(i).SERVICE_NUMBER;
      l_lane_tbl(i).mode_of_transportation_code := P_LANE_TABLE(i).TRANSPORT_MODE;
      l_lane_tbl(i).service_type_code 	:= P_LANE_TABLE(i).service_type_code;
      l_lane_tbl(i).container_all_flag 	:= FALSE;
      l_lane_tbl(i).basis_flag 		:= FALSE;
      l_lane_tbl(i).distance 		:= null;
      l_lane_tbl(i).distance_uom 	:= null;
      l_lane_tbl(i).transit_time 	:= null;
      l_lane_tbl(i).transit_time_uom 	:= null;
      l_lane_tbl(i).basis 		:= null;
      l_lane_tbl(i).comm_fc_class_code 	:= null;
      l_lane_tbl(i).additional_instructions := null;
      l_lane_tbl(i).special_handling 	:= null;
      l_lane_tbl(i).tariff_name 	:= null;
      l_lane_tbl(i).commodity_catg_id 	:= null;
      l_lane_tbl(i).equipment_type_code := null;
      l_lane_tbl(i).line_number 	:= null;
      IF (p_transaction_type = 'CREATE') THEN
        l_lane_tbl(i).lane_type 		:= 'HOLD_'||upper(P_RATE_CHART_HEADER_TABLE(p_rate_chart_header_table.FIRST).CHART_NAME);

	-- Initialize l_lane_service_tbl
	l_lane_service_tbl(i).lane_id 		:= l_lane_id;
	l_lane_service_tbl(i).service_code 	:= P_LANE_TABLE(i).SERVICE_TYPE_CODE;
	l_lane_service_tbl(i).lane_service_id 	:= FTE_LANE_PKG.get_next_lane_service_id;

      END IF;

      BEGIN
	SELECT postal_code_from, postal_code_to
	  INTO l_postal_code_from, l_postal_code_to
	  FROM wsh_regions_tl
	 WHERE region_id = l_lane_tbl(i).origin_id
           AND language = USERENV('LANG');
      EXCEPTION
	WHEN OTHERS THEN
          l_lane_tbl.DELETE;
          l_lane_rate_chart_tbl.DELETE;
          l_lane_commodity_tbl.DELETE;
          l_lane_service_tbl.DELETE;
          x_status := 2;
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_REGION_UNKNOWN',
				              p_tokens	=> STRINGARRAY('REGION_NAME'),
				              p_values	=> STRINGARRAY(l_postal_code_from || ' ' ||
								       l_postal_code_to));

	  RETURN;
      END;

      --inserting the region in wsh_zone_regions
      IF (FTE_REGION_ZONE_LOADER.INSERT_PARTY_REGION(p_region_id        => l_lane_tbl(i).origin_id,
				  		     p_parent_region_id => l_lane_tbl(i).origin_id,
				  		     p_supplier_id      => -1,
				  		     p_validate_flag    => TRUE,
				  		     p_postal_code_from => l_postal_code_from_num,
				  		     p_postal_code_to   => l_postal_code_to_num) = -1) THEN

        l_lane_tbl.DELETE;
        l_lane_rate_chart_tbl.DELETE;
        l_lane_commodity_tbl.DELETE;
        l_lane_service_tbl.DELETE;
        x_status := 2;
        x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_REGION_UNKNOWN',
				            p_tokens	=> STRINGARRAY('REGION_NAME'),
				            p_values	=> STRINGARRAY(l_postal_code_from || ' ' ||
								       l_postal_code_to));


	RETURN;
      END IF;

      BEGIN
	SELECT postal_code_from, postal_code_to
	  INTO l_postal_code_from, l_postal_code_to
	  FROM wsh_regions_tl
	 WHERE region_id = l_lane_tbl(i).destination_id
           AND language = USERENV('LANG');
      EXCEPTION
	WHEN OTHERS THEN
          l_lane_tbl.DELETE;
          l_lane_rate_chart_tbl.DELETE;
          l_lane_commodity_tbl.DELETE;
          l_lane_service_tbl.DELETE;
          x_status := 2;
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_REGION_UNKNOWN',
				              p_tokens	=> STRINGARRAY('REGION_NAME'),
				              p_values	=> STRINGARRAY(l_postal_code_from || ' ' ||
								       l_postal_code_to));
	  RETURN;
      END;

      --inserting the region in wsh_zone_regions
      IF (FTE_REGION_ZONE_LOADER.INSERT_PARTY_REGION(p_region_id        => l_lane_tbl(i).destination_id,
				  		     p_parent_region_id => l_lane_tbl(i).destination_id,
				  		     p_supplier_id      => -1,
				  		     p_validate_flag    => TRUE,
				  		     p_postal_code_from => l_postal_code_from_num,
				  		     p_postal_code_to   => l_postal_code_to_num) = -1) THEN

        l_lane_tbl.DELETE;
        l_lane_rate_chart_tbl.DELETE;
        l_lane_commodity_tbl.DELETE;
        l_lane_service_tbl.DELETE;
        x_status := 2;
        x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_REGION_UNKNOWN',
				            p_tokens	=> STRINGARRAY('REGION_NAME'),
				            p_values	=> STRINGARRAY(l_postal_code_from || ' ' ||
								       l_postal_code_to));
	RETURN;
      END IF;

    END LOOP;

    FTE_LANE_PKG.insert_lane_tables(p_lane_tbl			=> l_lane_tbl,
				    p_lane_rate_chart_tbl	=> l_lane_rate_chart_tbl,
				    p_lane_commodity_tbl	=> l_lane_commodity_tbl,
				    p_lane_service_tbl		=> l_lane_service_tbl,
				    x_status			=> x_status,
				    x_error_msg			=> x_error_msg);


    IF (x_status <> -1) THEN
      l_lane_tbl.DELETE;
      l_lane_rate_chart_tbl.DELETE;
      l_lane_commodity_tbl.DELETE;
      l_lane_service_tbl.DELETE;
      RETURN;
    END IF;

    -- rate chart processing
    IF (p_rate_chart_line_table.COUNT > 0) THEN
      FOR I IN P_RATE_CHART_LINE_TABLE.FIRST..P_RATE_CHART_LINE_TABLE.LAST LOOP
        l_rate_line_data(l_rate_line_data.COUNT+1)('ACTION') 	:= l_action;
        l_rate_line_data(l_rate_line_data.COUNT)('CARRIER_ID') 	:= P_RATE_CHART_HEADER_TABLE(p_rate_chart_header_table.FIRST).CARRIER_ID;
        l_rate_line_data(l_rate_line_data.COUNT)('RATE_CHART_NAME') := P_RATE_CHART_HEADER_TABLE(p_rate_chart_header_table.FIRST).CHART_NAME;
        l_rate_line_data(l_rate_line_data.COUNT)('CURRENCY') 	:= P_RATE_CHART_HEADER_TABLE(p_rate_chart_header_table.FIRST).CURRENCY_CODE;
        l_rate_line_data(l_rate_line_data.COUNT)('RATE_BASIS') 	:= P_RATE_CHART_LINE_TABLE(I).RATE_BASIS;
        l_rate_line_data(l_rate_line_data.COUNT)('RATE_BASIS_UOM_CODE') := P_RATE_CHART_LINE_TABLE(I).RATE_BASIS_UOM;
        l_rate_line_data(l_rate_line_data.COUNT)('DISTANCE_TYPE') := P_RATE_CHART_LINE_TABLE(I).DIST_TYPE;
        l_rate_line_data(l_rate_line_data.COUNT)('SERVICE_CODE') 	:= P_RATE_CHART_HEADER_TABLE(p_rate_chart_header_table.FIRST).SERVICE_LEVEL;
        l_rate_line_data(l_rate_line_data.COUNT)('VEHICLE_CODE') 	:= P_RATE_CHART_LINE_TABLE(I).VEHICLE_TYPE;
        l_rate_line_data(l_rate_line_data.COUNT)('RATE') 		:= P_RATE_CHART_LINE_TABLE(I).RATE;
        l_rate_line_data(l_rate_line_data.COUNT)('MINIMUM_CHARGE') := P_RATE_CHART_LINE_TABLE(I).MIN_CHARGE;
        l_rate_line_data(l_rate_line_data.COUNT)('START_DATE') 	:= to_char(P_RATE_CHART_LINE_TABLE(I).START_DATE, FTE_BULKLOAD_PKG.G_DATE_FORMAT);
        l_rate_line_data(l_rate_line_data.COUNT)('END_DATE') 	:= to_char(P_RATE_CHART_LINE_TABLE(I).END_DATE, FTE_BULKLOAD_PKG.G_DATE_FORMAT);

      END LOOP;

      FTE_TL_LOADER.PROCESS_TL_BASE_RATES(p_block_header  => l_block_header,
                      			  p_block_data    => l_rate_line_data,
                    			  p_line_number   => null,
					  p_doValidate	  => FALSE,
                    			  x_status        => x_status,
                    			  x_error_msg     => x_error_msg);
    END IF;

    FTE_TL_LOADER.RESET_ALL;
    l_lane_tbl.DELETE;
    l_lane_rate_chart_tbl.DELETE;
    l_lane_commodity_tbl.DELETE;
    l_lane_service_tbl.DELETE;

    l_rate_line_data.DELETE;

    IF (x_status = -1) THEN
      commit;
    ELSE
      rollback;
    END IF;

  END Edit_TL_Services;

END FTE_SERVICES_UI_WRAPPER;


/
