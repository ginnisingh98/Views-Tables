--------------------------------------------------------
--  DDL for Package Body IGS_EN_UNIT_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_UNIT_SET_PKG" as
/* $Header: IGSEI01B.pls 120.1 2006/02/16 04:04:49 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_UNIT_SET_ALL%RowType;
  new_references IGS_EN_UNIT_SET_ALL%RowType;

  PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
    --Created by  : smvk, Oracle India
    --Date created: 03-Jan-2003
    --
    --Purpose: Only planned unit set status are allowed for deletion
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------
    CURSOR cur_delete (cp_c_unit_set_cd igs_en_unit_set_all.unit_set_cd%TYPE,
                       cp_n_version_number igs_en_unit_set_all.version_number%TYPE)
    IS
    SELECT 'x'
      FROM     igs_en_unit_set_all usv,
               igs_en_unit_set_stat uss
      WHERE    usv.unit_set_status = uss.unit_set_status
      AND      uss.s_unit_set_status = 'PLANNED'
      AND      usv.unit_set_cd = cp_c_unit_set_cd
      AND      usv.version_number = cp_n_version_number;

     l_check VARCHAR2(1);

  BEGIN
    -- Only planned unit status are allowed for deletion
    OPEN  cur_delete (old_references.unit_set_cd,old_references.version_number);
    FETCH cur_delete INTO l_check;
    IF cur_delete%NOTFOUND THEN
      CLOSE cur_delete;
      fnd_message.set_name('IGS','IGS_PS_UNIT_SET_NO_DEL_ALLOWED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    CLOSE cur_delete;
  END beforerowdelete;

  PROCEDURE beforerowupdate AS
    ------------------------------------------------------------------
    --Created by  : smvk, Oracle India
    --Date created: 03-Jan-2003
    --
    --Purpose: Active/Inactive Unit Set Status can not be changed to Planned Status
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------
    CURSOR cur_get_status (cp_c_unit_set_status igs_en_unit_set_stat.unit_set_status%TYPE)
    IS
      SELECT s_unit_set_status
      FROM   igs_en_unit_set_stat
      WHERE  unit_set_status = cp_c_unit_set_status;

    l_c_sys_status igs_en_unit_set_stat.s_unit_set_status%TYPE;

    CURSOR cur_check_update (cp_c_unit_set_cd igs_en_unit_set_all.unit_set_cd%TYPE,
                             cp_n_version_number igs_en_unit_set_all.version_number%TYPE)
    IS
      SELECT 'x'
      FROM     igs_en_unit_set_all usv,
               igs_en_unit_set_stat  uss
      WHERE    usv.unit_set_status=uss.unit_set_status
      AND      uss.s_unit_set_status <> 'PLANNED'
      AND      usv.unit_set_cd = cp_c_unit_set_cd
      AND      usv.version_number = cp_n_version_number;

          l_check VARCHAR2(1);
  BEGIN
    -- Active/Inactive unit Status can not be changed to Planned Status
    OPEN cur_get_status(new_references.unit_set_status);
    FETCH cur_get_status INTO l_c_sys_status;
    IF cur_get_status%FOUND THEN
      CLOSE cur_get_status;
      IF (l_c_sys_status = 'PLANNED') THEN
        OPEN cur_check_update(old_references.unit_set_cd,old_references.version_number);
        FETCH cur_check_update INTO l_check;
        IF cur_check_update%FOUND THEN
          CLOSE cur_check_update;
          fnd_message.set_name('IGS','IGS_PS_UNIT_SET_STATUS_NOTALT');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
        CLOSE cur_check_update;
      END IF;
    ELSE
      -- If the unit set status is not found then the record might have been deleted
      CLOSE cur_get_status;
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END beforerowupdate;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_unit_set_status IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_review_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_short_title IN VARCHAR2 DEFAULT NULL,
    x_abbreviation IN VARCHAR2 DEFAULT NULL,
    x_responsible_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_responsible_ou_start_dt IN DATE DEFAULT NULL,
    x_administrative_ind IN VARCHAR2 DEFAULT NULL,
    x_authorisation_rqrd_ind IN VARCHAR2 DEFAULT NULL,
    x_attribute_category in VARCHAR2 DEFAULT NULL,
    x_attribute1 in VARCHAR2 DEFAULT NULL,
    x_attribute2 in VARCHAR2 DEFAULT NULL,
    x_attribute3 in VARCHAR2 DEFAULT NULL,
    x_attribute4 in VARCHAR2 DEFAULT NULL,
    x_attribute5 in VARCHAR2 DEFAULT NULL,
    x_attribute6 in VARCHAR2 DEFAULT NULL,
    x_attribute7 in VARCHAR2 DEFAULT NULL,
    x_attribute8 in VARCHAR2 DEFAULT NULL,
    x_attribute9 in VARCHAR2 DEFAULT NULL,
    x_attribute10 in VARCHAR2 DEFAULT NULL,
    x_attribute11 in VARCHAR2 DEFAULT NULL,
    x_attribute12 in VARCHAR2 DEFAULT NULL,
    x_attribute13 in VARCHAR2 DEFAULT NULL,
    x_attribute14 in VARCHAR2 DEFAULT NULL,
    x_attribute15 in VARCHAR2 DEFAULT NULL,
    x_attribute16 in VARCHAR2 DEFAULT NULL,
    x_attribute17 in VARCHAR2 DEFAULT NULL,
    x_attribute18 in VARCHAR2 DEFAULT NULL,
    x_attribute19 in VARCHAR2 DEFAULT NULL,
    x_attribute20 in VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_UNIT_SET_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.version_number := x_version_number;
    new_references.unit_set_status := x_unit_set_status;
    new_references.unit_set_cat := x_unit_set_cat;
    new_references.start_dt := x_start_dt;
    new_references.review_dt := x_review_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.end_dt := x_end_dt;
    new_references.title := x_title;
    new_references.short_title := x_short_title;
    new_references.abbreviation := x_abbreviation;
    new_references.responsible_org_unit_cd := x_responsible_org_unit_cd;
    new_references.responsible_ou_start_dt := x_responsible_ou_start_dt;
    new_references.administrative_ind := x_administrative_ind;
    new_references.authorisation_rqrd_ind := x_authorisation_rqrd_ind;
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
    new_references.org_id  := x_org_id;
  END Set_Column_Values;


  -- Trigger description :-
  -- "OSS_TST".trg_us_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_EN_UNIT_SET_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as

      v_message_name  varchar2(30);

  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting THEN
		-- <us1>
		-- Org UNIT inactive validation
		-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_US.crsp_val_ou_sys_sts
		IF  IGS_PS_VAL_CRV.crsp_val_ou_sys_sts (
						new_references.responsible_org_unit_cd,
						new_references.responsible_ou_start_dt,
						v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
		-- <us2>
		-- UNIT set status closed validation
		IF  IGS_PS_VAL_US.crsp_val_uss_closed (
						new_references.unit_set_status,
						v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
		-- <us2a>
		-- UNIT set category closed validation
		IF  IGS_PS_VAL_US.crsp_val_usc_closed (
						new_references.UNIT_SET_CAT,
						v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
		-- <us3>, <us4>, <us5>
		-- Start/Expiry/End date validations
		IF  IGS_PS_VAL_US.crsp_val_ver_dt (
						new_references.start_dt,
						new_references.end_dt,
						new_references.expiry_dt,
						v_message_name,FALSE) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
		-- <us7>
		-- End date/UNIT set status cross-field validation
		IF  IGS_PS_VAL_US.crsp_val_us_end_sts (
						new_references.end_dt,
						new_references.unit_set_status,
						v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
		-- <us8>
		-- Validate end date/UNIT set status when there are active students
		IF  new_references.end_dt IS NOT NULL or
				IGS_PS_GEN_006.CRSP_GET_US_SYS_STS (new_references.unit_set_status) = 'INACTIVE' THEN
			IF  IGS_PS_VAL_US.crsp_val_us_enr (
							new_references.unit_set_cd,
							new_references.version_number,
							v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- <us9>
		-- Validate UNIT set status changes
		IF  IGS_PS_VAL_US.crsp_val_us_status (
						old_references.unit_set_status,
						new_references.unit_set_status,
						v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
		-- <us11a>
		-- Validate details can not be altered when INACTIVE unless
		-- changing back to ACTIVE
		--smaddali changed the parameters passed to this call for bug#2182746
		-- as the parameters were passed wrong
		IF  IGS_PS_VAL_COUSR.crsp_val_iud_us_dtl (
						new_references.unit_set_cd,
						new_references.version_number,
						v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_us_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_EN_UNIT_SET_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
      v_message_name  varchar2(30);
  BEGIN
	IF  IGS_PS_VAL_US.crsp_val_us_exp_sts (
				New_References.unit_set_cd,
				New_References.version_number,
				New_References.unit_set_status,
				New_References.expiry_dt,
  				v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
  	END IF;

  END AfterRowInsertUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_us_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_EN_UNIT_SET_ALL
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
      v_message_name  varchar2(30);
  BEGIN
	IF p_updating THEN
		-- Create IGS_EN_UNIT_SET_ALL history record.
		IGS_PS_GEN_006.CRSP_INS_US_HIST (
			new_references.unit_set_cd,
			new_references.version_number,
			new_references.unit_set_status,
			old_references.unit_set_status,
			new_references.unit_set_cat,
			old_references.unit_set_cat,
			new_references.start_dt,
			old_references.start_dt,
			new_references.review_dt,
			old_references.review_dt,
			new_references.expiry_dt,
			old_references.expiry_dt,
			new_references.end_dt,
			old_references.end_dt,
			new_references.title,
			old_references.title,
			new_references.short_title,
			old_references.short_title,
			new_references.abbreviation,
			old_references.abbreviation,
			new_references.responsible_org_unit_cd,
			old_references.responsible_org_unit_cd,
			new_references.responsible_ou_start_dt,
			old_references.responsible_ou_start_dt,
			new_references.administrative_ind,
			old_references.administrative_ind,
			new_references.authorisation_rqrd_ind,
			old_references.authorisation_rqrd_ind,
			new_references.last_updated_by,
			old_references.last_updated_by,
			new_references.last_update_date,
			old_references.last_update_date);
	END IF;


  END AfterRowUpdate3;


 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF UPPER(column_name) = 'ADMINISTRATIVE_IND' THEN
	 new_references.administrative_ind := column_value;
    ELSIF  UPPER(column_name) = 'VERSION_NUMBER' THEN
        new_references.version_number := IGS_GE_NUMBER.TO_NUM(column_value);
    ELSIF  UPPER(column_name) = 'AUTHORISATION_RQRD_IND' THEN
        new_references.authorisation_rqrd_ind := column_value;
    ELSIF  UPPER(column_name) = 'ABBREVIATION' THEN
        new_references.abbreviation := column_value;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CAT' THEN
        new_references.UNIT_SET_CAT := column_value;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CD' THEN
        new_references.unit_set_cd := column_value;
    ELSIF  UPPER(column_name) = 'UNIT_SET_STATUS' THEN
        new_references.UNIT_SET_STATUS := column_value;
    END IF;



    IF ((UPPER (column_name) = 'ADMINISTRATIVE_IND') OR (column_name IS NULL)) THEN
      IF new_references.administrative_ind NOT IN ('Y' , 'N' )  THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
        	App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'VERSION_NUMBER') OR (column_name IS NULL)) THEN
      IF new_references.version_number < 1 OR
         new_references.version_number > 999  THEN
        	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
        	App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'AUTHORISATION_RQRD_IND') OR (column_name IS NULL)) THEN
      IF (new_references.authorisation_rqrd_ind <> UPPER (new_references.authorisation_rqrd_ind))  THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
        	App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'ABBREVIATION') OR (column_name IS NULL)) THEN
      IF (new_references.abbreviation <> UPPER (new_references.abbreviation)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'UNIT_SET_CAT') OR (column_name IS NULL)) THEN
      IF (new_references.UNIT_SET_CAT <> UPPER (new_references.UNIT_SET_CAT)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF ((UPPER (column_name) = 'UNIT_SET_CD') OR (column_name IS NULL)) THEN
      IF (new_references.unit_set_cd <> UPPER (new_references.unit_set_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'UNIT_SET_STATUS') OR (column_name IS NULL)) THEN
      IF (new_references.UNIT_SET_STATUS <> UPPER (new_references.UNIT_SET_STATUS)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.responsible_org_unit_cd = new_references.responsible_org_unit_cd) AND
         (old_references.responsible_ou_start_dt = new_references.responsible_ou_start_dt)) OR
        ((new_references.responsible_org_unit_cd IS NULL) OR
         (new_references.responsible_ou_start_dt IS NULL))) THEN
      NULL;
    ELSE

      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.responsible_org_unit_cd,
        new_references.responsible_ou_start_dt
        ) THEN

	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;

    END IF;

    IF (((old_references.UNIT_SET_CAT = new_references.UNIT_SET_CAT)) OR
        ((new_references.UNIT_SET_CAT IS NULL))) THEN
      NULL;
    ELSE

       IF NOT IGS_EN_UNIT_SET_CAT_PKG.Get_PK_For_Validation (
        new_references.UNIT_SET_CAT
        )  THEN

	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;

    END IF;

    IF (((old_references.UNIT_SET_STATUS = new_references.UNIT_SET_STATUS)) OR
        ((new_references.UNIT_SET_STATUS IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_UNIT_SET_STAT_PKG.Get_PK_For_Validation (
        new_references.UNIT_SET_STATUS
        ) THEN

	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance  as

   /* Who	When		What
      pathipat  17-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
                                Added call to igs_fi_fee_as_rate_pkg.get_fk_igs_en_unit_set_all
                                and igs_fi_fee_as_items_pkg.get_fk_igs_en_unit_set_all
    sbaliga    9-May-2002    Added 2 more calls to check for child existence
    				as part of #2330002
    myoganat   06-Jun-2003   Added IGS_EN_UNIT_SET_MAP_PKG.get_fk_igs_en_unit_set
				as part of #2829265
    */

  BEGIN

    IGS_AD_UNIT_SETS_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_GR_AWD_CRM_UT_ST_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_PS_COO_AD_UNIT_S_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_PS_ENT_PT_REF_CD_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_PS_OFR_UNIT_SET_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_PE_UNT_SET_EXCL_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_PR_OU_UNIT_SET_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_AD_SBM_PS_FNTRGT_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_PR_SDT_PR_UNT_ST_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_AS_SU_SETATMPT_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_EN_UNITSETPSTYPE_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_EN_UNITSETFEETRG_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_EN_UNIT_SET_NOTE_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

    IGS_EN_UNIT_SET_RULE_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );
    IGS_PS_RSV_ORGUN_PRF_PKG.GET_FK_IGS_EN_UNIT_SET_ALL(
        old_references.unit_set_cd,
        old_references.version_number);
    IGS_PS_RSV_UOP_PRF_PKG.GET_FK_IGS_EN_UNIT_SET_ALL(
        old_references.unit_set_cd,
        old_references.version_number);
    IGS_PS_RSV_USEC_PRF_PKG.GET_FK_IGS_EN_UNIT_SET_ALL(
        old_references.unit_set_cd,
        old_references.version_number);

    IGS_AS_GPC_UNIT_SETS_PKG.GET_FK_IGS_EN_UNIT_SET(
        old_references.unit_set_cd,
        old_references.version_number);

     --This call was added by sbaliga as part of #2330002
     IGS_HE_POOUS_OU_ALL_PKG.GET_FK_IGS_EN_UNIT_SET_ALL(
     old_references.unit_set_cd,
     old_references.version_number
     );


      -- Added the following check chaild existance for the HESA requirment, pmarada
       IGS_HE_POOUS_ALL_PKG.GET_FK_IGS_EN_UNIT_SET_ALL(
       old_references.unit_set_cd,
       old_references.version_number);

    -- Enh bug#2833852
    -- Added the following call for implementing the foreign key constraint.
    IGS_PS_US_FLD_STUDY_PKG.GET_FK_IGS_EN_UNIT_SET (
      old_references.unit_set_cd,
      old_references.version_number
      );

     IGS_EN_UNIT_SET_MAP_PKG.get_fk_igs_en_unit_set (
     old_references.unit_set_cd,
     old_references.version_number
     );

    igs_fi_fee_as_rate_pkg.get_fk_igs_en_unit_set_all(
      old_references.unit_set_cd,
      old_references.version_number
      );

    igs_fi_fee_as_items_pkg.get_fk_igs_en_unit_set_all(
      old_references.unit_set_cd,
      old_references.version_number
      );


  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    )  RETURN BOOLEAN as

    -- As a part of fixing the Bug # 2729917 to resolve locking issue.
    -- Need to lock the Unit Set table only when the system status of the unit set status is 'PLANNED'
    -- For other system statuses we are not allowing the user to delete the record.

    CURSOR cur_get_status IS
        SELECT   uss.s_unit_set_status
        FROM     igs_en_unit_set_all usv,
                 igs_en_unit_set_stat uss
        WHERE    usv.unit_set_status = uss.unit_set_status
        AND      usv.unit_set_cd = x_unit_set_cd
        AND      usv.version_number = x_version_number;

    l_c_unit_set_status igs_en_unit_set_stat.s_unit_set_status%TYPE;

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_ALL
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN  cur_get_status;
    FETCH cur_get_status INTO l_c_unit_set_status;
    IF cur_get_status%FOUND THEN
      CLOSE cur_get_status;
      IF l_c_unit_set_status = 'PLANNED' THEN
        OPEN cur_rowid;
        FETCH cur_rowid INTO lv_rowid;
        IF (cur_rowid%FOUND) THEN
          CLOSE cur_rowid;
          RETURN TRUE;
        ELSE
          CLOSE cur_rowid;
          RETURN FALSE;
        END IF;
      ELSE
        RETURN TRUE;
      END IF;
    ELSE
      CLOSE cur_get_status;
      RETURN FALSE;
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    )  as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_ALL
      WHERE    responsible_org_unit_cd = x_org_unit_cd
      AND      responsible_ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_US_OU_FK');
		IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET_CAT (
    x_unit_set_cat IN VARCHAR2
    )  as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_ALL
      WHERE    UNIT_SET_CAT = x_unit_set_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_US_USC_FK');
	IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_UNIT_SET_CAT;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET_STAT (
    x_unit_set_status IN VARCHAR2
    )  as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNIT_SET_ALL
      WHERE    UNIT_SET_STATUS = x_unit_set_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_US_USS_FK');
	IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_UNIT_SET_STAT;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_unit_set_status IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cat IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_review_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_short_title IN VARCHAR2 DEFAULT NULL,
    x_abbreviation IN VARCHAR2 DEFAULT NULL,
    x_responsible_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_responsible_ou_start_dt IN DATE DEFAULT NULL,
    x_administrative_ind IN VARCHAR2 DEFAULT NULL,
    x_authorisation_rqrd_ind IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 in VARCHAR2 DEFAULT NULL,
    x_attribute17 in VARCHAR2 DEFAULT NULL,
    x_attribute18 in VARCHAR2 DEFAULT NULL,
    x_attribute19 in VARCHAR2 DEFAULT NULL,
    x_attribute20 in VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER
  )  as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_set_cd,
      x_version_number,
      x_unit_set_status,
      x_unit_set_cat,
      x_start_dt,
      x_review_dt,
      x_expiry_dt,
      x_end_dt,
      x_title,
      x_short_title,
      x_abbreviation,
      x_responsible_org_unit_cd,
      x_responsible_ou_start_dt,
      x_administrative_ind,
      x_authorisation_rqrd_ind,
      x_attribute_category ,
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
      x_attribute16 ,
      x_attribute17 ,
      x_attribute18 ,
      x_attribute19 ,
      x_attribute20 ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation(
		 new_references.unit_set_cd,
 		 new_references.version_number
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
 		App_Exception.Raise_Exception;

	END IF;

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      -- Added the call to beforerowupdate as a part of Bug # 2729917
      beforerowupdate;
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      -- Added the call to beforerowdelete as a part of Bug # 2729917
      beforerowdelete;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
		          new_references.unit_set_cd,
		          new_references.version_number
				          ) THEN
		         	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
				IGS_GE_MSG_STACK.ADD;
		          	App_Exception.Raise_Exception;
     	        END IF;
      		Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      		  Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Added the call to beforerowdelete as a part of Bug # 2729917
      beforerowdelete;
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
      -- AfterStmtInsertUpdate4 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );
      AfterRowUpdate3 ( p_updating => TRUE );
      -- AfterStmtInsertUpdate4 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
    x_org_id IN NUMBER
  )  AS
    cursor C is select ROWID from IGS_EN_UNIT_SET_ALL
      where UNIT_SET_CD = X_UNIT_SET_CD
      and VERSION_NUMBER = X_VERSION_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML (
    p_action => 'INSERT',
    x_rowid => x_rowid  ,
    x_unit_set_cd => x_unit_set_cd   ,
    x_version_number => x_version_number ,
    x_unit_set_status => x_unit_set_status ,
    x_unit_set_cat => x_unit_set_cat  ,
    x_start_dt => x_start_dt ,
    x_review_dt => x_review_dt ,
    x_expiry_dt => x_expiry_dt ,
    x_end_dt => x_end_dt ,
    x_title => x_title  ,
    x_short_title => x_short_title ,
    x_abbreviation => x_abbreviation ,
    x_responsible_org_unit_cd => x_responsible_org_unit_cd ,
    x_responsible_ou_start_dt => x_responsible_ou_start_dt ,
    x_administrative_ind => NVL(X_ADMINISTRATIVE_IND,'N') ,
    x_authorisation_rqrd_ind=> NVL(X_AUTHORISATION_RQRD_IND,'N') ,
    x_attribute_category => x_attribute_category,
    x_attribute1 => x_attribute1,
    x_attribute2 => x_attribute2,
    x_attribute3 => x_attribute3,
    x_attribute4 => x_attribute4,
    x_attribute5 => x_attribute5,
    x_attribute6 => x_attribute6,
    x_attribute7 => x_attribute7,
    x_attribute8 => x_attribute8,
    x_attribute9 => x_attribute9,
    x_attribute10 => x_attribute10,
    x_attribute11 => x_attribute11,
    x_attribute12 => x_attribute12,
    x_attribute13 => x_attribute13,
    x_attribute14 => x_attribute14,
    x_attribute15 => x_attribute15,
    x_attribute16 => x_attribute16,
    x_attribute17 => x_attribute17,
    x_attribute18 => x_attribute18,
    x_attribute19 => x_attribute19,
    x_attribute20 => x_attribute20,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login ,
    x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_EN_UNIT_SET_ALL (
    UNIT_SET_CD,
    VERSION_NUMBER,
    UNIT_SET_STATUS,
    UNIT_SET_CAT,
    START_DT,
    REVIEW_DT,
    EXPIRY_DT,
    END_DT,
    TITLE,
    SHORT_TITLE,
    ABBREVIATION,
    RESPONSIBLE_ORG_UNIT_CD,
    RESPONSIBLE_OU_START_DT,
    ADMINISTRATIVE_IND,
    AUTHORISATION_RQRD_IND,
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
    ATTRIBUTE20,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    org_id
  ) values (
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.UNIT_SET_STATUS,
    NEW_REFERENCES.UNIT_SET_CAT,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.REVIEW_DT,
    NEW_REFERENCES.EXPIRY_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.TITLE,
    NEW_REFERENCES.SHORT_TITLE,
    NEW_REFERENCES.ABBREVIATION,
    NEW_REFERENCES.RESPONSIBLE_ORG_UNIT_CD,
    NEW_REFERENCES.RESPONSIBLE_OU_START_DT,
    NEW_REFERENCES.ADMINISTRATIVE_IND,
    NEW_REFERENCES.AUTHORISATION_RQRD_IND,
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
    NEW_REFERENCES.ATTRIBUTE20,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.org_id
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  After_DML(
	p_action => 'INSERT',
	x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL

) as
  cursor c1 is select
      UNIT_SET_STATUS,
      UNIT_SET_CAT,
      START_DT,
      REVIEW_DT,
      EXPIRY_DT,
      END_DT,
      TITLE,
      SHORT_TITLE,
      ABBREVIATION,
      RESPONSIBLE_ORG_UNIT_CD,
      RESPONSIBLE_OU_START_DT,
      ADMINISTRATIVE_IND,
      AUTHORISATION_RQRD_IND,
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
    from IGS_EN_UNIT_SET_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.UNIT_SET_STATUS = X_UNIT_SET_STATUS)
      AND (tlinfo.UNIT_SET_CAT = X_UNIT_SET_CAT)
      AND (tlinfo.START_DT = X_START_DT)
      AND ((tlinfo.REVIEW_DT = X_REVIEW_DT)
           OR ((tlinfo.REVIEW_DT is null)
               AND (X_REVIEW_DT is null)))
      AND ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND (tlinfo.TITLE = X_TITLE)
      AND (tlinfo.SHORT_TITLE = X_SHORT_TITLE)
      AND (tlinfo.ABBREVIATION = X_ABBREVIATION)
      AND ((tlinfo.RESPONSIBLE_ORG_UNIT_CD = X_RESPONSIBLE_ORG_UNIT_CD)
           OR ((tlinfo.RESPONSIBLE_ORG_UNIT_CD is null)
               AND (X_RESPONSIBLE_ORG_UNIT_CD is null)))
      AND ((tlinfo.RESPONSIBLE_OU_START_DT = X_RESPONSIBLE_OU_START_DT)
           OR ((tlinfo.RESPONSIBLE_OU_START_DT is null)
               AND (X_RESPONSIBLE_OU_START_DT is null)))
      AND (tlinfo.ADMINISTRATIVE_IND = X_ADMINISTRATIVE_IND)
      AND (tlinfo.AUTHORISATION_RQRD_IND = X_AUTHORISATION_RQRD_IND)
      AND ((tlinfo.attribute_category = X_ATTRIBUTE_CATEGORY) OR
           ((tlinfo.attribute_category IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND ((tlinfo.attribute1 = X_ATTRIBUTE1) OR
           ((tlinfo.attribute1 IS NULL) AND (X_ATTRIBUTE1 IS NULL)))
      AND ((tlinfo.attribute2 = X_ATTRIBUTE2) OR
           ((tlinfo.attribute2 IS NULL) AND (X_ATTRIBUTE2 IS NULL)))
      AND ((tlinfo.attribute3 = X_ATTRIBUTE3) OR
           ((tlinfo.attribute3 IS NULL) AND (X_ATTRIBUTE3 IS NULL)))
      AND ((tlinfo.attribute4 = X_ATTRIBUTE4) OR
           ((tlinfo.attribute4 IS NULL) AND (X_ATTRIBUTE4 IS NULL)))
      AND ((tlinfo.attribute5 = X_ATTRIBUTE5) OR
           ((tlinfo.attribute5 IS NULL) AND (X_ATTRIBUTE5 IS NULL)))
      AND ((tlinfo.attribute6 = X_ATTRIBUTE6) OR
           ((tlinfo.attribute6 IS NULL) AND (X_ATTRIBUTE6 IS NULL)))
      AND ((tlinfo.attribute7 = X_ATTRIBUTE7) OR
           ((tlinfo.attribute7 IS NULL) AND (X_ATTRIBUTE7 IS NULL)))
      AND ((tlinfo.attribute8 = X_ATTRIBUTE8) OR
           ((tlinfo.attribute8 IS NULL) AND (X_ATTRIBUTE8 IS NULL)))
      AND ((tlinfo.attribute9 = X_ATTRIBUTE9) OR
           ((tlinfo.attribute9 IS NULL) AND (X_ATTRIBUTE9 IS NULL)))
      AND ((tlinfo.attribute10 = X_ATTRIBUTE10) OR
           ((tlinfo.attribute10 IS NULL) AND (X_ATTRIBUTE10 IS NULL)))
      AND ((tlinfo.attribute11 = X_ATTRIBUTE11) OR
           ((tlinfo.attribute11 IS NULL) AND (X_ATTRIBUTE11 IS NULL)))
      AND ((tlinfo.attribute12 = X_ATTRIBUTE12) OR
           ((tlinfo.attribute12 IS NULL) AND (X_ATTRIBUTE12 IS NULL)))
      AND ((tlinfo.attribute13 = X_ATTRIBUTE13) OR
           ((tlinfo.attribute13 IS NULL) AND (X_ATTRIBUTE13 IS NULL)))
      AND ((tlinfo.attribute14 = X_ATTRIBUTE14) OR
           ((tlinfo.attribute14 IS NULL) AND (X_ATTRIBUTE14 IS NULL)))
      AND ((tlinfo.attribute15 = X_ATTRIBUTE15) OR
           ((tlinfo.attribute15 IS NULL) AND (X_ATTRIBUTE15 IS NULL)))
      AND ((tlinfo.attribute16 = X_ATTRIBUTE16) OR
           ((tlinfo.attribute16 IS NULL) AND (X_ATTRIBUTE16 IS NULL)))
      AND ((tlinfo.attribute17 = X_ATTRIBUTE17) OR
           ((tlinfo.attribute17 IS NULL) AND (X_ATTRIBUTE17 IS NULL)))
      AND ((tlinfo.attribute18 = X_ATTRIBUTE18) OR
           ((tlinfo.attribute18 IS NULL) AND (X_ATTRIBUTE18 IS NULL)))
      AND ((tlinfo.attribute19 = X_ATTRIBUTE19) OR
           ((tlinfo.attribute19 IS NULL) AND (X_ATTRIBUTE19 IS NULL)))
      AND ((tlinfo.attribute20 = X_ATTRIBUTE20) OR
           ((tlinfo.attribute20 IS NULL) AND (X_ATTRIBUTE20 IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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

  Before_DML(
    p_action => 'UPDATE' ,
    x_rowid =>  x_rowid,
    x_unit_set_cd => x_unit_set_cd ,
    x_version_number => x_version_number ,
    x_unit_set_status => x_unit_set_status ,
    x_unit_set_cat => x_unit_set_cat ,
    x_start_dt =>  x_start_dt,
    x_review_dt => x_review_dt ,
    x_expiry_dt => x_expiry_dt ,
    x_end_dt =>  x_end_dt ,
    x_title => x_title ,
    x_short_title => x_short_title ,
    x_abbreviation => x_abbreviation ,
    x_responsible_org_unit_cd => x_responsible_org_unit_cd ,
    x_responsible_ou_start_dt => x_responsible_ou_start_dt ,
    x_administrative_ind => x_administrative_ind ,
    x_authorisation_rqrd_ind => x_authorisation_rqrd_ind ,
    x_attribute_category => x_attribute_category,
    x_attribute1 => x_attribute1,
    x_attribute2 => x_attribute2,
    x_attribute3 => x_attribute3,
    x_attribute4 => x_attribute4,
    x_attribute5 => x_attribute5,
    x_attribute6 => x_attribute6,
    x_attribute7 => x_attribute7,
    x_attribute8 => x_attribute8,
    x_attribute9 => x_attribute9,
    x_attribute10 => x_attribute10,
    x_attribute11 => x_attribute11,
    x_attribute12 => x_attribute12,
    x_attribute13 => x_attribute13,
    x_attribute14 => x_attribute14,
    x_attribute15 => x_attribute15,
    x_attribute16 => x_attribute16,
    x_attribute17 => x_attribute17,
    x_attribute18 => x_attribute18,
    x_attribute19 => x_attribute19,
    x_attribute20 => x_attribute20,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date =>  x_last_update_date,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login
  );

  update IGS_EN_UNIT_SET_ALL set
    UNIT_SET_STATUS = NEW_REFERENCES.UNIT_SET_STATUS,
    UNIT_SET_CAT = NEW_REFERENCES.UNIT_SET_CAT,
    START_DT = NEW_REFERENCES.START_DT,
    REVIEW_DT = NEW_REFERENCES.REVIEW_DT,
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    END_DT = NEW_REFERENCES.END_DT,
    TITLE = NEW_REFERENCES.TITLE,
    SHORT_TITLE = NEW_REFERENCES.SHORT_TITLE,
    ABBREVIATION = NEW_REFERENCES.ABBREVIATION,
    RESPONSIBLE_ORG_UNIT_CD = NEW_REFERENCES.RESPONSIBLE_ORG_UNIT_CD,
    RESPONSIBLE_OU_START_DT = NEW_REFERENCES.RESPONSIBLE_OU_START_DT,
    ADMINISTRATIVE_IND = NEW_REFERENCES.ADMINISTRATIVE_IND,
    AUTHORISATION_RQRD_IND = NEW_REFERENCES.AUTHORISATION_RQRD_IND,
    ATTRIBUTE_CATEGORY = NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 = NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 = NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 = NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 = NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 = NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 = NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 = NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 = NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 = NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 = NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 = NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 = NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 = NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 = NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 = NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 = NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 = NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 = NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 = NEW_REFERENCES.ATTRIBUTE20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN

  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_STATUS in VARCHAR2,
  X_UNIT_SET_CAT in VARCHAR2,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_ADMINISTRATIVE_IND in VARCHAR2,
  X_AUTHORISATION_RQRD_IND in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER
  ) as
  cursor c1 is select rowid from IGS_EN_UNIT_SET_ALL
     where UNIT_SET_CD = X_UNIT_SET_CD
     and VERSION_NUMBER = X_VERSION_NUMBER;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_SET_CD,
     X_VERSION_NUMBER,
     X_UNIT_SET_STATUS,
     X_UNIT_SET_CAT,
     X_START_DT,
     X_REVIEW_DT,
     X_EXPIRY_DT,
     X_END_DT,
     X_TITLE,
     X_SHORT_TITLE,
     X_ABBREVIATION,
     X_RESPONSIBLE_ORG_UNIT_CD,
     X_RESPONSIBLE_OU_START_DT,
     X_ADMINISTRATIVE_IND,
     X_AUTHORISATION_RQRD_IND,
     X_ATTRIBUTE_CATEGORY ,
     X_ATTRIBUTE1 ,
     X_ATTRIBUTE2 ,
     X_ATTRIBUTE3 ,
     X_ATTRIBUTE4 ,
     X_ATTRIBUTE5 ,
     X_ATTRIBUTE6 ,
     X_ATTRIBUTE7 ,
     X_ATTRIBUTE8 ,
     X_ATTRIBUTE9 ,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11 ,
     X_ATTRIBUTE12 ,
     X_ATTRIBUTE13 ,
     X_ATTRIBUTE14 ,
     X_ATTRIBUTE15 ,
     X_ATTRIBUTE16 ,
     X_ATTRIBUTE17 ,
     X_ATTRIBUTE18 ,
     X_ATTRIBUTE19 ,
     X_ATTRIBUTE20 ,
     X_MODE,
     x_org_id);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_SET_CD,
   X_VERSION_NUMBER,
   X_UNIT_SET_STATUS,
   X_UNIT_SET_CAT,
   X_START_DT,
   X_REVIEW_DT,
   X_EXPIRY_DT,
   X_END_DT,
   X_TITLE,
   X_SHORT_TITLE,
   X_ABBREVIATION,
   X_RESPONSIBLE_ORG_UNIT_CD,
   X_RESPONSIBLE_OU_START_DT,
   X_ADMINISTRATIVE_IND,
   X_AUTHORISATION_RQRD_IND,
   X_ATTRIBUTE_CATEGORY ,
   X_ATTRIBUTE1 ,
   X_ATTRIBUTE2 ,
   X_ATTRIBUTE3 ,
   X_ATTRIBUTE4 ,
   X_ATTRIBUTE5 ,
   X_ATTRIBUTE6 ,
   X_ATTRIBUTE7 ,
   X_ATTRIBUTE8 ,
   X_ATTRIBUTE9 ,
   X_ATTRIBUTE10,
   X_ATTRIBUTE11 ,
   X_ATTRIBUTE12 ,
   X_ATTRIBUTE13 ,
   X_ATTRIBUTE14 ,
   X_ATTRIBUTE15 ,
   X_ATTRIBUTE16 ,
   X_ATTRIBUTE17 ,
   X_ATTRIBUTE18 ,
   X_ATTRIBUTE19 ,
   X_ATTRIBUTE20 ,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
) as
begin
  Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_UNIT_SET_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_EN_UNIT_SET_PKG;

/
