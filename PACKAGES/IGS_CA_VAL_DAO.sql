--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_DAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_DAO" AUTHID CURRENT_USER AS
/* $Header: IGSCA11S.pls 115.3 2002/11/28 22:58:47 nsidana ship $ */
  -- Validate IGS_CA_DA_OFST
  FUNCTION calp_val_dao_ins(
  p_dt_alias IN VARCHAR2 ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_CA_VAL_DAO;

 

/
