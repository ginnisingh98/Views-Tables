--------------------------------------------------------
--  DDL for Package IGS_PS_VALIDATE_LGCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VALIDATE_LGCY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPS86S.pls 120.4 2005/08/04 03:47:28 appldev ship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Shirish Tatiko, Saravana Kumar
    Date Created By:  11-NOV-2002
    Purpose        :  This package has the some validation function which will be called from sub processes,
                      in IGS_PS_UNIG_LGCY_PKG package.
                      This Package also few generic utility function like set_msg, get_lkup_meaning..

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk         28-Jul-2004    Bug # 3793580. Created utility procedure get_uso_id.
    sarakshi     12-Apr-2004    bug#3555871, Removed the function get_call_number
    smvk         10-Sep-2003    Bug # 3052445. Added the utilitiy function is_waitlist_allowed.
    smvk         23-Sep-2003    Bug # 3121311, Removed the utility procedures uso_effective_dates and validate_instructor.
    sarakshi     11-Sep-2003    Enh#3052452,added one parameter to procedure validate_uoo
    SMVK         27-Jun-2003    Bug # 2999888. Created procedure validate_unit_reference.
    jbegum       02-June-2003      Bug # 2972950. Created procedure validate_usec_el and uso_effective_dates. Functions post_uso_ins_busi
                                   and validate_instructor as mentioned in TD.
    jbegum       02-June-2003      Added three procedures (post_uso_ins_busi, uso_effective_dates , post_uso_ins ) and a function
                                   validate_instructor, As per PSP Legacy Enhancements TD. Bug #2972950
    smvk       26-Dec-2002      Added a generic procedure (get_party_id) and a function (validate_staff_person)
                                As a part of Bug # 2721495
  ********************************************************************************************** */

  -- This function does validations before inserting Unit Version Records
  PROCEDURE unit_version(p_unit_ver_rec    IN OUT NOCOPY  igs_ps_generic_pub.unit_ver_rec_type,
                         p_coord_person_id IN             igs_ps_unit_ver_all.coord_person_id%TYPE);

  -- This function does validations after inserting Teaching Responsibility Records
  FUNCTION post_teach_resp ( p_tab_teach_resp IN OUT NOCOPY igs_ps_generic_pub.unit_tr_tbl_type ) RETURN BOOLEAN;

  -- This function does validations after inserting Unit Discipline Records
  FUNCTION post_unit_discip ( p_tab_unit_dscp IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_tbl_type ) RETURN BOOLEAN;

  -- This procedure validates before inserting Unit Grading Schema records
  PROCEDURE validate_unit_grd_sch ( p_unit_gs_rec IN OUT NOCOPY igs_ps_generic_pub.unit_gs_rec_type );

  -- This function does validations after inserting Unit Grading Schema Records
  FUNCTION post_unit_grd_sch ( p_tab_grd_sch IN OUT NOCOPY igs_ps_generic_pub.unit_gs_tbl_type ) RETURN BOOLEAN;

  -- Validate Unit Offer Option Records before inserting them
  PROCEDURE validate_uoo ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                           p_c_cal_type IN igs_ca_type.cal_type%TYPE,
                           p_n_seq_num IN igs_ca_inst_all.sequence_number%TYPE,
                           p_n_sup_uoo_id IN OUT NOCOPY igs_ps_unit_ofr_opt_all.sup_uoo_id%TYPE,
			   p_insert_update VARCHAR2,
			   p_conc_flag OUT NOCOPY BOOLEAN);

  -- Validate Unit Section Credit Points Records before inserting them
  PROCEDURE validate_cps ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                           p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			   p_insert_update VARCHAR2) ;

  -- Validate Unit Section Referece Records before inserting them
  PROCEDURE validate_ref ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                           p_n_subtitle_id OUT NOCOPY igs_ps_unit_subtitle.subtitle_id%TYPE,
			   p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			   p_insert_update VARCHAR2);

  -- This procedure validates before inserting Unit Section Grading Schema records
  PROCEDURE validate_usec_grd_sch ( p_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type,
                                    p_n_uoo_id    IN NUMBER);

  -- This function does validations after inserting Unit Section Grading Schema Records
  FUNCTION post_usec_grd_sch ( p_tab_usec_gs IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
                               p_tab_uoo     IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN ;

  -- This procedure validates before inserting records of Unit Section Occurrence.
  PROCEDURE validate_usec_occurs ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type,
                                   p_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                   p_d_start_date IN igs_ca_inst_all.start_dt%TYPE,
                                   p_d_end_date IN igs_ca_inst_all.end_dt%TYPE,
				   p_n_building_code IN NUMBER,
				   p_n_room_code IN NUMBER,
				   p_n_dedicated_building_code IN NUMBER,
				   p_n_dedicated_room_code IN NUMBER,
				   p_n_preferred_building_code IN NUMBER,
				   p_n_preferred_room_code IN NUMBER,
				   p_n_uso_id IN NUMBER,
				   p_insert IN VARCHAR2,
				   p_calling_context IN VARCHAR2,
				   p_notify_status OUT NOCOPY VARCHAR2,
				   p_schedule_status IN OUT NOCOPY VARCHAR2
				   );

  -- This procedure does the business validation for Unit / Unit Section / Unit Section Occurrence reference codes.
  PROCEDURE validate_unit_reference(p_unit_ref_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type,
                                    p_n_uoo_id     IN NUMBER,
				    p_n_uso_id     IN NUMBER,
				    p_calling_context IN VARCHAR2);

  -- This procedure sets the message in the message stack
  PROCEDURE set_msg( p_c_msg_name IN VARCHAR2,
                     p_c_token IN VARCHAR2 DEFAULT NULL,
                     p_c_lkup_type IN VARCHAR2 DEFAULT NULL,
                     p_b_delete_flag IN BOOLEAN DEFAULT FALSE
                   );

  -- This generic function gets the meaning for the given lookup_code and lookup_type
  FUNCTION get_lkup_meaning(p_c_lkup_cd IN VARCHAR2,
                            p_c_lkup_type IN VARCHAR2
                           ) RETURN VARCHAR2 ;


  -- This generic function gets the Unit Offering Options Identifier (Unit Section identifier)
  PROCEDURE get_uoo_id( p_unit_cd IN VARCHAR2,
                        p_ver_num IN NUMBER,
                        p_cal_type IN VARCHAR2,
                        p_seq_num IN NUMBER,
                        p_loc_cd IN VARCHAR2,
                        p_unit_class IN VARCHAR2,
                        p_uoo_id OUT NOCOPY NUMBER,
                        p_message OUT NOCOPY VARCHAR2
                      );

  -- This Function will validate whether waitlisting is allowed for given organization unit code.
  FUNCTION validate_waitlist_allowed ( p_c_cal_type IN igs_ca_type.cal_type%TYPE,
                                       p_n_seq_num  IN igs_ca_inst_all.sequence_number%TYPE ) RETURN BOOLEAN;


  -- This function checks whether given Grading schema is of type p_c_gs_type or not.
  FUNCTION validate_gs_type ( p_c_gs_cd IN VARCHAR2, p_n_gs_ver IN NUMBER, p_c_gs_type IN VARCHAR2 DEFAULT 'UNIT' ) RETURN BOOLEAN;

  -- Validates calendar type whether its of give category or not
  FUNCTION validate_cal_cat ( p_c_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                              p_c_cal_cat  IN igs_ca_type.s_cal_cat%TYPE DEFAULT 'TEACHING' ) RETURN BOOLEAN;

  -- Validate Orgaization Unit Code
  FUNCTION validate_org_unit_cd ( p_c_org_unit_cd IN igs_ps_unit_ver_all.owner_org_unit_cd%TYPE,
                                  p_c_object_name IN VARCHAR2 ) RETURN BOOLEAN;

  PROCEDURE get_party_id(p_c_person_number IN hz_parties.party_number%TYPE,
                          p_n_person_id OUT NOCOPY hz_parties.party_id%TYPE) ;
  --
  PROCEDURE validate_usec_el(p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                             p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			     p_insert_update VARCHAR2);

  PROCEDURE post_usec_limits(p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                             p_calling_context IN VARCHAR2,
                             p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			     p_insert_update VARCHAR2);

  -- Procedure to do the post unit section occurrence instructor validation.
  PROCEDURE post_uso_ins( p_n_ins_id     IN igs_ps_uso_instrctrs.instructor_id%TYPE,
                          p_n_uoo_id     IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                          p_uso_ins_rec  IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type,
                          p_n_index      IN NUMBER);

  -- Procedure to do validate the unit section section teaching responsibility record after importing unit section occurrence instructors.
  FUNCTION post_uso_ins_busi( p_tab_uso_ins IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type) RETURN BOOLEAN;

  -- This Function will returns true if waitlist is allowed otherwise false.
  FUNCTION is_waitlist_allowed RETURN BOOLEAN;

  -- Procedure to derive unit section occurrence identifier.
  PROCEDURE get_uso_id( p_uoo_id                IN NUMBER,
                        p_occurrence_identifier IN VARCHAR2,
                        p_uso_id                OUT NOCOPY NUMBER,
                        p_message               OUT NOCOPY VARCHAR2
                       );
  --Function to validate if a person is a staff/faculty
  FUNCTION validate_staff_faculty (p_person_id IN NUMBER ) RETURN BOOLEAN ;

  --Function to validate whether a uoo_id exists in the pl/sql table p_tab_uoo
  FUNCTION isexists(p_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                    p_tab_uoo  IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN ;

  --Function to check whether import is allowed in context to scheduling (overlodad function)
  FUNCTION  check_import_allowed( p_unit_cd        IN VARCHAR2,
                                  p_version_number IN NUMBER,
				  p_alternate_code IN VARCHAR2,
				  p_location_cd    IN VARCHAR2,
				  p_unit_class     IN VARCHAR2,
				  p_uso_id         IN NUMBER) RETURN BOOLEAN;

  --Function to check whether import is allowed in context to scheduling (overlodad function)
  FUNCTION  check_import_allowed( p_uoo_id IN NUMBER,p_uso_id IN NUMBER) RETURN BOOLEAN;

  --Function to check whether a unit section status is NOT_OFFERED
  FUNCTION check_not_offered_usec_status(p_uoo_id IN NUMBER ) RETURN BOOLEAN;

  FUNCTION boundary_check_number( p_n_value IN NUMBER,p_n_int_part IN NUMBER,p_n_dec_part IN NUMBER) RETURN BOOLEAN;

END igs_ps_validate_lgcy_pkg;

 

/
