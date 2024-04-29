--------------------------------------------------------
--  DDL for Package FTE_LANE_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_LANE_LOADER" AUTHID CURRENT_USER AS
/* $Header: FTELNLDS.pls 120.0 2005/06/28 02:23:45 pkaliyam noship $ */

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
			  x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			     x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			 	   	  x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			      x_error_msg	OUT	NOCOPY 	VARCHAR2);

  ----------------------------------------------------------------------
  -- PROCEDURE SUBMIT_LANE
  --
  -- Purpose: insert all pl/sql tables into fte_lane_* tables
  ----------------------------------------------------------------------
  PROCEDURE SUBMIT_LANE(x_status	OUT NOCOPY 	NUMBER,
			x_error_msg	OUT NOCOPY 	VARCHAR2);


END FTE_LANE_LOADER;

 

/
