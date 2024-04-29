--------------------------------------------------------
--  DDL for Package Body CSI_GIS_INSTANCE_GEO_LOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_GIS_INSTANCE_GEO_LOC_PVT" AS
/* $Header: csivgilb.pls 120.0.12010000.2 2008/11/11 13:10:26 jgootyag noship $ */
/***************************************************************************
--
--  Copyright (c) 2008 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      csivgilb.pls
--
--  DESCRIPTION
--
--      Body of package CSI_GIS_INSTANCE_GEO_LOC_PVT
--
--  NOTES
--
--  HISTORY
--
--  11-NOV-2008     jgootyag     Initial Creation
***************************************************************************/

PROCEDURE INSERT_ROW
(
    p_instance_id             IN          NUMBER
   ,p_inst_latitude           IN          NUMBER
   ,p_inst_longitude          IN          NUMBER
   , x_return_status           OUT NOCOPY  VARCHAR2
)  IS

BEGIN

	x_return_status         := FND_API.G_RET_STS_SUCCESS;

	    INSERT INTO CSI_II_GEOLOCATIONS
	     (
	      INSTANCE_ID,
	      INST_LATITUDE,
	      INST_LONGITUDE,
	      VALID_FLAG,
	      CREATION_DATE,
	      CREATED_BY,
	      LAST_UPDATED_BY,
	      LAST_UPDATE_LOGIN,
	      LAST_UPDATE_DATE
	     )
	     VALUES
	     (
	      p_instance_id,
          p_inst_latitude,
	      p_inst_longitude,
	      'Y',
	      SYSDATE,
          FND_GLOBAL.user_id,
	      FND_GLOBAL.user_id,
	      FND_GLOBAL.login_id,
          SYSDATE
         );

   EXCEPTION

     WHEN OTHERS THEN
            x_return_status         := FND_API.G_RET_STS_ERROR;

  END INSERT_ROW;


 PROCEDURE UPDATE_ROW
  ( p_instance_id             IN          NUMBER
   ,p_inst_latitude           IN          NUMBER
   ,p_inst_longitude          IN          NUMBER
   ,p_valid_flag              IN          VARCHAR2
   ,x_return_status           OUT NOCOPY  VARCHAR2
)   IS

  l_instance_id NUMBER;

BEGIN

 	x_return_status         := FND_API.G_RET_STS_SUCCESS;

	IF p_valid_flag = 'N' THEN

        UPDATE CSI_II_GEOLOCATIONS
	    SET
	      VALID_FLAG         =  p_valid_flag,
	      LAST_UPDATED_BY    =  FND_GLOBAL.user_id,
	      LAST_UPDATE_LOGIN  =  FND_GLOBAL.login_id,
	      LAST_UPDATE_DATE   =  SYSDATE

	    WHERE
	      INSTANCE_ID = p_instance_id;
	ELSE
	          UPDATE CSI_II_GEOLOCATIONS
	    SET
	      INST_LATITUDE           =  p_inst_latitude,
	      INST_LONGITUDE          =  p_inst_longitude,
	      VALID_FLAG         =  NVL(p_valid_flag,'Y'),
	      LAST_UPDATED_BY    =  FND_GLOBAL.user_id,
	      LAST_UPDATE_LOGIN  =  FND_GLOBAL.login_id,
	      LAST_UPDATE_DATE   =  SYSDATE

	    WHERE
	      INSTANCE_ID = p_instance_id;
	END IF;


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	           x_return_status         := FND_API.G_RET_STS_SUCCESS;
			   Return;

     WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;

  END UPDATE_ROW;
END CSI_GIS_INSTANCE_GEO_LOC_PVT;

/
