--------------------------------------------------------
--  DDL for Package Body BIS_REGION_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REGION_EXTENSION_PVT" AS
/* $Header: BISVAKXB.pls 120.0 2005/06/01 17:00:47 appldev noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_REGION_EXTENSION_PVT                                --
--                                                                        --
--  DESCRIPTION:  Private package to create records in 			          --
--		          BIS_AK_REGION_EXTENSION table         				  --
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
) IS

l_user_id		NUMBER;
BEGIN
    l_user_id := fnd_global.user_id;
	BEGIN
		INSERT INTO bis_ak_region_extension
        (   REGION_CODE,
            REGION_APPLICATION_ID,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN)
		VALUES(
		   pRegionCode
    	  ,pRegionAppId
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
		  ,l_user_id
		  ,SYSDATE
		  ,l_user_id
		  ,SYSDATE
		  ,l_user_id
		);
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

	EXCEPTION
		WHEN OTHERS THEN
		  NULL;
	END;
END CREATE_REGION_EXTN_RECORD;

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
) IS
l_user_id		NUMBER;

BEGIN

   	l_user_id := fnd_global.user_id;
	BEGIN
		UPDATE bis_ak_region_extension
		SET
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
		,created_by = l_user_id
		,creation_date = SYSDATE
		,last_updated_by = l_user_id
		,last_update_date = SYSDATE
		,last_update_login = l_user_id
		WHERE region_code = pRegionCode AND region_application_id = pRegionAppId;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

	EXCEPTION
		WHEN OTHERS THEN
		  NULL;
	END;
END UPDATE_REGION_EXTN_RECORD;

PROCEDURE DELETE_REGION_EXTN_RECORD
(        p_commit           IN  VARCHAR2   := FND_API.G_TRUE
        ,pRegionCode 		IN	VARCHAR2
		,pRegionAppId		IN	NUMBER
) IS
BEGIN
   DELETE FROM bis_ak_region_extension
   WHERE region_code = pRegionCode AND region_application_id = pRegionAppId;

   IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
   END IF;
END DELETE_REGION_EXTN_RECORD;

END BIS_REGION_EXTENSION_PVT;

/
