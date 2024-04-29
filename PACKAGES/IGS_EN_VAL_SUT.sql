--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SUT" AUTHID CURRENT_USER AS
/* $Header: IGSEN70S.pls 120.0 2005/06/01 18:27:54 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed .
  -- kkillams   28-04-2003      Added new parameter p_uoo_id to the enrp_val_sut_delete and
  --                            enrp_val_sut_insert functions w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------

  -- To validate for student UNIT transfer on delete.
  FUNCTION enrp_val_sut_delete(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
RETURN BOOLEAN;
  --
--PRAGMA RESTRICT_REFERENCES( enrp_val_sut_delete , WNDS);

  -- To validate for student UNIT transfer on insert.
  FUNCTION enrp_val_sut_insert(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_transfer_course_cd          IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN NUMBER)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sut_insert , WNDS);
END IGS_EN_VAL_SUT;

 

/
