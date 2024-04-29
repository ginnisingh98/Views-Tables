--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_READINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_READINGS_PUB" as
/* $Header: csipcrdb.pls 120.3.12010000.2 2008/10/31 21:13:03 rsinn ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_READINGS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipcrdb.pls';
--
/*----------------------------------------------------*/
/* procedure name: Capture_Counter_Reading            */
/* description :   procedure used to                  */
/*                 capture counter readings           */
/*----------------------------------------------------*/

PROCEDURE Capture_Counter_Reading
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_tbl               IN OUT NOCOPY csi_datastructures_pub.transaction_tbl
    ,p_ctr_rdg_tbl           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_tbl
    ,p_ctr_prop_rdg_tbl      IN OUT NOCOPY csi_ctr_datastructures_pub.ctr_property_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'CAPTURE_COUNTER_READING';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   -- l_debug_level                   NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   l_dflt_ctr_prop_rec             csi_ctr_datastructures_pub.ctr_property_readings_rec;
   l_temp_ctr_prop_rec             csi_ctr_datastructures_pub.ctr_property_readings_rec;
   l_derive_ctr_rec                csi_ctr_datastructures_pub.counter_readings_rec;
   l_temp_ctr_rdg_rec              csi_ctr_datastructures_pub.counter_readings_rec;
   l_process_flag                  BOOLEAN := TRUE;
   l_dummy                         VARCHAR2(1);
   l_reset_only                    VARCHAR2(1);
   l_instance_id                   NUMBER;
   l_formula_rel_type              VARCHAR2(30) := 'FORMULA';
   l_target_rel_type               VARCHAR2(30) := 'CONFIGURATION';
   --
   TYPE T_NUM IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_assembler_tbl                 T_NUM;
   --
   CURSOR DFLT_PROP_RDG(p_counter_id IN NUMBER, p_value_id IN NUMBER) IS
   select ccp.counter_property_id,ccp.default_value
   from CSI_COUNTER_PROPERTIES_B ccp
   where ccp.counter_id = p_counter_id
   and    ((ccp.default_value is not null) or
           (ccp.default_value is null and ccp.is_nullable = 'N'))
   and   nvl(end_date_active,(sysdate+1)) > sysdate
   and   not exists (select 'x' from CSI_CTR_PROPERTY_READINGS cpr
                     Where cpr.counter_value_id = p_value_id
                     and   cpr.counter_property_id = ccp.counter_property_id);
   --
   CURSOR LATER_READINGS_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_value_id,counter_reading,net_reading,value_timestamp,adjustment_reading
         ,reset_mode,adjustment_type,include_target_resets
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp > p_value_timestamp
   ORDER BY value_timestamp asc, counter_value_id asc;
   --
   CURSOR FORMULA_CUR(p_src_ctr_id IN NUMBER) IS
   select distinct object_counter_id
   from csi_counter_relationships
   where source_counter_id = p_src_ctr_id
   and   relationship_type_code = l_formula_rel_type
   and   nvl(active_end_date,(sysdate+1)) > sysdate;
   --
   CURSOR TARGET_CUR(p_src_ctr_id IN NUMBER,p_value_timestamp IN DATE) IS
   select ccr.object_counter_id
   from CSI_COUNTER_RELATIONSHIPS ccr,
        CSI_COUNTERS_B ccv
   where ccr.source_counter_id = p_src_ctr_id
   and   ccr.relationship_type_code = l_target_rel_type
   and   nvl(ccr.active_start_date,sysdate) <= p_value_timestamp
   and   nvl(ccr.active_end_date,(sysdate+1)) > p_value_timestamp
   and   ccv.counter_id = ccr.object_counter_id;
   --
   CURSOR UPD_TARGET_CUR(p_ctr_value_id IN NUMBER,p_src_ctr_id IN NUMBER) IS
   SELECT crg.counter_id
   from CSI_COUNTER_READINGS crg,
        CSI_COUNTER_RELATIONSHIPS ccr,
        CSI_COUNTERS_B ccv
   where crg.source_counter_value_id = p_ctr_value_id
   and   ccr.object_counter_id = crg.counter_id
   and   ccr.source_counter_id = p_src_ctr_id
   and   ccr.relationship_type_code = l_target_rel_type
   and   ccv.counter_id = crg.counter_id;
   --
   CURSOR DERIVE_CUR(p_ctr_value_id IN NUMBER) IS
   SELECT ctr.counter_id
   FROM CSI_COUNTERS_B ctr, CSI_COUNTER_READINGS cv
   WHERE cv.counter_value_id = p_ctr_value_id
   AND   ctr.derive_counter_id = cv.counter_id
   AND   NVL(ctr.start_date_active,sysdate) <= cv.value_timestamp
   AND   NVL(ctr.end_date_active,(sysdate+1)) > cv.value_timestamp;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  capture_counter_reading;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'capture_counter_reading_pub'               ||'-'||
                                     p_api_version                              ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;
   --
   IF p_txn_tbl.count = 0 THEN
      csi_ctr_gen_utility_pvt.put_line('Transaction Information is empty. Cannot Proceed...');
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_NO_TXN_TYPE_ID');
   END IF;
   --
   FOR j in p_txn_tbl.FIRST .. p_txn_tbl.LAST LOOP
      IF p_txn_tbl.EXISTS(j) THEN
         csi_ctr_gen_utility_pvt.put_line('Dumping Transaction Record #  '||to_char(j));
         csi_ctr_gen_utility_pvt.dump_txn_rec(p_txn_rec   =>  p_txn_tbl(j));
         csi_ctr_gen_utility_pvt.put_line('Calling Create_Reading_Transaction...');
	 Csi_Counter_Readings_Pvt.Create_Reading_Transaction
	       ( p_api_version           =>  1.0
		,p_commit                =>  fnd_api.g_false
		,p_init_msg_list         =>  fnd_api.g_true
		,p_validation_level      =>  fnd_api.g_valid_level_full
		,p_txn_rec               =>  p_txn_tbl(j)
		,x_return_status         =>  x_return_status
		,x_msg_count             =>  x_msg_count
		,x_msg_data              =>  x_msg_data
	       );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csi_ctr_gen_utility_pvt.put_line('Error from Create_Reading_Transaction...');
	    l_msg_index := 1;
	    FND_MSG_PUB.Count_And_Get
		    (p_count  =>  x_msg_count,
		     p_data   =>  x_msg_data
		    );
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
	       x_msg_data := FND_MSG_PUB.GET
			  (  l_msg_index,
			     FND_API.G_FALSE        );
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	       l_msg_index := l_msg_index + 1;
	       l_msg_count := l_msg_count - 1;
	    END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF; -- p_txn_tbl record exists check
   END LOOP; -- End of Txn Tbl Loop
   --
   -- Calling Customer Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  )  then
      CSI_COUNTER_READINGS_CUHK.CAPTURE_COUNTER_READING_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_txn_tbl              => p_txn_tbl
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,p_ctr_prop_rdg_tbl     => p_ctr_prop_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_CUHK.Capture_Counter_Reading_Pre API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  then
      CSI_COUNTER_READINGS_VUHK.CAPTURE_COUNTER_READING_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_txn_tbl              => p_txn_tbl
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,p_ctr_prop_rdg_tbl     => p_ctr_prop_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_VUHK.Capture_Counter_Reading_Pre API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   IF p_ctr_rdg_tbl.count > 0 THEN
      FOR j IN p_ctr_rdg_tbl.FIRST .. p_ctr_rdg_tbl.LAST LOOP
         IF p_ctr_rdg_tbl.EXISTS(j) THEN
            -- Call Capture Counter reading PVT;
            csi_ctr_gen_utility_pvt.dump_counter_readings_rec(p_ctr_rdg_tbl(j));
            IF NOT p_txn_tbl.EXISTS(p_ctr_rdg_tbl(j).parent_tbl_index) THEN
               csi_ctr_gen_utility_pvt.put_line('Counter Reading record does not have a Transaction...');
               csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_RDG_NO_TXN');
            END IF;
            --
            -- Check whether this is Reset only reading.
            -- This will decide whether to compute Derive counters or not
            --
            IF NVL(p_ctr_rdg_tbl(j).counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
               NVL(p_ctr_rdg_tbl(j).reset_mode,FND_API.G_MISS_CHAR) = 'SOFT' THEN
               l_reset_only := 'T';
            ELSE
               l_reset_only := 'F';
            END IF;
            --
            IF p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index).transaction_type_id in (88,91,92,94,95) THEN
               IF p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index).transaction_type_id = 91 THEN
                  l_instance_id := p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index).source_header_ref_id;
               ELSE
                  l_instance_id := null;
               END IF;
               csi_ctr_gen_utility_pvt.put_line('Calling Insert Meter Log...');
               Eam_Asset_Log_Pvt.Insert_Meter_Log
                  (
                    P_api_version           =>  1.0,
                    P_init_msg_list         =>  fnd_api.g_false,
                    P_commit                =>  fnd_api.g_false,
                    P_validation_level      =>  fnd_api.g_valid_level_full,
                    P_event_date            =>  p_ctr_rdg_tbl(j).value_timestamp,
                    P_instance_id           =>  l_instance_id,
                    P_ref_id                =>  p_ctr_rdg_tbl(j).counter_id,
                    X_return_status         =>  x_return_status,
                    X_msg_count             =>  x_msg_count,
                    X_msg_data              =>  x_msg_data
               );
               -- Since this is only for logging we are ignoring the x_return_status.
               -- Just report the API error and proceed.
               --
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  csi_ctr_gen_utility_pvt.put_line('ERROR FROM Insert_Meter_Log API ');
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
                  -- DO NOT RAISE ERROR
	       END IF;
            END IF; -- EAM Logging Check
            --
            IF p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index).transaction_type_id = 92 THEN
               csi_ctr_gen_utility_pvt.put_line('Calling Update_Last_Service_Reading_Wo...');
               Eam_Meters_Util.Update_Last_Service_Reading_Wo
                  (
                    p_wip_entity_id    =>  p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index).source_header_ref_id,
                    p_meter_id         =>  p_ctr_rdg_tbl(j).counter_id,
		    p_meter_reading    =>  p_ctr_rdg_tbl(j).counter_reading,
		    p_wo_end_date      =>  p_ctr_rdg_tbl(j).value_timestamp,
                    X_return_status    =>  x_return_status,
                    X_msg_count        =>  x_msg_count,
                    X_msg_data         =>  x_msg_data
	           );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  csi_ctr_gen_utility_pvt.put_line('ERROR FROM Update_Last_Service_Reading_Wo API ');
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
            END IF; -- Call Update_Last_Service_Reading_WO check
            --
	    csi_ctr_gen_utility_pvt.put_line('Calling Capture_Counter_Reading_pvt...');
	    Csi_Counter_Readings_Pvt.Capture_Counter_Reading
	       (
		 p_api_version           => 1.0
		,p_commit                => p_commit
		,p_init_msg_list         => p_init_msg_list
		,p_validation_level      => p_validation_level
                ,p_txn_rec               => p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index)
		,p_ctr_rdg_rec           => p_ctr_rdg_tbl(j)
		,x_return_status         => x_return_status
		,x_msg_count             => x_msg_count
		,x_msg_data              => x_msg_data
	       );
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM Capture_Counter_Reading_pvt API ');
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
		  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
            --
            IF p_ctr_prop_rdg_tbl.count > 0 THEN
               FOR k IN p_ctr_prop_rdg_tbl.FIRST .. p_ctr_prop_rdg_tbl.LAST LOOP
                  IF p_ctr_prop_rdg_tbl.EXISTS(k) THEN
                     IF p_ctr_prop_rdg_tbl(k).parent_tbl_index = j THEN
                        p_ctr_prop_rdg_tbl(k).counter_value_id := p_ctr_rdg_tbl(j).counter_value_id;
                        p_ctr_prop_rdg_tbl(k).value_timestamp := p_ctr_rdg_tbl(j).value_timestamp;
                        -- Call Property reading PVT;
                        csi_ctr_gen_utility_pvt.dump_ctr_property_readings_rec(p_ctr_prop_rdg_tbl(k));
                        csi_ctr_gen_utility_pvt.put_line('Calling Capture_Ctr_Property_Reading...');
			Csi_Counter_Readings_Pvt.Capture_Ctr_Property_Reading
			   (
			     p_api_version           => 1.0
			    ,p_commit                => p_commit
			    ,p_init_msg_list         => p_init_msg_list
			    ,p_validation_level      => p_validation_level
			    ,p_ctr_prop_rdg_rec      => p_ctr_prop_rdg_tbl(k)
		            ,x_return_status         => x_return_status
		            ,x_msg_count             => x_msg_count
		            ,x_msg_data              => x_msg_data
			 );
			IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			   csi_ctr_gen_utility_pvt.put_line('ERROR FROM Capture_Ctr_Property_Reading API ');
			   l_msg_index := 1;
			   l_msg_count := x_msg_count;
			   WHILE l_msg_count > 0 LOOP
			      x_msg_data := FND_MSG_PUB.GET
			      (  l_msg_index,
				 FND_API.G_FALSE
			      );
			      csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			      l_msg_index := l_msg_index + 1;
			      l_msg_count := l_msg_count - 1;
			   END LOOP;
			   RAISE FND_API.G_EXC_ERROR;
			END IF;
                     END IF; -- Current counter property
                  END IF; -- Prop rec exists
               END LOOP; -- Property Tbl Loop
            END IF; -- Prop Tbl > 0
            -- Capture Default_Property
            --
            FOR dflt_rec IN DFLT_PROP_RDG(p_ctr_rdg_tbl(j).counter_id,p_ctr_rdg_tbl(j).counter_value_id)
            LOOP
               l_dflt_ctr_prop_rec := l_temp_ctr_prop_rec; -- Initialize
               --
               l_dflt_ctr_prop_rec.counter_property_id := dflt_rec.counter_property_id;
               l_dflt_ctr_prop_rec.property_value := dflt_rec.default_value;
               l_dflt_ctr_prop_rec.value_timestamp := p_ctr_rdg_tbl(j).value_timestamp;
               l_dflt_ctr_prop_rec.counter_value_id := p_ctr_rdg_tbl(j).counter_value_id;
               --
               csi_ctr_gen_utility_pvt.dump_ctr_property_readings_rec(l_dflt_ctr_prop_rec);
	       csi_ctr_gen_utility_pvt.put_line('Calling Capture_Ctr_Property_Reading for Dflt Property');
	       Csi_Counter_Readings_Pvt.Capture_Ctr_Property_Reading
		  (
		    p_api_version           => 1.0
		   ,p_commit                => p_commit
		   ,p_init_msg_list         => p_init_msg_list
		   ,p_validation_level      => p_validation_level
		   ,p_ctr_prop_rdg_rec      => l_dflt_ctr_prop_rec
		   ,x_return_status         => x_return_status
		   ,x_msg_count             => x_msg_count
		   ,x_msg_data              => x_msg_data
		);
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  csi_ctr_gen_utility_pvt.put_line('ERROR FROM Capture_Ctr_Property_Reading API ');
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
            END LOOP; -- Default Property Loop
            --
            -- Call compute Derive filters only if the current capture is not a pure reset.
            -- This is applicable for the Later readings cursor as Reset should be the last reading.
            IF l_reset_only = 'F' THEN
	       l_derive_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_derive_ctr_rec.counter_value_id := p_ctr_rdg_tbl(j).counter_value_id;
	       l_derive_ctr_rec.counter_id := p_ctr_rdg_tbl(j).counter_id;
	       l_derive_ctr_rec.value_timestamp := p_ctr_rdg_tbl(j).value_timestamp;
	       l_derive_ctr_rec.source_code := p_ctr_rdg_tbl(j).source_code;
	       l_derive_ctr_rec.source_line_id := p_ctr_rdg_tbl(j).source_line_id;
	       --
	       -- Call Compute Derive Counters
	       csi_ctr_gen_utility_pvt.put_line('Calling Compute_Derive_Counters...');
	       Csi_Counter_Readings_Pvt.Compute_Derive_Counters
		  (
		    p_api_version           => 1.0
		   ,p_commit                => p_commit
		   ,p_init_msg_list         => p_init_msg_list
		   ,p_validation_level      => p_validation_level
		   ,p_txn_rec               => p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index)
		   ,p_ctr_rdg_rec           => l_derive_ctr_rec
		   ,p_mode                  => 'CREATE'
		   ,x_return_status         => x_return_status
		   ,x_msg_count             => x_msg_count
		   ,x_msg_data              => x_msg_data
		 );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Derive_Counters API ');
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	       --
	       -- Re-compute Derive comunters for the Later Readings
	       -- No need for SOFT reset as we would not have created it before.
	       FOR later_rdg IN LATER_READINGS_CUR(p_ctr_rdg_tbl(j).counter_id,
                                                   p_ctr_rdg_tbl(j).value_timestamp)
	       LOOP
		  IF NVL(later_rdg.reset_mode,'$#$') <> 'SOFT' THEN
		     l_derive_ctr_rec := l_temp_ctr_rdg_rec;
		     --
		     l_derive_ctr_rec.counter_value_id := later_rdg.counter_value_id;
		     l_derive_ctr_rec.counter_id := p_ctr_rdg_tbl(j).counter_id;
		     l_derive_ctr_rec.value_timestamp := later_rdg.value_timestamp;
		     --
		     csi_ctr_gen_utility_pvt.put_line('Calling Compute_Derive_Counters for Update...');
		     Csi_Counter_Readings_Pvt.Compute_Derive_Counters
			(
			  p_api_version           => 1.0
			 ,p_commit                => p_commit
			 ,p_init_msg_list         => p_init_msg_list
			 ,p_validation_level      => p_validation_level
			 ,p_txn_rec               => p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index)
			 ,p_ctr_rdg_rec           => l_derive_ctr_rec
			 ,p_mode                  => 'UPDATE'
			 ,x_return_status         => x_return_status
			 ,x_msg_count             => x_msg_count
			 ,x_msg_data              => x_msg_data
		       );
		     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Derive_Counters API ');
			l_msg_index := 1;
			l_msg_count := x_msg_count;
			WHILE l_msg_count > 0 LOOP
			   x_msg_data := FND_MSG_PUB.GET
			   (  l_msg_index,
			      FND_API.G_FALSE
			   );
			   csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			   l_msg_index := l_msg_index + 1;
			   l_msg_count := l_msg_count - 1;
			END LOOP;
			RAISE FND_API.G_EXC_ERROR;
		     END IF;
		  END IF; -- End of Derive counter call check
	       END LOOP;
	    END IF; -- l_reset_only check
	    -- Call Compute Formula
	    Csi_Counter_Readings_Pvt.Compute_Formula_Counters
	       (
		 p_api_version           => 1.0
		,p_commit                => p_commit
		,p_init_msg_list         => p_init_msg_list
		,p_validation_level      => p_validation_level
		,p_txn_rec               => p_txn_tbl(p_ctr_rdg_tbl(j).parent_tbl_index)
		,p_ctr_rdg_rec           => p_ctr_rdg_tbl(j)
		,x_return_status         => x_return_status
		,x_msg_count             => x_msg_count
		,x_msg_data              => x_msg_data
	      );
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Formula_Counters API ');
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
		  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
            --
         END IF; -- Rdg rec exists
      END LOOP; -- Ctr Reading Tbl Loop
   END IF;
   --
   csi_ctr_gen_utility_pvt.put_line('End of Private API Calls...');
   -- Calling Customer Post-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  )  then
      CSI_COUNTER_READINGS_CUHK.CAPTURE_COUNTER_READING_POST
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_txn_tbl              => p_txn_tbl
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,p_ctr_prop_rdg_tbl     => p_ctr_prop_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_CUHK.Capture_Counter_Reading_Post API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Post-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  )  then
      CSI_COUNTER_READINGS_VUHK.CAPTURE_COUNTER_READING_POST
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_txn_tbl              => p_txn_tbl
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,p_ctr_prop_rdg_tbl     => p_ctr_prop_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_VUHK.Capture_Counter_Reading_Post API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Need to Call the Contracts Assembler Event for all the counters that got captured in this Transaction
   l_assembler_tbl.DELETE;
   --
   FOR J IN p_ctr_rdg_tbl.FIRST .. p_ctr_rdg_tbl.LAST LOOP
      IF p_ctr_rdg_tbl.EXISTS(J) THEN
         /*
         FOR formula_rec IN FORMULA_CUR(p_ctr_rdg_tbl(J).counter_id) LOOP
            IF NOT(l_assembler_tbl.EXISTS(formula_rec.object_counter_id)) THEN
               l_assembler_tbl(formula_rec.object_counter_id) := formula_rec.object_counter_id;
            END IF;
         END LOOP;
         --
         FOR target_rec IN TARGET_CUR(p_ctr_rdg_tbl(J).counter_id,p_ctr_rdg_tbl(J).value_timestamp) LOOP
            IF NOT(l_assembler_tbl.EXISTS(target_rec.object_counter_id)) THEN
               l_assembler_tbl(target_rec.object_counter_id) := target_rec.object_counter_id;
            END IF;
         END LOOP;
         --
         FOR upd_rec IN UPD_TARGET_CUR(p_ctr_rdg_tbl(J).counter_value_id,p_ctr_rdg_tbl(J).counter_id) LOOP
            IF NOT(l_assembler_tbl.EXISTS(upd_rec.counter_id)) THEN
               l_assembler_tbl(upd_rec.counter_id) := upd_rec.counter_id;
            END IF;
         END LOOP;
         --
         FOR derive_rec IN DERIVE_CUR(p_ctr_rdg_tbl(J).counter_value_id) LOOP
            IF NOT(l_assembler_tbl.EXISTS(derive_rec.counter_id)) THEN
               l_assembler_tbl(derive_rec.counter_id) := derive_rec.counter_id;
            END IF;
         END LOOP;
         */

         OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble
            (  p_api_version        =>  1.0,
               x_return_status      =>  x_return_status,
               x_msg_count          =>  x_msg_count,
               x_msg_data           =>  x_msg_data,
               p_counter_id         =>  p_ctr_rdg_tbl(J).counter_id
            );

	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    csi_ctr_gen_utility_pvt.put_line('ERROR FROM OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble API ');
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
	       x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
	       csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	       l_msg_index := l_msg_index + 1;
	       l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   END LOOP;
   --
   -- Loop thru' the Assembler Table and call the OKC Event
   --
   /* IF l_assembler_tbl.count > 0 THEN
      FOR J IN l_assembler_tbl.FIRST .. l_assembler_tbl.LAST LOOP
         IF l_assembler_tbl.EXISTS(J) THEN
            OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble
               (  p_api_version        =>  1.0,
                  x_return_status      =>  x_return_status,
                  x_msg_count          =>  x_msg_count,
                  x_msg_data           =>  x_msg_data,
                  p_counter_id         =>  l_assembler_tbl(J)
               );
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	       csi_ctr_gen_utility_pvt.put_line('ERROR FROM OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble API ');
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
		  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
         END IF;
      END LOOP;
   END IF;
   */
   --
   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;
   --
   csi_ctr_gen_utility_pvt.put_line('Capture Counter Reading Public API Successfully Completed...');
   csi_ctr_gen_utility_pvt.put_line('*******************************************************************');
   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO capture_counter_reading;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO capture_counter_reading;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO capture_counter_reading;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END Capture_Counter_Reading;
