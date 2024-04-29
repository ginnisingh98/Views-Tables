--------------------------------------------------------
--  DDL for Package Body IGS_FI_EXT_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_EXT_INT_PKG" AS
/* $Header: IGSSI79B.pls 115.23 2003/06/26 10:01:03 vvutukur ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_fi_ext_int_all%ROWTYPE;
  new_references igs_fi_ext_int_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_external_fee_id IN NUMBER ,
    x_person_id IN NUMBER ,
    x_status IN VARCHAR2 ,
    x_fee_type IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_crs_version_number IN NUMBER ,
    x_transaction_amount IN NUMBER ,
    x_currency_cd IN VARCHAR2 ,
    x_exchange_rate IN NUMBER ,
    x_effective_dt IN DATE ,
    x_comments IN VARCHAR2 ,
    x_logical_delete_dt IN DATE ,
    x_org_id IN NUMBER ,
    x_override_dr_rec_account_cd        IN     VARCHAR2    ,
    x_override_dr_rec_ccid              IN     NUMBER      ,
    x_override_cr_rev_account_cd        IN     VARCHAR2    ,
    x_override_cr_rev_ccid              IN     NUMBER      ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_attribute16                       IN     VARCHAR2    ,
    x_attribute17                       IN     VARCHAR2    ,
    x_attribute18                       IN     VARCHAR2    ,
    x_attribute19                       IN     VARCHAR2    ,
    x_attribute20                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_gl_date                           IN     DATE        ,
    x_error_msg                         IN     VARCHAR2
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     25-Jun-2003     Bug#2777502,2715795.Added error_msg column.
  smadathi     06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. Removed DEFAULT clause
  vvutukur     29-Jul-2002     Bug2425767.Removed references to chg_rate,chg_elements,transaction_type
                               columns as these columns are obsolete.
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_EXT_INT_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.external_fee_id := x_external_fee_id;
    new_references.person_id := x_person_id;
    new_references.status := x_status;
    new_references.fee_type := x_fee_type;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;

-- The columns course_cd and crs_version_number are obsolete.
-- Hence, we logically ignore them, as a part of changes due to Revised DLD
-- IGSFIDL3: Version 3

    new_references.course_cd := NULL;
    new_references.crs_version_number := NULL;
    new_references.transaction_amount := x_transaction_amount;
    new_references.currency_cd := x_currency_cd;
    new_references.exchange_rate := x_exchange_rate;
    new_references.effective_dt := x_effective_dt;
    new_references.comments := x_comments;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.override_dr_rec_account_cd        := x_override_dr_rec_account_cd;
    new_references.override_dr_rec_ccid              := x_override_dr_rec_ccid;
    new_references.override_cr_rev_account_cd        := x_override_cr_rev_account_cd;
    new_references.override_cr_rev_ccid              := x_override_cr_rev_ccid;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;
    new_references.org_id                            := x_org_id;
    new_references.gl_date                           := TRUNC(x_gl_date);
    new_references.error_msg                         := x_error_msg;

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

  END set_column_values;

 PROCEDURE Check_Constraints (
    Column_name  IN VARCHAR2 ,
    Column_value IN VARCHAR2
  ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     29-Jul-2002     Bug2425767.Removed references to chg_rate,chg_elements
                               columns as these columns are obsolete.
  ***************************************************************/
  BEGIN
        IF Column_name IS NULL then
                NULL;
        Elsif upper(Column_name) = 'STATUS' Then
                new_references.status := Column_value;
        Elsif upper(Column_name) = 'EXCHANGE_RATE' Then
                new_references.EXCHANGE_RATE  := igs_ge_number.to_num(Column_value);
        End if;

    -- The following code checks for check constraints on the Columns.
        IF upper(Column_name)=  'STATUS' or Column_name is null Then
                IF  new_references.status NOT IN ('TODO',
                                                  'SUCCESS',
                                                  'ERROR') THEN
                     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF upper(Column_name)=  'EXCHANGE_RATE'  or Column_name is null Then
                If  new_references.EXCHANGE_RATE <= 0 then
                     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                End if;
        End if;

  END Check_Constraints;

 PROCEDURE check_uniqueness AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
 /*  IF get_uk_for_validation (
 ||             new_references.fee_ci_sequence_number
 ||             ,new_references.fee_cal_type
 ||             ,new_references.person_id
 ||             ,new_references.fee_type
 ||             ) THEN
 ||             fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
 ||    igs_ge_msg_stack.add;
 ||                     app_exception.raise_exception;
 ||             END IF;
 */ ----Commented whole code as not needed anymore as indicated in Ancillary and External Charges by nshee
   null;
 END check_uniqueness ;


 FUNCTION get_pk_for_validation (
   x_external_fee_id IN NUMBER
   ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ext_int_all
      WHERE    external_fee_id = x_external_fee_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_pk_for_validation;

 FUNCTION get_uk_for_validation (
   x_fee_ci_sequence_number IN NUMBER,
    x_fee_cal_type IN VARCHAR2,
    x_person_id IN NUMBER,
    x_fee_type IN VARCHAR2
   ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ext_int_all
      WHERE    fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_cal_type = x_fee_cal_type
      AND      person_id = x_person_id
      AND      fee_type = x_fee_type    and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
    lv_rowid cur_rowid%RowType;

  BEGIN
/*
||    OPEN cur_rowid;
||    FETCH cur_rowid INTO lv_rowid;
||    IF (cur_rowid%FOUND) THEN
||      CLOSE cur_rowid;
||        RETURN (true);
||        ELSE
||       CLOSE cur_rowid;
||      RETURN(FALSE);
||    END IF;
*/----Commented whole code as not needed anymore as indicated in Ancillary and External Charges by nshee
  NULL;
  END get_uk_for_validation ;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF ((old_references.override_cr_rev_account_cd = new_references.override_cr_rev_account_cd) OR
         (new_references.override_cr_rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.override_cr_rev_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((old_references.override_dr_rec_account_cd = new_references.override_dr_rec_account_cd) OR
         (new_references.override_dr_rec_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.override_dr_rec_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF (((old_references.status = new_references.status)) OR
        ((new_references.status IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'STATUS',
          new_references.status
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;

 PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_external_fee_id IN NUMBER ,
    x_person_id IN NUMBER ,
    x_status IN VARCHAR2 ,
    x_fee_type IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_crs_version_number IN NUMBER ,
    x_transaction_amount IN NUMBER ,
    x_currency_cd IN VARCHAR2 ,
    x_exchange_rate IN NUMBER ,
    x_effective_dt IN DATE ,
    x_comments IN VARCHAR2 ,
    x_logical_delete_dt IN DATE ,
    x_org_id IN NUMBER ,
    x_override_dr_rec_account_cd        IN     VARCHAR2    ,
    x_override_dr_rec_ccid              IN     NUMBER      ,
    x_override_cr_rev_account_cd        IN     VARCHAR2    ,
    x_override_cr_rev_ccid              IN     NUMBER      ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_attribute16                       IN     VARCHAR2    ,
    x_attribute17                       IN     VARCHAR2    ,
    x_attribute18                       IN     VARCHAR2    ,
    x_attribute19                       IN     VARCHAR2    ,
    x_attribute20                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_gl_date                           IN     DATE        ,
    x_error_msg                         IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     25-Jun-2003     Bug#2777502,2715795.Added error_msg column.
  smadathi     06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. Removed DEFAULT clause
  vvutukur      29-Jul-2002     Bug#2425767.Removed references to chg_rate,chg_elements,transaction_type
                                columns as these are obsolete.
  ***************************************************************/

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_external_fee_id,
      x_person_id,
      x_status,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_course_cd,
      x_crs_version_number,
      x_transaction_amount,
      x_currency_cd,
      x_exchange_rate,
      x_effective_dt,
      x_comments,
      x_logical_delete_dt,
      x_org_id,
      x_override_dr_rec_account_cd,
      x_override_dr_rec_ccid,
      x_override_cr_rev_account_cd,
      x_override_cr_rev_ccid,
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
      x_gl_date,
      x_error_msg
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF get_pk_for_validation(
          new_references.external_fee_id)  THEN
            fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
      END IF;
--      check_uniqueness;
      check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
--      check_uniqueness;
      check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (
                new_references.external_fee_id)  THEN
               fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
          igs_ge_msg_stack.add;
               app_exception.raise_exception;
             END IF;
--      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;

  END before_dml;

 PROCEDURE after_dml (
    p_action IN VARCHAR2,
   x_rowid IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
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
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END after_dml;

 PROCEDURE insert_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
       x_external_fee_id IN OUT NOCOPY NUMBER,
       x_person_id IN NUMBER,
       x_status IN VARCHAR2,
       x_fee_type IN VARCHAR2,
       x_fee_cal_type IN VARCHAR2,
       x_fee_ci_sequence_number IN NUMBER,
       x_course_cd IN VARCHAR2 ,
       x_crs_version_number IN NUMBER ,
       x_transaction_amount IN NUMBER,
       x_currency_cd IN VARCHAR2,
       x_exchange_rate IN NUMBER,
       x_effective_dt IN DATE,
       x_comments IN VARCHAR2,
       x_logical_delete_dt IN DATE,
       x_org_id IN NUMBER,
    x_override_dr_rec_account_cd        IN     VARCHAR2,
    x_override_dr_rec_ccid              IN     NUMBER,
    x_override_cr_rev_account_cd        IN     VARCHAR2,
    x_override_cr_rev_ccid              IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_error_msg                         IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur      25-Jun-2003     Bug#2777502,2715795.Added error_msg column.
  smadathi      06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE
  vvutukur      29-Jul-2002     Bug#2425767.Removed references to chg_rate,chg_elements,transaction_type
                                columns as these are obsolete.
  ***************************************************************/

    CURSOR c IS SELECT ROWID FROM igs_fi_ext_int_all
             WHERE                 external_fee_id= x_external_fee_id
;
     x_last_update_date DATE ;
     x_last_updated_by NUMBER ;
     x_last_update_login NUMBER ;
     x_request_id NUMBER;
     x_program_id NUMBER;
     x_program_application_id NUMBER;
     x_program_update_date DATE;
 BEGIN
     x_last_update_date := SYSDATE;
      IF(x_mode = 'I') THEN
        x_last_updated_by := 1;
        x_last_update_login := 0;
         ELSIF (x_mode = 'R') THEN
               x_last_updated_by := fnd_global.user_id;
            IF x_last_updated_by IS NULL then
                x_last_updated_by := -1;
            END IF;
            x_last_update_login := fnd_global.login_id;
         IF x_last_update_login IS NULL THEN
            x_last_update_login := -1;
         END IF;
         x_request_id := fnd_global.conc_request_id;
    x_program_id := fnd_global.conc_program_id;
    x_program_application_id := fnd_global.prog_appl_id;
    IF (x_request_id =  -1) THEN
      x_request_id := NULL;
      x_program_id := NULL;
      x_program_application_id := NULL;
      x_program_update_date := NULL;
    ELSE
      x_program_update_date := SYSDATE;
    END IF;
       ELSE
        fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
          app_exception.raise_exception;
       end if;
       SELECT igs_fi_ext_int_s.NEXTVAL
       INTO x_external_fee_id
       FROM DUAL;
   before_dml(
               p_action=>'INSERT',
               x_rowid=>X_ROWID,
               x_external_fee_id=>x_external_fee_id,
               x_person_id=>x_person_id,
               x_status=>x_status,
               x_fee_type=>x_fee_type,
               x_fee_cal_type=>x_fee_cal_type,
               x_fee_ci_sequence_number=>x_fee_ci_sequence_number,
               x_course_cd=>x_course_cd,
               x_crs_version_number=>x_crs_version_number,
               x_transaction_amount=>x_transaction_amount,
               x_currency_cd=>x_currency_cd,
               x_exchange_rate=>x_exchange_rate,
               x_effective_dt=>x_effective_dt,
               x_comments=>x_comments,
               x_logical_delete_dt=>x_logical_delete_dt,
               x_org_id=> igs_ge_gen_003.get_org_id,
      x_override_dr_rec_account_cd        => x_override_dr_rec_account_cd,
      x_override_dr_rec_ccid              => x_override_dr_rec_ccid,
      x_override_cr_rev_account_cd        => x_override_cr_rev_account_cd,
      x_override_cr_rev_ccid              => x_override_cr_rev_ccid,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_gl_date                           => x_gl_date,
      x_error_msg                         => x_error_msg
      );

     INSERT INTO igs_fi_ext_int_all (
                external_fee_id
                ,person_id
                ,status
                ,fee_type
                ,fee_cal_type
                ,fee_ci_sequence_number
                ,course_cd
                ,crs_version_number
                ,transaction_amount
                ,currency_cd
                ,exchange_rate
                ,effective_dt
                ,comments
                ,logical_delete_dt
                ,org_id,
      override_dr_rec_account_cd,
      override_dr_rec_ccid,
      override_cr_rev_account_cd,
      override_cr_rev_ccid,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login
                ,request_id
                ,program_id
                ,program_application_id
                ,program_update_date
                ,gl_date
                ,error_msg
        ) VALUES  (
                new_references.external_fee_id
                ,new_references.person_id
                ,new_references.status
                ,new_references.fee_type
                ,new_references.fee_cal_type
                ,new_references.fee_ci_sequence_number
                ,new_references.course_cd
                ,new_references.crs_version_number
                ,new_references.transaction_amount
                ,new_references.currency_cd
                ,new_references.exchange_rate
                ,new_references.effective_dt
                ,new_references.comments
                ,new_references.logical_delete_dt
                ,new_references.org_id,
                 new_references.override_dr_rec_account_cd,
                 new_references.override_dr_rec_ccid,
                 new_references.override_cr_rev_account_cd,
                 new_references.override_cr_rev_ccid,
                 new_references.attribute_category,
                 new_references.attribute1,
                 new_references.attribute2,
                 new_references.attribute3,
                 new_references.attribute4,
                 new_references.attribute5,
                 new_references.attribute6,
                 new_references.attribute7,
                 new_references.attribute8,
                 new_references.attribute9,
                 new_references.attribute10,
                 new_references.attribute11,
                 new_references.attribute12,
                 new_references.attribute13,
                 new_references.attribute14,
                 new_references.attribute15,
                 new_references.attribute16,
                 new_references.attribute17,
                 new_references.attribute18,
                 new_references.attribute19,
                 new_references.attribute20
                ,x_last_update_date
                ,x_last_updated_by
                ,x_last_update_date
                ,x_last_updated_by
                ,x_last_update_login
                ,x_request_id
                ,x_program_id
                ,x_program_application_id
                ,x_program_update_date
                ,new_references.gl_date
                ,new_references.error_msg
);
                OPEN c;
                 FETCH c INTO x_rowid;
                IF (c%NOTFOUND) THEN
                CLOSE c;
             RAISE NO_DATA_FOUND;
                END IF;
                CLOSE c;
    after_dml (
                p_action => 'INSERT' ,
                x_rowid => X_ROWID );
END insert_row;
 PROCEDURE lock_row (
  x_rowid IN VARCHAR2,
  x_external_fee_id IN NUMBER,
  x_person_id IN NUMBER,
  x_status IN VARCHAR2,
  x_fee_type IN VARCHAR2,
  x_fee_cal_type IN VARCHAR2,
  x_fee_ci_sequence_number IN NUMBER,
  x_course_cd IN VARCHAR2 ,
  x_crs_version_number IN NUMBER ,
  x_transaction_amount IN NUMBER,
  x_currency_cd IN VARCHAR2,
  x_exchange_rate IN NUMBER,
  x_effective_dt IN DATE,
  x_comments IN VARCHAR2,
  x_logical_delete_dt IN DATE,
    x_override_dr_rec_account_cd        IN     VARCHAR2,
    x_override_dr_rec_ccid              IN     NUMBER,
    x_override_cr_rev_account_cd        IN     VARCHAR2,
    x_override_cr_rev_ccid              IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_error_msg                         IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     25-Jun-2003     Bug#2777502,2715795.Added error_msg column.
  smadathi     06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. Removed DEFAULT clause
  vvutukur      29-Jul-2002     Bug#2425767.Removed references to chg_rate,chg_elements,transaction_type
                                columns as these are obsolete.
  ***************************************************************/

   CURSOR c1 IS SELECT
      person_id
,      status
,      fee_type
,      fee_cal_type
,      fee_ci_sequence_number
,      course_cd
,      crs_version_number
,      transaction_amount
,      currency_cd
,      exchange_rate
,      effective_dt
,      comments
,      logical_delete_dt,
        override_dr_rec_account_cd,
        override_dr_rec_ccid,
        override_cr_rev_account_cd,
        override_cr_rev_ccid,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        gl_date,
        error_msg
    FROM igs_fi_ext_int_all
    WHERE ROWID = x_rowid
    FOR UPDATE NOWAIT;
     tlinfo c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%notfound) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
    CLOSE c1;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;
if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.STATUS = X_STATUS)
  AND (tlinfo.FEE_TYPE = X_FEE_TYPE)
  AND (tlinfo.FEE_CAL_TYPE = X_FEE_CAL_TYPE)
  AND (tlinfo.FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER)

-- The columns course_cd and crs_version_number are obsolete.
-- Hence, we logically ignore them, as a part of changes due to Revised DLD
-- IGSFIDL3: Version 3

  AND (tlinfo.TRANSACTION_AMOUNT = X_TRANSACTION_AMOUNT)
  AND (tlinfo.CURRENCY_CD = X_CURRENCY_CD)
  AND (tlinfo.EXCHANGE_RATE = X_EXCHANGE_RATE)
  AND ((tlinfo.EFFECTIVE_DT = X_EFFECTIVE_DT)
            OR ((tlinfo.EFFECTIVE_DT is null)
                AND (X_EFFECTIVE_DT is null)))
  AND ((tlinfo.COMMENTS = X_COMMENTS)
            OR ((tlinfo.COMMENTS is null)
                AND (X_COMMENTS is null)))
  AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
            OR ((tlinfo.LOGICAL_DELETE_DT is null)
                AND (X_LOGICAL_DELETE_DT is null)))

        AND ((tlinfo.override_dr_rec_account_cd = x_override_dr_rec_account_cd) OR ((tlinfo.override_dr_rec_account_cd IS NULL) AND (X_override_dr_rec_account_cd IS NULL)))
        AND ((tlinfo.override_dr_rec_ccid = x_override_dr_rec_ccid) OR ((tlinfo.override_dr_rec_ccid IS NULL) AND (X_override_dr_rec_ccid IS NULL)))
        AND ((tlinfo.override_cr_rev_account_cd = x_override_cr_rev_account_cd) OR ((tlinfo.override_cr_rev_account_cd IS NULL) AND (X_override_cr_rev_account_cd IS NULL)))
        AND ((tlinfo.override_cr_rev_ccid = x_override_cr_rev_ccid) OR ((tlinfo.override_cr_rev_ccid IS NULL) AND (X_override_cr_rev_ccid IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND ((TRUNC(tlinfo.gl_date)  = TRUNC(x_gl_date))     OR ((tlinfo.gl_date IS NULL)     AND (X_gl_date IS NULL)))
        AND ((tlinfo.error_msg = x_error_msg) OR ((tlinfo.error_msg IS NULL) AND (x_error_msg IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END IF;
  RETURN;
END lock_row;

 PROCEDURE update_row (
    x_rowid IN  VARCHAR2,
    x_EXTERNAL_FEE_ID IN NUMBER,
    x_PERSON_ID IN NUMBER,
    x_STATUS IN VARCHAR2,
    x_FEE_TYPE IN VARCHAR2,
    x_FEE_CAL_TYPE IN VARCHAR2,
    x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
    x_COURSE_CD IN VARCHAR2 ,
    x_CRS_VERSION_NUMBER IN NUMBER ,
    x_TRANSACTION_AMOUNT IN NUMBER,
    x_CURRENCY_CD IN VARCHAR2,
    x_EXCHANGE_RATE IN NUMBER,
    x_EFFECTIVE_DT IN DATE,
    x_COMMENTS IN VARCHAR2,
    x_LOGICAL_DELETE_DT IN DATE,
    x_override_dr_rec_account_cd        IN     VARCHAR2,
    x_override_dr_rec_ccid              IN     NUMBER,
    x_override_cr_rev_account_cd        IN     VARCHAR2,
    x_override_cr_rev_ccid              IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_error_msg                         IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     25-Jun-2003     Bug#2777502,2715795.Added error_msg column.
  smadathi     06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. Removed DEFAULT clause
  vvutukur      29-Jul-2002     Bug#2425767.Removed references to chg_rate,chg_elements,transaction_type
                                columns as these are obsolete.
  ***************************************************************/

     x_last_update_date DATE ;
     x_last_updated_by NUMBER ;
     x_last_update_login NUMBER ;
     x_request_id NUMBER;
     x_program_id NUMBER;
     x_program_application_id NUMBER;
     x_program_update_date DATE;
 BEGIN
     x_last_update_date := SYSDATE;
      IF (X_MODE = 'I') THEN
        x_last_updated_by := 1;
        x_last_update_login := 0;
         ELSIF (x_mode = 'R') THEN
               x_last_updated_by := fnd_global.user_id;
            IF x_last_updated_by IS NULL THEN
                x_last_updated_by := -1;
            END IF;
            x_last_update_login := fnd_global.login_id;
         IF x_last_update_login IS NULL THEN
            x_last_update_login := -1;
          END IF;
       ELSE
        fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
          app_exception.raise_exception;
       END IF;
   before_dml(
                p_action=>'UPDATE',
                x_rowid=>X_ROWID,
               x_external_fee_id=>X_EXTERNAL_FEE_ID,
               x_person_id=>X_PERSON_ID,
               x_status=>X_STATUS,
               x_fee_type=>X_FEE_TYPE,
               x_fee_cal_type=>X_FEE_CAL_TYPE,
               x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
               x_course_cd=>X_COURSE_CD,
               x_crs_version_number=>X_CRS_VERSION_NUMBER,
               x_transaction_amount=>X_TRANSACTION_AMOUNT,
               x_currency_cd=>X_CURRENCY_CD,
               x_exchange_rate=>X_EXCHANGE_RATE,
               x_effective_dt=>X_EFFECTIVE_DT,
               x_comments=>X_COMMENTS,
               x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
      x_override_dr_rec_account_cd        => x_override_dr_rec_account_cd,
      x_override_dr_rec_ccid              => x_override_dr_rec_ccid,
      x_override_cr_rev_account_cd        => x_override_cr_rev_account_cd,
      x_override_cr_rev_ccid              => x_override_cr_rev_ccid,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_gl_date                           => x_gl_date,
      x_error_msg                         => x_error_msg
      );
   IF (x_mode = 'R') THEN
         x_request_id := fnd_global.conc_request_id;
    x_program_id := fnd_global.conc_program_id;
    x_program_application_id := fnd_global.prog_appl_id;
    IF (x_request_id =  -1) THEN
      x_request_id := old_references.request_id;
      x_program_id := old_references.program_id;
      x_program_application_id := old_references.program_application_id;
      x_program_update_date := old_references.program_update_date;
    ELSE
      x_program_update_date := SYSDATE;
    END IF;
    END IF;
   UPDATE igs_fi_ext_int_all SET
      person_id =  NEW_REFERENCES.person_id,
      status =  NEW_REFERENCES.status,
      fee_type =  NEW_REFERENCES.fee_type,
      fee_cal_type =  NEW_REFERENCES.fee_cal_type,
      fee_ci_sequence_number =  NEW_REFERENCES.fee_ci_sequence_number,
      course_cd =  NEW_REFERENCES.course_cd,
      crs_version_number =  NEW_REFERENCES.crs_version_number,
      transaction_amount =  NEW_REFERENCES.transaction_amount,
      currency_cd =  NEW_REFERENCES.currency_cd,
      exchange_rate =  NEW_REFERENCES.exchange_rate,
      effective_dt =  NEW_REFERENCES.effective_dt,
      comments =  NEW_REFERENCES.comments,
      logical_delete_dt =  NEW_REFERENCES.logical_delete_dt,
        override_dr_rec_account_cd        = new_references.override_dr_rec_account_cd,
        override_dr_rec_ccid              = new_references.override_dr_rec_ccid,
        override_cr_rev_account_cd        = new_references.override_cr_rev_account_cd,
        override_cr_rev_ccid              = new_references.override_cr_rev_ccid,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        request_id                        = X_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        gl_date                           = new_references.gl_date,
	error_msg                         = new_references.error_msg
          WHERE ROWID = x_rowid;
        IF (SQL%NOTFOUND) THEN
                RAISE NO_DATA_FOUND;
        END IF;

 after_dml (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );
END update_row;
 PROCEDURE add_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
       x_external_fee_id IN OUT NOCOPY NUMBER,
       x_person_id IN NUMBER,
       x_status IN VARCHAR2,
       x_fee_type IN VARCHAR2,
       x_fee_cal_type IN VARCHAR2,
       x_fee_ci_sequence_number IN NUMBER,
       x_course_cd IN VARCHAR2 ,
       x_crs_version_number IN NUMBER ,
       x_transaction_amount IN NUMBER,
       x_currency_cd IN VARCHAR2,
       x_exchange_rate IN NUMBER,
       x_effective_dt IN DATE,
       x_comments IN VARCHAR2,
       x_logical_delete_dt IN DATE,
       x_org_id IN NUMBER,
    x_override_dr_rec_account_cd        IN     VARCHAR2,
    x_override_dr_rec_ccid              IN     NUMBER,
    x_override_cr_rev_account_cd        IN     VARCHAR2,
    x_override_cr_rev_ccid              IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_gl_date                           IN     DATE,
    x_error_msg                         IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     25-Jun-2003     Bug#2777502,2715795.Added error_msg column.
  smadathi     06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. Removed DEFAULT clause
  vvutukur      29-Jul-2002     Bug#2425767.Removed references to chg_rate,chg_elements,transaction_type
                                columns as these are obsolete.
  ***************************************************************/

    CURSOR c1 IS SELECT ROWID FROM igs_fi_ext_int_all
             WHERE     external_fee_id= x_external_fee_id
;
BEGIN
        OPEN c1;
                FETCH c1 INTO x_rowid;
        IF (c1%NOTFOUND) THEN
        CLOSE c1;
    insert_row (
      x_rowid,
       X_external_fee_id,
       X_person_id,
       X_status,
       X_fee_type,
       X_fee_cal_type,
       X_fee_ci_sequence_number,
       X_course_cd,
       X_crs_version_number,
       X_transaction_amount,
       X_currency_cd,
       X_exchange_rate,
       X_effective_dt,
       X_comments,
       X_logical_delete_dt,
       x_org_id,
        x_override_dr_rec_account_cd,
        x_override_dr_rec_ccid,
        x_override_cr_rev_account_cd,
        x_override_cr_rev_ccid,
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
        x_mode,
        x_gl_date,
	x_error_msg
       );
     RETURN;
        END IF;
           CLOSE c1;
update_row (
       x_rowid,
       x_external_fee_id,
       x_person_id,
       x_status,
       x_fee_type,
       x_fee_cal_type,
       x_fee_ci_sequence_number,
       x_course_cd,
       x_crs_version_number,
       x_transaction_amount,
       x_currency_cd,
       x_exchange_rate,
       x_effective_dt,
       x_comments,
       x_logical_delete_dt,
      x_override_dr_rec_account_cd,
      x_override_dr_rec_ccid,
      x_override_cr_rev_account_cd,
      x_override_cr_rev_ccid,
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
      x_mode ,
      x_gl_date,
      x_error_msg
       );
END add_row;

PROCEDURE delete_row (
  x_rowid IN VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN
before_dml (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 DELETE FROM igs_fi_ext_int_all
 WHERE ROWID = x_rowid;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
after_dml (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
END delete_row;
END igs_fi_ext_int_pkg;

/
