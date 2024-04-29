--------------------------------------------------------
--  DDL for Package Body EAM_METERREADING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METERREADING_PUB" as
/* $Header: EAMPMTRB.pls 120.6 2006/03/02 21:56:10 mmaduska ship $ */

-- Start of comments
--  API name: EAM_MeterReading_PUB
--  Type  : Public
--  Function: Create new meter reading; disable existing meter reading
--  Pre-reqs: None.
--  Version : Current version 1.0
-- End of comments

G_PKG_NAME      CONSTANT VARCHAR2(30):='EAM_MeterReading_PUB';


-- Procedure for raising errors
PROCEDURE RAISE_ERROR (ERROR VARCHAR2)
IS
BEGIN
  FND_MESSAGE.SET_NAME ('EAM', ERROR);
  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
END;


PROCEDURE check_wip_entity_id (p_wip_entity_id number , p_meter_id number)
IS
   x_maintenance_object_id number;
   l_count number;

   l_api_name			CONSTANT VARCHAR2(30)	:='check_wip_entity_id';
   l_module            varchar2(200) ;

   l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
   l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
   l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;
BEGIN
  IF (l_ulog) THEN
       l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
  END IF;

  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_MeterReading_PUB.check_wip_entity_id ====================');
  END IF;

  SELECT maintenance_object_id into x_maintenance_object_id
  FROM wip_discrete_jobs
  WHERE wip_entity_id = p_wip_entity_id
  AND maintenance_object_type = 3;
  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'x_maintenance_object_id:'||x_maintenance_object_id);
  END IF;


  SELECT COUNT(1) into l_count
  FROM csi_counter_associations csa,csi_counter_relationships ccr
  WHERE
  csa.source_object_id = x_maintenance_object_id
  AND csa.counter_id = ccr.OBJECT_COUNTER_ID (+)
  AND nvl(ccr.source_counter_id (+),csa.counter_id) = p_meter_id
  and CCR.ACTIVE_END_DATE (+) >= sysdate ;

  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_count:'||l_count);
  END IF;
  IF l_count = 0 then
    raise_error ('EAM_MTR_WO_INVALID');  -- Specified meter is invalid for this work order.
  END IF;

 IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting from EAM_MeterReading_PUB.check_wip_entity_id ====================');
  END IF;
EXCEPTION
  WHEN no_data_found THEN
    --Invalid work order
    fnd_message.set_name('EAM', 'EAM_INVALID_PARAMETER');
    fnd_message.set_token('NAME', 'WIP_ENTITY_ID :' || p_wip_entity_id);
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
END;


