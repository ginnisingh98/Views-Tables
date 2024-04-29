--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_CPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_CPS_PKG" AS
/* $Header: IGSPI1AB.pls 120.2 2006/05/15 00:48:09 sarakshi ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_usec_cps%RowType;
  new_references igs_ps_usec_cps%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_sec_credit_points_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_minimum_credit_points IN NUMBER DEFAULT NULL,
    x_maximum_credit_points IN NUMBER DEFAULT NULL,
    x_variable_increment IN NUMBER DEFAULT NULL,
    x_lecture_credit_points IN NUMBER DEFAULT NULL,
    x_lab_credit_points IN NUMBER DEFAULT NULL,
    x_other_credit_points IN NUMBER DEFAULT NULL,
    x_clock_hours IN NUMBER DEFAULT NULL,
    x_work_load_cp_lecture IN NUMBER DEFAULT NULL,
    x_work_load_cp_lab IN NUMBER DEFAULT NULL,
    x_continuing_education_units IN NUMBER DEFAULT NULL,
    x_WORK_LOAD_OTHER IN NUMBER DEFAULT NULL,
    x_CONTACT_HRS_LECTURE IN NUMBER DEFAULT NULL,
    x_CONTACT_HRS_LAB IN NUMBER DEFAULT NULL,
    x_CONTACT_HRS_OTHER IN NUMBER DEFAULT NULL,
    x_NON_SCHD_REQUIRED_HRS IN NUMBER DEFAULT NULL,
    x_EXCLUDE_FROM_MAX_CP_LIMIT IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_claimable_hours IN NUMBER DEFAULT NULL,
    x_achievable_credit_points IN NUMBER DEFAULT NULL,
    x_enrolled_credit_points IN NUMBER DEFAULT NULL,
    x_billing_credit_points IN NUMBER,
    x_billing_hrs IN NUMBER
  ) AS

  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_USEC_CPS
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_sec_credit_points_id := x_unit_sec_credit_points_id;
    new_references.uoo_id := x_uoo_id;
    new_references.minimum_credit_points := x_minimum_credit_points;
    new_references.maximum_credit_points := x_maximum_credit_points;
    new_references.variable_increment := x_variable_increment;
    new_references.lecture_credit_points := x_lecture_credit_points;
    new_references.lab_credit_points := x_lab_credit_points;
    new_references.other_credit_points := x_other_credit_points;
    new_references.clock_hours := x_clock_hours;
    new_references.work_load_cp_lecture := x_work_load_cp_lecture;
    new_references.work_load_cp_lab := x_work_load_cp_lab;
    new_references.continuing_education_units := x_continuing_education_units;
    new_references.work_load_other := x_work_load_other;
    new_references.contact_hrs_lecture := x_contact_hrs_lecture ;
    new_references.contact_hrs_lab := x_contact_hrs_lab;
    new_references.contact_hrs_other := x_contact_hrs_other;
    new_references.non_schd_required_hrs := x_non_schd_required_hrs;
    new_references.exclude_from_max_cp_limit := x_exclude_from_max_cp_limit;
    new_references.claimable_hours := x_claimable_hours;
    new_references.achievable_credit_points := x_achievable_credit_points;
    new_references.enrolled_credit_points       := x_enrolled_credit_points;
    new_references.billing_credit_points := x_billing_credit_points;
    new_references.billing_hrs := x_billing_hrs;

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

 PROCEDURE AfterRowUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

  -- Select the teaching responsibilites record which has only workload percentage defined and not
  -- other workload values defined.
  CURSOR c_teach_resp(p_uoo_id NUMBER) IS
         SELECT rowid,iputr.*
         FROM igs_ps_usec_tch_resp iputr
         WHERE iputr.uoo_id = p_uoo_id AND
               iputr.percentage_allocation IS NOT NULL AND
               iputr.instructional_load_lab IS NULL AND
               iputr.instructional_load_lecture IS NULL AND
               iputr.instructional_load IS NULL;

   l_new_lab  igs_ps_usec_tch_resp_v.instructional_load_lab%TYPE;
   l_new_lecture igs_ps_usec_tch_resp_v.instructional_load_lecture%TYPE;
   l_new_other igs_ps_usec_tch_resp_v.instructional_load%TYPE;

  BEGIN
    -- if the workload value are updated
    IF (p_updating = TRUE AND ( NVL(new_references.work_load_other,-1) <> NVL(old_references.work_load_other,-1) OR
       NVL(new_references.work_load_cp_lecture ,-1) <> NVL(old_references.work_load_cp_lecture ,-1) OR
       NVL(new_references.work_load_cp_lab,-1) <> NVL(old_references.work_load_cp_lab,-1)
       )) OR p_inserting = TRUE THEN
         -- Re-calculating the values in Worload lecture,Laboratory and Other in Teaching Responsibilities as these points are modified at Unit Section level

          FOR c_teach_resp_rec in c_teach_resp(new_references.uoo_id)
          LOOP
               igs_ps_fac_credt_wrkload.calculate_teach_work_load(c_teach_resp_rec.uoo_id,c_teach_resp_rec.percentage_allocation,l_new_lab,l_new_lecture,l_new_other);
               igs_ps_usec_tch_resp_pkg.update_row (
                                                  x_mode                       => 'R',
                                                  x_rowid                      => c_teach_resp_rec.rowid,
                                                  x_unit_section_teach_resp_id => c_teach_resp_rec.unit_section_teach_resp_id,
                                                  x_instructor_id              => c_teach_resp_rec.instructor_id,
                                                  x_confirmed_flag             => c_teach_resp_rec.confirmed_flag ,
                                                  x_percentage_allocation      => c_teach_resp_rec.percentage_allocation,
                                                  x_instructional_load         => l_new_other ,
                                                  x_lead_instructor_flag       => c_teach_resp_rec.lead_instructor_flag,
                                                  x_uoo_id                     => c_teach_resp_rec.uoo_id,
                                                  x_instructional_load_lab     => l_new_lab,
                                                  x_instructional_load_lecture => l_new_lecture
                                                 );
          END LOOP;
    END IF;
 END AfterRowUpdate1;

  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2  DEFAULT NULL,
                 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi        15-May-2006     Bug#3064563, modified the format mask(work_load_cp_lecture,work_load_cp_lab) as specified in the bug.
  sarakhsi        16-Jan-2003     Bug#2753280,minimum value for continuing_education_units and clock_hours
                                  changed from 1 to 0 and maximum value from 999 to 999.999
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF Upper(Column_Name)='MINIMUM_CREDIT_POINTS' Then
              New_References.minimum_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='MAXIMUM_CREDIT_POINTS' Then
              New_References.maximum_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='VARIABLE_INCREMENT' Then
              New_References.variable_increment := Column_Value;
      ELSIF Upper(Column_Name)='LECTURE_CREDIT_POINTS' Then
              New_References.lecture_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='LAB_CREDIT_POINTS' Then
              New_References.lab_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='OTHER_CREDIT_POINTS' Then
              New_References.other_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='CLOCK_HOURS' Then
              New_References.clock_hours := Column_Value;
      ELSIF Upper(Column_Name)='WORK_LOAD_CP_LECTURE' Then
              New_References.work_load_cp_lecture := Column_Value;
      ELSIF Upper(Column_Name)='WORK_LOAD_CP_LAB' Then
              New_References.work_load_cp_lab := Column_Value;
      ELSIF Upper(Column_Name)='CONTINUING_EDUCATION_UNITS' Then
              New_References.continuing_education_units := Column_Value;
      ELSIF Upper(Column_Name)='WORK_LOAD_OTHER' Then
              New_References.work_load_other := Column_Value;
      ELSIF Upper(Column_Name)='CONTACT_HRS_LECTURE' Then
              New_References.contact_hrs_lecture := Column_Value;
      ELSIF Upper(Column_Name)='CONTACT_HRS_LAB' Then
              New_References.contact_hrs_lab := Column_Value;
      ELSIF Upper(Column_Name)='CONTACT_HRS_OTHER' Then
              New_References.contact_hrs_other := Column_Value;
      ELSIF Upper(Column_Name)='NON_SCHD_REQUIRED_HRS' Then
              New_References.non_schd_required_hrs := Column_Value;
      ELSIF Upper(Column_Name)='EXCLUDE_FROM_MAX_CP_LIMIT' Then
              New_References.exclude_from_max_cp_limit := Column_Value;
      ELSIF Upper(Column_Name)='CLAIMABLE_HOURS' Then
              New_References.claimable_hours := Column_Value;
      ELSIF Upper(Column_Name)='ACHIEVABLE_CREDIT_POINTS' Then
              New_References.achievable_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='ENROLLED_CREDIT_POINTS' Then
              New_References.enrolled_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='BILLING_CREDIT_POINTS' Then
              New_References.billing_credit_points := Column_Value;
      ELSIF Upper(Column_Name)='BILLING_HRS' Then
              New_References.billing_hrs := Column_Value;
      END IF;

      IF Upper(Column_Name)='MINIMUM_CREDIT_POINTS' OR Column_Name IS NULL Then
              IF New_References.minimum_credit_points < 0 OR New_References.minimum_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                               App_Exception.Raise_Exception;
              END IF;
      END IF;

        IF Upper(Column_Name)='MAXIMUM_CREDIT_POINTS' OR Column_Name IS NULL Then
                IF New_References.maximum_credit_points < 0 OR New_References.maximum_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='VARIABLE_INCREMENT' OR Column_Name IS NULL Then
                IF New_References.variable_increment < 0 OR New_References.variable_increment > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='LECTURE_CREDIT_POINTS' OR Column_Name IS NULL Then
                IF New_References.lecture_credit_points < 0 OR New_References.lecture_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='LAB_CREDIT_POINTS' OR Column_Name IS NULL Then
                IF New_References.lab_credit_points < 0 OR New_References.lab_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='OTHER_CREDIT_POINTS' OR Column_Name IS NULL Then
                IF New_References.other_credit_points < 0 OR New_References.other_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='CLOCK_HOURS' OR Column_Name IS NULL Then
                IF New_References.clock_hours < 0 OR New_References.clock_hours > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='WORK_LOAD_CP_LECTURE' OR Column_Name IS NULL Then
                IF New_References.work_load_cp_lecture < 0 OR New_References.work_load_cp_lecture > 999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='WORK_LOAD_CP_LAB' OR Column_Name IS NULL Then
                IF New_References.work_load_cp_lab < 0 OR New_References.work_load_cp_lab > 999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='CONTINUING_EDUCATION_UNITS' OR Column_Name IS NULL Then
                IF New_References.continuing_education_units < 0 OR New_References.continuing_education_units > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='WORK_LOAD_OTHER' OR Column_Name IS NULL Then
                IF New_References.work_load_other < 0 OR New_References.WORK_LOAD_OTHER > 999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='CONTACT_HRS_LECTURE' OR Column_Name IS NULL Then
                IF New_References.contact_hrs_lecture < 0 OR New_References.contact_hrs_lecture > 999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='CONTACT_HRS_LAB' OR Column_Name IS NULL Then
                IF New_References.contact_hrs_lab < 0 OR New_References.contact_hrs_lab > 999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='CONTACT_HRS_OTHER' OR Column_Name IS NULL Then
                IF New_References.contact_hrs_other < 0 OR New_References.contact_hrs_other > 999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='NON_SCHD_REQUIRED_HRS' OR Column_Name IS NULL Then
                IF New_References.non_schd_required_hrs < 0 OR New_References.non_schd_required_hrs > 999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)= 'EXCLUDE_FROM_MAX_CP_LIMIT' OR Column_Name IS NULL Then
                IF New_References.exclude_from_max_cp_limit NOT IN ( 'Y' , 'N' ) Then
                               Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                               IGS_GE_MSG_STACK.ADD;
                               App_Exception.Raise_Exception;
               END IF;
        END IF;

        IF Upper(Column_Name)='CLAIMABLE_HOURS' OR Column_Name IS NULL Then
                IF New_References.claimable_hours < 0 OR New_References.claimable_hours > 99999.99 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

       IF Upper(Column_Name)='ACHIEVABLE_CREDIT_POINTS' OR Column_Name IS NULL Then
                IF New_References.achievable_credit_points < 0 OR New_References.achievable_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                             IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

       IF Upper(Column_Name)='ENROLLED_CREDIT_POINTS' OR Column_Name IS NULL Then
                IF New_References.enrolled_credit_points < 0 OR New_References.enrolled_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                             IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

       IF Upper(Column_Name)='BILLING_CREDIT_POINTS' OR Column_Name IS NULL Then
                IF New_References.billing_credit_points < 0 OR New_References.billing_credit_points > 999.999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

	IF Upper(Column_Name)='BILLING_HRS' OR Column_Name IS NULL Then
		IF New_References.billing_hrs < 0 OR New_References.billing_hrs > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :  shgeroge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
                IF Get_Uk_For_Validation (
                new_references.uoo_id
                ) THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
                        app_exception.raise_exception;
                END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :  shgeroge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ofr_Opt_Pkg.Get_UK_For_Validation (
                        new_references.uoo_id
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_sec_credit_points_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :  shgeroge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_cps
      WHERE    unit_sec_credit_points_id = x_unit_sec_credit_points_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

  FUNCTION Get_UK_For_Validation (
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_cps
      WHERE    uoo_id = x_uoo_id        and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;
  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_cps
      WHERE    uoo_id = x_uoo_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_USCP_UOO_UFK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_UFK_Igs_Ps_Unit_Ofr_Opt;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_sec_credit_points_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_minimum_credit_points IN NUMBER DEFAULT NULL,
    x_maximum_credit_points IN NUMBER DEFAULT NULL,
    x_variable_increment IN NUMBER DEFAULT NULL,
    x_lecture_credit_points IN NUMBER DEFAULT NULL,
    x_lab_credit_points IN NUMBER DEFAULT NULL,
    x_other_credit_points IN NUMBER DEFAULT NULL,
    x_clock_hours IN NUMBER DEFAULT NULL,
    x_work_load_cp_lecture IN NUMBER DEFAULT NULL,
    x_work_load_cp_lab IN NUMBER DEFAULT NULL,
    x_continuing_education_units IN NUMBER DEFAULT NULL,
    x_WORK_LOAD_OTHER IN NUMBER DEFAULT NULL,
    x_CONTACT_HRS_LECTURE IN NUMBER DEFAULT NULL,
    x_CONTACT_HRS_LAB IN NUMBER DEFAULT NULL,
    x_CONTACT_HRS_OTHER IN NUMBER DEFAULT NULL,
    x_NON_SCHD_REQUIRED_HRS IN NUMBER DEFAULT NULL,
    x_EXCLUDE_FROM_MAX_CP_LIMIT IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_claimable_hours IN NUMBER DEFAULT NULL,
    x_achievable_credit_points IN NUMBER ,
    x_enrolled_credit_points IN NUMBER ,
    x_billing_credit_points IN NUMBER,
    x_billing_hrs IN NUMBER
  ) AS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_sec_credit_points_id,
      x_uoo_id,
      x_minimum_credit_points,
      x_maximum_credit_points,
      x_variable_increment,
      x_lecture_credit_points,
      x_lab_credit_points,
      x_other_credit_points,
      x_clock_hours,
      x_work_load_cp_lecture,
      x_work_load_cp_lab,
      x_continuing_education_units,
      x_work_load_other,
      x_contact_hrs_lecture,
      x_contact_hrs_lab,
      x_contact_hrs_other,
      x_non_schd_required_hrs,
      x_exclude_from_max_cp_limit,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_claimable_hours,
      x_achievable_credit_points,
      x_enrolled_credit_points ,
      x_billing_credit_points,
      x_billing_hrs
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.unit_sec_credit_points_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.unit_sec_credit_points_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowUpdate1 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate1 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

    l_rowid := null;
  END After_DML;

 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SEC_CREDIT_POINTS_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_MINIMUM_CREDIT_POINTS IN NUMBER,
       x_MAXIMUM_CREDIT_POINTS IN NUMBER,
       x_VARIABLE_INCREMENT IN NUMBER,
       x_LECTURE_CREDIT_POINTS IN NUMBER,
       x_LAB_CREDIT_POINTS IN NUMBER,
       x_OTHER_CREDIT_POINTS IN NUMBER,
       x_CLOCK_HOURS IN NUMBER,
       x_WORK_LOAD_CP_LECTURE IN NUMBER,
       x_WORK_LOAD_CP_LAB IN NUMBER,
       x_CONTINUING_EDUCATION_UNITS IN NUMBER,
       x_WORK_LOAD_OTHER IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LECTURE IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LAB IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_OTHER IN NUMBER DEFAULT NULL,
       x_NON_SCHD_REQUIRED_HRS IN NUMBER DEFAULT NULL,
       x_EXCLUDE_FROM_MAX_CP_LIMIT IN VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'  ,
       x_claimable_hours IN NUMBER DEFAULT NULL,
        x_achievable_credit_points IN NUMBER ,
       x_enrolled_credit_points IN NUMBER ,
       x_billing_credit_points IN NUMBER,
       x_billing_hrs IN NUMBER
  ) AS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_USEC_CPS
             where                 UNIT_SEC_CREDIT_POINTS_ID= X_UNIT_SEC_CREDIT_POINTS_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
   SELECT
        IGS_PS_USEC_CPS_S.NextVal
   INTO
        x_UNIT_SEC_CREDIT_POINTS_ID
   FROM
        dual;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_unit_sec_credit_points_id=>X_UNIT_SEC_CREDIT_POINTS_ID,
               x_uoo_id=>X_UOO_ID,
               x_minimum_credit_points=>X_MINIMUM_CREDIT_POINTS,
               x_maximum_credit_points=>X_MAXIMUM_CREDIT_POINTS,
               x_variable_increment=>X_VARIABLE_INCREMENT,
               x_lecture_credit_points=>X_LECTURE_CREDIT_POINTS,
               x_lab_credit_points=>X_LAB_CREDIT_POINTS,
               x_other_credit_points=>X_OTHER_CREDIT_POINTS,
               x_clock_hours=>X_CLOCK_HOURS,
               x_work_load_cp_lecture=>X_WORK_LOAD_CP_LECTURE,
               x_work_load_cp_lab=>X_WORK_LOAD_CP_LAB,
               x_continuing_education_units=>X_CONTINUING_EDUCATION_UNITS,
               x_work_load_other => X_WORK_LOAD_OTHER,
               x_contact_hrs_lecture => X_CONTACT_HRS_LECTURE,
               x_contact_hrs_lab => X_CONTACT_HRS_LAB,
               x_contact_hrs_other => X_CONTACT_HRS_OTHER,
               x_non_schd_required_hrs => X_NON_SCHD_REQUIRED_HRS,
               x_exclude_from_max_cp_limit => X_EXCLUDE_FROM_MAX_CP_LIMIT,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
              x_claimable_hours => x_claimable_hours,
              x_achievable_credit_points => x_achievable_credit_points,
              x_enrolled_credit_points => x_enrolled_credit_points,
              x_billing_credit_points => x_billing_credit_points,
              x_billing_hrs => x_billing_hrs
	      );

     insert into IGS_PS_USEC_CPS (
                 UNIT_SEC_CREDIT_POINTS_ID
                ,UOO_ID
                ,MINIMUM_CREDIT_POINTS
                ,MAXIMUM_CREDIT_POINTS
                ,VARIABLE_INCREMENT
                ,LECTURE_CREDIT_POINTS
                ,LAB_CREDIT_POINTS
                ,OTHER_CREDIT_POINTS
                ,CLOCK_HOURS
                ,WORK_LOAD_CP_LECTURE
                ,WORK_LOAD_CP_LAB
                ,CONTINUING_EDUCATION_UNITS
                ,WORK_LOAD_OTHER
                ,CONTACT_HRS_LECTURE
                ,CONTACT_HRS_LAB
                ,CONTACT_HRS_OTHER
                ,NON_SCHD_REQUIRED_HRS
                ,EXCLUDE_FROM_MAX_CP_LIMIT
               ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
              ,claimable_hours
              ,achievable_credit_points
              ,enrolled_credit_points
              ,billing_credit_points
	      ,billing_hrs
        ) values  (
                 NEW_REFERENCES.UNIT_SEC_CREDIT_POINTS_ID
                ,NEW_REFERENCES.UOO_ID
                ,NEW_REFERENCES.MINIMUM_CREDIT_POINTS
                ,NEW_REFERENCES.MAXIMUM_CREDIT_POINTS
                ,NEW_REFERENCES.VARIABLE_INCREMENT
                ,NEW_REFERENCES.LECTURE_CREDIT_POINTS
                ,NEW_REFERENCES.LAB_CREDIT_POINTS
                ,NEW_REFERENCES.OTHER_CREDIT_POINTS
                ,NEW_REFERENCES.CLOCK_HOURS
                ,NEW_REFERENCES.WORK_LOAD_CP_LECTURE
                ,NEW_REFERENCES.WORK_LOAD_CP_LAB
                ,NEW_REFERENCES.CONTINUING_EDUCATION_UNITS
                ,NEW_REFERENCES.WORK_LOAD_OTHER
                 ,NEW_REFERENCES.CONTACT_HRS_LECTURE
                 ,NEW_REFERENCES.CONTACT_HRS_LAB
                 ,NEW_REFERENCES.CONTACT_HRS_OTHER
                 ,NEW_REFERENCES.NON_SCHD_REQUIRED_HRS
                 ,NEW_REFERENCES.EXCLUDE_FROM_MAX_CP_LIMIT
                ,X_LAST_UPDATE_DATE
                 ,X_LAST_UPDATED_BY
                 ,X_LAST_UPDATE_DATE
                 ,X_LAST_UPDATED_BY
                 ,X_LAST_UPDATE_LOGIN
               ,new_references.claimable_hours
               ,new_references.achievable_credit_points
               ,new_references.enrolled_credit_points
               ,new_references.billing_credit_points
	       ,new_references.billing_hrs);
                open c;
                 fetch c into X_ROWID;
                if (c%notfound) then
                close c;
             raise no_data_found;
                end if;
                close c;
    After_DML (
                p_action => 'INSERT' ,
                x_rowid => X_ROWID );
end INSERT_ROW;

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SEC_CREDIT_POINTS_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_MINIMUM_CREDIT_POINTS IN NUMBER,
       x_MAXIMUM_CREDIT_POINTS IN NUMBER,
       x_VARIABLE_INCREMENT IN NUMBER,
       x_LECTURE_CREDIT_POINTS IN NUMBER,
       x_LAB_CREDIT_POINTS IN NUMBER,
       x_OTHER_CREDIT_POINTS IN NUMBER,
       x_CLOCK_HOURS IN NUMBER,
       x_WORK_LOAD_CP_LECTURE IN NUMBER,
       x_WORK_LOAD_CP_LAB IN NUMBER,
       x_CONTINUING_EDUCATION_UNITS IN NUMBER,
       x_WORK_LOAD_OTHER IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LECTURE IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LAB IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_OTHER IN NUMBER DEFAULT NULL,
       x_NON_SCHD_REQUIRED_HRS IN NUMBER DEFAULT NULL,
       x_EXCLUDE_FROM_MAX_CP_LIMIT IN VARCHAR2 DEFAULT NULL,
       x_claimable_hours IN NUMBER DEFAULT NULL,
       x_achievable_credit_points IN NUMBER ,
       x_enrolled_credit_points IN NUMBER ,
       x_billing_credit_points IN NUMBER,
       x_billing_hrs IN NUMBER ) AS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      UOO_ID
,      MINIMUM_CREDIT_POINTS
,      MAXIMUM_CREDIT_POINTS
,      VARIABLE_INCREMENT
,      LECTURE_CREDIT_POINTS
,      LAB_CREDIT_POINTS
,      OTHER_CREDIT_POINTS
,      CLOCK_HOURS
,      WORK_LOAD_CP_LECTURE
,      WORK_LOAD_CP_LAB
,      CONTINUING_EDUCATION_UNITS
,      WORK_LOAD_OTHER
,      CONTACT_HRS_LECTURE
,      CONTACT_HRS_LAB
,      CONTACT_HRS_OTHER
,      NON_SCHD_REQUIRED_HRS
,      EXCLUDE_FROM_MAX_CP_LIMIT
,      claimable_hours
,      achievable_credit_points
,      enrolled_credit_points
,      billing_credit_points
,      billing_hrs
    from IGS_PS_USEC_CPS
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
if ( (  tlinfo.UOO_ID = X_UOO_ID)
  AND ((tlinfo.MINIMUM_CREDIT_POINTS = X_MINIMUM_CREDIT_POINTS)
            OR ((tlinfo.MINIMUM_CREDIT_POINTS is null)
                AND (X_MINIMUM_CREDIT_POINTS is null)))
  AND ((tlinfo.MAXIMUM_CREDIT_POINTS = X_MAXIMUM_CREDIT_POINTS)
            OR ((tlinfo.MAXIMUM_CREDIT_POINTS is null)
                AND (X_MAXIMUM_CREDIT_POINTS is null)))
  AND ((tlinfo.VARIABLE_INCREMENT = X_VARIABLE_INCREMENT)
            OR ((tlinfo.VARIABLE_INCREMENT is null)
                AND (X_VARIABLE_INCREMENT is null)))
  AND ((tlinfo.LECTURE_CREDIT_POINTS = X_LECTURE_CREDIT_POINTS)
            OR ((tlinfo.LECTURE_CREDIT_POINTS is null)
                AND (X_LECTURE_CREDIT_POINTS is null)))
  AND ((tlinfo.LAB_CREDIT_POINTS = X_LAB_CREDIT_POINTS)
            OR ((tlinfo.LAB_CREDIT_POINTS is null)
                AND (X_LAB_CREDIT_POINTS is null)))
  AND ((tlinfo.OTHER_CREDIT_POINTS = X_OTHER_CREDIT_POINTS)
            OR ((tlinfo.OTHER_CREDIT_POINTS is null)
                AND (X_OTHER_CREDIT_POINTS is null)))
  AND ((tlinfo.CLOCK_HOURS = X_CLOCK_HOURS)
            OR ((tlinfo.CLOCK_HOURS is null)
                AND (X_CLOCK_HOURS is null)))
  AND ((tlinfo.WORK_LOAD_CP_LECTURE = X_WORK_LOAD_CP_LECTURE)
            OR ((tlinfo.WORK_LOAD_CP_LECTURE is null)
                AND (X_WORK_LOAD_CP_LECTURE is null)))
  AND ((tlinfo.WORK_LOAD_CP_LAB = X_WORK_LOAD_CP_LAB)
            OR ((tlinfo.WORK_LOAD_CP_LAB is null)
                AND (X_WORK_LOAD_CP_LAB is null)))
  AND ((tlinfo.CONTINUING_EDUCATION_UNITS = X_CONTINUING_EDUCATION_UNITS)
            OR ((tlinfo.CONTINUING_EDUCATION_UNITS is null)
                AND (X_CONTINUING_EDUCATION_UNITS is null)))
  AND ((tlinfo.WORK_LOAD_OTHER = X_WORK_LOAD_OTHER)
            OR ((tlinfo.WORK_LOAD_OTHER is null)
                AND (X_WORK_LOAD_OTHER is null)))
  AND ((tlinfo.CONTACT_HRS_LECTURE = X_CONTACT_HRS_LECTURE)
            OR ((tlinfo.CONTACT_HRS_LECTURE  is null)
                AND (X_CONTACT_HRS_LECTURE  is null)))
  AND ((tlinfo.CONTACT_HRS_LAB = X_CONTACT_HRS_LAB)
            OR ((tlinfo.CONTACT_HRS_LAB  is null)
                AND (X_CONTACT_HRS_LAB  is null)))
 AND ((tlinfo.CONTACT_HRS_OTHER = X_CONTACT_HRS_OTHER)
            OR ((tlinfo.CONTACT_HRS_OTHER  is null)
                AND (X_CONTACT_HRS_OTHER  is null)))
 AND ((tlinfo.NON_SCHD_REQUIRED_HRS = X_NON_SCHD_REQUIRED_HRS)
            OR ((tlinfo.NON_SCHD_REQUIRED_HRS  is null)
                AND (X_NON_SCHD_REQUIRED_HRS  is null)))
AND ((tlinfo.EXCLUDE_FROM_MAX_CP_LIMIT = X_EXCLUDE_FROM_MAX_CP_LIMIT)
            OR ((tlinfo.EXCLUDE_FROM_MAX_CP_LIMIT  is null)
                AND (X_EXCLUDE_FROM_MAX_CP_LIMIT  is null)))
AND ((tlinfo.claimable_hours = x_claimable_hours)
            OR ((tlinfo.claimable_hours  is null)
                AND (x_claimable_hours  is null)))
AND ((tlinfo.achievable_credit_points = x_achievable_credit_points)
            OR ((tlinfo.achievable_credit_points  is null)
                AND (x_achievable_credit_points  is null)))
AND ((tlinfo.enrolled_credit_points = x_enrolled_credit_points)
            OR ((tlinfo.enrolled_credit_points  is null)
                AND (x_enrolled_credit_points  is null)))
AND ((tlinfo.billing_credit_points = x_billing_credit_points)
            OR ((tlinfo.billing_credit_points  is null)
                AND (x_billing_credit_points  is null)))
AND ((tlinfo.BILLING_HRS= X_BILLING_HRS)
            OR ((tlinfo.BILLING_HRS IS NULL)
                AND (X_BILLING_HRS IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SEC_CREDIT_POINTS_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_MINIMUM_CREDIT_POINTS IN NUMBER,
       x_MAXIMUM_CREDIT_POINTS IN NUMBER,
       x_VARIABLE_INCREMENT IN NUMBER,
       x_LECTURE_CREDIT_POINTS IN NUMBER,
       x_LAB_CREDIT_POINTS IN NUMBER,
       x_OTHER_CREDIT_POINTS IN NUMBER,
       x_CLOCK_HOURS IN NUMBER,
       x_WORK_LOAD_CP_LECTURE IN NUMBER,
       x_WORK_LOAD_CP_LAB IN NUMBER,
       x_CONTINUING_EDUCATION_UNITS IN NUMBER,
       x_WORK_LOAD_OTHER IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LECTURE IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LAB IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_OTHER IN NUMBER DEFAULT NULL,
       x_NON_SCHD_REQUIRED_HRS IN NUMBER DEFAULT NULL,
       x_EXCLUDE_FROM_MAX_CP_LIMIT IN VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R',
       x_claimable_hours IN NUMBER DEFAULT NULL,
       x_achievable_credit_points IN NUMBER,
       x_enrolled_credit_points IN NUMBER  ,
       x_billing_credit_points IN NUMBER ,
       x_billing_hrs IN NUMBER
  ) AS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
   Before_DML(
                p_action=>'UPDATE',
                x_rowid=>X_ROWID,
               x_unit_sec_credit_points_id=>X_UNIT_SEC_CREDIT_POINTS_ID,
               x_uoo_id=>X_UOO_ID,
               x_minimum_credit_points=>X_MINIMUM_CREDIT_POINTS,
               x_maximum_credit_points=>X_MAXIMUM_CREDIT_POINTS,
               x_variable_increment=>X_VARIABLE_INCREMENT,
               x_lecture_credit_points=>X_LECTURE_CREDIT_POINTS,
               x_lab_credit_points=>X_LAB_CREDIT_POINTS,
               x_other_credit_points=>X_OTHER_CREDIT_POINTS,
               x_clock_hours=>X_CLOCK_HOURS,
               x_work_load_cp_lecture=>X_WORK_LOAD_CP_LECTURE,
               x_work_load_cp_lab=>X_WORK_LOAD_CP_LAB,
               x_continuing_education_units=>X_CONTINUING_EDUCATION_UNITS,
               x_work_load_other => X_WORK_LOAD_OTHER,
               x_contact_hrs_lecture => X_CONTACT_HRS_LECTURE,
               x_contact_hrs_lab => X_CONTACT_HRS_LAB,
               x_contact_hrs_other => X_CONTACT_HRS_OTHER,
               x_non_schd_required_hrs => X_NON_SCHD_REQUIRED_HRS,
               x_exclude_from_max_cp_limit => X_EXCLUDE_FROM_MAX_CP_LIMIT,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               X_last_update_login=>X_LAST_UPDATE_LOGIN,
              x_claimable_hours=>x_claimable_hours,
              x_achievable_credit_points=>x_achievable_credit_points,
              x_enrolled_credit_points=>x_enrolled_credit_points,
              x_billing_credit_points =>x_billing_credit_points,
              x_billing_hrs => x_billing_hrs
              );


   update IGS_PS_USEC_CPS set
      UOO_ID =  NEW_REFERENCES.UOO_ID,
      MINIMUM_CREDIT_POINTS =  NEW_REFERENCES.MINIMUM_CREDIT_POINTS,
      MAXIMUM_CREDIT_POINTS =  NEW_REFERENCES.MAXIMUM_CREDIT_POINTS,
      VARIABLE_INCREMENT =  NEW_REFERENCES.VARIABLE_INCREMENT,
      LECTURE_CREDIT_POINTS =  NEW_REFERENCES.LECTURE_CREDIT_POINTS,
      LAB_CREDIT_POINTS =  NEW_REFERENCES.LAB_CREDIT_POINTS,
      OTHER_CREDIT_POINTS =  NEW_REFERENCES.OTHER_CREDIT_POINTS,
      CLOCK_HOURS =  NEW_REFERENCES.CLOCK_HOURS,
      WORK_LOAD_CP_LECTURE =  NEW_REFERENCES.WORK_LOAD_CP_LECTURE,
      WORK_LOAD_CP_LAB =  NEW_REFERENCES.WORK_LOAD_CP_LAB,
      CONTINUING_EDUCATION_UNITS =  NEW_REFERENCES.CONTINUING_EDUCATION_UNITS,
      WORK_LOAD_OTHER = NEW_REFERENCES.WORK_LOAD_OTHER,
      CONTACT_HRS_LECTURE = NEW_REFERENCES.CONTACT_HRS_LECTURE,
      CONTACT_HRS_LAB = NEW_REFERENCES.CONTACT_HRS_LAB,
      CONTACT_HRS_OTHER = NEW_REFERENCES.CONTACT_HRS_OTHER,
      NON_SCHD_REQUIRED_HRS = NEW_REFERENCES.NON_SCHD_REQUIRED_HRS,
      EXCLUDE_FROM_MAX_CP_LIMIT = NEW_REFERENCES.EXCLUDE_FROM_MAX_CP_LIMIT,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      claimable_hours = new_references.claimable_hours,
      achievable_credit_points = new_references.achievable_credit_points,
      enrolled_credit_points = new_references.enrolled_credit_points ,
      billing_credit_points = new_references.billing_credit_points,
      billing_hrs = new_references.billing_hrs
  where ROWID = X_ROWID;
        if (sql%notfound) then
                raise no_data_found;
        end if;

 After_DML (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );
end UPDATE_ROW;

 procedure ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SEC_CREDIT_POINTS_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_MINIMUM_CREDIT_POINTS IN NUMBER,
       x_MAXIMUM_CREDIT_POINTS IN NUMBER,
       x_VARIABLE_INCREMENT IN NUMBER,
       x_LECTURE_CREDIT_POINTS IN NUMBER,
       x_LAB_CREDIT_POINTS IN NUMBER,
       x_OTHER_CREDIT_POINTS IN NUMBER,
       x_CLOCK_HOURS IN NUMBER,
       x_WORK_LOAD_CP_LECTURE IN NUMBER,
       x_WORK_LOAD_CP_LAB IN NUMBER,
       x_CONTINUING_EDUCATION_UNITS IN NUMBER,
       x_WORK_LOAD_OTHER IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LECTURE IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_LAB IN NUMBER DEFAULT NULL,
       x_CONTACT_HRS_OTHER IN NUMBER DEFAULT NULL,
       x_NON_SCHD_REQUIRED_HRS IN NUMBER DEFAULT NULL,
       x_EXCLUDE_FROM_MAX_CP_LIMIT IN VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'  ,
       x_claimable_hours IN NUMBER DEFAULT NULL,
       x_achievable_credit_points IN NUMBER,
       x_enrolled_credit_points IN NUMBER ,
       x_billing_credit_points IN NUMBER,
       x_billing_hrs IN NUMBER
  ) AS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_USEC_CPS
             where     UNIT_SEC_CREDIT_POINTS_ID= X_UNIT_SEC_CREDIT_POINTS_ID
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
       X_ROWID,
       X_UNIT_SEC_CREDIT_POINTS_ID,
       X_UOO_ID,
       X_MINIMUM_CREDIT_POINTS,
       X_MAXIMUM_CREDIT_POINTS,
       X_VARIABLE_INCREMENT,
       X_LECTURE_CREDIT_POINTS,
       X_LAB_CREDIT_POINTS,
       X_OTHER_CREDIT_POINTS,
       X_CLOCK_HOURS,
       X_WORK_LOAD_CP_LECTURE,
       X_WORK_LOAD_CP_LAB,
       X_CONTINUING_EDUCATION_UNITS,
       x_WORK_LOAD_OTHER ,
       x_CONTACT_HRS_LECTURE ,
       x_CONTACT_HRS_LAB ,
       x_CONTACT_HRS_OTHER ,
       x_NON_SCHD_REQUIRED_HRS ,
       x_EXCLUDE_FROM_MAX_CP_LIMIT ,
       X_MODE,
       x_claimable_hours,
       x_achievable_credit_points,
       x_enrolled_credit_points,
       x_billing_credit_points,
       x_billing_hrs );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_SEC_CREDIT_POINTS_ID,
       X_UOO_ID,
       X_MINIMUM_CREDIT_POINTS,
       X_MAXIMUM_CREDIT_POINTS,
       X_VARIABLE_INCREMENT,
       X_LECTURE_CREDIT_POINTS,
       X_LAB_CREDIT_POINTS,
       X_OTHER_CREDIT_POINTS,
       X_CLOCK_HOURS,
       X_WORK_LOAD_CP_LECTURE,
       X_WORK_LOAD_CP_LAB,
       X_CONTINUING_EDUCATION_UNITS,
       x_WORK_LOAD_OTHER ,
       x_CONTACT_HRS_LECTURE ,
       x_CONTACT_HRS_LAB ,
       x_CONTACT_HRS_OTHER ,
       x_NON_SCHD_REQUIRED_HRS ,
       x_EXCLUDE_FROM_MAX_CP_LIMIT ,
       X_MODE,
       x_claimable_hours,
       x_achievable_credit_points,
       x_enrolled_credit_points,
       x_billing_credit_points,
       x_billing_hrs);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By :  shgeorge
  Date Created By :  10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_PS_USEC_CPS
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
END DELETE_ROW;
END igs_ps_usec_cps_pkg;

/
