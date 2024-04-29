--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_API" AUTHID CURRENT_USER AS
/* $Header: IGSEN23S.pls 120.1 2005/08/29 08:01:02 appldev ship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --pkpatel    8-JUN-2002       Bug No: 2402077
  --                            Added Functions val_overlap_api, val_ssn_overlap_api, fm_equal, unformat_api
  --jbegum      29-AUG-2001     Bug No. 1956374 . Removed function enrp_val_api_end_dt
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_STRT_END_DTS
  --                            removed.
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed.
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function declaration of genp_set_rowid
  --                            removed.
  -------------------------------------------------------------------------------------------
  --
  TYPE t_api_rowids IS TABLE OF
  ROWID
  INDEX BY BINARY_INTEGER;

  gt_rowid_table t_api_rowids;
  gt_empty_table t_api_rowids;
  gv_table_index BINARY_INTEGER;

   -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  PROCEDURE genp_prc_clear_rowid;

  -- Routine to process api rowids in a PL/SQL TABLE for the current commit
  FUNCTION enrp_prc_api_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;


  -- Validate the payment advice number is unique.
  FUNCTION enrp_val_api_pan(
  p_person_id  IGS_PE_ALT_PERS_ID.pe_person_id%TYPE ,
  p_pay_advice_number  IGS_PE_ALT_PERS_ID.api_person_id%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Check Overlapping period for Person Id Types
  FUNCTION val_overlap_api(
  p_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
  RETURN BOOLEAN;

  -- Check Overlapping period for Person Id Types associated with System Person ID type SSN
  FUNCTION val_ssn_overlap_api(
  p_person_id   IGS_PE_ALT_PERS_ID_V.PE_PERSON_ID%TYPE)
  RETURN BOOLEAN;

  -- To compare the Format mask whether it contains any character other than 9,X and special character.
  FUNCTION fm_equal(
   p_format_mask IN igs_pe_person_id_typ.format_mask%TYPE,
   p_frmt_msk_copy IN igs_pe_person_id_typ.format_mask%TYPE)
  RETURN BOOLEAN;

  -- To unformat the Formatted Alternate Person ID.
  FUNCTION unformat_api(
  p_api_pers_id IN igs_pe_alt_pers_id.api_person_id%TYPE)
  RETURN VARCHAR2;

  -- wrapper function To compare the Format mask whether it contains any character other than 9,X and special character.
  -- This function would be called from SS
  FUNCTION fm_equal_wrap(
   p_format_mask IN igs_pe_person_id_typ.format_mask%TYPE,
   p_frmt_msk_copy IN igs_pe_person_id_typ.format_mask%TYPE)
  RETURN NUMBER;
END IGS_EN_VAL_API;

 

/
