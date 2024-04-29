--------------------------------------------------------
--  DDL for Package IGS_PE_VAL_PIGM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_VAL_PIGM" AUTHID CURRENT_USER AS
  /* $Header: IGSPE01S.pls 115.7 2002/11/29 01:49:56 nsidana ship $ */
  ------------------------------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi  27-sep-2001    Added function merged_ind as a part of person Detail build.bug no:2000408
  ----------------------------------------------------------------------------------------------
  -- Validate IGS_PE_PERSON id group member ins/upd/del security
  FUNCTION idgp_val_pigm_iud(
  p_group_id IN IGS_PE_PERSID_GROUP_ALL.group_id%TYPE ,
  p_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  FUNCTION merged_ind(p_person_id  IN NUMBER)
  RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (merged_ind,WNDS);
  END IGS_PE_VAL_PIGM;

 

/
