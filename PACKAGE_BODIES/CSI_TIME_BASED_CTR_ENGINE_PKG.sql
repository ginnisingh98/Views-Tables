--------------------------------------------------------
--  DDL for Package Body CSI_TIME_BASED_CTR_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TIME_BASED_CTR_ENGINE_PKG" AS
/* $Header: csictimb.pls 120.3.12010000.8 2010/02/19 20:58:57 devijay ship $ */

--
/*******************************
 * Private program units *
 *******************************/

PROCEDURE Increment_Reading
(
   p_capture_date   IN  DATE,
   p_ctr_id	    IN  NUMBER,
   p_ctr_rdg	    IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER
) IS

   l_txn_rec                 csi_datastructures_pub.transaction_rec;
   l_ctr_rdg_rec             csi_ctr_datastructures_pub.counter_readings_rec;
   l_msg_index               NUMBER;
   l_msg_count               NUMBER;
   --
BEGIN
   SAVEPOINT Increment_Reading;
   --
   fnd_file.put_line(fnd_file.log, 'Inside Increment_Reading...');
   fnd_file.put_line(fnd_file.log, 'p_ctr_id :'||p_ctr_id);
   fnd_file.put_line(fnd_file.log, 'p_ctr_rdg :'||p_ctr_rdg);
   fnd_file.put_line(fnd_file.log, 'p_capture_date :'||to_char(p_capture_date,'DD-MON-YYYY HH24:MI:SS'));
   --
   l_txn_rec.source_transaction_date := sysdate;
   l_txn_rec.transaction_type_id := 89;
   l_txn_rec.source_header_ref_id := 0;
   --
   l_ctr_rdg_rec.counter_id := p_ctr_id;
   l_ctr_rdg_rec.value_timestamp := p_capture_date;
   l_ctr_rdg_rec.counter_reading := p_ctr_rdg;
   --
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
      fnd_file.put_line(fnd_file.log,'Error from Create_Reading_Transaction...');
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
	 fnd_file.put_line(fnd_file.log,'MESSAGE DATA = '||x_msg_data);
	 l_msg_index := l_msg_index + 1;
	 l_msg_count := l_msg_count - 1;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   fnd_file.put_line(fnd_file.log, 'Inserting Counter Reading...');
   select CSI_COUNTER_READINGS_S.nextval
   into l_ctr_rdg_rec.counter_value_id from dual;
   --
      CSI_COUNTER_READINGS_PKG.Insert_Row(
	  px_COUNTER_VALUE_ID         =>  l_ctr_rdg_rec.counter_value_id
	 ,p_COUNTER_ID                =>  l_ctr_rdg_rec.counter_id
	 ,p_VALUE_TIMESTAMP           =>  l_ctr_rdg_rec.value_timestamp
	 ,p_COUNTER_READING           =>  l_ctr_rdg_rec.counter_reading
	 ,p_RESET_MODE                =>  NULL
	 ,p_RESET_REASON              =>  NULL
	 ,p_ADJUSTMENT_TYPE           =>  NULL
	 ,p_ADJUSTMENT_READING        =>  NULL
	 ,p_OBJECT_VERSION_NUMBER     =>  1
	 ,p_LAST_UPDATE_DATE          =>  SYSDATE
	 ,p_LAST_UPDATED_BY           =>  fnd_global.user_id
	 ,p_CREATION_DATE             =>  SYSDATE
	 ,p_CREATED_BY                =>  fnd_global.user_id
	 ,p_LAST_UPDATE_LOGIN         =>  fnd_global.conc_login_id
	 ,p_ATTRIBUTE1                =>  NULL
	 ,p_ATTRIBUTE2                =>  NULL
	 ,p_ATTRIBUTE3                =>  NULL
	 ,p_ATTRIBUTE4                =>  NULL
	 ,p_ATTRIBUTE5                =>  NULL
	 ,p_ATTRIBUTE6                =>  NULL
	 ,p_ATTRIBUTE7                =>  NULL
	 ,p_ATTRIBUTE8                =>  NULL
	 ,p_ATTRIBUTE9                =>  NULL
	 ,p_ATTRIBUTE10               =>  NULL
	 ,p_ATTRIBUTE11               =>  NULL
	 ,p_ATTRIBUTE12               =>  NULL
	 ,p_ATTRIBUTE13               =>  NULL
	 ,p_ATTRIBUTE14               =>  NULL
	 ,p_ATTRIBUTE15               =>  NULL
	 ,p_ATTRIBUTE16               =>  NULL
	 ,p_ATTRIBUTE17               =>  NULL
	 ,p_ATTRIBUTE18               =>  NULL
	 ,p_ATTRIBUTE19               =>  NULL
	 ,p_ATTRIBUTE20               =>  NULL
	 ,p_ATTRIBUTE21               =>  NULL
	 ,p_ATTRIBUTE22               =>  NULL
	 ,p_ATTRIBUTE23               =>  NULL
	 ,p_ATTRIBUTE24               =>  NULL
	 ,p_ATTRIBUTE25               =>  NULL
	 ,p_ATTRIBUTE26               =>  NULL
	 ,p_ATTRIBUTE27               =>  NULL
	 ,p_ATTRIBUTE28               =>  NULL
	 ,p_ATTRIBUTE29               =>  NULL
	 ,p_ATTRIBUTE30               =>  NULL
	 ,p_ATTRIBUTE_CATEGORY        =>  NULL
	 ,p_MIGRATED_FLAG             =>  'N'
	 ,p_COMMENTS                  =>  NULL
	 ,p_LIFE_TO_DATE_READING      =>  l_ctr_rdg_rec.counter_reading
	 ,p_TRANSACTION_ID            =>  l_txn_rec.transaction_id
	 ,p_AUTOMATIC_ROLLOVER_FLAG   =>  NULL
	 ,p_INCLUDE_TARGET_RESETS     =>  NULL
	 ,p_SOURCE_COUNTER_VALUE_ID   =>  NULL
	 ,p_NET_READING               =>  l_ctr_rdg_rec.counter_reading
	 ,p_DISABLED_FLAG             =>  'N'
	 ,p_SOURCE_CODE               =>  NULL
	 ,p_SOURCE_LINE_ID            =>  NULL
	 ,p_INITIAL_READING_FLAG      =>  NULL
       );
      -- Added for FP Tracking bug 7390758 (base bug 7374316)
      CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
          p_api_version           =>  1.0
         ,p_commit                =>  fnd_api.g_false
         ,p_init_msg_list         =>  fnd_api.g_true
         ,p_validation_level      =>  fnd_api.g_valid_level_full
         ,p_counter_id            =>  l_ctr_rdg_rec.counter_id
         ,px_ctr_val_max_seq_no   =>  l_ctr_rdg_rec.counter_value_id
         ,x_return_status         =>  x_return_status
         ,x_msg_count             =>  x_msg_count
         ,x_msg_data              =>  x_msg_data
         );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        l_msg_index := 1;
        l_msg_count := x_msg_count;
	WHILE l_msg_count > 0 LOOP
          x_msg_data := FND_MSG_PUB.GET
            (l_msg_index,
            FND_API.G_FALSE
	    );
          csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
	  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	  l_msg_index := l_msg_index + 1;
	  l_msg_count := l_msg_count - 1;
        END LOOP;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
   -- End add for FP Tracking bug 7390758 (base bug 7374316)
   --
   fnd_file.put_line(fnd_file.log, 'Calling OKC Assembler Event...');
   OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble
      (  p_api_version        =>  1.0,
	 x_return_status      =>  x_return_status,
	 x_msg_count          =>  x_msg_count,
	 x_msg_data           =>  x_msg_data,
	 p_counter_id         =>  l_ctr_rdg_rec.counter_id
      );
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      fnd_file.put_line(fnd_file.log,'ERROR FROM OKC_CG_UPD_ASMBLR_PVT.Acn_Assemble API ');
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
	 x_msg_data := FND_MSG_PUB.GET
	 (  l_msg_index,
	    FND_API.G_FALSE
	 );
	 fnd_file.put_line(fnd_file.log,'MESSAGE DATA = '||x_msg_data);
	 l_msg_index := l_msg_index + 1;
	 l_msg_count := l_msg_count - 1;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Rollback To Increment_Reading;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Rollback To Increment_Reading;
      fnd_file.put_line(fnd_file.log,'Into when others error in Increment_Reading...');
      fnd_file.put_line(fnd_file.log,sqlerrm);
