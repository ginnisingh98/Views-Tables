--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_COOAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_COOAC" AUTHID CURRENT_USER AS
/* $Header: IGSAD50S.pls 115.4 2002/11/28 21:35:14 nsidana ship $ */
  -- Validate if IGS_AD_CAT.admission_cat is closed.

    /*****  Bug No :   1956374
        Task   :   Duplicated Procedures and functions
        PROCEDURE  admp_val_ac_closed is removed and reference is changed  *****/

  -- Validates if the admission cat is in an admission cat course type
    FUNCTION admp_val_ac_acct(
     p_admission_cat IN VARCHAR2 ,
     p_course_cd IN VARCHAR2 ,
     p_version_number IN NUMBER ,
     p_message_name OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN;

END IGS_AD_VAL_COOAC;

 

/
