--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_GDHC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_GDHC" AUTHID CURRENT_USER AS
/* $Header: IGSST07S.pls 115.4 2002/11/29 04:11:52 nsidana ship $ */
 --
  --
  -- Ensure the start and end dates don't overlap with other records.
  FUNCTION stap_val_gdhc_ovrlp(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY  VARCHAR2)
  RETURN BOOLEAN;

  --
  -- Validate that only one record has an open end date.
  FUNCTION stap_val_gdhc_open(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY  VARCHAR2)
  RETURN BOOLEAN;
  --
  -- Ensure the govt discipline group id not closed.
  FUNCTION stap_val_gdhc_gd(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
  RETURN BOOLEAN;
  --
  -- Validate that end date is null or >= start date.
  FUNCTION stap_val_gdhc_end_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY  VARCHAR2)
  RETURN BOOLEAN;

  END IGS_ST_VAL_GDHC;

 

/
