--------------------------------------------------------
--  DDL for Package Body EAM_METERASSOC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METERASSOC_PUB" AS
/* $Header: EAMPAMAB.pls 120.12 2006/04/12 23:31:46 sshahid noship $ */
/*
--      API name        : EAM_MeterAssoc_PUB
--      Type            : Public
--      Function        : Insert, update and validation of the asset meter association
--      Pre-reqs        : None.
*/

/* for de-bugging */
/* g_sr_no		number ; */
g_object_type VARCHAR2(30) := EAM_CONSTANTS.G_OBJECT_TYPE;
--G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_MeterAssoc_PUB';


/*
This procedure inserts a record in the eam_asset_meters table
--      Parameters      :
--      IN              :       P_API_VERSION	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				p_meter_id		in	not null number ,
--				p_organization_id		in	not null number ,
--				p_asset_group_id		in	not null number ,
--				p_asset_number		in    varchar2 default null,
--				p_maintenance_object_type	in    number  default null,
--				p_maintenance_object_id	in    number  default null,
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--				x_new_set_name_id	OUT	NOCOPY	NUMBER
--      Version :       Current version: 1.0
--                      Initial version: 1.0
*/

PROCEDURE Insert_AssetMeterAssoc
(
	p_api_version		           IN	          Number,
	p_init_msg_list		         IN	          VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	           IN  	        VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	       IN  	        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		         OUT	NOCOPY  VARCHAR2,
	x_msg_count		             OUT	NOCOPY  Number,
	x_msg_data		             OUT	NOCOPY  VARCHAR2,
	p_meter_id		             IN	          Number,
/*	The user can supply one of the following two combinations to identify the
maintained item / number: the (org_id, inventory_item_id, serial_number)
combination or (maintenance_object_type, maintenance_object_id,
creation_organization_id) combination. Thus all of these input parameters
should be default to null.*/
	p_organization_id	         IN	          NUMBER DEFAULT NULL,
	p_asset_group_id	         IN	          NUMBER DEFAULT NULL,
	p_asset_number		         IN	          VARCHAR2 DEFAULT NULL,
	p_maintenance_object_type  IN	          NUMBER  DEFAULT NULL,
	p_maintenance_object_id	   IN	          NUMBER  DEFAULT NULL,
	p_primary_failure_flag	   IN	          VARCHAR2  DEFAULT 'N',
  p_ATTRIBUTE_CATEGORY       IN           VARCHAR2 default null,
  p_ATTRIBUTE1               IN           VARCHAR2 default null,
  p_ATTRIBUTE2               IN           VARCHAR2 default null,
  p_ATTRIBUTE3               IN           VARCHAR2 default null,
  p_ATTRIBUTE4               IN           VARCHAR2 default null,
  p_ATTRIBUTE5               IN           VARCHAR2 default null,
  p_ATTRIBUTE6               IN           VARCHAR2 default null,
  p_ATTRIBUTE7               IN           VARCHAR2 default null,
  p_ATTRIBUTE8               IN           VARCHAR2 default null,
  p_ATTRIBUTE9               IN           VARCHAR2 default null,
  p_ATTRIBUTE10              IN           VARCHAR2 default null,
  p_ATTRIBUTE11              IN           VARCHAR2 default null,
  p_ATTRIBUTE12              IN           VARCHAR2 default null,
  p_ATTRIBUTE13              IN           VARCHAR2 default null,
  p_ATTRIBUTE14              IN           VARCHAR2 default null,
  p_ATTRIBUTE15              IN           VARCHAR2 default null,
  p_start_date_active        IN           DATE default NULL,
  p_end_date_active          IN           DATE default null
)
IS
l_api_name	CONSTANT VARCHAR2(30)	:='Insert_AssetMeterAssoc';
l_api_version   CONSTANT NUMBER 	:= 1.0;
l_instance_association_id Number;
l_maintenance_object_id NUMBER;
l_start_date_active DATE;
l_ctr_item_association_rec CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec;
l_counter_associations_tbl CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl;
l_exists_primary_flag varchar2(1);
l_required_flag varchar2(1) := 'N';

l_module             varchar2(200);
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;
l_exists NUMBER := 0;
l_association_id NUMBER;
l_object_version_number NUMBER;

