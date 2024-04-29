--------------------------------------------------------
--  DDL for Package Body BIS_BIA_RSG_GENERATOR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_RSG_GENERATOR_UTIL" AS
/*$Header: BISARGUB.pls 120.0 2005/06/01 15:40:07 appldev noship $*/

  FUNCTION GET_CONC_PAGES_BY_REQUEST_SET( P_SET_NAME VARCHAR2)
  RETURN VARCHAR2
  IS
    CURSOR C_PAGES ( P_SET_NAME bis_request_set_objects_v.user_object_name%type )
    IS
    select
      user_object_name
    from
      bis_request_set_objects_v
    where request_set_name = P_SET_NAME;
    l_page_name       bis_request_set_objects_v.user_object_name%type;
    l_page_name_conc  VARCHAR2(32767);

  begin
    open C_PAGES(P_SET_NAME);
    loop
      fetch C_PAGES into l_page_name;
      exit when C_PAGES%NOTFOUND;
      l_page_name_conc := l_page_name_conc || l_page_name || ', ';
    end loop;
    close C_PAGES;
    l_page_name_conc := substr(l_page_name_conc, 1, length(l_page_name_conc) - 2);
    return l_page_name_conc;
  end;

  --FUNCTION IS_INCR_REF_PREINIT( P_FORCE_FULL VARCHAR2, P_REFRESH_MODE VARCHAR2)
  FUNCTION GET_LOAD_SUMMARY_OPTION( P_FORCE_FULL VARCHAR2, P_REFRESH_MODE VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
   IF(P_FORCE_FULL = 'N' and P_REFRESH_MODE = 'INIT') THEN
     /*Initial Load (Incrementally refreshes previously collected summaries) */
     RETURN 'INCR_INIT_LK';
   ELSIF(P_FORCE_FULL = 'Y' and P_REFRESH_MODE = 'INIT') THEN
     /*Clear and Load all summaries */
     RETURN 'INIT_LK';
   ELSIF(P_REFRESH_MODE = 'INCR') THEN
     RETURN 'INCR_LK';
   ELSE
     RETURN NULL;
   END IF;
  END;


  FUNCTION GET_LOAD_SUMMARY_OPTION_LK( P_FORCE_FULL VARCHAR2, P_REFRESH_MODE VARCHAR2)
  RETURN VARCHAR2 IS
    CURSOR C_BIS_LK(p_type VARCHAR2, p_code VARCHAR2) IS
    select distinct meaning
    from fnd_common_lookups
    where lookup_type= p_type
    and lookup_code=NVL(p_code, 'N');

    CURSOR C_SYS_LK(p_type VARCHAR2, p_code VARCHAR2) IS
    select distinct meaning
    from fnd_lookups
    where lookup_type= p_type
    and lookup_code=NVL(p_code, 'N');

    l_lk  varchar2(2000);
  BEGIN
   IF(P_FORCE_FULL = 'N' and P_REFRESH_MODE = 'INIT') THEN
     /*Initial Load (Incrementally refreshes previously collected summaries) */
     l_lk := FND_MESSAGE.GET_STRING('BIS', 'BIS_BIA_RSG_GEN_OPT1');
     RETURN l_lk;
   ELSIF(P_FORCE_FULL = 'Y' and P_REFRESH_MODE = 'INIT') THEN
     /*Clear and Load all summaries */
     OPEN C_BIS_LK('BIS_BIA_RSG_GENERATOR_LOAD_OPT', 'INIT_LK');
     FETCH C_BIS_LK into l_lk;
     CLOSE C_BIS_LK;
     RETURN l_lk;
   ELSIF(P_REFRESH_MODE = 'INCR') THEN
     OPEN C_BIS_LK('BIS_BIA_RSG_GENERATOR_LOAD_OPT', 'INCR_LK');
     FETCH C_BIS_LK into l_lk;
     CLOSE C_BIS_LK;
     RETURN l_lk;
   ELSE
     OPEN C_SYS_LK('YES_NO', 'N');
     FETCH C_SYS_LK into l_lk;
     CLOSE C_SYS_LK;
     RETURN l_lk;
   END IF;
  END;


END BIS_BIA_RSG_GENERATOR_UTIL;

/
