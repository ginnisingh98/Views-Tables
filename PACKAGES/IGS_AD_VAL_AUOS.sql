--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AUOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AUOS" AUTHID CURRENT_USER AS
/* $Header: IGSAD46S.pls 120.1 2005/09/08 14:21:21 appldev noship $ */
  -- Validate against the system admission outcome status closed indicator.
  FUNCTION admp_val_saos_clsd(
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  -- Validate the system admission outcome status unit_outcome_ind is Y .
  FUNCTION ADMP_VAL_SAOS_UNIOUT(
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the admission unit outcome status has only one system default
  FUNCTION ADMP_VAL_AUOS_DFLT(
  p_adm_unit_outcome_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  -- PROCEDURE genp_prc_clear_rowid;
  --
  -- Routine to save rowids in a PL/SQL TABLE for the current commit.
  -- PROCEDURE genp_set_rowid(v_rowid  ROWID );

END IGS_AD_VAL_AUOS;

 

/