BEGIN
	/* Standard Start of API savepoint */
	SAVEPOINT Insert_AssetMeterAssoc_PUB;
	IF (l_ulog) THEN
             l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	END IF;

        IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_MeterAssoc_PUB.Insert_AssetMeterAssoc ====================');
	END IF;
	/* Standard call to check for call compatibility. */
	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME
					   )
        THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	/* Initialize message list if p_init_msg_list is set to TRUE. */
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	/* Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/* API body */

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'x_return_status: '||x_return_status);
	END IF;

	IF (p_start_date_active IS NULL) THEN
		l_start_date_active := SYSDATE;
	ELSE
	  l_start_date_active := p_start_date_active;
	END IF;

  IF (p_maintenance_object_id IS NULL AND p_asset_number IS NULL AND p_asset_group_id IS NOT NULL) THEN

    begin
    	if nvl(p_primary_failure_flag, 'N') = 'Y' then

    		select 'Y' into l_exists_primary_flag
    		from dual
    		where exists
    		(select * from csi_ctr_item_associations
    		 where inventory_item_id = p_asset_group_id
    		 and (end_date_active is null or end_date_active > sysdate)
    		 and nvl(primary_failure_flag, 'N') = 'Y');

    		if l_exists_primary_flag = 'Y' then
                    	FND_MESSAGE.SET_NAME('EAM', 'EAM_PRIMARY_FLAG_EXISTS');
                      	FND_MSG_PUB.ADD;
                      	RAISE  FND_API.G_EXC_ERROR;
    		end if;

    	end if;
    exception when no_data_found then
        null;
    end;


    l_ctr_item_association_rec.counter_id := p_meter_id;
  	l_ctr_item_association_rec.inventory_item_id := p_asset_group_id;
  	l_ctr_item_association_rec.start_date_active := l_start_date_active;
  	l_ctr_item_association_rec.end_date_active := p_end_date_active;
  	l_ctr_item_association_rec.primary_failure_flag := p_primary_failure_flag;
  	l_ctr_item_association_rec.attribute_category := p_attribute_category;
  	l_ctr_item_association_rec.attribute1 := p_attribute1;
  	l_ctr_item_association_rec.attribute2 := p_attribute2;
  	l_ctr_item_association_rec.attribute3 := p_attribute3;
  	l_ctr_item_association_rec.attribute4 := p_attribute4;
  	l_ctr_item_association_rec.attribute5 := p_attribute5;
  	l_ctr_item_association_rec.attribute6 := p_attribute6;
  	l_ctr_item_association_rec.attribute7 := p_attribute7;
  	l_ctr_item_association_rec.attribute8 := p_attribute8;
  	l_ctr_item_association_rec.attribute9 := p_attribute9;
  	l_ctr_item_association_rec.attribute10 := p_attribute10;
  	l_ctr_item_association_rec.attribute11 := p_attribute11;
  	l_ctr_item_association_rec.attribute12 := p_attribute12;
  	l_ctr_item_association_rec.attribute13 := p_attribute13;
  	l_ctr_item_association_rec.attribute14 := p_attribute14;
  	l_ctr_item_association_rec.attribute15 := p_attribute15;
