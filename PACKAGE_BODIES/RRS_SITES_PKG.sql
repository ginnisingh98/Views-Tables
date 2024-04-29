--------------------------------------------------------
--  DDL for Package Body RRS_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_SITES_PKG" AS
/* $Header: RRSSTPKB.pls 120.7 2006/02/02 10:25:00 pfarkade noship $ */

PROCEDURE CREATE_PROPERTY_LOCATIONS
     (errbuf          OUT NOCOPY VARCHAR2
     ,retcode         OUT NOCOPY VARCHAR2
     ,p_batch_name    IN   VARCHAR2
     ,p_org_id        IN   NUMBER
     )
IS
     CURSOR FAILED_RECORDS_CUR IS
     SELECT RRS.SITE_ID
           ,RRS.NAME
           ,RRS.SITE_IDENTIFICATION_NUMBER
           ,ITF.ERROR_MESSAGE
      FROM  RRS_SITES_VL RRS
           ,PN_LOCATIONS_ITF ITF
      WHERE ITF.BATCH_NAME = P_BATCH_NAME
        AND RRS.SITE_ID = ITF.SITE_ID
        AND ITF.ERROR_MESSAGE IS NOT NULL ;

     CURSOR UPDATE_ADDRESS_CUR IS
     SELECT HZ.COUNTRY
           ,HZ.ADDRESS1
           ,HZ.ADDRESS2
           ,HZ.ADDRESS3
           ,HZ.ADDRESS4
           ,HZ.CITY
           ,HZ.POSTAL_CODE
           ,HZ.STATE
           ,HZ.PROVINCE
           ,HZ.COUNTY
           ,HZ.ADDRESS_STYLE
           ,PN.BATCH_NAME
           ,PN.SITE_ID
         FROM
            HZ_LOCATIONS HZ
           ,RRS_SITES_B RRS
           ,PN_LOCATIONS_ITF PN
         WHERE HZ.LOCATION_ID = RRS.LOCATION_ID
           AND PN.SITE_ID = RRS.SITE_ID
        AND PN.BATCH_NAME = p_batch_name
	FOR UPDATE;

     CURSOR UPDATE_LOCATION_ID IS
     SELECT SITE_ID
           ,LOCATION_ID
      FROM  PN_LOCATIONS_ITF
      WHERE BATCH_NAME = P_BATCH_NAME
        AND ERROR_MESSAGE IS NULL ;

     l_debug_mode VARCHAR2(1);
     l_msg_count  NUMBER ;


BEGIN

     FND_MSG_PUB.INITIALIZE ;
     retcode := 'O' ;
     errbuf  := NULL ;

     IF p_batch_name IS NULL OR p_org_id IS NULL THEN
          FND_MESSAGE.Set_Name('RRS','RRS_INV_PARAMETER_PASSED');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
     END IF ;

	  FOR rec IN UPDATE_ADDRESS_CUR LOOP
          UPDATE PN_LOCATIONS_ITF
             SET  COUNTRY          = rec.COUNTRY
                 ,ADDRESS_LINE1    = rec.ADDRESS1
                 ,ADDRESS_LINE2    = rec.ADDRESS2
                 ,ADDRESS_LINE3    = rec.ADDRESS3
                 ,ADDRESS_LINE4    = rec.ADDRESS4
                 ,CITY        = rec.CITY
                 ,ZIP_CODE    = rec.POSTAL_CODE
                 ,STATE       = rec.STATE
                 ,PROVINCE    = rec.PROVINCE
                 ,COUNTY           = rec.COUNTY
                 ,ADDRESS_STYLE   = rec.ADDRESS_STYLE
		 WHERE CURRENT OF UPDATE_ADDRESS_CUR;
	   END LOOP ;

     /*FOR rec IN UPDATE_ADDRESS_CUR LOOP
          UPDATE PN_LOCATIONS_ITF
             SET  COUNTRY          = rec.COUNTRY
                 ,ADDRESS_LINE1    = rec.ADDRESS1
                 ,ADDRESS_LINE2    = rec.ADDRESS2
                 ,ADDRESS_LINE3    = rec.ADDRESS3
                 ,ADDRESS_LINE4    = rec.ADDRESS4
                 ,CITY        = rec.CITY
                 ,ZIP_CODE    = rec.POSTAL_CODE
                 ,STATE       = rec.STATE
                 ,PROVINCE    = rec.PROVINCE
                 ,COUNTY           = rec.COUNTY
                 ,ADDRESS_STYLE   = rec.ADDRESS_STYLE
                  WHERE SITE_ID = rec.SITE_ID
              AND BATCH_NAME = rec.BATCH_NAME ;
     END LOOP ;*/

     savepoint call_import ;

     PN_CAD_IMPORT.IMPORT_CAD( errbuf        => errbuf
                              ,retcode       => retcode
                              ,p_batch_name  => p_batch_name
                              ,function_flag => 'L'
                              ,p_org_id      => p_org_id
                              );

     FOR rec IN FAILED_RECORDS_CUR LOOP
           FND_MESSAGE.Set_Name('RRS', 'RRS_NAME_NUMBER_ERR');
           FND_MESSAGE.Set_Token('NAME', rec.NAME);
           FND_MESSAGE.Set_Token('NUMBER', rec.SITE_IDENTIFICATION_NUMBER);
           FND_MESSAGE.Set_Token('MESSAGE', rec.ERROR_MESSAGE);
           FND_MSG_PUB.Add;
     END LOOP ;

     l_msg_count := FND_MSG_PUB.COUNT_MSG;

     IF l_msg_count > 0 THEN
          errbuf := 'E' ;
          rollback to call_import ;
     ELSE
          FOR rec IN UPDATE_LOCATION_ID LOOP
               UPDATE RRS_SITES_B RRS
                  SET RRS.PROPERTY_LOCATION_ID = rec.LOCATION_ID
                WHERE RRS.SITE_ID = rec.SITE_ID ;
          END LOOP ;
          DELETE FROM PN_LOCATIONS_ITF WHERE BATCH_NAME = p_batch_name ;
          COMMIT ;
     END IF ;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     retcode         := '2';
     errbuf          := FND_MSG_PUB.GET;
     RETURN ;
