--------------------------------------------------------
--  DDL for Package IGS_GE_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSGE04S.pls 115.12 2003/04/11 07:45:28 smanglm ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  --smadathi    25-AUG-2001     Bug No. 1956374 .Modified function GENP_VAL_SDTT_SESS
  --msrinivi    25-Aug-2001     Bug No. 1956374. Removed and pointed genp_val_bus_day to igs_tr_val_tri
  -------------------------------------------------------------------------------------------
FUNCTION GENP_GET_WHO_NAME(p_last_updated_by   IN NUMBER)
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(GENP_GET_WHO_NAME, WNDS);

FUNCTION GENP_GET_LOOKUP(
  p_lookup_type           IN VARCHAR2,
  p_lookup_code           IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(GENP_GET_LOOKUP, WNDS);

FUNCTION GENP_UPD_ST_LGC_DEL(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION GENP_VAL_ADT_CRSP(
  p_addr_type FND_LOOKUP_VALUES.lookup_code%TYPE,
  p_crsp_ind IGS_PE_HZ_LOCATIONS.correspondence%TYPE)
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(GENP_VAL_ADT_CRSP, WNDS, WNPS);

FUNCTION JBSP_GET_DT_PICTURE(
  p_char_dt IN VARCHAR2 ,
  p_dt_picture OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION get_day (
    p_day_short_name IN VARCHAR2
  ) RETURN VARCHAR2;

FUNCTION get_POSITIVE_NUM (
    P_NUMBER  IN NUMBER
  ) RETURN VARCHAR2;

FUNCTION get_unit_set_title (p_unit_set_cd VARCHAR2) RETURN VARCHAR2;

END IGS_GE_GEN_004 ;

 

/