--  	l_ctr_item_association_rec.maint_organization_id := p_organization_id;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling csi_counter_template_pub.create_item_association ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;

  	csi_counter_template_pub.create_item_association(p_api_version,
                                                     p_commit,
                                                     p_init_msg_list,
                                                     p_validation_level,
                                                     l_ctr_item_association_rec,
                                                     x_return_status,
                                                     x_msg_count,
                                                     x_msg_data);
	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from csi_counter_template_pub.create_item_association ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;

   ELSIF (p_maintenance_object_id IS NOT NULL OR p_asset_number IS NOT NULL) THEN

  	IF (p_maintenance_object_type = 3 AND p_maintenance_object_id IS NOT NULL) THEN
  		l_maintenance_object_id := p_maintenance_object_id;
  	ELSIF (p_maintenance_object_id IS NULL AND p_asset_number IS NOT NULL) THEN
	      BEGIN
				  SELECT instance_id
				  INTO l_maintenance_object_id
				FROM csi_item_instances
				WHERE serial_number = p_asset_number
				  AND inventory_item_id = p_asset_group_id;

				  IF (l_plog) THEN
						 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
						'l_maintenance_object_id:'||l_maintenance_object_id);
				   END IF;
	      EXCEPTION
	          WHEN NO_DATA_FOUND THEN
		          raise_error('EAM_NO_ITEM_FOUND');
	      END;
  	ELSE
  	  raise_error('EAM_NO_ITEM_FOUND');
  	END IF;

	begin
    	if nvl(p_primary_failure_flag, 'N') = 'Y' then

    		select 'Y' into l_exists_primary_flag
    		from dual
    		where exists
    		(select * from csi_counter_associations
    		 where source_object_id = l_maintenance_object_id
    		 and (end_date_active is null or end_date_active > sysdate)
    		 and nvl(primary_failure_flag, 'N') = 'Y');

    		if l_exists_primary_flag = 'Y' then
                    	FND_MESSAGE.SET_NAME('EAM', 'EAM_PRIMARY_FLAG_EXISTS');
                      	FND_MSG_PUB.ADD;
                      	RAISE  FND_API.G_EXC_ERROR;
    		end if;

    	end if;
    exception when no_data_found then
        null;
    end;

  	l_counter_associations_tbl(1).counter_id := p_meter_id;
  	l_counter_associations_tbl(1).source_object_code := 'CP';
  	l_counter_associations_tbl(1).source_object_id := l_maintenance_object_id;
  	l_counter_associations_tbl(1).start_date_active := l_start_date_active;
  	l_counter_associations_tbl(1).end_date_active := p_end_date_active;
  	l_counter_associations_tbl(1).primary_failure_flag := p_primary_failure_flag;
  	l_counter_associations_tbl(1).attribute_category := p_attribute_category;
  	l_counter_associations_tbl(1).attribute1 := p_attribute1;
  	l_counter_associations_tbl(1).attribute2 := p_attribute2;
  	l_counter_associations_tbl(1).attribute3 := p_attribute3;
  	l_counter_associations_tbl(1).attribute4 := p_attribute4;
  	l_counter_associations_tbl(1).attribute5 := p_attribute5;
  	l_counter_associations_tbl(1).attribute6 := p_attribute6;
  	l_counter_associations_tbl(1).attribute7 := p_attribute7;
  	l_counter_associations_tbl(1).attribute8 := p_attribute8;
  	l_counter_associations_tbl(1).attribute9 := p_attribute9;
  	l_counter_associations_tbl(1).attribute10 := p_attribute10;
  	l_counter_associations_tbl(1).attribute11 := p_attribute11;
  	l_counter_associations_tbl(1).attribute12 := p_attribute12;
  	l_counter_associations_tbl(1).attribute13 := p_attribute13;
  	l_counter_associations_tbl(1).attribute14 := p_attribute14;
  	l_counter_associations_tbl(1).attribute15 := p_attribute15;
  	l_counter_associations_tbl(1).maint_organization_id := p_organization_id;

	-- Code added to take care of Re-Associations
	BEGIN
            select 1 into l_exists
            from csi_counter_associations
            where counter_id = p_meter_id AND source_object_id =l_maintenance_object_id;
	 EXCEPTION
	          WHEN NO_DATA_FOUND THEN
		      l_exists := 0;
	 END;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling csi_counter_pub.create_ctr_associations ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;

	if (l_exists = 1) then

	SELECT object_version_number, instance_association_id
        INTO l_object_version_number, l_association_id
		FROM csi_counter_associations
		WHERE source_object_id=l_maintenance_object_id and counter_id=p_meter_id;

  	l_counter_associations_tbl(1).instance_association_id := l_association_id;
  	l_counter_associations_tbl(1).object_version_number := l_object_version_number;
	l_counter_associations_tbl(1).end_date_active := FND_API.G_MISS_DATE;

      	csi_counter_pub.update_ctr_associations(p_api_version,
                                            p_commit,
                                            p_init_msg_list,
                                            p_validation_level,
                                            l_counter_associations_tbl,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data);

	else
      	csi_counter_pub.create_ctr_associations(p_api_version,
                                                     p_commit,
                                                     p_init_msg_list,
                                                     p_validation_level,
                                                     l_counter_associations_tbl,
                                                     x_return_status,
                                                     x_msg_count,
                                                     x_msg_data,
                                                     l_instance_association_id);
    	end if;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from csi_counter_pub.create_ctr_associations ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;
  ELSE
   raise_error('EAM_NO_ITEM_FOUND');
  END IF;


	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN

		COMMIT WORK;
                IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'Commiting Work');
		END IF;
	END IF;

        IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling FND_MSG_PUB.get ====================');
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from FND_MSG_PUB.get ====================');

	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_MeterAssoc_PUB.Insert_AssetMeterAssoc ====================');
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Insert_AssetMeterAssoc_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO Insert_AssetMeterAssoc_PUB');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterAssoc_PUB.Update_AssetMeterAssoc: EXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Insert_AssetMeterAssoc_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO Insert_AssetMeterAssoc_PUB');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterAssoc_PUB.Update_AssetMeterAssoc: UNEXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

	WHEN OTHERS THEN
		ROLLBACK TO Insert_AssetMeterAssoc_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO Update_AssetMeterAssoc_PUB');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterAssoc_PUB.Update_AssetMeterAssoc: OTHERS ERROR=======');
		END IF;

  		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
		        IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Calling FND_MSG_PUB.Add_Exc_Msg ====================');
	 		END IF;
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME ,
    	    			l_api_name
	    		);
			IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Returned from FND_MSG_PUB.Add_Exc_Msg ====================');
 			END IF;

		END IF;

		IF (l_plog) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;

		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

