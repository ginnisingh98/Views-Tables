--------------------------------------------------------
--  DDL for Package IGS_AD_INS_ADMPERD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_INS_ADMPERD" AUTHID CURRENT_USER AS
/* $Header: IGSAD14S.pls 115.6 2002/11/28 21:25:24 nsidana ship $ */

  --
  -- Insert admission period details as part of a rollover process.

  PROCEDURE admp_ins_acadci_roll(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_academic_period IN VARCHAR2,
  p_admission_cat IN VARCHAR2 ,
  p_org_id        IN NUMBER);

  -- Insert admission period IGS_PS_COURSE offering option.
  FUNCTION admp_ins_apapc_apcoo(
  p_acad_alternate_code IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_old_admission_cat IN VARCHAR2 ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_new_admission_cat IN VARCHAR2 ,
  p_rollover_ind IN VARCHAR2 DEFAULT 'N',
  p_s_log_type IN OUT NOCOPY VARCHAR2 ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Insert admission period details as part of a rollover process.
  FUNCTION admp_ins_adm_ci_roll(
  p_acad_alternate_code IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_log_type IN OUT NOCOPY VARCHAR2 ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate if IGS_AD_CAT.IGS_AD_CAT is closed.

  --
  -- Validate admission period calendar instance

END IGS_AD_INS_ADMPERD;

 

/
