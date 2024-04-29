--------------------------------------------------------
--  DDL for Package Body BIS_REGION_ITEM_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REGION_ITEM_EXTENSION_PVT" as
/* $Header: BISVRIEB.pls 120.1 2005/10/14 00:17:56 ankgoel noship $ */
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
--  10/14/05   ankgoel    Bug#4392955 - Replaced icx_sec.getID by FND_GLOBAL.user_id
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
		,pCommit		IN 	VARCHAR2	default 'Y' 	-- mdamle 02/11/2004
		) IS

vUserId		number;

BEGIN

   	--vUserId := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
	vUserId := FND_GLOBAL.user_id;

	begin
		insert into bis_ak_region_item_extension
                            (REGION_CODE,
                             REGION_APPLICATION_ID,
                             ATTRIBUTE_CODE,
                             ATTRIBUTE_APPLICATION_ID,
                             ATTRIBUTE16,
                             ATTRIBUTE17,
                             ATTRIBUTE18,
                             ATTRIBUTE19,
                             ATTRIBUTE20,
                             ATTRIBUTE21,
                             ATTRIBUTE22,
                             ATTRIBUTE23,
                             ATTRIBUTE24,
                             ATTRIBUTE25,
                             ATTRIBUTE26,
                             ATTRIBUTE27,
                             ATTRIBUTE28,
                             ATTRIBUTE29,
                             ATTRIBUTE30,
                             ATTRIBUTE31,
                             ATTRIBUTE32,
                             ATTRIBUTE33,
                             ATTRIBUTE34,
                             ATTRIBUTE35,
                             ATTRIBUTE36,
                             ATTRIBUTE37,
                             ATTRIBUTE38,
                             ATTRIBUTE39,
                             ATTRIBUTE40,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_LOGIN)
		values(
		 pRegionCode
		,pRegionAppId
		,pAttributeCode
		,pAttributeAppId
		,pAttribute16
		,pAttribute17
		,pAttribute18
		,pAttribute19
		,pAttribute20
		,pAttribute21
		,pAttribute22
		,pAttribute23
		,pAttribute24
		,pAttribute25
		,pAttribute26
		,pAttribute27
		,pAttribute28
		,pAttribute29
		,pAttribute30
		,pAttribute31
		,pAttribute32
		,pAttribute33
		,pAttribute34
		,pAttribute35
		,pAttribute36
		,pAttribute37
		,pAttribute38
		,pAttribute39
		,pAttribute40
		,SYSDATE
		,vUserId
		,SYSDATE
		,vUserId
		,vUserId);
	exception
		when others then null;
	end;

	if (pCommit = 'Y') then
		commit;
	end if;

END CREATE_REGION_ITEM_RECORD;

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
) IS
vUserId		number;

BEGIN

   	--vUserId := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
	vUserId := FND_GLOBAL.user_id;

	begin
		update bis_ak_region_item_extension
		set
		 attribute16 = pAttribute16
		,attribute17 = pAttribute17
		,attribute18 = pAttribute18
		,attribute19 = pAttribute19
		,attribute20 = pAttribute20
		,attribute21 = pAttribute21
		,attribute22 = pAttribute22
		,attribute23 = pAttribute23
		,attribute24 = pAttribute24
		,attribute25 = pAttribute25
		,attribute26 = pAttribute26
		,attribute27 = pAttribute27
		,attribute28 = pAttribute28
		,attribute29 = pAttribute29
		,attribute30 = pAttribute30
		,attribute31 = pAttribute31
		,attribute32 = pAttribute32
		,attribute33 = pAttribute33
		,attribute34 = pAttribute34
		,attribute35 = pAttribute35
		,attribute36 = pAttribute36
		,attribute37 = pAttribute37
		,attribute38 = pAttribute38
		,attribute39 = pAttribute39
		,attribute40 = pAttribute40
		,creation_date = SYSDATE
		,created_by = vUserId
		,last_update_date = SYSDATE
		,last_updated_by = vUserId
		,last_update_login = vUserId
		where region_code = pRegionCode
		and region_application_id = pRegionAppId
		and attribute_code = pAttributeCode
		and attribute_application_id = pAttributeAppId;
	exception
		when others then null;
	end;

	if (pCommit = 'Y') then
		commit;
	end if;


END UPDATE_REGION_ITEM_RECORD;

PROCEDURE DELETE_REGION_ITEM_RECORD
(  p_commit           IN  VARCHAR2   := FND_API.G_TRUE
 , pRegionCode 		  IN  VARCHAR2
 , pRegionAppId		  IN  NUMBER
 , pAttributeCode     IN  VARCHAR2
 , pAttributeAppId    IN  NUMBER
) IS
BEGIN
   DELETE FROM bis_ak_region_item_extension
   WHERE region_code = pRegionCode AND region_application_id = pRegionAppId
   AND attribute_code = pAttributeCode AND attribute_application_id = pAttributeAppId;

   IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
   END IF;

END DELETE_REGION_ITEM_RECORD;

END BIS_REGION_ITEM_EXTENSION_PVT;

/