END Insert_AssetMeterAssoc;


/*
This procedure updates a record in the eam_asset_meters table
--      Parameters      :
--      IN              :       p_api_version	IN NUMBER	REQUIRED
--                              P_INIT_MSG_LIST IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_COMMIT	IN VARCHAR2	OPTIONAL
--                                      DEFAULT = FND_API.G_FALSE
--                              P_VALIDATION_LEVEL IN NUMBER	OPTIONAL
--                                      DEFAULT = FND_API.G_VALID_LEVEL_FULL
--				p_meter_id		in	not null number ,
--				p_organization_id		in	not null number
--
--
--      OUT             :       x_return_status    OUT NOCOPY    VARCHAR2(1)
--                              x_msg_count        OUT NOCOPY    NUMBER
--                              x_msg_data         OUT NOCOPY    VARCHAR2 (2000)
--      Version :       Current version: 1.0
--                      Initial version: 1.0
--
*/
PROCEDURE Update_AssetMeterAssoc
(
	p_api_version		           IN	          Number,
	p_init_msg_list		         IN	          VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	           IN  	        VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	       IN  	        NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		         OUT	NOCOPY  VARCHAR2,
	x_msg_count		             OUT	NOCOPY  Number,
	x_msg_data		             OUT	NOCOPY  VARCHAR2,
  p_association_id           IN           Number,
  p_primary_failure_flag	   IN	          VARCHAR2  DEFAULT 'N',
  p_ATTRIBUTE_CATEGORY       IN           VARCHAR2 default null,
  p_ATTRIBUTE1               IN           VARCHAR2 default null,
  p_ATTRIBUTE2               IN           VARCHAR2 default null,
  p_ATTRIBUTE3               IN           VARCHAR2 default null,
  p_ATTRIBUTE4               IN           VARCHAR2 default null,
  p_ATTRIBUTE5               IN           VARCHAR2 default null,
  p_ATTRIBUTE6               IN           VARCHAR2 default null,
  p_ATTRIBUTE7               IN           VARCHAR2 default null,
  p_ATTRIBUTE8               IN           VARCHAR2 default null,
  p_ATTRIBUTE9               IN           VARCHAR2 default null,
  p_ATTRIBUTE10              IN           VARCHAR2 default null,
  p_ATTRIBUTE11              IN           VARCHAR2 default null,
  p_ATTRIBUTE12              IN           VARCHAR2 default null,
  p_ATTRIBUTE13              IN           VARCHAR2 default null,
  p_ATTRIBUTE14              IN           VARCHAR2 default null,
  p_ATTRIBUTE15              IN           VARCHAR2 default null,
  p_end_date_active          IN           DATE     DEFAULT NULL,
  p_tmpl_flag                IN           VARCHAR2 DEFAULT 'N'
)
IS
p_creation_organization_id NUMBER;
l_api_name			CONSTANT VARCHAR2(30)	:='update asset meter';
l_api_version           	CONSTANT NUMBER 	:= 1.0;
l_validated			boolean;
l_ctr_item_association_rec CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec;
l_counter_associations_tbl CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl;
l_start_date_active DATE;
l_object_version_number Number;
l_asset_group_id Number;
l_maint_object_id Number;
l_exists_primary_flag varchar2(1);

