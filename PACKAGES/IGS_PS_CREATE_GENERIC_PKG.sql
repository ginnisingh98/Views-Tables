--------------------------------------------------------
--  DDL for Package IGS_PS_CREATE_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_CREATE_GENERIC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPS91S.pls 120.1 2005/09/08 15:08:05 appldev noship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Somnath Mukherjee
    Date Created By:  17-Jun-2005


    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who              When          What
  ********************************************************************************************** */

   TYPE uoo_tbl_type IS TABLE OF igs_ps_unit_ofr_opt_all.uoo_id%TYPE INDEX BY BINARY_INTEGER;
      l_tbl_uoo uoo_tbl_type;

   TYPE class_meet_rec_type IS RECORD (
      class_meet_group_name               igs_ps_uso_cm_grp.class_meet_group_name%TYPE,
      class_meet_group_id                 igs_ps_uso_cm_grp.class_meet_group_id%TYPE,
      old_max_enr_group                   NUMBER
      );

   TYPE class_meet_rec_tbl_type IS TABLE OF class_meet_rec_type INDEX BY BINARY_INTEGER;
    class_meet_rec class_meet_rec_type;
    class_meet_tab class_meet_rec_tbl_type;

   TYPE cross_group_rec_type IS RECORD (
      usec_x_listed_group_name               igs_ps_usec_x_grp.usec_x_listed_group_name%TYPE,
      usec_x_listed_group_id                 igs_ps_usec_x_grp.usec_x_listed_group_id%TYPE,
      old_max_enr_group                      NUMBER
      );

   TYPE cross_group_rec_tbl_type IS TABLE OF cross_group_rec_type INDEX BY BINARY_INTEGER;
   cross_group_rec cross_group_rec_type;
   cross_group_tab cross_group_rec_tbl_type;



  --This procedure is a sub process to import records of Unit Section Reserve Seating.
  PROCEDURE create_usec_res_seat(
          p_usec_res_seat_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
          p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import records of Unit Section Occurence facility.
  PROCEDURE create_uso_facility (
          p_usec_occurs_facility_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import records of Unit Section category.
  PROCEDURE create_usec_cat (
          p_usec_cat_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_cat_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
          p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import records of Unit Section Teaching Responsibility Overrides.
  PROCEDURE create_usec_teach_resp_ovrd (
          p_usec_teach_resp_ovrd_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
          p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import records of Unit Section Unit Section Assesment Item .
  PROCEDURE create_usec_ass_item_grp(
          p_usec_ass_item_grp_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import records of Unit Section meet with Class group .
  PROCEDURE create_usec_meet_with(
          p_usec_meet_with_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import records of Cross-listed Unit Section Group .
  PROCEDURE create_usec_cross_group(
          p_usec_cross_group_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import Unit Section Waitlist.
  PROCEDURE create_usec_waitlist(
          p_usec_waitlist_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to import Unit Section Notes.
  PROCEDURE create_usec_notes(
          p_usec_notes_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_notes_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) ;

  --This procedure is a sub process to insert Unit Section assesment.
  PROCEDURE create_usec_assmnt(
          p_usec_assmnt_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2
  ) ;



  PROCEDURE create_uso_ins_ovrd(
          p_tab_uso_ins IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_teach_resp(
          p_usec_teach_resp_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_sp_fee(
          p_usec_sp_fee_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_plus_hr(
          p_usec_plus_hr_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_rule(
          p_usec_rule_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_rule_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_enr_dead(
          p_usec_enr_dead_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_enr_dis(
          p_usec_enr_dis_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_ret(
          p_usec_ret_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_ret_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);

  PROCEDURE create_usec_ret_dtl(
          p_usec_ret_dtl_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_tbl_type,
	  p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context IN VARCHAR2);


END igs_ps_create_generic_pkg;

 

/
