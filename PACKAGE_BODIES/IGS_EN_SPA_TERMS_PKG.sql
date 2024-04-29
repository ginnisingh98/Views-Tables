--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPA_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPA_TERMS_PKG" AS
/* $Header: IGSEI76B.pls 120.8 2005/10/07 03:06:20 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_spa_terms%ROWTYPE;
  new_references igs_en_spa_terms%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_term_record_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
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
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_plan_sht_status                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_spa_terms
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.term_record_id                    := x_term_record_id;
    new_references.person_id                         := x_person_id;
    new_references.program_cd                        := x_program_cd;
    new_references.program_version                   := x_program_version;
    new_references.acad_cal_type                     := x_acad_cal_type;
    new_references.term_cal_type                     := x_term_cal_type;
    new_references.term_sequence_number              := x_term_sequence_number;
    new_references.key_program_flag                  := NVL(x_key_program_flag,'N');
    new_references.location_cd                       := x_location_cd;
    new_references.attendance_mode                   := x_attendance_mode;
    new_references.attendance_type                   := x_attendance_type;
    new_references.fee_cat                           := x_fee_cat;
    new_references.coo_id                            := x_coo_id;
    new_references.class_standing_id                 := x_class_standing_id;
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
    new_references.plan_sht_status                   := x_plan_sht_status;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;

  PROCEDURE Check_Parent_Existance AS
  /*
  ||  Created By : ckasu
  ||  Created On : 04-DEC-2003
  ||  Purpose : Checks for the existance of Parent record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


   IF (((old_references.person_id = new_references.person_id) AND
         (old_references.program_cd = new_references.program_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.program_cd IS NULL))) THEN
      NULL;
   ELSIF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.program_cd
        )       THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   IF (((old_references.TERM_CAL_TYPE = new_references.TERM_CAL_TYPE) AND
         (old_references.TERM_SEQUENCE_NUMBER = new_references.TERM_SEQUENCE_NUMBER)) OR
        ((new_references.TERM_CAL_TYPE IS NULL) OR
         (new_references.TERM_SEQUENCE_NUMBER IS NULL))) THEN
       NULL;
   ELSIF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
                         new_references.TERM_CAL_TYPE,
                         new_references.TERM_SEQUENCE_NUMBER
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
   END IF;

   IF (((old_references.coo_id = new_references.coo_id)) OR
          ((new_references.coo_id IS NULL))) THEN
        NULL;
      ELSE
        IF NOT  IGS_PS_OFR_OPT_PKG.Get_UK_For_Validation (
          new_references.coo_id
        ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
       END IF;
   END IF;

   IF (((old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_cat IS NULL))) THEN
       NULL;
   ELSIF NOT IGS_FI_FEE_CAT_PKG.Get_PK_For_Validation (
         new_references.fee_cat
         ) THEN
           Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
   END IF;

   IF ((old_references.CLASS_STANDING_ID = new_references.CLASS_STANDING_ID)OR
        (new_references.CLASS_STANDING_ID IS NULL)) THEN
      NULL;
   ELSIF NOT IGS_PR_CLASS_STD_PKG.Get_PK_For_Validation (
       new_references.CLASS_STANDING_ID
       ) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
   END IF;


  END Check_Parent_Existance;

  PROCEDURE GET_FK_IGS_CA_INST (
    X_CAL_TYPE IN VARCHAR2,
    X_SEQUENCE_NUMBER IN NUMBER
    ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 04-DEC-2003
  ||  Purpose : Validates the Foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  (reverse chronological order - newest change first)
  ||  Who             When            What
  ||  ckasu        26-May-2004     Modified Message name from IGS_EN_ SPAT _CI_FK
  ||                               to IGS_EN_SPAT_CI_FK.
  ||
  */
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   IGS_EN_SPA_TERMS
      WHERE  TERM_CAL_TYPE   = X_CAL_TYPE  AND
             TERM_SEQUENCE_NUMBER = X_SEQUENCE_NUMBER ;
    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SPAT_CI_FK');
      Igs_Ge_Msg_Stack.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 04-DEC-2003
  ||  Purpose : Validates the Foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SPA_TERMS
      WHERE    person_id = x_person_id
      AND      program_cd = x_course_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SPAT_SPA_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE GET_FK_IGS_PR_CLASS_STD(
    X_IGS_PR_CLASS_STD_ID IN NUMBER
    ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 04-DEC-2003
  ||  Purpose : Validates the Foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM IGS_EN_SPA_TERMS
      WHERE CLASS_STANDING_ID = X_IGS_PR_CLASS_STD_ID;

    lv_cur cur_rowid%ROWTYPE;

    BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_cur;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SPAT_CS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
   END GET_FK_IGS_PR_CLASS_STD;

  PROCEDURE GET_FK_IGS_FI_FEE_CAT (
    x_fee_cat IN VARCHAR2
    ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 04-DEC-2003
  ||  Purpose : Validates the Foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SPA_TERMS
      WHERE    fee_cat = x_fee_cat ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SPAT_FC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_FI_FEE_CAT;

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
      x_coo_id IN VARCHAR2
     ) AS
   /*
  ||  Created By : ckasu
  ||  Created On : 04-DEC-2003
  ||  Purpose : Validates the Foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SPA_TERMS
      WHERE    coo_id = x_coo_id;
    lv_rowid cur_rowid%ROWTYPE;
    BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SPAT_COO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_UFK_IGS_PS_OFR_OPT;


  FUNCTION get_pk_for_validation (
    x_term_record_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spa_terms
      WHERE    term_record_id = x_term_record_id
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
    x_person_id                         IN    NUMBER,
    x_program_cd                        IN    VARCHAR2,
    x_term_cal_type                     IN    VARCHAR2,
    x_term_sequence_number      IN    NUMBER

  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Validates the Unique Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_rowid is
    SELECT      rowid
    FROM        igs_en_spa_terms
    WHERE       x_person_id     = person_id  AND
                x_program_cd    = program_cd AND
                x_term_cal_type = term_cal_type AND
                x_term_sequence_number = term_sequence_number
    FOR UPDATE NOWAIT;

  lv_rowid  cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid into lv_rowid;

    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN TRUE;
    ELSE
      CLOSE cur_rowid;
      RETURN FALSE;
    END IF;

  END get_uk_for_validation;

 --  code added by ckasu as a part of bug no#3631488
 PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN
    ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 26-MAY-2004
  ||  Change History :
  || (reverse chronological order - newest change first)
  || Who             When            What
  ||ckasu        26-May-2004       Procedure Created inorder to encapsulate logic
  ||                               to create TODO record in master and detail table
  ||                               as a part of bug#3631488
  */
        v_sequence_number       NUMBER;
  BEGIN
        -- Log an entry in the IGS_PE_STD_TODO table, indicating that a fee re-assessment
        -- is required.
        IF p_inserting OR p_updating THEN

                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        new_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');
        ELSE

                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        old_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');


        END IF;
        --  creates a entry in Child Table.
        IGS_GE_GEN_003.GENP_INS_TODO_REF(
                                        p_person_id => new_references.person_id,
                                        p_s_student_todo_type => 'FEE_RECALC',
                                        p_sequence_number => v_sequence_number,
                                        p_cal_type  => new_references.term_cal_type,
                                        p_ci_sequence_number  =>new_references.term_sequence_number,
                                        p_course_cd => new_references.program_cd,
                                        p_unit_cd  => null,
                                        p_uoo_id  =>  null,
                                        p_other_reference  =>  null
                                        );



END BeforeRowInsertUpdate;
-- end of code added by ckasu


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_term_record_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
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
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_plan_sht_status                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  (reverse chronological order - newest change first)
  ||  Who             When            What
  ||
  ||  ckasu        26-May-2004     Modified before_dml Procedure  by adding call to
  ||                               beforeinsertupdate Procedure ,inorder to create
  ||                               TODO record in master and detail table as a part
  ||                               of bug#3631488
  ||
  */

  Cursor cur_rowid(p_coo_id NUMBER,p_term_cal_type VARCHAR2,p_term_sequence_number VARCHAR2) is

                  SELECT 'x'
                  FROM igs_ps_ofr_opt cop,
                       igs_ca_inst_rel cr
                  WHERE cop.cal_type = cr.sup_cal_type AND
                        cop.coo_id = p_coo_id AND
                        cr.sub_cal_type = p_term_cal_type AND
                        cr.sub_ci_sequence_number = p_term_sequence_number;


  l_val cur_rowid%ROWTYPE;

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_term_record_id,
      x_person_id,
      x_program_cd,
      x_program_version,
      x_acad_cal_type,
      x_term_cal_type,
      x_term_sequence_number,
      x_key_program_flag,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_fee_cat,
      x_coo_id,
      x_class_standing_id,
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
      x_plan_sht_status
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      IF ( get_pk_for_validation(
             new_references.term_record_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

      -- Code added by ckasu as a part of
      -- bug no #3631488 inorder to create TODO record in both Parent
      -- and child table when Term Record is Created

      BeforeRowInsertUpdate ( p_inserting => TRUE,
                              p_updating  => FALSE
                             );
      -- end of code added by ckasu
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.term_record_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
     ELSIF (p_action = 'DELETE') THEN
      check_child_existence(new_references.person_id,new_references.program_cd);

     ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existence(new_references.person_id,new_references.program_cd);

     ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Insert.

     -- Code added by ckasu as a part of
     -- bug no #3631488 inorder to create TODO record in both Parent
     -- and child table when Term Record is Updated
        BeforeRowInsertUpdate ( p_inserting => FALSE,
                                p_updating  => TRUE
                              );
     -- end of code added by ckasu
        IF( new_references.coo_id <> old_references.coo_id) THEN
           OPEN cur_rowid(new_references.coo_id ,new_references.term_cal_type,new_references.term_sequence_number);
           FETCH cur_rowid INTO l_val;
           IF (cur_rowid%NOTFOUND) THEN
              CLOSE cur_rowid;
              fnd_message.set_name('IGS','IGS_AD_NOMINATED_PRG_NOTEXIST');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
           END IF;
           CLOSE cur_rowid;
        END IF;

     END IF;


  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_term_record_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
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
    x_plan_sht_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := sysdate;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := sysdate;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPA_TERMS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_term_record_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_term_record_id                    => x_term_record_id,
      x_person_id                         => x_person_id,
      x_program_cd                        => x_program_cd,
      x_program_version                   => x_program_version,
      x_acad_cal_type                     => x_acad_cal_type,
      x_term_cal_type                     => x_term_cal_type,
      x_term_sequence_number              => x_term_sequence_number,
      x_key_program_flag                  => x_key_program_flag,
      x_location_cd                       => x_location_cd,
      x_attendance_mode                   => x_attendance_mode,
      x_attendance_type                   => x_attendance_type,
      x_fee_cat                           => x_fee_cat,
      x_coo_id                            => x_coo_id,
      x_class_standing_id                 => x_class_standing_id,
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
      x_plan_sht_status                   => x_plan_sht_status
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_en_spa_terms (
      term_record_id,
      person_id,
      program_cd,
      program_version,
      acad_cal_type,
      term_cal_type,
      term_sequence_number,
      key_program_flag,
      location_cd,
      attendance_mode,
      attendance_type,
      fee_cat,
      coo_id,
      class_standing_id,
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
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      plan_sht_status
    ) VALUES (
      igs_en_spa_terms_s.NEXTVAL,
      new_references.person_id,
      new_references.program_cd,
      new_references.program_version,
      new_references.acad_cal_type,
      new_references.term_cal_type,
      new_references.term_sequence_number,
      new_references.key_program_flag,
      new_references.location_cd,
      new_references.attendance_mode,
      new_references.attendance_type,
      new_references.fee_cat,
      new_references.coo_id,
      new_references.class_standing_id,
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
      new_references.attribute20,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.plan_sht_status
    ) RETURNING ROWID, term_record_id INTO x_rowid, x_term_record_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



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
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_term_record_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
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
    x_plan_sht_status                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        program_cd,
        program_version,
        acad_cal_type,
        term_cal_type,
        term_sequence_number,
        key_program_flag,
        location_cd,
        attendance_mode,
        attendance_type,
        fee_cat,
        coo_id,
        class_standing_id,
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
        plan_sht_status
      FROM  igs_en_spa_terms
      WHERE rowid = x_rowid
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

    IF (
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.program_cd = x_program_cd)
        AND (tlinfo.program_version = x_program_version)
        AND (tlinfo.acad_cal_type = x_acad_cal_type)
        AND (tlinfo.term_cal_type = x_term_cal_type)
        AND (tlinfo.term_sequence_number = x_term_sequence_number)
        AND (tlinfo.key_program_flag = x_key_program_flag)
        AND (tlinfo.location_cd = x_location_cd)
        AND (tlinfo.attendance_mode = x_attendance_mode)
        AND (tlinfo.attendance_type = x_attendance_type)
        AND ((tlinfo.fee_cat = x_fee_cat) OR ((tlinfo.fee_cat IS NULL) AND (X_fee_cat IS NULL)))
        AND (tlinfo.coo_id = x_coo_id)
        AND ((tlinfo.class_standing_id = x_class_standing_id) OR ((tlinfo.class_standing_id IS NULL) AND (X_class_standing_id IS NULL)))
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
        AND (tlinfo.plan_sht_status = x_plan_sht_status)
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
    x_rowid                             IN     VARCHAR2,
    x_term_record_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
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
    x_plan_sht_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := sysdate;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPA_TERMS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_term_record_id                    => x_term_record_id,
      x_person_id                         => x_person_id,
      x_program_cd                        => x_program_cd,
      x_program_version                   => x_program_version,
      x_acad_cal_type                     => x_acad_cal_type,
      x_term_cal_type                     => x_term_cal_type,
      x_term_sequence_number              => x_term_sequence_number,
      x_key_program_flag                  => x_key_program_flag,
      x_location_cd                       => x_location_cd,
      x_attendance_mode                   => x_attendance_mode,
      x_attendance_type                   => x_attendance_type,
      x_fee_cat                           => x_fee_cat,
      x_coo_id                            => x_coo_id,
      x_class_standing_id                 => x_class_standing_id,
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
      x_plan_sht_status                   => x_plan_sht_status
    );

    IF (X_MODE IN ('R', 'S')) THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := sysdate;
      END IF;
    END IF;

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_en_spa_terms
      SET
        person_id                         = new_references.person_id,
        program_cd                        = new_references.program_cd,
        program_version                   = new_references.program_version,
        acad_cal_type                     = new_references.acad_cal_type,
        term_cal_type                     = new_references.term_cal_type,
        term_sequence_number              = new_references.term_sequence_number,
        key_program_flag                  = new_references.key_program_flag,
        location_cd                       = new_references.location_cd,
        attendance_mode                   = new_references.attendance_mode,
        attendance_type                   = new_references.attendance_type,
        fee_cat                           = new_references.fee_cat,
        coo_id                            = new_references.coo_id,
        class_standing_id                 = new_references.class_standing_id,
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
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        plan_sht_status                   = new_references.plan_sht_status
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



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
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_term_record_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
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
    x_plan_sht_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_spa_terms
      WHERE    term_record_id                    = x_term_record_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_term_record_id,
        x_person_id,
        x_program_cd,
        x_program_version,
        x_acad_cal_type,
        x_term_cal_type,
        x_term_sequence_number,
        x_key_program_flag,
        x_location_cd,
        x_attendance_mode,
        x_attendance_type,
        x_fee_cat,
        x_coo_id,
        x_class_standing_id,
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
        x_plan_sht_status,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_term_record_id,
      x_person_id,
      x_program_cd,
      x_program_version,
      x_acad_cal_type,
      x_term_cal_type,
      x_term_sequence_number,
      x_key_program_flag,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_fee_cat,
      x_coo_id,
      x_class_standing_id,
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
      x_plan_sht_status,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : ckasu
  ||  Created On : 18-NOV-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_en_spa_terms
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  END delete_row;

 PROCEDURE check_child_existence (
  x_person_id IN NUMBER,
  x_course_cd IN VARCHAR2
 ) AS
 BEGIN
    igs_en_plan_units_pkg.get_fk_igs_en_stdnt_ps_att(x_person_id,x_course_cd);
 END check_child_existence;

END igs_en_spa_terms_pkg;

/
