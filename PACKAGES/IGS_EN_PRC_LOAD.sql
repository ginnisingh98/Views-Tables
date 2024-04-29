--------------------------------------------------------
--  DDL for Package IGS_EN_PRC_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_PRC_LOAD" AUTHID CURRENT_USER AS
/* $Header: IGSEN18S.pls 120.3 2005/12/04 22:36:57 appldev ship $ */

/**************************************************************************************
 Who           When                What
stutta     17-NOV-2003    Added two new parameters for the function enrp_clc_key_prog as part
                          part of Term Records Build.
knaraset   04-Nov-2003    Added two functions enrp_get_inst_attendance enrp_get_inst_cp as part
                          of build EN212, bug 3198180
sarakshi   27-Jun-2003    Enh#2930935, added parameter uoo_id to teh function ENRP_CLC_SUA_LOAD
pradhakr   15-Jan-2003    Added one more parameter no_assessment_ind to the
                          procedure ENRP_CLC_SUA_EFTSU and ENRP_GET_LOAD_INCUR.
                          Changes wrt ENCR026. Bug# 2743459
amuthu     15-NOV-2002    Modified as per the SS Worksheet Redesign TD
vkarthik   21-Jul-2004    Added two parameters to enrp_clc_sua_load for EN308 Billable credit points build #3782329
vijrajag   07-Jul-2005    Added function get_term_credits
********************************************************************************************/
  -- To calculate the EFTSU total for a Unit attempt across all load cals
  FUNCTION ENRP_CLC_SUA_EFTSUT(
  P_PERSON_ID IN NUMBER ,
  P_COURSE_CD IN VARCHAR2 ,
  P_CRV_VERSION_NUMBER IN NUMBER ,
  P_UNIT_CD IN VARCHAR2 ,
  P_UNIT_VERSION_NUMBER IN NUMBER ,
  P_TEACH_CAL_TYPE IN VARCHAR2 ,
  P_TEACH_SEQUENCE_NUMBER IN NUMBER ,
  p_uoo_id IN NUMBER ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_sca_cp_total IN NUMBER ,
  p_original_eftsu OUT NOCOPY NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ENRP_CLC_SUA_EFTSUT,WNDS,WNPS);
  --
  -- To calc the total EFTSU figure for a SCA within a load cal instance
  FUNCTION enrp_clc_eftsu_total(
  p_person_id            IN NUMBER ,
  p_course_cd            IN VARCHAR2 ,
  p_acad_cal_type        IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_load_cal_type        IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER ,
  p_truncate_ind         IN VARCHAR2 DEFAULT 'N',
  p_include_research_ind IN VARCHAR2 ,
  p_key_course_cd        IN igs_en_su_attempt.course_cd%TYPE,
  p_key_version_number   IN igs_en_su_attempt.version_number%TYPE,
  p_credit_points        OUT NOCOPY NUMBER )
RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES (ENRP_CLC_EFTSU_TOTAL,WNDS,WNPS);
  --
  -- To calculate the EFTSU value of a student unit attempt
  FUNCTION enrp_clc_sua_eftsu(
  p_person_id             IN NUMBER ,
  p_course_cd             IN VARCHAR2 ,
  p_crv_version_number    IN NUMBER ,
  p_unit_cd               IN VARCHAR2 ,
  p_unit_version_number   IN NUMBER ,
  p_teach_cal_type        IN VARCHAR2 ,
  p_teach_sequence_number IN NUMBER ,
  p_uoo_id                IN NUMBER ,
  p_load_cal_type         IN VARCHAR2 ,
  p_load_sequence_number  IN NUMBER ,
  p_override_enrolled_cp  IN NUMBER ,
  p_override_eftsu        IN NUMBER ,
  p_truncate_ind          IN VARCHAR2 DEFAULT 'N',
  p_sca_cp_total          IN NUMBER ,
  p_key_course_cd         IN igs_en_su_attempt.course_cd%TYPE,
  p_key_version_number    IN igs_en_su_attempt.version_number%TYPE,
  p_credit_points         OUT NOCOPY NUMBER ,
  -- anilk, Audit special fee build
  p_include_audit         IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ENRP_CLC_SUA_EFTSU,WNDS,WNPS);
  --
  -- To calculate the WEFTSU for a student unit attempt
  FUNCTION ENRP_CLC_SUA_WEFTSU(
  p_unit_cd              IN VARCHAR2 ,
  p_version_number       IN NUMBER ,
  p_discipline_group_cd  IN VARCHAR2 ,
  p_org_unit_cd          IN VARCHAR2 ,
  p_sua_eftsu            IN NUMBER ,
  p_local_ins_deakin_ind IN VARCHAR2 )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (ENRP_CLC_SUA_WEFTSU,WNDS);
  --
  -- To calculate the truncated EFTSU figure according to DEETYA rules
  FUNCTION ENRP_CLC_EFTSU_TRUNC(
  p_unit_cd        IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_uoo_id         IN NUMBER ,
  p_eftsu          IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ENRP_CLC_EFTSU_TRUNC,WNDS,WNPS);
  --
  -- To get the annual load for a IGS_PS_UNIT attempt within a Course
  FUNCTION ENRP_GET_ANN_LOAD(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_version_number      IN NUMBER ,
  p_unit_cd             IN VARCHAR2 ,
  p_unit_version_number IN NUMBER ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_sca_cp_total        IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ENRP_GET_ANN_LOAD,WNDS,WNPS);
  --
  -- To calc the total load for an SCA for a load period
  FUNCTION ENRP_CLC_LOAD_TOTAL(
  p_person_id            IN NUMBER ,
  p_course_cd            IN VARCHAR2 ,
  p_acad_cal_type        IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_load_cal_type        IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER )
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES (ENRP_CLC_LOAD_TOTAL,WNDS);
  --
  -- To calculate the load for a sua (optionally within a load calendar)
  FUNCTION ENRP_CLC_SUA_LOAD(
  p_unit_cd                 IN VARCHAR2 ,
  p_version_number          IN NUMBER ,
  p_cal_type                IN VARCHAR2 ,
  p_ci_sequence_number      IN NUMBER ,
  p_load_cal_type           IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_override_enrolled_cp    IN NUMBER ,
  p_override_eftsu          IN NUMBER ,
  p_return_eftsu            OUT NOCOPY NUMBER ,
  p_uoo_id                  IN NUMBER,
  -- anilk, Audit special fee build
  p_include_as_audit        IN VARCHAR2 DEFAULT 'N',
  -- added for EN308 Billable credit point hours build
  p_audit_cp		    OUT NOCOPY NUMBER,
  p_billing_cp		    OUT NOCOPY NUMBER,
  p_enrolled_cp		    OUT NOCOPY NUMBER)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (ENRP_CLC_SUA_LOAD,WNDS,WNPS);
  --
  -- To get the attendance type of load within a nominated load calendar
  FUNCTION ENRP_GET_LOAD_ATT(
  p_load_cal_type IN VARCHAR2 ,
  p_load_figure   IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (ENRP_GET_LOAD_ATT,WNDS,WNPS);
  --
  -- To get whether a UA incurs load within a nominated load calendar
  FUNCTION ENRP_GET_LOAD_INCUR(
  p_cal_type                   IN VARCHAR2 ,
  p_sequence_number            IN NUMBER ,
  p_discontinued_dt            IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_unit_attempt_status        IN VARCHAR2 ,
  p_no_assessment_ind          IN VARCHAR2 DEFAULT 'N',
  p_load_cal_type              IN VARCHAR2 ,
  p_load_sequence_number       IN NUMBER,
  p_uoo_id                     IN NUMBER DEFAULT NULL,
  -- anilk, Audit special fee build
  p_include_audit        IN VARCHAR2 DEFAULT 'N' )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES (ENRP_GET_LOAD_INCUR,WNDS,WNPS);
  --
  -- To get whether a load applies to a UA within a nominated load calendar
  FUNCTION ENRP_GET_LOAD_APPLY(
  p_teach_cal_type             IN VARCHAR2 ,
  p_teach_sequence_number      IN NUMBER ,
  p_discontinued_dt            IN DATE ,
  p_administrative_unit_status IN VARCHAR2 ,
  p_unit_attempt_status        IN VARCHAR2 ,
  p_no_assessment_ind          IN VARCHAR2 DEFAULT 'N',
  p_load_cal_type              IN VARCHAR2 ,
  p_load_sequence_number       IN NUMBER,
  -- anilk, Audit special fee build
  p_include_audit        IN VARCHAR2 DEFAULT 'N' )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES (ENRP_GET_LOAD_APPLY,WNDS,WNPS);

 -- Function to get the Key Programs for a Particular Person

 FUNCTION enrp_clc_key_prog
                         (
                          p_person_id                     IN   hz_parties.party_id%TYPE,
                          p_version_number                OUT NOCOPY  igs_en_su_attempt.version_number%TYPE,
                          p_term_cal_type                  IN VARCHAR2 DEFAULT NULL,
                          p_term_sequence_number           IN NUMBER DEFAULT NULL
                          )
                          RETURN igs_en_su_attempt.course_cd%TYPE;


-- Function to calculate the Institutional Level Attendance Type

PROCEDURE enrp_get_inst_latt
                          (
                          p_person_id                  IN  hz_parties.party_id%TYPE,
                          p_load_cal_type              IN  igs_ca_inst.cal_type%TYPE,
                          p_load_seq_number            IN  igs_ca_inst.sequence_number%TYPE,
                          p_attendance                 OUT NOCOPY igs_en_atd_type_load.attendance_type%TYPE,
                          p_credit_points              OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE,
                          p_fte                        OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE
                          );

-- anilk, Bug# 3046897
-- Function to calculate the Institutional Level Attendance Type, called from View Academic History Page
PROCEDURE enrp_get_inst_latt_fte
                          (
                          p_person_id                  IN  hz_parties.party_id%TYPE,
                          p_load_cal_type              IN  igs_ca_inst.cal_type%TYPE,
                          p_load_seq_number            IN  igs_ca_inst.sequence_number%TYPE,
                          p_attendance                 OUT NOCOPY igs_en_atd_type_load.attendance_type%TYPE,
                          p_credit_points              OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE,
                          p_fte                        OUT NOCOPY igs_en_su_attempt.override_achievable_cp%TYPE
                          );

--Procedure to calculate the total credit points with in a given load calendar
PROCEDURE enrp_clc_cp_upto_tp_start_dt
                           (
                              p_person_id             IN  NUMBER,
                              p_load_cal_type         IN  VARCHAR2,
                              p_load_sequence_number  IN  NUMBER,
                              p_include_research_ind  IN  VARCHAR2,
                              p_tp_sd_cut_off_date    IN  DATE DEFAULT SYSDATE,
                              p_credit_points         OUT NOCOPY NUMBER
                           );
--Function to get attendace type for person and course and load or adac cal
FUNCTION  enrp_get_prg_att_type
                           (
                              p_person_id             IN  NUMBER,
                              p_course_cd             IN VARCHAR2,
                              p_cal_type                IN  VARCHAR2,
                              p_sequence_number         IN  NUMBER
                           ) RETURN VARCHAR2;

--Procedure to get latest load for an acad calendar
PROCEDURE get_latest_load_for_acad_cal
(
  p_acad_cal_type           IN igs_ca_inst.cal_type%TYPE,
  p_acad_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
  p_load_cal_type           OUT NOCOPY  igs_ca_inst.cal_type%TYPE,
  p_load_ci_sequence_number OUT NOCOPY igs_ca_inst.sequence_number%TYPE
)
;


Function ENRP_GET_PRG_LOAD_CP(p_person_id             IN  NUMBER,
                              p_course_cd             IN VARCHAR2,
                              p_cal_type              IN  VARCHAR2,
                              p_sequence_number       IN  NUMBER) RETURN VARCHAR2;


--Procedure to get EFTSU and CP for person and course and load or adac cal
Procedure enrp_get_prg_eftsu_cp
                           (
                              p_person_id             IN  NUMBER,
                              p_course_cd             IN VARCHAR2,
                              p_cal_type                IN  VARCHAR2,
                              p_sequence_number         IN  NUMBER,
                              P_EFTSU_TOTAL            OUT NOCOPY NUMBER,
                              P_CREDIT_POINTS          OUT NOCOPY NUMBER
                           ) ;

-- Function to calculate the Institutional Level Attendance Type

FUNCTION enrp_get_inst_attendance(
                          p_person_id                  IN  hz_parties.party_id%TYPE,
                          p_load_cal_type              IN  igs_ca_inst.cal_type%TYPE,
                          p_load_seq_number            IN  igs_ca_inst.sequence_number%TYPE
                          ) RETURN VARCHAR2;

-- Function to calculate the Institutional Level Attendance Type
FUNCTION  enrp_get_inst_cp(
                          p_person_id                  IN  hz_parties.party_id%TYPE,
                          p_load_cal_type              IN  igs_ca_inst.cal_type%TYPE,
                          p_load_seq_number            IN  igs_ca_inst.sequence_number%TYPE
                          ) RETURN VARCHAR2;

-- get_term_credits: Gets the total credits for the given person, program and term.
FUNCTION get_term_credits (p_n_person_id IN NUMBER,
                           p_c_program IN VARCHAR2,
                           p_c_load_cal IN VARCHAR2,
                           p_n_load_seq_num IN NUMBER,
			   p_c_acad_cal IN VARCHAR2,
			   p_c_acad_seq_num IN NUMBER) RETURN NUMBER;

END Igs_En_Prc_Load;

 

/
