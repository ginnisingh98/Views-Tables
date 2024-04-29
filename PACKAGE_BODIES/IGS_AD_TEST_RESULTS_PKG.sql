--------------------------------------------------------
--  DDL for Package Body IGS_AD_TEST_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TEST_RESULTS_PKG" AS
/* $Header: IGSAI79B.pls 120.3 2005/08/05 05:55:13 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_test_results%RowType;
  new_references igs_ad_test_results%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_test_results_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_test_type IN VARCHAR2 DEFAULT NULL,
    x_test_date IN DATE DEFAULT NULL,
    x_score_report_date IN DATE DEFAULT NULL,
    x_edu_level_id IN NUMBER DEFAULT NULL,
    x_score_type IN VARCHAR2 DEFAULT NULL,
    x_score_source_id IN NUMBER DEFAULT NULL,
    x_non_standard_admin IN VARCHAR2 DEFAULT NULL,
    x_comp_test_score IN NUMBER DEFAULT NULL,
    x_special_code IN VARCHAR2 DEFAULT NULL,
    x_registration_number IN VARCHAR2 DEFAULT NULL,
    x_grade_id IN NUMBER DEFAULT NULL,
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
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_active_ind IN VARCHAR2 DEFAULT NULL

  ) AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_TEST_RESULTS
      WHERE    rowid = x_rowid;

    CURSOR score_type_cur(cp_admission_test_type VARCHAR2) IS
    SELECT score_type
    FROM igs_ad_test_type
    WHERE admission_test_type = cp_admission_test_type;

    l_score_type igs_ad_test_type.score_type%TYPE;
  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('IGS', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.test_results_id := x_test_results_id;
    new_references.person_id := x_person_id;
    new_references.admission_test_type := x_admission_test_type;
    new_references.test_date := TRUNC(x_test_date);
    new_references.score_report_date := TRUNC(x_score_report_date);
    new_references.edu_level_id := x_edu_level_id;

    IF x_score_type IS NOT NULL THEN
      new_references.score_type := x_score_type;
    ELSE
      OPEN score_type_cur(x_admission_test_type);
      FETCH score_type_cur INTO l_score_type;
      CLOSE score_type_cur;

      new_references.score_type := l_score_type;
    END IF;

    new_references.score_source_id := x_score_source_id;
    new_references.non_standard_admin := x_non_standard_admin;
    new_references.comp_test_score := x_comp_test_score;
    new_references.special_code := x_special_code;
    new_references.registration_number := x_registration_number;
    new_references.grade_id := x_grade_id;
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
    new_references.active_ind  := x_active_ind ;
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

  PROCEDURE Check_Constraints (
         Column_Name IN VARCHAR2  DEFAULT NULL,
         Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  nshee 25-JUL-2002   commented the tochar(todate(<date>,FMT)FMT)
  conversion of score_Report_date which was giving problems.
  ***************************************************************/
    l_column_value  VARCHAR2(2000);
  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'TEST_DATE'  THEN
        new_references.test_date := IGS_GE_DATE.IGSDATE(column_value);
      ELSIF  UPPER(column_name) = 'SCORE_REPORT_DATE'  THEN
