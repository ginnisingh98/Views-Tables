--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_008" AUTHID CURRENT_USER AS
/* $Header: IGSEN08S.pls 115.12 2003/06/17 14:02:26 kkillams ship $ */

/******************************************************************
Created By        :
Date Created By   :
Purpose           :
Known limitations,
enhancements,
remarks            :
Change History
Who        When          What
vchappid 04-Jul-01   functions enrp_get_person_type, enrp_val_chg_grd_sch are  added
                     functions enrp_get_ua_del_alwd, enrp_get_var_window, enrp_get_uddc_aus
                     are modified by adding p_uoo_id parameter with default NULL
kkillams  26-12-2001  new parameters are added to procedure ENRP_INS_BTCH_PRENRL
                                  w.r.t. YOP-EN build bug id:2156956
Nishikant  07OCT2002     UK Enhancement build. Bug#2580731. Five new parameters p_start_day, p_start_month,
                         p_end_day, p_end_month, p_selection_date added in the procedure enrp_ins_btch_prenrl.
                         The function get_commence_date_range defined for being used in a cursor c_sca of the
                         procedure enrp_ins_btch_prenrl.
Nishikant  16DEC2002     ENCR030(UK Enh) - Bug#2708430. One more parameter p_completion_date added in the procedure
                         enrp_ins_btch_prenrl.
kkillams   25-04-2003    New parameter p_uoo_id is added to the function enrp_get_ua_rty w.r.t bug number 2829262
amuthu     04-JUN-2003   added new parameter p_progress_status to enrp_ins_btch_prenrl as part of bug 2829265
kkillams   16-06-2003    Three new parameters are added to the enrp_ins_btch_prenrl procedure as part of bug 2829270
******************************************************************/

FUNCTION enrp_get_ua_del_alwd(
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_effective_dt        IN DATE,
  p_uoo_id              IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Ua_Del_Alwd, WNDS);


FUNCTION enrp_get_ua_rty(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER,
  p_uoo_id              IN NUMBER)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Ua_Rty, WNDS);

FUNCTION enrp_get_uddc_aus(
  p_discontinued_dt       IN DATE ,
  p_cal_type              IN VARCHAR2 ,
  p_ci_sequence_number    IN NUMBER ,
  p_admin_unit_status_str OUT NOCOPY VARCHAR2 ,
  p_alias_val             OUT NOCOPY DATE,
  p_uoo_id                IN NUMBER DEFAULT NULL )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Uddc_Aus, WNDS, WNPS);

FUNCTION enrp_get_ug_pg_crs(
  p_course_cd       IN VARCHAR2 ,
  p_version_number     NUMBER )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Ug_Pg_Crs, WNDS);

FUNCTION enrp_get_us_title(
  p_unit_set_cd       IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd         IN VARCHAR2 ,
  p_version_number    IN NUMBER ,
  p_cal_type          IN VARCHAR2 ,
  p_sequence_number   IN NUMBER ,
  p_person_id         IN NUMBER )
RETURN varchar2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Us_Title, WNDS,WNPS);

FUNCTION enrp_get_var_window(
  p_cal_type           IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_effective_dt       IN DATE,
  p_uoo_id             IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Var_Window, WNDS);

FUNCTION enrp_get_within_ci(
  p_sup_cal_type        IN VARCHAR2 ,
  p_sup_sequence_number IN NUMBER ,
  p_sub_cal_type        IN VARCHAR2 ,
  p_sub_sequence_number IN NUMBER ,
  p_direct_match_ind    IN boolean )
RETURN boolean;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Within_Ci, WNDS, WNPS);

