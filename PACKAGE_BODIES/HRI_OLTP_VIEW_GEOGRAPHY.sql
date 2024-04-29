--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_GEOGRAPHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_GEOGRAPHY" AS
/* $Header: hriovgeo.pkb 120.1 2006/11/01 11:13:53 smohapat noship $ */

/******************************************************************************/
/* This function returns the specific region code for a location.             */
/*                                                                            */
/******************************************************************************/

FUNCTION get_region_code (p_Location_id IN NUMBER)
   RETURN  VARCHAR2 IS

BEGIN
RETURN hri_bpl_geography.get_region_code(p_location_id);


EXCEPTION
  WHEN OTHERS THEN
    RETURN TO_CHAR(NULL);
END get_region_code;

FUNCTION get_country_name (p_country_code IN VARCHAR2)
   RETURN  VARCHAR2 IS

   CURSOR ctry_name_cur IS
     SELECT terr.territory_short_name
     FROM fnd_territories_tl terr
     WHERE LANGUAGE = userenv('LANG')
     and terr.territory_code = p_country_code;

     l_country_name varchar2(90);

BEGIN

  OPEN ctry_name_cur ;

  FETCH ctry_name_cur INTO l_country_name ;
  RETURN l_country_name;

  CLOSE ctry_name_cur;

EXCEPTION
  WHEN OTHERS THEN
    RETURN TO_CHAR(NULL);
END get_country_name;
END;

/
