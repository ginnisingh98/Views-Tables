--------------------------------------------------------
--  DDL for Package Body RRS_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_ASSETS_PKG" AS
/* $Header: RRSASSTB.pls 120.9 2008/01/26 00:40:14 sunarang noship $ */

PROCEDURE CREATE_ASSET_INSTANCES
     ( errbuf			OUT NOCOPY VARCHAR2
      ,retcode			OUT NOCOPY VARCHAR2
      ,p_source_instance_id	IN  NUMBER
      ,p_additional_instances	IN  VARCHAR2
      ,p_session_id		IN  VARCHAR2
     )
IS

	CURSOR SELECTED_SITES_CUR IS
	SELECT SITE_ID
	FROM   RRS_SITES_INTF
	WHERE  SESSION_ID = p_session_id;

	CURSOR SELECTED_SITE_DET_CUR( c_site_id IN NUMBER ) IS
	SELECT PARTY_SITE_ID
	FROM   RRS_SITES_B
	WHERE  SITE_ID = c_site_id ;

	CURSOR SUBJECT_IDS_CUR IS
	SELECT cii.SUBJECT_ID
	      ,csi.INVENTORY_ITEM_ID
	      ,csi.LAST_VLD_ORGANIZATION_ID
              ,LEVEL
	FROM  CSI_II_RELATIONSHIPS cii,
	      CSI_ITEM_INSTANCES csi
	WHERE cii.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
	  AND cii.SUBJECT_ID = csi.INSTANCE_ID
	  AND TRUNC(NVL(cii.ACTIVE_START_DATE , SYSDATE)) <= TRUNC(SYSDATE)
       AND TRUNC(NVL(cii.ACTIVE_END_DATE , SYSDATE )) >= TRUNC(SYSDATE)
	START WITH cii.OBJECT_ID = p_source_instance_id
	CONNECT BY PRIOR cii.SUBJECT_ID = cii.OBJECT_ID
        ORDER BY LEVEL;

        CURSOR OBJECT_ID_CURS(c_subject_id NUMBER) IS
        SELECT cii.SUBJECT_ID OBJECT_ID
              ,csi.INVENTORY_ITEM_ID INVENTORY_ITEM_ID
  	 FROM  CSI_II_RELATIONSHIPS cii,
	       CSI_ITEM_INSTANCES csi
	WHERE  cii.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
	  AND  cii.OBJECT_ID = csi.INSTANCE_ID
	  AND  TRUNC(NVL(cii.ACTIVE_START_DATE , SYSDATE)) <= TRUNC(SYSDATE)
          AND  TRUNC(NVL(cii.ACTIVE_END_DATE , SYSDATE )) >= TRUNC(SYSDATE)
          AND cii.OBJECT_ID = p_source_instance_id
	START WITH cii.SUBJECT_ID = c_subject_id
	CONNECT BY PRIOR cii.OBJECT_ID = cii.SUBJECT_ID ;

        CURSOR LEVEL_ONE_ASSET_INSTANCES(c_party_site_id NUMBER) IS
        SELECT  CSI.INSTANCE_ID
               ,CSI.INVENTORY_ITEM_ID
          FROM  CSI_ITEM_INSTANCES CSI
         WHERE  LOCATION_ID = c_party_site_id
           AND  NOT EXISTS (SELECT 1 FROM CSI_II_RELATIONSHIPS CII WHERE CII.SUBJECT_ID = CSI.INSTANCE_ID) ;



	l_return_status  VARCHAR2(1);
	l_msg_count      NUMBER;
	l_msg_data       VARCHAR2(2000);

	l_instance_rec	                csi_datastructures_pub.instance_rec;
	l_transaction_rec               csi_datastructures_pub.transaction_rec;
	l_instance_tbl                  csi_datastructures_pub.instance_tbl;
	l_relationship_query_rec        csi_datastructures_pub.relationship_query_rec;
	l_ii_relationship_tbl           csi_datastructures_pub.ii_relationship_tbl;
	l_party_site_id                 rrs_sites_b.site_party_id%TYPE;


	TYPE l_parent_child_ids_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	l_parent_child_ids_tbl	        l_parent_child_ids_tbl_type ;
        l_level_one_instance_id_tbl     l_parent_child_ids_tbl_type ;
        l_inv_item_id_tbl               l_parent_child_ids_tbl_type ;
        l_tmp_tbl                       l_parent_child_ids_tbl_type ;
	l_exists_flag		        VARCHAR2(1) := 'N';
	l_conc_or_online                VARCHAR2(30);
        l_parent_id                     NUMBER ;

