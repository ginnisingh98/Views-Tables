--------------------------------------------------------
--  DDL for Package IGS_RU_VAL_RGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_VAL_RGI" AUTHID CURRENT_USER AS
/* $Header: IGSRU07S.pls 115.4 2002/02/12 17:30:54 pkm ship    $ */

  --
  -- Populate IGS_RU_GROUP_SET from IGS_RU_GROUP_ITEM
  PROCEDURE rulp_ins_rgi
;
  --
  -- To set gv_group_number
  PROCEDURE rulp_set_rgi(
  P_RUG_SEQUENCE_NUMBER  NUMBER ,
  P_DESCRIPTION_NUMBER  NUMBER ,
  P_DESCRIPTION_TYPE  VARCHAR2 )
;
  --
  -- To verify if the insert group can be inserted into the current group.
  FUNCTION rulp_val_grp_rgi
RETURN BOOLEAN;
   PRAGMA RESTRICT_REFERENCES(RULP_VAL_GRP_RGI,WNDS);

END IGS_RU_VAL_RGI;

 

/
