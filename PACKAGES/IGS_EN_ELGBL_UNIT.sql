--------------------------------------------------------
--  DDL for Package IGS_EN_ELGBL_UNIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ELGBL_UNIT" AUTHID CURRENT_USER AS
/* $Header: IGSEN80S.pls 120.5 2005/10/10 05:40:27 appldev ship $ */
/*--------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA         |
 |                            All rights reserved.                                |
 +================================================================================+
 |                                                                                |
 | DESCRIPTION                                                                    |
 |      PL/SQL spec for package: igs_en_elgbl_unit                                |
 |                                                                                |
 | NOTES                                                                          |
 |                                                                                |
 |                                                                                |
 | HISTORY                                                                        |
 | Who         When           What
 |bdeviset		17-JUN-2005		Modified for SSUI build.Bug# 4377985
 | ctyagi      20-SEPT-2005  Modified eval_rsv_seat  for Bug 4362302
 |ctyagi      22-sept-2005  Added p_enroll_from_waitlsit_flag  as a part of bug 4580204
 ctyagi      26-sept-2005  Removed p_enroll_from_waitlsit_flag  as a part of bug 4580204
 | amuthu     10-Oct-2005   Added new function eval_award_prog_only for bug 4381229
 */
  --
  FUNCTION eval_unit_steps (
    p_person_id                    IN     NUMBER,
    p_person_type                  IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_enrollment_category          IN     VARCHAR2,
    p_enr_method_type              IN     VARCHAR2,
    p_comm_type                    IN     VARCHAR2,
    p_message                      OUT NOCOPY    VARCHAR2,
    p_deny_warn                    OUT NOCOPY    VARCHAR2,
	p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_unit_ss_allowed (
    p_person_id                    IN     NUMBER,
		p_course_cd										 IN			VARCHAR2,
    p_person_type                  IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_program_check (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_rule_seq_number              IN     NUMBER,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_unit_forced_location (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_unit_forced_mode (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  --smaddali added two new parameters for PSCR014 ccr on academic records maintenance dld
  --also modified p_program_version from varchar2 to number
  FUNCTION eval_unit_repeat (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_repeat_tag                   OUT NOCOPY    VARCHAR2,
    p_unit_cd                      IN     VARCHAR2  DEFAULT NULL,
    p_unit_version                 IN     NUMBER DEFAULT NULL,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;

  --
  FUNCTION eval_time_conflict
  (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     VARCHAR2,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_prereq (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_coreq (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_incompatible (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
		p_calling_obj                  IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_spl_permission (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_rsv_seat (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
	p_calling_obj                  IN			VARCHAR2,
    p_deny_enrollment              OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_cart_max (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_rule_seq_number              IN     NUMBER
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_intmsn_unit_lvl (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     VARCHAR2,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_rule_seq_number              IN     NUMBER,
		p_calling_obj									 IN			VARCHAR2
  ) RETURN BOOLEAN;
  --
  FUNCTION eval_visa_unit_lvl (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     VARCHAR2,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_rule_seq_number              IN     NUMBER,
		p_calling_obj									 IN			VARCHAR2
  ) RETURN BOOLEAN;
  --

  FUNCTION eval_audit_permission (
		p_person_id             IN NUMBER,
		p_load_cal_type         IN VARCHAR2,
		p_load_sequence_number  IN VARCHAR2,
		p_uoo_id                IN NUMBER,
		p_course_cd             IN VARCHAR2,
		p_course_version        IN NUMBER,
		p_message               IN OUT NOCOPY VARCHAR2,
		p_deny_warn             IN VARCHAR2
	 ) RETURN BOOLEAN ;

  FUNCTION eval_unit_reenroll (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     NUMBER,
    p_deny_warn                    IN     VARCHAR2,
    p_upd_cp                       IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_val_level									   IN     VARCHAR2 DEFAULT 'ALL',
		p_calling_obj									 IN			VARCHAR2
  ) RETURN BOOLEAN;

 FUNCTION eval_student_audit_limit(
		p_person_id             IN NUMBER,
		p_load_cal_type         IN VARCHAR2,
		p_load_sequence_number  IN VARCHAR2,
		p_uoo_id                IN NUMBER,
		p_course_cd             IN VARCHAR2,
		p_course_version        IN NUMBER,
		p_message               IN OUT NOCOPY VARCHAR2,
		p_deny_warn             IN VARCHAR2,
		p_stud_audit_lim        IN NUMBER,
		p_calling_obj									 IN			VARCHAR2
	 ) RETURN BOOLEAN;

FUNCTION eval_award_prog_only(
		p_person_id             IN NUMBER,
        p_person_type       IN VARCHAR2,
        p_load_cal_type         IN VARCHAR2,
		p_load_sequence_number  IN VARCHAR2,
		p_uoo_id                IN NUMBER,
		p_course_cd             IN VARCHAR2,
		p_course_version        IN NUMBER,
		p_message               OUT NOCOPY VARCHAR2,
		p_calling_obj			IN			VARCHAR2
	 ) RETURN BOOLEAN;

END igs_en_elgbl_unit;

 

/
