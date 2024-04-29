--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_CCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_CCM" AUTHID CURRENT_USER AS
 /* $Header: IGSAD48S.pls 115.4 2002/11/28 21:34:43 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cc_closed"
  -------------------------------------------------------------------------------------------


  -- Validate that default correspondence cat is not closed.
  FUNCTION admp_val_ccm_dflt_2(
   p_correspondence_cat IN VARCHAR2 ,
   p_dflt_cat_ind IN VARCHAR2 DEFAULT 'N',
   p_message_name	OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  -- Validate that one cor cat is marked as the default for the adm cat.
  FUNCTION admp_val_ccm_dflt_1(
   p_admission_cat IN VARCHAR2 ,
   p_message_name	OUT NOCOPY VARCHAR2 ,
   p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  -- Validate if the cor cat can be marked as the default for the adm cat.
  FUNCTION admp_val_ccm_dflt(
   p_admission_cat IN VARCHAR2 ,
   p_correspondence_cat IN VARCHAR2 ,
   p_message_name	OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;


END IGS_AD_VAL_CCM;

 

/
