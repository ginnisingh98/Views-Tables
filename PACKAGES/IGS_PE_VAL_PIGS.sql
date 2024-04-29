--------------------------------------------------------
--  DDL for Package IGS_PE_VAL_PIGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_VAL_PIGS" AUTHID CURRENT_USER AS
  /* $Header: IGSPE02S.pls 115.5 2002/11/29 01:50:11 nsidana ship $ */


  --
  -- Validate IGS_PE_PERSON id group security ins/upd/del security
  FUNCTION idgp_val_pigs_iud(
  p_group_id IN IGS_PE_PERSID_GROUP_ALL.group_id%TYPE ,
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (idgp_val_pigs_iud,WNDS);
END IGS_PE_VAL_PIGS;

 

/
