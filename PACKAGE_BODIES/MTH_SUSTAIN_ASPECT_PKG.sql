--------------------------------------------------------
--  DDL for Package Body MTH_SUSTAIN_ASPECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_SUSTAIN_ASPECT_PKG" AS
/*$Header: mthesatb.pls 120.1.12010000.22 2010/04/21 22:13:25 yfeng noship $ */

p_reading MeterReadingTable;
p_shift EntityShiftTable;


/* ****************************************************************************
* Function     		:IS_RAW_DATA_ROW_VALID                                *
* Description 	 	:Check if the raw from MTH_TAG_METER_READINGS_RAW is  *
*                  valid or not. If it violates any validation rules,         *
*                  return -1; otherwise, return 1                             *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code - Tag code                                *
*                        p_reading_time - Reading time                        *
*                        p_tag_value -  tag value                             *
*                        p_is_number -  1 if tag value is number; 0 otherwise *
*                        p_is_cumulative -  1 to apply incremental logic;     *
*                                           0 otherwise                       *
*                        p_is_assending -  1 if tag is assending order;       *
*                                           0 otherwise                       *
*                        p_initial_value -  Tag initial value                 *
*                        p_max_reset_value -                                  *
*                        p_num_meters -  Number of meters associated with tag *
*                        p_prev_reading_time -  reading time for the previous *
*                                               tag reading                   *
* Return Value          : Found violations of the following rules:            *
*                         'NGV'  -	Usage value is negative.              *
*                         'OTR'  -	Usage value is out of range defined   *
*                                   for a cumulative tag.                     *
*                         'OTO'  - 	The raw reading data is out of order. *
*                         'DUP'  -	The raw reading data is duplicated.   *
*                         'MIM'  -  There is no meter associated with the tag *
*                         'IDS'  -  The data source is not for SUSTAINABILITY *
*                         'WFQ'  -  	Wrong frequency number                *
*                        NULL  - Valid row                                    *
**************************************************************************** */

FUNCTION IS_RAW_DATA_ROW_VALID
         (p_tag_code IN VARCHAR2,
          p_reading_time IN DATE,
          p_tag_value IN NUMBER,
          p_is_number IN NUMBER,
          p_is_cumulative IN NUMBER,
          p_is_assending IN NUMBER,
          p_initial_value IN NUMBER,
          p_max_reset_value IN NUMBER,
          p_tag_type IN varchar2,
          p_frequency IN NUMBER,
          p_num_meters IN NUMBER,
          p_prev_reading_time IN DATE) RETURN VARCHAR2
IS
  v_is_valid NUMBER;
  v_err_code VARCHAR2(255) := '';
BEGIN
  IF (p_tag_type IS NULL or p_tag_type <> 'SUSTAINABILITY') THEN
    v_err_code :=  v_err_code || 'IDS ';
  END IF;
  IF (p_tag_value < 0) THEN
    v_err_code :=  v_err_code || 'NGV ';
  END IF;
  IF (p_is_cumulative = 0 AND
      p_frequency <= 0) THEN
    v_err_code :=  v_err_code || 'WFQ ';
  END IF;
  IF (p_is_number = 1 AND p_is_cumulative = 1 AND
      p_tag_value > p_max_reset_value) THEN
    v_err_code :=  v_err_code || 'OTR ';
  END IF;
  IF (p_prev_reading_time IS NOT NULL AND
      p_reading_time < p_prev_reading_time) THEN
    v_err_code :=  v_err_code || 'OTO ';
  END IF;
  IF (p_prev_reading_time IS NOT NULL AND
      p_reading_time = p_prev_reading_time) THEN
    v_err_code :=  v_err_code || 'DUP ';
  END IF;
  IF (p_num_meters = 0) THEN
    v_err_code :=  v_err_code || 'MIM ';
  END IF;
  IF (Length(v_err_code) = 0) THEN
    v_err_code := NULL;
  END IF;
  RETURN v_err_code;
END IS_RAW_DATA_ROW_VALID;




/* ****************************************************************************
* Procedure    		:insert_row_to_err_tab                                *
* Description 	 	:Insert the error row into the error with error code  *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code - Tag code                                *
*                        p_reading_time - Reading time                        *
*                        p_tag_value -  tag value                             *
*                        p_err_code -  Error codes                            *
* Return Value          :None                                                 *
**************************************************************************** */
PROCEDURE insert_row_to_err_tab(P_TAG_CODE IN VARCHAR2,
                                P_READING_TIME IN DATE,
                                P_TAG_VALUE IN NUMBER,
                                P_ERROR_CODE IN VARCHAR2)
IS
  v_reprocess_ready_yn VARCHAR2(1) := 'N';
  v_meter_reading_err_pk_key NUMBER;
BEGIN
  INSERT INTO MTH_METER_READINGS_ERR
      (METER_READINGS_ERR_PK_KEY, TO_TIME, USAGE_VALUE, TAG_CODE,
       REPROCESS_READY_YN, ERR_CODE)
    VALUES (MTH_METER_READINGS_ERR_S.NEXTVAL, P_READING_TIME,
            P_TAG_VALUE, P_TAG_CODE, v_reprocess_ready_yn, P_ERROR_CODE);

  EXCEPTION
    WHEN others THEN
      NULL; -- Skip the error in this case

END insert_row_to_err_tab;



/* ****************************************************************************
* Function    		:get_incremental_value                                *
* Description 	 	:Get the incremental value for a tag value            *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_value -  tag value                             *
*                        p_is_number -  1 if tag value is number; 0 otherwise *
*                        p_is_cumulative -  1 to apply incremental logic;     *
*                                           0 otherwise                       *
*                        p_is_assending -  1 if tag is assending order;       *
*                                           0 otherwise                       *
*                        p_initial_value -  Tag initial value                 *
*                        p_max_reset_value -                                  *
*                        p_prev_tag_value -  Previous tag value               *
* Return Value          :Incremental value if incremental logic needs to be   *
*                          be applied; return p_tag_value otherwise           *
**************************************************************************** */

FUNCTION get_incremental_value(P_TAG_VALUE IN NUMBER,
                               P_IS_NUMBER IN NUMBER,
                               P_IS_CUMULATIVE IN NUMBER,
                               P_IS_ASSENDING IN NUMBER,
                               P_INITIAL_VALUE IN NUMBER,
                               P_MAX_RESET_VALUE IN NUMBER,
                               p_prev_tag_value IN NUMBER)  RETURN NUMBER
IS
  v_incr_value NUMBER;
BEGIN
  -- 1. Do not need to apply the incremental logic
  IF (P_IS_NUMBER IS NULL OR P_IS_NUMBER <> 1 OR
      P_IS_CUMULATIVE IS NULL OR P_IS_CUMULATIVE <> 1) THEN
    v_incr_value := P_TAG_VALUE;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 1 AND
         p_prev_tag_value IS NOT NULL) THEN
    -- 2. Assending tag and it is not the first reding
    -- 2.1 not reset
    v_incr_value := CASE WHEN P_TAG_VALUE >= p_prev_tag_value
                         THEN P_TAG_VALUE - p_prev_tag_value
                         -- 2.2 after reset
                         ELSE P_MAX_RESET_VALUE - p_prev_tag_value +
                              P_TAG_VALUE
                    END;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 1 AND
         p_prev_tag_value IS NULL) THEN
    -- 3. Assending tag and it is the first reding
    -- 3.1 First reading
    v_incr_value := CASE WHEN P_TAG_VALUE >= P_INITIAL_VALUE
                         THEN P_TAG_VALUE - P_INITIAL_VALUE
                         -- 3.2 First reading but reset already
                         ELSE P_MAX_RESET_VALUE - P_INITIAL_VALUE + P_TAG_VALUE
                    END;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 0 AND
         p_prev_tag_value IS NOT NULL) THEN
    -- 4. Descending tag and it is not the first reding
    -- 4.1 not reset
    v_incr_value := CASE WHEN P_TAG_VALUE <= p_prev_tag_value
                         THEN p_prev_tag_value - P_TAG_VALUE
                         -- 2.2 after reset
                         ELSE p_prev_tag_value + P_MAX_RESET_VALUE -
                              P_TAG_VALUE
                    END;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 0 AND
         p_prev_tag_value IS NULL) THEN
    -- 5. Descending tag and it is  the first reding
    -- 4.1 not reset
    v_incr_value := CASE WHEN P_TAG_VALUE <= P_INITIAL_VALUE
                         THEN P_INITIAL_VALUE - P_TAG_VALUE
                         -- 3.2 First reading but reset already
                         ELSE P_INITIAL_VALUE + P_MAX_RESET_VALUE - P_TAG_VALUE
                    END;
  END IF;
  RETURN v_incr_value;

END get_incremental_value;


/* ****************************************************************************
* Procedure    		:insert_runtime_error                                 *
* Description 	 	:Insert runtime exception into mth_runtime_err table  *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_proc_func_name -  Name of the calling procedure or *
*                                            function                         *
*                        p_error_code -      Oracle error code                *
*                        p_error_msg -       error message                    *
* Return Value          :None                                                 *
**************************************************************************** */
PROCEDURE insert_runtime_error(p_proc_func_name IN VARCHAR2,
                               p_error_code IN NUMBER,
                               p_error_msg IN VARCHAR2)
IS
 v_module_name VARCHAR2(80);
BEGIN
 v_module_name := 'MTH_SUSTAIN_ASPECT_PKG.' || p_proc_func_name;
 INSERT INTO mth_runtime_err
      ( MODULE, error_code, error_msg, timestamp) VALUES
       (v_module_name, p_error_code, p_error_msg, SYSDATE);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
END insert_runtime_error;

/* ****************************************************************************
* Procedure    		:insert_act_meters_to_readings                        *
* Description 	 	:Insert the actual meters associated with that tag    *
*                        into meter readings table                            *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code -  tag code                               *
*                        p_reading_time -  tag reading time                   *
*                        p_incr_tag_value -  incremental tag reading          *
*                        p_prev_reading_time - reading time for previous one  *
*                        p_frequency - frequeycy ;  null if not incremental   *
*                        p_meter_keys_arr -  List of meter fk keys associated *
*                                            with the tag                     *
* Return Value          :None                                                 *
**************************************************************************** */

PROCEDURE insert_act_meters_to_readings(p_tag_code IN VARCHAR2,
                                    p_reading_time IN DATE,
                                    p_incr_tag_value IN NUMBER,
                                    p_prev_reading_time IN DATE,
                                    p_frequency IN NUMBER,
                                    p_meter_keys_arr IN DBMS_SQL.NUMBER_TABLE)
IS
  v_from_time DATE;
  v_processed_flag VARCHAR2(1) := 'N';
  v_system_id NUMBER := -99999;
  v_from_time_using_frequency DATE;

BEGIN
  v_from_time_using_frequency := p_reading_time - p_frequency + 1/86400;
  v_from_time := CASE  WHEN p_prev_reading_time IS NULL THEN p_reading_time
                       ELSE p_prev_reading_time + 1/86400
                 END;

  -- Use freqnecy when available if it is the first reading or
  -- the reading is delayed
  IF v_from_time_using_frequency IS NOT NULL AND
       p_prev_reading_time IS NOT NULL AND
       v_from_time_using_frequency > v_from_time OR
       p_prev_reading_time IS NULL AND
       v_from_time_using_frequency IS NOT NULL THEN
    v_from_time := v_from_time_using_frequency;
  END IF;

  IF (p_meter_keys_arr IS NOT NULL) THEN
    FORALL i IN 1..p_meter_keys_arr.Count
      INSERT INTO MTH_METER_READINGS
            (METER_FK_KEY, FROM_TIME, TO_TIME, USAGE_VALUE, PROCESSED_FLAG,
              CREATION_DATE, LAST_UPDATE_DATE, CREATION_SYSTEM_ID,
              LAST_UPDATE_SYSTEM_ID) VALUES
            (p_meter_keys_arr(i), v_from_time, p_reading_time,
              p_incr_tag_value, v_processed_flag, SYSDATE, SYSDATE,
            v_system_id, v_system_id);
  END IF;

END insert_act_meters_to_readings;



/* ****************************************************************************
* Procedure    		:upsert_tag_to_latest_tab                             *
* Description 	 	:Update the latest reading time and tag value         *
*                  for a tag if table MTH_TAG_METER_READINGS_LATEST already   *
*                  has a entry for the tag. Otherwise, insert a new row       *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code -  tag code                               *
*                        p_latest_reading_time - reading time of the latest   *
*                        p_latest_tag_value -  latest tag reading             *
*                        p_lookup_entry_exist - whether the entry with the    *
*                            same tag code exists in the                      *
*                            MTH_TAG_METER_READINGS_LATEST or not             *
* Return Value          :None                                                 *
**************************************************************************** */

