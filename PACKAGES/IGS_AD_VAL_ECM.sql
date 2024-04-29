--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ECM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ECM" AUTHID CURRENT_USER AS
/* $Header: IGSAD55S.pls 115.4 2002/11/28 21:36:22 nsidana ship $ */
  -- Validate that default enr cat is not closed.
  FUNCTION admp_val_ecm_dflt_2(
  p_enrolment_cat IN VARCHAR2 ,
  p_dflt_cat_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;
  -- Validate that one enr cat is marked as the default for the adm cat.
  FUNCTION admp_val_ecm_dflt_1(
  p_admission_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  -- Validate if the enr cat can be marked as the default for the adm cat.
  FUNCTION admp_val_ecm_dflt(
  p_admission_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the enrolment category closed indicator
  FUNCTION enrp_val_ec_closed(
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate if IGS_AD_CAT.admission_cat is closed.


END IGS_AD_VAL_ECM;

 

/
