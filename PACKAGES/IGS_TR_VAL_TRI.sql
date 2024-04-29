--------------------------------------------------------
--  DDL for Package IGS_TR_VAL_TRI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_VAL_TRI" AUTHID CURRENT_USER AS
/* $Header: IGSTR03S.pls 115.7 2003/02/19 10:22:50 kpadiyar ship $ */
   -- msrinivi bug 1956374 Removed genp_val_prsn_id
  -- Validate that the date is a business day
  FUNCTION genp_val_bus_day(
    p_date IN DATE ,
    p_weekend_ind IN VARCHAR2 DEFAULT 'N',
    p_uni_holiday_ind IN VARCHAR2 DEFAULT 'N',
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA restrict_references (genp_val_bus_day, wnds,wnps);

  -- Validate the status for a tracking item.
  FUNCTION trkp_val_tri_status(
    p_tracking_status IN VARCHAR2 ,
    p_inserting IN BOOLEAN ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  -- Validate the tracking type for a tracking item.
  FUNCTION trkp_val_tri_type(
    p_tracking_type IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  -- Validate the tracking item start date.
  FUNCTION trkp_val_tri_strt_dt(
    p_start_dt IN DATE ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  -- Check for tracking type step catalog validity
   FUNCTION val_tr_step_ctlg(
    		p_step_catalog_cd IN VARCHAR2 ,
    		p_message_name OUT NOCOPY VARCHAR2 )
 	RETURN BOOLEAN;
END igs_tr_val_tri;

 

/
