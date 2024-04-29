--------------------------------------------------------
--  DDL for Package CS_SR_LOG_DATA_TEMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_LOG_DATA_TEMP_PVT" AUTHID CURRENT_USER AS
/*  $Header: csvlogs.pls 115.6 2002/11/30 11:50:31 pkesani noship $ */

  PROCEDURE delete_log(p_session_id  NUMBER
                     , p_incident_id NUMBER);

  PROCEDURE insert_log(p_session_id  NUMBER
                     , p_incident_id NUMBER
                     , p_log_text    VARCHAR2);


  procedure get_log_report(p_incident_id in number,
                           x_session_id  out NOCOPY number);

-- The Main arrays. This array will hold all data for Audit
-- and activities. It will also hold pointers to the other array.
-- This array will be sorted by Date.
-------------------Sorted Array has pointer to main array ---------------
  type table_pointer is table of integer
  index by binary_integer;
  main_log_pointer table_pointer;

  type table_date is table of date
  index by binary_integer;
  main_log_date table_date;

-------------------Un-sorted Array i.e The Main array ---------------
  type table_source is table of varchar2(30)
  index by binary_integer;
  main_log_source table_source;

  type table_text is table of varchar2(700)
  index by binary_integer;
  main_log_text table_text;

  main_log_page table_pointer;	-- Type Integer

-------------------Un-sorted Array i.e The Other array ---------------
-- The Other arrays. This array will hold all data for Notes, Tasks
-- and Knowledge. This is an Un-sorted array.

  other_log_source table_source;

  type table_id is table of number
  index by binary_integer;
  other_log_id table_id;

  type long_table_text is table of varchar2(4000)
  index by binary_integer;
  other_log_text long_table_text;

  i_total_records integer;   -- Total Number of records in Main array
  i_other_records integer;   -- Total Number of records in Other array
  i_current_record_pointer integer; -- Current position of the pointer

  total_log_pages integer ;
  current_log_page integer;

  display_seq number := 0;

  procedure get_log_details(p_incident_id in number);

  function format_data(column_name in varchar2,
                        old_field_name   in  varchar2,
                        new_field_name   in  varchar2,
                        changed_flag     in  varchar2,
                        last_update_date in  date,
                        last_updated_by  in  varchar2,
                        source_type      in varchar2) return number;

  function sort_log_data(p_low in integer, p_high in integer) RETURN INTEGER;

  procedure insert_log_data(p_session_id  NUMBER,
                            p_incident_id NUMBER);

  procedure get_data_location(source_type in varchar2, source_id in number, position out NOCOPY integer);

  procedure inc_display_seq;

END;

 

/
