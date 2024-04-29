--------------------------------------------------------
--  DDL for Package IGS_AV_VAL_ASU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_VAL_ASU" AUTHID CURRENT_USER AS
/* $Header: IGSAV04S.pls 120.0 2005/07/05 13:04:09 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed
  -- skoppula   15-SEP-2001     Enhancement Bug for Academic Records Maintenance DLD
  --                            To change the credit_percentage logic to include advance standing credit points
  -- nalkumar    11-Sep-2001    Added Parameter 'p_adv_stnd_trans' in advp_val_as_dates, advp_val_expiry_dt
  --				advp_val_status_dts functions.
  --                            These changes has been done as per the Career Impact DLD.
  --                            Bug# 2027984.
  --nalkumar    05-June-2002   Replaced the referances of the igs_av_stnd_unit/unit_lvl.(PREV_UNIT_CD and TEST_DETAILS_ID) columns
  --                           to igs_av_stnd_unit/unit_lvl.(unit_details_id and tst_rslt_dtls_id) columns. This is as per Bug# 2401170
  --
  -- nalkumar 10-Dec-2003       Bug# 3270446 RECR50 Build; Obsoleted the IGS_AV_STND_UNIT.CREDIT_PERCENTAGE column.
  --
 -------------------------------------------------------------------------------------------
/*****  Bug No :   1956374
          Task   :   Duplicated Procedures and functions
          PROCEDURE  advp_val_prclde_unit  is removed
          msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
                      *****/
   -- Bug #1956374
   -- As part of the bug# 1956374 removed the function crsp_val_uv_sys_sts
   -- As part of the bug# 1956374 removed the function crsp_val_uv_exists , advp_val_alt_unit

  -- To validate the advanced standing basis IGS_OR_INSTITUTION code.

  FUNCTION advp_val_asu_inst(
  p_exempt_inst IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- To validate the granting of advanced standing (form level only)
  FUNCTION advp_val_as_frm_grnt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_adv_stnd_granting_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- To validate the various dates of advanced standing units or levels.
  FUNCTION advp_val_as_dates(
  p_advanced_standing_dt IN DATE ,
  p_date_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_adv_stnd_trans IN VARCHAR2 DEFAULT 'N')  -- This parameter has been added for Career Impact DLD.
RETURN BOOLEAN;

  --
  -- Validate the AS recognition type closed indicator.
  FUNCTION advp_val_asrt_closed(
  p_recognition_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- To validate the status dates of advanced standing units or levels.
  FUNCTION advp_val_status_dts(
  p_granting_status IN VARCHAR2 ,
  p_related_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_adv_stnd_trans IN VARCHAR2 DEFAULT 'N')  -- This parameter has been added for Career Impact DLD.
RETURN BOOLEAN;

  --
  -- Routine to save rowids in a PL/SQL TABLE for the current commit.
  -- To validate the approved date of advanced standing units or levels.
  FUNCTION advp_val_as_aprvd_dt(
  p_approved_dt IN DATE ,
  p_related_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  -- To validate the approved date of advanced standing units or levels.
  FUNCTION advp_val_approved_dt(
  p_approved_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- To validate the expiry date of advanced standing units or levels.
  FUNCTION advp_val_expiry_dt(
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_adv_stnd_trans IN VARCHAR2 DEFAULT 'N')  -- This parameter has been added for Career Impact DLD.
RETURN BOOLEAN;


  -- To validate the credit percentage of advanced standing units.
  FUNCTION advp_val_credit_perc(
  p_percentage IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate internal/external advanced standing IGS_PS_COURSE limits.



  FUNCTION advp_val_as_totals(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_include_approved IN BOOLEAN ,
  p_asu_unit_cd IN VARCHAR2 ,
  p_asu_version_number IN NUMBER ,
  p_asu_advstnd_granting_status IN VARCHAR2 ,
  p_asul_unit_level IN VARCHAR2 ,
  p_asul_exmptn_institution_cd IN VARCHAR2 ,
  p_asul_advstnd_granting_status IN VARCHAR2 ,
  p_total_exmptn_approved OUT NOCOPY NUMBER ,
  p_total_exmptn_granted OUT NOCOPY NUMBER ,
  p_total_exmptn_perc_grntd OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_unit_details_id     IN NUMBER DEFAULT NULL,
  p_tst_rslt_dtls_id    IN NUMBER DEFAULT NULL,
  p_asu_exmptn_institution_cd IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;

  --
  -- To get whether delete of student IGS_PS_UNIT attempt is allowed.
  FUNCTION advp_get_ua_del_alwd(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_effective_dt IN DATE )
RETURN BOOLEAN;

  --
  -- To validate the granting of advanced standing.
  FUNCTION advp_val_as_grant(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_adv_stnd_granting_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


-- Record Type for the ref cursor that fetches the advance standing details.
  TYPE adv_cr_rec IS RECORD (credit_percentage igs_av_stnd_unit_all.credit_percentage%TYPE,
  			exemption_institution_cd igs_av_stnd_unit_all.exemption_institution_cd%TYPE,
  			s_adv_stnd_granting_status igs_av_stnd_unit_all.s_adv_stnd_granting_status%TYPE,
  			unit_cd igs_av_stnd_unit_all.unit_cd%TYPE,
  			version_number igs_av_stnd_unit_all.version_number%TYPE,
  			achievable_credit_points igs_av_stnd_unit_all.achievable_credit_points%TYPE);

 g_advcrrec adv_cr_rec;

-- Ref cursor that fetches the advance standing details dynamically depending on the values of previous_unit_cd,
-- test segment id.
 TYPE adv_cp_cur IS REF CURSOR RETURN g_advcrrec%TYPE;

 -- Procedure to compute advance standing credit points.
-- Intorduced as part of Academic Records Maintenance DLD
PROCEDURE advp_get_adv_credit_pts(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_adv_stnd_granting_status IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2,
  p_unit_version IN NUMBER,
  p_unit_details_id     IN NUMBER DEFAULT NULL,
  p_tst_rslt_dtls_id    IN NUMBER DEFAULT NULL,
  p_credit_points OUT NOCOPY NUMBER,
  p_inst_credit_points  OUT NOCOPY NUMBER,
  p_exemption_institution_cd IN VARCHAR2);

-- Function to return advance standing credit points for a program attempt,if any
FUNCTION granted_Adv_standing(p_person_id IN NUMBER,
  p_asu_course_cd IN VARCHAR2 ,
  p_asu_version_number IN NUMBER ,
  p_unit_cd IN VARCHAR2,
  p_version_number IN NUMBER,
  p_s_adv_stnd_granting_status IN VARCHAR2,
  p_effective_dt IN DATE
  ) RETURN VARCHAR2;

  pragma restrict_references(granted_adv_standing,wnds,wnps);

  -- Overloaded Function to return advance standing credit points for an
  -- unit with in an advance standing program attempt
FUNCTION adv_credit_pts(p_person_id IN NUMBER,
  p_asu_course_cd IN VARCHAR2 ,
  p_asu_version_number IN NUMBER ,
  p_unit_cd IN VARCHAR2,
  p_version_number IN NUMBER,
  p_s_adv_stnd_granting_status IN VARCHAR2,
  p_effective_dt IN DATE,
  p_cr_points OUT NOCOPY NUMBER,
  p_adv_grant_status OUT NOCOPY VARCHAR2,
  p_msg OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END IGS_AV_VAL_ASU;

 

/
