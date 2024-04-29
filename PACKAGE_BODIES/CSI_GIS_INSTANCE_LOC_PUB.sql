--------------------------------------------------------
--  DDL for Package Body CSI_GIS_INSTANCE_LOC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_GIS_INSTANCE_LOC_PUB" AS
/* $Header: csipgilb.pls 120.0.12010000.10 2009/01/09 08:54:19 jgootyag noship $ */
/***************************************************************************
--
--  Copyright (c) 2008 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      csipgilb.pls
--
--  DESCRIPTION
--
--      Body of package CSI_GIS_INSTANCE_LOC_PUB
--
--  NOTES
--
--  HISTORY
--
--  11-NOV-2008    jgootyag     Initial Creation
***************************************************************************/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_GIS_INSTANCE_LOC_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipgisb.pls';

/*Procedure to create or update asset/instance geolocation latitude and longitude values*/
PROCEDURE CREATEUPDATE_INST_GEOLOC_INFO
(
    p_api_version                IN           NUMBER
   ,p_commit	    	         IN           VARCHAR2 := FND_API.G_FALSE
   ,p_CSI_instance_geoloc_tbl    IN           CSI_GIS_INSTANCE_LOC_PUB.csi_instance_geoloc_tbl_type
   ,p_asset_context              IN           VARCHAR2 :='EAM'
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count		             OUT  NOCOPY  NUMBER
   ,x_msg_data	                 OUT  NOCOPY  VARCHAR2
 ) IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATEUPDATE_INST_GEOLOC_INFO';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_debug_level                   NUMBER;
   l_return_status           VARCHAR2(1);
   l_error_count NUMBER:=0;
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(4000);
   l_inst_latitude_dd_value  NUMBER;
   l_inst_longitude_dd_value NUMBER;
   l_create_update  VARCHAR2(1);
   l_instance_number VARCHAR2(30);
   TYPE l_instance_tbl_type IS TABLE OF VARCHAR2(1)
     INDEX BY  VARCHAR2(32760);
	 l_instance_tbl   l_instance_tbl_type;


