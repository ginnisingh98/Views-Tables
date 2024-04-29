--------------------------------------------------------
--  DDL for Package Body CSI_GIS_INSTANCE_LOC_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_GIS_INSTANCE_LOC_UTL_PKG" AS
/* $Header: csigilub.pls 120.0.12010000.9 2009/01/15 06:49:13 jgootyag noship $*/

/***************************************************************************
--
--  Copyright (c) 2008 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      csigilub.pls
--
--  DESCRIPTION
--
--      Body of package CSI_GIS_INSTANCE_LOC_UTL_PKG
--
--  NOTES
--
--  HISTORY
--
--  11-NOV-2008    jgootyag     Initial Creation
***************************************************************************/

/*validate instance */
PROCEDURE VALIDATE_INSTANCE_NUMBER
(
  p_instance_id             IN           NUMBER
 ,p_asset_context           IN           VARCHAR2
 ,x_instance_number         OUT  NOCOPY  VARCHAR2
 ,x_create_update           OUT  NOCOPY  VARCHAR2
 ,x_return_status           OUT  NOCOPY  VARCHAR2
 ,x_msg_count		        OUT  NOCOPY  NUMBER
 ,x_msg_data	            OUT  NOCOPY  VARCHAR2
 ) IS

 l_inventory_item_id          NUMBER;
 l_organization_id            NUMBER;
 l_serial_number              VARCHAR2(30);
 l_instance_number            VARCHAR2(30);
 l_csi_item_type	          NUMBER;
 l_serial_number_control_code NUMBER;
 l_network_asset_flag         VARCHAR2(1);
 l_exists                     VARCHAR2(1);
 l_create_update              VARCHAR2(1);
 l_instance_type              VARCHAR2(3):='EAM';
 l_debug_level                NUMBER;

BEGIN
	  l_debug_level:=to_number(fnd_profile.value('CSI_DEBUG_LEVEL'));
      csi_t_gen_utility_pvt.add( 'In Validate Instance Number');
      x_return_status         := FND_API.G_RET_STS_SUCCESS;

      /* check if the Instance exists */
	  BEGIN

	        SELECT 'Y', INVENTORY_ITEM_ID, LAST_VLD_ORGANIZATION_ID, SERIAL_NUMBER, INSTANCE_NUMBER,NETWORK_ASSET_FLAG
		     INTO l_exists, l_inventory_item_id, l_organization_id,l_serial_number, l_instance_number,l_network_asset_flag
	        FROM CSI_ITEM_INSTANCES
	        WHERE INSTANCE_ID = p_instance_id;


			IF  l_debug_level > 0 THEN
			  csi_t_gen_utility_pvt.add( 'Instance exists in csi_item_instances');
			  csi_t_gen_utility_pvt.add( 'Inventory Item Id:'||l_inventory_item_id);
			  csi_t_gen_utility_pvt.add( 'Organization Id:'||l_organization_id);
			  csi_t_gen_utility_pvt.add( 'Serial Number:'||l_serial_number);
			  csi_t_gen_utility_pvt.add( 'Instance Number:'||l_instance_number);
			END IF;

			SELECT  Nvl((SELECT 'EAM'
			              From MFG_LOOKUPS ml1, MTL_SYSTEM_ITEMS_B_KFV msi,csi_item_instances cii
                          where
                                 msi.inventory_item_id = cii.inventory_item_id
                             AND cii.last_vld_organization_id=msi.organization_id
                             AND (cii.active_start_date IS NULL OR (cii.active_start_date <= sysdate))
                             AND (cii.active_end_date IS NULL OR (cii.active_end_date >= sysdate))
                             AND ml1.lookup_type = 'EAM_ITEM_TYPE'
                             AND msi.eam_item_type = ml1.lookup_code
                             AND NVL(cii.maintainable_flag,'Y') = 'Y'
                             AND cii.instance_id = p_instance_id
                            ),'CSE' )
			INTO l_instance_type
            FROM DUAL;

            csi_t_gen_utility_pvt.add( 'Instance Type:'||l_instance_type);

        EXCEPTION WHEN NO_DATA_FOUND THEN
	        	 csi_t_gen_utility_pvt.add( 'Instance does not exist in csi_item_instances');
	             FND_MESSAGE.SET_NAME('CSI','CSI_INSTANCE_NOT_FOUND');
			     FND_MESSAGE.SET_TOKEN('INSTANCE',l_instance_number);
			     FND_MSG_PUB.ADD;
			     x_return_status := FND_API.G_RET_STS_ERROR;
	            return;

	    END;


	    /*If the asset is EAM asset validate it  */
		IF  l_instance_type = 'EAM' THEN
		   csi_t_gen_utility_pvt.add( 'Validating EAM Asset');
	       SELECT EAM_ITEM_TYPE,SERIAL_NUMBER_CONTROL_CODE
	       INTO l_csi_item_type,l_serial_number_control_code
		   FROM MTL_SYSTEM_ITEMS_B_KFV
		   WHERE INVENTORY_ITEM_ID = l_inventory_item_id
	       AND   ORGANIZATION_ID = l_organization_id;


	       IF l_csi_item_type NOT IN (1,3) THEN
	 	     -- Raise error
		      FND_MESSAGE.SET_NAME('CSI','CSI_ASSET_NOT_CAPTL_REBUILD');
		      FND_MESSAGE.SET_TOKEN('INSTANCE',l_instance_number);
			  FND_MSG_PUB.ADD;
			  x_return_status := FND_API.G_RET_STS_ERROR;
              return;

	       END IF;

		   IF l_serial_number_control_code = 1 THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_ASSET_NOT_SERIALIZED');
			  FND_MESSAGE.SET_TOKEN('INSTANCE',l_instance_number);
			  FND_MSG_PUB.ADD;
			  x_return_status := FND_API.G_RET_STS_ERROR;
              return;
           END IF;

           IF nvl(l_network_asset_flag,'N') = 'Y' THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_ASSET_ROUTE_CNT_GEOCODE');
			  FND_MESSAGE.SET_TOKEN('INSTANCE',l_instance_number);
			  FND_MSG_PUB.ADD;
			  x_return_status := FND_API.G_RET_STS_ERROR;
              return;
           END IF;
		END IF;

           /* check if Geo location info already exists for the instance, else mark it as create */
	    BEGIN
	          SELECT 'U'
			      INTO l_create_update
	          FROM CSI_II_GEOLOCATIONS
	          WHERE INSTANCE_ID = p_instance_id;

        EXCEPTION WHEN NO_DATA_FOUND THEN
	          l_create_update := 'C';

	    END;
        x_instance_number:=l_instance_number;
        x_create_update := l_create_update;

