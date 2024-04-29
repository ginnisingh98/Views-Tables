--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_FCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_FCM" AUTHID CURRENT_USER AS
/* $Header: IGSAD61S.pls 115.4 2002/11/28 21:37:40 nsidana ship $ */

/*
 --Bug # 1956374
 -- Removed duplicate proc finp_val_fc_closed
 -- msrinivi, 24 aug,2001
*/
 -- Validate that default fee cat is not closed.
  FUNCTION admp_val_fcm_dflt_2(
  p_fee_cat IN VARCHAR2 ,
  p_dflt_cat_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate that one fee cat is marked as the default for the adm cat.
  FUNCTION admp_val_fcm_dflt_1(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if the fee cat can be marked as the default for the adm cat.
  FUNCTION admp_val_fcm_dflt(
  p_admission_cat IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 -- Validate if IGS_FI_FEE_CAT.fee_cat is closed.
  FUNCTION finp_val_fc_closed(
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_FCM;

 

/