END Increment_Reading;
--

FUNCTION DOES_FORMULA_COUNTER_EXISTS
         (p_src_counter_id IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
   l_rel_type      VARCHAR2(30) := 'FORMULA';
BEGIN
   Begin
      select '1'
      into l_exists
      from dual
      where exists (select distinct object_counter_id
                     from csi_counter_relationships
                     where source_counter_id = p_src_counter_id
                     and   relationship_type_code = 'FORMULA'
                     and   nvl(active_end_date,(sysdate+1)) > sysdate
                     AND ROWNUM = 1);
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END DOES_FORMULA_COUNTER_EXISTS;


/*******************************
 * Public program units *
 *******************************/

--This is the main procedure that will be called as a conc program
PROCEDURE Capture_Readings
  (
     errbuf	OUT NOCOPY VARCHAR2,
     retcode	OUT NOCOPY NUMBER
  ) IS
   l_incr_rdg	   NUMBER;	--incremental reading
   l_new_rdg       NUMBER;	--incremental reading
   l_run_time	   DATE;
   l_conc_start_time DATE;
   l_ctr_rdg       NUMBER;
   l_ctr_value_id  NUMBER;
   l_timestamp     DATE;
   l_ctr_creation_date DATE;
   x_msg_data      VARCHAR2(2000);
   x_msg_count     NUMBER;
   x_return_status VARCHAR2(1);
   l_counter       NUMBER := 0;
   l_days          NUMBER;
   l_day_uom_code  VARCHAR2(30);
   l_hour_uom_code  VARCHAR2(30);
   l_ignore_time_component  VARCHAR2(30);
   l_formula_ctr_rec               csi_ctr_datastructures_pub.counter_readings_rec;
   l_txn_rec                       csi_datastructures_pub.transaction_rec;
   l_temp_txn_rec                       csi_datastructures_pub.transaction_rec;
   l_msg_index NUMBER;
   l_msg_count NUMBER;
   --
   CURSOR CTR_CUR IS
   SELECT counter_id,creation_date,uom_code
   FROM   CSI_COUNTERS_B ctr
   WHERE  counter_type = 'REGULAR'
   AND    nvl(end_date_active,(sysdate+1)) > sysdate
   AND    nvl(time_based_manual_entry, 'N') = 'N'
   AND    exists (select 'x'
                  from   MTL_UNITS_OF_MEASURE_VL uom
                  where  upper(uom.uom_class) = 'TIME'
                  and    uom.uom_code = ctr.uom_code);

  TYPE counter_array IS TABLE OF CTR_CUR%ROWTYPE;
  time_ctr_array counter_array;
 --
   CURSOR RDG_CUR(p_counter_id IN NUMBER) IS
   SELECT counter_value_id,counter_reading,value_timestamp
   FROM CSI_COUNTER_READINGS
   WHERE counter_id = p_counter_id
   AND   nvl(disabled_flag,'N') = 'N'
   ORDER BY value_timestamp desc;

BEGIN
   l_run_time := sysdate;
   l_conc_start_time := l_run_time;
   fnd_file.put_line(fnd_file.log, 'Start Execution : '|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
   --
   l_day_uom_code := FND_PROFILE.VALUE('DAY_UNIT_OF_MEASURE');
   l_hour_uom_code := FND_PROFILE.VALUE('HOUR_UNIT_OF_MEASURE');
   l_ignore_time_component := FND_PROFILE.VALUE('CSI_IGNORE_TIME_COMPONENT');
   --
   IF l_day_uom_code IS NULL THEN
      fnd_file.put_line(fnd_file.log,'DAY_UNIT_OF_MEASURE Profile Not Set..');
      errbuf := 'DAY_UNIT_OF_MEASURE Profile Not Set';
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --

   OPEN ctr_cur;
   LOOP
   FETCH ctr_cur BULK COLLECT INTO time_ctr_array LIMIT 1000;

   FOR i IN time_ctr_array.first..time_ctr_array.last
   loop
      fnd_file.put_line(fnd_file.log, '------------------------------------------------------');
     -- fnd_file.put_line(fnd_file.log, 'Fetched ctr-id '|| to_char(time_ctr_array(i).counter_id));

      -- Bug 9210555
      --
      -- If "CSI: Ignore Counter time component" profile is set to 'Y'
      -- then runtime will be truncated to ignore time component
      -- If "CSI: Ignore Counter time component" is Null or 'N'
      -- then time component and date/time calculation decimals are not
      -- ignored
      --
      -- Ignoring Time component is valid only for Day and Hour
      -- bases counters
      -- In case of Day based counter Hour/Minutes/Seconds will be truncated
      -- In case of Hour Based Counter Minutes/Seconds will be truncated

      IF (UPPER(time_ctr_array(i).uom_code) = l_day_uom_code)
         AND ( NVL(l_ignore_time_component,'N') = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Truncating time component from concurrent program start time');
        l_run_time := trunc(to_date(sysdate), 'DDD');
        l_ctr_creation_date := trunc(to_date(time_ctr_array(i).creation_date), 'DDD');
      ELSIF (UPPER(time_ctr_array(i).uom_code) = l_hour_uom_code)
         AND ( NVL(l_ignore_time_component,'N') = 'Y') THEN
        -- ER 9285073
        fnd_file.put_line(fnd_file.log, 'Truncating minutes/seconds component from concurrent program start time');
        l_run_time := trunc(l_conc_start_time, 'HH');
        l_ctr_creation_date := trunc(time_ctr_array(i).creation_date, 'HH');
      ELSE
        fnd_file.put_line(fnd_file.log, 'Retaining concurrent program start time');
        l_run_time := l_conc_start_time;
        l_ctr_creation_date := time_ctr_array(i).creation_date;
      END IF;

      -- End Bug 9210555
      --
      l_ctr_value_id := NULL;
      l_ctr_rdg := NULL;
      l_timestamp := NULL;
      --
      OPEN RDG_CUR(time_ctr_array(i).counter_id);
      FETCH RDG_CUR INTO l_ctr_value_id,l_ctr_rdg,l_timestamp;
      CLOSE RDG_CUR;
      --
      l_days := l_run_time - nvl(l_timestamp,time_ctr_array(i).creation_date);
      fnd_file.put_line(fnd_file.log, 'l_days '|| l_days);
      fnd_file.put_line(fnd_file.log, 'l_run_time'|| to_char(l_run_time, 'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, 'l_timestamp'|| to_char(l_timestamp, 'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, 'l_day_uom_code'|| to_char(l_day_uom_code));
      fnd_file.put_line(fnd_file.log, 'l_hour_uom_code'|| to_char(l_hour_uom_code));
      fnd_file.put_line(fnd_file.log, 'time_ctr_array(i).uom_code'|| to_char(time_ctr_array(i).uom_code));
      IF l_days = 0 THEN
         l_incr_rdg := 0;
      ELSE
         l_incr_rdg := oks_time_measures_pub.get_target_qty
                             ( p_start_date     =>  nvl(l_timestamp,time_ctr_array(i).creation_date),
                               p_source_qty     =>  l_days,
                               p_source_uom     =>  l_day_uom_code,
                               p_target_uom     =>  time_ctr_array(i).uom_code,
                               p_round_dec      =>  1
                             );
      END IF;
      --
      fnd_file.put_line(fnd_file.log, 'l_incr_rdg'|| to_char(l_incr_rdg));
      IF l_incr_rdg >= 1 THEN
         IF l_ctr_value_id IS NULL THEN
              -- This is the first rdg being captured
              l_new_rdg := l_incr_rdg;
           ELSE
              l_new_rdg := l_incr_rdg + l_ctr_rdg;
           END IF;
           --
           Increment_Reading
                    ( p_capture_date     =>  l_run_time,
                      p_ctr_id           =>  time_ctr_array(i).counter_id,
                      p_ctr_rdg          =>  l_new_rdg,
                      x_return_status    =>  x_return_status,
                      x_msg_data         =>  x_msg_data,
                      x_msg_count        =>  x_msg_count
                    );
           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

      -- Moving the END IF to the end of formulae counter update block
      -- END IF;
      --

      -- Bug 9283089
      -- Verify if formula counter exists for source counter id or not
      IF (DOES_FORMULA_COUNTER_EXISTS(time_ctr_array(i).counter_id)) THEN

        fnd_file.put_line(fnd_file.log, 'Formual Counter Updating');

        --
         -- Bug 9386676

         l_txn_rec := l_temp_txn_rec;
         l_txn_rec.source_transaction_date := sysdate;
         l_txn_rec.transaction_type_id := 89;
         l_txn_rec.source_header_ref_id := 0;

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
            fnd_file.put_line(fnd_file.log,'Error from Create_Reading_Transaction...');
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
           fnd_file.put_line(fnd_file.log,'MESSAGE DATA = '||x_msg_data);
           l_msg_index := l_msg_index + 1;
           l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
        -- End of bug 9386676

        l_formula_ctr_rec.counter_id := time_ctr_array(i).counter_id;

        -- Formula counter uses the same timestamp as used by source counter id
        -- If the run time was truncated due profile value setup
        -- the same run time is used for formula counter as well
        l_formula_ctr_rec.value_timestamp := l_run_time;

        --l_formula_ctr_rec.disabled_flag := 'Y';
        fnd_file.put_line(fnd_file.log, 'l_txn_rec.transaction_id - '|| l_txn_rec.transaction_id);
        fnd_file.put_line(fnd_file.log, 'l_formula_ctr_rec.value_timestamp - '||to_char(l_formula_ctr_rec.value_timestamp, 'DD-MON-YYYY HH24:MI:SS'));
        fnd_file.put_line(fnd_file.log, 'l_formula_ctr_rec.counter_id - '||l_formula_ctr_rec.counter_id);
        fnd_file.put_line(fnd_file.log, 'Calling Compute_Formula_Counters');

        CSI_COUNTER_READINGS_PVT.Compute_Formula_Counters
        (
          p_api_version           => 1.0
         ,p_commit                => FND_API.G_FALSE
         ,p_init_msg_list         => FND_API.G_TRUE
         ,p_validation_level      => fnd_api.g_valid_level_full
         ,p_txn_rec               => l_txn_rec
         ,p_ctr_rdg_rec           => l_formula_ctr_rec
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
       );
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            fnd_file.put_line(fnd_file.log, 'Error from Compute_Formula_Counters API');
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
               (  l_msg_index,
                  FND_API.G_FALSE
               );
               fnd_file.put_line(fnd_file.log, 'MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF; -- IS_FORMULA_COUNTER_EXISTS(time_ctr_array(i).counter_id)
      -- End Bug 9283089

      -- This END IF is common to increment reading and formula computation
      -- The formula computation is necessary only if source counter is updated
      END IF; -- l_incr_rdg >= 1

      l_counter := l_counter + 1;
      IF l_counter = 500 THEN
         l_counter := 0;
         commit;
      END IF;
   end loop;
    EXIT WHEN ctr_cur%NOTFOUND;
  END LOOP;

   fnd_file.put_line(fnd_file.log, '------------------------------------------------------');
   fnd_file.put_line(fnd_file.log, 'Finished Execution : '|| to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
   --
   -- Return 0 for successful completion, 1 for warnings, 2 for error
   errbuf := '';
   retcode := 0;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      retcode := 2;
      fnd_file.put_line(fnd_file.log,'Program Aborting....');
   WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, 'Into when others in Capture_Readings..');
      fnd_file.put_line(fnd_file.log,sqlerrm);
      fnd_file.put_line(fnd_file.log,'Program Aborting....');
      errbuf := sqlerrm;
      retcode := 2;
END Capture_Readings;
--
END CSI_Time_Based_Ctr_Engine_PKG;

/