PROCEDURE enrp_ins_btch_prenrl(
  p_course_cd                  IN VARCHAR2 ,
  p_acad_cal_type              IN VARCHAR2 ,
  p_acad_sequence_number       IN NUMBER ,
  p_course_type                IN VARCHAR2 ,
  p_responsible_org_unit_cd    IN VARCHAR2 ,
  p_location_cd                IN VARCHAR2 ,
  p_attendance_type            IN VARCHAR2 ,
  p_attendance_mode            IN VARCHAR2 ,
  p_student_comm_type          IN VARCHAR2 ,
  p_person_group_id            IN NUMBER ,
  p_dflt_enrolment_cat         IN VARCHAR2 ,
  p_units_indicator            IN VARCHAR2 ,
  p_override_enr_form_due_dt   IN DATE ,
  p_override_enr_pckg_prod_dt  IN DATE ,
  p_enr_cal_type               IN VARCHAR2 ,
  p_enr_sequence_number        IN NUMBER ,
  p_last_enrolment_cat         IN VARCHAR2 ,
  p_admission_cat              IN VARCHAR2 ,
  p_adm_cal_type               IN VARCHAR2 ,
  p_adm_sequence_number        IN NUMBER ,
  p_dflt_confirmed_ind         IN VARCHAR2 ,
  p_unit1_unit_cd              IN VARCHAR2 ,
  p_unit1_cal_type             IN VARCHAR2 ,
  p_unit1_location_cd          IN VARCHAR2 ,
  p_unit1_unit_class           IN VARCHAR2 ,
  p_unit2_unit_cd              IN VARCHAR2 ,
  p_unit2_cal_type             IN VARCHAR ,
  p_unit2_location_cd          IN VARCHAR2 ,
  p_unit2_unit_class           IN VARCHAR2 ,
  p_unit3_unit_cd              IN VARCHAR2 ,
  p_unit3_cal_type             IN VARCHAR2 ,
  p_unit3_location_cd          IN VARCHAR2 ,
  p_unit3_unit_class           IN VARCHAR2 ,
  p_unit4_unit_cd              IN VARCHAR2 ,
  p_unit4_cal_type             IN VARCHAR2 ,
  p_unit4_location_cd          IN VARCHAR2 ,
  p_unit4_unit_class           IN VARCHAR2 ,
  p_unit5_unit_cd              IN VARCHAR2 ,
  p_unit5_cal_type             IN VARCHAR2 ,
  p_unit5_location_cd          IN VARCHAR2 ,
  p_unit5_unit_class           IN VARCHAR2 ,
  p_unit6_unit_cd              IN VARCHAR2 ,
  p_unit6_cal_type             IN VARCHAR2 ,
  p_unit6_location_cd          IN VARCHAR2 ,
  p_unit6_unit_class           IN VARCHAR2 ,
  p_unit7_unit_cd              IN VARCHAR2 ,
  p_unit7_cal_type             IN VARCHAR2 ,
  p_unit7_location_cd          IN VARCHAR2 ,
  p_unit7_unit_class           IN VARCHAR2 ,
  p_unit8_unit_cd              IN VARCHAR2 ,
  p_unit8_cal_type             IN VARCHAR2 ,
  p_unit8_location_cd          IN VARCHAR2 ,
  p_unit8_unit_class           IN VARCHAR2 ,
  p_unit9_unit_cd              IN VARCHAR2 ,     --cloumns are added w.r.t. YOP-EN build by kkillams from p_unit9_unit_cd to p_unit_set_cd2
  p_unit9_cal_type             IN VARCHAR2 ,
  p_unit9_location_cd          IN VARCHAR2 ,
  p_unit9_unit_class           IN VARCHAR2 ,
  p_unit10_unit_cd             IN VARCHAR2 ,
  p_unit10_cal_type            IN VARCHAR2 ,
  p_unit10_location_cd         IN VARCHAR2 ,
  p_unit10_unit_class          IN VARCHAR2 ,
  p_unit11_unit_cd             IN VARCHAR2 ,
  p_unit11_cal_type            IN VARCHAR2 ,
  p_unit11_location_cd         IN VARCHAR2 ,
  p_unit11_unit_class          IN VARCHAR2 ,
  p_unit12_unit_cd             IN VARCHAR2 ,
  p_unit12_cal_type            IN VARCHAR2 ,
  p_unit12_location_cd         IN VARCHAR2 ,
  p_unit12_unit_class          IN VARCHAR2 ,
  p_unit_set_cd1               IN VARCHAR2 ,
  p_unit_set_cd2               IN VARCHAR2 ,
  -- The Below five parameters are added as part of the Enh bug#2580731
  p_start_day                  IN NUMBER,
  p_start_month                IN NUMBER,
  p_end_day                    IN NUMBER,
  p_end_month                  IN NUMBER,
  p_selection_date             IN DATE,
  --Below parameter added as part of ENCR030(UK Enh) - Bug#2708430
  p_completion_date            IN DATE DEFAULT NULL,
  p_log_creation_dt            OUT NOCOPY DATE,
  p_progress_stat              IN VARCHAR2 DEFAULT NULL,
  p_dflt_enr_method            IN VARCHAR2 DEFAULT NULL,
  p_load_cal_type              IN VARCHAR2 DEFAULT NULL,
  p_load_ci_seq_num            IN NUMBER DEFAULT NULL);

FUNCTION enrp_get_person_type(p_course_cd IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(enrp_get_person_type, WNDS,WNPS);


FUNCTION enrp_val_chg_grd_sch ( p_uoo_id             IN   NUMBER,
                                p_cal_type           IN   VARCHAR2,
                                p_ci_sequence_number IN   NUMBER,
                                p_message_name       OUT NOCOPY  VARCHAR2
                              ) RETURN BOOLEAN;


FUNCTION enrp_val_chg_grd_sch_wrapper ( p_uoo_id             IN   NUMBER,
                                p_cal_type           IN   VARCHAR2,
                                p_ci_sequence_number IN   NUMBER
                              ) RETURN CHAR;
FUNCTION enrp_val_chg_cp (      p_person_id IN NUMBER,
                                p_uoo_id             IN   NUMBER,
                                p_cal_type           IN   VARCHAR2,
                                p_ci_sequence_number IN   NUMBER
                              ) RETURN CHAR;

 FUNCTION enrp_get_dflt_sdrt(
   p_s_discont_reason_type IN VARCHAR2 )
  RETURN VARCHAR2;

FUNCTION get_commence_date_range(
        p_start_day          IN NUMBER,
        p_start_month        IN NUMBER,
        p_end_day            IN NUMBER,
        p_end_month          IN NUMBER,
        p_commencement_dt    IN DATE)
RETURN VARCHAR2;

END igs_en_gen_008;

 

/