PROCEDURE upsert_tag_to_latest_tab(p_tag_code IN VARCHAR2,
                                   p_latest_reading_time IN DATE,
                                   p_latest_tag_value IN NUMBER,
                                   p_lookup_entry_exist IN BOOLEAN)
IS
BEGIN
  -- If the entry exists, do the update; otherwise, do the insert
  IF (p_lookup_entry_exist) THEN
    UPDATE MTH_TAG_METER_READINGS_LATEST
    SET    reading_time = p_latest_reading_time, tag_value = p_latest_tag_value
    WHERE  tag_code = p_tag_code;
  ELSE
    INSERT INTO MTH_TAG_METER_READINGS_LATEST
           (TAG_CODE, READING_TIME, TAG_VALUE) VALUES
           (p_tag_code, p_latest_reading_time, p_latest_tag_value);
  END IF;

END upsert_tag_to_latest_tab;


/* ****************************************************************************
* Procedure		:LOAD_ACT_METER_RAW_TO_READINGS                       *
* Description 	 	:Load data from tag meter raw for energy consumption  *
* in MTH_TAG_METER_READINGS_RAW into meter readings table MTH_METER_READINGS  *
* for actual meters                                                           *
**************************************************************************** */

PROCEDURE LOAD_ACT_METER_RAW_TO_READINGS(p_curr_partition IN NUMBER)
IS
--  TYPE DBMS_SQL.NUMBER_TABLE IS TABLE OF NUMBER;


  -- Fetch raw data for active tags from the patition
  -- ordered by TAG_CODE, READING_TIME
  CURSOR c_getRawData (p_processing_flag IN NUMBER) IS
    SELECT R.TAG_CODE, R.READING_TIME,  R.TAG_VALUE,
           Decode(DATA_TYPE, 'NUM', 1, 0) IS_NUMBER,
           CASE WHEN Nvl(S.APPLY_INCREMENTAL_LOGIC, 'N') = 'Y' AND
                     T.READING_TYPE = 'CHNG'
                THEN 1
                ELSE 0
           END AS IS_CUMULATIVE,
           Decode(T.ORDER_TYPE, 'ASC', 1, 0) IS_ASSENDING,
           T.INITIAL_VALUE, T.MAX_RESET_VALUE, S.TAG_TYPE,
           T.FREQUENCY_IN_MINUTES  / 1440 as FREQUENCY
    FROM MTH_TAG_METER_READINGS_RAW R, MTH_TAG_MASTER T,
         MTH_TAG_DATA_SOURCES S
    WHERE
          R.TAG_CODE = T.TAG_CODE (+) AND
          'ACTIVE' = T.STATUS (+)  AND
          T.TAG_DATA_SOURCE_FK_KEY = S.TAG_DATA_SOURCE_PK_KEY (+)
    ORDER BY TAG_CODE, READING_TIME;


  -- Fetch actual meter keys for the given tag code
  CURSOR c_getMetersForTag (p_tag_code IN VARCHAR2) IS
    SELECT METER_PK_KEY
    FROM MTH_METERS
    WHERE TAG_CODE = p_tag_code AND meter_type = 'ACT';

  -- Fetch the previous reading time for the given tag code
  CURSOR c_getPrevReadingTimeForTag (p_tag_code IN VARCHAR2) IS
    SELECT TAG_VALUE, READING_TIME
    FROM MTH_TAG_METER_READINGS_LATEST
    WHERE TAG_CODE = p_tag_code;


  v_raw_tab_name VARCHAR2(30) := 'MTH_TAG_METER_READINGS_RAW';
  v_curr_partition NUMBER := p_curr_partition;
  v_prev_tag_code VARCHAR2(255) := NULL;
  v_curr_tag_code VARCHAR2(255) := NULL;
  v_meter_fk_key_array  DBMS_SQL.NUMBER_TABLE;
  v_err_code VARCHAR2(255);
  v_lookup_entry_exist boolean;
  v_prev_reading_time DATE := NULL;
  v_prev_tag_value NUMBER := NULL;
  v_incr_tag_value NUMBER;
  -- Record the number of insert and update operations
  v_num_insert_update NUMBER := 0;
  v_reprocess_ready_yn VARCHAR2(1) := 'N';
  v_meter_reading_err_pk_key NUMBER;
  v_error_code NUMBER;
  v_error_msg VARCHAR2(4000);


BEGIN
  -- 1. First switch the partition for the meter readings raw table
  --mth_util_pkg.switch_column_default_value(v_raw_tab_name, v_curr_partition);
  IF (v_curr_partition = 0) THEN
    -- No data available in the table to be processed
    RETURN;
  END IF;

  -- 2. Fetch the raw data for active tag and process each row
  FOR r_raw_data IN c_getRawData(v_curr_partition) LOOP
    v_curr_tag_code := r_raw_data.TAG_CODE;

    -- 2.0 Update/Create entry in MTH_TAG_METER_READINGS_LATEST for previous tag
    IF (v_prev_tag_code IS NOT NULL AND v_prev_tag_code <> v_curr_tag_code) THEN
      upsert_tag_to_latest_tab(v_prev_tag_code,
                               v_prev_reading_time,
                               v_prev_tag_value,
                               v_lookup_entry_exist);
      v_num_insert_update := v_num_insert_update + 1;
    END IF;

    -- 2.1 Find the meters and latest reading for the new tag code
    IF (v_prev_tag_code IS NULL OR v_prev_tag_code <> v_curr_tag_code) THEN
      -- 2.1.0 Reset the previous reading for the new tag code
      v_prev_tag_value := NULL;
      v_prev_reading_time := NULL;

      -- 2.1.1 Fetch meter keys for the specified tag code
      OPEN c_getMetersForTag(v_curr_tag_code);
      FETCH c_getMetersForTag BULK COLLECT INTO v_meter_fk_key_array;
      CLOSE c_getMetersForTag;

      -- 2.1.2 Find previous reading time and tag value for the  currenttag
      --       in the lookup table MTH_TAG_METER_READINGS_LATEST
      OPEN c_getPrevReadingTimeForTag(v_curr_tag_code);
      FETCH c_getPrevReadingTimeForTag INTO
              v_prev_tag_value, v_prev_reading_time;
      CLOSE c_getPrevReadingTimeForTag;
      v_lookup_entry_exist :=  v_prev_reading_time IS NOT NULL;
    END IF;



    -- 2.2 Validate the raw data
    v_err_code := IS_RAW_DATA_ROW_VALID (r_raw_data.TAG_CODE,
                                         r_raw_data.READING_TIME,
                                         r_raw_data.TAG_VALUE,
                                         r_raw_data.IS_NUMBER,
                                         r_raw_data.IS_CUMULATIVE,
                                         r_raw_data.IS_ASSENDING,
                                         r_raw_data.INITIAL_VALUE,
                                         r_raw_data.MAX_RESET_VALUE,
                                         r_raw_data.TAG_TYPE,
                                         r_raw_data.FREQUENCY,
                                         v_meter_fk_key_array.Count,
                                         v_prev_reading_time);

    -- 2.3 Insert data into either meter readings or error table
    IF (v_err_code IS NOT NULL OR Length(v_err_code) > 0) THEN
      -- 2.3.1 Insert the error row to error table  if there is any error
      INSERT INTO MTH_METER_READINGS_ERR
          (METER_READINGS_ERR_PK_KEY, TO_TIME, USAGE_VALUE, TAG_CODE,
          REPROCESS_READY_YN, ERR_CODE)
        VALUES (MTH_METER_READINGS_ERR_S.NEXTVAL, r_raw_data.READING_TIME,
                r_raw_data.TAG_VALUE, r_raw_data.TAG_CODE,
                v_reprocess_ready_yn, v_err_code);
      v_num_insert_update := v_num_insert_update + 1;
    ELSE
      -- 2.3.2 Get the incremental value
      v_incr_tag_value := get_incremental_value(r_raw_data.TAG_VALUE,
                                                r_raw_data.IS_NUMBER,
                                                r_raw_data.IS_CUMULATIVE,
                                                r_raw_data.IS_ASSENDING,
                                                r_raw_data.INITIAL_VALUE,
                                                r_raw_data.MAX_RESET_VALUE,
                                                v_prev_tag_value);

      -- 2.3.3 Insert the data into the meter readings table
      insert_act_meters_to_readings(r_raw_data.TAG_CODE,
                                    r_raw_data.READING_TIME,
                                    v_incr_tag_value,
                                    v_prev_reading_time,
                                    CASE r_raw_data.IS_CUMULATIVE
                                         WHEN 0 THEN r_raw_data.FREQUENCY
                                         ELSE NULL END,
                                    v_meter_fk_key_array);

      v_num_insert_update := v_num_insert_update + v_meter_fk_key_array.Count;
    END IF;

    -- 2.4 Save the current data as previous data, which can be used for :
    --     - Use the previous reading time - 1 second as FROM TIME for new data
    --     - Use the previous tag value to calcuate the incremental value
    --     - Save all of above into lookup table  MTH_TAG_METER_READINGS_LATEST
    --       when processing the last reading for this tag, wihch can be
    --       identified by find the next and different tag code
    v_prev_tag_code :=  v_curr_tag_code;
    v_prev_tag_value := r_raw_data.TAG_VALUE;
    v_prev_reading_time := Greatest(r_raw_data.READING_TIME,
                                    Nvl(v_prev_reading_time,
                                        r_raw_data.READING_TIME));

  END LOOP;

  -- 2.6 Update/Create entry in MTH_TAG_METER_READINGS_LATEST for the last tag
  upsert_tag_to_latest_tab(v_prev_tag_code,
                           v_prev_reading_time,
                           v_prev_tag_value,
                           v_lookup_entry_exist);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      v_error_code := SQLCODE;
      v_error_msg :=  SQLERRM;
      insert_runtime_error('insert_act_meters_to_readings',
                           v_error_code,
                           v_error_msg);
      COMMIT;
      RAISE;

END LOAD_ACT_METER_RAW_TO_READINGS;




/* ****************************************************************************
* Function	:getEquipPowerRating                                          *
* Description 	:Get the equipment power rating. If it is not an equipment,   *
*                  return 0.                                                  *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_entity_fk_key - type of the entity                 *
*                        p_entity_type - the ending point of time to          *
* Return Value          :Power rating of the equipment. If it is not an       *
                         equipment, return 0.                                 *
**************************************************************************** */

FUNCTION getEquipPowerRating(p_entity_fk_key IN NUMBER,
                             p_entity_type IN VARCHAR2) RETURN NUMBER
IS
  v_power_rating NUMBER := 0;
BEGIN
  IF (p_entity_type = 'EQUIPMENT') THEN
    SELECT power_rating INTO v_power_rating
    FROM   mth_equipments_d
    WHERE  equipment_pk_key = p_entity_fk_key;
  END IF;
  IF (v_power_rating IS NULL) THEN
    v_power_rating := 0;
  END IF;
  RETURN v_power_rating;

  EXCEPTION --generic exception to capture all the errors
  -- TO DO: Need to report the error
    WHEN others THEN
      RETURN 0;
END getEquipPowerRating;


/* ****************************************************************************
* Function	:getSFTInOneHour                                              *
* Description  	:Get shift availability time in the specified hour for the    *
*                  equipment power rating. If it is not an equipment, return 0*
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - The end time                             *
*                        p_cal_avb_time - true for shift available; false otw *
*                        p_shifts - nested table contains the shifts          *
*                        p_shifts_idx - current index to the shifts table     *
* Return Value          :Time in hour for the for the shift availability or   *
*                        not availability time within the hour specified      *
**************************************************************************** */

FUNCTION getSFTInOneHour(p_from_time IN DATE,
                         p_to_time IN DATE,
                         p_cal_avb_time IN BOOLEAN,
                         p_shifts IN shift_array_type,
                         p_shifts_idx IN OUT NOCOPY NUMBER)
           RETURN NUMBER
IS
  v_hours NUMBER := 0;
  v_continue BOOLEAN := TRUE;
  v_from_time DATE := p_from_time;
