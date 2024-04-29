--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CUL" AUTHID CURRENT_USER AS
 /* $Header: IGSPS38S.pls 115.5 2003/12/05 06:05:48 nalkumar ship $ */
 -- Bug #1956374
 -- As part of the bug# 1956374 removed the function  crsp_val_unit_lvl

  -- Validate IGS_PS_COURSE Code.
  FUNCTION crsp_val_crs_type(
    p_course_cd IN VARCHAR2 ,
    p_course_version_number IN NUMBER,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
END IGS_PS_VAL_CUL;

 

/
