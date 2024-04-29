--------------------------------------------------------
--  DDL for Package IGS_PS_VALIDATE_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VALIDATE_GENERIC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPS92S.pls 120.1 2005/09/08 16:13:10 appldev noship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Somnath Mukherjee
    Date Created By:  17-Jun-2005
    Purpose        :  This package has the some validation function which will be called from sub processes,
                      in igs_ps_create_generic_pkg package.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */



  -- Validate Unit Section Occurence Facility Records before inserting them
  PROCEDURE validate_facility (p_uso_fclt_rec    IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_rec_type,
                               p_n_uoo_id        IN NUMBER,
			       p_uso_id          IN NUMBER,
                               p_calling_context IN VARCHAR2);

  -- Validate Unit Section Category Records before inserting them
  PROCEDURE validate_category (p_usec_cat_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cat_rec_type,
                               p_n_uoo_id     IN NUMBER);


  -- This procedure validates before inserting Unit Section Grading Schema records
  PROCEDURE validate_tch_rsp_ovrd ( p_tch_rsp_ovrd_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type,
                                    p_n_uoo_id     IN NUMBER);

  -- This function does validations after inserting Unit Section Grading Schema Records
  FUNCTION post_tch_rsp_ovrd ( p_tab_tch_rsp_ovrd IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_tbl_type,
                               p_tab_uoo IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN ;

  -- This procedure validates before inserting Unit Section Notes
  PROCEDURE validate_usec_notes(p_usec_notes_rec IN OUT NOCOPY igs_ps_generic_pub.usec_notes_rec_type,
                                p_n_uoo_id       IN NUMBER);

  -- This procedure validates before inserting Unit Section Assessment records
  PROCEDURE validate_usec_assmnt ( p_usec_assmnt_rec IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type,
                                  p_n_uoo_id            igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
				  p_d_exam_start_time	igs_ps_usec_as.exam_start_time%TYPE,
                                  p_d_exam_end_time	igs_ps_usec_as.exam_end_time%TYPE,
				  p_n_building_id       NUMBER,
				  p_n_room_id           NUMBER,
				  p_insert_update       VARCHAR2);

  -- This procedure validates before inserting  Unit Section Reserved Seating Records
  PROCEDURE validate_usec_rsvpri(p_usec_rsv_rec  IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,
                                 p_n_uoo_id      IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
				 p_insert_update IN VARCHAR2);

  PROCEDURE validate_usec_rsvprf(p_usec_rsv_rec  IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,
				 p_insert_update IN VARCHAR2);

  -- This procedure validates before inserting  Unit Section Waitlist Records
  PROCEDURE validate_usec_wlstpri(p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,
                                  p_n_uoo_id      igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
				  p_insert_update VARCHAR2);

  PROCEDURE validate_usec_wlstprf(p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,
				  p_insert_update IN VARCHAR2);

  -- This procedure validates before inserting/updating  Unit Section Assessment item group records
  PROCEDURE validate_as_us_ai_group ( p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,
				      p_n_uoo_id           NUMBER);

  -- This procedure validates before inserting/updating  Unit Section meet with class group records
  PROCEDURE validate_uso_cm_grp ( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type,
				  p_c_cal_type     VARCHAR2 ,
				  p_n_seq_num      NUMBER,
				  p_insert_update  VARCHAR2,
				  p_class_meet_rec   IN OUT NOCOPY igs_ps_create_generic_pkg.class_meet_rec_type  );

  -- This procedure validates before inserting/updating  Unit Section meet with class  records
  PROCEDURE validate_uso_clas_meet ( p_uso_clas_meet_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type,
				     p_n_uoo_id              NUMBER,
				     p_n_class_meet_group_id NUMBER,
				     p_c_cal_type            VARCHAR2,
				     p_n_seq_num             NUMBER);

  -- This procedure validates before inserting/updating  cross listed Unit Section  records
  PROCEDURE validate_usec_x_grp ( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type,
				  p_c_cal_type     VARCHAR2,
				  p_n_seq_num      NUMBER,
				  p_insert_update  VARCHAR2,
				  p_cross_group_rec  IN OUT NOCOPY igs_ps_create_generic_pkg.cross_group_rec_type );

  -- This procedure validates before inserting/updating  cross listed Unit Section   records
  PROCEDURE validate_usec_x_grpmem ( p_usec_x_grpmem            IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type,
				     p_n_uoo_id                 NUMBER,
				     p_n_usec_x_listed_group_id NUMBER,
				     p_c_cal_type               VARCHAR2,
				     p_n_seq_num                NUMBER);

  -- This procedure validates after inserting/updating  cross listed Unit Section   records
  FUNCTION post_usec_cross_group(p_tab_usec_cross_group IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_tbl_type,
                                 p_cross_group_tab        IN igs_ps_create_generic_pkg.cross_group_rec_tbl_type) RETURN BOOLEAN;

  -- This procedure validates before inserting/updating  Unit Section Assessment item records
  PROCEDURE validate_unitass_item ( p_unitass_item_rec   IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,
                                    p_cal_type           IN VARCHAR2,
				    p_ci_sequence_number NUMBER,
				    p_n_uoo_id           NUMBER,
				    p_insert             VARCHAR2);

  -- This function does validations after inserting/updating Unit Section Assessment item records
  FUNCTION post_as_us_ai ( p_tab_as_us_ai IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_tbl_type,
                           p_tab_uoo      IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN;

  -- This function does validations after inserting/updating Unit Section meet with class group records
  FUNCTION post_usec_meet_with(p_tab_usec_meet_with IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_tbl_type,
                               p_class_meet_tab IN igs_ps_create_generic_pkg.class_meet_rec_tbl_type) RETURN BOOLEAN;

  -- This function does validations after inserting Unit Section Reserved Seating Records
  FUNCTION post_usec_rsv ( p_tab_usec_rsv IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_tbl_type,
                           p_tab_uoo IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN;

  -- This procedure validates after inserting  Unit Section Waitlist Records
  FUNCTION post_usec_wlst ( p_tab_usec_wlst IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_tbl_type,
                            p_tab_uoo IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN;


END igs_ps_validate_generic_pkg;

 

/