BEGIN
  IF p_cal_avb_time IS NULL THEN
  -- Wrong type
    RETURN 0;
  END IF;

  WHILE (p_shifts_idx <= p_shifts.Count AND v_from_time < p_to_time AND
         v_continue) LOOP
         --Dbms_Output.put_line(' p_shifts_idx : ' || p_shifts_idx);
         --Dbms_Output.put_line(' p_shifts.Count  : ' || p_shifts.Count );
    IF (p_to_time < p_shifts(p_shifts_idx).from_date) THEN
      -- No more shift for the tiem range  since the current shift
      -- is beyond the time range
      -- from time, to time:     |----------------|
      -- shift start and end:                         |---------------------|
      v_continue := FALSE;
    ELSIF  (v_from_time > p_shifts(p_shifts_idx).to_date) THEN
      -- The current time range is ahead of the shift, move the shift forward
      -- from time, to time:                               |----------------|
      -- shift start and end:    |---------------------|
      p_shifts_idx := p_shifts_idx + 1;
      -- there is intersection between the shift and the time range
    ELSIF (p_to_time >= p_shifts(p_shifts_idx).from_date AND
           p_to_time <= p_shifts(p_shifts_idx).To_Date) THEN
      -- to_time is within the range of the shift
      -- from time, to time:       |----------------|
      -- shift start and end:          |----------------------------|
      -- or
      -- from time, to time:             |----------------|
      -- shift start and end:          |----------------------------|
      -- time range overlaps with shift, but does not include the end of shift
      IF (p_cal_avb_time AND p_shifts(p_shifts_idx).availability_flag = 'Y' OR
          NOT p_cal_avb_time AND p_shifts(p_shifts_idx).availability_flag = 'N')
      THEN
        v_hours := v_hours + (Least(p_shifts(p_shifts_idx).To_Date, p_to_time)
                     - Greatest(p_shifts(p_shifts_idx).from_date, v_from_time))
                     * 24 + 1/3600;
      END IF;
      v_from_time := Least(p_shifts(p_shifts_idx).To_Date, p_to_time) +
                     1/86400;
      v_continue := FALSE;
    ELSIF (p_from_time <= p_shifts(p_shifts_idx).from_date AND
           p_to_time >= p_shifts(p_shifts_idx).To_Date) THEN
      -- The shift is within the time range
      -- from time, to time:         |--------------------------------|
      -- shift start and end:             |---------------------|
      IF (p_cal_avb_time AND p_shifts(p_shifts_idx).availability_flag = 'Y' OR
         NOT p_cal_avb_time AND p_shifts(p_shifts_idx).availability_flag = 'N')
      THEN
        v_hours := v_hours + (Least(p_shifts(p_shifts_idx).To_Date, p_to_time)
                     - Greatest(p_shifts(p_shifts_idx).from_date, v_from_time))
                     * 24 + 1/3600;
      END IF;
      v_from_time := Least(p_shifts(p_shifts_idx).To_Date, p_to_time) +
                     1/86400;
      v_continue := TRUE;
      p_shifts_idx := p_shifts_idx + 1;
    ELSIF (p_from_time >= p_shifts(p_shifts_idx).from_date AND
           p_from_time <= p_shifts(p_shifts_idx).To_Date) THEN
      -- from time is within the range of the shift, but not the to time.
      -- from time, to time:                         |----------------|
      -- shift start and end:          |---------------------|
      -- time range overlaps with shift, but does not include the end of shift
      IF (p_cal_avb_time AND p_shifts(p_shifts_idx).availability_flag = 'Y' OR
         NOT p_cal_avb_time AND p_shifts(p_shifts_idx).availability_flag = 'N')
      THEN
        v_hours := v_hours + (Least(p_shifts(p_shifts_idx).To_Date, p_to_time)
                     - Greatest(p_shifts(p_shifts_idx).from_date, v_from_time))
                     * 24 + 1/3600;
      END IF;
      v_from_time := Least(p_shifts(p_shifts_idx).To_Date, p_to_time) +
                     1/86400;
      v_continue := TRUE;
      p_shifts_idx := p_shifts_idx + 1;
    END IF;
  END LOOP;
  RETURN v_hours;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
END getSFTInOneHour;

/* ****************************************************************************
* Function	:getCompValuesForSFT                                          *
* Description  	:Get shift availability time in hours for an entity in each   *
*                  hour during the given time range.                          *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_entity_fk_key - type of the entity                 *
*                        p_entity_type - the ending point of time to          *
*                        p_component_value - Component value for shift avail: *
*                                                1) Available AVB             *
*                                                2) Non-Available NAVB        *
*                        p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - the ending point of time to              *
*                                      calculate the virtual meter            *
* Return Value          :Collection of shift availability time for each       *
*                        hour during the given time range.                    *
**************************************************************************** */

FUNCTION getCompValuesForSFT(p_entity_fk_key IN NUMBER,
                             p_entity_type IN VARCHAR2,
                             p_component_value IN VARCHAR2,
                             p_from_time IN DATE,
                             p_to_time IN DATE) RETURN DBMS_SQL.NUMBER_TABLE
IS
  CURSOR c_getShifts(p_entity_type IN VARCHAR2, p_entity_fk_key IN VARCHAR2,
                     p_from_time IN DATE, p_to_time IN DATE) IS
    SELECT from_date, To_Date, availability_flag
    FROM   MTH_EQUIPMENT_SHIFTS_D
    WHERE  equipment_fk_key = p_entity_fk_key AND
           UPPER(entity_type) = p_entity_type  AND
           To_Date >= p_from_time AND
           from_date <= p_to_time
    ORDER BY from_date;

  v_shifts shift_array_type;
  v_comp_values DBMS_SQL.NUMBER_TABLE;

  v_num_elements NUMBER;
  v_from_time DATE := p_from_time;
  v_to_time DATE;
  v_end_from_time DATE := p_to_time - 1/24;
  v_one_hour NUMBER := 1/24;
  i NUMBER := 1;
  v_value NUMBER;
  -- Record the current index for the shifts nested table v_shifts
  v_shifts_idx NUMBER := 1;
  v_for_shift_available BOOLEAN;


BEGIN
  OPEN c_getShifts(p_entity_type, p_entity_fk_key,p_from_time, p_to_time);
  FETCH c_getShifts BULK COLLECT INTO v_shifts;
  CLOSE c_getShifts;

  v_num_elements :=  Trunc((p_to_time - p_from_time) * 24) + 1;
    IF (p_component_value = 'AVB') THEN
      v_for_shift_available := TRUE;
    ELSIF (p_component_value = 'NAVB') THEN
      v_for_shift_available := FALSE;
    ELSE
      v_for_shift_available := NULL;
    END IF;
    WHILE (v_from_time <= v_end_from_time) LOOP
      v_to_time :=  v_from_time + 1/24 - 1/86400;
      v_comp_values(i) := getSFTInOneHour(v_from_time,
                                          v_to_time,
                                          v_for_shift_available,
                                          v_shifts,
                                          v_shifts_idx);
      i := i + 1;
      v_from_time := v_from_time + v_one_hour;
    END LOOP;

  RETURN v_comp_values;
END getCompValuesForSFT;


/* ****************************************************************************
* Function	:getstatusTimeInOneHour                                       *
* Description  	:Get shift availability time in the specified hour for the    *
*                  equipment power rating. If it is not an equipment, return 0*
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - The end time                             *
*                        p_component_value - The possible values are          *
*                                                1) Run Time RT               *
*                                                2) Down Time DT              *
*                                                3) Idle Time IT              *
*                                                4) Off Time  OT              *
*                        p_status - nested table contains the status times    *
*                        p_idx - current index to the status table            *
* Return Value          :Time in hour for the for the specified status        *
*                         within the hour specified;                          *
                         NULL if the status is not available for the          *
*                        specified time range. Need to wait for the status    *
*                        to be available.                                     *
**************************************************************************** */

FUNCTION getstatusTimeInOneHour(p_from_time IN DATE,
                                p_to_time IN DATE,
                                p_component_value IN varchar2,
                                p_status IN status_array_type,
                                p_idx IN OUT NOCOPY NUMBER)
           RETURN NUMBER
IS
  v_hours NUMBER := 0;
  v_time_range NUMBER := 0;
  v_continue BOOLEAN := TRUE;
  v_from_time DATE := p_from_time;
  v_time_for_status NUMBER;
BEGIN
  WHILE (p_idx <= p_status.Count AND v_from_time < p_to_time AND
         v_continue) LOOP

    IF (p_to_time >= p_status(p_idx).from_date AND
        p_status(p_idx).To_Date IS NULL) THEN
     -- The status range is still open without ending time. Need to wait until
     -- the status range is closed in order to calculate the hours for the
     -- status
      -- from time, to time:     |----------------|
      -- status start and end:           |-------------------...(end time=NULL)
      v_hours := NULL;
      v_continue := FALSE;
    ELSIF (p_to_time < p_status(p_idx).from_date) THEN
      -- No more status for the time range  since the current status range
      -- is beyond the time range
      -- from time, to time:     |----------------|
      -- status start and end:                         |---------------------|

      v_continue := FALSE;
    ELSIF  (v_from_time > p_status(p_idx).to_date) THEN
      -- The current time range is ahead of the status range, move the status
      -- range forward
      -- from time, to time:                               |----------------|
      -- status start and end:    |---------------------|

      p_idx := p_idx + 1;
      -- there is intersection between the status range and the time range
    ELSIF (p_to_time >= p_status(p_idx).from_date AND
           p_to_time <= p_status(p_idx).To_Date) THEN
      -- to_time is within the range of the status range
      -- from time, to time:       |----------------|
      -- status start and end:          |----------------------------|
      -- or
      -- from time, to time:              |----------------|
      -- status start and end:          |----------------------------|
      -- time range overlaps with status, but does not include end of status
      v_time_range := (Least(p_status(p_idx).To_Date, p_to_time) -
                   Greatest(p_status(p_idx).from_date, v_from_time)) + 1/86400;
      --Dbms_Output.put_line(' case 2 v_hours before : ' || v_hours);

      v_hours := v_hours + v_time_range / (p_status(p_idx).to_date -
                                      p_status(p_idx).from_date +
                                      1/86400) *
                           CASE p_component_value
                            WHEN 'RT' THEN Nvl(p_status(p_idx).run_hours, 0)
                            WHEN 'DT' THEN Nvl(p_status(p_idx).down_hours, 0)
                            WHEN 'IT' THEN Nvl(p_status(p_idx).idle_hours, 0)
                            WHEN 'OT' THEN Nvl(p_status(p_idx).off_hours, 0)
                            ELSE 0
                            END;
      --v_from_time := Least(p_status(p_idx).To_Date, p_to_time) + 1/86400;
      v_continue := FALSE;
      --Dbms_Output.put_line(' case 2 v_hours : ' || v_hours);

    ELSIF (p_from_time <= p_status(p_idx).from_date AND
           p_to_time >= p_status(p_idx).To_Date) THEN
      -- The status record is within the time range
      -- from time, to time:         |--------------------------------|
      -- status start and end:            |------------------|
      --v_time_range := (Least(p_status(p_idx).To_Date, p_to_time) -
      --             Greatest(p_status(p_idx).from_date, v_from_time)) + 1/86400;

     -- v_hours := v_hours + v_time_range / (p_status(p_idx).to_date -
      --                                p_status(p_idx).from_date +
      --                                1/86400) *
      v_hours := v_hours +  CASE p_component_value
                            WHEN 'RT' THEN Nvl(p_status(p_idx).run_hours, 0)
                            WHEN 'DT' THEN Nvl(p_status(p_idx).down_hours, 0)
                            WHEN 'IT' THEN Nvl(p_status(p_idx).idle_hours, 0)
                            WHEN 'OT' THEN Nvl(p_status(p_idx).off_hours, 0)
                            ELSE 0
                            END;
     -- v_from_time := Least(p_status(p_idx).To_Date, p_to_time) + 1/86400;
      v_continue := TRUE;
      p_idx := p_idx + 1;
            --Dbms_Output.put_line(' case 3 v_hours : ' || v_hours);

    ELSIF (p_from_time >= p_status(p_idx).from_date AND
           p_from_time <= p_status(p_idx).To_Date) THEN
      -- from time is within the range of the status range, but not the to time.
      -- from time, to time:                         |----------------|
      -- status start and end:          |---------------------|
      -- time range overlaps with status, but does not include the end of status
      v_time_range := (Least(p_status(p_idx).To_Date, p_to_time) -
                   Greatest(p_status(p_idx).from_date, v_from_time)) + 1/86400;
      v_hours := v_hours + v_time_range / (p_status(p_idx).to_date -
                                      p_status(p_idx).from_date +
                                      1/86400) *
                            CASE p_component_value
                            WHEN 'RT' THEN Nvl(p_status(p_idx).run_hours, 0)
                            WHEN 'DT' THEN Nvl(p_status(p_idx).down_hours, 0)
                            WHEN 'IT' THEN Nvl(p_status(p_idx).idle_hours, 0)
                            WHEN 'OT' THEN Nvl(p_status(p_idx).off_hours, 0)
                            ELSE 0
                            END ;
             --Dbms_Output.put_line(' case 4 v_hours : ' || v_hours);

    --  v_from_time := Least(p_status(p_idx).To_Date, p_to_time) + 1/86400;
      v_continue := TRUE;
      p_idx := p_idx + 1;

    END IF;
  END LOOP;
  RETURN v_hours;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
