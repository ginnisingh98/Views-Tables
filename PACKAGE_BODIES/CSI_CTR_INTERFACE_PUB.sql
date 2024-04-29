--------------------------------------------------------
--  DDL for Package Body CSI_CTR_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CTR_INTERFACE_PUB" as
/* $Header: csipcoib.pls 120.1 2005/08/10 17:33 srramakr noship $ */

/*-----------------------------------------------------------*/
/* procedure name: Execute_Open_Interface                    */
/* description :   procedure used to capture                 */
/*                 counter readings from the Open Interface  */
/*-----------------------------------------------------------*/

-- Process_status    E  =>  Error
-- Process_Status    R  =>  Ready
-- Process_Status    P  =>  Success
--
PROCEDURE Execute_Open_Interface
 (
     errbuf                  OUT NOCOPY VARCHAR2
    ,retcode                 OUT NOCOPY NUMBER
    ,p_batch_name            IN         VARCHAR2
    ,p_src_txn_from_date     IN         DATE
    ,p_src_txn_to_date       IN         DATE
    ,p_purge_processed_recs  IN         VARCHAR2
    ,p_reprocess_option      IN         VARCHAR2
 ) IS
   --
   CURSOR PURGE_CUR is
   SELECT counter_interface_id
   FROM CSI_CTR_READINGS_INTERFACE
   WHERE process_status = 'P';

   TYPE NumTabType IS VARRAY(10000) OF NUMBER;
   counter_intf_id_del      NumTabType;
   MAX_BUFFER_SIZE          NUMBER := 9999;
   --
   CURSOR CTR_READINGS_CUR IS
   SELECT
	  COUNTER_INTERFACE_ID
	 ,BATCH_NAME
	 ,SOURCE_TRANSACTION_DATE
	 ,PROCESS_STATUS
	 ,ERROR_TEXT
	 ,COUNTER_VALUE_ID
	 ,COUNTER_ID
	 ,NVL(VALUE_TIMESTAMP,SYSDATE) VALUE_TIMESTAMP
	 ,COUNTER_READING
	 ,RESET_MODE
	 ,RESET_REASON
	 ,ADJUSTMENT_TYPE
	 ,ADJUSTMENT_READING
	 ,LAST_UPDATE_DATE
	 ,LAST_UPDATED_BY
	 ,CREATION_DATE
	 ,CREATED_BY
	 ,LAST_UPDATE_LOGIN
	 ,ATTRIBUTE1
	 ,ATTRIBUTE2
	 ,ATTRIBUTE3
	 ,ATTRIBUTE4
	 ,ATTRIBUTE5
	 ,ATTRIBUTE6
	 ,ATTRIBUTE7
	 ,ATTRIBUTE8
	 ,ATTRIBUTE9
	 ,ATTRIBUTE10
	 ,ATTRIBUTE11
	 ,ATTRIBUTE12
	 ,ATTRIBUTE13
	 ,ATTRIBUTE14
	 ,ATTRIBUTE15
	 ,ATTRIBUTE16
	 ,ATTRIBUTE17
	 ,ATTRIBUTE18
	 ,ATTRIBUTE19
	 ,ATTRIBUTE20
	 ,ATTRIBUTE21
	 ,ATTRIBUTE22
	 ,ATTRIBUTE23
	 ,ATTRIBUTE24
	 ,ATTRIBUTE25
	 ,ATTRIBUTE26
	 ,ATTRIBUTE27
	 ,ATTRIBUTE28
	 ,ATTRIBUTE29
	 ,ATTRIBUTE30
	 ,ATTRIBUTE_CATEGORY
	 ,COMMENTS
	 ,SOURCE_TRANSACTION_TYPE_ID
	 ,SOURCE_TRANSACTION_ID
	 ,SOURCE_CODE
	 ,SOURCE_LINE_ID
	 ,AUTOMATIC_ROLLOVER_FLAG
	 ,INCLUDE_TARGET_RESETS
	 ,RESET_COUNTER_READING
         ,OBJECT_VERSION_NUMBER
         ,DISABLED_FLAG
         ,COUNTER_NAME
   FROM   CSI_CTR_READINGS_INTERFACE
   WHERE batch_name = p_batch_name
   AND   process_Status = 'R'
   AND   source_transaction_date between p_src_txn_from_date and p_src_txn_to_date
   ORDER BY VALUE_TIMESTAMP asc, COUNTER_ID asc;
   --
   --
   TYPE NTabType IS VARRAY(1000) OF NUMBER;
   TYPE V1TabType IS VARRAY(1000) OF VARCHAR2(1);
   TYPE V30TabType IS VARRAY(1000) OF VARCHAR2(30);
   TYPE V50TabType IS VARRAY(1000) OF VARCHAR2(50);
   TYPE V150TabType IS VARRAY(1000) OF VARCHAR2(150);
   TYPE V240TabType IS VARRAY(1000) OF VARCHAR2(240);
   TYPE V255TabType IS VARRAY(1000) OF VARCHAR2(255);
   TYPE V2000TabType IS VARRAY(1000) OF VARCHAR2(2000);
   TYPE DTabType IS VARRAY(1000) OF DATE;
   --
   l_COUNTER_INTERFACE_ID_mig         NTabType;
   l_BATCH_NAME_mig                   V30TabType;
   l_SOURCE_TRANSACTION_DATE_mig      DTabType;
   l_PROCESS_STATUS_mig               V1TabType;
   l_ERROR_TEXT_mig                   V240TabType;
   l_COUNTER_VALUE_ID_mig             NTabType;
   l_COUNTER_ID_mig                   NTabType;
   l_VALUE_TIMESTAMP_mig              DTabType;
   l_COUNTER_READING_mig              NTabType;
   l_RESET_MODE_mig                   V30TabType;
   l_RESET_REASON_mig                 V255TabType;
   l_ADJUSTMENT_TYPE_mig              V30TabType;
   l_ADJUSTMENT_READING_mig           NTabType;
   l_LAST_UPDATE_DATE_mig             DTabType;
   l_LAST_UPDATED_BY_mig              NTabType;
   l_CREATION_DATE_mig                DTabType;
   l_CREATED_BY_mig                   NTabType;
   l_LAST_UPDATE_LOGIN_mig            NTabType;
   l_ATTRIBUTE1_mig                   V150TabType;
   l_ATTRIBUTE2_mig                   V150TabType;
   l_ATTRIBUTE3_mig                   V150TabType;
   l_ATTRIBUTE4_mig                   V150TabType;
   l_ATTRIBUTE5_mig                   V150TabType;
   l_ATTRIBUTE6_mig                   V150TabType;
   l_ATTRIBUTE7_mig                   V150TabType;
   l_ATTRIBUTE8_mig                   V150TabType;
   l_ATTRIBUTE9_mig                   V150TabType;
   l_ATTRIBUTE10_mig                  V150TabType;
   l_ATTRIBUTE11_mig                  V150TabType;
   l_ATTRIBUTE12_mig                  V150TabType;
   l_ATTRIBUTE13_mig                  V150TabType;
   l_ATTRIBUTE14_mig                  V150TabType;
   l_ATTRIBUTE15_mig                  V150TabType;
   l_ATTRIBUTE16_mig                  V150TabType;
   l_ATTRIBUTE17_mig                  V150TabType;
   l_ATTRIBUTE18_mig                  V150TabType;
   l_ATTRIBUTE19_mig                  V150TabType;
   l_ATTRIBUTE20_mig                  V150TabType;
   l_ATTRIBUTE21_mig                  V150TabType;
   l_ATTRIBUTE22_mig                  V150TabType;
   l_ATTRIBUTE23_mig                  V150TabType;
   l_ATTRIBUTE24_mig                  V150TabType;
   l_ATTRIBUTE25_mig                  V150TabType;
   l_ATTRIBUTE26_mig                  V150TabType;
   l_ATTRIBUTE27_mig                  V150TabType;
   l_ATTRIBUTE28_mig                  V150TabType;
   l_ATTRIBUTE29_mig                  V150TabType;
   l_ATTRIBUTE30_mig                  V150TabType;
   l_ATTRIBUTE_CATEGORY_mig           V30TabType;
   l_COMMENTS_mig                     V2000TabType;
   l_SRC_TRANSACTION_TYPE_ID_mig      NTabType;
   l_SRC_TRANSACTION_ID_mig           NTabType;
   l_SOURCE_CODE_mig                  V30TabType;
   l_SOURCE_LINE_ID_mig               NTabType;
   l_AUTOMATIC_ROLLOVER_FLAG_mig      V1TabType;
   l_INCLUDE_TARGET_RESETS_mig        V1TabType;
   l_RESET_COUNTER_READING_mig        NTabType;
   l_OBJECT_VERSION_NUMBER_mig        NTabType;
   l_DISABLED_FLAG_mig                V1TabType;
   l_COUNTER_NAME_mig                 V50TabType;
   --
   MAX_OI_BUFFER_SIZE                 NUMBER := 1000;
   --
   l_txn_rec                          csi_datastructures_pub.transaction_rec;
   l_temp_txn_rec                     csi_datastructures_pub.transaction_rec;
   l_ctr_rdg_rec                      csi_ctr_datastructures_pub.counter_readings_rec;
   l_derive_ctr_rec                   csi_ctr_datastructures_pub.counter_readings_rec;
   l_temp_ctr_rdg_rec                 csi_ctr_datastructures_pub.counter_readings_rec;
   --
   l_dflt_ctr_prop_rec                csi_ctr_datastructures_pub.ctr_property_readings_rec;
   l_ctr_prop_rdg_rec                 csi_ctr_datastructures_pub.ctr_property_readings_rec;
   l_temp_ctr_prop_rec                csi_ctr_datastructures_pub.ctr_property_readings_rec;
   --
   l_reset_only                       VARCHAR2(1);
   --
   TYPE SRC_TXN_REC IS RECORD
     ( src_txn_id      NUMBER,
       src_txn_type_id NUMBER,
       value_timestamp DATE,
       transaction_id  NUMBER
     );
   TYPE SRC_TXN_TBL IS TABLE OF SRC_TXN_REC INDEX BY BINARY_INTEGER;
   --
   l_src_txn_tbl       SRC_TXN_TBL;
   l_src_txn_count     NUMBER := 0;
   l_exists            VARCHAR2(1);
   --
   CURSOR PROP_RDG_CUR(p_ctr_intf_id IN NUMBER) IS
   SELECT *
   FROM CSI_CTR_READ_PROP_INTERFACE
   WHERE counter_interface_id = p_ctr_intf_id;
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
   x_msg_data          VARCHAR2(2000);
   l_msg_index         NUMBER;
   l_msg_count         NUMBER;
   x_msg_count         NUMBER;
   x_return_status     VARCHAR2(1);
   --
   Skip_Error          EXCEPTION;
   Process_Next        EXCEPTION;
