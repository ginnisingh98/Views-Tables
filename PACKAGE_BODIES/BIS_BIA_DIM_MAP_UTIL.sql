--------------------------------------------------------
--  DDL for Package Body BIS_BIA_DIM_MAP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_DIM_MAP_UTIL" AS
/*$Header: BISDIMUB.pls 120.1 2006/05/09 13:11:55 aguwalan noship $*/

g_current_user_id         NUMBER  :=  FND_GLOBAL.User_id;
g_current_login_id        NUMBER  :=  FND_GLOBAL.Login_id;

/*This API is not been used currently. It was introduced to show countries asscociated to Area in Serach Page
Its kept for future use*/
/* Bug#5203008 :: Commenting this api since its SQL is being reported in Performance Repository and is not
 * used anyways
 */
/*FUNCTION GET_COUNTRIES_BY_AREA(p_AREA_CODE VARCHAR2) RETURN VARCHAR2
  IS
    CURSOR c_countries (l_AREA_CODE bis_areas_v.AREA_CODE%type)
    IS
       select
	con.name name
	from BIS_TERRITORY_HIERARCHIES ter,
	bis_countries_v con
	where ter.CHILD_TERRITORY_CODE = con.country_code
	and ter.parent_territory_code = l_AREA_CODE;

    l_countries   varchar(4000);

  begin

    for c_countries_rec in c_countries(p_AREA_CODE) loop
      l_countries := l_countries || c_countries_rec.name || ', ';
    end loop;

    l_countries := substr(l_countries, 1, length(l_countries) - 2);
    return l_countries;
  end;
*/

 /*This API adds are and country association.  THis is been called from UI.
  Here we do not have validation as all the validations are already been done on frontend part.*/

PROCEDURE ADD_AREA_COUNTRY_ASSOCIATION (p_area_code VARCHAR2 ,
					p_country_code VARCHAR2
					)
IS
BEGIN
INSERT into BIS_TERRITORY_HIERARCHIES (PARENT_TERRITORY_CODE,
					PARENT_TERRITORY_TYPE,
					CHILD_TERRITORY_CODE,
					CHILD_TERRITORY_TYPE,
					START_DATE_ACTIVE,
					END_DATE_ACTIVE,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATE_LOGIN)
				 values(p_area_code,
					'AREA',
					p_country_code,
					'COUNTRY',
					sysdate,
					sysdate,
					g_current_user_id,
					sysdate,
					g_current_user_id,
					sysdate,
					g_current_login_id);
 commit;

 EXCEPTION
	WHEN OTHERS THEN
	 RAISE;

 END ADD_AREA_COUNTRY_ASSOCIATION;

/* This API is been called from UI to delete are_country association.
We need not to do any validation here*/

PROCEDURE DEL_AREA_COUNTRY_ASSO(p_area_code VARCHAR2 )
IS
BEGIN

Delete BIS_TERRITORY_HIERARCHIES where PARENT_TERRITORY_CODE = p_area_code;

commit;

 EXCEPTION
	WHEN OTHERS THEN
	 RAISE;

 END DEL_AREA_COUNTRY_ASSO;


END BIS_BIA_DIM_MAP_UTIL;

/
