--------------------------------------------------------
--  DDL for Package CSFW_SPATIAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_SPATIAL_PUB" AUTHID CURRENT_USER as
/* $Header: csfwspls.pls 120.0 2005/05/25 11:12:28 appldev noship $ */
-- Start of Comments
-- Package name     : CSFW_SPATIAL_PUB
-- Purpose          : to get the distance between 2 points
-- History          :
-- NOTE             : Please see the function details for additional information
-- End of Comments

FUNCTION GET_AERIAL_DISTANCE(   p_start_point MDSYS.SDO_GEOMETRY,
                                p_end_point      MDSYS.SDO_GEOMETRY,
                                p_unit_of_measure varchar2 )
         RETURN number;


FUNCTION GET_AERIAL_DISTANCE(   p_start_longitude number,
                                p_start_latitude  number,
                                p_end_longitude   number,
                                p_end_latitude    number,
                                p_unit_of_measure varchar2 )
          RETURN number;

FUNCTION CHECK_GEOMETRY_POINT(  p_point MDSYS.SDO_GEOMETRY)
         RETURN VARCHAR;



END CSFW_SPATIAL_PUB;

 

/