BEGIN

    SAVEPOINT CREATEUPDATE_INST_GEOLOC_INFO;

    -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME   )   THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   --  Initialize API return status to success
	x_return_status         := FND_API.G_RET_STS_SUCCESS;

	FND_MSG_PUB.initialize;

	-- Check the profile option debug_level for debug message reporting
     l_debug_level:=to_number(fnd_profile.value('CSI_DEBUG_LEVEL'));


	 csi_t_gen_utility_pvt.build_file_name( p_file_segment1 => 'csi_gis',
                                             p_file_segment2 => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));

     csi_t_gen_utility_pvt.add('In createupdate_inst_geoloc_info');
     l_instance_tbl('init'):='Y';

	IF p_csi_instance_geoloc_tbl.COUNT > 0 THEN

	   FOR i in p_csi_instance_geoloc_tbl.FIRST..p_csi_instance_geoloc_tbl.LAST LOOP

	     BEGIN
	         csi_t_gen_utility_pvt.add( 'Processing Record : '||i);
            IF l_debug_level > 0 THEN
			    csi_t_gen_utility_pvt.add( 'Instance Id:'||p_csi_instance_geoloc_tbl(i).instance_id);
				csi_t_gen_utility_pvt.add( 'Latitude:'||p_csi_instance_geoloc_tbl(i).inst_latitude);
				csi_t_gen_utility_pvt.add( 'Longitude:'||p_csi_instance_geoloc_tbl(i).inst_longitude);
				csi_t_gen_utility_pvt.add( 'Geocode Format:'||p_csi_instance_geoloc_tbl(i).geocode_format);
				csi_t_gen_utility_pvt.add( 'Valid Flag:'||p_csi_instance_geoloc_tbl(i).Valid_flag);
			END IF;

            csi_t_gen_utility_pvt.add( 'calling validate instance');

			IF p_csi_instance_geoloc_tbl(i).instance_id IS NULL
     			OR p_csi_instance_geoloc_tbl(i).instance_id = FND_API.G_MISS_NUM THEN
			    IF p_asset_context = 'EAM' THEN
			      FND_MESSAGE.SET_NAME('CSI','CSI_ASSET_NOT_NULL');
			    ELSE
                  FND_MESSAGE.SET_NAME('CSI','CSI_INSTANCE_NOT_NULL');
                END IF;
	            FND_MSG_PUB.ADD;
		       x_return_status := FND_API.G_RET_STS_ERROR;
			   l_error_count:=l_error_count+1;
               RAISE  FND_API.G_EXC_ERROR;
			END IF;

			 /*validate Asset/instance  */
	      CSI_GIS_INSTANCE_LOC_UTL_PKG.VALIDATE_INSTANCE_NUMBER
	        (p_instance_id => p_csi_instance_geoloc_tbl(i).instance_id
			,p_asset_context => p_asset_context
			,x_instance_number => l_instance_number
		    ,x_create_update => l_create_update
		    ,x_return_status => l_return_status
	     	,x_msg_count     => l_msg_count
            ,x_msg_data      => l_msg_data
	     	);

            IF (TRIM(p_csi_instance_geoloc_tbl(i).inst_latitude) = 'DMS'
            	AND TRIM(p_csi_instance_geoloc_tbl(i).inst_longitude) = 'DMS')  THEN

				IF l_create_update = 'U' THEN
				   IF (l_debug_level > 0) THEN
                      csi_t_gen_utility_pvt.add( 'Invalidating Instance geo location info');
                    END IF;


		           CSI_GIS_INSTANCE_GEO_LOC_PVT.UPDATE_ROW
                    ( p_instance_id    => p_csi_instance_geoloc_tbl(i).instance_id
                    ,p_inst_latitude  => l_inst_latitude_dd_value
                    ,p_inst_longitude => l_inst_longitude_dd_value
			        ,p_valid_flag     => 'N'
                    ,x_return_status => l_return_status
                    );

		          	IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

                       l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
				       csi_t_gen_utility_pvt.add('Error Message:'||l_msg_data);
			  	       IF FND_API.To_Boolean(p_commit) THEN
				          UPDATE csi_ii_geoloc_interface
				          SET process_flag = 'E',
					          error_message=l_msg_data,
						      process_date=sysdate
			              WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
				          AND PROCESS_FLAG = 'R';
                       END IF;
				       l_error_count:=l_error_count+1;
		              --  Continue processing other records
				      RAISE  FND_API.G_EXC_ERROR;
                   END IF;
		          RAISE  FND_API.G_EXC_ERROR;
                ELSE
			      RAISE  FND_API.G_EXC_ERROR;
			   END IF;
			END IF;

      IF (l_instance_tbl.EXISTS(p_csi_instance_geoloc_tbl(i).instance_id)) THEN
              IF p_asset_context = 'EAM' THEN
			     FND_MESSAGE.SET_NAME('CSI','CSI_GIS_DUPLICATE_ASSET');
			  ELSE
                 FND_MESSAGE.SET_NAME('CSI','CSI_GIS_DUPLICATE_INSTANCE');
              END IF;
			   FND_MESSAGE.SET_TOKEN('INSTANCE',l_instance_number);
		       FND_MSG_PUB.ADD;
		       x_return_status := FND_API.G_RET_STS_ERROR;
			   l_error_count:=l_error_count+1;
               RAISE  FND_API.G_EXC_ERROR;
	  END IF;

			 l_instance_tbl(p_csi_instance_geoloc_tbl(i).instance_id) := 'Y'   ;

     	csi_t_gen_utility_pvt.add( 'Return Status:'||l_return_status);
			IF l_debug_level > 0 THEN
	    	  	csi_t_gen_utility_pvt.add( 'l_create_update:'||l_create_update);
			    csi_t_gen_utility_pvt.add( 'l_instance_number:'||l_instance_number);
            END IF;

			IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

 				l_error_count:=l_error_count+1;
				l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
				csi_t_gen_utility_pvt.add('Error Message:'||l_msg_data);
				IF FND_API.To_Boolean(p_commit) THEN
				   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'E',
					      error_message=l_msg_data,
						  process_date=sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
				   AND PROCESS_FLAG = 'R';
                END IF;
		          --  Continue processing other records
                  RAISE  FND_API.G_EXC_ERROR;
		    END IF;

			/*If delete from UI, this invalidates the geolocation information for asset/instance */
         IF p_CSI_instance_geoloc_tbl(i).valid_flag = 'N' THEN

		    IF (l_debug_level > 0) THEN
                csi_t_gen_utility_pvt.add( 'Invalidating Instance geo location info');
            END IF;

		        CSI_GIS_INSTANCE_GEO_LOC_PVT.UPDATE_ROW
             ( p_instance_id    => p_csi_instance_geoloc_tbl(i).instance_id
              ,p_inst_latitude  => l_inst_latitude_dd_value
              ,p_inst_longitude => l_inst_longitude_dd_value
			  ,p_valid_flag     => p_csi_instance_geoloc_tbl(i).valid_flag
              ,x_return_status => l_return_status
              );

		      	IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

                    l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
					csi_t_gen_utility_pvt.add('Error Message:'||l_msg_data);
				 IF FND_API.To_Boolean(p_commit) THEN
				   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'E',
					      error_message=l_msg_data,
						  process_date=sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
				   AND PROCESS_FLAG = 'R';
                END IF;
				  l_error_count:=l_error_count+1;
		          --  Continue processing other records
                  Return;
		        END IF;
		     Return;
        END IF;

        csi_t_gen_utility_pvt.add( 'calling validate latitude longitude');

	    /*This procedure is called to validate the latitude and longitude values*/
		CSI_GIS_INSTANCE_LOC_UTL_PKG.VALIDATE_LATITUDE_LONGITUDE
		   (p_latitude  => p_csi_instance_geoloc_tbl(i).inst_latitude
		   ,p_longitude => p_csi_instance_geoloc_tbl(i).inst_longitude
		   ,p_geocode_format => p_csi_instance_geoloc_tbl(i).geocode_format
		   ,p_instance_number => l_instance_number
		   ,x_return_status => l_return_status
		   ,x_msg_count     => l_msg_count
           ,x_msg_data      => l_msg_data
		    ) ;

		csi_t_gen_utility_pvt.add( 'Return Status:'||l_return_status);

		  IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		        l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
				csi_t_gen_utility_pvt.add('Error Message:'||l_msg_data);

				IF FND_API.To_Boolean(p_commit) THEN
				   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'E',
					      error_message=l_msg_data,
						  process_date=sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
					AND PROCESS_FLAG = 'R';
                END IF;

				l_error_count:=l_error_count+1;
		    --  Continue processing other records
                  RAISE  FND_API.G_EXC_ERROR;
		  END IF;

		  /*IF geocode format is 'DD'  no need to convert latitude and longitude values*/
		  IF p_CSI_instance_geoloc_tbl(i).geocode_format IN ('DMS','DM') THEN

            csi_t_gen_utility_pvt.add( 'Convert Latitude value to DD');

			/* calling procedure to convert latitude to DD value */
			CSI_GIS_INSTANCE_LOC_UTL_PKG.CONVERT_DMS_OR_DM_TO_DD
		    (p_value          =>  p_csi_instance_geoloc_tbl(i).inst_latitude
            ,p_mode           =>  'LAT'
            ,p_geocode_format => p_csi_instance_geoloc_tbl(i).geocode_format
			,p_instance_number => l_instance_number
            ,x_value          =>  l_inst_latitude_dd_value
            ,x_return_status  =>  l_return_status
            ,x_msg_count	  =>  l_msg_count
            ,x_msg_data	      =>  l_msg_data
			);

            csi_t_gen_utility_pvt.add( 'Return Status:'||l_return_status);

			IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		        l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
		        csi_t_gen_utility_pvt.add('Error Message:'||l_msg_data);
				IF FND_API.To_Boolean(p_commit) THEN
				   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'E',
					      error_message=l_msg_data,
						  process_date=sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
					AND PROCESS_FLAG = 'R';
                END IF;
				 l_error_count:=l_error_count+1;
		    --  Continue processing other records
                  RAISE  FND_API.G_EXC_ERROR;
		    END IF;

			csi_t_gen_utility_pvt.add( 'Convert Latitude value to DD');

			/* calling procedure to convert longitude to DD value */
			 CSI_GIS_INSTANCE_LOC_UTL_PKG.CONVERT_DMS_OR_DM_TO_DD
		    (p_value          =>  p_csi_instance_geoloc_tbl(i).inst_longitude
            ,p_mode           =>  'LON'
            ,p_geocode_format => p_csi_instance_geoloc_tbl(i).geocode_format
			,p_instance_number => l_instance_number
            ,x_value          =>  l_inst_longitude_dd_value
            ,x_return_status  =>  l_return_status
            ,x_msg_count	  =>  l_msg_count
            ,x_msg_data	      =>  l_msg_data
			);

             csi_t_gen_utility_pvt.add( 'Return Status:'||l_return_status);

			IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		       l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
			   csi_t_gen_utility_pvt.add('Error Message:'||l_msg_data);
				IF FND_API.To_Boolean(p_commit) THEN
				   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'E',
					      error_message=l_msg_data,
						  process_date=sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
					AND PROCESS_FLAG = 'R';
                END IF;
			   l_error_count:=l_error_count+1;
		    --  Continue processing other records
                  RAISE  FND_API.G_EXC_ERROR;
		    END IF;
		 ELSIF p_CSI_instance_geoloc_tbl(i).geocode_format IN ('DD') THEN

			l_inst_latitude_dd_value:=to_number(p_csi_instance_geoloc_tbl(i).inst_latitude);
		    l_inst_longitude_dd_value:=to_number(p_csi_instance_geoloc_tbl(i).inst_longitude);

		 END IF;

         /*l_create_update = 'C' indicates that latitude and longitude values are being entered for the first time for asset/instance */
		 IF l_create_update = 'C' THEN

             csi_t_gen_utility_pvt.add( 'Calling Insert row');

		     CSI_GIS_INSTANCE_GEO_LOC_PVT.INSERT_ROW
             ( p_instance_id    => p_CSI_instance_geoloc_tbl(i).instance_id
              ,p_inst_latitude  => l_inst_latitude_dd_value
              ,p_inst_longitude => l_inst_longitude_dd_value
              , x_return_status => l_return_status
              );

			 csi_t_gen_utility_pvt.add( 'Return Status:'||l_return_status);

             IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
				 csi_t_gen_utility_pvt.add('Error Message:'||l_msg_data);
				IF FND_API.To_Boolean(p_commit) THEN
				   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'E',
					      error_message=l_msg_data,
						  process_date=sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
				  AND PROCESS_FLAG = 'R';
                END IF;
			   l_error_count:=l_error_count+1;
		    --  Continue processing other records
                  RAISE  FND_API.G_EXC_ERROR;
		     END IF;

			IF FND_API.To_Boolean( p_commit ) THEN
			   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'P',
					      process_date = sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
					AND PROCESS_FLAG = 'R';
               COMMIT WORK;
			    csi_t_gen_utility_pvt.add( 'Completed Processing Record#:'||i);
		    END IF;

		   /*l_create_update = 'U' indicates that latitude and longitude values are already present for the asset/instance and they are just being updated*/
          ELSIF l_create_update = 'U'   THEN

               csi_t_gen_utility_pvt.add( 'Calling Update row');
               /* Updating information for an existing instance */
			  CSI_GIS_INSTANCE_GEO_LOC_PVT.UPDATE_ROW
             ( p_instance_id    => p_CSI_instance_geoloc_tbl(i).instance_id
              ,p_inst_latitude  => l_inst_latitude_dd_value
              ,p_inst_longitude => l_inst_longitude_dd_value
			        ,p_valid_flag     => p_CSI_instance_geoloc_tbl(i).valid_flag
              , x_return_status => l_return_status
              );

			IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	            l_msg_data:=fnd_msg_pub.get(fnd_msg_pub.G_LAST, FND_API.G_FALSE);
				csi_t_gen_utility_pvt.add(l_msg_data);
				IF FND_API.To_Boolean(p_commit) THEN
				   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'E',
					      error_message=l_msg_data,
						  process_date = sysdate
			       WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
					AND PROCESS_FLAG = 'R';
                END IF;
			   l_error_count:=l_error_count + 1;
		    --  Continue processing other records
                  RAISE  FND_API.G_EXC_ERROR;
		    END IF;

			IF FND_API.To_Boolean( p_commit ) THEN
			   UPDATE csi_ii_geoloc_interface
				      SET process_flag = 'P',
					      process_date = sysdate
			          WHERE  instance_number = (select instance_number
					                          FROM CSI_ITEM_INSTANCES
                                              WHERE instance_id = p_csi_instance_geoloc_tbl(i).instance_id)
                      AND PROCESS_FLAG = 'R' ;
               COMMIT WORK;
			     csi_t_gen_utility_pvt.add( 'Completed Processing Record#:'||i);
		    END IF;
	     END IF;
        EXCEPTION
           	 WHEN FND_API.G_EXC_ERROR THEN

                NULL;
        END;
      END LOOP;
    END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
	   csi_t_gen_utility_pvt.add( 'Returning to Import API');
       return;
	END IF;

	IF l_error_count > 0 THEN
	   RAISE FND_API.G_EXC_ERROR;
    END IF;

	COMMIT WORK;

    csi_t_gen_utility_pvt.add( 'Completed Processing Records');

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
				csi_t_gen_utility_pvt.add( 'Error in Processing Records');
				csi_t_gen_utility_pvt.add( 'Error Count:'||l_error_count);
                ROLLBACK TO CREATEUPDATE_INST_GEOLOC_INFO;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
          				p_count => x_msg_count,
                        p_data  => x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				csi_t_gen_utility_pvt.add( 'Error in Processing Records');
                ROLLBACK TO CREATEUPDATE_INST_GEOLOC_INFO;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
         				p_count => x_msg_count,
                        p_data  => x_msg_data
                );

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				csi_t_gen_utility_pvt.add( 'Error in Processing Records');
                ROLLBACK TO CREATEUPDATE_INST_GEOLOC_INFO;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
             l_api_name
                );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
         				p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

