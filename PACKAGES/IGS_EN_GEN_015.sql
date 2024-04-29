--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_015
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_015" AUTHID CURRENT_USER AS
/* $Header: IGSEN81S.pls 120.2 2005/11/25 03:00:54 appldev ship $ */
  --
  --  Function get_effective_census_date is used to get the effective
  --  census date which will be used to check the effectiveness of the hold.
  --
  FUNCTION get_effective_census_date
  (
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_teach_cal_type               IN     VARCHAR2,
    p_teach_cal_seq_number         IN     NUMBER
  ) RETURN DATE;
  --
  --  Function validation_step_overridden is used to check if the given
  --  Eligibility Step Type is overridden or not and also returns the
  --  overridden credit point limit if any. (The overridden credit point limit
  --  will not be present for all the steps. It will be applicable only
  --  for "Minimum Credit Point Limit", "Maximum Credit Point Limit" and
  --  "Variable Credit Point Limit" steps.
  --
  FUNCTION validation_step_is_overridden
  (
    p_eligibility_step_type        IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_step_override_limit          OUT NOCOPY    NUMBER
  ) RETURN BOOLEAN;
  --
  --  Function seats_in_unreserved_category is used to check if there are seats
  --  available in Unreserved Category.
  --
  FUNCTION seats_in_unreserved_category
  (
    p_uoo_id                       IN     NUMBER,
    p_level                        IN     VARCHAR2
  )
  RETURN NUMBER;
  --
  --
  --  This procedure is used to get the status of the Unit Section and Waitlist Indicator
  --  whether waitlist is open for this section or not.
  --
  --
  PROCEDURE get_usec_status
  (
    p_uoo_id                       IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_unit_section_status          OUT NOCOPY    VARCHAR2,
    p_waitlist_ind                 OUT NOCOPY    VARCHAR2,
    p_load_cal_type        IN VARCHAR2 DEFAULT NULL,
    p_load_ci_sequence_number IN NUMBER DEFAULT NULL,
    p_course_cd            IN VARCHAR2 DEFAULT NULL
  );
  --
  --
  --  Procedure to get the Academic Calendar and Academic Calenar Sequence Number.
  --
  --  This Procedure is modified to add new column (p_effective_dt) in ENCR015 DLD

  PROCEDURE get_academic_cal
  (
    p_person_id                       IN     NUMBER,
    p_course_cd                       IN     VARCHAR2,
    p_acad_cal_type                  OUT NOCOPY     VARCHAR2,
    p_acad_ci_sequence_number        OUT NOCOPY     NUMBER,
    p_message                        OUT NOCOPY     VARCHAR2,
    p_effective_dt                   IN      DATE DEFAULT SYSDATE
  );
  --
  -- Function to check whether given Program Stage is completed by the given student.
  --
  FUNCTION enrp_val_ps_stage (
    p_person_id IGS_EN_SU_ATTEMPT.person_id%TYPE,
    p_course_cd IGS_EN_SU_ATTEMPT.course_cd%TYPE,
    p_version_number NUMBER,
    p_preference_code VARCHAR2
  ) RETURN BOOLEAN;

  --
  -- Added as Part of ENCR013 DLD
  -- This Function returns Approved Credit Points if exists for student in override table
  --
  FUNCTION enrp_get_appr_cr_pt(
    p_person_id IN IGS_EN_SU_ATTEMPT.person_id%TYPE,
    p_uoo_id IN IGS_EN_SU_ATTEMPT.uoo_id%TYPE
    ) RETURN NUMBER;

  --
  -- Added as Part of ENCR015 DLD(Enh Bug : 2158654)
  -- This Procedure finds the Effective Load Calendar for a given Academic Calendar
  -- Modified the procedue by adding few more paramerers for bug# 2370100

  PROCEDURE enrp_get_eff_load_ci (
    p_person_id           IN    NUMBER,
    p_course_cd           IN    VARCHAR2,
    p_effective_dt        IN    DATE,
    p_acad_cal_type       OUT NOCOPY    VARCHAR2,
    p_acad_ci_seq_num     OUT NOCOPY    NUMBER,
    p_load_cal_type       OUT NOCOPY    VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY    NUMBER,
    p_load_ci_alt_code    OUT NOCOPY    VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY    DATE,
    p_load_ci_end_dt      OUT NOCOPY    DATE,
    p_message_name      OUT NOCOPY      VARCHAR2);

  -- This Function is created as part of the ENCR015 DLD ( Enh Bug num : 2158654)
  -- This Function returns the Derived Completion Date of a Student Program Attempt
  --
  FUNCTION enrf_drv_cmpl_dt (
    p_person_id         IN      NUMBER,
    p_course_cd         IN      VARCHAR2,
    p_achieved_cp       IN      NUMBER      DEFAULT NULL,
    p_attendance_type   IN      VARCHAR2    DEFAULT NULL,
    p_load_cal_type     IN      VARCHAR2    DEFAULT NULL,
    p_load_ci_seq_num   IN      NUMBER      DEFAULT NULL,
    p_load_ci_alt_code  IN      VARCHAR2    DEFAULT NULL,
    p_load_ci_start_dt  IN      DATE        DEFAULT NULL,
    p_load_ci_end_dt    IN      DATE        DEFAULT NULL,
    p_message_name      OUT NOCOPY      VARCHAR2
    )  RETURN DATE;

  PROCEDURE check_spl_perm_exists(
   p_cal_type              IN VARCHAR2,
   p_ci_sequence_number    IN NUMBER,
   p_person_id             IN  NUMBER,
   p_uoo_id                IN  NUMBER,
   p_person_type           IN VARCHAR2,
   p_program_cd            IN VARCHAR2,
   p_message_name          OUT NOCOPY VARCHAR2,
   p_return_status         OUT NOCOPY VARCHAR2,
   p_check_audit           IN VARCHAR2,
   p_audit_status          OUT NOCOPY VARCHAR2,
   p_audit_msg_name        OUT NOCOPY VARCHAR2);

  PROCEDURE check_audit_perm_exists(
   p_cal_type              IN VARCHAR2,
   p_ci_sequence_number    IN NUMBER,
   p_person_id             IN NUMBER,
   p_program_cd            IN VARCHAR2,
   p_uoo_id                IN NUMBER,
   p_person_type           IN VARCHAR2,
   p_enr_cat               IN VARCHAR2,
   p_enr_method            IN VARCHAR2,
   p_comm_type             IN VARCHAR2,
   p_return_status         OUT NOCOPY VARCHAR2,
   p_message_name          OUT NOCOPY VARCHAR2);

  --
  -- Added as Part of EN213 Build
  -- This Function checks whether the core unit attempt can be dropped.
  --
  FUNCTION eval_core_unit_drop
  (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_step_type                    IN     VARCHAR2,
    p_term_cal                     IN     VARCHAR2,
    p_term_sequence_number         IN     NUMBER,
    p_deny_warn                    OUT NOCOPY VARCHAR2,
    p_enr_method                 IN VARCHAR2
  )
  RETURN VARCHAR2;

  PROCEDURE  get_curr_acad_term_cal (
    p_acad_cal_type       IN VARCHAR,
    p_effective_dt        IN    DATE,
    p_load_cal_type       OUT NOCOPY   VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_ci_alt_code    OUT NOCOPY   VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY   DATE,
    p_load_ci_end_dt      OUT NOCOPY   DATE,
    p_message_name        OUT NOCOPY   VARCHAR2);

   PROCEDURE  get_curr_term_for_schedule(
    p_acad_cal_type       IN VARCHAR,
    p_effective_dt        IN    DATE,
    p_load_cal_type       OUT NOCOPY   VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY   NUMBER,
    p_load_ci_alt_code    OUT NOCOPY   VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY   DATE,
    p_load_ci_end_dt      OUT NOCOPY   DATE,
    p_message_name        OUT NOCOPY   VARCHAR2);

PROCEDURE get_academic_cal_poo_chg
  (
    p_person_id                       IN     NUMBER,
    p_course_cd                       IN     VARCHAR2,
    p_acad_cal_type                  IN OUT  NOCOPY VARCHAR2,
    p_acad_ci_sequence_number        OUT NOCOPY     NUMBER,
    p_message                        OUT NOCOPY     VARCHAR2,
    p_effective_dt                   IN      DATE DEFAULT SYSDATE
  );

PROCEDURE enrp_get_eff_load_ci_poo_chg (
    p_person_id           IN    NUMBER,
    p_course_cd           IN    VARCHAR2,
    p_effective_dt        IN    DATE,
    p_acad_cal_type       IN OUT NOCOPY VARCHAR2,
    p_acad_ci_seq_num     OUT NOCOPY    NUMBER,
    p_load_cal_type       OUT NOCOPY    VARCHAR2,
    p_load_ci_seq_num     OUT NOCOPY    NUMBER,
    p_load_ci_alt_code    OUT NOCOPY    VARCHAR2,
    p_load_ci_start_dt    OUT NOCOPY    DATE,
    p_load_ci_end_dt      OUT NOCOPY    DATE,
    p_message_name      OUT NOCOPY      VARCHAR2);




END igs_en_gen_015;

 

/