l_module             varchar2(200);
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;
BEGIN
	/* Standard Start of API savepoint */
	SAVEPOINT Update_AssetMeterAssoc_PUB;
	IF (l_ulog) THEN
             l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	END IF;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_MeterAssoc_PUB.Update_AssetMeterAssoc ====================');
	END IF;

	/* Standard call to check for call compatibility. */
	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME
					   )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	/* Initialize message list if p_init_msg_list is set to TRUE. */
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	/* Initialize API return status to success */
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'x_return_status:'||x_return_status);
	END IF;
	/* API body */

  IF p_tmpl_flag = 'Y' THEN

		SELECT ccia.object_version_number, inventory_item_id
		INTO l_object_version_number, l_asset_group_id
		FROM csi_ctr_item_associations ccia
		WHERE ccia.ctr_association_id = p_association_id;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_object_version_number:'||l_object_version_number);
	END IF;

begin
	if nvl(p_primary_failure_flag, 'N') = 'Y' then



		select 'Y' into l_exists_primary_flag
		from dual
		where exists
		(select * from csi_ctr_item_associations
		 where inventory_item_id = l_asset_group_id
		 and (end_date_active is null or end_date_active > sysdate)
		 and ctr_association_id <> p_association_id
		 and nvl(primary_failure_flag, 'N') = 'Y');


		if l_exists_primary_flag = 'Y' then
                	FND_MESSAGE.SET_NAME('EAM', 'EAM_PRIMARY_FLAG_EXISTS');
                  	FND_MSG_PUB.ADD;
                  	RAISE  FND_API.G_EXC_ERROR;
		end if;

	end if;
exception when no_data_found then
    null;
end;


        l_ctr_item_association_rec.ctr_association_id := p_association_id;
  	l_ctr_item_association_rec.end_date_active := p_end_date_active;
  	l_ctr_item_association_rec.primary_failure_flag := p_primary_failure_flag;
  	l_ctr_item_association_rec.attribute_category := p_attribute_category;
  	l_ctr_item_association_rec.object_version_number := l_object_version_number;
  	l_ctr_item_association_rec.attribute1 := p_attribute1;
  	l_ctr_item_association_rec.attribute2 := p_attribute2;
  	l_ctr_item_association_rec.attribute3 := p_attribute3;
  	l_ctr_item_association_rec.attribute4 := p_attribute4;
  	l_ctr_item_association_rec.attribute5 := p_attribute5;
  	l_ctr_item_association_rec.attribute6 := p_attribute6;
  	l_ctr_item_association_rec.attribute7 := p_attribute7;
  	l_ctr_item_association_rec.attribute8 := p_attribute8;
  	l_ctr_item_association_rec.attribute9 := p_attribute9;
  	l_ctr_item_association_rec.attribute10 := p_attribute10;
  	l_ctr_item_association_rec.attribute11 := p_attribute11;
  	l_ctr_item_association_rec.attribute12 := p_attribute12;
  	l_ctr_item_association_rec.attribute13 := p_attribute13;
  	l_ctr_item_association_rec.attribute14 := p_attribute14;
  	l_ctr_item_association_rec.attribute15 := p_attribute15;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling csi_counter_template_pub.update_item_association ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;
  	csi_counter_template_pub.update_item_association(p_api_version,
                                                     p_commit,
                                                     p_init_msg_list,
                                                     p_validation_level,
                                                     l_ctr_item_association_rec,
                                                     x_return_status,
                                                     x_msg_count,
                                                     x_msg_data);
        IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from csi_counter_template_pub.update_item_association ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;
  ELSE

  	SELECT cca.object_version_number
		INTO l_object_version_number
		FROM csi_counter_associations cca
		WHERE cca.instance_association_id = p_association_id;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_object_version_number:'||l_object_version_number);
	END IF;


begin
	if nvl(p_primary_failure_flag, 'N') = 'Y' then



		select 'Y' into l_exists_primary_flag
		from dual
		where exists
		(select * from csi_counter_associations
		 where source_object_id = l_maint_object_id
		 and (end_date_active is null or end_date_active > sysdate)
		 and instance_association_id <> p_association_id
		 and nvl(primary_failure_flag, 'N') = 'Y');


		if l_exists_primary_flag = 'Y' then
                	FND_MESSAGE.SET_NAME('EAM', 'EAM_PRIMARY_FLAG_EXISTS');
                  	FND_MSG_PUB.ADD;
                  	RAISE  FND_API.G_EXC_ERROR;
		end if;

	end if;
