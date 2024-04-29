--------------------------------------------------------
--  DDL for Package IGS_SS_ENR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SS_ENR_DETAILS" AUTHID CURRENT_USER AS
/* $Header: IGSSS05S.pls 120.11 2005/09/20 06:00:34 appldev ship $ */

FUNCTION get_location_bldg_room
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_instructor_day_time
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_programs
(
        p_person_id IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_occur_desc_details
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_occur_cd_details
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2 ;

FUNCTION get_occur_details_no_location
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_usec_ref_cd
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_usec_occurs_ref_cd
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_unit_note
(
        p_unit_cd IN VARCHAR2,
        p_version_NUMBER IN NUMBER
) RETURN VARCHAR2 ;
FUNCTION get_usec_note
(
        p_uoo_id IN NUMBER
) RETURN VARCHAR2  ;
/*
| Added for November 2001 |
*/
  --Purpose: To get the title and subtitle from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
  -- level
  -- To be used only in self service as then fields are seperated by <BR> tag
  -- and this is to be used only in SS.
FUNCTION get_title_section
(
        p_person_id      IN NUMBER,
        p_uoo_id         IN NUMBER,
        p_unit_cd        IN VARCHAR2,
        p_version_number IN NUMBER,
        p_course_cd      IN VARCHAR2

) RETURN VARCHAR2;

FUNCTION get_title
(
        p_person_id      IN NUMBER,
        p_uoo_id         IN NUMBER,
        p_unit_cd        IN VARCHAR2,
        p_version_number IN NUMBER,
        p_course_cd      IN VARCHAR2

) RETURN VARCHAR2;

FUNCTION get_subtitle
(
        p_person_id      IN NUMBER,
        p_uoo_id         IN NUMBER,
        p_unit_cd        IN VARCHAR2,
        p_version_number IN NUMBER,
        p_course_cd      IN VARCHAR2

) RETURN VARCHAR2;

  --Purpose: To get the grading schema from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
FUNCTION get_grading_schema
(
        p_person_id  IN NUMBER,
        p_uoo_id  IN NUMBER,
        p_unit_cd  IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN VARCHAR2;

 --Purpose: To get the grading schema version from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
FUNCTION get_grading_schema_ver
(
        p_person_id  IN NUMBER,
        p_uoo_id  IN NUMBER,
        p_unit_cd  IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN NUMBER;

  --Purpose: To get the grading schema description from SUA level. If not available
  -- at SUA level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
FUNCTION get_grading_schema_desc
(
        p_person_id  IN NUMBER,
        p_uoo_id  IN NUMBER,
        p_unit_cd  IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN VARCHAR2;


  --Purpose: To get the grading schema code and version number from SUA level. If not available
  -- at SUA level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
FUNCTION get_grading_cd_ver
(
        p_person_id  IN NUMBER,
        p_uoo_id  IN NUMBER,
        p_unit_cd  IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN VARCHAR2;


  -- Purpose: To get the overrid enrolled credit points from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- at unit level if the variable credit poins indicator is checked then
  -- the achievable credit points is not null at section level then fetch that value
  -- if that is null or the indiactor is not set then get the enrolled credit points
  -- at the unit level
  -- this is because it is assumed that at section level if variable credit points are
  -- to be defined then it would be  stored in achievable credit points field as enrolled
  -- credit points are not stored at section level
FUNCTION get_credit_points
(
        p_person_id       IN NUMBER,
        p_uoo_id          IN NUMBER,
        p_unit_cd         IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd       IN VARCHAR2
)RETURN NUMBER;

FUNCTION get_allowable_cp_range
(
 p_uoo_id IN NUMBER
 )
RETURN VARCHAR2;

-- to return the primary program, version and all the enrolled program
-- for a caerer

PROCEDURE enrp_get_prgm_for_career
(
p_primary_program OUT NOCOPY VARCHAR2,
p_primary_program_version OUT NOCOPY NUMBER,
p_programlist OUT NOCOPY VARCHAR2,
p_person_id IN NUMBER,
p_carrer IN VARCHAR2,
p_term_cal_type IN VARCHAR2 DEFAULT NULL,
p_term_sequence_number IN NUMBER DEFAULT NULL
);
-- Is subtitle modifiable by admin at sua level

FUNCTION enrp_val_subttl_chg (  p_person_id IN NUMBER,
                                p_uoo_id             IN   NUMBER
                              ) RETURN CHAR;

 FUNCTION get_notification(
    p_person_type            VARCHAR2,
    p_enrollment_category    VARCHAR2,
    p_comm_type              VARCHAR2,
    p_enr_method_type        VARCHAR2,
    p_step_group_type        VARCHAR2,
    p_step_type              VARCHAR2,
    p_person_id              NUMBER,
    p_message            OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2;

FUNCTION get_usec_eff_dates(
    x_unit_cd VARCHAR2,
    x_version NUMBER,
    x_cal_type VARCHAR2,
    x_ci_seq_number NUMBER,
    x_location_cd VARCHAR2,
    x_unit_class VARCHAR2) RETURN VARCHAR2;

PROCEDURE get_enrollment_limits(
                                p_uooid NUMBER,
                                p_unitcode VARCHAR2,
                                p_version  NUMBER,
                                p_actenrolled  OUT NOCOPY NUMBER,
                                p_maxlimit OUT NOCOPY NUMBER ,
                                p_minlimit  OUT NOCOPY NUMBER );

/* Procedure to get the Latest Term which has some ENROLLED unit attempt for the given person/program */
PROCEDURE enrp_get_enr_term
( p_person_id IN NUMBER,
p_course_cd IN VARCHAR2,
p_cal_type OUT NOCOPY VARCHAR2,
p_sequence_number OUT NOCOPY NUMBER,
p_term_desc OUT NOCOPY VARCHAR2
);

/* This Function returns Lead Instructor of a Unit Section if it exists otherwise returns NULL */
FUNCTION get_lead_instructor_name(
p_uoo_id IN NUMBER
) RETURN VARCHAR2;

/*This function returns the max waitlist defined at organization level for teaching calendar */
FUNCTION get_max_std_wait_org_level(
                                     p_owner_org_unit_cd  IN VARCHAR2,
                                     p_cal_type           IN VARCHAR2,
                                     p_sequence_number    IN NUMBER
) RETURN NUMBER;

/* This Function returns Instructor(s) names              */
/* for a given uoo_id if it exists otherwise returns NULL */
/* created for bug 2446078 - TNATARAJ                     */
FUNCTION get_usec_instructor_names(
p_uoo_id IN NUMBER
) RETURN VARCHAR2;




/*
 --
 --  Procedure added to get the Group Name and Group Type of the passed Unit Section,
 --  if it belongs to any cross-listed / meet with group.
 --
*/

 PROCEDURE  Enrp_Get_Usec_Group (
     p_uoo_id           igs_ps_unit_ofr_opt.uoo_id%TYPE,
     p_return_status    OUT NOCOPY VARCHAR2,
     p_group_type       OUT NOCOPY igs_lookups_view.meaning%TYPE,
     p_group_name       OUT NOCOPY igs_ps_usec_x_grp.usec_x_listed_group_name%TYPE
 );

/*
 --
 --  The following function returns the concatenated value of Enrollment Maximum and
 --  Actual Enrollment if the passed unit section belongs to any cross-listed / meet with group.
 --
*/

 FUNCTION Enrp_Get_Enr_Max_Act (
      p_uoo_id            igs_ps_unit_ofr_opt.uoo_id%TYPE
 )  RETURN VARCHAR2;


/*
 --
 --  The following function is a wrapper to the procedure Enrp_Get_Usec_Group.
 --  This function returns the value of Y/N deponding upon whether the unit section
 --  belongs to any group or not. It is called from the view IGS_SS_EN_ENROLL_CART_RSLT_V.
 --
*/

FUNCTION Enrp_Chk_Usec_Group (
      p_uoo_id            igs_ps_unit_ofr_opt.uoo_id%TYPE
 )  RETURN VARCHAR2;

--
-- Added as Part of EN213 Build
-- This Function checks whether the given unit section is a core unit or not in the
-- current pattern of study for the given student program attempt.
--
FUNCTION get_core_disp_unit(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_uoo_id IN NUMBER )
RETURN VARCHAR2;

--
-- This procedure checks whether the given enrollment category step is defined in the system or not
--
PROCEDURE get_enr_cat_step(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_enr_cat_prc_step IN VARCHAR2,
  p_ret_status OUT NOCOPY VARCHAR2);

--
-- This Function returns the current YOP unit set title
--
FUNCTION get_stud_yop_unit_set(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_term_cal_type IN VARCHAR2,
  p_term_sequence_number IN NUMBER)
RETURN VARCHAR2;

--
-- This Function returns the title of the given program or given primary program
--
FUNCTION get_pri_prg_title(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_term_cal_type IN VARCHAR2 DEFAULT NULL,
  p_term_sequence_number IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;

--
-- This Function returns return the concatenated titles of all the secondary programs in the same career of the given program
--
FUNCTION get_sec_prg_title(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2,
  p_program_version IN NUMBER ,
  p_term_cal_type IN VARCHAR2 DEFAULT NULL,
  p_term_sequence_number IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;
--this function checks if the passed in uoo_id is superior or subordinate or none
FUNCTION enrf_is_sup_sub(
p_uoo_id            IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_sup_sub_uoo_ids (
  p_uoo_id IN NUMBER,
  p_relation_type IN VARCHAR2,
  p_sup_uoo_id IN NUMBER)
RETURN VARCHAR2;
--this function returns the relation type of the uoo_id
 FUNCTION get_sup_sub_details (
    p_uoo_id IN NUMBER,
    p_sup_uoo_id IN NUMBER,
    p_relation_type IN VARCHAR2
  )  RETURN VARCHAR2 ;

-- Procedure to get the level at which notes is defined for give unit section.
-- Procedure retuns the following values in the out variable p_c_dfn_lvl.
-- 'UNIT_SECTION' - when the notes are defined at unit section level.
-- 'UNIT_OFFERING_PATTERN' - when the notes are defined at unit offering pattern level.
-- 'UNIT_OFFERING' - when the notes are defined at unit offering level.
-- 'UNIT_VERSION' - when the notes are defined at unit version level.
-- 'NOTES_UN_DEFINED' - when the notes are not defined at any of the above levels.
  PROCEDURE get_notes_defn_lvl (
    p_n_uoo_id IN NUMBER,
    p_c_dfn_lvl OUT NOCOPY VARCHAR2);

--function to return if a Duplicate SUA  can be uncheked on transfer page.

FUNCTION GET_DUP_SUA_SELECTION (
    p_person_id IN NUMBER,
    p_src_course_cd IN VARCHAR2,
    p_dest_course_cd IN VARCHAR2,
    p_uoo_id IN NUMBER
    )  RETURN VARCHAR2;

FUNCTION get_title_for_unit(p_unit_cd IN VARCHAR2, p_version IN NUMBER) RETURN VARCHAR2;

FUNCTION get_max_waitlist_for_unit(p_uoo_id IN NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER,
                  p_cal_type IN VARCHAR2, p_sequence_number IN NUMBER,
                  p_owner_org_unit_cd IN VARCHAR2) RETURN NUMBER;


FUNCTION get_enroll_max_for_unit(p_uooid IN NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER) RETURN NUMBER;

FUNCTION get_enroll_min_for_unit(p_uooid IN NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER) RETURN NUMBER;


-- Function to get alias value for the given calendar instance and date alias.
FUNCTION get_alias_val (p_c_cal_type IN VARCHAR2,
                        p_n_seq_num  IN NUMBER,
                        p_c_dt_alias IN VARCHAR2) RETURN DATE ;


-- Function to check whether timeslot is open or close for a student
-- returns true if the timeslot is open otherwise false
FUNCTION stu_timeslot_open (p_n_person_id IN NUMBER,
                               p_c_person_type IN VARCHAR2,
                               p_c_program_cd  IN VARCHAR2,
                               p_c_cal_type    IN VARCHAR2,
                               p_n_seq_num     IN NUMBER)
                               RETURN BOOLEAN;



FUNCTION get_meeting_pattern (p_n_uoo_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_usec_instructors(p_n_uoo_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_us_title(p_n_uoo_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_rule_text(p_rule_type IN VARCHAR2, p_n_uoo_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_special_audit_status(p_uoo_id IN NUMBER) RETURN VARCHAR2;
FUNCTION  get_apor_credits(p_uoo_id IN NUMBER,
                           p_override_enrolled_cp IN NUMBER,
                           p_term_cal_type IN VARCHAR2,
                           p_term_seq_num IN NUMBER
                           ) RETURN NUMBER;
FUNCTION   get_billable_credit_points(p_uoo_id IN IGS_PS_UNIT_OFR_OPT_ALL.uoo_id%TYPE) RETURN NUMBER;

FUNCTION get_uso_instructors(p_n_uso_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_meaning (p_c_lkup_type IN VARCHAR2,p_c_lkup_code IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION get_coreq_units(p_uoo_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION is_unit_rule_defined(p_uoo_id  IN NUMBER,
                              p_rule_type IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_special_status(p_uoo_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_audit_status(p_uoo_id IN NUMBER) RETURN VARCHAR2;

FUNCTION is_audit_allowed(p_uoo_id IN NUMBER,
                          p_person_type IN VARCHAR2) RETURN VARCHAR2;

FUNCTION is_placement_allowed (p_unit_cd IN VARCHAR2, p_version_number IN NUMBER) RETURN VARCHAR2;

FUNCTION get_enrollment_capacity(p_uoo_id NUMBER) RETURN VARCHAR2;

FUNCTION get_total_plan_credits(p_personid NUMBER,
                                p_course_cd VARCHAR2,
                                p_term_cal_type VARCHAR2,
                                p_term_seq_num NUMBER) RETURN NUMBER;

FUNCTION get_enr_period_open_status( p_person_id                    IN  NUMBER,
                                     p_course_cd                       IN VARCHAR2,
                                     p_load_calendar_type              IN  VARCHAR2,
                                     p_load_cal_sequence_number        IN  NUMBER,
                                         p_person_type                     IN VARCHAR2,
                                     p_message                         OUT NOCOPY  VARCHAR2)
                                     RETURN BOOLEAN;

 FUNCTION  is_selection_enabled (  p_person_id                  IN  NUMBER,
                                   p_load_cal_type              IN  VARCHAR2,
                                   p_load_seq_num               IN  NUMBER,
                                   p_person_type                IN VARCHAR2,
                                   p_message                    OUT NOCOPY  VARCHAR2
                                ) RETURN VARCHAR2;

 FUNCTION get_us_subtitle (p_n_uoo_id IN NUMBER) RETURN VARCHAR2 ;

 FUNCTION get_waitlist_capacity(p_uoo_id NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER,
                  p_cal_type IN VARCHAR2, p_sequence_number IN NUMBER,
                  p_owner_org_unit_cd IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_class_day (p_n_uso_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_class_time (p_n_uso_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_calling_object ( p_person_id         IN  NUMBER,
                         p_course_cd                  IN VARCHAR2,
                         p_load_cal_type              IN  VARCHAR2,
                         p_load_seq_num               IN  NUMBER,
                         p_person_type                IN VARCHAR2,
                         p_message                   OUT NOCOPY  VARCHAR2
                    ) RETURN VARCHAR2  ;

FUNCTION can_drop (p_cal_type           IN VARCHAR2,
                   p_ci_sequence_number IN NUMBER,
                   p_effective_dt       IN DATE,
                    p_uoo_id             IN NUMBER,
                     p_c_core             IN VARCHAR2,
                     p_n_person_id        IN NUMBER,
                     p_c_course_cd        IN VARCHAR2
                     ) RETURN VARCHAR2 ;

FUNCTION get_tba_desc RETURN VARCHAR2 ;

FUNCTION get_occur_dates (p_n_uso_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE get_definition_levels (p_n_uoo_id IN NUMBER,
                                 p_c_notes_lvl OUT NOCOPY VARCHAR2,
                                 p_c_ref_lvl OUT NOCOPY VARCHAR2,
                                 p_c_unit_cd OUT NOCOPY VARCHAR2,
                                 p_n_version OUT NOCOPY NUMBER,
                                 p_n_us_ref_id OUT NOCOPY NUMBER);

FUNCTION get_sua_core_disp_unit(p_person_id IN NUMBER ,
                                p_program_cd IN VARCHAR2 ,
                                p_uoo_id IN NUMBER)RETURN VARCHAR2;

FUNCTION get_total_cart_credits(p_personid IN NUMBER,
                                p_course_cd IN VARCHAR2,
                                p_term_cal_type IN VARCHAR2,
                                p_term_seq_num IN NUMBER) RETURN NUMBER;

FUNCTION get_sca_unit_sets( p_person_id IN NUMBER ,
                            p_program_cd IN VARCHAR2 ,
                            p_term_cal_type IN VARCHAR2,
                            p_term_sequence_number IN NUMBER) RETURN VARCHAR2;

 FUNCTION get_sup_sub_text (p_uoo_id IN NUMBER,
                               p_sup_uoo_id IN NUMBER,
                               p_relation_type IN VARCHAR2
                               )  RETURN VARCHAR2 ;

FUNCTION get_none_desc RETURN VARCHAR2;

FUNCTION  is_enr_open(p_load_cal IN varchar2,
                      p_load_seq_num IN Number,
                      p_d_date IN DATE,
                      p_n_uoo_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_total_cart_units(p_personid NUMBER,
                              p_course_cd VARCHAR2,
         		      p_term_cal_type VARCHAR2,
			      p_term_seq_num NUMBER) RETURN NUMBER;

END igs_ss_enr_details;

 

/
