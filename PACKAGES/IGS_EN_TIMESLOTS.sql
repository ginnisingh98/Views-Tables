--------------------------------------------------------
--  DDL for Package IGS_EN_TIMESLOTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TIMESLOTS" AUTHID CURRENT_USER AS
/* $Header: IGSEN74S.pls 115.6 2003/01/31 09:20:21 nbehera ship $ */

  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Nishikant       31MAR2003       The field full_name modified to last_name in the record
                                  type pdata_1 and pdata_2. Bug#2455364.
  Nishikant       24JUL2002       Added a new function acad_teach_rel_exist.
                                  This is being used locally in a cursor only.
  KNAG.IN         12-APR-2001     Included ecp attribute in pdata_1
                                  record type as per enh bug 1710227
  (reverse chronological order - newest change first)
  ***************************************************************/

-- pl/sql table for Holding person ID and full name, gpa, total cp
 TYPE pdata_1 IS RECORD(
        person_id NUMBER,
        last_name VARCHAR2(150),
	gpa NUMBER,
        cpc NUMBER,
        ecp NUMBER);
  TYPE plsql_table_1 IS TABLE OF pdata_1 INDEX BY BINARY_INTEGER;

-- pl/sql table for Holding person ID , full name , Start Time and End Time
  TYPE pdata_2 IS RECORD(
        person_id NUMBER,
        last_name VARCHAR2(150),
	start_time DATE,
	end_time DATE);
  TYPE plsql_table_2 IS TABLE OF pdata_2 INDEX BY BINARY_INTEGER;

--pl/sql table for Holding Start time and End time Of the Timeslot Session
  TYPE pdata_3 IS RECORD(
	start_dt_time DATE,
        end_dt_time DATE);
  TYPE plsql_table_3 IS TABLE OF pdata_3 INDEX BY BINARY_INTEGER;

PROCEDURE enrp_para_calculation(
p_program_type_group_cd IN VARCHAR2,
p_student_type IN VARCHAR2,
p_cal_type IN VARCHAR2,
p_seq_number IN NUMBER,
p_timeslot  IN VARCHAR2,
p_ts_start_dt IN DATE,
p_ts_end_dt IN DATE,
p_length_of_time IN VARCHAR2,
p_start_time  IN DATE,
p_end_time IN DATE,
p_total_num_students OUT NOCOPY NUMBER,
p_num_ts_sessions OUT NOCOPY NUMBER);

FUNCTION enrp_total_students(
p_prg_type_gr_cd IN VARCHAR2,
p_stdnt_type IN VARCHAR2,
p_cal_type IN VARCHAR2,
p_seq_num IN NUMBER)
RETURN plsql_table_1 ;

PROCEDURE enrp_assign_timeslot(
ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY NUMBER,
p_prg_type_gr_cd IN VARCHAR2,
p_cal_type IN VARCHAR2,
p_seq_num IN NUMBER,
p_stud_type IN VARCHAR2,
p_timeslot IN VARCHAR2,
p_start_date IN DATE,
p_end_date IN DATE,
p_max_headcount IN NUMBER,
p_length_of_time IN NUMBER,
p1_start_time IN VARCHAR2,
p1_end_time IN VARCHAR2,
p_mode IN VARCHAR2,
p_orgid IN NUMBER);

FUNCTION acad_teach_rel_exist(
p_acad_cal_type   IN VARCHAR2,
p_teach_cal_type  IN VARCHAR2,
p_teach_seq_num   IN NUMBER)
RETURN VARCHAR2;

END IGS_EN_TIMESLOTS;

 

/