BEGIN
	SAVEPOINT begin_create_assets;

        l_conc_or_online := nvl(FND_PROFILE.VALUE('RRS_ASSET_CREATION_MODE'),'ONLINE') ;

	FOR siterec IN SELECTED_SITES_CUR LOOP

		OPEN SELECTED_SITE_DET_CUR(siterec.SITE_ID);
		FETCH SELECTED_SITE_DET_CUR INTO l_party_site_id;
		CLOSE SELECTED_SITE_DET_CUR;

		IF p_additional_instances = 'N' THEN

                  OPEN LEVEL_ONE_ASSET_INSTANCES(l_party_site_id);
 		  FETCH LEVEL_ONE_ASSET_INSTANCES BULK COLLECT INTO  l_level_one_instance_id_tbl , l_tmp_tbl;
  	          CLOSE LEVEL_ONE_ASSET_INSTANCES;

                  -- This is done just to ease the process of checking whether
                  -- inv_item_id already exists. Which is used in the code down
                  -- the line .

                  IF (nvl(l_tmp_tbl.LAST,0)> 0) THEN
                     FOR i in l_tmp_tbl.FIRST..l_tmp_tbl.LAST LOOP
                        l_inv_item_id_tbl(l_tmp_tbl(i)) := l_tmp_tbl(i);
           	     END LOOP;
      		  END IF ;

   		 END IF ;

		 FOR rec IN SUBJECT_IDS_CUR LOOP

			l_instance_rec.INSTANCE_ID := rec.SUBJECT_ID ;

			IF p_additional_instances = 'N' THEN

	        -- If its a asset instance at level one
        	-- and its already been applied once , we
        	-- do not want to copy and its child again

			 l_exists_flag := 'N' ;
		         IF rec.LEVEL = 1 THEN
		            IF l_inv_item_id_tbl.EXISTS(rec.INVENTORY_ITEM_ID) THEN
		            l_exists_flag := 'Y' ;
		          END IF ;
                         ELSE
		        -- Get its parent at level one .
		          FOR rec1 in OBJECT_ID_CURS(rec.SUBJECT_ID) LOOP
		           IF l_inv_item_id_tbl.EXISTS(rec1.INVENTORY_ITEM_ID) THEN
               	                l_exists_flag := 'Y' ;
               		          EXIT;
		            ELSE
			        l_exists_flag := 'N' ;
		            END IF ;
		          END LOOP ;
		        END IF ;
