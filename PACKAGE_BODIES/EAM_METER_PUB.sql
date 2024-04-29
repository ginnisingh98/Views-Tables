--------------------------------------------------------
--  DDL for Package Body EAM_METER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METER_PUB" AS
/* $Header: EAMPMETB.pls 120.18 2006/10/26 14:22:16 vmec noship $ */

/* for de-bugging */
/* g_sr_no		number ; */

PROCEDURE print_log(info varchar2) is
PRAGMA  AUTONOMOUS_TRANSACTION;
l_dummy number;
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END;

-- Start of comments
--	API name 	: create_meter
--	Type		: Public
--	Function	:
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

--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--	Version	: Current version	1.0
-- End of comments


procedure create_meter
(
  p_api_version            IN          Number        ,
  p_init_msg_list          IN          VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN          VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level       IN          NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status          OUT nocopy  VARCHAR2,
  x_msg_count              OUT nocopy  NUMBER,
  x_msg_data               OUT nocopy  VARCHAR2,
  p_meter_name             IN          VARCHAR2,
  p_meter_uom              IN          VARCHAR2,
  p_meter_type             IN          NUMBER default 1,
  p_VALUE_CHANGE_DIR       IN          NUMBER DEFAULT 1,
  p_USED_IN_SCHEDULING     IN          VARCHAR2 default 'N',
  p_USER_DEFINED_RATE      IN          NUMBER default null,
  p_USE_PAST_READING       IN          NUMBER default null,
  p_DESCRIPTION            IN          VARCHAR2 default null,
  p_FROM_EFFECTIVE_DATE    IN          DATE default null,
  p_TO_EFFECTIVE_DATE      IN          DATE default null,
  p_source_meter_id        IN          Number DEFAULT NULL,
  p_factor                 IN          NUMBER DEFAULT 1,
  p_relationship_start_date IN         DATE default null,
  p_ATTRIBUTE_CATEGORY     IN          VARCHAR2 default null,
  p_ATTRIBUTE1             IN          VARCHAR2 default null,
  p_ATTRIBUTE2             IN          VARCHAR2 default null,
  p_ATTRIBUTE3             IN          VARCHAR2 default null,
  p_ATTRIBUTE4             IN          VARCHAR2 default null,
  p_ATTRIBUTE5             IN          VARCHAR2 default null,
  p_ATTRIBUTE6             IN          VARCHAR2 default null,
  p_ATTRIBUTE7             IN          VARCHAR2 default null,
  p_ATTRIBUTE8             IN          VARCHAR2 default null,
  p_ATTRIBUTE9             IN          VARCHAR2 default null,
  p_ATTRIBUTE10            IN          VARCHAR2 default null,
  p_ATTRIBUTE11            IN          VARCHAR2 default null,
  p_ATTRIBUTE12            IN          VARCHAR2 default null,
  p_ATTRIBUTE13            IN          VARCHAR2 default null,
  p_ATTRIBUTE14            IN          VARCHAR2 default null,
  p_ATTRIBUTE15            IN          VARCHAR2 default null,
  p_ATTRIBUTE16            IN          VARCHAR2 default null,
  p_ATTRIBUTE17            IN          VARCHAR2 default null,
  p_ATTRIBUTE18            IN          VARCHAR2 default null,
  p_ATTRIBUTE19            IN          VARCHAR2 default null,
  p_ATTRIBUTE20            IN          VARCHAR2 default null,
  p_ATTRIBUTE21            IN          VARCHAR2 default null,
  p_ATTRIBUTE22            IN          VARCHAR2 default null,
  p_ATTRIBUTE23            IN          VARCHAR2 default null,
  p_ATTRIBUTE24            IN          VARCHAR2 default null,
  p_ATTRIBUTE25            IN          VARCHAR2 default null,
  p_ATTRIBUTE26            IN          VARCHAR2 default null,
  p_ATTRIBUTE27            IN          VARCHAR2 default null,
  p_ATTRIBUTE28            IN          VARCHAR2 default null,
  p_ATTRIBUTE29            IN          VARCHAR2 default null,
  p_ATTRIBUTE30            IN          VARCHAR2 default null,
  p_TMPL_FLAG              IN          VARCHAR2 default 'N',
  p_SOURCE_TMPL_ID         IN          Number default null,
  p_INITIAL_READING        IN          NUMBER default 0,
  P_INITIAL_READING_DATE   IN          DATE default SYSDATE,
  P_EAM_REQUIRED_FLAG	  IN		VARCHAR2 default 'N',
  x_new_meter_id           OUT nocopy  Number

)
is