END getstatusTimeInOneHour;


/* ****************************************************************************
* Function	:getCompValuesForEquipStatus                                  *
* Description  	:Get run/idle/down/off time for the specified hour. If it     *
*                  is not an equipment, return 0.                             *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_entity_fk_key - type of the entity                 *
*                        p_entity_type - the ending point of time to          *
*                        p_component_value - Component value for shift avail: *
*                                                1) Run Time RT               *
*                                                2) Down Time DT              *
*                                                3) Idle Time IT              *
*                                                4) Off Time  OT              *
*                        p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - the ending point of time to              *
*                                      calculate the virtual meter            *
* Return Value          :Power rating of the equipment. If it is not an       *
                         equipment, return 0.                                 *
**************************************************************************** */

FUNCTION getCompValuesForEquipStatus(p_entity_fk_key IN NUMBER,
                                     p_entity_type IN VARCHAR2,
                                     p_component_value IN VARCHAR2,
                                     p_from_time IN DATE,
                                     p_to_time IN DATE)
                RETURN DBMS_SQL.NUMBER_TABLE
IS
  CURSOR c_getEquipStatusTime(p_equip_fk_key IN VARCHAR2,
                              p_from_time IN DATE,
                              p_to_time IN DATE) IS
    SELECT actual_from_date, actual_to_date, run_hours, down_hours,
           idle_hours, off_hours
    FROM   MTH_EQUIP_PROD_PERFORMANCE_F
    WHERE  equipment_fk_key = p_equip_fk_key AND
           actual_to_date >= p_from_time AND
           actual_from_date <= p_to_time  AND
           actual_to_date IS NOT NULL
    ORDER BY actual_from_date;

  v_status status_array_type;
  v_comp_values DBMS_SQL.NUMBER_TABLE;

  --v_num_elements NUMBER;
  v_from_time DATE := p_from_time;
  v_to_time DATE;
  v_end_from_time DATE := p_to_time - 1/24;
  v_one_hour NUMBER := 1/24;
  i NUMBER := 1;
  --v_value NUMBER;
  -- Record the current index for the shifts nested table v_shifts
  v_idx NUMBER := 1;
  v_continue BOOLEAN := TRUE;
  v_comp_value NUMBER;
  v_data_end_time DATE;

BEGIN

  IF (p_entity_type <> 'EQUIPMENT') THEN
   RETURN v_comp_values;
  END IF;

  OPEN c_getEquipStatusTime(p_entity_fk_key,
                            p_from_time, p_to_time);
  FETCH c_getEquipStatusTime BULK COLLECT INTO v_status;
  CLOSE c_getEquipStatusTime;

  IF (v_status IS NOT NULL AND v_status.Count > 0) THEN
    v_data_end_time := v_status(v_status.Count).to_date;
  ELSE
    v_data_end_time := v_from_time - 1;
  END IF;

  v_end_from_time := Least(v_end_from_time,
                            trunc(v_data_end_time - 1/24 + 1/86400, 'HH24'));

    WHILE (v_from_time <= v_end_from_time AND
           v_status IS NOT NULL AND
           v_idx <= v_status.Count AND
           v_continue) LOOP
      v_to_time :=  v_from_time + 1/24 - 1/86400;
      v_comp_value  := getstatusTimeInOneHour(v_from_time,
                                              v_to_time,
                                              p_component_value,
                                              v_status,
                                              v_idx);
      IF ( v_comp_value IS NOT NULL) THEN
        v_comp_values(i) :=  v_comp_value;
        i := i + 1;
        v_from_time := v_from_time + v_one_hour;
      ELSE
        -- The status is not available for this hour
        v_continue := FALSE;
      END IF;
    END LOOP;
    RETURN v_comp_values;

END getCompValuesForEquipStatus;


/* ****************************************************************************
* Function       :getMeterReadingInOneHour                                    *
* Description 	 :Get shift availability time in the specified hour for the   *
*                  equipment power rating. If it is not an equipment, return 0*
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - The end time                             *
*                        p_component_value - The possible values are          *
*                                                1) Run Time RT               *
*                                                2) Down Time DT              *
*                                                3) Idle Time IT              *
*                                                4) Off Time  OT              *
*                        p_status - nested table contains the status times    *
*                        p_idx - current index to the status table            *
* Return Value          :Time in hour for the for the specified status        *
*                         within the hour specified;                          *
                         NULL if the status is not available for the          *
*                        specified time range. Need to wait for the status    *
*                        to be available.                                     *
**************************************************************************** */

FUNCTION getMeterReadingInOneHour(p_from_time IN DATE,
                                  p_to_time IN DATE,
                                  p_meter_fk_key IN VARCHAR2,
                                  p_meter_readings IN readings_array_type,
                                  p_idx IN OUT NOCOPY NUMBER)
           RETURN NUMBER
IS
  v_usage_value NUMBER := 0;
  v_time_range NUMBER := 0;
  v_continue BOOLEAN := TRUE;
  v_from_time DATE := p_from_time;
  v_meter_value NUMBER;
BEGIN
  WHILE (p_idx <= p_meter_readings.Count AND v_from_time < p_to_time AND
         v_continue) LOOP

    IF (p_to_time > p_meter_readings(p_idx).from_date AND
        p_meter_readings(p_idx).To_Date IS NULL) THEN
     -- The meter range is still open without ending time. Need to wait until
     -- the status range is closed in order to calculate the hours for the
     -- status
      -- from time, to time:     |----------------|
      -- status start and end:           |-------------------...(end time=NULL)
      v_usage_value := NULL;
      v_continue := FALSE;
    ELSIF (p_to_time < p_meter_readings(p_idx).from_date) THEN
      -- No more status for the time range  since the current status range
      -- is beyond the time range
      -- from time, to time:     |----------------|
      -- status start and end:                         |---------------------|

      v_continue := FALSE;
    ELSIF  (v_from_time > p_meter_readings(p_idx).to_date) THEN
      -- The current time range is ahead of the status range, move the status
      -- range forward
      -- from time, to time:                               |----------------|
      -- status start and end:    |---------------------|

      p_idx := p_idx + 1;
      -- there is intersection between the status range and the time range
    ELSIF (p_to_time >= p_meter_readings(p_idx).from_date AND
           p_to_time <= p_meter_readings(p_idx).To_Date) THEN
      -- to_time is within the range of the status range
      -- from time, to time:       |----------------|
      -- status start and end:          |----------------------------|
      -- or
      -- from time, to time:              |----------------|
      -- status start and end:          |----------------------------|
      -- time range overlaps with status, but does not include end of status

      v_time_range := (Least(p_meter_readings(p_idx).To_Date, p_to_time) -
                       Greatest(p_meter_readings(p_idx).from_date, v_from_time))
                          + 1/86400;
      v_usage_value := v_usage_value +
                        v_time_range / (p_meter_readings(p_idx).to_date -
                                      p_meter_readings(p_idx).from_date +
                                      1/86400) *
                                      p_meter_readings(p_idx).usage_value;
      v_from_time := Least(p_meter_readings(p_idx).To_Date, p_to_time) +
                      1/86400;
      v_continue := FALSE;

    ELSIF (p_from_time <= p_meter_readings(p_idx).from_date AND
           p_to_time >= p_meter_readings(p_idx).To_Date) THEN
      -- The status record is within the time range
      -- from time, to time:         |--------------------------------|
      -- shift start and end:            |------------------|
      --v_time_range := (Least(p_status(p_idx).To_Date, p_to_time) -
      --           Greatest(p_status(p_idx).from_date, v_from_time)) + 1/86400;

     -- v_hours := v_hours + v_time_range / (p_status(p_idx).to_date -
      --                                p_status(p_idx).from_date +
      --                                1/86400) *
      v_usage_value := v_usage_value + p_meter_readings(p_idx).usage_value;
      v_from_time := Least(p_meter_readings(p_idx).To_Date, p_to_time) +
                      1/86400;
      v_continue := TRUE;
      p_idx := p_idx + 1;

    ELSIF (p_from_time >= p_meter_readings(p_idx).from_date AND
           p_from_time <= p_meter_readings(p_idx).To_Date) THEN
      -- from time is within the range of the status range, but not the to time.
      -- from time, to time:                         |----------------|
      -- status start and end:          |---------------------|
      -- time range overlaps with status, but does not include the end of status
      v_time_range := (Least(p_meter_readings(p_idx).To_Date, p_to_time) -
                     Greatest(p_meter_readings(p_idx).from_date, v_from_time)) +
                       1/86400;
      v_usage_value := v_usage_value +
                       v_time_range / (p_meter_readings(p_idx).to_date -
                                      p_meter_readings(p_idx).from_date +
                                      1/86400) *
                                      p_meter_readings(p_idx).usage_value;

      v_from_time := Least(p_meter_readings(p_idx).To_Date, p_to_time) +
                     1/86400;

      v_continue := TRUE;
      --ELSE
            --Dbms_Output.put_line(' case 4 p_idx : ' || p_idx);

    END IF;
  END LOOP;
  RETURN v_usage_value;
END getMeterReadingInOneHour;


/* ****************************************************************************
* Function	:getCompValuesForMeter                                        *
* Description 	:Get run/idle/down/off time for the specified hour. If it     *
*                  is not an equipment, return 0.                             *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_meter_fk_key - meter fk key                        *
*                        p_entity_type - the ending point of time to          *
*                        p_component_value - meter fk key                     *
*                        p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - the ending point of time to              *
*                                      calculate the virtual meter            *
* Return Value          :Array of meter readings with type readings_array_type*
**************************************************************************** */

FUNCTION getCompValuesForMeter(p_meter_fk_key IN NUMBER,
                               p_from_time IN DATE,
                               p_to_time IN DATE)
                RETURN DBMS_SQL.NUMBER_TABLE
IS
  CURSOR c_getMeterReadings(p_meter_fk_key IN NUMBER,
                            p_from_time IN DATE,
                            p_to_time IN DATE) IS

    SELECT from_time, to_time, usage_value
    FROM   mth_meter_readings
    WHERE  meter_fk_key = p_meter_fk_key AND
           to_time >= p_from_time AND
           from_time <= p_to_time
    ORDER BY from_time;

  v_meter_readings readings_array_type;
  v_comp_values DBMS_SQL.NUMBER_TABLE;

  v_num_elements NUMBER;
  v_from_time DATE := p_from_time;
  v_to_time DATE;
  v_end_from_time DATE := p_to_time - 1/24;
  v_one_hour NUMBER := 1/24;
  i NUMBER := 1;
  v_value NUMBER;
  -- Record the current index for the shifts nested table v_shifts
  v_idx NUMBER := 1;
  v_continue BOOLEAN := TRUE;
  v_comp_value NUMBER;
  v_data_end_time DATE;


BEGIN
  OPEN c_getMeterReadings(p_meter_fk_key, p_from_time, p_to_time);
  FETCH c_getMeterReadings BULK COLLECT INTO v_meter_readings;
  CLOSE c_getMeterReadings;

  IF (v_meter_readings IS NOT NULL AND v_meter_readings.Count > 0) THEN
    v_data_end_time := v_meter_readings(v_meter_readings.Count).To_Date;
  ELSE
    v_data_end_time := v_from_time - 1;
  END IF;
  --Dbms_Output.put_line( ' v_data_end_time ' || v_data_end_time);

    --Dbms_Output.put_line( ' p_to_time ' || p_to_time);

  v_end_from_time := Least(v_end_from_time,
                            trunc(v_data_end_time - 1/24 + 1/86400, 'HH24'));
  --Dbms_Output.put_line( ' v_end_from_time ' || v_end_from_time);

  v_num_elements :=  Trunc((p_to_time - p_from_time) * 24) + 1;
  WHILE (v_from_time <= v_end_from_time AND
         v_meter_readings IS NOT NULL AND
         v_idx <= v_meter_readings.Count AND
         v_continue) LOOP
    v_to_time :=  v_from_time + 1/24 - 1/86400;
    v_comp_value  := getMeterReadingInOneHour(v_from_time,
                                              v_to_time,
                                              p_meter_fk_key,
                                              v_meter_readings,
                                              v_idx);


    -- TO DO: Need to check whether that is the last reading and the
    -- end time of the last record is less than the from time
    --- If so, need to stop there.
    IF ( v_comp_value IS NOT NULL) THEN
      v_comp_values(i) :=  v_comp_value;
      i := i + 1;
      v_from_time := v_from_time + v_one_hour;
    ELSE
      -- The status is not available for this hour
      v_continue := FALSE;
    END IF;
    END LOOP;

    RETURN v_comp_values;
