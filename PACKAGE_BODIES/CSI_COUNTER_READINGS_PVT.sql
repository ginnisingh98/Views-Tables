--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_READINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_READINGS_PVT" as
/* $Header: csivcrdb.pls 120.41.12010000.10 2010/01/20 10:29:44 kdurgasi ship $ */
--
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_READINGS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivcrdb.pls';
CMRO_CALL VARCHAR(2);
--
FUNCTION get_reading_before_reset(p_counter_id NUMBER,
                                  p_value_timestamp DATE)
RETURN  NUMBER IS

  CURSOR c1 IS
  SELECT counter_reading
  FROM   csi_counter_readings
  WHERE counter_id = p_counter_id
  AND   value_timestamp < p_value_timestamp
  AND   nvl(disabled_flag,'N') = 'N'
  ORDER BY value_timestamp desc;
  --
  l_reading_before_reset NUMBER;
BEGIN
   OPEN c1;
   FETCH c1 INTO l_reading_before_reset;
   CLOSE c1;
   --
   RETURN l_reading_before_reset;
END get_reading_before_reset;
--
FUNCTION get_previous_net_reading(p_counter_id NUMBER,
                                  p_value_timestamp DATE)
RETURN  NUMBER IS

  CURSOR c1 IS
  SELECT net_reading
  FROM   csi_counter_readings
  WHERE counter_id = p_counter_id
  AND   value_timestamp < p_value_timestamp
  AND   nvl(disabled_flag,'N') = 'N'
  ORDER BY value_timestamp desc;
  --
  l_prev_net_reading NUMBER;
BEGIN
   OPEN c1;
   FETCH c1 INTO l_prev_net_reading;
   CLOSE c1;
   --
   RETURN l_prev_net_reading;
END get_previous_net_reading;
--
FUNCTION get_latest_reading(p_counter_id NUMBER)
RETURN  NUMBER IS
  l_counter_value_id NUMBER;
BEGIN
  --Modified function for bug 7563117
  BEGIN
    SELECT ctr_val_max_seq_no
    INTO l_counter_value_id
    FROM csi_counters_b
    WHERE counter_id = p_counter_id
    AND EXISTS(SELECT 'Y' FROM csi_counter_readings WHERE counter_value_id=ctr_val_max_seq_no);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_counter_value_id := NULL;
  END;

  RETURN l_counter_value_id;
