--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_FS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_FS" AUTHID CURRENT_USER AS
 /* $Header: IGSPS42S.pls 115.3 2002/11/29 03:03:52 nsidana ship $ */

  --
  -- Validate the funding source government funding source.
  FUNCTION crsp_val_fs_govt(
  p_govt_funding_source IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_FS ;

 

/