END getCompValuesForMeter;


/* ****************************************************************************
* Function	:getCompValuesForCustom                                       *
* Description  	:Call custom API to get the usage value for custom type       *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_entity_fk_key - type of the entity                 *
*                        p_entity_type - the ending point of time to          *
*                        p_component_value - Component value                  *
*                        p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - the ending point of time to              *
*                                      calculate the virtual meter            *
* Return Value          :Usage value for each hour for the time duration      *
*                        specified                                            *
**************************************************************************** */

FUNCTION getCompValuesForCustom(p_entity_fk_key IN NUMBER,
                                p_entity_type IN VARCHAR2,
                                p_component_value IN VARCHAR2,
                                p_from_time IN DATE,
                                p_to_time IN DATE)
                RETURN DBMS_SQL.NUMBER_TABLE
IS
  CURSOR c_get_custom_api IS

    SELECT DESCRIPTION
    FROM FND_LOOKUPS
    WHERE LOOKUP_CODE = 'CUSTOM_SUSTAIN_ASPECT_API' AND
          LOOKUP_TYPE ='MTH_CUSTOM_PLSQL_API';

  v_api_name VARCHAR2(200) := NULL;
  v_stmt VARCHAR2(4000);
  v_comp_values DBMS_SQL.NUMBER_TABLE;

  v_num_elements NUMBER;
  v_from_time DATE := p_from_time;
  v_to_time DATE;
  v_end_from_time DATE := p_to_time - 1/24;
  v_one_hour NUMBER := 1/24;
  i NUMBER := 1;
  v_value NUMBER;
  -- Record the current index for the shifts nested table v_shifts
  v_idx NUMBER := 1;
  v_continue BOOLEAN := TRUE;
  v_comp_value NUMBER;
  v_err_msg VARCHAR2(4000);
  v_err_code NUMBER;


BEGIN
    SELECT DESCRIPTION INTO v_api_name
    FROM FND_LOOKUPS
    WHERE LOOKUP_CODE = 'CUSTOM_SUSTAIN_ASPECT_API' AND
          LOOKUP_TYPE ='MTH_CUSTOM_PLSQL_API';

  IF (sql%NOTFOUND) THEN

    v_err_msg :=
    'Could not find the custom API to calculate sustainability aspect usage';

    INSERT INTO mth_runtime_err
      ( MODULE, error_msg, timestamp) VALUES
       ('MTH_SUSTAIN_ASPECT_PKG.getCompValuesForCustom', v_err_msg, SYSDATE);
  ELSE
  -- API signature:
  -- v_api_name(p_entity_fk_key IN NUMBER,
  --                              p_entity_type IN VARCHAR2,
  --                              p_component_value IN VARCHAR2,
  --                              p_from_time IN DATE,
  --                              p_to_time IN DATE)
    v_stmt := 'SELECT ' ||  v_api_name || '(:1, ' ||       -- p_entity_type
                                           ':2, ' ||       -- p_entity_type
                                           ':3, ' ||       -- p_component_value
                                           ':4, ' ||       -- p_from_time
                                           ':5)'  ||       -- p_to_time
                              ' FROM DUAL';
                              --Dbms_Output.put_line(' v_stmt ' || v_stmt);
    v_num_elements :=  Trunc((p_to_time - p_from_time) * 24) + 1;
    WHILE (v_from_time <= v_end_from_time AND v_continue) LOOP
      v_to_time :=  v_from_time + 1/24 - 1/86400;
      EXECUTE IMMEDIATE v_stmt INTO v_comp_value USING p_entity_fk_key,
                                                       p_entity_type,
                                                       p_component_value,
                                                       v_from_time,
                                                       v_to_time;



      -- TO DO: Need to check whether that is the last reading and the
      -- end time of the last record is less than the from time
      --- If so, need to stop there.
      IF ( v_comp_value IS NOT NULL) THEN
        v_comp_values(i) :=  v_comp_value;
        i := i + 1;
        v_from_time := v_from_time + v_one_hour;
      ELSE
        -- The status is not available for this hour
        v_continue := FALSE;
      END IF;
      END LOOP;

  END IF;

  RETURN v_comp_values;

  EXCEPTION
    WHEN OTHERS THEN
      v_err_msg := SQLERRM;
      v_err_code := SQLCODE;

    INSERT INTO mth_runtime_err
      ( MODULE, error_code, error_msg, timestamp) VALUES
       ('MTH_SUSTAIN_ASPECT_PKG.getCompValuesForCustom',
        v_err_code, v_err_msg, SYSDATE);

  RETURN v_comp_values;

END getCompValuesForCustom;


/* ****************************************************************************
* Function	:calculate_virtual_component                                  *
* Description  	:Calculate the virtual component for the specified time       *
*                  in every hour                                              *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_component_type - component type  could be:         *
*                         MTH_METER_BASED_COMPONENT	Constant CONST        *
*                         MTH_METER_BASED_COMPONENT	Meter	METER         *
*                         MTH_PWR_COMPONENT	Entity Power Rating	EPR   *
*                         MTH_PWR_COMPONENT	Equipment Status	ES    *
*                         MTH_PWR_COMPONENT	Shift Availibility	SFT   *
*                         MTH_CUST_COMPONENT	Custom Component	CC    *
*                        p_component_value - Component value depends on type  *
*                                                1) Meter Based: MB           *
*                                                2) Power rating Based: RPB   *
*                                                3) Custom : CB               *
*                        p_entity_type - Associated entity type for calcuation*
*                        p_entity_fk_key - Assocuated entity fk key           *
*                        p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - the ending point of time to              *
*                                      calculate the virtual meter            *
* Return Value          :List of values of the components for each hour       *
*                        within the from time and to time. The type of the    *
*                        return value is DBMS_SQL.NUMBER_TABLE                *
**************************************************************************** */

FUNCTION calculate_virtual_component(p_component_type IN VARCHAR2,
                                     p_component_value IN VARCHAR2,
                                     p_entity_type IN VARCHAR2,
                                     p_entity_fk_key IN VARCHAR2,
                                     p_from_time IN DATE,
                                     p_to_time IN DATE)
           RETURN DBMS_SQL.NUMBER_TABLE

IS
  v_comp_values DBMS_SQL.NUMBER_TABLE;
  v_num_elements NUMBER;
  v_from_time DATE := p_from_time;
  v_end_from_time DATE := p_to_time - 1/24;
  v_one_hour NUMBER := 1/24;
  i NUMBER := 1;
  v_value NUMBER;
BEGIN
  v_num_elements :=  Trunc((p_to_time - p_from_time) * 24) + 1;
 -- v_comp_values :=  DBMS_SQL.NUMBER_TABLE(v_num_elements);
  IF (p_component_type = 'CONST') THEN
    -- 1. Support CONST type component
    v_value := To_Number(p_component_value);
    WHILE (v_from_time <= v_end_from_time) LOOP
      v_comp_values(i) := v_value;
      i := i + 1;
      v_from_time := v_from_time + v_one_hour;
    END LOOP;
  ELSIF (p_component_type = 'EPR') THEN
    -- 2. Support Entity Power Rating type component
    v_value := getEquipPowerRating(p_entity_fk_key, p_entity_type);
    WHILE (v_from_time <= v_end_from_time) LOOP
      v_comp_values(i) := v_value;
      i := i + 1;
      v_from_time := v_from_time + v_one_hour;
    END LOOP;
  ELSIF (p_component_type = 'SFT') THEN
    -- 3. Support Shift Availibility type componen
    v_comp_values := getCompValuesForSFT(p_entity_fk_key,
                                         p_entity_type,
                                         p_component_value,
                                         p_from_time,
                                         p_to_time);
  ELSIF (p_component_type = 'ES') THEN
    -- 4. Support Equipment Status type componen
    v_comp_values := getCompValuesForEquipStatus(p_entity_fk_key,
                                                 p_entity_type,
                                                 p_component_value,
                                                 p_from_time,
                                                 p_to_time);

  ELSIF (p_component_type = 'METER') THEN
    -- 5. Support Meter type componen
    -- getCompValuesForMeter

    v_comp_values := getCompValuesForMeter(To_Number(p_component_value),
                                           p_from_time,
                                           p_to_time);
  ELSIF (p_component_type = 'CC') THEN
    -- 6. Support Custom Component type componen
    v_comp_values := getCompValuesForCustom(p_entity_fk_key,
                                            p_entity_type,
                                            p_component_value,
                                            p_from_time,
                                            p_to_time);

  END IF;


  RETURN v_comp_values;
END calculate_virtual_component;


/* ****************************************************************************
* Procedure		:cal_virtual_meter_component                          *
* Description 	 	:Calculate all the virtual meters that is power rating*
*                  based hourly if the components are available and           *
*                  load the data into meter readings table MTH_METER_READINGS *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_meter_pk_key - meter pk key                        *
*                        p_virtual_meter_type - virtual meter type. It can be *
*                                                1) Meter Based: MB           *
*                                                2) Powering rating Based: RPB*
*                                                3) Custom : CB               *
*                        p_virtual_meter_formula - Formula to calculate meter *
*                        p_entity_type - Associated entity type for calcuation*
*                        p_entity_fk_key - Assocuated entity fk key           *
*                        p_from_time - the starting point of time to          *
*                                      calculate the virtual meter.           *
*                        p_to_time - the ending point of time to              *
*                                      calculate the virtual meter            *
* Return Value          :None                                                 *
**************************************************************************** */

FUNCTION cal_virtual_meter_component(p_meter_pk_key IN NUMBER,
                                     p_virtual_meter_type IN VARCHAR2,
                                     p_virtual_meter_formula IN VARCHAR2,
                                     p_entity_type IN VARCHAR2,
                                     p_entity_fk_key IN VARCHAR2,
                                     p_from_time IN DATE,
                                     p_to_time IN DATE)
           RETURN component_lookup_type
IS
  CURSOR c_getMeterComponents(p_meter_fk_key IN NUMBER) IS
    SELECT virtual_meter_component_pk_key as component_pk_key,
           component_type, component_value
    FROM MTH_VIRTUAL_METER_COMPONENTS
    WHERE  meter_fk_key = p_meter_fk_key;

  v_one_comp component_record;
  v_compoents component_lookup_type;
  i NUMBER := 1;

BEGIN
   -- 1. Get all the virtual component components
   FOR r_comp IN  c_getMeterComponents(p_meter_pk_key) LOOP
     v_one_comp.component_pk_key := r_comp.component_pk_key;
     v_one_comp.component_type := r_comp.component_type;
     v_one_comp.component_value := r_comp.component_value;
     v_one_comp.comp_time_series_values :=
                      calculate_virtual_component(r_comp.component_type,
                                                  r_comp.component_value,
                                                  p_entity_type,
                                                  p_entity_fk_key,
                                                  p_from_time,
                                                  p_to_time);

     v_compoents(i) := v_one_comp;
     i := i + 1;
   END LOOP;

   RETURN v_compoents;
END cal_virtual_meter_component;



/* ****************************************************************************
* Function	:calVirtualMeter                                              *
* Description  	:Calculate the virtual meter using the formula with all the   *
*                  components available for pne hour                          *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_formula - Virtual meter formula                    *
*                        p_components - All the components with all their     *
*                           values for each component                         *
*                        p_idx - The index in p_components that indicates     *
*                           the set of components to be calculated.           *
* Return Value          :Usage value calcuated using the formula              *
**************************************************************************** */

FUNCTION calVirtualMeter(p_cursor IN NUMBER, -- p_formula IN VARCHAR2,
                         p_components IN component_lookup_type,
                         p_idx IN NUMBER) RETURN NUMBER
