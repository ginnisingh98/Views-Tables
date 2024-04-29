--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_GFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_GFS" AUTHID CURRENT_USER AS
/* $Header: IGSPS49S.pls 115.3 2002/11/29 03:05:57 nsidana ship $ */
  --
  -- To validate the update of a government funding source record
  FUNCTION crsp_val_gfs_upd(
  p_govt_funding_source IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_GFS;

 

/
