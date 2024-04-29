--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CRFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CRFC" AUTHID CURRENT_USER AS
 /* $Header: IGSPS32S.pls 115.3 2002/11/29 03:01:45 nsidana ship $ */

  --
  --
  -- Validate the reference code type
  FUNCTION crsp_val_ref_cd_type(
  p_reference_cd_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate that only one open reference code type exists
  FUNCTION crsp_val_crfc_rct(
  p_course_cd IN IGS_PS_REF_CD.course_cd%TYPE ,
  p_version_number IN IGS_PS_REF_CD.version_number%TYPE ,
  p_reference_cd_type IN VARCHAR2 ,
  p_reference_cd IN IGS_PS_REF_CD.reference_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
END IGS_PS_VAL_CRFC;

 

/
