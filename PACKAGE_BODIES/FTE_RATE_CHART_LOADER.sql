--------------------------------------------------------
--  DDL for Package Body FTE_RATE_CHART_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_RATE_CHART_LOADER" AS
/* $Header: FTERCLDB.pls 120.0 2005/06/28 02:27:32 pkaliyam noship $ */
 -------------------------------------------------------------------------- --
 --                                                                         --
 -- NAME:        FTE_RATE_CHART_LOADER                                      --
 -- TYPE:        PACKAGE BODY                                               --
 -- DESCRIPTION: Contains Rate Chart Validations for Bulk Loader purposes   --
 --                                                                         --
 -------------------------------------------------------------------------- --

  G_PKG_NAME         CONSTANT  VARCHAR2(50) := 'FTE_RATE_CHART_LOADER';
  g_qp_list_header_tbl		FTE_RATE_CHART_PKG.qp_list_header_tbl;
  g_qp_list_line_tbl		FTE_RATE_CHART_PKG.qp_list_line_tbl;
  g_qp_qualifier_tbl		FTE_RATE_CHART_PKG.qp_qualifier_tbl;
  g_qp_pricing_attrib_tbl	FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl;
  g_carrier_id		NUMBER;
  g_list_header_deleted	BOOLEAN := false;

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

    IF (p_type = 'RATE_CHART') THEN
      PROCESS_RATE_CHART(p_block_header	=> p_block_header,
			 p_block_data	=> p_block_data,
			 p_line_number	=> p_line_number,
			 x_status	=> x_status,
			 x_error_msg	=> x_error_msg);
    ELSIF (p_type = 'RATE_LINE') THEN
      PROCESS_RATE_LINE(p_block_header	=> p_block_header,
			p_block_data	=> p_block_data,
			p_line_number	=> p_line_number,
			x_status	=> x_status,
			x_error_msg	=> x_error_msg);
    ELSIF (p_type = 'RATE_BREAK') THEN
      PROCESS_RATE_BREAK(p_block_header	=> p_block_header,
			 p_block_data	=> p_block_data,
		     	 p_line_number	=> p_line_number,
		     	 x_status	=> x_status,
		     	 x_error_msg	=> x_error_msg);
    ELSIF (p_type = 'RATING_ATTRIBUTE') THEN
      PROCESS_RATING_ATTRIBUTE(p_block_header	=> p_block_header,
			       p_block_data	=> p_block_data,
			       p_line_number	=> p_line_number,
			       x_status		=> x_status,
			       x_error_msg	=> x_error_msg);
    ELSIF (p_type = 'CHARGES_DISCOUNTS') THEN
      PROCESS_CHARGES_DISCOUNTS(p_block_header	=> p_block_header,
			 	p_block_data	=> p_block_data,
			  	p_line_number	=> p_line_number,
			  	x_status	=> x_status,
			  	x_error_msg	=> x_error_msg);
    ELSIF (p_type = 'CHARGES_DISCOUNTS_LINE') THEN
      PROCESS_CHARGES_DISCOUNTS_LINE(p_block_header	=> p_block_header,
				     p_block_data	=> p_block_data,
			  	     p_line_number	=> p_line_number,
			  	     x_status		=> x_status,
			  	     x_error_msg	=> x_error_msg);
    ELSIF (p_type = 'ADJUSTED_RATE_CHART') THEN
      PROCESS_ADJUSTED_RATE_CHART(p_block_header	=> p_block_header,
			 	  p_block_data	=> p_block_data,
			  	  p_line_number	=> p_line_number,
			  	  x_status	=> x_status,
			  	  x_error_msg	=> x_error_msg);
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
  -- PROCEDURE PROCESS_RATE_CHART
  --
  -- Purpose: process the lines in p_table for rate chart header
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --	4. p_validate_column:	boolean for calling VALIDATE_COLUMNS, default true
  --	5. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_RATE_CHART(p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			       p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			       p_line_number	IN	NUMBER,
			       p_validate_column IN 	BOOLEAN DEFAULT TRUE,
			       p_validate 	IN 	BOOLEAN DEFAULT TRUE,
		               p_process_id  	IN 	NUMBER DEFAULT NULL,
			       x_status		OUT	NOCOPY 	NUMBER,
			       x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_action		VARCHAR2(20);
  l_carrier_id		NUMBER;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_RATE_CHART';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (p_validate_column) THEN
      --verify the column name
      FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys	=> p_block_header,
				          p_type	=> 'RATE_CHART',
					  p_line_number	=> p_line_number+1,
				          x_status	=> x_status,
				          x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);
      FTE_VALIDATION_PKG.VALIDATE_RATE_CHART(p_values		=> l_values,
					     p_line_number 	=> p_line_number+i+1,
				             p_qp_list_header_tbl	=> g_qp_list_header_tbl,
					     p_qp_qualifier_tbl	=> g_qp_qualifier_tbl,
					     p_action		=> l_action,
					     p_carrier_id	=> l_carrier_id,
					     p_validate		=> p_validate,
			            	     p_process_id 	=> p_process_id,
				       	     x_status		=> x_status,
				       	     x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	RETURN;
      END IF;

      g_carrier_id := l_carrier_id;

      IF (l_action = 'DELETE') THEN
        FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).list_header_id,
					  p_name 	   => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).name,
					  p_action	   => l_action,
					  p_line_number	   => p_line_number+i+1,
                          		  x_error_msg      => x_error_msg,
                           		  x_status         => x_status );

	g_list_header_deleted := true;
      ELSIF (l_action = 'UPDATE') THEN

	FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).list_header_id,
					  p_name 	   => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).name,
					  p_action	   => l_action,
					  p_line_number	   => p_line_number+i+1,
            		  		  x_error_msg      => x_error_msg,
              				  x_status         => x_status );


        FTE_LANE_PKG.UPDATE_LANE_RATE_CHART(p_list_header_id => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).list_header_id,
					    p_start_date => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).start_date_active,
					    p_end_date => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).end_date_active,
					    x_status => x_status,
					    x_error_msg => x_error_msg);

      END IF;

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
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_RATE_CHART;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_RATE_LINE
  --
  -- Purpose: process the lines in p_table for rate chart line
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --	4. p_validate_column:	boolean for calling VALIDATE_COLUMNS, default true
  --	5. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_RATE_LINE (p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			       p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			       p_line_number	IN	NUMBER,
			       p_validate_column IN 	BOOLEAN DEFAULT TRUE,
			       p_validate 	IN 	BOOLEAN DEFAULT TRUE,
			       x_status		OUT	NOCOPY 	NUMBER,
			       x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_RATE_LINE';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (g_list_header_deleted) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (p_validate_column) THEN
      --verify the column name
      FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys	=> p_block_header,
				          p_type	=> 'RATE_LINE',
  					  p_line_number	=> p_line_number+1,
				          x_status	=> x_status,
				          x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_RATE_LINE(p_values		=> l_values,
					    p_line_number 	=> p_line_number+i+1,
				            p_qp_list_line_tbl	=> g_qp_list_line_tbl,
					    p_qp_pricing_attrib_tbl	=> g_qp_pricing_attrib_tbl,
					    p_validate		=> p_validate,
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
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_RATE_LINE;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_RATE_BREAK
  --
  -- Purpose: process the lines in p_table for rate chart break
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --	4. p_validate_column:	boolean for calling VALIDATE_COLUMNS, default true
  --	5. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_RATE_BREAK(p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			       p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			       p_line_number	IN	NUMBER,
			       p_validate_column IN 	BOOLEAN DEFAULT TRUE,
			       p_validate 	IN 	BOOLEAN DEFAULT TRUE,
			       x_status		OUT	NOCOPY 	NUMBER,
			       x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_RATE_BREAK';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (g_list_header_deleted) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (p_validate_column) THEN
      --verify the column name

      FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys	=> p_block_header,
				          p_type	=> 'RATE_BREAK',
 					  p_line_number	=> p_line_number+1,
				          x_status	=> x_status,
				          x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_RATE_BREAK(p_values		=> l_values,
					     p_line_number 	=> p_line_number+i+1,
				             p_qp_list_line_tbl	=> g_qp_list_line_tbl,
					     p_qp_pricing_attrib_tbl	=> g_qp_pricing_attrib_tbl,
					     p_validate		=> p_validate,
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
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_RATE_BREAK;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_RATING_ATTRIBUTE
  --
  -- Purpose: process the lines in p_table for rate chart line attribute
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --	4. p_validate_column:	boolean for calling VALIDATE_COLUMNS, default true
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_RATING_ATTRIBUTE(p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			   	     p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			       	     p_line_number	IN	NUMBER,
				     p_validate_column 	IN 	BOOLEAN DEFAULT TRUE,
			   	     x_status		OUT	NOCOPY 	NUMBER,
			  	     x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_RATING_ATTRIBUTE';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (g_list_header_deleted) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (p_validate_column) THEN
      --verify the column name
      FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys	=> p_block_header,
				          p_type	=> 'RATING_ATTRIBUTE',
					  p_line_number	=> p_line_number+1,
				          x_status	=> x_status,
				          x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_RATING_ATTRIBUTE(p_values		=> l_values,
					  	   p_line_number 	=> p_line_number+i+1,
					  	   p_qp_pricing_attrib_tbl	=> g_qp_pricing_attrib_tbl,
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
	               		  p_msg  	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_RATING_ATTRIBUTE;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_CHARGES_DISCOUNTS
  --
  -- Purpose: process the lines in p_table for charges and discounts header
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --	4. p_validate_column:	boolean for calling VALIDATE_COLUMNS, default true
  --	5. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_CHARGES_DISCOUNTS(p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			   	      p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			 	      p_line_number	IN	NUMBER,
				      p_validate_column IN 	BOOLEAN DEFAULT TRUE,
				      p_validate 	IN 	BOOLEAN DEFAULT TRUE,
				      x_status		OUT	NOCOPY 	NUMBER,
				      x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_action		VARCHAR2(20);
  l_carrier_id		NUMBER;

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_CHARGES_DISCOUNTS';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (p_validate_column) THEN
      --verify the column name
      FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys	=> p_block_header,
				          p_type	=> 'CHARGES_DISCOUNTS',
					  p_line_number	=> p_line_number+1,
				          x_status	=> x_status,
				          x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_RATE_CHART(p_values		=> l_values,
					     p_line_number 	=> p_line_number+i+1,
				             p_qp_list_header_tbl	=> g_qp_list_header_tbl,
					     p_qp_qualifier_tbl	=> g_qp_qualifier_tbl,
				       	     p_action		=> l_action,
					     p_carrier_id	=> l_carrier_id,
					     p_validate		=> p_validate,
					     x_status		=> x_status,
				       	     x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	RETURN;
      END IF;
      g_carrier_id := l_carrier_id;

      IF (l_action = 'DELETE') THEN
        FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).list_header_id,
					  p_name 	   => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).name,
					  p_action	   => l_action,
					  p_line_number	   => p_line_number+i+1,
                          		  x_error_msg      => x_error_msg,
                           		  x_status         => x_status );

	g_list_header_deleted := true;
      ELSIF (l_action = 'UPDATE') THEN

	FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).list_header_id,
					  p_name 	   => g_qp_list_header_tbl(g_qp_list_header_tbl.COUNT).name,
					  p_action	   => l_action,
					  p_line_number	   => p_line_number+i+1,
            		  		  x_error_msg      => x_error_msg,
              				  x_status         => x_status );
      END IF;

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	RETURN;
      END IF;

    END LOOP;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg  	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_CHARGES_DISCOUNTS;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_CHARGES_DISCOUNTS_LINE
  --
  -- Purpose: process the lines in p_table for charges and discounts line
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --	4. p_validate_column:	boolean for calling VALIDATE_COLUMNS, default true
  --	5. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_CHARGES_DISCOUNTS_LINE (p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			       		    p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			       		    p_line_number	IN	NUMBER,
					    p_validate_column 	IN 	BOOLEAN DEFAULT TRUE,
				   	    p_validate 		IN 	BOOLEAN DEFAULT TRUE,
			   		    x_status		OUT	NOCOPY 	NUMBER,
			   		    x_error_msg		OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_CHARGES_DISCOUNTS_LINE';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;


    IF (g_list_header_deleted) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    --verify the column name
    IF (p_validate_column) THEN
      FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys	=> p_block_header,
	  			          p_type	=> 'CHARGES_DISCOUNTS_LINE',
					  p_line_number	=> p_line_number+1,
				          x_status	=> x_status,
				          x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;
    END IF;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_RATE_LINE(p_values		=> l_values,
					    p_line_number 	=> p_line_number+i+1,
				            p_qp_list_line_tbl	=> g_qp_list_line_tbl,
					    p_qp_pricing_attrib_tbl	=> g_qp_pricing_attrib_tbl,
					    p_validate		=> p_validate,
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
	               		  p_msg  	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_CHARGES_DISCOUNTS_LINE;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_ADJUSTED_RATE_CHART
  --
  -- Purpose: process the lines in p_table for charges and discounts' rate chart
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_ADJUSTED_RATE_CHART (p_block_header	IN	FTE_BULKLOAD_PKG.block_header_tbl,
			       		 p_block_data	IN	FTE_BULKLOAD_PKG.block_data_tbl,
			    		 p_line_number	IN	NUMBER,
			       		 x_status	OUT	NOCOPY 	NUMBER,
			       		 x_error_msg	OUT	NOCOPY 	VARCHAR2) IS

  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_ADJUSTED_RATE_CHART';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;


    IF (g_list_header_deleted) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    --verify the column name
    FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys		=> p_block_header,
				        p_type		=> 'ADJUSTED_RATE_CHART',
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

      FTE_VALIDATION_PKG.VALIDATE_ADJUSTED_RATE_CHART(p_values		=> l_values,
						      p_line_number 	=> p_line_number+i+1,
						      p_carrier_id	=> g_carrier_id,
				    		      p_qp_qualifier_tbl	=> g_qp_qualifier_tbl,
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
	               		  p_msg  	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_ADJUSTED_RATE_CHART;

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_QUALIFIER
  --
  -- Purpose: process the qualifiers for TL Rate Chart
  --
  -- IN parameters:
  --	1. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	2. p_block_data:	pl/sql table of the data
  --	3. p_line_number:	line number for the beginning of the block
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE PROCESS_QUALIFIER(p_block_header 	IN  FTE_BULKLOAD_PKG.block_header_tbl,
                              p_block_data    	IN  FTE_BULKLOAD_PKG.block_data_tbl,
                              p_line_number   	IN  NUMBER,
                              x_status        	OUT NOCOPY  NUMBER,
                              x_error_msg     	OUT NOCOPY  VARCHAR2) IS
  l_values		FTE_BULKLOAD_PKG.data_values_tbl;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_QUALIFIER';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    --now the body of the block
    FOR i IN p_block_data.FIRST..p_block_data.LAST LOOP
      l_values := p_block_data(i);

      FTE_VALIDATION_PKG.VALIDATE_QUALIFIER(p_values		=> l_values,
					    p_line_number 	=> p_line_number+i+1,
				    	    p_qp_qualifier_tbl	=> g_qp_qualifier_tbl,
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
	               		  p_msg  	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END PROCESS_QUALIFIER;

  ----------------------------------------------------------------------------
  -- PROCEDURE ADD_ATTRIBUTE
  --
  -- Purpose: process the attributes from the UI by directly adding it to pricing attrib tbl
  --
  -- IN parameters:
  --	1. p_pricing_attribute:		type of the attribute
  --	2. p_attr_value_from:		value of the attribute
  --	3. p_linenum:			line number
  --
  -- OUT parameters:
  --	1. x_status:	status of the processing, -1 means no error
  --	2. x_error_msg:	error message if any.
  ----------------------------------------------------------------------------

  PROCEDURE ADD_ATTRIBUTE(p_pricing_attribute 	IN 	VARCHAR2,
                      	  p_attr_value_from    	IN 	VARCHAR2,
                      	  p_line_number         IN	NUMBER,
                      	  x_status             	OUT NOCOPY	NUMBER,
			  x_error_msg		OUT NOCOPY	VARCHAR2) IS
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.ADD_ATTRIBUTE';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    FTE_VALIDATION_PKG.ADD_ATTRIBUTE(p_pricing_attribute  => p_pricing_attribute,
                      		     p_attr_value_from    => p_attr_value_from,
                      		     p_attr_value_to      => NULL,
                      		     p_line_number        => p_line_number,
                      		     p_context            => 'LOGISTICS',
                      		     p_comp_operator      => NULL,
		      		     p_qp_pricing_attrib_tbl => g_qp_pricing_attrib_tbl,
                      		     x_status             => x_status,
				     x_error_msg	  => x_error_msg);
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg  	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END ADD_ATTRIBUTE;

  ----------------------------------------------------------------------
  -- PROCEDURE SUBMIT_QP_PROCESS
  --
  -- Purpose: insert all pl/sql tables into QP_INTERFACE_* tables
  ----------------------------------------------------------------------

  PROCEDURE SUBMIT_QP_PROCESS(p_qp_call		IN 	BOOLEAN DEFAULT TRUE,
			      x_status		OUT NOCOPY 	NUMBER,
			      x_error_msg	OUT NOCOPY 	VARCHAR2) IS
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.SUBMIT_QP_PROCESS';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (g_list_header_deleted) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- have to check if the lanes that has no commodity have to have basis
    FTE_RATE_CHART_PKG.INSERT_QP_INTERFACE_TABLES(p_qp_list_header_tbl		=> g_qp_list_header_tbl,
				    		  p_qp_list_line_tbl		=> g_qp_list_line_tbl,
				    		  p_qp_qualifier_tbl		=> g_qp_qualifier_tbl,
				    		  p_qp_pricing_attrib_tbl	=> g_qp_pricing_attrib_tbl,
						  p_qp_call			=> p_qp_call,
				 		  x_status			=> x_status,
				 		  x_error_msg			=> x_error_msg);
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		  p_msg  	=> sqlerrm,
	               		  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;

  END SUBMIT_QP_PROCESS;

  ----------------------------------------------------------------------
  -- PROCEDURE INIT_QP_TABLES
  --
  -- Purpose: initialize all pl/sql tables
  ----------------------------------------------------------------------

  PROCEDURE INIT_QP_TABLES IS
  BEGIN

    g_qp_list_header_tbl.DELETE;
    g_qp_list_line_tbl.DELETE;
    g_qp_qualifier_tbl.DELETE;
    g_qp_pricing_attrib_tbl.DELETE;

  END INIT_QP_TABLES;


END FTE_RATE_CHART_LOADER;

/