PROCEDURE create_meter_reading
(
  p_api_version                IN             number,
  p_init_msg_list              IN             varchar2:=FND_API.G_FALSE,
  p_commit                     IN             varchar2:=FND_API.G_FALSE,
  x_msg_count                  OUT  NOCOPY    number,
  x_msg_data                   OUT  NOCOPY    varchar2,
  x_return_status              OUT  NOCOPY    varchar2,
  p_meter_reading_rec          IN             Eam_MeterReading_PUB.Meter_Reading_Rec_Type,
  p_ctr_property_readings_tbl  IN             EAM_MeterReading_PUB.Ctr_Property_readings_Tbl,
  p_value_before_reset         IN             number:=NULL,
  p_ignore_warnings            IN             varchar2 := 'Y',
  x_meter_reading_id           OUT  NOCOPY    number
)
IS
l_api_name                CONSTANT varchar2(30) := 'create_meter_reading';
l_api_version             CONSTANT number     := 1.0;
l_current_reading_date		         date;
l_reset                            varchar2(1);
l_transaction                      varchar2(1) := 'N';
l_wip_entity_id                    number;
l_source_transaction_id            number;
l_source_transaction_type_id       number;
l_ctr_property_readings_tbl        Csi_Ctr_Datastructures_PUB.Ctr_Property_Readings_Tbl;
l_ctr_rdg_tbl                      Csi_Ctr_Datastructures_PUB.Counter_Readings_Tbl;
l_csi_txn_tbl											 Csi_Datastructures_PUB.transaction_tbl;

   l_module            varchar2(200);

   l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
   l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
   l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
  -- Standard Start of API savepoint
    SAVEPOINT create_meter_reading_Pub;
    IF (l_ulog) THEN
       l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    END IF;

    IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_MeterReading_PUB.create_meter_reading ====================');
    END IF;
    -- Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
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
    l_ctr_property_readings_tbl.DELETE;
    l_ctr_rdg_tbl.DELETE;
    l_csi_txn_tbl.DELETE;

    l_wip_entity_id := p_meter_reading_rec.wip_entity_id;
    l_current_reading_date := p_meter_reading_rec.current_reading_date;
    l_reset := p_meter_reading_rec.reset_flag;

  -- Check if the asset for which the current work order is raised has the current counter associated to it.
    IF l_wip_entity_id IS NOT NULL THEN
      IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling check_wip_entity_id  ====================');
     END IF;
      check_wip_entity_id (l_wip_entity_id , p_meter_reading_rec.meter_id);
    IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returning from check_wip_entity_id  ====================');
     END IF;
    END IF;

  -- Assign the values of Source transaction id and source transactio type for the transaction records.
	  IF(l_wip_entity_id IS NOT NULL) THEN
	    l_source_transaction_type_id := 92;
	    l_source_transaction_id := l_wip_entity_id;
	    l_transaction := 'Y';
	  ELSIF (p_meter_reading_rec.check_in_out_type = 1 AND p_meter_reading_rec.check_in_out_txn_id  IS NOT NULL) THEN
	    l_source_transaction_type_id := 94;
	    l_source_transaction_id := p_meter_reading_rec.check_in_out_txn_id;
	    l_transaction := 'Y';
	  ELSIF (p_meter_reading_rec.check_in_out_type = 2 AND p_meter_reading_rec.check_in_out_txn_id  IS NOT NULL) THEN
	    l_source_transaction_type_id := 95;
	    l_source_transaction_id := p_meter_reading_rec.check_in_out_txn_id;
	    l_transaction := 'Y';
	  ELSIF(p_meter_reading_rec.instance_id IS NOT NULL) THEN
	    l_source_transaction_type_id := 91;
	    l_source_transaction_id := p_meter_reading_rec.instance_id;
	    l_transaction := 'Y';
	  ELSE
	    l_source_transaction_type_id := 88;    --transaction type when there is no transaction info
	    l_transaction := 'Y';
	  END IF;

	  IF l_transaction = 'Y' THEN
	    l_csi_txn_tbl(1).source_header_ref_id := l_source_transaction_id;
	    l_csi_txn_tbl(1).transaction_type_id := l_source_transaction_type_id;
	    l_csi_txn_tbl(1).transaction_date := l_current_reading_date;
	    l_csi_txn_tbl(1).source_transaction_date := l_current_reading_date;
	  END IF;


	-- Assigning values for the Counter readings record

	-- If the record is  a reset reading Reset Mode should be soft for EAM else null.
	  IF (l_reset='Y') then
 	    l_ctr_rdg_tbl(1).reset_mode := 'SOFT';
 	    l_ctr_rdg_tbl(1).reset_counter_reading := p_value_before_reset;
  	  l_ctr_rdg_tbl(1).reset_reason := p_meter_reading_rec.reset_reason;
	  ELSE
	    l_ctr_rdg_tbl(1).reset_mode := NULL;
	    l_ctr_rdg_tbl(1).reset_counter_reading := NULL;
 	    l_ctr_rdg_tbl(1).reset_reason := NULL;
    END IF;


  	l_ctr_rdg_tbl(1).counter_id := p_meter_reading_rec.meter_id;
	  l_ctr_rdg_tbl(1).counter_reading := p_meter_reading_rec.current_reading;
	  l_ctr_rdg_tbl(1).value_timestamp:= p_meter_reading_rec.current_reading_date;
	  l_ctr_rdg_tbl(1).comments := p_meter_reading_rec.description;
	  l_ctr_rdg_tbl(1).disabled_flag := 'N';
	  l_ctr_rdg_tbl(1).adjustment_type := p_meter_reading_rec.adjustment_type;
	  l_ctr_rdg_tbl(1).adjustment_reading := p_meter_reading_rec.adjustment_reading;
	  l_ctr_rdg_tbl(1).net_reading := p_meter_reading_rec.net_reading;
	  l_ctr_rdg_tbl(1).attribute_category := p_meter_reading_rec.attribute_category;
	  l_ctr_rdg_tbl(1).attribute1 := p_meter_reading_rec.attribute1;
	  l_ctr_rdg_tbl(1).attribute2 := p_meter_reading_rec.attribute2;
	  l_ctr_rdg_tbl(1).attribute3 := p_meter_reading_rec.attribute3;
	  l_ctr_rdg_tbl(1).attribute4 := p_meter_reading_rec.attribute4;
	  l_ctr_rdg_tbl(1).attribute5 := p_meter_reading_rec.attribute5;
	  l_ctr_rdg_tbl(1).attribute6 := p_meter_reading_rec.attribute6;
	  l_ctr_rdg_tbl(1).attribute7 := p_meter_reading_rec.attribute7;
	  l_ctr_rdg_tbl(1).attribute8 := p_meter_reading_rec.attribute8;
	  l_ctr_rdg_tbl(1).attribute9 := p_meter_reading_rec.attribute9;
	  l_ctr_rdg_tbl(1).attribute10 := p_meter_reading_rec.attribute10;
	  l_ctr_rdg_tbl(1).attribute11 := p_meter_reading_rec.attribute11;
	  l_ctr_rdg_tbl(1).attribute12 := p_meter_reading_rec.attribute12;
	  l_ctr_rdg_tbl(1).attribute13 := p_meter_reading_rec.attribute13;
	  l_ctr_rdg_tbl(1).attribute14 := p_meter_reading_rec.attribute14;
	  l_ctr_rdg_tbl(1).attribute15 := p_meter_reading_rec.attribute15;
	  l_ctr_rdg_tbl(1).attribute16 := p_meter_reading_rec.attribute16;
	  l_ctr_rdg_tbl(1).attribute17 := p_meter_reading_rec.attribute17;
	  l_ctr_rdg_tbl(1).attribute18 := p_meter_reading_rec.attribute18;
	  l_ctr_rdg_tbl(1).attribute19 := p_meter_reading_rec.attribute19;
	  l_ctr_rdg_tbl(1).attribute10 := p_meter_reading_rec.attribute20;
	  l_ctr_rdg_tbl(1).attribute21 := p_meter_reading_rec.attribute21;
	  l_ctr_rdg_tbl(1).attribute22 := p_meter_reading_rec.attribute22;
	  l_ctr_rdg_tbl(1).attribute23 := p_meter_reading_rec.attribute23;
	  l_ctr_rdg_tbl(1).attribute24 := p_meter_reading_rec.attribute24;
	  l_ctr_rdg_tbl(1).attribute25 := p_meter_reading_rec.attribute25;
	  l_ctr_rdg_tbl(1).attribute26 := p_meter_reading_rec.attribute26;
	  l_ctr_rdg_tbl(1).attribute27 := p_meter_reading_rec.attribute27;
	  l_ctr_rdg_tbl(1).attribute28 := p_meter_reading_rec.attribute28;
	  l_ctr_rdg_tbl(1).attribute29 := p_meter_reading_rec.attribute29;
	  l_ctr_rdg_tbl(1).attribute30 := p_meter_reading_rec.attribute30;
	  IF l_transaction = 'Y' THEN
	        l_ctr_rdg_tbl(1).parent_tbl_index := 1;
	  END IF;

	--Assigning values to the counter property record.
   IF p_ctr_property_readings_tbl.count > 0 THEN
      FOR i IN p_ctr_property_readings_tbl.FIRST .. p_ctr_property_readings_tbl.LAST LOOP
         IF p_ctr_property_readings_tbl.EXISTS(i) THEN
	          l_ctr_property_readings_tbl(i).counter_property_id := p_ctr_property_readings_tbl(i).counter_property_id;
	          l_ctr_property_readings_tbl(i).property_value := p_ctr_property_readings_tbl(i).property_value;
	          l_ctr_property_readings_tbl(i).value_timestamp := p_ctr_property_readings_tbl(i).value_timestamp;
	          l_ctr_property_readings_tbl(i).attribute_category := p_ctr_property_readings_tbl(i).attribute_category;
	          l_ctr_property_readings_tbl(i).attribute1 := p_ctr_property_readings_tbl(i).attribute1;
	          l_ctr_property_readings_tbl(i).attribute2 := p_ctr_property_readings_tbl(i).attribute2;
	          l_ctr_property_readings_tbl(i).attribute3 := p_ctr_property_readings_tbl(i).attribute3;
	          l_ctr_property_readings_tbl(i).attribute4 := p_ctr_property_readings_tbl(i).attribute4;
	          l_ctr_property_readings_tbl(i).attribute5 := p_ctr_property_readings_tbl(i).attribute5;
	          l_ctr_property_readings_tbl(i).attribute6 := p_ctr_property_readings_tbl(i).attribute6;
	          l_ctr_property_readings_tbl(i).attribute7 := p_ctr_property_readings_tbl(i).attribute7;
	          l_ctr_property_readings_tbl(i).attribute8 := p_ctr_property_readings_tbl(i).attribute8;
	          l_ctr_property_readings_tbl(i).attribute9 := p_ctr_property_readings_tbl(i).attribute9;
	          l_ctr_property_readings_tbl(i).attribute10 := p_ctr_property_readings_tbl(i).attribute10;
	          l_ctr_property_readings_tbl(i).attribute11 := p_ctr_property_readings_tbl(i).attribute11;
	          l_ctr_property_readings_tbl(i).attribute12 := p_ctr_property_readings_tbl(i).attribute12;
	          l_ctr_property_readings_tbl(i).attribute13 := p_ctr_property_readings_tbl(i).attribute13;
	          l_ctr_property_readings_tbl(i).attribute14 := p_ctr_property_readings_tbl(i).attribute14;
	          l_ctr_property_readings_tbl(i).attribute15 := p_ctr_property_readings_tbl(i).attribute15;
	          l_ctr_property_readings_tbl(i).migrated_flag := p_ctr_property_readings_tbl(i).migrated_flag;
	          IF l_transaction = 'Y' THEN
	          	l_ctr_property_readings_tbl(i).parent_tbl_index := 1;
	          END IF;
	       END IF;
	    END LOOP;
	 END IF;

	  -- Call to CSI API to create counter reading.
     IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling  Csi_Counter_Readings_PUB.Capture_Counter_reading ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
     END IF;
    Csi_Counter_Readings_PUB.Capture_Counter_reading(p_api_version => p_api_version,
                                                     p_commit => p_commit,
                                                     p_init_msg_list => p_init_msg_list,
                                                     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                     p_txn_tbl => l_csi_txn_tbl,
                                                     p_ctr_rdg_tbl => l_ctr_rdg_tbl,
                                                     p_ctr_prop_rdg_tbl => l_ctr_property_readings_tbl,
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data);
    IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returning from  Csi_Counter_Readings_PUB.Capture_Counter_reading ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
    END IF;

   x_meter_reading_id := l_ctr_rdg_tbl(1).counter_value_id;


  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
    IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'Committed Work');
    END IF;
  END IF;
   IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting from EAM_MeterReading_PUB.create_meter_reading ====================');
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_meter_reading_Pub;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_reading_Pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.create_meter_readingr: EXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
    IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_meter_reading_Pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_reading_Pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.create_meter_readingr: UNEXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
	END IF;
  WHEN OTHERS THEN
    ROLLBACK TO create_meter_reading_Pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_reading_Pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '=================== EAM_MeterReading_PUB.create_meter_reading: OTHERS ERROR=======');
      END IF;
      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
	    IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Calling FND_MSG_PUB.Add_Exc_Msg ====================');
    	     END IF;
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
          );
	  IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Add_Exc_Msg ====================');
 	  END IF;
    END IF;
    IF (l_plog) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
     FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
	END IF;
