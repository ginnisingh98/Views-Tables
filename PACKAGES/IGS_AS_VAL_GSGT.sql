--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_GSGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_GSGT" AUTHID CURRENT_USER AS
/* $Header: IGSAS25S.pls 115.4 2002/11/28 22:45:52 nsidana ship $ */
-- Bug # 1956374  , Procedure assp_val_gs_cur_fut is removed



  --
  -- Validate grade may not be translated against another grade in same ver
  FUNCTION assp_val_gsgt_gs_gs(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate grade may not be translated against more than 1 grade
  FUNCTION assp_val_gsgt_multi(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_to_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate rslt type for grade is same as rslt type for xlation grade
  FUNCTION assp_val_gsgt_result(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_to_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate is SUAO exist when changing/deleting translations
  FUNCTION assp_val_gsgt_suao(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_to_grading_schema_cd IN VARCHAR2 ,
  p_to_version_number IN NUMBER ,
  p_to_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

END IGS_AS_VAL_GSGT;

 

/