l_api_name			   CONSTANT  VARCHAR2(30)     :=   'create_meter';
l_api_version      CONSTANT  NUMBER 		:= 1.0;
l_meter_id                   number;
l_validated	                 boolean;
l_meter_reading_id           number;
l_initial_reading            number;
l_tmpl_flag                  varchar2(30);
l_meter_type                 number;
l_value_before_reset         Number;
l_INITIAL_READING_DATE       date;
l_commit       VARCHAR2(1);
l_init_msg_list     VARCHAR2(1);
l_validation_level          NUMBER;
l_counter_instance_rec	     CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec;
l_counter_template_rec	     CSI_CTR_DATASTRUCTURES_PUB.Counter_template_rec;
l_ctr_properties_tbl         CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl;
l_counter_relationships_tbl  CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl;
l_ctr_derived_filters_tbl    CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl;
l_counter_associations_tbl   CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl;
l_ctr_item_associations_tbl  CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl;
l_ctr_property_template_tbl  CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl;
l_meter_reading_rec          Eam_MeterReading_PUB.Meter_Reading_Rec_Type;
l_ctr_property_readings_tbl  EAM_MeterReading_PUB.Ctr_Property_readings_Tbl;
l_object_version_number            Number;

l_module            varchar2(200) ;
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

begin

	-- Standard Start of API savepoint
  SAVEPOINT create_meter_pub;
  if( l_ulog) then
           l_module    := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
  end if;

  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_METER_PUB.create_meter ====================');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_commit := p_commit;
	l_init_msg_list := p_init_msg_list;
	l_validation_level := p_validation_level;

	IF l_commit IS NULL THEN
		l_commit := FND_API.G_TRUE;
	END IF;

        IF l_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_TRUE;
	END IF;

         IF l_validation_level IS NULL THEN
		l_validation_level := FND_API.G_VALID_LEVEL_FULL;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

	l_ctr_properties_tbl.DELETE;
	l_counter_relationships_tbl.DELETE;
	l_ctr_derived_filters_tbl.DELETE;
	l_counter_associations_tbl.DELETE;
	l_ctr_property_readings_tbl.DELETE;


	if (p_tmpl_flag is null) then
		l_tmpl_flag:='N';
	else
		l_tmpl_flag:=p_tmpl_flag;
	end if;

	if (p_meter_type is null) then
		l_meter_type:=1;
	else
		l_meter_type:=p_meter_type;
	end if;

	if (p_initial_reading is null) then
		l_initial_reading:=0;
	else
		l_initial_reading:=p_initial_reading;
	end if;

  IF l_tmpl_flag = 'N' THEN
							  l_counter_instance_rec.name := p_meter_name;
							  IF p_value_change_dir = 1 THEN
										l_counter_instance_rec.direction := 'A';
							  ELSIF p_value_change_dir = 2 THEN
										l_counter_instance_rec.direction := 'D';
							  ELSE l_counter_instance_rec.direction := 'B';
							  END IF;

						    l_counter_instance_rec.counter_type := 'REGULAR';
						    l_counter_instance_rec.initial_reading := p_initial_reading;
						    l_counter_instance_rec.initial_reading_date := p_initial_reading_date;
						    l_counter_instance_rec.created_from_counter_tmpl_id := p_source_tmpl_id;
						    l_counter_instance_rec.uom_code := p_meter_uom;
						    l_counter_instance_rec.start_date_active := p_from_effective_date;
						    l_counter_instance_rec.end_date_active := p_to_effective_date;
						    l_counter_instance_rec.reading_type := p_meter_type;

						    l_counter_instance_rec.default_usage_rate := p_user_defined_rate;
						    l_counter_instance_rec.use_past_reading := p_use_past_reading;
						    l_counter_instance_rec.used_in_scheduling := p_used_in_scheduling;
						    l_counter_instance_rec.description := p_description;
						    l_counter_instance_rec.time_based_manual_entry := 'Y';
						    l_counter_instance_rec.eam_required_flag := p_eam_required_flag;
						    l_counter_instance_rec.attribute_category := p_attribute_category;
							  l_counter_instance_rec.attribute1 := p_attribute1;
							  l_counter_instance_rec.attribute2 := p_attribute2;
							  l_counter_instance_rec.attribute3 := p_attribute3;
							  l_counter_instance_rec.attribute4 := p_attribute4;
							  l_counter_instance_rec.attribute5 := p_attribute5;
							  l_counter_instance_rec.attribute6 := p_attribute6;
							  l_counter_instance_rec.attribute7 := p_attribute7;
							  l_counter_instance_rec.attribute8 := p_attribute8;
							  l_counter_instance_rec.attribute9 := p_attribute9;
							  l_counter_instance_rec.attribute10 := p_attribute10;
							  l_counter_instance_rec.attribute11 := p_attribute11;
							  l_counter_instance_rec.attribute12 := p_attribute12;
							  l_counter_instance_rec.attribute13 := p_attribute13;
							  l_counter_instance_rec.attribute14 := p_attribute14;
							  l_counter_instance_rec.attribute15 := p_attribute15;
							  l_counter_instance_rec.attribute16 := p_attribute16;
							  l_counter_instance_rec.attribute17 := p_attribute17;
							  l_counter_instance_rec.attribute18 := p_attribute18;
							  l_counter_instance_rec.attribute19 := p_attribute19;
							  l_counter_instance_rec.attribute20 := p_attribute20;
							  l_counter_instance_rec.attribute21 := p_attribute21;
							  l_counter_instance_rec.attribute22 := p_attribute22;
							  l_counter_instance_rec.attribute23 := p_attribute23;
							  l_counter_instance_rec.attribute24 := p_attribute24;
							  l_counter_instance_rec.attribute25 := p_attribute25;
							  l_counter_instance_rec.attribute26 := p_attribute26;
							  l_counter_instance_rec.attribute27 := p_attribute27;
							  l_counter_instance_rec.attribute28 := p_attribute28;
							  l_counter_instance_rec.attribute29 := p_attribute29;
							  l_counter_instance_rec.attribute30 := p_attribute30;

						    IF (l_plog) THEN
								 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
									'==================== Calling CSI_COUNTER_PUB.create_counter ===================='
									||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
						    END IF;
						    CSI_COUNTER_PUB.create_counter(p_api_version,
										   l_init_msg_list,
										   l_commit,
										   l_validation_level,
										   l_counter_instance_rec,
										   l_ctr_properties_tbl,
										   l_counter_relationships_tbl,
										   l_ctr_derived_filters_tbl,
										   l_counter_associations_tbl,
										   x_return_status,
										   x_msg_count,
										   x_msg_data,
										   x_new_meter_id);

							IF (l_plog) THEN
								 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
									'==================== Returned from CSI_COUNTER_PUB.create_counter ===================='
									||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
						        END IF;

			    IF p_source_meter_id IS NOT NULL THEN

                        l_counter_relationships_tbl(1).relationship_type_code := 'CONFIGURATION';
        				l_counter_relationships_tbl(1).source_counter_id := p_source_meter_id;
        				l_counter_relationships_tbl(1).factor := p_factor;
        				l_counter_relationships_tbl(1).active_start_date := p_relationship_start_date;
        				l_counter_relationships_tbl(1).active_end_date := to_date(null);


                  		SELECT object_version_number
                      		INTO l_object_version_number
                  		FROM CSI_COUNTERS_B
                  		WHERE counter_id = x_new_meter_id;

        			     l_counter_instance_rec.counter_id := x_new_meter_id;
	                     l_counter_instance_rec.object_version_number := l_object_version_number;

        				      IF (l_plog) THEN
        								 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
        									'==================== Calling CSI_COUNTER_PUB.update_counter ===================='
        									||'x_return_status:'||x_return_status
        				||' x_msg_count:'||x_msg_count
        				||'x_msg_data:'||x_msg_data);
        				    END IF;
    				    CSI_COUNTER_PUB.update_counter(p_api_version,
    								   l_init_msg_list,
    								   l_commit,
    								   l_validation_level,
    								   l_counter_instance_rec,
    								   l_ctr_properties_tbl,
    								   l_counter_relationships_tbl,
    								   l_ctr_derived_filters_tbl,
    								   l_counter_associations_tbl,
    								   x_return_status,
    								   x_msg_count,
    								   x_msg_data);

            			  IF (l_plog) THEN
            							 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
            								'==================== Returning from CSI_COUNTER_PUB.update_counter ===================='
            								||'x_return_status:'||x_return_status
            			||' x_msg_count:'||x_msg_count
            			||'x_msg_data:'||x_msg_data);
            			    END IF;

   			    END IF;

