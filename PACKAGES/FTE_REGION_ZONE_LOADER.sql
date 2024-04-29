--------------------------------------------------------
--  DDL for Package FTE_REGION_ZONE_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_REGION_ZONE_LOADER" AUTHID CURRENT_USER AS
/* $Header: FTERZLRS.pls 120.2.12000000.1 2007/01/18 21:25:55 appldev ship $ */


    -----------------------------------------------------------------------------
    --                                                                         --
    -- NAME:        FTE_REGION_ZONE_LOADER                                     --
    -- TYPE:        SPEC                                                       --
    -- DESCRIPTION: Contains Zone and Region functions for R12 Bulk Loader     --
    --                                                                         --
    -- PROCEDURES and FUNCTIONS:                                               --
    --                                                                         --
    --      FUNCTION: GET_NEXT_REGION_ID                                       --
    --                GET_REGION                                               --
    --                GET_ZONE_ID                                              --
    --                ADD_ZONE                                                 --
    --      PROCEDURE:                                                         --
    --             PROCESS_DATA                                                --
    --             PROCESS_ZONE                                                --
    --             PROCESS_REGION                                              --
    -----------------------------------------------------------------------------

    TYPE ZONE_RECORD IS RECORD(id   NUMBER,
			       name VARCHAR2(100));

    TYPE ZONE_TABLE IS TABLE OF ZONE_RECORD INDEX BY BINARY_INTEGER;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION GET_NEXT_REGION_ID
    --
    -- PURPOSE: Get the next avaiable region id for insertion
    --
    -- Returns region id, -1 if error occured
    --_______________________________________________________________________________________--

    FUNCTION GET_NEXT_REGION_ID RETURN NUMBER;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION  GET_ZONE_ID
    --
    -- Purpose
    --    Get the region_id of a zone from the wsh_regions_tl table.
    --
    -- IN Parameters
    --    1. p_zone_name:     The name of the zone.
    --    2. p_exact_match:   A boolean which specifies whether the match on zone_name
    --                        should be exact.
    --
    -- RETURNS: A p_zone_table.  If a match was found, this p_zone_table contains a
    --          single p_zone_record with the name and id of the FIRST match.
    --          If there was no match found, this p_zone_record is NULL.
    --_______________________________________________________________________________________--

    FUNCTION GET_ZONE_ID(p_zone_name IN VARCHAR2) RETURN NUMBER;

   --_______________________________________________________________________________________--
    --
    -- FUNCTION GET_REGION
    --
    -- Purpose: call wsh_regions_search_pkg and get region information
    --
    -- IN parameters:
    --    1. p_region_info:   region information record
    --
    -- OUT parameters:
    --    1. x_status:        status, -1 if no error
    --    2. x_error_msg:     error message if error
    --_______________________________________________________________________________________--

    FUNCTION GET_REGION_ID(p_region_info IN  wsh_regions_search_pkg.region_rec) RETURN NUMBER;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION GET_REGION_ID
    --
    -- Purpose: call wsh_regions_search_pkg and get region information
    --
    -- IN parameters:
    --    1. p_region_info:   region information record
    --	  2. p_recursively_flag: recursive search flag
    --
    -- OUT parameters:
    --    1. x_status:        status, -1 if no error
    --    2. x_error_msg:     error message if error
    --_______________________________________________________________________________________--

    FUNCTION GET_REGION_ID(p_region_info IN WSH_REGIONS_SEARCH_PKG.REGION_REC,
			   p_recursively_flag	IN VARCHAR2) RETURN NUMBER;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION ADD_ZONE
    --
    -- Purpose: Add a zone to wsh_regions table
    --
    -- IN parameters:
    --    1. p_zone_name:     name of the zone to be added
    --    2. p_validate_flag: validate flag
    --    3. p_supplier_id:   supplier id
    --
    -- OUT parameters:
    --    1. x_status:    status of the processing, -1 means no error
    --    2. x_error_msg: error message if any.
    --
    -- Returns zone id, -1 if any errors occured
    --_______________________________________________________________________________________--


    FUNCTION ADD_ZONE(p_zone_name      IN  VARCHAR2,
                      p_validate_flag  IN  BOOLEAN,
                      p_supplier_id    IN  NUMBER,
                      p_region_type    IN  VARCHAR2) RETURN NUMBER;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION INSERT_PARTY_REGION
    --
    -- Purpose: To insert into wsh_zone_regions for party
    --
    -- IN parameters:
    --    1. p_region_id
    --	  2. p_parent_region_id
    --    3. p_supllier_id
    --    4. p_validate_flag
    --    5. p_postal_code_from
    --    6. p_postal_code_to
    --
    -- RETURN
    --    1. p_part_region_id
    --_______________________________________________________________________________________--

    FUNCTION  INSERT_PARTY_REGION(p_region_id        IN NUMBER,
				  p_parent_region_id IN NUMBER,
				  p_supplier_id      IN NUMBER,
				  p_validate_flag    IN BOOLEAN,
				  p_postal_code_from IN NUMBER,
				  p_postal_code_to   IN NUMBER)
    RETURN NUMBER;
    --_______________________________________________________________________________________--
    --
    -- PROCEDURE PROCESS_ZONE
    --
    -- Purpose: process the lines in p_table for zones
    --
    -- IN parameters:
    --  1. p_table:     pl/sql table of STRINGARRAY containing the block information
    --  2. p_line_number:   line number for the beginning of the block
    --  3. p_region_type:   type of region
    --
    -- OUT parameters:
    --  1. x_status:    status of the processing, -1 means no error
    --  2. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE PROCESS_ZONE (p_block_header    IN   FTE_BULKLOAD_PKG.block_header_tbl,
                            p_block_data      IN   FTE_BULKLOAD_PKG.block_data_tbl,
                            p_line_number     IN   NUMBER,
			    p_region_type     IN   VARCHAR2,
                            x_status          OUT  NOCOPY  NUMBER,
                            x_error_msg       OUT  NOCOPY  VARCHAR2);


    --_______________________________________________________________________________________--
    --
    -- PROCEDURE PROCESS_REGION
    --
    -- PURPOSE: process the lines in p_table for zones
    --
    -- IN parameters:
    --  1. p_table:     pl/sql table of STRINGARRAY containing the block information
    --  2. p_line_number:   line number for the beginning of the block
    --  3. p_region_type:   type of region
    --
    -- OUT parameters:
    --  1. x_status:    status of the processing, -1 means no error
    --  2. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE PROCESS_REGION(p_block_header    IN   FTE_BULKLOAD_PKG.block_header_tbl,
                             p_block_data      IN   FTE_BULKLOAD_PKG.block_data_tbl,
                             p_line_number     IN   NUMBER,
                             x_status          OUT  NOCOPY  NUMBER,
                             x_error_msg       OUT  NOCOPY  VARCHAR2);

    --_______________________________________________________________________________________--
    --
    -- PROCEDURE PROCESS_DATA
    --
    -- Purpose: Call appropriate process function according to the type.
    --
    -- IN parameters:
    --  1. p_type:      type of the block (Zone or Region)
    --  2. p_table:     pl/sql table of STRINGARRAY containing the block information
    --  3. p_line_number:   line number for the beginning of the block
    --
    -- OUT parameters:
    --  1. x_status:    status of the processing, -1 means no error
    --  2. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE PROCESS_DATA(p_type            IN  VARCHAR2,
                           p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                           p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                           p_line_number     IN  NUMBER,
                           x_status          OUT NOCOPY  NUMBER,
                           x_error_msg       OUT NOCOPY  VARCHAR2);




END FTE_REGION_ZONE_LOADER;

 

/
