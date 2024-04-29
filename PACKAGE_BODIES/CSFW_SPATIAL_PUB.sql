--------------------------------------------------------
--  DDL for Package Body CSFW_SPATIAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_SPATIAL_PUB" as
/*$Header: csfwsplb.pls 120.0 2005/05/24 17:43:49 appldev noship $*/

/*
FUNCTION GET_AERIAL_DISTANCE( p_start_point MDSYS.SDO_GEOMETRY,
                             p_end_point    MDSYS.SDO_GEOMETRY,
            			     p_unit_of_measure varchar2 )
This function would find oput the distance between 2 points(MSDSYS.SDO_GEOMETRY)
In 8i, the distance computation assumes the coordinate system is NULL. So we would
convert the geometries to a projected coordinate system(Cartesian) and then do distance computation.
in that case this function would find out the longitude and latituide of the to and from points
and then calls
FUNCTION GET_AERIAL_DISTANCE(   p_start_longitude number,
                                p_start_latitude,
                                p_end_longitude ,
                                p_end_latitude  ,
                                p_unit_of_measure varchar2 )

*/

FUNCTION GET_AERIAL_DISTANCE(p_start_point MDSYS.SDO_GEOMETRY,
                             p_end_point    MDSYS.SDO_GEOMETRY,
                             p_unit_of_measure varchar2 )
RETURN number IS
x_distance NUMBER;
l_start_logitude number;
l_start_latitude number;
l_end_logitude   number;
l_end_latitude   number;
l_db_version     number;

BEGIN
    --initialize with 0;
    x_distance := 0;

        --MDSYS.GEOMETRY has longitude defined as SDO_POINT.x
        -- and latitude as SDO_POINT.y.So lets populate the longitude and latitude
        --for the start and end points
        l_start_logitude := p_start_point.sdo_point.x ;
        l_start_latitude := p_start_point.sdo_point.y ;
        l_end_logitude   := p_end_point.sdo_point.x ;
        l_end_latitude   := p_end_point.sdo_point.y ;



        --Check if the points are same
        IF ( (l_start_logitude = l_end_logitude) AND
            (l_start_latitude = l_end_latitude) ) THEN
            return 0;
        END IF;


        --now lets find out the distance by calling the other function
        x_distance :=
            GET_AERIAL_DISTANCE(   l_start_logitude,l_start_latitude, l_end_logitude ,l_end_latitude  , p_unit_of_measure );

    --end if;


    -- Now lets return the Distance
    RETURN x_distance ;

END GET_AERIAL_DISTANCE;



/*
This function does the distance(big Circle) calculation depending on the longitude and latitude of the two points
now, the formula we use to calculate the distance is
Ths distance between two points P and A is
Distance = ACOS ( (sin a * sin p) + (cos a * cos p * cos (dL) ) )
where,
    a = latitude of point A,
    p = latitude of point P,
    dL = is the absolute value of the difference in longitude between P and A
*/

FUNCTION GET_AERIAL_DISTANCE(   p_start_longitude number,
                                p_start_latitude  number,
                                p_end_longitude   number,
                                p_end_latitude    number,
                                p_unit_of_measure varchar2 )
RETURN NUMBER IS
PI NUMBER := 3.14159265358979323846;
    lat1 NUMBER := p_start_latitude * (PI/180.0);
    lat2 NUMBER := p_end_latitude * (PI/180.0);
    lon1 NUMBER := p_start_longitude * (PI/180.0);
    lon2 NUMBER := p_end_longitude * (PI/180.0);
    x_distance_in_meters number;

BEGIN

    --Check if the points are same
    IF ( (p_start_longitude = p_end_longitude) AND
       (p_start_latitude = p_end_latitude) ) THEN
            return 0;
    END IF;


    x_distance_in_meters :=
    ACOS(SIN(lat1)*SIN(lat2) + COS(lat1)*COS(lat2)*COS(lon2 - lon1)) * 6371200.0;

    IF ( p_unit_of_measure = 'KM' OR p_unit_of_measure = 'KILOMETER' ) THEN
	RETURN x_distance_in_meters/1000;
    END IF;




RETURN (x_distance_in_meters/1609.344); --Distance in Miles

END GET_AERIAL_DISTANCE;



FUNCTION CHECK_GEOMETRY_POINT(  p_point MDSYS.SDO_GEOMETRY)
         RETURN VARCHAR is

l_longitude  NUMBER;
l_latitude   NUMBER;
x_return_value VARCHAR2(1);


BEGIN

	x_return_value := 'T';

	IF (p_point.sdo_point IS null)THEN
	    RETURN 'F';
	end if;

	l_longitude  := p_point.sdo_point.x;
	l_latitude   := p_point.sdo_point.y;

	IF ((l_longitude = NULL) OR (l_latitude = NULL))
	THEN
		x_return_value := 'F';
	END IF;

	RETURN x_return_value;

	EXCEPTION
		WHEN OTHERS THEN
		RETURN 'F';

END CHECK_GEOMETRY_POINT;




END CSFW_SPATIAL_PUB;


/
