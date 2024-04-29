--------------------------------------------------------
--  DDL for Package IGS_EN_ELGBL_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ELGBL_PERSON" AUTHID CURRENT_USER AS
/* $Header: IGSEN78S.pls 120.2 2006/09/19 12:14:56 amuthu noship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUN-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Eligibility and Validation
  --          This package deals with the holds and person step validation. It has following
  --          functions:
  --             i)  eval_deny_all_hold - Validate Deny All Enrollment Hold
  --                 one local function vald_deny_all_hold
  --            ii)  eval_person_steps - Validate Person Steps
  --                 one local function vald_person_steps
  --           iii)  eval_timeslot - Validate Time Slot - Person Level
  --                 one local function - vald_timeslot
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kkillams    20-01-2003      New procedure eval_ss_deny_all_hold and get_enrl_comm_type are added,
  --                            eval_ss_deny_all_hold is a wrapper procedure to eval_deny_all_hold function
  --                            for self service purpose
  --                            get_enrl_comm_type procedure will derives the enrollment category type and
  --                            enrollment commencement type  w.r.t bug 2737703
  --rvangala    16 Jun 2005     Added parameters p_calling_obj and p_create_warning
  --                            in function eval_person_steps
  -- amuthu     18-Sep-2006     Added new function eval_rev_sus_all_hold
  -------------------------------------------------------------------------------------

 FUNCTION eval_deny_all_hold(
                              p_person_id                       IN  NUMBER,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_enrollment_category             IN  VARCHAR2,
                              p_comm_type                       IN  VARCHAR2,
                              p_enrl_method                     IN  VARCHAR2,
                              p_message                        OUT NOCOPY  VARCHAR2
                            )
 RETURN BOOLEAN;

 FUNCTION eval_ss_rev_sus_all_hold (
                              p_person_id                       IN  NUMBER,
                              p_course_cd                       IN  VARCHAR2,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_message                        OUT NOCOPY  VARCHAR2
                            )
 RETURN BOOLEAN;

 FUNCTION eval_person_steps (
                              p_person_id                       IN  NUMBER,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_program_cd                      IN  VARCHAR2,
                              p_program_version                 IN  NUMBER,
                              p_enrollment_category             IN  VARCHAR2,
                              p_comm_type                       IN  VARCHAR2,
                              p_enrl_method                     IN  VARCHAR2,
                              p_message                        OUT NOCOPY  VARCHAR2,
                              p_deny_warn                      OUT NOCOPY  VARCHAR2,
 	                      p_calling_obj                     IN VARCHAR2 ,
                              p_create_warning                  IN VARCHAR2
                            )
 RETURN BOOLEAN;

 FUNCTION eval_timeslot    (
                              p_person_id                       IN  NUMBER,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_uoo_id                          IN  NUMBER,
                              p_enrollment_category             IN  VARCHAR2,
                              p_comm_type                       IN  VARCHAR2,
                              p_enrl_method                     IN  VARCHAR2,
                              p_message                          OUT NOCOPY  VARCHAR2,
			      p_notification_flag               IN VARCHAR2
                            )
 RETURN BOOLEAN;

 PROCEDURE eval_ss_deny_all_hold(
                                 p_person_id                       IN  NUMBER,
                                 p_person_type                     IN  VARCHAR2,
                                 p_course_cd                       IN  VARCHAR2,
                                 p_load_calendar_type              IN  VARCHAR2,
                                 p_load_cal_sequence_number        IN  NUMBER,
                                 p_status                          OUT NOCOPY  VARCHAR2,
                                 p_message                         OUT NOCOPY  VARCHAR2);
 PROCEDURE get_enrl_comm_type(
                               p_person_id                       IN  NUMBER,
                               p_course_cd                       IN  VARCHAR2,
                               p_cal_type                        IN  VARCHAR2,
                               p_cal_seq_number                  IN  NUMBER,
                               p_enrolment_cat                   OUT NOCOPY  VARCHAR2,
                               p_commencement_type               OUT NOCOPY  VARCHAR2,
                               p_message                         OUT NOCOPY  VARCHAR2
                              );


END IGS_EN_ELGBL_PERSON;

 

/
