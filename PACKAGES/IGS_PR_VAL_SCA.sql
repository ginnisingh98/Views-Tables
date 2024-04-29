--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SCA" AUTHID CURRENT_USER AS
/* $Header: IGSPR08S.pls 115.5 2002/11/29 02:45:46 nsidana ship $ */


  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kdande      26-01-2002      Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
  --                            Removed program unit (PRGP_VAL_SCA_CMPLT) - from the spec and body.
  --kkillams    11-11-2002      As part of Legacy Build bug no:2661533,
  --                            New parameter p_legacy is added to following function
  --                            course_rqrmnts_complete_dt.
  -------------------------------------------------------------------------------------------

  --
  -- Validate the Student IGS_PS_UNIT Set Attempts.
  FUNCTION prgp_val_susa_cmplt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_susa_cmplt, WNDS);
  --
  -- Validate the Student IGS_PS_COURSE Attempt Status.
  FUNCTION prgp_val_sca_status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_sca_status, WNDS);
  --
  -- Validate the Student IGS_PS_COURSE complete indicator.
  FUNCTION prgp_val_undo_cmpltn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_exit_course_cd IN VARCHAR2 ,
  p_exit_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_undo_cmpltn, WNDS);
  --
  -- Validate the Student IGS_PS_COURSE complete indicator.
  FUNCTION prgp_val_cmplt_ind(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_exit_course_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_call_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_cmplt_ind, WNDS);
  --
  -- Validate that rqrmnts complete dt and source set if IGS_PS_COURSE complete.
  FUNCTION prgp_val_sca_crcd(
  p_course_rqrmnt_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_course_rqrmnts_complete_dt IN DATE ,
  p_s_completed_source_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_sca_crcd, WNDS);
  --
  -- To validate the IGS_EN_STDNT_PS_ATT.course_rqrmnts_complete_dt
  FUNCTION prgp_val_sca_cmpl_dt(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_commencement_dt             IN DATE ,
  p_course_rqrmnts_complete_dt  IN DATE ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_legacy                      IN  VARCHAR2 DEFAULT 'N')
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_sca_cmpl_dt, WNDS);
END IGS_PR_VAL_SCA;

 

/
