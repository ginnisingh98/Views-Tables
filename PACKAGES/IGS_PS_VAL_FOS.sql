--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_FOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_FOS" AUTHID CURRENT_USER AS
 /* $Header: IGSPS41S.pls 115.3 2002/11/29 03:03:36 nsidana ship $ */

  --
  -- Validate the field of study government field of study.
  FUNCTION crsp_val_fos_govt(
  p_govt_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_FOS;

 

/
