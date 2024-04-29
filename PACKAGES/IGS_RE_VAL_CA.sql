--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_CA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_CA" AUTHID CURRENT_USER AS
/* $Header: IGSRE04S.pls 120.0 2005/06/02 03:47:46 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_sdtt_sess removed
  --kkillams    11-11-2002      As part of Legacy Build bug no:2661533,
  --                            New parameter p_legacy is added to following functions
  --                            resp_val_ca_minsbmsn,resp_val_ca_maxsbmsn and resp_val_ca_topic
  -------------------------------------------------------------------------------------------

/*****  Bug No :   1956374
        Task   :   Duplicated Procedures and functions
||  Removed program unit (RESP_VAL_CA_ATT_PERC) - from the spec and body. -- kdande
        PROCEDURE  admp_val_ca_comm , admp_val_ca_comm_val is removed  *****/

  -- Validate adm IGS_PS_COURSE application proposed commencement date.

  FUNCTION admp_val_acai_comm(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_crv_version_number IN NUMBER ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_adm_cal_type IN VARCHAR2 ,

  p_adm_ci_sequence_number IN NUMBER ,

  p_adm_outcome_status IN VARCHAR2 ,

  p_prpsd_commencement_dt IN DATE ,

  p_min_submission_dt IN DATE ,

  p_ca_sequence_number IN OUT NOCOPY NUMBER ,

  p_parent IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;
  --

  -- Validate IGS_RE_CANDIDATURE update.

  FUNCTION resp_val_ca_upd(

  p_person_id IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate IGS_RE_CANDIDATURE research topic.

  FUNCTION resp_val_ca_topic(
  p_person_id                   IN  NUMBER ,
  p_sca_course_cd               IN  VARCHAR2 ,
  p_acai_admission_appl_number  IN  NUMBER ,
  p_acai_nominated_course_cd    IN  VARCHAR2 ,
  p_acai_sequence_number        IN  NUMBER ,
  p_research_topic              IN  VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2 ,
  p_legacy                      IN  VARCHAR2 DEFAULT 'N' )

RETURN BOOLEAN;



  -- Validate IGS_RE_CANDIDATURE ACAI link.

  FUNCTION resp_val_ca_acai(

  p_person_id IN NUMBER ,

  p_ca_sequence_number IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_old_acai_admission_appl_num IN NUMBER ,

  p_old_acai_nominated_course_cd IN VARCHAR2 ,

  p_old_acai_sequence_number IN NUMBER ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate IGS_RE_CANDIDATURE maximum submission date.

  FUNCTION resp_val_ca_maxsbmsn(
  p_person_id                   IN  NUMBER ,
  p_sca_course_cd               IN  VARCHAR2 ,
  p_acai_admission_appl_number  IN  NUMBER ,
  p_acai_nominated_course_cd    IN  VARCHAR2 ,
  p_acai_sequence_number        IN  NUMBER ,
  p_min_submission_dt           IN  DATE ,
  p_max_submission_dt           IN  DATE ,
  p_attendance_percentage       IN  NUMBER ,
  p_commencement_dt             IN  DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2 DEFAULT 'N' )

RETURN BOOLEAN;


  -- Validate IGS_RE_CANDIDATURE minimum submission date.

  FUNCTION resp_val_ca_minsbmsn(
  p_person_id                   IN  NUMBER ,
  p_sca_course_cd               IN  VARCHAR2 ,
  p_acai_admission_appl_number  IN  NUMBER ,
  p_acai_nominated_course_cd    IN  VARCHAR2 ,
  p_acai_sequence_number        IN  NUMBER ,
  p_min_submission_dt           IN  DATE ,
  p_max_submission_dt           IN  DATE ,
  p_attendance_percentage       IN  NUMBER ,
  p_commencement_dt             IN  DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2 DEFAULT 'N' )

RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE SCA link.

  FUNCTION resp_val_ca_sca(

  p_person_id IN NUMBER ,

  p_ca_sequence_number IN NUMBER ,

  p_old_sca_course_cd IN VARCHAR2 ,

  p_sca_course_cd IN VARCHAR2 ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE deletion and ACAI link.

  FUNCTION resp_val_ca_acai_del(

  p_person_id IN NUMBER ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE SCA link when deleting.

  FUNCTION resp_val_ca_sca_del(

  p_person_id IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  -- Validate if Government Type of Activity Classification Code is closed.

  FUNCTION resp_val_gtcc_closed(

  p_govt_toa_class_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE SCA/ACAI link.

  FUNCTION resp_val_ca_sca_acai(

  p_person_id IN NUMBER ,

  p_sca_course_cd IN VARCHAR2 ,

  p_acai_admission_appl_number IN NUMBER ,

  p_acai_nominated_course_cd IN VARCHAR2 ,

  p_acai_sequence_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

END IGS_RE_VAL_CA;

 

/
