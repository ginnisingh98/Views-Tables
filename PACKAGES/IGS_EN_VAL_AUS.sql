--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_AUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_AUS" AUTHID CURRENT_USER AS
/* $Header: IGSEN25S.pls 120.0 2005/06/01 17:52:39 appldev noship $ */

  --
  -- Validate AUSG records exist for an administrative unit status
  FUNCTION enrp_val_aus_ausg(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_aus_ausg,WNDS);

------------------------------------------------------------------
  --Created by  : ashok.Pelleti Oracle India
  --Date created: 3-APR-2001
  --
  --Purpose:To enforce the desired functionality for form IGSEN056.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
FUNCTION calp_val_ddcv_clash(
  p_non_std_disc_dl_stp_id IN NUMBER,
  p_offset_cons_type_cd IN VARCHAR2 ,
  p_constraint_condition IN VARCHAR2 ,
  p_constraint_resolution IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN ;

------------------------------------------------------------------
  --Created by  : ashok.Pelleti Oracle India
  --Date created: 3-APR-2001
  --
  --Purpose:To enforce the desired functionality for form IGSEN055.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk       14-Sep-2004      Bug # 3888835. Added parameter p_deadline_type.
  -------------------------------------------------------------------
FUNCTION calp_val_doscv_clash(
  p_non_std_usec_dls_id IN NUMBER,
  p_offset_cons_type_cd IN VARCHAR2 ,
  p_constraint_condition IN VARCHAR2 ,
  p_constraint_resolution IN NUMBER ,
  p_deadline_type IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN ;

END IGS_EN_VAL_AUS;

 

/
