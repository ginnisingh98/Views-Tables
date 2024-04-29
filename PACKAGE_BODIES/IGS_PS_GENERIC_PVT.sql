--------------------------------------------------------
--  DDL for Package Body IGS_PS_GENERIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GENERIC_PVT" AS
/* $Header: IGSPS90B.pls 120.2 2005/09/27 01:35:27 appldev noship $ */


G_PKG_NAME     CONSTANT VARCHAR2(30) := 'igs_ps_generic_pvt';

PROCEDURE psp_import (
p_api_version			IN           NUMBER,
p_init_msg_list			IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_commit			IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_validation_level		IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
x_return_status			OUT NOCOPY   VARCHAR2,
x_msg_count			OUT NOCOPY   NUMBER,
x_msg_data			OUT NOCOPY   VARCHAR2,
p_calling_context		IN VARCHAR2,
p_usec_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_tbl_type,
p_usec_gs_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
p_uso_tbl			IN OUT NOCOPY igs_ps_generic_pub.uso_tbl_type,
p_unit_ref_tbl			IN OUT NOCOPY igs_ps_generic_pub.unit_ref_tbl_type,
p_uso_ins_tbl			IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type,
p_usec_occurs_facility_tbl	IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_tbl_type,
p_usec_teach_resp_ovrd_tbl	IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_tbl_type,
p_usec_notes_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_notes_tbl_type,
p_usec_assmnt_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_tbl_type,
p_usec_plus_hr_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_tbl_type,
p_usec_cat_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_cat_tbl_type,
p_usec_rule_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_rule_tbl_type,
p_usec_cross_group_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_tbl_type,
p_usec_meet_with_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_tbl_type,
p_usec_waitlist_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_tbl_type,
p_usec_res_seat_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_tbl_type,
p_usec_sp_fee_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_tbl_type,
p_usec_ret_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_ret_tbl_type,
p_usec_ret_dtl_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_tbl_type,
p_usec_enr_dead_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_tbl_type,
p_usec_enr_dis_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_tbl_type,
p_usec_teach_resp_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_tbl_type,
p_usec_ass_item_grp_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_tbl_type,
p_usec_status			OUT NOCOPY VARCHAR2,
p_usec_gs_status		OUT NOCOPY VARCHAR2,
p_uso_status			OUT NOCOPY VARCHAR2,
p_uso_ins_status		OUT NOCOPY VARCHAR2,
p_uso_facility_status		OUT NOCOPY VARCHAR2,
p_unit_ref_status		OUT NOCOPY VARCHAR2,
p_usec_teach_resp_ovrd_status	OUT NOCOPY VARCHAR2,
p_usec_notes_status		OUT NOCOPY VARCHAR2,
p_usec_assmnt_status		OUT NOCOPY VARCHAR2,
p_usec_plus_hr_status		OUT NOCOPY VARCHAR2,
p_usec_cat_status		OUT NOCOPY VARCHAR2,
p_usec_rule_status		OUT NOCOPY VARCHAR2,
p_usec_cross_group_status	OUT NOCOPY VARCHAR2,
p_usec_meet_with_status		OUT NOCOPY VARCHAR2,
p_usec_waitlist_status		OUT NOCOPY VARCHAR2,
p_usec_res_seat_status		OUT NOCOPY VARCHAR2,
p_usec_sp_fee_status		OUT NOCOPY VARCHAR2,
p_usec_ret_status		OUT NOCOPY VARCHAR2,
p_usec_ret_dtl_status		OUT NOCOPY VARCHAR2,
p_usec_enr_dead_status		OUT NOCOPY VARCHAR2,
p_usec_enr_dis_status		OUT NOCOPY VARCHAR2,
p_usec_teach_resp_status	OUT NOCOPY VARCHAR2,
p_usec_ass_item_grp_status	OUT NOCOPY VARCHAR2 ) AS
/***********************************************************************************************
Created By:         Sanjeeb Rakshit
Date Created By:    25-May-2005
Purpose:            This is a public API to import data from external system to OSS.
Known limitations,enhancements,remarks:

Change History

Who         When           What
sommukhe    27-SEP-2005     BUG #4632652.FND logging included.
***********************************************************************************************/