END CREATEUPDATE_INST_GEOLOC_INFO;

PROCEDURE IMPORT_INSTANCE_GEO_LOCATION
(
    p_api_version       IN	NUMBER,
    p_commit	    	IN  	VARCHAR2 := FND_API.G_TRUE	,
    x_return_status     OUT     NOCOPY  VARCHAR2                ,
    x_msg_count		OUT	NOCOPY	NUMBER			,
    x_msg_data		OUT	NOCOPY	VARCHAR2
 )  IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'IMPORT_INSTANCE_GEO_LOCATION';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_debug_level                   NUMBER;
   l_return_status           VARCHAR2(1);
   l_record_status           VARCHAR2(1);
   l_error_count NUMBER:=0;
   l_msg_count NUMBER;
   l_msg_data  VARCHAR2(4000);
   l_index BINARY_INTEGER:=0;
   l_instance_id NUMBER;
   l_csi_instance_geoloc_tbl        CSI_GIS_INSTANCE_LOC_PUB.CSI_instance_geoloc_tbl_type;
   l_count NUMBER;
   l_geocode_format VARCHAR2(3);

   CURSOR import_inst_geo_loc_cur IS
       SELECT *
	   FROM csi_ii_geoloc_interface
	   WHERE process_flag = 'R';

	TYPE import_inst_geo_loc_tbl_type IS TABLE OF csi_ii_geoloc_interface%ROWTYPE;
   import_inst_geo_loc_tbl import_inst_geo_loc_tbl_type;