WHEN OTHERS THEN
     retcode         := '2';
     errbuf          := SQLERRM;
     RETURN ;
END CREATE_PROPERTY_LOCATIONS ;

PROCEDURE CREATE_PROPERTY_LOCATIONS_WRP
     (p_batch_name        IN  VARCHAR2
     ,p_org_id            IN  NUMBER
     ,x_request_id        OUT NOCOPY NUMBER
     ,x_return_status     OUT NOCOPY VARCHAR2
     ,x_msg_count         OUT NOCOPY NUMBER
     ,x_msg_data          OUT NOCOPY VARCHAR2
     )
IS
     l_conc_or_online VARCHAR2(30);
     l_errbuf         VARCHAR2(2000);
     l_retcode        VARCHAR2(2000);
BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_conc_or_online := nvl(FND_PROFILE.VALUE('RRS_LOCATION_CREATION_MODE'),'ONLINE') ;

    IF l_conc_or_online = 'ONLINE' THEN
          CREATE_PROPERTY_LOCATIONS
               (errbuf            => l_errbuf
               ,retcode           => l_retcode
               ,p_batch_name      => p_batch_name
               ,p_org_id          => p_org_id
               ) ;
          IF l_retcode <> '0' THEN
               Raise FND_API.G_EXC_ERROR;
          END IF;
     ELSE
          CREATE_PROPERTY_LOCATIONS_CONC
               (p_batch_name      => p_batch_name
               ,p_org_id          => p_org_id
               ,x_request_id      => x_request_id
               ,x_return_status   => x_return_status
               ,x_msg_count       => x_msg_count
               ,x_msg_data        => x_msg_data
               ) ;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               Raise FND_API.G_EXC_ERROR;
          END IF;
     END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_msg_count := FND_MSG_PUB.count_msg;
     x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
     x_msg_count := FND_MSG_PUB.count_msg;
     x_return_status := FND_API.G_RET_STS_ERROR;
END CREATE_PROPERTY_LOCATIONS_WRP ;

PROCEDURE CREATE_PROPERTY_LOCATIONS_CONC
     (p_batch_name        IN  VARCHAR2
     ,p_org_id            IN  NUMBER
     ,x_request_id        OUT NOCOPY NUMBER
     ,x_return_status     OUT NOCOPY VARCHAR2
     ,x_msg_count         OUT NOCOPY NUMBER
     ,x_msg_data          OUT NOCOPY VARCHAR2
     )
IS
--    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    x_msg_count       := 0 ;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_request_id := fnd_request.submit_request
     (
           application                =>   'RRS'
          ,program                    =>   'RRSCREATEPL'
          ,description                =>   'RRS:Create Property Location For Sites'
          ,start_time                 =>   NULL
          ,sub_request                =>   false
          ,argument1                  =>   p_batch_name
          ,argument2                  =>   p_org_id -- 3671408 changed parameter value to passed IN parameter
     );

     -- Throw an error if the request could not be submitted.
     IF x_request_id = 0 THEN
          FND_MESSAGE.Set_Name('RRS','RRS_CON_REQUEST_FAILED');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
     COMMIT ;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
     x_msg_count := FND_MSG_PUB.COUNT_MSG;
     x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
x_return_status := 'E' ;
x_msg_count := FND_MSG_PUB.COUNT_MSG;
END CREATE_PROPERTY_LOCATIONS_CONC ;


PROCEDURE DELETE_TEMPLATE
(
        p_site_id IN NUMBER
)
IS
BEGIN
    DELETE FROM RRS_SITES_EXT_TL WHERE SITE_ID = p_site_id;
    DELETE FROM RRS_SITES_EXT_B WHERE SITE_ID = p_site_id;
    DELETE FROM RRS_SITE_USES WHERE SITE_ID = p_site_id;
    DELETE FROM RRS_SITES_TL WHERE SITE_ID = p_site_id;
    DELETE FROM RRS_SITES_B WHERE SITE_ID = p_site_id;
    COMMIT;
END DELETE_TEMPLATE;

--Bug 4742710
PROCEDURE GET_COUNTRYCODE
     (
      p_location_id        IN   NUMBER
      ,x_country_code  OUT  NOCOPY  VARCHAR2
      ,x_country_name  OUT  NOCOPY  VARCHAR2
     )
     IS
     BEGIN
     SELECT HL.COUNTRY,FTV.TERRITORY_SHORT_NAME
     INTO x_country_code,x_country_name
     FROM HZ_LOCATIONS HL, FND_TERRITORIES_VL FTV
     WHERE FTV.TERRITORY_CODE = HL.COUNTRY
     AND HL.LOCATION_ID = p_location_id;
     END GET_COUNTRYCODE;
END RRS_SITES_PKG;


/
