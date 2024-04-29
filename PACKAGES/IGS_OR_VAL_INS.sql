--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_INS" AUTHID CURRENT_USER AS
/* $Header: IGSOR03S.pls 115.4 2002/11/29 01:46:20 nsidana ship $ */

 /*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO           WHEN          WHAT
  ||  pkpatel     5-MAR-2002     Bug NO: 2224621
  ||                             Modified the field GOVT_INSTITUTION_CD from NUMBER to VARCHAR2
  ||                             in Procedure ORGP_VAL_GOVT_CD
  ||  (reverse chronological order - newest change first)
  */

  --
  -- Validate the delete of an instn code on records with no foreign key.
  FUNCTION orgp_val_instn_del(
  p_institution_cd IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the government institution code.
  FUNCTION orgp_val_govt_cd(
  p_govt_institution_cd IN  VARCHAR2,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN Boolean;
  --
  -- Validate the institution status.
  FUNCTION orgp_val_instn_sts(
  p_institution_cd IN VARCHAR2 ,
  p_institution_status IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN Boolean;
  --
  -- Validate no active org units are associated with the specified instn.
  FUNCTION orgp_val_no_actv_ou(
  p_institution_cd IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN Boolean;
  --
  -- Validate the local indicator is for only one institution
  FUNCTION orgp_val_ins_local(
  p_institution_cd IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
--  PROCEDURE genp_prc_clear_rowid;
  --
  -- Routine to save rowids in a PL/SQL TABLE for the current commit.

END IGS_OR_VAL_INS;

 

/
