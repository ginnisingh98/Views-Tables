--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_CCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_CCI" AUTHID CURRENT_USER AS
/* $Header: IGSCO06S.pls 115.5 2002/11/28 23:04:16 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cort_closed"
  -------------------------------------------------------------------------------------------

  -- Validate that the correspondence type is  eligible for the category
  FUNCTION corp_val_cci_elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_correspondence_type IN VARCHAR2 ,
  p_job_name IN VARCHAR2 ,
  p_output_num IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN;
  --
  -- Validate for correspondence category item duplicates.
  FUNCTION corp_val_cci_duplict(
  p_correspondence_cat IN VARCHAR2 ,
  p_correspondence_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY varchar2)
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_cci_duplict,WNDS);
END IGS_CO_VAL_CCI;

 

/