--for template meters
  ELSE
								l_counter_template_rec.name := p_meter_name;
							    l_counter_template_rec.counter_type := 'REGULAR';
							  IF p_value_change_dir = 1 THEN
										l_counter_template_rec.direction := 'A';
							  ELSIF p_value_change_dir = 2 THEN
										l_counter_template_rec.direction := 'D';
							  ELSE l_counter_template_rec.direction := 'B';
							  END IF;
							    l_counter_template_rec.initial_reading := p_initial_reading;
							    l_counter_template_rec.initial_reading_date := p_initial_reading_date;
							    l_counter_template_rec.uom_code := p_meter_uom;
							    l_counter_template_rec.start_date_active := p_from_effective_date;
							    l_counter_template_rec.end_date_active := p_to_effective_date;
							    l_counter_template_rec.reading_type := p_meter_type;
							    l_counter_template_rec.default_usage_rate := p_user_defined_rate;
							    l_counter_template_rec.use_past_reading := p_use_past_reading;
							    l_counter_template_rec.used_in_scheduling := p_used_in_scheduling;
							    l_counter_template_rec.description := p_description;
							    l_counter_template_rec.time_based_manual_entry := 'Y';
							    l_counter_template_rec.eam_required_flag := p_eam_required_flag;
							    l_counter_template_rec.attribute_category := p_attribute_category;
								  l_counter_template_rec.attribute1 := p_attribute1;
								  l_counter_template_rec.attribute2 := p_attribute2;
								  l_counter_template_rec.attribute3 := p_attribute3;
								  l_counter_template_rec.attribute4 := p_attribute4;
								  l_counter_template_rec.attribute5 := p_attribute5;
								  l_counter_template_rec.attribute6 := p_attribute6;
								  l_counter_template_rec.attribute7 := p_attribute7;
								  l_counter_template_rec.attribute8 := p_attribute8;
								  l_counter_template_rec.attribute9 := p_attribute9;
								  l_counter_template_rec.attribute10 := p_attribute10;
								  l_counter_template_rec.attribute11 := p_attribute11;
								  l_counter_template_rec.attribute12 := p_attribute12;
								  l_counter_template_rec.attribute13 := p_attribute13;
								  l_counter_template_rec.attribute14 := p_attribute14;
								  l_counter_template_rec.attribute15 := p_attribute15;
								  l_counter_template_rec.attribute16 := p_attribute16;
								  l_counter_template_rec.attribute17 := p_attribute17;
								  l_counter_template_rec.attribute18 := p_attribute18;
								  l_counter_template_rec.attribute19 := p_attribute19;
								  l_counter_template_rec.attribute20 := p_attribute20;
								  l_counter_template_rec.attribute21 := p_attribute21;
								  l_counter_template_rec.attribute22 := p_attribute22;
								  l_counter_template_rec.attribute23 := p_attribute23;
								  l_counter_template_rec.attribute24 := p_attribute24;
								  l_counter_template_rec.attribute25 := p_attribute25;
								  l_counter_template_rec.attribute26 := p_attribute26;
								  l_counter_template_rec.attribute27 := p_attribute27;
								  l_counter_template_rec.attribute28 := p_attribute28;
								  l_counter_template_rec.attribute29 := p_attribute29;
								  l_counter_template_rec.attribute30 := p_attribute30;
							    IF (l_plog) THEN
									 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
										'==================== Calling csi_counter_template_pub.create_counter_template ===================='
										||'x_return_status:'||x_return_status
										||' x_msg_count:'||x_msg_count
										||'x_msg_data:'||x_msg_data);
							    END IF;
							    csi_counter_template_pub.create_counter_template(p_api_version,
													 l_commit,
													 l_init_msg_list,
													 l_validation_level,
													 l_counter_template_rec,
													 l_ctr_item_associations_tbl,
													 l_ctr_property_template_tbl,
													 l_counter_relationships_tbl,
													 l_ctr_derived_filters_tbl,
													 x_return_status,
													 x_msg_count,
													 x_msg_data);
							    IF (l_plog) THEN
									 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
										'==================== Returning from csi_counter_template_pub.create_counter_template ===================='
										||'x_return_status:'||x_return_status
										||' x_msg_count:'||x_msg_count
										||'x_msg_data:'||x_msg_data);
							    END IF;
  END IF;
  --end of check for meter/meter template


	-- End of API body.
	-- Standard check of l_commit.
	IF FND_API.To_Boolean( l_commit ) THEN

		COMMIT WORK;
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'Commiting Work');
		END IF;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.get
    	(  	p_msg_index_out         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);
	x_msg_data := substr(x_msg_data,1,4000);
	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting from EAM_METER_PUB.create_meter ====================');
       END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO create_meter_pub;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_METER_PUB.create_meter: EXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO create_meter_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_METER_PUB.create_meter: UNEXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN OTHERS THEN
		ROLLBACK TO create_meter_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_METER_PUB.create_meter: OTHERS ERROR=======');
		END IF;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
		        IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Calling FND_MSG_PUB.Add_Exc_Msg ====================');
	 		END IF;
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
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
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

		x_msg_data := substr(x_msg_data,1,4000);
