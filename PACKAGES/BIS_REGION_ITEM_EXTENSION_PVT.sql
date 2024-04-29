--------------------------------------------------------
--  DDL for Package BIS_REGION_ITEM_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REGION_ITEM_EXTENSION_PVT" AUTHID CURRENT_USER as
/* $Header: BISVRIES.pls 120.0 2005/06/01 18:15:42 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.5=120.0):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_REGION_ITEM_EXTENSION_PVT
--                                                                        --
--  DESCRIPTION:  Private package to create records in 			  --
--		  BIS_AK_REGION_ITEM_EXTENSION				  --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  09/26/01   mdamle     Initial creation                                --
--  02/11/2004 mdamle     Add Parameter Layout & Parameter Render Type    --
--  02/10/04   nbarik     BSC/PMV Integration                             --
----------------------------------------------------------------------------

PROCEDURE CREATE_REGION_ITEM_RECORD
		(pRegionCode 		IN	VARCHAR2
		,pRegionAppId		IN	VARCHAR2
		,pAttributeCode		IN	VARCHAR2
		,pAttributeAppId	IN	VARCHAR2
		,pAttribute16		IN	VARCHAR2	default NULL
		,pAttribute17		IN	VARCHAR2	default NULL
		,pAttribute18		IN	VARCHAR2	default NULL
		,pAttribute19		IN	VARCHAR2	default NULL
		,pAttribute20		IN	VARCHAR2	default NULL
		,pAttribute21		IN	VARCHAR2	default NULL
		,pAttribute22		IN	VARCHAR2	default NULL
		,pAttribute23		IN	VARCHAR2	default NULL
		,pAttribute24		IN	VARCHAR2	default NULL
		,pAttribute25		IN	VARCHAR2	default NULL
		,pAttribute26		IN	VARCHAR2	default NULL
		,pAttribute27		IN	VARCHAR2	default NULL
		,pAttribute28		IN	VARCHAR2	default NULL
		,pAttribute29		IN	VARCHAR2	default NULL
		,pAttribute30		IN	VARCHAR2	default NULL
		,pAttribute31		IN	VARCHAR2	default NULL
		,pAttribute32		IN	VARCHAR2	default NULL
		,pAttribute33		IN	VARCHAR2	default NULL
		,pAttribute34		IN	VARCHAR2	default NULL
		,pAttribute35		IN	VARCHAR2	default NULL
		,pAttribute36		IN	VARCHAR2	default NULL
		,pAttribute37		IN	VARCHAR2	default NULL
		,pAttribute38		IN	VARCHAR2	default NULL
		,pAttribute39		IN	VARCHAR2	default NULL
		,pAttribute40		IN	VARCHAR2	default NULL
		,pCommit		IN 	VARCHAR2	default 'Y'	-- mdamle 02/11/2004
	);

PROCEDURE UPDATE_REGION_ITEM_RECORD
		(pRegionCode 		IN	VARCHAR2
		,pRegionAppId		IN	VARCHAR2
		,pAttributeCode		IN	VARCHAR2
		,pAttributeAppId	IN	VARCHAR2
		,pAttribute16		IN	VARCHAR2	default NULL
		,pAttribute17		IN	VARCHAR2	default NULL
		,pAttribute18		IN	VARCHAR2	default NULL
		,pAttribute19		IN	VARCHAR2	default NULL
		,pAttribute20		IN	VARCHAR2	default NULL
		,pAttribute21		IN	VARCHAR2	default NULL
		,pAttribute22		IN	VARCHAR2	default NULL
		,pAttribute23		IN	VARCHAR2	default NULL
		,pAttribute24		IN	VARCHAR2	default NULL
		,pAttribute25		IN	VARCHAR2	default NULL
		,pAttribute26		IN	VARCHAR2	default NULL
		,pAttribute27		IN	VARCHAR2	default NULL
		,pAttribute28		IN	VARCHAR2	default NULL
		,pAttribute29		IN	VARCHAR2	default NULL
		,pAttribute30		IN	VARCHAR2	default NULL
		,pAttribute31		IN	VARCHAR2	default NULL
		,pAttribute32		IN	VARCHAR2	default NULL
		,pAttribute33		IN	VARCHAR2	default NULL
		,pAttribute34		IN	VARCHAR2	default NULL
		,pAttribute35		IN	VARCHAR2	default NULL
		,pAttribute36		IN	VARCHAR2	default NULL
		,pAttribute37		IN	VARCHAR2	default NULL
		,pAttribute38		IN	VARCHAR2	default NULL
		,pAttribute39		IN	VARCHAR2	default NULL
		,pAttribute40		IN	VARCHAR2	default NULL
		,pCommit		IN 	VARCHAR2	default 'Y' 	-- mdamle 02/11/2004
	);

PROCEDURE DELETE_REGION_ITEM_RECORD
(  p_commit           IN  VARCHAR2   := FND_API.G_TRUE
 , pRegionCode 		  IN  VARCHAR2
 , pRegionAppId		  IN  NUMBER
 , pAttributeCode     IN  VARCHAR2
 , pAttributeAppId    IN  NUMBER
);

END BIS_REGION_ITEM_EXTENSION_PVT;

 

/
