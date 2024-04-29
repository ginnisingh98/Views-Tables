--------------------------------------------------------
--  DDL for Package Body EAM_PM_LAST_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PM_LAST_SERVICE_PUB" AS
/* $Header: EAMPPLSB.pls 120.2 2005/11/28 04:55:57 kmurthy noship $ */
-- Start of comments
--	API name 	: EAM_PM_LAST_SERVICE_PUB
--	Type		: Public
--	Function	: insert_pm_last_service, update_pm_last_service
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_PM_LAST_SERVICE_PUB';



procedure validate_pm_last_service(p_meter_id in number, p_actv_assoc_id in number)
is

CURSOR c_val_meter_id(p_meter_id  number)
IS
      select 'X' from dual where exists
        (select COUNTER_ID from CSI_COUNTERS_B where counter_id = p_meter_id
         union
         select COUNTER_ID from CSI_COUNTER_TEMPLATE_B where counter_id = p_meter_id) ;
  --commnetd for perf issues
   /* SELECT 'X'
      from eam_counters_v where meter_id = p_meter_id;*/

CURSOR c_val_act_assoc_id(P_ACTIVITY_ASSOCIATION_ID number)
IS
 SELECT 'X'
 from mtl_eam_asset_activities where activity_association_id = p_activity_association_id;

CURSOR c_meter_act_assoc(P_ACTIVITY_ASSOCIATION_ID number, p_meter_id  number)
IS
 SELECT 'X' from mtl_eam_asset_activities meaa, CSI_COUNTER_ASSOCIATIONS eam,
  CSI_COUNTERS_B em where meaa.activity_association_id
  = p_activity_association_id
  and meaa.maintenance_object_id = eam.SOURCE_OBJECT_ID and eam.COUNTER_id =
  em.COUNTER_id and eam.COUNTER_id = p_meter_id and em.used_in_scheduling = 'Y' ;
   --commnetd for perf issues
   /* SELECT 'X'
   from mtl_eam_asset_activities meaa, eam_asset_meters_v eam, eam_counters_v em
   where meaa.activity_association_id = p_activity_association_id
    and meaa.maintenance_object_id = eam.maintenance_object_id
    and eam.meter_id = em.meter_id
    and eam.meter_id = p_meter_id
     and em.used_in_scheduling = 'Y';*/


	l_dummy 			VARCHAR2(1);
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);

begin
             if P_meter_id is null or p_actv_assoc_id is null
             then
                   FND_MESSAGE.SET_NAME('EAM','EAM_IAA_ID_MISSING');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
              end if;

	     open c_val_meter_id(p_meter_id);
	     fetch c_val_meter_id into l_dummy;
               IF c_val_meter_id%NOTFOUND
               THEN
                   FND_MESSAGE.SET_NAME('EAM','EAM_IAA_INV_METER_ID');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
                END IF;
              CLOSE c_val_meter_id;

	     open c_val_act_assoc_id(p_actv_assoc_id);
	     fetch c_val_act_assoc_id into l_dummy;
               IF c_val_act_assoc_id%NOTFOUND
               THEN
                   FND_MESSAGE.SET_NAME('EAM','EAM_IAA_INV_ACTIVITY_ASSOC_ID');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
                END IF;
              CLOSE c_val_act_assoc_id;

	      open c_meter_act_assoc(p_actv_assoc_id, p_meter_id);
	      fetch c_meter_act_assoc into l_dummy;
              IF c_meter_act_assoc %NOTFOUND
               THEN
                   FND_MESSAGE.SET_NAME('EAM','EAM_IAA_INV_METER_ID');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
                END IF;
              CLOSE c_meter_act_assoc;



end validate_pm_last_service;

PROCEDURE process_pm_last_service
(
	p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	,
	x_msg_count			OUT NOCOPY NUMBER	,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	p_pm_last_service_tbl           IN       pm_last_service_tbl,
	p_actv_assoc_id                 in       number
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'APIname';
	l_api_version           	CONSTANT NUMBER 		:= 1.0;
	l_boolean                       number;
	l_return_status	 		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data		 	VARCHAR2(30);
	l_dummy 			VARCHAR2(1);


CURSOR c_check_update(p_meter_id  number, p_actv_assoc_id number)
IS
 SELECT 'X'
 from EAM_PM_LAST_SERVICE where meter_id = p_meter_id and activity_association_id = p_actv_assoc_id;


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	process_pm_last_service;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body
        IF p_pm_last_service_tbl.count >0
        THEN
                FOR i IN p_pm_last_service_tbl.FIRST..p_pm_last_service_tbl.LAST
                LOOP

		validate_pm_last_service(p_pm_last_service_tbl(i).meter_id, p_actv_assoc_id );

                IF (p_pm_last_service_tbl(i).last_service_reading is null /*or
		    p_pm_last_service_tbl(i).prev_service_reading is null*/ ) THEN

		    FND_MESSAGE.SET_NAME('EAM','EAM_NULL_METER_READING');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;

		END IF;

	        open c_check_update(p_pm_last_service_tbl(i).meter_id,p_actv_assoc_id);
	        fetch c_check_update into l_dummy;
	        if c_check_update%NOTFOUND
	        THEN
			INSERT INTO EAM_PM_LAST_SERVICE
			(
				METER_ID		,
				ACTIVITY_ASSOCIATION_ID ,
				LAST_SERVICE_READING    ,
				PREV_SERVICE_READING    ,
				--WIP_ENTITY_ID           ,

				CREATED_BY           ,
				CREATION_DATE       ,
				LAST_UPDATE_LOGIN  ,
				LAST_UPDATE_DATE  ,
				LAST_UPDATED_BY
			)
			VALUES
			(
				p_pm_last_service_tbl(i).METER_ID		,
				p_actv_assoc_id,
				p_pm_last_service_tbl(i).LAST_SERVICE_READING	,
				p_pm_last_service_tbl(i).PREV_SERVICE_READING	,
				--p_WIP_ENTITY_ID       	,

				fnd_global.user_id,
				sysdate,
				fnd_global.login_id,
				sysdate    ,
				fnd_global.user_id
			);

		ELSE
			UPDATE EAM_PM_LAST_SERVICE
			SET
			   METER_ID	 	 =	p_pm_last_service_tbl(i).METER_ID,
			   ACTIVITY_ASSOCIATION_ID	 =	p_actv_assoc_id,
			   LAST_SERVICE_READING	 =	p_pm_last_service_tbl(i).LAST_SERVICE_READING,
			   PREV_SERVICE_READING	 =	p_pm_last_service_tbl(i).PREV_SERVICE_READING,
			   --WIP_ENTITY_ID       	 =	p_WIP_ENTITY_ID       ,

				LAST_UPDATE_LOGIN	 =	fnd_global.login_id	,
				LAST_UPDATE_DATE	 =	sysdate	,
				LAST_UPDATED_BY		 =	fnd_global.user_id
			WHERE METER_ID = p_pm_last_service_tbl(i).METER_ID AND
			      ACTIVITY_ASSOCIATION_ID = p_actv_assoc_id;
		END IF;
		CLOSE c_check_update;

	END LOOP;
	END IF;



	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO process_pm_last_service;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data          	,
        		P_ENCODED               =>       FND_API.G_FALSE
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO process_pm_last_service;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data       ,
        		P_ENCODED               =>       FND_API.G_FALSE
    		);
	WHEN OTHERS THEN
		ROLLBACK TO process_pm_last_service;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data       ,
        		P_ENCODED               =>       FND_API.G_FALSE
    		);
END process_pm_last_service;


END EAM_PM_LAST_SERVICE_PUB;

/