/**************************************
        BEGIN
				  SELECT 'Y'
				  INTO l_exists_flag
				  FROM DUAL
				  WHERE EXISTS ( SELECT 'Y'
				      FROM CSI_ITEM_INSTANCES csi
				      WHERE csi.location_id = l_party_site_id
 					 --AND csi.instance_id = rec.subject_id Bug#4548344
				        AND csi.inventory_item_id = rec.inventory_item_id --csi.inventory_item_id
				        AND csi.last_vld_organization_id = rec.last_vld_organization_id
				      ) ;
  				  --AND csi.location_id = l_party_site_id ;
				  --AND csi.instance_id = rec.subject_id Bug#4548344

				  EXCEPTION
				  WHEN NO_DATA_FOUND THEN
					l_exists_flag := 'N' ;
				  WHEN OTHERS THEN
					l_exists_flag := 'N' ;
				END;
**************************************/
			END IF;

			l_instance_rec.LOCATION_ID := l_party_site_id ;
			l_instance_rec.LOCATION_TYPE_CODE := 'HZ_PARTY_SITES';
			l_instance_rec.SERIAL_NUMBER := null;

			l_transaction_rec.source_transaction_date := SYSDATE ;
			l_transaction_rec.transaction_type_id := 1 ;

			IF l_exists_flag = 'N' THEN
				CSI_ITEM_INSTANCE_PUB.COPY_ITEM_INSTANCE
				(
				  p_api_version		   => 1.0
				 ,p_commit		   => fnd_api.g_false
				 ,p_init_msg_list	   => fnd_api.g_false
				 ,p_validation_level	   => fnd_api.g_valid_level_full
				 ,p_source_instance_rec    => l_instance_rec
				 ,p_copy_ext_attribs	   => fnd_api.g_false
				 ,p_copy_org_assignments   => fnd_api.g_false
				 ,p_copy_parties	   => fnd_api.g_false
				 ,p_copy_party_contacts    => fnd_api.g_false
				 ,p_copy_accounts	   => fnd_api.g_false
				 ,p_copy_asset_assignments => fnd_api.g_false
				 ,p_copy_pricing_attribs   => fnd_api.g_false
				 ,p_txn_rec		   => l_transaction_rec
				 ,x_new_instance_tbl	   => l_instance_tbl
				 ,x_return_status	   => l_return_status
				 ,x_msg_count              => l_msg_count
				 ,x_msg_data               => l_msg_data
				);

        l_parent_child_ids_tbl(l_instance_rec.INSTANCE_ID) := l_instance_tbl(1).INSTANCE_ID;
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					Raise FND_API.G_EXC_ERROR;
				END IF;
			END IF;
		END LOOP ;


		FOR rec IN SUBJECT_IDS_CUR LOOP
			l_relationship_query_rec.OBJECT_ID := rec.SUBJECT_ID;
			l_relationship_query_rec.RELATIONSHIP_TYPE_CODE := 'COMPONENT-OF';

			IF l_exists_flag = 'N' THEN
				CSI_II_RELATIONSHIPS_PUB.GET_RELATIONSHIPS
				(
				  p_api_version			=> 1.0
				 ,p_commit			=> fnd_api.g_false
				 ,p_init_msg_list		=> fnd_api.g_false
				 ,p_validation_level		=> fnd_api.g_valid_level_full
				 ,p_relationship_query_rec	=> l_relationship_query_rec
				 ,p_depth			=> 1
				 ,p_time_stamp			=> SYSDATE
				 ,p_active_relationship_only	=> fnd_api.g_true
				 ,x_relationship_tbl		=> l_ii_relationship_tbl
				 ,x_return_status		=> l_return_status
				 ,x_msg_count			=> l_msg_count
				 ,x_msg_data			=> l_msg_data
				);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					Raise FND_API.G_EXC_ERROR;
				END IF;

				   IF (l_ii_relationship_tbl.COUNT > 0) THEN
					FOR i IN l_ii_relationship_tbl.FIRST..l_ii_relationship_tbl.LAST LOOP

						l_ii_relationship_tbl(i).OBJECT_ID  := l_parent_child_ids_tbl(l_ii_relationship_tbl(i).OBJECT_ID) ;
						l_ii_relationship_tbl(i).SUBJECT_ID := l_parent_child_ids_tbl(l_ii_relationship_tbl(i).SUBJECT_ID) ;
						l_ii_relationship_tbl(i).RELATIONSHIP_ID := null;

					END LOOP ;

					l_transaction_rec.source_transaction_date := sysdate ;
					l_transaction_rec.transaction_type_id := 1 ;

					CSI_II_RELATIONSHIPS_PUB.CREATE_RELATIONSHIP
					(
						 p_api_version		=> 1.0
						,p_commit		=> fnd_api.g_false
						,p_init_msg_list	=> fnd_api.g_false
						,p_validation_level	=> fnd_api.g_valid_level_full
						,p_relationship_tbl	=> l_ii_relationship_tbl
						,p_txn_rec		=> l_transaction_rec
						,x_return_status	=> l_return_status
						,x_msg_count            => l_msg_count
						,x_msg_data             => l_msg_data
					);
					IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						Raise FND_API.G_EXC_ERROR;
					END IF;
				    END IF;
			END IF;  -- end l_exists_flag IF condition
		END LOOP ;  -- end SUBJECT_IDS_CUR cursor
	END LOOP ; -- end SELECTED_SITES_CUR FOR

--IF l_conc_or_online <> 'ONLINE' THEN
     DELETE FROM RRS_SITES_INTF WHERE SESSION_ID = p_session_id ;
	COMMIT;