exception when no_data_found then
        null;
end;

  	l_counter_associations_tbl(1).instance_association_id := p_association_id;
  	l_counter_associations_tbl(1).end_date_active := p_end_date_active;
  	l_counter_associations_tbl(1).object_version_number := l_object_version_number;
  	l_counter_associations_tbl(1).primary_failure_flag := p_primary_failure_flag;
  	l_counter_associations_tbl(1).attribute_category := p_attribute_category;
  	l_counter_associations_tbl(1).attribute1 := p_attribute1;
  	l_counter_associations_tbl(1).attribute2 := p_attribute2;
  	l_counter_associations_tbl(1).attribute3 := p_attribute3;
  	l_counter_associations_tbl(1).attribute4 := p_attribute4;
  	l_counter_associations_tbl(1).attribute5 := p_attribute5;
  	l_counter_associations_tbl(1).attribute6 := p_attribute6;
  	l_counter_associations_tbl(1).attribute7 := p_attribute7;
  	l_counter_associations_tbl(1).attribute8 := p_attribute8;
  	l_counter_associations_tbl(1).attribute9 := p_attribute9;
  	l_counter_associations_tbl(1).attribute10 := p_attribute10;
  	l_counter_associations_tbl(1).attribute11 := p_attribute11;
  	l_counter_associations_tbl(1).attribute12 := p_attribute12;
  	l_counter_associations_tbl(1).attribute13 := p_attribute13;
  	l_counter_associations_tbl(1).attribute14 := p_attribute14;
  	l_counter_associations_tbl(1).attribute15 := p_attribute15;

        IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling csi_counter_template_pub.update_ctr_associations ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;
  	csi_counter_pub.update_ctr_associations(p_api_version,
                                            p_commit,
                                            p_init_msg_list,
                                            p_validation_level,
                                            l_counter_associations_tbl,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data);
	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from csi_counter_template_pub.update_ctr_associations ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;

  END IF;

	/* Standard check of p_commit. */
	IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
		COMMIT WORK;
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'Commiting Work');
		END IF;
	END IF;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling FND_MSG_PUB.get ====================');
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);
        IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from FND_MSG_PUB.get ====================');

		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_MeterAssoc_PUB.Update_AssetMeterAssoc ====================');
	END IF;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_AssetMeterAssoc_PUB;

		x_return_status := FND_API.G_RET_STS_ERROR ;

		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO Update_AssetMeterAssoc_PUB');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterAssoc_PUB.Update_AssetMeterAssoc: EXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;

		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);

  	        IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO Update_AssetMeterAssoc_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO Update_AssetMeterAssoc_PUB');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterAssoc_PUB.Update_AssetMeterAssoc: UNEXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

	WHEN OTHERS THEN
		ROLLBACK TO Update_AssetMeterAssoc_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO Update_AssetMeterAssoc_PUB');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterAssoc_PUB.Update_AssetMeterAssoc: OTHERS ERROR=======');
		END IF;

  		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
		        IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Calling FND_MSG_PUB.Add_Exc_Msg ====================');
	 		END IF;

        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME ,
    	    			l_api_name
	    		);

			IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Returned from FND_MSG_PUB.Add_Exc_Msg ====================');
 			END IF;
		END IF;
               IF (l_plog) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out        	=>      x_msg_count ,
        		p_data         	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;
END Update_AssetMeterAssoc;

/* private procedure for raising exceptions */

PROCEDURE RAISE_ERROR (ERROR VARCHAR2)
IS
	l_api_name	CONSTANT VARCHAR2(30)	:='Insert_AssetMeterAssoc';
	l_module           varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
/* debugging */
       	IF (l_ulog) THEN
             l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	END IF;

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_MeterAssoc_PUB.RAISE_ERROR ====================');
	END IF;
	FND_MESSAGE.SET_NAME ('EAM', ERROR);
        FND_MSG_PUB.ADD;

        IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_MeterAssoc_PUB.RAISE_ERROR ====================');
	END IF;
	RAISE FND_API.G_EXC_ERROR;

END;


END EAM_MeterAssoc_PUB;

/
