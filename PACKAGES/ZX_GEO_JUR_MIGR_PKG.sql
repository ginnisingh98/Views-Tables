--------------------------------------------------------
--  DDL for Package ZX_GEO_JUR_MIGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_GEO_JUR_MIGR_PKG" AUTHID CURRENT_USER AS
/* $Header: zxgeojurmigrs.pls 120.8 2005/10/14 22:52:46 sachandr ship $ */


/*THIS PROCEDURE IS USED TO CREATE GEOGRAPHY TYPES */
PROCEDURE CREATE_GEO_TYPE;
PROCEDURE CREATE_ZONE_TYPE;


PROCEDURE CREATE_ZONE_RANGE(p_zone_type IN VARCHAR2,
                            p_zone_name IN VARCHAR2,
                            p_zone_code IN VARCHAR2,
                            p_zone_code_type IN VARCHAR2,
                            p_zone_name_prefix IN VARCHAR2,
                            p_start_date IN DATE,
                            p_end_date IN DATE,
                            p_zone_relation_tbl IN HZ_GEOGRAPHY_PUB.ZONE_RELATION_TBL_TYPE,
                            x_zone_geography_id OUT NOCOPY NUMBER);

END;

 

/
