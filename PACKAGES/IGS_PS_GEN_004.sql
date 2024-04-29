--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_004" AUTHID CURRENT_USER AS
 /* $Header: IGSPS04S.pls 120.0 2005/06/01 16:25:22 appldev noship $ */

TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

PROCEDURE crsp_ins_fsr_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source  IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_dflt_ind IN VARCHAR2 DEFAULT 'N',
  p_restricted_ind IN VARCHAR2 )
;

FUNCTION crsp_val_call_nbr(
    p_cal_type IN IGS_PS_UNIT_OFR_OPT_ALL.cal_type%TYPE ,
    p_ci_sequence_number  IN IGS_PS_UNIT_OFR_OPT_ALL.ci_sequence_number%TYPE,
    p_call_number IN IGS_PS_UNIT_OFR_OPT_ALL.call_number%TYPE
)
   RETURN BOOLEAN;

------------------------------------------------------------------
  --Created by  : ssomani ( Oracle IDC)
  --Date created: 9-APR-2001
  --
  --Purpose:  Created as pasrt of the build for DLD Enrollment Setup : Calendar, Access, Timeslots (Version 1a)
  --          Used for deadline date calculation for Enrollment setup.
  --          Called from IGSPS101.pll and IGSPS083.pll
  --
  --Known limitations/enhancements and/or remarks:
  --1. For the functions Variation_cuttoff, Record_cutoff and Grading_Schema,
  --the parameter p_function_name = 'FUNCTION'
  --For Discontinuation Dealdine calculation p_function_name = NULL
  --2. The parameter p_setup_id is the corresponding setup id from tables IGS_EN_NSU_DLSTP (for FUNCTION) or
  --   IGS_EN_NSD_DLSTP for Discontinuation.
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
FUNCTION recal_dl_date (p_v_uoo_id IGS_PS_USEC_OCCURS_V.uoo_id%TYPE,
				     p_formula_method igs_en_nsu_dlstp.formula_method%TYPE,
				     p_durationdays  IN OUT NOCOPY  igs_en_nstd_usec_dl_v.ENR_DL_TOTAL_DAYS%TYPE,
				     p_round_method    igs_en_nstd_usec_dl_v.round_method%TYPE,
				     p_OffsetDuration    igs_en_nstd_usec_dl_v.offset_duration%TYPE,
			  	     p_offsetdays IN OUT NOCOPY NUMBER,
				     p_function_name 	igs_en_nstd_usec_dl.function_name%type,
				     p_setup_id  igs_en_nstd_usec_dl.non_std_usec_dls_id%type,
                                     p_offset_dt_code   igs_en_nsu_dlstp.offset_dt_code%type,
				     p_msg OUT NOCOPY VARCHAR2
			     )
RETURN DATE;

 ------------------------------------------------------------------
  --Created by  : pradhakr ( Oracle IDC)
  --Date created: 9-APR-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Calendar, Access, Timeslots (Version 1a)
  --          Used for deadline date calculation for Enrollment setup by applying Offset Constraints.
  --          Called from IGSPS101.pll and IGSPS083.pll
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

PROCEDURE calpl_constraint_resolve (
	p_date_val 		IN OUT NOCOPY IGS_EN_NSTD_USEC_DL.ENR_DL_DATE%TYPE,
	p_offset_cnstr_id 	IN IGS_EN_DL_OFFSET_CONS.ENR_DL_OFFSET_CONS_ID%TYPE,
	p_type			IN IGS_EN_NSTD_USEC_DL.FUNCTION_NAME%TYPE,
        p_deadline_type         IN VARCHAR2,
	p_msg_name 		OUT NOCOPY VARCHAR2 );

 FUNCTION f_retention_offset_date ( p_n_uoo_id IN NUMBER,
                                   p_c_formula_method IN VARCHAR2,
                                   p_c_round_method IN VARCHAR2,
                                   p_c_incl_wkend_duration IN VARCHAR2,
                                   p_n_offset_value IN NUMBER
                                 ) RETURN DATE;

FUNCTION get_weekends ( p_d_start_dt IN DATE,
                        p_d_end_dt   IN DATE
                      ) RETURN NUMBER;

PROCEDURE populate_holidays ( p_d_start_dt      IN DATE,
                             p_d_end_dt        IN DATE,
                             p_c_incl_weekends IN VARCHAR2,
                             p_tab_holiday     IN OUT NOCOPY tab_date_type
                           ) ;
FUNCTION duration_days(   p_n_uoo_id              IN NUMBER,
                          p_d_us_st_dt            IN DATE,
                          p_d_end_dt              IN DATE,
                          p_c_formula_method      IN VARCHAR2,
                          p_c_round_method        IN VARCHAR2,
                          p_c_incl_wkend_duration IN VARCHAR2,
                          p_n_offset_value        IN NUMBER,
                          p_c_msg                 OUT NOCOPY VARCHAR2) RETURN DATE;

FUNCTION meeting_days (   p_n_uoo_id              IN NUMBER,
                          p_d_us_st_dt            IN DATE,
                          p_d_end_dt              IN DATE,
                          p_c_formula_method      IN VARCHAR2,
                          p_c_round_method        IN VARCHAR2,
                          p_c_incl_wkend_duration IN VARCHAR2,
                          p_n_offset_value        IN NUMBER,
                          p_c_msg                 OUT NOCOPY VARCHAR2) RETURN DATE;

PROCEDURE sort_date_array (p_tab_array IN OUT NOCOPY tab_date_type);

FUNCTION get_inst_constraint_id RETURN NUMBER;

PROCEDURE round_up( p_c_round_method IN VARCHAR2,
                    p_n_value IN OUT NOCOPY NUMBER);

END IGS_PS_GEN_004;

 

/
