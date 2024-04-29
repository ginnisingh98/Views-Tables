--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_008" AUTHID CURRENT_USER AS
 /* $Header: IGSPS08S.pls 120.1 2005/10/04 00:16:41 appldev ship $ */
 /*----------------------------------------------------------------------------
   ||  Created By :
   ||  Created On :
   ||  Purpose :
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  (reverse chronological order - newest change first)
   ||  sarakshi       17-oct-2003     Enh#3168650,added parameter p_c_message_superior in crsp_ins_unit_ver
 ----------------------------------------------------------------------------*/

PROCEDURE crsp_ins_unit_set(
  p_old_unit_set_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_new_unit_set_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
;

PROCEDURE crsp_ins_unit_ver(
  p_old_unit_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_new_unit_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_c_message_superior OUT NOCOPY VARCHAR2)
;

FUNCTION crsp_ins_uop_uoo(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_source_ci_sequence_number IN NUMBER ,
  p_dest_ci_sequence_number IN NUMBER ,
  p_source_cal_type IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2,
  p_log_creation_date DATE DEFAULT SYSDATE
   )
RETURN BOOLEAN;

END IGS_PS_GEN_008;


 

/