BEGIN
   IF NVL(p_reprocess_option,'SELECTED') = 'ALL' THEN
      UPDATE CSI_CTR_READINGS_INTERFACE cri
      SET process_status = 'R'
      WHERE cri.batch_name = p_batch_name
      AND   cri.process_Status = 'E'
      AND   cri.source_transaction_date between p_src_txn_from_date and p_src_txn_to_date;
      COMMIT;
   END IF;
   --
   IF NVL(p_purge_processed_recs,'N') = 'Y' THEN
      OPEN PURGE_CUR;
      LOOP
         FETCH PURGE_CUR BULK COLLECT INTO
         counter_intf_id_del
         LIMIT MAX_BUFFER_SIZE;
         --
         FORALL i1 IN 1 .. counter_intf_id_del.COUNT
         DELETE FROM CSI_CTR_READINGS_INTERFACE
         WHERE counter_interface_id = counter_intf_id_del(i1);
         --
         FORALL i1 IN 1 .. counter_intf_id_del.COUNT
         DELETE FROM CSI_CTR_READ_PROP_INTERFACE
         WHERE counter_interface_id = counter_intf_id_del(i1);
         --
         COMMIT;
         EXIT WHEN PURGE_CUR%NOTFOUND;
      END LOOP;
      COMMIT;
      CLOSE PURGE_CUR;
   END IF;
   --
   UPDATE CSI_CTR_READINGS_INTERFACE cri
   SET cri.counter_id = (select ccv.counter_id from CSI_COUNTERS_VL ccv
                         where ccv.name = cri.counter_name)
   WHERE cri.counter_id IS NULL
   AND   cri.counter_name IS NOT NULL;
   --
   COMMIT;
   --
   l_src_txn_tbl.DELETE;
   l_src_txn_count := 0;
   --
   OPEN CTR_READINGS_CUR;
   LOOP
      FETCH CTR_READINGS_CUR BULK COLLECT INTO
      l_COUNTER_INTERFACE_ID_mig
     ,l_BATCH_NAME_mig
     ,l_SOURCE_TRANSACTION_DATE_mig
     ,l_PROCESS_STATUS_mig
     ,l_ERROR_TEXT_mig
     ,l_COUNTER_VALUE_ID_mig
     ,l_COUNTER_ID_mig
     ,l_VALUE_TIMESTAMP_mig
     ,l_COUNTER_READING_mig
     ,l_RESET_MODE_mig
     ,l_RESET_REASON_mig
     ,l_ADJUSTMENT_TYPE_mig
     ,l_ADJUSTMENT_READING_mig
     ,l_LAST_UPDATE_DATE_mig
     ,l_LAST_UPDATED_BY_mig
     ,l_CREATION_DATE_mig
     ,l_CREATED_BY_mig
     ,l_LAST_UPDATE_LOGIN_mig
     ,l_ATTRIBUTE1_mig
     ,l_ATTRIBUTE2_mig
     ,l_ATTRIBUTE3_mig
     ,l_ATTRIBUTE4_mig
     ,l_ATTRIBUTE5_mig
     ,l_ATTRIBUTE6_mig
     ,l_ATTRIBUTE7_mig
     ,l_ATTRIBUTE8_mig
     ,l_ATTRIBUTE9_mig
     ,l_ATTRIBUTE10_mig
     ,l_ATTRIBUTE11_mig
     ,l_ATTRIBUTE12_mig
     ,l_ATTRIBUTE13_mig
     ,l_ATTRIBUTE14_mig
     ,l_ATTRIBUTE15_mig
     ,l_ATTRIBUTE16_mig
     ,l_ATTRIBUTE17_mig
     ,l_ATTRIBUTE18_mig
     ,l_ATTRIBUTE19_mig
     ,l_ATTRIBUTE20_mig
     ,l_ATTRIBUTE21_mig
     ,l_ATTRIBUTE22_mig
     ,l_ATTRIBUTE23_mig
     ,l_ATTRIBUTE24_mig
     ,l_ATTRIBUTE25_mig
     ,l_ATTRIBUTE26_mig
     ,l_ATTRIBUTE27_mig
     ,l_ATTRIBUTE28_mig
     ,l_ATTRIBUTE29_mig
     ,l_ATTRIBUTE30_mig
     ,l_ATTRIBUTE_CATEGORY_mig
     ,l_COMMENTS_mig
     ,l_SRC_TRANSACTION_TYPE_ID_mig
     ,l_SRC_TRANSACTION_ID_mig
     ,l_SOURCE_CODE_mig
     ,l_SOURCE_LINE_ID_mig
     ,l_AUTOMATIC_ROLLOVER_FLAG_mig
     ,l_INCLUDE_TARGET_RESETS_mig
     ,l_RESET_COUNTER_READING_mig
     ,l_OBJECT_VERSION_NUMBER_mig
     ,l_DISABLED_FLAG_mig
     ,l_COUNTER_NAME_mig
      LIMIT MAX_OI_BUFFER_SIZE;
      --
      fnd_file.put_line(fnd_file.log,'Record count is : '||to_char(l_counter_interface_id_mig.count));
      FOR j IN 1 .. l_counter_interface_id_mig.count LOOP
         Begin
            SAVEPOINT Execute_Open_Interface;
            --
            l_ERROR_TEXT_mig(j) := NULL;
            l_txn_rec := l_temp_txn_rec;
            l_ctr_rdg_rec := l_temp_ctr_rdg_rec;
            --
            -- Build the Counter Readings Record to Call Private API
            --
	    l_ctr_rdg_rec.counter_value_id   :=   l_COUNTER_VALUE_ID_mig(j);
	    l_ctr_rdg_rec.counter_id         :=   l_COUNTER_ID_mig(j);
	    l_ctr_rdg_rec.value_timestamp    :=   l_VALUE_TIMESTAMP_mig(j);
	    l_ctr_rdg_rec.counter_reading    :=   l_COUNTER_READING_mig(j);
	    l_ctr_rdg_rec.reset_mode         :=   l_RESET_MODE_mig(j);
	    l_ctr_rdg_rec.reset_reason       :=   l_RESET_REASON_mig(j);
	    l_ctr_rdg_rec.adjustment_type    :=   l_ADJUSTMENT_TYPE_mig(j);
	    l_ctr_rdg_rec.adjustment_reading :=   l_ADJUSTMENT_READING_mig(j);
	    l_ctr_rdg_rec.attribute1         :=   l_ATTRIBUTE1_mig(j);
	    l_ctr_rdg_rec.attribute2         :=   l_ATTRIBUTE2_mig(j);
	    l_ctr_rdg_rec.attribute3         :=   l_ATTRIBUTE3_mig(j);
	    l_ctr_rdg_rec.attribute4         :=   l_ATTRIBUTE4_mig(j);
	    l_ctr_rdg_rec.attribute5         :=   l_ATTRIBUTE5_mig(j);
	    l_ctr_rdg_rec.attribute6         :=   l_ATTRIBUTE6_mig(j);
	    l_ctr_rdg_rec.attribute7         :=   l_ATTRIBUTE7_mig(j);
	    l_ctr_rdg_rec.attribute8         :=   l_ATTRIBUTE8_mig(j);
	    l_ctr_rdg_rec.attribute9         :=   l_ATTRIBUTE9_mig(j);
	    l_ctr_rdg_rec.attribute10        :=   l_ATTRIBUTE10_mig(j);
	    l_ctr_rdg_rec.attribute11        :=   l_ATTRIBUTE11_mig(j);
	    l_ctr_rdg_rec.attribute12        :=   l_ATTRIBUTE12_mig(j);
	    l_ctr_rdg_rec.attribute13        :=   l_ATTRIBUTE13_mig(j);
	    l_ctr_rdg_rec.attribute14        :=   l_ATTRIBUTE14_mig(j);
	    l_ctr_rdg_rec.attribute15        :=   l_ATTRIBUTE15_mig(j);
	    l_ctr_rdg_rec.attribute16        :=   l_ATTRIBUTE16_mig(j);
	    l_ctr_rdg_rec.attribute17        :=   l_ATTRIBUTE17_mig(j);
	    l_ctr_rdg_rec.attribute18        :=   l_ATTRIBUTE18_mig(j);
	    l_ctr_rdg_rec.attribute19        :=   l_ATTRIBUTE19_mig(j);
	    l_ctr_rdg_rec.attribute20        :=   l_ATTRIBUTE20_mig(j);
	    l_ctr_rdg_rec.attribute21        :=   l_ATTRIBUTE21_mig(j);
	    l_ctr_rdg_rec.attribute22        :=   l_ATTRIBUTE22_mig(j);
	    l_ctr_rdg_rec.attribute23        :=   l_ATTRIBUTE23_mig(j);
	    l_ctr_rdg_rec.attribute24        :=   l_ATTRIBUTE24_mig(j);
	    l_ctr_rdg_rec.attribute25        :=   l_ATTRIBUTE25_mig(j);
	    l_ctr_rdg_rec.attribute26        :=   l_ATTRIBUTE26_mig(j);
	    l_ctr_rdg_rec.attribute27        :=   l_ATTRIBUTE27_mig(j);
	    l_ctr_rdg_rec.attribute28        :=   l_ATTRIBUTE28_mig(j);
	    l_ctr_rdg_rec.attribute29        :=   l_ATTRIBUTE29_mig(j);
	    l_ctr_rdg_rec.attribute30        :=   l_ATTRIBUTE30_mig(j);
	    l_ctr_rdg_rec.attribute_category :=   l_ATTRIBUTE_CATEGORY_mig(j);
	    l_ctr_rdg_rec.comments           :=   l_COMMENTS_mig(j);
	    l_ctr_rdg_rec.source_code      :=   l_SOURCE_CODE_mig(j);
	    l_ctr_rdg_rec.source_line_id   :=   l_SOURCE_LINE_ID_mig(j);
	    l_ctr_rdg_rec.automatic_rollover_flag    := l_AUTOMATIC_ROLLOVER_FLAG_mig(j);
	    l_ctr_rdg_rec.include_target_resets      := l_INCLUDE_TARGET_RESETS_mig(j);
	    l_ctr_rdg_rec.reset_counter_reading      := l_RESET_COUNTER_READING_mig(j);
	    l_ctr_rdg_rec.object_version_number      := l_OBJECT_VERSION_NUMBER_mig(j);
	    l_ctr_rdg_rec.disabled_flag              :=   l_DISABLED_FLAG_mig(j);
            --
            l_txn_rec.transaction_type_id := l_SRC_TRANSACTION_TYPE_ID_mig(j);
            l_txn_rec.source_header_ref_id := l_SRC_TRANSACTION_ID_mig(j);
            l_txn_rec.source_transaction_date := l_SOURCE_TRANSACTION_DATE_mig(j);
            --
            IF NVL(l_DISABLED_FLAG_mig(j),'N') = 'Y' THEN
	       Csi_Counter_Readings_Pvt.Update_Counter_Reading
		  (
		    p_api_version           => 1.0
		   ,p_commit                => fnd_api.g_false
		   ,p_init_msg_list         => fnd_api.g_true
		   ,p_validation_level      => fnd_api.g_valid_level_full
		   ,p_ctr_rdg_rec           => l_ctr_rdg_rec
		   ,x_return_status         => x_return_status
		   ,x_msg_count             => x_msg_count
		   ,x_msg_data              => x_msg_data
		  );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
                  l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
		  RAISE Skip_Error;
               ELSE
                  l_PROCESS_STATUS_mig(j) := 'E';
                  RAISE Process_Next; -- Process the next record
	       END IF;
            END IF; -- Disabled_flag check
            -- Check the existence of Transaction
            l_exists := 'N';
            IF l_src_txn_tbl.count > 0 THEN
               FOR src_txn IN l_src_txn_tbl.FIRST .. l_src_txn_tbl.LAST LOOP
                  IF l_src_txn_tbl(src_txn).src_txn_id = l_SRC_TRANSACTION_ID_mig(j) AND
                     l_src_txn_tbl(src_txn).src_txn_type_id = l_SRC_TRANSACTION_TYPE_ID_mig(j) AND
                     l_src_txn_tbl(src_txn).value_timestamp = l_VALUE_TIMESTAMP_mig(j) THEN
                     l_exists := 'Y';
                     l_txn_rec.transaction_id := l_src_txn_tbl(src_txn).transaction_id;
                     exit;
                  END IF;
               END LOOP;
            END IF;
            --
            IF l_exists = 'N' THEN
	       Csi_Counter_Readings_Pvt.Create_Reading_Transaction
		  ( p_api_version           =>  1.0
		   ,p_commit                =>  fnd_api.g_false
		   ,p_init_msg_list         =>  fnd_api.g_true
		   ,p_validation_level      =>  fnd_api.g_valid_level_full
		   ,p_txn_rec               =>  l_txn_rec
		   ,x_return_status         =>  x_return_status
		   ,x_msg_count             =>  x_msg_count
		   ,x_msg_data              =>  x_msg_data
		  );
               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
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
			 l_msg_index := l_msg_index + 1;
			 l_msg_count := l_msg_count - 1;
		  END LOOP;
                  l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
		  RAISE Skip_Error;
	       END IF;
            END IF; -- Transaction exists check
            --
            --
            -- Check whether this is Reset only reading.
            -- This will decide whether to compute Derive counters or not
            --
            IF NVL(l_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
               NVL(l_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) = 'SOFT' THEN
               l_reset_only := 'T';
            ELSE
               l_reset_only := 'F';
            END IF;
            --
            -- Calling Capture_Counter_Reading PVT
	    Csi_Counter_Readings_Pvt.Capture_Counter_Reading
	       (
		 p_api_version           => 1.0
		,p_commit                => fnd_api.g_false
		,p_init_msg_list         => fnd_api.g_true
		,p_validation_level      => fnd_api.g_valid_level_full
                ,p_txn_rec               => l_txn_rec
		,p_ctr_rdg_rec           => l_ctr_rdg_rec
		,x_return_status         => x_return_status
		,x_msg_count             => x_msg_count
		,x_msg_data              => x_msg_data
	       );
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
               l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
	       RAISE Skip_Error;
            ELSE
               l_COUNTER_VALUE_ID_mig(j) := l_ctr_rdg_rec.counter_value_id;
	    END IF;
            --
            FOR prop_rec IN PROP_RDG_CUR(l_COUNTER_INTERFACE_ID_mig(j)) LOOP
               l_ctr_prop_rdg_rec := l_temp_ctr_prop_rec;
               --
	       l_ctr_prop_rdg_rec.counter_prop_value_id := prop_rec.counter_prop_value_id;
	       l_ctr_prop_rdg_rec.counter_value_id      := l_ctr_rdg_rec.counter_value_id;
	       l_ctr_prop_rdg_rec.counter_property_id   := prop_rec.counter_property_id;
	       l_ctr_prop_rdg_rec.property_value        := prop_rec.property_value;
	       l_ctr_prop_rdg_rec.value_timestamp       := l_ctr_rdg_rec.value_timestamp;--prop_rec.value_timestamp;
	       l_ctr_prop_rdg_rec.attribute1            := prop_rec.attribute1;
	       l_ctr_prop_rdg_rec.attribute2            := prop_rec.attribute2;
	       l_ctr_prop_rdg_rec.attribute3            := prop_rec.attribute3;
	       l_ctr_prop_rdg_rec.attribute4            := prop_rec.attribute4;
	       l_ctr_prop_rdg_rec.attribute5            := prop_rec.attribute5;
	       l_ctr_prop_rdg_rec.attribute6            := prop_rec.attribute6;
	       l_ctr_prop_rdg_rec.attribute7            := prop_rec.attribute7;
	       l_ctr_prop_rdg_rec.attribute8            := prop_rec.attribute8;
	       l_ctr_prop_rdg_rec.attribute9            := prop_rec.attribute9;
	       l_ctr_prop_rdg_rec.attribute1            := prop_rec.attribute10;
	       l_ctr_prop_rdg_rec.attribute1            := prop_rec.attribute11;
	       l_ctr_prop_rdg_rec.attribute12           := prop_rec.attribute12;
	       l_ctr_prop_rdg_rec.attribute13           := prop_rec.attribute13;
	       l_ctr_prop_rdg_rec.attribute14           := prop_rec.attribute14;
	       l_ctr_prop_rdg_rec.attribute15           := prop_rec.attribute15;
	       l_ctr_prop_rdg_rec.attribute_category    := prop_rec.attribute_category;
               --
	       Csi_Counter_Readings_Pvt.Capture_Ctr_Property_Reading
		  (
		    p_api_version           => 1.0
		   ,p_commit                => fnd_api.g_false
		   ,p_init_msg_list         => fnd_api.g_true
		   ,p_validation_level      => fnd_api.g_valid_level_full
		   ,p_ctr_prop_rdg_rec      => l_ctr_prop_rdg_rec
		   ,x_return_status         => x_return_status
		   ,x_msg_count             => x_msg_count
		   ,x_msg_data              => x_msg_data
		);
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
                  l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
	          RAISE Skip_Error;
	       END IF;
            END LOOP; -- End of Property interface loop
            --
            -- Capture Default Property Reading
            FOR dflt_rec IN DFLT_PROP_RDG(l_ctr_rdg_rec.counter_id,l_ctr_rdg_rec.counter_value_id)
            LOOP
               l_dflt_ctr_prop_rec := l_temp_ctr_prop_rec; -- Initialize
               --
               l_dflt_ctr_prop_rec.counter_property_id := dflt_rec.counter_property_id;
               l_dflt_ctr_prop_rec.property_value := dflt_rec.default_value;
               l_dflt_ctr_prop_rec.value_timestamp := l_ctr_rdg_rec.value_timestamp;
               l_dflt_ctr_prop_rec.counter_value_id := l_ctr_rdg_rec.counter_value_id;
               --
	       Csi_Counter_Readings_Pvt.Capture_Ctr_Property_Reading
		  (
		    p_api_version           => 1.0
		   ,p_commit                => fnd_api.g_false
		   ,p_init_msg_list         => fnd_api.g_true
		   ,p_validation_level      => fnd_api.g_valid_level_full
		   ,p_ctr_prop_rdg_rec      => l_dflt_ctr_prop_rec
		   ,x_return_status         => x_return_status
		   ,x_msg_count             => x_msg_count
		   ,x_msg_data              => x_msg_data
		);
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
                  l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
	          RAISE Skip_Error;
	       END IF;
            END LOOP; -- Default Property Loop
            --
            -- Call compute Derive filters only if the current capture is not a pure reset.
            -- This is applicable for the Later readings cursor as Reset should be the last reading.
            IF l_reset_only = 'F' THEN
	       l_derive_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_derive_ctr_rec.counter_value_id := l_ctr_rdg_rec.counter_value_id;
	       l_derive_ctr_rec.counter_id := l_ctr_rdg_rec.counter_id;
	       l_derive_ctr_rec.value_timestamp := l_ctr_rdg_rec.value_timestamp;
	       l_derive_ctr_rec.source_code := l_ctr_rdg_rec.source_code;
	       l_derive_ctr_rec.source_line_id := l_ctr_rdg_rec.source_line_id;
	       --
	       -- Call Compute Derive Counters
	       Csi_Counter_Readings_Pvt.Compute_Derive_Counters
		  (
		    p_api_version           => 1.0
		   ,p_commit                => fnd_api.g_false
		   ,p_init_msg_list         => fnd_api.g_true
		   ,p_validation_level      => fnd_api.g_valid_level_full
		   ,p_txn_rec               => l_txn_rec
		   ,p_ctr_rdg_rec           => l_derive_ctr_rec
		   ,p_mode                  => 'CREATE'
		   ,x_return_status         => x_return_status
		   ,x_msg_count             => x_msg_count
		   ,x_msg_data              => x_msg_data
		 );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
                  l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
		  RAISE Skip_error;
	       END IF;
	       --
	       -- Re-compute Derive comunters for the Later Readings
	       -- No need for SOFT reset as we would not have created it before.
	       FOR later_rdg IN LATER_READINGS_CUR(l_ctr_rdg_rec.counter_id,
                                                   l_ctr_rdg_rec.value_timestamp)
	       LOOP
		  IF NVL(later_rdg.reset_mode,'$#$') <> 'SOFT' THEN
		     l_derive_ctr_rec := l_temp_ctr_rdg_rec;
		     --
		     l_derive_ctr_rec.counter_value_id := later_rdg.counter_value_id;
		     l_derive_ctr_rec.counter_id := l_ctr_rdg_rec.counter_id;
		     l_derive_ctr_rec.value_timestamp := later_rdg.value_timestamp;
		     --
		     Csi_Counter_Readings_Pvt.Compute_Derive_Counters
			(
			  p_api_version           => 1.0
			 ,p_commit                => fnd_api.g_false
			 ,p_init_msg_list         => fnd_api.g_true
			 ,p_validation_level      => fnd_api.g_valid_level_full
			 ,p_txn_rec               => l_txn_rec
			 ,p_ctr_rdg_rec           => l_derive_ctr_rec
			 ,p_mode                  => 'UPDATE'
			 ,x_return_status         => x_return_status
			 ,x_msg_count             => x_msg_count
			 ,x_msg_data              => x_msg_data
		       );
		     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			l_msg_index := 1;
			l_msg_count := x_msg_count;
			WHILE l_msg_count > 0 LOOP
			   x_msg_data := FND_MSG_PUB.GET
			   (  l_msg_index,
			      FND_API.G_FALSE
			   );
			   l_msg_index := l_msg_index + 1;
			   l_msg_count := l_msg_count - 1;
			END LOOP;
                        l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
			RAISE Skip_error;
		     END IF;
		  END IF; -- End of Derive counter call check
	       END LOOP;
	    END IF; -- l_reset_only check
            --
            -- Call Compute Formula
	    Csi_Counter_Readings_Pvt.Compute_Formula_Counters
	       (
		 p_api_version           => 1.0
		,p_commit                => fnd_api.g_false
		,p_init_msg_list         => fnd_api.g_true
		,p_validation_level      => fnd_api.g_valid_level_full
		,p_txn_rec               => l_txn_rec
		,p_ctr_rdg_rec           => l_ctr_rdg_rec
		,x_return_status         => x_return_status
		,x_msg_count             => x_msg_count
		,x_msg_data              => x_msg_data
	      );
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
		  (  l_msg_index,
		     FND_API.G_FALSE
		  );
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
               l_ERROR_TEXT_mig(j) := substr(x_msg_data,1,2000);
	       RAISE Skip_Error;
	    END IF;
            --
            -- If Success then cache the Transaction info
            l_src_txn_count := l_src_txn_count + 1;
            l_src_txn_tbl(l_src_txn_count).src_txn_id := l_SRC_TRANSACTION_ID_mig(j);
            l_src_txn_tbl(l_src_txn_count).src_txn_type_id := l_SRC_TRANSACTION_TYPE_ID_mig(j);
            l_src_txn_tbl(l_src_txn_count).value_timestamp := l_VALUE_TIMESTAMP_mig(j);
            l_src_txn_tbl(l_src_txn_count).transaction_id := l_txn_rec.transaction_id;
            --
            l_PROCESS_STATUS_mig(j) := 'P';
         Exception
            When Process_next then
               null;
            When Skip_Error then
               l_PROCESS_STATUS_mig(j) := 'E';
               Rollback to Execute_Open_Interface;
         End;
      END LOOP; -- l_counter_interface_id_mig.count Loop
      --
      -- Bulk Update error text,process_status and counter_value_id
      FORALL j IN 1 .. l_counter_interface_id_mig.count
         UPDATE CSI_CTR_READINGS_INTERFACE
         SET process_status = l_PROCESS_STATUS_mig(j),
             counter_value_id = l_COUNTER_VALUE_ID_mig(j),
             error_text = l_ERROR_TEXT_mig(j)
         WHERE counter_interface_id = l_counter_interface_id_mig(j);
      --
      COMMIT;
      EXIT WHEN CTR_READINGS_CUR%NOTFOUND;
   END LOOP;
   COMMIT;
   CLOSE CTR_READINGS_CUR;
END Execute_Open_Interface;
--
END CSI_CTR_INTERFACE_PUB;

/