IS
  v_usageValue NUMBER := 0;
  v_stmt VARCHAR2(4000);
  c NUMBER;
  dummy NUMBER;
BEGIN


  -- 1. Construct the dynamic sql statement to calculate virtual meter formula
  DBMS_SQL.DEFINE_COLUMN(p_cursor, 1, v_usageValue);

  FOR i IN 1..p_components.Count LOOP
    DBMS_SQL.BIND_VARIABLE(p_cursor, ':' || i,
                           p_components(i).comp_time_series_values(p_idx));
  END LOOP;

  dummy := DBMS_SQL.EXECUTE(p_cursor);
  IF DBMS_SQL.FETCH_ROWS(p_cursor)>0 THEN
         -- get column values of the row
      --     Dbms_Output.put_line( ' DBMS_SQL.FETCH_ROWS(c)>0 : ' );
         DBMS_SQL.COLUMN_VALUE(p_cursor, 1, v_usageValue);
  END IF;

  --DBMS_SQL.CLOSE_CURSOR(c);
  RETURN  v_usageValue;
   /*
  EXCEPTION WHEN OTHERS THEN
    IF DBMS_SQL.IS_OPEN(c) THEN
      DBMS_SQL.CLOSE_CURSOR(c);
    END IF;

   RETURN v_usageValue;
       */

END calVirtualMeter;


/* ****************************************************************************
* Procedure   :cal_save_virtual_meter                                         *
* Description  	  :Calculate  virtual meter using the component values   and  *
*                  load the data into meter readings table MTH_METER_READINGS *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_meter_pk_key - meter pk key                        *
*                        p_formula - Virtual meter formula to calculate meter *
*                        p_components - All the components with all their     *
*                           values for each component                         *
*                        p_virtual_meter_formula - Formula to calculate meter *
*                        p_entity_type - Associated entity type for calcuation*
*                        p_entity_fk_key - Assocuated entity fk key           *
*                        p_start_time - the starting point of time to         *
*                                      calculate the virtual meter.           *
*                        p_end_time - the ending point of time to             *
*                                      calculate the virtual meter            *
*                        p_bulk_commit_size - max commit size                 *
*                        p_num_trans  - current number of insert/update       *
* Return Value          :None                                                 *
**************************************************************************** */
PROCEDURE   cal_save_virtual_meter(p_meter_fk_key IN NUMBER,
                                   p_formula IN VARCHAR2,
                                   p_components IN component_lookup_type,
                                   p_start_time IN DATE,
                                   p_end_time IN DATE)

IS
  v_numElements NUMBER := NULL;
  v_usage_value NUMBER;
  v_hour_start_time DATE := p_start_time;
  v_hour_end_time DATE;
  v_system_id NUMBER := -99999;
  v_stmt VARCHAR2(4000);
  c NUMBER;
  v_err_msg VARCHAR2(4000);
  v_err_code NUMBER;
BEGIN
  -- 1. Find out the number of entries to be inserted, which should be the
  --    the least one among them
  FOR i IN 1..p_components.Count LOOP
    IF (v_numElements IS NULL OR
        p_components(i).comp_time_series_values.Count < v_numElements) THEN
      v_numElements := p_components(i).comp_time_series_values.Count;

    END IF;
  END LOOP;

  IF (v_numElements IS NULL) THEN
    v_numElements := 0;
  END IF;

  -- 2. Construct the sql statement
  v_stmt := 'SELECT ' || p_formula || ' FROM (SELECT ';
  FOR i IN 1..p_components.Count LOOP
    IF (i > 1) THEN
      v_stmt := v_stmt || ' ,';
    END IF;
    v_stmt := v_stmt || ':' || i || ' AS ID#' ||
                       p_components(i).component_pk_key;
  END LOOP;
  v_stmt := v_stmt || ' FROM DUAL)';

  c := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(c, v_stmt, DBMS_SQL.NATIVE);

  -- 2. Calculate the virtual meter for each hour available
  FOR i IN 1..v_numElements LOOP
    v_usage_value := calVirtualMeter(c, p_components, i);
    v_hour_end_time := v_hour_start_time + 1/24 - 1/86400;
    INSERT INTO mth_meter_readings
                  (meter_fk_key, from_time, to_time, usage_value,
                   creation_date, last_update_date, creation_system_id,
                   last_update_system_id, created_by, last_updated_by,
                   last_update_login, processed_flag) VALUES
                  (p_meter_fk_key, v_hour_start_time, v_hour_end_time,
                   v_usage_value, SYSDATE, SYSDATE, v_system_id,
                   v_system_id, v_system_id, v_system_id, v_system_id, 'N');
    v_hour_start_time := v_hour_start_time + 1/24;


  END LOOP;
    DBMS_SQL.CLOSE_CURSOR(c);

  EXCEPTION
    WHEN OTHERS THEN
    --  v_err_code := 'Failed to calculate the virtual meter between ' ||
    --        To_Char(p_start_time, 'YYYY-MM-DD HH24:MI:SS') || ' and '  ||
    --        To_Char(p_end_time, 'YYYY-MM-DD HH24:MI:SS') ||
    --        '. The error code is ' || SQLCODE ||
    --        ' and the error message is ' || SQLERRM || '.';
      v_err_code := SQLCODE;
      v_err_msg :=  SQLERRM;
    INSERT INTO mth_runtime_err
      ( MODULE, error_code, error_msg, timestamp) VALUES
       ('MTH_SUSTAIN_ASPECT_PKG.cal_save_virtual_meter',
        v_err_code, v_err_msg, SYSDATE);

       DBMS_SQL.CLOSE_CURSOR(c);


END cal_save_virtual_meter;




/* ****************************************************************************
* Procedure		:ADD_VRT_TO_METER_READINGS                            *
* Description 	  :Calculate all the virtual meters if possible hourly and    *
* load the data into meter readings table MTH_METER_READINGS                  *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :None                                                 *
* Return Value          :None                                                 *
**************************************************************************** */

PROCEDURE ADD_VRT_MTS_TO_METER_READINGS (p_virtual_meter_start_date IN DATE
                                             DEFAULT VIRTUAL_METER_START_DATE)
IS
  -- Get all the virtual meters order by precedence
  CURSOR c_getVirtualMeters  IS
    SELECT M.METER_PK_KEY, M.VIRTUAL_METER_TYPE, M.VIRTUAL_METER_FORMULA,
           M.PRECEDENCE, E.ENTITY_FK_KEY, UPPER(E.ENTITY_TYPE) ENTITY_TYPE,
           R.END_TIME
    FROM MTH_METERS M, MTH_METER_ENTITIES  E,
         (SELECT meter_fk_key, Max(to_time) end_time
          FROM   MTH_METER_READINGS
          GROUP BY meter_fk_key) R
    WHERE M.METER_TYPE = 'VRT' AND M.METER_PK_KEY = E.METER_FK_KEY (+) AND
          M.METER_PK_KEY = r.meter_fk_key (+)
    ORDER BY M.PRECEDENCE;

  v_start_time DATE;
  v_end_time DATE;
  v_compoents component_lookup_type;
  v_num_trans NUMBER := 0;

BEGIN
  -- 1. Get all the virtual meters order by their precedence to
  --    to calculate the virtual meters
  v_end_time :=  trunc(SYSDATE, 'HH24');
  FOR v_meter IN c_getVirtualMeters LOOP
    -- 1.1 Calculate the virtual meter only if it has passed at least
    --     one hour from last reading
    --v_start_time := Nvl(v_meter.END_TIME, p_virtual_meter_start_date) + 1/2600;
    v_start_time := Nvl(v_meter.END_TIME, p_virtual_meter_start_date) + 1/23600;
    v_start_time := Trunc(v_start_time, 'HH24');
    IF (v_meter.END_TIME IS NOT NULL AND v_start_time <= v_meter.END_TIME) THEN
      v_start_time := v_start_time + 1/24;
    END IF;
    IF (v_end_time > trunc(v_start_time + 1/24, 'HH24')) THEN

      v_compoents :=  cal_virtual_meter_component(v_meter.METER_PK_KEY,
                                                  v_meter.VIRTUAL_METER_TYPE,
                                                  v_meter.VIRTUAL_METER_FORMULA,
                                                  v_meter.ENTITY_TYPE,
                                                  v_meter.ENTITY_FK_KEY,
                                                  v_start_time,
                                                  v_end_time);


    END IF;

    -- 1.2 Calculate and save the meter values
    cal_save_virtual_meter(v_meter.METER_PK_KEY,
                           v_meter.VIRTUAL_METER_FORMULA,
                           v_compoents,
                           v_start_time,
                           v_end_time);
  END LOOP;

END ADD_VRT_MTS_TO_METER_READINGS;

PROCEDURE init_hour_reading_table
AS

BEGIN
  p_reading := MeterReadingTable(NULL,NULL,NULL,NULL,NULL);
END init_hour_reading_table;

PROCEDURE init_shift_break_table
AS

BEGIN
  p_shift := EntityShiftTable(NULL,NULL,NULL,NULL,NULL,NULL,NULL);
END init_shift_break_table;

FUNCTION break_hours RETURN MeterReadingTable
AS
   CURSOR cur_meter
   IS
      SELECT a.meter_fk_key, a.from_time, a.to_time, a.usage_value, b.meter_code
      FROM mth_meter_readings a, mth_meters b
      WHERE a.meter_fk_key = b.meter_pk_key
      AND a.processed_flag = 'N'
      ORDER BY a.meter_fk_key, a.from_time;

   l_hour_count NUMBER;
   i NUMBER := 1;

BEGIN
   init_hour_reading_table;
   FOR reading_rec in cur_meter LOOP
      --SELECT round ((reading_rec.to_time - reading_rec.from_time) *24)
      SELECT (Trunc(reading_rec.to_time, 'hh24') - Trunc(reading_rec.from_time, 'hh24')) *24
      INTO l_hour_count
      FROM DUAL;

     FOR idx in 0..l_hour_count LOOP
         p_reading.EXTEND(1);
         BEGIN
            SELECT reading_rec.meter_fk_key,
                 h.hour_pk_key,
                 (CASE idx
                     WHEN 0 THEN reading_rec.from_time
                       ELSE h.from_time
                     END) reading_from_time,
                 (CASE idx
                       WHEN l_hour_count THEN reading_rec.to_time
                       ELSE h.to_time
                     END) reading_to_time,
                  (((CASE idx
                       WHEN l_hour_count THEN reading_rec.to_time
                       ELSE h.to_time
                     END) -
                   (CASE idx
                       WHEN 0 THEN reading_rec.from_time
                        ELSE h.from_time
                     END))*24*60*60+1)
                  /((reading_rec.to_time - reading_rec.from_time)*24*60*60+1)
                  *reading_rec.usage_value
            INTO p_reading(i).meter_fk_key, p_reading(i).hour_pk_key, p_reading(i).from_time, p_reading(i).to_time, p_reading(i).usage_value
            FROM mth_hour_d h
            WHERE Trunc(reading_rec.from_time, 'hh24') + idx/24 = h.from_time;
            i := i+1;

        EXCEPTION
            WHEN No_Data_Found THEN
                IF SQL%NOTFOUND THEN
                   INSERT INTO mth_meter_readings_err
                      (meter_readings_err_pk_key, meter_code, from_time, to_time, usage_value, tag_code, reprocess_ready_yn,
                       err_code, creation_date, last_update_date)
                   VALUES (MTH_METER_READINGS_ERR_S.NEXTVAL, reading_rec.meter_code, reading_rec.from_time, reading_rec.to_time,
                           reading_rec.usage_value, NULL, 'N', 'HRNA', SYSDATE, SYSDATE);
                END IF;
                EXIT;
            WHEN OTHERS THEN
              ROLLBACK;
              raise_application_error(-20000,'Error occurs when inserting error table:'||SQLCODE||' -ERROR- '||SQLERRM);
        END;

     END LOOP;

     BEGIN
        UPDATE mth_meter_readings SET processed_flag = 'Y'
        WHERE meter_fk_key = reading_rec.meter_fk_key
        AND from_time = reading_rec.from_time;
     EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            raise_application_error(-20001,'Error occurs when update process flag:'||SQLCODE||' -ERROR- '||SQLERRM);
     END;
   END LOOP;

   RETURN p_reading;

END break_hours;

