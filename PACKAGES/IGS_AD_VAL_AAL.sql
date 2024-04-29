--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AAL" AUTHID CURRENT_USER AS
/* $Header: IGSAD17S.pls 115.4 2002/11/28 21:26:01 nsidana ship $ */

  --
  -- Validate the correspondence type for an admission application letter.
  FUNCTION admp_val_aal_cort(
  p_correspondence_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate if an unsent adm appl letter exists with the same corres type
  FUNCTION admp_val_aal_exists(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the correspondence type closed indicator.
  FUNCTION corp_val_cort_closed(
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_AAL;

 

/
