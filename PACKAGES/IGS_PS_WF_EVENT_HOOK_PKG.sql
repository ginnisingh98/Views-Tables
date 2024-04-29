--------------------------------------------------------
--  DDL for Package IGS_PS_WF_EVENT_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_WF_EVENT_HOOK_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPS79S.pls 115.4 2002/11/29 03:12:33 nsidana ship $ */
TYPE OccurNew IS REF CURSOR;
TYPE OccurOld IS REF CURSOR;
TYPE UnitDtls IS REF CURSOR;
TYPE StudentDetails IS REF CURSOR;
TYPE InstructorDetails IS REF CURSOR;
TYPE rec_OccurNew IS RECORD (monday IGS_PS_USEC_OCCURS.monday%TYPE,
			     tuesday IGS_PS_USEC_OCCURS.tuesday%TYPE,
			     wednesday IGS_PS_USEC_OCCURS.wednesday%TYPE,
			     thursday IGS_PS_USEC_OCCURS.thursday%TYPE,
			     friday IGS_PS_USEC_OCCURS.friday%TYPE,
			     saturday IGS_PS_USEC_OCCURS.saturday%TYPE,
			     sunday IGS_PS_USEC_OCCURS.sunday%TYPE,
			     start_time IGS_PS_USEC_OCCURS.start_time%TYPE,
			     end_time IGS_PS_USEC_OCCURS.end_time%TYPE,
			     building_code IGS_PS_USEC_OCCURS.building_code%TYPE,
			     room_code IGS_PS_USEC_OCCURS.room_code%TYPE);

TYPE rec_OccurOld IS RECORD (unit_section_occurrence_id IGS_PS_SH_USEC_OCCURS.unit_section_occurrence_id%TYPE,
			     monday IGS_PS_SH_USEC_OCCURS.monday%TYPE,
			     tuesday IGS_PS_SH_USEC_OCCURS.tuesday%TYPE,
			     wednesday IGS_PS_SH_USEC_OCCURS.wednesday%TYPE,
			     thursday IGS_PS_SH_USEC_OCCURS.thursday%TYPE,
			     friday IGS_PS_SH_USEC_OCCURS.friday%TYPE,
			     saturday IGS_PS_SH_USEC_OCCURS.saturday%TYPE,
			     sunday IGS_PS_SH_USEC_OCCURS.sunday%TYPE,
			     start_time IGS_PS_SH_USEC_OCCURS.start_time%TYPE,
			     end_time IGS_PS_SH_USEC_OCCURS.end_time%TYPE,
			     building_code IGS_PS_SH_USEC_OCCURS.building_code%TYPE,
			     room_code IGS_PS_SH_USEC_OCCURS.room_code%TYPE);

TYPE rec_UnitDtls IS RECORD (unit_cd IGS_PS_UNIT_OFR_OPT_V.unit_cd%TYPE,
                           title IGS_PS_UNIT_OFR_OPT_V.title%TYPE,
	                   cal_start_dt IGS_PS_UNIT_OFR_OPT_V.cal_start_dt%TYPE,
	                   cal_end_dt IGS_PS_UNIT_OFR_OPT_V.cal_end_dt%TYPE,
	                   location_cd IGS_PS_UNIT_OFR_OPT_V.location_cd%TYPE,
	                   location_description IGS_PS_UNIT_OFR_OPT_V.location_description%TYPE,
	                   unit_mode IGS_PS_UNIT_OFR_OPT_V.unit_mode%TYPE);
TYPE rec_StudentDetails IS RECORD (  person_id igs_pe_person.person_id%TYPE,
                           unit_attempt_status IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE,
	                   person_number igs_pe_person.person_number%TYPE,
	                   email_addr igs_pe_person.email_addr%TYPE,
	                   full_name igs_pe_person.full_name%TYPE);
TYPE rec_InstructorDetails IS RECORD (person_number IGS_PE_PERSON.person_number%TYPE,
                           email_addr IGS_PE_PERSON.email_addr%TYPE,
	                   full_name igs_pe_person.full_name%TYPE);
PROCEDURE wf_get_shadow_values (p_uoo_id IN NUMBER,
                           p_unit_section_occurrence_id IN NUMBER,
                           p_type IN VARCHAR2,
                           p_old_values IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.OCCUROLD,
                           p_new_values IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.OCCURNEW,
			   p_unit_dtls  IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.UNITDTLS);

PROCEDURE wf_event_audience (p_uoo_id IN NUMBER,
                           p_unit_section_occurrence_id IN NUMBER,
                           p_type IN VARCHAR2,
                           p_students IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.StudentDetails,
                           p_instructors IN OUT NOCOPY IGS_PS_WF_EVENT_HOOK_PKG.InstructorDetails);
END IGS_PS_WF_EVENT_HOOK_PKG;

 

/
