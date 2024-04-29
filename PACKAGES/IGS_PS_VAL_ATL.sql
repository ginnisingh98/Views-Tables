--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_ATL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_ATL" AUTHID CURRENT_USER AS
 /* $Header: IGSPS10S.pls 115.6 2002/11/29 02:56:07 nsidana ship $
   Change History:
   WHO                    WHEN            WHAT
   ayedubat            17-MAY-2001  Added one new procedure,chk_mandatory_ref_cd
-- avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_att_closed"
 */



  -- Validate the calendar type SI_CA_S_CA_CAT = 'LOAD' and closed_ind
  FUNCTION crsp_val_atl_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;


  -- To validate the att type load ranges
  FUNCTION crsp_val_atl_range(
  p_attendance_type IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_lower_enr_load_range IN NUMBER ,
  p_upper_enr_load_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  --To Check the Mandatory Reference Type
  FUNCTION chk_mandatory_ref_cd(
  p_reference_type IN VARCHAR2)
  RETURN BOOLEAN;

END IGS_PS_VAL_ATL;

 

/
