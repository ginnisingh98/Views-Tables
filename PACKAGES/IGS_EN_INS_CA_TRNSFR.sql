--------------------------------------------------------
--  DDL for Package IGS_EN_INS_CA_TRNSFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_INS_CA_TRNSFR" AUTHID CURRENT_USER AS
/* $Header: IGSEN17S.pls 115.3 2002/11/28 23:54:01 nsidana ship $ */

  -- Insert CAFOS as part of Course Transfer.
  FUNCTION ENRP_INS_CAFOSTRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

  --
  -- Insert CAH as part of Course Transfer.
  FUNCTION ENRP_INS_CAH_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

  --
  -- Insert CSC as part of Course Transfer.
  FUNCTION ENRP_INS_CSC_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

  --
  -- Insert SCH as part of Course Transfer.
  FUNCTION ENRP_INS_MIL_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

  --
  -- Insert RSUP as part of Course Transfer.
  FUNCTION ENRP_INS_RSUP_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

  --
  -- Insert SCH as part of Course Transfer.
  FUNCTION ENRP_INS_SCH_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

  --
  -- Insert THE as part of Course Transfer.
  FUNCTION ENRP_INS_THE_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

  --
  -- Insert Research Candidature as part of Course Transfer.
  FUNCTION ENRP_INS_CA_TRNSFR(
  p_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_parent IN VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

END IGS_EN_INS_CA_TRNSFR;

 

/