END get_latest_reading;
--
FUNCTION Transaction_ID_Exists
               (p_transaction_id IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
BEGIN
   Begin
      select 'x'
      into l_exists
      from CSI_TRANSACTIONS
      where transaction_id = p_transaction_id;
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Transaction_ID_Exists;
--
FUNCTION Counter_Value_Exists
               (p_ctr_value_id IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
BEGIN
   Begin
      select 'x'
      into l_exists
      from CSI_COUNTER_READINGS
      where counter_value_id = p_ctr_value_id;
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Counter_Value_Exists;
--
FUNCTION Counter_Prop_Value_Exists
               (p_ctr_prop_value_id IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
BEGIN
   Begin
      select 'x'
      into l_exists
      from CSI_CTR_PROPERTY_READINGS
      where counter_prop_value_id = p_ctr_prop_value_id;
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Counter_Prop_Value_Exists;
--
FUNCTION Estimated_Rdg_ID_Exists
               (p_estimated_rdg_id IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
BEGIN
   Begin
      select 'x'
      into l_exists
      from CSI_CTR_ESTIMATED_READINGS
      where estimated_reading_id = p_estimated_rdg_id;
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Estimated_Rdg_ID_Exists;
--
FUNCTION Is_Formula_Counter
              (p_counter_id IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
   l_rel_type      VARCHAR2(30) := 'FORMULA';
BEGIN
   Begin
      select '1'
      into l_exists
      from dual
      where exists (select 'x'
                    from CSI_COUNTER_RELATIONSHIPS
                    where object_counter_id = p_counter_id
                    and   relationship_type_code = l_rel_type);
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Is_Formula_Counter;
--
FUNCTION Is_Target_Counter
              (p_counter_id IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
   l_rel_type      VARCHAR2(30) := 'CONFIGURATION';
BEGIN
   Begin
      select '1'
      into l_exists
      from dual
      where exists (select 'x'
                    from CSI_COUNTER_RELATIONSHIPS
                    where object_counter_id = p_counter_id
                    and   relationship_type_code = l_rel_type
                    and   nvl(active_end_date,(sysdate+1)) > sysdate);
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Is_Target_Counter;
--
FUNCTION Valid_Adjustment_Type
              (p_adjustment_type IN VARCHAR2)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
   l_adj_type      VARCHAR2(30) := 'CSI_CTR_ADJUST_READING_TYPE';
BEGIN
   Begin
      select 'x'
      into l_exists
      from CSI_LOOKUPS
      where lookup_type = l_adj_type
      and   lookup_code = p_adjustment_type;
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Valid_Adjustment_Type;
--
FUNCTION Valid_Reset_Mode
              (p_reset_mode IN VARCHAR2)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
   l_adj_type      VARCHAR2(30) := 'CSI_CTR_READING_RESET_TYPE';
BEGIN
   Begin
      select 'x'
      into l_exists
      from CSI_LOOKUPS
      where lookup_type = l_adj_type
      and   lookup_code = p_reset_mode;
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Valid_Reset_Mode;
--
FUNCTION Valid_Ctr_Property_ID
              (p_ctr_value_id IN NUMBER
              ,p_ctr_prop_id  IN NUMBER)
RETURN BOOLEAN IS
   l_return_value  BOOLEAN := FALSE;
   l_exists        VARCHAR2(1);
BEGIN
   Begin
      select 'x'
      into l_exists
      from CSI_COUNTER_READINGS ccr,
           CSI_COUNTER_PROPERTIES_B ccp
      where ccr.counter_value_id = p_ctr_value_id
      and   ccp.counter_id = ccr.counter_id
      and   ccp.counter_property_id = p_ctr_prop_id
      and   nvl(ccp.end_date_active,(sysdate+1)) > sysdate;
      --
      l_return_value := TRUE;
   Exception
      when no_data_found then
         l_return_value := FALSE;
   End;
   RETURN l_return_value;
END Valid_Ctr_Property_ID;
--
FUNCTION HAS_PROPERTY_VALUE(
    p_counter_property_id in number,
    p_counter_value_id in number
  ) RETURN VARCHAR2
  IS
     l_s_temp varchar2(1);
BEGIN
    select 'x'
    into l_s_temp
    from CSI_CTR_PROPERTY_READINGS
    where counter_property_id = p_counter_property_id
    and counter_value_id = p_counter_value_id;
    return 'T';
EXCEPTION
   when no_data_found then
      return 'F';
END HAS_PROPERTY_VALUE;
--
PROCEDURE Calculate_Net_Reading
   (
     p_prev_net_rdg    IN         NUMBER
    ,p_prev_ltd_rdg    IN         NUMBER
    ,p_curr_rdg        IN         NUMBER
    ,p_prev_rdg        IN         NUMBER
    ,p_curr_adj        IN         NUMBER
    ,p_rdg_type        IN         NUMBER
    ,p_direction       IN         VARCHAR2
    ,l_ctr_rdg_rec     IN         csi_ctr_datastructures_pub.counter_readings_rec
    ,px_net_rdg        OUT NOCOPY NUMBER
    ,px_ltd_rdg        OUT NOCOPY NUMBER
   ) IS
   l_curr_adj          NUMBER;
   l_debug_level       NUMBER;    -- 8214848 - dsingire
BEGIN
   -- For Bi-directional counters, Net and LTD will be same as Counter Reading
   -- Read the debug profiles values in to global variable 7197402
    IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire
    IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('Calculate Net Reading Procedure');
      csi_ctr_gen_utility_pvt.put_line('6398254: p_prev_net_rdg' || p_prev_net_rdg);
      csi_ctr_gen_utility_pvt.put_line('6398254: p_prev_ltd_rdg' || p_prev_ltd_rdg);
      csi_ctr_gen_utility_pvt.put_line('6398254: p_curr_rdg' || p_curr_rdg);
      csi_ctr_gen_utility_pvt.put_line('6398254: p_prev_rdg' || p_prev_rdg);
      csi_ctr_gen_utility_pvt.put_line(' p_curr_adj' || p_curr_adj);
      csi_ctr_gen_utility_pvt.put_line('6398254: p_rdg_type' || p_rdg_type);
      csi_ctr_gen_utility_pvt.put_line('p_direction' || p_direction);
      csi_ctr_gen_utility_pvt.put_line('6398254: l_ctr_rdg_rec.reset_mode' || l_ctr_rdg_rec.reset_mode);   -- added 6398254
      csi_ctr_gen_utility_pvt.put_line('6398254: l_ctr_rdg_rec.reset_reason' || l_ctr_rdg_rec.reset_reason);   -- added 6398254
    END IF;                -- 8214848 - dsingire
   /* Only return if a Bi-directional counter AND a reset flow */

        --

  /* Treat Adjustments of Fluctuating counters like Ascending counters */
   IF p_curr_adj IS NULL OR p_curr_adj = FND_API.G_MISS_NUM THEN
      l_curr_adj := 0;
   ELSE
      l_curr_adj := p_curr_adj;
   END IF;
   -- Adjustment will get added if Descending. To retain the same formula we just mutiply with -1
   IF NVL(p_direction,'X') = 'D' THEN
      l_curr_adj := l_curr_adj * -1;
   END IF;
   --
   IF p_rdg_type = 1 THEN -- Absolute
      -- Net Reading = Prev Net + (Curr Rdg - Prev Rdg) - Curr Adj
      -- LTD Reading = Prev LTD + (Curr Rdg - Prev Rdg)
      px_net_rdg := nvl(p_prev_net_rdg,0) +
                    (nvl(p_curr_rdg,0) - nvl(p_prev_rdg,0)) - l_curr_adj;
      px_ltd_rdg := nvl(p_prev_ltd_rdg,0) + (nvl(p_curr_rdg,0) - nvl(p_prev_rdg,0));
   ELSIF p_rdg_type = 2 THEN -- Change
      -- Net Reading = Prev Net + Curr Rdg - Curr Adj -- For Ascending
      -- Net Reading = Prev Net - Curr Rdg - Curr Adj -- For Descending
      IF NVL(p_direction,'X') = 'A' or NVL(p_direction,'X') = 'B' THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Inside the IF block');
         END IF;         -- 8214848 - dsingire
         px_net_rdg := nvl(p_prev_net_rdg,0) + nvl(p_curr_rdg,0) - l_curr_adj;
         px_ltd_rdg := nvl(p_prev_ltd_rdg,0) + nvl(p_curr_rdg,0);
      ELSIF NVL(p_direction,'X') = 'D' THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.put_line('Calculate Net Reading for Desc');
            csi_ctr_gen_utility_pvt.put_line('Prev Reading = '||to_char(p_prev_rdg));
            csi_ctr_gen_utility_pvt.put_line('Prev Net Reading = '||to_char(nvl(p_prev_net_rdg,0)));
            csi_ctr_gen_utility_pvt.put_line('Prev LTD Reading = '||to_char(nvl(p_prev_ltd_rdg,0)));
            csi_ctr_gen_utility_pvt.put_line('Current Reading = '||to_char(nvl(p_curr_rdg,0)));
         END IF;                     -- 8214848 - dsingire
         IF nvl(p_prev_net_rdg,0) = 0 THEN
            /* Check if there is a previous reading */
            IF p_prev_rdg IS NOT  NULL THEN
               px_net_rdg := nvl(p_prev_net_rdg,0) - nvl(p_curr_rdg,0);
            ELSE
               px_net_rdg := nvl(p_curr_rdg,0) - l_curr_adj;
            END IF;
         ELSE
            px_net_rdg := nvl(p_prev_net_rdg,0) - nvl(p_curr_rdg,0) - l_curr_adj;
         END IF;

         IF nvl(p_prev_ltd_rdg,0) = 0 THEN
            IF p_prev_rdg IS NOT NULL THEN
               px_ltd_rdg := nvl(p_prev_ltd_rdg,0) - nvl(p_curr_rdg,0);
            ELSE
               px_ltd_rdg := nvl(p_curr_rdg,0);
            END IF;
         ELSE
            px_ltd_rdg := nvl(p_prev_ltd_rdg,0) - nvl(p_curr_rdg,0);
         END IF;
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.put_line('New Net Reading = '||to_char(px_net_rdg));
            csi_ctr_gen_utility_pvt.put_line('New LTD Reading = '||to_char(px_ltd_rdg));
         END IF;       -- 8214848 - dsingire
      END IF;
   END IF;
    IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    /* added 6398254 */
      csi_ctr_gen_utility_pvt.put_line('6398254: New Net Reading = '||to_char(px_net_rdg));
      csi_ctr_gen_utility_pvt.put_line('6398254: New LTD Reading = '||to_char(px_ltd_rdg));
      /* end addition */
    END IF;     -- 8214848 - dsingire
    IF NVL(p_direction,'X') = 'B' AND p_rdg_type = 2 THEN
    IF p_curr_adj IS NULL OR p_curr_adj = FND_API.G_MISS_NUM THEN
    IF l_ctr_rdg_rec.reset_mode = 'SOFT' THEN
    -- AND NVL(l_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
        -- csi_ctr_gen_utility_pvt.put_line('6398254: Inside Bidir Reset Block p_curr_rdg' || p_curr_rdg);

        px_net_rdg := nvl(p_curr_rdg,0);
        px_ltd_rdg := nvl(p_prev_ltd_rdg,0);
        -- Return;
        END IF;
    END IF;
   END IF;

END Calculate_Net_Reading;
--
PROCEDURE Reset_Target_Counters
   (
     p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,p_ctr_rdg_rec           IN     csi_ctr_datastructures_pub.counter_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_rel_type                      VARCHAR2(30) := 'CONFIGURATION';
   l_counter_reading               NUMBER;
   l_ctr_rdg_rec                   csi_ctr_datastructures_pub.counter_readings_rec;
   l_temp_ctr_rdg_rec              csi_ctr_datastructures_pub.counter_readings_rec;
   l_process_flag                  BOOLEAN;
   l_mode                          VARCHAR2(30);

    -- Bug 8214848
    l_ctr_val_max                 NUMBER := -1;
    l_prev_ctr_max_reading        NUMBER;
    l_prev_net_max_reading        NUMBER;
    l_prev_ltd_max_reading        NUMBER;
    l_prev_value_max_timestamp    DATE;


   --
   CURSOR OBJECT_CTR_CUR IS
   select ccr.object_counter_id,nvl(ccr.factor,1) factor,
          ccv.direction,ccv.reading_type, ccv.uom_code object_uom_code
   from CSI_COUNTER_RELATIONSHIPS ccr,
        CSI_COUNTERS_B ccv
   where ccr.source_counter_id = p_ctr_rdg_rec.counter_id
   and   ccr.relationship_type_code =l_rel_type
   and   nvl(ccr.active_start_date,sysdate) <= p_ctr_rdg_rec.value_timestamp
   and   nvl(ccr.active_end_date,(sysdate+1)) > p_ctr_rdg_rec.value_timestamp
   and   ccv.counter_id = ccr.object_counter_id;
   -- and   ccv.reading_type <> 2;  -- Exclude Change counters as resets are not allowed
   --
   CURSOR PREV_READING_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_reading,net_reading,life_to_date_reading
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp < p_value_timestamp
   ORDER BY value_timestamp desc;
   --,counter_value_id desc;
   --
   CURSOR GET_UOM_CLASS(p_uom_code VARCHAR2) IS
   SELECT uom_class
   FROM   mtl_units_of_measure
   WHERE  uom_code =  p_uom_code;

   l_previous_ctr_rdg NUMBER;
   l_previous_net_rdg NUMBER;
   l_previous_ltd_rdg NUMBER;

   l_source_uom_class VARCHAR2(10);
   l_object_uom_class VARCHAR2(10);
   l_source_uom_code  VARCHAR2(3);
   l_source_direction VARCHAR2(1);
   l_uom_rate         NUMBER;
   l_src_reading_type VARCHAR2(1);
   l_debug_level       NUMBER;    -- 8214848 - dsingire
   l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
   l_conc_login_id		NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
BEGIN
   SAVEPOINT  reset_target_counters;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --

   -- Read the debug profiles values in to global variable 7197402
    IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

   l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('6398254: Inside Reset_Target_Counters...');
    csi_ctr_gen_utility_pvt.dump_counter_readings_rec(p_ctr_rdg_rec);
   END IF;      -- 8214848 - dsingire
   IF p_txn_rec.transaction_type_id in (88,91,92,94,95) THEN
      l_mode := 'Meter';
   ELSE
      l_mode := 'Counter';
   END IF;
   --
   FOR obj_cur IN OBJECT_CTR_CUR LOOP
      -- Check previous reading exists
      l_previous_ctr_rdg := NULL;
      --

      -- Get the last reading for this counter
  -- Bug 	8214848
   BEGIN
    SELECT CTR_VAL_MAX_SEQ_NO INTO l_ctr_val_max
      FROM CSI_COUNTERS_B WHERE COUNTER_ID = obj_cur.object_counter_id;

   SELECT COUNTER_READING,NET_READING,LIFE_TO_DATE_READING
         INTO l_prev_ctr_max_reading,
              l_prev_net_max_reading,
              l_prev_ltd_max_reading
              --,l_prev_value_max_timestamp
              --l_prev_max_comments
   FROM CSI_COUNTER_READINGS WHERE COUNTER_VALUE_ID = NVL(l_ctr_val_max,-1);

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('l_ctr_val_max - ' || l_ctr_val_max );
   END IF;      -- 8214848 - dsingire

  EXCEPTION
   WHEN OTHERS THEN
    -- Assign max counter value id to 0 and use the PREV_READING_CUR cursor
    l_ctr_val_max := -1;
  END;  --

   IF (l_prev_value_max_timestamp <=  p_ctr_rdg_rec.value_timestamp
            AND NVL(l_ctr_val_max,-1) > 0) THEN

      -- The requested timestamp is greater than the timestamp of the
      -- CTR_VAL_MAX_SEQ_NO
      l_previous_ctr_rdg := l_prev_ctr_max_reading;
      l_previous_net_rdg := l_prev_net_max_reading;
      l_previous_ltd_rdg := l_prev_ltd_max_reading;
      --l_prev_value_timestamp := l_prev_value_max_timestamp;
      --l_prev_comments := l_prev_max_comments;

      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Max Value counter id used');
      END IF;      -- 8214848 - dsingire
   ELSE
      OPEN PREV_READING_CUR(obj_cur.object_counter_id,p_ctr_rdg_rec.value_timestamp);
      FETCH PREV_READING_CUR
      INTO l_previous_ctr_rdg,
           l_previous_net_rdg,
           l_previous_ltd_rdg;
      CLOSE PREV_READING_CUR;
   END IF;
      --
      IF l_previous_ctr_rdg = NULL THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Target Counter ID '||to_char(obj_cur.object_counter_id)||
                                        ' does not have any prior readings. First reading cannot be reset');
         END IF;       -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_CTR_INVALID_FIRST_RDG',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
      --
      IF p_ctr_rdg_rec.counter_reading > l_previous_ctr_rdg THEN
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	  csi_ctr_gen_utility_pvt.put_line('Reset counter reading has to be less than the previous reading');
   END IF;       -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_CTR_LESS_RESET_RDG',
	      p_token1_name =>  'PREV_RDG',
	      p_token1_val  =>  to_char(l_previous_ctr_rdg),
	      p_token2_name =>  'MODE',
	      p_token2_val  =>  l_mode
	    );
      END IF;
      --
      l_ctr_rdg_rec := l_temp_ctr_rdg_rec;
      --

      l_ctr_rdg_rec.counter_id := obj_cur.object_counter_id;
      l_ctr_rdg_rec.source_counter_value_id := p_ctr_rdg_rec.counter_value_id;
      l_ctr_rdg_rec.value_timestamp := p_ctr_rdg_rec.value_timestamp;
      l_ctr_rdg_rec.counter_reading := p_ctr_rdg_rec.counter_reading;
      l_ctr_rdg_rec.net_reading := l_previous_net_rdg;
      l_ctr_rdg_rec.life_to_date_reading := l_previous_ltd_rdg;
      l_ctr_rdg_rec.reset_mode := p_ctr_rdg_rec.reset_mode;
      l_ctr_rdg_rec.reset_reason := p_ctr_rdg_rec.reset_reason;
      l_ctr_rdg_rec.source_code := p_ctr_rdg_rec.source_code;
      l_ctr_rdg_rec.source_line_id := p_ctr_rdg_rec.source_line_id;
      l_ctr_rdg_rec.comments := p_ctr_rdg_rec.comments;

      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('6398254: reset reason' || l_ctr_rdg_rec.reset_reason);
      csi_ctr_gen_utility_pvt.put_line('6398254: net reading' || l_ctr_rdg_rec.net_reading);
      end IF;            -- 8214848 - dsingire
      --
      -- Generate the Value_id for insert
      l_process_flag := TRUE;
      WHILE l_process_flag LOOP
	 select CSI_COUNTER_READINGS_S.nextval
	 into l_ctr_rdg_rec.counter_value_id from dual;
	 IF NOT Counter_Value_Exists(l_ctr_rdg_rec.counter_value_id) THEN
	    l_process_flag := FALSE;
	 END IF;

      END LOOP;

      /* Check reset factor */
      BEGIN
         SELECT uom_code, direction, reading_type
         INTO   l_source_uom_code, l_source_direction, l_src_reading_type
         FROM   csi_counters_b
         WHERE  counter_id = p_ctr_rdg_rec.counter_id;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF obj_cur.object_uom_code <> l_source_uom_code THEN
          /* Validate if same UOM class */
          OPEN get_uom_class(obj_cur.object_uom_code);
          FETCH get_uom_class into l_object_uom_class;

          IF get_uom_class%notfound THEN
             csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_ALL_INVALID_UOM_CODE');
          END IF;

          IF get_uom_class%ISOPEN THEN
             CLOSE get_uom_class;
          END IF;

          OPEN get_uom_class(l_source_uom_code);
          FETCH get_uom_class into l_source_uom_class;

          IF get_uom_class%notfound THEN
             csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_ALL_INVALID_UOM_CODE');
          END IF;

          IF get_uom_class%ISOPEN THEN
             CLOSE get_uom_class;
          END IF;

          IF l_source_uom_class = l_object_uom_class THEN
             /* Do a conversion */
             INV_CONVERT.INV_UM_CONVERSION(l_source_uom_code
                              ,obj_cur.object_uom_code
                              ,null
                              ,l_uom_rate);
             IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Object UOM Code = '||obj_cur.object_uom_code);
              csi_ctr_gen_utility_pvt.put_line('Source UOM Code = '||l_source_uom_code);
              csi_ctr_gen_utility_pvt.put_line('UOM Rate = '||to_char(l_uom_rate));
             END IF;                 -- 8214848 - dsingire
             IF l_uom_rate = -99999 then
                 csi_ctr_gen_utility_pvt.put_line(' Error during the conversion of UOM');
             END IF;
          ELSE
             l_uom_rate := 1;
          END IF;
       ELSE
          l_uom_rate := 1;
       END IF;

       IF obj_cur.reading_type = 1 THEN
          IF l_source_direction = 'A' AND obj_cur.direction = 'D' THEN
                l_counter_reading := ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor) * -1;
          END IF;

          IF l_source_direction = 'D' and obj_cur.direction = 'A' THEN
                l_counter_reading := (p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor;
          END IF;

	  IF obj_cur.direction = 'A'  and l_source_direction = 'A' THEN
	      l_counter_reading := (p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor;
	  ELSIF obj_cur.direction = 'D' and l_source_direction = 'D' THEN
	      l_counter_reading := (p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor;
              l_counter_reading := l_counter_reading * -1;
          ELSIF obj_cur.direction = 'B'  and l_source_direction = 'B' THEN
              l_counter_reading := (p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor;
	  END IF;
       ELSE
          l_counter_reading := (p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor;
      END IF;

      l_ctr_rdg_rec.counter_reading := l_counter_reading;

      --
      -- Call the Table Handler to insert into CSI_COUNTER_READINGS
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Resetting target Counter '||to_char(l_ctr_rdg_rec.counter_id));
      END IF;       -- 8214848 - dsingire
      --
      CSI_COUNTER_READINGS_PKG.Insert_Row(
	  px_COUNTER_VALUE_ID         =>  l_ctr_rdg_rec.counter_value_id
	 ,p_COUNTER_ID                =>  l_ctr_rdg_rec.counter_id
	 ,p_VALUE_TIMESTAMP           =>  l_ctr_rdg_rec.value_timestamp
	 ,p_COUNTER_READING           =>  l_ctr_rdg_rec.counter_reading
	 ,p_RESET_MODE                =>  l_ctr_rdg_rec.reset_mode
	 ,p_RESET_REASON              =>  l_ctr_rdg_rec.reset_reason
	 ,p_ADJUSTMENT_TYPE           =>  NULL
	 ,p_ADJUSTMENT_READING        =>  NULL
	 ,p_OBJECT_VERSION_NUMBER     =>  1
	 ,p_LAST_UPDATE_DATE          =>  SYSDATE
	 ,p_LAST_UPDATED_BY           =>  l_user_id
	 ,p_CREATION_DATE             =>  SYSDATE
	 ,p_CREATED_BY                =>  l_user_id
	 ,p_LAST_UPDATE_LOGIN         =>  l_conc_login_id
	 ,p_ATTRIBUTE1                =>  l_ctr_rdg_rec.attribute1
	 ,p_ATTRIBUTE2                =>  l_ctr_rdg_rec.attribute2
	 ,p_ATTRIBUTE3                =>  l_ctr_rdg_rec.attribute3
	 ,p_ATTRIBUTE4                =>  l_ctr_rdg_rec.attribute4
	 ,p_ATTRIBUTE5                =>  l_ctr_rdg_rec.attribute5
	 ,p_ATTRIBUTE6                =>  l_ctr_rdg_rec.attribute6
	 ,p_ATTRIBUTE7                =>  l_ctr_rdg_rec.attribute7
	 ,p_ATTRIBUTE8                =>  l_ctr_rdg_rec.attribute8
	 ,p_ATTRIBUTE9                =>  l_ctr_rdg_rec.attribute9
	 ,p_ATTRIBUTE10               =>  l_ctr_rdg_rec.attribute10
	 ,p_ATTRIBUTE11               =>  l_ctr_rdg_rec.attribute11
	 ,p_ATTRIBUTE12               =>  l_ctr_rdg_rec.attribute12
	 ,p_ATTRIBUTE13               =>  l_ctr_rdg_rec.attribute13
	 ,p_ATTRIBUTE14               =>  l_ctr_rdg_rec.attribute14
	 ,p_ATTRIBUTE15               =>  l_ctr_rdg_rec.attribute15
	 ,p_ATTRIBUTE16               =>  l_ctr_rdg_rec.attribute16
	 ,p_ATTRIBUTE17               =>  l_ctr_rdg_rec.attribute17
	 ,p_ATTRIBUTE18               =>  l_ctr_rdg_rec.attribute18
	 ,p_ATTRIBUTE19               =>  l_ctr_rdg_rec.attribute19
	 ,p_ATTRIBUTE20               =>  l_ctr_rdg_rec.attribute20
	 ,p_ATTRIBUTE21               =>  l_ctr_rdg_rec.attribute21
	 ,p_ATTRIBUTE22               =>  l_ctr_rdg_rec.attribute22
	 ,p_ATTRIBUTE23               =>  l_ctr_rdg_rec.attribute23
	 ,p_ATTRIBUTE24               =>  l_ctr_rdg_rec.attribute24
	 ,p_ATTRIBUTE25               =>  l_ctr_rdg_rec.attribute25
	 ,p_ATTRIBUTE26               =>  l_ctr_rdg_rec.attribute26
	 ,p_ATTRIBUTE27               =>  l_ctr_rdg_rec.attribute27
	 ,p_ATTRIBUTE28               =>  l_ctr_rdg_rec.attribute28
	 ,p_ATTRIBUTE29               =>  l_ctr_rdg_rec.attribute29
	 ,p_ATTRIBUTE30               =>  l_ctr_rdg_rec.attribute30
	 ,p_ATTRIBUTE_CATEGORY        =>  l_ctr_rdg_rec.attribute_category
	 ,p_MIGRATED_FLAG             =>  'N'
	 ,p_COMMENTS                  =>  l_ctr_rdg_rec.comments
	 ,p_LIFE_TO_DATE_READING      =>  l_ctr_rdg_rec.life_to_date_reading
	 ,p_TRANSACTION_ID            =>  p_txn_rec.transaction_id
	 ,p_AUTOMATIC_ROLLOVER_FLAG   =>  l_ctr_rdg_rec.automatic_rollover_flag
	 ,p_INCLUDE_TARGET_RESETS     =>  l_ctr_rdg_rec.include_target_resets
	 ,p_SOURCE_COUNTER_VALUE_ID   =>  l_ctr_rdg_rec.source_counter_value_id
	 ,p_NET_READING               =>  l_ctr_rdg_rec.net_reading
	 ,p_DISABLED_FLAG             =>  'N'
	 ,p_SOURCE_CODE               =>  l_ctr_rdg_rec.source_code
	 ,p_SOURCE_LINE_ID            =>  l_ctr_rdg_rec.source_line_id
	 ,p_INITIAL_READING_FLAG      =>  l_ctr_rdg_rec.initial_reading_flag
       );

       --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
       --for bug 7374316
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
   END LOOP; -- Obj Cursor
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO reset_target_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO reset_target_counters;
END Reset_Target_Counters;
--
PROCEDURE Disable_Target_Derive_Rdg
  ( p_src_counter_value_id   IN  NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2
  )
IS
 l_ctr_val_max_seq_no   NUMBER;
 l_msg_data             VARCHAR2(2000);
 l_msg_index            NUMBER;
 l_msg_count            NUMBER;
 x_msg_data             VARCHAR2(2000);
 x_msg_count            NUMBER;
 l_user_id 				      NUMBER := fnd_global.user_id;        -- 8214848 - dsingire

 CURSOR derived_readings_cur IS
 SELECT counter_value_id, counter_id
 FROM   csi_counter_readings
 WHERE  source_counter_value_id = p_src_counter_value_id
 AND    nvl(disabled_flag,'N') <> 'Y';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FOR derived_reading IN derived_readings_cur LOOP
      UPDATE CSI_COUNTER_READINGS
      SET    disabled_flag = 'Y',
             last_updated_by = l_user_id,
             last_update_date = SYSDATE,
             object_version_number = object_version_number + 1
      WHERE  counter_value_id = derived_reading.counter_value_id;

      l_ctr_val_max_seq_no := NULL;

      CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
          p_api_version           =>  1.0
         ,p_commit                =>  fnd_api.g_false
         ,p_init_msg_list         =>  fnd_api.g_true
         ,p_validation_level      =>  fnd_api.g_valid_level_full
         ,p_counter_id            =>  derived_reading.counter_id
         ,px_ctr_val_max_seq_no   =>  l_ctr_val_max_seq_no
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
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Disable_Target_Derive_Rdg;
--
PROCEDURE Calculate_Rollover_Reading
  ( p_prev_net_rdg      IN   NUMBER
   ,p_prev_ltd_rdg      IN   NUMBER
   ,p_curr_rdg          IN   NUMBER
   ,p_prev_rdg          IN   NUMBER
   ,p_rollover_fm       IN   NUMBER
   ,p_rollover_to       IN   NUMBER
   ,px_net_rdg          OUT  NOCOPY NUMBER
   ,px_ltd_rdg          OUT  NOCOPY NUMBER
  )
IS
BEGIN
   px_net_rdg := nvl(p_prev_net_rdg,0) +
                    (nvl(p_curr_rdg,0) - nvl(p_prev_rdg,0)) + p_rollover_fm - p_rollover_to;
   px_ltd_rdg := nvl(p_prev_ltd_rdg,0) +
                    (nvl(p_curr_rdg,0) - nvl(p_prev_rdg,0)) + p_rollover_fm - p_rollover_to;
END Calculate_Rollover_Reading;
--
PROCEDURE Create_Reading_Transaction
   ( p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
   ) IS
   --
   l_process_flag             BOOLEAN := TRUE;
   l_dummy                    VARCHAR2(1);
   l_api_name                 VARCHAR2(30) := 'CREATE_READING_TRANSACTION';
   l_debug_level       NUMBER;    -- 8214848 - dsingire
   l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
   l_conc_login_id		NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
BEGIN
   SAVEPOINT create_reading_transaction;
   --
   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- Create Transaction
   IF p_txn_rec.transaction_id IS NULL OR
      p_txn_rec.transaction_id = FND_API.G_MISS_NUM THEN
      l_process_flag := TRUE;
      WHILE l_process_flag LOOP
	 select CSI_TRANSACTIONS_S.nextval
	 into p_txn_rec.transaction_id from dual;
	 IF NOT csi_counter_readings_pvt.Transaction_ID_Exists(p_txn_rec.transaction_id) THEN
	    l_process_flag := FALSE;
	 END IF;
      END LOOP;
   ELSE
      IF csi_counter_readings_pvt.Transaction_ID_Exists(p_txn_rec.transaction_id) THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
               ( p_msg_name    =>  'CSI_TXN_ID_ALREADY_EXISTS'
                ,p_token1_name =>  'TRANSACTION_ID'
                ,p_token1_val  =>  to_char(p_txn_rec.transaction_id)
               );
      END IF;
   END IF;
   --
   IF p_txn_rec.transaction_type_id IS NULL OR
      p_txn_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_NO_TXN_TYPE_ID');
   ELSE
      IF p_txn_rec.transaction_type_id NOT in (80,81,82,83,84,85,86,87,88,89,91,92,94,95)
      THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_INVALID_TXN_TYPE_ID');
      ELSE
         Begin
            SELECT  'x'
            INTO    l_dummy
            FROM    csi_txn_types
            WHERE   transaction_type_id = p_txn_rec.transaction_type_id;
         Exception
            when no_data_found THEN
               csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_INVALID_TXN_TYPE_ID');
         End;
      END IF;
   END IF;
   --
   IF p_txn_rec.source_transaction_date IS NULL OR
      p_txn_rec.source_transaction_date = FND_API.G_MISS_DATE THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_NO_TXN_DATE');
   END IF;
   --
   IF p_txn_rec.transaction_date IS NULL OR
      p_txn_rec.transaction_date = FND_API.G_MISS_DATE THEN
      p_txn_rec.transaction_date := sysdate;
   END IF;
   --
   p_txn_rec.object_version_number := 1;
   p_txn_rec.gl_interface_status_code := 1; -- Pending
   --
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
   csi_ctr_gen_utility_pvt.put_line( '....create_reading_transactions'               ||'-'||
                                  p_api_version                              ||'-'||
                                  nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                  nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                  nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;       -- 8214848 - dsingire

   CSI_TRANSACTIONS_PKG.Insert_Row
	 ( px_transaction_id             => p_txn_rec.transaction_id,
	   p_transaction_date            => p_txn_rec.transaction_date,
	   p_source_transaction_date     => p_txn_rec.source_transaction_date,
	   p_transaction_type_id         => p_txn_rec.transaction_type_id,
	   p_txn_sub_type_id             => p_txn_rec.txn_sub_type_id,
	   p_source_group_ref_id         => p_txn_rec.source_group_ref_id,
	   p_source_group_ref            => p_txn_rec.source_group_ref,
	   p_source_header_ref_id        => p_txn_rec.source_header_ref_id,
	   p_source_header_ref           => p_txn_rec.source_header_ref,
	   p_source_line_ref_id          => p_txn_rec.source_line_ref_id,
	   p_source_line_ref             => p_txn_rec.source_line_ref,
	   p_source_dist_ref_id1         => p_txn_rec.source_dist_ref_id1,
	   p_source_dist_ref_id2         => p_txn_rec.source_dist_ref_id2,
	   p_inv_material_transaction_id => p_txn_rec.inv_material_transaction_id,
	   p_transaction_quantity        => p_txn_rec.transaction_quantity,
	   p_transaction_uom_code        => p_txn_rec.transaction_uom_code,
	   p_transacted_by               => p_txn_rec.transacted_by,
	   p_transaction_status_code     => p_txn_rec.transaction_status_code,
	   p_transaction_action_code     => p_txn_rec.transaction_action_code,
	   p_message_id                  => p_txn_rec.message_id,
	   p_context                     => p_txn_rec.context,
	   p_attribute1                  => p_txn_rec.attribute1,
	   p_attribute2                  => p_txn_rec.attribute2,
	   p_attribute3                  => p_txn_rec.attribute3,
	   p_attribute4                  => p_txn_rec.attribute4,
	   p_attribute5                  => p_txn_rec.attribute5,
	   p_attribute6                  => p_txn_rec.attribute6,
	   p_attribute7                  => p_txn_rec.attribute7,
	   p_attribute8                  => p_txn_rec.attribute8,
	   p_attribute9                  => p_txn_rec.attribute9,
	   p_attribute10                 => p_txn_rec.attribute10,
	   p_attribute11                 => p_txn_rec.attribute11,
	   p_attribute12                 => p_txn_rec.attribute12,
	   p_attribute13                 => p_txn_rec.attribute13,
	   p_attribute14                 => p_txn_rec.attribute14,
	   p_attribute15                 => p_txn_rec.attribute15,
	   p_created_by                  => l_user_id,
	   p_creation_date               => SYSDATE,
	   p_last_updated_by             => l_user_id,
	   p_last_update_date            => SYSDATE,
	   p_last_update_login           => l_conc_login_id,
	   p_object_version_number       => p_txn_rec.object_version_number,
	   p_split_reason_code           => p_txn_rec.split_reason_code,
           p_gl_interface_status_code    => p_txn_rec.gl_interface_status_code
        );
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
      ROLLBACK TO create_reading_transaction;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_reading_transaction;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_reading_transaction;
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
END Create_Reading_Transaction;
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
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,p_ctr_rdg_rec           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'CAPTURE_COUNTER_READING_PVT';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   l_prev_ctr_reading              NUMBER;
   l_prev_net_reading              NUMBER;
   l_prev_ltd_reading              NUMBER;
   l_prev_value_timestamp          DATE;
   l_next_ctr_reading              NUMBER;
   l_next_value_timestamp          DATE;
   l_next_reset_mode               VARCHAR2(30);
   l_ctr_name                      VARCHAR2(50);
   l_ctr_type                      VARCHAR2(30);
   l_rollover_last_rdg             NUMBER;
   l_rollover_first_rdg            NUMBER;
   l_direction                     VARCHAR2(1);
   l_reading_type                  NUMBER;
   l_auto_rollover                 VARCHAR2(1);
   l_net_reading                   NUMBER;
   l_ltd_reading                   NUMBER;
   l_previous_rdg                  NUMBER;
   l_previous_net                  NUMBER;
   l_previous_ltd                  NUMBER;
   l_process_flag                  BOOLEAN := TRUE;
   l_reset_value_id                NUMBER;
   l_seq_num                       NUMBER;
   l_rdg_lock_date                 DATE;
   l_curr_adj                      NUMBER;
   l_target_ctr_rec                csi_ctr_datastructures_pub.counter_readings_rec;
   l_reset_rdg_rec                 csi_ctr_datastructures_pub.counter_readings_rec;
   l_recalc_fl_rdg_rec             csi_ctr_datastructures_pub.counter_readings_rec;
   l_temp_ctr_rdg_rec              csi_ctr_datastructures_pub.counter_readings_rec;
   l_disabled_ctr_rec              csi_ctr_datastructures_pub.counter_readings_rec;
   l_reset_timestamp               DATE;
   l_exists                        VARCHAR2(1);
   l_target_ctr_exist              VARCHAR2(1);
   l_update_loop                   BOOLEAN := FALSE;
   l_derive_ctr_rec                csi_ctr_datastructures_pub.counter_readings_rec;
   l_mode                          VARCHAR2(30);
   l_prev_comments                 VARCHAR2(240);
   l_next_comments                 VARCHAR2(240);
   l_rec_count                     NUMBER;
   l_counter_value_id              NUMBER;
   l_obj_version_num               NUMBER;
   Skip_Process                    EXCEPTION;
   --
   -- Bug 8214848
    l_ctr_val_max                 NUMBER := -1;
    l_prev_ctr_max_reading        NUMBER;
    l_prev_net_max_reading        NUMBER;
    l_prev_ltd_max_reading        NUMBER;
    l_prev_value_max_timestamp    DATE;
    l_prev_max_comments           VARCHAR2(240);
    l_counter_id NUMBER;
    l_debug_level       NUMBER;    -- 8214848 - dsingire
    l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
    l_conc_login_id		  NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
    l_date_format       VARCHAR2(50) := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-YYYY HH24:MI:SS');
	-- Bug 9148094
	l_update_net_flag VARCHAR2(1) := NVL(fnd_profile.value('CSI_UPDATE_NET_READINGS_ON_RESET'), 'Y');

   CURSOR PREV_READING_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_reading,net_reading,life_to_date_reading,
          value_timestamp
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp < p_value_timestamp
   ORDER BY value_timestamp desc;
   --,counter_value_id desc;
   --
   CURSOR NEXT_READING_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_reading,value_timestamp,reset_mode
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp > p_value_timestamp
   ORDER BY value_timestamp asc;
   --,counter_value_id asc;

   CURSOR WO_COUNTER_VALUE_CUR(p_counter_id IN NUMBER, p_value_timestamp IN DATE) IS
    SELECT COUNTER_VALUE_ID, OBJECT_VERSION_NUMBER
      FROM   CSI_COUNTER_READINGS
      WHERE  COUNTER_ID = p_counter_id
      AND    VALUE_TIMESTAMP = p_value_timestamp;

   --
   CURSOR LATER_READINGS_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_value_id,counter_reading,net_reading,value_timestamp,adjustment_reading
         ,reset_mode,adjustment_type,include_target_resets, comments
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp > p_value_timestamp
   ORDER BY value_timestamp asc, counter_value_id asc;
   --
BEGIN

csi_ctr_gen_utility_pvt.put_line(' dk: cap read: Update Net Reading Flag : '||l_update_net_flag);

   -- Standard Start of API savepoint
   SAVEPOINT  capture_counter_reading_pvt;
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
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

   l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
   csi_ctr_gen_utility_pvt.put_line( '....capture_counter_reading_pvt'               ||'-'||
                                  p_api_version                              ||'-'||
                                  nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                  nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                  nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
	csi_ctr_gen_utility_pvt.put_line('CMRO_CALL : '||CMRO_CALL);
   csi_ctr_gen_utility_pvt.put_line('Passed Transaction ID is '||to_char(p_txn_rec.transaction_id));
   END IF;          -- 8214848 - dsingire
   -- *

   --
   IF p_txn_rec.transaction_type_id in (91,92,94,95) THEN
      l_mode := 'Meter';
   ELSE
      l_mode := 'Counter';
   END IF;
   --
   IF p_ctr_rdg_rec.counter_id IS NULL OR
      p_ctr_rdg_rec.counter_id = FND_API.G_MISS_NUM THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_INVALID',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   ELSE
      -- Get the counter definition
      Begin
         select name,counter_type,rollover_last_reading,
                rollover_first_reading,direction,reading_type,
                automatic_rollover
         into l_ctr_name,l_ctr_type,l_rollover_last_rdg,l_rollover_first_rdg,
              l_direction,l_reading_type,l_auto_rollover
         from CSI_COUNTERS_VL -- Need to be changed
         where counter_id = p_ctr_rdg_rec.counter_id
         and   nvl(end_date_active,(sysdate+1)) > sysdate;
      Exception
         when no_data_found then
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
		 ( p_msg_name     => 'CSI_API_CTR_INVALID',
		   p_token1_name  => 'MODE',
		   p_token1_val   => l_mode
		 );
      End;
   END IF;
   -- Atleast one reading should be captured.
   IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
      NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
      NVL(p_ctr_rdg_rec.reset_counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('At least one reading should be entered...');
      END IF;              -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
         ( p_msg_name     => 'CSI_API_CTR_RDG_MISSING',
           p_token1_name  => 'MODE',
           p_token1_val   => l_mode
         );
   END IF;
   --
   IF nvl(l_direction,'X') NOT IN ('A','D','B') THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Counter has invalid Direction...');
      END IF;             -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_INVALID_DIR',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   IF nvl(p_ctr_rdg_rec.disabled_flag,'N') = 'Y' THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot disable the value during Insert...');
      END IF;             -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_NO_RDG_DISABLE',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   -- Cannot Capture Reading for Target Counters as they are driven by source counters
   IF Is_Target_Counter(p_ctr_rdg_rec.counter_id) THEN
      IF p_txn_rec.transaction_type_id in (91,92,94,95) THEN
         l_rec_count := 0;
         select count(*)
         into l_rec_count
         from CSI_COUNTER_READINGS
         where counter_id = p_ctr_rdg_rec.counter_id
         and   ROWNUM = 1;
         --
         IF l_rec_count > 0 THEN
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Only First Reading can be captured for a Target Counter manually');
            END IF;                      -- 8214848 - dsingire
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
		 ( p_msg_name     => 'CSI_API_NO_RDG_TARGET_CTR',
		   p_token1_name  => 'MODE',
		   p_token1_val   => l_mode
		 );
         END IF;
      ELSE
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Cannot Capture Reading for a Target Counter...');
         END IF;      -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
	      ( p_msg_name     => 'CSI_API_NO_RDG_TARGET_CTR',
	        p_token1_name  => 'MODE',
	        p_token1_val   => l_mode
	      );
      END IF;
   END IF;
   --
   -- Cannot Capture Reading for Formula Counters
   IF Is_Formula_Counter(p_ctr_rdg_rec.counter_id) THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Capture Reading for a Formula Counter...');
      END IF;    -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_NO_RDG_FORMULA_CTR',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   IF p_ctr_rdg_rec.value_timestamp IS NULL OR
      p_ctr_rdg_rec.value_timestamp = FND_API.G_MISS_DATE THEN
      p_ctr_rdg_rec.value_timestamp := sysdate;
     -- csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID_RDG_DATE');
   END IF;
   --

   Begin
      -- Bug 8214848
      select counter_id
      into   l_counter_id
      from   CSI_COUNTER_READINGS
      where  counter_id = p_ctr_rdg_rec.counter_id
      and    value_timestamp = p_ctr_rdg_rec.value_timestamp;

      /* Readings return status fixes */
      IF p_txn_rec.transaction_type_id in (91,92,94,95) THEN
         BEGIN
            select 'x'
            into   l_exists
            from   dual
            where  exists (select 'x'
       	                   from   CSI_COUNTER_READINGS
		           where  counter_id = p_ctr_rdg_rec.counter_id
		           and    value_timestamp = p_ctr_rdg_rec.value_timestamp
		           and    counter_reading = p_ctr_rdg_rec.counter_reading);
            raise skip_process;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF p_txn_rec.transaction_type_id = 92 THEN
                  /* ECO 5344596, Disable previous reading and capture new
                     WO Recompletion Reading */

                  -- Bug 8214848
                  l_counter_value_id := null;
                  l_obj_version_num := null;

                  OPEN WO_COUNTER_VALUE_CUR(p_ctr_rdg_rec.counter_id, p_ctr_rdg_rec.value_timestamp);
                  FETCH WO_COUNTER_VALUE_CUR INTO
                    l_counter_value_id,
                    l_obj_version_num;
                  CLOSE WO_COUNTER_VALUE_CUR;
                  -- Enf of addition for bug 8214848

                  l_disabled_ctr_rec.counter_value_id := l_counter_value_id;
                  l_disabled_ctr_rec.disabled_flag    := 'Y';
                  l_disabled_ctr_rec.object_version_number := l_obj_version_num;

                  update_counter_reading
	            (p_api_version           =>  1.0
	             ,p_commit               =>  p_commit
	             ,p_init_msg_list        =>  p_init_msg_list
	             ,p_validation_level     =>  p_validation_level
	             ,p_ctr_rdg_rec          =>  l_disabled_ctr_rec
	             ,x_return_status        =>  x_return_status
	             ,x_msg_count            =>  x_msg_count
	             ,x_msg_data             =>  x_msg_data
	            );
	          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	              csi_ctr_gen_utility_pvt.put_line('ERROR FROM Update_Counter_Reading when disabling WO ');
               END IF;                -- 8214848 - dsingire
	             l_msg_index := 1;
	             l_msg_count := x_msg_count;
	             WHILE l_msg_count > 0 LOOP
	                x_msg_data := FND_MSG_PUB.GET
	                (l_msg_index,
		         FND_API.G_FALSE
	                );
                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  END IF;
	                l_msg_index := l_msg_index + 1;
	                l_msg_count := l_msg_count - 1;
	             END LOOP;
	             RAISE FND_API.G_EXC_ERROR;
                  END IF;
               ELSE
                  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                    (p_msg_name     => 'CSI_API_CTR_RDG_DATE_EXISTS',
	             p_token1_name  => 'VALUE_TIMESTAMP',
	             p_token1_val   => to_char(p_ctr_rdg_rec.value_timestamp,l_date_format),
	             p_token2_name  => 'MODE',
	             p_token2_val   => l_mode
	             );
               END IF;
         END;
      ELSE
         /* end of return status fixes */
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
            (p_msg_name     => 'CSI_API_CTR_RDG_DATE_EXISTS',
	     p_token1_name  => 'VALUE_TIMESTAMP',
	     p_token1_val   => to_char(p_ctr_rdg_rec.value_timestamp,l_date_format),
	     p_token2_name  => 'MODE',
	     p_token2_val   => l_mode
	    );
      END IF;
   Exception
      when no_data_found then
         null;
   End;
   --
   IF p_ctr_rdg_rec.value_timestamp > sysdate THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
         ( p_msg_name     => 'CSI_API_CTR_FUTURE_RDG_DATE',
           p_token1_name  => 'VALUE_TIMESTAMP',
           p_token1_val   => to_char(p_ctr_rdg_rec.value_timestamp,l_date_format),
	   p_token2_name  => 'MODE',
	   p_token2_val   => l_mode
         );
   END IF;
   -- *
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('Adjustment type is..' || p_ctr_rdg_rec.adjustment_type);
   END IF;

   IF NVL(p_ctr_rdg_rec.adjustment_type,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      -- Validate Adjustment Type against lookups
      IF NOT Valid_Adjustment_Type(p_ctr_rdg_rec.adjustment_type) THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_INV_ADJ_TYPE',
               p_token1_name  =>  'ADJ_TYPE',
               p_token1_val   =>  p_ctr_rdg_rec.adjustment_type
             );
      END IF;
   END IF;
   --
   IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      -- Validate Reset Mode against lookups
      -- IF NOT Valid_Reset_Mode(p_ctr_rdg_rec.reset_mode) THEN
      -- Since we allow only SOFT reset at this point, no need to check against Lookups
      IF p_ctr_rdg_rec.reset_mode <> 'SOFT' THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_INV_RESET_MODE',
               p_token1_name  =>  'RESET_MODE',
               p_token1_val   =>  p_ctr_rdg_rec.reset_mode
             );
      END IF;
      --
      IF NVL(p_ctr_rdg_rec.reset_counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Reset counter reading is mandatory for SOFT reset..');
         END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name     => 'CSI_API_CTR_SOFT_RDG_MISS',
	      p_token1_name  => 'MODE',
	      p_token1_val   => l_mode
	    );
      END IF;
      --


      IF NVL(p_ctr_rdg_rec.reset_reason,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name     => 'CSI_API_CTR_RESET_REASON_MISS',
	      p_token1_name  => 'MODE',
	      p_token1_val   => l_mode
	    );
      END IF;
   END IF; -- Reset Mode check
   --
   -- Adjustment reading is Mandatory for Adjustments
   IF NVL(p_ctr_rdg_rec.adjustment_type,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR AND
      NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('Adjustment Reading cannot be Null or Zero for Adjustments...');
      END IF;                   -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	 ( p_msg_name     => 'CSI_API_CTR_ADJ_RDG_MISS',
	   p_token1_name  => 'MODE',
	   p_token1_val   => l_mode
	 );
   END IF;
   --
   -- Reverse Validation
   IF NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM AND
      NVL(p_ctr_rdg_rec.adjustment_type,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Adjustment Type is Mandatory for Adjustments...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	 ( p_msg_name     => 'CSI_API_CTR_ADJ_TYPE_MISS',
	   p_token1_name  => 'MODE',
	   p_token1_val   => l_mode
	 );
   END IF;
   --
   IF NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) <= 0 THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Adjustment Reading cannot be Zero or Negative...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	 ( p_msg_name     => 'CSI_API_CTR_POSITIVE_ADJ_RDG',
	   p_token1_name  => 'MODE',
	   p_token1_val   => l_mode
	 );
   END IF;
   -- Reverse Validations
   IF NVL(p_ctr_rdg_rec.reset_counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('Reset Mode is Mandatory for Resets...');
        END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name     => 'CSI_API_CTR_RESET_MODE_MISS',
	      p_token1_name  => 'MODE',
	      p_token1_val   => l_mode
	    );
      END IF;
      -- Reset Reason is Mandatory
      IF NVL(p_ctr_rdg_rec.reset_reason,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name     => 'CSI_API_CTR_RESET_REASON_MISS',
	      p_token1_name  => 'MODE',
	      p_token1_val   => l_mode
	    );
      END IF;
   END IF;
   -- *
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('Reset Mode is Mandatory for Resets...'|| p_ctr_rdg_rec.reset_counter_reading );
   END IF;          -- 8214848 - dsingire
   IF NVL(p_ctr_rdg_rec.reset_reason,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      IF NVL(p_ctr_rdg_rec.reset_counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Reset Reading is Mandatory for Resets...');
         END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name     => 'CSI_API_CTR_RESET_RDG_MISS',
	      p_token1_name  => 'MODE',
	      p_token1_val   => l_mode
	    );
      END IF;
      --
      IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('Reset Mode is Mandatory for Resets...');
        END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name     => 'CSI_API_CTR_RESET_MODE_MISS',
	      p_token1_name  => 'MODE',
	      p_token1_val   => l_mode
	    );
      END IF;
   END IF;
   --
   -- Atleast one reading should be captured.
   IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
      NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM AND
      NVL(p_ctr_rdg_rec.reset_counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('At least one reading should be entered...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	 ( p_msg_name     => 'CSI_API_CTR_RDG_MISSING',
	   p_token1_name  => 'MODE',
	   p_token1_val   => l_mode
	 );
   END IF;
   --
   -- If the Source counter or its object counters have a reading lock date then
   -- the reading date cannot be earlier than the lock date (Max of all)
   l_rdg_lock_date := NULL;

  Begin
      select max(reading_lock_date)
      into l_rdg_lock_date
      from CSI_COUNTER_READING_LOCKS
      where counter_id = p_ctr_rdg_rec.counter_id
      OR    counter_id in (select object_counter_id
                           from CSI_COUNTER_RELATIONSHIPS
                           where source_counter_id = p_ctr_rdg_rec.counter_id
                           and   nvl(active_end_date,(p_ctr_rdg_rec.value_timestamp+1)) > p_ctr_rdg_rec.value_timestamp);
   End;
   --
   IF l_rdg_lock_date IS NOT NULL THEN
      IF p_ctr_rdg_rec.value_timestamp <= l_rdg_lock_date THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Reading Date cannot be earlier than the Reading Lock Date...');
         END IF;          -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_RDG_DATE_LOCKED',
               p_token1_name  =>  'LOCKED_DATE',
               p_token1_val   =>  to_char(l_rdg_lock_date,l_date_format), --fix for bug 5435071
               p_token2_name  =>  'MODE',
               p_token2_val   =>  l_mode
             );
      END IF;
   END IF;
   -- *
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('Getting PREV Counter reading' || p_ctr_rdg_rec.value_timestamp );
   END IF;          -- 8214848 - dsingire

  -- Get the last reading for this counter
  -- Bug 	8214848
   BEGIN
    SELECT CTR_VAL_MAX_SEQ_NO INTO l_ctr_val_max
      FROM CSI_COUNTERS_B WHERE COUNTER_ID = p_ctr_rdg_rec.counter_id;

   SELECT COUNTER_READING,NET_READING,LIFE_TO_DATE_READING,
          VALUE_TIMESTAMP
         INTO l_prev_ctr_max_reading,
              l_prev_net_max_reading,
              l_prev_ltd_max_reading,
              l_prev_value_max_timestamp
              --l_prev_max_comments
   FROM CSI_COUNTER_READINGS WHERE COUNTER_VALUE_ID = NVL(l_ctr_val_max,-1);

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('l_ctr_val_max - ' || l_ctr_val_max );
   END IF;          -- 8214848 - dsingire

  EXCEPTION
   WHEN OTHERS THEN
    -- Assign max counter value id to 0 and use the PREV_READING_CUR cursor
    l_ctr_val_max := -1;
  END;  --

   IF (l_prev_value_max_timestamp <=  p_ctr_rdg_rec.value_timestamp
            AND NVL(l_ctr_val_max,-1) > 0) THEN

      -- The requested timestamp is greater than the timestamp of the
      -- CTR_VAL_MAX_SEQ_NO
      l_prev_ctr_reading := l_prev_ctr_max_reading;
      l_prev_net_reading := l_prev_net_max_reading;
      l_prev_ltd_reading := l_prev_ltd_max_reading;
      l_prev_value_timestamp := l_prev_value_max_timestamp;
      --l_prev_comments := l_prev_max_comments;

      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Max Value counter id used');
      END IF;          -- 8214848 - dsingire

   ELSE

     OPEN PREV_READING_CUR(p_ctr_rdg_rec.counter_id,p_ctr_rdg_rec.value_timestamp);
     FETCH PREV_READING_CUR
     INTO  l_prev_ctr_reading,
          l_prev_net_reading,
          l_prev_ltd_reading,
          l_prev_value_timestamp;
          --l_prev_comments;
     CLOSE PREV_READING_CUR;
   END IF;

   -- End of modification for the bug 	8214848
   -- *
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('PREV Counter reading' || l_prev_ctr_reading );
  END IF;          -- 8214848 - dsingire


   --
   -- Check whether this is the first reading
   IF l_prev_ctr_reading IS NULL THEN -- First Reading
      IF NVL(p_ctr_rdg_rec.adjustment_type,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
         NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
         NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.put_line('First Reading cannot be Adjustment or Reset or Automatic Rollover');
         END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_CTR_INVALID_FIRST_RDG',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
   ELSE
      IF NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
         IF p_ctr_rdg_rec.adjustment_reading > l_prev_net_reading THEN
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Adjustment Reading cannot be greater than Previous Net Reading');
            END IF;          -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.ExitWithErrMsg
               ( p_msg_name     =>  'CSI_API_CTR_INVALID_ADJ_RDG',
                 p_token1_name  =>  'PREV_NET',
                 p_token1_val   =>  to_char(l_prev_net_reading)
               );
         END IF;
      END IF;
   END IF;

   -- *
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('Getting LAST Counter reading' || to_char(p_ctr_rdg_rec.value_timestamp,'DD-MON-YYYY HH24:MI:SS'));

    csi_ctr_gen_utility_pvt.put_line('next value timestamp before fetch' || l_next_value_timestamp);
   END IF;          -- 8214848 - dsingire

   -- Get the next reading for this counter
   OPEN NEXT_READING_CUR(p_ctr_rdg_rec.counter_id,p_ctr_rdg_rec.value_timestamp);
   FETCH NEXT_READING_CUR
   INTO  l_next_ctr_reading,
	 l_next_value_timestamp,
         l_next_reset_mode;
         --l_next_comments;
   CLOSE NEXT_READING_CUR;

   -- *
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
   csi_ctr_gen_utility_pvt.put_line('LAST Counter reading' ||  l_next_ctr_reading );
   csi_ctr_gen_utility_pvt.put_line('LAST Counter reading' ||  to_char(l_next_value_timestamp,'DD-MON-YYYY HH24:MI:SS') );
   csi_ctr_gen_utility_pvt.put_line('Reading Type is' ||  l_reading_type );
   END IF;          -- 8214848 - dsingire
   --
   --
   IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
      IF NVL(l_auto_rollover,'N') <> 'Y' OR
         l_rollover_last_rdg IS NULL OR
         l_rollover_first_rdg IS NULL THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Counter does not have automatic rollover attributes set...');
         END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_CTR_ROLLOVER_ATTR_MISS',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
   END IF;
   -- For Change Counters Reset and Automatic rollover are not allowed

   IF l_reading_type = 2 THEN
      /* IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
         csi_ctr_gen_utility_pvt.put_line('Soft Reset is not allowed for Change Counters..');
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_NO_RESET_CHG_CTR',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
      */
      --
      IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('Automatic Rollover  is not allowed for Change Counters..');
        END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_NO_AUTO_CHG_CTR',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
      --
      /* IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) < 0 THEN
         csi_ctr_gen_utility_pvt.put_line('Counter Reading cannot be negative for Change Counters...');
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_CTR_NEG_RDG',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF
      */
   END IF;
   -- For Bi-Directionsl Counters Adjustments, Reset and Automatic rollover are not allowed
   IF l_direction = 'B' THEN
    --Commented by Anju for cMRO bug
     /* IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
         csi_ctr_gen_utility_pvt.put_line('Reset is not allowed for Bi-directional Counters..');
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_NO_RESET_BID_CTR',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;*/

      --
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line( 'p_ctr_rdg_rec.reset_mode ' || p_ctr_rdg_rec.reset_mode);
      END IF;          -- 8214848 - dsingire
      IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Automatic Rollover is not allowed for Bi-directional Counters..');
         END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_NO_AUTO_BID_CTR',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
      --

      /* IF NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
         THEN
         csi_ctr_gen_utility_pvt.put_line('Adjustment Reading is' || p_ctr_rdg_rec.adjustment_reading);
         csi_ctr_gen_utility_pvt.put_line('Adjustment is not allowed for Bi-directional Counters..');
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_NO_ADJ_BID_CTR',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;*/

   END IF;
   -- Automatic Rollover cannot be combined with other reading captures.
   IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
      IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
         NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('Automatic Rollover cannot be combined with Reset or Adj...');
         END IF;          -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID_AUTO_RDG');
      END IF;
   END IF;
   -- *
   --csi_ctr_gen_utility_pvt.put_line( '1');         -- 8214848 - dsingire
   IF l_next_value_timestamp IS NOT NULL THEN
        -- *
        --csi_ctr_gen_utility_pvt.put_line( '2');    -- 8214848 - dsingire
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line( 'l_next_value_timestamp' || l_next_value_timestamp);
        END IF;          -- 8214848 - dsingire
      -- Automatic Rollover Cannot occur inbetween readings
      IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Next counter reading exists. Cannot Rollover...');     ----- this point
         END IF;          -- 8214848 - dsingire

         csi_ctr_gen_utility_pvt.ExitWithErrMsg
                 ( p_msg_name     => 'CSI_API_CTR_NEXT_RDG_DT_EXISTS',
                   p_token1_name  => 'NEXT_DATE',
                   p_token1_val   => to_char(l_next_value_timestamp,l_date_format)
                 );
      END IF;
      -- Reset cannot happen in between. It has to be at the end
      IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('Next counter reading exists. Cannot Reset in between...');
        END IF;          -- 8214848 - dsingire

         csi_ctr_gen_utility_pvt.ExitWithErrMsg
                 ( p_msg_name     => 'CSI_API_CTR_NEXT_RDG_DT_EXISTS',
                   p_token1_name  => 'NEXT_DATE',
                   p_token1_val   => to_char(l_next_value_timestamp,l_date_format)
                 );
      END IF;
      --
      -- Inbetween Adjustments cannot be clubbed with other readings
      IF NVL(p_ctr_rdg_rec.adjustment_type,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR OR
         NVL(p_ctr_rdg_rec.adjustment_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
         IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Between readings adjustments cannot be clubbed with others...');
            END IF;          -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.ExitWithErrMsg
                 ( p_msg_name     => 'CSI_API_CTR_ADJ_RDG_ONLY',
                   p_token1_name  => 'NEXT_DATE',
                   p_token1_val   => to_char(l_next_value_timestamp,l_date_format)
                 );
         END IF;
      END IF;
   END IF; -- Look for Next Value


   -- Reset Counter reading cannot be greater than previous counter reading
   IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         IF l_direction = 'D' THEN
            /* Validate that the reset reading is between the rollover if
               rollover attributes does exists */
            IF nvl(l_auto_rollover,'N') = 'Y'  THEN
               IF p_ctr_rdg_rec.reset_counter_reading < l_rollover_last_rdg OR
                  p_ctr_rdg_rec.reset_counter_reading > l_rollover_first_rdg THEN
                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line('Reset counter reading not in the range of valid rollover values ...D Dir ');
                  END IF;          -- 8214848 - dsingire
	          csi_ctr_gen_utility_pvt.ExitWithErrMsg
		     ( p_msg_name       =>  'CSI_API_CTR_DSC_ROLLOVER_RDG',
		       p_token1_name    =>  'MODE',
		       p_token1_val     =>  l_mode
                     );
               END IF;
            END IF;


            IF p_ctr_rdg_rec.reset_counter_reading < l_prev_ctr_reading THEN
              IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.put_line('Reset counter reading has to be greater than the previous reading ...D Dir ');
               END IF;          -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.ExitWithErrMsg
                  ( p_msg_name    =>  'CSI_API_CTR_MORE_RESET_RDG',
                    p_token1_name =>  'PREV_RDG',
                    p_token1_val  =>  to_char(l_prev_ctr_reading),
	            p_token2_name =>  'MODE',
	            p_token2_val  =>  l_mode
                  );
            END IF;
         ELSIF l_direction = 'A' THEN
            IF nvl(l_auto_rollover,'N') = 'Y'  THEN
               IF p_ctr_rdg_rec.reset_counter_reading > l_rollover_last_rdg OR
                  p_ctr_rdg_rec.reset_counter_reading < l_rollover_first_rdg THEN

                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line('Reset counter reading not in the range of valid rollover values ...A Dir ');
                  END IF;          -- 8214848 - dsingire
	          csi_ctr_gen_utility_pvt.ExitWithErrMsg
		     ( p_msg_name       =>  'CSI_API_CTR_ASC_ROLLOVER_RDG',
		       p_token1_name    =>  'MODE',
		       p_token1_val     =>  l_mode
                     );
               END IF;
            END IF;
            IF p_ctr_rdg_rec.reset_counter_reading > l_prev_ctr_reading THEN
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                csi_ctr_gen_utility_pvt.put_line('Reset counter reading has to be less than the previous reading ... A Dir');
               END IF;          -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.ExitWithErrMsg
                  ( p_msg_name    =>  'CSI_API_CTR_LESS_RESET_RDG',
                    p_token1_name =>  'PREV_RDG',
                    p_token1_val  =>  to_char(l_prev_ctr_reading),
	            p_token2_name =>  'MODE',
	            p_token2_val  =>  l_mode
                  );
            END IF;
         END IF;
      ELSE
         IF l_direction = 'D' THEN
            IF p_ctr_rdg_rec.reset_counter_reading < l_prev_ctr_reading THEN
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                csi_ctr_gen_utility_pvt.put_line('Reset counter reading has to be greater than the previous reading ...D Dir ');
               END IF;          -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.ExitWithErrMsg
                  ( p_msg_name    =>  'CSI_API_CTR_MORE_RESET_RDG',
                    p_token1_name =>  'PREV_RDG',
                    p_token1_val  =>  to_char(l_prev_ctr_reading),
	            p_token2_name =>  'MODE',
	            p_token2_val  =>  l_mode
                  );
            END IF;
        /* As in 11.5.10, ensure that Reset of Bidirection counter, reading is less than current reading */
         ELSIF l_direction = 'A' THEN
            IF p_ctr_rdg_rec.reset_counter_reading > l_prev_ctr_reading THEN
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.put_line('Reset counter reading has to be less than the previous reading ... A Dir');
               END IF;          -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.ExitWithErrMsg
                  ( p_msg_name    =>  'CSI_API_CTR_LESS_RESET_RDG',
                    p_token1_name =>  'PREV_RDG',
                    p_token1_val  =>  to_char(l_prev_ctr_reading),
	            p_token2_name =>  'MODE',
	            p_token2_val  =>  l_mode
                  );
            END IF;
         END IF;
      END IF;
   END IF;
   --
   -- For Absolute counters check the Counter reading based on the Direction
   -- If Reading is captured inbetween then also it should be within prev and next readings
   -- If rollover flag is set then current reading can be less than previous reading
   IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') <> 'Y' THEN
      IF l_reading_type = 1  THEN -- Absolute
         -- OR l_reading_type = 2 THEN -- Changed
	 IF nvl(l_direction,'X') = 'A' THEN
	    IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	       IF ( (p_ctr_rdg_rec.counter_reading < nvl(l_prev_ctr_reading,p_ctr_rdg_rec.counter_reading)) OR
		    ( l_next_ctr_reading IS NOT NULL AND
		      p_ctr_rdg_rec.counter_reading > l_next_ctr_reading) ) THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
		  csi_ctr_gen_utility_pvt.put_line('1. Reading should be in increasing order...');
      END IF;          -- 8214848 - dsingire
		  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                      ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                        p_token1_name    =>  'DIRECTION',
                        -- p_token1_val     =>  l_direction,
                        p_token1_val     =>  'an Ascending',
  	                p_token2_name    =>  'MODE',
	                p_token2_val     =>  l_mode,
  	                p_token3_name    =>  'CTR_NAME',
	                p_token3_val     =>  l_ctr_name
                      );
	       END IF;
	    END IF;
	 ELSIF nvl(l_direction,'X') = 'D' THEN
	    IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	       IF ( (p_ctr_rdg_rec.counter_reading > nvl(l_prev_ctr_reading,p_ctr_rdg_rec.counter_reading)) OR
		    ( l_next_ctr_reading IS NOT NULL AND
		      p_ctr_rdg_rec.counter_reading < l_next_ctr_reading) ) THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
		  csi_ctr_gen_utility_pvt.put_line('2. Reading should be in decreasing order...');
      END IF;          -- 8214848 - dsingire
		  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                      ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                        p_token1_name    =>  'DIRECTION',
                        -- p_token1_val     =>  l_direction,
                        p_token1_val     =>  'a Descending',
  	                p_token2_name    =>  'MODE',
	                p_token2_val     =>  l_mode,
  	                p_token3_name    =>  'CTR_NAME',
	                p_token3_val     =>  l_ctr_name
                      );
	       END IF;
	    END IF;
	 END IF;
      END IF; -- Reading Type and Direction check
   ELSE -- Automatic Rollover
      IF nvl(l_direction,'X') = 'A' THEN
         IF p_ctr_rdg_rec.counter_reading > l_rollover_last_rdg OR
            p_ctr_rdg_rec.counter_reading < l_rollover_first_rdg THEN
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Counter Reading has to be within Rollover From-To Rdgs..');
            END IF;          -- 8214848 - dsingire
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
		( p_msg_name       =>  'CSI_API_CTR_ASC_ROLLOVER_RDG',
		  p_token1_name    =>  'MODE',
		  p_token1_val     =>  l_mode
		);
         END IF;
      ELSIF nvl(l_direction,'X') = 'D' THEN
         IF p_ctr_rdg_rec.counter_reading < l_rollover_last_rdg OR
            p_ctr_rdg_rec.counter_reading > l_rollover_first_rdg THEN
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Counter Reading has to be within Rollover From-To Rdgs..');
            END IF;          -- 8214848 - dsingire
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
		( p_msg_name       =>  'CSI_API_CTR_DSC_ROLLOVER_RDG',
		  p_token1_name    =>  'MODE',
		  p_token1_val     =>  l_mode
		);
         END IF;
      END IF;
   END IF; -- Rollover flag check
   --
   -- If counter reading is not entered then look for adjustments
   IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF NVL(p_ctr_rdg_rec.adjustment_type,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
         IF l_reading_type = 1 THEN
            p_ctr_rdg_rec.counter_reading := l_prev_ctr_reading;
         ELSE
            p_ctr_rdg_rec.counter_reading := 0;
         END IF;
      END IF;
   END IF; -- Null counter reading
   --
   p_ctr_rdg_rec.object_version_number := 1;
   --
   -- If counter_reading gets a user entered value or thru' adjustments (Previous value)
   -- Insert into CSI_COUNTER_READINGS
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line( 'l_reading_type ' || l_reading_type);
    csi_ctr_gen_utility_pvt.put_line( 'p_ctr_rdg_rec.counter_reading ' || p_ctr_rdg_rec.counter_reading);
    csi_ctr_gen_utility_pvt.put_line( 'p_ctr_rdg_rec.automatic_rollover_flag ' || p_ctr_rdg_rec.automatic_rollover_flag);
    csi_ctr_gen_utility_pvt.put_line( 'p_ctr_rdg_rec.reset_mode ' || p_ctr_rdg_rec.reset_mode);

    csi_ctr_gen_utility_pvt.put_line( 'p_ctr_rdg_rec.reset_reason ' || p_ctr_rdg_rec.reset_reason);

    csi_ctr_gen_utility_pvt.put_line( 'p_ctr_rdg_rec.reset_counter_reading ' || p_ctr_rdg_rec.reset_counter_reading);
   END IF;          -- 8214848 - dsingire

   IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
   IF NVL(p_ctr_rdg_rec.reset_counter_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM OR
   (NVL(p_ctr_rdg_rec.reset_counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
    AND (p_ctr_rdg_rec.counter_reading <> p_ctr_rdg_rec.reset_counter_reading)) THEN
    -- check := true;
   --csi_ctr_gen_utility_pvt.put_line( 'check' || check);
   -- IF (p_ctr_rdg_rec.counter_reading <> p_ctr_rdg_rec.reset_counter_reading) THEN   -- for cMRO resetTHEN
      IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') <> 'Y' THEN

         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Calculate Net Reading 1');
         END IF;          -- 8214848 - dsingire

         Calculate_Net_Reading
            ( p_prev_net_rdg      => l_prev_net_reading
             ,p_prev_ltd_rdg      => l_prev_ltd_reading
             ,p_curr_rdg          => p_ctr_rdg_rec.counter_reading
             ,p_prev_rdg          => l_prev_ctr_reading
             ,p_curr_adj          => p_ctr_rdg_rec.adjustment_reading
             ,p_rdg_type          => l_reading_type
             ,p_direction         => l_direction
             ,px_net_rdg          => l_net_reading
             ,px_ltd_rdg          => l_ltd_reading
             ,l_ctr_rdg_rec      => p_ctr_rdg_rec -- added 6398254
            );

         IF l_reading_type = 2 THEN
	    IF nvl(l_direction,'X') = 'A' THEN
	       IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	          IF (l_ltd_reading < l_prev_ltd_reading) THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
		      csi_ctr_gen_utility_pvt.put_line('3. LTD Reading should be in increasing orde for a CHANGE COUNTER...');
         END IF;          -- 8214848 - dsingire
		     csi_ctr_gen_utility_pvt.ExitWithErrMsg
                         ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                           p_token1_name    =>  'DIRECTION',
                           -- p_token1_val     =>  l_direction,
                           p_token1_val     =>  'an Ascending',
  	                   p_token2_name    =>  'MODE',
	                   p_token2_val     =>  l_mode,
  	                   p_token3_name    =>  'CTR_NAME',
	                   p_token3_val     =>  l_ctr_name
                         );
	          END IF;
	       END IF;
	    ELSIF nvl(l_direction,'X') = 'D' THEN
	       IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	          IF (l_ltd_reading > l_prev_ltd_reading) THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
		      csi_ctr_gen_utility_pvt.put_line('4. LTD Reading should be in decreasing order for a CHANGE COUNTER...');
         END IF;          -- 8214848 - dsingire
		     csi_ctr_gen_utility_pvt.ExitWithErrMsg
                         ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                           p_token1_name    =>  'DIRECTION',
                           -- p_token1_val     =>  l_direction,
                           p_token1_val     =>  'a Descending',
  	                   p_token2_name    =>  'MODE',
	                   p_token2_val     =>  l_mode,
  	                   p_token3_name    =>  'CTR_NAME',
	                   p_token3_val     =>  l_ctr_name
                         );
	          END IF;
               END IF;
            END IF;
         END IF;
      ELSE
         Calculate_Rollover_Reading
            ( p_prev_net_rdg      => l_prev_net_reading
             ,p_prev_ltd_rdg      => l_prev_ltd_reading
             ,p_curr_rdg          => p_ctr_rdg_rec.counter_reading
             ,p_prev_rdg          => l_prev_ctr_reading
             ,p_rollover_fm       => l_rollover_last_rdg
             ,p_rollover_to       => l_rollover_first_rdg
             ,px_net_rdg          => l_net_reading
             ,px_ltd_rdg          => l_ltd_reading
            );
      END IF; -- automatic_rollover_flag check
      -- Need to pass back the Net and LTD Readings
      p_ctr_rdg_rec.net_reading := l_net_reading;
      p_ctr_rdg_rec.life_to_date_reading := l_ltd_reading;
      --
      -- Call Table Handler to insert into CSI_COUNTER_READINGS
      -- Check and Generate Counter_value_id
      IF p_ctr_rdg_rec.counter_value_id IS NULL OR
	 p_ctr_rdg_rec.counter_value_id = FND_API.G_MISS_NUM THEN
	 WHILE l_process_flag LOOP
	    select CSI_COUNTER_READINGS_S.nextval
	    into p_ctr_rdg_rec.counter_value_id from dual;
	    IF NOT Counter_Value_Exists(p_ctr_rdg_rec.counter_value_id) THEN
	       l_process_flag := FALSE;
	    END IF;
	 END LOOP;
      ELSE
	 IF Counter_Value_Exists(p_ctr_rdg_rec.counter_value_id) THEN
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
		    ( p_msg_name     => 'CSI_API_CTR_VALUE_EXISTS',
		      p_token1_name  => 'CTR_NAME',
		      p_token1_val   => l_ctr_name,
		      p_token2_name  => 'CTR_VALUE_ID',
		      p_token2_val   => to_char(p_ctr_rdg_rec.counter_value_id),
		      p_token3_name  => 'MODE',
		      p_token3_val   => l_mode
		    );
	 END IF;
      END IF;
      --

      --
      CSI_COUNTER_READINGS_PKG.Insert_Row(
	  px_COUNTER_VALUE_ID         =>  p_ctr_rdg_rec.counter_value_id
	 ,p_COUNTER_ID                =>  p_ctr_rdg_rec.counter_id
	 ,p_VALUE_TIMESTAMP           =>  p_ctr_rdg_rec.value_timestamp
	 ,p_COUNTER_READING           =>  p_ctr_rdg_rec.counter_reading
	 ,p_RESET_MODE                =>  p_ctr_rdg_rec.reset_mode    -- NULL 6398254
	 ,p_RESET_REASON              =>  p_ctr_rdg_rec.reset_reason   --NULL  6398254
	 ,p_ADJUSTMENT_TYPE           =>  p_ctr_rdg_rec.adjustment_type
	 ,p_ADJUSTMENT_READING        =>  p_ctr_rdg_rec.adjustment_reading
	 ,p_OBJECT_VERSION_NUMBER     =>  p_ctr_rdg_rec.object_version_number
	 ,p_LAST_UPDATE_DATE          =>  SYSDATE
	 ,p_LAST_UPDATED_BY           =>  l_user_id
	 ,p_CREATION_DATE             =>  SYSDATE
	 ,p_CREATED_BY                =>  l_user_id
	 ,p_LAST_UPDATE_LOGIN         =>  l_conc_login_id
	 ,p_ATTRIBUTE1                =>  p_ctr_rdg_rec.attribute1
	 ,p_ATTRIBUTE2                =>  p_ctr_rdg_rec.attribute2
	 ,p_ATTRIBUTE3                =>  p_ctr_rdg_rec.attribute3
	 ,p_ATTRIBUTE4                =>  p_ctr_rdg_rec.attribute4
	 ,p_ATTRIBUTE5                =>  p_ctr_rdg_rec.attribute5
	 ,p_ATTRIBUTE6                =>  p_ctr_rdg_rec.attribute6
	 ,p_ATTRIBUTE7                =>  p_ctr_rdg_rec.attribute7
	 ,p_ATTRIBUTE8                =>  p_ctr_rdg_rec.attribute8
	 ,p_ATTRIBUTE9                =>  p_ctr_rdg_rec.attribute9
	 ,p_ATTRIBUTE10               =>  p_ctr_rdg_rec.attribute10
	 ,p_ATTRIBUTE11               =>  p_ctr_rdg_rec.attribute11
	 ,p_ATTRIBUTE12               =>  p_ctr_rdg_rec.attribute12
	 ,p_ATTRIBUTE13               =>  p_ctr_rdg_rec.attribute13
	 ,p_ATTRIBUTE14               =>  p_ctr_rdg_rec.attribute14
	 ,p_ATTRIBUTE15               =>  p_ctr_rdg_rec.attribute15
	 ,p_ATTRIBUTE16               =>  p_ctr_rdg_rec.attribute16
	 ,p_ATTRIBUTE17               =>  p_ctr_rdg_rec.attribute17
	 ,p_ATTRIBUTE18               =>  p_ctr_rdg_rec.attribute18
	 ,p_ATTRIBUTE19               =>  p_ctr_rdg_rec.attribute19
	 ,p_ATTRIBUTE20               =>  p_ctr_rdg_rec.attribute20
	 ,p_ATTRIBUTE21               =>  p_ctr_rdg_rec.attribute21
	 ,p_ATTRIBUTE22               =>  p_ctr_rdg_rec.attribute22
	 ,p_ATTRIBUTE23               =>  p_ctr_rdg_rec.attribute23
	 ,p_ATTRIBUTE24               =>  p_ctr_rdg_rec.attribute24
	 ,p_ATTRIBUTE25               =>  p_ctr_rdg_rec.attribute25
	 ,p_ATTRIBUTE26               =>  p_ctr_rdg_rec.attribute26
	 ,p_ATTRIBUTE27               =>  p_ctr_rdg_rec.attribute27
	 ,p_ATTRIBUTE28               =>  p_ctr_rdg_rec.attribute28
	 ,p_ATTRIBUTE29               =>  p_ctr_rdg_rec.attribute29
	 ,p_ATTRIBUTE30               =>  p_ctr_rdg_rec.attribute30
	 ,p_ATTRIBUTE_CATEGORY        =>  p_ctr_rdg_rec.attribute_category
	 ,p_MIGRATED_FLAG             =>  'N'
	 ,p_COMMENTS                  =>  p_ctr_rdg_rec.comments
	 ,p_LIFE_TO_DATE_READING      =>  p_ctr_rdg_rec.life_to_date_reading
	 ,p_TRANSACTION_ID            =>  p_txn_rec.transaction_id
	 ,p_AUTOMATIC_ROLLOVER_FLAG   =>  p_ctr_rdg_rec.automatic_rollover_flag
	 ,p_INCLUDE_TARGET_RESETS     =>  NULL
	 ,p_SOURCE_COUNTER_VALUE_ID   =>  NULL
	 ,p_NET_READING               =>  p_ctr_rdg_rec.net_reading
	 ,p_DISABLED_FLAG             =>  'N'
	 ,p_SOURCE_CODE               =>  p_ctr_rdg_rec.source_code
	 ,p_SOURCE_LINE_ID            =>  p_ctr_rdg_rec.source_line_id
	 ,p_INITIAL_READING_FLAG      =>  p_ctr_rdg_rec.initial_reading_flag
       );

       --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
       --for bug 7374316
       CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
           p_api_version           =>  1.0
	  ,p_commit                =>  fnd_api.g_false
	  ,p_init_msg_list         =>  fnd_api.g_true
	  ,p_validation_level      =>  fnd_api.g_valid_level_full
          ,p_counter_id            =>  p_ctr_rdg_rec.counter_id
          ,px_ctr_val_max_seq_no   =>  p_ctr_rdg_rec.counter_value_id
          ,x_return_status         =>  x_return_status
	  ,x_msg_count             =>  x_msg_count
	  ,x_msg_data              =>  x_msg_data
        );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
  	    csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
      END IF;          -- 8214848 - dsingire
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
	       x_msg_data := FND_MSG_PUB.GET
	       (  l_msg_index,
		  FND_API.G_FALSE
	       );
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	          csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
         END IF;          -- 8214848 - dsingire
	       l_msg_index := l_msg_index + 1;
	       l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      --
      BEGIN
          select 'Y'
          into   l_target_ctr_exist
          from   CSI_COUNTER_RELATIONSHIPS ccr,
                 CSI_COUNTERS_B ccv,
                 CSI_COUNTERS_TL cct
          where  ccr.source_counter_id = p_ctr_rdg_rec.counter_id
          and    ccr.relationship_type_code = 'CONFIGURATION'
          and    nvl(ccr.active_start_date,sysdate) <= p_ctr_rdg_rec.value_timestamp
          and    nvl(ccr.active_end_date,(sysdate+1)) > p_ctr_rdg_rec.value_timestamp
          and    ccv.counter_id = ccr.object_counter_id
          and    ccv.counter_id = cct.counter_id
          and    cct.language = USERENV('LANG');
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_target_ctr_exist := 'N';
        WHEN TOO_MANY_ROWS THEN
           l_target_ctr_exist := 'Y';
    END;

      --
      IF l_target_ctr_exist = 'Y' THEN
         -- Exclude Bi-Directional Counters as Target counters won't be defined for them.
	 -- Need to Compute Target Counters
	 -- For this we need to pass the usage of the current counter based on the current reading
	 -- If Reading type is 'ABSOLUTE' then Usage is (Curr Rdg - Prev Rdg)
	 -- If Reading type is 'CHANGE' then Usage is (Curr Rdg)
	 --
	 l_target_ctr_rec := l_temp_ctr_rdg_rec;
	 --
	 l_target_ctr_rec.counter_value_id := p_ctr_rdg_rec.counter_value_id; -- source_counter_value_id
	 l_target_ctr_rec.counter_id := p_ctr_rdg_rec.counter_id;
	 l_target_ctr_rec.value_timestamp := p_ctr_rdg_rec.value_timestamp;
	 l_target_ctr_rec.adjustment_reading := p_ctr_rdg_rec.adjustment_reading;
	 l_target_ctr_rec.adjustment_type := p_ctr_rdg_rec.adjustment_type;
	 l_target_ctr_rec.source_code := p_ctr_rdg_rec.source_code;
	 l_target_ctr_rec.source_line_id := p_ctr_rdg_rec.source_line_id;
         l_target_ctr_rec.comments := p_ctr_rdg_rec.comments;
	 --
	 IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
	    -- For rollover Usage = curr - prev + roll from - roll to
	    --
	    -- l_target_ctr_rec.counter_reading := ABS(p_ctr_rdg_rec.counter_reading-nvl(l_prev_ctr_reading,0) + l_rollover_last_rdg - l_rollover_first_rdg);
	    l_target_ctr_rec.counter_reading := p_ctr_rdg_rec.counter_reading-nvl(l_prev_ctr_reading,0) + l_rollover_last_rdg - l_rollover_first_rdg;
	 ELSE
	    IF l_reading_type = 1 THEN
	       -- l_target_ctr_rec.counter_reading := ABS(p_ctr_rdg_rec.counter_reading - nvl(l_prev_ctr_reading,0));
	       IF l_direction = 'D' THEN
                  l_target_ctr_rec.counter_reading := ABS(p_ctr_rdg_rec.counter_reading - nvl(l_prev_ctr_reading,0));
               ELSE
                  l_target_ctr_rec.counter_reading := p_ctr_rdg_rec.counter_reading - nvl(l_prev_ctr_reading,0);
               END IF;
	    ELSIF l_reading_type = 2 THEN
	       -- l_target_ctr_rec.counter_reading := ABS(p_ctr_rdg_rec.counter_reading);
	       l_target_ctr_rec.counter_reading := p_ctr_rdg_rec.counter_reading;
	    END IF;
	 END IF; -- Rollover flag check
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('Target counter reading = '||to_char(l_target_ctr_rec.counter_reading));
         csi_ctr_gen_utility_pvt.put_line('Calling Compute_Target_Counters 1...');
        END IF;          -- 8214848 - dsingire

	 --
	 -- Call Compute_Target_Counters
	 --

	 Compute_Target_Counters
	    (
	      p_api_version           =>  1.0
	     ,p_commit                =>  p_commit
	     ,p_init_msg_list         =>  p_init_msg_list
	     ,p_validation_level      =>  p_validation_level
	     ,p_txn_rec               =>  p_txn_rec
	     ,p_ctr_rdg_rec           =>  l_target_ctr_rec
	     ,p_mode                  =>  'CREATE'
	     ,x_return_status         =>  x_return_status
	     ,x_msg_count             =>  x_msg_count
	     ,x_msg_data              =>  x_msg_data
	   );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Target_Counters API ');
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
      END IF; -- l_target_ctr_exist check
      --
      -- Since Bi-Directional counter readings cannot impact Later readings no need to proceed further.
      -- Also re-sets are not allowed for such counters
      IF l_direction = 'B' and l_reading_type = 1 THEN
         Raise Skip_Process;
      END IF;
      --
      -- Since Automatic rollover has to be the last reading, no need to proceed further
      --
      IF NVL(p_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
         Raise Skip_Process;
      END IF;
      --
      -- Following variables will be set inside the loop
      l_previous_rdg := p_ctr_rdg_rec.counter_reading;
      l_previous_net := p_ctr_rdg_rec.net_reading;
      l_previous_ltd := p_ctr_rdg_rec.life_to_date_reading;

      -- For Adjustments or next reading was a reset then
      -- adjust the Net Reading of Subsequent readings
      -- Re-calculate the formula counters only if the subsequent net reading changes
      -- Re-calculate Target counters irrespective of net reading changes.  *
      IF l_reading_type = 2 OR
         (p_ctr_rdg_rec.adjustment_reading IS NOT NULL AND
          p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM AND
          p_ctr_rdg_rec.adjustment_reading <> 0) OR
         NVL(l_next_reset_mode,'X') = 'SOFT' THEN
         -- *
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Re-calculating target counters');
         END IF;          -- 8214848 - dsingire
         l_update_loop := TRUE;
         FOR later_rdg IN LATER_READINGS_CUR(p_ctr_rdg_rec.counter_id,p_ctr_rdg_rec.value_timestamp)

         LOOP

            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                csi_ctr_gen_utility_pvt.put_line('Updating Later Readings for Ctr Value ID : '||to_char(later_rdg.counter_value_id));
            END IF;          -- 8214848 - dsingire

            IF NVL(later_rdg.reset_mode,'X') = 'SOFT' THEN
                IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                csi_ctr_gen_utility_pvt.put_line('SOFT and re-calculating net readings');
                END IF;          -- 8214848 - dsingire

			    -- added IF for Bug 9148094

				--l_update_net_flag :=  NVL(fnd_profile.value('CSI: UPDATE NET READINGS UPON RESET'), 'Y');
				csi_ctr_gen_utility_pvt.put_line(' Update Net Reading Flag : '||l_update_net_flag);
				IF l_update_net_flag = 'Y' THEN
					UPDATE CSI_COUNTER_READINGS
				    set net_reading = later_rdg.counter_reading, -- l_previous_net
					life_to_date_reading = l_previous_ltd,
					last_update_date = sysdate,
					last_updated_by = l_user_id
					where counter_value_id = later_rdg.counter_value_id;
					l_previous_net := later_rdg.counter_reading;
				ELSE
					UPDATE CSI_COUNTER_READINGS
					set net_reading = l_previous_net,
					life_to_date_reading = l_previous_ltd,
					last_update_date = sysdate,
					last_updated_by = l_user_id
					where counter_value_id = later_rdg.counter_value_id;
				END IF;

            ELSE

	       Calculate_Net_Reading
		  ( p_prev_net_rdg      => l_previous_net
		   ,p_prev_ltd_rdg      => l_previous_ltd
		   ,p_curr_rdg          => later_rdg.counter_reading
		   ,p_prev_rdg          => l_previous_rdg
		   ,p_curr_adj          => later_rdg.adjustment_reading
		   ,p_rdg_type          => l_reading_type
                   ,p_direction         => l_direction
		   ,px_net_rdg          => l_net_reading
		   ,px_ltd_rdg          => l_ltd_reading
                  ,l_ctr_rdg_rec       => p_ctr_rdg_rec -- added 6398254
		  );
               UPDATE CSI_COUNTER_READINGS
               set net_reading = l_net_reading,
                   life_to_date_reading = l_ltd_reading,
                   last_update_date = sysdate,
                   last_updated_by = l_user_id
               where counter_value_id = later_rdg.counter_value_id;
               --
               l_previous_net := l_net_reading;
               l_previous_ltd := l_ltd_reading;
            END IF;
            --
            --
            -- Re-calculate Compute Target Counters
            -- For Resets which did not include Targets before, no need to Re-compute
            --
            IF later_rdg.reset_mode IS NULL OR
              (later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y') THEN
	       l_target_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_target_ctr_rec.counter_value_id := later_rdg.counter_value_id; -- source_counter_value_id
	       l_target_ctr_rec.counter_id := p_ctr_rdg_rec.counter_id;
	       l_target_ctr_rec.value_timestamp := later_rdg.value_timestamp;
	       l_target_ctr_rec.adjustment_reading := later_rdg.adjustment_reading;
	       l_target_ctr_rec.adjustment_type := later_rdg.adjustment_type;
	       l_target_ctr_rec.comments := later_rdg.comments;
	       --
	       IF later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y' THEN
		  -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading);
		  l_target_ctr_rec.counter_reading := later_rdg.counter_reading;
	       ELSE
		  IF l_reading_type = 1 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading - nvl(l_previous_rdg,0));
		     l_target_ctr_rec.counter_reading := later_rdg.counter_reading - nvl(l_previous_rdg,0);
		  ELSIF l_reading_type = 2 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading);
		     l_target_ctr_rec.counter_reading := later_rdg.counter_reading;
		  END IF;
	       END IF;
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                csi_ctr_gen_utility_pvt.put_line('Calling Compute_Target_Counters for Update ...');
               END IF;          -- 8214848 - dsingire
	       Compute_Target_Counters
		  (
		    p_api_version           =>  1.0
		   ,p_commit                =>  p_commit
		   ,p_init_msg_list         =>  p_init_msg_list
		   ,p_validation_level      =>  p_validation_level
		   ,p_txn_rec               =>  p_txn_rec
		   ,p_ctr_rdg_rec           =>  l_target_ctr_rec
		   ,p_mode                  =>  'UPDATE'
		   ,x_return_status         =>  x_return_status
		   ,x_msg_count             =>  x_msg_count
		   ,x_msg_data              =>  x_msg_data
		 );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Target_Counters API ');
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
            END IF;  -- End of Target counter call check
	    --
            l_previous_rdg := later_rdg.counter_reading;
         END LOOP; -- Later Readings loop
      END IF; -- Condition to loop thru' later readings
      --
      -- If the above loop was not executed then to re-calculate the Traget counters we loop thru'
      -- This is because target counter readings could change even if the net reading did not change.
      --
      l_previous_rdg := p_ctr_rdg_rec.counter_reading;
      --
      IF NOT l_update_loop THEN
         FOR later_rdg IN LATER_READINGS_CUR(p_ctr_rdg_rec.counter_id,p_ctr_rdg_rec.value_timestamp)
         LOOP
              IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('6398254: If not update_loop');
              END IF;          -- 8214848 - dsingire
            -- Re-calculate Compute Target Counters
            -- For Resets which did not include Targets before, no need to Re-compute
            --
            IF later_rdg.reset_mode IS NULL OR
              (later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y') THEN
	       l_target_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_target_ctr_rec.counter_value_id := later_rdg.counter_value_id; -- source_counter_value_id
	       l_target_ctr_rec.counter_id := p_ctr_rdg_rec.counter_id;
	       l_target_ctr_rec.value_timestamp := later_rdg.value_timestamp;
	       l_target_ctr_rec.adjustment_reading := later_rdg.adjustment_reading;
	       l_target_ctr_rec.adjustment_type := later_rdg.adjustment_type;
	       l_target_ctr_rec.comments := later_rdg.comments;
	       --
	       IF later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y' THEN
		  -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading);
		  l_target_ctr_rec.counter_reading := later_rdg.counter_reading;
	       ELSE
		  IF l_reading_type = 1 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading - nvl(l_previous_rdg,0));
		     l_target_ctr_rec.counter_reading := later_rdg.counter_reading - nvl(l_previous_rdg,0);
		  ELSIF l_reading_type = 2 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading);
		     l_target_ctr_rec.counter_reading := later_rdg.counter_reading;
		  END IF;
	       END IF;
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.put_line('Calling Compute_Target_Counters for Update 2...');
               END IF;          -- 8214848 - dsingire
	       Compute_Target_Counters
		  (
		    p_api_version           =>  1.0
		   ,p_commit                =>  p_commit
		   ,p_init_msg_list         =>  p_init_msg_list
		   ,p_validation_level      =>  p_validation_level
		   ,p_txn_rec               =>  p_txn_rec
		   ,p_ctr_rdg_rec           =>  l_target_ctr_rec
		   ,p_mode                  =>  'UPDATE'
		   ,x_return_status         =>  x_return_status
		   ,x_msg_count             =>  x_msg_count
		   ,x_msg_data              =>  x_msg_data
		 );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Target_Counters API ');
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
            END IF;  -- End of Target counter call check
	    --
            l_previous_rdg := later_rdg.counter_reading;
         END LOOP;
      END IF; -- l_update_loop check
   END IF; -- Current counter reading not null check
   --
   IF NVL(p_ctr_rdg_rec.reset_mode,FND_API.G_MISS_CHAR) = 'SOFT' THEN
      -- Introduce a delay. Basically, value_timestamp of reset should be slightly > than the curr Reading
      -- For Reset Mode insert a separate record in CSI_COUNTER_READINGS with the Reset counter reading.
      -- Net and LTD readings are from the previous counter reading.
      -- If only Reset is performed then no need to introduce the delay.
      --
      l_reset_rdg_rec := l_temp_ctr_rdg_rec;
      --

      IF NVL(p_ctr_rdg_rec.counter_reading,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
      AND (p_ctr_rdg_rec.counter_reading <> p_ctr_rdg_rec.reset_counter_reading) THEN
         l_reset_timestamp := p_ctr_rdg_rec.value_timestamp + (1/(24*60*60)); -- Add 1 Sec
      ELSE -- Only Reset is performed
	 l_reset_timestamp := p_ctr_rdg_rec.value_timestamp;
      END IF;
      --
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('Reset Timestamp is : '||to_char(l_reset_timestamp,'DD-MON-YYYY HH24:MI:SS'));
      END IF;          -- 8214848 - dsingire

      --
      l_reset_rdg_rec.counter_id := p_ctr_rdg_rec.counter_id;
      l_reset_rdg_rec.value_timestamp := l_reset_timestamp;
      l_reset_rdg_rec.counter_reading := p_ctr_rdg_rec.reset_counter_reading;
      l_reset_rdg_rec.source_code := p_ctr_rdg_rec.source_code;
      l_reset_rdg_rec.source_line_id := p_ctr_rdg_rec.source_line_id;
      l_reset_rdg_rec.reset_mode := p_ctr_rdg_rec.reset_mode;
      l_reset_rdg_rec.reset_reason := p_ctr_rdg_rec.reset_reason;
      --
      -- If counter reading had been captured along with the reset then net and ltd would take the
      -- calculated values stored in p_ctr_rdg_rec. Otherwise, use the previous values.
      --
	  csi_ctr_gen_utility_pvt.put_line('lakmohan : p_ctr_rdg_rec.counter_id : '||p_ctr_rdg_rec.counter_id);
	  csi_ctr_gen_utility_pvt.put_line('lakmohan : l_target_ctr_rec.counter_value_id : '||l_target_ctr_rec.counter_value_id);
	  csi_ctr_gen_utility_pvt.put_line('lakmohan : l_reset_rdg_rec.counter_value_id : '||l_reset_rdg_rec.counter_value_id);
      IF NVL(p_ctr_rdg_rec.net_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
		 -- added IF for Bug 9148094
		    --l_update_net_flag :=  NVL(fnd_profile.value('CSI: UPDATE NET READINGS UPON RESET'), 'Y');
			csi_ctr_gen_utility_pvt.put_line(' Update Net Reading Flag : '||l_update_net_flag);
			IF l_update_net_flag = 'Y' THEN
				l_reset_rdg_rec.net_reading := p_ctr_rdg_rec.reset_counter_reading;
			ELSE
				l_reset_rdg_rec.net_reading := l_prev_net_reading;
			END IF;
      ELSE
         l_reset_rdg_rec.net_reading := p_ctr_rdg_rec.net_reading;
      END IF;
      IF NVL(p_ctr_rdg_rec.life_to_date_reading,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         l_reset_rdg_rec.life_to_date_reading := l_prev_ltd_reading;
      ELSE
         l_reset_rdg_rec.life_to_date_reading := p_ctr_rdg_rec.life_to_date_reading;
      END IF;
      --
      -- Generate the Value_id
      l_process_flag := TRUE;
      WHILE l_process_flag LOOP
         select CSI_COUNTER_READINGS_S.nextval
         into l_reset_rdg_rec.counter_value_id from dual;
         IF NOT Counter_Value_Exists(l_reset_rdg_rec.counter_value_id) THEN
            l_process_flag := FALSE;
         END IF;
      END LOOP;
      --
      -- If only Reset is captured then we need to pass the reset counter value_id to p_ctr_rdg_rec
      --
      IF NVL(p_ctr_rdg_rec.counter_value_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
         p_ctr_rdg_rec.counter_value_id := l_reset_rdg_rec.counter_value_id;
      END IF;
      -- Call the Table Handler to insert the Reset Reading into CSI_COUNTER_READINGS
      --
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('Inserting Reset Record with Ctr Value ID '||to_char(l_reset_rdg_rec.counter_value_id));
      END IF;          -- 8214848 - dsingire

      --
      CSI_COUNTER_READINGS_PKG.Insert_Row(
	  px_COUNTER_VALUE_ID         =>  l_reset_rdg_rec.counter_value_id
	 ,p_COUNTER_ID                =>  l_reset_rdg_rec.counter_id
	 ,p_VALUE_TIMESTAMP           =>  l_reset_rdg_rec.value_timestamp
	 ,p_COUNTER_READING           =>  l_reset_rdg_rec.counter_reading
	 ,p_RESET_MODE                =>  l_reset_rdg_rec.reset_mode
	 ,p_RESET_REASON              =>  l_reset_rdg_rec.reset_reason
	 ,p_ADJUSTMENT_TYPE           =>  NULL
	 ,p_ADJUSTMENT_READING        =>  NULL
	 ,p_OBJECT_VERSION_NUMBER     =>  1
	 ,p_LAST_UPDATE_DATE          =>  SYSDATE
	 ,p_LAST_UPDATED_BY           =>  l_user_id
	 ,p_CREATION_DATE             =>  SYSDATE
	 ,p_CREATED_BY                =>  l_user_id
	 ,p_LAST_UPDATE_LOGIN         =>  l_conc_login_id
	 ,p_ATTRIBUTE1                =>  l_reset_rdg_rec.attribute1
	 ,p_ATTRIBUTE2                =>  l_reset_rdg_rec.attribute2
	 ,p_ATTRIBUTE3                =>  l_reset_rdg_rec.attribute3
	 ,p_ATTRIBUTE4                =>  l_reset_rdg_rec.attribute4
	 ,p_ATTRIBUTE5                =>  l_reset_rdg_rec.attribute5
	 ,p_ATTRIBUTE6                =>  l_reset_rdg_rec.attribute6
	 ,p_ATTRIBUTE7                =>  l_reset_rdg_rec.attribute7
	 ,p_ATTRIBUTE8                =>  l_reset_rdg_rec.attribute8
	 ,p_ATTRIBUTE9                =>  l_reset_rdg_rec.attribute9
	 ,p_ATTRIBUTE10               =>  l_reset_rdg_rec.attribute10
	 ,p_ATTRIBUTE11               =>  l_reset_rdg_rec.attribute11
	 ,p_ATTRIBUTE12               =>  l_reset_rdg_rec.attribute12
	 ,p_ATTRIBUTE13               =>  l_reset_rdg_rec.attribute13
	 ,p_ATTRIBUTE14               =>  l_reset_rdg_rec.attribute14
	 ,p_ATTRIBUTE15               =>  l_reset_rdg_rec.attribute15
	 ,p_ATTRIBUTE16               =>  l_reset_rdg_rec.attribute16
	 ,p_ATTRIBUTE17               =>  l_reset_rdg_rec.attribute17
	 ,p_ATTRIBUTE18               =>  l_reset_rdg_rec.attribute18
	 ,p_ATTRIBUTE19               =>  l_reset_rdg_rec.attribute19
	 ,p_ATTRIBUTE20               =>  l_reset_rdg_rec.attribute20
	 ,p_ATTRIBUTE21               =>  l_reset_rdg_rec.attribute21
	 ,p_ATTRIBUTE22               =>  l_reset_rdg_rec.attribute22
	 ,p_ATTRIBUTE23               =>  l_reset_rdg_rec.attribute23
	 ,p_ATTRIBUTE24               =>  l_reset_rdg_rec.attribute24
	 ,p_ATTRIBUTE25               =>  l_reset_rdg_rec.attribute25
	 ,p_ATTRIBUTE26               =>  l_reset_rdg_rec.attribute26
	 ,p_ATTRIBUTE27               =>  l_reset_rdg_rec.attribute27
	 ,p_ATTRIBUTE28               =>  l_reset_rdg_rec.attribute28
	 ,p_ATTRIBUTE29               =>  l_reset_rdg_rec.attribute29
	 ,p_ATTRIBUTE30               =>  l_reset_rdg_rec.attribute30
	 ,p_ATTRIBUTE_CATEGORY        =>  l_reset_rdg_rec.attribute_category
	 ,p_MIGRATED_FLAG             =>  'N'
	 ,p_COMMENTS                  =>  l_reset_rdg_rec.comments
	 ,p_LIFE_TO_DATE_READING      =>  l_reset_rdg_rec.life_to_date_reading
	 ,p_TRANSACTION_ID            =>  p_txn_rec.transaction_id
	 ,p_AUTOMATIC_ROLLOVER_FLAG   =>  l_reset_rdg_rec.automatic_rollover_flag
	 ,p_INCLUDE_TARGET_RESETS     =>  p_ctr_rdg_rec.include_target_resets
	 ,p_SOURCE_COUNTER_VALUE_ID   =>  NULL
	 ,p_NET_READING               =>  l_reset_rdg_rec.net_reading
	 ,p_DISABLED_FLAG             =>  'N'
	 ,p_SOURCE_CODE               =>  l_reset_rdg_rec.source_code
	 ,p_SOURCE_LINE_ID            =>  l_reset_rdg_rec.source_line_id
	 ,p_INITIAL_READING_FLAG      =>  l_reset_rdg_rec.initial_reading_flag
       );

       --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
       --for bug 7374316
       CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
           p_api_version           =>  1.0
	  ,p_commit                =>  fnd_api.g_false
	  ,p_init_msg_list         =>  fnd_api.g_true
	  ,p_validation_level      =>  fnd_api.g_valid_level_full
          ,p_counter_id            =>  l_reset_rdg_rec.counter_id
          ,px_ctr_val_max_seq_no   =>  l_reset_rdg_rec.counter_value_id
          ,x_return_status         =>  x_return_status
	  ,x_msg_count             =>  x_msg_count
	  ,x_msg_data              =>  x_msg_data
        );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
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
     --   END IF;
      --
      --
      -- Compute Target counters if Include Target flag is checked
      IF NVL(p_ctr_rdg_rec.include_target_resets,'N') = 'Y' THEN
	 -- Re-calculate Compute Target Counters
	 l_target_ctr_rec := l_temp_ctr_rdg_rec;
	 --
	 l_target_ctr_rec.counter_value_id := l_reset_rdg_rec.counter_value_id; -- source_counter_value_id
	 l_target_ctr_rec.counter_id := l_reset_rdg_rec.counter_id;
	 l_target_ctr_rec.value_timestamp := l_reset_rdg_rec.value_timestamp;
	 l_target_ctr_rec.counter_reading := l_reset_rdg_rec.counter_reading;
         l_target_ctr_rec.source_code := l_reset_rdg_rec.source_code;
         l_target_ctr_rec.source_line_id := l_reset_rdg_rec.source_line_id;
         l_target_ctr_rec.reset_mode := l_reset_rdg_rec.reset_mode;
         l_target_ctr_rec.reset_reason := l_reset_rdg_rec.reset_reason;
         l_target_ctr_rec.comments := l_reset_rdg_rec.comments;
	 --
	  -- added 6398254
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('6398254: l_reset_rdg_rec.reset_reason' || l_reset_rdg_rec.reset_reason);
         csi_ctr_gen_utility_pvt.put_line('Calling Reset_Target_Counters 1...');
        END IF;          -- 8214848 - dsingire
	 -- Call Re-Compute Target Counters
	 Reset_Target_Counters
	    (
	      p_txn_rec               =>  p_txn_rec
	     ,p_ctr_rdg_rec           =>  l_target_ctr_rec
	     ,x_return_status         =>  x_return_status
             ,x_msg_count             =>  x_msg_count
             ,x_msg_data              =>  x_msg_data
	   );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    csi_ctr_gen_utility_pvt.put_line('ERROR FROM Reset_Target_Counters API ');
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
      END IF; -- Include Target Resets check
      --
      -- No need to compute Derived Filters for SOFT reset as it has the same net reading
      -- as the previous counter reading.
   END IF; -- Reset Mode check
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
   WHEN Skip_Process THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      FND_MSG_PUB.Count_And_Get
         ( p_count  =>  x_msg_count,
           p_data   =>  x_msg_data
         );
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO capture_counter_reading_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO capture_counter_reading_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO capture_counter_reading_pvt;
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
PROCEDURE Compute_Formula_Counters
   (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,p_ctr_rdg_rec           IN     csi_ctr_datastructures_pub.counter_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'COMPUTE_FORMULA_COUNTERS';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   l_rel_type                      VARCHAR2(30) := 'FORMULA';
   l_formula_text                  CSI_COUNTERS_B.formula_text%TYPE;
   l_cursor_handle                 INTEGER;  --Dynamic SQL cursor handler
   l_n_temp                        INTEGER;
   l_counter_reading               NUMBER;
   l_bind_var_value                NUMBER;
   l_bind_var_name                 VARCHAR2(255);
   l_other_src_captured            VARCHAR2(1);
   l_disabled_flag                 VARCHAR2(1);
   l_exists                        VARCHAR2(1);
   l_ctr_value_id                  NUMBER;
   l_process_flag                  BOOLEAN;
   l_mode                          VARCHAR2(30);
   Process_Next                    EXCEPTION;
   l_debug_level       NUMBER;    -- 8214848 - dsingire
   l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
   l_conc_login_id		NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
   l_ctr_val_max                 NUMBER := -1;
   l_net_reading_bind            NUMBER;
   l_value_max_timestamp         DATE;
   l_net_max_reading             NUMBER;

   --
   TYPE source_ctr_rec IS RECORD
     ( source_counter_id     NUMBER,
       bind_variable_name    VARCHAR2(255)
     );
   TYPE source_ctr_tbl IS TABLE OF source_ctr_rec INDEX BY BINARY_INTEGER;
   --
   l_src_ctr_tbl                  source_ctr_tbl;
   l_src_count                    NUMBER := 0;
   l_tmp_ctr_value_id             NUMBER;
   --
   CURSOR OBJECT_CTR_CUR(p_src_ctr_id IN NUMBER) IS
   select distinct object_counter_id
   from csi_counter_relationships
   where source_counter_id = p_src_ctr_id
   and   relationship_type_code = l_rel_type
   and   nvl(active_end_date,(sysdate+1)) > sysdate;
   --
   CURSOR SOURCE_CTR_CUR(p_obj_ctr_id IN NUMBER) IS
   select source_counter_id,bind_variable_name
   from csi_counter_relationships
   where object_counter_id = p_obj_ctr_id
   and   relationship_type_code = l_rel_type
   and   nvl(active_end_date,(sysdate+1)) > sysdate;
   --
   CURSOR GET_NET_RDG_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select net_reading
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp <= p_value_timestamp
   ORDER BY value_timestamp desc;
   --,counter_value_id desc;
   --
   CURSOR LATER_FORMULA_CUR(p_obj_ctr_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_value_id,value_timestamp
   from CSI_COUNTER_READINGS
   where counter_id = p_obj_ctr_id
   and   value_timestamp > p_value_timestamp
   and   nvl(disabled_flag,'N') = 'N'
   ORDER BY value_timestamp desc, counter_value_id desc;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  compute_formula_counters;
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
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire
   --
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line( 'compute_formula_counters'                  ||'-'||
                                  p_api_version                              ||'-'||
                                  nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                  nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                  nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
    csi_ctr_gen_utility_pvt.dump_counter_readings_rec(p_ctr_rdg_rec);
   END IF;          -- 8214848 - dsingire
   --

   --
   IF p_txn_rec.transaction_type_id in (88,91,92,94,95) THEN
      l_mode := 'Meter';
   ELSE
      l_mode := 'Counter';
   END IF;
   --
   IF p_ctr_rdg_rec.counter_id IS NULL OR
      p_ctr_rdg_rec.counter_id = FND_API.G_MISS_NUM THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
        ( p_msg_name    => 'CSI_API_CTR_INVALID',
          p_token1_name => 'MODE',
          p_token1_val  => l_mode
        );
   END IF;
   --
   IF p_ctr_rdg_rec.disabled_flag IS NULL OR
      p_ctr_rdg_rec.disabled_flag = FND_API.G_MISS_CHAR THEN
      l_disabled_flag := 'N';
   ELSE
      l_disabled_flag := p_ctr_rdg_rec.disabled_flag;
   END IF;
   --
   FOR obj_cur IN OBJECT_CTR_CUR(p_ctr_rdg_rec.counter_id) LOOP
      Begin
         l_formula_text := NULL;
	 Begin
	    select formula_text
	    into l_formula_text
	    from CSI_COUNTERS_B -- Need to be changed
	    where counter_id = obj_cur.object_counter_id
	    and   nvl(end_date_active,(sysdate+1)) > sysdate;
	 Exception
	    when no_data_found then
	       RAISE Process_Next;
	 End;
	 --
	 l_cursor_handle := dbms_sql.open_cursor;
	 l_formula_text := 'SELECT '||l_formula_text||' FROM DUAL';
	 --
	 Begin
	    DBMS_SQL.PARSE(l_cursor_handle, l_formula_text, dbms_sql.native);
	 Exception
	    when others then
	       csi_ctr_gen_utility_pvt.ExitWithErrMsg
		       ( p_msg_name     => 'CSI_API_CTR_FORMULA_DEF_INV',
			 p_token1_name  => 'FMLA_TEXT',
			 p_token1_val   => l_formula_text
		       );
	 End;
	 --
	 DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_counter_reading);
	 --
	 l_src_count := 0;
	 l_src_ctr_tbl.DELETE;
	 -- l_src_ctr_bl will be used when we re-calculate the later readings of this formula counter
	 -- as the set of source counters remain same
	 --
	 -- For each source_counter, get the bind_variable_name and the net reading
         l_other_src_captured := 'F';
         --
	 FOR sub_cur IN SOURCE_CTR_CUR(obj_cur.object_counter_id) LOOP
            -- Check whether the other source counters are read for the same timestamp.
            -- If so, then we can't disable the formula counter reading. We use the calculated net rdg.
            -- If the other source counters are not read then we can disable the formula counter reading.
            IF NVL(p_ctr_rdg_rec.disabled_flag,'N') = 'Y' AND
               sub_cur.source_counter_id <> p_ctr_rdg_rec.counter_id AND
               l_other_src_captured <> 'T' THEN
               Begin
                  select '1'
                  into l_exists from dual
                  where exists (select 'x'
                                from CSI_COUNTER_READINGS
                                where counter_id = sub_cur.source_counter_id
                                and   value_timestamp = p_ctr_rdg_rec.value_timestamp
                                and   nvl(disabled_flag,'N') <> 'Y');
                  l_other_src_captured := 'T';
               Exception
                  when no_data_found then
                     null;
               End;
            END IF;
            --
	    l_bind_var_name := ':'||ltrim(sub_cur.bind_variable_name);
	    l_src_count := l_src_count + 1;
	    l_src_ctr_tbl(l_src_count).source_counter_id := sub_cur.source_counter_id;
	    l_src_ctr_tbl(l_src_count).bind_variable_name := sub_cur.bind_variable_name;
	    --
            l_bind_var_value := NULL;
            --
      -- Bug 9230940
      /*OPEN GET_NET_RDG_CUR(sub_cur.source_counter_id,p_ctr_rdg_rec.value_timestamp);
	    FETCH GET_NET_RDG_CUR INTO l_bind_var_value;
	    CLOSE GET_NET_RDG_CUR;
      */
      BEGIN
      SELECT CTR_VAL_MAX_SEQ_NO INTO l_ctr_val_max
        FROM CSI_COUNTERS_B WHERE COUNTER_ID = sub_cur.source_counter_id;
       SELECT NET_READING, VALUE_TIMESTAMP
             INTO l_net_max_reading,
                  l_value_max_timestamp
       FROM CSI_COUNTER_READINGS WHERE COUNTER_VALUE_ID = NVL(l_ctr_val_max,-1);
       IF (l_debug_level > 0) THEN
        csi_ctr_gen_utility_pvt.put_line('l_ctr_val_max - ' || l_ctr_val_max );
       END IF;
      EXCEPTION
       WHEN OTHERS THEN
        l_ctr_val_max := -1;
      END;  --
       IF (l_value_max_timestamp <=  p_ctr_rdg_rec.value_timestamp
                AND NVL(l_ctr_val_max,-1) > 0) THEN
          -- The requested timestamp is greater than the timestamp of the
          -- CTR_VAL_MAX_SEQ_NO
          l_bind_var_value := l_net_max_reading;
          IF (l_debug_level > 0) THEN
            csi_ctr_gen_utility_pvt.put_line('Max Value counter id used');
          END IF;
     ELSE
	    OPEN GET_NET_RDG_CUR(sub_cur.source_counter_id,p_ctr_rdg_rec.value_timestamp);
	    FETCH GET_NET_RDG_CUR INTO l_bind_var_value;
	    CLOSE GET_NET_RDG_CUR;
     END IF;
     -- End Bug 9230940
	    DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_var_name, nvl(l_bind_var_value,0));
	 END LOOP; -- Sub Cursor
	 --
	 l_n_temp := dbms_sql.execute(l_cursor_handle);
	 --Get the value
	 IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
	    dbms_sql.column_value(l_cursor_handle,1,l_counter_reading);
	 ELSE
	    l_counter_reading := 0;
	 END IF;
	 --Close cursor
	 DBMS_SQL.close_cursor(l_cursor_handle);
         --
	 -- If the source counter reading is not disabled then we update/insert the row for formula
         -- counter.
	 --
         IF NVL(p_ctr_rdg_rec.disabled_flag,'N') <> 'Y' THEN
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.put_line('Trying to Update Object Ctr : '||to_char(obj_cur.object_counter_id));
            END IF;          -- 8214848 - dsingire
	    Update CSI_COUNTER_READINGS
	    set counter_reading = l_counter_reading,
		net_reading = l_counter_reading,
		life_to_date_reading = l_counter_reading,
		disabled_flag = 'N',
		last_update_date = sysdate,
		last_updated_by = l_user_id
	    where counter_id = obj_cur.object_counter_id
	    and   value_timestamp = p_ctr_rdg_rec.value_timestamp;
	    --
	    IF SQL%ROWCOUNT = 0 THEN -- If update was not successfull
	       -- Generate the Value_id for insert
	       l_process_flag := TRUE;
	       WHILE l_process_flag LOOP
		  select CSI_COUNTER_READINGS_S.nextval
		  into l_ctr_value_id from dual;
		  IF NOT Counter_Value_Exists(l_ctr_value_id) THEN
		     l_process_flag := FALSE;
		  END IF;
	       END LOOP;
	       --
              IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.put_line('Unable to Update. Inserting Object Ctr : '||to_char(obj_cur.object_counter_id));
              END IF;          -- 8214848 - dsingire
	       -- Call the Table Handler to insert the new reading
	       CSI_COUNTER_READINGS_PKG.Insert_Row(
		   px_COUNTER_VALUE_ID         =>  l_ctr_value_id
		  ,p_COUNTER_ID                =>  obj_cur.object_counter_id
		  ,p_VALUE_TIMESTAMP           =>  p_ctr_rdg_rec.value_timestamp
		  ,p_COUNTER_READING           =>  l_counter_reading
		  ,p_RESET_MODE                =>  NULL
		  ,p_RESET_REASON              =>  NULL
		  ,p_ADJUSTMENT_TYPE           =>  NULL
		  ,p_ADJUSTMENT_READING        =>  NULL
		  ,p_OBJECT_VERSION_NUMBER     =>  1
		  ,p_LAST_UPDATE_DATE          =>  SYSDATE
		  ,p_LAST_UPDATED_BY           =>  l_user_id
		  ,p_CREATION_DATE             =>  SYSDATE
		  ,p_CREATED_BY                =>  l_user_id
		  ,p_LAST_UPDATE_LOGIN         =>  l_conc_login_id
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
		  ,p_LIFE_TO_DATE_READING      =>  l_counter_reading
		  ,p_TRANSACTION_ID            =>  p_txn_rec.transaction_id
		  ,p_AUTOMATIC_ROLLOVER_FLAG   =>  NULL
		  ,p_INCLUDE_TARGET_RESETS     =>  NULL
		  ,p_SOURCE_COUNTER_VALUE_ID   =>  NULL
		  ,p_NET_READING               =>  l_counter_reading
		  ,p_DISABLED_FLAG             =>  'N'
		  ,p_SOURCE_CODE               =>  p_ctr_rdg_rec.source_code
		  ,p_SOURCE_LINE_ID            =>  p_ctr_rdg_rec.source_line_id
		  ,p_INITIAL_READING_FLAG      =>  p_ctr_rdg_rec.initial_reading_flag
		);

                --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
                --for bug 7374316
                CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
                   p_api_version           =>  1.0
                  ,p_commit                =>  fnd_api.g_false
                  ,p_init_msg_list         =>  fnd_api.g_true
                  ,p_validation_level      =>  fnd_api.g_valid_level_full
                  ,p_counter_id            =>  obj_cur.object_counter_id
                  ,px_ctr_val_max_seq_no   =>  l_ctr_value_id
                  ,x_return_status         =>  x_return_status
                  ,x_msg_count             =>  x_msg_count
                  ,x_msg_data              =>  x_msg_data
                );
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
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
            ELSE
                --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
                --for bug 7374316
                l_tmp_ctr_value_id := NULL;
                CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
                   p_api_version           =>  1.0
                  ,p_commit                =>  fnd_api.g_false
                  ,p_init_msg_list         =>  fnd_api.g_true
                  ,p_validation_level      =>  fnd_api.g_valid_level_full
                  ,p_counter_id            =>  obj_cur.object_counter_id
                  ,px_ctr_val_max_seq_no   =>  l_tmp_ctr_value_id
                  ,x_return_status         =>  x_return_status
                  ,x_msg_count             =>  x_msg_count
                  ,x_msg_data              =>  x_msg_data
                );
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
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
         ELSE -- If source counter is disabled then the corresponding formula counter reading is updated
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Disabling Obj Ctr '||to_char(obj_cur.object_counter_id));
            END IF;          -- 8214848 - dsingire
	    Update CSI_COUNTER_READINGS
	    set counter_reading = l_counter_reading,
		net_reading = l_counter_reading,
		life_to_date_reading = l_counter_reading,
		disabled_flag = decode(l_disabled_flag,'Y',decode(l_other_src_captured,'T','N','Y'),'N'),
		last_update_date = sysdate,
		last_updated_by = l_user_id
	    where counter_id = obj_cur.object_counter_id
	    and   value_timestamp = p_ctr_rdg_rec.value_timestamp;

            IF (l_disabled_flag = 'Y') AND (l_other_src_captured <> 'T') THEN
                --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
                --for bug 7374316
                l_tmp_ctr_value_id := NULL;
                CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
                   p_api_version           =>  1.0
                  ,p_commit                =>  fnd_api.g_false
                  ,p_init_msg_list         =>  fnd_api.g_true
                  ,p_validation_level      =>  fnd_api.g_valid_level_full
                  ,p_counter_id            =>  obj_cur.object_counter_id
                  ,px_ctr_val_max_seq_no   =>  l_tmp_ctr_value_id
                  ,x_return_status         =>  x_return_status
                  ,x_msg_count             =>  x_msg_count
                  ,x_msg_data              =>  x_msg_data
                );
                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
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
         END IF; -- Check for disabled_flag
	 --
	 -- Re-compute Later Formula Counter Readings
	 -- For this Formula counter, pick up the readings later than passed timestamp and re-compute
	 --
	 FOR later_rec IN LATER_FORMULA_CUR(obj_cur.object_counter_id,p_ctr_rdg_rec.value_timestamp) LOOP
	    l_cursor_handle := dbms_sql.open_cursor;
         -- Formula Text is reused from the above
	 --   l_formula_text := 'SELECT '||l_formula_text||' FROM DUAL';
	    --
	    Begin
	       DBMS_SQL.PARSE(l_cursor_handle, l_formula_text, dbms_sql.native);
	    Exception
	       when others then
		  csi_ctr_gen_utility_pvt.ExitWithErrMsg
			  ( p_msg_name     => 'CSI_API_CTR_FORMULA_DEF_INV',
			    p_token1_name  => 'FMLA_TEXT',
			    p_token1_val   => l_formula_text
			  );
	    End;
	    --
	    DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_counter_reading);
	    --
	    -- Since we already have the list of Source counters for this Object (Formula) we are using it.
	    IF l_src_ctr_tbl.count > 0 THEN
	       FOR src_rec in l_src_ctr_tbl.FIRST .. l_src_ctr_tbl.LAST LOOP
		  l_bind_var_name := ':'||ltrim(l_src_ctr_tbl(src_rec).bind_variable_name);
                  l_bind_var_value := NULL;
      -- Bug 9230940
		  /*OPEN GET_NET_RDG_CUR(l_src_ctr_tbl(src_rec).source_counter_id,later_rec.value_timestamp);
		  FETCH GET_NET_RDG_CUR INTO l_bind_var_value;
		  CLOSE GET_NET_RDG_CUR;*/
     BEGIN
      SELECT CTR_VAL_MAX_SEQ_NO INTO l_ctr_val_max
        FROM CSI_COUNTERS_B WHERE COUNTER_ID = l_src_ctr_tbl(src_rec).source_counter_id;
       SELECT NET_READING, VALUE_TIMESTAMP
             INTO l_net_max_reading,
                  l_value_max_timestamp
       FROM CSI_COUNTER_READINGS WHERE COUNTER_VALUE_ID = NVL(l_ctr_val_max,-1);
       IF (l_debug_level > 0) THEN
        csi_ctr_gen_utility_pvt.put_line('l_ctr_val_max - ' || l_ctr_val_max );
       END IF;
      EXCEPTION
       WHEN OTHERS THEN
        l_ctr_val_max := -1;
      END;  --
       IF (l_value_max_timestamp <=  later_rec.value_timestamp
                AND NVL(l_ctr_val_max,-1) > 0) THEN
          -- The requested timestamp is greater than the timestamp of the
          -- CTR_VAL_MAX_SEQ_NO
          l_bind_var_value := l_net_max_reading;
          IF (l_debug_level > 0) THEN
            csi_ctr_gen_utility_pvt.put_line('Max Value counter id used');
          END IF;
     ELSE
		  OPEN GET_NET_RDG_CUR(l_src_ctr_tbl(src_rec).source_counter_id,later_rec.value_timestamp);
		  FETCH GET_NET_RDG_CUR INTO l_bind_var_value;
		  CLOSE GET_NET_RDG_CUR;
     END IF;
     -- End Bug 9230940
		  DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_var_name, nvl(l_bind_var_value,0));
	       END LOOP;
	    END IF;
	    --
	    l_n_temp := dbms_sql.execute(l_cursor_handle);
	    --Get the value
	    IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
	       dbms_sql.column_value(l_cursor_handle,1,l_counter_reading);
	       -- Updating Formula Counter
              IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.put_line('Re-computing later formula Ctr Value ID '||to_char(later_rec.counter_value_id));
              END IF;          -- 8214848 - dsingire
	       Update CSI_COUNTER_READINGS
	       set counter_reading = l_counter_reading,
		   net_reading = l_counter_reading,
		   life_to_date_reading = l_counter_reading,
		   last_update_date = sysdate,
		   last_updated_by = l_user_id
	       where counter_value_id = later_rec.counter_value_id;
	    ELSE
	       l_counter_reading := 0;
	    END IF;
	    --Close cursor
	    DBMS_SQL.close_cursor(l_cursor_handle);
	 END LOOP; -- Later Formula Readings Loop
      Exception
         when Process_Next then
            null;
      End;
   END LOOP; -- Obj Cursor
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
      ROLLBACK TO compute_formula_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO compute_formula_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO compute_formula_counters;
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
END Compute_Formula_Counters;
--
PROCEDURE Compute_Derive_Counters(
    P_Api_Version           IN   NUMBER,
    P_Init_Msg_List         IN   VARCHAR2,
    P_Commit                IN   VARCHAR2,
    p_validation_level      IN   NUMBER,
    p_txn_rec               IN OUT NOCOPY  csi_datastructures_pub.transaction_rec,
    p_ctr_rdg_rec           IN   csi_ctr_datastructures_pub.counter_readings_rec,
    p_mode                  IN   VARCHAR2,
    X_Return_Status         OUT  NOCOPY VARCHAR2,
    X_Msg_Count             OUT  NOCOPY NUMBER,
    X_Msg_Data              OUT  NOCOPY VARCHAR2
    )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'COMPUTE_DERIVE_COUNTERS';
  l_msg_index               NUMBER;
  l_msg_count               NUMBER;
  -- Start fix for bug 6852415, part 1 of 3
  CURSOR base_ctrs IS
    SELECT  counter_id      AS base_ctr_id,
            value_timestamp AS base_ctr_timestamp
    FROM    csi_counter_readings
    WHERE   counter_value_id = p_ctr_rdg_rec.counter_value_id;
  CURSOR ctrs_to_be_calc(base_ctr_id NUMBER, base_ctr_timestamp DATE) IS
    SELECT  counter_id,
            derive_function,
            derive_counter_id,
            derive_property_id,
            filter_reading_count,
            filter_type,
            filter_time_uom
    FROM    csi_counters_b
    WHERE   derive_counter_id = base_ctr_id
    AND     NVL(start_date_active, base_ctr_timestamp) <= base_ctr_timestamp
    AND     NVL(end_date_active, (base_ctr_timestamp + 1)) > base_ctr_timestamp;
/*
  CURSOR CTRS_TO_BE_CALC IS
  SELECT ctr.counter_id, ctr.derive_function,
  ctr.derive_counter_id, ctr.derive_property_id,ctr.filter_reading_count,ctr.filter_type,
  ctr.filter_time_uom, cv.value_timestamp as new_rdg_dt, cv.counter_id as base_ctr_id
  FROM CSI_COUNTERS_B ctr, CSI_COUNTER_READINGS cv
  WHERE cv.counter_value_id = p_ctr_rdg_rec.counter_value_id
  AND   ctr.derive_counter_id = cv.counter_id
  AND   NVL(ctr.start_date_active,cv.value_timestamp) <= cv.value_timestamp
  AND   NVL(ctr.end_date_active,(cv.value_timestamp+1)) > cv.value_timestamp;
*/
  -- End fix for bug 6852415, part 1 of 3
  CURSOR DER_FILTERS(b_counter_id IN NUMBER) IS
  SELECT filt.counter_property_id, filt.seq_no,filt.left_parent left_paren,
         filt.right_parent right_paren, filt.relational_operator,
         filt.logical_operator, filt.right_value,
         pro.property_data_type
  FROM CSI_COUNTER_DERIVED_FILTERS filt, CSI_COUNTER_PROPERTIES_B pro
  WHERE filt.counter_id = b_counter_id
  AND pro.counter_property_id(+) = filt.counter_property_id;
  --
  CURSOR GET_TIME_UOM_CUR(p_filter_time_uom IN VARCHAR2) IS
  SELECT uom_code
  FROM OKC_TIME_CODE_UNITS_V
  WHERE uom_code=p_filter_time_uom;
  --
  l_sqlstr_init          VARCHAR2(2000);
  l_sqlstr               VARCHAR2(2000);
  l_sqlwhere             VARCHAR2(1000);
  l_sqlfrom              VARCHAR2(1000);
  l_cursor_handle        NUMBER;
  l_ctr_value            NUMBER;
  l_n_temp               NUMBER;
  l_ctr_value_id         NUMBER;
  l_process_flag         BOOLEAN;
  l_ctr_in               csi_ctr_datastructures_pub.counter_readings_rec;
  l_temp_ctr_rdg_rec     csi_ctr_datastructures_pub.counter_readings_rec;
  --
  --variable and arrays for binding dbmssql
  TYPE FILTS IS RECORD(
      BINDNAME_RIGHTVAL  VARCHAR2(240),
      BINDVAL_RIGHTVAL   VARCHAR2(240),
      BINDNAME_CTRPROPID VARCHAR2(240),
      BINDVAL_CTRPROPID  NUMBER
    );
  --
  TYPE T1 is TABLE OF FILTS index by binary_integer;
  T2 T1;
  i NUMBER := 1;
  lj NUMBER := 1;
  --
  BINDVAL_DERIVECTRID     NUMBER;
  --
  l_bind_varname          VARCHAR2(240);
  l_bind_varvalc          VARCHAR2(240);
  l_bind_varvaln          NUMBER;
  l_debug_level       NUMBER;    -- 8214848 - dsingire
  l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
  l_conc_login_id		  NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  compute_derive_counters;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('Inside Compute_Derive_Counters...');
    csi_ctr_gen_utility_pvt.dump_counter_readings_rec(p_ctr_rdg_rec);
   END IF;          -- 8214848 - dsingire
   --
-- Start fix for bug 6852415, part 2 of 3
FOR base_ctr IN base_ctrs LOOP
   FOR ctrs IN ctrs_to_be_calc(base_ctr.base_ctr_id, base_ctr.base_ctr_timestamp) LOOP
-- End fix for bug 6852415, part 2 of 3
      IF ctrs.derive_function = 'AVERAGE' AND ctrs.filter_type = 'COUNT' THEN
         Declare
	    n number;
	    j number := 0;
            l_rec_count number;
	    l_ctr_rdg number;
	    l_sum_rdg number := 0;
	    l_avg_rdg number;
            l_previous_net number;
            --
	    CURSOR CTR_RDGS(d1_counter_id number) is
	    SELECT net_reading net_rdg,value_timestamp
            FROM CSI_COUNTER_READINGS
	    WHERE counter_id = d1_counter_id
            AND   value_timestamp <= p_ctr_rdg_rec.value_timestamp
            AND   NVL(disabled_flag,'N') = 'N'
	    order by value_timestamp desc;
            --
         Begin
            -- We need n+1 readings to compute the average where n is the filter count. This is because
            -- we don't have the previous net_reading in the same record.
            --
            IF nvl(ctrs.filter_reading_count,0) <= 0 THEN
              IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.put_line('Invalid Filter Reading count for the Counter '||
                                                   to_char(ctrs.counter_id));
              END IF;          -- 8214848 - dsingire
	       csi_ctr_gen_utility_pvt.ExitWithErrMsg
			 ( p_msg_name     => 'CSI_INVD_FILTER_READING_COUNT',
			   p_token1_name  => 'COUNTER_ID',
			   p_token1_val   => to_char(ctrs.counter_id)
			 );
            END IF;
            --
            l_rec_count := ctrs.filter_reading_count + 1;
            l_previous_net := null;
            --
            FOR ctr_rdgs_rec in CTR_RDGS(ctrs.derive_counter_id) LOOP
               j := j+1;
               IF l_previous_net IS NOT NULL THEN -- To skip the first one
                  l_sum_rdg := l_sum_rdg + ABS((l_previous_net) - (ctr_rdgs_rec.net_rdg));
               END IF;
               IF j = l_rec_count THEN
                  l_previous_net := ctr_rdgs_rec.net_rdg; -- will be used if j = 1
                  exit;
               END IF;
               l_previous_net := ctr_rdgs_rec.net_rdg;
            END LOOP;
            --
            IF j = 1 THEN -- If only one reading was found
               l_sum_rdg := l_previous_net;
            ELSIF j < l_rec_count THEN -- Not enough readings found
               j := j - 1;
            ELSE
               j := ctrs.filter_reading_count;
            END IF;
            --
            l_ctr_value := round(nvl(l_sum_rdg,0) / j,2);
            --
         End; -- 'AVERAGE' and 'COUNT' combination
      ELSIF ctrs.derive_function = 'AVERAGE' AND ctrs.filter_type = 'TIME' THEN
         Declare
	    CURSOR GET_TIME_UOM_CUR(p_filter_time_uom IN VARCHAR2) IS
	    select uom_code
	    from OKC_TIME_CODE_UNITS_V
	    where uom_code=p_filter_time_uom;
            --
	    CURSOR GET_FIRST_READING(d3_counter_id IN NUMBER) IS
	    SELECT net_reading,value_timestamp
	    FROM   CSI_COUNTER_READINGS
	    WHERE  counter_id = d3_counter_id
            AND    NVL(disabled_flag,'N') = 'N'
            order by value_timestamp asc;
            --
	    CURSOR CTR_CUR_RDG IS
	    SELECT net_reading
	    FROM CSI_COUNTER_READINGS
	    WHERE counter_value_id = p_ctr_rdg_rec.counter_value_id;
            --
	    l_time_uom  VARCHAR2(10);
	    l_min_date  DATE;
	    l_first_rdg NUMBER;
	    l_captured_rdg NUMBER;
	    l_no_of_days NUMBER;
	    l_target_qty  NUMBER;
	    l_new_datetime DATE := p_ctr_rdg_rec.value_timestamp;
         Begin
            OPEN  GET_TIME_UOM_CUR(ctrs.filter_time_uom);
            FETCH GET_TIME_UOM_CUR INTO l_time_uom;
            CLOSE GET_TIME_UOM_CUR;
            --
            OPEN GET_FIRST_READING(ctrs.derive_counter_id);
            FETCH GET_FIRST_READING INTO l_first_rdg,l_min_date;
            CLOSE GET_FIRST_READING;
            --
            OPEN CTR_CUR_RDG;
            FETCH CTR_CUR_RDG INTO l_captured_rdg;
            CLOSE CTR_CUR_RDG;
            --
            IF l_time_uom IS NULL THEN
	       csi_ctr_gen_utility_pvt.ExitWithErrMsg
                   ( p_msg_name    =>  'CSI_API_CTR_INVALID_FILT_UOM',
                     p_token1_name =>  'UOM_CODE',
                     p_token1_val  =>  ctrs.filter_time_uom
                   );
            ELSE
	       DECLARE
		  l_source_qty number;
		  l_period_uom_code varchar2(200);
		  l_status varchar2(2000);
		  l_offset number :=0;
	       BEGIN
		  l_period_uom_code := 'DAY';
		  l_source_qty      := l_new_datetime - l_min_date;
		  IF l_source_qty = 0 THEN
                     l_source_qty := 1;
		  END IF;

		  l_target_qty := oks_time_measures_pub.get_target_qty(l_min_date,
					  l_source_qty,
					  l_period_uom_code,
					  ctrs.filter_time_uom,
					  5);

		  IF l_target_qty = 0 THEN
                     l_target_qty := 1;
		  END IF;
		  l_ctr_value:=round(( l_captured_rdg-l_first_rdg)/l_target_qty,2) ;
	       END;
            END IF; -- get_time_uom check
         End; -- 'AVERAGE' and 'TIME' combination
      ELSE
         i := 1;
         lj := 1;
         l_sqlstr_init := 'select '||ctrs.derive_function||'( nvl(net_reading,0) )';
	 l_sqlstr_init := l_sqlstr_init || ' from CSI_COUNTER_READINGS cv ';
	 l_sqlstr :=  ' where counter_value_id in (';
	 l_sqlstr := l_sqlstr || ' select distinct cv1.counter_value_id from ';
	 l_sqlfrom := ' CSI_COUNTER_READINGS cv1';
	 l_sqlwhere := '';
         --
	 FOR filts IN der_filters(ctrs.counter_id) LOOP
	   l_sqlfrom := l_sqlfrom ||', CSI_CTR_PROPERTY_READINGS pv';
	   l_sqlfrom := l_sqlfrom ||ltrim(rtrim(filts.seq_no));
	   l_sqlwhere := l_sqlwhere || nvl(filts.left_paren,' ')||' pv';
	   l_sqlwhere := l_sqlwhere || ltrim(rtrim(filts.seq_no));
	   l_sqlwhere := l_sqlwhere || '.property_value ';


	   l_sqlwhere := l_sqlwhere ||filts.relational_operator;

	   T2(i).BINDVAL_RIGHTVAL := filts.right_value;
	   T2(i).BINDNAME_RIGHTVAL := ':x_right_value'||ltrim(rtrim(filts.seq_no));

	   if filts.property_data_type = 'NUMBER' then
	     l_sqlwhere := l_sqlwhere || ':x_right_value'||ltrim(rtrim(filts.seq_no));
	   elsif filts.property_data_type = 'DATE' then
	     l_sqlwhere := l_sqlwhere || 'to_date( '||':x_right_value'||ltrim(rtrim(filts.seq_no))||','||'''DD-MON-RRRR'''||' )';
	   else
	     l_sqlwhere := l_sqlwhere || ':x_right_value'||ltrim(rtrim(filts.seq_no));
	   end if;


	   l_sqlwhere := l_sqlwhere || nvl(filts.right_paren,' ');
	   l_sqlwhere := l_sqlwhere || filts.logical_operator;
	   l_sqlwhere := l_sqlwhere || ' and pv'||ltrim(rtrim(filts.seq_no)) ;
	   l_sqlwhere := l_sqlwhere || '.counter_value_id = cv.counter_value_id ';
	   l_sqlwhere := l_sqlwhere || ' and pv'||ltrim(rtrim(filts.seq_no)) ;
	   l_sqlwhere := l_sqlwhere || '.counter_property_id = ';

	   T2(i).BINDVAL_CTRPROPID := filts.counter_property_id;
	   T2(i).BINDNAME_CTRPROPID := ':x_ctr_prop_id'||ltrim(rtrim(filts.seq_no));
	   l_sqlwhere := l_sqlwhere ||':x_ctr_prop_id'||ltrim(rtrim(filts.seq_no));

	   l_sqlwhere := l_sqlwhere || ' and cv.counter_id = ';
	   l_sqlwhere := l_sqlwhere || ':x_derive_counter_id';
	   --l_sqlwhere := l_sqlwhere || ctrs.derive_counter_id;
	 END LOOP;
         --
	 if l_sqlwhere is null then
	    l_sqlstr := l_sqlstr_init || ' where cv.counter_id = :x_derive_counter_id';
	    l_cursor_handle := dbms_sql.open_cursor;
	    DBMS_SQL.PARSE(l_cursor_handle, l_sqlstr, dbms_sql.native);
	    DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_ctr_value);
	    BINDVAL_DERIVECTRID := ctrs.derive_counter_id;
	    DBMS_SQL.BIND_VARIABLE(l_cursor_handle, ':x_derive_counter_id',BINDVAL_DERIVECTRID);
         else
	    l_sqlstr := l_sqlstr_init||l_sqlstr || l_sqlfrom || ' where '||l_sqlwhere||')';
	    l_cursor_handle := dbms_sql.open_cursor;
	    DBMS_SQL.PARSE(l_cursor_handle, l_sqlstr, dbms_sql.native);
	    DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_ctr_value);

	    BINDVAL_DERIVECTRID := ctrs.derive_counter_id;
	    DBMS_SQL.BIND_VARIABLE(l_cursor_handle, ':x_derive_counter_id',BINDVAL_DERIVECTRID);

	    while lj < i+1
	    loop
	       l_bind_varname := t2(lj).BINDNAME_RIGHTVAL;
	       l_bind_varvalc := t2(lj).BINDVAL_RIGHTVAL;
	       DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvalc);
	       l_bind_varname := t2(lj).BINDNAME_CTRPROPID;
	       l_bind_varvaln := t2(lj).BINDVAL_CTRPROPID;
	       DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvaln);
	       lj:= lj+1;
            end loop;
         end if;
         --
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.put_line('SQL String is '||l_sqlstr);
         END IF;          -- 8214848 - dsingire
	 l_n_temp := dbms_sql.execute(l_cursor_handle);
	 IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
	    dbms_sql.column_value(l_cursor_handle,1,l_ctr_value);
	 END IF;
	 DBMS_SQL.close_cursor(l_cursor_handle);
      END IF;
      --
      --  Capture Reading
      IF l_ctr_value IS NOT NULL THEN
	 l_ctr_in := l_temp_ctr_rdg_rec;
	 --
	 l_ctr_in.COUNTER_ID := ctrs.counter_id;

	 -- Pass the reading date of the base counter to the group avg ctr and sysdate for sum and count
	 --
	 IF ctrs.derive_function = 'AVERAGE' THEN
	   l_ctr_in.VALUE_TIMESTAMP := base_ctr.base_ctr_timestamp; -- Modified for bug 6852415
	 ELSE
	   l_ctr_in.VALUE_TIMESTAMP := sysdate;
	 END IF;
	 --
	 l_ctr_in.COUNTER_READING := l_ctr_value;
	 l_ctr_in.source_counter_value_id := p_ctr_rdg_rec.counter_value_id;
	 l_ctr_in.source_code := p_ctr_rdg_rec.source_code;
	 l_ctr_in.source_line_id := p_ctr_rdg_rec.source_line_id;
	 --
	 IF p_mode = 'UPDATE' THEN
	    UPDATE CSI_COUNTER_READINGS
	    set counter_reading = l_ctr_value,
		net_reading = l_ctr_value,
		life_to_date_reading = l_ctr_value,
		last_update_date = sysdate,
		last_updated_by = l_user_id
	    where counter_id = ctrs.counter_id
	    and   value_timestamp = l_ctr_in.value_timestamp
	    and   source_counter_value_id = l_ctr_in.source_counter_value_id;
	 ELSIF p_mode = 'CREATE' THEN
	    -- Generate the Value_id for insert
	    l_process_flag := TRUE;
	    WHILE l_process_flag LOOP
	       select CSI_COUNTER_READINGS_S.nextval
	       into l_ctr_value_id from dual;
	       IF NOT Counter_Value_Exists(l_ctr_value_id) THEN
		  l_process_flag := FALSE;
	       END IF;
	    END LOOP;
	    --
	    -- Call the Table Handler to insert the new reading
	    CSI_COUNTER_READINGS_PKG.Insert_Row(
		px_COUNTER_VALUE_ID         =>  l_ctr_value_id
	       ,p_COUNTER_ID                =>  l_ctr_in.counter_id
	       ,p_VALUE_TIMESTAMP           =>  l_ctr_in.value_timestamp
	       ,p_COUNTER_READING           =>  l_ctr_value
	       ,p_RESET_MODE                =>  NULL
	       ,p_RESET_REASON              =>  NULL
	       ,p_ADJUSTMENT_TYPE           =>  NULL
	       ,p_ADJUSTMENT_READING        =>  NULL
	       ,p_OBJECT_VERSION_NUMBER     =>  1
	       ,p_LAST_UPDATE_DATE          =>  SYSDATE
	       ,p_LAST_UPDATED_BY           =>  l_user_id
	       ,p_CREATION_DATE             =>  SYSDATE
	       ,p_CREATED_BY                =>  l_user_id
	       ,p_LAST_UPDATE_LOGIN         =>  l_conc_login_id
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
	       ,p_LIFE_TO_DATE_READING      =>  l_ctr_value
	       ,p_TRANSACTION_ID            =>  p_txn_rec.transaction_id
	       ,p_AUTOMATIC_ROLLOVER_FLAG   =>  NULL
	       ,p_INCLUDE_TARGET_RESETS     =>  NULL
	       ,p_SOURCE_COUNTER_VALUE_ID   =>  l_ctr_in.source_counter_value_id
	       ,p_NET_READING               =>  l_ctr_value
	       ,p_DISABLED_FLAG             =>  'N'
	       ,p_SOURCE_CODE               =>  l_ctr_in.source_code
	       ,p_SOURCE_LINE_ID            =>  l_ctr_in.source_line_id
	       ,p_INITIAL_READING_FLAG      =>  l_ctr_in.initial_reading_flag
	     );

          --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
          --for bug 7374316
          CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
            p_api_version           =>  1.0
            ,p_commit                =>  fnd_api.g_false
            ,p_init_msg_list         =>  fnd_api.g_true
            ,p_validation_level      =>  fnd_api.g_valid_level_full
            ,p_counter_id            =>  l_ctr_in.counter_id
            ,px_ctr_val_max_seq_no   =>  l_ctr_value_id
            ,x_return_status         =>  x_return_status
            ,x_msg_count             =>  x_msg_count
            ,x_msg_data              =>  x_msg_data
          );
          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
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
	 END IF; -- p_mode check
      ELSE
         csi_ctr_gen_utility_pvt.put_line('No derive filters computed for '||to_char(ctrs.counter_id));
      END IF; -- l_ctr_value check
   END LOOP;
-- Start fix bug 6852415, part 3 of 3
END LOOP;
-- End fix bug 6852415, part 3 of 3
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO compute_derive_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO compute_derive_counters;
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
      IF DBMS_SQL.IS_OPEN(l_cursor_handle) THEN
         DBMS_SQL.CLOSE_cursor(l_cursor_handle);
      END IF;
END Compute_Derive_Counters;
--
PROCEDURE Compute_Target_Counters
   (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_txn_rec               IN OUT NOCOPY    csi_datastructures_pub.transaction_rec
    ,p_ctr_rdg_rec           IN     csi_ctr_datastructures_pub.counter_readings_rec
    ,p_mode                  IN     VARCHAR2
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'COMPUTE_TARGET_COUNTERS';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   l_rel_type                      VARCHAR2(30) := 'CONFIGURATION';
   l_counter_reading               NUMBER;
   l_prev_ctr_reading              NUMBER;
   l_prev_net_reading              NUMBER;
   l_prev_ltd_reading              NUMBER;
   l_prev_value_timestamp          DATE;
   l_net_reading                   NUMBER;
   l_ltd_reading                   NUMBER;
   l_ctr_rdg_rec                   csi_ctr_datastructures_pub.counter_readings_rec;
   l_temp_ctr_rdg_rec              csi_ctr_datastructures_pub.counter_readings_rec;
   l_process_flag                  BOOLEAN;
   l_mode                          VARCHAR2(30);
   Process_next                    EXCEPTION;
   l_instance_id                   NUMBER;

   -- Bug 8214848
    l_ctr_val_max                 NUMBER := -1;
    l_prev_ctr_max_reading        NUMBER;
    l_prev_net_max_reading        NUMBER;
    l_prev_ltd_max_reading        NUMBER;
    l_prev_value_max_timestamp    DATE;
    l_prev_max_comments           VARCHAR2(240);
   --
   CURSOR OBJECT_CTR_CUR IS
   select ccr.object_counter_id,nvl(ccr.factor,1) factor,
          ccv.direction,ccv.reading_type, ccv.uom_code object_uom_code,
          cct.name object_counter_name
   from   CSI_COUNTER_RELATIONSHIPS ccr,
          CSI_COUNTERS_B ccv,
          CSI_COUNTERS_TL cct
   where  ccr.source_counter_id = p_ctr_rdg_rec.counter_id
   and    ccr.relationship_type_code = l_rel_type
   and    nvl(ccr.active_start_date,sysdate) <= p_ctr_rdg_rec.value_timestamp
   and    nvl(ccr.active_end_date,(sysdate+1)) > p_ctr_rdg_rec.value_timestamp
   and    ccv.counter_id = ccr.object_counter_id
   and    ccv.counter_id = cct.counter_id
   and    cct.language = USERENV('LANG');
   --
   CURSOR UPD_OBJ_CUR IS
   SELECT crg.counter_value_id,crg.value_timestamp,crg.counter_id object_counter_id,
          crg.adjustment_reading,crg.counter_reading,nvl(ccr.factor,1) factor,
          ccv.direction,ccv.reading_type,crg.reset_mode,
          ccv.uom_code object_uom_code, cct.name object_counter_name
   from CSI_COUNTER_READINGS crg,
        CSI_COUNTER_RELATIONSHIPS ccr,
        CSI_COUNTERS_B ccv,
        CSI_COUNTERS_TL cct
   where crg.source_counter_value_id = p_ctr_rdg_rec.counter_value_id
   and   ccr.object_counter_id = crg.counter_id
   and   ccr.source_counter_id = p_ctr_rdg_rec.counter_id
   and   ccr.relationship_type_code = l_rel_type
   and   ccv.counter_id = crg.counter_id
   and   ccv.counter_id = cct.counter_id
   and   cct.language = USERENV('LANG');
   --
   CURSOR PREV_READING_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_reading,net_reading,life_to_date_reading,value_timestamp
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp < p_value_timestamp
   ORDER BY value_timestamp desc;
   --,counter_value_id desc;
   --
   CURSOR GET_UOM_CLASS(p_uom_code VARCHAR2) IS
   SELECT uom_class
   FROM   mtl_units_of_measure
   WHERE  uom_code =  p_uom_code;

   l_source_uom_class VARCHAR2(10);
   l_object_uom_class VARCHAR2(10);
   l_source_uom_code  VARCHAR2(3);
   l_source_direction VARCHAR2(1);
   l_uom_rate         NUMBER;
   l_src_reading_type VARCHAR2(1);
   l_debug_level       NUMBER;    -- 8214848 - dsingire
   l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
   l_conc_login_id		NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  compute_target_counters;
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
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line( 'compute_target_counters'                   ||'-'||
                                  p_api_version                              ||'-'||
                                  p_mode                                     ||'-'||
                                  nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                  nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                  nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
    csi_ctr_gen_utility_pvt.dump_counter_readings_rec(p_ctr_rdg_rec);
   END IF;          -- 8214848 - dsingire
   --

   --
   IF p_txn_rec.transaction_type_id IN (88,91,92,94,95) THEN
      l_mode := 'Meter';
   ELSE
      l_mode := 'Counter';
   END IF;
   --
   IF p_ctr_rdg_rec.counter_id IS NULL OR
      p_ctr_rdg_rec.counter_id = FND_API.G_MISS_NUM THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	 ( p_msg_name    =>  'CSI_API_CTR_INVALID',
	   p_token1_name =>  'MODE',
	   p_token1_val  =>  l_mode
	 );
   END IF;
   --
   IF p_ctr_rdg_rec.value_timestamp IS NULL OR
      p_ctr_rdg_rec.value_timestamp = FND_API.G_MISS_DATE THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID_RDG_DATE');
   END IF;
   --
   -- Fundamental Assumption is, the direction of All Target counters should be same as the Source Counter
   --
   IF p_mode = 'UPDATE' THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line(' Compute Target Counters - UPDATE');
      END IF;          -- 8214848 - dsingire
      FOR obj_cur in UPD_OBJ_CUR LOOP
	 IF NVL(obj_cur.direction,'X') NOT IN ('A','D','B') THEN
	    IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('Target Counter has Invalid Direction...');
      END IF;          -- 8214848 - dsingire
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
		 ( p_msg_name     => 'CSI_API_CTR_INVALID_DIR',
		   p_token1_name  => 'MODE',
		   p_token1_val   => l_mode
		 );
	 END IF;
	 --
         BEGIN
            SELECT uom_code, direction, reading_type
            INTO   l_source_uom_code, l_source_direction, l_src_reading_type
            FROM   csi_counters_b
            WHERE  counter_id = p_ctr_rdg_rec.counter_id;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         /* Validate direction */
         IF obj_cur.direction = 'B' and l_source_direction <> 'B'  THEN
             CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
         END IF;

         IF l_source_direction = 'B' and obj_cur.direction <> 'B' THEN
            CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
         END IF;

         IF obj_cur.object_uom_code <> l_source_uom_code THEN
            /* Validate if same UOM class */
            OPEN get_uom_class(obj_cur.object_uom_code);
            FETCH get_uom_class into l_object_uom_class;

            IF get_uom_class%notfound THEN
               csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_ALL_INVALID_UOM_CODE');
            END IF;

            IF get_uom_class%ISOPEN THEN
               CLOSE get_uom_class;
            END IF;

            OPEN get_uom_class(l_source_uom_code);
            FETCH get_uom_class into l_source_uom_class;

            IF get_uom_class%notfound THEN
               csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_ALL_INVALID_UOM_CODE');
            END IF;

            IF get_uom_class%ISOPEN THEN
               CLOSE get_uom_class;
            END IF;

            IF l_source_uom_class = l_object_uom_class THEN
               /* Do a conversion */
               INV_CONVERT.INV_UM_CONVERSION(l_source_uom_code
                                             ,obj_cur.object_uom_code
                                             ,null
                                             ,l_uom_rate);
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                csi_ctr_gen_utility_pvt.put_line('Object UOM Code = '||obj_cur.object_uom_code);
                csi_ctr_gen_utility_pvt.put_line('Source UOM Code = '||l_source_uom_code);
                csi_ctr_gen_utility_pvt.put_line('UOM Rate = '||to_char(l_uom_rate));
               END IF;          -- 8214848 - dsingire
               IF l_uom_rate = -99999 THEN
                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line(' Error during the conversion of UOM');
                  END IF;          -- 8214848 - dsingire
               END IF;
            ELSE
               l_uom_rate := 1;
            END IF;
         ELSE
            l_uom_rate := 1;
         END IF;
         --
         l_prev_ctr_reading := NULL;
	 l_prev_net_reading := NULL;
	 l_prev_ltd_reading := NULL;
	 l_prev_value_timestamp := NULL;
         --

  -- Get the last reading for this counter
  -- Bug 	8214848
   BEGIN
    SELECT CTR_VAL_MAX_SEQ_NO INTO l_ctr_val_max
      FROM CSI_COUNTERS_B WHERE COUNTER_ID = obj_cur.object_counter_id;

   SELECT COUNTER_READING,NET_READING,LIFE_TO_DATE_READING,
          VALUE_TIMESTAMP
         INTO l_prev_ctr_max_reading,
              l_prev_net_max_reading,
              l_prev_ltd_max_reading,
              l_prev_value_max_timestamp
              --l_prev_max_comments
   FROM CSI_COUNTER_READINGS WHERE COUNTER_VALUE_ID = NVL(l_ctr_val_max,-1);

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('l_ctr_val_max - ' || l_ctr_val_max );
   END IF;          -- 8214848 - dsingire

  EXCEPTION
   WHEN OTHERS THEN
    -- Assign max counter value id to 0 and use the PREV_READING_CUR cursor
    l_ctr_val_max := -1;
  END;  --

   IF (l_prev_value_max_timestamp <=  obj_cur.value_timestamp
            AND NVL(l_ctr_val_max,-1) > 0) THEN

      -- The requested timestamp is greater than the timestamp of the
      -- CTR_VAL_MAX_SEQ_NO
      l_prev_ctr_reading := l_prev_ctr_max_reading;
      l_prev_net_reading := l_prev_net_max_reading;
      l_prev_ltd_reading := l_prev_ltd_max_reading;
      l_prev_value_timestamp := l_prev_value_max_timestamp;
      --l_prev_comments := l_prev_max_comments;

      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Max Value counter id used');
      END IF;          -- 8214848 - dsingire

   ELSE

     OPEN PREV_READING_CUR(obj_cur.object_counter_id,obj_cur.value_timestamp);
     FETCH PREV_READING_CUR
     INTO  l_prev_ctr_reading,
           l_prev_net_reading,
           l_prev_ltd_reading,
           l_prev_value_timestamp;
     CLOSE PREV_READING_CUR;
	 END IF;
   --
         -- p_ctr_rdg_rec.counter_reading contains the Usage from the source counter readings
         -- Since there is no change to adjustments, no need to take the passed adjustment.
         -- It will be same as the obj_cur.adjustment_reading.

         IF obj_cur.reset_mode IS NOT NULL THEN
            l_counter_reading := p_ctr_rdg_rec.counter_reading;
         ELSE
            IF obj_cur.reading_type = 1 THEN
               IF l_source_direction = 'A' AND obj_cur.direction = 'D' THEN
                  IF nvl(l_prev_ctr_reading, 0) = 0 THEN
                     l_counter_reading := ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor) * -1;
                  ELSE
                     IF l_prev_ctr_reading < 0 THEN
                        l_counter_reading := ((l_prev_ctr_reading * -1) - ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor));
                        l_counter_reading := l_counter_reading * -1;
                     ELSE
                        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                          csi_ctr_gen_utility_pvt.put_line('Source is A, Target is D');
                          csi_ctr_gen_utility_pvt.put_line('l_prev_ctr_reading = '||to_char(l_prev_ctr_reading));
                          csi_ctr_gen_utility_pvt.put_line('p_ctr_reading = '||to_char(p_ctr_rdg_rec.counter_reading));
                          csi_ctr_gen_utility_pvt.put_line('l_uom_rate = '||to_char(l_uom_rate));
                          csi_ctr_gen_utility_pvt.put_line('factor  = '||to_char(obj_cur.factor));
                        END IF;          -- 8214848 - dsingire

                        l_counter_reading := nvl(l_prev_ctr_reading,0) - ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                     END IF;
                  END IF;
               END IF;

               IF l_source_direction = 'D' and obj_cur.direction = 'A' THEN
                  IF nvl(l_prev_ctr_reading, 0) = 0 THEN
                     l_counter_reading := ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);

                     IF l_counter_reading < 0 THEN
                        l_counter_reading := l_counter_reading * -1;
                     END IF;
                  ELSE
                     l_counter_reading := nvl(l_prev_ctr_reading,0) + ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                  END IF;
               END IF;

               IF obj_cur.direction = 'A'  and l_source_direction = 'A' THEN
                  l_counter_reading := nvl(l_prev_ctr_reading,0) + ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
               ELSIF obj_cur.direction = 'D' and l_source_direction = 'D' THEN
                  IF nvl(l_prev_ctr_reading, 0) = 0 THEN
                     l_counter_reading := ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                  ELSE
                     IF l_prev_ctr_reading < 0 THEN
                        l_counter_reading := ((l_prev_ctr_reading * -1) - ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor));
                        l_counter_reading := l_counter_reading * -1;
                     ELSE
                        l_counter_reading := nvl(l_prev_ctr_reading,0) - ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                     END IF;
                  END IF;
               ELSIF obj_cur.direction = 'B'  and l_source_direction = 'B' THEN
                  l_counter_reading := nvl(l_prev_ctr_reading,0) + ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
               END IF;
            ELSE
               l_counter_reading := (p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor;
            END IF;
         END IF;

	 -- Calculate Net and LTD Readings
         IF obj_cur.reset_mode IS NULL THEN
            Calculate_Net_Reading
	       ( p_prev_net_rdg      => l_prev_net_reading
		,p_prev_ltd_rdg      => l_prev_ltd_reading
		,p_curr_rdg          => l_counter_reading
		,p_prev_rdg          => l_prev_ctr_reading
		,p_curr_adj          => obj_cur.adjustment_reading
		,p_rdg_type          => obj_cur.reading_type
		,p_direction         => obj_cur.direction
		,px_net_rdg          => l_net_reading
		,px_ltd_rdg          => l_ltd_reading
		,l_ctr_rdg_rec      => p_ctr_rdg_rec -- added 6398254
	       );
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Prev net reading = '||to_char(l_prev_net_reading));
              csi_ctr_gen_utility_pvt.put_line('Prev ltd reading = '||to_char(l_prev_ltd_reading));
              csi_ctr_gen_utility_pvt.put_line('Prev reading  = '||to_char(l_prev_ctr_reading));
              csi_ctr_gen_utility_pvt.put_line('5. Current reading  = '||to_char(l_counter_reading));
            END IF;          -- 8214848 - dsingire
            IF obj_cur.direction = 'D' THEN
               IF l_counter_reading > nvl(l_prev_ctr_reading, l_counter_reading) THEN
                  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                      ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                        p_token1_name    =>  'DIRECTION',
                        -- p_token1_val     =>  obj_cur.direction,
                        p_token1_val     =>  'a Descending',
                        p_token2_name    =>  'MODE',
                        p_token2_val     =>  l_mode,
                        p_token3_name    =>  'CTR_NAME',
                        p_token3_val     =>  obj_cur.object_counter_name
                    );
               END IF;
            ELSIF obj_cur.direction = 'A' THEN
               IF l_counter_reading < nvl(l_prev_ctr_reading, l_counter_reading) THEN
                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line('6. Current reading ');
                  END IF;          -- 8214848 - dsingire
                  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                      ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                        p_token1_name    =>  'DIRECTION',
                        -- p_token1_val     =>  obj_cur.direction,
                        p_token1_val     =>  'an Ascending',
                        p_token2_name    =>  'MODE',
                        p_token2_val     =>  l_mode,
                        p_token3_name    =>  'CTR_NAME',
                        p_token3_val     =>  obj_cur.object_counter_name
                      );
               END IF;
            END IF;
         ELSE
            l_net_reading := l_prev_net_reading;
            l_ltd_reading := l_prev_ltd_reading;
         END IF;
	 --
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Updating Target Counter Value ID : '||to_char(obj_cur.counter_value_id));
        END IF;          -- 8214848 - dsingire

	 Update CSI_COUNTER_READINGS
	 set counter_reading = l_counter_reading,
	     net_reading = l_net_reading,
	     life_to_date_reading = l_ltd_reading,
	     last_update_date = sysdate,
	     last_updated_by = l_user_id
	 where counter_value_id = obj_cur.counter_value_id;
      END LOOP;
   ELSIF p_mode = 'CREATE' THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line(' Compute Target Counters - CREATE');
      END IF;          -- 8214848 - dsingire
      FOR obj_cur IN OBJECT_CTR_CUR LOOP
         Begin
	    IF NVL(obj_cur.direction,'X') NOT IN ('A','D','B') THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	       csi_ctr_gen_utility_pvt.put_line('Target Counter has Invalid Direction...');
        END IF;          -- 8214848 - dsingire
	       csi_ctr_gen_utility_pvt.ExitWithErrMsg
		    ( p_msg_name     => 'CSI_API_CTR_INVALID_DIR',
		      p_token1_name  => 'MODE',
		      p_token1_val   => l_mode
                    );
	    END IF;
	    --
             BEGIN
                SELECT uom_code, direction, reading_type
                INTO   l_source_uom_code, l_source_direction, l_src_reading_type
                FROM   csi_counters_b
                WHERE  counter_id = p_ctr_rdg_rec.counter_id;
             EXCEPTION
                WHEN OTHERS THEN
                   NULL;
             END;

             /* Validate direction */
             IF obj_cur.direction = 'B' and l_source_direction <> 'B'  THEN
                CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
             END IF;

             IF l_source_direction = 'B' and obj_cur.direction <> 'B' THEN
                CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_INV_REL_DIR');
             END IF;

             IF obj_cur.object_uom_code <> l_source_uom_code THEN
                /* Validate if same UOM class */
                OPEN get_uom_class(obj_cur.object_uom_code);
                FETCH get_uom_class into l_object_uom_class;

                IF get_uom_class%notfound THEN
                   csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_ALL_INVALID_UOM_CODE');
                END IF;

                IF get_uom_class%ISOPEN THEN
                   CLOSE get_uom_class;
                END IF;

                OPEN get_uom_class(l_source_uom_code);
                FETCH get_uom_class into l_source_uom_class;

                IF get_uom_class%notfound THEN
                   csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_ALL_INVALID_UOM_CODE');
                END IF;

                IF get_uom_class%ISOPEN THEN
                   CLOSE get_uom_class;
                END IF;

                IF l_source_uom_class = l_object_uom_class THEN
                   /* Do a conversion */
                   INV_CONVERT.INV_UM_CONVERSION(l_source_uom_code
                                                 ,obj_cur.object_uom_code
                                                 ,null
                                                 ,l_uom_rate);
                   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line('Object UOM Code = '||obj_cur.object_uom_code);
                    csi_ctr_gen_utility_pvt.put_line('Source UOM Code = '||l_source_uom_code);
                    csi_ctr_gen_utility_pvt.put_line('UOM Rate = '||to_char(l_uom_rate));
                   END IF;          -- 8214848 - dsingire
                   IF l_uom_rate = -99999 THEN
                    IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                      csi_ctr_gen_utility_pvt.put_line(' Error during the conversion of UOM');
                    END IF;          -- 8214848 - dsingire
                   END IF;
                ELSE
                   l_uom_rate := 1;
                END IF;
             ELSE
                l_uom_rate := 1;
             END IF;

            --
	    l_ctr_rdg_rec := l_temp_ctr_rdg_rec;
	    --
	    l_ctr_rdg_rec.counter_id := obj_cur.object_counter_id;
	    l_ctr_rdg_rec.value_timestamp := p_ctr_rdg_rec.value_timestamp;
	    l_ctr_rdg_rec.adjustment_type := p_ctr_rdg_rec.adjustment_type;
	    l_ctr_rdg_rec.adjustment_reading := p_ctr_rdg_rec.adjustment_reading;
	    l_ctr_rdg_rec.source_counter_value_id := p_ctr_rdg_rec.counter_value_id;
	    l_ctr_rdg_rec.source_code := p_ctr_rdg_rec.source_code;
	    l_ctr_rdg_rec.source_line_id := p_ctr_rdg_rec.source_line_id;
	    l_ctr_rdg_rec.comments := p_ctr_rdg_rec.comments;
	    --
	    -- Get the last reading for this counter
	    l_prev_ctr_reading := NULL;
	    l_prev_net_reading := NULL;
	    l_prev_ltd_reading := NULL;
	    l_prev_value_timestamp := NULL;
	    --

        -- Get the last reading for this counter
  -- Bug 	8214848
   BEGIN
    SELECT CTR_VAL_MAX_SEQ_NO INTO l_ctr_val_max
      FROM CSI_COUNTERS_B WHERE COUNTER_ID = obj_cur.object_counter_id;

   SELECT COUNTER_READING,NET_READING,LIFE_TO_DATE_READING,
          VALUE_TIMESTAMP
         INTO l_prev_ctr_max_reading,
              l_prev_net_max_reading,
              l_prev_ltd_max_reading,
              l_prev_value_max_timestamp
              --l_prev_max_comments
   FROM CSI_COUNTER_READINGS WHERE COUNTER_VALUE_ID = NVL(l_ctr_val_max,-1);

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('l_ctr_val_max - ' || l_ctr_val_max );
   END IF;          -- 8214848 - dsingire

  EXCEPTION
   WHEN OTHERS THEN
    -- Assign max counter value id to 0 and use the PREV_READING_CUR cursor
    l_ctr_val_max := -1;
  END;  --

   IF (l_prev_value_max_timestamp <=  p_ctr_rdg_rec.value_timestamp
            AND NVL(l_ctr_val_max,-1) > 0) THEN

      -- The requested timestamp is greater than the timestamp of the
      -- CTR_VAL_MAX_SEQ_NO
      l_prev_ctr_reading := l_prev_ctr_max_reading;
      l_prev_net_reading := l_prev_net_max_reading;
      l_prev_ltd_reading := l_prev_ltd_max_reading;
      l_prev_value_timestamp := l_prev_value_max_timestamp;
      --l_prev_comments := l_prev_max_comments;

      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Max Value counter id used');
      END IF;          -- 8214848 - dsingire

   ELSE

	    OPEN PREV_READING_CUR(obj_cur.object_counter_id,p_ctr_rdg_rec.value_timestamp);
	    FETCH PREV_READING_CUR
	    INTO  l_prev_ctr_reading,
		  l_prev_net_reading,
		  l_prev_ltd_reading,
		  l_prev_value_timestamp;
	    CLOSE PREV_READING_CUR;

   END IF;
      --
            IF l_prev_ctr_reading IS NULL AND
               (p_ctr_rdg_rec.adjustment_type IS NOT NULL AND
                p_ctr_rdg_rec.adjustment_type <> FND_API.G_MISS_CHAR) THEN
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                  csi_ctr_gen_utility_pvt.put_line('First reading of this Target Counter '||
                     to_char(obj_cur.object_counter_id)||' cannot be an Adjustment reading. Ingoring it..');
               END IF;          -- 8214848 - dsingire
               Raise Process_next;
            END IF;
            --
            /* Check if the readings needed to be reverse based on the
               source and target direction combination */
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Reading Type = '||to_char(obj_cur.reading_type));
              csi_ctr_gen_utility_pvt.put_line('Source Direction = '||l_source_direction);
              csi_ctr_gen_utility_pvt.put_line('Object Direction = '||obj_cur.direction);
              csi_ctr_gen_utility_pvt.put_line('Factor = '||to_char(obj_cur.factor));
              csi_ctr_gen_utility_pvt.put_line('UOM Rate = '||to_char(l_uom_rate));
              csi_ctr_gen_utility_pvt.put_line('target prev rdg = '||to_char(l_prev_ctr_reading));
              csi_ctr_gen_utility_pvt.put_line('source prev rdg = '||to_char(p_ctr_rdg_rec.counter_reading));
            END IF;          -- 8214848 - dsingire
	    IF obj_cur.reading_type = 1 THEN
               IF l_source_direction = 'A' AND obj_cur.direction = 'D' THEN
                  IF nvl(l_prev_ctr_reading, 0) = 0 THEN
                     l_counter_reading := ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor) * -1;
                     IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
                        l_ctr_rdg_rec.adjustment_reading := ((p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor) * -1;
                     END IF;
                  ELSE
                     IF l_prev_ctr_reading < 0 THEN
                        l_counter_reading := ((l_prev_ctr_reading * -1) - (((p_ctr_rdg_rec.counter_reading * -1) * l_uom_rate) * obj_cur.factor));
                        l_counter_reading := l_counter_reading * -1;
                        IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
                           l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
                           l_ctr_rdg_rec.adjustment_reading := l_ctr_rdg_rec.adjustment_reading * -1;
                        END IF;
                     ELSE
                        l_counter_reading := nvl(l_prev_ctr_reading,0) - ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                        IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
                           l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
                        END IF;
                     END IF;
                  END IF;
                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line('New target reading = '||to_char(l_counter_reading));
                  END IF;          -- 8214848 - dsingire
              END IF;


               IF l_source_direction = 'D' and obj_cur.direction = 'A' THEN
                  IF nvl(l_prev_ctr_reading, 0) = 0 THEN
                     l_counter_reading := ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);

                     IF l_counter_reading < 0 THEN
                        l_counter_reading := l_counter_reading * -1;
                     END IF;

                     IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
                        l_ctr_rdg_rec.adjustment_reading := ((p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor);

                        IF l_ctr_rdg_rec.adjustment_reading < 0 THEN
                           l_ctr_rdg_rec.adjustment_reading := l_ctr_rdg_rec.adjustment_reading * -1;
                        END IF;
                     END IF;
                  ELSE
                     l_counter_reading := nvl(l_prev_ctr_reading,0) + ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                     IF p_ctr_rdg_rec.adjustment_reading is not null  and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
                        l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
                     END IF;
                  END IF;
               END IF;
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                csi_ctr_gen_utility_pvt.put_line('New target reading = '||to_char(l_counter_reading));
               END IF;          -- 8214848 - dsingire

	       IF obj_cur.direction = 'A'  and l_source_direction = 'A' THEN
		  l_counter_reading := nvl(l_prev_ctr_reading,0) + ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                  IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
		     l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
                  END IF;
	       ELSIF obj_cur.direction = 'D' and l_source_direction = 'D' THEN
                  IF nvl(l_prev_ctr_reading, 0) = 0 THEN
                     l_counter_reading := ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                     IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
                        l_ctr_rdg_rec.adjustment_reading := ((p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor);
                     END IF;
                  ELSE
                     IF l_prev_ctr_reading < 0 THEN
		        l_counter_reading := ((l_prev_ctr_reading * -1) - ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor));
                        l_counter_reading := l_counter_reading * -1;
                        IF p_ctr_rdg_rec.adjustment_reading is not null  and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
		           l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
                           l_ctr_rdg_rec.adjustment_reading := l_ctr_rdg_rec.adjustment_reading * -1;
                        END IF;
                     ELSE
		        l_counter_reading := nvl(l_prev_ctr_reading,0) - ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                        IF p_ctr_rdg_rec.adjustment_reading is not null then
		           l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
                        END IF;
                     END IF;
	          END IF;
            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('New target reading = '||to_char(l_counter_reading));
            END IF;          -- 8214848 - dsingire
               ELSIF obj_cur.direction = 'B'  and l_source_direction = 'B' THEN
                  l_counter_reading := nvl(l_prev_ctr_reading,0) + ((p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor);
                  IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
                     l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
	          END IF;
	       END IF;
	    ELSE
	       l_counter_reading := (p_ctr_rdg_rec.counter_reading * l_uom_rate) * obj_cur.factor;
               IF p_ctr_rdg_rec.adjustment_reading is not null and p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM then
	          l_ctr_rdg_rec.adjustment_reading := (p_ctr_rdg_rec.adjustment_reading * l_uom_rate) * obj_cur.factor;
	       END IF;
	    END IF;
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('New target reading = '||to_char(l_counter_reading));
      END IF;          -- 8214848 - dsingire
	    -- Calculate Net and LTD Readings
	    Calculate_Net_Reading
	       ( p_prev_net_rdg      => l_prev_net_reading
		,p_prev_ltd_rdg      => l_prev_ltd_reading
		,p_curr_rdg          => l_counter_reading
		,p_prev_rdg          => l_prev_ctr_reading
		,p_curr_adj          => l_ctr_rdg_rec.adjustment_reading
		,p_rdg_type          => obj_cur.reading_type
		,p_direction         => obj_cur.direction
		,px_net_rdg          => l_net_reading
		,px_ltd_rdg          => l_ltd_reading
		,l_ctr_rdg_rec      => p_ctr_rdg_rec -- added 6398254
	       );

            IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
              csi_ctr_gen_utility_pvt.put_line('Current reading  = '||to_char(l_counter_reading));
            END IF;          -- 8214848 - dsingire
            IF obj_cur.direction = 'D' THEN
               IF l_counter_reading > nvl(l_prev_ctr_reading, l_counter_reading) THEN
                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line('7. Current reading ');
                  END IF;          -- 8214848 - dsingire
                  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                      ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                        p_token1_name    =>  'DIRECTION',
                        -- p_token1_val     =>  obj_cur.direction,
                        p_token1_val     =>  'a Descending',
                        p_token2_name    =>  'MODE',
                        p_token2_val     =>  l_mode,
                        p_token3_name    =>  'CTR_NAME',
                        p_token3_val     =>  obj_cur.object_counter_name
                      );
               END IF;
            ELSIF obj_cur.direction = 'A' THEN
               IF l_counter_reading < nvl(l_prev_ctr_reading, l_counter_reading) THEN
                  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                    csi_ctr_gen_utility_pvt.put_line('8. Current reading ');
                  END IF;          -- 8214848 - dsingire
                  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                      ( p_msg_name       =>  'CSI_API_CTR_INV_RDG',
                        p_token1_name    =>  'DIRECTION',
                        -- p_token1_val     =>  obj_cur.direction,
                        p_token1_val     =>  'an Ascending',
                        p_token2_name    =>  'MODE',
                        p_token2_val     =>  l_mode,
                        p_token3_name    =>  'CTR_NAME',
                        p_token3_val     =>  obj_cur.object_counter_name
                      );
               END IF;
            END IF;

            --
            IF p_txn_rec.transaction_type_id in (88,91,92,94,95) THEN
               IF p_txn_rec.transaction_type_id = 91 THEN
                  l_instance_id := p_txn_rec.source_header_ref_id;
               ELSE
                  l_instance_id := null;
               END IF;
               IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
                  csi_ctr_gen_utility_pvt.put_line('Calling Insert Meter Log...');
               END IF;          -- 8214848 - dsingire
               Eam_Asset_Log_Pvt.Insert_Meter_Log
                  (
                    P_api_version           =>  1.0,
                    P_init_msg_list         =>  fnd_api.g_false,
                    P_commit                =>  fnd_api.g_false,
                    P_validation_level      =>  fnd_api.g_valid_level_full,
                    P_event_date            =>  l_ctr_rdg_rec.value_timestamp,
                    P_instance_id           =>  l_instance_id,
                    P_ref_id                =>  l_ctr_rdg_rec.counter_id,
                    X_return_status         =>  x_return_status,
                    X_msg_count             =>  x_msg_count,
                    X_msg_data              =>  x_msg_data
               );
               -- Since this is only for logging we are ignoring the x_return_status.
               -- Just report the API error and proceed.
               --
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
		      csi_ctr_gen_utility_pvt.put_line('ERROR FROM Insert_Meter_Log API ');
         END IF;          -- 8214848 - dsingire
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
            IF p_txn_rec.transaction_type_id = 92 THEN
              IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
               csi_ctr_gen_utility_pvt.put_line('Calling Update_Last_Service_Reading_Wo...');
              END IF;          -- 8214848 - dsingire
               Eam_Meters_Util.Update_Last_Service_Reading_Wo
                  (
                    p_wip_entity_id    =>  p_txn_rec.source_header_ref_id,
                    p_meter_id         =>  l_ctr_rdg_rec.counter_id,
	            p_meter_reading    =>  l_counter_reading,
	            p_wo_end_date      =>  l_ctr_rdg_rec.value_timestamp,
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
	    -- Generate the Value_id for insert
	    l_process_flag := TRUE;
	    WHILE l_process_flag LOOP
	       select CSI_COUNTER_READINGS_S.nextval
	       into l_ctr_rdg_rec.counter_value_id from dual;
	       IF NOT Counter_Value_Exists(l_ctr_rdg_rec.counter_value_id) THEN
		  l_process_flag := FALSE;
	       END IF;
	    END LOOP;
	    --
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	      csi_ctr_gen_utility_pvt.put_line('Inserting Target Counter ID : '||to_char(l_ctr_rdg_rec.counter_id));
      END IF;          -- 8214848 - dsingire
	    -- Call the Table Handler to insert into CSI_COUNTER_READINGS
	    CSI_COUNTER_READINGS_PKG.Insert_Row(
		px_COUNTER_VALUE_ID         =>  l_ctr_rdg_rec.counter_value_id
	       ,p_COUNTER_ID                =>  l_ctr_rdg_rec.counter_id
	       ,p_VALUE_TIMESTAMP           =>  l_ctr_rdg_rec.value_timestamp
	       ,p_COUNTER_READING           =>  l_counter_reading
	       ,p_RESET_MODE                =>  p_ctr_rdg_rec.reset_mode  -- NULL 6398254
	       ,p_RESET_REASON              =>  p_ctr_rdg_rec.reset_reason -- NULL 6398254
	       ,p_ADJUSTMENT_TYPE           =>  l_ctr_rdg_rec.adjustment_type
	       ,p_ADJUSTMENT_READING        =>  l_ctr_rdg_rec.adjustment_reading
	       ,p_OBJECT_VERSION_NUMBER     =>  1
	       ,p_LAST_UPDATE_DATE          =>  SYSDATE
	       ,p_LAST_UPDATED_BY           =>  l_user_id
	       ,p_CREATION_DATE             =>  SYSDATE
	       ,p_CREATED_BY                =>  l_user_id
	       ,p_LAST_UPDATE_LOGIN         =>  l_conc_login_id
	       ,p_ATTRIBUTE1                =>  l_ctr_rdg_rec.attribute1
	       ,p_ATTRIBUTE2                =>  l_ctr_rdg_rec.attribute2
	       ,p_ATTRIBUTE3                =>  l_ctr_rdg_rec.attribute3
	       ,p_ATTRIBUTE4                =>  l_ctr_rdg_rec.attribute4
	       ,p_ATTRIBUTE5                =>  l_ctr_rdg_rec.attribute5
	       ,p_ATTRIBUTE6                =>  l_ctr_rdg_rec.attribute6
	       ,p_ATTRIBUTE7                =>  l_ctr_rdg_rec.attribute7
	       ,p_ATTRIBUTE8                =>  l_ctr_rdg_rec.attribute8
	       ,p_ATTRIBUTE9                =>  l_ctr_rdg_rec.attribute9
	       ,p_ATTRIBUTE10               =>  l_ctr_rdg_rec.attribute10
	       ,p_ATTRIBUTE11               =>  l_ctr_rdg_rec.attribute11
	       ,p_ATTRIBUTE12               =>  l_ctr_rdg_rec.attribute12
	       ,p_ATTRIBUTE13               =>  l_ctr_rdg_rec.attribute13
	       ,p_ATTRIBUTE14               =>  l_ctr_rdg_rec.attribute14
	       ,p_ATTRIBUTE15               =>  l_ctr_rdg_rec.attribute15
	       ,p_ATTRIBUTE16               =>  l_ctr_rdg_rec.attribute16
	       ,p_ATTRIBUTE17               =>  l_ctr_rdg_rec.attribute17
	       ,p_ATTRIBUTE18               =>  l_ctr_rdg_rec.attribute18
	       ,p_ATTRIBUTE19               =>  l_ctr_rdg_rec.attribute19
	       ,p_ATTRIBUTE20               =>  l_ctr_rdg_rec.attribute20
	       ,p_ATTRIBUTE21               =>  l_ctr_rdg_rec.attribute21
	       ,p_ATTRIBUTE22               =>  l_ctr_rdg_rec.attribute22
	       ,p_ATTRIBUTE23               =>  l_ctr_rdg_rec.attribute23
	       ,p_ATTRIBUTE24               =>  l_ctr_rdg_rec.attribute24
	       ,p_ATTRIBUTE25               =>  l_ctr_rdg_rec.attribute25
	       ,p_ATTRIBUTE26               =>  l_ctr_rdg_rec.attribute26
	       ,p_ATTRIBUTE27               =>  l_ctr_rdg_rec.attribute27
	       ,p_ATTRIBUTE28               =>  l_ctr_rdg_rec.attribute28
	       ,p_ATTRIBUTE29               =>  l_ctr_rdg_rec.attribute29
	       ,p_ATTRIBUTE30               =>  l_ctr_rdg_rec.attribute30
	       ,p_ATTRIBUTE_CATEGORY        =>  l_ctr_rdg_rec.attribute_category
	       ,p_MIGRATED_FLAG             =>  'N'
	       ,p_COMMENTS                  =>  l_ctr_rdg_rec.comments
	       ,p_LIFE_TO_DATE_READING      =>  l_ltd_reading
	       ,p_TRANSACTION_ID            =>  p_txn_rec.transaction_id
	       ,p_AUTOMATIC_ROLLOVER_FLAG   =>  l_ctr_rdg_rec.automatic_rollover_flag
	       ,p_INCLUDE_TARGET_RESETS     =>  l_ctr_rdg_rec.include_target_resets
	       ,p_SOURCE_COUNTER_VALUE_ID   =>  l_ctr_rdg_rec.source_counter_value_id
	       ,p_NET_READING               =>  l_net_reading
	       ,p_DISABLED_FLAG             =>  'N'
	       ,p_SOURCE_CODE               =>  l_ctr_rdg_rec.source_code
	       ,p_SOURCE_LINE_ID            =>  l_ctr_rdg_rec.source_line_id
	       ,p_INITIAL_READING_FLAG      =>  l_ctr_rdg_rec.initial_reading_flag
	     );

          --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
          --for bug 7374316
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
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_PVT.update_ctr_val_max_seq_no');
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
         Exception
            when Process_next then
               null;
         End;
      END LOOP; -- Obj Cursor
   END IF; -- p_mode check
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
      ROLLBACK TO compute_target_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO compute_target_counters;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO compute_target_counters;
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
END Compute_Target_Counters;
--
/*----------------------------------------------------*/
/* procedure name: Update_Counter_Reading             */
/* description :   procedure used to                  */
/*                 disable counter readings           */
/*----------------------------------------------------*/

PROCEDURE Update_Counter_Reading
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_rdg_rec           IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_READING_PVT';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   l_prev_ctr_reading              NUMBER;
   l_prev_net_reading              NUMBER;
   l_prev_ltd_reading              NUMBER;
   l_prev_value_timestamp          DATE;
   l_next_ctr_reading              NUMBER;
   l_next_value_timestamp          DATE;
   l_next_reset_mode               VARCHAR2(30);
   l_next_adj_type                 VARCHAR2(30);
   l_next_auto_rollover            VARCHAR2(1);
   l_later_ctr_reading             NUMBER;
   l_adj_ctr                       NUMBER;
   l_ctr_name                      VARCHAR2(50);
   l_ctr_type                      VARCHAR2(30);
   l_rollover_last_rdg             NUMBER;
   l_rollover_first_rdg            NUMBER;
   l_direction                     VARCHAR2(1);
   l_reading_type                  NUMBER;
   l_auto_rollover                 VARCHAR2(1);
   l_net_reading                   NUMBER;
   l_ltd_reading                   NUMBER;
   l_previous_rdg                  NUMBER;
   l_upd_previous_rdg              NUMBER;
   l_previous_net                  NUMBER;
   l_previous_ltd                  NUMBER;
   l_process_flag                  BOOLEAN := TRUE;
   l_seq_num                       NUMBER;
   l_rdg_lock_date                 DATE;
   l_target_ctr_rec                csi_ctr_datastructures_pub.counter_readings_rec;
   l_temp_ctr_rdg_rec              csi_ctr_datastructures_pub.counter_readings_rec;
   l_exists                        VARCHAR2(1);
   l_update_loop                   BOOLEAN := FALSE;
   l_upd_fl_rdg_rec                csi_ctr_datastructures_pub.counter_readings_rec;
   l_derive_ctr_rec                csi_ctr_datastructures_pub.counter_readings_rec;
   l_txn_rec                       csi_datastructures_pub.transaction_rec;
   l_mode                          VARCHAR2(30);
   l_txn_type_id                   NUMBER;
   l_ctr_val_max_seq_no            NUMBER;

    -- Bug 8214848
    l_ctr_val_max                 NUMBER := -1;
    l_prev_ctr_max_reading        NUMBER;
    l_prev_net_max_reading        NUMBER;
    l_prev_ltd_max_reading        NUMBER;
    l_prev_value_max_timestamp    DATE;
    l_prev_max_comments           VARCHAR2(240);
    l_debug_level       NUMBER;    -- 8214848 - dsingire
    l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
    l_conc_login_id		  NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
    l_date_format       VARCHAR2(50) := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-YYYY HH24:MI:SS');
   --
   -- Bug 9148094
     l_update_net_flag VARCHAR2(1) := NVL(fnd_profile.value('CSI_UPDATE_NET_READINGS_ON_RESET'), 'Y');
   --
   CURSOR CURRENT_READING_CUR(p_counter_value_id IN NUMBER) IS
   select * from
   CSI_COUNTER_READINGS
   where counter_value_id = p_counter_value_id;
   --
   l_curr_ctr_rdg_rec              CURRENT_READING_CUR%rowtype;
   --
   CURSOR PREV_READING_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_reading,net_reading,life_to_date_reading,value_timestamp
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp < p_value_timestamp
   ORDER BY value_timestamp desc;
   --,counter_value_id desc;
   --
   CURSOR NEXT_READING_CUR(p_counter_id IN NUMBER,p_value_timestamp IN DATE) IS
   select counter_reading,value_timestamp,reset_mode,
          adjustment_type,automatic_rollover_flag
   from CSI_COUNTER_READINGS
   where counter_id = p_counter_id
   and   nvl(disabled_flag,'N') = 'N'
   and   value_timestamp > p_value_timestamp
   ORDER BY value_timestamp asc;
   --,counter_value_id asc;
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
BEGIN

csi_ctr_gen_utility_pvt.put_line(' dk: updt read: Update Net Reading Flag : '||l_update_net_flag);

   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_reading_pvt;
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
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
   csi_ctr_gen_utility_pvt.put_line( 'update_counter_reading_pvt'               ||'-'||
                                  p_api_version                              ||'-'||
                                  nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                  nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                  nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;          -- 8214848 - dsingire
   --
   IF NVL(p_ctr_rdg_rec.counter_value_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Invalid Counter Value ID...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_VALUE_ID_MISS');
   ELSE
      OPEN CURRENT_READING_CUR(p_ctr_rdg_rec.counter_value_id);
      FETCH CURRENT_READING_CUR INTO l_curr_ctr_rdg_rec;
      CLOSE CURRENT_READING_CUR;
      --
      IF l_curr_ctr_rdg_rec.counter_value_id IS NULL THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Invalid Counter Value ID...');
        END IF;          -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_VALUE_ID_MISS');
      END IF;
      --
      Begin
         select transaction_type_id
         into l_txn_type_id
         from csi_transactions
         where transaction_id = l_curr_ctr_rdg_rec.transaction_id;
      Exception
         when no_data_found then
            l_txn_type_id := -1;
      End;
      --
      IF l_txn_type_id IN (88,91,92,94,95) THEN
         l_mode := 'Meter';
      ELSE
         l_mode := 'Counter';
      END IF;
      --
      IF l_curr_ctr_rdg_rec.object_version_number <> NVL(p_ctr_rdg_rec.object_version_number,0) THEN
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_CTR_OBJ_VER_MISMATCH',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
      --
      IF NVL(l_curr_ctr_rdg_rec.disabled_flag,'N') = 'Y' THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Counter Reading is already disabled...');
        END IF;          -- 8214848 - dsingire
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name    =>  'CSI_API_CTR_DISABLED_RDG',
	      p_token1_name =>  'MODE',
	      p_token1_val  =>  l_mode
	    );
      END IF;
   END IF;
   --
   IF p_ctr_rdg_rec.counter_id <> FND_API.G_MISS_NUM AND
      p_ctr_rdg_rec.counter_id IS NOT NULL AND
      p_ctr_rdg_rec.counter_id <> l_curr_ctr_rdg_rec.counter_id THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Update Counter ID...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	 ( p_msg_name    =>  'CSI_API_CTR_UPD_COUNTER_ID',
	   p_token1_name =>  'MODE',
	   p_token1_val  =>  l_mode
	 );
   ELSE
      -- Get the counter definition
      Begin
         select name,counter_type,rollover_last_reading,
                rollover_first_reading,direction,reading_type,
                automatic_rollover
         into l_ctr_name,l_ctr_type,l_rollover_last_rdg,l_rollover_first_rdg,
              l_direction,l_reading_type,l_auto_rollover
         from CSI_COUNTERS_VL
         where counter_id = l_curr_ctr_rdg_rec.counter_id
         and   nvl(end_date_active,(sysdate+1)) > sysdate;
      Exception
         when no_data_found then
            csi_ctr_gen_utility_pvt.ExitWithErrMsg
               ( p_msg_name    =>  'CSI_API_CTR_INVALID',
                 p_token1_name =>  'MODE',
                 p_token1_val  =>  l_mode
               );
      End;
   END IF;
   --
   IF nvl(p_ctr_rdg_rec.disabled_flag,'N') <> 'Y' THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Disabled flag is not set...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_DISABLED_FLAG');
   END IF;
   --
   IF NVL(l_direction,'X') NOT IN ('A','D','B') THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('This counter has an Invalid Direction...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_INVALID_DIR',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   IF l_curr_ctr_rdg_rec.reset_mode IS NOT NULL THEN
      /* Check if there are readings after the reset */
      OPEN NEXT_READING_CUR(l_curr_ctr_rdg_rec.counter_id,
                            l_curr_ctr_rdg_rec.value_timestamp);
      FETCH NEXT_READING_CUR
      INTO  l_next_ctr_reading,
	    l_next_value_timestamp,
            l_next_reset_mode,
            l_next_adj_type,
            l_next_auto_rollover;
      CLOSE NEXT_READING_CUR;

      IF l_next_ctr_reading IS NOT NULL THEN
         /* End of checking */
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
          csi_ctr_gen_utility_pvt.put_line('Cannot Disable Reset Reading...');
         END IF;          -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
	    ( p_msg_name     => 'CSI_API_CTR_DISABLE_RESET',
	      p_token1_name  => 'MODE',
	      p_token1_val   => l_mode
	    );
      END IF;
   END IF;
   --
   IF NVL(l_curr_ctr_rdg_rec.automatic_rollover_flag,'N') = 'Y' THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Disable Automatic Rollover Reading...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_DISABLE_ROLLOVER',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   -- Cannot Disable Target Counters as they are driven by source counters
   IF Is_Target_Counter(l_curr_ctr_rdg_rec.counter_id) THEN
     IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('Cannot Disable Target Counter...');
     END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_DISABLE_TARGET',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   -- Cannot Disable Formula Counters Readings
   IF Is_Formula_Counter(l_curr_ctr_rdg_rec.counter_id) THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Disable Formula Counter...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_DISABLE_FORMULA',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   IF p_ctr_rdg_rec.value_timestamp <> FND_API.G_MISS_DATE AND
      p_ctr_rdg_rec.value_timestamp IS NOT NULL AND
      p_ctr_rdg_rec.value_timestamp <> l_curr_ctr_rdg_rec.value_timestamp THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Update Value Timestamp...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_UPD_READING_DATE',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   IF p_ctr_rdg_rec.counter_reading <> FND_API.G_MISS_NUM AND
      p_ctr_rdg_rec.counter_reading IS NOT NULL AND
      p_ctr_rdg_rec.counter_reading <> NVL(l_curr_ctr_rdg_rec.counter_reading,0) THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Update Counter Reading...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_UPD_CTR_READING',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   IF p_ctr_rdg_rec.adjustment_type <> FND_API.G_MISS_CHAR AND
      p_ctr_rdg_rec.adjustment_type IS NOT NULL AND
      p_ctr_rdg_rec.adjustment_type <> NVL(l_curr_ctr_rdg_rec.adjustment_type,'$#$') THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Update Adjustment Type...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
	   ( p_msg_name     => 'CSI_API_CTR_UPD_ADJ_TYPE',
	     p_token1_name  => 'MODE',
	     p_token1_val   => l_mode
	   );
   END IF;
   --
   IF p_ctr_rdg_rec.adjustment_reading <> FND_API.G_MISS_NUM AND
      p_ctr_rdg_rec.adjustment_reading IS NOT NULL AND
      p_ctr_rdg_rec.adjustment_reading <> NVL(l_curr_ctr_rdg_rec.adjustment_reading,0) THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Cannot Update Adjustment Reading...');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_UPD_ADJ_RDG');
   END IF;
   --
   -- If the Source counter or its object counters have a reading lock date then
   -- the reading date cannot be earlier than the lock date (Max of all)
   l_rdg_lock_date := NULL;
   Begin
      select max(reading_lock_date)
      into l_rdg_lock_date
      from CSI_COUNTER_READING_LOCKS
      where counter_id = l_curr_ctr_rdg_rec.counter_id
      OR    counter_id in (select object_counter_id
                           from CSI_COUNTER_RELATIONSHIPS
                           where source_counter_id = l_curr_ctr_rdg_rec.counter_id
                           and   nvl(active_end_date,(l_curr_ctr_rdg_rec.value_timestamp+1)) > l_curr_ctr_rdg_rec.value_timestamp);
   End;
   --
   IF l_rdg_lock_date IS NOT NULL THEN
      IF l_curr_ctr_rdg_rec.value_timestamp <= l_rdg_lock_date THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
           csi_ctr_gen_utility_pvt.put_line('Reading Date cannot be earlier than the Reading Lock Date...');
         END IF;          -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
             ( p_msg_name     =>  'CSI_API_CTR_RDG_DATE_LOCKED',
               p_token1_name  =>  'LOCKED_DATE',
               p_token1_val   =>  to_char(l_rdg_lock_date,l_date_format), --fix for bug 5435071
               p_token2_name  =>  'MODE',
               p_token2_val   =>  l_mode
             );
      END IF;
   END IF;
   --
   -- Get the last reading for this counter

   -- Get the last reading for this counter
  -- Bug 	8214848
   BEGIN
    SELECT CTR_VAL_MAX_SEQ_NO INTO l_ctr_val_max
      FROM CSI_COUNTERS_B WHERE COUNTER_ID = l_curr_ctr_rdg_rec.counter_id;

   SELECT COUNTER_READING,NET_READING,LIFE_TO_DATE_READING,
          VALUE_TIMESTAMP
         INTO l_prev_ctr_max_reading,
              l_prev_net_max_reading,
              l_prev_ltd_max_reading,
              l_prev_value_max_timestamp
              --l_prev_max_comments
   FROM CSI_COUNTER_READINGS WHERE COUNTER_VALUE_ID = NVL(l_ctr_val_max,-1);

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('l_ctr_val_max - ' || l_ctr_val_max );
   END IF;          -- 8214848 - dsingire

  EXCEPTION
   WHEN OTHERS THEN
    -- Assign max counter value id to 0 and use the PREV_READING_CUR cursor
    l_ctr_val_max := -1;
  END;  --

   IF (l_prev_value_max_timestamp <=  l_curr_ctr_rdg_rec.value_timestamp
            AND NVL(l_ctr_val_max,-1) > 0) THEN

      -- The requested timestamp is greater than the timestamp of the
      -- CTR_VAL_MAX_SEQ_NO
      l_prev_ctr_reading := l_prev_ctr_max_reading;
      l_prev_net_reading := l_prev_net_max_reading;
      l_prev_ltd_reading := l_prev_ltd_max_reading;
      l_prev_value_timestamp := l_prev_value_max_timestamp;
      --l_prev_comments := l_prev_max_comments;

      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Max Value counter id used');
      END IF;          -- 8214848 - dsingire

   ELSE

     OPEN PREV_READING_CUR(l_curr_ctr_rdg_rec.counter_id,l_curr_ctr_rdg_rec.value_timestamp);
     FETCH PREV_READING_CUR
     INTO  l_prev_ctr_reading,
     l_prev_net_reading,
           l_prev_ltd_reading,
     l_prev_value_timestamp;
     CLOSE PREV_READING_CUR;
   END IF;

   --
   -- Get the next reading for this counter
   OPEN NEXT_READING_CUR(l_curr_ctr_rdg_rec.counter_id,l_curr_ctr_rdg_rec.value_timestamp);
   FETCH NEXT_READING_CUR
   INTO  l_next_ctr_reading,
	 l_next_value_timestamp,
         l_next_reset_mode,
         l_next_adj_type,
         l_next_auto_rollover;
   CLOSE NEXT_READING_CUR;
   --
   IF l_prev_ctr_reading IS NULL AND
      l_next_reset_mode IS NOT NULL THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Next Reading is a Reset. Disabling the current reading will cause the Reset Reading to be the first reading.');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NEXT_RESET_RDG');
   END IF;
   --
   IF l_prev_ctr_reading IS NULL AND
      l_next_adj_type IS NOT NULL THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Next Reading is a Adjustment. Disabling the current reading will cause the Adjustment Reading to be the first reading.');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NEXT_ADJ_RDG');
   END IF;
   --
   IF l_prev_ctr_reading IS NULL AND
      nvl(l_next_auto_rollover,'N') = 'Y' THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Next Reading is an Automatic Rollover. Disabling the current reading will cause the Automatic Rollover Reading to be the first reading.');
      END IF;          -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NEXT_AUTO_RDG');
   END IF;
   --
   p_ctr_rdg_rec.object_version_number := l_curr_ctr_rdg_rec.object_version_number + 1;
   --
   -- Below two assignments are required by Update public API to call OKC Assembler
   p_ctr_rdg_rec.counter_id := l_curr_ctr_rdg_rec.counter_id;
   p_ctr_rdg_rec.value_timestamp := l_curr_ctr_rdg_rec.value_timestamp;
   --
   -- Call Table Handler to Update CSI_COUNTER_READINGS
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line('Calling Update Row to Disable the Reading...');
   END IF;          -- 8214848 - dsingire
   CSI_COUNTER_READINGS_PKG.Update_Row(
	 p_COUNTER_VALUE_ID           =>  p_ctr_rdg_rec.counter_value_id
	,p_COUNTER_ID                 =>  NULL
	,p_VALUE_TIMESTAMP            =>  NULL
	,p_COUNTER_READING            =>  NULL
	,p_RESET_MODE                 =>  NULL
	,p_RESET_REASON               =>  p_ctr_rdg_rec.reset_reason -- NULL 6398254
	,p_ADJUSTMENT_TYPE            =>  NULL
	,p_ADJUSTMENT_READING         =>  NULL
	,p_OBJECT_VERSION_NUMBER      =>  p_ctr_rdg_rec.object_version_number
	,p_LAST_UPDATE_DATE           =>  SYSDATE
	,p_LAST_UPDATED_BY            =>  l_user_id
	,p_CREATION_DATE              =>  NULL
	,p_CREATED_BY                 =>  NULL
	,p_LAST_UPDATE_LOGIN          =>  l_conc_login_id
	,p_ATTRIBUTE1                 =>  NULL
	,p_ATTRIBUTE2                 =>  NULL
	,p_ATTRIBUTE3                 =>  NULL
	,p_ATTRIBUTE4                 =>  NULL
	,p_ATTRIBUTE5                 =>  NULL
	,p_ATTRIBUTE6                 =>  NULL
	,p_ATTRIBUTE7                 =>  NULL
	,p_ATTRIBUTE8                 =>  NULL
	,p_ATTRIBUTE9                 =>  NULL
	,p_ATTRIBUTE10                =>  NULL
	,p_ATTRIBUTE11                =>  NULL
	,p_ATTRIBUTE12                =>  NULL
	,p_ATTRIBUTE13                =>  NULL
	,p_ATTRIBUTE14                =>  NULL
	,p_ATTRIBUTE15                =>  NULL
	,p_ATTRIBUTE16                =>  NULL
	,p_ATTRIBUTE17                =>  NULL
	,p_ATTRIBUTE18                =>  NULL
	,p_ATTRIBUTE19                =>  NULL
	,p_ATTRIBUTE20                =>  NULL
	,p_ATTRIBUTE21                =>  NULL
	,p_ATTRIBUTE22                =>  NULL
	,p_ATTRIBUTE23                =>  NULL
	,p_ATTRIBUTE24                =>  NULL
	,p_ATTRIBUTE25                =>  NULL
	,p_ATTRIBUTE26                =>  NULL
	,p_ATTRIBUTE27                =>  NULL
	,p_ATTRIBUTE28                =>  NULL
	,p_ATTRIBUTE29                =>  NULL
	,p_ATTRIBUTE30                =>  NULL
	,p_ATTRIBUTE_CATEGORY         =>  NULL
	,p_MIGRATED_FLAG              =>  NULL
	,p_COMMENTS                   =>  NULL
	,p_LIFE_TO_DATE_READING       =>  NULL
	,p_TRANSACTION_ID             =>  NULL
	,p_AUTOMATIC_ROLLOVER_FLAG    =>  NULL
	,p_INCLUDE_TARGET_RESETS      =>  NULL
	,p_SOURCE_COUNTER_VALUE_ID    =>  NULL
	,p_NET_READING                =>  NULL
	,p_DISABLED_FLAG              =>  p_ctr_rdg_rec.disabled_flag
	,p_SOURCE_CODE                =>  NULL
	,p_SOURCE_LINE_ID             =>  NULL
	,p_INITIAL_READING_FLAG       =>  NULL
	);

   IF p_ctr_rdg_rec.disabled_flag = 'Y' THEN
       l_ctr_val_max_seq_no := NULL;
       --Add call to CSI_COUNTER_PVT.update_ctr_val_max_seq_no
       --for bug 7374316
       CSI_COUNTER_PVT.update_ctr_val_max_seq_no(
          p_api_version           =>  1.0
         ,p_commit                =>  fnd_api.g_false
         ,p_init_msg_list         =>  fnd_api.g_true
         ,p_validation_level      =>  fnd_api.g_valid_level_full
         ,p_counter_id            =>  p_ctr_rdg_rec.counter_id
         ,px_ctr_val_max_seq_no   =>  l_ctr_val_max_seq_no
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
   END IF;
   --
   Disable_Target_Derive_Rdg
     ( p_src_counter_value_id   => p_ctr_rdg_rec.counter_value_id,
       x_return_status          => x_return_status
     );
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      csi_ctr_gen_utility_pvt.put_line('ERROR FROM Disable_Target_Derive_Rdg API ');
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   -- Following variables will be set inside the loop
   l_previous_rdg := l_prev_ctr_reading;
   l_upd_previous_rdg := l_prev_ctr_reading;
   l_previous_net := l_prev_net_reading;
   l_previous_ltd := l_prev_ltd_reading;
   --
   -- For Adjustments or next reading was a reset then
   -- adjust the Net Reading of Subsequent readings.
   -- Re-calculate Target counters irrespective of net reading changes.

   --Modified if condition for bug 7589871, to allow later reading to be updated for Changed Fluctuating counter
   IF (l_direction <> 'B') OR (l_direction = 'B' AND l_reading_type = 2) THEN
      IF l_reading_type = 2 OR
	 l_curr_ctr_rdg_rec.adjustment_reading IS NOT NULL OR
	 l_next_adj_type IS NOT NULL OR
	 NVL(l_next_reset_mode,'X') = 'SOFT' THEN
	 l_update_loop := TRUE;
	 l_adj_ctr := 0;
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	  csi_ctr_gen_utility_pvt.put_line('Updating Later Readings for Ctr ID '||to_char(l_curr_ctr_rdg_rec.counter_id));
   END IF;          -- 8214848 - dsingire
	 FOR later_rdg IN LATER_READINGS_CUR(l_curr_ctr_rdg_rec.counter_id
					    ,l_curr_ctr_rdg_rec.value_timestamp)
	 LOOP
	    l_adj_ctr := l_adj_ctr + 1;
	    --
	    -- If the immediate reading after the current disabled rdg is an Adjustment then
	    -- we need to update the counter reading of that adjustment, provided it took the same disabled
	    -- counter reading. If a counter rdg was also captured as the part of adjustment then
	    -- no need to update the counter reading. Just retain the same and pass it to Net rdg calculation.
	    -- It will come back with the same values.
	    --
	    -- Above statements are true only for Absolute counters since we take the usage for Change counters
	    --
	    -- l_previous_rdg always takes the un-updated counter reading from the cursor
	    -- l_upd_previous_rdg takes the updated value which will be used to compute the usage for Targets
	    -- l_prev_ctr_reading is read outside the loop and never change. Used only for the first record
	    -- in the following Loop.
	    --
	    IF later_rdg.adjustment_type IS NOT NULL AND
	       l_reading_type = 1 THEN
	       IF l_adj_ctr = 1 THEN -- First record of Later Readings (Immediate record after disabled rdg)
		  -- Checking whether it took the same rdg as the disabled one.
		  IF later_rdg.counter_reading = l_curr_ctr_rdg_rec.counter_reading THEN
		     l_later_ctr_reading := l_prev_ctr_reading; -- The one before disable rdg
		  ELSE -- Retain the counter reading
		     l_later_ctr_reading := later_rdg.counter_reading;
		  END IF;
	       ELSE
		  IF later_rdg.counter_reading <> l_previous_rdg THEN
		     l_later_ctr_reading := later_rdg.counter_reading;
		  -- ELSE part is basically retaining the l_later_ctr_reading derived in Previous iteration
		  END IF;
	       END IF;
	    ELSE
	       l_later_ctr_reading := later_rdg.counter_reading;
	    END IF;
	    --
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	      csi_ctr_gen_utility_pvt.put_line('Updating Counter Value ID '||to_char(later_rdg.counter_value_id));
      END IF;          -- 8214848 - dsingire
	    IF NVL(later_rdg.reset_mode,'X') = 'SOFT' THEN
			-- added IF for Bug 9148094
			--l_update_net_flag :=  NVL(fnd_profile.value('CSI: UPDATE NET READINGS UPON RESET'), 'Y');
			csi_ctr_gen_utility_pvt.put_line(' Update Net Reading Flag : '||l_update_net_flag);
			IF l_update_net_flag = 'Y' THEN
				UPDATE CSI_COUNTER_READINGS
				set net_reading = later_rdg.counter_reading,
				life_to_date_reading = l_previous_ltd,
				last_update_date = sysdate,
				last_updated_by = l_user_id
				where counter_value_id = later_rdg.counter_value_id;
				l_previous_net := later_rdg.counter_reading;
			ELSE
				UPDATE CSI_COUNTER_READINGS
				set net_reading = l_previous_net,
				life_to_date_reading = l_previous_ltd,
				last_update_date = sysdate,
				last_updated_by = l_user_id
				where counter_value_id = later_rdg.counter_value_id;
			END IF;
	    ELSE
	       Calculate_Net_Reading
		  ( p_prev_net_rdg      => l_previous_net
		   ,p_prev_ltd_rdg      => l_previous_ltd
		   ,p_curr_rdg          => l_later_ctr_reading -- later_rdg.counter_reading
		   ,p_prev_rdg          => l_upd_previous_rdg -- l_previous_rdg
		   ,p_curr_adj          => later_rdg.adjustment_reading
		   ,p_rdg_type          => l_reading_type
		   ,p_direction         => l_direction
		   ,px_net_rdg          => l_net_reading
		   ,px_ltd_rdg          => l_ltd_reading
		   ,l_ctr_rdg_rec      => p_ctr_rdg_rec -- added 6398254
		  );
	       UPDATE CSI_COUNTER_READINGS
	       set counter_reading = l_later_ctr_reading,
		   net_reading = l_net_reading,
		   life_to_date_reading = l_ltd_reading,
		   last_update_date = sysdate,
		   last_updated_by = l_user_id
	       where counter_value_id = later_rdg.counter_value_id;
	       --
	       l_previous_net := l_net_reading;
	       l_previous_ltd := l_ltd_reading;
	    END IF;
	    --
	    --
	    -- Re-calculate Compute Target Counters
	    -- For Resets which did not include Targets before, no need to Re-compute
	    --
	    IF later_rdg.reset_mode IS NULL OR
	       (later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y') THEN
	       l_target_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_target_ctr_rec.counter_value_id := later_rdg.counter_value_id; -- source_counter_value_id
	       l_target_ctr_rec.counter_id := l_curr_ctr_rdg_rec.counter_id;
	       l_target_ctr_rec.value_timestamp := later_rdg.value_timestamp;
	       l_target_ctr_rec.adjustment_reading := later_rdg.adjustment_reading;
	       l_target_ctr_rec.adjustment_type := later_rdg.adjustment_type;
	       --
	       -- Used l_later_ctr_reading instead of later_rdg.counter_reading
	       --
	       IF later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y' THEN
		  -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading);
		  l_target_ctr_rec.counter_reading := later_rdg.counter_reading;
	       ELSE
		  IF l_reading_type = 1 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(l_later_ctr_reading - nvl(l_upd_previous_rdg,0));
		     l_target_ctr_rec.counter_reading := l_later_ctr_reading - nvl(l_upd_previous_rdg,0);
		  ELSIF l_reading_type = 2 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(l_later_ctr_reading);
		     l_target_ctr_rec.counter_reading := l_later_ctr_reading;
		  END IF;
	       END IF;
	       --
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	          csi_ctr_gen_utility_pvt.put_line('Calling Compute_Target_Counters for Update...');
         END IF;          -- 8214848 - dsingire
	       Compute_Target_Counters
		  (
		    p_api_version           =>  1.0
		   ,p_commit                =>  p_commit
		   ,p_init_msg_list         =>  p_init_msg_list
		   ,p_validation_level      =>  p_validation_level
		   ,p_txn_rec               =>  l_txn_rec
		   ,p_ctr_rdg_rec           =>  l_target_ctr_rec
		   ,p_mode                  =>  'UPDATE'
		   ,x_return_status         =>  x_return_status
		   ,x_msg_count             =>  x_msg_count
		   ,x_msg_data              =>  x_msg_data
		 );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Target_Counters API ');
		     csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	    END IF; -- Target Counter call check
	    --
	    -- Re-compute Derive comunters.
	    -- No need for SOFT reset as we would not have created it before.
	    --
	    IF NVL(later_rdg.reset_mode,'$#$') <> 'SOFT' THEN
	       l_derive_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_derive_ctr_rec.counter_value_id := later_rdg.counter_value_id; -- source_counter_value_id
	       l_derive_ctr_rec.counter_id := l_curr_ctr_rdg_rec.counter_id;
	       l_derive_ctr_rec.value_timestamp := later_rdg.value_timestamp;
	       --
	       -- Compute Derive Counters
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	          csi_ctr_gen_utility_pvt.put_line('Calling Compute_Derive_Counters for Update...');
         END IF;          -- 8214848 - dsingire
	       Compute_Derive_Counters
		  (
		    p_api_version           => 1.0
		   ,p_commit                => p_commit
		   ,p_init_msg_list         => p_init_msg_list
		   ,p_validation_level      => p_validation_level
		   ,p_txn_rec               => l_txn_rec
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
	    END IF; -- Derive Counters call check
	    --
	    l_previous_rdg := later_rdg.counter_reading;
	    l_upd_previous_rdg := l_later_ctr_reading;
	 END LOOP; -- Later Readings loop
      END IF; -- Condition to loop thru' later readings
      --
      -- If the above loop was not executed then to re-calculate the Traget counters we loop thru'
      -- This is because target counter readings could change even if the net reading did not change.
      --
      l_previous_rdg := l_prev_ctr_reading; -- Assigning it to Rdg before Disable Rdg (Just in case...)
      --
      IF NOT l_update_loop THEN
	 FOR later_rdg IN LATER_READINGS_CUR(l_curr_ctr_rdg_rec.counter_id,
					     l_curr_ctr_rdg_rec.value_timestamp)
	 LOOP
	    -- Re-calculate Compute Target Counters
	    -- For Resets which did not include Targets before, no need to Re-compute
	    --
	    IF later_rdg.reset_mode IS NULL OR
	       (later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y') THEN
	       l_target_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_target_ctr_rec.counter_value_id := later_rdg.counter_value_id; -- source_counter_value_id
	       l_target_ctr_rec.counter_id := l_curr_ctr_rdg_rec.counter_id;
	       l_target_ctr_rec.value_timestamp := later_rdg.value_timestamp;
	       l_target_ctr_rec.adjustment_reading := later_rdg.adjustment_reading;
	       l_target_ctr_rec.adjustment_type := later_rdg.adjustment_type;
	       --
	       IF later_rdg.reset_mode IS NOT NULL AND NVL(later_rdg.include_target_resets,'N') = 'Y' THEN
		  -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading);
		  l_target_ctr_rec.counter_reading := later_rdg.counter_reading;
	       ELSE
		  IF l_reading_type = 1 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading - nvl(l_previous_rdg,0));
		     l_target_ctr_rec.counter_reading := later_rdg.counter_reading - nvl(l_previous_rdg,0);
		  ELSIF l_reading_type = 2 THEN
		     -- l_target_ctr_rec.counter_reading := ABS(later_rdg.counter_reading);
		     l_target_ctr_rec.counter_reading := later_rdg.counter_reading;
		  END IF;
	       END IF;
	       --
	       -- Call Compute Target Counters
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	          csi_ctr_gen_utility_pvt.put_line('Calling Compute_Target_Counters for Update...');
         END IF;          -- 8214848 - dsingire
	       Compute_Target_Counters
		  (
		    p_api_version           =>  1.0
		   ,p_commit                =>  p_commit
		   ,p_init_msg_list         =>  p_init_msg_list
		   ,p_validation_level      =>  p_validation_level
		   ,p_txn_rec               =>  l_txn_rec
		   ,p_ctr_rdg_rec           =>  l_target_ctr_rec
		   ,p_mode                  =>  'UPDATE'
		   ,x_return_status         =>  x_return_status
		   ,x_msg_count             =>  x_msg_count
		   ,x_msg_data              =>  x_msg_data
		 );
	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0 LOOP
		     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		     );
		     csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Target_Counters API ');
		     csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	    END IF; -- Target counter call check
	    --
	    -- Re-Compute Derive Counters
	    -- No need for SOFT reset as we would not have created it before.
	    IF NVL(later_rdg.reset_mode,'$#$') <> 'SOFT' THEN
	       l_derive_ctr_rec := l_temp_ctr_rdg_rec;
	       --
	       l_derive_ctr_rec.counter_value_id := later_rdg.counter_value_id; -- source_counter_value_id
	       l_derive_ctr_rec.counter_id := l_curr_ctr_rdg_rec.counter_id;
	       l_derive_ctr_rec.value_timestamp := later_rdg.value_timestamp;
	       --
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	          csi_ctr_gen_utility_pvt.put_line('Calling Compute_Derive_Counters for Update...');
         END IF;          -- 8214848 - dsingire
	       Compute_Derive_Counters
		  (
		    p_api_version           => 1.0
		   ,p_commit                => p_commit
		   ,p_init_msg_list         => p_init_msg_list
		   ,p_validation_level      => p_validation_level
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
		     csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Derive_Counters API ');
		     csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		     l_msg_index := l_msg_index + 1;
		     l_msg_count := l_msg_count - 1;
		  END LOOP;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	    END IF; -- Derive counters call check
	    --
	    l_previous_rdg := later_rdg.counter_reading;
	 END LOOP;
      END IF; -- l_update_loop check
   ELSE
      -- For Bi-directional counters just Re-compute the Derived filters for Later readings
      FOR later_rdg IN LATER_READINGS_CUR(l_curr_ctr_rdg_rec.counter_id,
					  l_curr_ctr_rdg_rec.value_timestamp)
      LOOP
	 -- Re-Compute Derive Counters
	 -- No need for SOFT reset as we would not have created it before.
	 IF NVL(later_rdg.reset_mode,'$#$') <> 'SOFT' THEN
	    l_derive_ctr_rec := l_temp_ctr_rdg_rec;
	    --
	    l_derive_ctr_rec.counter_value_id := later_rdg.counter_value_id; -- source_counter_value_id
	    l_derive_ctr_rec.counter_id := l_curr_ctr_rdg_rec.counter_id;
	    l_derive_ctr_rec.value_timestamp := later_rdg.value_timestamp;
	    --
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	      csi_ctr_gen_utility_pvt.put_line('Calling Compute_Derive_Counters for Update...');
      END IF;          -- 8214848 - dsingire
	    Compute_Derive_Counters
	       (
		 p_api_version           => 1.0
		,p_commit                => p_commit
		,p_init_msg_list         => p_init_msg_list
		,p_validation_level      => p_validation_level
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
		  csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Derive_Counters API ');
		  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF; -- Derive counters call check
      END LOOP;
   END IF; -- l_direction check
   --
   l_upd_fl_rdg_rec.counter_id := l_curr_ctr_rdg_rec.counter_id;
   l_upd_fl_rdg_rec.value_timestamp := l_curr_ctr_rdg_rec.value_timestamp;
   l_upd_fl_rdg_rec.disabled_flag := 'Y';
   --
   -- Call Compute Formula
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line('Calling Compute_Formula_Counters for Update...');
   END IF;          -- 8214848 - dsingire
   Compute_Formula_Counters
      (
	p_api_version           => 1.0
       ,p_commit                => p_commit
       ,p_init_msg_list         => p_init_msg_list
       ,p_validation_level      => p_validation_level
       ,p_txn_rec               => l_txn_rec
       ,p_ctr_rdg_rec           => l_upd_fl_rdg_rec
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
     );
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      csi_ctr_gen_utility_pvt.put_line('Error from Compute_Formula_Counters API...');
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
	 x_msg_data := FND_MSG_PUB.GET
	 (  l_msg_index,
	    FND_API.G_FALSE
	 );
	 csi_ctr_gen_utility_pvt.put_line('ERROR FROM Compute_Formula_Counters API ');
	 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	 l_msg_index := l_msg_index + 1;
	 l_msg_count := l_msg_count - 1;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
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
      ROLLBACK TO update_counter_reading_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_reading_pvt;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_reading_pvt;
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
--
PROCEDURE Capture_Ctr_Property_Reading
   (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_prop_rdg_rec      IN OUT NOCOPY csi_ctr_datastructures_pub.ctr_property_readings_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
   l_api_name                      CONSTANT VARCHAR2(30)   := 'CAPTURE_CTR_PROPERTY_READING';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;
   l_pval                          VARCHAR2(1) := 'F';
   l_prop_lov_type                 VARCHAR2(30);
   l_property_type                 VARCHAR2(30);
   l_is_nullable                   VARCHAR2(30);
   l_n_temp                        NUMBER;
   l_d_temp                        DATE;
   l_process_flag                  BOOLEAN := TRUE;
   l_debug_level       NUMBER;    -- 8214848 - dsingire
   l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
   l_conc_login_id		NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
   --
   CURSOR PROP_LOV_CUR(p_prop_id IN NUMBER) IS
   select lookup_code,meaning   --Meaning added for bug #6904836
   from CSI_LOOKUPS
   where lookup_type = (select property_lov_type
                        from CSI_COUNTER_PROPERTIES_B
                        where counter_property_id = p_prop_id);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  capture_ctr_property_reading;
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
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
   csi_ctr_gen_utility_pvt.put_line( 'capture_ctr_property_reading'              ||'-'||
                                  p_api_version                              ||'-'||
                                  nvl(p_commit,FND_API.G_FALSE)              ||'-'||
                                  nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
                                  nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
   END IF;          -- 8214848 - dsingire
   --
   IF p_ctr_prop_rdg_rec.counter_value_id IS NULL OR
      p_ctr_prop_rdg_rec.counter_value_id = FND_API.G_MISS_NUM THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_VALUE_ID_MISS');
   END IF;
   --
   IF p_ctr_prop_rdg_rec.counter_property_id IS NULL OR
      p_ctr_prop_rdg_rec.counter_property_id = FND_API.G_MISS_NUM THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
   END IF;
   --
   IF p_ctr_prop_rdg_rec.value_timestamp IS NULL OR
      p_ctr_prop_rdg_rec.value_timestamp = FND_API.G_MISS_DATE THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID_RDG_DATE');
   END IF;
   --
   Begin
      select property_lov_type,property_data_type,is_nullable
      into l_prop_lov_type,l_property_type, l_is_nullable
      from CSI_COUNTER_PROPERTIES_B
      where counter_property_id = p_ctr_prop_rdg_rec.counter_property_id
      and   nvl(end_date_active,(sysdate+1)) > sysdate;
   Exception
      when no_data_found THEN
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.put_line('Counter Property is Invalid or Expired...');
         END IF;          -- 8214848 - dsingire
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
   End;
   --
   IF l_is_nullable <> 'Y' THEN
	   IF p_ctr_prop_rdg_rec.property_value IS NULL OR
	      p_ctr_prop_rdg_rec.property_value = FND_API.G_MISS_CHAR THEN
	      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_VALUE_MISSING');
	   END IF;
   END IF;
   --
   IF NOT Valid_Ctr_Property_ID
            (p_ctr_value_id    =>   p_ctr_prop_rdg_rec.counter_value_id
            ,p_ctr_prop_id     =>   p_ctr_prop_rdg_rec.counter_property_id) THEN
      -- Property does not belong to the captured counter
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
   END IF;
   --
   IF Has_Property_Value(p_counter_property_id   =>  p_ctr_prop_rdg_rec.counter_property_id,
                         p_counter_value_id      =>  p_ctr_prop_rdg_rec.counter_value_id) = 'T' THEN
      -- Property value already exists
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_VALUE_EXISTS');
   END IF;
   --
   IF l_is_nullable <> 'Y' THEN
	   IF l_prop_lov_type IS NOT NULL THEN
	      FOR prop_rec in PROP_LOV_CUR(p_ctr_prop_rdg_rec.counter_property_id) LOOP
		 IF RTRIM(p_ctr_prop_rdg_rec.PROPERTY_VALUE) = RTRIM(prop_rec.lookup_code) OR
        RTRIM(p_ctr_prop_rdg_rec.PROPERTY_VALUE) = RTRIM(prop_rec.meaning) THEN    --Condition added for bug #6904836
        l_pval := 'T';
		 END IF;
	      END LOOP;
	   ELSE -- LOV Type Not defined
	      l_pval := 'T';
	   END IF;
	   --
	   IF l_pval = 'F' THEN
        IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
	        csi_ctr_gen_utility_pvt.put_line('Property Value does not match with Property LOV Type...');
        END IF;          -- 8214848 - dsingire
	      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_LOV_MISMATCH');
	   END IF;
	   --
	   /***********************************************
	    *Check if value is valid for property data type
	    ***********************************************/
	   IF l_property_type = 'NUMBER' THEN
	      BEGIN
		 l_n_temp := TO_NUMBER(p_ctr_prop_rdg_rec.PROPERTY_VALUE);
	      EXCEPTION
		 WHEN OTHERS THEN
		    IF (SQLCODE = -6502) THEN
		       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_DATA_MISMATCH');
		    ELSE
		       RAISE;
		    END IF;
	      END;
	   ELSIF l_property_type = 'CHAR' then
	      null;
	   ELSIF l_property_type = 'DATE' then
	      BEGIN
		 l_d_temp := to_date(p_ctr_prop_rdg_rec.PROPERTY_VALUE,'MM-DD-YYYY');
	      EXCEPTION
		 WHEN OTHERS THEN
		    IF (SQLCODE BETWEEN -1899 AND -1800) THEN
		       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_DATA_MISMATCH');
		    ELSE
		       RAISE;
		    END IF;
	      END;
	   ELSE
	      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_DATA_MISMATCH');
	   END IF;

   END IF;
   --
   -- Generate Counter_Prop_Value_id
   IF p_ctr_prop_rdg_rec.counter_prop_value_id IS NULL OR
      p_ctr_prop_rdg_rec.counter_prop_value_id = FND_API.G_MISS_NUM THEN
      WHILE l_process_flag LOOP
         select CSI_CTR_PROPERTY_READINGS_S.nextval
         into p_ctr_prop_rdg_rec.counter_prop_value_id from dual;
         IF NOT Counter_Prop_Value_Exists(p_ctr_prop_rdg_rec.counter_prop_value_id) THEN
            l_process_flag := FALSE;
         END IF;
      END LOOP;
   ELSE
      IF Counter_Prop_Value_Exists(p_ctr_prop_rdg_rec.counter_prop_value_id) THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg
              ( p_msg_name     =>  'CSI_API_CTR_PROP_VALUE_EXISTS',
                p_token1_name  =>  'PROP_VALUE_ID',
                p_token1_val   =>  to_char(p_ctr_prop_rdg_rec.counter_prop_value_id)
              );
      END IF;
   END IF;
   --
   p_ctr_prop_rdg_rec.object_version_number := 1;
   --
   CSI_CTR_PROPERTY_READING_PKG.Insert_Row(
	 px_COUNTER_PROP_VALUE_ID         => p_ctr_prop_rdg_rec.counter_prop_value_id
	,p_COUNTER_VALUE_ID               => p_ctr_prop_rdg_rec.counter_value_id
	,p_COUNTER_PROPERTY_ID            => p_ctr_prop_rdg_rec.counter_property_id
	,p_PROPERTY_VALUE                 => p_ctr_prop_rdg_rec.property_value
	,p_VALUE_TIMESTAMP                => p_ctr_prop_rdg_rec.value_timestamp
	,p_OBJECT_VERSION_NUMBER          => p_ctr_prop_rdg_rec.object_version_number
	,p_LAST_UPDATE_DATE               => SYSDATE
	,p_LAST_UPDATED_BY                => l_user_id
	,p_CREATION_DATE                  => SYSDATE
	,p_CREATED_BY                     => l_user_id
	,p_LAST_UPDATE_LOGIN              => l_conc_login_id
	,p_ATTRIBUTE1                     => p_ctr_prop_rdg_rec.attribute1
	,p_ATTRIBUTE2                     => p_ctr_prop_rdg_rec.attribute2
	,p_ATTRIBUTE3                     => p_ctr_prop_rdg_rec.attribute3
	,p_ATTRIBUTE4                     => p_ctr_prop_rdg_rec.attribute4
	,p_ATTRIBUTE5                     => p_ctr_prop_rdg_rec.attribute5
	,p_ATTRIBUTE6                     => p_ctr_prop_rdg_rec.attribute6
	,p_ATTRIBUTE7                     => p_ctr_prop_rdg_rec.attribute7
	,p_ATTRIBUTE8                     => p_ctr_prop_rdg_rec.attribute8
	,p_ATTRIBUTE9                     => p_ctr_prop_rdg_rec.attribute9
	,p_ATTRIBUTE10                    => p_ctr_prop_rdg_rec.attribute10
	,p_ATTRIBUTE11                    => p_ctr_prop_rdg_rec.attribute11
	,p_ATTRIBUTE12                    => p_ctr_prop_rdg_rec.attribute12
	,p_ATTRIBUTE13                    => p_ctr_prop_rdg_rec.attribute13
	,p_ATTRIBUTE14                    => p_ctr_prop_rdg_rec.attribute14
	,p_ATTRIBUTE15                    => p_ctr_prop_rdg_rec.attribute15
	,p_ATTRIBUTE_CATEGORY             => p_ctr_prop_rdg_rec.attribute_category
	,p_MIGRATED_FLAG                  => 'N'
   );
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
      ROLLBACK TO capture_ctr_property_reading;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO capture_ctr_property_reading;
      FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
           p_data  => x_msg_data
         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO capture_ctr_property_reading;
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
END Capture_Ctr_Property_Reading;
--
FUNCTION Est_daily_avg(
    p_start_date	IN DATE,
    p_start_reading	IN NUMBER,
    p_end_date		IN DATE,
    p_end_reading	IN NUMBER
   ) RETURN NUMBER IS
    l_daily_avg   NUMBER;
BEGIN
    l_daily_avg :=  (p_end_reading-p_start_reading)/(trunc(p_end_date)-trunc(p_start_date));
    RETURN (l_daily_avg);
END;
--
PROCEDURE ESTIMATE_START_READINGS(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_default_value		 IN   NUMBER,
    p_calculation_start_date     IN   DATE,
    x_calc_start_reading         OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   CURSOR PRIOR_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "prev_reading",b.value_timestamp "prev_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   b.value_timestamp < b_rdg_date
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp desc;
   --
   l_prev_reading   NUMBER;
   l_prev_value_timestamp  DATE;
   --
   CURSOR POST_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "post_reading",b.value_timestamp "post_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   b.value_timestamp > b_rdg_date
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp asc;
   --
   l_post_reading    NUMBER;
   l_post_value_timestamp  DATE;
   --
   CURSOR PASSED_DT_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "passed_dt_reading", b.value_timestamp "passed_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   and   trunc(b.value_timestamp) = trunc(b_rdg_date)
   order by b.value_timestamp desc;
   --
   l_passed_dt_reading   NUMBER;
   l_passed_rdg_date     DATE;
   --
   CURSOR FIRST_RDG_VALUES(b_counter_id NUMBER) IS
   select b.net_reading "first_reading",b.value_timestamp "first_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp asc;
   --
   l_first_reading   NUMBER;
   l_first_rdg_date  DATE;
   --
   CURSOR CTR_START_DATE(b_counter_id NUMBER) IS
   select nvl(start_date_active,creation_date) "ctr_start_date"
   from CSI_COUNTERS_B
   where counter_id = b_counter_id;

   CURSOR CTR_DIRECTION(b_counter_id NUMBER) IS
   select direction
   from CSI_COUNTERS_B
   where counter_id = b_counter_id;
   --
   l_ctr_direction VARCHAR2(1);
   --
   l_api_name              CONSTANT VARCHAR2(30)   := 'ESTIMATE_START_READINGS';
   l_api_version           CONSTANT NUMBER         := 1.0;
   l_calculation_start_rdg NUMBER;
   l_calculation_start_dt  DATE;
   l_calc_daily_avg        NUMBER;
   l_calc_usage            NUMBER;
   l_calc_start_rdg        NUMBER;
   l_debug_level           NUMBER;    -- 8214848 - dsingire
BEGIN
   SAVEPOINT ESTIMATE_START_READINGS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
      csi_ctr_gen_utility_pvt.put_line( 'Inside Estimate_Start_Readings...');
   END IF;          -- 8214848 - dsingire
   --
   -- fetch the reading of the passed avg calculation start date
   OPEN PASSED_DT_RDG_VALUES(p_counter_id, p_calculation_start_date);
   FETCH PASSED_DT_RDG_VALUES
   INTO l_calculation_start_rdg,l_calculation_start_dt;
   CLOSE PASSED_DT_RDG_VALUES;
   -- if no actual reading on passed avg calc start dt then compute the reading.
   IF l_calculation_start_rdg is NULL THEN
      OPEN PRIOR_RDG_VALUES(p_counter_id,p_calculation_start_date);
      FETCH PRIOR_RDG_VALUES
      INTO l_prev_reading,l_prev_value_timestamp;
      CLOSE PRIOR_RDG_VALUES;
      --
      IF l_prev_reading IS NOT NULL THEN
         OPEN POST_RDG_VALUES(p_counter_id,p_calculation_start_date);
         FETCH POST_RDG_VALUES
         INTO l_post_reading,l_post_value_timestamp;
         CLOSE POST_RDG_VALUES;
         --
         IF l_post_reading IS NOT NULL THEN
            l_calc_daily_avg := Est_daily_avg(l_prev_value_timestamp,l_prev_reading,l_post_value_timestamp,l_post_reading);
            l_calc_usage := (trunc(p_calculation_start_date) - trunc(l_prev_value_timestamp))*l_calc_daily_avg;
            l_calc_start_rdg := l_prev_reading + l_calc_usage;
         ELSE  --l_post_reading is null
            OPEN FIRST_RDG_VALUES(p_counter_id);
            FETCH FIRST_RDG_VALUES
            INTO l_first_reading,l_first_rdg_date;
            CLOSE FIRST_RDG_VALUES;
            --
            IF (trunc(l_first_rdg_date) = trunc(l_prev_value_timestamp)) THEN
               IF p_default_Value IS NULL THEN
                  csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_EST_DEF_VAL_NULL');
               END IF;
               --
               l_calc_start_rdg := (trunc(p_calculation_start_date) - trunc(l_first_rdg_date)) * p_default_Value;
               -- get the next reading after the period start date to check for erroneous readings
               -- For Descending counter
               OPEN CTR_DIRECTION(p_counter_id);
               FETCH CTR_DIRECTION
               INTO l_ctr_direction;
               CLOSE CTR_DIRECTION;
               --
               IF nvl(l_ctr_direction,'X') = 'D' THEN
                 l_calc_start_rdg := l_first_reading - l_calc_start_rdg;
               ELSIF nvl(l_ctr_direction,'X') = 'A' THEN
                 l_calc_start_rdg := l_first_reading + l_calc_start_rdg;
               END IF;
            ELSE
               l_calc_daily_avg := Est_daily_avg(l_first_rdg_date,l_first_reading,l_prev_value_timestamp,l_prev_reading);
               l_calc_usage := (trunc(p_calculation_start_date) - trunc(l_prev_value_timestamp))*l_calc_daily_avg;
               l_calc_start_rdg := l_prev_reading + l_calc_usage;
            END IF;
         END IF; --l_post_reading not null
      ELSE  --prev reading is null
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDG_PR_CAL_STDT');
      END IF; --l_prev_reading not null
      --
      x_calc_start_reading := round(l_calc_start_rdg);
      --
   ELSE --_calculation_start_rdg not null
      x_calc_start_reading := round(l_calculation_start_rdg);
   END IF; --l_calculation_start_rdg null
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
      ROLLBACK TO ESTIMATE_START_READINGS;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ESTIMATE_START_READINGS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
       p_count => x_msg_count,
       p_data => x_msg_data
           );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO ESTIMATE_START_READINGS;
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
END ESTIMATE_START_READINGS;
--
PROCEDURE EST_PERIOD_START_READINGS(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_default_value		 IN   NUMBER,
    p_avg_calculation_start_date  IN    DATE,
    p_calculation_start_date     IN   DATE,
    x_calc_start_reading         OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name              CONSTANT VARCHAR2(30)   := 'EST_PERIOD_START_READINGS';
   l_api_version           CONSTANT NUMBER         := 1.0;
   l_msg_data                       VARCHAR2(2000);
   l_msg_index                      NUMBER;
   l_msg_count                      NUMBER;
   --
   CURSOR PRIOR_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "prev_reading",b.value_timestamp "prev_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   b.value_timestamp < b_rdg_date
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp desc;

   l_prev_reading   NUMBER;
   l_prev_value_timestamp  DATE;

   CURSOR POST_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "post_reading",b.value_timestamp "post_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   b.value_timestamp > b_rdg_date
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp asc;

   l_post_reading    NUMBER;
   l_post_value_timestamp  DATE;

   CURSOR PASSED_DT_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "passed_dt_reading", b.value_timestamp "passed_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   and   trunc(b.value_timestamp) = trunc(b_rdg_date)
   order by b.value_timestamp desc;

   l_passed_dt_reading   NUMBER;
   l_passed_rdg_date     DATE;

   CURSOR first_rdg_values(b_counter_id NUMBER) IS
   select b.net_reading "first_reading",b.value_timestamp "first_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp asc;

   l_first_reading   NUMBER;
   l_first_rdg_date  DATE;

   CURSOR ctr_start_date(b_counter_id NUMBER) IS
   select nvl(start_date_active,creation_date) "ctr_start_date"
   from CSI_COUNTERS_B
   where counter_id = b_counter_id;

   CURSOR CTR_DIRECTION(b_counter_id NUMBER) IS
   select direction
   from CSI_COUNTERS_B
   where counter_id = b_counter_id;

   l_ctr_direction VARCHAR2(1);

   l_calculation_start_rdg NUMBER;
   l_calculation_start_dt  DATE;
   l_calc_daily_avg   NUMBER;
   l_calc_usage  NUMBER;
   l_calc_start_rdg  NUMBER;

   l_avg_calc_start_rdg NUMBER;
   l_debug_level       NUMBER;    -- 8214848 - dsingire
BEGIN
   SAVEPOINT EST_PERIOD_START_READINGS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line( 'Inside Est_Period_Start_Readings...');
   END IF;          -- 8214848 - dsingire
   --
   IF FND_API.to_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;
   --
   -- fetch the reading of the passed avg calculation start date
   OPEN PASSED_DT_RDG_VALUES(p_counter_id, p_calculation_start_date);
   FETCH PASSED_DT_RDG_VALUES
   INTO l_calculation_start_rdg,l_calculation_start_dt;
   CLOSE PASSED_DT_RDG_VALUES;
   -- if no actual reading on passed avg calc start dt then compute the reading.
   IF l_calculation_start_rdg is NULL THEN
      IF p_avg_calculation_start_date  IS NULL THEN
         OPEN PRIOR_RDG_VALUES(p_counter_id,p_calculation_start_date);
         FETCH PRIOR_RDG_VALUES INTO l_prev_reading,l_prev_value_timestamp;
         CLOSE PRIOR_RDG_VALUES;
         --
         IF l_prev_reading IS NOT NULL THEN
            OPEN POST_RDG_VALUES(p_counter_id,p_calculation_start_date);
            FETCH POST_RDG_VALUES INTO l_post_reading,l_post_value_timestamp;
            CLOSE POST_RDG_VALUES;
            --
            IF l_post_reading IS NOT NULL THEN
               l_calc_daily_avg := Est_daily_avg(l_prev_value_timestamp,l_prev_reading,l_post_value_timestamp,l_post_reading);
               l_calc_usage := (trunc(p_calculation_start_date) - trunc(l_prev_value_timestamp))*l_calc_daily_avg;
               l_calc_start_rdg := l_prev_reading + l_calc_usage;
            ELSE  --l_post_reading is null
               OPEN FIRST_RDG_VALUES(p_counter_id);
               FETCH FIRST_RDG_VALUES
               INTO l_first_reading,l_first_rdg_date;
               CLOSE FIRST_RDG_VALUES;
               --
               IF (trunc(l_first_rdg_date) = trunc(l_prev_value_timestamp)) THEN
                  IF p_default_Value IS NULL THEN
                     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_EST_DEF_VAL_NULL');
                  END IF;
                  l_calc_start_rdg := (trunc(p_calculation_start_date) - trunc(l_first_rdg_date)) * p_default_Value;
                  OPEN CTR_DIRECTION(p_counter_id);
                  FETCH CTR_DIRECTION
                  INTO l_ctr_direction;
                  CLOSE CTR_DIRECTION;
                  --
                  IF nvl(l_ctr_direction,'X') = 'D' THEN
                     l_calc_start_rdg := l_first_reading - l_calc_start_rdg;
                  ELSIF nvl(l_ctr_direction,'X') = 'A' THEN
                     l_calc_start_rdg := l_first_reading + l_calc_start_rdg;
                  END IF;
               ELSE
		  l_calc_daily_avg := Est_daily_avg(l_first_rdg_date,l_first_reading,l_prev_value_timestamp,l_prev_reading);
		  l_calc_usage := (trunc(p_calculation_start_date) - trunc(l_prev_value_timestamp))*l_calc_daily_avg;
		  l_calc_start_rdg := l_prev_reading + l_calc_usage;
               END IF;
            END IF; --l_post_reading not null
         ELSE  --prev reading is null
            csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDG_PR_PRD_STDT');
         END IF; --l_prev_reading not null
      ELSE --p avg calculation start date is not null
         -- get the avg calculation start reading.
         IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
            csi_ctr_gen_utility_pvt.put_line('Calling Estimate_Start_Readings...');
         END IF;          -- 8214848 - dsingire
         ESTIMATE_START_READINGS(
	     P_api_version                     => 1.0,
	     P_Init_Msg_List                   => P_Init_Msg_List,
	     P_Commit                          => P_Commit,
	     p_validation_level                => p_validation_level,
	     p_counter_id                      => p_counter_id,
	     p_default_value                   => p_default_value,
	     p_calculation_start_date          => p_avg_calculation_start_date,
	     x_calc_start_reading              => l_avg_calc_start_rdg,
	     X_Return_Status                   => X_Return_Status,
	     X_Msg_Count                       => X_Msg_Count,
	     X_Msg_Data                        => X_Msg_Data
           );
      	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    csi_ctr_gen_utility_pvt.put_line('ERROR FROM Estimate_Start_Readings API ');
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
	 OPEN PRIOR_RDG_VALUES(p_counter_id,p_calculation_start_date);
	 FETCH PRIOR_RDG_VALUES
         INTO l_prev_reading,l_prev_value_timestamp;
	 CLOSE PRIOR_RDG_VALUES;
         --
         IF l_prev_reading IS NOT NULL THEN
            OPEN POST_RDG_VALUES(p_counter_id,p_calculation_start_date);
            FETCH POST_RDG_VALUES
            INTO l_post_reading,l_post_value_timestamp;
            CLOSE POST_RDG_VALUES;
            --
            IF l_post_reading IS NOT NULL THEN
               l_calc_daily_avg := Est_daily_avg(l_prev_value_timestamp,l_prev_reading,l_post_value_timestamp,l_post_reading);
               l_calc_usage := (trunc(p_calculation_start_date) - trunc(l_prev_value_timestamp))*l_calc_daily_avg;
               l_calc_start_rdg := l_prev_reading + l_calc_usage;
            ELSE  --l_post_reading is null
               IF trunc(l_prev_value_timestamp) > trunc(p_avg_calculation_start_date) THEN
                  l_calc_daily_avg := Est_daily_avg(p_avg_calculation_start_date,l_avg_calc_start_rdg,l_prev_value_timestamp,l_prev_reading);
                  l_calc_usage := (trunc(p_calculation_start_date) - trunc(l_prev_value_timestamp)) * l_calc_daily_avg;
                  l_calc_start_rdg := l_prev_reading + l_calc_usage;
               ELSE
                  IF p_default_Value IS NULL THEN
                     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_EST_DEF_VAL_NULL');
                  END IF;
                  l_calc_start_rdg := (trunc(p_calculation_start_date) - trunc(p_avg_calculation_start_date)) * p_default_Value;
                  OPEN CTR_DIRECTION(p_counter_id);
                  FETCH CTR_DIRECTION INTO l_ctr_direction;
                  CLOSE CTR_DIRECTION;
                  --
                  IF nvl(l_ctr_direction,'X') = 'D' THEN
                     l_calc_start_rdg := l_avg_calc_start_rdg - l_calc_start_rdg;
                  ELSIF nvl(l_ctr_direction,'X') = 'A' THEN
                     l_calc_start_rdg := l_avg_calc_start_rdg + l_calc_start_rdg;
                  END IF;
               END IF;
            END IF; --l_post_reading not null
         ELSE  --prev reading is null
            csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDG_PR_PRD_STDT');
         END IF; --l_prev_reading not null
      END IF; -- p avg calculation start date is null
      --
      x_calc_start_reading := round(l_calc_start_rdg);
      --
   ELSE --l_calculation_start_rdg not null
      x_calc_start_reading := round(l_calculation_start_rdg);
   END IF; --l_calculation_start_rdg null
   --
   -- Standard call to get message count and IF count is  get message info.
   FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO EST_PERIOD_START_READINGS;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO EST_PERIOD_START_READINGS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
       p_count => x_msg_count,
       p_data => x_msg_data
           );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO EST_PERIOD_START_READINGS;
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
END EST_PERIOD_START_READINGS;
--
PROCEDURE ESTIMATE_USAGE(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_usage_markup		 IN   NUMBER,
    p_default_value		 IN   NUMBER,
    p_estimation_avg_type        IN   VARCHAR2,
    p_estimation_period_start_date IN DATE,
    p_estimation_period_end_date IN   DATE,
    p_avg_calculation_start_date  IN    DATE,
    p_number_of_readings         IN   NUMBER,
    x_estimated_usage_qty        OUT  NOCOPY NUMBER,
    x_estimated_meter_reading    OUT  NOCOPY NUMBER,
    x_estimated_period_start_rdg OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name              CONSTANT VARCHAR2(30)   := 'ESTIMATE_USAGE';
   l_api_version           CONSTANT NUMBER         := 1.0;
   l_msg_data                       VARCHAR2(2000);
   l_msg_index                      NUMBER;
   l_msg_count                      NUMBER;
   --
   CURSOR PRIOR_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "prev_reading",b.value_timestamp "prev_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   b.value_timestamp < b_rdg_date
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp desc;
   --
   l_prev_reading   NUMBER;
   l_prev_value_timestamp  DATE;
   --
   CURSOR POST_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "post_reading",b.value_timestamp "post_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   b.value_timestamp > b_rdg_date
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp asc;
   --
   l_post_reading    NUMBER;
   l_post_value_timestamp  DATE;

   CURSOR PASSED_DT_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "passed_dt_reading", b.value_timestamp "passed_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   and   trunc(b.value_timestamp) = trunc(b_rdg_date)
   order by b.value_timestamp desc;
   --
   l_passed_dt_reading   NUMBER;
   l_passed_rdg_date     DATE;

   CURSOR first_rdg_values(b_counter_id NUMBER) IS
   select b.net_reading "first_reading",b.value_timestamp "first_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp asc;
   --
   l_first_reading   NUMBER;
   l_first_rdg_date  DATE;

   CURSOR ctr_start_date(b_counter_id NUMBER) IS
   select nvl(start_date_active,creation_date) "ctr_start_date"
   from CSI_COUNTERS_B
   where counter_id = b_counter_id;
   --
   CURSOR CTR_DIRECTION(b_counter_id NUMBER) IS
   select direction
   from CSI_COUNTERS_B
   where counter_id = b_counter_id;
   --
   l_ctr_direction VARCHAR2(1);
   --
   l_avg_calc_start_reading  NUMBER;
   l_period_start_reading  NUMBER;

   l_daily_avg_for_est NUMBER;
   l_usage_for_est NUMBER;
   l_estimated_meter_rdg NUMBER;
   l_estimated_usage NUMBER;

   l_num_ctr_rdg number;
   l_num_value_timestamp DATE;

   lp_period_start_reading number;
   lprdst_num_ctr_rdg number;
   lprdst_num_value_timestamp date;
   l_debug_level       NUMBER;    -- 8214848 - dsingire
BEGIN
   SAVEPOINT ESTIMATE_USAGE;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
   csi_ctr_gen_utility_pvt.put_line( 'Inside Estimate_Usage...');
   END IF;          -- 8214848 - dsingire
   --
   IF p_avg_calculation_start_date IS NOT NULL THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Calling Estimate_Start_Readings...');
      END IF;          -- 8214848 - dsingire
      ESTIMATE_START_READINGS(
	  P_api_version                     => 1.0,
	  P_Init_Msg_List                   => P_Init_Msg_List,
	  P_Commit                          => P_Commit,
	  p_validation_level                => p_validation_level,
	  p_counter_id                      => p_counter_id,
	  p_default_value                   => p_default_value,
	  p_calculation_start_date          => p_avg_calculation_start_date,
	  x_calc_start_reading              => l_avg_calc_start_reading,
	  X_Return_Status                   => X_Return_Status,
 	  X_Msg_Count                       => X_Msg_Count,
	  X_Msg_Data                        => X_Msg_Data
        );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM Estimate_Start_Readings API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF p_estimation_period_start_date IS NOT NULL THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Calling Est_Period_Start_Readings...');
      END IF;          -- 8214848 - dsingire
      EST_PERIOD_START_READINGS(
	  P_api_version                     => 1.0,
	  P_Init_Msg_List                   => P_Init_Msg_List,
	  P_Commit                          => P_Commit,
	  p_validation_level                => p_validation_level,
	  p_counter_id                      => p_counter_id,
	  p_default_value                   => p_default_value,
	  p_avg_calculation_start_date      => p_avg_calculation_start_date,
	  p_calculation_start_date          => p_estimation_period_start_date,
	  x_calc_start_reading              => l_period_start_reading,
	  X_Return_Status                   => X_Return_Status,
	  X_Msg_Count                       => X_Msg_Count,
	  X_Msg_Data                        => X_Msg_Data
        );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM Est_Period_Start_Readings API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -- estimation usage calculation
   -- fetch the reading of the passed estimation period end date
   OPEN PASSED_DT_RDG_VALUES(p_counter_id, p_estimation_period_end_date);
   FETCH PASSED_DT_RDG_VALUES
   INTO l_estimated_meter_rdg,l_passed_rdg_date;
   CLOSE PASSED_DT_RDG_VALUES;
   -- if no actual reading on passed estimation period end dt then compute the reading.
   IF l_estimated_meter_rdg is NULL THEN
      IF p_avg_calculation_start_date IS NOT NULL THEN
         OPEN PRIOR_RDG_VALUES(p_counter_id, p_estimation_period_end_date);
         FETCH PRIOR_RDG_VALUES
         INTO l_prev_reading,l_prev_value_timestamp;
         CLOSE PRIOR_RDG_VALUES;
         --
	 IF l_prev_reading IS NOT NULL THEN
	    OPEN POST_RDG_VALUES(p_counter_id,p_estimation_period_end_date);
	    FETCH POST_RDG_VALUES
	    INTO l_post_reading,l_post_value_timestamp;
	    CLOSE POST_RDG_VALUES;
	    --
	    IF l_post_reading IS NOT NULL THEN
	       l_daily_avg_for_est := Est_daily_avg(l_prev_value_timestamp,l_prev_reading,l_post_value_timestamp,l_post_reading);
	       l_usage_for_est := (trunc(p_estimation_period_end_date) - trunc(l_prev_value_timestamp)) * l_daily_avg_for_est;
	       l_usage_for_est := l_usage_for_est + ((nvl(p_usage_markup,0)/100) * (l_usage_for_est));
	       l_estimated_meter_rdg := l_prev_reading + l_usage_for_est;
	       IF p_estimation_period_start_date IS NOT NULL THEN
		  l_estimated_usage := l_estimated_meter_rdg - l_period_start_reading;
	       END IF;
	    ELSE  --l_post_reading is null
	       IF trunc(l_prev_value_timestamp) > trunc(p_avg_calculation_start_date) THEN
		  l_daily_avg_for_est := Est_daily_avg(p_avg_calculation_start_date,l_avg_calc_start_reading,l_prev_value_timestamp,l_prev_reading);
		  l_usage_for_est := (trunc(p_estimation_period_end_date) - trunc(l_prev_value_timestamp)) * l_daily_avg_for_est;
		  l_usage_for_est := l_usage_for_est + ((nvl(p_usage_markup,0)/100) * (l_usage_for_est));
		  l_estimated_meter_rdg := l_prev_reading + l_usage_for_est;
		  IF p_estimation_period_start_date IS NOT NULL THEN
		     l_estimated_usage := l_estimated_meter_rdg - l_period_start_reading;
		  END IF;
	       ELSE
		  IF p_default_Value IS NULL THEN
                     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_EST_DEF_VAL_NULL');
		  END IF;
		  l_estimated_meter_rdg := (trunc(p_estimation_period_end_date) - trunc(p_avg_calculation_start_date)) * p_default_Value;
		  l_estimated_meter_rdg := l_estimated_meter_rdg + ((nvl(p_usage_markup,0)/100) * (l_estimated_meter_rdg));
		  -- get the next reading after the period start date to check for erroneous readings
		  OPEN CTR_DIRECTION(p_counter_id);
		  FETCH CTR_DIRECTION
		  INTO l_ctr_direction;
		  CLOSE CTR_DIRECTION;
		  --
		  IF nvl(l_ctr_direction,'X') = 'D' THEN
		     l_estimated_meter_rdg := l_avg_calc_start_reading - l_estimated_meter_rdg;
		  ELSIF nvl(l_ctr_direction,'X') = 'A' THEN
		     l_estimated_meter_rdg := l_avg_calc_start_reading + l_estimated_meter_rdg;
		  END IF;
		  --
		  IF p_estimation_period_start_date IS NOT NULL THEN
		     l_estimated_usage := l_estimated_meter_rdg - l_period_start_reading;
		  END IF;
	       END IF; --l_prev_value_timestamp>p_avg_calculation_start_date
	    END IF; --l_post_reading not null
	 ELSE --l_prev_reading is null
            csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDG_PR_PRD_ENDT');
	 END IF; --l_prev_reading not null
      ELSIF P_number_of_readings is not null then -- p_number of rdgs not null
	 Declare
	    n number;
	    j number := 0;
	    l_min_seqno number;
	    CURSOR CTR_RDGS(d1_counter_id number, b_prd_rdg_date DATE) IS
	    select cval.net_reading AS NET_RDG, cval.value_timestamp
	    from CSI_COUNTER_READINGS cval
	    where cval.counter_id = d1_counter_id
	    and   cval.value_timestamp <   b_prd_rdg_date
            and   nvl(cval.disabled_flag,'N') = 'N'
	    order by cval.value_timestamp desc;
	    --for prd start reading
	    n1 number;
	    j1 number := 0;
	 Begin
	    -- estimation start meter reading.
	    IF p_estimation_period_start_date IS NOT NULL THEN
	       FOR prd_st_ctr_rdgs_rec in CTR_RDGS(p_counter_id,p_estimation_period_start_date) LOOP
		  j1 := j1+1;
		  lprdst_num_ctr_rdg := nvl(prd_st_ctr_rdgs_rec.net_rdg,0);
		  lprdst_num_value_timestamp := prd_st_ctr_rdgs_rec.value_timestamp;
		  IF j1 = p_number_of_readings then
		     exit;
		  END IF;
	       END LOOP;
	       --
	       IF J1 < 2 THEN
		  lprdst_num_ctr_rdg := null;
                  csi_ctr_gen_utility_pvt.ExitWithErrMsg
                      ( p_msg_name     =>  'CSI_API_CTR_INVD_NUM_OF_RDGS',
                        p_token1_name  =>  'P_NUMBER_OF_READINGS',
                        p_token1_val   =>  to_char(p_number_of_readings)
                      );
	       ELSE
		  OPEN PRIOR_RDG_VALUES(p_counter_id, p_estimation_period_start_date);
		  FETCH PRIOR_RDG_VALUES
		  INTO l_prev_reading,l_prev_value_timestamp;
		  CLOSE PRIOR_RDG_VALUES;
		  --
		  IF l_prev_reading IS NOT NULL THEN
		     l_daily_avg_for_est := Est_daily_avg(lprdst_num_value_timestamp,lprdst_num_ctr_rdg,l_prev_value_timestamp,l_prev_reading);
		     l_usage_for_est := (trunc(p_estimation_period_start_date) - trunc(l_prev_value_timestamp)) * l_daily_avg_for_est;
		     lp_period_start_reading := l_prev_reading + l_usage_for_est;
		     l_period_start_reading := round(lp_period_start_reading);
		  ELSE
		     csi_ctr_gen_utility_pvt.ExitWithErrMsg
			 ( p_msg_name     =>  'CSI_API_CTR_INVD_NUM_OF_RDGS',
			   p_token1_name  =>  'P_NUMBER_OF_READINGS',
			   p_token1_val   =>  to_char(p_number_of_readings)
			 );
		  END IF;
	       END IF;
	    END IF;
	    --
	    l_prev_reading :=  null;
	    l_prev_value_timestamp := null;
	    l_daily_avg_for_est :=  null;
	    l_usage_for_est := null;
	    --estimation end meter reading.
	    FOR ctr_rdgs_rec in CTR_RDGS(p_counter_id, p_estimation_period_end_date) LOOP
	      j:=j+1;
	      l_num_ctr_rdg := nvl(ctr_rdgs_rec.net_rdg,0);
	      l_num_value_timestamp := ctr_rdgs_rec.value_timestamp;
	      IF j = p_number_of_readings then
		 exit;
	      END IF;
	    END LOOP;
	    --
	    IF J < 2 THEN   --J <> p_number_of_readings then
	       l_num_ctr_rdg := null;
	       csi_ctr_gen_utility_pvt.ExitWithErrMsg
		   ( p_msg_name     =>  'CSI_API_CTR_INVD_NUM_OF_RDGS',
		     p_token1_name  =>  'P_NUMBER_OF_READINGS',
		     p_token1_val   =>  to_char(p_number_of_readings)
		   );
	    END IF;
	 End;
	 --
	 OPEN PRIOR_RDG_VALUES(p_counter_id, p_estimation_period_end_date);
	 FETCH PRIOR_RDG_VALUES INTO l_prev_reading,l_prev_value_timestamp;
	 CLOSE PRIOR_RDG_VALUES;
	 IF l_prev_reading IS NOT NULL THEN
	     l_daily_avg_for_est := Est_daily_avg(l_num_value_timestamp,l_num_ctr_rdg,l_prev_value_timestamp,l_prev_reading);
	     l_usage_for_est := (trunc(p_estimation_period_end_date) - trunc(l_prev_value_timestamp)) * l_daily_avg_for_est;
	     l_usage_for_est := l_usage_for_est + ((nvl(p_usage_markup,0)/100) * (l_usage_for_est));
	     l_estimated_meter_rdg := l_prev_reading + l_usage_for_est;
	     IF p_estimation_period_start_date IS NOT NULL THEN
		l_estimated_usage := l_estimated_meter_rdg - lp_period_start_reading;
	     END IF;
	 ELSE
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
		( p_msg_name     =>  'CSI_API_CTR_INVD_NUM_OF_RDGS',
		  p_token1_name  =>  'P_NUMBER_OF_READINGS',
		  p_token1_val   =>  to_char(p_number_of_readings)
		);
	 END IF;
      ELSIF p_avg_calculation_start_date IS NULL and P_number_of_readings IS NULL THEN
	 OPEN PRIOR_RDG_VALUES(p_counter_id, p_estimation_period_end_date);
	 FETCH PRIOR_RDG_VALUES
	 INTO l_prev_reading,l_prev_value_timestamp;
	 CLOSE PRIOR_RDG_VALUES;
	 --
	 IF l_prev_reading IS NOT NULL THEN
	    OPEN POST_RDG_VALUES(p_counter_id,p_estimation_period_end_date);
	    FETCH POST_RDG_VALUES
	    INTO l_post_reading,l_post_value_timestamp;
	    CLOSE POST_RDG_VALUES;
	    --
	    IF l_post_reading IS NOT NULL THEN
	       l_daily_avg_for_est := Est_daily_avg(l_prev_value_timestamp,l_prev_reading,l_post_value_timestamp,l_post_reading);
	       l_usage_for_est := (trunc(p_estimation_period_end_date) - trunc(l_prev_value_timestamp)) * l_daily_avg_for_est;
	       l_usage_for_est := l_usage_for_est + ((nvl(p_usage_markup,0)/100) * (l_usage_for_est));
	       l_estimated_meter_rdg := l_prev_reading + l_usage_for_est;
	       IF p_estimation_period_start_date IS NOT NULL THEN
		  l_estimated_usage := l_estimated_meter_rdg - l_period_start_reading;
	       END IF;
	    ELSE  --l_post_reading is null
	       OPEN FIRST_RDG_VALUES(p_counter_id);
	       FETCH FIRST_RDG_VALUES
	       INTO l_first_reading,l_first_rdg_date;
	       CLOSE FIRST_RDG_VALUES;
	       --
	       IF trunc(l_prev_value_timestamp) = trunc(l_first_rdg_date) THEN
		  IF p_default_Value IS NULL THEN
                     csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_EST_DEF_VAL_NULL');
		  END IF;
		  l_estimated_meter_rdg := (trunc(p_estimation_period_end_date) - trunc(l_first_rdg_date)) * p_default_Value;
		  l_estimated_meter_rdg := l_estimated_meter_rdg + ((nvl(p_usage_markup,0)/100) * (l_estimated_meter_rdg));
		  OPEN CTR_DIRECTION(p_counter_id);
		  FETCH CTR_DIRECTION
		  INTO l_ctr_direction;
		  CLOSE CTR_DIRECTION;
		  --
		  IF nvl(l_ctr_direction,'X') = 'D' THEN
		    l_estimated_meter_rdg := l_first_reading - l_estimated_meter_rdg;
		  ELSIF nvl(l_ctr_direction,'X') = 'A' THEN
		    l_estimated_meter_rdg := l_first_reading + l_estimated_meter_rdg;
		  END IF;
		  IF p_estimation_period_start_date IS NOT NULL THEN
		     l_estimated_usage := l_estimated_meter_rdg - l_period_start_reading;
		  END IF;
	       ELSE
		  l_daily_avg_for_est := Est_daily_avg(l_first_rdg_date,l_first_reading,l_prev_value_timestamp,l_prev_reading);
		  l_usage_for_est := (trunc(p_estimation_period_end_date) - trunc(l_prev_value_timestamp)) * l_daily_avg_for_est;
		  l_usage_for_est := l_usage_for_est + ((nvl(p_usage_markup,0)/100) * (l_usage_for_est));
		  l_estimated_meter_rdg := l_prev_reading + l_usage_for_est;
		  IF p_estimation_period_start_date IS NOT NULL THEN
		     l_estimated_usage := l_estimated_meter_rdg - l_period_start_reading;
		  END IF;
	       END IF;
	    END IF; --l_post_reading not null
         ELSE --l_prev_reading is null
	  --error out - not enough readings to calculate the estimation
            csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDG_PR_PRD_ENDT');
         END IF;
      END IF; --p_avg_calculation_start_date not null
   ELSE  --l_estimated_meter_rdg is  NOT NULL
      IF p_estimation_period_start_date IS NOT NULL THEN
         l_estimated_usage := l_estimated_meter_rdg - l_period_start_reading;
      END IF;
   END IF; -- l_estimated_meter_rdg is NULL
   --
   x_estimated_meter_reading := round(l_estimated_meter_rdg);
   x_estimated_usage_qty     := abs(round(l_estimated_usage));
   x_estimated_period_start_rdg := l_period_start_reading;
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
      ROLLBACK TO ESTIMATE_USAGE;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ESTIMATE_USAGE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
       p_count => x_msg_count,
       p_data => x_msg_data
           );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO ESTIMATE_USAGE;
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
END ESTIMATE_USAGE;
--
PROCEDURE ESTIMATE_COUNTER_READING(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_estimation_period_start_date IN DATE,
    p_estimation_period_end_date IN   DATE,
    p_avg_calculation_start_date  IN    DATE,
    p_number_of_readings         IN   NUMBER,
    x_estimated_usage_qty        OUT  NOCOPY NUMBER,
    x_estimated_meter_reading    OUT  NOCOPY NUMBER,
    x_estimated_period_start_rdg OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name              CONSTANT VARCHAR2(30)   := 'ESTIMATE_COUNTER_READING';
   l_api_version           CONSTANT NUMBER         := 1.0;
   l_msg_data                       VARCHAR2(2000);
   l_msg_index                      NUMBER;
   l_msg_count                      NUMBER;
   l_estimated_rdg_id               NUMBER;
   l_process_flag                   BOOLEAN := TRUE;
   --
   CURSOR CTREST_REC IS
   select group_id counter_group_id,estimation_id
   from CSI_COUNTERS_B
   where counter_id = p_counter_id;
   --
   l_counter_group_id NUMBER;
   l_estimation_id   NUMBER;
   --
   CURSOR EST_REC(b_estimation_id NUMBER) IS
   select name, estimation_type, fixed_value, usage_markup,
   default_value, estimation_avg_type
   from CSI_CTR_ESTIMATE_METHODS_VL
   where estimation_id = b_estimation_id;
   --
   l_est_rec est_rec%rowtype;
   --
   CURSOR REF_COUNTER(b_counter_group_id NUMBER,b_counter_id NUMBER) IS
   select counter_id
   from CSI_COUNTERS_B -- Need to change
   where group_id = b_counter_group_id
   and created_from_counter_tmpl_id =b_counter_id;
   --
   l_ref_counter_id NUMBER;
   --
   l_dummy VARCHAR2(1);
   l_estimation_period_start_date DATE;
   --
   -- cursor to fetch the captured reading of the period end date if exists.
   CURSOR EST_DT_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "passed_dt_reading", b.value_timestamp "passed_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   and   trunc(b.value_timestamp) = trunc(b_rdg_date)
   order by b.value_timestamp desc;
   --
   l_est_dt_reading   NUMBER;
   l_est_rdg_date     DATE;

   -- cursor to check whether any counter readings exist
   CURSOR CTR_RDGS_EXIST(b_counter_id NUMBER) IS
   select counter_value_id
   FROM CSI_COUNTER_READINGS
   WHERE counter_id = b_counter_id
   and   nvl(disabled_flag,'N') = 'N';
   --
   l_ctr_val_id NUMBER;
   l_debug_level       NUMBER;    -- 8214848 - dsingire
   l_user_id 				  NUMBER := fnd_global.user_id;        -- 8214848 - dsingire
   l_conc_login_id		NUMBER := fnd_global.conc_login_id;  -- 8214848 - dsingire
   l_date_format       VARCHAR2(50) := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-YYYY HH24:MI:SS');
BEGIN
   SAVEPOINT ESTIMATE_COUNTER_READING;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

  IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line( 'Inside Estimate_Counter_Reading...');
  END IF;          -- 8214848 - dsingire
   --
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   IF p_counter_id IS NULL or p_estimation_period_end_date IS NULL THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
           ( p_msg_name    =>  'CSI_API_CTR_CTRID_PRD_ENDDT',
             p_token1_name =>  'P_COUNTER_ID',
             p_token1_val  =>  to_char(p_counter_id),
             p_token2_name =>  'P_ESTIMATION_PERIOD_END_DATE',
             p_token2_val  =>  to_char(p_estimation_period_end_date,l_date_format)
           );
   END IF;
   IF p_avg_calculation_start_date IS NOT NULL and p_number_of_readings IS NOT NULL THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg
           ( p_msg_name    =>  'CSI_API_CTR_CAL_STDT_NUM_RDGS',
             p_token1_name =>  'P_AVG_CALCULATION_START_DATE',
             p_token1_val  =>  to_char(p_avg_calculation_start_date,l_date_format),
             p_token2_name =>  'P_NUMBER_OF_READINGS',
             p_token2_val  =>  to_char(p_number_of_readings)
           );
   END IF;

   IF NOT trunc(p_estimation_period_start_date) <= trunc(p_estimation_period_end_date) THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INV_PRD_ST_END_DT');
   END IF;

   IF NOT trunc(p_avg_calculation_start_date) < trunc(p_estimation_period_start_date) THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_CAL_STDT_PRD_STDT');
   END IF;

   IF NOT trunc(p_avg_calculation_start_date) < trunc(p_estimation_period_end_date) THEN
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_CAL_STDT_PRD_ENDDT');
   END IF;
   --
   BEGIN
      select 'X' into l_dummy
      from CSI_COUNTERS_B
      where counter_id = p_Counter_id;
   EXCEPTION
       when no_data_found then
	  csi_ctr_gen_utility_pvt.ExitWithErrMsg
	     ( p_msg_name    =>  'CSI_API_CTR_INVALID',
	       p_token1_name =>  'MODE',
	       p_token1_val  =>  'Counter'
	     );
   END;
   --
   OPEN CTREST_REC;
   FETCH CTREST_REC
   INTO l_counter_group_id,l_estimation_id;
   CLOSE CTREST_REC;
   --
   OPEN EST_REC(l_estimation_id);
   FETCH EST_REC INTO l_est_rec;
   CLOSE EST_REC;
   --
   IF p_estimation_period_start_date IS NOT NULL THEN
     l_estimation_period_start_date := p_estimation_period_start_date -1;
   END IF;

   IF l_est_rec.estimation_type in ('FIXED','USAGE') THEN
      -- if no counter reading exists then exit the estimation routine
      OPEN CTR_RDGS_EXIST(p_counter_id);
      FETCH CTR_RDGS_EXIST into l_ctr_val_id;
      CLOSE CTR_RDGS_EXIST;
      IF l_ctr_val_id IS NULL THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDGS_EXIST');
      END IF;
   END IF;

   IF l_est_rec.estimation_type = 'FIXED' THEN
      /********************
       Compute Fixed Value Estimation
      ********************/
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Calling Estimate_fixed_values...');
      END IF;          -- 8214848 - dsingire
      --
      Estimate_fixed_values(
	  P_api_version 		 => 1.0,
	  P_Init_Msg_List 		 => P_Init_Msg_List,
	  P_Commit 			 => P_Commit,
	  p_validation_level 		 => p_validation_level,
	  p_counter_id  		 => p_counter_id,
	  p_fixed_value 		 => l_est_rec.fixed_value,
	  p_default_value 		 => l_est_rec.default_value,
	  p_estimation_period_start_date => l_estimation_period_start_date,
	  p_estimation_period_end_date   => p_estimation_period_end_date,
	  x_estimated_meter_reading    	 => x_estimated_meter_reading,
	  x_estimated_usage_qty          => x_estimated_usage_qty,
	  x_estimated_period_start_rdg   => x_estimated_period_start_rdg,
	  X_Return_Status 		 => X_Return_Status,
	  X_Msg_Count 		 	 => X_Msg_Count,
	  X_Msg_Data 		 	 => X_Msg_Data
        );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM Estimate_fixed_values API ');
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

   ELSIF l_est_rec.estimation_type = 'USAGE' THEN
       /********************
	Compute Usage of direct counter Estimation
	*******************/
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Calling Estimate_Usage...');
      END IF;          -- 8214848 - dsingire
      Estimate_Usage(
	   P_api_version                     => 1.0,
	   P_Init_Msg_List                   => P_Init_Msg_List,
	   P_Commit                          => P_Commit,
	   p_validation_level                => p_validation_level,
	   p_counter_id                      => p_counter_id,
	   p_usage_markup		     => l_est_rec.usage_markup,
	   p_default_value                   => l_est_rec.default_value,
	   p_estimation_avg_type             => l_est_rec.estimation_avg_type,
	   p_estimation_period_start_date    => l_estimation_period_start_date,
	   p_estimation_period_end_date      => p_estimation_period_end_date,
	   p_avg_calculation_start_date      => p_avg_calculation_start_date,
	   p_number_of_readings              => p_number_of_readings,
	   x_estimated_usage_qty             => x_estimated_usage_qty,
	   x_estimated_meter_reading         => x_estimated_meter_reading,
	   x_estimated_period_start_rdg      => x_estimated_period_start_rdg,
	   X_Return_Status                   => X_Return_Status,
	   X_Msg_Count                       => X_Msg_Count,
	   X_Msg_Data                        => X_Msg_Data
       );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 csi_ctr_gen_utility_pvt.put_line('ERROR FROM Estimate_Usage API ');
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
   ELSIF l_est_rec.estimation_type = 'REFCTR' THEN
      /********************
       Compute Usage of indirect counter Estimation
       *******************/

      OPEN REF_COUNTER(l_counter_group_id,p_counter_id);
      FETCH REF_COUNTER INTO l_ref_counter_id;
      CLOSE REF_COUNTER;
      -- if no counter readings exist for the counter then exit.
      OPEN CTR_RDGS_EXIST(l_ref_counter_id);
      FETCH CTR_RDGS_EXIST into l_ctr_val_id;
      close CTR_RDGS_EXIST;
      --
      IF l_ctr_val_id IS NULL THEN
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDGS_EXIST');
      END IF;

      Estimate_Usage(
	   P_api_version                     => 1.0,
	   P_Init_Msg_List                   => P_Init_Msg_List,
	   P_Commit                          => P_Commit,
	   p_validation_level                => p_validation_level,
	   p_counter_id                      => l_ref_counter_id,
	   p_usage_markup                    => l_est_rec.usage_markup,
	   p_default_value                   => l_est_rec.default_value,
	   p_estimation_avg_type             => l_est_rec.estimation_avg_type,
	   p_estimation_period_start_date    => l_estimation_period_start_date,
	   p_estimation_period_end_date      => p_estimation_period_end_date,
	   p_avg_calculation_start_date      => p_avg_calculation_start_date,
	   p_number_of_readings              => p_number_of_readings,
	   x_estimated_usage_qty             => x_estimated_usage_qty,
	   x_estimated_meter_reading         => x_estimated_meter_reading,
	   x_estimated_period_start_rdg      => x_estimated_period_start_rdg,
	   X_Return_Status                   => X_Return_Status,
	   X_Msg_Count                       => X_Msg_Count,
	   X_Msg_Data                        => X_Msg_Data
         );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 csi_ctr_gen_utility_pvt.put_line('ERROR FROM Estimate_Usage API ');
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
   -- Generate the Value_id for insert
   l_process_flag := TRUE;
   WHILE l_process_flag LOOP
      select CSI_CTR_ESTIMATED_READINGS_S.nextval
      into l_estimated_rdg_id from dual;
      IF NOT Estimated_Rdg_ID_Exists(l_estimated_rdg_id) THEN
	 l_process_flag := FALSE;
      END IF;
   END LOOP;
   --
   CSI_CTR_ESTIMATED_READINGS_PKG.Insert_Row
	(
	  px_ESTIMATED_READING_ID      =>  l_estimated_rdg_id
	 ,p_COUNTER_ID                 =>  p_counter_id
	 ,p_ESTIMATION_ID              =>  l_estimation_id
	 ,p_VALUE_TIMESTAMP            =>  SYSDATE
	 ,p_ESTIMATED_METER_READING    =>  x_estimated_meter_reading
	 ,p_NUM_OF_READINGS            =>  p_number_of_readings
	 ,p_PERIOD_START_DATE          =>  p_estimation_period_start_date
	 ,p_PERIOD_END_DATE            =>  p_estimation_period_end_date
	 ,p_AVG_CALCULATION_START_DATE =>  p_avg_calculation_start_date
	 ,p_ESTIMATED_USAGE            =>  x_estimated_usage_qty
	 ,p_ATTRIBUTE1                 =>  NULL
	 ,p_ATTRIBUTE2                 =>  NULL
	 ,p_ATTRIBUTE3                 =>  NULL
	 ,p_ATTRIBUTE4                 =>  NULL
	 ,p_ATTRIBUTE5                 =>  NULL
	 ,p_ATTRIBUTE6                 =>  NULL
	 ,p_ATTRIBUTE7                 =>  NULL
	 ,p_ATTRIBUTE8                 =>  NULL
	 ,p_ATTRIBUTE9                 =>  NULL
	 ,p_ATTRIBUTE10                =>  NULL
	 ,p_ATTRIBUTE11                =>  NULL
	 ,p_ATTRIBUTE12                =>  NULL
	 ,p_ATTRIBUTE13                =>  NULL
	 ,p_ATTRIBUTE14                =>  NULL
	 ,p_ATTRIBUTE15                =>  NULL
	 ,p_ATTRIBUTE_CATEGORY         =>  NULL
	 ,p_LAST_UPDATE_DATE           =>  SYSDATE
	 ,p_LAST_UPDATED_BY            =>  l_user_id
	 ,p_LAST_UPDATE_LOGIN          =>  l_conc_login_id
	 ,p_CREATION_DATE              =>  SYSDATE
	 ,p_CREATED_BY                 =>  l_user_id
	 ,p_OBJECT_VERSION_NUMBER      =>  1
	 ,p_MIGRATED_FLAG              =>  'N'
   );
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
      ROLLBACK TO ESTIMATE_COUNTER_READING;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ESTIMATE_COUNTER_READING;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
       p_count => x_msg_count,
       p_data => x_msg_data
           );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO ESTIMATE_COUNTER_READING;
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
END ESTIMATE_COUNTER_READING;
--
PROCEDURE ESTIMATE_FIXED_VALUES(
    P_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_fixed_value                IN   NUMBER,
    p_default_value              IN   NUMBER,
    p_estimation_period_start_date   IN   DATE,
    p_estimation_period_end_date     IN   DATE,
    x_estimated_meter_reading    OUT  NOCOPY NUMBER,
    x_estimated_usage_qty        OUT  NOCOPY NUMBER,
    x_estimated_period_start_rdg OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
  )
IS
   l_api_name              CONSTANT VARCHAR2(30)   := 'ESTIMATE_FIXED_VALUES';
   l_api_version           CONSTANT NUMBER         := 1.0;
   l_msg_data                       VARCHAR2(2000);
   l_msg_index                      NUMBER;
   l_msg_count                      NUMBER;
   --
   CURSOR PRIOR_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "prev_reading",b.value_timestamp "prev_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   b.value_timestamp < b_rdg_date
   and   nvl(b.disabled_flag,'N') = 'N'
   order by b.value_timestamp desc;
   --
   CURSOR PASSED_DT_RDG_VALUES(b_counter_id NUMBER, b_rdg_date DATE) IS
   select b.net_reading "passed_dt_reading", b.value_timestamp "passed_rdg_date"
   from CSI_COUNTER_READINGS b
   where b.counter_id = b_counter_id
   and   nvl(b.disabled_flag,'N') = 'N'
   and   trunc(b.value_timestamp) = trunc(b_rdg_date)
   order by b.value_timestamp desc;
   --
   l_passed_dt_reading                 NUMBER;
   l_passed_rdg_date                   DATE;
   l_adjustment_usage_amount           NUMBER;
   l_estimated_meter_reading           NUMBER;
   l_creation_date                     DATE;
   l_period_days                       NUMBER;
   l_default_value                     NUMBER;
   l_captured_date                     DATE;
   l_period_start_date_reading         NUMBER;
   l_prev_reading                      NUMBER;
   l_prev_value_timestamp              DATE;
   l_fixed_value                       NUMBER;
   l_period_start_reading              NUMBER;
   l_estimated_usage                   NUMBER;
   l_debug_level       NUMBER;    -- 8214848 - dsingire
BEGIN
   SAVEPOINT ESTIMATE_FIXED_VALUES;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
    csi_ctr_gen_utility_pvt.put_line( 'Inside Estimate_Fixed_Values...');
   END IF;          -- 8214848 - dsingire
   --

   -- Read the debug profiles values in to global variable 7197402
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level is null) THEN  -- 8214848 - dsingire
	    CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;
	  END IF;                      -- 8214848 - dsingire

    l_debug_level :=  CSI_CTR_GEN_UTILITY_PVT.g_debug_level; -- 8214848 - dsingire

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   IF p_estimation_period_start_date IS NOT NULL THEN
      IF (l_debug_level > 0) THEN                           -- 8214848 - dsingire
        csi_ctr_gen_utility_pvt.put_line('Calling Est_Period_Start_Readings...');
      END IF;          -- 8214848 - dsingire
      EST_PERIOD_START_READINGS(
	   P_api_version                     => 1.0,
	   P_Init_Msg_List                   => P_Init_Msg_List,
	   P_Commit                          => P_Commit,
	   p_validation_level                => p_validation_level,
	   p_counter_id                      => p_counter_id,
	   p_default_value                   => p_default_value,
	   p_avg_calculation_start_date      => null,
	   p_calculation_start_date          => p_estimation_period_start_date,
	   x_calc_start_reading              => l_period_start_reading,
	   X_Return_Status                   => X_Return_Status,
	   X_Msg_Count                       => X_Msg_Count,
	   X_Msg_Data                        => X_Msg_Data
         );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 csi_ctr_gen_utility_pvt.put_line('ERROR FROM Est_Period_Start_Readings API ');
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
   -- fetch the reading of the passed estimation period end date
   OPEN PASSED_DT_RDG_VALUES(p_counter_id, p_estimation_period_end_date);
   FETCH PASSED_DT_RDG_VALUES
   INTO l_estimated_meter_reading,l_passed_rdg_date;
   CLOSE PASSED_DT_RDG_VALUES;
   -- if no actual reading on passed estimation period end dt then compute the reading.
   IF l_estimated_meter_reading is NULL THEN
      open prior_rdg_values(p_counter_id, p_estimation_period_end_date);
      fetch prior_rdg_values into l_prev_reading,l_prev_value_timestamp;
      close prior_rdg_values;
      --
      IF l_prev_reading IS NULL THEN
	 -- raise error message - no readings to calculate
         csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_NO_RDG_PR_PRD_ENDT');
      ELSE  --  l_prev_reading IS not null
	 l_period_days := trunc(p_estimation_period_end_date) - trunc(l_prev_value_timestamp) ;
	 l_estimated_meter_reading:=(l_prev_reading +(P_fixed_value*l_period_days)) ;
      END IF;
   END IF;
   --
   x_estimated_meter_reading := l_estimated_meter_reading;
   IF p_estimation_period_start_date IS NOT NULL THEN
      l_estimated_usage := l_estimated_meter_reading - l_period_start_reading;
   END If;
   --
   X_estimated_usage_qty := l_estimated_usage;
   x_estimated_period_start_rdg := l_period_start_reading;
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
      ROLLBACK TO ESTIMATE_FIXED_VALUES;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ESTIMATE_FIXED_VALUES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
       p_count => x_msg_count,
       p_data => x_msg_data
           );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO ESTIMATE_FIXED_VALUES;
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
END ESTIMATE_FIXED_VALUES;
--
END CSI_COUNTER_READINGS_PVT;

/