--END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    retcode         := '1';
    errbuf          := SQLERRM;
    ROLLBACK TO begin_create_assets;
WHEN OTHERS THEN
    retcode         := '2';
    errbuf          := SQLERRM;
    ROLLBACK TO begin_create_assets;

END CREATE_ASSET_INSTANCES;

PROCEDURE CREATE_ASSET_INSTANCES_WRP
     ( p_source_instance_id	IN  NUMBER
      ,p_additional_instances	IN  VARCHAR2
      ,p_session_id		IN  VARCHAR2
      ,x_request_id		OUT NOCOPY NUMBER
      ,x_return_status		OUT NOCOPY VARCHAR2
      ,x_msg_count		OUT NOCOPY NUMBER
      ,x_msg_data		OUT NOCOPY VARCHAR2
     )
IS
	l_conc_or_online VARCHAR2(30);
	l_errbuf         VARCHAR2(2000);
	l_retcode	 VARCHAR2(2000);
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_conc_or_online := nvl(FND_PROFILE.VALUE('RRS_ASSET_CREATION_MODE'),'ONLINE') ;


    IF l_conc_or_online = 'ONLINE' THEN
	CREATE_ASSET_INSTANCES
	      (errbuf			=> l_errbuf
	      ,retcode			=> l_retcode
		 ,p_source_instance_id	=> p_source_instance_id
	      ,p_additional_instances	=> p_additional_instances
	      ,p_session_id		=> p_session_id
	     ) ;
	IF l_retcode <> '0' THEN
		Raise FND_API.G_EXC_ERROR;
	END IF;
    ELSE
	CREATE_ASSET_INSTANCES_CONC
	     ( p_source_instance_id	=> p_source_instance_id
	      ,p_additional_instances	=> p_additional_instances
	      ,p_session_id		=> p_session_id
	      ,x_request_id		=> x_request_id
	      ,x_return_status		=> x_return_status
	      ,x_msg_count		=> x_msg_count
	      ,x_msg_data		=> x_msg_data
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
END CREATE_ASSET_INSTANCES_WRP ;


PROCEDURE CREATE_ASSET_INSTANCES_CONC
     ( p_source_instance_id	IN  NUMBER
      ,p_additional_instances	IN  VARCHAR2
      ,p_session_id		IN  VARCHAR2
      ,x_request_id		OUT NOCOPY NUMBER
      ,x_return_status		OUT NOCOPY VARCHAR2
      ,x_msg_count		OUT NOCOPY NUMBER
      ,x_msg_data		OUT NOCOPY VARCHAR2
      )
IS

BEGIN
    x_msg_count     := 0 ;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_request_id := FND_REQUEST.SUBMIT_REQUEST
     (
           application                =>   'RRS'
          ,program                    =>   'RRSCREATEASSETS'
          ,description                =>   'RRS : Create Asset Instances For Sites'
          ,start_time                 =>   NULL
          ,sub_request                =>   false
          ,argument1                  =>   p_source_instance_id
          ,argument2                  =>   p_additional_instances
          ,argument3                  =>   p_session_id
     );

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
END CREATE_ASSET_INSTANCES_CONC ;

PROCEDURE POPULATE_RRS_SITES_INTF
      (  p_session_id		IN VARCHAR2
	,p_site_ids		IN RRS_NUMBER_TBL_TYPE DEFAULT NULL
	,p_created_by           IN NUMBER
	,p_creation_date        IN DATE
	,p_last_updated_by      IN NUMBER
	,p_last_update_date     IN DATE
	,p_last_update_login    IN NUMBER
	)
IS
BEGIN
	FORALL i in 1..p_site_ids.count
		INSERT INTO RRS_SITES_INTF
		( session_id
		 ,site_id
		 ,created_by
		 ,creation_date
		 ,last_updated_by
		 ,last_update_date
		 ,last_update_login )
		values
		( p_session_id
		 ,p_site_ids(i)
		 ,p_created_by
		 ,p_creation_date
		 ,p_last_updated_by
		 ,p_last_update_date
		 ,p_last_update_login
		 );

END POPULATE_RRS_SITES_INTF;


END RRS_ASSETS_PKG;


/