END VALIDATE_INSTANCE_NUMBER;

/* Procedure to convert latitude/longitude to DD format */

PROCEDURE CONVERT_DMS_OR_DM_TO_DD
(
  p_value          IN           VARCHAR2
 ,p_mode           IN           VARCHAR2
 ,p_geocode_format   IN           VARCHAR2
 ,p_instance_number  IN           VARCHAR2
 ,x_value          OUT  NOCOPY  NUMBER
 ,x_return_status  OUT  NOCOPY  VARCHAR2
 ,x_msg_count	   OUT  NOCOPY  NUMBER
 ,x_msg_data	   OUT  NOCOPY  VARCHAR2
 )  IS

 l_length NUMBER;
 l_value VARCHAR2(100);
 l_dd_value NUMBER;
 l_direction  VARCHAR2(1);
 l_sign  VARCHAR2(1);

 BEGIN
 		csi_t_gen_utility_pvt.add( 'Converting latitude or longitude value to DD format');

		 l_value := UPPER(TRIM(p_value));
		 l_length := LENGTH(l_value);

        SELECT  decode(substr(l_value,l_length),'N','N','S','S','E','E','W','W','A')
        INTO  l_direction
        FROM DUAL;

        SELECT   decode(substr(l_value,1,1),'+','+','-','-','+')
        INTO l_sign
        FROM DUAL;

	    IF p_geocode_format = 'DMS' THEN
	      IF l_direction = 'S' AND instr(substr(l_value,1,l_length-1),'S') = 0 THEN
	         l_direction := 'A';
          END IF;
	    END IF;

        IF l_direction IN ('S','W') THEN
           l_sign := '-';
        END IF;

	    IF l_sign = '-' THEN

			IF l_direction ='A' THEN
			   IF substr(l_value,1,1) = '-' THEN
                 l_value := substr(l_value,2);
			   ELSE
			      l_value := substr(l_value,1);
			   END IF;
			ELSE
               IF substr(l_value,1,1) = '-' THEN
                 l_value := substr(l_value,2,l_length-2);
	            ELSE
                 l_value := substr(l_value,1,l_length-1);
                END IF;

            END IF;

			Calculate_DD( p_value=>l_value,
                        p_geocode_format=>p_geocode_format,
						p_mode => p_mode,
                        p_instance_number=>p_instance_number,
						x_value=>l_dd_value,
                        x_return_status=>x_return_status,
                        x_msg_count=>x_msg_count,
                        x_msg_data=>x_msg_data);

		    x_value:= - l_dd_value;

		ELSIF l_sign = '+' THEN

     		IF l_direction ='A' THEN
               IF substr(l_value,1,1) = '+' THEN
                 l_value := substr(l_value,2);
			   ELSE
			      l_value := substr(l_value,1);
			   END IF;
		  	ELSE
               IF substr(l_value,1,1) = '+' THEN
                 l_value := substr(l_value,2,l_length-2);
               ELSE
                 l_value := substr(l_value,1,l_length-1);
                END IF;
            END IF;

            Calculate_DD( p_value=>l_value,
                        p_geocode_format=>p_geocode_format,
						p_mode => p_mode,
                        p_instance_number=>p_instance_number,
                        x_value=>l_dd_value,
                        x_return_status=>x_return_status,
                        x_msg_count=>x_msg_count,
                        x_msg_data=>x_msg_data);

            x_value:= l_dd_value;

		END IF;

		IF p_mode = 'LAT' THEN
		   IF NOT (x_value BETWEEN -90 AND +90) THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_OOR_LAT_VALUE');
			  FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		      FND_MSG_PUB.ADD;
		      x_return_status := FND_API.G_RET_STS_ERROR;
              return;
			END IF;
		ELSIF p_mode = 'LON' THEN
		   IF NOT (x_value BETWEEN -180 AND +180) THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_OOR_LON_VALUE');
			  FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		      FND_MSG_PUB.ADD;
		      x_return_status := FND_API.G_RET_STS_ERROR;
              return;
			END IF;
		END IF;

