--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_CRDP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_CRDP" AUTHID CURRENT_USER AS
/* $Header: IGSGR07S.pls 115.4 2002/11/29 00:40:46 nsidana ship $ */
  --
  -- Warn if ins/upd/del on crdp if after start date of crd.
  FUNCTION grdp_val_crdp_iud(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_GR_VAL_CRDP;

 

/