--
/*----------------------------------------------------*/
/* procedure name: Update_Counter_Reading             */
/* description :   procedure used to                  */
/*                 update counter readings            */
/*----------------------------------------------------*/

PROCEDURE Update_Counter_Reading
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_rdg_tbl           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_READING';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   -- l_debug_level                   NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   l_formula_rel_type              VARCHAR2(30) := 'FORMULA';
   l_target_rel_type               VARCHAR2(30) := 'CONFIGURATION';
   --
   TYPE T_NUM IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_assembler_tbl                 T_NUM;
   --
   CURSOR FORMULA_CUR(p_src_ctr_id IN NUMBER) IS
   select distinct object_counter_id
   from csi_counter_relationships
   where source_counter_id = p_src_ctr_id
   and   relationship_type_code = l_formula_rel_type
   and   nvl(active_end_date,(sysdate+1)) > sysdate;
   --
   CURSOR TARGET_CUR(p_src_ctr_id IN NUMBER,p_value_timestamp IN DATE) IS
   select ccr.object_counter_id
   from CSI_COUNTER_RELATIONSHIPS ccr,
        CSI_COUNTERS_B ccv
   where ccr.source_counter_id = p_src_ctr_id
   and   ccr.relationship_type_code = l_target_rel_type
   and   nvl(ccr.active_start_date,sysdate) <= p_value_timestamp
   and   nvl(ccr.active_end_date,(sysdate+1)) > p_value_timestamp
   and   ccv.counter_id = ccr.object_counter_id;
   --
   CURSOR UPD_TARGET_CUR(p_ctr_value_id IN NUMBER,p_src_ctr_id IN NUMBER) IS
   SELECT crg.counter_id
   from CSI_COUNTER_READINGS crg,
        CSI_COUNTER_RELATIONSHIPS ccr,
        CSI_COUNTERS_B ccv
   where crg.source_counter_value_id = p_ctr_value_id
   and   ccr.object_counter_id = crg.counter_id
   and   ccr.source_counter_id = p_src_ctr_id
   and   ccr.relationship_type_code = l_target_rel_type
   and   ccv.counter_id = crg.counter_id;
   --
   CURSOR DERIVE_CUR(p_ctr_value_id IN NUMBER) IS
   SELECT ctr.counter_id
   FROM CSI_COUNTERS_B ctr, CSI_COUNTER_READINGS cv
   WHERE cv.counter_value_id = p_ctr_value_id
   AND   ctr.derive_counter_id = cv.counter_id
   AND   NVL(ctr.start_date_active,sysdate) <= cv.value_timestamp
   AND   NVL(ctr.end_date_active,(sysdate+1)) > cv.value_timestamp;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_reading;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   --
   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_reading');
   END IF;
   --
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_reading'     ||
                                     p_api_version         ||'-'||
                                     nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                     nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                     nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;
   -- Calling Customer Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  )  then
      CSI_COUNTER_READINGS_CUHK.UPDATE_COUNTER_READING_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_CUHK.Update_Counter_Reading_Pre API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  then
      CSI_COUNTER_READINGS_VUHK.UPDATE_COUNTER_READING_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_VUHK.Update_Counter_Reading_Pre API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   IF p_ctr_rdg_tbl.count > 0 THEN
      FOR j IN p_ctr_rdg_tbl.FIRST .. p_ctr_rdg_tbl.LAST LOOP
         IF p_ctr_rdg_tbl.EXISTS(j) THEN
            -- Call Update Counter reading PVT;
            csi_ctr_gen_utility_pvt.dump_counter_readings_rec(p_ctr_rdg_tbl(j));
	    csi_ctr_gen_utility_pvt.put_line('Calling Update_Counter_Reading_pvt...');
	    Csi_Counter_Readings_Pvt.Update_Counter_Reading
	       (
		 p_api_version           => 1.0
		,p_commit                => p_commit
		,p_init_msg_list         => p_init_msg_list
		,p_validation_level      => p_validation_level
		,p_ctr_rdg_rec           => p_ctr_rdg_tbl(j)
		,x_return_status         => x_return_status
		,x_msg_count             => x_msg_count
		,x_msg_data              => x_msg_data
	       );
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM Update_Counter_Reading_pvt API ');
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
		  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
         END IF; -- Rdg rec exists
      END LOOP; -- Ctr Reading Tbl Loop
   END IF;
   --
   -- Calling Customer Post-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  )  then
      CSI_COUNTER_READINGS_CUHK.UPDATE_COUNTER_READING_POST
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_CUHK.Update_Counter_Reading_Post API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Post-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  )  then
      CSI_COUNTER_READINGS_VUHK.UPDATE_COUNTER_READING_POST
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_rdg_tbl          => p_ctr_rdg_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_READINGS_VUHK.Update_Counter_Reading_Post API ');
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Need to Call the Contracts Assembler Event for all the counters that got captured in this Transaction
   l_assembler_tbl.DELETE;
   --
   FOR J IN p_ctr_rdg_tbl.FIRST .. p_ctr_rdg_tbl.LAST LOOP
      IF p_ctr_rdg_tbl.EXISTS(J) THEN
         /*
         FOR formula_rec IN FORMULA_CUR(p_ctr_rdg_tbl(J).counter_id) LOOP
            IF NOT(l_assembler_tbl.EXISTS(formula_rec.object_counter_id)) THEN
               l_assembler_tbl(formula_rec.object_counter_id) := formula_rec.object_counter_id;
            END IF;
         END LOOP;
         --
         FOR target_rec IN TARGET_CUR(p_ctr_rdg_tbl(J).counter_id,p_ctr_rdg_tbl(J).value_timestamp) LOOP
            IF NOT(l_assembler_tbl.EXISTS(target_rec.object_counter_id)) THEN
               l_assembler_tbl(target_rec.object_counter_id) := target_rec.object_counter_id;
            END IF;
         END LOOP;
         --
         FOR upd_rec IN UPD_TARGET_CUR(p_ctr_rdg_tbl(J).counter_value_id,p_ctr_rdg_tbl(J).counter_id) LOOP
            IF NOT(l_assembler_tbl.EXISTS(upd_rec.counter_id)) THEN
               l_assembler_tbl(upd_rec.counter_id) := upd_rec.counter_id;
            END IF;
         END LOOP;
         --
         FOR derive_rec IN DERIVE_CUR(p_ctr_rdg_tbl(J).counter_value_id) LOOP
            IF NOT(l_assembler_tbl.EXISTS(derive_rec.counter_id)) THEN
               l_assembler_tbl(derive_rec.counter_id) := derive_rec.counter_id;
            END IF;
         END LOOP;
         */
         OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble
            (  p_api_version        =>  1.0,
               x_return_status      =>  x_return_status,
               x_msg_count          =>  x_msg_count,
               x_msg_data           =>  x_msg_data,
               p_counter_id         =>  p_ctr_rdg_tbl(J).counter_id
            );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    csi_ctr_gen_utility_pvt.put_line('ERROR FROM OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble API ');
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
	       x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
	       csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	       l_msg_index := l_msg_index + 1;
	       l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
       END IF;
   END LOOP;
   --
   -- Loop thru' the Assembler Table and call the OKC Event
   --
   /*
   IF l_assembler_tbl.count > 0 THEN
      FOR J IN l_assembler_tbl.FIRST .. l_assembler_tbl.LAST LOOP
         IF l_assembler_tbl.EXISTS(J) THEN
            OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble
               (  p_api_version        =>  1.0,
                  x_return_status      =>  x_return_status,
                  x_msg_count          =>  x_msg_count,
                  x_msg_data           =>  x_msg_data,
                  p_counter_id         =>  l_assembler_tbl(J)
               );
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	       csi_ctr_gen_utility_pvt.put_line('ERROR FROM OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble API ');
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
		  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
         END IF;
      END LOOP;
   END IF;
   */
    --
   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;
   --
   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_reading;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_reading;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_reading;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
            ( G_PKG_NAME,
              l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );
END Update_Counter_Reading;

END CSI_COUNTER_READINGS_PUB;

/