PROCEDURE break_reading
AS

  j NUMBER := 1;
  l NUMBER := 1;
  l_duration NUMBER;
  l_entity_fk_key mth_meter_entities.entity_fk_key%TYPE;
  l_shift_rec_to_time mth_meter_readings.to_time%TYPE;
  l_new_from_time mth_meter_readings.from_time%TYPE;
  l_to_time mth_meter_readings.to_time%TYPE;


  CURSOR cur_entities (l_meter_fk_key NUMBER)
  IS
     SELECT meter_fk_key, entity_fk_key
     FROM mth_meter_entities
     WHERE meter_fk_key = l_meter_fk_key
     AND status = 'ACTIVE';

  CURSOR cur_shifts (l_meter_fk_key NUMBER, l_entity_fk_key NUMBER, l_from_time DATE, l_to_time DATE)
  IS
     SELECT l_meter_fk_key, l_entity_fk_key, shift_workday_fk_key,
            Greatest(from_date, l_from_time) from_time,
            least(l_to_time, To_Date) to_time
     FROM mth_equipment_shifts_d
     WHERE equipment_fk_key = l_entity_fk_key
     AND ( from_date <= l_from_time AND to_date >= l_from_time OR
           from_date <= l_to_time   AND to_date >= l_to_time OR
           from_date >= l_from_time AND from_date <= l_to_time ) AND
           from_date IS NOT NULL AND To_Date IS NOT NULL AND
           from_date <> To_Date;


  CURSOR cur_catch_all_shifts (l_meter_fk_key NUMBER, l_entity_fk_key NUMBER, l_from_time DATE, l_to_time DATE)
  IS
     SELECT l_meter_fk_key, l_entity_fk_key, shift_workday_fk_key,
            l_from_time from_time,
            l_to_time to_time
     FROM mth_equipment_shifts_d
     WHERE equipment_fk_key = l_entity_fk_key
     AND Trunc(availability_date) = Trunc(l_from_time)
     AND Nvl(from_date, Trunc(availability_date)) = Nvl(To_Date, Trunc(availability_date));

  -- Find catch all shifts from workday shifts
  CURSOR cur_workday_shifts (l_meter_fk_key NUMBER, l_entity_fk_key NUMBER, l_from_time DATE, l_to_time DATE)
  IS
     SELECT l_meter_fk_key, l_entity_fk_key, a.shift_workday_pk_key,
            l_from_time from_time,
            l_to_time to_time
     FROM mth_workday_shifts_d a,
         (SELECT plant_fk_key site_id, entity_pk_key
          FROM mth_equip_entities_mst
          UNION ALL
          SELECT plant_pk_key site_id, plant_pk_key entity_pk_key
          FROM mth_plants_d
          UNION ALL
          SELECT plant_fk_key site_id, resource_pk_key entity_pk_key
          FROM mth_resources_d
          UNION ALL
          SELECT plant_fk_key site_id, equipment_pk_key entity_pk_key
          FROM mth_equipments_d
         ) b
     WHERE a.plant_fk_key = b.site_id
     AND b.entity_pk_key = l_entity_fk_key
     AND a.shift_workday_pk_key NOT IN (
         SELECT DISTINCT shift_workday_fk_key shift_key
         FROM mth_equipment_shifts_d
         WHERE equipment_fk_key = l_entity_fk_key)
     AND Trunc(a.shift_date) = Trunc(l_from_time)
     AND Nvl(a.from_date, Trunc(a.shift_date)) = Nvl(a.To_Date, Trunc(a.shift_date));

     v_new_to_time DATE;

BEGIN

   p_reading := break_hours;
   init_shift_break_table;

   FOR i in p_reading.FIRST..p_reading.LAST LOOP
       FOR entity_rec IN cur_entities (p_reading(i).meter_fk_key) LOOP
          l_shift_rec_to_time := p_reading(i).from_time;
          l_new_from_time := p_reading(i).from_time;
          IF p_reading(i).from_time = p_reading(i).to_time THEN
             l_shift_rec_to_time := p_reading(i).from_time - 1/(24*60*60);
          END IF;
          l_to_time := p_reading(i).to_time;
          l_duration := REPLACE( Round((p_reading(i).to_time - p_reading(i).from_time)*24*60*60), 0, 1);

          l_entity_fk_key := entity_rec.entity_fk_key;
          WHILE l_to_time > l_shift_rec_to_time
          LOOP
                BEGIN
                    OPEN cur_shifts (p_reading(i).meter_fk_key, l_entity_fk_key, l_new_from_time, l_to_time);
                    FETCH cur_shifts INTO p_shift(j).meter_fk_key, p_shift(j).entity_fk_key,
                                          p_shift(j).shift_workday_fk_key, p_shift(j).from_time, p_shift(j).to_time;

                    IF cur_shifts%NOTFOUND OR l_new_from_time < p_shift(j).from_time THEN
                       v_new_to_time :=  CASE WHEN cur_shifts%NOTFOUND
                                                   THEN l_to_time
                                                   ELSE p_shift(j).from_time - 1/86400
                                              END;
                       OPEN cur_catch_all_shifts (p_reading(i).meter_fk_key,
                                                  l_entity_fk_key,
                                                  l_new_from_time,
                                                  v_new_to_time);
                       FETCH cur_catch_all_shifts INTO p_shift(j).meter_fk_key, p_shift(j).entity_fk_key,
                                                       p_shift(j).shift_workday_fk_key,
                                                       p_shift(j).from_time, p_shift(j).to_time;

                       IF cur_catch_all_shifts%NOTFOUND THEN
                          OPEN cur_workday_shifts (p_reading(i).meter_fk_key,
                                                   l_entity_fk_key,
                                                   l_new_from_time,
                                                   v_new_to_time);
                          FETCH cur_workday_shifts INTO p_shift(j).meter_fk_key, p_shift(j).entity_fk_key,
                                                        p_shift(j).shift_workday_fk_key,
                                                        p_shift(j).from_time, p_shift(j).to_time;

                          IF cur_workday_shifts%NOTFOUND THEN
                             p_shift(j).meter_fk_key := p_reading(i).meter_fk_key;
                             p_shift(j).entity_fk_key := l_entity_fk_key;
                             p_shift(j).shift_workday_fk_key := -99999;
                             p_shift(j).from_time := l_new_from_time;
                             p_shift(j).to_time := v_new_to_time;
                          END IF;
                          CLOSE cur_workday_shifts;
                       END IF;
                       CLOSE cur_catch_all_shifts;
                    END IF;
                 EXCEPTION
                    WHEN OTHERS THEN
                        raise_application_error(-20002,'Unknown Exception to allocate meter reading');
                 END;
                 CLOSE cur_shifts;
                 p_shift(j).hour_fk_key := p_reading(i).hour_pk_key;
                 p_shift(j).usage_value := Round(REPLACE(Round((p_shift(j).to_time - p_shift(j).from_time)*24*60*60),0,1)/l_duration*p_reading(i).usage_value,2);
                 l_shift_rec_to_time := p_shift(j).to_time;
                 l_new_from_time := p_shift(j).to_time + 1/(24*60*60);
                 j := j + 1;
                 p_shift.extend(1);
            END LOOP;
       END LOOP;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20003,'Error occurs when break shifts:'||SQLCODE||' -ERROR- '||SQLERRM);

END break_reading;


PROCEDURE load_sustain_emission_to_hour
IS

BEGIN

   INSERT INTO MTH_ENTITY_SUST_HR_EMISSIONS
             (esa_hr_fk_key, emission_code, emission_name, emission_quantity,
              emission_uom)
       SELECT Max(esa_pk_key) AS esa_hr_fk_key,
              e.emission_code,
              e.emission_name,
              sum(e.emission_quantity) AS emission_quantity,
              e.emission_uom
       FROM mth_entity_sustain_aspect a, mth_hour_d h,
            MTH_ENTITY_SUST_EMISSIONS e
       WHERE a.hour_fk_key = h.hour_pk_key AND e.esa_fk_key = a.esa_pk_key
       GROUP BY a.plant_fk_key, a.entity_fk_key, a.entity_type,
              a.sustain_aspect, a.usage_category, a.meter_fk_key,
              a.meter_category, h.from_time, h.to_time, a.hour_fk_key,
              a.shift_workday_fk_key, a.entity_name, a.entity_type_name,
              a.sustain_aspect_name, a.usage_category_name, a.meter_type,
              a.meter_type_name, a.meter_category_name,
              a.simulation_name, a.usage_uom, a.currency,
              e.emission_code, e.emission_name, e.emission_uom
       order BY a.entity_fk_key, a.entity_type, a.sustain_aspect,
              a.usage_category, a.meter_fk_key, a.meter_category,
              h.from_time, h.to_time, a.hour_fk_key,a.shift_workday_fk_key,
              a.entity_name, a.entity_type_name,
              a.sustain_aspect_name, a.usage_category_name, a.meter_type,
              a.meter_type_name, a.meter_category_name,
              a.simulation_name, a.usage_uom, a.currency,
              e.emission_code, e.emission_name, e.emission_uom;

EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20005,
          'Error occurs when inserting MTH_ENTITY_SUST_HR_EMISSIONS table:'
          ||SQLCODE||' -ERROR- '||SQLERRM);
END load_sustain_emission_to_hour;


PROCEDURE load_sustain_aspect_to_hour
IS

BEGIN

   DELETE FROM MTH_ENTITY_SUST_HR_EMISSIONS;
   DELETE FROM mth_entity_sustain_aspect_hour;

   INSERT INTO mth_entity_sustain_aspect_hour
             (esa_hr_pk_key, plant_fk_key, entity_fk_key, entity_type,
              sustain_aspect_fk_key,
              sustain_aspect, usage_category, meter_fk_key, meter_category,
              from_time, to_time, hour_fk_key, shift_workday_fk_key,
              entity_name, entity_type_name,
              sustain_aspect_name, usage_category_name, meter_type,
              meter_type_name, meter_category_name,
              simulation_name, usage_value, usage_uom, usage_cost,
              currency, creation_date, last_update_date)
       SELECT max(esa_pk_key) AS esa_hr_pk_key,
              a.plant_fk_key, a.entity_fk_key, a.entity_type,
              a.sustain_aspect_fk_key,
              a.sustain_aspect, a.usage_category, a.meter_fk_key,
              a.meter_category, h.from_time, h.to_time, a.hour_fk_key,
              a.shift_workday_fk_key, a.entity_name, a.entity_type_name,
              a.sustain_aspect_name, a.usage_category_name, a.meter_type,
              a.meter_type_name, a.meter_category_name,
              a.simulation_name, Sum(a.usage_value) AS usage_value,
              a.usage_uom, Sum(a.usage_cost) AS usage_cost,
              a.currency, SYSDATE AS creation_date,
              SYSDATE AS last_update_date
       FROM mth_entity_sustain_aspect a, mth_hour_d h
       WHERE a.hour_fk_key = h.hour_pk_key
       GROUP BY a.plant_fk_key, a.entity_fk_key, a.entity_type,
              a.sustain_aspect, a.sustain_aspect_fk_key, a.usage_category, a.meter_fk_key,
              a.meter_category, h.from_time, h.to_time, a.hour_fk_key,
              a.shift_workday_fk_key, a.entity_name, a.entity_type_name,
              a.sustain_aspect_name, a.usage_category_name, a.meter_type,
              a.meter_type_name, a.meter_category_name,
              a.simulation_name, a.usage_uom, a.currency
       order BY a.entity_fk_key, a.entity_type, a.sustain_aspect,
              a.sustain_aspect_fk_key,
              a.usage_category, a.meter_fk_key, a.meter_category,
              h.from_time, h.to_time, a.hour_fk_key,a.shift_workday_fk_key,
              a.entity_name, a.entity_type_name,
              a.sustain_aspect_name, a.usage_category_name, a.meter_type,
              a.meter_type_name, a.meter_category_name,
              a.simulation_name, a.usage_uom, a.currency;

  load_sustain_emission_to_hour;

EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20005,
          'Error occurs when inserting MTH_ENTITY_SUSTAIN_ASPECT_HOUR table:'
          ||SQLCODE||' -ERROR- '||SQLERRM);
END load_sustain_aspect_to_hour;



/* ****************************************************************************
* Procedure   :load_data_to_sustain_emissions                                 *
* Description :Load data into the child table MTH_ENTITY_SUST_EMISSIONS       *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :None                                                 *
* Return Value          :None                                                 *
**************************************************************************** */

PROCEDURE load_data_to_sustain_emissions
AS

l_start_time DATE;
l_end_time DATE;
l_count NUMBER;

