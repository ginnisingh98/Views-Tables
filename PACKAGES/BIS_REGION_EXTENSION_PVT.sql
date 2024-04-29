--------------------------------------------------------
--  DDL for Package BIS_REGION_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REGION_EXTENSION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVAKXS.pls 120.0 2005/06/01 15:10:10 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.0=120.0):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_REGION_EXTENSION_PVT                                --
--                                                                        --
--  DESCRIPTION:  Private package to create records in  			      --
--		  		  BIS_AK_REGION_EXTENSION table                           --
--                                                                        --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  02/03/04   nbarik     Initial Creation                                --
----------------------------------------------------------------------------

PROCEDURE CREATE_REGION_EXTN_RECORD
(        p_commit           IN  VARCHAR2   := FND_API.G_TRUE
        ,pRegionCode 		IN	VARCHAR2
        ,pRegionAppId		IN	NUMBER
        ,pAttribute16		IN	VARCHAR2	DEFAULT NULL
        ,pAttribute17		IN	VARCHAR2	DEFAULT NULL
        ,pAttribute18		IN	VARCHAR2	DEFAULT NULL
		,pAttribute19		IN	VARCHAR2	DEFAULT NULL
		,pAttribute20		IN	VARCHAR2	DEFAULT NULL
		,pAttribute21		IN	VARCHAR2	DEFAULT NULL
		,pAttribute22		IN	VARCHAR2	DEFAULT NULL
		,pAttribute23		IN	VARCHAR2	DEFAULT NULL
		,pAttribute24		IN	VARCHAR2	DEFAULT NULL
		,pAttribute25		IN	VARCHAR2	DEFAULT NULL
		,pAttribute26		IN	VARCHAR2	DEFAULT NULL
		,pAttribute27		IN	VARCHAR2	DEFAULT NULL
		,pAttribute28		IN	VARCHAR2	DEFAULT NULL
		,pAttribute29		IN	VARCHAR2	DEFAULT NULL
		,pAttribute30		IN	VARCHAR2	DEFAULT NULL
		,pAttribute31		IN	VARCHAR2	DEFAULT NULL
		,pAttribute32		IN	VARCHAR2	DEFAULT NULL
		,pAttribute33		IN	VARCHAR2	DEFAULT NULL
		,pAttribute34		IN	VARCHAR2	DEFAULT NULL
		,pAttribute35		IN	VARCHAR2	DEFAULT NULL
		,pAttribute36		IN	VARCHAR2	DEFAULT NULL
		,pAttribute37		IN	VARCHAR2	DEFAULT NULL
		,pAttribute38		IN	VARCHAR2	DEFAULT NULL
		,pAttribute39		IN	VARCHAR2	DEFAULT NULL
		,pAttribute40		IN	VARCHAR2	DEFAULT NULL
);

PROCEDURE UPDATE_REGION_EXTN_RECORD
(        p_commit           IN  VARCHAR2   := FND_API.G_TRUE
        ,pRegionCode 		IN	VARCHAR2
		,pRegionAppId		IN	NUMBER
		,pAttribute16		IN	VARCHAR2	DEFAULT NULL
		,pAttribute17		IN	VARCHAR2	DEFAULT NULL
		,pAttribute18		IN	VARCHAR2	DEFAULT NULL
		,pAttribute19		IN	VARCHAR2	DEFAULT NULL
		,pAttribute20		IN	VARCHAR2	DEFAULT NULL
		,pAttribute21		IN	VARCHAR2	DEFAULT NULL
		,pAttribute22		IN	VARCHAR2	DEFAULT NULL
		,pAttribute23		IN	VARCHAR2	DEFAULT NULL
		,pAttribute24		IN	VARCHAR2	DEFAULT NULL
		,pAttribute25		IN	VARCHAR2	DEFAULT NULL
		,pAttribute26		IN	VARCHAR2	DEFAULT NULL
		,pAttribute27		IN	VARCHAR2	DEFAULT NULL
		,pAttribute28		IN	VARCHAR2	DEFAULT NULL
		,pAttribute29		IN	VARCHAR2	DEFAULT NULL
		,pAttribute30		IN	VARCHAR2	DEFAULT NULL
		,pAttribute31		IN	VARCHAR2	DEFAULT NULL
		,pAttribute32		IN	VARCHAR2	DEFAULT NULL
		,pAttribute33		IN	VARCHAR2	DEFAULT NULL
		,pAttribute34		IN	VARCHAR2	DEFAULT NULL
		,pAttribute35		IN	VARCHAR2	DEFAULT NULL
		,pAttribute36		IN	VARCHAR2	DEFAULT NULL
		,pAttribute37		IN	VARCHAR2	DEFAULT NULL
		,pAttribute38		IN	VARCHAR2	DEFAULT NULL
		,pAttribute39		IN	VARCHAR2	DEFAULT NULL
		,pAttribute40		IN	VARCHAR2	DEFAULT NULL
);


PROCEDURE DELETE_REGION_EXTN_RECORD
(        p_commit           IN  VARCHAR2   := FND_API.G_TRUE
        ,pRegionCode 		IN	VARCHAR2
		,pRegionAppId		IN	NUMBER
);

END BIS_REGION_EXTENSION_PVT;

 

/
