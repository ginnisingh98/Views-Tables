--------------------------------------------------------
--  DDL for Package EDW_GEOGRAPHY_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_GEOGRAPHY_M_C" AUTHID CURRENT_USER AS
	/*$Header: poaphge.pkh 120.1 2005/06/13 13:08:49 sriswami noship $ */
   Procedure Push(Errbuf        in out NOCOPY Varchar2,
                  Retcode       in out NOCOPY Varchar2,
                  p_from_date   IN  Varchar2,
                  p_to_date     IN  Varchar2);
   Procedure Push_EDW_GEOG_LOCATION_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_GEOG_POSTCODE_CITY_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GEOG_CITY_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GEOG_POSTCODE_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_GEOG_STATE_REGION_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GEOG_STATE_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GEOG_REGION_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GEOG_COUNTRY_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GEOG_AREA2_LSTG(p_from_date IN date, p_to_date IN DATE);
   Procedure Push_EDW_GEOG_AREA1_LSTG(p_from_date IN date, p_to_date IN DATE);
End EDW_GEOGRAPHY_M_C;

 

/
