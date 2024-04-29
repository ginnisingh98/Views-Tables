--------------------------------------------------------
--  DDL for Package MTH_SUSTAIN_ASPECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTH_SUSTAIN_ASPECT_PKG" AUTHID CURRENT_USER AS
/*$Header: mthesats.pls 120.2.12010000.7 2010/02/13 22:58:04 yfeng noship $ */

--  TYPE NUMBER_TABLE IS TABLE OF NUMBER;

  MAX_BULK_COMMIT_SIZE NUMBER := 1000;
  VIRTUAL_METER_START_DATE DATE := trunc(SYSDATE - 100,'HH24') - 1/(3600 * 24);

  TYPE shift_record IS
       RECORD (from_date DATE, To_Date DATE, availability_flag VARCHAR2(1));
  TYPE shift_array_type IS TABLE OF shift_record;


  TYPE status_record IS
       RECORD (from_date DATE, To_Date DATE, run_hours NUMBER,
               down_hours NUMBER, idle_hours NUMBER, off_hours NUMBER);
  TYPE status_array_type IS TABLE OF status_record;

  TYPE meter_reading_record IS
       RECORD (from_date DATE, To_Date DATE, usage_value NUMBER);
  TYPE readings_array_type IS TABLE OF meter_reading_record;


  TYPE component_record IS
       RECORD (component_pk_key NUMBER,
               component_type VARCHAR2(30),
               component_value VARCHAR2(255),
               comp_time_series_values Dbms_Sql.NUMBER_TABLE);
  TYPE component_lookup_type IS TABLE OF component_record
       INDEX BY BINARY_INTEGER;

  TYPE ReadingType IS RECORD (
     meter_fk_key mth.mth_meter_readings.meter_fk_key%type,
     from_time mth.mth_meter_readings.from_time%type,
     to_time mth.mth_meter_readings.to_time%TYPE,
     hour_pk_key mth.mth_hour_d.hour_pk_key%TYPE,
     usage_value mth.mth_meter_readings.usage_value%TYPE
  );

  TYPE EntityShiftType IS RECORD (
     esa_pk_key mth_entity_sustain_aspect.esa_pk_key%TYPE,
     meter_fk_key mth.mth_meter_entities.meter_fk_key%type,
     entity_fk_key mth.mth_meter_entities.entity_fk_key%type,
     from_time mth.mth_meter_readings.from_time%type,
     to_time mth.mth_meter_readings.to_time%TYPE,
     shift_workday_fk_key mth.mth_equipment_shifts_d.shift_workday_fk_key%type,
     hour_fk_key mth.mth_hour_d.hour_pk_key%TYPE,
     usage_value mth.mth_meter_readings.usage_value%TYPE
  );


  TYPE MeterReadingTable IS TABLE OF ReadingType;
  TYPE EntityShiftTable IS TABLE OF EntityShiftType;


/* ****************************************************************************
* Procedure   :LOAD_RAW_TO_METER_READINGS                                     *
* Description  	:TLoad data from tag meter raw data for energy consumption  *
* in MTH_TAG_METER_READINGS_RAW into meter readings table MTH_METER_READINGS  *
**************************************************************************** */

PROCEDURE LOAD_ACT_METER_RAW_TO_READINGS(p_curr_partition IN NUMBER);
PROCEDURE ADD_VRT_MTS_TO_METER_READINGS (p_virtual_meter_start_date IN DATE
                                             DEFAULT VIRTUAL_METER_START_DATE);
PROCEDURE load_reading_to_sustain_aspect;

--PROCEDURE LOAD_ACT_METER_RAW_TO_READINGS (p_virtual_meter_start_date IN DATE
--                                          DEFAULT VIRTUAL_METER_START_DATE);

PROCEDURE process_entity_sustain_aspect
  (p_err_buff                     out NOCOPY  VARCHAR2,
   p_retcode                      out NOCOPY NUMBER,
   p_process_mode                 IN VARCHAR2 DEFAULT 'INCR',
   p_virtual_meter_start_date_str IN varchar2 );


END MTH_SUSTAIN_ASPECT_PKG;

/