end create_meter;


procedure update_meter
(
  p_api_version           IN            Number,
  p_init_msg_list         IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN            NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT nocopy    VARCHAR2,
  x_msg_count             OUT nocopy    NUMBER,
  x_msg_data              OUT nocopy    VARCHAR2,
  p_meter_id              IN            number,
  p_meter_name            IN            varchar DEFAULT NULL,
  p_meter_uom             IN            varchar DEFAULT NULL,
  p_METER_TYPE            IN            Number default NULL,
  p_VALUE_CHANGE_DIR      IN            Number default NULL,
  p_USED_IN_SCHEDULING    IN            VARCHAR2 default NULL,
  p_USER_DEFINED_RATE     IN            NUMBER default null,
  p_USE_PAST_READING      IN            Number default null,
  p_DESCRIPTION           IN            VARCHAR2 default null,
  p_FROM_EFFECTIVE_DATE   IN            DATE default null,
  p_TO_EFFECTIVE_DATE     IN            DATE default null,
  p_source_meter_id       IN            Number DEFAULT NULL,
  p_factor                IN            NUMBER DEFAULT NULL,
  p_relationship_start_date IN          DATE default null,
  p_ATTRIBUTE_CATEGORY    IN            VARCHAR2 default null,
  p_ATTRIBUTE1            IN            VARCHAR2 default null,
  p_ATTRIBUTE2            IN            VARCHAR2 default null,
  p_ATTRIBUTE3            IN            VARCHAR2 default null,
  p_ATTRIBUTE4            IN            VARCHAR2 default null,
  p_ATTRIBUTE5            IN            VARCHAR2 default null,
  p_ATTRIBUTE6            IN            VARCHAR2 default null,
  p_ATTRIBUTE7            IN            VARCHAR2 default null,
  p_ATTRIBUTE8            IN            VARCHAR2 default null,
  p_ATTRIBUTE9            IN            VARCHAR2 default null,
  p_ATTRIBUTE10           IN            VARCHAR2 default null,
  p_ATTRIBUTE11           IN            VARCHAR2 default null,
  p_ATTRIBUTE12           IN            VARCHAR2 default null,
  p_ATTRIBUTE13           IN            VARCHAR2 default null,
  p_ATTRIBUTE14           IN            VARCHAR2 default null,
  p_ATTRIBUTE15           IN            VARCHAR2 default null,
  p_ATTRIBUTE16           IN            VARCHAR2 default null,
  p_ATTRIBUTE17           IN            VARCHAR2 default null,
  p_ATTRIBUTE18           IN            VARCHAR2 default null,
  p_ATTRIBUTE19           IN            VARCHAR2 default null,
  p_ATTRIBUTE20           IN            VARCHAR2 default null,
  p_ATTRIBUTE21           IN            VARCHAR2 default null,
  p_ATTRIBUTE22           IN            VARCHAR2 default null,
  p_ATTRIBUTE23           IN            VARCHAR2 default null,
  p_ATTRIBUTE24           IN            VARCHAR2 default null,
  p_ATTRIBUTE25           IN            VARCHAR2 default null,
  p_ATTRIBUTE26           IN            VARCHAR2 default null,
  p_ATTRIBUTE27           IN            VARCHAR2 default null,
  p_ATTRIBUTE28           IN            VARCHAR2 default null,
  p_ATTRIBUTE29           IN            VARCHAR2 default null,
  p_ATTRIBUTE30           IN            VARCHAR2 default null,
  p_TMPL_FLAG             IN            VARCHAR2 default 'N',
  p_SOURCE_TMPL_ID        IN            Number default NULL,
  P_EAM_REQUIRED_FLAG	  IN		VARCHAR2 default 'N',
  p_from_eam		  IN		varchar2 default null
)
is