END create_meter_reading;

procedure create_meter_reading
(
   p_api_version                IN             number,
   p_init_msg_list              IN             varchar2 := FND_API.G_FALSE,
   p_commit                     IN             varchar2 := FND_API.G_FALSE,
   x_msg_count                  OUT  NOCOPY    number,
   x_msg_data                   OUT  NOCOPY    varchar2,
   x_return_status              OUT  NOCOPY    varchar2,
   p_meter_reading_rec          IN             EAM_MeterReading_PUB.Meter_Reading_Rec_Type,
   p_value_before_reset         IN             number := NULL,
   p_ignore_warnings            IN             varchar2 := 'Y',
   x_meter_reading_id           OUT  NOCOPY    number
)
IS

l_api_name                CONSTANT varchar2(30) := 'create_meter_reading';
l_api_version             CONSTANT number     := 1.0;
l_ctr_property_readings_tbl        EAM_MeterReading_PUB.Ctr_Property_readings_Tbl;
l_msg_count                        NUMBER;
l_msg_data                         VARCHAR2(5000);
l_return_status                    VARCHAR2(1);
l_meter_reading_id                 NUMBER;

l_module            varchar2(200) ;
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;


BEGIN
  -- Standard Start of API savepoint
    SAVEPOINT create_meter_reading_Pub;
    IF (l_ulog) THEN
       l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    END IF;

    IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_MeterReading_PUB.create_meter_reading ====================');
    END IF;
    -- Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
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
    l_ctr_property_readings_tbl.DELETE;
    IF (l_plog) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling EAM_MeterReading_PUB.create_meter_reading ===================='
		||'l_return_status:'||l_return_status
				||' l_msg_count:'||l_msg_count
				||'l_msg_data:'||l_msg_data);
    END IF;
    EAM_MeterReading_PUB.create_meter_reading(p_api_version => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     p_commit => p_commit,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data,
                     x_return_status => l_return_status,
                     p_meter_reading_rec => p_meter_reading_rec,
                     p_ctr_property_readings_tbl => l_ctr_property_readings_tbl,
                     p_value_before_reset => p_value_before_reset,
                     p_ignore_warnings => p_ignore_warnings,
                     x_meter_reading_id => l_meter_reading_id);
   IF (l_plog) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Returned from EAM_MeterReading_PUB.create_meter_reading ===================='
		||'l_return_status:'||l_return_status
				||' l_msg_count:'||l_msg_count
				||'l_msg_data:'||l_msg_data);
    END IF;

  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN

    COMMIT WORK;
     IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'Commiting Work');
     END IF;
  END IF;
  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_MeterReading_PUB.create_meter_reading ====================');
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_meter_reading_Pub;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_reading_Pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.create_meter_reading: EXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
	END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_meter_reading_Pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_reading_Pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.create_meter_reading: UNEXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
	END IF;
  WHEN OTHERS THEN
    ROLLBACK TO create_meter_reading_Pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO create_meter_reading_Pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.create_meter_reading: OTHERS ERROR=======');
    END IF;
      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
              IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Calling FND_MSG_PUB.Add_Exc_Msg ====================');
		END IF;
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
          );
	  IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Returned from FND_MSG_PUB.Add_Exc_Msg ====================');
    	  END IF;
    END IF;
    IF (l_plog) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
	END IF;