END CONVERT_DMS_OR_DM_TO_DD;

/*Procedure to calculate DD value */
PROCEDURE Calculate_DD
(
  p_value   IN VARCHAR2
 ,p_geocode_format  IN VARCHAR2
 ,p_mode   IN VARCHAR2
 ,p_instance_number IN VARCHAR2
 ,x_value   OUT NOCOPY NUMBER
 ,x_return_status  OUT  NOCOPY VARCHAR2
 ,x_msg_count	   OUT  NOCOPY  NUMBER
 ,x_msg_data	   OUT  NOCOPY  VARCHAR2
)  IS
l_degrees NUMBER:=0;
 l_minutes NUMBER:=0;
 l_seconds NUMBER:=0;
 l_d_pos   NUMBER:=0;
 l_m_pos NUMBER:=0;
 l_s_pos NUMBER:=0;
 l_value VARCHAR2(100);
 Invalid_Decimal Exception;
BEGIN
     csi_t_gen_utility_pvt.add( 'Calculating DD value');
     l_value := Trim(Upper(p_value));

	 l_d_pos := INSTR(l_value,'D');
     l_m_pos := INSTR(l_value,'M');
	 l_s_pos := INSTR(l_value,'S');


     IF p_geocode_format = 'DMS' THEN
    	 IF (NOT(l_d_pos < l_m_pos and l_m_pos < l_s_pos)) OR (substr(l_value,l_s_pos + 1) IS NOT NULL) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DMS_VALUE');
		   FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		   IF p_mode = 'LAT' THEN
		      FND_MESSAGE.SET_TOKEN('ORD','Latitude');
		   ELSE
              FND_MESSAGE.SET_TOKEN('ORD','Longitude');
           END IF;
		   FND_MSG_PUB.ADD;
		   x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
		 END IF;
	 ELSE
         IF (NOT(l_d_pos < l_m_pos) or (l_s_pos > 0) or (substr(l_value,l_m_pos + 1) IS NOT NULL)) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DM_VALUE');
		   FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		   IF p_mode = 'LAT' THEN
		      FND_MESSAGE.SET_TOKEN('ORD','Latitude');
		   ELSE
              FND_MESSAGE.SET_TOKEN('ORD','Longitude');
           END IF;
		   FND_MSG_PUB.ADD;
		   x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
          END IF;
       END IF;


		BEGIN

		   SELECT to_number(nvl(substr(l_value,1,l_d_pos-1),-1))
		   INTO l_degrees
		   FROM DUAL;

		   IF l_degrees - Trunc(l_degrees) > 0 THEN
		         RAISE Invalid_Decimal;
           END IF;

		   IF l_degrees < 0 THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_INV_DEGREE_VALUE');
			  FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			  IF p_mode = 'LAT' THEN
		         FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			   ELSE
                 FND_MESSAGE.SET_TOKEN('ORD','Longitude');
               END IF;
		      FND_MSG_PUB.ADD;
		      x_return_status := FND_API.G_RET_STS_ERROR;
              return;
		   END IF;

		EXCEPTION
            WHEN INVALID_NUMBER THEN
			    FND_MESSAGE.SET_NAME('CSI','CSI_INV_DEGREE_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				IF p_mode = 'LAT' THEN
		          FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			    ELSE
                 FND_MESSAGE.SET_TOKEN('ORD','Longitude');
                END IF;
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
			WHEN Invalid_Decimal THEN
			    FND_MESSAGE.SET_NAME('CSI','CSI_INV_DECIMAL_DEGREE_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				IF p_mode = 'LAT' THEN
		           FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			    ELSE
                  FND_MESSAGE.SET_TOKEN('ORD','Longitude');
                END IF;
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
        END;

		BEGIN

		   SELECT to_number(nvl(substr(l_value,l_d_pos+1,(l_m_pos-l_d_pos-1)),-1))
		   INTO l_minutes
		   FROM DUAL;

		IF p_geocode_format = 'DMS'  THEN
          IF l_minutes - Trunc(l_minutes) > 0 THEN
		         RAISE Invalid_Decimal;
          END IF;

		END IF;
		IF l_minutes < 0 OR l_minutes > 59 THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_OOR_MINUTES_VALUE');
		   FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		   IF p_mode = 'LAT' THEN
		      FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			ELSE
              FND_MESSAGE.SET_TOKEN('ORD','Longitude');
            END IF;
		   FND_MSG_PUB.ADD;
		   x_return_status := FND_API.G_RET_STS_ERROR;
		   return;
        END IF;

		EXCEPTION
            WHEN INVALID_NUMBER THEN
			    FND_MESSAGE.SET_NAME('CSI','CSI_INV_MINUTES_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				IF p_mode = 'LAT' THEN
		          FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			    ELSE
                 FND_MESSAGE.SET_TOKEN('ORD','Longitude');
                END IF;
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
			WHEN Invalid_Decimal THEN
			    FND_MESSAGE.SET_NAME('CSI','CSI_INV_DECIMAL_MINUTES_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				IF p_mode = 'LAT' THEN
		          FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			    ELSE
                 FND_MESSAGE.SET_TOKEN('ORD','Longitude');
                END IF;
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
         END;

		IF p_geocode_format <> 'DM'  THEN
	      BEGIN

		     SELECT to_number(nvl(substr(l_value,l_m_pos+1,(l_s_pos-l_m_pos-1)),-1))
		     INTO l_seconds
		     FROM DUAL;

		     IF l_seconds < 0 OR l_seconds > 59 THEN
			   FND_MESSAGE.SET_NAME('CSI','CSI_OOR_SECONDS_VALUE');
			   FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			   IF p_mode = 'LAT' THEN
		         FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			   ELSE
                 FND_MESSAGE.SET_TOKEN('ORD','Longitude');
               END IF;
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
		        return;
            END IF;

		  EXCEPTION
            WHEN INVALID_NUMBER THEN
			    FND_MESSAGE.SET_NAME('CSI','CSI_INV_SECONDS_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				IF p_mode = 'LAT' THEN
		          FND_MESSAGE.SET_TOKEN('ORD','Latitude');
			    ELSE
                 FND_MESSAGE.SET_TOKEN('ORD','Longitude');
                END IF;
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
          END;
		END IF;

	 x_value:= (l_degrees + l_minutes/60 + l_seconds/3600);



END  Calculate_DD;

/*Procedure to Validate latitude, longitude values */
PROCEDURE VALIDATE_LATITUDE_LONGITUDE
(
  p_latitude        IN           VARCHAR2
 ,p_longitude       IN           VARCHAR2
 ,p_geocode_format  IN           VARCHAR2
 ,p_instance_number IN           VARCHAR2
 ,x_return_status   OUT  NOCOPY  VARCHAR2
 ,x_msg_count	    OUT  NOCOPY  NUMBER
 ,x_msg_data	    OUT  NOCOPY  VARCHAR2
 )  IS
 l_msg_count NUMBER:=0;
 l_msg_data  VARCHAR2(4000);
 l_return_status VARCHAR2(1);
 l_latitude_length   NUMBER:=0;
 l_longitude_length  NUMBER:=0;
 l_latitude_value   NUMBER:=0;
 l_longitude_value  NUMBER:=0;
 l_latitude  VARCHAR2(100);
 l_longitude VARCHAR2(100);
 l_latitude_direction  VARCHAR2(1);
 l_longitude_direction VARCHAR2(1);
 l_latitude_sign  VARCHAR2(1);
 l_longitude_sign  VARCHAR2(1);
 l_char    VARCHAR2(2);
 l_valid    VARCHAR2(1);
 l_direction_count NUMBER:=0;
 l_error_count NUMBER:=0;


 BEGIN
      csi_t_gen_utility_pvt.add( 'In Validate latitude/longitude');

	  l_latitude        := UPPER(TRIM(p_latitude));
	  l_latitude_length := LENGTH(l_latitude);
	  l_longitude       := UPPER(TRIM(p_longitude));
	  l_longitude_length:= LENGTH(l_longitude);

      SELECT   decode(substr(l_latitude,1,1),'+','+','-','-','+'),decode(substr(l_longitude,1,1),'+','+','-','-','+')
      INTO l_latitude_sign,l_longitude_sign
      FROM DUAL;

	   /* Get the direction*/
	  SELECT  decode(substr(l_latitude,l_latitude_length),'N','N','S','S','E','E','W','W','A')
	         ,decode(substr(l_longitude,l_longitude_length),'N','N','S','S','E','E','W','W','A')
      INTO    l_latitude_direction
	         ,l_longitude_direction
      FROM    DUAL;

	  IF p_geocode_format = 'DMS' THEN
	    IF l_latitude_direction = 'S' AND instr(substr(l_latitude,1,l_latitude_length-1),'S') = 0 THEN
		    l_latitude_direction := 'A';
        END IF;
	    IF l_longitude_direction = 'S' AND instr(substr(l_longitude,1,l_longitude_length-1),'S') = 0 THEN
		     l_longitude_direction := 'A';
        END IF;
	  END IF;

	  IF  p_geocode_format = 'DD' THEN

		    BEGIN
		        SELECT to_number(l_latitude)
		        INTO l_latitude_value
		        FROM DUAL;
		    EXCEPTION
                WHEN INVALID_NUMBER THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_DD_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
				return;
            END;
		    BEGIN
		        SELECT to_number(l_longitude)
		        INTO l_longitude_value
		        FROM DUAL;
		    EXCEPTION
                WHEN INVALID_NUMBER THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LONG_DD_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
				return;
            END;

            IF NOT (l_latitude_value  BETWEEN -90 AND +90) THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_OOR_LAT_VALUE');
			  FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		      FND_MSG_PUB.ADD;
		      x_return_status := FND_API.G_RET_STS_ERROR;
              return;
		    	END IF;
            IF NOT (l_longitude_value  BETWEEN -180 AND +180) THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_OOR_LON_VALUE');
			  FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		      FND_MSG_PUB.ADD;
		      x_return_status := FND_API.G_RET_STS_ERROR;
              return;
			END IF;

	  END IF;
	  /*Checking for invalid Characters*/
	  FOR i IN 1..l_latitude_length LOOP

		  l_char:=substr(l_latitude,i,1);

		  IF l_char NOT IN ('0','1','2','3','4','5','6','7','8','9','N','S','E','W','D','M','S',' ','+','-','.') THEN
		     FND_MESSAGE.SET_NAME('CSI','CSI_INV_CHAR_LAT_VALUE');
			 FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		     FND_MSG_PUB.ADD;
			 x_return_status := FND_API.G_RET_STS_ERROR;
			 l_error_count :=l_error_count + 1;
       		 return;
		  END IF;

          IF l_latitude_direction in  ('N','E','W','A','S') AND l_char IN ('N','S','E','W') THEN
             l_direction_count := l_direction_count + 1;
          END IF;

		  IF i <> 1 and l_char in ('+','-') THEN
		    FND_MESSAGE.SET_NAME('CSI','CSI_INV_LAT_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
		  END IF;

		  IF p_geocode_format = 'DMS' THEN
			 IF l_direction_count > 2 THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INV_LAT_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
				l_error_count :=l_error_count + 1;
                return;
             END IF;

		  ELSIF p_geocode_format = 'DM' THEN
		   	 IF l_direction_count > 1 THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INV_LAT_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
				l_error_count :=l_error_count + 1;
                return;
             END IF;
		  END IF;
	  END LOOP;




      l_direction_count := 0;

	  FOR i IN 1..l_longitude_length LOOP

		  l_char:=substr(l_longitude,i,1);

		  IF l_char NOT IN ('0','1','2','3','4','5','6','7','8','9','N','S','E','W','D','M','S',' ','+','-','.') THEN
		     FND_MESSAGE.SET_NAME('CSI','CSI_INV_CHAR_LONG_VALUE');
			 FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		     FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
             return;
		  END IF;

       	  IF l_longitude_direction in  ('N','E','W','A','S') AND l_char IN ('N','S','E','W') THEN
             l_direction_count := l_direction_count + 1;
          END IF;

		  IF i <> 1 and l_char in ('+','-') THEN
		    FND_MESSAGE.SET_NAME('CSI','CSI_INV_LON_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
		  END IF;

		  IF p_geocode_format = 'DMS' THEN
		     IF l_direction_count > 2 THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INV_LON_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
             END IF;
	      ELSIF p_geocode_format = 'DM' THEN
		     IF l_direction_count > 1 THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INV_LON_VALUE');
				FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
             END IF;
          END IF;
	  END LOOP;

    IF p_geocode_format = 'DMS' THEN

	     IF NOT (instr(l_latitude,'D') > 0 AND instr(l_latitude,'M') > 0 AND instr(l_latitude,'S') > 0) THEN
		        FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DMS_VALUE');
		    	FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				FND_MESSAGE.SET_TOKEN('ORD','Latitude');
		        FND_MSG_PUB.ADD;
		       x_return_status := FND_API.G_RET_STS_ERROR;
           return;
		 END IF;
         IF NOT (instr(l_longitude,'D') > 0 AND instr(l_longitude,'M') > 0 AND instr(l_longitude,'S') > 0) THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DMS_VALUE');
		    	FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				FND_MESSAGE.SET_TOKEN('ORD','Longitude');
		        FND_MSG_PUB.ADD;
		       x_return_status := FND_API.G_RET_STS_ERROR;
           return;
		 END IF;


	  ELSIF p_geocode_format = 'DM' THEN

         IF  (instr(SubStr(l_latitude,1,l_latitude_length-1),'S') > 0)  THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DM_VALUE');
		       	FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				FND_MESSAGE.SET_TOKEN('ORD','Latitude');
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
            return;
         END IF;

		 IF  (instr(SubStr(l_longitude,1,l_longitude_length-1),'S') > 0 )  THEN
                FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DM_VALUE');
		       	FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
				FND_MESSAGE.SET_TOKEN('ORD','Longitude');
                FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
            return;
         END IF;

         IF NOT (instr(l_latitude,'D') > 0 AND instr(l_latitude,'M') > 0 )  THEN
		        FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DM_VALUE');
			    FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MESSAGE.SET_TOKEN('ORD','Latitude');
		        FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
            return;
		  END IF;

		 IF NOT (instr(l_longitude,'D') > 0 AND instr(l_longitude,'M') > 0 ) THEN
		        FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_LAT_LONG_DM_VALUE');
			    FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
			    FND_MESSAGE.SET_TOKEN('ORD','Longitude');
                FND_MSG_PUB.ADD;
		        x_return_status := FND_API.G_RET_STS_ERROR;
            return;
		 END IF;

	  END IF;



      IF (l_latitude_direction = 'A' and NOT(l_longitude_direction = 'A')) OR
	     (l_longitude_direction = 'A' and NOT(l_latitude_direction = 'A')) THEN
		 FND_MESSAGE.SET_NAME('CSI','CSI_LAT_LONG_DIFF_FORMAT');
		 FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		 FND_MSG_PUB.ADD;
		 x_return_status := FND_API.G_RET_STS_ERROR;
         return;
      END IF;

      IF l_latitude_direction NOT IN ('N','S','A') THEN
	     FND_MESSAGE.SET_NAME('CSI','CSI_INV_LAT_DIRECTION');
		 FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
	     FND_MSG_PUB.ADD;
	     x_return_status := FND_API.G_RET_STS_ERROR;
         return;
      END IF;

	  IF l_latitude_sign = '-' THEN
	 	IF l_latitude_direction = 'N' THEN
	       FND_MESSAGE.SET_NAME('CSI','CSI_INV_LAT_NEG_VALUE');
           FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
	       FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
           return;
        END IF;
      END IF;

	  IF l_longitude_direction NOT IN ('E','W','A') THEN
		 FND_MESSAGE.SET_NAME('CSI','CSI_INV_LON_DIRECTION');
		 FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		 FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
         return;
	  END IF;

	  IF l_longitude_sign = '-' THEN
		IF l_longitude_direction = 'E' THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_INV_LON_NEG_VALUE');
		   FND_MESSAGE.SET_TOKEN('INSTANCE',p_instance_number);
		   FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
           return;
        END IF;
	  END IF;

END VALIDATE_LATITUDE_LONGITUDE;

/*Function to get Degrees from DD value */
FUNCTION GET_DEGREES_FROM_DD
( p_value IN NUMBER)
RETURN VARCHAR2 IS
l_value VARCHAR2(4);
BEGIN

  l_value:=TO_CHAR(TRUNC(p_value));
  return ABS(l_value);

END GET_DEGREES_FROM_DD;

/*Function to get Minutesfrom DD value */
FUNCTION GET_MINUTES_FROM_DD
( p_value IN NUMBER)
RETURN VARCHAR2 IS
l_value VARCHAR2(2);
l_integer_part NUMBER;
l_decimal_part NUMBER;
BEGIN

 l_integer_part := ABS(TRUNC(p_value));
 l_decimal_part:=  ABS(p_value) - l_integer_part ;
 l_value:= TO_CHAR(TRUNC(l_decimal_part * 60));
 return l_value;

END GET_MINUTES_FROM_DD;

/*Function to get Seconds from DD value */
FUNCTION GET_SECONDS_FROM_DD
( p_value IN NUMBER)
RETURN VARCHAR2 IS
l_value VARCHAR2(40);
l_minutes_decimal_part NUMBER;
l_seconds_decimal NUMBER;
l_seconds_integer NUMBER;
BEGIN

 l_minutes_decimal_part:=  ABS(p_value) - ABS(TRUNC(p_value)) ;
 l_seconds_integer:= l_minutes_decimal_part * 60;
 l_seconds_decimal:= l_seconds_integer - TRUNC(l_seconds_integer);
 l_value:= TO_CHAR(ROUND((l_seconds_decimal * 60),2));
 return l_value;

END GET_SECONDS_FROM_DD;

/*Function to get Direction from DD value */
FUNCTION GET_DIRECTION_FROM_DD
(p_mode  IN VARCHAR2
,p_value IN NUMBER)
RETURN VARCHAR2 IS
l_sign NUMBER;
l_direction VARCHAR2(1);
BEGIN
  IF p_value IS NULL THEN
    return ' ';
  END IF;
  l_sign := SIGN(p_value);
  IF p_mode = 'LAT' THEN
     IF l_sign = -1 THEN
	    return 'S';
     ELSE
        return 'N';
     END IF;
  ELSIF p_mode = 'LON' THEN
     IF l_sign = -1 THEN
	    return 'W';
     ELSE
        return 'E';
     END IF;
  END IF;

END GET_DIRECTION_FROM_DD;

END  CSI_GIS_INSTANCE_LOC_UTL_PKG;

/
