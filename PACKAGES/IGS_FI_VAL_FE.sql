--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FE" AUTHID CURRENT_USER AS
/* $Header: IGSFI29S.pls 115.6 2002/11/29 00:21:13 nsidana ship $ */

-- bug id : 1956374
-- sjadhav ,28-aug-2001
-- remove function enrp_val_et_closed
  --
 /****************************
Removed the functions shown below as part of bug 2126091 by sykrishn - 30112001
1) finp_val_fe_dai
2) finp_val_fe_ft
3) finp_val_fe_offset
4) finp_val_fe_ins
5) finp_val_fe_create
*****************************/
  -- Validate IGS_FI_FEE_ENCMB dt alias.
--  Removed the function as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate IGS_FI_FEE_ENCMB fee type
 --  Removed the function as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate IGS_FI_FEE_ENCMB offsets.
 --  Removed the function as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate IGS_FI_FEE_ENCMB insert.
 --  Removed the function as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate appropriate fields set for relation type.
  FUNCTION finp_val_sched_mbrs(
  p_fee_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_sched_mbrs,WNDS);
  --
  -- Validate fee encumbrance can be created for the relation type.
 --  Removed the function as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate insert of FE does not clash currency with FCFL definitions
  FUNCTION finp_val_fe_cur(
  p_fee_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fe_cur,WNDS);
END IGS_FI_VAL_FE;

 

/