l_api_name			          CONSTANT VARCHAR2(30)	:= 'update_meter';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_meter_id                         number;
l_meter_type                       NUMBER;
l_commit                               VARCHAR2(1);
l_init_msg_list                     VARCHAR2(1);
l_validation_level                 NUMBER;
l_counter_instance_rec	           CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec;
l_counter_template_rec	           CSI_CTR_DATASTRUCTURES_PUB.Counter_template_rec;
l_ctr_properties_tbl               CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl;
l_counter_relationships_tbl        CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl;
l_ctr_derived_filters_tbl          CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl;
l_counter_associations_tbl         CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl;
l_ctr_item_associations_tbl        CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl;
l_ctr_property_template_tbl        CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl;
l_meter_reading_rec                Eam_MeterReading_PUB.Meter_Reading_Rec_Type;
l_ctr_property_readings_tbl        EAM_MeterReading_PUB.Ctr_Property_readings_Tbl;
l_object_version_number            Number;

l_prev_source_counter_id        Number;
l_prev_relationship_id          Number;
l_previous_factor               Number;
l_source_meter_id		Number;
l_prev_required_flag varchar2(1);
l_primary_flag varchar2(1);

l_module            varchar2(200);
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	update_meter_pub;
    if( l_ulog) then
           l_module    := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    end if;

    IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_METER_PUB.update_meter ====================');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_commit := p_commit;
	l_init_msg_list := p_init_msg_list;
	l_validation_level := p_validation_level;

	IF l_commit IS NULL THEN
		l_commit := FND_API.G_TRUE;
	END IF;

        IF l_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_TRUE;
	END IF;

         IF l_validation_level IS NULL THEN
		l_validation_level := FND_API.G_VALID_LEVEL_FULL;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API body

	l_source_meter_id := p_source_meter_id;

	l_ctr_properties_tbl.DELETE;
	l_counter_relationships_tbl.DELETE;
	l_ctr_derived_filters_tbl.DELETE;
	l_ctr_property_readings_tbl.DELETE;
	l_counter_associations_tbl.DELETE;

  	IF p_tmpl_flag = 'N' THEN

  		SELECT object_version_number
  		INTO l_object_version_number
  		FROM CSI_COUNTERS_B
  		WHERE counter_id = p_meter_id;



		l_counter_instance_rec.counter_id := p_meter_id;
		l_counter_instance_rec.name := p_meter_name;

	IF p_value_change_dir is not null THEN
		IF p_value_change_dir = 1 THEN
			l_counter_instance_rec.direction := 'A';
		ELSIF p_value_change_dir = 2 THEN
			l_counter_instance_rec.direction := 'D';
		ELSE l_counter_instance_rec.direction := 'B';
		END IF;
	END IF;

		if nvl(p_eam_required_flag, 'N') = 'N' then
			select eam_required_flag into l_prev_required_flag
			from csi_counters_b
			where counter_id = p_meter_id;

			if nvl(l_prev_required_flag, 'N') = 'Y' then

				begin
					select primary_failure_flag into l_primary_flag
					from csi_counter_associations
					where counter_id = p_meter_id;

					if nvl(l_primary_flag, 'N') = 'Y' then
			                	FND_MESSAGE.SET_NAME('EAM', 'EAM_PRIMARY_FLAG_EXISTS');
                  				FND_MSG_PUB.ADD;
                  				RAISE  FND_API.G_EXC_ERROR;
					end if;

				exception when no_data_found then
					-- this is not an error condition.
					null;
				end;

			end if;
		end if;


		l_counter_instance_rec.counter_type := 'REGULAR';
		l_counter_instance_rec.object_version_number := l_object_version_number;
		l_counter_instance_rec.created_from_counter_tmpl_id := p_source_tmpl_id;
		l_counter_instance_rec.uom_code := p_meter_uom;
		l_counter_instance_rec.start_date_active := p_from_effective_date;
		l_counter_instance_rec.end_date_active := p_to_effective_date;
		l_counter_instance_rec.reading_type := p_meter_type;
		l_counter_instance_rec.default_usage_rate := p_user_defined_rate;
		l_counter_instance_rec.use_past_reading := p_use_past_reading;
		l_counter_instance_rec.used_in_scheduling := p_used_in_scheduling;
		l_counter_instance_rec.description := p_description;
  	    	l_counter_instance_rec.time_based_manual_entry := 'Y';
		l_counter_instance_rec.eam_required_flag := p_eam_required_flag;
		l_counter_instance_rec.attribute_category := p_attribute_category;
		l_counter_instance_rec.attribute1 := p_attribute1;
		l_counter_instance_rec.attribute2 := p_attribute2;
		l_counter_instance_rec.attribute3 := p_attribute3;
		l_counter_instance_rec.attribute4 := p_attribute4;
		l_counter_instance_rec.attribute5 := p_attribute5;
		l_counter_instance_rec.attribute6 := p_attribute6;
		l_counter_instance_rec.attribute7 := p_attribute7;
		l_counter_instance_rec.attribute8 := p_attribute8;
		l_counter_instance_rec.attribute9 := p_attribute9;
		l_counter_instance_rec.attribute10 := p_attribute10;
		l_counter_instance_rec.attribute11 := p_attribute11;
		l_counter_instance_rec.attribute12 := p_attribute12;
		l_counter_instance_rec.attribute13 := p_attribute13;
		l_counter_instance_rec.attribute14 := p_attribute14;
		l_counter_instance_rec.attribute15 := p_attribute15;
		l_counter_instance_rec.attribute16 := p_attribute16;
		l_counter_instance_rec.attribute17 := p_attribute17;
		l_counter_instance_rec.attribute18 := p_attribute18;
		l_counter_instance_rec.attribute19 := p_attribute19;
		l_counter_instance_rec.attribute20 := p_attribute20;
		l_counter_instance_rec.attribute21 := p_attribute21;
		l_counter_instance_rec.attribute22 := p_attribute22;
		l_counter_instance_rec.attribute23 := p_attribute23;
		l_counter_instance_rec.attribute24 := p_attribute24;
		l_counter_instance_rec.attribute25 := p_attribute25;
		l_counter_instance_rec.attribute26 := p_attribute26;
		l_counter_instance_rec.attribute27 := p_attribute27;
		l_counter_instance_rec.attribute28 := p_attribute28;
		l_counter_instance_rec.attribute29 := p_attribute29;
		l_counter_instance_rec.attribute30 := p_attribute30;

		BEGIN
			select source_counter_id,relationship_id,factor,object_version_number
			into l_prev_source_counter_id,l_prev_relationship_id,l_previous_factor,l_object_version_number
			from csi_counter_relationships
			where object_counter_id = p_meter_id and active_end_date is null;

			if nvl(p_from_eam, 'N') = 'Y' then

				if l_source_meter_id is null and l_prev_source_counter_id is not null then
		   			l_source_meter_id := FND_API.G_MISS_NUM;
				end if;

			end if;



			IF l_source_meter_id IS NOT NULL THEN
				IF l_source_meter_id = FND_API.G_MISS_NUM THEN
			        	l_counter_relationships_tbl(1).object_version_number := l_object_version_number;
					l_counter_relationships_tbl(1).RELATIONSHIP_ID := l_prev_relationship_id;
					l_counter_relationships_tbl(1).ACTIVE_END_DATE := SYSDATE;
				ELSIF l_prev_source_counter_id  <> l_source_meter_id THEN
			               -- When source counter is changed .. End date the old one and insert a new one
					l_counter_relationships_tbl(1).object_version_number := l_object_version_number;
					l_counter_relationships_tbl(1).RELATIONSHIP_ID := l_prev_relationship_id;
					l_counter_relationships_tbl(1).ACTIVE_END_DATE := SYSDATE;
					l_counter_relationships_tbl(2).source_counter_id := l_source_meter_id;
					l_counter_relationships_tbl(2).factor := p_factor;
					IF( p_relationship_start_date is not null) THEN
						l_counter_relationships_tbl(2).active_start_date := p_relationship_start_date;
					ELSE
						l_counter_relationships_tbl(2).active_start_date := sysdate;
					END IF;
					l_counter_relationships_tbl(2).active_end_date := null;
					l_counter_relationships_tbl(2).relationship_type_code := 'CONFIGURATION';
				ELSE
					l_counter_relationships_tbl(1).object_version_number := l_object_version_number;
					l_counter_relationships_tbl(1).RELATIONSHIP_ID := l_prev_relationship_id;
					l_counter_relationships_tbl(1).factor := p_factor;
					IF( p_relationship_start_date is not null) THEN
						l_counter_relationships_tbl(1).active_start_date := p_relationship_start_date;
					ELSE
						l_counter_relationships_tbl(1).active_start_date := sysdate;
					END IF;
				END IF;
			ELSE
				l_counter_relationships_tbl.delete;
			END IF;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					IF (l_source_meter_id IS NOT NULL) THEN -- When a relationship has to be added
					       l_counter_relationships_tbl(1).source_counter_id := l_source_meter_id;
					       l_counter_relationships_tbl(1).factor := p_factor;
					       l_counter_relationships_tbl(1).relationship_type_code := 'CONFIGURATION';
					       	IF( p_relationship_start_date is not null) THEN
							l_counter_relationships_tbl(1).active_start_date := p_relationship_start_date;
						ELSE
							l_counter_relationships_tbl(1).active_start_date := sysdate;
						END IF;
					END IF;
			END;


				      IF (l_plog) THEN
								 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
									'==================== Calling CSI_COUNTER_PUB.update_counter ===================='
									||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
				    END IF;
				    CSI_COUNTER_PUB.update_counter(p_api_version,
								   l_init_msg_list,
								   l_commit,
								   l_validation_level,
								   l_counter_instance_rec,
								   l_ctr_properties_tbl,
								   l_counter_relationships_tbl,
								   l_ctr_derived_filters_tbl,
								   l_counter_associations_tbl,
								   x_return_status,
								   x_msg_count,
								   x_msg_data);

				  IF (l_plog) THEN
								 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
									'==================== Returning from CSI_COUNTER_PUB.update_counter ===================='
									||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
				    END IF;

  ELSE


  		SELECT object_version_number
  		INTO l_object_version_number
  		FROM CSI_COUNTER_TEMPLATE_B
  		WHERE counter_id = p_meter_id;

									    l_counter_template_rec.counter_id := p_meter_id;
									    l_counter_template_rec.name := p_meter_name;
									    IF (l_plog) THEN
										  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
											'l_object_version_number:'||l_object_version_number);
										END IF;
									  IF p_value_change_dir = 1 THEN
												l_counter_template_rec.direction := 'A';
									  ELSIF p_value_change_dir = 2 THEN
												l_counter_template_rec.direction := 'D';
									  ELSE l_counter_template_rec.direction := 'B';
									  END IF;
									    l_counter_template_rec.counter_type := 'REGULAR';
								      l_counter_template_rec.object_version_number := l_object_version_number;
									    l_counter_template_rec.uom_code := p_meter_uom;
									    l_counter_template_rec.start_date_active := p_from_effective_date;
									    l_counter_template_rec.end_date_active := p_to_effective_date;
									    l_counter_template_rec.reading_type := p_meter_type;
									    l_counter_template_rec.default_usage_rate := p_user_defined_rate;
									    l_counter_template_rec.use_past_reading := p_use_past_reading;
									    l_counter_template_rec.used_in_scheduling := p_used_in_scheduling;
									    l_counter_template_rec.description := p_description;
									    l_counter_template_rec.time_based_manual_entry := 'Y';
									    l_counter_template_rec.eam_required_flag := p_eam_required_flag;
									    l_counter_template_rec.attribute_category := p_attribute_category;
										  l_counter_template_rec.attribute1 := p_attribute1;
										  l_counter_template_rec.attribute2 := p_attribute2;
										  l_counter_template_rec.attribute3 := p_attribute3;
										  l_counter_template_rec.attribute4 := p_attribute4;
										  l_counter_template_rec.attribute5 := p_attribute5;
										  l_counter_template_rec.attribute6 := p_attribute6;
										  l_counter_template_rec.attribute7 := p_attribute7;
										  l_counter_template_rec.attribute8 := p_attribute8;
										  l_counter_template_rec.attribute9 := p_attribute9;
										  l_counter_template_rec.attribute10 := p_attribute10;
										  l_counter_template_rec.attribute11 := p_attribute11;
										  l_counter_template_rec.attribute12 := p_attribute12;
										  l_counter_template_rec.attribute13 := p_attribute13;
										  l_counter_template_rec.attribute14 := p_attribute14;
										  l_counter_template_rec.attribute15 := p_attribute15;
										  l_counter_template_rec.attribute16 := p_attribute16;
										  l_counter_template_rec.attribute17 := p_attribute17;
										  l_counter_template_rec.attribute18 := p_attribute18;
										  l_counter_template_rec.attribute19 := p_attribute19;
										  l_counter_template_rec.attribute20 := p_attribute20;
										  l_counter_template_rec.attribute21 := p_attribute21;
										  l_counter_template_rec.attribute22 := p_attribute22;
										  l_counter_template_rec.attribute23 := p_attribute23;
										  l_counter_template_rec.attribute24 := p_attribute24;
										  l_counter_template_rec.attribute25 := p_attribute25;
										  l_counter_template_rec.attribute26 := p_attribute26;
										  l_counter_template_rec.attribute27 := p_attribute27;
										  l_counter_template_rec.attribute28 := p_attribute28;
										  l_counter_template_rec.attribute29 := p_attribute29;
										  l_counter_template_rec.attribute30 := p_attribute30;

									    IF (l_plog) THEN
										 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
										'==================== Calling csi_counter_template_pub.update_counter_template ===================='
										||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
									   END IF;
									    csi_counter_template_pub.update_counter_template(p_api_version,
															 l_commit,
															 l_init_msg_list,
															 l_validation_level,
															 l_counter_template_rec,
															 l_ctr_item_associations_tbl,
															 l_ctr_property_template_tbl,
															 l_counter_relationships_tbl,
															 l_ctr_derived_filters_tbl,
															 x_return_status,
															 x_msg_count,
															 x_msg_data);
									 IF (l_plog) THEN
										 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
										'==================== Returning from csi_counter_template_pub.update_counter_template ===================='
										||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
									  END IF;
  END IF;



	-- End of API body.
	-- Standard check of l_commit.
	IF FND_API.To_Boolean( l_commit ) THEN
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
    	(  	p_msg_index_out        	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    	);
	  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from FND_MSG_PUB.get ====================');

		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_METER_PUB.update_meter ====================');
	END IF;
	x_msg_data := substr(x_msg_data,1,4000);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO update_meter_pub;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO update_meter_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_METER_PUB.update_meter: EXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

		x_msg_data := substr(x_msg_data,1,4000);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO update_meter_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO update_meter_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_METER_PUB.update_meter: UNEXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.get ====================');
		END IF;
		FND_MSG_PUB.get
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;
		x_msg_data := substr(x_msg_data,1,4000);
	WHEN OTHERS THEN
		ROLLBACK TO update_meter_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO update_meter_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_METER_PUB.update_meter: OTHERS ERROR=======');
		END IF;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Calling FND_MSG_PUB.Add_Exc_Msg ====================');
	 		END IF;
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
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
    		(  	p_msg_index_out         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
		IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.get ====================');
 		END IF;

		x_msg_data := substr(x_msg_data,1,4000);
end update_meter;



END EAM_METER_PUB;


/