BEGIN

   FOR i IN p_shift.FIRST..p_shift.LAST LOOP
       INSERT INTO MTH_ENTITY_SUST_EMISSIONS
             (esa_fk_key, emission_code, emission_name, emission_quantity,
              emission_uom)
      SELECT p_shift(i).esa_pk_key,
              y.emission_code,
              (SELECT meaning FROM fnd_lookup_values_vl
               WHERE lookup_type = 'MTH_SUSTAIN_EMISSION'
               AND lookup_code = y.emission_code) emission_name,
               p_shift(i).usage_value *
                  y.average_emission_factor AS emission_quantity,
              (SELECT emission_uom FROM mth_sustain_emissions
               WHERE sustain_aspect_fk_key = w.sustain_aspect_pk_key
               AND emission_code = y.emission_code) emission_uom
          FROM MTH_METER_ENTITIES x, mth_meters x1,
               (SELECT m.plant_fk_key, m.effective_date, m.expiration_date, m.sustain_aspect_fk_key,
                       m.average_planned_cost, n.emission_code, Nvl(n.average_emission_factor,0) average_emission_factor
                FROM MTH_SITE_SUSTAINABILITIES m,
                     (SELECT a.site_sustain_pk_key, c.sustain_emission_fk_key, d.emission_code,
                             sum(b.planned_usage_percentage/100 * Nvl(c.emission_factor,0)) average_emission_factor
                      FROM MTH_SITE_SUSTAINABILITIES a, MTH_SITE_SUSTAIN_SOURCES b,
                           MTH_SOURCE_EMISSION_FACTORS c, MTH_SUSTAIN_EMISSIONS d
                      WHERE a.site_sustain_pk_key = b.site_sustain_fk_key
                      AND b.site_sustain_source_pk_key = c.site_sustain_source_fk_key
                      AND d.sustain_emission_pk_key = c.sustain_emission_fk_key
                      AND a.sustain_aspect_fk_key = d.sustain_aspect_fk_key
                      AND d.status = 'ACTIVE'
                      AND  p_shift(i).to_time BETWEEN a.effective_date AND Nvl(a.expiration_date, SYSDATE)
                      GROUP by a.site_sustain_pk_key, c.sustain_emission_fk_key, d.emission_code
                     ) n
                WHERE m.site_sustain_pk_key = n.site_sustain_pk_key
                AND  p_shift(i).to_time BETWEEN m.effective_date AND Nvl(m.expiration_date, SYSDATE)
               ) y,
               (SELECT f.*, g.meaning entity_type_name
                FROM mth_all_entities_v f, fnd_lookup_values_vl g
                WHERE Upper(f.entity_type) = g.lookup_code
                AND (g.lookup_type = 'MTH_USER_DEFINED_ENTITIES' OR
                     g.lookup_type = 'MTH_OTHER_ENTITY_TYPE')
               ) z,
               (SELECT f.sustain_aspect_pk_key, f.sustain_aspect_code,
                       f.usage_uom, g.meaning
                FROM mth_sustain_aspects f, fnd_lookup_values_vl g
                WHERE f.sustain_aspect_code = g.lookup_code
                AND g.lookup_type = 'MTH_SUSTAIN_ASPECT'
               ) w
          WHERE x.STATUS = 'ACTIVE'
          AND x.meter_fk_key = x1.meter_pk_key
          AND x.entity_fk_key = z.entity_pk_key
          AND x.entity_type = Upper(z.entity_type)
          AND y.plant_fk_key = z.site_id
          AND w.sustain_aspect_pk_key = y.sustain_aspect_fk_key
          AND w.sustain_aspect_pk_key = x1.sustain_aspect_fk_key
          AND x.meter_fk_key = p_shift(i).meter_fk_key
          AND x.entity_fk_key = p_shift(i).entity_fk_key;
END LOOP;
EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20004,
        'Error occurs when inserting data into MTH_ENTITY_SUST_EMISSIONS table:'
         || SQLCODE||' -ERROR- '||SQLERRM);

END load_data_to_sustain_emissions;




PROCEDURE load_reading_to_sustain_aspect
AS

l_start_time DATE;
l_end_time DATE;
l_count NUMBER;

BEGIN
   init_hour_reading_table;
   init_shift_break_table;
   break_reading;

   -- Fill the esa_pk_key
   FOR i IN p_shift.FIRST..p_shift.LAST LOOP
     SELECT  MTH_ENTITY_SUSTAIN_ASPECT_S.NEXTVAL
     INTO    p_shift(i).esa_pk_key
     FROM    dual;
   END LOOP;


   FOR i IN p_shift.FIRST..p_shift.LAST LOOP
       INSERT INTO mth_entity_sustain_aspect
             (esa_pk_key, plant_fk_key, entity_fk_key, entity_type,
              sustain_aspect_fk_key,
              sustain_aspect, usage_category, meter_fk_key, meter_category,
              from_time, to_time, hour_fk_key, shift_workday_fk_key,
              entity_name, entity_type_name,
              sustain_aspect_name, usage_category_name, meter_type,
              meter_type_name, meter_category_name,
              simulation_name, usage_value, usage_uom, usage_cost,
               currency, creation_date, last_update_date)
      SELECT  p_shift(i).esa_pk_key, y.plant_fk_key, x.entity_fk_key,
              z.entity_type, w.sustain_aspect_pk_key, w.sustain_aspect_code,
              Nvl(x.usage_category_code, -99999), x.meter_fk_key,
              Nvl(x.meter_category_code, -99999),
              p_shift(i).from_time, p_shift(i).to_time,
              p_shift(i).hour_fk_key, p_shift(i).shift_workday_fk_key,
              z.entity_name, z.entity_type_name,
              w.meaning, (SELECT meaning FROM fnd_lookup_values_vl
                          WHERE lookup_type = 'MTH_ENERGY_USAGE_CATEGORIES'
                          AND lookup_code = x.usage_category_code) usage_category_name,
              x1.meter_type, (SELECT meaning FROM fnd_lookup_values_vl
                              WHERE lookup_type = 'MTH_METER_TYPE'
                              AND lookup_code = x1.meter_type) meter_type_name,
              (SELECT meaning FROM fnd_lookup_values_vl
               WHERE lookup_type = 'MTH_METER_CATEGORY'
               AND lookup_code = x.meter_category_code) meter_category_name,
              (SELECT meaning FROM fnd_lookup_values_vl
               WHERE lookup_type = 'MTH_SIMULATION_NAME'
               AND lookup_code = x.simulation_name_code) simulation_name,
              p_shift(i).usage_value,
              w.usage_uom,
              p_shift(i).usage_value * y.average_planned_cost,
              (SELECT i.currency_code FROM mth_plants_d i
               WHERE i.plant_pk_key = z.site_id) currency,
              SYSDATE, SYSDATE
          FROM MTH_METER_ENTITIES x, mth_meters x1,
               (SELECT m.plant_fk_key, m.effective_date, m.expiration_date, m.sustain_aspect_fk_key,
                       m.average_planned_cost
                FROM MTH_SITE_SUSTAINABILITIES m
                WHERE  p_shift(i).to_time BETWEEN m.effective_date AND Nvl(m.expiration_date, SYSDATE)
               ) y,
               (SELECT f.*, g.meaning entity_type_name
                FROM mth_all_entities_v f, fnd_lookup_values_vl g
                WHERE Upper(f.entity_type) = g.lookup_code
                AND (g.lookup_type = 'MTH_USER_DEFINED_ENTITIES' OR
                     g.lookup_type = 'MTH_OTHER_ENTITY_TYPE')
               ) z,
               (SELECT f.sustain_aspect_pk_key, f.sustain_aspect_code,
                       f.usage_uom, g.meaning
                FROM mth_sustain_aspects f, fnd_lookup_values_vl g
                WHERE f.sustain_aspect_code = g.lookup_code
                AND g.lookup_type = 'MTH_SUSTAIN_ASPECT'
               ) w
          WHERE x.STATUS = 'ACTIVE'
          AND x.meter_fk_key = x1.meter_pk_key
          AND x.entity_fk_key = z.entity_pk_key
          AND x.entity_type = Upper(z.entity_type)
          AND y.plant_fk_key = z.site_id
          AND w.sustain_aspect_pk_key = y.sustain_aspect_fk_key
          AND w.sustain_aspect_pk_key = x1.sustain_aspect_fk_key
          AND x.meter_fk_key = p_shift(i).meter_fk_key
          AND x.entity_fk_key = p_shift(i).entity_fk_key;
end loop;

   -- Load emission data into MTH_ENTITY_SUST_EMISSIONS child table
   load_data_to_sustain_emissions;

   load_sustain_aspect_to_hour;

EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20004,
        'Error occurs when inserting MTH_ENTITY_SUSTAIN_ASPECT table:'
        ||SQLCODE||' -ERROR- '||SQLERRM);

END load_reading_to_sustain_aspect;



/* ****************************************************************************
* Procedure :truncate_entity_sustain_data                                     *
* Description 	 	:Truncate sustainability aspect tables and set the          *
*                   production performance table to be null.                  *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :None                                                 *
* Return Value          :None                                                 *
**************************************************************************** */
PROCEDURE truncate_entity_sustain_data
IS
BEGIN
  mth_util_pkg.mth_truncate_table('MTH_TAG_METER_READINGS_LATEST');
  mth_util_pkg.mth_truncate_table('MTH_METER_READINGS');
  mth_util_pkg.mth_truncate_table('MTH_METER_READINGS_ERR');
  mth_util_pkg.mth_truncate_table('MTH_ENTITY_SUST_EMISSIONS');
  mth_util_pkg.mth_truncate_table('MTH_ENTITY_SUSTAIN_ASPECT');
  mth_util_pkg.mth_truncate_table('MTH_ENTITY_SUST_HR_EMISSIONS');
  mth_util_pkg.mth_truncate_table('MTH_ENTITY_SUSTAIN_ASPECT_HOUR');
  mth_util_pkg.mth_truncate_table('MTH_EQUIP_PROD_SUSTAIN_F');

END truncate_entity_sustain_data;

PROCEDURE process_entity_sustain_aspect
  (p_err_buff                     out NOCOPY  VARCHAR2,
   p_retcode                      out NOCOPY NUMBER,
   p_process_mode                 IN VARCHAR2 DEFAULT 'INCR',
   p_virtual_meter_start_date_str IN varchar2 )
IS
  v_raw_tab_name VARCHAR2(30) := 'MTH_TAG_METER_READINGS_RAW';
  v_curr_partition NUMBER;
  v_virtual_meter_start_date date;
  v_process_mode VARCHAR2(200);
BEGIN

  v_process_mode := p_process_mode;
  IF (v_process_mode IS NULL OR length(v_process_mode) = 0) THEN
    v_process_mode := 'INCR';
  END IF;

  IF (v_process_mode = 'INIT') THEN
    truncate_entity_sustain_data;
  END IF;

  IF (v_process_mode = 'INCR' OR v_process_mode = 'INIT') THEN

    v_virtual_meter_start_date :=
      NVL(fnd_date.canonical_to_date(p_virtual_meter_start_date_str),trunc(sysdate));


    mth_util_pkg.switch_column_default_value(v_raw_tab_name, v_curr_partition);

    IF (v_curr_partition = 1 OR v_curr_partition = 2) THEN
      LOAD_ACT_METER_RAW_TO_READINGS( v_curr_partition );

      mth_util_pkg.truncate_table_partition (v_raw_tab_name, v_curr_partition);
    END IF;


    ADD_VRT_MTS_TO_METER_READINGS (v_virtual_meter_start_date);

    COMMIT;
    load_reading_to_sustain_aspect;
    COMMIT;

    fnd_file.put_line(FND_FILE.LOG,
    'Processing and populating data into entity sustainability aspect completed successfully');
    p_err_buff :=
    'Processing and populating data into entity sustainability aspect completed successfully';
    p_retcode := 0;
  ELSE
    p_retcode := 1;
    fnd_file.put_line(FND_FILE.LOG,
    'The process mode can only be INIT or INCR for initial and incremental respectively.'
              );
    fnd_file.put_line(FND_FILE.LOG,-20005);
    p_err_buff :=
     'The process mode can only be INIT or INCR for initial and incremental respectively.';
  END IF;

    EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
            p_retcode := 1;
            fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
            fnd_file.put_line(FND_FILE.LOG,sqlcode);
            p_err_buff := substr(sqlerrm,1,240);
            --RAISE;



END process_entity_sustain_aspect;

END MTH_SUSTAIN_ASPECT_PKG;

/
