--------------------------------------------------------
--  DDL for Package FTE_RATE_CHART_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_RATE_CHART_LOADER" AUTHID CURRENT_USER AS
/* $Header: FTERCLDS.pls 120.0 2005/06/28 02:26:54 pkaliyam noship $ */

  ----------------------------------------------------------------------------
  -- PROCEDURE PROCESS_DATA
  --
  -- Purpose: Call appropriate process function according to the type.
  --
  -- IN parameters:
  --	1. p_type:		type of the block (Rating zone chart, rating setup, orign, destination)
  --	2. p_block_header:	pl/sql table of STRINGARRAY containing the block information
  --	3. p_block_data:	pl/sql table of the data
  --	4. p_line_number:	line number for the beginning of the block
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
			  x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
             p_process_id  IN NUMBER DEFAULT NULL,
			       x_status		OUT	NOCOPY 	NUMBER,
			       x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			       x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			       x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			  	     x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
				      x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			   		    x_error_msg		OUT	NOCOPY 	VARCHAR2);

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
			       		 x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
                              x_error_msg     	OUT NOCOPY  VARCHAR2);

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
			  x_error_msg		OUT NOCOPY	VARCHAR2);

  ----------------------------------------------------------------------
  -- PROCEDURE SUBMIT_QP_PROCESS
  --
  -- Purpose: insert all pl/sql tables into QP_INTERFACE_* tables
  ----------------------------------------------------------------------
  PROCEDURE SUBMIT_QP_PROCESS(p_qp_call		IN 	BOOLEAN DEFAULT TRUE,
			      x_status		OUT NOCOPY 	NUMBER,
			      x_error_msg	OUT NOCOPY 	VARCHAR2);


  PROCEDURE INIT_QP_TABLES ;

END FTE_RATE_CHART_LOADER;

 

/
