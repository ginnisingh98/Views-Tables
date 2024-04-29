--------------------------------------------------------
--  DDL for Package Body IGF_AP_OSS_INTRFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_OSS_INTRFACE" AS
/* $Header: IGFAP09B.pls 120.1 2005/09/08 14:44:28 appldev noship $ */


PROCEDURE get_acad_calendar(awd_caltype IN VARCHAR2,awd_Seqnum IN NUMBER,acad_caltype OUT NOCOPY VARCHAR2,
                            acad_seqnum OUT NOCOPY NUMBER,acad_altcode OUT NOCOPY VARCHAR2)

IS
 BEGIN
   NULL;
END;


FUNCTION  get_ssn(vperson_id  IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


PROCEDURE get_program_code(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER,
                           vcourse_cd OUT NOCOPY VARCHAR2,vversion_number OUT NOCOPY NUMBER)
IS
 BEGIN
   NULL;
 END;


FUNCTION get_grade_level_code(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER)
RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_completion_date(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;



FUNCTION get_admission_index(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION is_degree_stdnt(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
BOOLEAN
IS
 BEGIN
   RETURN FALSE;
 END;


FUNCTION get_attd_mode(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_attd_type(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION is_stdnt_discontd(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
BOOLEAN
IS
 BEGIN
   RETURN FALSE;
 END;


FUNCTION stdnt_intermission(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
BOOLEAN
IS
 BEGIN
   RETURN FALSE;
 END;


FUNCTION attends_other_inst(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN
BOOLEAN
IS
 BEGIN
   RETURN FALSE;
 END;


FUNCTION eligible_for_aid(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER,aid_type IN VARCHAR2) RETURN
BOOLEAN
IS
 BEGIN
   RETURN FALSE;
 END;


FUNCTION is_transferee(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN BOOLEAN
IS
 BEGIN
   RETURN FALSE;
 END;


FUNCTION get_adm_appl_status(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_adm_outcome_status(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_adm_offr_resp_status(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_adm_offr_accept_date(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN DATE
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_adm_date(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN DATE
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_adm_fee_status(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_adm_test_score(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_diploma_school(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_school_rank(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_school_gpa(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN NUMBER
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_transfer_school(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_cumulative_tr_credits(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN NUMBER
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_transfer_gpa(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN NUMBER
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_athletic_sport(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_cumulative_cr_points(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN NUMBER
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_cumulative_gpa(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN NUMBER
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_term_gpa(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN NUMBER
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_minor_unit_set(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_credit_points_enrol(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN NUMBER
IS
 BEGIN
   RETURN NULL;
 END;


FUNCTION get_final_unit_set(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER) RETURN VARCHAR2
IS
 BEGIN
   RETURN NULL;
 END;


PROCEDURE get_adm_data(vperson_id IN NUMBER,awdcal_type IN VARCHAR2,awdcal_seq IN NUMBER,
                       adm_status OUT NOCOPY VARCHAR2,adm_pro_dt OUT NOCOPY DATE,grade_level OUT NOCOPY VARCHAR2,
                       student_type OUT NOCOPY VARCHAR2,adm_pro_status OUT NOCOPY VARCHAR2,admission_index OUT NOCOPY VARCHAR2,
                       outcome_status OUT NOCOPY VARCHAR2,org_id OUT NOCOPY NUMBER,decision_date OUT NOCOPY DATE,
                       final_unit_set OUT NOCOPY VARCHAR2,program OUT NOCOPY VARCHAR2,term_start_date OUT NOCOPY DATE,
                       current_gpa OUT NOCOPY VARCHAR2,cumulative_gpa OUT NOCOPY VARCHAR2,curent_enrol_hrs OUT NOCOPY NUMBER,
                       acheived_cr_pts OUT NOCOPY NUMBER,enrolment_status OUT NOCOPY VARCHAR2,enrolment_status_date OUT NOCOPY DATE,
                       grade_level_type OUT NOCOPY VARCHAR2,grade_level_date OUT NOCOPY DATE,transfered OUT NOCOPY VARCHAR2)
IS
 BEGIN
   NULL;
 END;




END igf_ap_oss_intrface;

/
