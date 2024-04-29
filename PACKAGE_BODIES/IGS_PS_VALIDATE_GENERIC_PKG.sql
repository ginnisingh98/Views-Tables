--------------------------------------------------------
--  DDL for Package Body IGS_PS_VALIDATE_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VALIDATE_GENERIC_PKG" AS
/* $Header: IGSPS92B.pls 120.2 2006/02/19 08:19:03 sommukhe noship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Somnath Mukherjee
    Date Created By:  17-Jun-2005
    Purpose        :  This package has the some validation function which will be called from sub processes,
                      in igs_ps_create_generic_pkg package.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

  g_n_user_id igs_ps_unit_ver_all.created_by%TYPE := NVL(fnd_global.user_id,-1);
  g_n_login_id igs_ps_unit_ver_all.last_update_login%TYPE := NVL(fnd_global.login_id,-1);


  PROCEDURE validate_usec_notes(p_usec_notes_rec IN OUT NOCOPY igs_ps_generic_pub.usec_notes_rec_type,
                                p_n_uoo_id       IN NUMBER)
  AS
   /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:
    Purpose        :  This function will do validations after inserting records of Unit Section NOTES.
                      .

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  v_message_name VARCHAR2(30);
  BEGIN
    IF NOT igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_notes_rec.unit_cd, p_usec_notes_rec.version_number,v_message_name ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS');
      fnd_msg_pub.add;
      p_usec_notes_rec.status := 'E';
    END IF;

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_usec_notes_rec.status := 'E';
    END IF;

  END validate_usec_notes;


 PROCEDURE validate_usec_assmnt ( p_usec_assmnt_rec     IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_rec_type,
                                  p_n_uoo_id            igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
				  p_d_exam_start_time	igs_ps_usec_as.exam_start_time%TYPE,
                                  p_d_exam_end_time	igs_ps_usec_as.exam_end_time%TYPE,
                                  p_n_building_id       NUMBER,
				  p_n_room_id           NUMBER,
				  p_insert_update       VARCHAR2)
 AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:
    Purpose        :  This function will do validations before inserting records of Unit Section Assesments.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR c_check_host(cp_uoo_id IN igs_ps_us_exam_meet.exam_meet_group_id%TYPE) IS
    SELECT host
    FROM   igs_ps_us_exam_meet
    WHERE  uoo_id = cp_uoo_id;

    l_host igs_ps_us_exam_meet.host%TYPE;

    CURSOR c_building(cp_building_id igs_ad_building_all.building_id%TYPE,
                      cp_location_cd igs_ad_building_all.location_cd%TYPE ) IS
    SELECT 'X'
    FROM   igs_ad_building_all
    WHERE  building_id = cp_building_id
    AND    location_cd = cp_location_cd
    AND    closed_ind = 'N';

    CURSOR c_room(cp_room_id igs_ad_room_all.room_id%TYPE,cp_building_id igs_ad_building_all.building_id%TYPE) IS
    SELECT 'X'
    FROM   igs_ad_room_all
    WHERE  room_id = cp_room_id
    AND    building_id =cp_building_id
    AND    closed_ind = 'N';
    l_c_var VARCHAR2(1);

  BEGIN

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_usec_assmnt_rec.status := 'E';
    END IF;

    IF p_usec_assmnt_rec.final_exam_date IS NOT NULL
       AND (p_d_exam_start_time IS NULL OR p_d_exam_end_time IS NULL ) THEN
         fnd_message.set_name ('IGS','IGS_PS_XM_ST_END_TIME_ENTR' );
         fnd_msg_pub.add;
         p_usec_assmnt_rec.status := 'E';
    END IF;

    IF p_d_exam_end_time IS NOT NULL AND p_d_exam_start_time IS NOT NULL
       AND (TO_NUMBER(TO_CHAR(p_d_exam_end_time,'HH24MI')) <
            TO_NUMBER(TO_CHAR(p_d_exam_start_time,'HH24MI'))) THEN
           fnd_message.set_name ( 'IGS','IGS_PS_XM_END_GR_ST_TM');
           fnd_msg_pub.add;
           p_usec_assmnt_rec.status := 'E';
    END IF;

    IF (p_d_exam_start_time IS NOT NULL OR p_d_exam_end_time IS NOT NULL) AND  (p_usec_assmnt_rec.final_exam_date IS NULL ) THEN
           fnd_message.set_name ('IGS','IGS_PS_FIN_XM_DT_ST_ET');
           fnd_msg_pub.add;
           p_usec_assmnt_rec.status := 'E';
    END IF;

    IF p_n_building_id IS NOT NULL  THEN
      OPEN c_building(p_n_building_id,p_usec_assmnt_rec.exam_location_cd);
      FETCH c_building INTO l_c_var;
      IF c_building%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'BUILDING_CODE', 'LEGACY_TOKENS', FALSE);
          p_usec_assmnt_rec.status := 'E';
      END IF;
      CLOSE c_building;
    END IF;

    IF p_n_building_id IS NOT NULL AND p_n_room_id IS NOT NULL THEN
      OPEN c_room(p_n_room_id,p_n_building_id);
      FETCH c_room INTO l_c_var;
      IF c_room%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
          p_usec_assmnt_rec.status := 'E';
      END IF;
      CLOSE c_room;
    END IF;


    IF p_insert_update = 'U' THEN
      OPEN c_check_host(p_n_uoo_id );
      FETCH c_check_host INTO l_host;
      IF c_check_host%FOUND THEN
	IF l_host = 'Y' THEN
	  fnd_message.set_name('IGS','IGS_PS_CHANGE_US_HOST_REM');
	  fnd_msg_pub.add;
	  p_usec_assmnt_rec.status := 'E';
	END IF;
      END IF;
      CLOSE c_check_host;
    END IF;

  END validate_usec_assmnt;


  PROCEDURE validate_tch_rsp_ovrd ( p_tch_rsp_ovrd_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type,
                                    p_n_uoo_id         IN NUMBER)
    AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  l_c_message  VARCHAR2(30);
  BEGIN
    -- Check if unit status is inactive.
    IF NOT igs_ps_val_unit.crsp_val_iud_uv_dtl(p_tch_rsp_ovrd_rec.unit_cd,p_tch_rsp_ovrd_rec.version_number,l_c_message) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
      fnd_msg_pub.add;
      p_tch_rsp_ovrd_rec.status := 'E';
    END IF;

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_tch_rsp_ovrd_rec.status := 'E';
    END IF;

    -- Check if orgunit is inactive.
    IF NOT igs_ps_val_crv.crsp_val_ou_sys_sts(p_tch_rsp_ovrd_rec.org_unit_cd,p_tch_rsp_ovrd_rec.ou_start_dt,l_c_message) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_ORGUNIT_STATUS_INACTIV' );
      fnd_msg_pub.add;
      p_tch_rsp_ovrd_rec.status := 'E';
    END IF;
  END validate_tch_rsp_ovrd;

  ---validations before inserting/updating  Unit Section Assessment item group records
  PROCEDURE validate_as_us_ai_group (p_as_us_ai_group_rec IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,
				     p_n_uoo_id NUMBER)
  AS
/***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR cur_usec (cp_uoo_id NUMBER) IS
    SELECT 'X'
    FROM   igs_ps_unit_ofr_opt_all
    WHERE  uoo_id = cp_uoo_id
    AND    NVL(enrollment_actual,0) > 0;
    l_c_var VARCHAR2(1);
    l_c_message  VARCHAR2(30);

  BEGIN
    IF p_as_us_ai_group_rec.final_formula_code  IN ('ATLEAST_N', 'BEST_N') THEN
      IF p_as_us_ai_group_rec.final_formula_qty IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'FINAL_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
      END IF;
    END IF;

    IF p_as_us_ai_group_rec.final_formula_code  IN ('ATLEAST_N', 'BEST_N','WEIGHTED_AVERAGE') THEN
      IF p_as_us_ai_group_rec.final_weight_qty IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'FINAL_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
      END IF;
    END IF;

    IF (p_as_us_ai_group_rec.midterm_formula_code IS NOT NULL) AND  (p_as_us_ai_group_rec.midterm_formula_code  IN ('ATLEAST_N', 'BEST_N')) THEN
      IF p_as_us_ai_group_rec.midterm_formula_qty IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'MIDTERM_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
      END IF;
    END IF;

    IF (p_as_us_ai_group_rec.midterm_formula_code IS NOT NULL) AND (p_as_us_ai_group_rec.midterm_formula_code IN ('ATLEAST_N', 'BEST_N','WEIGHTED_AVERAGE')) THEN
      IF p_as_us_ai_group_rec.midterm_weight_qty IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'MIDTERM_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
      END IF;
    END IF;


    --Final formula qty cannot have value when final formula code is null
    IF p_as_us_ai_group_rec.final_formula_qty IS NOT NULL AND  p_as_us_ai_group_rec.final_formula_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FINAL_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
    END IF;

    --Final weight qty cannot have value when final formula code is null
    IF p_as_us_ai_group_rec.final_weight_qty IS NOT NULL AND  p_as_us_ai_group_rec.final_formula_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FINAL_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
    END IF;

    --Midterm weight qty cannot have value when Midterm formula code is null
    IF p_as_us_ai_group_rec.midterm_weight_qty IS NOT NULL AND  p_as_us_ai_group_rec.midterm_formula_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'MIDTERM_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
    END IF;

    --Midterm formula qty cannot have value when Midterm formula code is null
    IF p_as_us_ai_group_rec.midterm_formula_qty IS NOT NULL AND  p_as_us_ai_group_rec.midterm_formula_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'MIDTERM_FORMULA_QTY', 'LEGACY_TOKENS', FALSE);
        p_as_us_ai_group_rec.status := 'E';
    END IF;



    IF (p_as_us_ai_group_rec.final_formula_code IS NOT NULL) AND  (p_as_us_ai_group_rec.final_formula_code NOT IN ('ATLEAST_N', 'BEST_N','WEIGHTED_AVERAGE')) THEN
      p_as_us_ai_group_rec.status := 'E';
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FINAL_FORMULA_CODE', 'LEGACY_TOKENS', FALSE);
    END IF;

    IF (p_as_us_ai_group_rec.midterm_formula_code IS NOT NULL) AND  (p_as_us_ai_group_rec.midterm_formula_code NOT IN ('ATLEAST_N', 'BEST_N','WEIGHTED_AVERAGE')) THEN
      p_as_us_ai_group_rec.status := 'E';
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'MIDTERM_FORMULA_CODE', 'LEGACY_TOKENS', FALSE);
    END IF;

    --Check if enrollment exists against a unit section then import is not allowed
    OPEN cur_usec(p_n_uoo_id) ;
    FETCH cur_usec INTO l_c_var;
    IF cur_usec%FOUND THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_ENR_EXISTS_NO_IMPORT' );
      fnd_msg_pub.add;
      p_as_us_ai_group_rec.status := 'E';
    END IF;
    CLOSE cur_usec;

    --check if location code is closed.
    IF NOT igs_ps_val_uoo.crsp_val_loc_cd(p_as_us_ai_group_rec.location_cd,l_c_message) THEN
      fnd_message.set_name ( 'IGS', l_c_message );
      fnd_msg_pub.add;
      p_as_us_ai_group_rec.status := 'E';
    END IF;

    -- Check if unit status is inactive.
    IF NOT igs_ps_val_unit.crsp_val_iud_uv_dtl(p_as_us_ai_group_rec.unit_cd,p_as_us_ai_group_rec.version_number,l_c_message) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
      fnd_msg_pub.add;
      p_as_us_ai_group_rec.status := 'E';
    END IF;

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_as_us_ai_group_rec.status := 'E';
    END IF;

  END validate_as_us_ai_group;

 -- validations before inserting/updating  Unit Section Assessment item records
 PROCEDURE validate_unitass_item ( p_unitass_item_rec   IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_rec_type,
                                   p_cal_type           IN VARCHAR2,
				   p_ci_sequence_number NUMBER,
				   p_n_uoo_id           NUMBER,
				   p_insert             VARCHAR2)
    AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    CURSOR cp_st_en_dt(cp_cal_type VARCHAR ,cp_seq_number NUMBER) IS
    SELECT start_dt, end_dt
    FROM   igs_ca_inst
    WHERE  cal_type = cp_cal_type
    AND    sequence_number = cp_seq_number;

    cp_st_en_dt_rec cp_st_en_dt%ROWTYPE;

    CURSOR c_reference(cp_n_uoo_id NUMBER,cp_reference VARCHAR2) IS
    SELECT 'X'
    FROM   igs_ps_unitass_item
    WHERE  uoo_id = cp_n_uoo_id
    AND    reference = cp_reference
    AND    logical_delete_dt IS NULL;

    c_reference_rec c_reference%ROWTYPE;

    CURSOR c_usec(cp_n_uoo_id NUMBER) IS
    SELECT *
    FROM   igs_ps_unit_ofr_opt_all
    WHERE  uoo_id = cp_n_uoo_id;

    c_usec_rec c_usec%ROWTYPE;

    CURSOR c_action_dt(cp_assessment_id igs_as_assessmnt_itm.ass_id%TYPE,cp_uoo_id NUMBER,cp_sequence_number NUMBER) IS
    SELECT *
    FROM igs_ps_unitass_item
    WHERE ass_id =cp_assessment_id
    AND uoo_id =cp_uoo_id
    AND sequence_number =cp_sequence_number ;

    c_action_dt_rec c_action_dt%ROWTYPE;
    l_c_message  VARCHAR2(30);


    CURSOR cur_assessment_id(cp_assessment_id  igs_as_assessmnt_itm.ass_id%TYPE ) IS
    SELECT assessment_type
    FROM   igs_as_assessmnt_itm
    WHERE  ass_id = cp_assessment_id;
    l_cur_assessment_id  cur_assessment_id%ROWTYPE;

    l_grading_schema_cd igs_ps_unitass_item.grading_schema_cd%TYPE;
    l_gs_version_number igs_ps_unitass_item.gs_version_number%TYPE;
    l_description       igs_as_grd_schema.description%TYPE;
    l_approved          VARCHAR2 (1);

    CURSOR cur_grading_approved(cp_unit_cd VARCHAR2,cp_version_number NUMBER,cp_assessment_type VARCHAR2,cp_grading_schema_cd VARCHAR2,cp_gs_version_number NUMBER) IS
    SELECT 'X'
    FROM   igs_as_appr_grd_sch  agrs,
	   igs_as_grd_schema grd
    WHERE grd.grading_schema_cd = agrs.grading_schema_cd
    AND grd.version_number = agrs.gs_version_number
    AND agrs.unit_cd = cp_unit_cd
    AND agrs.version_number = cp_version_number
    AND agrs.assessment_type = cp_assessment_type
    AND agrs.closed_ind = 'N'
    AND agrs.grading_schema_cd = cp_grading_schema_cd
    AND agrs.gs_version_number = cp_gs_version_number;

    CURSOR cur_grading_assess(cp_grading_schema_cd VARCHAR2,cp_gs_version_number NUMBER) IS
    SELECT 'X'
    FROM  igs_as_grd_schema
    WHERE grading_schema_cd = cp_grading_schema_cd
    AND version_number = cp_gs_version_number
    AND NVL(end_dt,SYSDATE) >= SYSDATE
    AND grading_schema_type = 'ASSESSMENT_ITEM';

    l_c_var VARCHAR2(1);
    l_c_token_val   fnd_new_messages.message_text%TYPE;

  BEGIN

    IF (p_unitass_item_rec.midterm_mandatory_type_code IS NOT NULL) AND  (p_unitass_item_rec.midterm_mandatory_type_code NOT IN ('MANDATORY', 'MANDATORY_PASS','OPTIONAL')) THEN
      p_unitass_item_rec.status := 'E';
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'MIDTERM_MANDATORY_TYPE_CD', 'LEGACY_TOKENS', FALSE);
    END IF;

    IF (p_unitass_item_rec.final_mandatory_type_code IS NOT NULL) AND  (p_unitass_item_rec.final_mandatory_type_code NOT IN ('MANDATORY', 'MANDATORY_PASS','OPTIONAL')) THEN
      p_unitass_item_rec.status := 'E';
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FINAL_MANDATORY_TYPE_CD', 'LEGACY_TOKENS', FALSE);
    END IF;

    --If midterm_mandatory_type_code is not null then MIDTERM_WEIGHT_QTY is mandatory.
    IF p_unitass_item_rec.midterm_mandatory_type_code IS NOT NULL THEN
      IF p_unitass_item_rec.midterm_weight_qty_item IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'MIDTERM_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
        p_unitass_item_rec.status := 'E';
      END IF;
    END IF;

    --If final_mandatory_type_code is not null then FINAL_WEIGHT_QTY is mandatory.
    IF p_unitass_item_rec.final_mandatory_type_code IS NOT NULL THEN
      IF p_unitass_item_rec.final_weight_qty_item IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'FINAL_WEIGHT_QTY', 'LEGACY_TOKENS', FALSE);
        p_unitass_item_rec.status := 'E';
      END IF;
    END IF;


    --Midterm weight qty cannot have value when Midterm mandatory Type code is null
    IF p_unitass_item_rec.midterm_weight_qty_item IS NOT NULL AND  p_unitass_item_rec.midterm_mandatory_type_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'MIDTERM_WEIGHT_QTY_ITEM', 'LEGACY_TOKENS', FALSE);
        p_unitass_item_rec.status := 'E';
    END IF;

    --Final weight qty cannot have value when Final mandatory Type code is null
    IF p_unitass_item_rec.final_weight_qty_item IS NOT NULL AND  p_unitass_item_rec.final_mandatory_type_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'FINAL_WEIGHT_QTY_ITEM', 'LEGACY_TOKENS', FALSE);
        p_unitass_item_rec.status := 'E';
    END IF;



    --Validate grading schema code
    OPEN cur_assessment_id(p_unitass_item_rec.assessment_id);
    FETCH cur_assessment_id INTO l_cur_assessment_id;
    CLOSE cur_assessment_id;
    igs_as_gen_003.get_default_grds (
          x_unit_cd                      => p_unitass_item_rec.unit_cd,
          x_version_number               => p_unitass_item_rec.version_number,
          x_assessment_type              => l_cur_assessment_id.assessment_type,
          x_grading_schema_cd            => l_grading_schema_cd,
          x_gs_version_number            => l_gs_version_number,
          x_description                  => l_description,
          x_approved                     => l_approved
        );
    IF NVL (l_approved, 'N') = 'Y' THEN
      OPEN cur_grading_approved(p_unitass_item_rec.unit_cd,p_unitass_item_rec.version_number,l_cur_assessment_id.assessment_type,p_unitass_item_rec.grading_schema_cd,p_unitass_item_rec.gs_version_number);
      FETCH cur_grading_approved INTO l_c_var;
      IF cur_grading_approved%NOTFOUND THEN
	igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'GRADINGS_SCHEMA_CD', 'LEGACY_TOKENS', FALSE);
	p_unitass_item_rec.status := 'E';
      END IF;
      CLOSE cur_grading_approved;
    ELSE
      OPEN cur_grading_assess(p_unitass_item_rec.grading_schema_cd,p_unitass_item_rec.gs_version_number);
      FETCH cur_grading_assess INTO l_c_var;
      IF cur_grading_assess%NOTFOUND THEN
	igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'GRADINGS_SCHEMA_CD', 'LEGACY_TOKENS', FALSE);
	p_unitass_item_rec.status := 'E';
      END IF;
      CLOSE cur_grading_assess;
    END IF;

    --Release date should be greater than or equal to due date
    IF p_unitass_item_rec.release_date IS NOT NULL AND p_unitass_item_rec.due_dt IS NOT NULL THEN
      IF p_unitass_item_rec.release_date <  p_unitass_item_rec.due_dt THEN
        fnd_message.set_name ( 'IGS', 'IGS_AS_DUE_DT_LESS_RELEASE_DT' );
        fnd_msg_pub.add;
        p_unitass_item_rec.status := 'E';
      END IF;
    END IF;


    IF p_insert = 'I' THEN
      OPEN c_reference(p_n_uoo_id,p_unitass_item_rec.reference);
      FETCH c_reference INTO c_reference_rec;
      IF c_reference%FOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_REF_USAI_UNIQUE_US' );
        fnd_msg_pub.add;
        p_unitass_item_rec.status := 'E';
      END IF;
      CLOSE c_reference;
    ELSE
      OPEN c_action_dt(p_unitass_item_rec.assessment_id,p_n_uoo_id,p_unitass_item_rec.sequence_number);
      FETCH c_action_dt INTO c_action_dt_rec;
      IF c_action_dt_rec.reference <>p_unitass_item_rec.reference THEN
        OPEN c_reference(p_n_uoo_id,p_unitass_item_rec.reference);
        FETCH c_reference INTO c_reference_rec;
        IF c_reference%FOUND THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_REF_USAI_UNIQUE_US' );
          fnd_msg_pub.add;
          p_unitass_item_rec.status := 'E';
        END IF;
        CLOSE c_reference;
      END IF;
      CLOSE c_action_dt;
    END IF;



    --If item is examinable then validate that reference is set
    IF  NVL (p_unitass_item_rec.reference, 'NULL666') = 'NULL666'
       AND (igs_as_val_aiem.assp_val_ai_exmnbl (p_unitass_item_rec.assessment_id, l_c_message) OR igs_as_gen_002.assp_get_ai_s_type (p_unitass_item_rec.assessment_id) = 'ASSIGNMENT') THEN
       fnd_message.set_name ( 'IGS', 'IGS_AS_REF_ASSITEM_EXAM' );
       fnd_msg_pub.add;
       p_unitass_item_rec.status := 'E';
    END IF;

    --If the assessment item is examinable,Validate that the reference number id unique within a UOP.Else if record has not been deleted, again validate the reference number.
    IF igs_as_val_aiem.assp_val_ai_exmnbl (p_unitass_item_rec.assessment_id, l_c_message) = TRUE THEN
      IF igs_as_val_uai.assp_val_uai_uniqref (p_unitass_item_rec.unit_cd,
                                              p_unitass_item_rec.version_number,
					      p_cal_type, p_ci_sequence_number,
					      p_unitass_item_rec.sequence_number,
					      p_unitass_item_rec.reference,
					      p_unitass_item_rec.assessment_id,
					      l_c_message) = FALSE THEN
        fnd_message.set_name ( 'IGS', l_c_message );
        fnd_msg_pub.add;
        p_unitass_item_rec.status := 'E';
      ELSIF NVL(p_unitass_item_rec.logical_delete_dt, igs_ge_date.igsdate ('1900/01/01')) = igs_ge_date.igsdate ('1900/01/01') THEN
        IF igs_ps_val_uai.assp_val_uai_opt_ref (
					       p_unitass_item_rec.unit_cd,
					       p_unitass_item_rec.version_number,
					       p_cal_type, p_ci_sequence_number,
					       p_unitass_item_rec.sequence_number,
					       p_unitass_item_rec.reference,
					       p_unitass_item_rec.assessment_id,
					       igs_as_gen_001.assp_get_ai_a_type (p_unitass_item_rec.assessment_id),
					       l_c_message) = FALSE THEN

	  fnd_message.set_name ( 'IGS', l_c_message );
          fnd_msg_pub.add;
          p_unitass_item_rec.status := 'E';
	END IF;
      END IF;
    END IF;

    --validations on Due date
    OPEN c_usec(p_n_uoo_id);
    FETCH c_usec INTO c_usec_rec;
    OPEN cp_st_en_dt(p_cal_type, p_ci_sequence_number);
    FETCH cp_st_en_dt INTO cp_st_en_dt_rec;
    IF p_unitass_item_rec.due_dt IS NOT NULL THEN
      IF c_usec_rec.unit_section_start_date IS NOT NULL
	 OR c_usec_rec.unit_section_end_date IS NOT NULL THEN
	IF c_usec_rec.unit_section_start_date IS NULL THEN
	  IF p_unitass_item_rec.due_dt < TRUNC  (cp_st_en_dt_rec.start_dt)
	     OR p_unitass_item_rec.due_dt > TRUNC (c_usec_rec.unit_section_end_date) THEN
	     fnd_message.set_name ('IGS', 'IGS_PS_USEC_EFFET_DATES');
             l_c_token_val:= fnd_message.get;

	     fnd_message.set_name ('IGS', 'IGS_PS_UA_DUDT_IN_TP');
	     fnd_message.set_token ('PERIOD', l_c_token_val);
	     fnd_msg_pub.add;
	     p_unitass_item_rec.status := 'E';

	  END IF;
	ELSIF c_usec_rec.unit_section_end_date IS NULL THEN
	  IF p_unitass_item_rec.due_dt < TRUNC (c_usec_rec.unit_section_start_date)
	     OR p_unitass_item_rec.due_dt > TRUNC  (cp_st_en_dt_rec.end_dt) THEN
	     fnd_message.set_name ('IGS', 'IGS_PS_USEC_EFFET_DATES');
             l_c_token_val:= fnd_message.get;

	     fnd_message.set_name ('IGS', 'IGS_PS_UA_DUDT_IN_TP');
	     fnd_message.set_token ('PERIOD', l_c_token_val);
	     fnd_msg_pub.add;
	     p_unitass_item_rec.status := 'E';

	  END IF;
	ELSE
	  IF p_unitass_item_rec.due_dt < TRUNC  (c_usec_rec.unit_section_start_date)
	     OR p_unitass_item_rec.due_dt > TRUNC  (c_usec_rec.unit_section_end_date) THEN
	     fnd_message.set_name ('IGS', 'IGS_PS_USEC_EFFET_DATES');
             l_c_token_val:= fnd_message.get;

	     fnd_message.set_name ('IGS', 'IGS_PS_UA_DUDT_IN_TP');
	     fnd_message.set_token ('PERIOD', l_c_token_val);
	     fnd_msg_pub.add;
	     p_unitass_item_rec.status := 'E';

	  END IF;
	END IF;
      ELSE
	IF p_unitass_item_rec.due_dt < TRUNC (cp_st_en_dt_rec.start_dt)
	   OR p_unitass_item_rec.due_dt > TRUNC (cp_st_en_dt_rec.end_dt) THEN
	   fnd_message.set_name ('IGS', 'IGS_PS_TP_DATES');
           l_c_token_val:= fnd_message.get;

	   fnd_message.set_name ('IGS', 'IGS_PS_UA_DUDT_IN_TP');
	   fnd_message.set_token ('PERIOD', l_c_token_val);
	   fnd_msg_pub.add;
	   p_unitass_item_rec.status := 'E';
	END IF;
      END IF;
    END IF;
    CLOSE cp_st_en_dt;
    CLOSE c_usec;

  END validate_unitass_item;


 PROCEDURE validate_uso_clas_meet ( p_uso_clas_meet_rec     IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type,
				    p_n_uoo_id              NUMBER,
				    p_n_class_meet_group_id NUMBER,
				    p_c_cal_type            VARCHAR2,
				    p_n_seq_num             NUMBER)
 AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

   CURSOR cur_usec  IS
   SELECT  'X'
   FROM    igs_ps_unit_ofr_opt_all uoo
   WHERE   uoo.unit_section_status IN ('OPEN','PLANNED','FULLWAITOK','CLOSED')
   AND     uoo.relation_type='NONE'
   AND     uoo.cal_type=p_c_cal_type
   AND     uoo.ci_sequence_number =p_n_seq_num
   AND     uoo.uoo_id=p_n_uoo_id;

  cur_usec_rec cur_usec%ROWTYPE;

  CURSOR cur_std_attempt(cp_uoo_id   igs_en_su_attempt.uoo_id%TYPE) IS
  SELECT *
  FROM   igs_en_su_attempt
  WHERE  uoo_id=cp_uoo_id
  AND    unit_attempt_status='WAITLISTED';

  CURSOR  c_x_grpmem(cp_uoo_id  igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT 'X'
  FROM   igs_ps_usec_x_grpmem
  WHERE  uoo_id=cp_uoo_id;

  c_x_grpmem_rec c_x_grpmem%ROWTYPE;

  CURSOR  cur_waitlist(cp_uoo_id   igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  waitlist_actual
  FROM    igs_ps_unit_ofr_opt
  WHERE   uoo_id=cp_uoo_id;
  l_cur_waitlist  cur_waitlist%ROWTYPE;

  l_sysdate DATE := trunc(SYSDATE);



 BEGIN

   --Check if the unit section is NOT_OFFERED
   IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
     fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
     fnd_msg_pub.add;
     p_uso_clas_meet_rec.status := 'E';
   END IF;

   --Validation on selection of
   OPEN cur_usec;
   FETCH cur_usec INTO cur_usec_rec;
   IF cur_usec%NOTFOUND THEN
     igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
     p_uso_clas_meet_rec.status := 'E';
   END IF;
   CLOSE cur_usec;

   --This unit section should not be present in any cross listed Unit section group
   OPEN c_x_grpmem(p_n_uoo_id);
   FETCH c_x_grpmem INTO c_x_grpmem_rec;
   IF c_x_grpmem%FOUND THEN
     fnd_message.set_name('IGS','IGS_PS_UNT_SEC_DEFINED_GRP');
     fnd_msg_pub.add;
     p_uso_clas_meet_rec.status := 'E';
   END IF;
   CLOSE c_x_grpmem;

   OPEN  cur_waitlist(p_n_uoo_id);
   FETCH cur_waitlist INTO l_cur_waitlist;
   IF l_cur_waitlist.waitlist_actual >= 1 THEN
     FOR  l_c_fetch_record_cur IN  cur_std_attempt(p_n_uoo_id) LOOP

	DECLARE
	FUNCTION get_msg_from_stack(l_n_msg_count NUMBER) RETURN VARCHAR2 AS
	      l_c_msg VARCHAR2(3000);
	      l_c_msg_name fnd_new_messages.message_name%TYPE;
	      l_appl_name       VARCHAR2(30);
	    BEGIN
	      l_c_msg := FND_MSG_PUB.GET(p_msg_index => l_n_msg_count, p_encoded => 'T');
	      FND_MESSAGE.SET_ENCODED (l_c_msg);
	      FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_appl_name, l_c_msg_name);
	      RETURN l_c_msg_name;
	    END get_msg_from_stack;

	BEGIN

		IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT(
						 X_ROWID                      => l_c_fetch_record_cur.row_id,
						 x_waitlist_manual_ind        => l_c_fetch_record_cur.waitlist_manual_ind,
						 X_PERSON_ID                  => l_c_fetch_record_cur.person_id,
						 X_COURSE_CD                  => l_c_fetch_record_cur.course_cd,
						 X_UNIT_CD                    => l_c_fetch_record_cur.unit_cd,
						 X_CAL_TYPE                   => l_c_fetch_record_cur.cal_type,
						 X_CI_SEQUENCE_NUMBER         => l_c_fetch_record_cur.ci_sequence_number,
						 X_VERSION_NUMBER             => l_c_fetch_record_cur.version_number,
						 X_LOCATION_CD                => l_c_fetch_record_cur.location_cd,
						 X_UNIT_CLASS                 => l_c_fetch_record_cur.unit_class,
						 X_CI_START_DT                => l_c_fetch_record_cur.ci_start_dt,
						 X_CI_END_DT                  => l_c_fetch_record_cur.ci_end_dt,
						 X_UOO_ID                     => l_c_fetch_record_cur.uoo_id,
						 X_ENROLLED_DT                => l_c_fetch_record_cur.enrolled_dt,
						 X_UNIT_ATTEMPT_STATUS        => 'DROPPED',
						 X_ADMINISTRATIVE_UNIT_STATUS => l_c_fetch_record_cur.administrative_unit_status,
						 X_DISCONTINUED_DT            => nvl(l_c_fetch_record_cur.discontinued_dt, l_sysdate),
						 X_RULE_WAIVED_DT             => l_c_fetch_record_cur.rule_waived_dt,
						 X_RULE_WAIVED_PERSON_ID      => l_c_fetch_record_cur.rule_waived_person_id,
						 X_NO_ASSESSMENT_IND          => l_c_fetch_record_cur.no_assessment_ind,
						 X_SUP_UNIT_CD                => l_c_fetch_record_cur.sup_unit_cd,
						 X_SUP_VERSION_NUMBER         => l_c_fetch_record_cur.sup_version_number,
						 X_EXAM_LOCATION_CD           => l_c_fetch_record_cur.exam_location_cd,
						 X_ALTERNATIVE_TITLE          => l_c_fetch_record_cur.alternative_title,
						 X_OVERRIDE_ENROLLED_CP       => l_c_fetch_record_cur.override_enrolled_cp,
						 X_OVERRIDE_EFTSU             => l_c_fetch_record_cur.override_eftsu,
						 X_OVERRIDE_ACHIEVABLE_CP     => l_c_fetch_record_cur.override_achievable_cp,
						 X_OVERRIDE_OUTCOME_DUE_DT    => l_c_fetch_record_cur.override_outcome_due_dt,
						 X_OVERRIDE_CREDIT_REASON     => l_c_fetch_record_cur.override_credit_reason,
						 X_ADMINISTRATIVE_PRIORITY    => l_c_fetch_record_cur.administrative_priority,
						 X_WAITLIST_DT                => l_c_fetch_record_cur.waitlist_dt,
						 X_DCNT_REASON_CD             => l_c_fetch_record_cur.dcnt_reason_cd,
						 X_MODE                       => 'R',
						 X_GS_VERSION_NUMBER          => l_c_fetch_record_cur.gs_version_number,
						 X_ENR_METHOD_TYPE            => l_c_fetch_record_cur.enr_method_type,
						 X_FAILED_UNIT_RULE           => l_c_fetch_record_cur.failed_unit_rule,
						 X_CART                       => l_c_fetch_record_cur.cart,
						 X_RSV_SEAT_EXT_ID            => l_c_fetch_record_cur.rsv_seat_ext_id ,
						 X_ORG_UNIT_CD                => l_c_fetch_record_cur.org_unit_cd,
						 X_SESSION_ID                 => l_c_fetch_record_cur.session_id,
						 X_GRADING_SCHEMA_CODE        => l_c_fetch_record_cur.grading_schema_code,
						 X_DEG_AUD_DETAIL_ID          => l_c_fetch_record_cur.deg_aud_detail_id,
						 X_SUBTITLE                   => l_c_fetch_record_cur.subtitle,
						 X_STUDENT_CAREER_TRANSCRIPT  => l_c_fetch_record_cur.student_career_transcript,
						 X_STUDENT_CAREER_STATISTICS  => l_c_fetch_record_cur.student_career_statistics,
						 X_ATTRIBUTE_CATEGORY         => l_c_fetch_record_cur.attribute_category,
						 X_ATTRIBUTE1                 => l_c_fetch_record_cur.attribute1,
						 X_ATTRIBUTE2                 => l_c_fetch_record_cur.attribute2,
						 X_ATTRIBUTE3                 => l_c_fetch_record_cur.attribute3,
						 X_ATTRIBUTE4                 => l_c_fetch_record_cur.attribute4,
						 X_ATTRIBUTE5                 => l_c_fetch_record_cur.attribute5,
						 X_ATTRIBUTE6                 => l_c_fetch_record_cur.attribute6,
						 X_ATTRIBUTE7                 => l_c_fetch_record_cur.attribute7,
						 X_ATTRIBUTE8                 => l_c_fetch_record_cur.attribute8,
						 X_ATTRIBUTE9                 => l_c_fetch_record_cur.attribute9,
						 X_ATTRIBUTE10                => l_c_fetch_record_cur.attribute10,
						 X_ATTRIBUTE11                => l_c_fetch_record_cur.attribute11,
						 X_ATTRIBUTE12                => l_c_fetch_record_cur.attribute12,
						 X_ATTRIBUTE13                => l_c_fetch_record_cur.attribute13,
						 X_ATTRIBUTE14                => l_c_fetch_record_cur.attribute14,
						 X_ATTRIBUTE15                => l_c_fetch_record_cur.attribute15,
						 X_ATTRIBUTE16                => l_c_fetch_record_cur.attribute16,
						 X_ATTRIBUTE17                => l_c_fetch_record_cur.attribute17,
						 X_ATTRIBUTE18                => l_c_fetch_record_cur.attribute18,
						 X_ATTRIBUTE19                => l_c_fetch_record_cur.attribute19,
						 X_ATTRIBUTE20                => l_c_fetch_record_cur.attribute20,
						 X_WLST_PRIORITY_WEIGHT_NUM   => l_c_fetch_record_cur.wlst_priority_weight_num,
						 X_WLST_PREFERENCE_WEIGHT_NUM => l_c_fetch_record_cur.wlst_preference_weight_num,
						 X_CORE_INDICATOR_CODE        => l_c_fetch_record_cur.core_indicator_code
					    ) ;
	EXCEPTION
	    WHEN OTHERS THEN
	     fnd_message.set_name('IGS', get_msg_from_stack(1));
	     fnd_msg_pub.add;
	     p_uso_clas_meet_rec.status := 'E';
	END;

     END LOOP;
   END IF;
   CLOSE cur_waitlist;

 END validate_uso_clas_meet;

PROCEDURE update_usec_status(p_uoo_id               IN igs_ps_unit_ofr_opt.uoo_id%TYPE,
                               p_unit_section_status  IN igs_ps_unit_ofr_opt.unit_section_status%TYPE)   IS
CURSOR cur_usec(cp_uoo_id   igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
SELECT *
FROM   igs_ps_unit_ofr_opt
WHERE  uoo_id=cp_uoo_id;
l_cur_usec  cur_usec%ROWTYPE;

BEGIN
  OPEN cur_usec(p_uoo_id);
  FETCH cur_usec INTO l_cur_usec;
  CLOSE cur_usec;


  igs_ps_unit_ofr_opt_pkg.update_row(  x_rowid                       =>l_cur_usec.row_id,
                                         x_unit_cd                     =>l_cur_usec.unit_cd,
                                         x_version_number              =>l_cur_usec.version_number,
                                         x_cal_type                    =>l_cur_usec.cal_type,
                                         x_ci_sequence_number          =>l_cur_usec.ci_sequence_number,
                                         x_location_cd                 =>l_cur_usec.location_cd,
                                         x_unit_class                  =>l_cur_usec.unit_class,
                                         x_uoo_id                      =>l_cur_usec.uoo_id,
                                         x_ivrs_available_ind          =>l_cur_usec.ivrs_available_ind,
                                         x_call_number                 =>l_cur_usec.call_number,
                                         x_unit_section_status         =>p_unit_section_status,
                                         x_unit_section_start_date     =>l_cur_usec.unit_section_start_date,
                                         x_unit_section_end_date       =>l_cur_usec.unit_section_end_date,
                                         x_enrollment_actual           =>l_cur_usec.enrollment_actual,
                                         x_waitlist_actual             =>l_cur_usec.waitlist_actual,
                                         x_offered_ind                 =>l_cur_usec.offered_ind,
                                         x_state_financial_aid         =>l_cur_usec.state_financial_aid,
                                         x_grading_schema_prcdnce_ind  =>l_cur_usec.grading_schema_prcdnce_ind,
                                         x_federal_financial_aid       =>l_cur_usec.federal_financial_aid,
                                         x_unit_quota                  =>l_cur_usec.unit_quota,
                                         x_unit_quota_reserved_places  =>l_cur_usec.unit_quota_reserved_places,
                                         x_institutional_financial_aid =>l_cur_usec.institutional_financial_aid,
                                         x_grading_schema_cd           =>l_cur_usec.grading_schema_cd,
                                         x_gs_version_number           =>l_cur_usec.gs_version_number,
                                         x_unit_contact                =>l_cur_usec.unit_contact,
                                         x_mode                        =>'R',
                                         x_ss_enrol_ind                =>l_cur_usec.ss_enrol_ind,
                                         x_owner_org_unit_cd           => l_cur_usec.owner_org_unit_cd,
                                         x_attendance_required_ind     => l_cur_usec.attendance_required_ind,
                                         x_reserved_seating_allowed    => l_cur_usec.reserved_seating_allowed,
                                         x_ss_display_ind              => l_cur_usec.ss_display_ind,
                                         x_special_permission_ind      => l_cur_usec.special_permission_ind,
                                         x_rev_account_cd              => l_cur_usec.rev_account_cd ,
                                         x_anon_unit_grading_ind       => l_cur_usec.anon_unit_grading_ind,
                                         x_anon_assess_grading_ind     => l_cur_usec.anon_assess_grading_ind ,
                                         x_non_std_usec_ind            => l_cur_usec.non_std_usec_ind,
                                         x_auditable_ind               => l_cur_usec.auditable_ind,
                                         x_audit_permission_ind        => l_cur_usec.audit_permission_ind,
                                         x_not_multiple_section_flag   => l_cur_usec.not_multiple_section_flag,
                                         x_sup_uoo_id                  => l_cur_usec.sup_uoo_id,
                                         x_relation_type               => l_cur_usec.relation_type,
                                         x_default_enroll_flag         => l_cur_usec.default_enroll_flag,
					 x_abort_flag                  => l_cur_usec.abort_flag
                                       );
 END update_usec_status;

  FUNCTION post_usec_meet_with(p_tab_usec_meet_with IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_tbl_type,
                               p_class_meet_tab IN igs_ps_create_generic_pkg.class_meet_rec_tbl_type) RETURN BOOLEAN
  AS
   /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR c_host(cp_class_meet_group_id NUMBER) IS
    SELECT count (ROWID) cnt
    FROM   igs_ps_uso_clas_meet
    WHERE   host = 'Y'
    AND class_meet_group_id =cp_class_meet_group_id;

    c_host_rec c_host%ROWTYPE;

    CURSOR c_cm_grp(cp_class_meet_group_id  igs_ps_uso_clas_meet_v.class_meet_group_id%TYPE) IS
    SELECT *
    FROM igs_ps_uso_cm_grp
    WHERE class_meet_group_id = cp_class_meet_group_id;

    c_cm_grp_rec c_cm_grp%ROWTYPE;


    CURSOR c_sum_enract(cp_class_meet_group_id  igs_ps_uso_clas_meet_v.class_meet_group_id%TYPE)  IS
    SELECT SUM(enrollment_actual) sum_enrollment_actual
    FROM igs_ps_uso_clas_meet_v
    WHERE class_meet_group_id = cp_class_meet_group_id ;

    c_sum_enract_rec c_sum_enract%ROWTYPE;

    CURSOR c_usec_enr(cp_class_meet_group_id  igs_ps_uso_clas_meet_v.class_meet_group_id%TYPE)  IS
    SELECT *
    FROM igs_ps_uso_clas_meet_v
    WHERE class_meet_group_id = cp_class_meet_group_id ;

    c_usec_enr_rec c_usec_enr%ROWTYPE;

    CURSOR cur_usec (cp_class_meet_group_id   igs_ps_uso_clas_meet.class_meet_group_id%TYPE,
		      cp_usec_status           igs_ps_unit_ofr_opt.unit_section_status%TYPE ) IS
    SELECT uoo.uoo_id
    FROM igs_ps_uso_clas_meet usm,
	 igs_ps_unit_ofr_opt uoo
    WHERE usm.class_meet_group_id = cp_class_meet_group_id
    AND   usm.uoo_id=uoo.uoo_id
    AND   uoo.unit_section_status NOT IN (cp_usec_status,'PLANNED','CANCELLED','NOT_OFFERED');

    CURSOR cur_group_id (cp_group_name VARCHAR2, cp_alternate_cd VARCHAR2) IS
    SELECT a.class_meet_group_id
    FROM   igs_ps_uso_cm_grp a, igs_ca_inst_all b
    WHERE  a.class_meet_group_name = cp_group_name
    AND    a.cal_type = b.cal_type
    AND    a.ci_sequence_number =b.sequence_number
    AND    b.alternate_code=cp_alternate_cd;
    l_cur_group_id  NUMBER;


    l_new_sum            NUMBER;
    l_execute_next_logic BOOLEAN;
    l_n_count_msg        NUMBER;
    max_enr_group_temp   igs_ps_uso_cm_grp.max_enr_group%TYPE;
    max_ovr_group_temp   igs_ps_uso_cm_grp.max_ovr_group%TYPE;
    l_b_status           BOOLEAN;
    l_b_error            BOOLEAN;
  BEGIN

    l_b_status := TRUE;
    FOR i IN 1 ..p_class_meet_tab.LAST LOOP
      l_b_error := FALSE;
      OPEN c_host (p_class_meet_tab(i).class_meet_group_id);
      FETCH c_host INTO c_host_rec;
      CLOSE c_host;
      IF NVL(c_host_rec.cnt,0) = 0 THEN
        l_b_status := FALSE;
        l_b_error := TRUE;
        fnd_message.set_name ( 'IGS', 'IGS_PS_CM_NO_HOST' );
        fnd_message.set_token('GROUP_NAME',p_class_meet_tab(i).class_meet_group_name);
	fnd_msg_pub.add;
	l_n_count_msg := fnd_msg_pub.count_msg;
      ELSIF NVL(c_host_rec.cnt,0) > 1 THEN
        l_b_status := FALSE;
        l_b_error := TRUE;
	fnd_message.set_name ( 'IGS', 'IGS_PS_CM_ONLY_ONE_HOST' );
	fnd_msg_pub.add;
	l_n_count_msg := fnd_msg_pub.count_msg;
      END IF;
      IF  l_b_error THEN
        FOR j in 1..p_tab_usec_meet_with.LAST LOOP
           IF p_tab_usec_meet_with.EXISTS(j) THEN
	     OPEN cur_group_id(p_tab_usec_meet_with(j).class_meet_group_name,p_tab_usec_meet_with(j).teach_cal_alternate_code);
	     FETCH cur_group_id INTO l_cur_group_id;
	     CLOSE cur_group_id;
             IF p_tab_usec_meet_with(j).status = 'S' AND l_cur_group_id = p_class_meet_tab(i).class_meet_group_id THEN
                p_tab_usec_meet_with(j).status := 'E';
                p_tab_usec_meet_with(j).msg_from := l_n_count_msg;
                p_tab_usec_meet_with(j).msg_to := l_n_count_msg;
             END IF;
           END IF;
        END LOOP;
      END IF;

      -- Group Override Maximum should always be greater than or equal to
      -- Actual Enrollment for the group
      OPEN c_sum_enract(p_class_meet_tab(i).class_meet_group_id);
      FETCH c_sum_enract INTO c_sum_enract_rec;
      CLOSE c_sum_enract;

      OPEN c_cm_grp(p_class_meet_tab(i).class_meet_group_id);
      FETCH c_cm_grp INTO c_cm_grp_rec;
      CLOSE c_cm_grp;

      IF ((c_cm_grp_rec.max_ovr_group IS NOT NULL)  AND (NVL(c_cm_grp_rec.max_ovr_group,0) < NVL(c_sum_enract_rec.sum_enrollment_actual,0))) THEN
        l_b_status := FALSE;
	fnd_message.set_name('IGS','IGS_PS_MAX_OVR_MAX');
	fnd_msg_pub.add;
	l_n_count_msg := fnd_msg_pub.count_msg;
        FOR j in 1..p_tab_usec_meet_with.LAST LOOP
           IF p_tab_usec_meet_with.EXISTS(j) THEN
	     OPEN cur_group_id(p_tab_usec_meet_with(j).class_meet_group_name,p_tab_usec_meet_with(j).teach_cal_alternate_code);
	     FETCH cur_group_id INTO l_cur_group_id;
	     CLOSE cur_group_id;
             IF p_tab_usec_meet_with(j).status = 'S' AND l_cur_group_id = p_class_meet_tab(i).class_meet_group_id THEN
		p_tab_usec_meet_with(j).status := 'E';
                p_tab_usec_meet_with(j).msg_from := l_n_count_msg;
                p_tab_usec_meet_with(j).msg_to := l_n_count_msg;
             END IF;
           END IF;
        END LOOP;
      END IF;

      IF l_b_status THEN
	OPEN c_cm_grp(p_class_meet_tab(i).class_meet_group_id);
	FETCH c_cm_grp INTO c_cm_grp_rec;
	CLOSE c_cm_grp;

	OPEN c_usec_enr(p_class_meet_tab(i).class_meet_group_id);
	FETCH c_usec_enr INTO c_usec_enr_rec;
	CLOSE c_usec_enr;

	OPEN c_sum_enract(p_class_meet_tab(i).class_meet_group_id);
	FETCH c_sum_enract INTO l_new_sum;
	CLOSE c_sum_enract;

	l_execute_next_logic:= TRUE;

	IF c_cm_grp_rec.max_ovr_group IS NOT NULL OR c_cm_grp_rec.max_enr_group IS NOT NULL THEN--1o
	  IF NVL(c_usec_enr_rec.enrollment_actual,0) >= 1 THEN--2o
	    l_execute_next_logic:= FALSE;
	    IF NVL(c_cm_grp_rec.max_enr_group,0) < NVL(l_new_sum,0) THEN--3o
	      max_enr_group_temp:=l_new_sum;
	      max_ovr_group_temp:=c_cm_grp_rec.max_ovr_group;

	      IF NVL(c_cm_grp_rec.max_ovr_group,0) < NVL(l_new_sum,0) THEN
		max_ovr_group_temp:=l_new_sum;
	      END IF;

	      --Update the maximum enrollment/ovrride group
	      UPDATE igs_ps_uso_cm_grp
	      SET max_enr_group=max_enr_group_temp,
	      max_ovr_group=max_ovr_group_temp,
	      last_updated_by = g_n_user_id,
	      last_update_date = SYSDATE,
	      last_update_login = g_n_login_id
	      WHERE class_meet_group_id =p_class_meet_tab(i).class_meet_group_id;

	      --Make all the unit section status to closed if open in that group
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'CLOSED') LOOP
		update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	      END LOOP;

	    ELSIF NVL(c_cm_grp_rec.max_enr_group,0) > NVL(l_new_sum,0) THEN
	      --Make this unit section status open if closed
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'OPEN') LOOP
		update_usec_status(l_cur_usec.uoo_id,'OPEN');
	      END LOOP;

	    ELSE
	      --Make all the unit section status to closed if open in that group
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'CLOSED') LOOP
		update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	      END LOOP;

	    END IF;--3c

	  ELSE
	    --If the inserted/modified unit section is not an enrolled one then also change the status
	    --accordingly, bug#2702252
	    IF NVL(c_cm_grp_rec.max_enr_group,0) < NVL(l_new_sum,0) THEN--4o
	      --Make all the unit section status to closed if open in that group
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'CLOSED') LOOP
		update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	      END LOOP;

	    ELSIF NVL(c_cm_grp_rec.max_enr_group,0) > NVL(l_new_sum,0) THEN
	      --Make this unit section status open if closed
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'OPEN') LOOP
		update_usec_status(l_cur_usec.uoo_id,'OPEN');
	      END LOOP;

	    ELSIF c_cm_grp_rec.max_enr_group IS NULL AND l_new_sum IS NULL THEN
	      --Make all the unit section status to open if closed in that group
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'OPEN') LOOP
		update_usec_status(l_cur_usec.uoo_id,'OPEN');
	      END LOOP;

	    ELSE
	      --Make all the unit section status to closed if open in that group
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'CLOSED') LOOP
		update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	      END LOOP;

	    END IF;--4c
	  END IF; --2c
        END IF;--1c

	IF l_execute_next_logic = TRUE THEN
	  IF NVL(p_class_meet_tab(i).old_max_enr_group ,0) <> NVL(c_cm_grp_rec.max_enr_group,0) THEN
	    IF p_class_meet_tab(i).old_max_enr_group  =  l_new_sum THEN
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'OPEN') LOOP
		update_usec_status(l_cur_usec.uoo_id,'OPEN');
	      END LOOP;

	    ELSIF  l_new_sum = c_cm_grp_rec.max_enr_group THEN
	      FOR l_cur_usec IN cur_usec(p_class_meet_tab(i).class_meet_group_id,'CLOSED') LOOP
		update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	      END LOOP;
	    END IF;
	  END IF;
	END IF;

      END IF; --l_b_status

    END LOOP;

    RETURN l_b_status;

  END post_usec_meet_with;


  PROCEDURE validate_uso_cm_grp ( p_uso_cm_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_rec_type,
				  p_c_cal_type     VARCHAR2,
				  p_n_seq_num      NUMBER,
				  p_insert_update  VARCHAR2,
				  p_class_meet_rec   IN OUT NOCOPY igs_ps_create_generic_pkg.class_meet_rec_type )
  AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  18-Jun-2005
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR c_uso_cm_grp(cp_cmg_name VARCHAR2) IS
    SELECT 'X'  FROM  igs_ps_uso_cm_grp
    WHERE class_meet_group_name =cp_cmg_name;

    c_uso_cm_grp_rec c_uso_cm_grp%ROWTYPE;

    CURSOR c_val_enr(cp_cmg_name VARCHAR2,cp_cal_type VARCHAR2,cp_sequence_number NUMBER) IS
    SELECT *
    FROM igs_ps_uso_cm_grp
    WHERE class_meet_group_name =cp_cmg_name
    AND Cal_type=cp_cal_type
    AND ci_sequence_number=cp_sequence_number;

    c_val_enr_rec c_val_enr%ROWTYPE;

    CURSOR c_old_cmgrp(cp_cmg_name VARCHAR2,cp_cal_type VARCHAR2,cp_seq_no NUMBER) IS
    SELECT *  FROM  igs_ps_uso_cm_grp
    WHERE class_meet_group_name =cp_cmg_name
    AND cal_type=cp_cal_type
    AND ci_sequence_number=cp_seq_no;

    c_old_cmgrp_rec c_old_cmgrp%ROWTYPE;

    CURSOR cur_usec (cp_class_meet_group_id   igs_ps_uso_clas_meet.class_meet_group_id%TYPE,
		      cp_usec_status           igs_ps_unit_ofr_opt.unit_section_status%TYPE ) IS
    SELECT uoo.uoo_id
    FROM igs_ps_uso_clas_meet usm,
	 igs_ps_unit_ofr_opt uoo
    WHERE usm.class_meet_group_id = cp_class_meet_group_id
    AND   usm.uoo_id=uoo.uoo_id
    AND   uoo.unit_section_status NOT IN (cp_usec_status,'PLANNED','CANCELLED','NOT_OFFERED');

    CURSOR cur_usecs_in_group(cp_class_meet_group_id   igs_ps_uso_clas_meet.class_meet_group_id%TYPE) IS
    SELECT uoo_id
    FROM   igs_ps_uso_clas_meet
    WHERE  class_meet_group_id = cp_class_meet_group_id;

    l_message_name fnd_new_messages.message_name%TYPE;
    l_request_id       igs_ps_sch_hdr_int.request_id%TYPE;

  BEGIN

    --Cannot enter a value for Override Maximum when Enrollment Maximum is null
    IF ((p_uso_cm_grp_rec.max_ovr_group IS NOT NULL) AND (p_uso_cm_grp_rec.max_enr_group IS NULL)) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_ENR_NULL_OVR_NOT' );
      fnd_msg_pub.add;
      p_uso_cm_grp_rec.status := 'E';
    END IF;

    --Group Override Maximum should always be greater than or equal toMaximum Enrollment for the group
    IF ((p_uso_cm_grp_rec.max_ovr_group IS NOT NULL) AND (NVL(p_uso_cm_grp_rec.max_ovr_group,0) < NVL(p_uso_cm_grp_rec.max_enr_group,0))) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_OVERIDE_MIN_MAX_CP' );
      fnd_msg_pub.add;
      p_uso_cm_grp_rec.status := 'E';
    END IF;


    p_class_meet_rec.class_meet_group_name:=p_uso_cm_grp_rec.class_meet_group_name;

    OPEN c_old_cmgrp(p_uso_cm_grp_rec.class_meet_group_name,p_c_cal_type,p_n_seq_num);
    FETCH c_old_cmgrp INTO c_old_cmgrp_rec;
    IF c_old_cmgrp%FOUND THEN
      p_class_meet_rec.class_meet_group_id:=c_old_cmgrp_rec.class_meet_group_id;
      p_class_meet_rec.old_max_enr_group:=c_old_cmgrp_rec.max_enr_group;
    ELSE
      p_class_meet_rec.class_meet_group_id:=NULL;
      p_class_meet_rec.old_max_enr_group:=NULL;
    END IF;
    CLOSE c_old_cmgrp;


    -- IF the group enrollment is getting modified
    OPEN c_val_enr(p_uso_cm_grp_rec.class_meet_group_name,p_c_cal_type,p_n_seq_num);
    FETCH c_val_enr INTO c_val_enr_rec;

    IF c_val_enr%FOUND THEN
      IF NVL( p_uso_cm_grp_rec.max_enr_group,0) <> c_val_enr_rec.max_enr_group OR
	      NVL(p_uso_cm_grp_rec.max_ovr_group,0) <>  c_val_enr_rec.max_ovr_group THEN

	 --for loop which loops thru all unit sections within a group.
	FOR rec_cur_usecs_in_group IN cur_usecs_in_group(c_val_enr_rec.class_meet_group_id) LOOP
	    --Before updating check for validity of schedule status...
	  IF igs_ps_usec_schedule.prgp_get_schd_status(p_uoo_id   => rec_cur_usecs_in_group.uoo_id,
							  p_usec_id  => NULL,
							  p_message_name => l_message_name ) = TRUE THEN
	    IF l_message_name IS NULL THEN
	      l_message_name := 'IGS_PS_SCST_PROC';
	    END IF;

	    fnd_message.set_name('IGS',l_message_name);
	    fnd_msg_pub.add;
	    p_uso_cm_grp_rec.status := 'E';
	     --update the schedule status to 'Rescheduling Requested', if unit section occurrence is a scheduled one.
	  ELSIF igs_ps_usec_schedule.prgp_upd_usec_dtls
				    (
				     p_uoo_id                  => rec_cur_usecs_in_group.uoo_id,
				     p_location_cd             => NULL,
				     p_usec_status             => NULL,
				     p_max_enrollments         => NVL(p_uso_cm_grp_rec.max_enr_group,-999),
				     p_override_enrollment_max => NVL(p_uso_cm_grp_rec.max_ovr_group,-999),
				     p_enrollment_expected     => NULL,
				     p_request_id              => l_request_id,
				     p_message_name            => l_message_name
				    ) = FALSE THEN
	    fnd_message.set_name('IGS',l_message_name);
	    fnd_msg_pub.add;
	    p_uso_cm_grp_rec.status := 'E';
	  END IF;
	END LOOP;
      END IF;
    END IF;
    CLOSE c_val_enr;

  END validate_uso_cm_grp;


--Validations of crosslisted unit sections
PROCEDURE validate_usec_x_grpmem ( p_usec_x_grpmem            IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type,
				   p_n_uoo_id                 NUMBER,
				   p_n_usec_x_listed_group_id NUMBER,
				   p_c_cal_type               VARCHAR2,
				   p_n_seq_num                NUMBER)
 AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

   CURSOR cur_usec  IS
   SELECT  'X'
   FROM    igs_ps_unit_ofr_opt_all uoo
   WHERE   uoo.unit_section_status IN ('OPEN','PLANNED','FULLWAITOK','CLOSED')
   AND     uoo.relation_type='NONE'
   AND     uoo.cal_type=p_c_cal_type
   AND     uoo.ci_sequence_number =p_n_seq_num
   AND     uoo.uoo_id=p_n_uoo_id;

   cur_usec_rec cur_usec%ROWTYPE;

   CURSOR  c_uso_cm(cp_uoo_id  igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
   SELECT 'X'
   FROM   igs_ps_uso_clas_meet
   WHERE  uoo_id=cp_uoo_id;

   c_uso_cm_rec c_uso_cm%ROWTYPE;

   CURSOR cur_std_attempt(cp_uoo_id   igs_en_su_attempt.uoo_id%TYPE) IS
   SELECT *
   FROM   igs_en_su_attempt
   WHERE  uoo_id=cp_uoo_id
   AND    unit_attempt_status='WAITLISTED';

   CURSOR  cur_waitlist(cp_uoo_id   igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
   SELECT  waitlist_actual
   FROM    igs_ps_unit_ofr_opt
   WHERE   uoo_id=cp_uoo_id;
   l_cur_waitlist  cur_waitlist%ROWTYPE;

   l_sysdate DATE := trunc(SYSDATE);

 BEGIN

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_usec_x_grpmem.status := 'E';
    END IF;


   --Validation on selection of
   OPEN cur_usec;
   FETCH cur_usec INTO cur_usec_rec;
   IF cur_usec%NOTFOUND THEN
     igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
     p_usec_x_grpmem.status := 'E';
   END IF;
   CLOSE cur_usec;

   --This unit section should not be present in any  Unit section meet with class group
   OPEN c_uso_cm(p_n_uoo_id);
   FETCH c_uso_cm INTO c_uso_cm_rec;
   IF c_uso_cm%FOUND THEN
     fnd_message.set_name('IGS','IGS_PS_UNT_SEC_DEFINED_GRP');
     fnd_msg_pub.add;
     p_usec_x_grpmem.status := 'E';
   END IF;
   CLOSE c_uso_cm;

   OPEN  cur_waitlist(p_n_uoo_id);
   FETCH cur_waitlist INTO l_cur_waitlist;
   IF l_cur_waitlist.waitlist_actual >= 1 THEN
      FOR  l_c_fetch_record_cur IN  cur_std_attempt(p_n_uoo_id) LOOP

	DECLARE
	  FUNCTION get_msg_from_stack(l_n_msg_count NUMBER) RETURN VARCHAR2 AS
	    l_c_msg VARCHAR2(3000);
	    l_c_msg_name fnd_new_messages.message_name%TYPE;
	    l_appl_name       VARCHAR2(30);
	  BEGIN
	    l_c_msg := FND_MSG_PUB.GET(p_msg_index => l_n_msg_count, p_encoded => 'T');
	    FND_MESSAGE.SET_ENCODED (l_c_msg);
	    FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_appl_name, l_c_msg_name);
	    RETURN l_c_msg_name;
	  END get_msg_from_stack;
	BEGIN

	  IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT(
					   X_ROWID                      => l_c_fetch_record_cur.row_id,
					   x_waitlist_manual_ind        => l_c_fetch_record_cur.waitlist_manual_ind,
					   X_PERSON_ID                  => l_c_fetch_record_cur.person_id,
					   X_COURSE_CD                  => l_c_fetch_record_cur.course_cd,
					   X_UNIT_CD                    => l_c_fetch_record_cur.unit_cd,
					   X_CAL_TYPE                   => l_c_fetch_record_cur.cal_type,
					   X_CI_SEQUENCE_NUMBER         => l_c_fetch_record_cur.ci_sequence_number,
					   X_VERSION_NUMBER             => l_c_fetch_record_cur.version_number,
					   X_LOCATION_CD                => l_c_fetch_record_cur.location_cd,
					   X_UNIT_CLASS                 => l_c_fetch_record_cur.unit_class,
					   X_CI_START_DT                => l_c_fetch_record_cur.ci_start_dt,
					   X_CI_END_DT                  => l_c_fetch_record_cur.ci_end_dt,
					   X_UOO_ID                     => l_c_fetch_record_cur.uoo_id,
					   X_ENROLLED_DT                => l_c_fetch_record_cur.enrolled_dt,
					   X_UNIT_ATTEMPT_STATUS        => 'DROPPED',
					   X_ADMINISTRATIVE_UNIT_STATUS => l_c_fetch_record_cur.administrative_unit_status,
					   X_DISCONTINUED_DT            => nvl(l_c_fetch_record_cur.discontinued_dt, l_sysdate),
					   X_RULE_WAIVED_DT             => l_c_fetch_record_cur.rule_waived_dt,
					   X_RULE_WAIVED_PERSON_ID      => l_c_fetch_record_cur.rule_waived_person_id,
					   X_NO_ASSESSMENT_IND          => l_c_fetch_record_cur.no_assessment_ind,
					   X_SUP_UNIT_CD                => l_c_fetch_record_cur.sup_unit_cd,
					   X_SUP_VERSION_NUMBER         => l_c_fetch_record_cur.sup_version_number,
					   X_EXAM_LOCATION_CD           => l_c_fetch_record_cur.exam_location_cd,
					   X_ALTERNATIVE_TITLE          => l_c_fetch_record_cur.alternative_title,
					   X_OVERRIDE_ENROLLED_CP       => l_c_fetch_record_cur.override_enrolled_cp,
					   X_OVERRIDE_EFTSU             => l_c_fetch_record_cur.override_eftsu,
					   X_OVERRIDE_ACHIEVABLE_CP     => l_c_fetch_record_cur.override_achievable_cp,
					   X_OVERRIDE_OUTCOME_DUE_DT    => l_c_fetch_record_cur.override_outcome_due_dt,
					   X_OVERRIDE_CREDIT_REASON     => l_c_fetch_record_cur.override_credit_reason,
					   X_ADMINISTRATIVE_PRIORITY    => l_c_fetch_record_cur.administrative_priority,
					   X_WAITLIST_DT                => l_c_fetch_record_cur.waitlist_dt,
					   X_DCNT_REASON_CD             => l_c_fetch_record_cur.dcnt_reason_cd,
					   X_MODE                       => 'R',
					   X_GS_VERSION_NUMBER          => l_c_fetch_record_cur.gs_version_number,
					   X_ENR_METHOD_TYPE            => l_c_fetch_record_cur.enr_method_type,
					   X_FAILED_UNIT_RULE           => l_c_fetch_record_cur.failed_unit_rule,
					   X_CART                       => l_c_fetch_record_cur.cart,
					   X_RSV_SEAT_EXT_ID            => l_c_fetch_record_cur.rsv_seat_ext_id ,
					   X_ORG_UNIT_CD                => l_c_fetch_record_cur.org_unit_cd,
					   X_SESSION_ID                 => l_c_fetch_record_cur.session_id,
					   X_GRADING_SCHEMA_CODE        => l_c_fetch_record_cur.grading_schema_code,
					   X_DEG_AUD_DETAIL_ID          => l_c_fetch_record_cur.deg_aud_detail_id,
					   X_SUBTITLE                   => l_c_fetch_record_cur.subtitle,
					   X_STUDENT_CAREER_TRANSCRIPT  => l_c_fetch_record_cur.student_career_transcript,
					   X_STUDENT_CAREER_STATISTICS  => l_c_fetch_record_cur.student_career_statistics,
					   X_ATTRIBUTE_CATEGORY         => l_c_fetch_record_cur.attribute_category,
					   X_ATTRIBUTE1                 => l_c_fetch_record_cur.attribute1,
					   X_ATTRIBUTE2                 => l_c_fetch_record_cur.attribute2,
					   X_ATTRIBUTE3                 => l_c_fetch_record_cur.attribute3,
					   X_ATTRIBUTE4                 => l_c_fetch_record_cur.attribute4,
					   X_ATTRIBUTE5                 => l_c_fetch_record_cur.attribute5,
					   X_ATTRIBUTE6                 => l_c_fetch_record_cur.attribute6,
					   X_ATTRIBUTE7                 => l_c_fetch_record_cur.attribute7,
					   X_ATTRIBUTE8                 => l_c_fetch_record_cur.attribute8,
					   X_ATTRIBUTE9                 => l_c_fetch_record_cur.attribute9,
					   X_ATTRIBUTE10                => l_c_fetch_record_cur.attribute10,
					   X_ATTRIBUTE11                => l_c_fetch_record_cur.attribute11,
					   X_ATTRIBUTE12                => l_c_fetch_record_cur.attribute12,
					   X_ATTRIBUTE13                => l_c_fetch_record_cur.attribute13,
					   X_ATTRIBUTE14                => l_c_fetch_record_cur.attribute14,
					   X_ATTRIBUTE15                => l_c_fetch_record_cur.attribute15,
					   X_ATTRIBUTE16                => l_c_fetch_record_cur.attribute16,
					   X_ATTRIBUTE17                => l_c_fetch_record_cur.attribute17,
					   X_ATTRIBUTE18                => l_c_fetch_record_cur.attribute18,
					   X_ATTRIBUTE19                => l_c_fetch_record_cur.attribute19,
					   X_ATTRIBUTE20                => l_c_fetch_record_cur.attribute20,
					   X_WLST_PRIORITY_WEIGHT_NUM   => l_c_fetch_record_cur.wlst_priority_weight_num,
					   X_WLST_PREFERENCE_WEIGHT_NUM => l_c_fetch_record_cur.wlst_preference_weight_num,
					   X_CORE_INDICATOR_CODE        => l_c_fetch_record_cur.core_indicator_code
				      ) ;
        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('IGS', get_msg_from_stack(1));
            fnd_msg_pub.add;
            p_usec_x_grpmem.status := 'E';
        END;

     END LOOP;

   END IF;
   CLOSE cur_waitlist;

 END validate_usec_x_grpmem;


  FUNCTION post_usec_cross_group(p_tab_usec_cross_group IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_tbl_type,
                                 p_cross_group_tab IN igs_ps_create_generic_pkg.cross_group_rec_tbl_type) RETURN BOOLEAN
  AS
   /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR c_parent(cp_usec_x_listed_group_id NUMBER) IS
    SELECT count (ROWID) cnt
    FROM   igs_ps_usec_x_grpmem
    WHERE   parent = 'Y'
    AND usec_x_listed_group_id =cp_usec_x_listed_group_id;

    c_parent_rec c_parent%ROWTYPE;

    CURSOR c_x_grp(cp_usec_x_listed_group_id  igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE) IS
    SELECT *
    FROM igs_ps_usec_x_grp
    WHERE usec_x_listed_group_id = cp_usec_x_listed_group_id;

    c_x_grp_rec c_x_grp%ROWTYPE;


    CURSOR c_sum_enract(cp_usec_x_listed_group_id  igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE)  IS
    SELECT SUM(enrollment_actual) sum_enrollment_actual
    FROM igs_ps_usec_x_grpmem_v
    WHERE usec_x_listed_group_id = cp_usec_x_listed_group_id;


    c_sum_enract_rec c_sum_enract%ROWTYPE;

    CURSOR c_usec_enr(cp_usec_x_listed_group_id  igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE)  IS
    SELECT *
    FROM igs_ps_usec_x_grpmem_v
    WHERE usec_x_listed_group_id = cp_usec_x_listed_group_id ;

    c_usec_enr_rec c_usec_enr%ROWTYPE;

    CURSOR cur_usec (cp_usec_x_listed_group_id   igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE,
		     cp_usec_status              igs_ps_unit_ofr_opt.unit_section_status%TYPE
		    ) IS
    SELECT uoo.uoo_id
    FROM igs_ps_usec_x_grpmem usm,
	 igs_ps_unit_ofr_opt uoo
    WHERE usm.usec_x_listed_group_id = cp_usec_x_listed_group_id
    AND   usm.uoo_id=uoo.uoo_id
    AND   uoo.unit_section_status NOT IN (cp_usec_status,'PLANNED','CANCELLED','NOT_OFFERED');

    CURSOR cur_group_id (cp_group_name VARCHAR2, cp_alternate_cd VARCHAR2) IS
    SELECT a.usec_x_listed_group_id
    FROM   igs_ps_usec_x_grp a, igs_ca_inst_all b
    WHERE  a.usec_x_listed_group_name = cp_group_name
    AND    a.cal_type = b.cal_type
    AND    a.ci_sequence_number =b.sequence_number
    AND    b.alternate_code=cp_alternate_cd;
    l_cur_group_id  NUMBER;

    l_new_sum            NUMBER;
    l_execute_next_logic BOOLEAN;
    l_n_count_msg        NUMBER;
    max_enr_group_temp   NUMBER;
    max_ovr_group_temp   NUMBER;
    l_b_status           BOOLEAN;
    l_b_error            BOOLEAN;
  BEGIN
    l_b_status := TRUE;
    FOR i IN 1 ..p_cross_group_tab.LAST LOOP
      l_b_error := FALSE;
      OPEN c_parent (p_cross_group_tab(i).usec_x_listed_group_id);
      FETCH c_parent INTO c_parent_rec;
      CLOSE c_parent;
      IF NVL(c_parent_rec.cnt,0) = 0 THEN
        l_b_status := FALSE;
        l_b_error := TRUE;
        fnd_message.set_name ( 'IGS', 'IGS_PS_USXL_NO_PARENT' );
        fnd_message.set_token ( 'GROUP_NAME',p_cross_group_tab(i).usec_x_listed_group_name );
	fnd_msg_pub.add;
	l_n_count_msg := fnd_msg_pub.count_msg;
      ELSIF NVL(c_parent_rec.cnt,0) > 1 THEN
        l_b_status := FALSE;
        l_b_error := TRUE;
	fnd_message.set_name ( 'IGS', 'IGS_PS_UXL_ONLY_ONE_PARENT' );
	fnd_msg_pub.add;
	l_n_count_msg := fnd_msg_pub.count_msg;
      END IF;
      IF  l_b_error THEN
        FOR j in 1..p_tab_usec_cross_group.LAST LOOP
           IF p_tab_usec_cross_group.EXISTS(j) THEN
	     OPEN cur_group_id(p_tab_usec_cross_group(j).usec_x_listed_group_name,p_tab_usec_cross_group(j).teach_cal_alternate_code);
	     FETCH cur_group_id INTO l_cur_group_id;
	     CLOSE cur_group_id;
             IF p_tab_usec_cross_group(j).status = 'S' AND l_cur_group_id = p_cross_group_tab(i).usec_x_listed_group_id THEN
                p_tab_usec_cross_group(j).status := 'E';
                p_tab_usec_cross_group(j).msg_from := l_n_count_msg;
                p_tab_usec_cross_group(j).msg_to := l_n_count_msg;
             END IF;
           END IF;
        END LOOP;
      END IF;


      -- Group Override Maximum should always be greater than or equal to
      -- Actual Enrollment for the group
      OPEN c_sum_enract(p_cross_group_tab(i).usec_x_listed_group_id);
      FETCH c_sum_enract INTO c_sum_enract_rec;
      CLOSE c_sum_enract;

      OPEN c_x_grp(p_cross_group_tab(i).usec_x_listed_group_id);
      FETCH c_x_grp INTO c_x_grp_rec;
      CLOSE c_x_grp;

      IF ((c_x_grp_rec.max_ovr_group IS NOT NULL)  AND (NVL(c_x_grp_rec.max_ovr_group,0) < NVL(c_sum_enract_rec.sum_enrollment_actual,0))) THEN
        l_b_status := FALSE;
	fnd_message.set_name('IGS','IGS_PS_MAX_OVR_MAX');
        fnd_msg_pub.add;
        l_n_count_msg := fnd_msg_pub.count_msg;
        FOR j in 1..p_tab_usec_cross_group.LAST LOOP
           IF p_tab_usec_cross_group.EXISTS(j) THEN
	     OPEN cur_group_id(p_tab_usec_cross_group(j).usec_x_listed_group_name,p_tab_usec_cross_group(j).teach_cal_alternate_code);
	     FETCH cur_group_id INTO l_cur_group_id;
	     CLOSE cur_group_id;
             IF p_tab_usec_cross_group(j).status = 'S' AND l_cur_group_id =p_cross_group_tab(i).usec_x_listed_group_id THEN
		p_tab_usec_cross_group(j).status := 'E';
                p_tab_usec_cross_group(j).msg_from := l_n_count_msg;
                p_tab_usec_cross_group(j).msg_to := l_n_count_msg;
             END IF;
           END IF;
        END LOOP;
      END IF;

      IF l_b_status THEN

	OPEN c_x_grp(p_cross_group_tab(i).usec_x_listed_group_id);
	FETCH c_x_grp INTO c_x_grp_rec;
	CLOSE c_x_grp;

	OPEN c_usec_enr(p_cross_group_tab(i).usec_x_listed_group_id);
	FETCH c_usec_enr INTO c_usec_enr_rec;
	CLOSE c_usec_enr;

	OPEN c_sum_enract(p_cross_group_tab(i).usec_x_listed_group_id);
	FETCH c_sum_enract INTO l_new_sum;
	CLOSE c_sum_enract;

	l_execute_next_logic:= TRUE;

	IF c_x_grp_rec.max_ovr_group IS NOT NULL OR c_x_grp_rec.max_enr_group IS NOT NULL THEN--1o

	  IF NVL(c_usec_enr_rec.enrollment_actual,0) >= 1 THEN--2o
	    l_execute_next_logic:= FALSE;

	    IF NVL(c_x_grp_rec.max_enr_group,0) < NVL(l_new_sum,0) THEN--3o
	      max_enr_group_temp:=l_new_sum;
	      max_ovr_group_temp:=c_x_grp_rec.max_ovr_group;

	      IF NVL(c_x_grp_rec.max_ovr_group,0) < NVL(l_new_sum,0) THEN
		max_ovr_group_temp:=l_new_sum;
	      END IF;

	      --Update the maximum enrollment/ovrride group
	      UPDATE igs_ps_usec_x_grp
	      SET max_enr_group=max_enr_group_temp,
	      max_ovr_group=max_ovr_group_temp,
	      last_updated_by = g_n_user_id,
	      last_update_date = SYSDATE,
	      last_update_login = g_n_login_id
	      WHERE usec_x_listed_group_id =p_cross_group_tab(i).usec_x_listed_group_id;

	      --Make all the unit section status to closed if open in that group
	      FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'CLOSED') LOOP
		update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	      END LOOP;

	    ELSIF NVL(c_x_grp_rec.max_enr_group,0) > NVL(l_new_sum,0) THEN
	       --Make this unit section status open if closed

		FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'OPEN') LOOP
		  update_usec_status(l_cur_usec.uoo_id,'OPEN');
		END LOOP;

	    ELSE

	       --Make all the unit section status to closed if open in that group
		FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'CLOSED') LOOP
		  update_usec_status(l_cur_usec.uoo_id,'CLOSED');
		END LOOP;

	    END IF;--3c

	  ELSE
	    --If the inserted/modified unit section is not an enrolled one then also change the status
	    --accordingly, bug#2702252
	    IF NVL(c_x_grp_rec.max_enr_group,0) < NVL(l_new_sum,0) THEN--4o

	       --Make all the unit section status to closed if open in that group
	       FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'CLOSED') LOOP
		 update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	       END LOOP;

	    ELSIF NVL(c_x_grp_rec.max_enr_group,0) > NVL(l_new_sum,0) THEN
	       --Make this unit section status open if closed

	       FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'OPEN') LOOP
		 update_usec_status(l_cur_usec.uoo_id,'OPEN');
	       END LOOP;

	    ELSIF c_x_grp_rec.max_enr_group IS NULL AND l_new_sum IS NULL THEN
	       --Make all the unit section status to open if closed in that group

	       FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'OPEN') LOOP
		 update_usec_status(l_cur_usec.uoo_id,'OPEN');
	       END LOOP;

	    ELSE

	       --Make all the unit section status to closed if open in that group
	       FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'CLOSED') LOOP
		 update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	       END LOOP;

	    END IF;--4c
	  END IF; --2c
	END IF;--1c

	IF l_execute_next_logic = TRUE THEN

	  IF NVL(p_cross_group_tab(i).old_max_enr_group ,0) <> NVL(c_x_grp_rec.max_enr_group,0) THEN
	    IF p_cross_group_tab(i).old_max_enr_group  =  l_new_sum THEN

	      FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'OPEN') LOOP
		update_usec_status(l_cur_usec.uoo_id,'OPEN');
	      END LOOP;

	    ELSIF l_new_sum = c_x_grp_rec.max_enr_group THEN
	      FOR l_cur_usec IN cur_usec(p_cross_group_tab(i).usec_x_listed_group_id,'CLOSED') LOOP
		update_usec_status(l_cur_usec.uoo_id,'CLOSED');
	      END LOOP;
	    END IF;
	  END IF;
	END IF;

      END IF; --l_b_status

    END LOOP;

    RETURN l_b_status;

  END post_usec_cross_group;



  PROCEDURE validate_usec_x_grp ( p_usec_x_grp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_rec_type,
				  p_c_cal_type     VARCHAR2,
				  p_n_seq_num      NUMBER,
				  p_insert_update  VARCHAR2,
				  p_cross_group_rec  IN OUT NOCOPY igs_ps_create_generic_pkg.cross_group_rec_type )
  AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  10-Jun-2005
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR c_usec_x_grp(cp_xgrp_name VARCHAR2) IS
    SELECT 'X'
    FROM  igs_ps_usec_x_grp
    WHERE usec_x_listed_group_name =cp_xgrp_name;

    c_usec_x_grp_rec c_usec_x_grp%ROWTYPE;


    CURSOR c_val_enr(cp_x_name VARCHAR2,cp_cal_type VARCHAR2,cp_sequence_number NUMBER) IS
    SELECT *
    FROM igs_ps_usec_x_grp
    WHERE usec_x_listed_group_name =cp_x_name
    AND Cal_type=cp_cal_type
    AND ci_sequence_number=cp_sequence_number;

    c_val_enr_rec c_val_enr%ROWTYPE;

    CURSOR c_old_cmgrp(cp_x_name VARCHAR2,cp_cal_type VARCHAR2,cp_seq_no NUMBER) IS
    SELECT *  FROM  igs_ps_usec_x_grp
    WHERE usec_x_listed_group_name =cp_x_name
    AND cal_type=cp_cal_type
    AND ci_sequence_number=cp_seq_no;

    c_old_cmgrp_rec c_old_cmgrp%ROWTYPE;

    CURSOR cur_usecs_in_group(cp_usec_x_listed_group_id igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE) IS
    SELECT uoo_id
    FROM   igs_ps_usec_x_grpmem
    WHERE  usec_x_listed_group_id = cp_usec_x_listed_group_id;

    l_message_name     fnd_new_messages.message_name%TYPE;
    l_request_id       igs_ps_sch_hdr_int.request_id%TYPE;

  BEGIN

    --Cannot enter a value for Override Maximum when Enrollment Maximum is null
    IF ((p_usec_x_grp_rec.max_ovr_group IS NOT NULL) AND (p_usec_x_grp_rec.max_enr_group IS NULL)) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_ENR_NULL_OVR_NOT' );
      fnd_msg_pub.add;
      p_usec_x_grp_rec.status := 'E';
    END IF;

    --Group Override Maximum should always be greater than or equal toMaximum Enrollment for the group
    IF ((p_usec_x_grp_rec.max_ovr_group IS NOT NULL) AND (NVL(p_usec_x_grp_rec.max_ovr_group,0) < NVL(p_usec_x_grp_rec.max_enr_group,0))) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_OVERIDE_MIN_MAX_CP' );
      fnd_msg_pub.add;
      p_usec_x_grp_rec.status := 'E';
    END IF;


    p_cross_group_rec.usec_x_listed_group_name:=p_usec_x_grp_rec.usec_x_listed_group_name;

    OPEN c_old_cmgrp(p_usec_x_grp_rec.usec_x_listed_group_name,p_c_cal_type,p_n_seq_num);
    FETCH c_old_cmgrp INTO c_old_cmgrp_rec;
    IF c_old_cmgrp%FOUND THEN
      p_cross_group_rec.usec_x_listed_group_id:=c_old_cmgrp_rec.usec_x_listed_group_id;
      p_cross_group_rec.old_max_enr_group:=c_old_cmgrp_rec.max_enr_group;
    ELSE
      p_cross_group_rec.usec_x_listed_group_id:=NULL;
      p_cross_group_rec.old_max_enr_group:=NULL;
    END IF;
    CLOSE c_old_cmgrp;

    --validation related to location_inheritance
    IF p_insert_update = 'U' THEN
      IF p_usec_x_grp_rec.location_inheritance = 'N' AND c_old_cmgrp_rec.location_inheritance ='Y' THEN
	Fnd_Message.Set_Name('IGS', 'IGS_PS_LOC_INHR_CANNOT_UPD');
        fnd_msg_pub.add;
        p_usec_x_grp_rec.status := 'E';
      END IF;
    END IF;

    -- IF the group enrollment is getting modified
    OPEN c_val_enr(p_usec_x_grp_rec.usec_x_listed_group_name,p_c_cal_type,p_n_seq_num);
    FETCH c_val_enr INTO c_val_enr_rec;
    IF c_val_enr%FOUND THEN
      IF NVL( p_usec_x_grp_rec.max_enr_group,0) <> c_val_enr_rec.max_enr_group OR
	      NVL(p_usec_x_grp_rec.max_ovr_group,0) <>  c_val_enr_rec.max_ovr_group THEN

	--for loop which loops thru all unit sections within a group.
	FOR rec_cur_usecs_in_group IN cur_usecs_in_group(c_val_enr_rec.usec_x_listed_group_id) LOOP
	    --Before updating check for validity of schedule status...
	  IF igs_ps_usec_schedule.prgp_get_schd_status( p_uoo_id   => rec_cur_usecs_in_group.uoo_id,
							p_usec_id  => NULL,
							p_message_name => l_message_name ) = TRUE THEN
	    IF l_message_name IS NULL THEN
	      l_message_name := 'IGS_PS_SCST_PROC';
	    END IF;

	    fnd_message.set_name('IGS',l_message_name);
	    fnd_msg_pub.add;
	    p_usec_x_grp_rec.status := 'E';
	     --update the schedule status to 'Rescheduling Requested', if unit section occurrence is a scheduled one.
	  ELSIF igs_ps_usec_schedule.prgp_upd_usec_dtls
				    (
				     p_uoo_id                  => rec_cur_usecs_in_group.uoo_id,
				     p_location_cd             => NULL,
				     p_usec_status             => NULL,
				     p_max_enrollments         => NVL(p_usec_x_grp_rec.max_enr_group,-999),
				     p_override_enrollment_max => NVL(p_usec_x_grp_rec.max_ovr_group,-999),
				     p_enrollment_expected     => NULL,
				     p_request_id              => l_request_id,
				     p_message_name            => l_message_name
				    ) = FALSE THEN
	    fnd_message.set_name('IGS',l_message_name);
	    fnd_msg_pub.add;
	    p_usec_x_grp_rec.status := 'E';
	  END IF;
	END LOOP;
      END IF;
    END IF;
    CLOSE c_val_enr;


  END validate_usec_x_grp;


  FUNCTION post_as_us_ai ( p_tab_as_us_ai IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_tbl_type,
                           p_tab_uoo IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR cur_aig (cp_uoo_id IN NUMBER) IS
    SELECT us_ass_item_group_id,
	   group_name,
	   NVL (final_weight_qty, 0) group_final_weight_qty,
	   NVL (midterm_weight_qty, 0) group_midterm_weight_qty,
	   NVL (final_formula_qty, 0) group_final_formula_qty,
	   NVL (midterm_formula_qty, 0) group_midterm_formula_qty
    FROM   igs_as_us_ai_group
    WHERE  uoo_id = cp_uoo_id;

    CURSOR cur_ai (cp_us_ass_item_group_id IN NUMBER ) IS
    SELECT NVL (SUM (final_weight_qty), 0) sum_final_weight_qty,
	   NVL (SUM (midterm_weight_qty), 0) sum_midterm_weight_qty,
	   COUNT (us_ass_item_group_id) number_of_ai,
	   COUNT (DECODE (dflt_item_ind, 'Y', 1, NULL)) number_of_default_ai
    FROM   igs_ps_unitass_item
    WHERE  us_ass_item_group_id = cp_us_ass_item_group_id
    AND    logical_delete_dt IS NULL;

    CURSOR cur_group (cp_rec_as_us_ai igs_ps_generic_pub.usec_ass_item_grp_rec_type) IS
    SELECT a.us_ass_item_group_id
    FROM   igs_as_us_ai_group a, igs_ps_unit_ofr_opt_all b, igs_ca_inst_all c
    WHERE  a.group_name = cp_rec_as_us_ai.group_name
    AND    a.uoo_id =b.uoo_id
    AND    b.unit_cd=cp_rec_as_us_ai.unit_cd
    AND    b.version_number=cp_rec_as_us_ai.version_number
    AND    b.cal_type=c.cal_type
    AND    b.ci_sequence_number=c.sequence_number
    AND    c.alternate_code=cp_rec_as_us_ai.teach_cal_alternate_code
    AND    b.unit_class=cp_rec_as_us_ai.unit_class
    AND    b.location_cd=cp_rec_as_us_ai.location_cd;
    l_cur_group  cur_group%ROWTYPE;

    rec_ai cur_ai%ROWTYPE;
    l_n_count_msg NUMBER(6);
    l_b_status    BOOLEAN;
  BEGIN
    l_b_status := TRUE;

    FOR i IN 1 ..p_tab_uoo.LAST LOOP
      FOR rec_aig IN cur_aig (p_tab_uoo(i)) LOOP
	--
	-- Validate that the at least one Assessment Item has to have a weighting
	-- of more than zero, if the corresponding Assessment Item Group's Grading
	-- Period has a weighting of more than zero.
	--
	OPEN cur_ai (rec_aig.us_ass_item_group_id);
	FETCH cur_ai INTO rec_ai;
	CLOSE cur_ai;
	--
	-- Midterm Grading Period
	--
	IF (rec_aig.group_midterm_weight_qty > 0) THEN
	  IF (rec_ai.number_of_ai >= 0) THEN
	    IF (rec_ai.sum_midterm_weight_qty = 0) THEN
	      fnd_message.set_name ('IGS', 'IGS_AS_GRP_WEIT_GT_SUM_AI_WEIT');
	      fnd_msg_pub.add;
	      l_n_count_msg := fnd_msg_pub.count_msg;
	      FOR j in 1..p_tab_as_us_ai.LAST LOOP
		IF p_tab_as_us_ai.EXISTS(j) THEN
		  OPEN cur_group( p_tab_as_us_ai(j));
		  FETCH cur_group INTO l_cur_group;
		  CLOSE cur_group;
		  IF p_tab_as_us_ai(j).status = 'S' AND l_cur_group.us_ass_item_group_id = rec_aig.us_ass_item_group_id THEN
		    p_tab_as_us_ai(j).status := 'E';
		    p_tab_as_us_ai(j).msg_from := l_n_count_msg;
		    p_tab_as_us_ai(j).msg_to := l_n_count_msg;
		  END IF;
	       END IF;
	     END LOOP;
	     l_b_status :=FALSE;
	    END IF;
	  END IF;
	END IF;

	--
	-- Final Grading Period
	--
	IF (rec_aig.group_final_weight_qty > 0) THEN
	  IF (rec_ai.number_of_ai >= 0) THEN
	    IF (rec_ai.sum_final_weight_qty = 0) THEN
	      fnd_message.set_name ('IGS', 'IGS_AS_GRP_WEIT_GT_SUM_AI_WEIT');
	      fnd_msg_pub.add;
	      l_n_count_msg := fnd_msg_pub.count_msg;
	      FOR j in 1..p_tab_as_us_ai.LAST LOOP
		IF p_tab_as_us_ai.EXISTS(j) THEN
		  OPEN cur_group( p_tab_as_us_ai(j));
		  FETCH cur_group INTO l_cur_group;
		  CLOSE cur_group;
		  IF p_tab_as_us_ai(j).status = 'S' AND l_cur_group.us_ass_item_group_id = rec_aig.us_ass_item_group_id THEN
		    p_tab_as_us_ai(j).status := 'E';
		    p_tab_as_us_ai(j).msg_from := l_n_count_msg;
		    p_tab_as_us_ai(j).msg_to := l_n_count_msg;
		  END IF;
	       END IF;
	     END LOOP;
	     l_b_status :=FALSE;
	    END IF;
	  END IF;
	END IF;
	--
	-- Check that there are enough Default Assessment Items to satisfy the
	-- Assessment Item Group's Final/Midterm Grading Period formula number.
	--
	IF ((rec_ai.number_of_default_ai < rec_aig.group_final_formula_qty) OR
	    (rec_ai.number_of_default_ai < rec_aig.group_midterm_formula_qty)) THEN
	  fnd_message.set_name ('IGS', 'IGS_AS_NOT_ENOUGH_DFLT_AI');
	  fnd_msg_pub.add;
	  l_n_count_msg := fnd_msg_pub.count_msg;
	  FOR j in 1..p_tab_as_us_ai.LAST LOOP
	    IF p_tab_as_us_ai.EXISTS(j) THEN
	      OPEN cur_group( p_tab_as_us_ai(j));
	      FETCH cur_group INTO l_cur_group;
	      CLOSE cur_group;
	      IF p_tab_as_us_ai(j).status = 'S' AND l_cur_group.us_ass_item_group_id = rec_aig.us_ass_item_group_id THEN
		p_tab_as_us_ai(j).status := 'E';
		p_tab_as_us_ai(j).msg_from := l_n_count_msg;
		p_tab_as_us_ai(j).msg_to := l_n_count_msg;
	      END IF;
	    END IF;
	  END LOOP;
	  l_b_status :=FALSE;
	END IF;
      END LOOP;
    END LOOP;

    RETURN l_b_status;

  END post_as_us_ai;


  FUNCTION post_tch_rsp_ovrd ( p_tab_tch_rsp_ovrd IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_tbl_type,
                               p_tab_uoo IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  18-Jun-2005
    Purpose        :  This function will do validations after importing records of Unit Section Teaching Responsibility Override.
                      This will returns TRUE if all the validations pass and returns FALSE, if fails.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_tro_perc_sum( cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT SUM(percentage) percentage
  FROM   igs_ps_tch_resp_ovrd_all
  WHERE  uoo_id=cp_uoo_id;
  c_tro_perc_sum_rec c_tro_perc_sum%ROWTYPE;

  CURSOR c_uoo_id (cp_usec_tch_resp_rec IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_rec_type) IS
  SELECT uoo_id
  FROM   igs_ps_unit_ofr_opt_all a,igs_ca_inst_all b
  WHERE  a.unit_cd = cp_usec_tch_resp_rec.unit_cd
  AND    a.version_number = cp_usec_tch_resp_rec.version_number
  AND    a.cal_type = b.cal_type
  AND    a.ci_sequence_number = b.sequence_number
  AND    b.alternate_code=cp_usec_tch_resp_rec.teach_cal_alternate_code
  AND    a.location_cd =cp_usec_tch_resp_rec.location_cd
  AND    a.unit_class = cp_usec_tch_resp_rec.unit_class;
  c_uoo_id_rec c_uoo_id%ROWTYPE;

  l_n_count_msg NUMBER(6);
  l_b_status    BOOLEAN;

  BEGIN
    l_b_status:= TRUE;

    FOR i IN 1 ..p_tab_uoo.LAST LOOP
      OPEN c_tro_perc_sum (p_tab_uoo(i));
      FETCH c_tro_perc_sum INTO c_tro_perc_sum_rec;
      CLOSE c_tro_perc_sum;
      IF (c_tro_perc_sum_rec.percentage) <> 100 THEN
           l_b_status:= FALSE;
           fnd_message.set_name ( 'IGS', 'IGS_PS_PRCALLOC_TEACH_RESP' );
           fnd_msg_pub.add;
	   l_n_count_msg := fnd_msg_pub.count_msg;
           FOR j in 1..p_tab_tch_rsp_ovrd.LAST LOOP
             OPEN c_uoo_id (p_tab_tch_rsp_ovrd(j));
	     FETCH c_uoo_id INTO c_uoo_id_rec;
             CLOSE c_uoo_id;
             IF p_tab_tch_rsp_ovrd.EXISTS(j) THEN
               IF p_tab_tch_rsp_ovrd(j).status = 'S' AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id THEN
                  p_tab_tch_rsp_ovrd(j).status := 'E';
                  p_tab_tch_rsp_ovrd(j).msg_from := l_n_count_msg;
                  p_tab_tch_rsp_ovrd(j).msg_to := l_n_count_msg;
               END IF;
             END IF;
           END LOOP;
      END IF;
    END LOOP;

    RETURN   l_b_status;

  END post_tch_rsp_ovrd;


FUNCTION post_usec_rsv ( p_tab_usec_rsv IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_tbl_type,
                         p_tab_uoo       IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  18-Jul-2005
    Purpose        :  Check child existence for a priority
		      Priority order should be in series
		      Preference order should be in series

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    l_n_count_msg NUMBER(6);

    CURSOR c_rsv_perc_sum( cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT nvl(SUM(percentage_reserved),0) percentage_reserved
    FROM igs_ps_rsv_usec_pri usprv,igs_ps_rsv_usec_prf uspfv
    WHERE usprv.rsv_usec_pri_id  = uspfv.rsv_usec_pri_id
    AND  usprv.uoo_id =cp_uoo_id;

    c_rsv_perc_sum_rec c_rsv_perc_sum%ROWTYPE;

    CURSOR c_usec_rsvpric_ser(cp_uoo_id NUMBER) IS
    SELECT priority_order
    FROM   igs_ps_rsv_usec_pri
    WHERE  uoo_id=cp_uoo_id
    ORDER BY priority_order;

    CURSOR cur_priority_id(cp_uoo_id NUMBER) IS
    SELECT rsv_usec_pri_id,priority_value
    FROM   igs_ps_rsv_usec_pri
    WHERE  uoo_id=cp_uoo_id;

    CURSOR c_usec_rsvprfc_ser(cp_rsv_usec_pri_id NUMBER) IS
    SELECT preference_order
    FROM   igs_ps_rsv_usec_prf
    WHERE  rsv_usec_pri_id = cp_rsv_usec_pri_id
    ORDER BY preference_order;
    l_c_usec_rsvprfc_ser c_usec_rsvprfc_ser%ROWTYPE;

    CURSOR c_uoo_id (cp_usec_rsv_rec IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type) IS
    SELECT uoo_id
    FROM   igs_ps_unit_ofr_opt_all a,igs_ca_inst_all b
    WHERE  a.unit_cd = cp_usec_rsv_rec.unit_cd
    AND    a.version_number = cp_usec_rsv_rec.version_number
    AND    a.cal_type = b.cal_type
    AND    a.ci_sequence_number = b.sequence_number
    AND    b.alternate_code=cp_usec_rsv_rec.teach_cal_alternate_code
    AND    a.location_cd =cp_usec_rsv_rec.location_cd
    AND    a.unit_class = cp_usec_rsv_rec.unit_class;

    c_uoo_id_rec c_uoo_id%ROWTYPE;

    l_b_status  BOOLEAN;
    l_n_counter NUMBER;

  BEGIN
    l_b_status:=TRUE;
    FOR i IN 1 ..p_tab_uoo.LAST LOOP
      --Check child existence for a priority
      FOR rec_priority_id IN cur_priority_id(p_tab_uoo(i)) LOOP

	 OPEN c_usec_rsvprfc_ser(rec_priority_id.rsv_usec_pri_id);
         FETCH c_usec_rsvprfc_ser INTO l_c_usec_rsvprfc_ser;
	 IF c_usec_rsvprfc_ser%NOTFOUND THEN
	   l_b_status:= FALSE;
	   fnd_message.set_name ( 'IGS', 'IGS_EN_PREF_REQ_PRIOR');
           fnd_message.set_token('PRIORITY',rec_priority_id.priority_value);
	   fnd_msg_pub.add;
	   l_n_count_msg := fnd_msg_pub.count_msg;
	   FOR j in 1..p_tab_usec_rsv.LAST LOOP
	     IF p_tab_usec_rsv.EXISTS(j) THEN
	       OPEN c_uoo_id(p_tab_usec_rsv(j));
	       FETCH c_uoo_id INTO c_uoo_id_rec;
	       CLOSE c_uoo_id;
	       IF p_tab_usec_rsv(j).status = 'S'  AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id AND p_tab_usec_rsv(j).priority_value = rec_priority_id.priority_value THEN
		 p_tab_usec_rsv(j).status := 'E';
		 p_tab_usec_rsv(j).msg_from := l_n_count_msg;
		 p_tab_usec_rsv(j).msg_to := l_n_count_msg;
	       END IF;
	     END IF;
	   END LOOP;

	 END IF;
	 CLOSE c_usec_rsvprfc_ser;

      END LOOP;


      --Sum of the percentage of preferences for a unit section should not be greater than 100.
      OPEN c_rsv_perc_sum (p_tab_uoo(i));
      FETCH c_rsv_perc_sum INTO c_rsv_perc_sum_rec;
      IF (c_rsv_perc_sum_rec.percentage_reserved) > 100 THEN
      	  l_b_status:= FALSE;
	  fnd_message.set_name ( 'IGS', 'IGS_PS_PREF_SUM_BET_0_100' );
	  fnd_msg_pub.add;
	  l_n_count_msg := fnd_msg_pub.count_msg;
	  FOR j in 1..p_tab_usec_rsv.LAST LOOP
	     IF p_tab_usec_rsv.EXISTS(j) THEN
	       OPEN c_uoo_id(p_tab_usec_rsv(j));
	       FETCH c_uoo_id INTO c_uoo_id_rec;
	       CLOSE c_uoo_id;
	       IF p_tab_usec_rsv(j).status = 'S'  AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id THEN
	         p_tab_usec_rsv(j).status := 'E';
	         p_tab_usec_rsv(j).msg_from := l_n_count_msg;
	         p_tab_usec_rsv(j).msg_to := l_n_count_msg;
	       END IF;
	     END IF;
	  END LOOP;
      END IF;
      CLOSE c_rsv_perc_sum;


      --Priority order should be in series
      l_n_counter :=1;
      FOR c_usec_rsvpric_ser_rec IN c_usec_rsvpric_ser(p_tab_uoo(i)) LOOP
         IF l_n_counter <> c_usec_rsvpric_ser_rec.priority_order THEN
	   l_b_status:= FALSE;
	   fnd_message.set_name ( 'IGS', 'IGS_PS_RSV_PRI_NOT_IN_SERIES' );
	   fnd_msg_pub.add;
	   l_n_count_msg := fnd_msg_pub.count_msg;
	   FOR j in 1..p_tab_usec_rsv.LAST LOOP
	     IF p_tab_usec_rsv.EXISTS(j) THEN
	       OPEN c_uoo_id(p_tab_usec_rsv(j));
	       FETCH c_uoo_id INTO c_uoo_id_rec;
	       CLOSE c_uoo_id;
	       IF p_tab_usec_rsv(j).status = 'S'  AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id THEN
	         p_tab_usec_rsv(j).status := 'E';
	         p_tab_usec_rsv(j).msg_from := l_n_count_msg;
	         p_tab_usec_rsv(j).msg_to := l_n_count_msg;
	       END IF;
	     END IF;
	   END LOOP;

	   IF l_b_status = FALSE THEN
             EXIT;
	   END IF;

         END IF;
         l_n_counter:= l_n_counter+1;
      END LOOP;

      --Preference order should be in series
      FOR rec_priority_id IN cur_priority_id(p_tab_uoo(i)) LOOP
         l_n_counter:=1;
	 FOR c_usec_rsvprfc_ser_rec IN c_usec_rsvprfc_ser(rec_priority_id.rsv_usec_pri_id) LOOP

	   IF l_n_counter <> c_usec_rsvprfc_ser_rec.preference_order THEN
	     l_b_status:= FALSE;
	     fnd_message.set_name ( 'IGS', 'IGS_PS_RSV_PRF_NOT_IN_SERIES' );
	     fnd_msg_pub.add;
	     l_n_count_msg := fnd_msg_pub.count_msg;
	     FOR j in 1..p_tab_usec_rsv.LAST LOOP
	       IF p_tab_usec_rsv.EXISTS(j) THEN
		 OPEN c_uoo_id(p_tab_usec_rsv(j));
		 FETCH c_uoo_id INTO c_uoo_id_rec;
		 CLOSE c_uoo_id;
		 IF p_tab_usec_rsv(j).status = 'S'  AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id AND p_tab_usec_rsv(j).priority_value = rec_priority_id.priority_value THEN
		   p_tab_usec_rsv(j).status := 'E';
		   p_tab_usec_rsv(j).msg_from := l_n_count_msg;
		   p_tab_usec_rsv(j).msg_to := l_n_count_msg;
		 END IF;
	       END IF;
	     END LOOP;

	   END IF;
	   l_n_counter:= l_n_counter+1;

	 END LOOP;
      END LOOP; --distinct priority_id loop

   END LOOP; --Main distinct uoo_id loop

   RETURN l_b_status;

 END post_usec_rsv;



--post insert/update validations for Unit section Waitlist
FUNCTION post_usec_wlst ( p_tab_usec_wlst IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_tbl_type,
                          p_tab_uoo       IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  18-Jul-2005
    Purpose        :  Check child existence for a priority
		      Priority order should be in series
		      Preference order should be in series

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    l_n_count_msg NUMBER(6);

    CURSOR c_usec_wlstpric_ser(cp_uoo_id NUMBER) IS
    SELECT priority_number
    FROM   igs_ps_usec_wlst_pri
    WHERE  uoo_id=cp_uoo_id
    ORDER BY priority_number;

    CURSOR cur_priority_id(cp_uoo_id NUMBER) IS
    SELECT unit_sec_waitlist_priority_id,priority_value
    FROM   igs_ps_usec_wlst_pri
    WHERE  uoo_id=cp_uoo_id;

    CURSOR c_usec_wlstprfc_ser(cp_waitlist_priority_id NUMBER) IS
    SELECT preference_order
    FROM   igs_ps_usec_wlst_prf
    WHERE  unit_sec_waitlist_priority_id = cp_waitlist_priority_id
    ORDER BY preference_order;
    l_c_usec_wlstprfc_ser c_usec_wlstprfc_ser%ROWTYPE;

    CURSOR c_uoo_id (cp_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type) IS
    SELECT   uoo_id
    FROM   igs_ps_unit_ofr_opt_all a,igs_ca_inst_all b
    WHERE  a.unit_cd = cp_usec_wlst_rec.unit_cd
    AND a.version_number = cp_usec_wlst_rec.version_number
    AND a.cal_type = b.cal_type
    AND a.ci_sequence_number = b.sequence_number
    AND b.alternate_code=cp_usec_wlst_rec.teach_cal_alternate_code
    AND a.location_cd =cp_usec_wlst_rec.location_cd
    AND a.unit_class = cp_usec_wlst_rec.unit_class;

    c_uoo_id_rec c_uoo_id%ROWTYPE;

    l_b_status  BOOLEAN;
    l_n_counter NUMBER;

  BEGIN
    l_b_status:=TRUE;
    FOR i IN 1 ..p_tab_uoo.LAST LOOP
      --Check child existence for a priority
      FOR rec_priority_id IN cur_priority_id(p_tab_uoo(i)) LOOP
	 OPEN c_usec_wlstprfc_ser(rec_priority_id.unit_sec_waitlist_priority_id);
	 FETCH c_usec_wlstprfc_ser INTO l_c_usec_wlstprfc_ser;
	 IF c_usec_wlstprfc_ser%NOTFOUND THEN
	   l_b_status:= FALSE;
	   fnd_message.set_name ( 'IGS', 'IGS_EN_PREF_REQ_PRIOR');
           fnd_message.set_token('PRIORITY',rec_priority_id.priority_value);
	   fnd_msg_pub.add;
	   l_n_count_msg := fnd_msg_pub.count_msg;
	   FOR j in 1..p_tab_usec_wlst.LAST LOOP
	     IF p_tab_usec_wlst.EXISTS(j) THEN
	       OPEN c_uoo_id(p_tab_usec_wlst(j));
	       FETCH c_uoo_id INTO c_uoo_id_rec;
	       CLOSE c_uoo_id;
	       IF p_tab_usec_wlst(j).status = 'S'  AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id AND p_tab_usec_wlst(j).priority_value = rec_priority_id.priority_value THEN
		 p_tab_usec_wlst(j).status := 'E';
		 p_tab_usec_wlst(j).msg_from := l_n_count_msg;
		 p_tab_usec_wlst(j).msg_to := l_n_count_msg;
	       END IF;
	     END IF;
	   END LOOP;
	 END IF;
         CLOSE c_usec_wlstprfc_ser;
      END LOOP;


      --Priority order should be in series
      l_n_counter :=1;
      FOR c_usec_wlstpric_ser_rec IN c_usec_wlstpric_ser(p_tab_uoo(i)) LOOP
         IF l_n_counter <> c_usec_wlstpric_ser_rec.priority_number THEN
	   l_b_status:= FALSE;
	   fnd_message.set_name ( 'IGS', 'IGS_PS_WLST_PRI_NOT_IN_SERIES' );
	   fnd_msg_pub.add;
	   l_n_count_msg := fnd_msg_pub.count_msg;
	   FOR j in 1..p_tab_usec_wlst.LAST LOOP
	     IF p_tab_usec_wlst.EXISTS(j) THEN
	       OPEN c_uoo_id(p_tab_usec_wlst(j));
	       FETCH c_uoo_id INTO c_uoo_id_rec;
	       CLOSE c_uoo_id;
	       IF p_tab_usec_wlst(j).status = 'S'  AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id THEN
	         p_tab_usec_wlst(j).status := 'E';
	         p_tab_usec_wlst(j).msg_from := l_n_count_msg;
	         p_tab_usec_wlst(j).msg_to := l_n_count_msg;
	       END IF;
	     END IF;
	   END LOOP;

	   IF l_b_status = FALSE THEN
             EXIT;
	   END IF;

         END IF;
         l_n_counter:= l_n_counter+1;
      END LOOP;

      --Preference order should be in series
      FOR rec_priority_id IN cur_priority_id(p_tab_uoo(i)) LOOP
         l_n_counter:=1;
	 FOR c_usec_wlstprfc_ser_rec IN c_usec_wlstprfc_ser(rec_priority_id.unit_sec_waitlist_priority_id) LOOP

	   IF l_n_counter <> c_usec_wlstprfc_ser_rec.preference_order THEN
	     l_b_status:= FALSE;
	     fnd_message.set_name ( 'IGS', 'IGS_PS_WLST_PRF_NOT_IN_SERIES' );
	     fnd_msg_pub.add;
	     l_n_count_msg := fnd_msg_pub.count_msg;
	     FOR j in 1..p_tab_usec_wlst.LAST LOOP
	       IF p_tab_usec_wlst.EXISTS(j) THEN
		 OPEN c_uoo_id(p_tab_usec_wlst(j));
		 FETCH c_uoo_id INTO c_uoo_id_rec;
		 CLOSE c_uoo_id;
		 IF p_tab_usec_wlst(j).status = 'S'  AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id AND p_tab_usec_wlst(j).priority_value = rec_priority_id.priority_value THEN
		   p_tab_usec_wlst(j).status := 'E';
		   p_tab_usec_wlst(j).msg_from := l_n_count_msg;
		   p_tab_usec_wlst(j).msg_to := l_n_count_msg;
		 END IF;
	       END IF;
	     END LOOP;

	   END IF;
	   l_n_counter:= l_n_counter+1;

	 END LOOP;
      END LOOP; --distinct priority_id loop

   END LOOP; --Main distinct uoo_id loop

   RETURN l_b_status;

 END post_usec_wlst;




-- Validate Unit Section Occurence Facility Records before inserting them

PROCEDURE validate_facility (p_uso_fclt_rec    IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_rec_type,
                             p_n_uoo_id        IN NUMBER,
                             p_uso_id          IN NUMBER,
                             p_calling_context IN VARCHAR2)
  AS
  /***********************************************************************************************
    Created By     :  SOMMUKHE
    Date Created By:  21-NOV-2002
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

  CURSOR cur_facility_closed (cp_facility_code igs_ps_media_equip_all.media_code%TYPE) IS
  SELECT 'X'
  FROM   igs_ps_media_equip_all
  WHERE  media_code = cp_facility_code
  AND    closed_ind = 'Y';

  CURSOR c_facility (cp_uso_id igs_ps_uso_facility.unit_section_occurrence_id%TYPE) IS
  SELECT 'X'
  FROM   igs_ps_usec_occurs_all
  WHERE  unit_section_occurrence_id = cp_uso_id
  AND    schedule_status = 'PROCESSING';

  l_c_var   VARCHAR2(1);

  CURSOR c_occurs(cp_unit_section_occurrence_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
  SELECT uso.unit_section_occurrence_id
  FROM igs_ps_usec_occurs_all uso
  WHERE (uso.schedule_status IS NOT NULL AND uso.schedule_status NOT IN ('PROCESSING','USER_UPDATE'))
  AND uso.no_set_day_ind ='N'
  AND uso.unit_section_occurrence_id=cp_unit_section_occurrence_id;

  BEGIN

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_uso_fclt_rec.status := 'E';
    END IF;

   --Facility code cannot be closed
   OPEN cur_facility_closed( p_uso_fclt_rec.facility_code);
   FETCH cur_facility_closed INTO l_c_var;
   IF cur_facility_closed%FOUND THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_FACILITY_CLOSED' );
      fnd_msg_pub.add;
      p_uso_fclt_rec.status := 'E';
   END IF;
   CLOSE cur_facility_closed;

   --Cannot import facilities when the occurrence is in progress except calling context is scheduling
   IF p_calling_context <> 'S' THEN
     OPEN c_facility (p_uso_id);
     FETCH c_facility INTO l_c_var;
     IF c_facility%FOUND THEN
	fnd_message.set_name ( 'IGS', 'IGS_PS_SCHEDULING_IN_PROGRESS' );
	fnd_msg_pub.add;
	p_uso_fclt_rec.status := 'E';
     END IF;
     CLOSE c_facility;

     --Update the schedule status of the occurrence to USER_UPDATE if inserting/updating a record
     IF p_uso_fclt_rec.status = 'S' THEN
       FOR l_occurs_rec IN c_occurs(p_uso_id) LOOP
	 igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
       END LOOP;
     END IF;

   END IF;


  END validate_facility;

  PROCEDURE validate_category (p_usec_cat_rec IN OUT NOCOPY igs_ps_generic_pub.usec_cat_rec_type,
                               p_n_uoo_id     IN NUMBER)
  AS
  /***********************************************************************************************
    Created By     :  SOMMUKHE
    Date Created By:  21-NOV-2002
    Purpose        :  Check for the closed indicator for the unit category

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_category(cp_unit_cat igs_ps_usec_category.unit_cat%type) IS
  SELECT 'X'
  FROM   igs_ps_unit_cat
  WHERE  unit_cat = cp_unit_cat
  AND    closed_ind = 'Y';

  c_category_rec c_category%ROWTYPE;
  BEGIN

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_usec_cat_rec.status := 'E';
    END IF;

    OPEN c_category(p_usec_cat_rec.unit_cat);
    FETCH c_category INTO c_category_rec;
    IF c_category%FOUND THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_CATEGORY_CLOSED' );
      fnd_msg_pub.add;
      p_usec_cat_rec.status := 'E';
    END IF;
    CLOSE c_category;

  END validate_category;

  PROCEDURE validate_usec_rsvpri(p_usec_rsv_rec  IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,
                                 p_n_uoo_id      IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
				 p_insert_update IN VARCHAR2)
  AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:
    Purpose        : Check if reserved  seating is allowed and if priority value is 'PERSON_GRP'

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_rsv_allow (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT reserved_seating_allowed
  FROM   igs_ps_unit_ofr_opt_all
  WHERE  uoo_id =cp_n_uoo_id;
  c_rsvpri_rec c_rsv_allow%ROWTYPE;

  l_c_message VARCHAR2(30);
  BEGIN

    -- Check if unit status is inactive.
    IF NOT igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_rsv_rec.unit_cd,p_usec_rsv_rec.version_number,l_c_message) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
      fnd_msg_pub.add;
      p_usec_rsv_rec.status := 'E';
    END IF;

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_usec_rsv_rec.status := 'E';
    END IF;


    OPEN c_rsv_allow (p_n_uoo_id);
    FETCH c_rsv_allow INTO c_rsvpri_rec;
    IF c_rsvpri_rec.reserved_seating_allowed = 'N' THEN
       fnd_message.set_name ( 'IGS', 'IGS_PS_RSV_SEAT_NOT_ALLOWED' );
       fnd_msg_pub.add;
       p_usec_rsv_rec.status := 'E';
    END IF;
    CLOSE c_rsv_allow;

    IF p_insert_update = 'I' THEN
      IF p_usec_rsv_rec.priority_order IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PRIORITY_ORDER', 'LEGACY_TOKENS', FALSE);
        p_usec_rsv_rec.status := 'E';
      END IF;
    END IF;

  END validate_usec_rsvpri;

  PROCEDURE validate_usec_rsvprf(p_usec_rsv_rec  IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_rec_type,
				 p_insert_update IN VARCHAR2)
  AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:
    Purpose        : Check if reserved  seating is allowed and if priority value is 'PERSON_GRP'

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    16-FEB-2006     Bug#3094371, replaced IGS_OR_UNIT by igs_or_inst_org_base_v for cursor c_org
  ********************************************************************************************** */

   CURSOR c_clstd(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE) IS
   SELECT 'X'
   FROM   igs_pr_class_std
   WHERE  closed_ind = 'N'
   AND    class_standing = cp_preference_code;

   c_clstd_rec c_clstd%ROWTYPE;

   CURSOR c_pstage(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE) IS
   SELECT 'X'
   FROM   igs_ps_stage_type
   WHERE  closed_ind  = 'N'
   AND    course_stage_type  = cp_preference_code;

   c_pstage_rec c_pstage%ROWTYPE;

   CURSOR c_prog(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE,
                 cp_preference_version igs_ps_rsv_usec_prf.preference_version%TYPE) IS
   SELECT 'X'
   FROM   igs_ps_ver pv, igs_ps_stat pvst
   WHERE  pvst.course_status = pv.course_status
   AND    pvst.s_course_status <> 'INACTIVE'
   AND    pv.course_cd=cp_preference_code
   AND    pv.version_number=cp_preference_version;

   c_prog_rec c_prog%ROWTYPE;

   CURSOR c_unit_set(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE,
                     cp_preference_version igs_ps_rsv_usec_prf.preference_version%TYPE) IS
   SELECT 'X'
   FROM   igs_en_unit_set us, igs_en_unit_set_stat uss
   WHERE  us.unit_set_status = uss.unit_set_status
   AND    uss.s_unit_set_status <> 'INACTIVE'
   AND    us.unit_set_cd = cp_preference_code
   AND    us.version_number = cp_preference_version;

   c_unit_set_rec c_unit_set%ROWTYPE;

   CURSOR c_pgrp(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE) IS
   SELECT 'X'
   FROM   igs_pe_persid_group_all
   WHERE  closed_ind = 'N'
   AND    group_cd = cp_preference_code
   AND    file_name IS NULL
   AND   NVL(org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),
             ' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
             NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),
             ' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);

   c_pgrp_rec c_pgrp%ROWTYPE;

   CURSOR c_org(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE) IS
   SELECT 'X'
   FROM   igs_or_inst_org_base_v a, igs_or_status b
   WHERE  a.party_number = cp_preference_code
   AND    a.org_status = b.org_status
   AND    b.s_org_status <> 'INACTIVE';
   c_org_rec c_org%ROWTYPE;

  BEGIN

    IF p_insert_update = 'I' THEN

      --validation when priority value as Person Group
      IF p_usec_rsv_rec.priority_value = 'PERSON_GRP' THEN
	OPEN c_pgrp (p_usec_rsv_rec.preference_code);
	FETCH c_pgrp  INTO c_pgrp_rec;
	IF c_pgrp%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
	CLOSE c_pgrp;
      END IF;

      --validation when priority value as Org unit
      IF p_usec_rsv_rec.priority_value = 'ORG_UNIT' THEN
	OPEN c_org (p_usec_rsv_rec.preference_code);
	FETCH c_org  INTO c_org_rec;
	IF c_org%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
	CLOSE c_org;
      END IF;


      --validation when priority value as Class standing
      IF p_usec_rsv_rec.priority_value = 'CLASS_STD' THEN
	OPEN c_clstd (p_usec_rsv_rec.preference_code);
	FETCH c_clstd  INTO c_clstd_rec;
	IF c_clstd%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
	CLOSE c_clstd;
      END IF;

      --Validation  when priority value as Program stage.
      IF p_usec_rsv_rec.priority_value = 'PROGRAM_STAGE' THEN
	OPEN c_pstage (p_usec_rsv_rec.preference_code);
	FETCH c_pstage  INTO c_pstage_rec;
	IF c_pstage%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
	CLOSE c_pstage;
      END IF;

      --Validation  when priority value as Program .
      IF p_usec_rsv_rec.priority_value = 'PROGRAM' THEN
	OPEN c_prog (p_usec_rsv_rec.preference_code,p_usec_rsv_rec.preference_version);
	FETCH c_prog  INTO c_prog_rec;
	IF c_prog%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
	CLOSE c_prog;
      END IF;

      --Validation  when priority value as UNIT_SET .
      IF p_usec_rsv_rec.priority_value = 'UNIT_SET' THEN
	OPEN c_unit_set (p_usec_rsv_rec.preference_code,p_usec_rsv_rec.preference_version);
	FETCH c_unit_set  INTO c_unit_set_rec;
	IF c_unit_set%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_rsv_rec.status := 'E';
	END IF;
	CLOSE c_unit_set;
      END IF;

    END IF;

  END validate_usec_rsvprf;


  PROCEDURE validate_usec_wlstprf(p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,
				  p_insert_update IN VARCHAR2) AS

  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:
    Purpose        : Check if waitlist  preference related validation are passed.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    16-FEB-2006     Bug#3094371, replaced IGS_OR_UNIT by igs_or_inst_org_base_v for cursor c_org
  ********************************************************************************************** */

   CURSOR c_clstd(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE) IS
   SELECT 'X'
   FROM   igs_pr_class_std
   WHERE  closed_ind = 'N'
   AND    class_standing = cp_preference_code;

   c_clstd_rec c_clstd%ROWTYPE;

   CURSOR c_pstage(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE) IS
   SELECT 'X'
   FROM   igs_ps_stage_type
   WHERE  closed_ind  = 'N'
   AND    course_stage_type  = cp_preference_code;

   c_pstage_rec c_pstage%ROWTYPE;

   CURSOR c_prog(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE,
                 cp_preference_version igs_ps_rsv_usec_prf.preference_version%TYPE) IS
   SELECT 'X'
   FROM   igs_ps_ver pv, igs_ps_stat pvst
   WHERE  pvst.course_status = pv.course_status
   AND    pvst.s_course_status <> 'INACTIVE'
   AND    pv.course_cd=cp_preference_code
   AND    pv.version_number=cp_preference_version;

   c_prog_rec c_prog%ROWTYPE;

   CURSOR c_unit_set(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE,
                     cp_preference_version igs_ps_rsv_usec_prf.preference_version%TYPE) IS
   SELECT 'X'
   FROM   igs_en_unit_set us, igs_en_unit_set_stat uss
   WHERE  us.unit_set_status = uss.unit_set_status
   AND    uss.s_unit_set_status <> 'INACTIVE'
   AND    us.unit_set_cd = cp_preference_code
   AND    us.version_number = cp_preference_version;

   c_unit_set_rec c_unit_set%ROWTYPE;

   CURSOR c_org(cp_preference_code igs_ps_rsv_usec_prf.preference_code%TYPE) IS
   SELECT 'X'
   FROM   igs_or_inst_org_base_v a, igs_or_status b
   WHERE  a.party_number = cp_preference_code
   AND    a.org_status = b.org_status
   AND    b.s_org_status <> 'INACTIVE';
   c_org_rec c_org%ROWTYPE;

  BEGIN

    IF p_insert_update = 'I' THEN

      --validation when priority value as Org unit
      IF p_usec_wlst_rec.priority_value = 'ORG_UNIT' THEN
	OPEN c_org (p_usec_wlst_rec.preference_code);
	FETCH c_org  INTO c_org_rec;
	IF c_org%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	CLOSE c_org;
      END IF;


      --validation when priority value as Class standing
      IF p_usec_wlst_rec.priority_value = 'CLASS_STD' THEN
	OPEN c_clstd (p_usec_wlst_rec.preference_code);
	FETCH c_clstd  INTO c_clstd_rec;
	IF c_clstd%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	CLOSE c_clstd;
      END IF;

      --Validation  when priority value as Program stage.
      IF p_usec_wlst_rec.priority_value = 'PROGRAM_STAGE' THEN
	OPEN c_pstage (p_usec_wlst_rec.preference_code);
	FETCH c_pstage  INTO c_pstage_rec;
	IF c_pstage%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	CLOSE c_pstage;
      END IF;

      --Validation  when priority value as Program .
      IF p_usec_wlst_rec.priority_value = 'PROGRAM' THEN
	OPEN c_prog (p_usec_wlst_rec.preference_code,p_usec_wlst_rec.preference_version);
	FETCH c_prog  INTO c_prog_rec;
	IF c_prog%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	CLOSE c_prog;
      END IF;

      --Validation  when priority value as UNIT_SET .
      IF p_usec_wlst_rec.priority_value = 'UNIT_SET' THEN
	OPEN c_unit_set (p_usec_wlst_rec.preference_code,p_usec_wlst_rec.preference_version);
	FETCH c_unit_set  INTO c_unit_set_rec;
	IF c_unit_set%NOTFOUND THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'PREFERENCE_CODE', 'LEGACY_TOKENS', FALSE);
	  p_usec_wlst_rec.status := 'E';
	END IF;
	CLOSE c_unit_set;
      END IF;

    END IF;


  END validate_usec_wlstprf;


  --Validations for Unit section waitlist
  PROCEDURE validate_usec_wlstpri(p_usec_wlst_rec IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_rec_type,
                                  p_n_uoo_id      igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
				  p_insert_update VARCHAR2)
  AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:
    Purpose        : Check if Waitlist is allowed and if priority value is 'PERSON_GRP'

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_wlst_allow (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT waitlist_allowed
  FROM   igs_ps_usec_lim_wlst
  WHERE  uoo_id = cp_n_uoo_id;

  c_wlst_allow_rec c_wlst_allow%ROWTYPE;

  CURSOR c_wlst_allow_pat (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT 'X'
  FROM   igs_ps_unit_ofr_pat_all a, igs_ps_unit_ofr_opt_all b
  WHERE  b.uoo_id = cp_n_uoo_id
  AND    a.unit_cd=b.unit_cd
  AND    a.version_number=b.version_number
  AND    a.cal_type=b.cal_type
  AND    a.ci_sequence_number=b.ci_sequence_number
  AND    waitlist_allowed='Y';
  l_c_var     VARCHAR2(1);
  l_c_message VARCHAR2(30);

  BEGIN

    -- Check if unit status is inactive.
    IF NOT igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_wlst_rec.unit_cd,p_usec_wlst_rec.version_number,l_c_message) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
      fnd_msg_pub.add;
      p_usec_wlst_rec.status := 'E';
    END IF;

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_usec_wlst_rec.status := 'E';
    END IF;

    --Waitlist should be allowed at section level if record exists else at pattern level such that priorities and preferences
    --can be imported
    OPEN c_wlst_allow (p_n_uoo_id);
    FETCH c_wlst_allow INTO c_wlst_allow_rec;
    IF c_wlst_allow%FOUND THEN
      IF c_wlst_allow_rec.waitlist_allowed = 'N' THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_WAITLIST_NOT_ALLOWED' );
        fnd_msg_pub.add;
        p_usec_wlst_rec.status := 'E';
      END IF;
    ELSE
      OPEN c_wlst_allow_pat(p_n_uoo_id);
      FETCH c_wlst_allow_pat INTO l_c_var;
      IF c_wlst_allow_pat%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_WAITLIST_NOT_ALLOWED' );
        fnd_msg_pub.add;
        p_usec_wlst_rec.status := 'E';
      END IF;
      CLOSE c_wlst_allow_pat;
    END IF;
    CLOSE c_wlst_allow;

    IF p_insert_update = 'I' THEN
       IF p_usec_wlst_rec.priority_number IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PRIORITY_NUMBER', 'LEGACY_TOKENS', FALSE);
        p_usec_wlst_rec.status := 'E';
      END IF;
    END IF;

  END validate_usec_wlstpri;


END igs_ps_validate_generic_pkg;

/
