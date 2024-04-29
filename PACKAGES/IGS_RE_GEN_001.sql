--------------------------------------------------------
--  DDL for Package IGS_RE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSRE01S.pls 120.0 2005/06/02 04:15:47 appldev noship $ */

-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --Nishikant   11DEC2002       ENCR027 Build (Program Length Integration). The pragma restriction for the functions
  --                            RESP_CLC_MAX_SBMSN and RESP_CLC_MIN_SBMSN removed since its modifying the variables in package.
  --Nalin Kumar 12-Dec-2002     Once again putting back the  pragma restriction in the RESP_CLC_MAX_SBMSN and RESP_CLC_MIN_SBMSN functions.
	--                            ENCR027 Build (Program Length Integration). Bug# 2608227
-- knaraset  09-May-03   modified function RESP_CLC_SUA_EFTSU to add parameter uoo_id, as part of MUS build bug 2829262

-------------------------------------------------------------------------------------------

FUNCTION RESP_CLC_EFTSU_TRUNC(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_uoo_id IN NUMBER ,
  p_census_dt IN DATE ,
  p_eftsu IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(RESP_CLC_EFTSU_TRUNC, WNDS,WNPS);

FUNCTION RESP_CLC_LOAD_EFTSU(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(RESP_CLC_LOAD_EFTSU, WNDS,WNPS);

FUNCTION RESP_CLC_MAX_SBMSN(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_attendance_percentage IN NUMBER ,
  p_commencement_dt IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(RESP_CLC_MAX_SBMSN, WNDS,WNPS);

FUNCTION RESP_CLC_MIN_SBMSN(
  P_PERSON_ID IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_attendance_percentage IN NUMBER ,
  p_commencement_dt IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(RESP_CLC_MIN_SBMSN, WNDS,WNPS);

FUNCTION RESP_CLC_SUA_EFTSU(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_truncate_ind IN VARCHAR2,
  p_uoo_id igs_en_su_attempt.uoo_id%TYPE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(RESP_CLC_SUA_EFTSU, WNDS,WNPS);

FUNCTION RESP_CLC_USED_EFTD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_candidature_identified_ind IN VARCHAR2 DEFAULT 'N',
  p_ca_sequence_number IN NUMBER ,
  p_attendance_percentage IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(RESP_CLC_USED_EFTD, WNDS,WNPS);

FUNCTION RESP_GET_CA_ATT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_ca_sequence_number IN NUMBER ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_percentage IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(RESP_GET_CA_ATT, WNDS, WNPS);


FUNCTION resp_get_ca_comm(
  p_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(resp_get_ca_comm, WNDS,WNPS);

END IGS_RE_GEN_001;

 

/