--      l_column_value := tochar( todate ( column_value, 'DD/MM/YYYY'), 'YYYY/MM/DD');
        new_references.score_report_date := IGS_GE_DATE.IGSDATE(l_column_value);
      ELSIF  UPPER(column_name) = 'NON_STANDARD_ADMIN'  THEN
        new_references.non_standard_admin := column_value;
        NULL;
      END IF;

    -- The following code checks for check constraints on the Columns.

      IF Upper(Column_Name) = 'SCORE_REPORT_DATE' OR
        Column_Name IS NULL THEN
        IF TRUNC(new_references.score_report_date) > TRUNC(sysdate)  OR
         TRUNC(new_references.score_report_date) < TRUNC(new_references.test_date)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SCORE_RPT_DATE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'NON_STANDARD_ADMIN' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.non_standard_admin in ('Y','N'))  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_NON_STANDARD_ADMIN'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.edu_level_id = new_references.edu_level_id)) OR
        ((new_references.edu_level_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                new_references.edu_level_id,
                        'EDU_LEVEL',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EDU_LEVEL'));
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.admission_test_type = new_references.admission_test_type)) OR
        ((new_references.admission_test_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Test_Type_Pkg.Get_PK_For_Validation (
                new_references.admission_test_type,
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_TEST'));
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.grade_id = new_references.grade_id)) OR
        ((new_references.grade_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                new_references.grade_id,
                        'TEST_RESULTS_GRADE',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_GRADE'));
         IGS_GE_MSG_STACK.ADD;
    END IF;

    IF (((old_references.score_source_id = new_references.score_source_id)) OR
        ((new_references.score_source_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                new_references.score_source_id,
                        'SYS_SCORE_SOURCE',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SCORE_SOURCE'));
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
                new_references.person_id
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON'));
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.score_type = new_references.score_type)) OR
        ((new_references.score_type IS NULL))) THEN
      NULL;
    ELSE
    IF  NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
         'TEST_SCORE_TYPE',
         new_references.score_type
    ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SCORE_TYPE'));
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
     END IF;
    END IF;

    IF (((old_references.special_code = new_references.special_code)) OR
        ((new_references.special_code IS NULL))) THEN
      NULL;
    ELSE
    IF  NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
         'TEST_SPECIAL_CODE',
         new_references.special_code
    ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_GE_SPECIAL'));
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
     END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ad_Tst_Rslt_Dtls_Pkg.Get_FK_Igs_Ad_Test_Results (
      old_references.test_results_id
      );

  END Check_Child_Existance;


  PROCEDURE Check_Child_For_Update  AS

  /*************************************************************
  Created By : Adarsh Padegal
  Date Created By : 28 Dec 2004
  Purpose : To check if child records are available while updating
  the parent record.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         21-Jul-2005     Bug 4327807 (Person SS Enhancement)
                                  Added the check that test date can't be a future date when child records exist
   (Reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid(cp_test_results_id NUMBER) IS
      SELECT   rowid
      FROM     igs_ad_tst_rslt_dtls
      WHERE    test_results_id = cp_test_results_id;

    lv_rowid cur_rowid%RowType;

  BEGIN
  IF old_references.admission_test_type <> new_references.admission_test_type THEN
    Open cur_rowid(old_references.test_results_id);
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRD_ATR_UPD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END IF;

   IF new_references.test_date <> old_references.test_date THEN
     Open cur_rowid(old_references.test_results_id);
     Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
  		IF (new_references.test_date > TRUNC(SYSDATE)) THEN
            Close cur_rowid;
			Fnd_Message.Set_Name ('IGS', 'IGS_SS_AD_SEG_NOT_IN_FUTURE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
      END IF;
      Close cur_rowid;
   END IF;

  END  Check_Child_For_Update;

  PROCEDURE beforerowinsertupdate(p_inserting BOOLEAN,p_updating BOOLEAN) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 6-Jun-2005
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR get_dob_dt_cur(cp_person_id igs_pe_passport.person_id%TYPE)
  IS
  SELECT birth_date
  FROM  igs_pe_person_base_v
  WHERE person_id = cp_person_id;

  l_birth_dt igs_pe_person_base_v.birth_date%TYPE;
  BEGIN
    IF p_inserting or p_updating THEN
         OPEN get_dob_dt_cur(new_references.person_id);
         FETCH get_dob_dt_cur INTO l_birth_dt;
         CLOSE get_dob_dt_cur;

         IF l_birth_dt IS NOT NULL AND new_references.test_date IS NOT NULL THEN
            IF l_birth_dt > new_references.test_date THEN
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
         END IF;
    END IF;
  END beforerowinsertupdate;

  FUNCTION Get_PK_For_Validation (
    x_test_results_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_test_results
      WHERE    test_results_id = x_test_results_id
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

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_test_results
      WHERE    edu_level_id = x_code_id ;

    CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     igs_ad_test_results
      WHERE    grade_id = x_code_id ;

    CURSOR cur_rowid3 IS
      SELECT   rowid
      FROM     igs_ad_test_results
      WHERE    score_source_id = x_code_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATR_ACDC_FK2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

    Open cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid;
    IF (cur_rowid2%FOUND) THEN
      Close cur_rowid2;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATR_ACDC_FK3');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid2;

    Open cur_rowid3;
    Fetch cur_rowid3 INTO lv_rowid;
    IF (cur_rowid3%FOUND) THEN
      Close cur_rowid3;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATR_ACDC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid3;
  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Get_FK_Igs_Ad_Test_Type (
    x_admission_test_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_test_results
      WHERE    admission_test_type = x_admission_test_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATR_ADMTT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Test_Type;


  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_test_results
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_PE_PERSON_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_test_results_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_test_type IN VARCHAR2 DEFAULT NULL,
    x_test_date IN DATE DEFAULT NULL,
    x_score_report_date IN DATE DEFAULT NULL,
    x_edu_level_id IN NUMBER DEFAULT NULL,
    x_score_type IN VARCHAR2 DEFAULT NULL,
    x_score_source_id IN NUMBER DEFAULT NULL,
    x_non_standard_admin IN VARCHAR2 DEFAULT NULL,
    x_comp_test_score IN NUMBER DEFAULT NULL,
    x_special_code IN VARCHAR2 DEFAULT NULL,
    x_registration_number IN VARCHAR2 DEFAULT NULL,
    x_grade_id IN NUMBER DEFAULT NULL,
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
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_active_ind IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  APADEGAL    10-JAN-2005     To check if the child records exist
  before the update of parent record.

  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_test_results_id,
      x_person_id,
      x_admission_test_type,
      x_test_date,
      x_score_report_date,
      x_edu_level_id,
      x_score_type,
      x_score_source_id,
      x_non_standard_admin,
      x_comp_test_score,
      x_special_code,
      x_registration_number,
      x_grade_id,
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
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_active_ind
    );


    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      beforerowinsertupdate(TRUE, FALSE);
         IF Get_Pk_For_Validation(
            new_references.test_results_id)  THEN
           Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
         END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforerowinsertupdate(FALSE, TRUE);
      Check_Constraints;
      Check_Parent_Existance;

      Check_Child_For_Update;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
     -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
            new_references.test_results_id)  THEN
           Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
         END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
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
      --Raise the buisness event
      igs_ad_wf_001.TESTSCORE_CRT_EVENT
      (
        P_TEST_RESULTS_ID     =>   new_references.test_results_id,
        P_PERSON_ID           =>   new_references.person_id,
        P_ACTIVE_IND          =>   new_references.active_ind
      );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      --Raise the buisness event
      igs_ad_wf_001.TESTSCORE_UPD_EVENT
      (
        P_TEST_RESULTS_ID            =>    new_references.test_results_id,
        P_PERSON_ID                  =>    new_references.person_id,
        P_ACTIVE_IND_NEW             =>    new_references.active_ind,
        P_ACTIVE_IND_OLD             =>    old_references.active_ind,
        P_ADMISSION_TEST_TYPE_NEW    =>    new_references.admission_test_type,
        P_ADMISSION_TEST_TYPE_OLD    =>    old_references.admission_test_type,
        P_GRADE_ID_NEW               =>    new_references.grade_id,
        P_GRADE_ID_OLD               =>    old_references.grade_id,
        P_COMP_TEST_SCORE_NEW        =>    new_references.comp_test_score,
        P_COMP_TEST_SCORE_OLD        =>    old_references.comp_test_score
      );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TEST_RESULTS_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_DATE IN DATE,
       x_SCORE_REPORT_DATE IN DATE,
       x_EDU_LEVEL_ID IN NUMBER,
       x_SCORE_TYPE IN VARCHAR2,
       x_SCORE_SOURCE_ID IN NUMBER,
       x_NON_STANDARD_ADMIN IN VARCHAR2,
       x_COMP_TEST_SCORE IN NUMBER,
       x_SPECIAL_CODE IN VARCHAR2,
       x_REGISTRATION_NUMBER IN VARCHAR2,
       x_GRADE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
      X_MODE in VARCHAR2,
      x_ACTIVE_IND IN VARCHAR2 default  NULL
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
                  GSCC standard says that default value should be
                  present only in specification

  (reverse chronological order - newest change first)
  pbondugu     03-04-2003        For test_date and score_report_date  trunc of those fileds are inserted into tables.

  ***************************************************************/

    cursor C is select ROWID from IGS_AD_TEST_RESULTS
             where                 TEST_RESULTS_ID= X_TEST_RESULTS_ID;

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
     L_MODE VARCHAR2(1);
 begin
    L_MODE := NVL(X_MODE,'R');
    X_LAST_UPDATE_DATE := SYSDATE;
    if(L_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (L_MODE = 'R') then
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
      if (X_REQUEST_ID =  -1) then
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

   X_TEST_RESULTS_ID := -1;
   Before_DML(
        p_action=>'INSERT',
        x_rowid=>X_ROWID,
           x_test_results_id=>X_TEST_RESULTS_ID,
           x_person_id=>X_PERSON_ID,
           x_admission_test_type=>X_ADMISSION_TEST_TYPE,
           x_test_date=>X_TEST_DATE,
           x_score_report_date=>X_SCORE_REPORT_DATE,
           x_edu_level_id=>X_EDU_LEVEL_ID,
           x_score_type=>X_SCORE_TYPE,
           x_score_source_id=>X_SCORE_SOURCE_ID,
           x_non_standard_admin=>X_NON_STANDARD_ADMIN,
           x_comp_test_score=>X_COMP_TEST_SCORE,
           x_special_code=>X_SPECIAL_CODE,
           x_registration_number=>X_REGISTRATION_NUMBER,
           x_grade_id=>X_GRADE_ID,
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
           x_attribute20=>X_ATTRIBUTE20,
           x_creation_date=>X_LAST_UPDATE_DATE,
           x_created_by=>X_LAST_UPDATED_BY,
           x_last_update_date=>X_LAST_UPDATE_DATE,
           x_last_updated_by=>X_LAST_UPDATED_BY,
           x_last_update_login=>X_LAST_UPDATE_LOGIN,
           x_active_ind => X_ACTIVE_IND );
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_TEST_RESULTS (
        TEST_RESULTS_ID
        ,PERSON_ID
        ,ADMISSION_TEST_TYPE
        ,TEST_DATE
        ,SCORE_REPORT_DATE
        ,EDU_LEVEL_ID
        ,SCORE_TYPE
        ,SCORE_SOURCE_ID
        ,NON_STANDARD_ADMIN
        ,COMP_TEST_SCORE
        ,SPECIAL_CODE
        ,REGISTRATION_NUMBER
        ,GRADE_ID
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,ATTRIBUTE16
        ,ATTRIBUTE17
        ,ATTRIBUTE18
        ,ATTRIBUTE19
        ,ATTRIBUTE20
            ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,REQUEST_ID
        ,PROGRAM_ID
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_UPDATE_DATE
        ,ACTIVE_IND
        ) values  (
             IGS_AD_TEST_RESULTS_S.NEXTVAL
            ,NEW_REFERENCES.PERSON_ID
            ,NEW_REFERENCES.ADMISSION_TEST_TYPE
            ,NEW_REFERENCES.TEST_DATE
            ,NEW_REFERENCES.SCORE_REPORT_DATE
            ,NEW_REFERENCES.EDU_LEVEL_ID
            ,NEW_REFERENCES.SCORE_TYPE
            ,NEW_REFERENCES.SCORE_SOURCE_ID
            ,NEW_REFERENCES.NON_STANDARD_ADMIN
            ,NEW_REFERENCES.COMP_TEST_SCORE
            ,NEW_REFERENCES.SPECIAL_CODE
            ,NEW_REFERENCES.REGISTRATION_NUMBER
            ,NEW_REFERENCES.GRADE_ID
            ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
            ,NEW_REFERENCES.ATTRIBUTE1
            ,NEW_REFERENCES.ATTRIBUTE2
            ,NEW_REFERENCES.ATTRIBUTE3
            ,NEW_REFERENCES.ATTRIBUTE4
            ,NEW_REFERENCES.ATTRIBUTE5
            ,NEW_REFERENCES.ATTRIBUTE6
            ,NEW_REFERENCES.ATTRIBUTE7
            ,NEW_REFERENCES.ATTRIBUTE8
            ,NEW_REFERENCES.ATTRIBUTE9
            ,NEW_REFERENCES.ATTRIBUTE10
            ,NEW_REFERENCES.ATTRIBUTE11
            ,NEW_REFERENCES.ATTRIBUTE12
            ,NEW_REFERENCES.ATTRIBUTE13
            ,NEW_REFERENCES.ATTRIBUTE14
            ,NEW_REFERENCES.ATTRIBUTE15
            ,NEW_REFERENCES.ATTRIBUTE16
            ,NEW_REFERENCES.ATTRIBUTE17
            ,NEW_REFERENCES.ATTRIBUTE18
            ,NEW_REFERENCES.ATTRIBUTE19
            ,NEW_REFERENCES.ATTRIBUTE20
            ,X_LAST_UPDATE_DATE
        ,X_LAST_UPDATED_BY
        ,X_LAST_UPDATE_DATE
        ,X_LAST_UPDATED_BY
        ,X_LAST_UPDATE_LOGIN
        ,X_REQUEST_ID
        ,X_PROGRAM_ID
        ,X_PROGRAM_APPLICATION_ID
        ,X_PROGRAM_UPDATE_DATE
        ,NEW_REFERENCES.ACTIVE_IND
)RETURNING TEST_RESULTS_ID INTO X_TEST_RESULTS_ID;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    NEW_REFERENCES.TEST_RESULTS_ID := X_TEST_RESULTS_ID;
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
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_TEST_RESULTS_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_DATE IN DATE,
       x_SCORE_REPORT_DATE IN DATE,
       x_EDU_LEVEL_ID IN NUMBER,
       x_SCORE_TYPE IN VARCHAR2,
       x_SCORE_SOURCE_ID IN NUMBER,
       x_NON_STANDARD_ADMIN IN VARCHAR2,
       x_COMP_TEST_SCORE IN NUMBER,
       x_SPECIAL_CODE IN VARCHAR2,
       x_REGISTRATION_NUMBER IN VARCHAR2,
       x_GRADE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_ACTIVE_IND IN VARCHAR2  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  pbondugu     03-04-2003        For test_date and score_report_date check is done for trunc of those fileds
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      ADMISSION_TEST_TYPE
,      TEST_DATE
,      SCORE_REPORT_DATE
,      EDU_LEVEL_ID
,      SCORE_TYPE
,      SCORE_SOURCE_ID
,      NON_STANDARD_ADMIN
,      COMP_TEST_SCORE
,      SPECIAL_CODE
,      REGISTRATION_NUMBER
,      GRADE_ID
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
,      ACTIVE_IND
    from IGS_AD_TEST_RESULTS
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
if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.ADMISSION_TEST_TYPE = X_ADMISSION_TEST_TYPE)
  AND (trunc(tlinfo.TEST_DATE) = trunc(X_TEST_DATE))
  AND ((trunc(tlinfo.SCORE_REPORT_DATE) = trunc(X_SCORE_REPORT_DATE))
        OR ((tlinfo.SCORE_REPORT_DATE is null)
        AND (X_SCORE_REPORT_DATE is null)))
  AND ((tlinfo.EDU_LEVEL_ID = X_EDU_LEVEL_ID)
        OR ((tlinfo.EDU_LEVEL_ID is null)
        AND (X_EDU_LEVEL_ID is null)))
  AND ((tlinfo.SCORE_TYPE = X_SCORE_TYPE)
        OR ((tlinfo.SCORE_TYPE is null)
        AND (X_SCORE_TYPE is null)))
  AND ((tlinfo.SCORE_SOURCE_ID = X_SCORE_SOURCE_ID)
        OR ((tlinfo.SCORE_SOURCE_ID is null)
        AND (X_SCORE_SOURCE_ID is null)))
  AND ((tlinfo.NON_STANDARD_ADMIN = X_NON_STANDARD_ADMIN)
        OR ((tlinfo.NON_STANDARD_ADMIN is null)
        AND (X_NON_STANDARD_ADMIN is null)))
  AND ((tlinfo.COMP_TEST_SCORE = X_COMP_TEST_SCORE)
        OR ((tlinfo.COMP_TEST_SCORE is null)
        AND (X_COMP_TEST_SCORE is null)))
  AND ((tlinfo.SPECIAL_CODE = X_SPECIAL_CODE)
        OR ((tlinfo.SPECIAL_CODE is null)
        AND (X_SPECIAL_CODE is null)))
  AND ((tlinfo.REGISTRATION_NUMBER = X_REGISTRATION_NUMBER)
        OR ((tlinfo.REGISTRATION_NUMBER is null)
        AND (X_REGISTRATION_NUMBER is null)))
  AND ((tlinfo.GRADE_ID = X_GRADE_ID)
        OR ((tlinfo.GRADE_ID is null)
        AND (X_GRADE_ID is null)))
  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
        OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
        AND (X_ATTRIBUTE_CATEGORY is null)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
        OR ((tlinfo.ATTRIBUTE1 is null)
        AND (X_ATTRIBUTE1 is null)))
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
        OR ((tlinfo.ATTRIBUTE2 is null)
        AND (X_ATTRIBUTE2 is null)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
        OR ((tlinfo.ATTRIBUTE3 is null)
        AND (X_ATTRIBUTE3 is null)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
        OR ((tlinfo.ATTRIBUTE4 is null)
        AND (X_ATTRIBUTE4 is null)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
        OR ((tlinfo.ATTRIBUTE5 is null)
        AND (X_ATTRIBUTE5 is null)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
        OR ((tlinfo.ATTRIBUTE6 is null)
        AND (X_ATTRIBUTE6 is null)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
        OR ((tlinfo.ATTRIBUTE7 is null)
        AND (X_ATTRIBUTE7 is null)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
        OR ((tlinfo.ATTRIBUTE8 is null)
        AND (X_ATTRIBUTE8 is null)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
        OR ((tlinfo.ATTRIBUTE9 is null)
        AND (X_ATTRIBUTE9 is null)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
        OR ((tlinfo.ATTRIBUTE10 is null)
        AND (X_ATTRIBUTE10 is null)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
        OR ((tlinfo.ATTRIBUTE11 is null)
        AND (X_ATTRIBUTE11 is null)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
        OR ((tlinfo.ATTRIBUTE12 is null)
        AND (X_ATTRIBUTE12 is null)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
        OR ((tlinfo.ATTRIBUTE13 is null)
        AND (X_ATTRIBUTE13 is null)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
        OR ((tlinfo.ATTRIBUTE14 is null)
        AND (X_ATTRIBUTE14 is null)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
        OR ((tlinfo.ATTRIBUTE15 is null)
        AND (X_ATTRIBUTE15 is null)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
        OR ((tlinfo.ATTRIBUTE16 is null)
        AND (X_ATTRIBUTE16 is null)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
        OR ((tlinfo.ATTRIBUTE17 is null)
        AND (X_ATTRIBUTE17 is null)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
        OR ((tlinfo.ATTRIBUTE18 is null)
        AND (X_ATTRIBUTE18 is null)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
        OR ((tlinfo.ATTRIBUTE19 is null)
        AND (X_ATTRIBUTE19 is null)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
        OR ((tlinfo.ATTRIBUTE20 is null)
        AND (X_ATTRIBUTE20 is null)))
  AND ((tlinfo.ACTIVE_IND = X_ACTIVE_IND)
        OR ((tlinfo.ACTIVE_IND is null)
        AND (X_ACTIVE_IND is null)))
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
       x_TEST_RESULTS_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_DATE IN DATE,
       x_SCORE_REPORT_DATE IN DATE,
       x_EDU_LEVEL_ID IN NUMBER,
       x_SCORE_TYPE IN VARCHAR2,
       x_SCORE_SOURCE_ID IN NUMBER,
       x_NON_STANDARD_ADMIN IN VARCHAR2,
       x_COMP_TEST_SCORE IN NUMBER,
       x_SPECIAL_CODE IN VARCHAR2,
       x_REGISTRATION_NUMBER IN VARCHAR2,
       x_GRADE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_MODE in VARCHAR2,
       x_ACTIVE_IND IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
                  GSCC standard says that default value should be
                  present only in specification

  pbondugu     03-04-2003        For test_date and score_report_date  trunc of those fileds are updated into table.

  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
     L_MODE VARCHAR2(1);
 begin
     L_MODE := NVL(X_MODE,'R');
    X_LAST_UPDATE_DATE := SYSDATE;
    if(L_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (L_MODE = 'R') then
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
           x_test_results_id=>X_TEST_RESULTS_ID,
           x_person_id=>X_PERSON_ID,
           x_admission_test_type=>X_ADMISSION_TEST_TYPE,
           x_test_date=>X_TEST_DATE,
           x_score_report_date=>X_SCORE_REPORT_DATE,
           x_edu_level_id=>X_EDU_LEVEL_ID,
           x_score_type=>X_SCORE_TYPE,
           x_score_source_id=>X_SCORE_SOURCE_ID,
           x_non_standard_admin=>X_NON_STANDARD_ADMIN,
           x_comp_test_score=>X_COMP_TEST_SCORE,
           x_special_code=>X_SPECIAL_CODE,
           x_registration_number=>X_REGISTRATION_NUMBER,
           x_grade_id=>X_GRADE_ID,
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
           x_attribute20=>X_ATTRIBUTE20,
           x_creation_date=>X_LAST_UPDATE_DATE,
           x_created_by=>X_LAST_UPDATED_BY,
           x_last_update_date=>X_LAST_UPDATE_DATE,
           x_last_updated_by=>X_LAST_UPDATED_BY,
           x_last_update_login=>X_LAST_UPDATE_LOGIN,
           x_active_ind => X_ACTIVE_IND);

    if (L_MODE = 'R') then
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID = -1) then
        X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
        X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
        X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    end if;

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_AD_TEST_RESULTS set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      ADMISSION_TEST_TYPE =  NEW_REFERENCES.ADMISSION_TEST_TYPE,
      TEST_DATE =  NEW_REFERENCES.TEST_DATE,
      SCORE_REPORT_DATE =  NEW_REFERENCES.SCORE_REPORT_DATE,
      EDU_LEVEL_ID =  NEW_REFERENCES.EDU_LEVEL_ID,
      SCORE_TYPE =  NEW_REFERENCES.SCORE_TYPE,
      SCORE_SOURCE_ID =  NEW_REFERENCES.SCORE_SOURCE_ID,
      NON_STANDARD_ADMIN =  NEW_REFERENCES.NON_STANDARD_ADMIN,
      COMP_TEST_SCORE =  NEW_REFERENCES.COMP_TEST_SCORE,
      SPECIAL_CODE =  NEW_REFERENCES.SPECIAL_CODE,
      REGISTRATION_NUMBER =  NEW_REFERENCES.REGISTRATION_NUMBER,
      GRADE_ID =  NEW_REFERENCES.GRADE_ID,
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
      ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    ACTIVE_IND = NEW_REFERENCES.ACTIVE_IND
      where ROWID = X_ROWID;
    if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
    end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


 After_DML (
    p_action => 'UPDATE' ,
    x_rowid => X_ROWID
    );
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TEST_RESULTS_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_DATE IN DATE,
       x_SCORE_REPORT_DATE IN DATE,
       x_EDU_LEVEL_ID IN NUMBER,
       x_SCORE_TYPE IN VARCHAR2,
       x_SCORE_SOURCE_ID IN NUMBER,
       x_NON_STANDARD_ADMIN IN VARCHAR2,
       x_COMP_TEST_SCORE IN NUMBER,
       x_SPECIAL_CODE IN VARCHAR2,
       x_REGISTRATION_NUMBER IN VARCHAR2,
       x_GRADE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
      X_MODE in VARCHAR2,
      x_ACTIVE_IND IN  VARCHAR2
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
                  GSCC standard says that default value should be
                  present only in specification
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_TEST_RESULTS
             where     TEST_RESULTS_ID= X_TEST_RESULTS_ID
;
  L_MODE VARCHAR2(1);
begin
  L_MODE := NVL(X_MODE,'R');
    open c1;
        fetch c1 into X_ROWID;
    if (c1%notfound) then
    close c1;
    INSERT_ROW (
      X_ROWID,
       X_TEST_RESULTS_ID,
       X_PERSON_ID,
       X_ADMISSION_TEST_TYPE,
       X_TEST_DATE,
       X_SCORE_REPORT_DATE,
       X_EDU_LEVEL_ID,
       X_SCORE_TYPE,
       X_SCORE_SOURCE_ID,
       X_NON_STANDARD_ADMIN,
       X_COMP_TEST_SCORE,
       X_SPECIAL_CODE,
       X_REGISTRATION_NUMBER,
       X_GRADE_ID,
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
       X_ATTRIBUTE20,
      L_MODE,
      X_ACTIVE_IND);
     return;
    end if;
       close c1;
UPDATE_ROW (
      X_ROWID,
       X_TEST_RESULTS_ID,
       X_PERSON_ID,
       X_ADMISSION_TEST_TYPE,
       X_TEST_DATE,
       X_SCORE_REPORT_DATE,
       X_EDU_LEVEL_ID,
       X_SCORE_TYPE,
       X_SCORE_SOURCE_ID,
       X_NON_STANDARD_ADMIN,
       X_COMP_TEST_SCORE,
       X_SPECIAL_CODE,
       X_REGISTRATION_NUMBER,
       X_GRADE_ID,
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
       X_ATTRIBUTE20,
      L_MODE,
      X_ACTIVE_IND );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By : 15-May-2000
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
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_TEST_RESULTS
 where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ad_test_results_pkg;

/
