--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_THE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_THE" AUTHID CURRENT_USER AS
/* $Header: IGSRE16S.pls 115.5 2002/11/29 10:55:21 pradhakr ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --Nishikant   19NOV2002       Bug#2661533. The signature of the functions resp_val_the_expct, resp_val_the_embrg,
  --                            resp_val_the_thr got modified to add one more parameer p_legacy.
  --                            Three more functions get_candidacy_dtls, check_dup_thesis, eval_min_sub_dt are added.
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed
  -- pradhakr   29-Nov-2002     Added the hint NOCOPY to all the OUT parameters. Replaced all
  --				the OUT parameter with OUT NOCOPY. Bug# 2683043
  -------------------------------------------------------------------------------------------
    -- To valdate IGS_RE_THESIS citation fiels
  FUNCTION RESP_VAL_THE_CTN(
  p_thesis_status IN VARCHAR2 ,
  p_citation IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_THESIS logical deletion date
  FUNCTION RESP_VAL_THE_DEL_DT(
  p_old_logical_delete_dt IN DATE ,
  p_new_logical_delete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate the IGS_RE_THESIS expected submission date
  FUNCTION RESP_VAL_THE_EXPCT(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_expected_submission_dt IN DATE ,
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate IGS_RE_THESIS embargo details
  FUNCTION RESP_VAL_THE_EMBRG(
  p_embargo_details IN VARCHAR2 ,
  p_old_embargo_expiry_dt IN DATE ,
  p_new_embargo_expiry_dt IN DATE ,
  p_thesis_status IN VARCHAR2 ,
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_THESIS deletion (logical deletion)
  FUNCTION RESP_VAL_THE_DEL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_logical_delete_dt IN DATE ,
  p_thesis_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate IGS_RE_THESIS library details
  FUNCTION RESP_VAL_THE_LBRY(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_library_catalogue_number IN VARCHAR2 ,
  p_library_lodgement_dt IN DATE ,
  p_thesis_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate the IGS_RE_THESIS result code
  FUNCTION RESP_VAL_THE_THR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_thesis_status IN VARCHAR2 ,
  p_legacy IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate the update of the IGS_RE_THESIS table.
  FUNCTION RESP_VAL_THE_UPD(
  p_logical_delete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate the IGS_RE_THESIS IGS_PE_TITLE
  FUNCTION RESP_VAL_THE_TTL(
  p_old_title IN VARCHAR2 ,
  p_new_title IN VARCHAR2 ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate IGS_RE_THESIS finalised_title_indicator
  FUNCTION RESP_VAL_THE_FNL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_final_title_ind IN VARCHAR2 ,
  p_thesis_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  FUNCTION get_candidacy_dtls (
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_ca_sequence_number OUT NOCOPY NUMBER )
RETURN BOOLEAN;

FUNCTION check_dup_thesis(
  p_person_id IN NUMBER ,
  p_title IN VARCHAR2 ,
  p_ca_sequence_number IN NUMBER )
RETURN BOOLEAN;

FUNCTION eval_min_sub_dt (
  p_expected_submission_date IN DATE,
  p_ca_sequence_number  IN NUMBER ,
  p_person_id IN NUMBER )
RETURN BOOLEAN;

END IGS_RE_VAL_THE;

 

/
