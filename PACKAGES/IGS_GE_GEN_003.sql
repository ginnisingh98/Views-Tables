--------------------------------------------------------
--  DDL for Package IGS_GE_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSGE03S.pls 120.1 2006/01/06 03:59:26 gmaheswa noship $ */
--
-- Who         When            What
-- knaraset  29-Apr-03   Added parameter p_uoo_id in GENP_INS_TODO_REF, as part of MUS build bug 2829262
--

FUNCTION genp_get_user_person(
  p_oracle_username IN VARCHAR2 ,
  p_staff_member_ind OUT NOCOPY VARCHAR2 )
RETURN NUMBER ;

PROCEDURE genp_ins_log(
  p_s_log_type IN VARCHAR2 ,
  p_key IN VARCHAR2 ,
  p_creation_dt OUT NOCOPY DATE ) ;


PROCEDURE genp_ins_log_entry(
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE ,
  p_key IN VARCHAR2 ,
  p_s_message_name IN VARCHAR2,
  p_text IN VARCHAR2 ) ;


FUNCTION genp_ins_stdnt_todo(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_todo_dt IN DATE ,
  p_single_entry_ind IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER ;

PROCEDURE genp_set_sle_count(
  p_s_log_type IN VARCHAR2 ,
  p_key IN VARCHAR2 ,
  p_sle_key IN VARCHAR2 ,
  p_message_name IN VARCHAR2  ,
  p_count IN NUMBER ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_total_count OUT NOCOPY NUMBER ) ;

FUNCTION genp_set_time(
  p_time IN DATE )
RETURN DATE ;

FUNCTION genp_upd_str_lgc_del(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_reference_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

PROCEDURE genp_ins_todo_ref(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_other_reference IN VARCHAR2,
  p_uoo_id IN NUMBER);



PROCEDURE set_org_id(p_context IN VARCHAR2 DEFAULT NULL);

FUNCTION get_org_id RETURN NUMBER;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose:Function to get the person ID for the given person number
--        returns NULL if no person or more than one person found in the system.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION get_person_id(
  p_person_number IN VARCHAR2)
RETURN NUMBER;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose:Function to get the version number for the given program attempt
--        returns NULL if no program attempt found in the system.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION get_program_version(
  p_person_id IN NUMBER,
  p_program_cd IN VARCHAR2)
RETURN NUMBER;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose:procedure which returns the calendar details of the given caledar alternate code as OUT params.
--        returns NULL if no calendar instance found or more than one calendar instance found in the system.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
PROCEDURE get_calendar_instance(
  p_alternate_cd IN VARCHAR2,
  p_s_cal_category IN VARCHAR2 DEFAULT NULL,
  p_cal_type OUT NOCOPY VARCHAR2,
  p_ci_sequence_number OUT NOCOPY NUMBER,
  p_start_dt OUT NOCOPY DATE,
  p_end_dt OUT NOCOPY DATE,
  p_return_status OUT NOCOPY VARCHAR2);

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: procedure which returns the unit set version number and sequence number of the given unit set attempt.
--         returns NULL if no unit set attempt found or more than one unit set attempt found in the system.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
PROCEDURE get_susa_sequence_num(
  p_person_id IN NUMBER,
  p_program_cd IN VARCHAR2,
  p_unit_set_cd IN VARCHAR2,
  p_us_version_number OUT NOCOPY NUMBER,
  p_sequence_number OUT NOCOPY NUMBER);

FUNCTION disable_oss RETURN VARCHAR2;

g_oss_disable_exception           EXCEPTION;

END igs_ge_gen_003 ;

 

/