l_api_name      CONSTANT VARCHAR2(30) := 'psp_import';
l_api_version   CONSTANT NUMBER := 1.0;
l_record_exists BOOLEAN := FALSE;
BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_generic_pvt.psp_import.start_logging_for',
                    'Data import from external Sysytem to OSS ');
  END IF;

  --Standard start of API savepoint
  SAVEPOINT psp_import_PVT;

  --Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version ,
                                     p_api_version ,
                                     l_api_name    ,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  --API body
  IF p_calling_context NOT IN ('S','G') THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_PS_INVALID_VALUE_CONTEXT');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  --API body
  p_usec_status	                := 'S';
  p_usec_gs_status              := 'S';
  p_uso_status	                := 'S';
  p_uso_ins_status              := 'S';
  p_uso_facility_status	        := 'S';
  p_unit_ref_status	        := 'S';
  p_usec_teach_resp_ovrd_status := 'S';
  p_usec_notes_status		:= 'S';
  p_usec_assmnt_status		:= 'S';
  p_usec_plus_hr_status		:= 'S';
  p_usec_cat_status		:= 'S';
  p_usec_rule_status		:= 'S';
  p_usec_cross_group_status	:= 'S';
  p_usec_meet_with_status	:= 'S';
  p_usec_waitlist_status	:= 'S';
  p_usec_res_seat_status	:= 'S';
  p_usec_sp_fee_status		:= 'S';
  p_usec_ret_status		:= 'S';
  p_usec_ret_dtl_status		:= 'S';
  p_usec_enr_dead_status	:= 'S';
  p_usec_enr_dis_status		:= 'S';
  p_usec_teach_resp_status	:= 'S';
  p_usec_ass_item_grp_status	:= 'S';


  --Similarly for all the other PL/SQL table status variable


  --Call the Unit Section sub process
  IF p_usec_tbl.COUNT > 0 THEN
    SAVEPOINT create_unit_section;

    igs_ps_unit_lgcy_pkg.create_unit_section( p_usec_tbl,p_usec_status,p_calling_context);
    l_record_exists := TRUE;

    IF p_usec_status = 'E' THEN
      --Set the API status to 'E'
      x_return_status := 'E';
      --Set the record status to 'P' for the 'S' marked record
      FOR I in 1..p_uso_tbl.LAST LOOP
          IF p_usec_tbl.EXISTS(I) THEN
              IF p_usec_tbl(I).status = 'S' THEN
                 p_usec_tbl(I).status := 'P';
	      END IF;
	  END IF;
      END LOOP;
      ROLLBACK TO create_unit_section;
     END IF;
  END IF;


  --Call the Unit Section Grading schema sub process
  IF p_usec_gs_tbl.COUNT > 0 THEN
    SAVEPOINT create_usec_grd_sch;

    igs_ps_unit_lgcy_pkg.create_usec_grd_sch( p_usec_gs_tbl,p_usec_gs_status,p_calling_context);
    l_record_exists := TRUE;

    IF p_usec_gs_status = 'E' THEN
      --Set the API status to 'E'
      x_return_status := 'E';
      --Set the record status to 'P' for the 'S' marked record
      FOR I in 1..p_usec_gs_tbl.LAST LOOP
          IF p_usec_gs_tbl.EXISTS(I) THEN
              IF p_usec_gs_tbl(I).status = 'S' THEN
                 p_usec_gs_tbl(I).status := 'P';
	      END IF;
	  END IF;
      END LOOP;
      ROLLBACK TO create_usec_grd_sch;
    END IF;
  END IF;


  --Call the Unit Section Occurrence sub process

  IF p_uso_tbl.COUNT > 0 THEN
    SAVEPOINT create_usec_occur;

    igs_ps_unit_lgcy_pkg.create_usec_occur( p_uso_tbl,p_uso_status,p_calling_context);
    l_record_exists := TRUE;

    IF p_uso_status = 'E' THEN
      --Set the API status to 'E'
      x_return_status := 'E';
      --Set the record status to 'P' for the 'S' marked record
      FOR I in 1..p_uso_tbl.LAST LOOP
          IF p_uso_tbl.EXISTS(I) THEN
              IF p_uso_tbl(I).status = 'S' THEN
                 p_uso_tbl(I).status := 'P';
	      END IF;
	  END IF;
      END LOOP;
      ROLLBACK TO create_usec_occur;
    END IF;
  END IF;


  -- Call the Unit Section Occurrence Instructors sub process
  IF p_uso_ins_tbl.COUNT > 0 THEN
     SAVEPOINT create_uso_ins;

     igs_ps_create_generic_pkg.create_uso_ins_ovrd(p_uso_ins_tbl,p_uso_ins_status,p_calling_context);

     l_record_exists := TRUE;

     IF p_uso_ins_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_uso_ins_tbl.LAST LOOP
            IF p_uso_ins_tbl.EXISTS(I) THEN
              IF p_uso_ins_tbl(I).status = 'S' THEN
                 p_uso_ins_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_uso_ins;
     END IF;
  END IF;


  -- Call the Unit Section Occurrence Facilities sub process
  IF p_usec_occurs_facility_tbl.COUNT > 0 THEN
     SAVEPOINT create_uso_facility;

     igs_ps_create_generic_pkg.create_uso_facility(p_usec_occurs_facility_tbl,p_uso_facility_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_uso_facility_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_occurs_facility_tbl.LAST LOOP
            IF p_usec_occurs_facility_tbl.EXISTS(I) THEN
              IF p_usec_occurs_facility_tbl(I).status = 'S' THEN
                 p_usec_occurs_facility_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_uso_facility;
     END IF;
  END IF;


  -- Call the Unit Section/ Occurrence reference codes sub process
  IF p_unit_ref_tbl.COUNT > 0 THEN
     SAVEPOINT create_unit_ref_code;

     igs_ps_unit_lgcy_pkg.create_unit_ref_code(p_unit_ref_tbl,p_unit_ref_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_unit_ref_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_unit_ref_tbl.LAST LOOP
            IF p_unit_ref_tbl.EXISTS(I) THEN
              IF p_unit_ref_tbl(I).status = 'S' THEN
                 p_unit_ref_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_unit_ref_code;
     END IF;
  END IF;


  -- Call the Unit Section teaching responsibility Override sub process
  IF p_usec_teach_resp_ovrd_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_teach_resp_ovrd;

     igs_ps_create_generic_pkg.create_usec_teach_resp_ovrd(p_usec_teach_resp_ovrd_tbl,p_usec_teach_resp_ovrd_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_teach_resp_ovrd_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_teach_resp_ovrd_tbl.LAST LOOP
            IF p_usec_teach_resp_ovrd_tbl.EXISTS(I) THEN
              IF p_usec_teach_resp_ovrd_tbl(I).status = 'S' THEN
                 p_usec_teach_resp_ovrd_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_teach_resp_ovrd;
     END IF;
  END IF;


  -- Call the Unit Section Notes sub process
  IF p_usec_notes_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_notes;

     igs_ps_create_generic_pkg.create_usec_notes(p_usec_notes_tbl,p_usec_notes_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_notes_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_notes_tbl.LAST LOOP
            IF p_usec_notes_tbl.EXISTS(I) THEN
              IF p_usec_notes_tbl(I).status = 'S' THEN
                 p_usec_notes_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_notes;
     END IF;
  END IF;


  -- Call the Unit Section Assessment sub process
  IF p_usec_assmnt_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_assmnt;

     igs_ps_create_generic_pkg.create_usec_assmnt(p_usec_assmnt_tbl,p_usec_assmnt_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_assmnt_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_assmnt_tbl.LAST LOOP
            IF p_usec_assmnt_tbl.EXISTS(I) THEN
              IF p_usec_assmnt_tbl(I).status = 'S' THEN
                 p_usec_assmnt_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_assmnt;
     END IF;
  END IF;

  -- Call the Unit Section Plus Hour sub process
  IF p_usec_plus_hr_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_plus_hr;

     igs_ps_create_generic_pkg.create_usec_plus_hr(p_usec_plus_hr_tbl,p_usec_plus_hr_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_plus_hr_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_plus_hr_tbl.LAST LOOP
            IF p_usec_plus_hr_tbl.EXISTS(I) THEN
              IF p_usec_plus_hr_tbl(I).status = 'S' THEN
                 p_usec_plus_hr_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_plus_hr;
     END IF;
  END IF;

  -- Call the Unit Section Categories sub process
  IF p_usec_cat_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_cat;

     igs_ps_create_generic_pkg.create_usec_cat(p_usec_cat_tbl,p_usec_cat_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_cat_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_cat_tbl.LAST LOOP
            IF p_usec_cat_tbl.EXISTS(I) THEN
              IF p_usec_cat_tbl(I).status = 'S' THEN
                 p_usec_cat_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_cat;
     END IF;
  END IF;

  -- Call the Unit Section Rule sub process
  IF p_usec_rule_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_rule;

     igs_ps_create_generic_pkg.create_usec_rule(p_usec_rule_tbl,p_usec_rule_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_rule_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_rule_tbl.LAST LOOP
            IF p_usec_rule_tbl.EXISTS(I) THEN
              IF p_usec_rule_tbl(I).status = 'S' THEN
                 p_usec_rule_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_rule;
     END IF;
  END IF;

  -- Call the Unit Section Cross Listed Group sub process
  IF p_usec_cross_group_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_cross_group;

     igs_ps_create_generic_pkg.create_usec_cross_group(p_usec_cross_group_tbl,p_usec_cross_group_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_cross_group_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_cross_group_tbl.LAST LOOP
            IF p_usec_cross_group_tbl.EXISTS(I) THEN
              IF p_usec_cross_group_tbl(I).status = 'S' THEN
                 p_usec_cross_group_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_cross_group;
     END IF;
  END IF;


  -- Call the Unit Section Meet With Group sub process
  IF p_usec_meet_with_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_meet_with;

     igs_ps_create_generic_pkg.create_usec_meet_with(p_usec_meet_with_tbl,p_usec_meet_with_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_meet_with_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_meet_with_tbl.LAST LOOP
            IF p_usec_meet_with_tbl.EXISTS(I) THEN
              IF p_usec_meet_with_tbl(I).status = 'S' THEN
                 p_usec_meet_with_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_meet_with;
     END IF;
  END IF;

  -- Call the Unit Section Waitlist sub process
  IF p_usec_waitlist_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_waitlist;

     igs_ps_create_generic_pkg.create_usec_waitlist(p_usec_waitlist_tbl,p_usec_waitlist_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_waitlist_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_waitlist_tbl.LAST LOOP
            IF p_usec_waitlist_tbl.EXISTS(I) THEN
              IF p_usec_waitlist_tbl(I).status = 'S' THEN
                 p_usec_waitlist_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_waitlist;
     END IF;
  END IF;

  -- Call the Unit Section Reserve Seating sub process
  IF p_usec_res_seat_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_res_seat;

     igs_ps_create_generic_pkg.create_usec_res_seat(p_usec_res_seat_tbl,p_usec_res_seat_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_res_seat_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_res_seat_tbl.LAST LOOP
            IF p_usec_res_seat_tbl.EXISTS(I) THEN
              IF p_usec_res_seat_tbl(I).status = 'S' THEN
                 p_usec_res_seat_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_res_seat;
     END IF;
  END IF;

  -- Call the Unit Section Special Fees sub process
  IF p_usec_sp_fee_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_sp_fee;

     igs_ps_create_generic_pkg.create_usec_sp_fee(p_usec_sp_fee_tbl,p_usec_sp_fee_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_sp_fee_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_sp_fee_tbl.LAST LOOP
            IF p_usec_sp_fee_tbl.EXISTS(I) THEN
              IF p_usec_sp_fee_tbl(I).status = 'S' THEN
                 p_usec_sp_fee_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_sp_fee;
     END IF;
  END IF;

  -- Call the Unit Section Retention sub process
  IF p_usec_ret_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_ret;

     igs_ps_create_generic_pkg.create_usec_ret(p_usec_ret_tbl,p_usec_ret_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_ret_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_ret_tbl.LAST LOOP
            IF p_usec_ret_tbl.EXISTS(I) THEN
              IF p_usec_ret_tbl(I).status = 'S' THEN
                 p_usec_ret_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_ret;
     END IF;
  END IF;

  -- Call the Unit Section Retention Details sub process
  IF p_usec_ret_dtl_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_ret_dtl;

     igs_ps_create_generic_pkg.create_usec_ret_dtl(p_usec_ret_dtl_tbl,p_usec_ret_dtl_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_ret_dtl_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_ret_dtl_tbl.LAST LOOP
            IF p_usec_ret_dtl_tbl.EXISTS(I) THEN
              IF p_usec_ret_dtl_tbl(I).status = 'S' THEN
                 p_usec_ret_dtl_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_ret_dtl;
     END IF;
  END IF;

  -- Call the Unit Section Enrollment Deadline sub process
  IF p_usec_enr_dead_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_enr_dead;

     igs_ps_create_generic_pkg.create_usec_enr_dead(p_usec_enr_dead_tbl,p_usec_enr_dead_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_enr_dead_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_enr_dead_tbl.LAST LOOP
            IF p_usec_enr_dead_tbl.EXISTS(I) THEN
              IF p_usec_enr_dead_tbl(I).status = 'S' THEN
                 p_usec_enr_dead_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_enr_dead;
     END IF;
  END IF;

  -- Call the Unit Section Enrollment Discontinuation sub process
  IF p_usec_enr_dis_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_enr_dis;

     igs_ps_create_generic_pkg.create_usec_enr_dis(p_usec_enr_dis_tbl,p_usec_enr_dis_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_enr_dis_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_enr_dis_tbl.LAST LOOP
            IF p_usec_enr_dis_tbl.EXISTS(I) THEN
              IF p_usec_enr_dis_tbl(I).status = 'S' THEN
                 p_usec_enr_dis_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_enr_dis;
     END IF;
  END IF;

  -- Call the Unit Section Teaching Responsibility (for Update only) sub process
  IF p_usec_teach_resp_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_teach_resp;

     igs_ps_create_generic_pkg.create_usec_teach_resp(p_usec_teach_resp_tbl,p_usec_teach_resp_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_teach_resp_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_teach_resp_tbl.LAST LOOP
            IF p_usec_teach_resp_tbl.EXISTS(I) THEN
              IF p_usec_teach_resp_tbl(I).status = 'S' THEN
                 p_usec_teach_resp_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_teach_resp;
     END IF;
  END IF;

  -- Call the Unit Section Assessment Item Group sub process
  IF p_usec_ass_item_grp_tbl.COUNT > 0 THEN
     SAVEPOINT create_usec_ass_item_grp;

     igs_ps_create_generic_pkg.create_usec_ass_item_grp(p_usec_ass_item_grp_tbl,p_usec_ass_item_grp_status,p_calling_context);
     l_record_exists := TRUE;

     IF p_usec_ass_item_grp_status = 'E' THEN
          --Set the API status to 'E'
	  x_return_status := 'E';
	  FOR I in 1..p_usec_ass_item_grp_tbl.LAST LOOP
            IF p_usec_ass_item_grp_tbl.EXISTS(I) THEN
              IF p_usec_ass_item_grp_tbl(I).status = 'S' THEN
                 p_usec_ass_item_grp_tbl(I).status := 'P';
	      END IF;
	    END IF;
          END LOOP;
	  ROLLBACK TO create_usec_ass_item_grp;
     END IF;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_generic_pvt.psp_import.end_of_logging_for',
                    'Data import from external Sysytem to OSS ');
  END IF;

  --If none of the PL/SQL data has been passed then raise error
  IF NOT l_record_exists THEN
    FND_MESSAGE.SET_NAME ('IGS','IGS_PS_LGCY_DATA_NOT_PASSED');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --End of API body

  --Standard check of p_commit
  IF FND_API.TO_Boolean( p_commit) THEN
    COMMIT WORK;
  END IF;

  --Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                             p_data   => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO psp_import_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO psp_import_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO psp_import_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                   l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_generic_pvt.psp_import.in_exception_section_OTHERS.err_msg',
			  SUBSTRB(SQLERRM,1,4000));
	END IF;

END psp_import;

END igs_ps_generic_pvt;

/
