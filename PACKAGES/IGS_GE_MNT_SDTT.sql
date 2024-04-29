--------------------------------------------------------
--  DDL for Package IGS_GE_MNT_SDTT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_MNT_SDTT" AUTHID CURRENT_USER AS
/* $Header: IGSGE06S.pls 115.7 2002/11/29 00:32:23 nsidana ship $ */
  --
  -- Delete a record in the table s_disable_table_trigger.
  PROCEDURE GENP_DEL_SDTT(
  p_table_name IN VARCHAR2 )
;
  -- Validate whether the person is a staff member
FUNCTION pid_val_staff
(p_person_id IN NUMBER,
 p_preferred_name OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN;

-- This function takes a varchar string and a format mask and checks whether the string is in the passed format or not. Bug : 2325141
FUNCTION check_format_mask(s IN VARCHAR2, t IN VARCHAR2) RETURN BOOLEAN;

END IGS_GE_MNT_SDTT;

 

/
