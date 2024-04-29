--------------------------------------------------------
--  DDL for Package IGS_TR_VAL_TRST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_VAL_TRST" AUTHID CURRENT_USER AS
/* $Header: IGSTR04S.pls 115.8 2002/11/29 04:19:09 nsidana ship $ */
  /* Bug 1956374
   Who msrinivi
   What duplicate removal Removed genp_val_bus_day,genp_val_prsn_id
  */
  -- Validate that the tracking step completion date set correctly.
  FUNCTION trkp_val_trst_cd_set(
    p_tracking_id IN NUMBER ,
    p_tracking_step_number IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  -- Validate the step completion indicator against step completion date
  FUNCTION trkp_val_trst_sci_cd(
    p_step_completion_ind IN VARCHAR2 DEFAULT 'N',
    p_completion_dt IN DATE ,
    p_by_pass_ind IN VARCHAR2 DEFAULT 'N',
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA restrict_references(trkp_val_trst_sci_cd, wnds,wnps);


  -- Validate the tracking step type within the tracking type.
  FUNCTION trkp_val_stst_stt(
    p_s_tracking_step_type IN VARCHAR2 ,
    p_tracking_type IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

END igs_tr_val_trst;

 

/
