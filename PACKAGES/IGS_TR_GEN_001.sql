--------------------------------------------------------
--  DDL for Package IGS_TR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSTR01S.pls 115.8 2002/11/29 04:18:15 nsidana ship $ */
--added new parameter p_override_offset_clc_ind for tracking dld nov2001 release
-- (bug#1837257) to function trkp_clc_dt_offset()
  FUNCTION trkp_clc_action_dt(
    p_tracking_id IN NUMBER ,
    p_tracking_step_number IN NUMBER ,
    p_start_dt IN DATE ,
    p_sequence_ind IN VARCHAR2 DEFAULT 'N',
    p_business_days_ind IN VARCHAR2 DEFAULT 'N')
  RETURN DATE;
  PRAGMA restrict_references (trkp_clc_action_dt, wnds);

  FUNCTION trkp_clc_bus_dt(
    p_start_dt IN DATE ,
    p_business_days IN NUMBER )
  RETURN DATE;
  PRAGMA restrict_references (trkp_clc_bus_dt, wnds,wnps);

  FUNCTION trkp_clc_days_ovrdue(
    p_action_dt IN DATE ,
    p_completion_dt IN DATE ,
    p_business_days_ind IN VARCHAR2 DEFAULT 'N')
  RETURN NUMBER;
  PRAGMA restrict_references (trkp_clc_days_ovrdue, wnds,wnps);

  FUNCTION trkp_clc_dt_offset(
    p_start_dt IN DATE ,
    p_offset_days IN NUMBER ,
    p_business_days_ind IN VARCHAR2 DEFAULT 'N'  ,
    -- added for tracking dld nov2001 release (bug#1837257)
    p_override_offset_clc_ind IN varchar2 DEFAULT 'N' )
  RETURN DATE;
  PRAGMA restrict_references (trkp_clc_dt_offset, wnds,wnps);

  FUNCTION trkp_clc_num_bus_day(
    p_start_dt IN DATE ,
    p_end_dt IN DATE ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN NUMBER;
  PRAGMA restrict_references (trkp_clc_num_bus_day, wnds,wnps);

  FUNCTION trkp_clc_tri_cmp_dt(
    p_tracking_id IN NUMBER ,
    p_start_dt IN DATE )
  RETURN DATE;
  PRAGMA restrict_references (trkp_clc_tri_cmp_dt, wnds,wnps);

END igs_tr_gen_001;

 

/
