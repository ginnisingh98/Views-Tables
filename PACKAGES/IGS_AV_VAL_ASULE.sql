--------------------------------------------------------
--  DDL for Package IGS_AV_VAL_ASULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_VAL_ASULE" AUTHID CURRENT_USER AS
/* $Header: IGSAV06S.pls 115.5 2002/11/28 22:53:22 nsidana ship $ */

--
-- bug id : 1956374
-- sjadhav , 28-aug-2001
-- removed function ENRP_VAL_EXCLD_PRSN
--
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn
  --                            removed
  -------------------------------------------------------------------------------------------
/*****  Bug No :   1956374
          Task   :   Duplicated Procedures and functions
          PROCEDURE  admp_val_approved_dt  is removed
                     admp_val_as_aprvd_dt is removed
                     advp_val_as_dates is removed
                     advp_val_as_totals is removed
                     advp_val_asu_inst is removed
                     advp_val_expiry_dt is removed
                     advp_val_status_dts is removed
--msrinivi 24-AUG-2001   genp_val_prsn_id removed
                      *****/



  -- Validate the IGS_PS_UNIT level closed indicator.
  FUNCTION advp_val_ule_closed(
  p_unit_level IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


END IGS_AV_VAL_ASULE;

 

/