END create_meter_reading;

PROCEDURE disable_meter_reading
(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2:=FND_API.G_FALSE,
  p_commit              IN    VARCHAR2:=FND_API.G_FALSE,
  x_msg_count           OUT NOCOPY   NUMBER,
  x_msg_data            OUT NOCOPY   VARCHAR2,
  x_return_status       OUT NOCOPY   VARCHAR2,
  p_meter_reading_id    IN    NUMBER:=null,
  p_meter_id            IN    NUMBER:=null,
  p_meter_reading_date  IN    DATE :=NULL
)
IS

l_api_name                      CONSTANT VARCHAR2(30)   := 'disable_meter_reading';
l_api_version                   CONSTANT NUMBER                 := 1.0;
l_object_version_number                  Number;
l_ctr_rdg_tbl                            Csi_Ctr_Datastructures_PUB.Counter_Readings_Tbl;

l_module             varchar2(200);
l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN

 SAVEPOINT   disable_meter_reading_pub;
   IF (l_ulog) THEN
       l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
  END IF;

  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_MeterReading_PUB.disable_meter_reading_pub ====================');
  END IF;
-- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (  l_api_version         ,
                              p_api_version         ,
                        l_api_name        ,
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

  l_ctr_rdg_tbl.DELETE;

  SELECT object_version_number
  INTO l_object_version_number
  FROM csi_counter_readings
  WHERE counter_value_id = p_meter_reading_id;
  IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_object_version_number: '||l_object_version_number);
  END IF;

  -- Assigning values for the Counter readings record
  l_ctr_rdg_tbl(1).counter_id := p_meter_id;
	l_ctr_rdg_tbl(1).counter_value_id := p_meter_reading_id;
	l_ctr_rdg_tbl(1).value_timestamp:= p_meter_reading_date;
	l_ctr_rdg_tbl(1).object_version_number:= l_object_version_number;
	l_ctr_rdg_tbl(1).disabled_flag := 'Y';

	-- Call to CSI API to disable counter reading.
	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Calling Csi_Counter_Readings_PUB.Update_Counter_Reading ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;
	 Csi_Counter_Readings_PUB.Update_Counter_Reading (p_api_version => p_api_version,
                                                    p_commit => p_commit,
                                                    p_init_msg_list => p_init_msg_list,
                                                    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                    p_ctr_rdg_tbl => l_ctr_rdg_tbl,
                                                    x_return_status => x_return_status,
                                                    x_msg_count => x_msg_count,
                                                    x_msg_data => x_msg_data);
	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting from Csi_Counter_Readings_PUB.Update_Counter_Reading ===================='
		||'x_return_status:'||x_return_status
				||' x_msg_count:'||x_msg_count
				||'x_msg_data:'||x_msg_data);
	END IF;

  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
    IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'Committed Work');
    END IF;
  END IF;
IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_MeterReading_PUB.disable_meter_reading_pub ====================');
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO disable_meter_reading_pub;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO disable_meter_reading_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.disable_meter_reading_pub: EXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
 		END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO disable_meter_reading_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO disable_meter_reading_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.disable_meter_reading_pub: UNEXPECTED ERROR======='||
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
 		END IF;
  WHEN OTHERS THEN

    ROLLBACK TO disable_meter_reading_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF (l_plog) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,'ROLLBACK TO disable_meter_reading_pub');
	             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		        '===================EAM_MeterReading_PUB.disable_meter_reading_pub: OTHERS ERROR=======');
	END IF;
      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
          IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Calling FND_MSG_PUB.Add_Exc_Msg ====================');
	   END IF;
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
          );
          IF (l_plog) THEN
				 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
				'==================== Returned from FND_MSG_PUB.Add_Exc_Msg ====================');
	END IF;
    END IF;
	IF (l_plog) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Calling FND_MSG_PUB.Count_And_Get ====================');
	END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count       ,
              p_data            =>      x_msg_data
        );
	IF (l_plog) THEN
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'==================== Returned from FND_MSG_PUB.Count_And_Get ====================');
 		END IF;

END disable_meter_reading;

END EAM_METERREADING_PUB;

/