BEGIN

    -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME   )   THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   --  Initialize API return status to success
	x_return_status         := FND_API.G_RET_STS_SUCCESS;

	-- Check the profile option debug_level for debug message reporting
     l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

     -- If debug_level >0 then dump the procedure name
     IF (l_debug_level > 0) THEN
        csi_t_gen_utility_pvt.add( 'IMPORT_INSTANCE_GEO_LOCATION');
     END IF;

	 OPEN import_inst_geo_loc_cur;
	 FETCH import_inst_geo_loc_cur BULK COLLECT INTO import_inst_geo_loc_tbl;
	 CLOSE import_inst_geo_loc_cur;



	 FOR i IN import_inst_geo_loc_tbl.FIRST..import_inst_geo_loc_tbl.LAST LOOP

        BEGIN
		   SELECT Count(instance_number)
		   INTO l_count
		   FROM csi_ii_geoloc_interface
           WHERE instance_number = import_inst_geo_loc_tbl(i).instance_number
		   AND PROCESS_FLAG = 'R';

		   /*checking for duplicate instances*/
		   IF l_count > 1 OR l_count = 0 THEN
		     l_error_count  := l_error_count + 1;
			 l_record_status:='E';
		     UPDATE csi_ii_geoloc_interface
		     SET process_flag = 'E',
			     error_message = FND_MESSAGE.Get_String('CSI', 'CSI_GIS_DUP_INST_ASSET'),
				 process_date=sysdate
		     WHERE instance_number = import_inst_geo_loc_tbl(i).instance_number
			 AND PROCESS_FLAG = 'R';
 			 RAISE  FND_API.G_EXC_ERROR;
		   END IF;

	       BEGIN
		     SELECT instance_id
		     INTO l_instance_id
		     FROM csi_item_instances
			 WHERE 	instance_number = import_inst_geo_loc_tbl(i).instance_number;
		   EXCEPTION
             WHEN NO_DATA_FOUND THEN

                 l_error_count  := l_error_count + 1;
				 l_record_status:='E';
				 UPDATE csi_ii_geoloc_interface
				 SET process_flag = 'E',
				     error_message = FND_MESSAGE.Get_String('CSI', 'CSI_INSTANCE_NOT_FOUND'),
					 process_date=sysdate
			     WHERE instance_number = import_inst_geo_loc_tbl(i).instance_number
				 AND PROCESS_FLAG = 'R';
 				 RAISE  FND_API.G_EXC_ERROR;

		   END;

          /*checking for valid geocode formats*/

           l_geocode_format:=Trim(import_inst_geo_loc_tbl(i).geocode_format);

           IF   NOT( l_geocode_format = 'DMS'
			              OR l_geocode_format = 'DM'
                    OR l_geocode_format = 'DD'
		                OR l_geocode_format IS NULL
                    OR Length(l_geocode_format)IS  NULL) THEN

           	 l_error_count  := l_error_count + 1;
             l_record_status:='E';
	         UPDATE csi_ii_geoloc_interface
	         SET process_flag = 'E',
		         error_message = FND_MESSAGE.Get_String('CSI', 'CSI_INVALID_GEOCODE_FORMAT'),
		         process_date=sysdate
		     WHERE instance_number = import_inst_geo_loc_tbl(i).instance_number
		       AND PROCESS_FLAG = 'R';
 		     RAISE  FND_API.G_EXC_ERROR;
		   END IF;

            l_index:=l_index + 1;
		    l_csi_instance_geoloc_tbl(l_index).INSTANCE_ID    :=l_instance_id;
		    l_csi_instance_geoloc_tbl(l_index).INST_LATITUDE  :=import_inst_geo_loc_tbl(i).inst_latitude;
            l_csi_instance_geoloc_tbl(l_index).INST_LONGITUDE :=import_inst_geo_loc_tbl(i).inst_longitude;
            IF Length(l_geocode_format)IS  NULL OR l_geocode_format IS NULL THEN
                l_csi_instance_geoloc_tbl(l_index).GEOCODE_FORMAT := 'DMS';
            ELSE
                l_csi_instance_geoloc_tbl(l_index).GEOCODE_FORMAT :=import_inst_geo_loc_tbl(i).geocode_format;
            END IF;
        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
               NULL;
        END;
	 END LOOP;

   	 /*calling create update API*/
	 IF l_csi_instance_geoloc_tbl.count > 0 THEN

         CSI_GIS_INSTANCE_LOC_PUB.CREATEUPDATE_INST_GEOLOC_INFO(p_api_version => 1,
                                                                p_commit      => FND_API.G_TRUE
                                                                ,p_csi_instance_geoloc_tbl => l_csi_instance_geoloc_tbl
																,x_return_status => l_return_status
																,x_msg_count     => l_msg_count
																,x_msg_data      => l_msg_data);
     END IF;

      csi_t_gen_utility_pvt.add( 'No of errored records: '||to_char(l_msg_count + l_error_count));
	  csi_t_gen_utility_pvt.add( 'Completed processing records');

END IMPORT_INSTANCE_GEO_LOCATION;

END CSI_GIS_INSTANCE_LOC_PUB;

/
