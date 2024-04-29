--------------------------------------------------------
--  DDL for Package IGS_EN_RPT_PRC_UHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_RPT_PRC_UHK" AUTHID CURRENT_USER AS
/* $Header: IGSEN84S.pls 120.0 2005/06/01 14:02:44 appldev noship $ */
  --
  --  User Hook - which can be customisable by the customer.
  --Change History:
  -- Who         When            What
  -- bdeviset    04-AUG-2004     Removed function repeat_allowed  and added function
  --                             repeat_reenroll_allowed as part of Bug 3807707

  FUNCTION enrf_drv_cmpl_dt_uhk
  (
    p_person_id			   IN	  NUMBER,
    p_course_cd			   IN	  VARCHAR2,
    p_achieved_cp		   IN	  NUMBER,
    p_attendance_type		   IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_ci_seq_number           IN     NUMBER,
    p_load_ci_alt_code		   IN     VARCHAR2,
    p_load_ci_start_dt		   IN	  DATE,
    p_load_ci_end_dt		   IN	  DATE,
    p_init_load_cal_type	   IN	  VARCHAR2,
    p_init_load_ci_seq_num	   IN	  NUMBER,
    p_init_load_ci_alt_code        IN     VARCHAR2,
    p_init_load_ci_start_dt	   IN     DATE,
    p_init_load_ci_end_dt	   IN     DATE
  ) RETURN DATE;

  FUNCTION repeat_reenroll_allowed (
    p_person_id                    IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_repeat_reenroll              IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_ci_seq_number           IN     NUMBER,
    p_mus_ind                      IN     VARCHAR2,
    p_reenroll_max                 IN     NUMBER,
    p_reenroll_max_cp              IN     NUMBER,
    p_repeat_max                   IN     NUMBER,
    p_repeat_funding               IN     NUMBER,
    p_same_tch_reenroll_max        IN     NUMBER,
    p_same_tch_reenroll_max_cp     IN     NUMBER,
    p_message                      OUT    NOCOPY  VARCHAR2
   ) RETURN BOOLEAN;

END igs_en_rpt_prc_uhk;

 

/
