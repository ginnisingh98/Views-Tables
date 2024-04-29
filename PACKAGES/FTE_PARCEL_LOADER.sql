--------------------------------------------------------
--  DDL for Package FTE_PARCEL_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_PARCEL_LOADER" AUTHID CURRENT_USER AS
/* $Header: FTEPCLDS.pls 120.0 2005/06/28 02:25:50 pkaliyam noship $ */

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
			  x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			  	      x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			  	 x_error_msg	OUT	NOCOPY 	VARCHAR2);

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
			   x_error_msg		OUT	NOCOPY 	VARCHAR2);

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
			        x_error_msg	OUT	NOCOPY 	VARCHAR2);

  TYPE service_array IS VARRAY (10) OF NUMBER;

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
				    x_error_msg		OUT	NOCOPY VARCHAR2);

END FTE_PARCEL_LOADER;

 

/
