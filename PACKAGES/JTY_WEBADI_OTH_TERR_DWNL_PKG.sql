--------------------------------------------------------
--  DDL for Package JTY_WEBADI_OTH_TERR_DWNL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_WEBADI_OTH_TERR_DWNL_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfowdps.pls 120.10.12010000.6 2008/11/01 05:26:59 appldev ship $ */

-- ===========================================================================+

-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_OTH_WEBADI_PKG
--    ---------------------------------------------------
--
--    PURPOSE
--
--      WebAdi Other Territory Upload package.
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      08/18/2005              mhtran    created

--  ===============================================================
--    End of Comments

  TYPE terr_id_tbl_type is table of JTF_TERR_ALL.TERR_ID%TYPE;
  TYPE terr_name_tbl_type is table of JTF_TERR_ALL.NAME%TYPE;
  TYPE rank_tbl_type is table of JTF_TERR_ALL.RANK%TYPE;
  TYPE num_winners_tbl_type is table of JTF_TERR_ALL.NUM_WINNERS%TYPE;
  TYPE date_tbl_type is table of JTF_TERR_ALL.START_DATE_ACTIVE%TYPE;
  TYPE terr_type_name_tbl_type is table of jtf_terr_types_all.name%TYPE;
  TYPE terr_type_id_tbl_type is table of jtf_terr_types_all.terr_type_id%TYPE;
  TYPE org_name_tbl_type is table of HR_OPERATING_UNITS.NAME%TYPE;
  TYPE ATTRIBUTE_CATEGORY_TBL_type is table of JTF_TERR_ALL.ATTRIBUTE_CATEGORY%TYPE;
  TYPE ATTRIBUTE_TBL_type is table of JTF_TERR_ALL.ATTRIBUTE1%TYPE;

TYPE terr_rec_type IS RECORD
  ( terr_id		      terr_id_tbl_type,
    terr_name	   	  terr_name_tbl_type,
    rank			  rank_tbl_type,
    num_winners		  num_winners_tbl_type,
    start_date		  date_tbl_type,
    end_date		  date_tbl_type,
	terr_type_name	  terr_type_name_tbl_type,
	terr_type_id	  terr_type_id_tbl_type,
	parent_terr_id	  terr_id_tbl_type,
	org_name		  org_name_tbl_type,
	hierarchy		  terr_name_tbl_type,
	ATTRIBUTE_CATEGORY          ATTRIBUTE_CATEGORY_tbl_type,
    ATTRIBUTE1                  ATTRIBUTE_tbl_type,
    ATTRIBUTE2                  ATTRIBUTE_tbl_type,
    ATTRIBUTE3                  ATTRIBUTE_tbl_type,
    ATTRIBUTE4                  ATTRIBUTE_tbl_type,
    ATTRIBUTE5                  ATTRIBUTE_tbl_type,
    ATTRIBUTE6                  ATTRIBUTE_tbl_type,
    ATTRIBUTE7                  ATTRIBUTE_tbl_type,
    ATTRIBUTE8                  ATTRIBUTE_tbl_type,
    ATTRIBUTE9                  ATTRIBUTE_tbl_type,
    ATTRIBUTE10                 ATTRIBUTE_tbl_type,
    ATTRIBUTE11                 ATTRIBUTE_tbl_type,
    ATTRIBUTE12                 ATTRIBUTE_tbl_type,
    ATTRIBUTE13                 ATTRIBUTE_tbl_type,
    ATTRIBUTE14                 ATTRIBUTE_tbl_type,
    ATTRIBUTE15                 ATTRIBUTE_tbl_type
	);

PROCEDURE populate_webadi_interface(  p_usage_id        IN NUMBER
                                    , p_user_id         IN NUMBER
                                    , p_terr_id     	IN NUMBER
				    				, p_org_id			IN NUMBER
				    				, p_type_id			in NUMBER
				    				, p_mode			IN VARCHAR2  DEFAULT  'NODE'
				    				, p_view			IN VARCHAR2  DEFAULT  'TERR'
				    				, p_geo_type		IN NUMBER
									, p_active			IN DATE
									, p_terr_id_array   IN VARCHAR2 DEFAULT NULL
                                    , x_seq             OUT NOCOPY VARCHAR2
                                    , x_retcode         OUT NOCOPY VARCHAR2
                                    , x_errbuf          OUT NOCOPY VARCHAR2 );
FUNCTION get_resource_name(p_resource_type VARCHAR2,   p_resource_id NUMBER,   p_group_id NUMBER,   p_role_id VARCHAR2,   p_role VARCHAR2) RETURN VARCHAR;
FUNCTION get_group_name(p_resource_type VARCHAR, p_group_id NUMBER,  p_resource_id NUMBER) RETURN VARCHAR;
FUNCTION get_role_name(p_resource_type VARCHAR,   p_role VARCHAR2) RETURN VARCHAR;
FUNCTION get_email(p_resource_type VARCHAR, p_resource_id NUMBER) RETURN VARCHAR;

END JTY_WEBADI_OTH_TERR_DWNL_PKG;

/
