--------------------------------------------------------
--  DDL for Package Body IGS_GR_GRADUAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_GRADUAND_PKG" as
/* $Header: IGSGI12B.pls 115.16 2003/10/08 09:10:33 ijeddy ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_GR_GRADUAND_ALL%RowType;
  new_references IGS_GR_GRADUAND_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_create_dt IN DATE ,
    x_grd_cal_type IN VARCHAR2 ,
    x_grd_ci_sequence_number IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_award_course_cd IN VARCHAR2 ,
    x_award_crs_version_number IN NUMBER ,
    x_award_cd IN VARCHAR2 ,
    x_graduand_status IN VARCHAR2 ,
    x_graduand_appr_status IN VARCHAR2 ,
    x_s_graduand_type IN VARCHAR2 ,
    x_graduation_name IN VARCHAR2 ,
    x_proxy_award_ind IN VARCHAR2 ,
    x_proxy_award_person_id IN NUMBER ,
    x_previous_qualifications IN VARCHAR2 ,
    x_convocation_membership_ind IN VARCHAR2 ,
    x_sur_for_course_cd IN VARCHAR2 ,
    x_sur_for_crs_version_number IN NUMBER ,
    x_sur_for_award_cd IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER  ,
    x_org_id IN NUMBER ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.create_dt := x_create_dt;
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.course_cd := x_course_cd;
    new_references.award_course_cd := x_award_course_cd;
    new_references.award_crs_version_number := x_award_crs_version_number;
    new_references.award_cd := x_award_cd;
    new_references.graduand_status := x_graduand_status;
    new_references.graduand_appr_status := x_graduand_appr_status;
    new_references.s_graduand_type := x_s_graduand_type;
    new_references.graduation_name := x_graduation_name;
    new_references.proxy_award_ind := x_proxy_award_ind;
    new_references.proxy_award_person_id := x_proxy_award_person_id;
    new_references.previous_qualifications := x_previous_qualifications;
    new_references.convocation_membership_ind := x_convocation_membership_ind;
    new_references.sur_for_course_cd := x_sur_for_course_cd;
    new_references.sur_for_crs_version_number := x_sur_for_crs_version_number;
    new_references.sur_for_award_cd := x_sur_for_award_cd;
    new_references.comments := x_comments;
    new_references.org_id := x_org_id;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END Set_Column_Values;

  -- Trigger description :-
  -- "OSS_TST".trg_gr_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_GRADUAND_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	IF p_inserting OR p_updating THEN
		-- Validate the graduand record has the required details
		IF IGS_GR_VAL_GR.grdp_val_gr_rqrd(
		                 p_course_cd                   =>   new_references.course_cd,
                                 p_graduand_status             =>   new_references.graduand_status,
                                 p_s_graduand_type             =>   new_references.s_graduand_type,
                                 p_award_course_cd             =>   new_references.award_course_cd,
                                 p_award_crs_version_number    =>   new_references.award_crs_version_number,
                                 p_award_cd                    =>   new_references.award_cd,
                                 p_sur_for_course_cd           =>   new_references.sur_for_course_cd,
                                 p_sur_for_crs_version_number  =>   new_references.sur_for_crs_version_number,
                                 p_sur_for_award_cd            =>   new_references.sur_for_award_cd,
                                 p_message_name                =>   v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
		-- Validate proxy award details
		IF IGS_GR_VAL_GR.grdp_val_gr_proxy(
				new_references.person_id,
				new_references.s_graduand_type,
				new_references.proxy_award_ind,
				new_references.proxy_award_person_id,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
			NVL(new_references.grd_cal_type, 'NULL') <> NVL(old_references.grd_cal_type, 'NULL') OR
			NVL(new_references.grd_ci_sequence_number, 0) <>
			NVL(old_references.grd_ci_sequence_number, 0)) THEN
		-- validate the ceremony round calendar instance
		IF IGS_GR_VAL_GR.grdp_val_gr_crd_ci(
						new_references.grd_cal_type,
  						new_references.grd_ci_sequence_number,
  						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
			new_references.graduand_status <> old_references.graduand_status) THEN
		-- Validate graduand status is not closed
		IF IGS_GR_VAL_GR.grdp_val_gst_closed(
				new_references.graduand_status,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
		-- Validate the graduand status
		IF IGS_GR_VAL_GR.grdp_val_gr_gst(
				new_references.person_id,
				new_references.create_dt,
				new_references.course_cd,
				new_references.graduand_appr_status,
				new_references.s_graduand_type,
				new_references.award_course_cd,
				new_references.award_crs_version_number,
				new_references.award_cd,
				new_references.graduand_status,
				old_references.graduand_status,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
			new_references.graduand_appr_status <> old_references.graduand_appr_status) THEN
		-- Validate graduand approval status is not closed
		IF IGS_GR_VAL_GR.grdp_val_gas_closed(
				new_references.graduand_appr_status,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
		-- Validate the graduand approval status
		IF IGS_GR_VAL_GR.grdp_val_gr_gas(
				new_references.person_id,
				new_references.course_cd,
				new_references.graduand_status,
				new_references.graduand_appr_status,
				old_references.graduand_appr_status,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
			NVL(new_references.course_cd,'NULL') <> NVL(old_references.course_cd,'NULL')) THEN
		IF new_references.course_cd IS NOT NULL THEN
			-- Validate the student course attempt course version graduates students
			IF IGS_GR_VAL_GR.grdp_val_gr_sca(
						new_references.person_id,
						new_references.course_cd,
						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
			(new_references.award_cd <> old_references.award_cd OR
			NVL(new_references.course_cd,'NULL') <> NVL(old_references.course_cd,'NULL'))) THEN
		IF new_references.course_cd IS NOT NULL THEN
			-- COURSE award
			-- Validate the award type
			IF  IGS_GR_VAL_AWC.GRDP_VAL_AWARD_TYPE(
						new_references.award_cd,
						'COURSE',
						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
			END IF;
			-- Validate the graduand course award
			IF IGS_GR_VAL_GR.grdp_val_gr_caw(
					new_references.person_id,
					new_references.course_cd,
					new_references.award_course_cd,
					new_references.award_crs_version_number,
					new_references.award_cd,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
			END IF;
		ELSE
			-- HONORARY award
			-- Validate the award type
			IF  IGS_GR_VAL_AWC.GRDP_VAL_AWARD_TYPE(
						new_references.award_cd,
						'HONORARY',
						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
			END IF;
			-- Validate award is not closed
			IF igs_gr_val_awc.crsp_val_aw_closed(
						new_references.award_cd,
						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
			new_references.s_graduand_type <> old_references.s_graduand_type) THEN
		-- Validate the system graduand type
		IF IGS_GR_VAL_GR.grdp_val_gr_type(
				new_references.person_id,
				new_references.create_dt,
				new_references.course_cd,
				new_references.graduand_status,
				new_references.s_graduand_type,
				old_references.s_graduand_type,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR (p_updating AND
			(new_references.person_id <> old_references.person_id OR
			NVL(new_references.course_cd,'NULL') <> NVL(old_references.course_cd,'NULL') OR
			NVL(new_references.sur_for_course_cd,'NULL') <> NVL(old_references.sur_for_course_cd,'NULL') OR
			NVL(new_references.sur_for_crs_version_number,0) <>
				NVL(old_references.sur_for_crs_version_number,0) OR
			NVL(new_references.sur_for_award_cd,'NULL') <> NVL(old_references.sur_for_award_cd,'NULL'))) THEN
		-- Validate the surrender for details
		IF IGS_GR_VAL_GR.grdp_val_gr_sur_caw(
				new_references.person_id,
				new_references.course_cd,
				new_references.graduand_status,
				new_references.sur_for_course_cd,
				new_references.sur_for_crs_version_number,
				new_references.sur_for_award_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
			IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_gr_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_GR_GRADUAND_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	IF p_inserting OR p_updating THEN
		-- validate graduand award uniqueness
		-- Save the rowid of the current row.
		-- Cannot call grdp_val_gr_unique because trigger
		-- will be mutating.
  			-- validate graduand award uniqueness
  			IF IGS_GR_VAL_GR.grdp_val_gr_unique(
  						new_references.person_id,
  						new_references.create_dt,
  						new_references.grd_cal_type,
  						new_references.grd_ci_sequence_number,
  						new_references.award_course_cd,
  						new_references.award_crs_version_number,
  						new_references.award_cd,
  						v_message_name) = FALSE THEN
 				Fnd_Message.Set_Name('IGS', v_message_name);
 				IGS_GE_MSG_STACK.ADD;
  				App_Exception.Raise_Exception;
  			END IF;
		v_rowid_saved := TRUE;
	END IF;
  END AfterRowInsertUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_gr_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_GR_GRADUAND_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
  BEGIN
	-- create a history
	IGS_GR_GEN_002.GRDP_INS_GR_HIST(
                            p_person_id                             =>  old_references.person_id,
                            p_create_dt                             =>  old_references.create_dt,
                            p_old_grd_cal_type                      =>  old_references.grd_cal_type,
                            p_new_grd_cal_type                      =>  new_references.grd_cal_type,
                            p_old_grd_ci_sequence_number            =>  old_references.grd_ci_sequence_number,
                            p_new_grd_ci_sequence_number            =>  new_references.grd_ci_sequence_number,
                            p_old_course_cd                         =>  old_references.course_cd,
                            p_new_course_cd                         =>  new_references.course_cd,
                            p_old_award_course_cd                   =>  old_references.award_course_cd,
                            p_new_award_course_cd                   =>  new_references.award_course_cd,
                            p_old_award_crs_version_number          =>  old_references.award_crs_version_number,
                            p_new_award_crs_version_number          =>  new_references.award_crs_version_number,
                            p_old_award_cd                          =>  old_references.award_cd,
                            p_new_award_cd                          =>  new_references.award_cd,
                            p_old_graduand_status                   =>  old_references.graduand_status,
                            p_new_graduand_status                   =>  new_references.graduand_status,
                            p_old_graduand_appr_status              =>  old_references.graduand_appr_status,
                            p_new_graduand_appr_status              =>  new_references.graduand_appr_status,
                            p_old_s_graduand_type                   =>  old_references.s_graduand_type,
                            p_new_s_graduand_type                   =>  new_references.s_graduand_type,
                            p_old_graduation_name                   =>  old_references.graduation_name,
                            p_new_graduation_name                   =>  new_references.graduation_name,
                            p_old_proxy_award_ind                   =>  old_references.proxy_award_ind,
                            p_new_proxy_award_ind                   =>  new_references.proxy_award_ind,
                            p_old_proxy_award_person_id             =>  old_references.proxy_award_person_id,
                            p_new_proxy_award_person_id             =>  new_references.proxy_award_person_id,
                            p_old_previous_qualifications           =>  old_references.previous_qualifications,
                            p_new_previous_qualifications           =>  new_references.previous_qualifications,
                            p_old_convocation_memb_ind              =>  old_references.convocation_membership_ind,
                            p_new_convocation_memb_ind              =>  new_references.convocation_membership_ind,
                            p_old_sur_for_course_cd                 =>  old_references.sur_for_course_cd,
                            p_new_sur_for_course_cd                 =>  new_references.sur_for_course_cd,
                            p_old_sur_for_crs_version_numb          =>  old_references.sur_for_crs_version_number,
                            p_new_sur_for_crs_version_numb          =>  new_references.sur_for_crs_version_number,
                            p_old_sur_for_award_cd                  =>  old_references.sur_for_award_cd,
                            p_new_sur_for_award_cd                  =>  new_references.sur_for_award_cd,
                            p_old_update_who                        =>  old_references.last_updated_by,
                            p_new_update_who                        =>  new_references.last_updated_by,
                            p_old_update_on                         =>  old_references.last_update_date,
                            p_new_update_on                         =>  new_references.last_update_date,
                            p_old_comments                          =>  old_references.comments,
                            p_new_comments                          =>  new_references.comments);


  END AfterRowUpdate3;

  PROCEDURE before_insert_update(p_inserting IN BOOLEAN DEFAULT FALSE,
                                 p_updating  IN BOOLEAN DEFAULT FALSE ) AS
    CURSOR c_closed_ind (cp_c_award_cd IN IGS_PS_AWARD.AWARD_CD%TYPE,
                         cp_c_course_cd IN IGS_PS_AWARD.COURSE_CD%TYPE,
                         cp_n_version_num IN IGS_PS_AWARD.VERSION_NUMBER%TYPE) IS
      SELECT CLOSED_IND
      FROM IGS_PS_AWARD
      WHERE AWARD_CD = cp_c_award_cd
      AND   COURSE_CD = cp_c_course_cd
      AND   VERSION_NUMBER = cp_n_version_num;

      l_c_closed_ind VARCHAR2(1);

  BEGIN
      IF p_inserting OR ( p_updating AND new_references.award_cd <> old_references.award_cd ) THEN
         OPEN c_closed_ind(new_references.award_cd,new_references.award_course_cd, new_references.award_crs_version_number);
         FETCH c_closed_ind INTO l_c_closed_ind;
         CLOSE c_closed_ind;
         IF l_c_closed_ind = 'Y' THEN
            fnd_message.set_name('IGS','IGS_PS_AWD_CD_CLOSED');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
         END IF;
      END IF;

      IF p_inserting OR ( p_updating AND new_references.sur_for_award_cd <> old_references.sur_for_award_cd ) THEN
         OPEN c_closed_ind(new_references.sur_for_award_cd, new_references.sur_for_course_cd, new_references.sur_for_crs_version_number);
         FETCH c_closed_ind INTO l_c_closed_ind;
         CLOSE c_closed_ind;
         IF l_c_closed_ind = 'Y' THEN
            fnd_message.set_name('IGS','IGS_PS_AWD_CD_CLOSED');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
         END IF;
      END IF;
  END before_insert_update;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_AWD_PKG.Get_PK_For_Validation (
        new_references.award_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED2');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.award_course_cd = new_references.award_course_cd) AND
         (old_references.award_crs_version_number = new_references.award_crs_version_number) AND
         (old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_course_cd IS NULL) OR
         (new_references.award_crs_version_number IS NULL) OR
         (new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_AWARD_PKG.Get_PK_For_Validation (
        new_references.award_course_cd,
        new_references.award_crs_version_number,
        new_references.award_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED3');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_CRMN_ROUND_PKG.Get_PK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED4');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.graduand_appr_status = new_references.graduand_appr_status)) OR
        ((new_references.graduand_appr_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_APRV_STAT_PKG.Get_PK_For_Validation (
        new_references.graduand_appr_status
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED5');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.graduand_status = new_references.graduand_status)) OR
        ((new_references.graduand_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_STAT_PKG.Get_PK_For_Validation (
        new_references.graduand_status
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED6');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED7');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.proxy_award_person_id = new_references.proxy_award_person_id)) OR
        ((new_references.proxy_award_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.proxy_award_person_id
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED8');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED9');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.sur_for_course_cd = new_references.sur_for_course_cd) AND
         (old_references.sur_for_crs_version_number = new_references.sur_for_crs_version_number) AND
         (old_references.sur_for_award_cd = new_references.sur_for_award_cd)) OR
        ((new_references.sur_for_course_cd IS NULL) OR
         (new_references.sur_for_crs_version_number IS NULL) OR
         (new_references.sur_for_award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_AWARD_PKG.Get_PK_For_Validation (
        new_references.sur_for_course_cd,
        new_references.sur_for_crs_version_number,
        new_references.sur_for_award_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED0');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Uniqueness AS
  BEGIN
	IF Get_UK_For_Validation (
         NEW_REFERENCES.person_id,
         NEW_REFERENCES.create_dt,
         NEW_REFERENCES.award_course_cd,
         NEW_REFERENCES.award_crs_version_number,
         NEW_REFERENCES.award_cd) THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
  END Check_Uniqueness;

  PROCEDURE CHECK_CONSTRAINTS(
	Column_Name IN VARCHAR2 ,
	Column_Value IN VARCHAR2
	) AS
  BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' THEN
  new_references.GRD_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PROXY_AWARD_IND' THEN
  new_references.PROXY_AWARD_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CONVOCATION_MEMBERSHIP_IND' THEN
  new_references.CONVOCATION_MEMBERSHIP_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'S_GRADUAND_TYPE' THEN
  new_references.S_GRADUAND_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'AWARD_CD' THEN
  new_references.AWARD_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'AWARD_COURSE_CD' THEN
  new_references.AWARD_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'COURSE_CD' THEN
  new_references.COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROXY_AWARD_IND' THEN
  new_references.PROXY_AWARD_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SUR_FOR_AWARD_CD' THEN
  new_references.SUR_FOR_AWARD_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SUR_FOR_COURSE_CD' THEN
  new_references.SUR_FOR_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'S_GRADUAND_TYPE' THEN
  new_references.S_GRADUAND_TYPE:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CI_SEQUENCE_NUMBER < 1 OR new_references.GRD_CI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROXY_AWARD_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROXY_AWARD_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CONVOCATION_MEMBERSHIP_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CONVOCATION_MEMBERSHIP_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;

IF upper(Column_name) = 'S_GRADUAND_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_GRADUAND_TYPE not in  ( 'ATTENDING' , 'INABSENTIA' , 'ARTICULATE' , 'DEFERRED' , 'UNKNOWN' , 'DECLINED' ) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;

IF upper(Column_name) = 'AWARD_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_CD<> upper(new_references.AWARD_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'AWARD_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_COURSE_CD<> upper(new_references.AWARD_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


IF upper(Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_CD<> upper(new_references.COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROXY_AWARD_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROXY_AWARD_IND<> upper(new_references.PROXY_AWARD_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SUR_FOR_AWARD_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.SUR_FOR_AWARD_CD<> upper(new_references.SUR_FOR_AWARD_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SUR_FOR_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.SUR_FOR_COURSE_CD<> upper(new_references.SUR_FOR_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'S_GRADUAND_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_GRADUAND_TYPE<> upper(new_references.S_GRADUAND_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
  END CHECK_CONSTRAINTS;



  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_GR_AWD_CRMN_PKG.GET_UFK_IGS_GR_GRADUAND (
      old_references.person_id,
      old_references.create_dt,
	old_references.award_course_cd,
	old_references.award_crs_version_number,
	old_references.award_cd
      );

    IGS_GR_AWD_CRMN_HIST_PKG.GET_FK_IGS_GR_GRADUAND (
      old_references.person_id,
      old_references.create_dt
      );

  END Check_Child_Existance;

  PROCEDURE Check_UK_Child_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.create_dt = new_references.create_dt) AND
	 (old_references.award_course_cd = new_references.award_course_cd) AND
         (old_references.award_crs_version_number = new_references.award_crs_version_number)) AND
	 (old_references.award_cd = new_references.award_cd) OR
        ((old_references.person_id IS NULL) AND
         (old_references.create_dt IS NULL) AND
	 (old_references.award_course_cd IS NULL) AND
         (old_references.award_crs_version_number IS NULL) AND
	 (old_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IGS_GR_AWD_CRMN_PKG.GET_UFK_IGS_GR_GRADUAND(
        old_references.person_id,
	old_references.create_dt,
        old_references.award_course_cd,
	old_references.award_crs_version_number,
	old_references.award_cd
        );
    END IF;
  END Check_UK_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_create_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    person_id = x_person_id
      AND      create_dt = x_create_dt
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    	IF (cur_rowid%FOUND) THEN
		Close cur_rowid;
		Return (TRUE);
	ELSE
		Close cur_rowid;
		Return (FALSE);
	END IF;

  END Get_PK_For_Validation;

  FUNCTION Get_UK_For_Validation (
    x_person_id IN NUMBER,
    x_create_dt IN DATE,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    person_id = x_person_id
      AND      create_dt = x_create_dt
	AND	   award_course_cd = x_award_course_cd
	AND	   award_crs_version_number = x_award_crs_version_number
	AND	   award_cd = x_award_cd
	AND (l_rowid is null or rowid <> l_rowid )
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    	IF (cur_rowid%FOUND) THEN
		Close cur_rowid;
		Return (TRUE);
	ELSE
		Close cur_rowid;
		Return (FALSE);
	END IF;
    Close cur_rowid;

  END Get_UK_For_Validation;

  PROCEDURE GET_FK_IGS_GR_CRMN_ROUND (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GR_CRD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_CRMN_ROUND;

  PROCEDURE GET_FK_IGS_GR_APRV_STAT (
    x_graduand_appr_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    graduand_appr_status = x_graduand_appr_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GR_GAS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_APRV_STAT;

  PROCEDURE GET_FK_IGS_GR_STAT (
    x_graduand_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    graduand_status = x_graduand_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GR_GST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_STAT;

  PROCEDURE GET_FK_IGS_GR_HONOURS_LEVEL (
    x_honours_level IN VARCHAR2
    ) AS
  BEGIN
          NULL;
  END GET_FK_IGS_GR_HONOURS_LEVEL;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    (person_id = x_person_id)
	OR	   (proxy_award_person_id = x_person_id);

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GR_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_GR_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE GET_FK_IGS_EN_SPA_AWD (
          x_person_id IN NUMBER,
          x_course_cd IN VARCHAR2,
          x_award_cd  IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      award_cd  = x_award_cd;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_SPAA_AW_CCD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_SPA_AWD;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_create_dt IN DATE ,
    x_grd_cal_type IN VARCHAR2 ,
    x_grd_ci_sequence_number IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_award_course_cd IN VARCHAR2 ,
    x_award_crs_version_number IN NUMBER ,
    x_award_cd IN VARCHAR2 ,
    x_honours_level IN VARCHAR2 DEFAULT NULL,
    x_conferral_dt IN DATE  DEFAULT NULL,
    x_graduand_status IN VARCHAR2 ,
    x_graduand_appr_status IN VARCHAR2 ,
    x_s_graduand_type IN VARCHAR2 ,
    x_graduation_name IN VARCHAR2 ,
    x_proxy_award_ind IN VARCHAR2 ,
    x_proxy_award_person_id IN NUMBER ,
    x_previous_qualifications IN VARCHAR2 ,
    x_convocation_membership_ind IN VARCHAR2 ,
    x_sur_for_course_cd IN VARCHAR2 ,
    x_sur_for_crs_version_number IN NUMBER ,
    x_sur_for_award_cd IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_create_dt,
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_course_cd,
      x_award_course_cd,
      x_award_crs_version_number,
      x_award_cd,
      x_graduand_status,
      x_graduand_appr_status,
      x_s_graduand_type,
      x_graduation_name,
      x_proxy_award_ind,
      x_proxy_award_person_id,
      x_previous_qualifications,
      x_convocation_membership_ind,
      x_sur_for_course_cd,
      x_sur_for_crs_version_number,
      x_sur_for_award_cd,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE,
      p_updating => FALSE,
      p_deleting => FALSE );
      before_insert_update( p_inserting => TRUE, p_updating => FALSE);
	IF GET_PK_FOR_VALIDATION(
		    NEW_REFERENCES.person_id,
		    NEW_REFERENCES.create_dt
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	check_uniqueness;
	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE ,
      p_inserting => FALSE,
    p_deleting => FALSE);
      before_insert_update( p_inserting => FALSE, p_updating => TRUE);
	check_uniqueness;
	check_constraints;
      Check_Parent_Existance;
      Check_UK_Child_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
		    NEW_REFERENCES.person_id,
		    NEW_REFERENCES.create_dt
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	check_uniqueness;
	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	check_uniqueness;
	check_constraints;
        Check_UK_Child_Existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	check_child_existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE ,
      p_updating => FALSE ,
     p_deleting=>FALSE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE ,
      p_inserting => FALSE ,
      p_deleting =>FALSE );
      AfterRowUpdate3 ( p_updating => TRUE,
      p_inserting =>FALSE,
      p_deleting =>FALSE );
    END IF;

    l_rowid := NULL;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in out NOCOPY DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_GR_GRADUAND_ALL
      where PERSON_ID = X_PERSON_ID
      and CREATE_DT = NEW_REFERENCES.CREATE_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1) then
    	X_REQUEST_ID := NULL;
    	X_PROGRAM_ID := NULL;
    	X_PROGRAM_APPLICATION_ID := NULL;
    	X_PROGRAM_UPDATE_DATE := NULL;
    else
    	X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_create_dt => NVL(X_CREATE_DT, SYSDATE),
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_course_cd => X_COURSE_CD,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_graduand_status => X_GRADUAND_STATUS,
    x_graduand_appr_status => X_GRADUAND_APPR_STATUS,
    x_s_graduand_type => NVL(X_S_GRADUAND_TYPE, 'UNKNOWN'),
    x_graduation_name => X_GRADUATION_NAME,
    x_proxy_award_ind => NVL(X_PROXY_AWARD_IND, 'N'),
    x_proxy_award_person_id => X_PROXY_AWARD_PERSON_ID,
    x_previous_qualifications => X_PREVIOUS_QUALIFICATIONS,
    x_convocation_membership_ind => NVL(X_CONVOCATION_MEMBERSHIP_IND, 'N'),
    x_sur_for_course_cd => X_SUR_FOR_COURSE_CD,
    x_sur_for_crs_version_number => X_SUR_FOR_CRS_VERSION_NUMBER,
    x_sur_for_award_cd => X_SUR_FOR_AWARD_CD,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
     x_org_id => igs_ge_gen_003.get_org_id,
     x_attribute_category=>X_ATTRIBUTE_CATEGORY,
     x_attribute1=>X_ATTRIBUTE1,
     x_attribute2=>X_ATTRIBUTE2,
     x_attribute3=>X_ATTRIBUTE3,
     x_attribute4=>X_ATTRIBUTE4,
     x_attribute5=>X_ATTRIBUTE5,
     x_attribute6=>X_ATTRIBUTE6,
     x_attribute7=>X_ATTRIBUTE7,
     x_attribute8=>X_ATTRIBUTE8,
     x_attribute9=>X_ATTRIBUTE9,
     x_attribute10=>X_ATTRIBUTE10,
     x_attribute11=>X_ATTRIBUTE11,
     x_attribute12=>X_ATTRIBUTE12,
     x_attribute13=>X_ATTRIBUTE13,
     x_attribute14=>X_ATTRIBUTE14,
     x_attribute15=>X_ATTRIBUTE15,
     x_attribute16=>X_ATTRIBUTE16,
     x_attribute17=>X_ATTRIBUTE17,
     x_attribute18=>X_ATTRIBUTE18,
     x_attribute19=>X_ATTRIBUTE19,
     x_attribute20=>X_ATTRIBUTE20
  );

  insert into IGS_GR_GRADUAND_ALL (
    PERSON_ID,
    CREATE_DT,
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    COURSE_CD,
    AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER,
    AWARD_CD,
    GRADUAND_STATUS,
    GRADUAND_APPR_STATUS,
    S_GRADUAND_TYPE,
    GRADUATION_NAME,
    PROXY_AWARD_IND,
    PROXY_AWARD_PERSON_ID,
    PREVIOUS_QUALIFICATIONS,
    CONVOCATION_MEMBERSHIP_IND,
    SUR_FOR_COURSE_CD,
    SUR_FOR_CRS_VERSION_NUMBER,
    SUR_FOR_AWARD_CD,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    ORG_ID,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.AWARD_COURSE_CD,
    NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.GRADUAND_STATUS,
    NEW_REFERENCES.GRADUAND_APPR_STATUS,
    NEW_REFERENCES.S_GRADUAND_TYPE,
    NEW_REFERENCES.GRADUATION_NAME,
    NEW_REFERENCES.PROXY_AWARD_IND,
    NEW_REFERENCES.PROXY_AWARD_PERSON_ID,
    NEW_REFERENCES.PREVIOUS_QUALIFICATIONS,
    NEW_REFERENCES.CONVOCATION_MEMBERSHIP_IND,
    NEW_REFERENCES.SUR_FOR_COURSE_CD,
    NEW_REFERENCES.SUR_FOR_CRS_VERSION_NUMBER,
    NEW_REFERENCES.SUR_FOR_AWARD_CD,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    NEW_REFERENCES.ATTRIBUTE1,
    NEW_REFERENCES.ATTRIBUTE2,
    NEW_REFERENCES.ATTRIBUTE3,
    NEW_REFERENCES.ATTRIBUTE4,
    NEW_REFERENCES.ATTRIBUTE5,
    NEW_REFERENCES.ATTRIBUTE6,
    NEW_REFERENCES.ATTRIBUTE7,
    NEW_REFERENCES.ATTRIBUTE8,
    NEW_REFERENCES.ATTRIBUTE9,
    NEW_REFERENCES.ATTRIBUTE10,
    NEW_REFERENCES.ATTRIBUTE11,
    NEW_REFERENCES.ATTRIBUTE12,
    NEW_REFERENCES.ATTRIBUTE13,
    NEW_REFERENCES.ATTRIBUTE14,
    NEW_REFERENCES.ATTRIBUTE15,
    NEW_REFERENCES.ATTRIBUTE16,
    NEW_REFERENCES.ATTRIBUTE17,
    NEW_REFERENCES.ATTRIBUTE18,
    NEW_REFERENCES.ATTRIBUTE19,
    NEW_REFERENCES.ATTRIBUTE20
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  After_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID
    );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2
) AS
  cursor c1 is select
      GRD_CAL_TYPE,
      GRD_CI_SEQUENCE_NUMBER,
      COURSE_CD,
      AWARD_COURSE_CD,
      AWARD_CRS_VERSION_NUMBER,
      AWARD_CD,
      GRADUAND_STATUS,
      GRADUAND_APPR_STATUS,
      S_GRADUAND_TYPE,
      GRADUATION_NAME,
      PROXY_AWARD_IND,
      PROXY_AWARD_PERSON_ID,
      PREVIOUS_QUALIFICATIONS,
      CONVOCATION_MEMBERSHIP_IND,
      SUR_FOR_COURSE_CD,
      SUR_FOR_CRS_VERSION_NUMBER,
      SUR_FOR_AWARD_CD,
      COMMENTS,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20
    from IGS_GR_GRADUAND_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED11');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.GRD_CAL_TYPE = X_GRD_CAL_TYPE)
      AND (tlinfo.GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER)
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.AWARD_COURSE_CD = X_AWARD_COURSE_CD)
           OR ((tlinfo.AWARD_COURSE_CD is null)
               AND (X_AWARD_COURSE_CD is null)))
      AND ((tlinfo.AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER)
           OR ((tlinfo.AWARD_CRS_VERSION_NUMBER is null)
               AND (X_AWARD_CRS_VERSION_NUMBER is null)))
      AND (tlinfo.AWARD_CD = X_AWARD_CD)
      AND (tlinfo.GRADUAND_STATUS = X_GRADUAND_STATUS)
      AND (tlinfo.GRADUAND_APPR_STATUS = X_GRADUAND_APPR_STATUS)
      AND (tlinfo.S_GRADUAND_TYPE = X_S_GRADUAND_TYPE)
      AND (tlinfo.GRADUATION_NAME = X_GRADUATION_NAME)
      AND (tlinfo.PROXY_AWARD_IND = X_PROXY_AWARD_IND)
      AND ((tlinfo.PROXY_AWARD_PERSON_ID = X_PROXY_AWARD_PERSON_ID)
           OR ((tlinfo.PROXY_AWARD_PERSON_ID is null)
               AND (X_PROXY_AWARD_PERSON_ID is null)))
      AND ((tlinfo.PREVIOUS_QUALIFICATIONS = X_PREVIOUS_QUALIFICATIONS)
           OR ((tlinfo.PREVIOUS_QUALIFICATIONS is null)
               AND (X_PREVIOUS_QUALIFICATIONS is null)))
      AND (tlinfo.CONVOCATION_MEMBERSHIP_IND = X_CONVOCATION_MEMBERSHIP_IND)
      AND ((tlinfo.SUR_FOR_COURSE_CD = X_SUR_FOR_COURSE_CD)
           OR ((tlinfo.SUR_FOR_COURSE_CD is null)
               AND (X_SUR_FOR_COURSE_CD is null)))
      AND ((tlinfo.SUR_FOR_CRS_VERSION_NUMBER = X_SUR_FOR_CRS_VERSION_NUMBER)
           OR ((tlinfo.SUR_FOR_CRS_VERSION_NUMBER is null)
               AND (X_SUR_FOR_CRS_VERSION_NUMBER is null)))
      AND ((tlinfo.SUR_FOR_AWARD_CD = X_SUR_FOR_AWARD_CD)
           OR ((tlinfo.SUR_FOR_AWARD_CD is null)
               AND (X_SUR_FOR_AWARD_CD is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL)
               AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 IS NULL)
               AND (X_ATTRIBUTE1 IS NULL)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 IS NULL)
               AND (X_ATTRIBUTE2 IS NULL)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 IS NULL)
               AND (X_ATTRIBUTE3 IS NULL)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 IS NULL)
               AND (X_ATTRIBUTE4 IS NULL)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 IS NULL)
               AND (X_ATTRIBUTE5 IS NULL)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 IS NULL)
               AND (X_ATTRIBUTE6 IS NULL)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 IS NULL)
               AND (X_ATTRIBUTE7 IS NULL)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 IS NULL)
               AND (X_ATTRIBUTE8 IS NULL)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 IS NULL)
               AND (X_ATTRIBUTE9 IS NULL)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 IS NULL)
               AND (X_ATTRIBUTE10 IS NULL)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 IS NULL)
               AND (X_ATTRIBUTE11 IS NULL)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 IS NULL)
               AND (X_ATTRIBUTE12 IS NULL)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 IS NULL)
               AND (X_ATTRIBUTE13 IS NULL)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 IS NULL)
               AND (X_ATTRIBUTE14 IS NULL)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 IS NULL)
               AND (X_ATTRIBUTE15 IS NULL)))
      AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((tlinfo.ATTRIBUTE16 IS NULL)
               AND (X_ATTRIBUTE16 IS NULL)))
      AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((tlinfo.ATTRIBUTE17 IS NULL)
               AND (X_ATTRIBUTE17 IS NULL)))
      AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((tlinfo.ATTRIBUTE18 IS NULL)
               AND (X_ATTRIBUTE18 IS NULL)))
      AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((tlinfo.ATTRIBUTE19 IS NULL)
               AND (X_ATTRIBUTE19 IS NULL)))
      AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
      OR ((tlinfo.ATTRIBUTE20 IS NULL)
      AND (X_ATTRIBUTE20 IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_create_dt => X_CREATE_DT,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_course_cd => X_COURSE_CD,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_graduand_status => X_GRADUAND_STATUS,
    x_graduand_appr_status => X_GRADUAND_APPR_STATUS,
    x_s_graduand_type => X_S_GRADUAND_TYPE,
    x_graduation_name => X_GRADUATION_NAME,
    x_proxy_award_ind => X_PROXY_AWARD_IND,
    x_proxy_award_person_id => X_PROXY_AWARD_PERSON_ID,
    x_previous_qualifications => X_PREVIOUS_QUALIFICATIONS,
    x_convocation_membership_ind => X_CONVOCATION_MEMBERSHIP_IND,
    x_sur_for_course_cd => X_SUR_FOR_COURSE_CD,
    x_sur_for_crs_version_number => X_SUR_FOR_CRS_VERSION_NUMBER,
    x_sur_for_award_cd => X_SUR_FOR_AWARD_CD,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
     x_attribute_category=>X_ATTRIBUTE_CATEGORY,
     x_attribute1=>X_ATTRIBUTE1,
     x_attribute2=>X_ATTRIBUTE2,
     x_attribute3=>X_ATTRIBUTE3,
     x_attribute4=>X_ATTRIBUTE4,
     x_attribute5=>X_ATTRIBUTE5,
     x_attribute6=>X_ATTRIBUTE6,
     x_attribute7=>X_ATTRIBUTE7,
     x_attribute8=>X_ATTRIBUTE8,
     x_attribute9=>X_ATTRIBUTE9,
     x_attribute10=>X_ATTRIBUTE10,
     x_attribute11=>X_ATTRIBUTE11,
     x_attribute12=>X_ATTRIBUTE12,
     x_attribute13=>X_ATTRIBUTE13,
     x_attribute14=>X_ATTRIBUTE14,
     x_attribute15=>X_ATTRIBUTE15,
     x_attribute16=>X_ATTRIBUTE16,
     x_attribute17=>X_ATTRIBUTE17,
     x_attribute18=>X_ATTRIBUTE18,
     x_attribute19=>X_ATTRIBUTE19,
     x_attribute20=>X_ATTRIBUTE20
     );

  if (X_MODE = 'R') then
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID = -1) then
    	X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
    	X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
    	X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
    	X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
    	X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  end if;
  update IGS_GR_GRADUAND_ALL set
    GRD_CAL_TYPE = NEW_REFERENCES.GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    AWARD_COURSE_CD = NEW_REFERENCES.AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER = NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    AWARD_CD = NEW_REFERENCES.AWARD_CD,
    GRADUAND_STATUS = NEW_REFERENCES.GRADUAND_STATUS,
    GRADUAND_APPR_STATUS = NEW_REFERENCES.GRADUAND_APPR_STATUS,
    S_GRADUAND_TYPE = NEW_REFERENCES.S_GRADUAND_TYPE,
    GRADUATION_NAME = NEW_REFERENCES.GRADUATION_NAME,
    PROXY_AWARD_IND = NEW_REFERENCES.PROXY_AWARD_IND,
    PROXY_AWARD_PERSON_ID = NEW_REFERENCES.PROXY_AWARD_PERSON_ID,
    PREVIOUS_QUALIFICATIONS = NEW_REFERENCES.PREVIOUS_QUALIFICATIONS,
    CONVOCATION_MEMBERSHIP_IND = NEW_REFERENCES.CONVOCATION_MEMBERSHIP_IND,
    SUR_FOR_COURSE_CD = NEW_REFERENCES.SUR_FOR_COURSE_CD,
    SUR_FOR_CRS_VERSION_NUMBER = NEW_REFERENCES.SUR_FOR_CRS_VERSION_NUMBER,
    SUR_FOR_AWARD_CD = NEW_REFERENCES.SUR_FOR_AWARD_CD,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
    );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in out NOCOPY DATE,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_GR_GRADUAND_ALL
     where PERSON_ID = X_PERSON_ID
     and CREATE_DT = NVL(X_CREATE_DT, SYSDATE)
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_CREATE_DT,
     X_GRD_CAL_TYPE,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_COURSE_CD,
     X_AWARD_COURSE_CD,
     X_AWARD_CRS_VERSION_NUMBER,
     X_AWARD_CD,
     null,
     null,
     X_GRADUAND_STATUS,
     X_GRADUAND_APPR_STATUS,
     X_S_GRADUAND_TYPE,
     X_GRADUATION_NAME,
     X_PROXY_AWARD_IND,
     X_PROXY_AWARD_PERSON_ID,
     X_PREVIOUS_QUALIFICATIONS,
     X_CONVOCATION_MEMBERSHIP_IND,
     X_SUR_FOR_COURSE_CD,
     X_SUR_FOR_CRS_VERSION_NUMBER,
     X_SUR_FOR_AWARD_CD,
     X_COMMENTS,
     X_MODE,
     x_org_id,
     X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_ATTRIBUTE16,
     X_ATTRIBUTE17,
     X_ATTRIBUTE18,
     X_ATTRIBUTE19,
     X_ATTRIBUTE20
);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CREATE_DT,
   X_GRD_CAL_TYPE,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_COURSE_CD,
   X_AWARD_COURSE_CD,
   X_AWARD_CRS_VERSION_NUMBER,
   X_AWARD_CD,
   null,
   null,
   X_GRADUAND_STATUS,
   X_GRADUAND_APPR_STATUS,
   X_S_GRADUAND_TYPE,
   X_GRADUATION_NAME,
   X_PROXY_AWARD_IND,
   X_PROXY_AWARD_PERSON_ID,
   X_PREVIOUS_QUALIFICATIONS,
   X_CONVOCATION_MEMBERSHIP_IND,
   X_SUR_FOR_COURSE_CD,
   X_SUR_FOR_CRS_VERSION_NUMBER,
   X_SUR_FOR_AWARD_CD,
   X_COMMENTS,
   X_MODE,
   X_ATTRIBUTE_CATEGORY,
   X_ATTRIBUTE1,
   X_ATTRIBUTE2,
   X_ATTRIBUTE3,
   X_ATTRIBUTE4,
   X_ATTRIBUTE5,
   X_ATTRIBUTE6,
   X_ATTRIBUTE7,
   X_ATTRIBUTE8,
   X_ATTRIBUTE9,
   X_ATTRIBUTE10,
   X_ATTRIBUTE11,
   X_ATTRIBUTE12,
   X_ATTRIBUTE13,
   X_ATTRIBUTE14,
   X_ATTRIBUTE15,
   X_ATTRIBUTE16,
   X_ATTRIBUTE17,
   X_ATTRIBUTE18,
   X_ATTRIBUTE19,
   X_ATTRIBUTE20
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

 Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );

  delete from IGS_GR_GRADUAND_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_GR_GRADUAND_PKG;

/
