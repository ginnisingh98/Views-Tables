--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_RSUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_RSUP" AUTHID CURRENT_USER AS
/* $Header: IGSRE11S.pls 115.5 2002/11/29 03:29:23 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The Function genp_val_sdtt_sess removed
  --smadathi    29-AUG-2001     Bug No. 1956374 .The Function genp_val_strt_end_dt removed
  -- pradhakr   20-Nov-2002     Bug# 2661533. Created a new function to get the
  --                            organization start date for the given organisation unit code.
  --                            Added p_legacy paramter to some of the functions.
  -------------------------------------------------------------------------------------------

/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (RESP_VAL_CA_CHILDUPD) - from the spec and body. -- kdande
||  Removed program unit (RESP_VAL_CA_TRG) - from the spec and body. -- kdande
*/

  -- Bug No 1956374 , Procedure  admp_val_ca_comm is removed
  -- Validate research supervisor principal at commencement.
  FUNCTION resp_val_rsup_comm(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  -- Validate research supervisor percentage.
  FUNCTION resp_val_rsup_perc(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_val_supervision_perc_ind IN VARCHAR2 DEFAULT 'N',
  p_val_funding_perc_ind IN VARCHAR2 DEFAULT 'N',
  p_parent IN VARCHAR2 ,
  p_supervision_start_dt OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES (RESP_VAL_RSUP_PERC, WNDS, WNPS);

  -- Validate research supervisor IGS_PE_PERSON.
  FUNCTION resp_val_rsup_person(
  p_ca_person_id IN NUMBER ,
  p_person_id IN NUMBER ,
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate research supervisor principal.
  FUNCTION resp_val_rsup_princ(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_parent IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES (RESP_VAL_RSUP_PRINC, WNDS, WNPS);
  --
  -- Validate research supervisor replaced supervisor.
  FUNCTION resp_val_rsup_repl(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_replaced_person_id IN NUMBER ,
  p_replaced_sequence_number IN NUMBER ,
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate research supervisor funding percentage.
  FUNCTION resp_val_rsup_fund(
  p_person_id IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_funding_percentage IN NUMBER ,
  p_staff_member_ind IN VARCHAR2 DEFAULT 'N',
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate research supervisor organisational IGS_PS_UNIT.
  FUNCTION resp_val_rsup_ou(
  p_person_id IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_staff_member_ind IN VARCHAR2 DEFAULT 'N',
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate research supervisor overlaps.
  FUNCTION resp_val_rsup_ovrlp(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;



  -- Validate research supervisor end date.
  FUNCTION resp_val_rsup_end_dt(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_sequence_number  NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate if Research Supervisor Type is closed.
  FUNCTION resp_val_rst_closed(
  p_research_supervisor_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

 -- Function to get the Start Date of the Organisation Unit.
 FUNCTION get_org_unit_dtls (
   p_org_unit_cd IN VARCHAR2,
   p_start_dt OUT NOCOPY DATE
 ) RETURN BOOLEAN;


END IGS_RE_VAL_RSUP;

 

/
