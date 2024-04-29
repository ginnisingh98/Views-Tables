--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_ENCMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_ENCMB" AUTHID CURRENT_USER AS
/* $Header: IGSEN37S.pls 120.1 2006/05/18 11:31:57 amuthu noship $ */

/*------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA       |
 |                            All rights reserved.                              |
 +==============================================================================+
 |                                                                              |
 | DESCRIPTION                                                                  |
 |      PL/SQL Spec for package: IGS_EN_VAL_ENCMB                               |
 |                                                                              |
 |                                                                              |
 | HISTORY                                                                      |
 | Who        When         What                                                 |
 | amuthu     18-May-2006  Modified the spec for ENRP_VAL_ENR_ENCMB to pass the |
 |                         the effective date                                   |
 |-----------------------------------------------------------------------------*/
  --
  -- Validate whether a IGS_PE_PERSON is excluded from a IGS_PS_UNIT.
  FUNCTION enrp_val_excld_unit(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_excld_unit,WNDS);
  --
  -- Validate whether or not a IGS_PE_PERSON is excluded from the university.
  FUNCTION enrp_val_excld_prsn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES (enrp_val_excld_prsn,WNDS,WNPS);
  --
  -- Validate whether a IGS_PE_PERSON is excluded from a IGS_PS_COURSE.
  FUNCTION enrp_val_excld_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES (enrp_val_excld_crs,WNDS,WNPS);
  --
  -- Validate whether a IGS_PE_PERSON is excluded from a IGS_PS_UNIT set.
  FUNCTION enrp_val_excld_us(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_excld_us,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON is enrolled in all required units.
  FUNCTION enrp_val_rqrd_units(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_rqrd_units,WNDS);
  --
  -- Validate whether or not a IGS_PE_PERSON is restricted to an attendance type.
  FUNCTION enrp_val_rstrct_atyp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_restricted_attendance_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_rstrct_atyp,WNDS);
  --
  -- Validate whether or not a IGS_PE_PERSON is restricted to an enrolment cp.
  FUNCTION enrp_val_rstrct_cp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_rstrct_le_cp_value OUT NOCOPY NUMBER ,
  p_rstrct_ge_cp_value OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_rstrct_cp,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking IGS_PS_COURSE material.
  FUNCTION enrp_val_blk_crsmtrl(
  p_person_id IN NUMBER ,
  p_course_cd  VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_blk_crsmtrl,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking graduation.
  FUNCTION enrp_val_blk_grd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_blk_grd,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking their ID card.
  FUNCTION enrp_val_blk_id_card(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_blk_id_card,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking the info booth.
  FUNCTION enrp_val_blk_inf_bth(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_blk_inf_bth,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking issue of results
  FUNCTION enrp_val_blk_result(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_blk_result,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking system corresp.
  FUNCTION enrp_val_blk_sys_cor(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_blk_sys_cor,WNDS);
  --
  -- Validate whether a IGS_PE_PERSON has an encumbrance blocking acad transcript.
  FUNCTION enrp_val_blk_trscrpt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_blk_trscrpt,WNDS);
  --
  -- Valiate enrolment encumbrances related to load periods
  FUNCTION ENRP_VAL_ENR_ENCMB(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_message_name2 OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2,
  p_effective_dt IN DATE DEFAULT NULL)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (ENRP_VAL_ENR_ENCMB,WNDS);

END IGS_EN_VAL_ENCMB;

 

/
